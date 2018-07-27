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
private class GEMS_Account_Handler_Test {

    static testMethod void Account_Test() {
        Map<string,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        list<Account> accountList = new list<Account>();
        
        GEMS_OASIS_CountryGroup__c countryCode = new GEMS_OASIS_CountryGroup__c();
        countryCode.Name= '172';
        countryCode.NATIONALITY_API__c= '172';
        countryCode.CTY_NATIONALITY__c= 'UAE';
        countryCode.CTY_GROUP__c= 'UAE nationals';
        countryCode.CTY_CORP_GROUP__c= 'Arab Countries';
        insert countryCode;
        
        Account mother = new Account();
        Id Rectype1= rt_Map.get('Parent/Guardian').getRecordtypeId();
        mother.Recordtypeid = Rectype1;
        mother.firstname = 'motherfirstname';
        mother.lastname = 'motherlastname';
        mother.Role__c = 'Mother';
        mother.PersonEmail = 'test@test.test';
        mother.PersonMobilePhone = '1111111';
        mother.Master_Student__c = '111111111';
        mother.Sys_Parent_from_Oasis__c = true;
        mother.Sys_Student_from_Oasis__c = true;
        accountList.add(mother);
        
        Account father = new Account();
        Id Rectype2= rt_Map.get('Parent/Guardian').getRecordtypeId();
        father.Recordtypeid = Rectype2;
        father.firstname = 'fatherfirstname';
        father.lastname = 'fatherlastname';
        father.Role__c = 'Father';
        father.PersonEmail = 'test@test.test';
        father.PersonMobilePhone = '1111111';
        father.Master_Student__c = '111111111';
        father.Master_Student__c = '111111111';
        father.Sys_Parent_from_Oasis__c = true;
        father.Sys_Student_from_Oasis__c = true;
        accountList.add(father);
        
        Account guardian = new Account();
        Id Rectype3= rt_Map.get('Parent/Guardian').getRecordtypeId();
        guardian.Recordtypeid = Rectype3;
        guardian.firstname = 'guardianfirstname';
        guardian.lastname = 'guardianlastname';
        guardian.Role__c = 'Guardian';
        guardian.PersonEmail = 'test@test.test';
        guardian.PersonMobilePhone = '1111111';
        guardian.Master_Student__c = '111111111';
        guardian.Sys_Parent_from_Oasis__c = true;
        guardian.Sys_Student_from_Oasis__c = true;
        accountList.add(guardian);
        
        Account guardian1 = new Account();
        guardian1.Recordtypeid = Rectype3;
        guardian1.firstname = 'guardianfirstname1';
        guardian1.lastname = 'guardianlastname1';
        guardian1.Role__c = 'Guardian';
        guardian1.PersonEmail = 'test@test.test';
        guardian1.PersonMobilePhone = '1111111';
        guardian1.Master_Student__c = '111111111';
        guardian1.Sys_Parent_from_Oasis__c = true;
        guardian1.Sys_Student_from_Oasis__c = true;
        accountList.add(guardian1);
        
        insert accountList;
        
        accountList = new list<Account>();
        
        Account objStudent = new Account();
        objStudent.primary_contact__c = 'Mother';
        objStudent.father__c = father.id;
        objStudent.mother__c = mother.id;
        objStudent.guardian_1__c = guardian.id;
        objStudent.guardian_2__c = guardian1.id;
        objStudent.Master_Student__c = '111111111';
        objStudent.Sibling_ID__c = '333333333';
        objStudent.Sys_Student_from_Oasis__c = true;
        objStudent.Current_Status__c = 'EN';
        objStudent.recordtypeid = rt_Map.get('Student').getRecordtypeId();
        objStudent.firstName = 'dsaa';
        objStudent.lastname = 'dsaa';
        objStudent.Nationality__c = '172';
        accountList.add(objStudent);
        
        Account objSibling = new Account();
        objSibling.primary_contact__c = 'Mother';
        objSibling.father__c = father.id;
        objSibling.mother__c = mother.id;
        objSibling.guardian_1__c = guardian.id;
        objSibling.guardian_2__c = guardian1.id;
        objSibling.Master_Student__c = '111111111';
        objSibling.Sibling_ID__c = '111111111';
        objSibling.Sys_Student_from_Oasis__c = true;
        objSibling.Current_Status__c = 'EN';
        objSibling.recordtypeid = rt_Map.get('Student').getRecordtypeId();
        objSibling.firstName = 'dsaasas';
        objSibling.lastname = 'dsaaasas';
        accountList.add(objSibling);
        
        insert accountList;
        
        list<Relationship__c> relationList = new list<Relationship__c>();
        
        Relationship__c objFather = new Relationship__c();
        objFather.subject_account__c = objStudent.id;
        objFather.object_account__c = father.id;
        objFather.type__c = 'Father';
        objFather.active__c = true;
        relationList.add(objFather);
        
        Relationship__c objMother = new Relationship__c();
        objMother.subject_account__c = objStudent.id;
        objMother.object_account__c = Mother.id;
        objMother.type__c = 'Mother';
        objMother.active__c = true;
        relationList.add(objMother);
        
        Relationship__c objGuardian = new Relationship__c();
        objGuardian.subject_account__c = objStudent.id;
        objGuardian.object_account__c = Guardian.id;
        objGuardian.type__c = 'Guardian';
        objGuardian.active__c = true;
        relationList.add(objGuardian);
        
        Relationship__c objsib = new Relationship__c();
        objsib.subject_account__c = objStudent.id;
        objsib.object_account__c = objsibling.id;
        objsib.type__c = 'Sibling';
        objsib.active__c = true;
        relationList.add(objsib);
        
        Relationship__c objstu = new Relationship__c();
        objstu.subject_account__c = objSibling.id;
        objstu.object_account__c = objStudent.id;
        objstu.type__c = 'Sibling';
        objstu.active__c = true;
        relationList.add(objstu);
        
        insert relationList;
        
        objStudent.primary_contact__c = 'Father';
        update objStudent;
        
        father.PersonEmail = 'test1@test.test';
        update father;
        
        objStudent.primary_contact__c = 'Mother';
        update objStudent;
        
        objStudent.primary_contact__c = 'Guardian';
        update objStudent;
        
        objStudent.primary_contact__c = '';
        update objStudent;
        
        Account objStudent1 = GEMS_TestUtils.createStudentAccount('TestStudent');
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objsec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        
      
        
        objStudent1.Gender__c = 'Male';
        objStudent1.School__c = objSchool.id;
        objStudent1.Academic_Year__c = objAY.id;
        objStudent1.GradeLookup__c = objGrade.id;
        objStudent1.Section__c = objsec.id;
        objStudent1.Current_Status__c = 'EN';
        update objStudent1;
        
        delete objStudent1;
        
        
        Account par = new Account();
        par.Recordtypeid = Rectype3;
        par.lastname = 'parentlastname';
        par.Sys_Parent_from_Oasis__c = true;
        par.Master_Student__c = '1234';
        par.Role__c = 'Mother';
        insert par;
        
        Account std = new Account();
        Id Rectype= rt_Map.get('Student').getRecordtypeId(); 
        std.Recordtypeid = Rectype;
        std.lastname = 'Testlastname';
        std.Current_Status__c = 'EN';
        std.Gender__c = 'Male';
        std.School__c = objSchool.id;
        std.Academic_Year__c = objAY.id;
        std.GradeLookup__c = objGrade.id;
        std.Section__c = objsec.id;
        std.Photo_URL__c = 'test';
        std.First_Language__c = 'English';
        std.Child_have_any_special_education_needs__c = 'Yes';
        std.Sibling_ID__c = '1234';
        std.Sys_Student_from_Oasis__c = true;
        std.Primary_Contact__c = 'Father';
        std.mother__c = par.id;
        std.Nationality__c = '172';
        insert std;
        
        Account std2 = new Account();
        Id Rectype0= rt_Map.get('Student').getRecordtypeId(); 
        std2.Recordtypeid = Rectype0;
        std2.lastname = 'Testlastname';
        std2.Current_Status__c = 'EN';
        std2.Gender__c = 'Male';
        std2.School__c = objSchool.id;
        std2.Academic_Year__c = objAY.id;
        std2.GradeLookup__c = objGrade.id;
        std2.Section__c = objsec.id;
        std2.Sibling_ID__c = '12345';
        std2.Primary_Contact__c = 'Father';
        std2.Nationality__c = '172';
        insert std2;
        
        Account std3 = new Account();       
        std3.Recordtypeid = Rectype;
        std3.lastname = 'Testlastname';
        std3.Current_Status__c = 'EN';
        std3.Gender__c = 'Male';
        std3.School__c = objSchool.id;
        std3.Academic_Year__c = objAY.id;
        std3.GradeLookup__c = objGrade.id;
        std3.Section__c = objsec.id;
        std3.Sibling_ID__c = '123456';
        std3.Primary_Contact__c = 'Guardian';
        std3.Nationality__c = '172';
        insert std3;
        
        Account par3 = new Account();
        //Id Rectype3= rt_Map.get('Parent/Guardian').getRecordtypeId();
        par3.Recordtypeid = Rectype3;
        par3.lastname = 'parentlastname';
        par3.Sys_Parent_from_Oasis__c = true;
        par3.Master_Student__c = '123456';
        par3.Role__c = 'Guardian'; 
        par3.PersonEmail = 'test@email.com';
        insert par3;
        
        Account std4 = new Account();       
        std4.Recordtypeid = rt_Map.get('Student').getRecordtypeId();
        std4.lastname = 'Testlastname1';
        std4.Current_Status__c = 'EN';
        std4.Gender__c = 'Male';
        std4.School__c = objSchool.id;
        std4.Academic_Year__c = objAY.id;
        std4.GradeLookup__c = objGrade.id;
        std4.Section__c = objsec.id;
        std4.Sibling_ID__c = '123456';
        std4.Sys_Student_from_Oasis__c = true;
        std4.Primary_Contact__c = 'Guardian';
        std4.Role__c = 'Sibling';
        insert std4;
    }
}