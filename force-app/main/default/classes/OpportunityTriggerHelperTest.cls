/**
 * @Purpose : Test class for OpportunityTriggerHelper
 **/
@isTest
public class OpportunityTriggerHelperTest {
    @TestSetup
    public static  void testData() {
        
        //Create Account Record
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        //accountRecord.Type='Customer';
        Insert accountRecord;
        
        //Create Contact record
        contact contactRecord = new contact();
        contactRecord.LastName = 'Test Contact';
        contactRecord.AccountId = accountRecord.id;
        Insert contactRecord;
        
        //Created Opportunity Records
        List<Opportunity> opportunityList= new List<Opportunity>();
        
        for(Integer i=0;i<10;i++){
            Opportunity opportunityRecord = new Opportunity();
            opportunityRecord.CloseDate = Date.Today();
            opportunityRecord.Name = 'Test Opportunity'+i;
            opportunityRecord.StageName = 'Negotiation';
            opportunityRecord.AccountId = accountRecord.id;
            opportunityRecord.Contact__c = contactRecord.id;
            opportunityList.add(opportunityRecord);
        }
        Insert opportunityList;
        
        //Created product Records
        product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = '123';
        Insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry( Pricebook2Id = pricebookId, Product2Id = product.id, UnitPrice = 10000, IsActive = true); 
        insert standardPrice;
        
        //Created OpportunityLineItem Records
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>(); 
        for(Opportunity oppRecord: opportunityList){
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.OpportunityId = oppRecord.id;
            lineItem.Product2Id = product.id;
            lineItem.UnitPrice = 100;
            lineItem.Quantity = 2;
            lineItem.PricebookEntryId = standardPrice.Id;
            lineItem.ServiceDate = System.today();
            lineItemList.add(lineItem);
        }
        Insert lineItemList;
        
        //Create Custom Setting 
        List<OpportunityStageCloseMail__c> settingList= new List<OpportunityStageCloseMail__c>();
        
        for(Integer i=0;i<2;i++){
            OpportunityStageCloseMail__c customSetting = new OpportunityStageCloseMail__c();
            customSetting.Email__c='test@xyz.com';
            customSetting.Name='Test'+i;
            customSetting.Name__c='test'+i;
            settingList.add(customSetting);
        }
        System.debug('settingList'+settingList);
        Insert settingList;
        
        //Create Attachments for every Opportunity
        List<Attachment>attachmentList = new List<Attachment>();
        for(Opportunity opportunity:opportunityList){
            Blob bodyBlob = Blob.valueOf('Test Data');
            Attachment attachment=new Attachment();   	
            attachment.Name='New customer form';
            attachment.body=bodyBlob;
            attachment.parentId=opportunity.id;
            attachmentList.add(attachment);
        }
        Insert attachmentList;
        
    }
    
    @isTest 			
    static void test(){
        List<Opportunity> opportunityUpdateList= new List<Opportunity>();
        
        List<Opportunity> opportunityList= [SELECT Id, Name ,StageName,AccountId,Contact__c,CloseDate
                                            FROM Opportunity 
                                            LIMIT 80];
        for(Opportunity opportunity: opportunityList){
            opportunity.StageName = 'Closed Won';
            opportunity.DocuSign_Status__c='Completed';
            opportunityUpdateList.add(opportunity);
        }
        integer numBefore =  Limits.getEmailInvocations();
        system.debug(numBefore);
        test.startTest();
        UPDATE opportunityList;
        integer invocations =  Limits.getEmailInvocations();
        test.stopTest();
//        system.assertEquals(1, invocations, 'An email has not been sent');
    }
    
}