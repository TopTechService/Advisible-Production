trigger accountTrigger on Account (after insert) {
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            
        } else if (Trigger.isAfter) {
            for(Account ac :Trigger.new) {
                if(ac.Type == 'Customer') {
                    try {
                        pushAccountToXeroContact.pushAccountToXeroContact(Trigger.New);
                    } catch(Exception e) {
                        XeroErrorHandling.insertErrorDebugLog(e.getMessage());
                    }
                    
                }
            }
        }
    }
}