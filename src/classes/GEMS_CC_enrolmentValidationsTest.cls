@isTest
private class GEMS_CC_enrolmentValidationsTest {
    static testMethod void GEMS_CC_enrolmentValidationsTest1(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.Joining_Date__c = system.today().addDays(10);
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.Transfer_Type__c = 'New';
        objSR.Sibling_Fee_ID__c = '11111';
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
    }
    
     static testMethod void GEMS_CC_enrolmentValidationsTest2(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Assessment/Screening','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
    }
    
     static testMethod void GEMS_CC_enrolmentValidationsTest3(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Offer Letter','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.accept_offer__c = 'No';
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
    }
    
    static testMethod void GEMS_CC_enrolmentValidationsTest4(){
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,null);
    }
    
    static testMethod void GEMS_CC_enrolmentValidationsTest5(){
    	
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.accept_offer__c = 'No';
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
    }
    
     static testMethod void GEMS_CC_enrolmentValidationsTest6(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('REGISTRATION', 'REGISTRATION', objSR.id);
    	
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.Joining_Date__c = system.today().addDays(10);
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.Transfer_Type__c = 'New';
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
    }
    
    static testMethod void GEMS_CC_enrolmentValidationsTest7(){
    	
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('REGISTRATION', 'REGISTRATION', objSR.id);
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.StudentId__c = '11111111111111';
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
    }
    
    static testMethod void GEMS_CC_enrolmentValidationsTest8(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.Fees_Sponsor__c = 'Mother';
    	objSR.Transfer_Type__c = 'New';
        objSR.Sibling_Fee_ID__c = '11111';
        objSR.Joining_Date__c = system.today().addDays(10);
        objSR.Sibling_Fee_ID__c = '123456';
        objSR.Sibling_Fee_Id_Verified__c = 'Yes';
        update objSR;
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:objStep.id];
        
        GEMS_CC_enrolmentValidations obj = new GEMS_CC_enrolmentValidations();
        obj.EvaluateCustomCode(null,objStep);
        
        
        objSR.Nationality__c = null;
        update objSR;
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.Nationality__c = '178';
    	objSR.Religion__c = null;
    	update objSR;
        obj.EvaluateCustomCode(null,objStep);
    }
}