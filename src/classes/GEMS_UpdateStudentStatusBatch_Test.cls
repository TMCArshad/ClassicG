/**
 * Created by bilalnazir on 6/1/17.
 */

@IsTest
private class GEMS_UpdateStudentStatusBatch_Test {
    static testMethod void testUpdateStudentBatch() {

//        List<Account> studentAccounts = new List<Account>();
//        for(Integer i = 0; i < 10; i++){
//            Account student = GEMS_TestUtils.createStudentAccount('Test ' + i);
//            studentAccounts.add(student);
//
//            //
//            HexaBPM__Service_Request__c sr = GEMS_TestUtils.createSR('TC_Request');
//            sr.Student__c = student.Id;
//            sr.Date_of_Leaving__c = System.today();
//            update sr;
//        }
//
//        insert studentAccounts;


        List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
        List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
        List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
        List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10,schoolList[0]);
        List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0],academicYears);
        List<Amount__c> amounts = GEMS_ChangeTCCntlr_Test.createAmounts(prodList);
        GEMS_Site_Domain_Config__c sc = GEMS_ChangeTCCntlr_Test.createSiteConfig(schoolList[0]);
        GEMS_ChangeTCCntlr_Test.createLeadEnquirySyncConfig();
        List<HexaBPM__Pricing_Line__c> plList = GEMS_ChangeTCCntlr_Test.createPricingLines(prodList);
        List<Lead> LeadList = GEMS_ChangeTCCntlr_Test.createLeads(schoolList[0]);
        LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);

        List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'TC_Request');
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);

        HexaBPM__SR_Status__c closedStatus = [SELECT id, Name FROM HexaBPM__SR_Status__c WHERE Name='Closed' LIMIT 1];

        for(HexaBPM__Service_Request__c sr: SR_List){
            sr.HexaBPM__External_SR_Status__c = closedStatus.Id;
            sr.Date_of_Leaving__c = System.today();
        }
        update SR_List;
        students[0].Leave_Date__c = System.today();
        students[0].cancel_Date__c = System.today()-7;
        students[0].SO_Cancel_Date__c = System.today()-7;
        
        students[1].Leave_Date__c = System.today();
        students[1].cancel_Date__c = NULL;
        students[1].SO_Cancel_Date__c = NULL;
        
        students[2].Leave_Date__c = System.today();
        students[2].cancel_Date__c = NULL;
        students[2].SO_Cancel_Date__c = System.today()-7;
        
        students[3].Leave_Date__c = System.today();
        students[3].cancel_Date__c = System.today()-7;
        students[3].SO_Cancel_Date__c = NUll;
        
        update students;
        Test.startTest();
        GEMS_UpdateStudentStatusBatch updateStudentBatch = new GEMS_UpdateStudentStatusBatch();
        Database.executeBatch(updateStudentBatch);
        Test.stopTest();
    }
}