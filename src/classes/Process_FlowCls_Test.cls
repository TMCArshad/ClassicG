/**
 * Created by bilalnazir on 6/3/17.
 */

/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Process_FlowCls_Test{

    static testMethod void myUnitTest() {

        HexaBPM__Service_Request__c sr = GEMS_TestUtils.createSR('Enrollment');
        Account acc = GEMS_TestUtils.createStudentAccount('Test');
        sr.filled_page_ids__c = '';
        update sr;

        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        objPF.Record_Type_API_Name__c = 'New_Credit_Card';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Primary Contact';
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

        Page__c objPg3 = new Page__c();
        objPg3.Name = 'Other Details';
        objPg3.Page_Description__c = 'Page2';
        objPg3.Is_Custom_Component__c = true;
        objPg3.Page_Order__c = 2;
        objPg3.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg3.Render_By_Default__c = true;
        objPg3.No_Quick_navigation__c = true;
        objPg3.VF_Page_API_Name__c = 'Review_Finalise';
        objPg3.Page_Flow__c = objPF.Id;
        insert objPg3;
        // 1.0
        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Default_Rendering__c = true;
        objSec.Layout__c = '1';
        objSec.Section_Description__c = 'Test';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'PageblockSection';
        insert objSec;

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

        Section__c objSec3 = new Section__c();
        objSec3.Page__c = objPg.Id;
        objSec3.Name = 'Page1 Section3';
        objSec3.Default_Rendering__c = false;
        objSec3.Order__c = 1;
        objSec3.layout__c = '1';
        objSec3.Section_Description__c = 'Test';
        objSec3.Section_Title__c = 'Test Type';
        objSec3.Section_Type__c = 'PageblockSection';
        insert objSec3;

        Section_Detail__c objSecDet = new Section_Detail__c();
        objSecDet.Section__c = objSec.Id;
        objSecDet.Order__c = 1;
        objSecDet.Component_Type__c = 'Input Field';
        objSecDet.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet.Field_API_Name__c = 'Student_Full_Name__c';
        objSecDet.Render_By_Default__c = true;
        objSecDet.Component_Label__c = 'Student';
        objSecDet.Field_Description__c = 'Full name';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section_Detail__c objSecDetCon = new Section_Detail__c();
        objSecDetCon.Section__c = objSec.Id;
        objSecDetCon.Order__c = 2;
        objSecDetCon.Component_Type__c = 'Input Field';
        objSecDetCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetCon.Field_API_Name__c = 'Staff_ID__c';
        objSecDetCon.Render_By_Default__c = true;
        objSecDetCon.Field_Description__c = 'Father Staff Id';
        objSecDetCon.Mark_it_as_Required__c = false;
        objSecDetCon.hasOnChange__c = true;
        objSecDetCon.Re_render_Sections__c = 'a0f12345699393939;a0f12345699393939';
        insert objSecDetCon;

        Section_Detail__c objSecDetCon2 = new Section_Detail__c();
        objSecDetCon2.Section__c = objSec.Id;
        objSecDetCon2.Order__c = 2;
        objSecDetCon2.Component_Type__c = 'Input Field';
        objSecDetCon2.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetCon2.Field_API_Name__c = 'Show_Mother_Contact_Details__c';
        objSecDetCon2.Render_By_Default__c = true;
        objSecDetCon2.Field_Description__c = 'Show_Mother_Contact_Details__c';
        objSecDetCon2.Mark_it_as_Required__c = false;
        objSecDetCon2.hasOnChange__c = true;
        objSecDetCon2.Re_render_Sections__c = 'All';
        insert objSecDetCon2;

        Section_Detail__c objSecDetc = new Section_Detail__c();
        objSecDetc.Section__c = objSec.Id;
        objSecDetc.Order__c = 3;
        objSecDetc.Component_Type__c = 'Input Field';
        objSecDetc.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetc.Field_API_Name__c = 'Mother_Name__c';
        objSecDetc.Render_By_Default__c = false;
        objSecDetc.Field_Description__c = 'Mother Name';
        objSecDetc.Mark_it_as_Required__c = false;
        insert objSecDetc;

        Section_Detail__c objSecDetOut = new Section_Detail__c();
        objSecDetOut.Section__c = objSec.Id;
        objSecDetOut.Order__c = 4;
        objSecDetOut.Render_By_Default__c = true;
        objSecDetOut.Component_Type__c = 'Output Field';
        objSecDetOut.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOut.Field_API_Name__c = 'Name';
        objSecDetOut.Component_Label__c = 'Client';
        objSecDetOut.Field_Description__c = 'Service Request No :';
        insert objSecDetOut;

        Section_Detail__c objSecDetOutStat = new Section_Detail__c();
        objSecDetOutStat.Section__c = objSec.Id;
        objSecDetOutStat.Order__c = 5;
        objSecDetOutStat.Render_By_Default__c = true;
        objSecDetOutStat.Component_Type__c = 'Output Field';
        objSecDetOutStat.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOutStat.Field_API_Name__c = 'HexaBPM__External_Status_Name__c';
        objSecDetOutStat.Field_Description__c = 'Status';
        insert objSecDetOutStat;
        // 1.0
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

        Section_Detail__c CancBtn = new Section_Detail__c();
        CancBtn.Section__c = ButtonSec.Id;
        CancBtn.Order__c = 2;
        CancBtn.Button_Position__c = 'Center';
        CancBtn.Render_By_Default__c = false;
        CancBtn.Component_Type__c = 'Command Button';
        CancBtn.Component_Label__c = 'Client';
        CancBtn.Commit_the_Record__c = true;
        insert CancBtn;

        Section_Detail__c SaveBtn = new Section_Detail__c();
        SaveBtn.Section__c = ButtonSec.Id;
        SaveBtn.Order__c = 3;
        SaveBtn.Button_Position__c = 'Center';
        SaveBtn.Navigation_Directions__c = 'Previous';
        SaveBtn.Render_By_Default__c = true;
        SaveBtn.Component_Type__c = 'Command Button';
        SaveBtn.Component_Label__c = 'Client';
        SaveBtn.Cancel_Request__c = true;
        insert SaveBtn;

        Section_Detail__c PrevBtn = new Section_Detail__c();
        PrevBtn.Section__c = ButtonSec.Id;
        PrevBtn.Order__c = 4;
        NextBtn.Button_Location__c = 'Bottom';
        NextBtn.Button_Position__c = 'Right';
        NextBtn.Navigation_Directions__c = 'Previous';
        PrevBtn.Render_By_Default__c = false;
        PrevBtn.Component_Type__c = 'Command Button';
        PrevBtn.Component_Label__c = 'Client';
        insert PrevBtn;

        Section_Detail__c objSecDetOutStat_blank = new Section_Detail__c();
        objSecDetOutStat_blank.Section__c = objSec.Id;
        objSecDetOutStat_blank.Order__c = 5;
        objSecDetOutStat_blank.Render_By_Default__c = true;
        objSecDetOutStat_blank.Component_Type__c = 'Blank Space';
        objSecDetOutStat_blank.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOutStat_blank.Field_API_Name__c = 'HexaBPM__External_Status_Name__c';
        objSecDetOutStat_blank.Field_Description__c = 'Blank Space';
        insert objSecDetOutStat_blank;

        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg2.Id;
        objNextAct.Section_Detail__c = NextBtn.Id;
        objNextAct.S_No__c = 1;
        insert objNextAct;

        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = ButtonSec.Id;
        SecRenRule1.Section_Detail__c = NextBtn.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;

        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section_Detail__c = CancBtn.Id;
        objCon.Field_Name__c = 'Full_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;

        Page_Navigation_Rule__c objPNR = new Page_Navigation_Rule__c();
        objPNR.Page__c = objPg3.Id;
        objPNR.Rule_Name__c = 'Test';
        objPNR.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR.Rule_Condition__c = '1';
        insert objPNR;
        // 1.0
        Apexpages.currentPage().getParameters().put('FlowId',objPF.Id);
        Apexpages.currentPage().getParameters().put('Id',SR.Id);
        Apexpages.currentPage().getParameters().put('PageId',objPg.Id);
        Apexpages.currentPage().getParameters().put('BSU','12345');
        Process_FlowCls objPageFlowcls = new Process_FlowCls();
        //objPageFlowcls.prePopulateServiceRequest(SR ,acc.Id,'New_Credit_Card');



        objPageFlowcls.getDyncPgMainPB();
        objPageFlowcls.CommitRecord();
        objPageFlowcls.RePrepareSection();
        objPageFlowcls.getClass();
        objPageFlowcls.stringActionId = NextBtn.Id;
        objPageFlowcls.DynamicButtonAction();
        objPageFlowcls.strNavigatePageId = objPg2.Id;
        objPageFlowcls.goTopage();
        objPageFlowcls.Redirect_DefaultCustomPage();
        objPageFlowcls.CancelSR();
//        objPageFlowcls.SearchActivities();
//        objPageFlowcls.ClearActivities();
//        objPageFlowcls.SearchCompanies();
//        objPageFlowcls.ClearCompanies();



        Page__c objPg1 = new Page__c();
        objPg1.Page_Flow__c = objPF.Id;
        objPg1.Name = 'General Instructions';
        objPg1.Page_Title__c = 'General Instructions';
        objPg1.Page_Description__c = 'General Instructions';
        objPg1.Is_Custom_Component__c = true;
        objPg1.VF_Page_API_Name__c = 'InstructionsPage';
        objPg1.No_Quick_navigation__c = false;
        objPg1.Page_Order__c = 1;
        objPg1.Render_By_Default__c = true;
        objPg1.What_Id__c = 'Application_Form__c';
        insert objPg1;

        Page__c objPgLic = new Page__c();
        objPgLic.Page_Flow__c = objPF.Id;
        objPgLic.Name = 'License Activities';
        objPgLic.Page_Title__c = 'License Activities';
        objPgLic.Page_Description__c = 'License Activities';
        objPgLic.Is_Custom_Component__c = true;
        objPgLic.VF_Page_API_Name__c = 'Manage_Licenses';
        objPgLic.No_Quick_navigation__c = false;
        objPgLic.Page_Order__c = 3;
        objPgLic.Render_By_Default__c = true;
        objPgLic.What_Id__c = 'Application_Form__c';
        insert objPgLic;

        Page__c objPg4 = new Page__c();
        objPg4.Page_Flow__c = objPF.Id;
        objPg4.Name = 'Key Roles';
        objPg4.Page_Title__c = 'Key Roles';
        objPg4.Page_Description__c = 'Key Roles';
        objPg4.Is_Custom_Component__c = true;
        objPg4.VF_Page_API_Name__c = 'KeyRoles';
        objPg4.No_Quick_navigation__c = false;
        objPg4.Page_Order__c = 5;
        objPg4.Render_By_Default__c = true;
        objPg4.What_Id__c = 'Application_Form__c';
        insert objPg4;

        Page__c objPg5 = new Page__c();
        objPg5.Page_Flow__c = objPF.Id;
        objPg5.Name = 'Key Roles';
        objPg5.Page_Title__c = 'Key Roles';
        objPg5.Page_Description__c = 'Key Roles';
        objPg5.Is_Custom_Component__c = true;
        objPg5.VF_Page_API_Name__c = 'Review_Finalise';
        objPg5.No_Quick_navigation__c = false;
        objPg5.Page_Order__c = 6;
        objPg5.Render_By_Default__c = true;
        objPg5.What_Id__c = 'Application_Form__c';
        insert objPg5;

        Page__c objPg6 = new Page__c();
        objPg6.Page_Flow__c = objPF.Id;
        objPg6.Name = 'Upload Documents';
        objPg6.Page_Title__c = 'Upload Documents';
        objPg6.Page_Description__c = 'Upload Documents';
        objPg6.Is_Custom_Component__c = true;
        objPg6.VF_Page_API_Name__c = 'DocumentUpload';
        objPg6.No_Quick_navigation__c = true;
        objPg6.Page_Order__c = 7;
        objPg6.Render_By_Default__c = true;
        objPg6.What_Id__c = 'Application_Form__c';
        insert objPg6;

        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg1.Id;
        PreparePageBlockUtil.PageName = 'Primary Information';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg2.Id;
        PreparePageBlockUtil.ActionId = NextBtn.Id;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = 'Test Process Flow';

        PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg1.Id);

        PreparePageBlockUtil objPBU = new PreparePageBlockUtil();

        PreparePageBlockUtil.PageName = 'Instructions Page';

        PreparePageBlockUtil.PageId = objPg1.Id;
        objPBU.getReviewFinalisePB();
        objPBU.getDyncPgMainPB();

        objPBU.getButtonAction();
        objPBU.getBottomButtonsPB();
        objPBU.getSideBarReference();

        PreparePageBlockUtil.getHiddenPageIds(objPF.Id,SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg5.Id);

        PreparePageBlockUtil.PageName = 'Value Added Services';

        PreparePageBlockUtil.PageId = objPg2.Id;
        objPBU.getReviewFinalisePB();
        objPBU.getDyncPgMainPB();

        PreparePageBlockUtil.ActionId = NextBtn.Id;
        objPBU.getButtonAction();

        objPBU.getSideBarReference();
        // 1.0
        PreparePageBlockUtil.PageName = 'Primary Information';

        PreparePageBlockUtil.PageId = objPg2.Id;
        objPBU.getReviewFinalisePB();
        objPBU.getDyncPgMainPB();

        PreparePageBlockUtil.ActionId = NextBtn.Id;
        objPBU.getConfirmationPB();
        objPBU.getButtonsPB();
        objPBU.getTopButtonsPB();
        objPBU.getButtonAction();
        objPBU.getBottomButtonsPB();
        objPBU.getSideBarReference();

        PreparePageBlockUtil.Cancel_SR(null);
        PreparePageBlockUtil.Cancel_Open_SR(SR.Id);

    }
}