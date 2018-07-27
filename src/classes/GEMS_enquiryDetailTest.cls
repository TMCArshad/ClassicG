@isTest
private class GEMS_enquiryDetailTest {
    static testmethod void GEMS_enquiryDetailTest1(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
    	GEMS_Queue_Config__c objConfig = GEMS_TestUtils.createQueueConfig(objSchool);
    	Group objQueue = GEMS_TestUtils.createQueue(objSchool);
    	objQueue = [select id,name, developerName from Group where id=:objQueue.id];
    	
    	GEMS_TestUtils.createLeadEnquirySyncConfig();
    	Enquiry__c objEnq = GEMS_TestUtils.createEnquiry(objSchool, objAy, objGrade);
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(objEnq);
        GEMS_enquiryDetailCtlr casePage = new GEMS_enquiryDetailCtlr(sc); 
    	
    }
    
    static testmethod void GEMS_enquiryDetailTest2(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Lead__c,Enquiry__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
        school__c objSchool = [select id from school__c where id=:objSR.school__c limit 1];
        academic_year__c objAy = [select id,curriculum__c from academic_year__c where id=:objSR.academic_year__c limit 1];
        grade__c objGrade = [select id,stream__c from grade__c where id=:objSR.gradeLookup__c limit 1];
        
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
         
        HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
        objSR1.recordTypeId = recordTypeId;
        objSR1.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR1.HexaBPM__External_SR_Status__c = srStatus.id;

        objSR1.school__c = objSR.school__c;
        objSR1.academic_year__c = objSR.academic_year__c;
        objSR1.gradeLookup__c = objSR.gradeLookup__c;
        objSR1.curriculum__c = objSR.curriculum__c;
        objSR1.stream__c = objSR.stream__c;
        
    	objSR1.lead__c = GEMS_TestUtils.createLead(objSchool,objAy,objGrade).id;
    	objSR1.first_name__c = 'Test';
    	objSR1.last_name__c = 'Test';
    	objSR1.First_Name_Father__c = 'Test';
    	objSR1.Last_Name_Father__c = 'Test';
    	objSR1.First_Name_Mother__c = 'Test';
    	objSR1.Last_Name_Mother__c = 'Test';
    	objSR1.First_Name_Guardian__c = 'Test';
    	objSR1.Last_Name_Guardian__c = 'Test';
    	objSR1.Date_Of_Birth__c = system.today().addYears(-7);
    	objSR1.gender__c = 'Male';
    	objSR1.Passport_No__c = '11111';
    	
    	system.debug('----objSR1.lead__c---'+objSR1.lead__c);
    	if(objSR1.lead__c!=null){
    		list<enquiry__c> objEnq = [select id from enquiry__c where lead__c =: objSR1.lead__c];
    		if(objEnq!=null && objEnq.size()>0){
    			objSR1.enquiry__c = objEnq[0].id;	
    		}
    	}
        objSR1.HexaBPM__SR_Template__c = objSR.HexaBPM__SR_Template__c;
        insert objSR1;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(objSR);
        GEMS_enquiryDetailCtlr casePage = new GEMS_enquiryDetailCtlr(sc); 
    	
    }
}