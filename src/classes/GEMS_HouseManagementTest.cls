@isTest
private class GEMS_HouseManagementTest {

    static testMethod void GEMS_HouseManagement() {
        school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        House_Master__c objHouse = new House_Master__c();
        objHouse.House_Color__c = '#FF0000';
        objHouse.House_Description__c = 'TestHouse';
        objHouse.School__c = objSchool.id;
        insert objHouse;
        
        Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
    	objStudent.house__c = objHouse.id;
    	update objStudent;
    	
        Test.setCurrentPageReference(new PageReference('Page.GEMS_HouseManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
    	GEMS_HouseManagementCtlr houseCtlr = new GEMS_HouseManagementCtlr(); 
    	houseCtlr.initiateAction();
    	houseCtlr.getExistingStudents();
    	
    	houseCtlr.searchStudentValue = 'Test';
    	houseCtlr.searchStudents();
    	houseCtlr.clearSearch();
    	
    	houseCtlr.createHouse();
    	houseCtlr.allocateHouse();
    	houseCtlr.showPopUp();
    	houseCtlr.closePopup();
    	
    	houseCtlr.selectedAction = 'new';
    	houseCtlr.initiateAction();
    }
}