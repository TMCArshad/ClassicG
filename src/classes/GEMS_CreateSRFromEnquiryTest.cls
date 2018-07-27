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
private class GEMS_CreateSRFromEnquiryTest {

    static testMethod void GEMS_CreateSRFromEnquiryTest() {
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	objQueue = [select id,name, developerName from Group where id=:objQueue.id];
    	
    	GEMS_TestUtils.createLeadEnquirySyncConfig();
    	Enquiry__c objEnq = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
        objEnq.Relation_to_student__c = 'Father';
        update objEnq;
        
        GEMS_CreateSRFromEnquiry.createSRFromEnquiry(objEnq.id);
        
        Enquiry__c objEnq2 = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
        objEnq2.Relation_to_student__c = 'Mother';
        update objEnq2;
        
        GEMS_CreateSRFromEnquiry.createSRFromEnquiry(objEnq2.id);
        
        Enquiry__c objEnq3 = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
        objEnq3.Relation_to_student__c = 'Guardian';
        update objEnq3;
        
        GEMS_CreateSRFromEnquiry.createSRFromEnquiry(objEnq3.id);
        
    }
}