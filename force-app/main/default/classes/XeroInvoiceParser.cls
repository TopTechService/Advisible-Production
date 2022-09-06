/*
 * @Author	 	: Dan Peaper (Top Tech Service, daniel@toptechservice.com.au)
 * 
 * @Date		: 31/12/2020
 * 
 * @Description	: This class will parse the xero Invoice object.
 */
public class XeroInvoiceParser {
    public static map<id, XeroInvoiceWrapper.cls_Invoices> createXeroReceivableParser(List<Invoice_Header__c> invoiceList) {
        
        Map<Id, XeroInvoiceWrapper.cls_Invoices> invoiceIdtoInvoiceWrapper = new Map<Id, XeroInvoiceWrapper.cls_Invoices>();

        for(Invoice_Header__c invoicesObj : invoiceList) {
            if(!invoicesObj.Invoice_Line_Items__r.isEmpty()) {
                XeroInvoiceWrapper.cls_Invoices invoiceWrappObj = new XeroInvoiceWrapper.cls_Invoices();
                //Create invoice in Xero
                invoiceWrappObj.SalesforceID = invoicesObj.Id;
                invoiceWrappObj.Type = 'ACCREC';
                invoiceWrappObj.Status = invoicesObj.Status__c;
                invoiceWrappObj.LineAmountTypes = 'Inclusive';
                //Get related Line Items
                invoiceWrappObj.LineItems = createReceivableLineWrapper(invoicesObj.Invoice_Line_Items__r);
                //Get account Xero Id
                invoiceWrappObj.Contact = createXeroContactWrapper(invoicesObj.Client_ID__c);
                //Add to map
                invoiceIdtoInvoiceWrapper.put(invoicesObj.Id, invoiceWrappObj);
            }
        }
        return invoiceIdtoInvoiceWrapper;
    }

    private static List<XeroInvoiceWrapper.cls_LineItems> createReceivableLineWrapper(List<Invoice_Detail__c> invoiceReceivableDetailList){
        
        List<XeroInvoiceWrapper.cls_LineItems> lineItemList = new List<XeroInvoiceWrapper.cls_LineItems>();
        XeroInvoiceWrapper.cls_LineItems lineItemWrapper;
        for(Invoice_Detail__c invoiceRecevableObj : invoiceReceivableDetailList){
            lineItemWrapper = new XeroInvoiceWrapper.cls_LineItems();
            lineItemWrapper.Description = invoiceRecevableObj.Description__c;
            //unit amout is required field for 'Bill' in xero.
            lineItemWrapper.UnitAmount = String.valueOf(invoiceRecevableObj.Line_Amount__c);
            lineItemWrapper.AccountCode = invoiceRecevableObj.Account_Code__c;
            lineItemWrapper.ItemCode = invoiceRecevableObj.Item_Code__c;
//            lineItemWrapper.TaxType = 'OUTPUT';
            lineItemList.add(lineItemWrapper);
        }
        
        return lineItemList;
    }
    
    private static XeroInvoiceWrapper.cls_Contact createXeroContactWrapper(String xeroContactId){
        XeroInvoiceWrapper.cls_Contact xeroContactIdWrapper = new XeroInvoiceWrapper.cls_Contact();
        xeroContactIdWrapper.ContactID = xeroContactId;
        return xeroContactIdWrapper;
    }
    

}