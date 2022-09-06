@isTest
private with sharing class ScheduleXeroInvoiceSyncTest {
    // Dummy CRON expression: Midnight on March 10th.
    // Because this is a test, job executes 
    // immediately after Test.stopTest().

    public static string CRON_EXP = '0 0 0 10 3 ?';
    @IsTest static void ScheduleSync(){
        
        //Set the mock class
        xeroInvoiceCallout.mock = new xeroInvoiceCalloutTestMock();
        xeroAccountCallout.mock = new pushAccountToXeroContactTestMock();
    
        TestDataFactory.createXeroTenantId();
        TestDataFactory.createXeroLastResponseTime();
        List<Account> Accounts = TestDataFactory.createAccounts(1, 'Customer');
        Map<Id, List<Contact>> ContactsMap = TestDataFactory.createContacts(Accounts, 1);
        TestDataFactory.createAffiliates(Accounts);
        List<Opportunity> Opportunities = TestDataFactory.createOpportunities(Accounts, ContactsMap, 1);
        List<PricebookEntry> PricebookEntries = TestDataFactory.createProducts(2);
        TestDataFactory.addProductsToOpportunities(opportunities, pricebookEntries);
        
        List<Opportunity> testOpportunityList = New List<Opportunity>([SELECT Id, StageName,DocuSign_Status__c FROM Opportunity]);
        for(Opportunity opObj :testOpportunityList) {
            opObj.StageName = 'Closed Won';
            opObj.DocuSign_Status__c = 'Completed';
        }
        update testOpportunityList;

        Test.startTest();
        //Schedule test job
        String JobId = System.Schedule('ScheduledApexTest',CRON_EXP, 
        new ScheduleXeroInvoiceSync());
        Test.stopTest();
        
    }
}