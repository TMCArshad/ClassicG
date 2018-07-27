/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Assign registrar as an owner to step created under Enrollment depending on the school selected on SR
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/


global without sharing class CC_Step_Assignment implements HexaBPM.iStepAssignmentExecutable {

  //Assigns owner for the first step that is created on SR submit
  global List<HexaBPM__Step__c> Assign_Step_Owner_SR_Submit(Map<String, HexaBPM__Service_Request__c> MapSRs, list<HexaBPM__Step__c> lstSteps, Map<String, HexaBPM__SR_Steps__c> MapSRSteps) {
    System.debug('***Submit:' + lstSteps);
    list<HexaBPM__Step__c> stepsWithOwnerAssigned = assignStepOwner(lstSteps);
    return stepsWithOwnerAssigned;

  }

  //Assigns owner for the subsquent steps that are created depending on closure of previous step
  global list<HexaBPM__Step__c> Assign_Step_Owner_Step_Closure(Map<String, HexaBPM__Step__c> MapSteps, list<HexaBPM__Step__c> lstSteps, Map<String, HexaBPM__SR_Steps__c> MapSRSteps) {
    System.debug('***Closure:' + lstSteps);
    list<HexaBPM__Step__c> stepsWithOwnerAssigned = assignStepOwner(lstSteps);
    return stepsWithOwnerAssigned;

  }




  /*
   * name     : assignStepOwnerMethod
   * param    : list of steps
   * return   : list of steps
  */
  /*
  public static list<HexaBPM__Step__c> assignStepOwnerMethod(list<HexaBPM__Step__c> lstSteps) {
    map<string, GEMS_Queue_Config__c> customSettingsForQueue = GEMS_Queue_Config__c.getAll();
    map<string, string> mapOfSchoolAndQueue = new map<string, string>();
    map<string, id> mapOfQueueAndId = new map<string, id>();
    if (customSettingsForQueue != null && customSettingsForQueue.size() > 0) {
      for (GEMS_Queue_Config__c var : customSettingsForQueue.values()) {
        if (var.Queue_Type__c == 'Registrar') {
          mapOfSchoolAndQueue.put(var.School_Code__c, var.Queue_Name__c);
        }
      }
      for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue' and DeveloperName = :mapOfSchoolAndQueue.values()]) {
        mapOfQueueAndId.put(grp.DeveloperName, grp.id);
      }

    }

    map<id, string> serviceRequestAndLinkedSchool = new map<id, string>();
    if (lstSteps != null && lstSteps.size() > 0 && mapOfSchoolAndQueue != null && mapOfSchoolAndQueue.size() > 0) {
      map<id, HexaBPM__Service_Request__c> mapOfIdAndSR = new map<id, HexaBPM__Service_Request__c>();

      list<id> tempSRList = new list<id>();
      for (HexaBPM__Step__c objStep : lstSteps) {
        tempSRList.add(objStep.HexaBPM__SR__c);
      }
      if (tempSRList != null && tempSRList.size() > 0) {
        for (HexaBPM__Service_Request__c obj : [select id, School__r.Short_Name__c, School_Name_Dev__c, ownerId, HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where id IN : tempSRList]) {
          mapOfIdAndSR.put(obj.id, obj);
        }
      }

      for (HexaBPM__Step__c objStep : lstSteps) {
        if (string.isNotBlank(mapOfQueueAndId.get(mapOfSchoolAndQueue.get(mapOfIdAndSR.get(objStep.HexaBPM__SR__c).School__r.Short_Name__c)))) {
          objStep.OwnerId = mapOfQueueAndId.get(mapOfSchoolAndQueue.get(mapOfIdAndSR.get(objStep.HexaBPM__SR__c).School__r.Short_Name__c));
        }
      }
      return lstSteps;
    }
    return null;
  }
   */
 
  /**Keerthan**/
  public   List<HexaBPM__Step__c> assignStepOwner(list<HexaBPM__Step__c> lstSteps) {
    try {

      //Map containing all valid SR Record Type API name which is checked before owner assignment
      Map<String, String> SRRTMap = new Map<String, String> {'TC_Request' => 'TC_Request', 'Enrollment' => 'Enrollment'};

      List<Id> SRStepIdList = new List<Id>();
      List<ID>srIdList = new List<Id>();
      Map<Id, HexaBPM__Service_Request__c> srIdtoSRMap = new Map<Id, HexaBPM__Service_Request__c>();
      Map<Id, String> SRStepIdtoOwnerMap = new Map<Id, String>() ;
	  
      //Collect all step IDs and SR ID
      for (HexaBPM__Step__c step :  lstSteps) {

        SRStepIdList.add(step.HexaBPM__SR_Step__c);
        srIdList.add(step.HexaBPM__SR__c);
      }
      System.debug('CC_Step_Assignment assignStepOwner SRStepIdList :' + SRStepIdList);
      System.debug('CC_Step_Assignment assignStepOwner srIdList :' + srIdList);
      
	  
      //Get all SR step template information
      for (HexaBPM__SR_Steps__c SRSTep : [Select Id, Owner_Name__c, HexaBPM__Step_Template_Code__c from HexaBPM__SR_Steps__c Where Id IN :SRStepIdList  ]) {
        SRStepIdtoOwnerMap.put(SRStep.Id, SRStep.Owner_Name__c);
      }

      for (HexaBPM__Service_Request__c SR : [Select Id, HexaBPM__Customer__r.School__r.Short_Name__c, School__r.Short_Name__c,School_Short_Name__c, HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c Where Id IN:srIdList]) {
        srIdtoSRMap.put(SR.Id, SR);
      }
     
      System.debug('CC_Step_Assignment assignStepOwner SRStepIdtoOwnerMap :' + SRStepIdtoOwnerMap);
      System.debug('CC_Step_Assignment assignStepOwner srIdtoSRMap :' + srIdtoSRMap);

      //Get all QueueConfig information for the School associated with SR
      Map<string, GEMS_Queue_Config__c> customSettingsForQueue = GEMS_Queue_Config__c.getAll();
      Set<String> queueNames = new Set<String>();
      for (GEMS_Queue_Config__c var : customSettingsForQueue.values()) {
          queueNames.add(var.Queue_Name__c);
        }
      //Get all queue DevName --> Id Map
      map<string, id> mapOfQueueAndId = new map<string, id>();
      for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue' and DeveloperName IN :queueNames]) {
        mapOfQueueAndId.put(grp.DeveloperName, grp.id);
      }

      System.debug('CC_Step_Assignment assignStepOwner mapOfQueueAndId :' + mapOfQueueAndId);

      //Start assigning owner depending on SR Step Queue
      for (HexaBPM__Step__c step : lstSteps ) {
        String queueName = '';
        if (SRStepIdtoOwnerMap.containsKey(step.HexaBPM__SR_Step__c) && SRStepIdtoOwnerMap.get(step.HexaBPM__SR_Step__c) == 'Parent_Relations_Officer' )
		  {
		  	queueName	= srIdtoSRMap.get(step.HexaBPM__SR__c).School__r.Short_Name__c + '_Parent_Relation_Officer';
            step.OwnerId = mapOfQueueAndId.containsKey(queueName) ?  mapOfQueueAndId.get(queueName) :  step.OwnerId;
		  }
        //Assign the step to the new school registrar
        if (SRStepIdtoOwnerMap.containsKey(step.HexaBPM__SR_Step__c) && SRStepIdtoOwnerMap.get(step.HexaBPM__SR_Step__c) == 'Registrar')
	      {
	      	queueName	= srIdtoSRMap.get(step.HexaBPM__SR__c).School__r.Short_Name__c + '_Registrar';
            step.OwnerId = mapOfQueueAndId.containsKey(queueName) ?  mapOfQueueAndId.get(queueName) :  step.OwnerId;
	      }
        //Assign the step to the current school registrar
        if (SRStepIdtoOwnerMap.containsKey(step.HexaBPM__SR_Step__c) && SRStepIdtoOwnerMap.get(step.HexaBPM__SR_Step__c) == 'Registrar2')
          {
          	queueName	= srIdtoSRMap.get(step.HexaBPM__SR__c).HexaBPM__Customer__r.School__r.Short_Name__c + '_Registrar';
           step.OwnerId = mapOfQueueAndId.containsKey(queueName) ?  mapOfQueueAndId.get(queueName) :  step.OwnerId;
          }
        if (SRStepIdtoOwnerMap.containsKey(step.HexaBPM__SR_Step__c) && SRStepIdtoOwnerMap.get(step.HexaBPM__SR_Step__c) == 'GEMS_Corporate_Office')
		  {
		  	queueName	= 'GEMS_Corporate_Office';
            step.OwnerId = mapOfQueueAndId.containsKey(queueName) ?  mapOfQueueAndId.get(queueName) :  step.OwnerId;
		  }
		  System.debug('queueName==>'+queueName);
      }
       
      return lstSteps;
    } catch (Exception e) {
      GEMS_Utility.logException(e);
      return null;
    }

  }

}