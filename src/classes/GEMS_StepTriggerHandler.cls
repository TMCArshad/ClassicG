/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   6th Mar 2018
    Description :   Handler class for step trigger
   
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_StepTriggerHandler {
    public GEMS_StepTriggerHandler() { 
    }
    
    public void Execute_BI(list<HexaBPM__Step__c> StepList) {
    }
    
    public void Execute_AI(list<HexaBPM__Step__c> StepList) {
    }
   
    public void Execute_BU(list<HexaBPM__Step__c> TriggerNew, map<Id, HexaBPM__Step__c> oldMap) {
		GEMS_StepTriggerHelper.handleRejection(TriggerNew,oldMap);
	}
    
    public void Execute_AU(list<HexaBPM__Step__c> StepList, map<Id, HexaBPM__Step__c> oldMap) {
    }   
    
    public void Execute_IA(list<HexaBPM__Step__c> StepList, map<Id, HexaBPM__Step__c> oldMap) {
    }   
}