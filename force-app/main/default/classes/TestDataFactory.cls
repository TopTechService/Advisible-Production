@isTest
public class TestDataFactory {

    public static void createXeroTenantId() {
        Xero_Setting__c tenantId = New Xero_Setting__c(Name = 'Xero',
                                                      Xero_Tenant_Id__c = 'd3ad10bc-3fdd-4e39-8954-e165fa6bd1ba',
                                                      Xero_Id__c = 'fe0ee125-b42f-44ae-a04d-a0db5de363bb');
        insert tenantId;
    }
    
    public static void createXeroLastResponseTime() {
        Xero_Last_Response_Time__c xeroLastResponse = New Xero_Last_Response_Time__c(Name = 'InvoiceResponseTime',
                                                                                    Last_Response_Time__c = DateTime.now(),
                                                                                    Xero_Page_Number__c = 1);
        insert xeroLastResponse;
    }

    public static List<Account> createAccounts(Integer numOfAccounts, String typeOfAccount) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numOfAccounts;i++) {
            Account a = new Account(Name = 'ABC Limited' + i,
                                   Xero_First_Name__c = 'Andrea',
                                   Xero_Last_Name__c = 'Dutchess' + i,
                                   Xero_eMail__c = 'a.dutchess' + i + '@abclimited.com',
                                   Account_Status__c = 'Active',
                                   Type = typeOfAccount);
            accts.add(a);
        }
        
        insert accts;
        
        return accts;
    }
    
    public static Map<Id, List<Contact>> createContacts(List<Account> Accounts, Integer numOfContacts) {

        Map<Id, List<Contact>> mapOfAccountIdToListOfContacts = New Map<Id, List<Contact>>();
        List<Contact> addedContacts = New List<Contact>();
        List<Contact> accContacts = New List<Contact>();

        for(Account ac :Accounts) {
            for(Integer i=0;i<numOfContacts;i++) {
                accContacts.clear();
                Contact newContact = New Contact(LastName='TestContact'+i,
                                                AccountId=ac.Id);
                accContacts.add(newContact);
            }
            mapOfAccountIdToListOfContacts.put(ac.Id, accContacts);
            addedContacts.addAll(accContacts);
        }
        insert addedContacts;
        return mapOfAccountIdToListOfContacts;
    }

    public static Void createAffiliates(List<Account> accounts) {
        List<xeroContact__c> affiliates = 
            New List<xeroContact__c>();
        
        for(Account ac :accounts) {
            xeroContact__c bwac = 
                New xeroContact__c(Company_Name__c = ac.Name,
                                   Email_Address__c = ac.Xero_eMail__c,
                                   FirstName__c = ac.Xero_First_Name__c,
                                   LastName__c = ac.Xero_Last_Name__c,
                                   IsCustomer__c = true,
                                   Salesforce_Account__c = ac.Id,
                                   Reference_Id__c = 'bd2270c3-8706-4c11-9cfb-000b551c3f51',
                                   Status__c = 'ACTIVE',
                                   Xero_Org_ID__c = '!wQSk-');
            affiliates.add(bwac);
        }
        insert affiliates;
    }
    
    public static List<Opportunity> createOpportunities(List<Account> accountsList, Map<Id, List<Contact>> mapOfAccountIdToListOfContacts, Integer numOfOpportunities) {
        
        List<Opportunity> Opportunities = New List<Opportunity>();
        Id oppContact;
        
        for(Account ac :accountsList) {
            List<Contact> relatedContacts = mapOfAccountIdToListOfContacts.get(ac.Id);
            if(relatedContacts.size()>0) {
                oppContact = relatedContacts[0].Id;
            }
            for(Integer i=0;i<numOfOpportunities;i++) {
                Opportunity opportunity = New Opportunity(Name = 'Test' + i,
                                                         AccountId = ac.Id,
                                                         CloseDate = Date.today(),
                                                         StageName = 'Discovery Meeting',
                                                         Contact__c = oppContact);
                Opportunities.add(opportunity);
            }
        }
        insert Opportunities;
        return opportunities;
    }
    
    public static List<PricebookEntry> createProducts(Integer numOfProducts) {
        
        List<Product2> Products = New List<Product2>();
        for(Integer i=0;i<numOfProducts;i++) {
            Product2 p = New Product2(Name = 'TestProduct' + i,
                                     isActive = true,
                                     Description = 'TestProduct' + i);
            Products.add(p);
        }
        insert Products;
        
        //Create an instance of the standard price book
        Pricebook2 standardPriceBook = New Pricebook2(ID = test.getStandardPricebookId(),
                                                     isActive = true);
        update standardPriceBook;
        
        //Create pricebook entries for each product
        List<PricebookEntry> PricebookEntries = New List<PricebookEntry>();
        for(Product2 p2 :Products) {
            PricebookEntry pbe = New PricebookEntry(Pricebook2Id = standardPriceBook.Id,
                                                   Product2Id = p2.Id,
                                                   UnitPrice = 1078,
                                                   isActive = true);
            PricebookEntries.add(pbe);
        }
        insert PricebookEntries;
        return PricebookEntries;
    }
    
    public static void addProductsToOpportunities(List<Opportunity> opportunityList, List<PricebookEntry> pricebookEntryList) {
        
        List<OpportunityLineItem> opportunityProducts = New List<OpportunityLineItem>();
        for(Opportunity oppo :opportunityList) {
            for(PricebookEntry pbe :pricebookEntryList) {
                OpportunityLineItem oli = New OpportunityLineItem(OpportunityId = oppo.Id,
                                                                 PricebookEntryId = pbe.Id,
                                                                 Product2Id = pbe.Product2Id,
                                                                 Quantity = 1,
                                                                 ServiceDate = Date.today());
                opportunityProducts.add(oli);
            }
        }
        insert opportunityProducts;
    }
}