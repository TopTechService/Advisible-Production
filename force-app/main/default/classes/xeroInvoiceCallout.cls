/*
 * @Author			: Dan Peaper, daniel@toptechservice.com.au
 * 
 * @Date Completed	: 01/01/2021
 * 
 * @Description		: This class is responsible for the api callout to Xero and the deserialization of invoice data.
*/
global with sharing class xeroInvoiceCallout {

    public static HttpCalloutMock mock = null;
    
    @future (callout=true)
    public static Void executeCallout(string method, string resourceName, string requestBody) {
        
        //Deserialize requestbody to retrieve the Salesforce Ids.
        List<XeroInvoiceWrapper.cls_Invoices> deserializedInvoices = (List<XeroInvoiceWrapper.cls_Invoices>)JSON.deserialize(requestBody,List<XeroInvoiceWrapper.cls_Invoices>.class);
        List<String> salesforceIDlist = new List<String>();
        
        for(XeroInvoiceWrapper.cls_Invoices deserializedInvoice : deserializedInvoices) {
            system.debug('Dan-SF_Id:'+deserializedInvoice.SalesforceId);
            salesforceIDlist.add(deserializedInvoice.SalesforceId);
        }

        requestBody = '{"Invoices": ' + requestBody + '}';

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
        HttpResponse response;
        if(test.isRunningTest() && (mock != null)) {
            xeroInvoiceCalloutTestMock calloutMock = New xeroInvoiceCalloutTestMock();
            response = calloutMock.respond(request);
        } Else {
            response = new Http().send(request);
        }
        

        system.debug('### Xero Response Status: ' + response.getStatusCode() + ': ' + response.getStatus());
        system.debug('### Xero Response Body: ' + response.getBody());

        //If the post was successful parse the JSON Response
        if(response.getStatusCode() == 200) {
            List<String> xeroIDlist = New List<String>();
            Map<Id, XeroInvoiceWrapper.cls_Invoices> mapSfInvToXeroInv = New Map<Id, XeroInvoiceWrapper.cls_Invoices>();
            JSONParser parser = JSON.createParser(response.getBody());
            Integer j = 0;
            While(parser.nextToken() != null) {
                //Start at the array of xero invoices
                System.debug('Dan-j:'+j);
                if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    While(parser.nextToken() != null) {
                        //Advance tot eh start object marker to
                        //find the next xero invoice object
                        if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            //Read entire xero invoice object
                            XeroInvoiceWrapper.cls_Invoices xInvoice = (XeroInvoiceWrapper.cls_Invoices)parser.readValueAs(XeroInvoiceWrapper.cls_Invoices.class);
                            system.debug('Dan- Invoice ID:' + xInvoice.InvoiceID);
                            system.debug('Dan- Invoice Obj:' + xInvoice);
                            if(salesforceIDlist.size() > 0){
	                            mapSfInvToXeroInv.put(salesforceIDlist[j], xInvoice);
                            }
                            j++;
                        }
                    }
                }
            }
            updateInvRecDetail.updateInvoice(mapSfInvToXeroInv);
        }
    }
}