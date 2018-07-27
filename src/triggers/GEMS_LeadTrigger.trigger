/**************************************************************************************************
* Name               : GEMS_LeadTrigger                                                           *
* Description        : Lead Trigger                                                               *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017                                                              *
**************************************************************************************************/
trigger GEMS_LeadTrigger on Lead (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		GEMS_LeadTriggerHandler handler = new GEMS_LeadTriggerHandler();
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
	//Execute Before Delete Operations
	if(Trigger.isBefore && Trigger.isDelete){
       handler.Execute_BD(Trigger.old);
	}
}