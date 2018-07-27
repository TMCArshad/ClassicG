trigger GEMS_ProductTrigger on Product2 (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {
GEMS_ProductTriggerHandler handler = new GEMS_ProductTriggerHandler();
if(Trigger.isAfter && Trigger.isUpdate){
 handler.Execute_AU(Trigger.New,Trigger.oldMap);
}

}