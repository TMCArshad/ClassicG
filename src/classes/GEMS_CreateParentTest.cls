/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GEMS_CreateParentTest {

    static testMethod void GEMS_CreateParentCls() {
        
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
        Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
        objStudent.school__c = objSchool.id;
        objStudent.Sibling_ID__c = '123456';
        objStudent.academic_year__c = objAY.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Section__c = objSec.id;
        objStudent.stream__c = objGrade.stream__c;
        objStudent.curriculum__c = objAY.curriculum__c;
        objStudent.Current_Status__c = 'EN';
        update objStudent;
        
        Account objStudent2 = GEMS_TestUtils.createStudentAccount('Test Sibling');
        objStudent2.school__c = objSchool.id;
        objStudent2.Sibling_ID__c = '123456';
        objStudent2.academic_year__c = objAY.id;
        objStudent2.gradeLookup__c = objGrade.id;
        objStudent2.Section__c = objSec.id;
        objStudent2.stream__c = objGrade.stream__c;
        objStudent2.curriculum__c = objAY.curriculum__c;
        objStudent2.Current_Status__c = 'EN';
        update objStudent2;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_CreateParent'));
        System.currentPageReference().getParameters().put('Id', objStudent.id);
        GEMS_CreateParentCls Ctlr = new GEMS_CreateParentCls(); 
        Ctlr.rel = new relationship__c();
        Ctlr.rel.first_name__c = 'Test';
        Ctlr.rel.last_name__c = 'Test';
        Ctlr.rel.email__c = 'test@test.test';
        Ctlr.rel.Mobile__c = '+971557047445';
        Ctlr.rel.type__c = 'Guardian'; 
        Ctlr.SaveDetails();
        Ctlr.CancelDetails();
        
        GEMS_CreateParentCls Ctlr1 = new GEMS_CreateParentCls(); 
        Ctlr1.SaveDetails();
    }
}