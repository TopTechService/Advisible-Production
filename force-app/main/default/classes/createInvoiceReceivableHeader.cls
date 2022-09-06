public with sharing class createInvoiceReceivableHeader {
    public static List<Invoice_Header__c> createHeader(List<Opportunity> oppoListFromTrigger) {

		string lastInvoiceNumber;
        try {
        
            List<Id> accountId = new List<Id>();
            for(Opportunity o : oppoListFromTrigger) {
                accountId.add(o.AccountId);
            }
            
            List<xeroContact__c> affiliates = New List<xeroContact__c>([SELECT Id, Reference_Id__c,Salesforce_Account__c FROM 
            xeroContact__c WHERE Salesforce_Account__c 
            IN :accountId]);
            
            Map<Id, xeroContact__c> accountToXeroContactMap = New Map<Id, xeroContact__c>();
            for(xeroContact__c affiliate : affiliates) {
                accountToXeroContactMap.put(affiliate.Salesforce_Account__c, affiliate);
            }
            
            //Query the Opportunity Line Items
            List<OpportunityLineItem> oppToLineItemList = New List<OpportunityLineItem>([SELECT Id,Description,ProductName__c,ProductCode,Quantity,UnitPrice,TotalPrice,OpportunityID,PricebookEntry.Product2.GL_Code__c 
                                                                                        FROM OpportunityLineItem 
                                                                                        WHERE OpportunityId IN :oppoListFromTrigger]);


            Map<Id, List<OpportunityLineItem>> oppToLineItemMap = new Map<Id, List<OpportunityLineItem>>();

            for(OpportunityLineItem oli : oppToLineItemList) {
                Id opportunityID = oli.OpportunityID;
                if(string.isNotBlank(opportunityID)) {
                    List<OpportunityLineItem> temp = oppToLineItemMap.get(opportunityID);
                    if(temp == null) {
                        oppToLineItemMap.put(opportunityID, new List<OpportunityLineItem>{oli});
                    } else {
                        temp.add(oli);
                    }
                }
            }
            
            //Iterate through the opportunities and create the Invoice header records.
            Invoice_Header__c invoiceReceivableHeader;
            Map<Id, Invoice_Header__c> oppIdToInvoiceHeader = new Map<Id, Invoice_Header__c>();
            List<Invoice_Header__c> InvoiceHeadersList = new List<Invoice_Header__c>();
            
            for(Opportunity OpportunityRecord : oppoListFromTrigger) {
                if(OpportunityRecord != null) {
                    invoiceReceivableHeader = new Invoice_Header__c();
                    invoiceReceivableHeader.Name = nextInvoice(lastInvoiceNumber);
                    invoiceReceivableHeader.Opportunity__c = OpportunityRecord.Id;
                    invoiceReceivableHeader.Account__c = OpportunityRecord.AccountId;
                    invoiceReceivableHeader.Xero_Contact__c = accountToXeroContactMap.get(OpportunityRecord.AccountId).Id;
                    invoiceReceivableHeader.Client_ID__c = accountToXeroContactMap.get(OpportunityRecord.AccountId).Reference_Id__c;
                    invoiceReceivableHeader.Status__c = 'DRAFT';
                    invoiceReceivableHeader.Type__c = 'Invoice';
                    invoiceReceivableHeader.Reference__c = OpportunityRecord.Name;
                    invoiceReceivableHeader.Amount_Paid__c = 0.00;
                    invoiceReceivableHeader.Total_Tax__c = OpportunityRecord.Amount / 11;
                    invoiceReceivableHeader.Sub_Total__c = OpportunityRecord.Amount - (OpportunityRecord.Amount / 11);
                    invoiceReceivableHeader.Total__c = OpportunityRecord.Amount;
                    invoiceReceivableHeader.Amount_Due__c = OpportunityRecord.Amount;
                    invoiceReceivableHeader.Invoice_Date__c = InvoicingDate(OpportunityRecord.CloseDate);
                    invoiceReceivableHeader.Due_Date__c = invoiceReceivableHeader.Invoice_Date__c.addDays(7);
                    // Add to the map of oppo Id to Inv Header
                    system.debug('Dan-OppoId:' + OpportunityRecord.Id);
                    system.debug('Dan-Header:'+ invoiceReceivableHeader);
                    oppIdToInvoiceHeader.put(OpportunityRecord.Id, invoiceReceivableHeader);
                    InvoiceHeadersList.add(invoiceReceivableHeader);
                    lastInvoiceNumber = invoiceReceivableHeader.Name; 
                }
            }
            
            if(!InvoiceHeadersList.isEmpty()) {
                insert InvoiceHeadersList;
            }
            
            System.debug('Dan - Line items: ' + oppToLineItemList);
            System.debug('Dan - affiliates: ' + affiliates);
            System.debug('Dan - Map xeroToAccount: ' + accountToXeroContactMap);

            //Create the detail lines
            createInvoiceReceivableDetail.createLineItems(oppToLineItemList, oppIdToInvoiceHeader);
            
            return InvoiceHeadersList;
        } catch(Exception e) {
            XeroErrorHandling.insertErrorDebugLog(e.getMessage());
        }
        return null;
    }
    
    

/*
 * Private Methods
 */
    private static string nextInvoice(string lastInvoiceName) {
        if(string.isBlank(lastInvoiceName)) {
            List<Invoice_Header__c> lastInvoiceList = new List<Invoice_Header__c>([SELECT Id, Name FROM Invoice_Header__c ORDER BY Id DESC Limit 1]);
            if(lastInvoiceList.isEmpty()) {
                lastInvoiceName = 'INV0000';
            } Else {
                lastInvoiceName = lastInvoiceList[0].Name;
            }
        }
        integer numberlength = lastInvoiceName.length() - 3;
        integer invoiceNumber = Integer.valueof(LastInvoiceName.trim().right(numberlength));
        invoiceNumber ++;
        string strInvoiceNumber = string.valueOf(invoiceNumber);
        strInvoiceNumber = strInvoiceNumber.leftPad(numberlength, '0');
        return 'INV' + strInvoiceNumber;
    }

    private static Date InvoicingDate(Date opportunityCloseDate) {

        integer opportunityCloseDay = opportunityCloseDate.day();
        integer opportunityInvoicingDay;
        integer opportunityInvoicingMonth = opportunityCloseDate.month();
        integer opportunityInvoicingYear = opportunityCloseDate.year();
        Date invoiceDate;

        if(opportunityCloseDay > 14) {
            opportunityInvoicingDay = 1;
            if(opportunityInvoicingMonth == 12) {
                opportunityInvoicingMonth = 1;
                opportunityInvoicingYear = opportunityInvoicingYear + 1;
            } else {
                opportunityInvoicingMonth = opportunityCloseDate.month() + 1;
            }
        } else {
            opportunityInvoicingDay = 15;
        }

        return invoiceDate = Date.newInstance(opportunityInvoicingYear, opportunityInvoicingMonth, opportunityInvoicingDay);
    }
}