@IsTest
private class GEMS_siblingRelationsManagementTest {
    
    static testMethod void GEMS_siblingRelationsManagementTest0(){
    	
    	Account objStudent = GEMS_TestUtils.createAccount('Student');
    	Account objSibling = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Account objMother = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel0 = GEMS_TestUtils.createRelationship(objStudent,objParent,'Father');
    	Relationship__c objRel1 = GEMS_TestUtils.createRelationship(objStudent,objMother,'Mother');
    	Relationship__c objRel2 = GEMS_TestUtils.createRelationship(objStudent,objSibling,'Sibling');
    	objStudent.father__c = objParent.id;
    	objStudent.mother__c = objMother.id;
        objStudent.student_id__c = '1111111';
    	update objStudent;
    	
    	Account objStudent1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objSibling1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent1 = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel3 = GEMS_TestUtils.createRelationship(objStudent1,objParent1,'Father');
    	Relationship__c objRel4 = GEMS_TestUtils.createRelationship(objStudent1,objSibling1,'Sibling');
    	objStudent1.father__c = objParent1.id;
    	objStudent1.student_id__c = '2222222';
    	update objStudent1;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objStudent.school__c);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    	
    	sibCtlr.searchStudentId = '1111111';
    	
    	Id [] fixedSearchResults = new Id[]{objStudent.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
    	sibCtlr.getStudentList();
    	
    	sibCtlr.selectedStudentId = '1111111';
    	sibCtlr.searchRecord = 'Student';
    	sibCtlr.getSelectedStudentFromSearch();
    }
    
    static testMethod void GEMS_siblingRelationsManagementTest1(){
    	
    	Account objStudent = GEMS_TestUtils.createAccount('Student');
    	Account objSibling = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Account objMother = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel0 = GEMS_TestUtils.createRelationship(objStudent,objParent,'Father');
    	Relationship__c objRel1 = GEMS_TestUtils.createRelationship(objStudent,objMother,'Mother');
    	Relationship__c objRel2 = GEMS_TestUtils.createRelationship(objStudent,objSibling,'Sibling');
    	objStudent.father__c = objParent.id;
    	objStudent.mother__c = objMother.id;
        objStudent.student_id__c = '1111111';
    	update objStudent;
    	
    	Account objStudent1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objSibling1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent1 = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel3 = GEMS_TestUtils.createRelationship(objStudent1,objParent1,'Father');
    	Relationship__c objRel4 = GEMS_TestUtils.createRelationship(objStudent1,objSibling1,'Sibling');
    	objStudent1.father__c = objParent1.id;
    	objStudent1.student_id__c = '2222222';
    	update objStudent1;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objStudent.school__c);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    	
    	sibCtlr.searchSiblingId = '2222222';
    	
    	Id [] fixedSearchResults1 = new Id[]{objStudent1.Id};
        Test.setFixedSearchResults(fixedSearchResults1);
        
    	sibCtlr.getStudentList();
    	
