@isTest
private class createXeroAffiliateRecordTest {
    @isTest static void createAffiliate() {
        // Test data setup
        //Set the mock class
        test.setMock(HttpCalloutMock.class, new pushAccountToXeroContactTestMock());
        
        TestDataFactory.createXeroTenantId();

        // Create a client account
        test.startTest();
        List<Account> accts = TestDataFactory.createAccounts(1, 'Customer');
        test.stopTest();
        system.debug('Account:' + accts[0]);
        List<xeroContact__c> affiliates = [SELECT Id,Company_Name__c,
                                            Email_Address__c,
                                            FirstName__c,
                                            LastName__c,
                                            IsCustomer__c,
                                            Reference_Id__c,
                                            Salesforce_Account__c,
                                            Status__c,
                                            Xero_Org_ID__c 
                                            FROM xeroContact__c 
                                            WHERE Salesforce_Account__c IN :accts];

		system.assert(affiliates.size()>0);
        for(Account ac :accts) {
            for(xeroContact__c aff : affiliates) {
                system.assertEquals(ac.Id, aff.Salesforce_Account__c);
                system.assertEquals(ac.Name, aff.Company_Name__c);
                system.assertEquals(ac.Xero_eMail__c, aff.Email_Address__c);
                system.assertEquals(ac.Xero_First_Name__c, aff.FirstName__c);
                system.assertEquals(ac.Xero_Last_Name__c, aff.LastName__c);
                system.assertEquals(true, aff.IsCustomer__c);
                system.assertEquals('ACTIVE', aff.Status__c);
                system.assertEquals('bd2270c3-8706-4c11-9cfb-000b551c3f51', aff.Reference_Id__c);
            }
    }
            
        }
}