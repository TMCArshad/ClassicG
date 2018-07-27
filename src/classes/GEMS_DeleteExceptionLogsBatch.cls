/**************************************************************************************************
* Name               : GEMS_DeleteExceptionLogsBatch                                                               *
* Description        : Batch apex class to delete all the Exception logs                                       *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
**************************************************************************************************/
global class GEMS_DeleteExceptionLogsBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global GEMS_DeleteExceptionLogsBatch(String queryStr) {
		query = queryStr;
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Exception_Log__c> scope) {
	
	System.debug('EL Scope Size :'+scope.size());
	List<Exception_Log__c> logsToDelete = new List<Exception_Log__c>();
	for(Exception_Log__c el : scope ){
       logsToDelete.add(el);
	}
	if(!logsToDelete.isEmpty()){
        delete logsToDelete;
	}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}