@isTest
private class GEMS_CC_initiateTransferTest {
    static testMethod void GEMS_CC_initiateTransferTest1(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,HexaBPM__Customer__c,Transfer_date__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
    	objSR.HexaBPM__Customer__c = Student.id;
    	objSR.Transfer_date__c = system.today();
    	update objSR;
    	
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        GEMS_CC_initiateTransfer obj = new GEMS_CC_initiateTransfer();
        obj.EvaluateCustomCode(null,objStep);
    }
}