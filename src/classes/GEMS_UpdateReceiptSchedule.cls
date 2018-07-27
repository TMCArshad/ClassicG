/**************************************************************************************************
* Name               : GEMS_UpdateReceiptSchedule                                                               *
* Description        : Class implements logic to schedule batch updating Receipt records                                     *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
**************************************************************************************************/
global class GEMS_UpdateReceiptSchedule implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		string receiptQuryStr = GEMS_Utility.getAllFields(Reciept__c.getsObjectType().getDescribe());
		receiptQuryStr += ' WHERE school_code__c != NULL AND  Transaction_Status__c = \'Initiated\' AND createdDate < '+ DateTime.now().addMinutes(-30).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		GEMS_UpdateReceiptBatch b = new GEMS_UpdateReceiptBatch(receiptQuryStr);  
		database.executebatch(b,5);
		//Schedule the job after defined time upon completion of batch execution
		//RecurringScheduleJob();
	}
}