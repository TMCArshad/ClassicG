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
private class GEMS_SRManageTest {
    static testMethod void GEMS_SRManageTest1() {
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	GEMS_SRManageCtlr.checkValidations(objSR.id);
    	
    	HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Cancelled');
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus1.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus1.id;
        update objSR;
        
    	GEMS_SRManageCtlr.checkValidations(objSR.id);
    	
    	HexaBPM__SR_Status__c srStatus2 = GEMS_TestUtils.createSRStatus('Enrolled');
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus2.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus2.id;
        update objSR;
        
    	GEMS_SRManageCtlr.checkValidations(objSR.id);
    	
    }
    
    static testMethod void GEMS_SRManageTest2() {
    	system.debug('---fromhere----');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.Reason_for_cancellation__c = 'Duplicate';
    	update objSR;
    	
    	HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Cancelled');
    	srStatus1.HexaBPM__Type__c = 'End';
    	update srStatus1;
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
    	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification','Awaiting Verification');
    	
    	Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('REGISTRATION', 'REGISTRATION', objSR.id);
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_SRManage'));
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	
    	ApexPages.StandardController scontroller = new ApexPages.standardController(objSR);
    	
    	GEMS_SRManageCtlr objCtrl = new GEMS_SRManageCtlr(scontroller);
    	objCtrl.cancelSR();
    	
    	GEMS_SRManageCtlr.reOpenSR(objSR.id);
    }
    
    static testMethod void GEMS_SRManageTest3() {
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.Reason_for_cancellation__c = 'Other';
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_SRManage'));
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	
    	ApexPages.StandardController scontroller = new ApexPages.standardController(objSR);
    	
    	GEMS_SRManageCtlr objCtrl = new GEMS_SRManageCtlr(scontroller);
    	objCtrl.cancelSR();
    }
    
     static testMethod void GEMS_SRManageTest4() {
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_SRManage'));
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	
    	ApexPages.StandardController scontroller = new ApexPages.standardController(objSR);
    	
    	GEMS_SRManageCtlr objCtrl = new GEMS_SRManageCtlr(scontroller);
    	objCtrl.cancelSR();
    }
    
    static testMethod void GEMS_SRManageTest5() {
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	GEMS_SRManageCtlr.reOpenSR(objSR.id);
    }
    
}