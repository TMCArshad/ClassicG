@isTest
private class GEMS_longFormTest {
    static testMethod void GEMS_longFormTest(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	HexaBPM__SR_Template__c objTempLate = GEMS_TestUtils.createSRTemplate('Enrollment','Enrollment');
    	
    	Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        objPF.Record_Type_API_Name__c = objTempLate.HexaBPM__SR_RecordType_API_Name__c;
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Applicant Details';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = true;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;
        
        Page__c objPg2 = new Page__c();
        objPg2.Name = 'Applicant Info';
        objPg2.Page_Description__c = 'Page2';
        objPg2.Is_Custom_Component__c = true;
        objPg2.Page_Order__c = 2;
        objPg2.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg2.Render_By_Default__c = true;
        objPg2.No_Quick_navigation__c = false;
        objPg2.VF_Page_API_Name__c = 'Required-documents';
        objPg2.Page_Flow__c = objPF.Id;
        insert objPg2;
        
        Section__c ButtonSec = new Section__c();
        ButtonSec.Page__c = objPg.Id;
        ButtonSec.Name = 'Page1 Section2';
        ButtonSec.Section_Description__c = 'Test';
        ButtonSec.Default_Rendering__c = true;
        ButtonSec.Layout__c = '1';
        ButtonSec.Order__c = 2;
        ButtonSec.Section_Title__c = 'Test Type';
        ButtonSec.Section_Type__c = 'CommandButtonSection';
        insert ButtonSec;
        
        Section_Detail__c NextBtn = new Section_Detail__c();
        NextBtn.Section__c = ButtonSec.Id;
        NextBtn.Order__c = 2;
        NextBtn.Render_By_Default__c = false;
        NextBtn.Component_Type__c = 'Command Button';
        NextBtn.Navigation_Directions__c = 'Forward';
        NextBtn.Button_Location__c = 'Top';
        NextBtn.Button_Position__c = 'Left';
        NextBtn.Component_Label__c = 'Client';
        insert NextBtn;
		
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
    	Apexpages.currentPage().getParameters().put('PageId',String.valueOf(objPg.id));
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.stringActionId = NextBtn.Id;
    	longFormCtlr.strNavigatePageId = objPg2.Id;
    	longFormCtlr.DynamicButtonAction(); 
    	longFormCtlr.goTopage();
    	longFormCtlr.Redirect_DefaultCustomPage();
    	longFormCtlr.getClass();
    	longFormCtlr.getDyncPgMainPB();
    	longFormCtlr.RePrepareSection();
    	longFormCtlr.getDyncPgMainPBBottom();
    }
    
    
    static testMethod void GEMS_longFormTest2(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	HexaBPM__SR_Template__c objTempLate = GEMS_TestUtils.createSRTemplate('Enrollment','Enrollment');
    	
    	Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        objPF.Record_Type_API_Name__c = objTempLate.HexaBPM__SR_RecordType_API_Name__c;
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Other Details';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = true;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;
        
        Section__c ButtonSec = new Section__c();
        ButtonSec.Page__c = objPg.Id;
        ButtonSec.Name = 'Page1 Section2';
        ButtonSec.Section_Description__c = 'Test';
        ButtonSec.Default_Rendering__c = true;
        ButtonSec.Layout__c = '1';
        ButtonSec.Order__c = 2;
        ButtonSec.Section_Title__c = 'Test Type';
        ButtonSec.Section_Type__c = 'CommandButtonSection';
        insert ButtonSec;
        
        Section_Detail__c NextBtn = new Section_Detail__c();
        NextBtn.Section__c = ButtonSec.Id;
        NextBtn.Order__c = 2;
        NextBtn.Render_By_Default__c = false;
        NextBtn.Component_Type__c = 'Command Button';
        NextBtn.Navigation_Directions__c = 'Forward';
        NextBtn.Button_Location__c = 'Top';
        NextBtn.Button_Position__c = 'Left';
        NextBtn.Component_Label__c = 'Client';
        insert NextBtn;
		
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_previousSchoolDetails'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
    	Apexpages.currentPage().getParameters().put('PageId',String.valueOf(objPg.id));
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.stringActionId = NextBtn.Id;
    	longFormCtlr.DynamicButtonAction(); 
    }
    
