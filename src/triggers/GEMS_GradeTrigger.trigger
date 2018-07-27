trigger GEMS_GradeTrigger on Grade__c (before insert,
                                       before update,
                                       before delete,
                                       after insert,
                                       after update,
                                       after delete,
                                       after undelete) {
	GEMS_GradeTriggerHandler handler = new GEMS_GradeTriggerHandler();
	if (Trigger.isAfter && Trigger.isUpdate) {

		handler.execute_AU(Trigger.New, Trigger.oldMap);

	}
}