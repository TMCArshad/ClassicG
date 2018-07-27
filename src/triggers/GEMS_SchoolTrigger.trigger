trigger GEMS_SchoolTrigger on School__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update,  
	after delete, 
	after undelete) {
GEMS_SchoolTriggerHandler handler = new GEMS_SchoolTriggerHandler();

if(Trigger.isAfter && Trigger.isUpdate){
   handler.execute_AU(Trigger.new,Trigger.oldMap);
}

}