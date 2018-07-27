/**************************************************************************************************
* Name               : GEMS_CC_SendClearanceEmail                                                               *
* Description        : Implements HexaBPM  iCustomCodeExecutable interface. Executes default action of clearance step for SR type = TC_Request                                       *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017
* 1.1        Leeba        25/3/2018 CR - 312, Copy LDA to Account and update the Leave Date in student and SR if the Leave Date is less than todays date
                                              if the student's Academic year is active.
**************************************************************************************************/
global without sharing class GEMS_CC_SendClearanceEmail implements HexaBPM.iCustomCodeExecutable {
    
    
     global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
     try{

      String result = 'Success';
      Account Student;
      HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
      Savepoint sp =  database.setSavePoint();
      for(HexaBPM__Service_Request__c SRobj:  [SELECT Id,
                                                  School__c,
                                                  Student__c,
                                                  School__r.Lab_Email__c,
                                                  School__r.Finance_Officer_Email__c,
                                                  School__r.Library_Email__c,
                                                  School__r.Registrar__r.Email,
                                                  School__r.Principal__r.Email__c,
                                                  School__r.STS_Email__c,
                                                  School__r.Principals_PA_Email__c,
                                                  HexaBPM__Email__c,
                                                  Date_of_leaving__c,
                                                  Academic_Year__c,
                                                  Academic_Year__r.Sys_Active__c,
                                                  Last_Date_of_Attendance__c
                                        FROM      HexaBPM__Service_Request__c 
                                        WHERE     Id=: step.HexaBPM__SR__c
                                                  
                                                  ]){
                                           objSR = SRobj;           
                                                  }
      System.debug('objSR.Student__c==>'+objSR.Student__c);
      //Change the status of student                                         
      student = new Account(Id = objSR.Student__c );
      
      if(objSR.Date_of_leaving__c != NULL && objSR.Date_of_leaving__c <= System.Today()){
           student.current_Status__c = 'TC';
      }
	  //start of 1.1
      if(objSR.Academic_Year__c!=null && objSR.Academic_Year__r.Sys_Active__c && objSR.Date_of_leaving__c < System.Today()){
          student.Leave_Date__c = system.today();
		  student.Last_Att_Date__c = objSR.Last_Date_of_Attendance__c;
          objSR.Date_of_leaving__c = system.today();
          objSR.sys_Allow_change_of_Leaving_Date__c = true;
      }else{
          student.Leave_Date__c = objSR.Date_of_Leaving__c;
		  student.Last_Att_Date__c = objSR.Last_Date_of_Attendance__c;
		}
	   //end of 1.1
      update student;   
                                              
      objSR.Send_Clearance_Email__c = true;
      update objSR;
     
     
     
     }
     catch(Exception e){
       GEMS_Utility.logException(e);
       String message = (e.getTypeName().equals('System.DmlException')) ? e.getDMLMessage(0)  : e.getMessage() ;   
       return message;
     }
      return NUll;
     }
     

    
     
}