    static testMethod void GEMS_longFormTest3(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	HexaBPM__SR_Template__c objTempLate = GEMS_TestUtils.createSRTemplate('Enrollment','Enrollment');
    	
    	Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        objPF.Record_Type_API_Name__c = objTempLate.HexaBPM__SR_RecordType_API_Name__c;
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Declaration';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = true;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;
        
        Section__c ButtonSec = new Section__c();
        ButtonSec.Page__c = objPg.Id;
        ButtonSec.Name = 'Page1 Section2';
        ButtonSec.Section_Description__c = 'Test';
        ButtonSec.Default_Rendering__c = true;
        ButtonSec.Layout__c = '1';
        ButtonSec.Order__c = 2;
        ButtonSec.Section_Title__c = 'Test Type';
        ButtonSec.Section_Type__c = 'CommandButtonSection';
        insert ButtonSec;
        
        Section_Detail__c NextBtn = new Section_Detail__c();
        NextBtn.Section__c = ButtonSec.Id;
        NextBtn.Order__c = 2;
        NextBtn.Render_By_Default__c = false;
        NextBtn.Component_Type__c = 'Command Button';
        NextBtn.Navigation_Directions__c = 'Forward';
        NextBtn.Button_Location__c = 'Top';
        NextBtn.Button_Position__c = 'Left';
        NextBtn.Component_Label__c = 'Client';
        insert NextBtn;
		
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_Declaration'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
    	Apexpages.currentPage().getParameters().put('PageId',String.valueOf(objPg.id));
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.stringActionId = NextBtn.Id;
    	longFormCtlr.DynamicButtonAction(); 
    	
    	
    	objSR.The_application_is_filled_by__c = 'Parent';
    	objSR.Declaration__c = true;
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_Declaration'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
    	Apexpages.currentPage().getParameters().put('PageId',String.valueOf(objPg.id));
    	GEMS_LongFormController longFormCtlr1 = new GEMS_LongFormController(); 
    	longFormCtlr1.stringActionId = NextBtn.Id;
    	longFormCtlr1.DynamicButtonAction();  
    	longFormCtlr1.selectTypeMethod();
    	
    	objSR.The_application_is_filled_by__c = 'Relocation Agent';
    	objSR.Declaration__c = true;
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_Declaration'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
    	Apexpages.currentPage().getParameters().put('PageId',String.valueOf(objPg.id));
    	GEMS_LongFormController longFormCtlr2 = new GEMS_LongFormController(); 
    	longFormCtlr2.stringActionId = NextBtn.Id;
    	longFormCtlr2.DynamicButtonAction(); 
    }
    
    
    
    static testMethod void GEMS_longFormTest4(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
    	
    	HexaBPM__SR_Template__c objTempLate = GEMS_TestUtils.createSRTemplate('Enrollment','Enrollment');
    	
    	Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        objPF.Record_Type_API_Name__c = objTempLate.HexaBPM__SR_RecordType_API_Name__c;
        insert objPF;

        
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	
    }
    
    static testMethod void GEMS_longFormTest5(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.passport_expiry_date__c = system.today().addDays(-1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    	
    }
    
    static testMethod void GEMS_longFormTest6(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.visa_expiry_date__c = system.today().addDays(-1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    }
    
    static testMethod void GEMS_longFormTest7(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.Emirates_ID_Expiry_Date__c = system.today().addDays(-1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    }
    
    static testMethod void GEMS_longFormTest8(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.visa_expiry_date__c = system.today().addDays(1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    }
    
    static testMethod void GEMS_longFormTest9(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.Emirates_ID_Expiry_Date__c = system.today().addDays(1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    }
    
    static testMethod void GEMS_longFormTest11(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.visa_issue_date__c = system.today().addDays(1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    }
    
    static testMethod void GEMS_longFormTest12(){
    	
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.passport_issue_date__c = system.today().addDays(1);
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_SelectSchoolLongForm'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id__c);
    	GEMS_LongFormController longFormCtlr = new GEMS_LongFormController(); 
    	longFormCtlr.applicantDetailValidations(objSR);
    }
    
    
}