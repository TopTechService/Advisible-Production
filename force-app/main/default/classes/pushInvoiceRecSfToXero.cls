public with sharing class pushInvoiceRecSfToXero {
    public static void pushInvoiceRecSfToXero(List<Opportunity> oppoListFromTrigger) {

        List<Invoice_Header__c> InvoiceHeadersList = createInvoiceReceivableHeader.createHeader(oppoListFromTrigger);

        if(InvoiceHeadersList.size() <> 0){

            //Query invoices with line Items
            List<Invoice_Header__c> invRecHeaderList = new List<Invoice_Header__c>([SELECT Id,Type__c,Status__c,Client_ID__c,
                                                                                    (SELECT Id,Description__c,Line_Amount__c,
                                                                                    Account_Code__c,Item_Code__c FROM Invoice_Line_Items__r) 
                                                                                    FROM Invoice_Header__c WHERE Id IN :InvoiceHeadersList]);

            //Get invoice Id and invoice wrapper in a map using the XeroInvoiceParser class.
            system.debug('Dan-invRecHeaderList:'+invRecHeaderList);
            Map<id, XeroInvoiceWrapper.cls_Invoices> invoiceIdtoInvoiceWrapper = XeroInvoiceParser.createXeroReceivableParser(invRecHeaderList);
            //Extract invoices from map
            List<XeroInvoiceWrapper.cls_Invoices> listOfInvoices = new List<XeroInvoiceWrapper.cls_Invoices>();
            for(XeroInvoiceWrapper.cls_Invoices lio : invoiceIdtoInvoiceWrapper.values()) {
                listOfInvoices.add(lio);
            }

            string method = 'POST';
            string resourceName = 'Invoices';
            string requestBody = JSON.serialize(listOfInvoices);

            xeroInvoiceCallout.executeCallout(method, resourceName, requestBody);
        }
    }
}