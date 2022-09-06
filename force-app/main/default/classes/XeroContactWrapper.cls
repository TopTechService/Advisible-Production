public class XeroContactWrapper {

	public List<cls_Contacts> Contacts;
	public class cls_Contacts {
        Public String SalesforceId;
        public String ContactID;	
        public String AccountNumber; 
        public String ContactStatus;	 
        public String Name;	
        public String FirstName;	
        public String LastName;	
        public String EmailAddress;	
        public String BankAccountDetails;	
        public Boolean isSupplier;
        public Boolean isCustomer;
        public List<cls_Addresses> Addresses;
        public List<cls_Phones> Phones;
	}
	public class cls_Addresses {
		public String AddressType;	
		public String City;	
		public String Region;	
		public String PostalCode;	
		public String Country;	
		public String AttentionTo;	
	}
	public class cls_Phones {
		public String PhoneType;	
		public String PhoneNumber;	
		public String PhoneAreaCode;	
		public String PhoneCountryCode;	
	}
}