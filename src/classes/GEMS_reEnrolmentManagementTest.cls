@IsTest
private class GEMS_reEnrolmentManagementTest {
    static testMethod void GEMS_reEnrolmentManagementTest1() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createAccount('Student');
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.Curriculum_Current__c = objAY.curriculum__c;
        update objStudent;
        
        Promotion__c objPromo = new Promotion__c();
        objPromo.Academic_Year__c = objAY.id;
        objPromo.Active__c = true;
        objPromo.Curriculum__c = objAY.curriculum__c;
        objPromo.Grade__c = objGrade.id;
        objPromo.Re_enrolment_Remark__c = 'Fee Pending';
        objPromo.School__c = objSchool.id;
        objPromo.Section__c = objSec.id;
        objPromo.Student__c = objStudent.id;
        objPromo.sys_Primary_Key__c = '1';
        insert objPromo;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
        reEnrolCtlr.selectedGrade = objGrade.id;
        reEnrolCtlr.selectedSection = objSec.id;
        reEnrolCtlr.academicYearLabel = '2016-2017';
        
        reEnrolCtlr.clearSearch();
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.searchStudentValue = 'Test';
        reEnrolCtlr.searchStudents();
        
        reEnrolCtlr.blockObj = objPromo.id;
        reEnrolCtlr.blockStudent = objStudent.id;
        reEnrolCtlr.selectedBlockRemark = 'Fee Pending';
        reEnrolCtlr.blockAction = 'Block';
        reEnrolCtlr.blockStudent();
        
        reEnrolCtlr.blockObj = objPromo.id;
        reEnrolCtlr.blockStudent = objStudent.id;
        reEnrolCtlr.blockReason = ' Fee Pending';
        reEnrolCtlr.blockAction = 'Unblock';
        reEnrolCtlr.blockStudent();
        
