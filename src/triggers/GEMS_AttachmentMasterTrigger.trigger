trigger GEMS_AttachmentMasterTrigger on Attachment (after insert, after update) {
    
    /*//check if the attachment parent is account
    //if it is Account call the Informatic job to execute
    List<Attachment> lstAttachments = Trigger.New;
    boolean isAccountsAttachment = false;
    for(Attachment attach : lstAttachments){
        if(String.valueOf(attach.ParentId).startsWith('001')){
            isAccountsAttachment = true;
        }
    }
    
    if(isAccountsAttachment){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint('https://ps1w2.rt.informaticacloud.com/active-bpel/public/rt/001OL7/SFDC-Attachment-To-SQLSERVER');
        req.setMethod('GET');
        try{
            if(!system.test.isRunningTest()){
                res = http.send(req);
            }
            system.debug('res==>'+res);
            system.debug('res==>'+res.getBody());
        }catch(System.CalloutException e){
            System.debug('Job Error: '+ e);
            System.debug(res.toString());
        }
    }*/
}