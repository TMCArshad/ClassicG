@isTest
private class GEMS_RelationpShipClsTest {
    
    static testMethod void method1() {
        
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
        
        
        Relationship__c siblingRel  = GEMS_TestUtils.createRelationship(objStudent,objStudent2,'Sibling');
        //insert siblingRel;
        
        Account parentAccount = TestDataFactory.createParentAccount();
        insert parentAccount;
         
        Relationship__c parentRel  = GEMS_TestUtils.createRelationship(objStudent,parentAccount,'Father');
        //insert parentRel;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_RelationShipVFpage'));
        System.currentPageReference().getParameters().put('Id', objStudent.id);
        
        ApexPages.StandardController scontroller = new ApexPages.standardController(objStudent);
         
        Test.startTest();
        GEMS_RelationpShipCls objRel = new GEMS_RelationpShipCls(scontroller);
        objRel.strAcctId = objStudent.id;
        objRel.getRelationshipData();
        Test.stopTest();
    
    }
    
      static testMethod void method2() {
        
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
        
        
        Relationship__c siblingRel  = GEMS_TestUtils.createRelationship(objStudent,objStudent2,'Sibling');
        //insert siblingRel;
        
        Test.setCurrentPageReference(new PageReference('Page.GEMS_RelationShipVFpage'));
        System.currentPageReference().getParameters().put('Id', objStudent.id);
        
        ApexPages.StandardController scontroller = new ApexPages.standardController(objStudent);
         
        Test.startTest();
        GEMS_RelationpShipCls objRel = new GEMS_RelationpShipCls(scontroller);
        objRel.getRelationshipData();
        Test.stopTest();
    
    }

}