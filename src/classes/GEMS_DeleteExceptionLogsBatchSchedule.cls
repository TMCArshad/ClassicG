/**************************************************************************************************
* Name               : GEMS_DeleteExceptionLogsBatchSchedule                                                               *
* Description        : Class implements logic to schedule batch deletion of Exception Logs                                     *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
**************************************************************************************************/
global class GEMS_DeleteExceptionLogsBatchSchedule implements Schedulable { 
	global void execute(SchedulableContext sc) {
		String ELQueryStr =' SELECT Id,CreatedDate FROM Exception_Log__c ';
		GEMS_DeleteExceptionLogsBatch b = new GEMS_DeleteExceptionLogsBatch(ELQueryStr);  
		database.executebatch(b,1000);
	}
}