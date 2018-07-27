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
private class GEMS_AllocateSectionforStudent_Test {

    static testMethod void Allocatesectionforstudent() {
      school__c objSchool = GEMS_TestUtils.createSchool();
      academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
      grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
      Section_Master__c objsec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
      
      Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(Account.getsObjectType()).get('Student');
       Account objStudent = new Account();
       objStudent.lastName = 'test';
       objStudent.RecordTypeId = recTypeID;
       objStudent.School__c = objSchool.id;
       objStudent.Academic_Year__c = objAY.id;
       objStudent.GradeLookup__c = objGrade.id;
       objstudent.Section__c = objsec.id;
       insert objstudent;
       
      Test.setCurrentPageReference(new PageReference('Page.GEMS_Allot_Section_forStudent'));
      apexpages.currentPage().getParameters().put('StudentId', objStudent.Id);
      apexpages.currentPage().getParameters().put('School', objSchool.name);
      apexpages.currentPage().getParameters().put('Name', objStudent.lastName);
      apexpages.currentPage().getParameters().put('GradeId', objGrade.id);
      GEMS_AllocateSectionforStudent secCtlr = new GEMS_AllocateSectionforStudent(); 
        
      secCtlr.selectedSection = objsec.id;
      secCtlr.AcademicYear = objAY.Academic_Year__c;
      secCtlr.GradeValue = objGrade.Grade_Display__c;
      
     
      secCtlr.PrepareSections();
      secCtlr.PrepareSectionDetails();
      
      
      
      secCtlr.allocateStudents();
      secCtlr.CancelAllocation();
    }
}