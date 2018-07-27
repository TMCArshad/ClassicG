/**************************************************************************************************
 * Name               : GEMS_LeadTriggerHandler                                                    *
 * Description        : Lead Trigger  Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                                              *
 * V1.1     |  Umair Khan |19-Dec-2017 | Comment out creation of 'Call to Book Tour Task
 * V1.2		|  Swati	  |31-Jan-2018 | remove delete access for corporate
 **************************************************************************************************/
public without sharing class GEMS_LeadTriggerHandler {
    public GEMS_LeadTriggerHelper helper;
    public GEMS_LeadTriggerHandler() {
        helper = new GEMS_LeadTriggerHelper();
    }
    /**
     * [Execute_BI Execute before insert operations]
     * @param Lead_List
     */
    public void Execute_BI(List < Lead > Lead_List) {
         try{
	         if(GEMS_checkRecursiveTriggers.runOnceForLeadBI == true){ // to avoid recursive issue
	        	GEMS_checkRecursiveTriggers.runOnceForEnquiryBI = false; 
		        GEMS_LeadTriggerHelper.assignLeadToQueue(Lead_List,'Registrar',false);
		        GEMS_LeadTriggerHelper.assignSupportUserFromSchool(Lead_List);
			    GEMS_LeadTriggerHelper.checkForDuplicates(lead_List[0]); 
	            GEMS_LeadTriggerHelper.validateAgeCutOff(lead_List);
			    GEMS_LeadTriggerHelper.updateSchoolLogoOnInsert(Lead_List);
	         }
    	}catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
    /**
     * [Execute_AI Execute after insert operations]
     * @param Lead_List
     */
    public void Execute_AI(List < Lead > Lead_List) {
		try{
			if(GEMS_checkRecursiveTriggers.runOnceForLeadAI == true){ // to avoid recursive issue
	        	GEMS_checkRecursiveTriggers.runOnceForEnquiryAI = false; 
				GEMS_LeadTriggerHelper.syncLeadAndEnquiryOnInsert(Lead_List);
				GEMS_checkRecursiveTriggers.runOnceForLeadAI = false;
			}
		}catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
    /**
     * [Execute_BU Execute before update operations]
     * @param Lead_List
     * @param Map<Id,Lead>oldMap
     */
    public void Execute_BU(List < Lead > Lead_List, Map < Id, Lead > oldMap) {
		try{
			if(GEMS_checkRecursiveTriggers.runOnceForLeadBU == true){ // to avoid recursive issue
	        	GEMS_checkRecursiveTriggers.runOnceForEnquiryBU = false; 
	        //V1.1
	        //Case is accepted  and the status is New
	           //GEMS_LeadTriggerHelper.activityDate = System.Today();
	           //GEMS_LeadTriggerHelper.subjectVal = 'Call To Book Tour';
	           //GEMS_LeadTriggerHelper.createTaskandAssignitToOwner(GEMS_LeadTriggerHelper.getAllLeadsAcceptedByUser(Lead_List,oldMap,'New'));
	           
	           
	        //Tour Booked
	            //Create task when Any Status --> Tour Booked
	            GEMS_LeadTriggerHelper.activityDatefieldName = 'Tour_Date__c';
	            GEMS_LeadTriggerHelper.subjectVal = 'Conduct Tour';
	            GEMS_LeadTriggerHelper.createTaskandAssignitToOwner(GEMS_LeadTriggerHelper.getAllLeadsWithStatus(Lead_List, oldMap, GEMS_Constants.TOUR_BOOKED, '', false, false));
	            //Create task when lead accepted in Tour Booked Status
	            GEMS_LeadTriggerHelper.activityDatefieldName = 'Tour_Date__c';
	            GEMS_LeadTriggerHelper.subjectVal = 'Conduct Tour';
	            GEMS_LeadTriggerHelper.createTaskandAssignitToOwner(GEMS_LeadTriggerHelper.getAllLeadsAcceptedByUser(Lead_List,oldMap,GEMS_Constants.TOUR_BOOKED));
	            //Referred to another school
	            GEMS_LeadTriggerHelper.assignLeadToQueue(GEMS_LeadTriggerHelper.getLeadsAssignedToAnotherSchool(Lead_List, oldMap),'Registrar',true);
	          
	          
	            //Assign leads to Central Enrollment Officer when tour booked and contacted 2 times
	            //GEMS_LeadTriggerHelper.assignLeadToCentralEnrolmentOfficerQueue(GEMS_LeadTriggerHelper.getAllLeadsWithStatus(Lead_List, oldMap, GEMS_Constants.TOUR_NOT_ATTENDED, GEMS_Constants.CONTACTED_TWO_TIMES, false, true),'Registrar');
				
				GEMS_LeadTriggerHelper.updateSchoolLogoOnUpdate(Lead_List, oldMap);
				
				GEMS_checkRecursiveTriggers.runOnceForLeadBU = false;
	    	}
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
    /**
     * [Execute_AU Execute after update operations]
     * @param Lead_List
     * @param Map<Id,Lead>oldMap
     */
    public void Execute_AU(List < Lead > Lead_List, Map < Id, Lead > oldMap) {
    	try{
	    	if(GEMS_checkRecursiveTriggers.runOnceForLeadAU == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForEnquiryAU = false;
	            
	    		GEMS_LeadTriggerHelper.syncLeadAndEnquiryOnUpdate(Lead_List, oldMap);	
	    		GEMS_checkRecursiveTriggers.runOnceForLeadAU = false;
	    	}
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
    
    /**
     * [Execute_BD Execute before delete operations]
     * @param Lead_List
     * @param Map<Id,Lead>oldMap
     */
    public void Execute_BD(List <lead> Lead_List) {
    	try{
    		//V1.2
	    	GEMS_LeadTriggerHelper.hasDeleteAccess(Lead_List);
	    	
	    	if(GEMS_checkRecursiveTriggers.runOnceForLeadBD == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForEnquiryBD = false;
	            GEMS_LeadTriggerHelper.deleteRelatedRecords(Lead_List);
	    		GEMS_checkRecursiveTriggers.runOnceForLeadBD = false;
	    	}
	    	
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
}