        reEnrolCtlr.showPopUp();
        reEnrolCtlr.closePopup();
        
    }
    
    
    static testMethod void GEMS_reEnrolmentManagementTest2() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createAccount('Student');
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.Curriculum_Current__c = objAY.curriculum__c;
        update objStudent;
        
        Promotion__c objPromo = new Promotion__c();
        objPromo.Academic_Year__c = objAY.id;
        objPromo.Active__c = true;
        objPromo.Curriculum__c = objAY.curriculum__c;
        objPromo.Grade__c = objGrade.id;
        objPromo.Re_enrolment_Remark__c = 'Fee Override';
        objPromo.School__c = objSchool.id;
        objPromo.Section__c = objSec.id;
        objPromo.Student__c = objStudent.id;
        objPromo.sys_Primary_Key__c = '1';
        insert objPromo;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
        reEnrolCtlr.selectedGrade = objGrade.id;
        reEnrolCtlr.selectedSection = objSec.id;
        reEnrolCtlr.academicYearLabel = '2016-2017';
        
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'GEMS Staff Re-Enroled / Fee Override';
        reEnrolCtlr.getStudents();
        
        if(reEnrolCtlr.promotionWrapperList!=null && reEnrolCtlr.promotionWrapperList.size()>0){
            reEnrolCtlr.promotionWrapperList[0].selectRecord = true;
        }
        
        reEnrolCtlr.selectedEnrolmentRemark = 'GEMS Staff Re-Enroled';
        reEnrolCtlr.updatePromotions();     
    }
    
    static testMethod void GEMS_reEnrolmentManagementTest3() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createAccount('Student');
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.Curriculum_Current__c = objAY.curriculum__c;
        update objStudent;
        
        Promotion__c objPromo = new Promotion__c();
        objPromo.Academic_Year__c = objAY.id;
        objPromo.Active__c = true;
        objPromo.Curriculum__c = objAY.curriculum__c;
        objPromo.Grade__c = objGrade.id;
        objPromo.Re_enrolment_Remark__c = 'Fee Pending';
        objPromo.School__c = objSchool.id;
        objPromo.Section__c = objSec.id;
        objPromo.Student__c = objStudent.id;
        objPromo.sys_Primary_Key__c = '1';
        insert objPromo;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
        reEnrolCtlr.selectedGrade = objGrade.id;
        reEnrolCtlr.selectedSection = objSec.id;
        reEnrolCtlr.academicYearLabel = '2016-2017';
        
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'Fee Pending';
        reEnrolCtlr.getStudents();
        
        if(reEnrolCtlr.promotionWrapperList!=null && reEnrolCtlr.promotionWrapperList.size()>0){
            reEnrolCtlr.promotionWrapperList[0].selectRecord = true;
        }
        
        reEnrolCtlr.selectedEnrolmentRemark = 'Register';
        reEnrolCtlr.updatePromotions();
    }
    
    static testMethod void GEMS_reEnrolmentManagementTest4() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createAccount('Student');
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.Curriculum_Current__c = objAY.curriculum__c;
        objStudent.Is_primary_contact_employee_of_GEMS__c = 'Yes';
        objStudent.Primary_Contact__c = 'Father';
        update objStudent;
        
        Promotion__c objPromo = new Promotion__c();
        objPromo.Academic_Year__c = objAY.id;
        objPromo.Active__c = true;
        objPromo.Curriculum__c = objAY.curriculum__c;
        objPromo.Grade__c = objGrade.id;
        objPromo.Re_enrolment_Remark__c = 'Fee Pending';
        objPromo.School__c = objSchool.id;
        objPromo.Section__c = objSec.id;
        objPromo.Student__c = objStudent.id;
        objPromo.sys_Primary_Key__c = '1';
        insert objPromo;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
        reEnrolCtlr.selectedGrade = objGrade.id;
        reEnrolCtlr.selectedSection = objSec.id;
        reEnrolCtlr.academicYearLabel = '2016-2017';
        
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'Fee Pending';
        reEnrolCtlr.getStudents();
        
        if(reEnrolCtlr.promotionWrapperList!=null && reEnrolCtlr.promotionWrapperList.size()>0){
            reEnrolCtlr.promotionWrapperList[0].selectRecord = true;
        }
        
        reEnrolCtlr.selectedEnrolmentRemark = 'Register';
        reEnrolCtlr.updatePromotions();
    }
    
    
    static testMethod void GEMS_reEnrolmentManagementTest5() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createAccount('Student');
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.Curriculum_Current__c = objAY.curriculum__c;
        objStudent.Is_primary_contact_employee_of_GEMS__c = 'Yes';
        objStudent.Primary_Contact__c = 'Mother';
        update objStudent;
        
        Promotion__c objPromo = new Promotion__c();
        objPromo.Academic_Year__c = objAY.id;
        objPromo.Active__c = true;
        objPromo.Curriculum__c = objAY.curriculum__c;
        objPromo.Grade__c = objGrade.id;
        objPromo.Re_enrolment_Remark__c = 'Fee Pending';
        objPromo.School__c = objSchool.id;
        objPromo.Section__c = objSec.id;
        objPromo.Student__c = objStudent.id;
        objPromo.sys_Primary_Key__c = '1';
        insert objPromo;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
        reEnrolCtlr.selectedGrade = objGrade.id;
        reEnrolCtlr.selectedSection = objSec.id;
        reEnrolCtlr.academicYearLabel = '2016-2017';
        
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'Fee Pending';
        reEnrolCtlr.getStudents();
        
        if(reEnrolCtlr.promotionWrapperList!=null && reEnrolCtlr.promotionWrapperList.size()>0){
            reEnrolCtlr.promotionWrapperList[0].selectRecord = true;
        }
        
        reEnrolCtlr.selectedEnrolmentRemark = 'Register';
        reEnrolCtlr.updatePromotions();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'TC Students';
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'Refund';
        reEnrolCtlr.getStudents();
        
        reEnrolCtlr.selectedEnrolmentStatus = 'Re-Enroled';
        reEnrolCtlr.getStudents();
    }
    
    static testMethod void GEMS_reEnrolmentManagementTest6() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createAccount('Student');
        objStudent.firstName = 'Test';
        objStudent.lastName = 'Test';
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.Curriculum_Current__c = objAY.curriculum__c;
        update objStudent;
        
        Promotion__c objPromo = new Promotion__c();
        objPromo.Academic_Year__c = objAY.id;
        objPromo.Active__c = true;
        objPromo.Curriculum__c = objAY.curriculum__c;
        objPromo.Grade__c = objGrade.id;
        objPromo.Re_enrolment_Remark__c = 'Fee Pending';
        objPromo.School__c = objSchool.id;
        objPromo.Section__c = objSec.id;
        objPromo.Student__c = objStudent.id;
        objPromo.sys_Primary_Key__c = '1';
        insert objPromo;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
        reEnrolCtlr.selectedGrade = objGrade.id;
        reEnrolCtlr.selectedSection = objSec.id;
        
        Id [] fixedSearchResults = new Id[]{objStudent.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        reEnrolCtlr.searchStudentValue = 'Test';
        reEnrolCtlr.searchStudents();
    }
    
    static testMethod void GEMS_interUnitTransferManagementTest7(){
        school__c objSchool = GEMS_TestUtils.createSchool();
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrolmentManagement'));
        System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
        GEMS_reEnrolmentManagementCtlr reEnrolCtlr = new GEMS_reEnrolmentManagementCtlr();  
    }
}