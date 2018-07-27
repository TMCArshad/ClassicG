@isTest
private class GEMS_DeleteExceptionLogsBatch_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
		Exception_Log__c el = new Exception_Log__c();
		insert el;

		Test.startTest();
		GEMS_DeleteExceptionLogsBatchSchedule elSchedule = new GEMS_DeleteExceptionLogsBatchSchedule();
        elSchedule.execute(null);
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}