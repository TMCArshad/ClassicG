@isTest
private class DocumentUploadCls_Test {
	 public static  List<Page_Flow__c>  createPageFlow(String RTApiName, String MasterObj, String PFName, Integer count) {
    List<Page_Flow__c> PF_List = new List<Page_Flow__c>();
    try {
      Page_Flow__c pf;
      for (Integer i = 0; i < count; i++) {
        pf = new Page_Flow__c();
        pf.Name = (PFName != '' && PFName != NULL)  ? PFName + i : 'New Page FLow' + i;
        pf.Flow_Description__c   = pf.Name + '_Description';
        pf.Master_Object__c  = MasterObj;
        pf.Record_Type_API_Name__c   = RTApiName;
        pf.Requirements__c = 'Requirements_' + i;
        PF_List.add(pf);
      }
      insert PF_List;
    } catch (Exception e) {
      System.debug('==>Error occured when creating Page FLow Records<==');


    }
    return PF_List;

  }
  
  public static List<Page__c> createPageRecords(List<Page_Flow__c> pageFlow_List) {
    List<Page__c> Page_List = new List<Page__c>();

    try {
      //For every flow
      for (Integer i = 0 ; i < pageFlow_List.Size(); i++) {
        Page__c page;
        //Create 5 Pages
        for (Integer j = 0; j < 5; j++) {
          page = new Page__c();
          page.No_Quick_navigation__c = true;
          page.Is_Custom_Component__c = true;
          page.Migration_Rec_Id__c  = '';
          page.Page_Description__c = 'PRE-APPROVAL FOR VISA SERVICES';
          page.Page_Flow__c = pageFlow_List[j].id;
          page.Page_Order__c = j++;
          page.Page_Title__c = 'Package';
          page.Render_By_Default__c = true;
          page.VF_Page_API_Name__c = 'Process_Flow';
          page.What_Id__c = '';
          Page_List.add(page);
        }


      }
      insert Page_List;
    } catch (Exception e) {
      System.debug('==>Error occured when creating Pages<==');
    }
    return Page_List;
  }

  public static List<Section__c> createSectionRecords(List<Page__c> Page_List) {
    List<Section__c> section_List =  new List<Section__c>();
    try {
      for (Integer i = 0; i < Page_List.Size(); i++) {
        Section__c objSec ;
        for (Integer j = 0; j < 5; j++) {
          objSec  = new Section__c();
          objSec.Page__c = Page_List[i].Id;
          objSec.Name = 'Page_' + i + '_Section_' + j;
          objSec.Default_Rendering__c = true;
          objSec.Layout__c = '1';
          objSec.Section_Description__c = i + '_Description_' + j;
          objSec.Order__c = j++;
          objSec.Section_Title__c = i + '_Section title_' + j;
          if (j == 0) {
            objSec.Section_Type__c = 'PageblockSection';
          }
          if (j == 1) {
            objSec.Section_Type__c = 'CommandButtonSection';
          } else {
            objSec.Section_Type__c = 'PageblockSection';
          }

          section_List.add(objSec);

        }
      }
      insert section_List;
    } catch (Exception e) {
      System.debug('==>Error occured when creating Section Records<==');
    }
    return section_List;
  }

