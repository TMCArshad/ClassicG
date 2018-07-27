@isTest
private class GEMS_EnrollmentCtlrHelperTest {
    static testMethod void GEMS_EnrollmentCtlrHelperTest1(){
    	GEMS_EnrollmentCtlrHelper obj = new GEMS_EnrollmentCtlrHelper();
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Primary_Contact__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Primary_Contact__c = 'Mother';
        update objSR;
        
        GEMS_EnrollmentCtlrHelper.saveAndRedirect(objSR);
    }
    
    static testMethod void GEMS_EnrollmentCtlrHelperTest2(){
    	GEMS_EnrollmentCtlrHelper obj = new GEMS_EnrollmentCtlrHelper();
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Primary_Contact__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Primary_Contact__c = 'Father';
        update objSR;
        
        GEMS_EnrollmentCtlrHelper.saveAndRedirect(objSR);
    }
    
    static testMethod void GEMS_EnrollmentCtlrHelperTest3(){
    	GEMS_EnrollmentCtlrHelper obj = new GEMS_EnrollmentCtlrHelper();
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Primary_Contact__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Primary_Contact__c = 'Guardian';
        update objSR;
        
        GEMS_EnrollmentCtlrHelper.saveAndRedirect(objSR);
    }
}