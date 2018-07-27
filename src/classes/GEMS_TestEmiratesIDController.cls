/**
 * Created by bilalnazir on 5/14/17.
 */

@IsTest
private class GEMS_TestEmiratesIDController {

    static testMethod void testSearchEnrollments() {
        Test.startTest();

        Account student = GEMS_TestUtils.createStudentAccount('test');

        Date d = Date.today(); d = d.addYears(1);
        student.Emirates_ID_Expiry_Date__c = d;
        student.Emirates_ID_Synced_Date__c = Date.today();

        Account mother = GEMS_TestUtils.createStudentAccount('mother');
        mother.Emirates_ID_Expiry_Date__c = d;
        mother.Emirates_ID_Synced_Date__c = Date.today();
        update mother;
        student.Mother__c = mother.Id;

        Account father = GEMS_TestUtils.createStudentAccount('father');
        father.Emirates_ID_Expiry_Date__c = d;
        father.Emirates_ID_Synced_Date__c = Date.today();
        update father;
        student.Father__c = father.Id;
        update student;

        GEMS_EmiratesIDController gems_eidController = new GEMS_EmiratesIDController();
        gems_eidController.studentName = 'test';

        //gems_eidController.searchType = 'enrollment';
        //gems_eidController.selectedSchool = '12345';
        gems_eidController.search();

        List<GEMS_EmiratesIDController.StudentEmiratesIDAccount>account_res = gems_eidController.studentEmiratesIDAccounts;
        if(account_res.size() > 0){
            account_res[0].getIsStudentEmiratesIdExpired();
            account_res[0].getIsMotherEmiratesIdExpired();
            account_res[0].getIsFatherEmiratesIDFilled();
            account_res[0].getIsFatherEmiratesIdExpired();
        }

        Test.stopTest();
    }

    static testMethod void testSearchEnquiries() {
        Test.startTest();

        HexaBPM__Service_Request__c sr = null;
        sr = GEMS_TestUtils.createStudentSR('test');

        System.assertNotEquals(sr,null);

        HexaBPM__SR_Status__c endStatus = new HexaBPM__SR_Status__c();

//        List<SelectOption> statusOptions = new List<SelectOption>();
//        statusOptions.add(new SelectOption('End', 'End'));
//
//        endStatus.HexaBPM__Type__c = statusOptions;
//        endStatus.HexaBPM__Type__c = 'End';
//        endStatus.HexaBPM__Code__c = '1234';
        endStatus.HexaBPM__Type__c = 'Open';
        endStatus.HexaBPM__Code__c = '1234';

        insert endStatus;

        sr.HexaBPM__Internal_SR_Status__c = endStatus.Id;
        sr.HexaBPM__External_SR_Status__c = endStatus.Id;


        GEMS_EmiratesIDController gems_eidController = new GEMS_EmiratesIDController();
        gems_eidController.studentName = 'test';

        Date expiryDate = Date.today(); expiryDate = expiryDate.addYears(1);

        sr.Last_Emirates_ID_Sync_Date__c = Date.today();
        sr.Emirates_ID_Expiry_Date__c = expiryDate;

        sr.Emirates_ID_Expiry_Date__c = expiryDate;
        sr.Last_Emirates_ID_Sync_Date__c = Date.today();

        sr.Emirates_ID_Expire_Date_Mother__c = expiryDate;
        sr.Last_Emirates_ID_Sync_Date_Mother__c = Date.today();

        sr.Emirates_ID_Expire_Date_Father__c = expiryDate;
        sr.Last_Emirates_ID_Sync_Date_Father__c = Date.today();

        upsert sr;

        gems_eidController.searchType = 'enquiries';
        gems_eidController.search();

        List<GEMS_EmiratesIDController.StudentEmiratesIDSR>sr_res = gems_eidController.studentEmiratesIDServiceRequests;
        if(sr_res.size() > 0){
            sr_res[0].getIsStudentEmiratesIdExpired();
            sr_res[0].getIsMotherEmiratesIdExpired();
            sr_res[0].getIsFatherEmiratesIDFilled();
            sr_res[0].getIsFatherEmiratesIdExpired();
        }

        Test.stopTest();
    }

    static testMethod void create_School(){
        School__c school = new School__c(ID__c='12345', Name='Miami School');
        insert school;

        Academic_Year__c academic_year = new Academic_Year__c(School__c = school.Id);
        insert academic_year;

        Grade__c grade = new Grade__c(Academic_Year__c=academic_year.Id, School__c=school.Id, Grade_Display__c='1339393');
        insert grade;

        GEMS_EmiratesIDController gems_eidController = new GEMS_EmiratesIDController();
        gems_eidController.academicYear = academic_year.id;

        gems_eidController.getAllGemsSchools();
        gems_eidController.getAllAcademicYears();
        gems_eidController.getGradesForAcademicYear();

    }
}