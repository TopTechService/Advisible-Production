/*
 * @Author			: Dan Peaper, daniel@toptechservice.com.au
 * 
 * @Date Completed	: 18/12/2020
 * 
 * @Description		: This class creates the Breadwinner Xero Affiliate record and relates
 * 					  it to the new account record.
 */ 
public class createXeroAffiliateRecord {
    
    public static void createAffiliate(Map<String, Account> accountToXeroID){
        List<xeroContact__c> affiliates = New List<xeroContact__c>();
        
        for(String key : accountToXeroID.Keyset()){
            xeroContact__c aff = New xeroContact__c(Company_Name__c = accountToXeroID.get(key).Name,
                                                    Email_Address__c = accountToXeroID.get(key).Xero_eMail__c,
                                                    FirstName__c = accountToXeroID.get(key).Xero_First_Name__c,
                                                    LastName__c = accountToXeroID.get(key).Xero_Last_Name__c,
                                                    IsCustomer__c = true,
                                                    Reference_Id__c = key,
                                                    Salesforce_Account__c = accountToXeroID.get(key).Id,
                                                    Status__c = 'ACTIVE',
                                                    Xero_Org_ID__c = '!wQSk-');
            affiliates.add(aff);
        }
        Database.SaveResult[] result = Database.Insert(affiliates, false);
    }

}