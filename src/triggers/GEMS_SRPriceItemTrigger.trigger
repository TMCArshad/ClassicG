/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Trigger written on SR price item.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
trigger GEMS_SRPriceItemTrigger on HexaBPM__SR_Price_Item__c (before insert, before update, after insert, after update) {
        GEMS_SRPriceItemTriggerHandler handler = new GEMS_SRPriceItemTriggerHandler();
        
        //Execute Before Insert Operations
        if(Trigger.isBefore && Trigger.isInsert){
            handler.Execute_BI(Trigger.New);
        }
        
        //Execute After Insert Operations
        if(Trigger.isAfter && Trigger.isInsert){
            handler.Execute_AI(Trigger.New);
        }
        
        //Execute After Update Operations
        if(Trigger.isAfter && Trigger.isUpdate){
           handler.Execute_AU(Trigger.New,Trigger.oldMap);
        }
}