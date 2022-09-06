/*
 * @Author			: Dan Peaper, daniel@toptechservice.com.au
 * 
 * @Date completed	: 18/12/2020
 * 
 * @Description		: This class filters the accounts from the trigger to
 * 					  only include customers and constructs a xero contact
 * 					  object passed to a callout method.
 */
public class pushAccountToXeroContact {

    public static void pushAccountToXeroContact(List<Account> acctsFromTrigger){
        
        //Construct the xero object from the account records.
        List<XeroContactWrapper.cls_Contacts> xeroContactsList = XeroContactParser.createXeroContactParser(AcctsFromTrigger);

        string method = 'POST';
        string resourceName = 'Contacts';
        string requestBody = JSON.serialize(xeroContactsList);
        
        xeroAccountCallout.executeCallout(method, resourceName, requestBody);
    }
}