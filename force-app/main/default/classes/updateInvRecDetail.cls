/*
 * @Author			: Dan Peaper, daniel@toptechservice.com.au
 * 
 * @Date Completed	: 02/01/2021
 * 
 * @Description		: This class is responsible for updating the salesforce invoice record with returned Xero data.
*/
public class updateInvRecDetail {
    public static void updateInvoice(Map<Id, XeroInvoiceWrapper.cls_Invoices> mapSfInvToXeroInv) {
        
        List<Invoice_Header__c> sfInvoices = New List<Invoice_Header__c>([SELECT Id FROM Invoice_Header__c 
                                                                                        WHERE Id IN :mapSfInvToXeroInv.keySet()]);
        List<Invoice_Header__c> updatedInvoices = New List<Invoice_Header__c>();
        for(Invoice_Header__c bwi :sfInvoices) {
            bwi.Name = mapSfInvToXeroInv.get(bwi.Id).InvoiceNumber;
            bwi.Invoice_Id__c = mapSfInvToXeroInv.get(bwi.Id).InvoiceID;
            bwi.Sub_Total__c = Decimal.valueOf(mapSfInvToXeroInv.get(bwi.Id).SubTotal);
            bwi.Total_Tax__c = Decimal.valueOf(mapSfInvToXeroInv.get(bwi.Id).TotalTax);
            bwi.Total__c = Decimal.valueOf(mapSfInvToXeroInv.get(bwi.Id).Total);
            bwi.Reference__c = mapSfInvToXeroInv.get(bwi.Id).Reference;
            updatedInvoices.add(bwi);
        }
        update updatedInvoices;
    }

}