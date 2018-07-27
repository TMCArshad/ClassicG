@isTest
private class CC_Step_Assignment_Test {

	@isTest static void test_method_one() {
		// Implement test code
		
		
		
		List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		
		List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5,'Enrollment');
		List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);
		
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList,users);
		List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10,schoolList[0]);
		List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0],academicYears);
		List<Section_master__c> sections = GEMS_ChangeTCCntlr_Test.createSectionsForGrades(grades);
		List<Amount__c> amounts = GEMS_ChangeTCCntlr_Test.createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = GEMS_ChangeTCCntlr_Test.createSiteConfig(schoolList[0]);
		GEMS_ChangeTCCntlr_Test.createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = GEMS_ChangeTCCntlr_Test.createPricingLines(prodList);
		List<Lead> LeadList = GEMS_ChangeTCCntlr_Test.createLeads(schoolList[0]);
		LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);
		
		List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'TC_Request');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
        
        Test.startTest();
         CC_Step_Assignment obj = new CC_Step_Assignment();
         map<string, id> mapOfQueueAndId = new map<string, id>();
          for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue']) {
            mapOfQueueAndId.put(grp.DeveloperName, grp.id);
          }
        SRSteps[0].OwnerId = mapOfQueueAndId.get('Registrar');
        update SRSteps[0];
        
        stepList[0].HexaBPM__SR_Step__c = SRSteps[0].Id;
        update stepList[0];     
        
        obj.Assign_Step_Owner_SR_Submit(NULL,stepList,NULL);
        obj.Assign_Step_Owner_Step_Closure(NULL,stepList,NULL);
        
        SRSteps[0].OwnerId = mapOfQueueAndId.get('Registrar2');
        System.debug('==>'+SRSteps[0].OwnerId);
        update SRSteps[0];
        
        stepList[0].HexaBPM__SR_Step__c = SRSteps[0].Id;
        update stepList[0];
        
        obj.Assign_Step_Owner_SR_Submit(NULL,stepList,NULL);
        obj.Assign_Step_Owner_Step_Closure(NULL,stepList,NULL);
        
        SRSteps[0].OwnerId = mapOfQueueAndId.get('GEMS_Corporate_Office');
        update SRSteps[0];
        
        stepList[0].HexaBPM__SR_Step__c = SRSteps[0].Id;
        update stepList[0];
        
        obj.Assign_Step_Owner_SR_Submit(NULL,stepList,NULL);
        obj.Assign_Step_Owner_Step_Closure(NULL,stepList,NULL);
        
        SRSteps[0].OwnerId = mapOfQueueAndId.get('Parent_Relations_Officer');
        update SRSteps[0];
        
        stepList[0].HexaBPM__SR_Step__c = SRSteps[0].Id;
        update stepList[0];
        
        obj.Assign_Step_Owner_SR_Submit(NULL,stepList,NULL);
        obj.Assign_Step_Owner_Step_Closure(NULL,stepList,NULL);
        
        Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}