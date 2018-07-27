@isTest
private class GEMS_recieptTriggerTest {
    static testmethod void GEMS_recieptTriggerTest(){
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Academic_Year__c, gradeLookup__c,School__c,
    					school__r.id__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
        reciept__c obj1 = new reciept__c();
        obj1.school_code__c = objSR.school__r.id__c;
        obj1.Account_Student__c = objStudent.id;
        insert obj1;
        
        obj1.Merchant__c = 'Test';
        obj1.school_code__c = objSR.school__r.id__c;
        update obj1;
        
        reciept__c obj2 = new reciept__c();
        obj2.Service_Request__c = objSR.id;
        insert obj2;
        
        obj2.Merchant__c = 'Test';
        update obj2;
    	
    }
}