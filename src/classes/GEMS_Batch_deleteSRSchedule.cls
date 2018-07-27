global class GEMS_Batch_deleteSRSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		 
		GEMS_Batch_deleteSR b = new GEMS_Batch_deleteSR();  
		database.executebatch(b);
		
		
	}
}