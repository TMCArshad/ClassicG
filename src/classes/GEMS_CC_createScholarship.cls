/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   22th March 2018
    Description :   Convert scholarship SR into scholarship record.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History 
----------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global without sharing class GEMS_CC_createScholarship implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        String msg = 'success';
        Savepoint spdata = Database.setSavepoint();
        try { 
        	
        	if(step.HexaBPM__SR__c!=null){
        		
        		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        		objSR = step.HexaBPM__SR__r;
        		if(step.Step_Name__c=='School Principle Approval'){
	        		if(objSR.Academic_Year__c == null || objSR.GradeLookup__c == null){
	        			msg = 'Please provide AY and grade.';	
	        			return msg;			
	        		}
	        		
	        		if(objSR.Eligible_for_Scholarship_Program__c == false){
	        			msg = 'Please verify AY and grade and check Eligible for Scholarship Program before approving the step.';				
	        			return msg;
	        		}
        		}
        		if(step.Step_Name__c=='Chief Enrolment Officer Approval'){
	        		if(string.isNotBlank(objSR.Scholarship_Category__c)){
		        		Id recTypeID = Schema.SObjectType.scholarship__c.getRecordTypeInfosByName().get(objSR.Scholarship_Category__c).getRecordTypeId();
		    	
		        		scholarship__c objScholarship = new scholarship__c();
		        		if(objSR.student__c!=null)
		        			objScholarship.student__c = objSR.student__c;
		        		if(objSR.Service_Request__c!=null)
		        			objScholarship.Enrolment_SR__c = objSR.Service_Request__c;
		        		
		        		objScholarship.recordtypeid = recTypeID;
		        		objScholarship.Scholarship_SR__c = objSR.id;
		        		objScholarship.active__c = true;
		        		
						for(Scholarship_Sync__c obj : Scholarship_Sync__c.getAll().values()){
		                	objScholarship.put(obj.Scholarship_Field__c,objSR.get(obj.SR_Field__c));
		              	}
		              	
		        		insert objScholarship;
		        		
		        		if(objScholarship!=null && objScholarship.id!=null){
		        			list<HexaBPM__SR_Doc__c> tempSRDocList = new list<HexaBPM__SR_Doc__c>();
		        			tempSRDocList = [select id,HexaBPM__Customer__c,Scholarship__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c =: step.HexaBPM__SR__c];
		        			if(tempSRDocList!=null && tempSRDocList.size()>0){
		        				for(HexaBPM__SR_Doc__c obj : tempSRDocList){
		        					obj.Scholarship__c = objScholarship.id;
		        				}
		        				update tempSRDocList;
		        			}
		        		}
	        		}
        		}
        	}	
        }catch (Exception e) {
            msg = e.getMessage()+ '-----' + e.getLineNumber();
            system.debug('----msg----'+msg);
            Database.rollback(spdata);
        }
        return msg;
    }
}