/**
 * Created by bilalnazir on 6/4/17.
 */

@isTest
public with sharing class CC_Update_sObject_Test {

    static testMethod void testUpdateSobject() {
        List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
        List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10, 'REGISTRATION FEE');

        List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5, 'Enrollment');
        List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);

        List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
        List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus();
        List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
        List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
        GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
        GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList, users);
        List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10, schoolList[0]);
        List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0], academicYears);
        List<Section_Master__c> sections = GEMS_ChangeTCCntlr_Test.createSectionsForGrades(grades);
        List<Amount__c> amounts = GEMS_ChangeTCCntlr_Test.createAmounts(prodList);
        GEMS_Site_Domain_Config__c sc = GEMS_ChangeTCCntlr_Test.createSiteConfig(schoolList[0]);
        GEMS_ChangeTCCntlr_Test.createLeadEnquirySyncConfig();
        List<HexaBPM__Pricing_Line__c> plList = GEMS_ChangeTCCntlr_Test.createPricingLines(prodList);
        List<Lead> LeadList = GEMS_ChangeTCCntlr_Test.createLeads(schoolList[0]);
        LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);

        List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
        createPromotionsForStudents(students);
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList, students, schoolList[0], 'Enrollment');
        List<HexaBPM__Step__c> stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList = GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List, prodList, plList);

        Contact c = new Contact(LastName='Last Name');
        insert c;

        stepList[0].HexaBPM__SR__r = SR_List[0];
        stepList[0].HexaBPM__SR__r.HexaBPM__Customer__c = students[0].Id;
        stepList[0].HexaBPM__SR__r.HexaBPM__Contact__c = c.Id;
        update stepList[0];

        Test.startTest();

        CC_Update_sObject update_sObject = new CC_Update_sObject();

        HexaBPM__Action__c action = new HexaBPM__Action__c(HexaBPM__Action_Type__c='HexaBPM__Service_Request__c');
        action.HexaBPM__Field_Type__c = 'DOUBLE';
        action.HexaBPM__Field_Name__c='HexaBPM__Quantity__c';
        action.HexaBPM__Field_Value__c='123';
        action.HexaBPM__Value_or_Field__c = 'Value';

        update_sObject.UpdatesObject(action, stepList[0]);

        action.HexaBPM__Field_Type__c = 'DATE';
        action.HexaBPM__Field_Name__c='Passport_Issue_Date__c';
        action.HexaBPM__Field_Value__c='05/12/2017';
        action.HexaBPM__Value_or_Field__c = 'Value';
        update_sObject.UpdatesObject(action, stepList[0]);

        action.HexaBPM__Field_Type__c = 'BOOLEAN';
        action.HexaBPM__Field_Name__c='Enrolment_Transferred__c';
        action.HexaBPM__Field_Value__c='true';
        action.HexaBPM__Value_or_Field__c = 'Value';
        update_sObject.UpdatesObject(action, stepList[0]);

        try{
            action.HexaBPM__Field_Type__c = 'BOOLEAN';
            action.HexaBPM__Field_Name__c='Skip_Validations__c';
            action.HexaBPM__Field_Value__c='true';
            action.HexaBPM__Value_or_Field__c = 'Step Field';
            update_sObject.UpdatesObject(action, stepList[0]);
        }catch(Exception ex){}


        HexaBPM__Action__c action_step = new HexaBPM__Action__c(HexaBPM__Action_Type__c='HexaBPM__Step__c');
        action_step.HexaBPM__Field_Type__c = 'DOUBLE';
        action_step.HexaBPM__Field_Name__c='HexaBPM__Step_No__c';
        action_step.HexaBPM__Field_Value__c='123';
        action_step.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_step, stepList[0]);

        action_step.HexaBPM__Field_Type__c = 'DATE';
        action_step.HexaBPM__Field_Name__c='HexaBPM__Due_Date__c';
        action_step.HexaBPM__Field_Value__c='05/12/2017';
        action_step.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_step, stepList[0]);

        action_step.HexaBPM__Field_Type__c = 'BOOLEAN';
        action_step.HexaBPM__Field_Name__c='Skip_Validations__c';
        action_step.HexaBPM__Field_Value__c='true';
        action_step.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_step, stepList[0]);

        try{
            action_step.HexaBPM__Field_Type__c = 'BOOLEAN';
            action_step.HexaBPM__Field_Name__c='Enrolment_Transferred__c';
            action_step.HexaBPM__Field_Value__c='true';
            action_step.HexaBPM__Value_or_Field__c='SR Field';
            update_sObject.UpdatesObject(action_step, stepList[0]);
        }catch(Exception ex){}


        HexaBPM__Action__c action_account = new HexaBPM__Action__c(HexaBPM__Action_Type__c='Account');
        action_account.HexaBPM__Field_Type__c = 'DOUBLE';
        action_account.HexaBPM__Field_Name__c='NumberOfEmployees';
        action_account.HexaBPM__Field_Value__c='123';
        action_account.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_account, stepList[0]);

        action_account.HexaBPM__Field_Type__c = 'DATE';
        action_account.HexaBPM__Field_Name__c='Cancel_Date__c';
        action_account.HexaBPM__Field_Value__c='05/12/2017';
        action_account.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_account, stepList[0]);

        action_account.HexaBPM__Field_Type__c = 'BOOLEAN';
        action_account.HexaBPM__Field_Name__c='Do_you_require_school_transportation__c';
        action_account.HexaBPM__Field_Value__c='true';
        action_account.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_account, stepList[0]);

        HexaBPM__Action__c action_contact = new HexaBPM__Action__c(HexaBPM__Action_Type__c='Contact');

        action_contact.HexaBPM__Field_Type__c = 'DATE';
        action_contact.HexaBPM__Field_Name__c='Birthdate';
        action_contact.HexaBPM__Field_Value__c='05/12/2017';
        action_contact.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_contact, stepList[0]);

        action_contact.HexaBPM__Field_Type__c = 'BOOLEAN';
        action_contact.HexaBPM__Field_Name__c='DoNotCall';
        action_contact.HexaBPM__Field_Value__c='true';
        action_contact.HexaBPM__Value_or_Field__c='Value';
        update_sObject.UpdatesObject(action_contact, stepList[0]);

        try{
            action_contact.HexaBPM__Field_Type__c = 'BOOLEAN';
            action_contact.HexaBPM__Field_Name__c='Enrolment_Transferred__c';
            action_contact.HexaBPM__Field_Value__c='true';
            action_contact.HexaBPM__Value_or_Field__c='SR Field';
            update_sObject.UpdatesObject(action_contact, stepList[0]);

            action_contact.HexaBPM__Field_Type__c = 'DOUBLE';
            action_contact.HexaBPM__Field_Name__c='Title';
            action_contact.HexaBPM__Field_Value__c='123';
            action_contact.HexaBPM__Value_or_Field__c='Value';
            update_sObject.UpdatesObject(action_contact, stepList[0]);
            
        }catch(Exception ex){}
        try{
            action_contact.HexaBPM__Field_Type__c = 'BOOLEAN';
            action_contact.HexaBPM__Field_Name__c='Skip_Validations__c';
            action_contact.HexaBPM__Field_Value__c='true';
            action_contact.HexaBPM__Value_or_Field__c='Step Field';
            update_sObject.UpdatesObject(action_contact, stepList[0]);
        }catch(Exception ex){}

        Test.stopTest();
    }

    public static void createPromotionsForStudents(List<Account> students){
        Promotion__c prom ;
        List<Promotion__c> promList =  new List<Promotion__c>();
        for(Account accObj :  students){

            prom = new Promotion__c();
            prom.Student__c = accObj.Id;
            prom.Active__c = true;
            promList.add(prom);

        }
        insert promList;

    }
}