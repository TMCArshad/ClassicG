@IsTest
private class GEMS_BudgetMasterTest {
    
    static testMethod void GEMS_BudgetMasterTest() {
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	Capacity_Master__c objBudget = new Capacity_Master__c();
    	objBudget.Academic_Year__c = objAY.id; 
    	objBudget.Curriculum__c = objAY.curriculum__c;
    	objBudget.School__c = objSchool.id;
    	objBudget.Capacity__c = 100;
    	objBudget.Grade__c = objGrade.id;
    	
    	insert objBudget;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_budgetMaster'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.Id);
    	GEMS_BudgetMasterCtlr budgetCtlr = new GEMS_BudgetMasterCtlr();  
    	
    	
    	system.debug('---objBudget---'+objBudget);
    	budgetCtlr.saveCapacity();
    }
}