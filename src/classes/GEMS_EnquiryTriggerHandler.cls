/*****************************************************************************************************************************
       Modification History
    --------------------------------------------------------------------------------------------------------------------------
    Version  |  Author     |   Date       | Description
    V1.0     |  Umair Khan |  27-Nov-2017 | Comment out creation of 'Call to Book Tour Task
	V1.1	 |	Swati	   |  21-Jan-2018 |	remove delete access for corporate
*****************************************************************************************************************************/


public without sharing class GEMS_EnquiryTriggerHandler {
    public GEMS_EnquiryTriggerHandler() {
    }
    
    /**
     * [Execute_BI Execute before insert operations]
     * @param enquiryList
     */
    public void Execute_BI(list<Enquiry__c> enquiryList) {
    	try{
	    	if(GEMS_checkRecursiveTriggers.runOnceForEnquiryBI == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForLeadBI = false;
	            GEMS_EnquiryTriggerHelper.checkForDuplicates(enquiryList[0]); 
		    	GEMS_EnquiryTriggerHelper.assignEnquiryToQueue(enquiryList,'Registrar',false);
		        GEMS_EnquiryTriggerHelper.assignSupportUserFromSchool(EnquiryList);
		        GEMS_checkRecursiveTriggers.runOnceForEnquiryBI = false;
	    	}
	    	GEMS_EnquiryTriggerHelper.checkDuplicatesAmongSchool(enquiryList);
    	}catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
    
    /**
     * [Execute_AI Execute after insert operations]
     * @param enquiryList
    */
    public void Execute_AI(list<Enquiry__c> enquiryList) {
    	try{
	    	if(GEMS_checkRecursiveTriggers.runOnceForEnquiryAI == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForLeadAI = false;
	    		GEMS_EnquiryTriggerHelper.syncLeadAndEnquiryOnInsert(enquiryList);
	    		GEMS_checkRecursiveTriggers.runOnceForEnquiryAI = false;
	    	}
	    }catch(Exception e){
	    	system.debug('------'+e.getLineNumber());
		  	GEMS_Utility.logException(e);
	  	}
    }
    
    /**
     * [Execute_BU Execute before update operations]
     * @param enquiryList,Map<Id,Enquiry__c>oldMap
    */
    public void Execute_BU(list<Enquiry__c> enquiryList, map<Id, Enquiry__c> oldMap) {
    	try{
    		system.debug('---check---'+GEMS_checkRecursiveTriggers.runOnceForEnquiryBU);
	    	if(GEMS_checkRecursiveTriggers.runOnceForEnquiryBU == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForLeadBU = false;
	    	//Case is accepted  
	         
	         //V1.0
	         /* GEMS_EnquiryTriggerHelper.activityDate = System.Today();
	           GEMS_EnquiryTriggerHelper.subjectVal = 'Call to Book Tour';
	           GEMS_EnquiryTriggerHelper.createTaskandAssignitToOwner(GEMS_EnquiryTriggerHelper.getAllEnquiryAcceptedByUser(enquiryList,oldMap));
	           */
	        //End
	        
	        //Tour Booked
	            GEMS_EnquiryTriggerHelper.activityDatefieldName = 'Tour_Date__c';
	            GEMS_EnquiryTriggerHelper.subjectVal = 'Conduct Tour';
	            GEMS_EnquiryTriggerHelper.createTaskandAssignitToOwner(GEMS_EnquiryTriggerHelper.getAllEnquiryWithStatus(enquiryList, oldMap, GEMS_Constants.TOUR_BOOKED, '', false, false));
	            
	          //Referred to another school
	            GEMS_EnquiryTriggerHelper.assignEnquiryToQueue(GEMS_EnquiryTriggerHelper.getEnquiryAssignedToAnotherSchool(enquiryList, oldMap),'Registrar',true);
	          
	          //
	    		GEMS_checkRecursiveTriggers.runOnceForEnquiryBU = false;
	    	}
	    	GEMS_EnquiryTriggerHelper.checkDuplicatesAmongSchool(enquiryList);
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
		  	system.debug('-------'+e.getlinenumber());
	  	}
    }
    
    /**
     * [Execute_AU Execute after update operations]
     * @param enquiryList,Map<Id,Enquiry__c>oldMap
    */
    public void Execute_AU(list<Enquiry__c> enquiryList, map<Id, Enquiry__c> oldMap) {
    	try{
	    	if(GEMS_checkRecursiveTriggers.runOnceForEnquiryAU == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForLeadAU = false;
	    		GEMS_EnquiryTriggerHelper.syncLeadAndEnquiryOnUpdate(enquiryList,oldMap);
	    		GEMS_checkRecursiveTriggers.runOnceForEnquiryAU = false;
	    	}
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }  
    
    /**
     * [Execute_BD Execute before delete operations]
     * @param Enquiry_List
     */
    public void Execute_BD(List <Enquiry__c> Enquiry_List) {
    	try{
    		//V1.1
	    	GEMS_EnquiryTriggerHelper.hasDeleteAccess(Enquiry_List);
	    	
	    	if(GEMS_checkRecursiveTriggers.runOnceForEnquiryBD == true){ // to avoid recursive issue
	            GEMS_checkRecursiveTriggers.runOnceForLeadBD = false;
	            GEMS_EnquiryTriggerHelper.deleteRelatedRecords(Enquiry_List);
	    		GEMS_checkRecursiveTriggers.runOnceForEnquiryBD = false;
	    	}
	    	
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }   
}