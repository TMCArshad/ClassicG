/**************************************************************************************************
* Name               : GEMS_UpdateSR                                                               *
* Description        : This class implements logic on approval of Strike off and Edit Critical Data  
*                                               *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         7/05/2017
  1.1         Leeba       25/3/2018 - Added the code to copy the LDA and Date of Leaving from Strike off SR to Account, CR - 312

**************************************************************************************************/
global without sharing class GEMS_CC_UpdateAccountData implements HexaBPM.iCustomCodeExecutable {

	global String EvaluateCustomCode(HexaBPM__Service_Request__c objSR, HexaBPM__Step__c step) {
    	String retStr = 'Success';
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        try {
            list<HexaBPM__Service_Request__c> srList = [SELECT Id, Academic_Year__c, GradeLookup__c,
	                                                    Section_Lookup__c, Curriculum__c,
	                                                    Stream__c, Strike_Off_reason__c,
	                                                    HexaBPM__Record_Type_Name__c, Student__c,
	                                                    Joining_Date__c,Last_Date_of_Attendance__c,
	                                                    Date_of_Leaving__c
	                                                    FROM  HexaBPM__Service_Request__c
	                                                    WHERE Id = : step.HexaBPM__SR__c];
            
            if(srList!=null && srList.size()>0){
            	SR = srList[0];	
            }
            //Edit critical Details
            if(SR.HexaBPM__Record_Type_Name__c == 'Edit_Critical_Data'){
                updateStudentEditCriticalData(SR);
            }
            else if(SR.HexaBPM__Record_Type_Name__c == 'Strike_Off'){
                updateStudentStrikeOff(SR);
            }
        } catch (DmlException e) {
            GEMS_Utility.LogException(e);
            retStr = e.getMessage();
        }
        return retStr;
    }
     
    
	public static void updateStudentEditCriticalData(HexaBPM__Service_Request__c SR){
	    system.debug('--1--'+SR.Academic_Year__c);
	    system.debug('--2--'+SR.GradeLookup__c);
	    system.debug('--3--'+SR.Section_Lookup__c);
	    system.debug('--4--'+SR.Joining_Date__c);
	    
	    Account studentAcc = new Account(id = SR.Student__c);
	    if(SR.Academic_Year__c!=null)
	    	studentAcc.Academic_Year__c =SR.Academic_Year__c;
	    
	    if(SR.GradeLookup__c!=null)
	    	studentAcc.GradeLookup__c =SR.GradeLookup__c;
	    	
	    if(string.isNotBlank(SR.Stream__c))
	    	studentAcc.Stream__c =SR.Stream__c;
	    	
	    if(string.isNotBlank(SR.Curriculum__c))
	    	studentAcc.Curriculum_Current__c =SR.Curriculum__c;
	    	
	    if(SR.Section_Lookup__c!=null)
	    	studentAcc.Section__c =SR.Section_Lookup__c;
	    
	    if(SR.Joining_Date__c!=null)
	    	studentAcc.Date_of_Join__c =SR.Joining_Date__c;
	    	
	    update studentAcc;
    }
    
    public static void updateStudentStrikeOff(HexaBPM__Service_Request__c SR){
       Account studentAcc = new Account(id = SR.Student__c);
       studentAcc.Strike_Off_reason__c =  SR.Strike_Off_reason__c;
       studentAcc.current_Status__c = 'SO';
       // start of 1.1
       studentAcc.Last_Att_Date__c = SR.Last_Date_of_Attendance__c;
       studentAcc.Leave_date__c = SR.Date_of_Leaving__c;
       studentAcc.SO_Cancel_Date__c = NULL;
       //end of 1.1
       update studentAcc;
    }
    
}