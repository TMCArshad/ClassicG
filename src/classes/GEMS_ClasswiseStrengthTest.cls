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
private class GEMS_ClasswiseStrengthTest {

    static testMethod void ClasswiseStrengthCls() {
        // TO DO: implement unit test
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);       
        objAY.Start_Date__c = system.today();   
        objAY.End_Date__c = system.today();         
        update objAY;
        
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
        objStudent.Date_of_Join__c = system.today();
        objStudent.Gender__c = 'Male';
        update objStudent;
        
        Account objStudent1 = GEMS_TestUtils.createStudentAccount('Test1');
        objStudent1.school__c = objSchool.id;
        objStudent1.Sibling_ID__c = '123456';
        objStudent1.academic_year__c = objAY.id;
        objStudent1.gradeLookup__c = objGrade.id;
        objStudent1.Section__c = objSec.id;
        objStudent1.stream__c = objGrade.stream__c;
        objStudent1.curriculum__c = objAY.curriculum__c;
        objStudent1.Current_Status__c = 'EN';
        objStudent1.Date_of_Join__c = system.today();
        objStudent1.Gender__c = 'Female';
        update objStudent1;
        
        Promotion__c objpromo = new Promotion__c();
        objpromo.Active__c = true;
        objpromo.Student__c = objStudent.id; 
        objpromo.Academic_Year__c = objAY.id;
        objpromo.Grade__c = objGrade.id;
        objpromo.Section__c = objSec.id; 
        insert objpromo;
        
        Promotion__c objpromo1 = new Promotion__c();
        objpromo1.Active__c = true;
        objpromo1.Student__c = objStudent1.id; 
        objpromo1.Academic_Year__c = objAY.id;
        objpromo1.Grade__c = objGrade.id;
        objpromo1.Section__c = objSec.id; 
        insert objpromo1;
        
         Test.setCurrentPageReference(new PageReference('Page.GEMS_ClasswiseStrength'));
         System.currentPageReference().getParameters().put('Id', objSchool.id);
         System.currentPageReference().getParameters().put('Name',objSchool.Name);
         GEMS_ClasswiseStrengthCntlr Ctlr = new GEMS_ClasswiseStrengthCntlr();
         Ctlr.sDate = system.today().format();
         Ctlr.selectedcurriculum = '2';
         Ctlr.objAcc.Date_of_Join__c =  Date.parse(Ctlr.sDate);
         Ctlr.AY.Curriculum__c = '2';
         Ctlr.FetchRecords();
         Ctlr.ExportResults();
        
        
    }
}