/******************************************************************
 *   Author       :  Khushboo Agarwal
 *   Description  : Controller for Sending Emails from Case Object
 *   Date         : 23/04/2017    
 ******************************************************************/
public class EmailComposePageController {
  /* Variable Declaration */
    public List<Email_Activities__c> lastMsg = new List<Email_Activities__c>();
    public List<Attachment> attList{get;set;}
    private List<String> emailIds;
    public String emailVal{get;set;}
    public String cc{get;set;}
    public String emailSubject{get;set;}
    public String body{get;set;} 
    private List<String> ccEmailIds;
    public ID CaseID{get; set;}
    public String EmailBody='';
    public Attachment att{get;set;}
    
    /*** Defining the constructor ***/
    public EmailComposePageController(Apexpages.StandardController stdController){
        attList = new List<Attachment>();
        att = new Attachment();
        CaseID = ApexPages.currentPage().getParameters().get('CaseID');
        system.debug('CASE ID----->' + CaseID);
        
        lastMsg = [Select id,Name,Email_Body__c,Subject__c,From__c,Incoming__c,Case_ID__c from Email_Activities__c where Case_ID__c =:CaseID AND Incoming__c=true order by Name Asc limit 1];
        system.debug('lastMsg==>'+lastMsg);
        if(!lastMsg.isEmpty()){
            system.debug('Subject==>'+lastMsg[0].Subject__c);
            String Subject = (lastMsg[0].Subject__c).contains('ID:_')?lastMsg[0].Subject__c:'Case Ref ID - '+lastMsg[0].Case_ID__c+' - '+lastMsg[0].Subject__c;
            emailSubject = Subject;
            emailVal = lastMsg[0].From__c;
          //  system.debug('Ass Case-->'+lastMsg[0].Project_Task__r.Case__c);
          //  Document doc= [Select id,body from Document where name='EmailSignature'];
        }
    }
    
    /*** Method to attach attachment to attachment list. ***/
    public Pagereference upload(){
        if(att.name == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select File Path First.'));
        }
        else{
            att.OwnerId = UserInfo.getUserId();
            attList.add(att);
            att = new Attachment();
        } 
        CaseID = ApexPages.currentPage().getParameters().get('CaseID');
        system.debug('Case ID --->'+CaseID );
        return null;       
    }
    
    /*** Method to redirect to the project scope page ***/
    public PageReference Cancel() {
        return null;
    }
    
