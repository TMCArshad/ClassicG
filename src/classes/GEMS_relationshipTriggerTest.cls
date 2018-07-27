@isTest
private class GEMS_relationshipTriggerTest {
	static testMethod void GEMS_relationshipTriggerTest1(){
		string parentRecordTypeId = '';
		string studentRecordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
            if(rectyp.DeveloperName == 'Parent_Guardian')
            	parentRecordTypeId = rectyp.Id;
            else if(rectyp.DeveloperName == 'Student')
            	studentRecordTypeId = rectyp.Id;
        }
		
		Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
		objStudent.primary_contact__c = 'Father';
		objStudent.recordTypeid = studentRecordTypeId;
		update objStudent;
		
		account Father = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Father.recordTypeid = parentRecordTypeId;
	    update Father;
	    
        relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Father, 'Father');
	}
	
	static testMethod void GEMS_relationshipTriggerTest2(){
		string parentRecordTypeId = '';
		string studentRecordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
            if(rectyp.DeveloperName == 'Parent_Guardian')
            	parentRecordTypeId = rectyp.Id;
            else if(rectyp.DeveloperName == 'Student')
            	studentRecordTypeId = rectyp.Id;
        }
		
		Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
		objStudent.primary_contact__c = 'Guardian';
		objStudent.recordTypeid = studentRecordTypeId;
		update objStudent;
		
		account Guardian = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian.recordTypeid = parentRecordTypeId;
	    update Guardian;
	    
        relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Guardian, 'Guardian');
	}
	
	static testMethod void GEMS_relationshipTriggerTest3(){
		string parentRecordTypeId = '';
		string studentRecordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
            if(rectyp.DeveloperName == 'Parent_Guardian')
            	parentRecordTypeId = rectyp.Id;
            else if(rectyp.DeveloperName == 'Student')
            	studentRecordTypeId = rectyp.Id;
        }
		
		Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
		objStudent.primary_contact__c = 'Guardian';
		objStudent.recordTypeid = studentRecordTypeId;
		update objStudent;
		
		account Guardian = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian.recordTypeid = parentRecordTypeId;
	    update Guardian;
	    
		account Guardian2 = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian2.recordTypeid = parentRecordTypeId;
	    update Guardian2;
	    
	    objStudent.guardian_1__c = Guardian2.id;
		update objStudent;
	    
        relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Guardian, 'Guardian');
	}
	
	static testMethod void GEMS_relationshipTriggerTest4(){
		string parentRecordTypeId = '';
		string studentRecordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
            if(rectyp.DeveloperName == 'Parent_Guardian')
            	parentRecordTypeId = rectyp.Id;
            else if(rectyp.DeveloperName == 'Student')
            	studentRecordTypeId = rectyp.Id;
        }
		
		Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
		objStudent.primary_contact__c = 'Guardian';
		objStudent.recordTypeid = studentRecordTypeId;
		update objStudent;
		
		account Guardian = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian.recordTypeid = parentRecordTypeId;
	    update Guardian;
	    
		account Guardian2 = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian2.recordTypeid = parentRecordTypeId;
	    update Guardian2;
	    
	    objStudent.guardian_2__c = Guardian2.id;
		update objStudent;
	    
        relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Guardian, 'Guardian');
	}
	
	static testMethod void GEMS_relationshipTriggerTest5(){
		string parentRecordTypeId = '';
		string studentRecordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
            if(rectyp.DeveloperName == 'Parent_Guardian')
            	parentRecordTypeId = rectyp.Id;
            else if(rectyp.DeveloperName == 'Student')
            	studentRecordTypeId = rectyp.Id;
        }
		
		Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
		objStudent.primary_contact__c = 'Guardian';
		objStudent.recordTypeid = studentRecordTypeId;
		update objStudent;
		
		account Guardian = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian.recordTypeid = parentRecordTypeId;
	    update Guardian;
	    
		account Guardian2 = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian2.recordTypeid = parentRecordTypeId;
	    update Guardian2;
	    
	    account Guardian3 = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Guardian3.recordTypeid = parentRecordTypeId;
	    update Guardian3;
	    
	    objStudent.guardian_2__c = Guardian2.id;
	    objStudent.guardian_1__c = Guardian3.id;
		update objStudent;
	    
        relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Guardian, 'Guardian');
	}
	
	static testMethod void GEMS_relationshipTriggerTest6(){
		string parentRecordTypeId = '';
		string studentRecordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
            if(rectyp.DeveloperName == 'Parent_Guardian')
            	parentRecordTypeId = rectyp.Id;
            else if(rectyp.DeveloperName == 'Student')
            	studentRecordTypeId = rectyp.Id;
        }
		
		Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
		objStudent.primary_contact__c = 'Mother';
		objStudent.recordTypeid = studentRecordTypeId;
		update objStudent;
		
		account Mother = GEMS_TestUtils.createAccount('Parent_Guardian');
	    Mother.recordTypeid = parentRecordTypeId;
	    update Mother;
	    
        relationship__c r1 = GEMS_TestUtils.createRelationship(objStudent, Mother, 'Mother');
	}
	
	
}