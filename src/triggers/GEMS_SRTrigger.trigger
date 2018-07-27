trigger GEMS_SRTrigger on HexaBPM__Service_Request__c (after insert, after update, before insert, before update) {
    
    GEMS_SRTriggerHandler handler = new GEMS_SRTriggerHandler();
    
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