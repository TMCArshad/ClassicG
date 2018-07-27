@IsTest
private class GEMS_enrolmentTransferManagementTest {
    static testMethod void GEMS_enrolmentTransferManagementTest1(){
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSR.School__c);
    	GEMS_enrolmentTransferManagementCtlr transferCtlr = new GEMS_enrolmentTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	transferCtlr.getExistingStudents();
    	
    	transferCtlr.clearSearch();
    }
    
    static testMethod void GEMS_enrolmentTransferManagementTest2(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	Section_Master__c objSecTransfer = GEMS_TestUtils.createSection(objSchoolTransfer,objAYTransfer,objGradeTransfer);
    	
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_enrolmentTransferManagementCtlr transferCtlr = new GEMS_enrolmentTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	transferCtlr.transferRequest();
    	transferCtlr.transferred = true;
    	transferCtlr.getExistingStudents();
    }
    
     static testMethod void GEMS_enrolmentTransferManagementTest3(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_enrolmentTransferManagementCtlr transferCtlr = new GEMS_enrolmentTransferManagementCtlr(); 
    	
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	transferCtlr.transferRequest();
    }
    
    static testMethod void GEMS_enrolmentTransferManagementTest4(){
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchoolTransfer);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchoolTransfer);
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSR.School__c);
    	GEMS_enrolmentTransferManagementCtlr transferCtlr = new GEMS_enrolmentTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	transferCtlr.getExistingStudents(); 
    	
    	if(!transferCtlr.studentWrapperList.isEmpty()){
    		transferCtlr.studentWrapperList[0].selectRecord = true;
    	}
    	transferCtlr.transferRequest();
    }
    
    static testMethod void GEMS_enrolmentTransferManagementTest5(){
    	
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	 
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,lead__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_enrolmentTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSR.School__c);
    	GEMS_enrolmentTransferManagementCtlr transferCtlr = new GEMS_enrolmentTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	Id [] fixedSearchResults = new Id[]{objSR.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        transferCtlr.searchStudentValue = 'Test';
    	transferCtlr.searchStudents();
    }
}