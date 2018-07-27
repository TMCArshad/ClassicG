@isTest
private class GEMS_ApplyScholarshipTest {

    static testMethod void GEMS_ApplyScholarship1() {
		
		school__c objSchool = GEMS_TestUtils.createSchool();
    	objSchool.Scholarship_Start_Date__c = system.today();
		objSchool.Scholarship_End_Date__c = system.today();
		update objSchool;
		
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	academic_year__c objAY1 = GEMS_TestUtils.createAcademicYear(objSchool);
    	objAY1.year__c = '28';
    	update objAY1;
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '111111';
		objStudent.Curriculum_Current__c = objAY.curriculum__c;
		objStudent.date_of_birth__c = System.Today().addYears(-10);
		update objStudent;
		
		string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Scholarship' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.student__c = objStudent.id;
        objSR.academic_year__c = objAY1.id;
        objSR.Eligible_for_Scholarship_Program__c = false;
        insert objSR;
        
        scholarship__c obj = new scholarship__c();
		obj.student__c = objStudent.id;
		obj.school__c = objSchool.id;
		obj.academic_year__c = objAY1.id;
		obj.active__c = true;
		obj.TC_SO_CN_Applied__c = false;
		insert obj;
		
		HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
		objDocMaster.Name = 'Offer Letter Other PDF';
		objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
		objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
		insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Document_Master__c = objDocMaster.id;
        objSRDoc.HexaBPM__Service_Request__c = objSR.id;
        objSRDoc.HexaBPM__SR_Template_Doc__c = objTempDocs.id;
        insert objSRDoc;
        
        
		Test.setCurrentPageReference(new PageReference('Page.GEMS_ApplyScholarshipPage'));
    	System.currentPageReference().getParameters().put('BSU', objSchool.id__c);
    	System.currentPageReference().getParameters().put('exStudentNameParam', '111111');
    	System.currentPageReference().getParameters().put('exDOBParam',string.valueOf(objStudent.date_of_birth__c));
    	System.currentPageReference().getParameters().put('srDocId', objSRDoc.id);
    	
    	GEMS_ApplyScholarshipCntrl scholarCntrl = new GEMS_ApplyScholarshipCntrl();    
    	
    	scholarCntrl.SRDocName = '';
    	scholarCntrl.isFinancialStable = false;
    	scholarCntrl.isTerms =  false;
    	scholarCntrl.isStudentVal = '';
    	scholarCntrl.isEnrolled = '';
    	scholarCntrl.selectedContentType = '';
    	scholarCntrl.SRDocID = objSRDoc.id;
    	
    	scholarCntrl.checkExistingScholarshipDetails();    
    	scholarCntrl.validateScholarship();
    	scholarCntrl.draftScholarship();
    	scholarCntrl.submitScholarship();
    	scholarCntrl.Upload();
    	scholarCntrl.clearValues();
    	scholarCntrl.uploadadditional();
    	scholarCntrl.cancel();
    }
    
    static testMethod void GEMS_ApplyScholarship2() {
		Test.setCurrentPageReference(new PageReference('Page.GEMS_ApplyScholarshipPage'));
    	System.currentPageReference().getParameters().put('BSU', '');
    	GEMS_ApplyScholarshipCntrl scholarCntrl = new GEMS_ApplyScholarshipCntrl();        
    }
    
    static testMethod void GEMS_ApplyScholarship3() {
		Test.setCurrentPageReference(new PageReference('Page.GEMS_ApplyScholarshipPage'));
    	System.currentPageReference().getParameters().put('BSU', '111');
    	GEMS_ApplyScholarshipCntrl scholarCntrl = new GEMS_ApplyScholarshipCntrl();        
    }
    
    static testMethod void GEMS_ApplyScholarship4() {
		
		school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	academic_year__c objAY1 = GEMS_TestUtils.createAcademicYear(objSchool);
    	objAY1.Curriculum__c = objAY.Curriculum__c;
    	objAY1.year__c = '28';
    	update objAY1;
    	
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Draft');
		
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.academic_year__c = objAy.id;
        objSR.gradeLookup__c = objGrade.id;
        objSR.Curriculum__c = objAy.curriculum__c;
        objSR.stream__c = objGrade.stream__c;
        objSR.Sys_GEMS_School_Sibling__c = objSchool.id; 
        objSR.Service_Type__c = 'Enrollment Short Form';
        objSR.Lead_Reference__c = '1111111111111';
        objSR.Primary_Contact__c = 'Father';
        objSR.Last_Name_Father__c = 'Test FName';
        objSR.First_Name_Father__c = 'Test LName';
        objSR.date_of_birth__c  = System.Today().addYears(-10);
        insert objSR;
    	
    	HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
    	objSR1 = [select id, name,date_of_birth__c,Date_Of_Birth_String__c,academic_year__c,school__c,gradeLookup__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	
		Test.setCurrentPageReference(new PageReference('Page.GEMS_ApplyScholarshipPage'));
    	System.currentPageReference().getParameters().put('BSU', objSchool.id__c);
    	System.currentPageReference().getParameters().put('exStudentNameParam', objSR1.name);
    	System.currentPageReference().getParameters().put('exDOBParam',string.valueOf(objSR1.Date_Of_Birth_String__c));
    	
    	GEMS_ApplyScholarshipCntrl scholarCntrl = new GEMS_ApplyScholarshipCntrl();        
    	
    	scholarCntrl.validateScholarship();
    	scholarCntrl.draftScholarship();
    	scholarCntrl.submitScholarship();
    }
    
}