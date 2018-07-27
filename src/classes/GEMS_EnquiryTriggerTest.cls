@isTest
private class GEMS_EnquiryTriggerTest {
    static testMethod void GEMS_EnquiryTriggerTest1(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	objQueue = [select id,name, developerName from Group where id=:objQueue.id];
    	
    	GEMS_TestUtils.createLeadEnquirySyncConfig();
    	Enquiry__c objEnq = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
    	
    	GEMS_checkRecursiveTriggers.runOnceForEnquiryAU = true;
    	
    	GEMS_EnquiryTriggerHelper.activityDate = System.Today();
	    GEMS_EnquiryTriggerHelper.subjectVal = 'Call Activity - Registrar';
		GEMS_EnquiryTriggerHelper.createTask(objEnq, UserInfo.getuserId(), 'Normal', 'Open');
		
    	objEnq.lastName__c = 'update';
    	objEnq.email__c = 'Non@Digital.com';
    	objEnq.MobilePhone__c = '+971555258999';
    	objEnq.firstname__c = 'update';
    	objEnq.middlename__c = 'update';
    	objEnq.phone__c = '+971555258999';
    	objEnq.salutation__c = 'Master';
    	update objEnq;
    	
    }
    
    static testMethod void GEMS_EnquiryTriggerTest2(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	objQueue = [select id,name, developerName from Group where id=:objQueue.id];
    	
    	GEMS_TestUtils.createLeadEnquirySyncConfig();
    	Enquiry__c objEnq = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
    	delete objEnq;
    }
    
}