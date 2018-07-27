@isTest
private class GEMS_SectionManagementTest {

    static testMethod void GEMS_SectionManagement1() {
        school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        
        Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'TC';
    	update objStudent;
    	
        Test.setCurrentPageReference(new PageReference('Page.GEMS_SectionManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
    	GEMS_SectionManagementCtlr sectCtlr = new GEMS_SectionManagementCtlr();  
    	sectCtlr.showPopUp();  
    	sectCtlr.closePopup();  
    	sectCtlr.editDel = 'Delete';
    	sectCtlr.selectedAction = 'crud';
    	sectCtlr.selectedAY = objAY.id;
    	sectCtlr.selectedGrade = objGrade.id;
    	sectCtlr.selectedStream = objGrade.stream__c;
    	sectCtlr.selectedSection = objSec.id;
    	sectCtlr.objSection = objSec;
    	sectCtlr.initiateAction();
    	sectCtlr.getInactiveStudents();
    	sectCtlr.transferStudents();  
    	sectCtlr.CRUDOperation();
    	sectCtlr.editDel = 'Upsert';
        sectCtlr.CRUDOperation();
    }
    
    static testMethod void GEMS_SectionManagement2() {
        school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_SectionManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
    	System.currentPageReference().getParameters().put('selectedAction', 'assign');
    	GEMS_SectionManagementCtlr sectCtlr = new GEMS_SectionManagementCtlr();  
        sectCtlr.assignFormTutor();
    }
}