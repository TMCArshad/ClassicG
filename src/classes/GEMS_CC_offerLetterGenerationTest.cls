@isTest
private class GEMS_CC_offerLetterGenerationTest {
    static testMethod void GEMS_CC_offerLetterGenerationTest1(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c,school__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        school__c objSchool = [select id, id__c,Short_Name__c from school__c where id=:objSR.school__c];
    	GEMS_Site_Domain_Config__c sc = GEMS_TestUtils.createSiteConfig(objSchool);
    	
    	GEMS_CC_offerLetterGeneration obj = new GEMS_CC_offerLetterGeneration();
        obj.EvaluateCustomCode(null,objStep);
    }
}