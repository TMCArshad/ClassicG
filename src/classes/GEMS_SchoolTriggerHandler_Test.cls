@isTest
private class GEMS_SchoolTriggerHandler_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
		School__c school = new School__c();
		insert school;

		Test.startTest();
		   school.Sys_is_Deleted__c = true;
		   update school;
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}