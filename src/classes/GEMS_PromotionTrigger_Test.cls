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
private class GEMS_PromotionTrigger_Test {

    static testMethod void Promotion_Test() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        Section_Master__c objsec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        Map<string,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
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
        std.Primary_Contact__c = 'Mother';
        std.Child_have_any_special_education_needs__c = 'No';
        insert std;
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('Re-Enroll', objGrade.stream__c, objAY.id, objSchool.id);
                
        Promotion__c objpromo = new Promotion__c();
        objpromo.Active__c = true;
        objpromo.Student__c = std.id;
        insert objpromo;
        
        Promotion__c objpromo1 = new Promotion__c();
        objpromo1.Active__c = true;
        objpromo1.Student__c = std.id;
        insert objpromo1;
        
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__SR_Status__c EnrolledsrStatus = GEMS_TestUtils.createSRStatus('CLOSED');
        
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Re_Enrolment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
                        HexaBPM__Record_Type_Name__c,Primary_Contact__c,Academic_Year__c, gradeLookup__c,School__c
                 from HexaBPM__Service_Request__c 
                 where id=:objSR.id];
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        
        objSR.School__c = objSchool.id;
        objSR.Student__c = std.Id;
        objSR.Academic_Year__c = objAY.Id;
        objSR.Primary_Contact__c = 'Guardian';
        objSR.GradeLookup__c = objGrade.id;
        objSR.Section_Lookup__c = objsec.id;
        update objSR;
        
        HexaBPM__SR_Price_Item__c SRP = new HexaBPM__SR_Price_Item__c();
        SRP.HexaBPM__ServiceRequest__c = objSR.Id;
        SRP.Status__c = 'Added';
        SRP.HexaBPM__Status__c = 'Added';
        SRP.HexaBPM__Sys_Added_through_Code__c = true;
        SRP.HexaBPM__Non_Reevaluate__c = true;
        SRP.HexaBPM__Price__c = 100;
        insert SRP;
        
        objpromo1.Reenrolment_fee_paid_at_School__c = true;
        update objpromo1;
        
    }
}