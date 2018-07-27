/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   19th April 2017
    Description :   GEMS_relationshipTriggerHandler.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_relationshipTriggerHandler {
    
    public GEMS_relationshipTriggerHandler() {
    }
    
    /**
     * [Execute_BI Execute before insert operations]
     * @param relationshipList
     */
    public void Execute_BI(list<Relationship__c> relationshipList) {
    }
    
    
    public void Execute_BU(list<Relationship__c> relationshipList,Map<Id,Relationship__c> oldMap) {
    }
    
    /**
     * [Execute_AI Execute after insert operations]
     * @param relationshipList
    */
    public void Execute_AI(list<Relationship__c> relationshipList) {
    	GEMS_relationshipTriggerHelper.updateStudentParentDetails(relationshipList,false);
    }
    
    
    public void Execute_AU(list<Relationship__c> relationshipList,Map<Id,Relationship__c> oldMap) {
    	GEMS_relationshipTriggerHelper.updateStudentParentDetails(relationshipList,true);
    }
    
     
}