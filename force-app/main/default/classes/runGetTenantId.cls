public class runGetTenantId {
    public void runGetTenantId() {
            GetXeroTenantId.getXeroTenantId();
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Getting Xero Tenant ID.'));
    }
}