    /*** Method to send email ***/
    public PageReference sendMail() { 
        system.debug('In Mail--->');
       if( emailVal !=null && emailVal!='' && emailVal.length() > 0 )
           emailIds = emailVal.split(';');
       if( cc !=null && cc!='' && cc.length() > 0 )
           ccEmailIds = cc.split(';');
       try{
       EmailBody = '<html><head><style type="text/css">#outlook a{padding:0;}.ReadMsgBody{width:100%;} .ExternalClass{width:100%;}.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {line-height: 100%;}body, table, td, p, a, li, blockquote{-webkit-text-size-adjust:100%; -ms-text-size-adjust:100%;}table, td{mso-table-lspace:0pt; mso-table-rspace:0pt;}img{-ms-interpolation-mode:bicubic;}body{background-color:#FAFAFA;margin:0; padding:0;font-family: Arial;}img{border:0; height:auto; line-height:100%; outline:none; text-decoration:none;}table{border-collapse:collapse !important;}body{height:100% !important; margin:0; padding:0; width:100% !important;}p,a{line-height: 140%;}p{margin: 13px 0px;}#headerImage{height:auto;width:100%;display: block;max-width: 600px;}#templateHeader{background-color:#F4F4F4;border-top:1px solid #FFFFFF;border-bottom:1px solid #CCCCCC;}#templateContainer{max-width:600px;width: 100%;border:1px solid #DDDDDD;background-color: white;}#templateContent{font-size: 15px;}#templateFooter{font-size: 13px;color: #474747;}#footer-logo{width: 60px;}#tableBody{width: 100% !important;max-width: 600px;}</style></head><body style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;background-color: #FAFAFA;margin: 0;padding: 0;font-family: Arial;height: 100% !important;width: 100% !important;"><center><table id="tableBody" border="0" cellpadding="0" cellspacing="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;max-width: 600px;border-collapse: collapse !important;width: 100% !important;">                              <tr height="20"></tr><tr><td style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;"><table id="templateContainer" border="0" cellpadding="0" cellspacing="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;max-width: 600px;width: 100%;border: 1px solid #DDDDDD;background-color: white;border-collapse: collapse !important;"><tr><td align="center" valign="top" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;"><table border="0" cellpadding="0" cellspacing="0" width="100%" id="templateHeader" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;background-color: #F4F4F4;border-top: 1px solid #FFFFFF;border-bottom: 1px solid #CCCCCC;border-collapse: collapse !important;"><tr><td valign="top" class="headerContent" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;"><img width="600" src="http://www.nsigulf.com/email_banner.png" id="headerImage" alt="NSI" style="-ms-interpolation-mode: bicubic;border: 0;height: auto;line-height: 100%;outline: none;text-decoration: none;width: 100%;display: block;max-width: 600px;"></td></tr></table></td></tr><tr><td align="center" valign="top" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;"><tr height="10"></tr><tr height="5"></tr><tr><td width="5%" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;"></td><td valign="top" id="templateFooter" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;font-size: 13px;color: #474747;"><p style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;line-height: 140%;margin: 13px 0px;">'+body+'<br/><br/><br/>Kind regards,</p><p style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;line-height: 140%;margin: 13px 0px;"><b>GEMS Support</b></p><p style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;line-height: 140%;margin: 13px 0px;"><b>P</b>'+lastMsg[0].Email_body__c+'</tr></table></td></tr><tr height="20"></tr></table></center></body></html>';
       Messaging.SingleEmailMessage mail = sendEmail(emailIds ,ccEmailIds ,null, emailSubject, EmailBody);
       system.debug('Mail--->'+mail);
       if(mail != null){
           Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
           system.debug('After Email');
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Email Has Been Sent');
           ApexPages.addMessage(myMsg);
       }
       }catch(Exception e){system.debug(e);}    
       
       PageReference reference=new PageReference('/'+CaseID);
       reference.setRedirect(true);
       return reference;
    }
    
    // The mail is sent from this method
    private Messaging.SingleEmailMessage sendEmail( List<String> toMail, List<String> ccEmailIdList,List<String> bccEmailIdList, String strSubject, String strMsgBody ){
        List<Messaging.EmailFileAttachment> mailAttList = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toMail);
        if(ccEmailIdList != null && ccEmailIdList.size()>0){
            email.setCcAddresses(ccEmailIdList);
        }
        if(bccEmailIdList != null && bccEmailIdList.size()>0){
            email.setBccAddresses(bccEmailIdList);
            email.setBccSender(true);
        }
        email.setSubject(strSubject);    
        email.setHTMLBody(strMsgBody);
        email.setSaveAsActivity(false);
        Attachment myduplicate;
        List<Attachment> InsertAttachments = new List<Attachment>();
        for(Attachment att1 : attList){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setBody(att1.body);
            efa.setFileName(att1.name);
            mailAttList.add(efa);
            
            myduplicate=new Attachment();
            myduplicate.Name=att1.Name;
          //  myduplicate.parentid = EmailMsg.Case;
            myduplicate.Body=att1.Body;
            InsertAttachments.add(myduplicate);
        }
        email.setFileAttachments(mailAttList);
        Messaging.SendEmailResult[] sendResult;
    
        //Create Email Message
        EmailMessage newEmail = new EmailMessage(
        FromAddress ='case-support@14ae5daqkpaoa0iy6mfvk978w2y5dig6pc11ca1yfs32lh99du.9e-cvusuac.cs88.apex.sandbox.salesforce.com',
        ToAddress = toMail[0],
        Subject = strSubject,
        HTMLBody = body,
        MessageDate = system.today(),
        ParentId = lastMsg[0].Case_ID__c);
        insert newEmail;
        for(Attachment att : InsertAttachments){
            att.parentid  = newEmail.id;
        }
        insert InsertAttachments;
        system.debug('After Attachments');
        return  email ;
    }
}