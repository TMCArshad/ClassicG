@IsTest
private class GEMS_interUnitTransferManagementTest {
    
    static testMethod void GEMS_interUnitTransferManagementTest1(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	Section_Master__c objSecTransfer = GEMS_TestUtils.createSection(objSchoolTransfer,objAYTransfer,objGradeTransfer);
    	
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Section__c = objSec.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Current_Status__c = 'EN';
    	update objStudent;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_interUnitTransferManagementCtlr transferCtlr = new GEMS_interUnitTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	transferCtlr.getExistingStudents();
    	
    	transferCtlr.clearSearch();
    }
    
    static testMethod void GEMS_interUnitTransferManagementTest2(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	Section_Master__c objSecTransfer = GEMS_TestUtils.createSection(objSchoolTransfer,objAYTransfer,objGradeTransfer);
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_interUnitTransferManagementCtlr transferCtlr = new GEMS_interUnitTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	transferCtlr.transferDate = system.today();
    	transferCtlr.transferRequest();
    	transferCtlr.transferred = true;
    	transferCtlr.getExistingStudents();
    }
    
     static testMethod void GEMS_interUnitTransferManagementTest3(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_interUnitTransferManagementCtlr transferCtlr = new GEMS_interUnitTransferManagementCtlr(); 
    	
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	transferCtlr.transferRequest();
    }
    
    static testMethod void GEMS_interUnitTransferManagementTest4(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	Section_Master__c objSecTransfer = GEMS_TestUtils.createSection(objSchoolTransfer,objAYTransfer,objGradeTransfer);
    	
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Section__c = objSec.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Current_Status__c = 'EN';
    	update objStudent;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_interUnitTransferManagementCtlr transferCtlr = new GEMS_interUnitTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	transferCtlr.getExistingStudents(); 
    	
    	if(!transferCtlr.studentWrapperList.isEmpty()){
    		transferCtlr.studentWrapperList[0].selectRecord = true;
    	}
    	transferCtlr.transferDate = system.today();
    	transferCtlr.transferRequest();
    }
    
    static testMethod void GEMS_interUnitTransferManagementTest5(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	Section_Master__c objSecTransfer = GEMS_TestUtils.createSection(objSchoolTransfer,objAYTransfer,objGradeTransfer);
    	
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.firstName = 'Test';
    	objStudent.lastName = 'Test';
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Section__c = objSec.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Current_Status__c = 'EN';
    	objStudent.gender__c = 'Female';
    	update objStudent;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_interUnitTransferManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_interUnitTransferManagementCtlr transferCtlr = new GEMS_interUnitTransferManagementCtlr(); 
    	transferCtlr.selectedSchool = objSchoolTransfer.id;
    	transferCtlr.getTransferSchoolSelected();
    	
    	Id [] fixedSearchResults = new Id[]{objStudent.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        transferCtlr.selectedGender = 'Female';
        transferCtlr.searchStudentValue = 'Test';
    	transferCtlr.searchStudents();
    }
}