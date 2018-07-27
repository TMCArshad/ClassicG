/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   6th Mar 2018
    Description :   Test class for step trigger
   
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

@isTest
private class GEMS_StepTriggerTest {

    static testMethod void myUnitTest() {
        List<User> users = GEMS_TestUtils.createUsers('System Administrator');
        
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Registered');
        HexaBPM__SR_Status__c srStatus2 = GEMS_TestUtils.createSRStatus('Approved');
        HexaBPM__SR_Status__c srStatus3 = GEMS_TestUtils.createSRStatus('Rejected');
        
        HexaBPM__Status__c stepStatus1 = GEMS_TestUtils.createStepStatus('APPROVED');
        HexaBPM__Status__c stepStatus2 = GEMS_TestUtils.createStepStatus('REJECTED');
        
        list<school__c> schoolList = new list<school__c>();
        schoolList.add(objSchool);
        
        GEMS_TestUtils.createQueueConfig(schoolList);
        GEMS_TestUtils.createQueuesForSchools(schoolList, users);
        
        HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
        objSR1 = GEMS_TestUtils.createSR('Edit_Critical_Data');
        
        objSR1 = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c 
                 where id=:objSR1.id];
                 
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR1,'VERIFICATION_OF_APPLICATION','Awaiting Verification');
        
        objStep.HexaBPM__Rejection_Reason__c = 'Test';
        update objStep;
    }
}