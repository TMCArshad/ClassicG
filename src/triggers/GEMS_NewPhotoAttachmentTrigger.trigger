/**
 * Created by bilalnazir on 6/29/17.
 */

trigger GEMS_NewPhotoAttachmentTrigger on Attachment (after insert, after update) {

    List<Id> attachmentsIds = new List<Id>();
    Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();

    for (Attachment att:Trigger.new) {

        //001 is the starting is the ID for accounts, and attachment is of photo
        if(att.parentId != null && String.valueOf(att.parentId).startsWith('001')
                && att.Name.toLowerCase().equals('photo.jpeg')){
            attachmentsIds.add(att.ParentId);
            attachmentMap.put(att.ParentId, att);
        }
    }

    //Look for the photo attachments and update the account photo links
    List<Account> photoAttachmentAccounts = new List<Account>();
    for(Account userAccount : [SELECT id, Photo__c, Photo_URL__c FROM Account WHERE id IN:attachmentsIds]){
        if(attachmentMap.containsKey(userAccount.Id)){
            Attachment att = attachmentMap.get(userAccount.Id);

            userAccount.Photo_URL__c = Label.Attachment_File_URL+'?file=' + att.Id;
            //userAccount.Photo__c = '<img src='+Label.Attachment_File_URL+'?file=' + att.Id + ' alt="photo"/>';

            photoAttachmentAccounts.add(userAccount);
        }
    }
    update photoAttachmentAccounts;
    
    //code added by Mahadev to real time sync attachments 
    ////check if the attachment parent is account
    //if it is Account call the Informatic job to execute
    
    boolean isAccountsAttachment = false;
    if(!attachmentsIds.isEmpty() && attachmentsIds.size() > 0){
        isAccountsAttachment = true;
    }
    
    if(isAccountsAttachment){
        GEMS_AttachmentCalloutHandler.makeCalloutToInformatica();
    }

}