@isTest
private class GEMS_SRPriceItemTriggerTest {
    static testMethod void GEMS_SRPriceItemTrigger1(){
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,academic_year__c,stream__c,school__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
    	objSR.Transfer_date__c = system.today(); 
    	update objSR;
    	
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('REGISTRATION');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('REGISTRATION', 'REGISTRATION', objSR.id);
    	
    	system.debug('--objAmount--'+objAmount);
    	HexaBPM__SR_Status__c srStatus2 = GEMS_TestUtils.createSRStatus('Registered');
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus2.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus2.id;
        update objSR;
        system.debug('--objAmount--'+objAmount);
        
        HexaBPM__SR_Price_Item__c objSRItem1 = GEMS_testUtils.createPricing('ENROLLMENT', 'ENROLLMENT', objSR.id);
    }
    
    static testMethod void GEMS_SRPriceItemTrigger2(){
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Re_Enrolment');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,academic_year__c,stream__c,school__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
    	objSR.Transfer_date__c = system.today(); 
    	update objSR;
    	
        Amount__c objAmount = GEMS_TestUtils.createAmount('RE-ENROL', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('RE-ENROL', 'RE-ENROL', objSR.id);
    	system.debug('--objAmount--'+objAmount);
    }
    
    static testMethod void GEMS_SRPriceItemTrigger3(){
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Re_Enrolment');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,academic_year__c,stream__c,school__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
    	objSR.Transfer_date__c = system.today(); 
    	update objSR;
    	
        Amount__c objAmount = GEMS_TestUtils.createAmount('STUDENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	objAmount.Tution_fee_percentage__c = 5;
        update objAmount;
        
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('STUDENT', 'STUDENT', objSR.id);
    	objSRItem.status__c = 'Paid';
    	update objSRItem;
    	system.debug('--objAmount--'+objAmount);
    }
    
    static testMethod void GEMS_SRPriceItemTrigger4(){
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Closed');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Inter_Unit_Student_Transfer');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,academic_year__c,stream__c,school__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
    	objSR.Transfer_date__c = system.today(); 
    	update objSR;
    	
        Amount__c objAmount = GEMS_TestUtils.createAmount('Tuition', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('Tuition', 'Tuition', objSR.id);
    	objSRItem.status__c = 'Paid';
    	update objSRItem;
    	
    	system.debug('--objAmount--'+objAmount);
    }
    
}