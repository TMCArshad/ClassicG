@isTest
private class GEMS_EnquiryRelationshipTest {
	static testMethod void GEMS_EnquiryRelationshipTest(){
		school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
        lead objLead1 = GEMS_TestUtils.createLead(objSchool,objAy,objGrade);	
        
        lead objLead2 = GEMS_TestUtils.createLead(objSchool,objAy,objGrade);
        
        EnquiryRelationship__c obj = new EnquiryRelationship__c();
        obj.Lead__c	= objLead1.id;
        obj.Sibling_Lead__c = objLead2.id;
        insert obj;
	}
}