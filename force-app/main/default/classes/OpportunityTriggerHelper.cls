/*---------------------------------------------------------------------------------------------------------------------------------------------------------------
Description     : Trigger for Opportunity
Inputs          : "Opportunities" - Opportunity records that are being triggered
Test Classes    : OpportunityTriggerHelperTest
History:
---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public inherited sharing class OpportunityTriggerHelper { 
    
    /*
* PURPOSE  : Send Email to custom setting records with Opportunity details and attachment
* PARAM    : Opportunity List
* RETURNS  : Void
*/
    public static void email_send(Map<Id,Opportunity> mapNewOpportunities,Map<Id,Opportunity> mapOldOpportunities)
    {
        //Created List of Email
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        //Close Opportunity List
        List<Opportunity> opportunityCloseList = new List<Opportunity>();
        List<String> closedOpportunityIds = new List<String>();
        for(Opportunity opportunityRec: mapNewOpportunities.values()){
            if(opportunityRec.IsClosed && opportunityRec.IsClosed != mapOldOpportunities.get(opportunityRec.Id).IsClosed)
            {
                opportunityCloseList.add(opportunityRec);
                closedOpportunityIds.add(opportunityRec.Id);
            }
        }
        
        if(!opportunityCloseList.isEmpty()){
            //Query Template to use in Email
            EmailTemplate emailtempRecord  = [Select id, Name, Body, Subject, HtmlValue
                                              from EmailTemplate 
                                              where Name =: 'Notify Bellina About Closed Opportunity'];

            //Query Content Document Links related to opportunities
            Map<Id, List<String>> documentLinkMap = new Map<Id, List<String>>();
            List<String> contentDocumentIds = new List<String>();

            for(ContentDocumentLink documentLink : [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                    FROM ContentDocumentLink
                                                    WHERE LinkedEntityId IN :closedOpportunityIds]) {
                                                        if(!documentLinkMap.containsKey(documentLink.LinkedEntityId)) {
                                                            documentLinkMap.put(documentLink.LinkedEntityId,new List<String>());
                                                        }
                                                        documentLinkMap.get(documentLink.LinkedEntityId).add(documentLink.ContentDocumentId);
                                                        contentDocumentIds.add(documentLink.ContentDocumentId);
                                                    }

            //Build a map of content documents and latest versions
            Map<Id, String> documentLatestVersionMap = new Map<Id, String>();
            for(ContentDocument documentRecord : [SELECT Id, LatestPublishedVersionId
                                                  FROM ContentDocument
                                                  WHERE Id IN :contentDocumentIds]) {
                                                      documentLatestVersionMap.put(documentRecord.Id, documentRecord.LatestPublishedVersionId);
                                                  }

            //Build a map of Opportunity and ContentVersions
            Map<Id, List<String>> documentVersionMap = new Map<Id, List<String>>();
            Map<Id, Id> contentVersionOpportunityMap = new Map<Id, Id>();
            List<Id> contentVersionIds = new List<Id>();

            for(Id idValue :documentLinkMap.keySet()) {
                if(!documentVersionMap.containsKey(idValue)) {
                    documentVersionMap.put(idValue, new List<String>());
                }
                for(String str :documentLinkMap.get(idValue)) {
                    documentVersionMap.get(idValue).add(documentLatestVersionMap.get(str));
                    contentVersionIds.add(documentLatestVersionMap.get(str));
                    contentVersionOpportunityMap.put(documentLatestVersionMap.get(str), idValue);
                }
            }

            //Query Content Versions related to customer form
            Map<ID, List<ContentVersion>> attachmentMap = new Map<Id, List<ContentVersion>>();
            System.debug('contentVersion IDs:' + contentVersionIds);
            for(ContentVersion attachRecords : [SELECT Id, Title, VersionData
                                                FROM ContentVersion
                                                WHERE Title Like '%New customer form%' AND Id IN :contentVersionIds]) {
                                                    if(!attachmentMap.containsKey(contentVersionOpportunityMap.get(attachRecords.Id))) {
                                                        attachmentMap.put(contentVersionOpportunityMap.get(attachRecords.Id),new List<ContentVersion>());
                                                    }
                                                    attachmentMap.get(contentVersionOpportunityMap.get(attachRecords.Id)).add(attachRecords);
                                              } 

            
            //Create List of Emails to whome Email is to be sent
            List<String> toAddressList= new List<String>();
            
            for(OpportunityStageCloseMail__c customMailList:OpportunityStageCloseMail__c.getall().values()){
                if(!String.isBlank(customMailList.Email__c)){
                    toAddressList.add(customMailList.Email__c);    
                }
            }

            //Get the org wide address to be used as the from address
            String orgWideEmailAddressID;
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'welcome@advisible.com.au'];
            if ( owea.size() > 0 ) {
                orgWideEMailAddressID = owea.get(0).Id;
            }
            
            for(Opportunity opportunityRecord :opportunityCloseList) {
                //Created List of Attachments related to every opportunity
                List<Id> ownerIDs = New List<Id>();
                if(opportunityRecord.IsClosed && !toAddressList.isEmpty() )
                {
                    System.debug('Oppo: ' + opportunityRecord.Id);
                    System.debug('Map:' + attachmentMap);
                    System.debug('Map Value: ' + attachmentMap.get(opportunityRecord.Id));
                    Messaging.SingleEmailMessage renderTemplate = Messaging.renderStoredEmailTemplate(emailtempRecord.Id, opportunityRecord.Contact__c, opportunityRecord.Id); 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddressList);
                    ownerIDs.add(OpportunityRecord.OwnerId);
                    mail.setCcAddresses(OwnerIDs);
                    mail.setSubject(renderTemplate.getSubject());
                    mail.setHtmlBody(renderTemplate.getHtmlBody());
                    mail.setOrgWideEmailAddressId(orgWideEmailAddressID);
                    
                    //Add attachments
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    if(attachmentMap.get(opportunityRecord.Id) != null) {

                        for (ContentVersion attachment : attachmentMap.get(opportunityRecord.Id))
                        {
                            Messaging.Emailfileattachment emailAttachment = new Messaging.Emailfileattachment();
                            emailAttachment.setFileName(attachment.Title);
                            emailAttachment.setBody(attachment.VersionData);
                            fileAttachments.add(emailAttachment);
                        }
                    }
                    mail.setFileAttachments(fileAttachments);
                    mailList.add(mail);
                }
                
            }
            
            //Send Mail to if list size is not zero
            if ( mailList.size() > 0 )
                Messaging.sendEmail(mailList);//Send mail to ContactList
            
        }
        
    }
    
    public static void OpportunityTriggerHelper(List<Opportunity> OpportunitiesFromTrigger) {
        
        try {
            pushInvoiceRecSfToXero.pushInvoiceRecSfToXero(OpportunitiesFromTrigger);
        } catch(Exception e) {
            XeroErrorHandling.insertErrorDebugLog(e.getMessage());
        }
    }
}