/*
 * @Author	 	: Dan Peaper (Top Tech Service, daniel@toptechservice.com.au)
 * 
 * @Date		: 17/12/2020
 * 
 * @Description	: This class will parse the xero contact object.
 */
public class XeroContactParser {
    public static List<XeroContactWrapper.cls_Contacts> createXeroContactParser(List<Account> accountsList){
        
        List<XeroContactWrapper.cls_Contacts> contactsList = new List<XeroContactWrapper.cls_Contacts>();
        
        for(Account accountObj : accountsList){
            XeroContactWrapper.cls_Contacts contactWrapperObj = new XeroContactWrapper.cls_Contacts();
            //Create a customer record in Xero
            contactWrapperObj.SalesforceId = accountObj.Id;
            contactWrapperObj.Name = accountObj.Name;
            contactWrapperObj.FirstName = accountObj.Xero_First_Name__c;
            contactWrapperObj.LastName = accountObj.Xero_Last_Name__c;
            contactWrapperObj.EmailAddress = accountObj.Xero_eMail__c;
            contactWrapperObj.isCustomer = true;
            contactsList.add(contactWrapperObj);
        }
        return contactsList;
    }
}