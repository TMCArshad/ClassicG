public without sharing class GEMS_EmailHelper {
	public Messaging.SingleEmailMessage singleEmailMessage;
	public List<String> toAddresses{get;set;}
	public String subject {get;set;}
	public String htmlBody {get;set;}
	public Boolean useSignature = false;
	public List<Messaging.EmailFileAttachment> fileAttachments = null;
	public String senderDisplayName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
	User currentUser = [Select email from User where username = :UserInfo.getUserName() limit 1];
	public String replyTo = currentUser.email;
	public String plainTextBody {get;set;}
	public String TemplateID {get;set;}
	public GEMS_EmailHelper(List<String> addresses) {
		toAddresses = new List<String>();
		toAddresses = addresses;
	}


   public void build() {
           singleEmailMessage = new Messaging.SingleEmailMessage();
           singleEmailMessage.setToAddresses(this.toAddresses);
           singleEmailMessage.setSenderDisplayName(this.senderDisplayName);
           singleEmailMessage.setSubject(this.subject);
           singleEmailMessage.setHtmlBody(this.htmlBody);
           singleEmailMessage.setUseSignature(this.useSignature);
           singleEmailMessage.setReplyTo(this.replyTo);
           singleEmailMessage.setPlainTextBody(this.plainTextBody);
           if(TemplateID != NULL){
           singleEmailMessage.setTemplateId(TemplateID);
           }
           //singleEmailMessage.setFileAttachments(this.fileAttachments);
          
       }

       public void sendEmail() {
         try{
             build();
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });

         	}catch(Exception e){
               GEMS_Utility.LogException(e);

         	}

       }
}