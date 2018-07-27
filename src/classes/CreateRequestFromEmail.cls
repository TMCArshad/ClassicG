/* This is an Apex Class for Email Service in Case Management 
   Author : Khushboo Agarwal
   Date   : 22/04/2017
*/

global class CreateRequestFromEmail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelop){
        
        try{
            
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            system.debug('---test--'+(email.Subject).substringAfterLast(':'));    
                  
            String StdId = (email.Subject).substringAfterLast(':');
            String SchId = (email.Subject).substringAfterLast(':').substring(0,6);
            
            System.debug('StdID----->'+StdId);
            System.debug('SchID----->'+SchId);
            
            //Variable declaration
            String studentId=null;
            string studentName=null;  
            String schoolName=null;
            String schoolNameT=null;
                  
            //Retrieving Contact Id       
            List<Account> accList = [SELECT id,Name FROM Account where Student_Id__c=:StdId limit 1 ];
            System.debug('AccList----->' + accList);
            if(accList.size()>0){
            List<contact> CList = [select id from contact where accountId=:accList[0].id];
           
            if(CList.size()>0){
                studentId =CList[0].id;
            }
            }
                      
            System.debug('Info Ret----->' + studentId);
            
            //Retreiving School Id for Parent Complaints
            List<School__c> sList = [Select ID__c, Name from School__c where Id__c=:SchId limit 1];
            System.debug('sList---->'+ sList);
            if(sList.size()>0){
            schoolName=sList[0].name;
            }
            System.debug('School name---->' + SchoolName);
            
            //Retrieving School ID for Teacher Feedback
            String SchTId = (email.Subject).substringAfterLast(':');
            List<School__c> sListT = [Select ID__c, Name from School__c where Id__c=:SchTId limit 1];
            System.debug('sList---->'+ sList);
            if(sListT.size()>0){
            schoolNameT=sListT[0].name;
            }
            System.debug('School name---->' + SchoolName);
            
            //Creating New Case
            Case c = new Case();
            
            //Parent Complaints Record Type        
            if ((email.subject).contains('Student ID:')){
                
                c = new Case(
                    Student_ID__c=(email.Subject).substringAfterLast(':'),
                    subject = email.subject,
                    description = email.plainTextBody,
                    School_ID__c =(email.Subject).substringAfterLast(':').substring(0,6),
                   // ContactID=CList[0].id,
                    ContactID=studentId,
                    School_Name__c=schoolName,
                    Origin = 'Email' ,
                    Status ='New');
                    c.recordTypeID = GEMS_Utility.getRecordTypeId('Case','Parent_Complaints');
                    insert c;
                      
            //Teacher Feedback Record Type
            }else if((email.subject).contains(' (Staff)') && (email.subject).contains('School ID:')){
                c = new Case(
                subject = email.subject,
                Staff_Name__c= email.fromname.substring(0,email.fromname.indexOf(' ')),
                description = email.plainTextBody,
                School_ID__c =(email.Subject).substringAfterLast(':'),
                School_Name__c=schoolNameT,
                Origin = 'Email' ,
                Status ='New',
                Case_Assigned_To__c='Principal' );
                c.recordTypeID = GEMS_Utility.getRecordTypeId('Case','Teacher_Feedback');
                insert c;       
            }
            
            //General Record Type
            else{
                c = new Case(
                subject = email.subject, 
                description = email.plainTextBody, 
                School_ID__c =(email.Subject).substringAfterLast(':'), 
                Origin = 'Email' , Status ='New'  );
                c.recordTypeID = GEMS_Utility.getRecordTypeId('Case','General');
                insert c;
            }  
            
            //Creating new EmailMessage 
            EmailMessage Obj = new EmailMessage();
            Obj.ParentID = c.Id;
            Obj.Subject = email.Subject;
            Obj.HtmlBody = email.htmlBody;
            Obj.TextBody = email.plainTextBody;
            Obj.FromAddress = email.FromAddress;
            system.debug('Email--->'+email.toAddresses[0]);
            if(email.toAddresses!=null && email.toAddresses.size()>0){
            Obj.ToAddress = email.toAddresses[0];
            }
            if(email.ccAddresses!=null && email.ccAddresses.size()>0){
            Obj.CcAddress = email.ccAddresses[0];
            }
            Obj.MessageDate = system.today();
            Obj.FromName = email.FromName;
            insert Obj;
            system.debug('In Email Service===>'+Obj);
         
            //Creating a new Email Activity
            Email_Activities__c EObj = new Email_Activities__c   ();
            EObj .Case_ID__c= c.Id;
            EObj.Subject__c= email.Subject;
            EObj.Email_Body__c = email.htmlBody;
            EObj.Date__c=obj.MessageDate;
            EObj.From__c=email.FromAddress;
            EObj.Incoming__c=True;
            insert EObj;
            system.debug('In Email Activties===>'+EObj);
            
          //Attachments
            if(email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                for(integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                    Attachment attachment = new Attachment();
                    // attach to the newly created contact record
                    attachment.ParentId = Obj.Id;
                    attachment.Name = email.binaryAttachments[i].filename;
                    attachment.Body = email.binaryAttachments[i].body;
                    insert attachment;
                }
            }      
            return result;
        }catch(exception ex){ 
            system.debug('----Line-'+ex.getLineNumber());
        }
        return null;
    }
}