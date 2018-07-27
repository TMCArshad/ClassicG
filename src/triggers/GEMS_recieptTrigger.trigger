trigger GEMS_recieptTrigger on Reciept__c (after update, before insert, before update) {
    
    GEMS_recieptTriggerHandler handler = new GEMS_recieptTriggerHandler();
    
    
    //Execute Before Insert Operations
    if(Trigger.isBefore && Trigger.isInsert){
       handler.Execute_BI(Trigger.New);
    }
    //Execute Before Update Operations
    if(Trigger.isBefore && Trigger.isUpdate){
       handler.Execute_BU(Trigger.New,Trigger.oldMap);
    }
}