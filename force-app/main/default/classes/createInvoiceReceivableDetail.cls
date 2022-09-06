public with sharing class createInvoiceReceivableDetail {
    public static void createLineItems(List<OpportunityLineItem> OppoLineItems, Map<Id, Invoice_Header__c> OppToInvMap) {

        List<Invoice_Detail__c> invoiceLineItemsList = new List<Invoice_Detail__c>();

        integer i = 1;
        for(OpportunityLineItem oli : OppoLineItems) {
            Invoice_Detail__c invoiceLineItem = new Invoice_Detail__c();
            InvoiceLineItem.Name = 'LineItem-' + i;
            InvoiceLineItem.Invoice__c = OppToInvMap.get(oli.OpportunityId).Id;
            InvoiceLineItem.Description__c = oli.ProductName__c;
            invoiceLineItem.Item_Code__c = oli.ProductCode;
            invoiceLineItem.Account_Code__c = oli.PricebookEntry.Product2.GL_Code__c;
            invoiceLineItem.Quantity__c = oli.Quantity;
            invoiceLineItem.Unit_Price__c = oli.UnitPrice;
            invoiceLIneItem.Tax_Amount__c = oli.UnitPrice * oli.Quantity / 11;
            invoiceLineItem.Line_Amount__c = oli.TotalPrice;
            invoiceLineItemsList.add(invoiceLineItem);
            i++;
        }

        insert invoiceLineItemsList;
    }
}