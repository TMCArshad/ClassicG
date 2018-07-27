trigger GEMS_AmountTrigger on Amount__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
	GEMS_AmountTriggerHandler handler = new GEMS_AmountTriggerHandler();
	if (Trigger.isAfter && Trigger.isUpdate) {
		handler.Execute_AU(Trigger.New, Trigger.oldMap);

	}
}