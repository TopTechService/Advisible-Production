@isTest
private class GetXeroTenantIdTest {
    @isTest static void getTenantId() {
        //Set the mock class
        test.setMock(HTTPCalloutMock.class, New getXeroTenantIdTestMock());
        
        test.startTest();
        runGetTenantId runTest = new runGetTenantId();
        runTest.runGetTenantId();
        test.stopTest();
        
        List<Xero_Setting__c> xeroSettings = Xero_Setting__c.getAll().values();
        System.debug('Dan' + xeroSettings);
        System.assertEquals(1, xeroSettings.size());
        
        String xeroTenantId;
        String xeroSettingName;
        for(Xero_Setting__c xs : xeroSettings) {
            System.assertEquals('Xero', xs.Name);
            System.assertEquals('6721c022-2163-4f10-bc66-a0cf7b4812d7', xs.Xero_Tenant_ID__c);
        }
    }
    
    @isTest Static void errTenantId() {
        //Don't set the mock class to cause an exception.
        
        test.startTest();
        runGetTenantId runTest = new runGetTenantId();
        runTest.runGetTenantId();
        test.stopTest();
        
        List<Xero_Setting__c> xeroSettings = Xero_Setting__c.getAll().values();
        System.assertEquals(0, xeroSettings.size());
        
        List<Xero_Debug_Log__c> debugLogs = New List<Xero_Debug_Log__c>([Select Name, Error__c
                                                                         FROM Xero_Debug_Log__c]);
        System.debug('log'+debugLogs);
        System.assertEquals(2, debugLogs.size());

        System.assert(debugLogs[0].Error__c.contains('Methods defined as TestMethod do not support Web service callouts'));
        System.assert(debugLogs[1].Error__c.contains('Attempt to de-reference a null object'));
    }
    
    @isTest static void updateTenantId() {
        //Set the mock class
        test.setMock(HTTPCalloutMock.class, New getXeroTenantIdTestMock());
        
		TestDataFactory.createXeroTenantId();
	        
        test.startTest();
        GetXeroTenantId.GetXeroTenantId();
        test.stopTest();
        
        List<Xero_Setting__c> xeroSettings = Xero_Setting__c.getAll().values();
        System.assertEquals(1, xeroSettings.size());
        
        String xeroTenantId;
        String xeroSettingName;
        for(Xero_Setting__c xs : xeroSettings) {
            System.assertEquals('Xero', xs.Name);
            System.assertEquals('6721c022-2163-4f10-bc66-a0cf7b4812d7', xs.Xero_Tenant_ID__c);
        }
    }
}