@isTest
private class GEMS_PaymentCntlr_Test {

    public static Page_Flow__c createPageFlow(String rtName){
             Page_Flow__c pf = new Page_Flow__c();
             pf.Name = rtName + '_Name';
             pf.Record_Type_API_Name__c = rtName;
             pf.Master_Page__c = 'Process_Flow';
             pf.Master_Object__c = 'HexaBPM__Service_Request__c';
             insert pf;
             return pf;
    }

    public static Page__c createPage(Page_Flow__c pf,String pageName){
          Page__c page =  new Page__c();
          page.Page_Flow__c = pf.Id;
          page.Page_Order__c = 10;
          page.Name = pageName;
          page.VF_Page_API_Name__c = 'Process_Flow';
          page.What_Id__c = 'HexaBPM__Service_Request__c';
          insert page;
          return page;

    }
    
    
   
	@isTest static void test_method_one() {
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
	//	LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);
		
		List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
		
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        for(HexaBPM__Service_Request__c srObj : SR_List ){
            System.debug('RefId==>'+srObj.Lead_Reference__c);
        }
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
        
		Page_Flow__c pf = createPageFlow('Enrollment');
        Page__c cf = createPage(pf,'Complete File');
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.GEMS_PaymentPage')); 
        System.currentPageReference().getParameters().put('BSU', schoolList[0].ID__c);
        System.currentPageReference().getParameters().put('RefId', LeadList[0].Lead_Reference__c);
        GEMS_PaymentCntlr obj = new GEMS_PaymentCntlr();
        
        obj.init();
        
        if(obj.paymentWrappers!=null && obj.paymentWrappers.size()>0){
	        obj.paymentWrappers[0].isSelected = true;    
	        obj.calculateTotalPrice();
        }
        
	    if(obj.paymentWrappers!=null && obj.paymentWrappers.size()>0){
	        obj.payNow();
        }
        obj.payLater();
        obj.leadReferenceNumberEncrypted = 'leadReferenceNumberEncrypted';
        obj.lstSR = SR_List;
        obj.payLaterFlag = true; 
        obj.goToEnquiryDetailsPage();
        
        GEMS_PaymentCntlr_Helper helperObj = new GEMS_PaymentCntlr_Helper();
        Test.stopTest();
		
	}
	
	
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}