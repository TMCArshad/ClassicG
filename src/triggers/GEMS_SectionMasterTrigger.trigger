trigger GEMS_SectionMasterTrigger on Section_Master__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	GEMS_SectionMasterTriggerHandler handler = new GEMS_SectionMasterTriggerHandler();
	if(Trigger.isAfter && Trigger.isUpdate){
  		handler.Execute_AU(Trigger.New,Trigger.oldMap);
	}
	
	if(Trigger.isBefore && Trigger.isUpdate){
		handler.Execute_BU(Trigger.New,Trigger.oldMap); 
	}
		
}