  public static List<Section_Detail__c> createSectionDetailRecords(List<Section__c> section_List) {
    List<Section_Detail__c> sectionDetail_List = new List<Section_Detail__c>();
    try {
      for (Integer i = 0; i < section_List.Size() ; i++) {
        Section_Detail__c objSecDet ;
        for (Integer j = 0; j < 5; j++) {
        objSecDet = new Section_Detail__c();
          objSecDet.Section__c = section_List[i].Id;
          objSecDet.Order__c = 1;
          if (section_List[i].Section_Type__c == 'PageblockSection') {
            objSecDet.Component_Type__c = 'Input Field';
            objSecDet.Object_Name__c = 'HexaBPM__Service_Request__c';
            objSecDet.Field_API_Name__c = 'Apartment_No__c';
            objSecDet.Field_Description__c = 'Description';
          } else {
            objSecDet.Component_Type__c = 'Command Button';
            objSecDet.Navigation_Directions__c = 'Forward';
            objSecDet.Button_Location__c = 'Top';
            objSecDet.Button_Position__c = 'Left';

          }
          objSecDet.Render_By_Default__c = true;
          objSecDet.Component_Label__c = 'Client';
          objSecDet.Mark_it_as_Required__c = true;
          sectionDetail_List.add(objSecDet);
        }
        insert sectionDetail_List;

      }


    } catch (Exception e) {
        System.debug('==>'+e.getMessage());
      System.debug('==>Error occured when creating Section Details Records<==');
    }
    return sectionDetail_List;
  }
//Create Page Navigation rule
//When looking up on Page it behaves as Page render Ruke
//When Looking up on section(Pageblock Section) it behaves as Section render rule
//When lookin up on section details(I/O field) behaves as section detail render rule
//When looking  up on Section details(Command Button) behaves as PNR
  public Page_Navigation_Rule__c createPageNavigationRuleRecord(Id SectionId, Id SectionDetailId, String RuleTextCondition, String RuleCondition) {
    Page_Navigation_Rule__c objPNR = new Page_Navigation_Rule__c();
    objPNR.Section_Detail__c = SectionDetailId;
    objPNR.Section__c = SectionId;
    objPNR.Rule_Name__c = 'Page Navigation Rule Name';
    objPNR.Rule_Text_Condition__c = RuleTextCondition;
    objPNR.Rule_Condition__c = RuleCondition;
    insert objPNR;
    return objPNR;
  }
//Creates Page FLow condition - What is the condition to meet
  public Page_Flow_Condition__c createPageFlowConditionRecord(Id PageId, Id SectionDetailId, String FieldName, String ObjectName, String Operator, String Value) {
    Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
    objCon.Section_Detail__c = SectionDetailId;
    objCon.Page__c = PageId;
    objCon.Field_Name__c = FieldName;
    objCon.Object_Name__c = ObjectName;
    objCon.Operator__c = Operator;
    objCon.Value__c = Value;
    insert objCon;
    return objCon;
  }

  public Page_Flow_Action__c createPageFlowActionRecord(Id PageId, Id SectionDetailId) {
    Page_Flow_Action__c objPFAction = new Page_Flow_Action__c();
    objPFAction.Is_Custom_Component__c = true;
    objPFAction.Page__c = PageId;
    objPFAction.Section_Detail__c = SectionDetailId;
    objPFAction.S_No__c = 1;
    insert objPFAction;
    return objPFAction;
  }
 
  public static  HexaBPM__Document_Master__c createDocMasters(){
        hexaBPM__Document_Master__c Dm = new hexaBPM__Document_Master__c();
        Dm.Name = 'Test DM';
        Dm.HexaBPM__Code__c = 'Bank Statement';
        Dm.HexaBPM__Document_Type_Code__c = 'Doc Type';
        insert Dm;
        return Dm;
  }
 
