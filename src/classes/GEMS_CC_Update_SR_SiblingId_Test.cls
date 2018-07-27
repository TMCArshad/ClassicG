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
private class GEMS_CC_Update_SR_SiblingId_Test {
    static testMethod void myUnitTest() {
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        objSR.Primary_Contact__c = 'Father';
        objSR.Sibling_Fee_ID__c = '12345';
        objSR.Student_Id__c = '12345612341234';
        objSR.Lead_Reference__c = '00Q9E000001gXpO';
        update objSR;
        HexaBPM__Step__c step;
        for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where Id=:objSR.id]){
            step = GEMS_TestUtils.createStep(SR,'Verification Step','Awaiting Verification');
        }
        for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR__c,HexaBPM__SR__r.StudentId__c,HexaBPM__SR__r.Sibling_Fee_Id_Verified__c,HexaBPM__SR__r.Lead_Reference__c,HexaBPM__SR__r.Sibling_Fee_ID__c from HexaBPM__Step__c where Id=:step.Id]){
            step = stp;
        }
        GEMS_CC_Update_SR_SiblingId objInterface = new GEMS_CC_Update_SR_SiblingId();
        string result = objInterface.EvaluateCustomCode(objSR,step);
    }
    static testMethod void myUnitTest2() {
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR.Primary_Contact__c = 'Father';
        objSR.Sibling_Fee_ID__c = '12345123451234';//12345
        objSR.Student_Id__c = '12345612341234';
        objSR.Lead_Reference__c = '00Q9E000001gXpO';
        objSR.Sibling_Fee_Id_Verified__c = 'Yes';
        update objSR;
        HexaBPM__Step__c step;
        for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where Id=:objSR.id]){
            step = GEMS_TestUtils.createStep(SR,'Verification Step','Awaiting Verification');
        }
        for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR__c,HexaBPM__SR__r.School__c,HexaBPM__SR__r.StudentId__c,HexaBPM__SR__r.Sibling_Fee_Id_Verified__c,HexaBPM__SR__r.Lead_Reference__c,HexaBPM__SR__r.Sibling_Fee_ID__c,HexaBPM__SR__r.Sys_GEMS_School_Sibling__c from HexaBPM__Step__c where Id=:step.Id]){
            step = stp;
        }
        GEMS_CC_Update_SR_SiblingId objInterface = new GEMS_CC_Update_SR_SiblingId();
        string result = objInterface.EvaluateCustomCode(objSR,step);
    }
    static testMethod void myUnitTest3() {
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        objSR.Primary_Contact__c = 'Father';
        objSR.Sibling_Fee_ID__c = '12345';
        objSR.Student_Id__c = '12345612341234';
        update objSR;
        HexaBPM__Step__c step;
        for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where Id=:objSR.id]){
            step = GEMS_TestUtils.createStep(SR,'Verification Step','Awaiting Verification');
        }
        for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR__c,HexaBPM__SR__r.Sibling_Fee_Id_Verified__c,HexaBPM__SR__r.StudentId__c,HexaBPM__SR__r.Lead_Reference__c,HexaBPM__SR__r.Sibling_Fee_ID__c from HexaBPM__Step__c where Id=:step.Id]){
            step = stp;
        }
        GEMS_CC_Update_SR_SiblingId objInterface = new GEMS_CC_Update_SR_SiblingId();
        string result = objInterface.EvaluateCustomCode(objSR,step);
        
        for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR__c,HexaBPM__SR__r.Sibling_Fee_Id_Verified__c,HexaBPM__SR__r.Lead_Reference__c,HexaBPM__SR__r.Sibling_Fee_ID__c from HexaBPM__Step__c where Id=:step.Id]){
            step = stp;
        }
        try{
            string Exceptionresult = objInterface.EvaluateCustomCode(objSR,step);
        }catch(Exception e){}
    }
    static testMethod void myUnitTest4() {
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR.Primary_Contact__c = 'Father';
        objSR.Sibling_Fee_ID__c = '12345';//12345
        objSR.Student_Id__c = '12345612341234';
        objSR.Lead_Reference__c = '00Q9E000001gXpO';
        objSR.Sibling_Fee_Id_Verified__c = 'Yes';
        update objSR;
        HexaBPM__Step__c step;
        for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where Id=:objSR.id]){
            step = GEMS_TestUtils.createStep(SR,'Verification Step','Awaiting Verification');
        }
        for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR__c,HexaBPM__SR__r.School__c,HexaBPM__SR__r.StudentId__c,HexaBPM__SR__r.Sibling_Fee_Id_Verified__c,HexaBPM__SR__r.Lead_Reference__c,HexaBPM__SR__r.Sibling_Fee_ID__c,HexaBPM__SR__r.Sys_GEMS_School_Sibling__c from HexaBPM__Step__c where Id=:step.Id]){
            step = stp;
        }
        GEMS_CC_Update_SR_SiblingId objInterface = new GEMS_CC_Update_SR_SiblingId();
        string result = objInterface.EvaluateCustomCode(objSR,step);
    }
    static testMethod void myUnitTest5() {
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        GEMS_TestUtils.createLeadEnquirySyncConfig();
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR.Primary_Contact__c = 'Father';
        objSR.Sibling_Fee_ID__c = '12345';//12345
        objSR.Student_Id__c = '12345612341234';
        objSR.Lead_Reference__c = '00Q9E000001gXpO';
        objSR.Sibling_Fee_Id_Verified__c = 'No';
        update objSR;
        
        HexaBPM__Service_Request__c objSR2 = objSR.clone();
        //objSR2 = GEMS_TestUtils.createSR('Enrollment');
        insert objSR2;
        
        objSR2.Primary_Contact__c = 'Father';
        objSR2.Sibling_Fee_ID__c = '12345';//12345
        objSR2.Student_Id__c = '12345612341234';
        objSR2.Lead_Reference__c = '00Q9E000001gXpO';
        objSR2.Sibling_Fee_Id_Verified__c = 'No';
        
        HexaBPM__SR_Status__c stat = new HexaBPM__SR_Status__c();
        stat.Name = 'Enrolled';
        stat.HexaBPM__Code__c = 'ENROLLED';
        insert stat;
        objSR2.HexaBPM__External_SR_Status__c = stat.Id;
        objSR2.HexaBPM__Internal_SR_Status__c = stat.Id;
        update objSR2;
        
        HexaBPM__Step__c step;
        for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where Id=:objSR.id]){
            step = GEMS_TestUtils.createStep(SR,'Verification Step','Awaiting Verification');
        }
        for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR__c,HexaBPM__SR__r.School__c,HexaBPM__SR__r.StudentId__c,HexaBPM__SR__r.Sibling_Fee_Id_Verified__c,HexaBPM__SR__r.Lead_Reference__c,HexaBPM__SR__r.Sibling_Fee_ID__c from HexaBPM__Step__c where Id=:step.Id]){
            step = stp;
        }
        GEMS_CC_Update_SR_SiblingId objInterface = new GEMS_CC_Update_SR_SiblingId();
        string result = objInterface.EvaluateCustomCode(objSR,step);
    }
}