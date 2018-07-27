@isTest
private class GEMS_CC_ConvertLeadIntoAccountTest {
    static testMethod void GEMS_CC_ConvertLeadIntoAccountTest1(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.academic_year__c = objAy.id;
        objSR.gradeLookup__c = objGrade.id;
        objSR.curriculum__c = objAy.curriculum__c;
        objSR.stream__c = objGrade.stream__c;
        objSR.Sys_GEMS_School_Sibling__c = objSchool.id; 
        objSR.Service_Type__c = 'Enrollment Short Form';
        objSR.Lead_Reference__c = '1111111111111';
        objSR.Primary_Contact__c = 'Father';
        objSR.Last_Name_Father__c = 'Test FName';
        objSR.First_Name_Father__c = 'Test LName';
        objSR.date_of_birth__c  = System.Today().addYears(-10);
        objSR.Primary_Contact__c = 'Father';
        objSR.Last_Name_Father__c = 'Test FName';
        objSR.First_Name_Father__c = 'Test LName';
        objSR.last_name__c = 'test';
        objSR.first_name__c = 'test';
        insert objSR;
        
        string temp = objSR.id;
        
        objSR = new HexaBPM__Service_Request__c();
        List<HexaBPM__Service_Request__c> SRList = new List<HexaBPM__Service_Request__c>();
	    String srQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
	    srQueryStr += ' WHERE id=:temp ';
	    SRList = Database.query(srQueryStr);
        objSR = SRList[0];
				 
        Reciept__c objRec = new Reciept__c();
    	objRec.lead__c = objSR.lead__c;
    	insert objRec;
        
        attachment attach = new attachment();
        attach.Body=Blob.valueOf('Unit Test Attachment Body');
        attach.name = 'Father';
        attach.parentID = objSR.id;
        insert attach;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification','Awaiting Verification');
        objStep.HexaBPM__SR__r = objSR;
        update objStep;
        
        GEMS_CC_ConvertLeadIntoAccount obj = new GEMS_CC_ConvertLeadIntoAccount();
        obj.EvaluateCustomCode(null,objStep);
    }
    
    static testMethod void GEMS_CC_ConvertLeadIntoAccountTest2(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.academic_year__c = objAy.id;
        objSR.gradeLookup__c = objGrade.id;
        objSR.curriculum__c = objAy.curriculum__c;
        objSR.stream__c = objGrade.stream__c;
        objSR.Sys_GEMS_School_Sibling__c = objSchool.id; 
        objSR.Service_Type__c = 'Enrollment Short Form';
        objSR.Lead_Reference__c = '1111111111111';
        objSR.date_of_birth__c  = System.Today().addYears(-10);
        objSR.Primary_Contact__c = 'Mother';
        objSR.Last_Name_Mother__c = 'Test FName';
        objSR.First_Name_Mother__c = 'Test LName';
        objSR.last_name__c = 'test';
        objSR.first_name__c = 'test';
        insert objSR;
        
        string temp = objSR.id;
        
        objSR = new HexaBPM__Service_Request__c();
        List<HexaBPM__Service_Request__c> SRList = new List<HexaBPM__Service_Request__c>();
	    String srQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
	    srQueryStr += ' WHERE id=:temp ';
	    SRList = Database.query(srQueryStr);
        objSR = SRList[0];
				 
        attachment attach = new attachment();
        attach.Body=Blob.valueOf('Unit Test Attachment Body');
        attach.name = 'Mother';
        attach.parentID = objSR.id;
        insert attach;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification','Awaiting Verification');
        objStep.HexaBPM__SR__r = objSR;
        update objStep;
        
        GEMS_CC_ConvertLeadIntoAccount obj = new GEMS_CC_ConvertLeadIntoAccount();
        obj.EvaluateCustomCode(null,objStep);
    }
    
    static testMethod void GEMS_CC_ConvertLeadIntoAccountTest3(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.academic_year__c = objAy.id;
        objSR.gradeLookup__c = objGrade.id;
        objSR.curriculum__c = objAy.curriculum__c;
        objSR.stream__c = objGrade.stream__c;
        objSR.Sys_GEMS_School_Sibling__c = objSchool.id; 
        objSR.Service_Type__c = 'Enrollment Short Form';
        objSR.Lead_Reference__c = '1111111111111';
        objSR.date_of_birth__c  = System.Today().addYears(-10);
        objSR.Primary_Contact__c = 'Guardian';
        objSR.Last_Name_Guardian__c = 'Test FName';
        objSR.First_Name_Guardian__c = 'Test LName';
        objSR.last_name__c = 'test';
        objSR.first_name__c = 'test';
        insert objSR;
        
        string temp = objSR.id;
        
        objSR = new HexaBPM__Service_Request__c();
        List<HexaBPM__Service_Request__c> SRList = new List<HexaBPM__Service_Request__c>();
	    String srQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
	    srQueryStr += ' WHERE id=:temp ';
	    SRList = Database.query(srQueryStr);
        objSR = SRList[0];
				 
        attachment attach = new attachment();
        attach.Body=Blob.valueOf('Unit Test Attachment Body');
        attach.name = 'Guardian';
        attach.parentID = objSR.id;
        insert attach;
        
        attachment attach1 = new attachment();
        attach1.Body=Blob.valueOf('Unit Test Attachment Body');
        attach1.name = 'Student';
        attach1.parentID = objSR.id;
        insert attach1;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification','Awaiting Verification');
        objStep.HexaBPM__SR__r = objSR;
        update objStep;
        
        GEMS_CC_ConvertLeadIntoAccount obj = new GEMS_CC_ConvertLeadIntoAccount();
        obj.EvaluateCustomCode(null,objStep);
    }
}