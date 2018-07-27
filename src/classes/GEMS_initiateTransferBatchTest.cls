@isTest
private class GEMS_initiateTransferBatchTest {
    static testMethod void GEMS_initiateTransferBatchTest(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Approved');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	
    	account Father = GEMS_TestUtils.createAccount('Parent_Guardian');
        Father.role__c = 'Father';
        update Father;
        
        account Mother = GEMS_TestUtils.createAccount('Parent_Guardian');
        Mother.role__c = 'Mother';
        update Mother;
        
        account guardian = GEMS_TestUtils.createAccount('Parent_Guardian');
        Guardian.role__c = 'Guardian';
        update Guardian;
        
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.Current_Status__c = 'EN';
    	objStudent.father__c = Father.id;
        objStudent.mother__c = Mother.id;
        objStudent.guardian_1__c = guardian.id;
    	update objStudent;
    	
    	relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Father, 'Father');
        relationship__c r2 = GEMS_TestUtils.createRelationship(objStudent, Mother, 'Mother');
        relationship__c r3 = GEMS_TestUtils.createRelationship(objStudent, Guardian, 'Guardian');
        
    	objSR = GEMS_TestUtils.createSR('Inter_Unit_Student_Transfer');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c,Transfer_date__c, HexaBPM__External_SR_Status__c,HexaBPM__Customer__c,
    					HexaBPM__Record_Type_Name__c,Academic_Year__c, gradeLookup__c,School__c,HexaBPM__Customer__r.Current_Status__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.HexaBPM__Customer__c = objStudent.id;
        objSR.Transfer_date__c = system.today();
        update objSR;
        
        GEMS_initiateTransferBatch batchJob = new GEMS_initiateTransferBatch() ;
        Database.executeBatch(batchJob,1);
    }
    
    
    static testMethod void GEMS_initiateTransferBatchTest1(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Approved');
    	HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('SUBMITTED');
    	HexaBPM__SR_Status__c srStatus2 = GEMS_TestUtils.createSRStatus('APPLICATION TRANSFERRED');
    	HexaBPM__SR_Status__c srStatus3 = GEMS_TestUtils.createSRStatus('CLOSED');
    	HexaBPM__Status__c StepStatus = GEMS_TestUtils.createStepStatus('TRANSFERRED');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	
        
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.Current_Status__c = 'EN';
    	update objStudent;
    	
      	objSR = GEMS_TestUtils.createSR('Enrollment');  
      	HexaBPM__Step__c objStep = new HexaBPM__Step__c();
      	
      	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
    					HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
				 
        objStep = GEMS_TestUtils.createStep(objSR,'Verification','Awaiting Verification');
    	
    	HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
		objDocMaster.Name = 'Offer Letter PDF';
		objDocMaster.HexaBPM__Code__c='Offer Letter PDF';
		objDocMaster.HexaBPM__Document_Index__c='Offer Letter PDF';
		insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Document_Master__c = objDocMaster.id;
        objSRDoc.HexaBPM__Service_Request__c = objSR.id;
        objSRDoc.HexaBPM__SR_Template_Doc__c = objTempDocs.id;
        objSRDoc.HexaBPM__Status__c = 'Uploaded';
        insert objSRDoc;
        
        attachment attach = new attachment();
        attach.Body=Blob.valueOf('Unit Test Attachment Body');
        attach.name = 'Father';
        attach.parentID = objSRDoc.id;
        insert attach;
        
        objSRDoc.HexaBPM__Doc_ID__c = attach.id;
        update objSRDoc;
        
        list<HexaBPM__Service_Request__c> listSR = new list<HexaBPM__Service_Request__c>();
    	HexaBPM__Service_Request__c objSRClone = new HexaBPM__Service_Request__c();
    	objSRClone = objSR.clone();
		listSR.add(objSRClone);
		
        GEMS_interUnitStudentTransferBatch batchJob1 = new GEMS_interUnitStudentTransferBatch(listSR,'Application Transferred','Enrollment') ;
        Database.executeBatch(batchJob1,1);
    }
    
    static testMethod void GEMS_initiateTransferBatchTest2(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Approved');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	
        
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.Current_Status__c = 'EN';
    	update objStudent;
    	
        
        school__c objSchoolTransfer = GEMS_TestUtils.createSchool();
    	academic_year__c objAYTransfer = GEMS_TestUtils.createAcademicYear(objSchoolTransfer);
    	grade__c objGradeTransfer = GEMS_TestUtils.createGrade(objSchoolTransfer,objAYTransfer);
    	Section_Master__c objSecTransfer = GEMS_TestUtils.createSection(objSchoolTransfer,objAYTransfer,objGradeTransfer);
    	
    	
    	string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Re_Enrolment');
        list<HexaBPM__Service_Request__c> listSR = new list<HexaBPM__Service_Request__c>();
    	objSR = new HexaBPM__Service_Request__c();
		objSR.HexaBPM__Customer__c = objStudent.id;
		objSR.School__c = objSchoolTransfer.id;
		objSR.Academic_Year__c = objAYTransfer.id;
		objSR.Stream__c = objGradeTransfer.stream__c;	
		objSR.GradeLookup__c = objGradeTransfer.id;
		objSR.Section_Lookup__c = objSecTransfer.id;
		objSR.Transfer_date__c = system.today();
		objSR.recordTypeId = recTypeID;
		objSR.gender__c = 'Female';
		objSR.payment_status__c = 'No Payment';
		listSR.add(objSR);
		
        GEMS_interUnitStudentTransferBatch batchJob1 = new GEMS_interUnitStudentTransferBatch(listSR,'','Re_Enrolment') ;
        Database.executeBatch(batchJob1,1);
    }
}