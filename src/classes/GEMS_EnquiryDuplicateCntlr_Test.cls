/**
 * Created by bilalnazir on 6/4/17.
 */

@IsTest
private class GEMS_EnquiryDuplicateCntlr_Test {
    static testMethod void testEnquiryDuplicate() {


        // Default test Setup

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
        List<Enquiry__c> enquiries = GEMS_TestUtils.createEnquiries(schoolList[0]);
        //LeadList = GEMS_TestUtils.updateLeadRef(LeadList);

        List<Account> students = GEMS_TestUtils.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_TestUtils.createSRForEnquiry(enquiries,students,schoolList[0],'Enrollment');
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_TestUtils.createPriceitems(SR_List,prodList,plList);


        Date bDate = Date.today();
        bDate = bDate.addYears(-6);

        List<Enquiry__c>newEnquiries = new List<Enquiry__c>();
        for(Enquiry__c enquiry: enquiries){
            enquiry.LastName__c = 'Kerr';
            enquiry.FirstName__c = 'Miranda';
            enquiry.Gender__c = 'Female';
            enquiry.MobilePhone__c = '+9715252516594';
            enquiry.SchoolLookup__c  = schoolList[0].Id;
            enquiry.Date_Of_Birth__c = bDate;
//            lead.Passport_Number__c = '1234567890';
            newEnquiries.add(enquiry);
        }
        update newEnquiries;

        Enquiry__c l1 = newEnquiries[0];
        HexaBPM__Service_Request__c sr1 = SR_List[0];

        //sr1.Lead__c = newEnquiries[0].Id;
        sr1.Date_Of_Birth__c = bDate;
        sr1.Gender__c = newEnquiries[0].Gender__c;
        sr1.First_Name__c = newEnquiries[0].FirstName__c;
        sr1.Last_Name__c = newEnquiries[0].LastName__c;
        sr1.Enquiry__c = newEnquiries[0].Id;
        update sr1;

        ApexPages.StandardController scontroller = new ApexPages.standardController(sr1);
        GEMS_EnquiryDuplicateCntlr enquiryDuplicateCntlr = new GEMS_EnquiryDuplicateCntlr(scontroller);

        ApexPages.StandardController scontrolle = new ApexPages.standardController(l1);
        GEMS_EnquiryDuplicateCntlr enquiryDuplicateCntlr2 = new GEMS_EnquiryDuplicateCntlr(scontrolle);

    }

}