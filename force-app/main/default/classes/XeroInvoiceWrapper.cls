public class XeroInvoiceWrapper {
    
    public List<cls_Invoices> Invoices;
    public class cls_Invoices {
        public String SalesforceID;
        public String InvoiceID;
        public String Type;	//ACCREC
        public cls_Contact Contact;
        public String DateString;	//2018-03-12T00:00:00
        public String DueDateString;	//2018-03-15T00:00:00
        public String FullyPaidOnDate;    // /Date(1641945600000+0000)/
        public String Status;	//DRAFT
        public String LineAmountTypes;	//Exclusive
        public String InvoiceNumber;
        public String Reference;        
        public String SubTotal;
        public String TotalTax;
        public String Total;
        public String AmountDue;
        public String AmountPaid;
        public String AmountCredited;
        public List<cls_LineItems> LineItems;
    }
    public class cls_Contact {
        public String ContactID;	//804b2f06-ba17-422b-8064-927f0aa7e53b
    }
    public class cls_LineItems {
        public String LineItemID;
        public String ItemCode;
        public String UnitAmount;	//1000.00
        public String Quantity;	//5
        public String Description;	//Consulting services as agreed
        public String AccountCode;	//200
        public String TaxType;
        public String TaxAmount;
    }
}