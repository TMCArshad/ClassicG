/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   29thth March 2017
    Description :   Trigger written on Account
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

trigger GEMS_AccountTrigger on Account (before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete){
    
    GEMS_AccountTriggerHandler handler = new GEMS_AccountTriggerHandler();
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
    //Exeucte Before Delete Operations
        if(Trigger.isBefore && Trigger.isDelete){
          handler.Execute_BD(Trigger.oldMap);
        }
    
}