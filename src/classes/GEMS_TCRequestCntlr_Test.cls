@isTest
private class GEMS_TCRequestCntlr_Test {
	public static void createPromotionsForStudents(List<Account> students){
     Promotion__c prom ;
     List<Promotion__c> promList =  new List<Promotion__c>();
     for(Account accObj :  students){

     	  prom = new Promotion__c();
     	  prom.Student__c = accObj.Id;
     	  prom.Active__c = true;
     	  promList.add(prom);

     }
      insert promList;

	}
	@isTest static void test_method_one() {
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
		createPromotionsForStudents(students);
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
		Test.startTest(); 
		     
		      Test.setCurrentPageReference(new PageReference('Page.TCRequestPage')); 
              System.currentPageReference().getParameters().put('BSU', GEMS_Utility.getEnctryptedURLparam(schoolList[0].ID__c));
              System.currentPageReference().getParameters().put('StudentID', GEMS_Utility.getEnctryptedURLparam(students[0].Student_Id__c));
		      GEMS_TCRequestCntlr obj = NEW GEMS_TCRequestCntlr();
		      obj.init();
		     
		      
		      //getTCOptions
		      obj.getTCOptions();
		      
		      //getFeedbackOptions
		      obj.getFeedbackOptions();
		      
		      //getStudentDetails
		      obj.getStudentDetails();
		      
		      //getAcademicYear
		      GEMS_TCRequestCntlr.getAcademicYear(academicYears[0].Id);
		      
		      //validateAcademicYearRange
		      GEMS_TCRequestCntlr.validateAcademicYearRange(System.today(),academicYears[0]);
		      
		      //getOpenSRs
		      obj.getOpenSRs();
		      
		      //setPrimaryContactDetails
		      students[0].Primary_Contact__c = 'Father';
		      students[0].Father__c = students[1].Id;
		      update students[0];
		      obj.setPrimaryContactDetails(students[0]);
		      
		      students[1].Primary_Contact__c = 'Mother';
		      students[1].Mother__c = students[0].Id;
		      update students[1];
		      obj.setPrimaryContactDetails(students[1]);
		      
		      //
		      Academic_Year__c ay = new Academic_Year__c();
		      ay.Start_Date__c = System.today().addDays(-10);
		      ay.End_date__c = System.today().addDays(-2);
		      ay.School__c = schoolList[0].id;
		      insert ay;
		      GEMS_TCRequestCntlr.validateAcademicYearRange(System.today(),ay);
		      
		      ay.Start_Date__c = System.today().addDays(10);
		      ay.End_date__c = System.today().addDays(12);
		      update ay;
		       GEMS_TCRequestCntlr.validateAcademicYearRange(System.today(),ay);
		      
		      ay.Start_Date__c = System.today();
		      ay.End_date__c = System.today().addDays(12);
		      update ay;
		      GEMS_TCRequestCntlr.validateAcademicYearRange(System.today(),ay);
		      //
		      
		Test.stopTest();
	}
	
	@isTest static void test_method_submitTCRequest() {
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
		createPromotionsForStudents(students);
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
		Test.startTest(); 
		
		      Test.setMock(WebServiceMock.class, new GEMS_FeeDetailService_Test.GEMS_FeeDetailStudentFee_OutstandingServiceMockImpl1());
		      Test.setCurrentPageReference(new PageReference('Page.TCRequestPage')); 
              System.currentPageReference().getParameters().put('BSU', GEMS_Utility.getEnctryptedURLparam(schoolList[0].ID__c));
              System.currentPageReference().getParameters().put('StudentID', GEMS_Utility.getEnctryptedURLparam(students[0].Student_Id__c));
		      GEMS_TCRequestCntlr obj = NEW GEMS_TCRequestCntlr();
		      obj.TCOptionsSelected = '';
		      obj.savedRequest = false;
		      
		      
		      obj.init();
		      obj.submitTCRequest();
		Test.stopTest();      
	}
	
}