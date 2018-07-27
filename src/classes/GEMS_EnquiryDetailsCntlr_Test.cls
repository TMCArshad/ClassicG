@isTest
private class GEMS_EnquiryDetailsCntlr_Test {
	
	@isTest static void test_method_SaveLead() {
		// Implement test code
		
		List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		
		List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5,'Enrollment');
		List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);
		
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList,users);
		List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10,schoolList[0]);
		List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0],academicYears);
		List<Section_Master__c> sections =  GEMS_ChangeTCCntlr_Test.createSectionsForGrades(grades);
		List<Amount__c> amounts = GEMS_ChangeTCCntlr_Test.createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = GEMS_ChangeTCCntlr_Test.createSiteConfig(schoolList[0]);
		GEMS_ChangeTCCntlr_Test.createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = GEMS_ChangeTCCntlr_Test.createPricingLines(prodList);
		List<Lead> LeadList = GEMS_ChangeTCCntlr_Test.createLeads(schoolList[0]);
		LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);
		
		List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
		Test.startTest(); 
		
	    	Test.setCurrentPageReference(new PageReference('Page.GEMS_EditCriticalDetailsPage')); 
            System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
            System.currentPageReference().getParameters().put('RefId', LeadList[0].Lead_Reference__c);
            GEMS_EnquiryDetailsCntlr obj = new GEMS_EnquiryDetailsCntlr();
            obj.hasSibling = false;
            GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
            obj.isValidCaptcha = true;
            obj.leadObj = LeadList[0];
            System.assertNotEquals(obj.leadObj.lastName,'');
            obj.pardotLeadId = LeadList[0].Id;
            obj.leadObj.has_sibling_in_GEMS__c = false;
            obj.leadObj.Academic_Year__c = sections[0].Academic_Year__c;
            obj.leadObj.GradeLookup__c = sections[0].grade__c;
            obj.leadObj.SchoolLookup__c = sections[0].School__c;
            obj.leadObj.Date_Of_Birth__c = System.Today().addYears(-5);
            obj.saveLead();
            /*
            obj.isValidCaptcha = false;
            obj.saveLead();*/
            
		
		Test.stopTest();
	}
	
	@isTest static void test_method_SaveLeadNegative() {
		// Implement test code
		List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		
		List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5,'Enrollment');
		List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);
		
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList,users);
		List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10,schoolList[0]);
		List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0],academicYears);
		List<Section_Master__c> sections =  GEMS_ChangeTCCntlr_Test.createSectionsForGrades(grades);
		List<Amount__c> amounts = GEMS_ChangeTCCntlr_Test.createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = GEMS_ChangeTCCntlr_Test.createSiteConfig(schoolList[0]);
		GEMS_ChangeTCCntlr_Test.createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = GEMS_ChangeTCCntlr_Test.createPricingLines(prodList);
		List<Lead> LeadList = GEMS_ChangeTCCntlr_Test.createLeads(schoolList[0]);
		LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);
		
		List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
		Test.startTest(); 
		
	    	Test.setCurrentPageReference(new PageReference('Page.GEMS_EditCriticalDetailsPage')); 
            System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
            System.currentPageReference().getParameters().put('RefId', LeadList[0].Lead_Reference__c);
            GEMS_EnquiryDetailsCntlr obj = new GEMS_EnquiryDetailsCntlr();
            obj.hasSibling = false;
            
            GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
            LeadList[0].Date_of_Birth__c = System.Today().addYears(-100);
            update LeadList[0];
            
            obj.leadObj = LeadList[0];
            obj.leadObj.has_sibling_in_GEMS__c = false;
            obj.leadObj.GradeLookup__c = sections[0].grade__c;
            obj.isValidCaptcha = true;
            obj.saveLead();
            
            
            
            GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
            LeadList[1].Date_of_Birth__c = System.Today().addyears(-5);
            update LeadList[1];
            
            obj.leadObj = LeadList[1];
            obj.leadObj.has_sibling_in_GEMS__c = false;
            obj.leadObj.GradeLookup__c = sections[0].grade__c;
            obj.isValidCaptcha = true;
            obj.saveLead();
            
            obj.getStreamsForSchool();
		    obj.resetSiblingDetails(); 
		    obj.addLead();
		    obj.cancelLead();
		    obj.preparePageFromPardotURL();
		    obj.populateTransferStudentDetails();
		    obj.showErrorMsg = true;
		    obj.ErrorMsg = 'ErrorMsg';
		Test.stopTest();
	}
		@isTest static void test_method_ProceedToPay() {
		// Implement test code
		List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		
		List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5,'Enrollment');
		List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);
		
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList,users);
		List<Academic_Year__c> academicYears = GEMS_ChangeTCCntlr_Test.createsAYs(10,schoolList[0]);
		List<Grade__c> grades = GEMS_ChangeTCCntlr_Test.createGrades(schoolList[0],academicYears);
		List<Section_Master__c> sections =  GEMS_ChangeTCCntlr_Test.createSectionsForGrades(grades);
		List<Amount__c> amounts = GEMS_ChangeTCCntlr_Test.createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = GEMS_ChangeTCCntlr_Test.createSiteConfig(schoolList[0]);
		GEMS_ChangeTCCntlr_Test.createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = GEMS_ChangeTCCntlr_Test.createPricingLines(prodList);
		List<Lead> LeadList = GEMS_ChangeTCCntlr_Test.createLeads(schoolList[0]);
		GEMS_ChangeTCCntlr_Test.createCompanyRecords(leadList);
		LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);
		
		List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
		Test.startTest(); 
		    GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
		    LeadList[0].Relation_to_student__c = 'Father';
		    update leadList[0];
		    
		    Test.setCurrentPageReference(new PageReference('Page.GEMS_EditCriticalDetailsPage')); 
            System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
            System.currentPageReference().getParameters().put('RefId', LeadList[0].Lead_Reference__c);
            GEMS_EnquiryDetailsCntlr obj = new GEMS_EnquiryDetailsCntlr();
            obj.siblingInfo = new GEMS_EnquiryDetailsCntlr_Helper.siblingInfoWrapper();
            obj.siblingInfo.siblingName = 'siblingName';
            obj.siblingInfo.siblingFeeID = 'siblingFeeID';
            obj.siblingInfo.siblingSchool = schoolList[0].Id;
            obj.siblingInfo.siblingDOB = System.Today();
            obj.hasSibling = true;
            
            obj.proceedToPay();
            
            obj.siblingInfo = new GEMS_EnquiryDetailsCntlr_Helper.siblingInfoWrapper();
            obj.siblingInfo.siblingName = 'siblingName';
            obj.siblingInfo.siblingFeeID = 'siblingFeeID';
            obj.siblingInfo.siblingSchool = schoolList[0].Id;
            obj.hasSibling = true;
            obj.leadEditFlag = false;
            obj.populateTransferStudentDetails();
            obj.clearValues();
            obj.proceedToPay();
            
		Test.stoptest();
		
		}
	
}