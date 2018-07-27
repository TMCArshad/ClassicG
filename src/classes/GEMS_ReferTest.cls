@isTest
private class GEMS_ReferTest {

    static testMethod void GEMS_Refer() {
        
        school__c objSchool = GEMS_TestUtils.createSchool();
        objSchool.Is_School_participating_in_Ambassador_pr__c = true;
        update objSchool;
        
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
                
        Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
    	objStudent.student_id__c = '11111111';
    	update objStudent;
    	
    	objAY.year__c = '28';
    	update objAY;
    	
        Test.setCurrentPageReference(new PageReference('Page.GEMS_Refer'));
        System.currentPageReference().getParameters().put('studentID', GEMS_Utility.getEnctryptedURLparam(objStudent.id));
    	System.currentPageReference().getParameters().put('BSU', GEMS_Utility.getEnctryptedURLparam(objSchool.Id));
    	GEMS_ReferCls referCtlr = new GEMS_ReferCls(); 
    	referCtlr.refer_lead.FirstName__c = 'test';
    	referCtlr.refer_lead.LastName__c = 'test';
    	referCtlr.refer_lead.Parent_First_Name__c = 'test';
    	referCtlr.refer_lead.Parent_Last_Name__c = 'test';
    	referCtlr.refer_lead.email__C = 'test@test.test';
    	referCtlr.refer_lead.MobilePhone__c = '555555555';
    	referCtlr.selectedSchool = objSchool.id;
    	referCtlr.selectedAY = objAY.id;
    	referCtlr.selectedGrade = objGrade.id;
    	referCtlr.selectedCurriculum = '2';
    	referCtlr.selectedStream = '1';
    	
        referCtlr.CreateReferLeads();
    }
}