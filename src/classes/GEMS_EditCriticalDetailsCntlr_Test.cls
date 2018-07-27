@isTest
private class GEMS_EditCriticalDetailsCntlr_Test {
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
	     	Test.setCurrentPageReference(new PageReference('Page.GEMS_EditCriticalDetailsPage')); 
            System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
		    GEMS_EditCriticalDetailsCntlR obj = NEW GEMS_EditCriticalDetailsCntlr();
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    obj.getAllStudents();
		    
		   
		    
		    obj.clearSearch();
		    Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = students[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
		    obj.searchStudentValue = students[0].Student_Id__c;
		     
		    obj.searchStudents();
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedToGrade = sections[0].Grade__c;
		    obj.selectedToStream = sections[0].Stream__c;
		    obj.selectedToSection = sections[0].Id;
		    
		    
		    obj.getStreamsForSchool();
		    obj.getToStreamsForSchool();
		    obj.getCurriculumsForSchool();
		    obj.getToCurriculumsForSchool();
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.validatedateOfJoining(System.Today());
		    GEMS_EditCriticalDetailsCntlR.formatDate(System.Today());
		    GEMS_EditCriticalDetailsCntlR.SubmitSrs(SR_List);
		    obj.validateAcademicyear(); 
		    
		    
		    
		    
		    
		Test.stopTest();
	}
	
	@isTest static void test_method_requestChange() {
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
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Edit_Critical_Data');
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
		Test.startTest(); 
	     	Test.setCurrentPageReference(new PageReference('Page.GEMS_EditCriticalDetailsPage')); 
            System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
		    GEMS_EditCriticalDetailsCntlR obj = NEW GEMS_EditCriticalDetailsCntlr();
		    
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedToGrade = sections[0].Grade__c;
		    obj.selectedToStream = sections[0].Stream__c;
		    obj.selectedToSection = sections[0].Id;
		    obj.requestChange();
		    
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedToGrade = sections[0].Grade__c;
		    obj.selectedToStream = sections[0].Stream__c;
		    obj.selectedToSection = sections[1].Id;
		    obj.requestChange();
		    
		    
		    
		    obj.selectedToAcademicYear = '';
		    obj.selectedToGrade = sections[0].Grade__c;
		    obj.selectedToStream = sections[0].Stream__c;
		    obj.selectedToSection = sections[1].Id;
		    obj.requestChange();
		    
		   
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedToGrade = '';
		    obj.selectedToStream = sections[0].Stream__c;
		    obj.selectedToSection = sections[1].Id;
		    obj.requestChange();
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedToGrade = sections[0].Grade__c;
		    obj.selectedToStream = sections[0].Stream__c;
		    obj.selectedToSection = Sections[0].Id;
		    obj.requestChange();
		    
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    
		    GEMS_EditCriticalDetailsCntlR obj1 = NEW GEMS_EditCriticalDetailsCntlr();
		    obj1.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj1.selectedToGrade = sections[0].Grade__c;
		    obj1.selectedToStream = sections[0].Stream__c;
		    obj1.selectedToSection = sections[1].Id;
		    obj1.objSR = SR_List[1];
		    obj1.objSr.Comments__c = NULL;
		    obj1.requestChange();
		    
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    
		    obj.selectedToAcademicYear = sections[1].Academic_Year__c;
		    obj.selectedToGrade = sections[1].Grade__c;
		    obj.selectedToStream = sections[1].Stream__c;
		    obj.selectedToSection = sections[1].Id;
		    obj.objSR = SR_List[0];
		    obj.objSr.Comments__c = 'Comments';
		    obj.objSr.Joining_date__c = NULL;
		    obj.requestChange();
		    
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    
		    obj.selectedToAcademicYear = sections[1].Academic_Year__c;
		    obj.selectedToGrade = sections[1].Grade__c;
		    obj.selectedToStream = sections[1].Stream__c;
		    obj.selectedToSection = sections[1].Id;
		    obj.objSR = SR_List[0];
		    obj.objSr.Joining_date__c = System.Today();
		    obj.requestChange();
		    
		   
		    
		    
		test.stopTest();    
	}
	
	@isTest static void test_method_requestChangePositive() {
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
	     	Test.setCurrentPageReference(new PageReference('Page.GEMS_EditCriticalDetailsPage')); 
            System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
		    GEMS_EditCriticalDetailsCntlR obj = NEW GEMS_EditCriticalDetailsCntlr();
		    sections[1].school__c = schoolList[0].Id;
		    sections[0].school__c = schoolList[0].Id;
		    update sections;
		    
		    obj.selectedFromAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedFromGrade = sections[0].Grade__c;
		    obj.selectedFromStream = sections[0].Stream__c;
		    obj.selectedFromSection = sections[0].Id;
		    
		    obj.selectedToAcademicYear = sections[0].Academic_Year__c;
		    obj.selectedToGrade = sections[1].Grade__c;
		    obj.selectedToStream = sections[1].Stream__c;
		    obj.selectedToSection = sections[1].Id;
		    obj.objSR = SR_List[0];
		    obj.objSr.Comments__c = 'Comments';
		    obj.getAllStudents();
		    System.debug('obj.studentWrapperList=>'+obj.studentWrapperList);
		    for(GEMS_EditCriticalDetailsCntlr.studentWrapper wrp :  obj.studentWrapperList){
		        wrp.isSelected = true;
		    }
		    obj.requestChange();
		Test.stopTest();    
	}
	
}