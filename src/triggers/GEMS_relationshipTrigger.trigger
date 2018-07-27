/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   19th April 2017
    Description :   GEMS_relationshipTrigger.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
trigger GEMS_relationshipTrigger on Relationship__c (after insert, after update, before insert, before update) {
    	 
    	GEMS_relationshipTriggerHandler handler = new GEMS_relationshipTriggerHandler();
        
        //Execute Before Insert Operations
        if(Trigger.isBefore && Trigger.isInsert){
            handler.Execute_BI(Trigger.New);
        }
        
        //Execute Before Insert Operations
        if(Trigger.isBefore && Trigger.isUpdate){
            handler.Execute_BU(Trigger.New,Trigger.oldMap);
        }
        
        //Execute After Insert Operations
        if(Trigger.isAfter && Trigger.isInsert){
            handler.Execute_AI(Trigger.New);
        }
        
        //Execute After Insert Operations
        if(Trigger.isAfter && Trigger.isUpdate){
            handler.Execute_AU(Trigger.New,Trigger.oldMap);
        }
      
}