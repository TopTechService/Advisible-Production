global with sharing class getXeroInvoices {
    
    public static HttpCalloutMock mock = null;
    
    @future(callout = true)
    public static void executeCallout() {

        Integer pageNumber = 1;
        try {
            
            //Get the datetime when we last checked Xero from the custom setting
            Xero_Last_Response_Time__c xeroLastResponse = Xero_Last_Response_Time__c.getValues('InvoiceResponseTime');
            string lastResponseTime = string.valueOfGmt(xeroLastResponse.Last_Response_Time__c);
            lastResponseTime = lastResponseTime.left(10) + 'T' + lastResponseTime.right(8);
            
            //Initiate a new request
            HttpRequest request = New HttpRequest();
            request.setMethod('GET');
            request.setHeader('Accept', 'application/json');
            request.setHeader('If-Modified-Since', lastResponseTime);
            request.setTimeout(120000);
            
            // Set the Xero Tenant ID
            List<Xero_Setting__c> XeroTenantIds = New List<Xero_Setting__c>([SELECT Xero_Tenant_Id__c FROM Xero_Setting__c]);
            String XeroTenantId = XeroTenantIds[0]?.Xero_Tenant_Id__c;
            request.setHeader('xero-tenant-id', XeroTenantId);
            
            system.debug('### Xero Callout Endpoint: ' + request.getEndpoint());
            system.debug('### Xero Callout Method: ' + request.getMethod());
            system.debug('### Xero Callout Body: ' + request.getBody());
            
            List<xeroInvoiceWrapper.cls_Invoices> invoicesToUpdate = New List<xeroInvoiceWrapper.cls_Invoices>();
            xeroInvoiceWrapper invoiceWrapObj = New xeroInvoiceWrapper();
            
            Do {
                request.setEndpoint('callout:Xero/api.xro/2.0/invoices?Page=' + String.ValueOf(pageNumber));
                HttpResponse response = new HttpResponse();
                system.debug('Test:' + test.isRunningTest());
                system.debug('Mock:' + mock);
                if(test.isRunningTest()) {
                    xeroInvoiceCalloutTestMock calloutMock = New xeroInvoiceCalloutTestMock();
                    response = calloutMock.respond(request);
                } Else {
                    response = new Http().send(request);
                }
                system.debug('Time:' + lastResponseTime);
                system.debug('Response Status Code:' + response.getStatusCode());
                system.debug('Response Body:' + response.getBody());
                
                invoiceWrapObj = (xeroInvoiceWrapper) JSON.deserialize(response.getBody(), xeroInvoiceWrapper.class);
                If(invoiceWrapObj.Invoices.size()==100) {
                    pageNumber++;
                }
                System.debug('Count of invoices:'+invoiceWrapObj.Invoices.size()+'Page:'+string.valueOf(pageNumber));
                
                for(xeroInvoiceWrapper.cls_Invoices xeroInvoice : invoiceWrapObj.Invoices) {
                    system.debug('Id:' + xeroInvoice.InvoiceID);
                    invoicesToUpdate.add(xeroInvoice);
                }
            } While(pageNumber < 100 && invoiceWrapObj != null && invoiceWrapObj.Invoices.size() == 100);
            
            updateInvoicesFromXero.updateInvoices(invoicesToUpdate);
            
        } catch(Exception e) {
                XeroErrorHandling.insertErrorDebugLog(e);
        }
    }
}