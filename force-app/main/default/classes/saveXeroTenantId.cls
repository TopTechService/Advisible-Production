public with sharing class saveXeroTenantId {
    
    public static void saveXeroTenantId(string xeroTenantID) {
        
        //Check if there is an existing record
        List<Xero_Setting__c> updatedXeroSettings = New List<Xero_Setting__c>();
        List<Xero_Setting__c> xeroSettings = New List<Xero_Setting__c>([SELECT Xero_Tenant_ID__c FROM Xero_Setting__c]);
        if(xeroSettings.size() == 0) {
            //Record does not exist so create it
            Xero_Setting__c newXeroSetting = New Xero_Setting__c(Name = 'Xero', Xero_Tenant_ID__c = xeroTenantID);
            insert newXeroSetting;
        } else {
            //Update existing xero setting
            for(Xero_Setting__c x : xeroSettings) {
                x.Xero_Tenant_ID__c = xeroTenantID;
                updatedXeroSettings.add(x);
            }
            update updatedXeroSettings;
        }
    }
}