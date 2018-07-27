@isTest
private class GEMS_CC_InsertPriceItemTest {
    static testMethod void GEMS_CC_InsertPriceItemTest1(){
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
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(objSR,objStep);
    }
    
    static testMethod void GEMS_CC_InsertPriceItemTest2(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Re_Enrolment');
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
        objStep = GEMS_TestUtils.createStep(objSR,'Re_Enrolment','Awaiting Verification');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('RE-ENROL', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(objSR,objStep);
    }
    
    static testMethod void GEMS_CC_InsertPriceItemTest3(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Inter_Unit_Student_Transfer');
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
        objStep = GEMS_TestUtils.createStep(objSR,'Inter_Unit_Student_Transfer','Awaiting Verification');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('Inter_Unit_Student_Transfer', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(objSR,objStep);
    }
    
    static testMethod void GEMS_CC_InsertPriceItemTest4(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,HexaBPM__Customer__c,Transfer_date__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Customer__c = Student.id;
    	objSR.Transfer_date__c = system.today(); 
    	update objSR;
    	
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(objSR,objStep);
    }
    
    static testMethod void GEMS_CC_InsertPriceItemTest5(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,HexaBPM__Customer__c,Transfer_date__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Customer__c = Student.id;
    	objSR.Transfer_date__c = system.today(); 
    	update objSR;
    	
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Enrolment','Awaiting Verification');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(Null,objStep);
    }
    
    static testMethod void GEMS_CC_InsertPriceItemTest6(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Re_Enrolment');
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
        objStep = GEMS_TestUtils.createStep(objSR,'Re_Enrolment','Awaiting Verification');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('STUDENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        objAmount.Tution_fee_percentage__c = 5;
        update objAmount;
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(objSR,objStep);
    }
    
    static testMethod void GEMS_CC_InsertPriceItemTest7(){
    	Account Student = GEMS_TestUtils.createAccount('Student');
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Re_Enrolment');
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
        objStep = GEMS_TestUtils.createStep(objSR,'Re_Enrolment','Awaiting Verification');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('STUDENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
        
        GEMS_CC_InsertPriceItem obj = new GEMS_CC_InsertPriceItem();
        obj.EvaluateCustomCode(objSR,objStep);
    }
}