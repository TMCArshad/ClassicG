@isTest
private class GEMS_UpdateStep_Test {
	
	

	@isTest static void test_method_one() {
		// Implement test code
		 
			// Implement test code
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10,schoolList[0]);
		List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0],academicYears);
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
        Test.setMock(WebServiceMock.class, new GEMS_FeeDetailService_Test.GEMS_FeeDetailTC_ClearanceServiceMockImpl());
        GEMS_UpdateStep.updateClearanceStatus(stepList[0].Id);
        /*
        HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(id= stepList[0].HexaBPM__SR__c);
        sr.StudentId__c = '12345678';
        update sr;
        */
        GEMS_UpdateStep.updateClearanceStatus(stepList[0].Id);
        GEMS_UpdateStep.updateClearanceStatus('errorId');
        
        GEMS_UpdateStep.acceptStep(stepList[0].Id);
        GEMS_UpdateStep.acceptStep('errorId');
        GEMS_UpdateStep.resultWrapper rw = new GEMS_UpdateStep.resultWrapper('Test',true);
        
        Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}