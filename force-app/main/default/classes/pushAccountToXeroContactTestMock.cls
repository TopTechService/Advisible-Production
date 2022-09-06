@isTest
global class pushAccountToXeroContactTestMock implements HTTPCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('callout:Xero/api.xro/2.0/Contacts', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        String xeroResponseBody = '{"Id": "fe0ee125-b42f-44ae-a04d-a0db5de363bb", '+
                                '"Status": "OK", '+
                                '"ProviderName": "Salesforce",'+
                                '"DateTimeUTC": "/Date(1522736957313)/",  '+
                                '"Contacts": [    {  '+
                                '"ContactID": "bd2270c3-8706-4c11-9cfb-000b551c3f51",  '+
                                '"ContactStatus": "ACTIVE", '+
                                '"Name": "ABC Limited0",    '+
                                '"FirstName": "Andrea",   '+
                                '"LastName": "Dutchess",   '+
                                '"EmailAddress": "a.dutchess0@abclimited.com",    '+
                                '"SkypeUserName": "skype.dutchess@abclimited.com",  '+
                                '"BankAccountDetails": "45465844", '+
                                '"TaxNumber": "415465456454",    '+
                                '"AccountsReceivableTaxType": "INPUT2",  '+
                                '"AccountsPayableTaxType": "OUTPUT2", '+
                                '"Addresses ": [    {  '+
                                '"AddressType": "POBOX", '+
                                '"AddressLine1": "P O Box 123",        '+
                                '"City": "SYDNEY",  '+
                                '"PostalCode": "2000",     '+
            					'"AttentionTo": "Andrea"},{      '+
            					'"AddressType": "STREET"}   ],     '+
            					'"Phones": [   { '+
                                '"PhoneType": "DEFAULT",  '+
                                '"PhoneNumber": "1111111",  '+
                                '"PhoneAreaCode": "02",'+
            					'"PhoneCountryCode": "61"},{   '+
            					'"PhoneType": "FAX"},{  '+
                                '"PhoneType": "MOBILE"},{ '+
                                '"PhoneType": "DDI"}],   '+
                                '"UpdatedDateUTC": "/Date(1488391422280+0000)/", '+
                                '"IsSupplier": false,  '+
                                '"IsCustomer": true,       '+
            					'"DefaultCurrency": "AUD"}]}     ';
        
        if(req.getEndpoint().contains('Contacts')) {
            response.setHeader('Date', 'Mon, 21 Dec 2020 09:12:28 GMT');
            response.setBody(xeroResponseBody);
            response.setStatusCode(200);
        }
        return response;
    }
}