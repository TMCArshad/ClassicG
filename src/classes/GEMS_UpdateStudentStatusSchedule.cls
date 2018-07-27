global class GEMS_UpdateStudentStatusSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		GEMS_UpdateStudentStatusBatch b = new GEMS_UpdateStudentStatusBatch();
		database.executebatch(b);
	}
}