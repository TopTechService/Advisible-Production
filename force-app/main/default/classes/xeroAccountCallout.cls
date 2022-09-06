/*
 * @Author			: Dan Peaper, daniel@toptechservice.com.au
 * 
 * @Date Completed	: 18/12/2020
 * 
 * @Description		: This class is responsible for the api callout to Xero and the deserialization of data.
*/
global with sharing class xeroAccountCallout {

    public static HTTPCalloutMock mock = null;
    
    @future (callout=true)
    public static void executeCallout(String method, String resourceName, String requestBody) {
        
        //Deserialize requestbody to retrieve the Salesforce Ids.
        List<XeroContactWrapper.cls_Contacts> deserializedContacts = (List<XeroContactWrapper.cls_Contacts>)JSON.deserialize(requestBody,List<XeroContactWrapper.cls_Contacts>.class);
        List<String> salesforceIDlist = new List<String>();
        
        for(XeroContactWrapper.cls_Contacts deserializedContact : deserializedContacts) {
            salesforceIDlist.add(deserializedContact.SalesforceId);
        }
        
        List<Account> acctsFromTrigger = [Select Id, Name, Xero_eMail__c, Xero_First_Name__c, Xero_Last_Name__c 
                                         FROM Account
                                         WHERE Id IN :salesforceIDlist];
        
        requestBody = '{"Contacts": ' + requestBody + '}'; 
        
      
        
        // Instantiate a new request
        HttpRequest request = new HttpRequest();

        // Set request parameters
        request.setMethod(method);

        // Set the endpoint using the named credential
        request.setEndpoint(
            'callout:Xero/' + 
            (resourceName.equalsIgnoreCase('connections') ? 'connections': 'api.xro/2.0/' + resourceName)
        );
        
        // Accept a JSON response from the call
        request.setHeader('Accept', 'application/json');

        // Set the Xero Tenant ID
        List<Xero_Setting__c> XeroTenantIds = New List<Xero_Setting__c>([SELECT Xero_Tenant_Id__c FROM Xero_Setting__c]);
        String XeroTenantId = XeroTenantIds[0]?.Xero_Tenant_Id__c;
        request.setHeader('xero-tenant-id', XeroTenantId);
        system.debug('xeroTenant Id: ' + XeroTenantId);

        // Set max timeout
        request.setTimeout(120000);

        // If the callout includes a body (POST and PUT requests)
        if (String.isNotBlank(requestBody)) {

            // Set the body to the callout
            request.setBody(requestBody);

            // Set the content to XML
            request.setHeader('Content-Type', 'application/json');
        }
        
        system.debug('### Xero Callout Endpoint: ' + request.getEndpoint());
        system.debug('### Xero Callout Method: ' + request.getMethod());
        system.debug('### Xero Callout Body: ' + request.getBody());

        // Execute the callout
        HTTPResponse response;
        if(test.isRunningTest() && (mock != null)) {
            pushAccountToXeroContactTestMock calloutMock = New pushAccountToXeroContactTestMock();
            response = calloutMock.respond(request);
        } Else {
            response = new Http().send(request);
        }

        system.debug('### Xero Response Status: ' + response.getStatusCode() + ': ' + response.getStatus());
        system.debug('### Xero Response Body: ' + response.getBody());
        
        //If the post was successful Parse entire JSON response.
        if(response.getStatusCode() == 200) {
            List<String> xeroIDlist = New List<String>();
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                // Start at the array of xero contacts.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        // find next xero contact object. 
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT){
                            // Read entire xero contact object
                            XeroContactWrapper.cls_Contacts xContact = (XeroContactWrapper.cls_Contacts)parser.readValueAs(XeroContactWrapper.cls_Contacts.class);
                            system.debug('Dan - Contact ID: ' + xContact.ContactID);
                            xeroIDlist.add(xContact.ContactID);
                        }
                    }
                }
            }
            System.debug('Dan - List of IDs: ' + xeroIDlist);
            Map<String, Account> mapXeroContactToAccount = New Map<String, Account>();
            Integer i = 0;
            for(String xc : xeroIDlist){
                mapXeroContactToAccount.put(xc, acctsFromTrigger[i]);
                i++;
            }
            
            createXeroAffiliateRecord.createAffiliate(mapXeroContactToAccount);
        }
        
    }

}