    	sibCtlr.selectedStudentId = '2222222';
    	sibCtlr.searchRecord = 'Sibling';
    	sibCtlr.getSelectedStudentFromSearch();
    }
    
    static testMethod void GEMS_siblingRelationsManagementTest2(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    
    	sibCtlr.clearValuesFromPage();
    	sibCtlr.showPopUp();
    	sibCtlr.showSearchPopUp();
    	sibCtlr.closePopup();
    }
    
    static testMethod void GEMS_siblingRelationsManagementTest3(){
    	
    	Account objStudent = GEMS_TestUtils.createAccount('Student');
    	Account objSibling = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Account objMother = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel0 = GEMS_TestUtils.createRelationship(objStudent,objParent,'Father');
    	Relationship__c objRel1 = GEMS_TestUtils.createRelationship(objStudent,objMother,'Mother');
    	Relationship__c objRel2 = GEMS_TestUtils.createRelationship(objStudent,objSibling,'Sibling');
    	objStudent.father__c = objParent.id;
    	objStudent.mother__c = objMother.id;
        objStudent.student_id__c = '1111111';
    	update objStudent;
    	
    	Account objStudent1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objSibling1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent1 = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel3 = GEMS_TestUtils.createRelationship(objStudent1,objParent1,'Father');
    	Relationship__c objRel4 = GEMS_TestUtils.createRelationship(objStudent1,objSibling1,'Sibling');
    	objStudent1.father__c = objParent1.id;
    	objStudent1.student_id__c = '2222222';
    	update objStudent1;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objStudent.school__c);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    	
    	sibCtlr.studentRecord = objStudent;
    	sibCtlr.siblingRecord = objStudent1;
    	
    	sibCtlr.studentRelations = new list<account>();
    	sibCtlr.studentRelations.add(objSibling);
    	
    	sibCtlr.siblingRelations = new list<account>();
    	sibCtlr.siblingRelations.add(objSibling1);
    	
    	sibCtlr.linkStudents();
    }
    
    static testMethod void GEMS_siblingRelationsManagementTest4(){
    	
    	Account objStudent = GEMS_TestUtils.createAccount('Student');
    	Account objSibling = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel1 = GEMS_TestUtils.createRelationship(objStudent,objParent,'Father');
    	Relationship__c objRel2 = GEMS_TestUtils.createRelationship(objStudent,objSibling,'Sibling');
    	objStudent.father__c = objParent.id;
        objStudent.student_id__c = '1111111';
        objStudent.sibling_id__c = '1111111';
    	update objStudent;
    	
    	Account objStudent1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objSibling1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent1 = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel3 = GEMS_TestUtils.createRelationship(objStudent1,objParent1,'Father');
    	Relationship__c objRel4 = GEMS_TestUtils.createRelationship(objStudent1,objSibling1,'Sibling');
    	objStudent1.father__c = objParent1.id;
    	objStudent1.student_id__c = '2222222';
    	update objStudent1;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objStudent.school__c);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    	
    	sibCtlr.studentRecord = objStudent;
    	sibCtlr.siblingRecord = objStudent1;
    	
    	sibCtlr.studentRelations = new list<account>();
    	sibCtlr.studentRelations.add(objSibling);
    	
    	sibCtlr.siblingRelations = new list<account>();
    	sibCtlr.siblingRelations.add(objSibling1);
    	
    	sibCtlr.primaryContact = new Account();
    	sibCtlr.primaryContact.firstName = 'Test';
    	sibCtlr.primaryContact.lastName = 'Test';
    	sibCtlr.createParentAndDelink();
    }
    
    static testMethod void GEMS_siblingRelationsManagementTest5(){
    	
    	Account objStudent = GEMS_TestUtils.createAccount('Student');
    	Account objSibling = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel1 = GEMS_TestUtils.createRelationship(objStudent,objParent,'Father');
    	Relationship__c objRel2 = GEMS_TestUtils.createRelationship(objStudent,objSibling,'Sibling');
    	objStudent.father__c = objParent.id;
        objStudent.student_id__c = '1111111';
    	update objStudent;
    	
    	Account objStudent1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objSibling1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent1 = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel3 = GEMS_TestUtils.createRelationship(objStudent1,objParent1,'Father');
    	Relationship__c objRel4 = GEMS_TestUtils.createRelationship(objStudent1,objSibling1,'Sibling');
    	objStudent1.father__c = objParent1.id;
    	objStudent1.student_id__c = '2222222';
    	update objStudent1;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objStudent.school__c);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    	
    	sibCtlr.studentRecord = objStudent;
    	sibCtlr.siblingRecord = objStudent1;
    	
    	sibCtlr.studentRelations = new list<account>();
    	sibCtlr.studentRelations.add(objSibling);
    	
    	sibCtlr.siblingRelations = new list<account>();
    	sibCtlr.siblingRelations.add(objSibling1);
    	
    	sibCtlr.activateOldRelationAndDelink();
    }
    
    static testMethod void GEMS_siblingRelationsManagementTest6(){
    	
    	Account objStudent = GEMS_TestUtils.createAccount('Student');
    	Account objSibling = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel1 = GEMS_TestUtils.createRelationship(objStudent,objParent,'Father');
    	Relationship__c objRel2 = GEMS_TestUtils.createRelationship(objStudent,objSibling,'Sibling');
    	objStudent.father__c = objParent.id;
        objStudent.student_id__c = '1111111';
    	update objStudent;
    	
    	Account objStudent1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objSibling1 = GEMS_TestUtils.createStudentAccount('Student');
    	Account objParent1 = GEMS_TestUtils.createStudentAccount('Parent_Guardian');
    	Relationship__c objRel3 = GEMS_TestUtils.createRelationship(objStudent1,objParent1,'Father');
    	Relationship__c objRel4 = GEMS_TestUtils.createRelationship(objStudent1,objSibling1,'Sibling');
    	objStudent1.father__c = objParent1.id;
    	objStudent1.student_id__c = '2222222';
    	update objStudent1;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_siblingRelationsManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objStudent.school__c);
    	GEMS_siblingRelationsManagementCtlr sibCtlr = new GEMS_siblingRelationsManagementCtlr(); 
    	
    	sibCtlr.studentRecord = objStudent;
    	sibCtlr.siblingRecord = objStudent1;
    	 
    	sibCtlr.studentRelations = new list<account>();
    	sibCtlr.studentRelations.add(objSibling);
    	
    	sibCtlr.siblingRelations = new list<account>();
    	sibCtlr.siblingRelations.add(objSibling1);
    	
    	sibCtlr.delinkIndividual();
    }
}