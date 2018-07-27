/**
 * Created by bilalnazir on 6/5/17.
 */

@IsTest
private class ProgressIndicatorController_Test {


    static testMethod void testProgressInidcator() {

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

        Test.startTest();


        HexaBPM__Service_Request__c sr =  SR_List[0];
        List<HexaBPM__SR_Steps__c> sr_steps = new List<HexaBPM__SR_Steps__c>();
        for(HexaBPM__SR_Steps__c sr_step: SRSteps){
            sr_step.groupname__c = 'xyz';
            sr_steps.add(sr_step);
        }
        update sr_steps;

        HexaBPM__Step__c step = stepList[0];
        step.HexaBPM__Summary__c = 'Online System Check';
        step.HexaBPM__SR__c = sr.Id;//SR_List[0];

        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c();
        stepStatus.HexaBPM__Code__c = '1929';
        insert stepStatus;
        step.HexaBPM__Status__c = stepStatus.Id;
        step.HexaBPM__SR_Step__c = SRSteps[0].Id;
        update step;


        HexaBPM__Step_Transition__c step_transition_From = new HexaBPM__Step_Transition__c();
        HexaBPM__Step_Transition__c step_transition_To = new HexaBPM__Step_Transition__c();
        insert step_transition_From;
        insert step_transition_To;

        HexaBPM__Transition__c transition = new HexaBPM__Transition__c();
        transition.HexaBPM__From__c = stepStatus.Id;
        transition.HexaBPM__To__c = stepStatus.Id;
        insert transition;

        step_transition_From.HexaBPM__Transition__c = transition.Id;
        step_transition_From.HexaBPM__SR_Status_Internal__c = SRStatusList[0].Id;
        step_transition_From.HexaBPM__SR_Status_External__c = SRStatusList[0].Id;

        step_transition_To.HexaBPM__Transition__c = transition.Id;
        step_transition_To.HexaBPM__SR_Status_Internal__c = SRStatusList[0].Id;
        step_transition_To.HexaBPM__SR_Status_External__c = SRStatusList[0].Id;

        update step_transition_To;
        update step_transition_From;

        stepStatus.Name = step_transition_From.Name;
        update stepStatus;



        Test.setCurrentPageReference(new PageReference('/apex/ProgressInidcator'));
        System.currentPageReference().getParameters().put('Id', sr.Id);
        sr.HexaBPM__Submitted_DateTime__c = DateTime.now();

        update sr;

        ProgressIndicatorController progressIndicatorController = new ProgressIndicatorController(null);

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