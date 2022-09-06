@isTest
public class getXeroInvoicesTest {
    
    @testSetup static void setInvoice() {
        
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
    }
    
    @isTest static void getInvoice() {
        
        List<Invoice_Header__c> testInvoices = New List<Invoice_Header__c>([SELECT Id,Name, Type__c,Status__c,Client_ID__c,
                                                                                            Invoice_Id__c,Sub_Total__c,Total_Tax__c,
                                                                                            Total__c,Reference__c,Amount_Due__c,Amount_Paid__c,
                                                                                            (SELECT Id,Description__c,Line_Amount__c,
                                                                                            Account_Code__c FROM Invoice_Line_Items__r) 
                                                                                            FROM Invoice_Header__c]);
        system.assert(testInvoices.size() > 0);
        for(Invoice_Header__c inv : testInvoices) {
            system.assertEquals('DRAFT', inv.Status__c);
            system.assertEquals(2156.00, inv.Amount_Due__c);
            system.assertEquals(0.00, inv.Amount_Paid__c);
        }
        
        getXeroInvoices.executeCallout();

        testInvoices.clear();
        testInvoices = New List<Invoice_Header__c>([SELECT Id,Name, Type__c,Status__c,Client_ID__c,
                                                                                            Invoice_Id__c,Sub_Total__c,Total_Tax__c,
                                                                                            Total__c,Reference__c,Amount_Due__c,Amount_Paid__c,
                                                                                            (SELECT Id,Description__c,Line_Amount__c,
                                                                                            Account_Code__c FROM Invoice_Line_Items__r) 
                                                                                            FROM Invoice_Header__c]);
        system.assert(testInvoices.size() > 0);
    }
}