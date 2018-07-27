global without sharing class GEMS_CC_SendEmailToFinance implements HexaBPM.iCustomCodeExecutable{
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step){
        String msg = 'success';
        try{
                
                EmailTemplate emailTemplate;
                for(EmailTemplate et : [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName =: 'GEMS_TC_Clearance_Email']){
                    emailTemplate = et;
                }
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
      for(HexaBPM__Service_Request__c SRobj:  [SELECT Id,
                                                  School__c,
                                                  Student__c,
                                                  School__r.Principal__r.Email__c,
                                                  School__r.Lab_Email__c,
                                                  School__r.Finance_Officer_Email__c,
                                                  School__r.Library_Email__c,
                                                  School__r.Registrar__r.Email
                                        FROM      HexaBPM__Service_Request__c
                                        WHERE     Id=: step.HexaBPM__SR__c
                                                  
                                                  ]){
                                           objSR = SRobj;           
                                                  }        
                String[] toAddresses = new String[] {};
                if(objSR.School__r.Finance_Officer_Email__c != NULL){
                    toAddresses.add(objSR.School__r.Finance_Officer_Email__c);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                    mail.setWhatId(step.HexaBPM__SR__c);
                    if(emailTemplate != NULL) mail.setTemplateId(emailTemplate.Id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } 
            } catch(Exception e){
            msg = e.getMessage();
        }
        return msg;
    }
}