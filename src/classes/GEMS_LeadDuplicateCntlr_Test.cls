/**
 * Created by bilalnazir on 6/1/17.
 */

@IsTest
private class GEMS_LeadDuplicateCntlr_Test {
    static testMethod void testBehavior() {

        GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
        List<User> users = GEMS_TestUtils.createUsers('System Administrator');

        List<Product2> prodList = GEMS_TestUtils.createProducts(10,'REGISTRATION FEE');
        List<HexaBPM__SR_Status__c> SRStatusList = GEMS_TestUtils.createSRStatus();
        List<School__c> schoolList = GEMS_TestUtils.createSchools(5);

        GEMS_TestUtils.createQueueConfig(schoolList);
        GEMS_TestUtils.createQueuesForSchools(schoolList, users);

        List<Academic_Year__c> academicYears = GEMS_TestUtils.createsAYs(10,schoolList[0]);
        List<Grade__c> grades = GEMS_TestUtils.createGrades(schoolList[0],academicYears);
        List<Amount__c> amounts = GEMS_TestUtils.createAmounts(prodList);
        GEMS_Site_Domain_Config__c sc = GEMS_TestUtils.createSiteConfig(schoolList[0]);
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        List<HexaBPM__Pricing_Line__c> plList = GEMS_TestUtils.createPricingLines(prodList);
        List<Lead> LeadList = GEMS_TestUtils.createLeads(schoolList[0]);
        LeadList = GEMS_TestUtils.updateLeadRef(LeadList);

        List<Account> students = GEMS_TestUtils.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_TestUtils.createSRForLead(LeadList,students,schoolList[0],'TC_Request');
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_TestUtils.createPriceitems(SR_List,prodList,plList);



        Date bDate = Date.today();
        bDate = bDate.addYears(-6);

        List<Lead>newLeads = new List<Lead>();
        for(Lead lead : LeadList){
            lead.lastName = 'Kerr';
            lead.FirstName = 'Miranda';
            lead.Gender__c = 'Female';
            lead.mobilePhone = '+9715252516594';
            lead.SchoolLookup__c  = schoolList[0].Id;
            lead.Date_Of_Birth__c = bDate;
//            lead.Passport_Number__c = '1234567890';
            newLeads.add(lead);
        }
        update newLeads;

        Lead l1 = newLeads[0];
        HexaBPM__Service_Request__c sr1 = SR_List[0];

        sr1.HexaBPM__Email__c = newLeads[0].Email;
        sr1.Mobile__c = newLeads[0].MobilePhone;
        sr1.First_Name__c = newLeads[0].FirstName;
        sr1.Last_Name__c = newLeads[0].LastName;
        sr1.Lead__c = newLeads[1].Id;
        update sr1;

//        HexaBPM__Service_Request__c sr2 = SR_List[0];
//        sr2.Lead__c = newLeads[0].Id;
//        sr2.Date_Of_Birth__c = bDate;
//        sr2.Gender__c = newLeads[0].Gender__c;
//        sr2.Passport_No__c = newLeads[0].Passport_Number__c;
//        update sr2;



        ApexPages.StandardController scontroller = new ApexPages.standardController(sr1);
        GEMS_LeadDuplicateCntlr testLeadDuplicateCntlr = new GEMS_LeadDuplicateCntlr(scontroller);
        //testLeadDuplicateCntlr.getDuplicateAccounts();

        ApexPages.StandardController scontrolle = new ApexPages.standardController(l1);
        GEMS_LeadDuplicateCntlr testLeadDuplicateCntlr2 = new GEMS_LeadDuplicateCntlr(scontrolle);
        //testLeadDuplicateCntlr2.getDuplicateLeads('Lead');
        //testLeadDuplicateCntlr2.getDuplicateAccounts();



    }

}