@isTest
global class xeroInvoiceCalloutTestMock implements HTTPCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse response = new HttpResponse();

        if(req.getMethod() == 'POST' && req.getEndpoint().contains('Invoices')){
            response.setBody(response1(req));
        } else {
            response.setBody(response2(req));
        }

        response.setHeader('Date', 'Sun, 3 Jan 2021 17:05:28 GMT');
        response.setStatusCode(200);

        return response;
    }

    private static string response1(HTTPRequest req) {
    
        System.assertEquals('callout:Xero/api.xro/2.0/Invoices', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        String xeroResponseBody = '{"Id": "bf2e059b-fa35-4160-965c-362bcb0eb1ce", '+
                                '"Status": "OK", '+
                                '"ProviderName": "Salesforce",'+
                                '"DateTimeUTC": "/Date(1522736957313)/",  '+
                                '"Invoices": [    {  '+
                                '"Type": "ACCREC", '+
                                '"InvoiceID": "c738b881-b17e-4689-9428-747cc481df31", '+
                                '"Reference": "ABC Limited0 2160", '+
                                '"InvoiceNumber": "INV0001", '+
                                '"AmountDue": 980.00, '+
                                '"AmountPaid": 0.00, '+
                                '"Contact": { '+
                                '"ContactID": "bd2270c3-8706-4c11-9cfb-000b551c3f51",  '+
                                '"ContactStatus": "ACTIVE", '+
                                '"Name": "ABC Limited0", '+
                                '"IsSupplier": "false", '+
                                '"IsCustomer": "true"}, '+
                                '"Date": "/Date(1518685950940+0000)/", '+
                                '"Status": "DRAFT", '+
                                '"LineAmountTypes": "Exclusive", '+
                                '"LineItems": [   { '+
                                '"Description": "TestProduct0", '+
                                '"Quantity": "1.0000", '+
                                '"UnitAmount": "980.00", '+
                                '"LineAmount": 980.00, '+
                                '"AccountCode": "200", '+
                                '"ItemCode": "GR 01", '+
                                '"LineItemID": "dbf6c452-c70b-4f71-b953-dcb723c1f299"}], '+
                                '"SubTotal": 980.00, '+
                                '"TotalTax": 98.00, '+
                                '"Total": 1078.00, '+
                                '"CurrencyCode": "AUD"}]} ';

        return xeroResponseBody;
    }
    private static string response2(HTTPRequest req) {
    
        System.assertEquals('callout:Xero/api.xro/2.0/invoices?Page=1', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());

        String xeroResponseBody = '{"Id": "bf2e059b-fa35-4160-965c-362bcb0eb1ce", '+
                                '"Status": "OK", '+
                                '"ProviderName": "Salesforce",'+
                                '"DateTimeUTC": "/Date(1522736957313)/",  '+
                                '"Invoices": [    {  '+
                                '"Type": "ACCREC", '+
                                '"InvoiceID": "c738b881-b17e-4689-9428-747cc481df31", '+
                                '"Reference": "TestInvoice", '+
                                '"InvoiceNumber": "INV-0015", '+
                                '"AmountDue": 0.00, '+
                                '"AmountPaid": 1080.00, '+
            					'"AmountCredited": 0.00, '+
                                '"Contact": { '+
                                '"ContactID": "bd2270c3-8706-4c11-9cfb-000b551c3f51",  '+
                                '"ContactStatus": "ACTIVE", '+
                                '"Name": "ABC Limited0", '+
                                '"IsSupplier": "false", '+
                                '"IsCustomer": "true"}, '+
                                '"Date": "/Date(1518685950940+0000)/", '+
                                '"Status": "PAID", '+
                                '"LineAmountTypes": "Exclusive", '+
                                '"LineItems": [   { '+
                                '"Description": "TestProduct0", '+
                                '"Quantity": "1.0000", '+
                                '"UnitAmount": "1080.00", '+
                                '"LineAmount": 1080.00, '+
                                '"AccountCode": "200", '+
                                '"LineItemID": "dbf6c452-c70b-4f71-b953-dcb723c1f299"}], '+
                                '"SubTotal": 1080.00, '+
                                '"TotalTax": 108.00, '+
                                '"Total": 1188.00, '+
                                '"CurrencyCode": "AUD"}]} ';

        return xeroResponseBody;
    }
}