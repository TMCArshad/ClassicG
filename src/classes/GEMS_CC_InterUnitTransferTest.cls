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
private class GEMS_CC_InterUnitTransferTest {

    static testMethod void myUnitTest() {
        school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '11111111';
		update objStudent;
		
    	string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Inter_Unit_Student_Transfer' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.student__c = objStudent.id;
        objSR.transfer_date__c = system.today().addDays(-1);
        insert objSR;
        
        string temp = objSR.id;
        
        objSR = new HexaBPM__Service_Request__c();
        List<HexaBPM__Service_Request__c> SRList = new List<HexaBPM__Service_Request__c>();
	    String srQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
	    srQueryStr += ' WHERE id=:temp ';
	    SRList = Database.query(srQueryStr);
        objSR = SRList[0];
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application','Pending Approval');
        string temp1 = objStep.id;
        
        objStep = new HexaBPM__Step__c();
        objStep = [select id,Step_Name__c,HexaBPM__SR__c,HexaBPM__Step_Status__c from HexaBPM__Step__c where id=:temp1];
        objStep.HexaBPM__SR__r = objSR;
        update objStep;
        
        GEMS_CC_InterUnitTransfer obj = new GEMS_CC_InterUnitTransfer();
        obj.EvaluateCustomCode(null,objStep);
        
        objSR.transfer_date__c = system.today().addDays(1);
        update objSR;
        obj = new GEMS_CC_InterUnitTransfer();
        obj.EvaluateCustomCode(null,objStep);
    }
}