@isTest
public class pushInvoiceRecSfToXeroTest {
    @testSetup Static void pushInvoice() {
        
        //Test Setup
        //Set the mock class
        xeroInvoiceCallout.mock = new xeroInvoiceCalloutTestMock();
        xeroAccountCallout.mock = new pushAccountToXeroContactTestMock();

        TestDataFactory.createXeroTenantId();

        List<Account> Accounts = TestDataFactory.createAccounts(1,'Customer');

        Map<Id, List<Contact>> ContactsMap = TestDataFactory.createContacts(Accounts, 1);
        
        TestDataFactory.createAffiliates(Accounts);

        List<Opportunity> Opportunities = TestDataFactory.createOpportunities(Accounts, ContactsMap, 2);
        List<PricebookEntry> PricebookEntries = TestDataFactory.createProducts(2);
        TestDataFactory.addProductsToOpportunities(opportunities, pricebookEntries);
        
        List<Opportunity> testOpportunityList = New List<Opportunity>([SELECT Id, StageName,DocuSign_Status__c  FROM Opportunity]);
        integer i = 0;
        for(Opportunity opObj :testOpportunityList) {
            opObj.StageName = 'Closed Won';
            opObj.DocuSign_Status__c = 'Completed';
            opObj.CloseDate = Date.today().addDays(i);
            i = i + 15;
        }
        update testOpportunityList;    
    }
    
    @isTest static void testMethod1() {
        
        List<Invoice_Header__c> testInvoices = New List<Invoice_Header__c>([SELECT Id,Name, Type__c,Status__c,Client_ID__c,
                                                                                            Invoice_Id__c,Sub_Total__c,Total_Tax__c,
                                                                                            Total__c,Reference__c,
                                                                                            (SELECT Id,Description__c,Line_Amount__c,
                                                                                            Account_Code__c,Item_Code__c FROM Invoice_Line_Items__r) 
                                                                                            FROM Invoice_Header__c]);
        system.assert(testInvoices.size() > 0);
        system.assertEquals('INV0001', testInvoices[0].Name);
        system.assertEquals('INV0002', testInvoices[1].Name);
        system.assertEquals('c738b881-b17e-4689-9428-747cc481df31', testInvoices[0].Invoice_Id__c);
        
		integer j = 1;
        for(Invoice_Header__c bwi :testInvoices) {
            System.assertEquals(980.00, bwi.Sub_Total__c / j);
            System.assertEquals(98.00, bwi.Total_Tax__c / j);
            System.assertEquals(1078.00, bwi.Total__c / j);
            j++;
        }
    }

}