  public static List<HexaBPM__SR_Doc__c> createSRDocs(List<HexaBPM__Service_Request__c> SR_List){
      
     List<HexaBPM__SR_Doc__c> SRDOcList = new List<HexaBPM__SR_Doc__c>(); 
     HexaBPM__SR_Doc__c srDocObj ;
     HexaBPM__Document_Master__c dm = createDocMasters();
     for(HexaBPM__Service_Request__c srObj :  SR_List){
         
         srDocObj = new HexaBPM__SR_Doc__c();
         srDocObj.Name = srObj.Id;
         srDocObj.HexaBPM__Doc_ID__c = NULL;
         srDocObj.HexaBPM__Document_Master__c  = dm.Id;
         srDocObj.HexaBPM__Service_Request__c = srObj.Id;
         srDocObj.HexaBPM__Is_Not_Required__c = false;
         
         SRDOcList.add(srDocObj);
     }
      insert SRDOcList;
      return SRDOcList;
      
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
		LeadList = GEMS_ChangeTCCntlr_Test.updateLeadRef(LeadList);
		
		List<Account> students = GEMS_ChangeTCCntlr_Test.createStudents();
		
        List<HexaBPM__Service_Request__c> SR_List = GEMS_ChangeTCCntlr_Test.createSRForLead(LeadList,students,schoolList[0],'Enrollment');
        List<HexaBPM__SR_Doc__c> SrDocs = createSRDocs(SR_List);
        List<HexaBPM__Step__c>  stepList = GEMS_ChangeTCCntlr_Test.createStepsForSR(SR_List);
        List<HexaBPM__SR_Price_Item__c> piList =  GEMS_ChangeTCCntlr_Test.createPriceitems(SR_List,prodList,plList);
        
        List<Page_Flow__c> pageFlows = createPageFlow('Enrollment','HexaBPM__Service_Request__c','PF',10);
        List<Page__c>pageRecords =  createPageRecords(pageFlows);
        List<Section__c> sectionRecords  = createSectionRecords(pageRecords);
        List<Section_Detail__c> sectionDetailRecords = createSectionDetailRecords(sectionRecords);
        
		Test.startTest();
	    	Apexpages.currentPage().getParameters().put('RefId',LeadList[0].Id);
	    	Apexpages.currentPage().getParameters().put('BSU',schoolList[0].Id__c);
	    	Apexpages.currentPage().getParameters().put('Id',GEMS_Utility.getEnctryptedURLparam(String.valueOf(SR_List[0].Id)));
	    	Apexpages.currentPage().getParameters().put('FlowId',GEMS_Utility.getEnctryptedURLparam(String.valueOf(pageFlows[0].Id)));
	    	Apexpages.currentPage().getParameters().put('PageId',GEMS_Utility.getEnctryptedURLparam(String.valueOf(pageRecords[0].Id)));
		    DocumentUploadCls obj = new DocumentUploadCls();
		    
		    SR_List[0].HexaBPM__Required_Docs_not_Uploaded__c =  false;
		    update SR_List[0];
		    
		    //goTopage
		    obj.strNavigatePageId = pageRecords[0].Id;
		    obj.objSR = SR_List[0];
		    obj.goTopage();
		    
		    //getDyncPgMainPBBottom
		    obj.getDyncPgMainPBBottom();
		    
		    //getDyncPgMainPB
		    obj.getDyncPgMainPB();
		    
		    //Back_To_SR
		    obj.strObjectId = SR_List[0].Id;
		    obj.Back_To_SR();
		    
		    //DynamicButtonAction
		    obj.strActionId = sectionDetailRecords[0].Id;
		    obj.strObjectId = SR_List[0].Id;
		    obj.DynamicButtonAction();
		    
		    
		    
		    //SaveDoc
		    SrDocs[0].HexaBPM__Status__c = 'Rejected';
		    SrDocs[1].HexaBPM__Status__c = 'Approved';
		    //update SrDocs[0];
		    //update SrDocs[1];
		    
		    obj.objSRDocEdit = SrDocs[0];
		    obj.SaveDoc();
		    
		    obj.objSRDocEdit = SrDocs[1];
		    obj.SaveDoc();
		    
		    //EditDoc
		    obj.AgrDocId = SrDocs[0].Id;
		    obj.EditDoc();
		    
		    //PreviousPage
	        obj.offsetVal = 0;
	        obj.PreviousPage();
	        
	        obj.offsetVal =100;
	        obj.PreviousPage();
	        
	        //NextPage
	        
	        obj.offsetVal = 2001;
	        obj.NextPage();
	        
	        obj.TotalListSize = 2000;
	        obj.NextPage();
	        
	        obj.TotalListSize = 2002;
	        obj.NextPage();
	        
	        obj.TotalListSize =  null;
	        obj.NextPage();
		    
		    //Upload
	        
	        obj.docBody = EncodingUtil.base64Encode(Blob.valueOf('String toBlob'));
	        obj.FileName = 'testDoc.pdf';
	        obj.strAttachmentName = 'strAttachmentName';
	        obj.strSRDocId = SrDocs[0].Id;
	        obj.Upload();
	        
	        //Cancel
	        
	        obj.Cancel();
	        
	        obj.strDocumentName = 'test';
	        obj.thumbBase64 = 'thumbBase64';
	        obj.setstrObjectName('test');
	        obj.getstrObjectName();
		    
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}