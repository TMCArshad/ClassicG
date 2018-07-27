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
private class GEMS_SectionAllotmentCtlr_Test {

    static testMethod void SectionAlloctaion() {
      school__c objSchool = GEMS_TestUtils.createSchool();
      academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
      grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
      
      Account acc = new Account();
      acc.FirstName = 'First';
      acc.LastName = 'Test Last';
      for(RecordType rectyp:[Select Id from RecordType where sObjectType='Account' and DeveloperName='Student']){
          acc.RecordTypeId = rectyp.Id;
      }
      acc.Current_Status__c = 'EN';
      acc.School__c = objSchool.Id;
      acc.Academic_Year__c = objAY.Id;
      acc.GradeLookup__c = objGrade.Id;
      upsert acc;
      
      
      Test.setCurrentPageReference(new PageReference('Page.GEMS_SectionAllotment'));
      apexpages.currentPage().getParameters().put('SchoolId', objSchool.id);
      GEMS_SectionAllotmentCtlr secCtrl = new GEMS_SectionAllotmentCtlr();
      
      secCtrl.selectedAcademicYear = objAY.id;
      secCtrl.selectedAcademicYear1 = objAY.id;
      secCtrl.selectedGrade = objGrade.id;
      secCtrl.selectedStream = objGrade.Stream__c;
      secCtrl.prepareAcademicYears();
      secCtrl.PrepareCurriculum();
      secCtrl.PrepareGrades();
      secCtrl.PrepareStreams();
      secCtrl.PrepareSections();
      secCtrl.PrepareSectionsforAssigning();
      secCtrl.RePrepareAllotSectionList();
      secCtrl.PrepareSectionDetails();
      secCtrl.ListStudents();
      
      secCtrl.StudentName = '';
      secCtrl.StudentId = '1234';
      secCtrl.ListStudents();
      
      secCtrl.StudentName = 'First Test Last';
      secCtrl.StudentId = '';
      secCtrl.ListStudents();
      
      secCtrl.StudentName = '';
      secCtrl.StudentId = '';
      secCtrl.ListStudents();
      
      secCtrl.allocateStudents();
      secCtrl.CancelChanges();
      
      GEMS_SectionAllotmentCtlr.StudentWrap objWrap = new GEMS_SectionAllotmentCtlr.StudentWrap();
    }
}