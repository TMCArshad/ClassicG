trigger GEMS_EmployeeTrigger on Employee__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {


 GEMS_EmployeeTriggerHandler handler = new GEMS_EmployeeTriggerHandler();
 if(Trigger.isAfter && Trigger.isUpdate){
   handler.Ececute_AU(Trigger.New, Trigger.oldMap);
 }
		
}