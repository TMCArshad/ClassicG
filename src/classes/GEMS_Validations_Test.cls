/**
 * Created by bilalnazir on 6/4/17.
 */


@IsTest
private without sharing class GEMS_Validations_Test {

    static testMethod void testGEMSValidations() {

        GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
        List<User> users = createUsers('System Administrator');


        List<Product2> prodList = GEMS_TestUtils.createProducts(10,'REGISTRATION FEE');
        List<HexaBPM__SR_Status__c> SRStatusList = GEMS_TestUtils.createSRStatus();
        List<School__c> schoolList = GEMS_TestUtils.createSchools(5);

        List<Academic_Year__c> academicYears = GEMS_TestUtils.createsAYs(10,schoolList[0]);
        List<Grade__c> grades = GEMS_TestUtils.createGrades(schoolList[0],academicYears);
        List<Amount__c> amounts = GEMS_TestUtils.createAmounts(prodList);
        GEMS_Site_Domain_Config__c sc = GEMS_TestUtils.createSiteConfig(schoolList[0]);
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        List<HexaBPM__Pricing_Line__c> plList = GEMS_TestUtils.createPricingLines(prodList);
        List<Lead> LeadList = GEMS_TestUtils.createLeads(schoolList[0]);
        LeadList = GEMS_TestUtils.updateLeadRef(LeadList);

        List<Account> students = GEMS_TestUtils.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_TestUtils.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_TestUtils.createPriceitems(SR_List,prodList,plList);

        testDuplicateLead();
        testDuplicateEnquiry();
        testValidPayments();
        testAgeCutOffValidations();
        testOtherValidations();
//        testAgeCutOffValidations();
//        testValidPayments();
//        testOtherValidations();

    }

    static void testDuplicateLead() {

        List<Lead> leads= [SELECT id FROM Lead LIMIT 2];

        //Section_Master__c section = [SELECT id From Section_Master__c LIMIT 1];

        School__c school = [SELECT id From School__c LIMIT 1];
        Academic_Year__c academic_year = [SELECT id FROM Academic_Year__c WHERE School__c=:school.Id LIMIT 1];
        Grade__c grade = [SELECT id, Maximum_Age__c FROM Grade__c WHERE Academic_Year__c=:academic_year.Id and School__c=:school.Id LIMIT 1];

        List<Lead> newLeads = new List<Lead>();

        if(grade != null && school != null){
            for(Lead lead: leads){
                lead.FirstName = 'Jack';
                lead.LastName = 'Sparrow';

                Date validDOB = System.today();
                validDOB = validDOB.addYears(2 - Integer.valueof(grade.Maximum_Age__c));
                lead.Date_of_Birth__c = validDOB;

                lead.Academic_Year__c = academic_year.Id;
                lead.SchoolLookup__c = school.Id;
                lead.GradeLookup__c = grade.Id;

                newLeads.add(lead);
            }

            if(newLeads.size() > 0){
                update newLeads;
                GEMS_Validations.checkForDuplicates(leads[0]);
            }
        }
    }

    static void testDuplicateEnquiry() {
        List<Enquiry__c> enquiries= [SELECT id FROM Enquiry__c LIMIT 2];

        School__c school = [SELECT id From School__c LIMIT 1];
        Academic_Year__c academic_year = [SELECT id FROM Academic_Year__c WHERE School__c=:school.Id LIMIT 1];
        Grade__c grade = [SELECT id, Maximum_Age__c FROM Grade__c WHERE Academic_Year__c=:academic_year.Id and School__c=:school.Id LIMIT 1];

        List<Enquiry__c> newEnquiries = new List<Enquiry__c>();

        if(grade != null && school != null){
            for(Enquiry__c enquiry: enquiries){
                enquiry.FirstName__c = 'Jack';
                enquiry.LastName__c = 'Sparrow';

                Date validDOB = System.today();
                validDOB = validDOB.addYears(2 - Integer.valueof(grade.Maximum_Age__c));
                enquiry.Date_of_Birth__c = validDOB;

                enquiry.Academic_Year__c = academic_year.Id;
                enquiry.SchoolLookup__c = school.Id;
                enquiry.GradeLookup__c = grade.Id;

                newEnquiries.add(enquiry);
            }

            if(newEnquiries.size() > 0){
                update newEnquiries;

                GEMS_Validations.checkForDuplicates(newEnquiries[0]);
            }
        }

    }

    static void testAgeCutOffValidations(){

        Lead lead= [SELECT id FROM Lead LIMIT 1];

        School__c school = [SELECT id From School__c LIMIT 1];
        Academic_Year__c academic_year = [SELECT id FROM Academic_Year__c WHERE School__c=:school.Id LIMIT 1];
        Grade__c grade = [SELECT id, Grade_Display__c, Maximum_Age__c FROM Grade__c WHERE Academic_Year__c=:academic_year.Id and School__c=:school.Id LIMIT 1];

        if(lead != null && grade != null && school != null) {

            lead.FirstName = 'Jack';
            lead.LastName = 'Sparrow';

            Date validDOB = System.today();
            validDOB = validDOB.addYears(2 - Integer.valueof(grade.Maximum_Age__c));
            lead.Date_of_Birth__c = validDOB;

            lead.Academic_Year__c = academic_year.Id;
            lead.SchoolLookup__c = school.Id;
            lead.GradeLookup__c = grade.Id;

            update lead;

            // within cut-off age
            GEMS_Validations.validateAgeCutOff(lead, grade.Grade_Display__c);


            lead.Date_of_Birth__c = validDOB.addYears(-10);
            update lead;

            //Maximum-age null
            Grade__c max_cutOffAgeGrade = grade.clone();
            max_cutOffAgeGrade.Maximum_Age__c = null;
            max_cutOffAgeGrade.Academic_Year__c = academic_year.Id;
            insert max_cutOffAgeGrade;


            GEMS_Validations.validateAgeCutOff(lead, max_cutOffAgeGrade.Grade_Display__c);

            //Minimum-age null
            Grade__c min_cutOffAgeGrade = grade.clone();
            min_cutOffAgeGrade.Minimum_Age__c = null;
            min_cutOffAgeGrade.Academic_Year__c = academic_year.Id;
            insert min_cutOffAgeGrade;

            GEMS_Validations.validateAgeCutOff(lead, min_cutOffAgeGrade.Grade_Display__c);

            GEMS_Validations.CheckAgeCutOff(validDOB, grade.Grade_Display__c, school.Id, academic_year.Id);

            grade.Maximum_Age__c = null;
            update grade;
            GEMS_Validations.CheckAgeCutOff(validDOB, grade.Grade_Display__c, school.Id, academic_year.Id);

            grade.Minimum_Age__c = null;
            update grade;
            GEMS_Validations.CheckAgeCutOff(validDOB, grade.Grade_Display__c, school.Id, academic_year.Id);

        }
    }



    static void testValidPayments(){
        List<ID>SRIDs = new List<ID>();
        for(HexaBPM__Service_Request__c sr:[SELECT id FROM HexaBPM__Service_Request__c]){
            SRIDs.add(sr.Id);
        }

        GEMS_Validations.validatePayment(SRIDs);
    }

    static void testOtherValidations(){

        List<HexaBPM__Service_Request__c> openSRs = [SELECT id, Student__c, HexaBPM__Record_Type_Name__c FROM HexaBPM__Service_Request__c];
        GEMS_Validations.validateOpenSR(openSRs);

        List<Account> studentAccounts = [SELECT id, Student_Id__c FROM Account LIMIT 1];
        Account sibling = null;
        if(studentAccounts.size() > 0){
            sibling = studentAccounts[0];
            sibling.Student_Id__c = '12345';

            update sibling;

            GEMS_Validations.validateSiblingFeeId(sibling.Student_Id__c);
        }

        GEMS_Validations.formatDate(Date.today());
    }

    public static List<User> createUsers(String profileName) {
        List<User> User_List = new List<User>();
        Map<String, Id> profileMap = new Map<String, Id>();
        for (Profile p : [Select Id,Name from Profile]) {
            profileMap.put(p.Name, p.Id);
        }
        for (Integer i = 0; i <10; i++) {
            User user = new User(alias = 'test' + i, email = 'test' + i + '@noemail.com',
                    emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                    localesidkey = 'en_US', profileid = profileMap.get(profileName) , country = 'United States', IsActive = true,
                    timezonesidkey = 'America/Los_Angeles', username = 'tester' + Integer.valueOf(math.rint(math.random()*1000000))+ i + '@noemail.com');
            User_List.add(user);
        }
        insert User_List;
        return User_List;
    }
}