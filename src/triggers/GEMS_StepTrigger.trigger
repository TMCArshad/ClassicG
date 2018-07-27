trigger GEMS_StepTrigger on HexaBPM__Step__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    GEMS_StepTriggerHandler handler = new GEMS_StepTriggerHandler();
    
    //Execute Before Insert Operations
    if(Trigger.isBefore && Trigger.isInsert){
        handler.Execute_BI(Trigger.New);
    }
    
    //Execute After Insert Operations
    if(Trigger.isAfter && Trigger.isInsert){
        handler.Execute_AI(Trigger.New);
    }
    
    //Execute Before Update Operations
    if(Trigger.isBefore && Trigger.isUpdate){
       handler.Execute_BU(Trigger.New,Trigger.oldMap);
    }
    
    //Execute After Update Operations
    if(Trigger.isAfter && Trigger.isUpdate){
       handler.Execute_AU(Trigger.New,Trigger.oldMap);
    }
    
    //Execute After Update Operations
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
       handler.Execute_IA(Trigger.New,Trigger.oldMap);
    }
}