/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Assign registrar as an owner to step created under Enrollment depending on the school selected on SR
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/


global without sharing class GEMS_CC_AssignStepOwner implements HexaBPM.iStepAssignmentExecutable {
    
    //Assigns owner for the first step that is created on SR submit
	global List<HexaBPM__Step__c> Assign_Step_Owner_SR_Submit(Map<String, HexaBPM__Service_Request__c> MapSRs, list<HexaBPM__Step__c> lstSteps, Map<String, HexaBPM__SR_Steps__c> MapSRSteps) {
    	System.debug('==>Assign_Step_Owner_SR_Submit<==');
    	lststeps = assignStepOwnerMethod(lststeps);
    	return lstSteps;
  	}
   
	//Assigns owner for the subsquent steps that are created depending on closure of previous step
	global list<HexaBPM__Step__c> Assign_Step_Owner_Step_Closure(Map<String, HexaBPM__Step__c> MapSteps, list<HexaBPM__Step__c> lstSteps, Map<String, HexaBPM__SR_Steps__c> MapSRSteps) {
    	System.debug('==>Assign_Step_Owner_Step_Closure<==');
    	return lststeps;
  	} 
  	
  	public static list<HexaBPM__Step__c> assignStepOwnerMethod(list<HexaBPM__Step__c> lstSteps){
  		map<string,GEMS_Queue_Config__c> customSettingsForQueue = GEMS_Queue_Config__c.getAll();
  		map<string,string> mapOfSchoolAndQueue = new map<string,string>();
  		map<string,id> mapOfQueueAndId = new map<string,id>();
  		if(customSettingsForQueue!=null && customSettingsForQueue.size()>0){
  			for(GEMS_Queue_Config__c var : customSettingsForQueue.values()){
  				mapOfSchoolAndQueue.put(var.School_Name__c,var.Queue_Name__c);	
  			}	
  			for(Group grp : [Select Id,Name,DeveloperName from Group where type = 'Queue' and DeveloperName = :mapOfSchoolAndQueue.values()]){
	        	mapOfQueueAndId.put(grp.DeveloperName,grp.id);
			}
  			
  		}
  		
  		map<id,string> serviceRequestAndLinkedSchool = new map<id,string>();
  		if(lstSteps!=null && lstSteps.size()>0 && mapOfSchoolAndQueue!=null && mapOfSchoolAndQueue.size()>0){
  			for(HexaBPM__Step__c objStep : lstSteps){
  				objStep.OwnerId = mapOfQueueAndId.get(mapOfSchoolAndQueue.get(objStep.HexaBPM__SR__r.School_Name_Dev__c));
  			}	
  			return lstSteps;
  		}
  		return null;
  	}
    
}