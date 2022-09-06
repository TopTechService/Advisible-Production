public class updateInvoicesFromXero {
    
    public static void updateInvoices(List<xeroInvoiceWrapper.cls_Invoices> xeroInvoices) {
        
		List<Invoice_Header__c> updatedSfInvoices = new List<Invoice_Header__c>();
        List<String> xeroInvoiceIdList = new List<String>();
        for(xeroInvoiceWrapper.cls_Invoices xeroInvoice : xeroInvoices) {
            xeroInvoiceIdList.add(xeroInvoice.InvoiceID);
        }
        System.debug('xeroInvoiceIdList: ' + xeroInvoiceIdList);
        List<Invoice_Header__c> sfInvoices = new List<Invoice_Header__c>([SELECT Id, Invoice_Id__c FROM Invoice_Header__c 
                                                                          WHERE Invoice_Id__c IN :xeroInvoiceIdList]);
        System.debug('sfInvoices: ' + sfInvoices);
        Map<String, Id> xeroInvoiceToSfInvoiceMap = new Map<String, Id>();
        for(Invoice_Header__c inv : sfInvoices) {
            xeroInvoiceToSfInvoiceMap.put(inv.Invoice_Id__c,inv.Id);
        }
        
        for(xeroInvoiceWrapper.cls_Invoices xeroInvoice : xeroInvoices) {
            Invoice_Header__c invHeader = new Invoice_Header__c();
            invHeader.Id = xeroInvoiceToSfInvoiceMap.get(xeroInvoice.InvoiceID);
            invHeader.Status__c = xeroInvoice.Status;
            invHeader.Reference__c = xeroInvoice.Reference;
            invHeader.Amount_Due__c = Decimal.valueOf(xeroInvoice.AmountDue);
            invHeader.Amount_Paid__c = Decimal.valueOf(xeroInvoice.AmountPaid);
            invHeader.Amount_Credited__c = Decimal.valueOf(xeroInvoice.AmountCredited);
            if(xeroInvoice.FullyPaidOnDate != null) {
                String xeroDate = xeroInvoice.FullyPaidOnDate.mid(6,13);
                Datetime dt = datetime.newinstance(long.valueOf(xeroDate));
                invHeader.Fully_Paid_On_Date__c = Date.newinstance(dt.year(),dt.month(),dt.day());    
            }
            If(invHeader.Id != null) {
                updatedSfInvoices.add(invHeader);
                System.debug('invHeader:'+invHeader);
            }
        }
        If(updatedSfInvoices.size()>0) {
            update updatedSfInvoices;
        }
        
        
        Xero_Last_Response_Time__c xeroLastResponse = Xero_Last_Response_Time__c.getValues('InvoiceResponseTime');
        xeroLastResponse.Last_Response_Time__c = DateTime.now();
        update xeroLastResponse;
    }

}