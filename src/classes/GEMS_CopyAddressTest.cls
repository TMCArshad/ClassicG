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
private class GEMS_CopyAddressTest {

    static testMethod void CopyAddressCls() {
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
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Account acc = new Account();
        acc.LastName = 'name';
        acc.recordtypeid = AccountRecordTypeInfo.get('Parent/Guardian').getRecordTypeId();
        acc.Emirates_Full_Name__c = 'Full Name';
        acc.Country__c = '172';
        acc.P_O_Box__c = '34';
        acc.Role__c = 'Father';
        acc.Master_Student__c = '123456';
        acc.school__c = objSchool.id;
        insert acc;
        
        Account acc1 = new Account(LastName = 'lname', recordtypeid = AccountRecordTypeInfo.get('Parent/Guardian').getRecordTypeId());
        acc1.Emirates_Full_Name__c = 'Full Name';
        acc1.Country__c = '172';
        acc1.Role__c = 'Mother';
        acc1.Master_Student__c = '123456';
        acc1.school__c = objSchool.id;
        
        insert acc1;
        
        
        Relationship__c rel = new Relationship__c();
        rel.Subject_Account__c = objStudent.id;
        rel.Object_Account__c = acc.id;
        rel.Type__c = 'Father';
        rel.Active__c = true;
        
        
        insert rel;
        
        Relationship__c rel1 = new Relationship__c();
        rel1.Subject_Account__c = objStudent.id;
        rel1.Object_Account__c = acc1.id;
        rel1.Type__c = 'Mother';
        rel1.Active__c = true;
        
        
        insert rel1;
        
      
        Test.setCurrentPageReference(new PageReference('Page.GEMS_CopyAddress'));
        System.currentPageReference().getParameters().put('Id', objStudent.id);
        GEMS_CopyAddressCls Ctlr = new GEMS_CopyAddressCls(); 
        Ctlr.SubjectAccountId = acc.id;
        Ctlr.MasterStudentId = '123456';
        Ctlr.SubjectRelation = 'Father'; 
        Ctlr.selectedRole = 'Mother';
        Ctlr.SaveDetails();
        Ctlr.CancelDetails();
        
    }
}