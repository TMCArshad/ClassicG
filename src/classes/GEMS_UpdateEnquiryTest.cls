@isTest
private class GEMS_UpdateEnquiryTest {
    static testMethod void GEMS_UpdateEnquiryTest(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	objQueue = [select id,name, developerName from Group where id=:objQueue.id];
    	
    	GEMS_TestUtils.createLeadEnquirySyncConfig();
    	Enquiry__c objEnq = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
    	
    	GEMS_UpdateEnquiry.acceptEnquiry(objEnq.id);
    	GEMS_UpdateEnquiry.acceptEnquiry('test');
    }
    
}