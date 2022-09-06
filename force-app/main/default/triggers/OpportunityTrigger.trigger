/*---------------------------------------------------------------------------------------------------------------------------------------------------------------
Description     : Trigger for Opportunity records
Inputs          : "Opportunities" - Opportunityrecords that are being triggered
Handler Classes : OpportunityTriggerHelper
Test Classes    : OpportunityTriggerHelperTest
History:
---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
trigger OpportunityTrigger on Opportunity (after update,before Insert) {
    
    if (Trigger.isAfter) 
    {
        /*
         * Send Email When Opportunity Stage is Closed
         */
        if(Trigger.isUpdate){
            OpportunityTriggerHelper.email_send(Trigger.newMap,Trigger.oldMap);
        }     
    } 
    
    
    List<Opportunity> closedWon = New List<Opportunity>();
    for(Opportunity opp :trigger.new) {
        if(opp.StageName == 'Closed Won' && trigger.oldMap.get(opp.Id).StageName != 'Closed Won' && opp.Account_Type__c == 'Customer') {
            closedWon.add(opp);
        }
    }
    if(closedWon.size() != 0) {
//        pushInvoiceRecSfToXero.pushInvoiceRecSfToXero(closedWon);
        OpportunityTriggerHelper.OpportunityTriggerHelper(closedWon);
    }
    
    
}