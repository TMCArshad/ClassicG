/**
 * Created by bilalnazir on 6/3/17.
 */

@isTest
private class PreparePageBlockUtil_Test {

    public static String retObjectRecordTypeId(SObjectType sObjectType, String recordTypeName) {
        Map <string, schema.recordtypeInfo> recordtypeinfo = sObjectType.getDescribe().getRecordTypeInfosByName();
        if (!recordTypeInfo.containsKey(recordTypeName)) {
            return 'Record type ' + recordTypeName + ' does not exist.';
        }
        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

    @isTest static void test_getConfirmationPB() {
//        Account a = new Account();
//        a.Name = 'Test Account';
//        insert a;


//        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
//        SR.HexaBPM__Customer__c  = a.Id;
//        SR.HexaBPM__Email__c = 'test@nsigulf.com';
//        SR.HexaBPM__Send_SMS_to_Mobile__c = '12123';
//        SR.RecordtypeId = retObjectRecordTypeId(HexaBPM__Service_Request__c.sObjectType, 'General');
//        insert SR;

        Account acc = GEMS_TestUtils.createStudentAccount('Test');

        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createSR('Enrollment');
        SR.Student_Full_Name__c = 'Full Name';
        SR.First_Name__c = 'First Name';
        SR.Last_Name__c = 'Last Name';
        SR.Gender__c = '';
        SR.Staff_ID__c = '19399329';
        sr.filled_page_ids__c = '';
        update SR;


        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Process_Flow';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Page__c objPg2 = new Page__c();
        objPg2.Name = 'Page2';
        objPg2.Page_Description__c = 'Page2';
        objPg2.Is_Custom_Component__c = false;
        objPg2.Page_Order__c = 2;
        objPg2.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg2.Render_By_Default__c = false;
        objPg2.No_Quick_navigation__c = false;
        objPg2.Page_Flow__c = objPF.Id;
        insert objPg2;

        Page__c objPg3 = new Page__c();
        objPg3.Name = 'Page2';
        objPg3.Page_Description__c = 'Page2';
        objPg3.Is_Custom_Component__c = false;
        objPg3.Page_Order__c = 2;
        objPg3.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg3.Render_By_Default__c = false;
        objPg3.No_Quick_navigation__c = true;
        objPg3.Page_Flow__c = objPF.Id;
        insert objPg3;

        Page__c objPg4 = new Page__c();
        objPg4.Name = 'Page2';
        objPg4.Page_Description__c = 'Page2';
        objPg4.Is_Custom_Component__c = false;
        objPg4.Page_Order__c = 2;
        objPg4.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg4.Render_By_Default__c = true;
        objPg4.No_Quick_navigation__c = true;
        objPg4.Page_Flow__c = objPF.Id;
        insert objPg4;



        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Default_Rendering__c = true;
        objSec.Layout__c = '1';
        objSec.Section_Description__c = 'Test';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'PageBlockSection';
        insert objSec;

        Section__c ButtonSec = new Section__c();
        ButtonSec.Page__c = objPg3.Id;
        ButtonSec.Name = 'Page1 Section2';
        ButtonSec.Section_Description__c = 'Test';
        ButtonSec.Default_Rendering__c = true;
        ButtonSec.Layout__c = '1';
        ButtonSec.Order__c = 2;
        ButtonSec.Section_Title__c = 'Test Type';
        ButtonSec.Section_Type__c = 'PageBlockSection';//'CommandButtonSection';
        insert ButtonSec;

        Section__c objSec3 = new Section__c();
        objSec3.Page__c = objPg4.Id;
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
        objSecDet.Field_API_Name__c = 'First_Name__c';
        objSecDet.Render_By_Default__c = true;
        objSecDet.Component_Label__c = 'Client';
        objSecDet.Field_Description__c = 'Customer has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec3.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Last_Name__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'Client';
        objSecDet1.Field_Description__c = 'Customer has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        insert objSecDet1;

        Section_Detail__c objSecDetCon = new Section_Detail__c();
        objSecDetCon.Section__c = ButtonSec.Id;//objSec.Id;
        objSecDetCon.Order__c = 2;
        objSecDetCon.Component_Type__c = 'Input Field';
        objSecDetCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetCon.Field_API_Name__c = 'Staff_ID__c';
        objSecDetCon.Render_By_Default__c = true;
        objSecDetCon.Field_Description__c = 'User has to select';
        objSecDetCon.Mark_it_as_Required__c = false;
        objSecDetCon.hasOnChange__c = true;
        objSecDetCon.Re_render_Sections__c = 'a0f12345699393939;a0f12345699393939';
        insert objSecDetCon;

        Section_Detail__c objSecDetc = new Section_Detail__c();
        objSecDetc.Section__c = objSec.Id;
        objSecDetc.Order__c = 3;
        objSecDetc.Component_Type__c = 'Input Field';
        objSecDetc.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetc.Field_API_Name__c = 'Gender__c';
        objSecDetc.Render_By_Default__c = false;
        objSecDetc.Field_Description__c = 'User has to select';
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
        objSecDetOutStat.Field_API_Name__c = 'Gender__c';
        objSecDetOutStat.Field_Description__c = 'Status';
        insert objSecDetOutStat;

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
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;

        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section_Detail__c = CancBtn.Id;
        objCon.Page__c = objPg2.Id;
        objCon.Field_Name__c = 'First_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;

        Page_Flow_Condition__c objCon1 = new Page_Flow_Condition__c();
        objCon1.Section_Detail__c = objSecDet1.Id;
        objCon1.Page__c = objPg4.Id;
        objCon1.Field_Name__c = 'Last_Name__c';
        objCon1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon1.Operator__c = '!=';
        objCon1.Value__c = '';
        insert objCon1;





        Page_Navigation_Rule__c objPNR = new Page_Navigation_Rule__c();

        objPNR.Rule_Name__c = 'Test';
        objPNR.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR.Rule_Condition__c = '1';
        insert objPNR;

        Page_Navigation_Rule__c objPNR1 = new Page_Navigation_Rule__c();
        objPNR1.Section_Detail__c = objSecDet1.Id;
        objPNR1.Section__c = objSec3.Id;
        objPNR1.Rule_Name__c = 'Test';
        objPNR1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR1.Rule_Condition__c = '1';
        insert objPNR1;

        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', SR.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = NextBtn.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();

        cls.getConfirmationPB();
        objSec3.Default_Rendering__c = true;
        update objSec3;
        cls.getConfirmationPB();
        objSecDet1.Render_By_Default__c = true;
        update objSecDet1;
        cls.getConfirmationPB();

        objSecDet1.Commit_the_Record__c = true;
        update objSecDet1;
        cls.getConfirmationPB();
        objSecDet1.Commit_the_Record__c = false;
        objSecDet1.Cancel_Request__c = true;
        update objSecDet1;
        cls.getConfirmationPB();
        objSecDet1.Button_Location__c = 'Top';
        objSecDet1.Button_Position__c = 'Left';
        update objSecDet1;
        cls.getConfirmationPB();
        objSecDet1.Button_Position__c = 'Right';
        update objSecDet1;
        cls.getConfirmationPB();



        Test.stopTest();
    }
    @isTest static void test_getBottomButtonsPB() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'New';
        objSRStatus.HexaBPM__Code__c = 'CANCELLED';
        objSRStatus.HexaBPM__Type__c  = 'Cancel';
        insert objSRStatus;



//        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
//        SR.HexaBPM__Customer__c  = a.Id;
//        SR.HexaBPM__Email__c = 'test@nsigulf.com';
//        SR.HexaBPM__Send_SMS_to_Mobile__c = '12123';
//        SR.RecordtypeId = retObjectRecordTypeId(HexaBPM__Service_Request__c.sObjectType, 'General');
//        insert SR;
        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createSR('Enrollment');


        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Page1';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow?';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Section_Description__c = 'Test';
        objSec.Default_Rendering__c = false;
        objSec.Layout__c = '1';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'CommandButtonSection';
        insert objSec;



        Section_Detail__c objSecDet = new Section_Detail__c();
        objSecDet.Section__c = objSec.Id;
        objSecDet.Order__c = 1;
        objSecDet.Component_Type__c = 'Input Field';
        objSecDet.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet.Field_API_Name__c = 'First_Name__c';
        objSecDet.Render_By_Default__c = false;
        objSecDet.Component_Label__c = 'Client';
        objSecDet.Field_Description__c = 'Customer has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section__c objSec1 = new Section__c();
        objSec1.Page__c = objPg.Id;
        objSec1.Name = 'Page1 Section2';
        objSec1.Section_Description__c = 'Test';
        objSec1.Default_Rendering__c = false;
        objSec1.Layout__c = '1';
        objSec1.Order__c = 2;
        objSec1.Section_Title__c = 'Test Type';
        objSec1.Section_Type__c = 'CommandButtonSection';
        insert objSec1;



        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec1.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Last_Name__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'Client';
        objSecDet1.Field_Description__c = 'Customer has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        insert objSecDet1;



        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg.Id;
        objNextAct.Section_Detail__c = objSecDet.Id;
        objNextAct.S_No__c = 1;
        insert objNextAct;



        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = objSec.Id;
        SecRenRule1.Section_Detail__c = objSecDet.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;



        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section__c = objSec1.Id;
        objCon.Section_Detail__c = objSecDet1.Id;
        objCon.Page__c = objPg.Id;
        objCon.Field_Name__c = 'Last_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;


        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', SR.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = objSecDet.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();
        cls.getBottomButtonsPB();
        PreparePageBlockUtil.ActionId = objSecDet1.Id;
        cls.getBottomButtonsPB();
        objSec.Default_Rendering__c = true;
        update objSec;
        objSec1.Default_Rendering__c = true;
        update objSec1;
        cls.getBottomButtonsPB();

        objSecDet.Render_By_Default__c = true;
        update objSecDet;
        objSecDet1.Render_By_Default__c = true;
        update objSecDet1;
        cls.getBottomButtonsPB();
        objSecDet.Commit_the_Record__c = true;
        update objSecDet;
        cls.getBottomButtonsPB();

        objSecDet.Button_Location__c = 'Top';
        update objSecDet;
        cls.getBottomButtonsPB();
        objSecDet.Button_Position__c = 'left';
        update objSecDet;
        cls.getBottomButtonsPB();
        objSecDet.Button_Position__c = 'right';
        update objSecDet;
        cls.getBottomButtonsPB();
        Test.stopTest();
    }

    @isTest static void test_getButtonsPB() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'New';
        objSRStatus.HexaBPM__Code__c = 'CANCELLED';
        objSRStatus.HexaBPM__Type__c  = 'Cancel';
        insert objSRStatus;



        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        SR.HexaBPM__Customer__c  = a.Id;
        SR.HexaBPM__Email__c = 'test@nsigulf.com';
        SR.HexaBPM__Send_SMS_to_Mobile__c = '12123';
        SR.RecordtypeId = retObjectRecordTypeId(HexaBPM__Service_Request__c.sObjectType, 'General');
        insert SR;


        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Page1';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow?';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Section_Description__c = 'Test';
        objSec.Default_Rendering__c = false;
        objSec.Layout__c = '1';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'CommandButtonSection';
        insert objSec;



        Section_Detail__c objSecDet = new Section_Detail__c();
        objSecDet.Section__c = objSec.Id;
        objSecDet.Order__c = 1;
        objSecDet.Component_Type__c = 'Input Field';
        objSecDet.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet.Field_API_Name__c = 'First_Name__c';
        objSecDet.Render_By_Default__c = false;
        objSecDet.Component_Label__c = 'Client';
        objSecDet.Field_Description__c = 'Customer has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section__c objSec1 = new Section__c();
        objSec1.Page__c = objPg.Id;
        objSec1.Name = 'Page1 Section2';
        objSec1.Section_Description__c = 'Test';
        objSec1.Default_Rendering__c = false;
        objSec1.Layout__c = '1';
        objSec1.Order__c = 2;
        objSec1.Section_Title__c = 'Test Type';
        objSec1.Section_Type__c = 'CommandButtonSection';
        insert objSec1;



        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec1.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Last_Name__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'Client';
        objSecDet1.Field_Description__c = 'Customer has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        insert objSecDet1;



        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg.Id;
        objNextAct.Section_Detail__c = objSecDet.Id;
        objNextAct.S_No__c = 1;
        insert objNextAct;



        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = objSec.Id;
        SecRenRule1.Section_Detail__c = objSecDet.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;



        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section__c = objSec1.Id;
        objCon.Section_Detail__c = objSecDet1.Id;
        objCon.Page__c = objPg.Id;
        objCon.Field_Name__c = 'Last_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;


        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', SR.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = objSecDet.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();
        cls.getButtonsPB();
        PreparePageBlockUtil.ActionId = objSecDet1.Id;
        cls.getButtonsPB();
        objSec.Default_Rendering__c = true;
        update objSec;
        objSec1.Default_Rendering__c = true;
        update objSec1;
        cls.getButtonsPB();

        objSecDet.Render_By_Default__c = true;
        update objSecDet;
        objSecDet1.Render_By_Default__c = true;
        update objSecDet1;
        cls.getButtonsPB();
        objSecDet.Commit_the_Record__c = true;
        update objSecDet;
        cls.getButtonsPB();

        objSecDet.Button_Location__c = 'Top';
        update objSecDet;
        cls.getButtonsPB();
        objSecDet.Button_Position__c = 'left';
        update objSecDet;
        cls.getButtonsPB();
        objSecDet.Button_Position__c = 'right';
        update objSecDet;
        cls.getButtonsPB();
        Test.stopTest();
    }
    @isTest static void test_getTopButtonsPB() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'New';
        objSRStatus.HexaBPM__Code__c = 'CANCELLED';
        objSRStatus.HexaBPM__Type__c  = 'Cancel';
        insert objSRStatus;



        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        SR.HexaBPM__Customer__c  = a.Id;
        SR.HexaBPM__Email__c = 'test@nsigulf.com';
        SR.HexaBPM__Send_SMS_to_Mobile__c = '12123';
        SR.RecordtypeId = retObjectRecordTypeId(HexaBPM__Service_Request__c.sObjectType, 'General');
        insert SR;


        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Page1';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow?';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Section_Description__c = 'Test';
        objSec.Default_Rendering__c = false;
        objSec.Layout__c = '1';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'CommandButtonSection';
        insert objSec;



        Section_Detail__c objSecDet = new Section_Detail__c();
        objSecDet.Section__c = objSec.Id;
        objSecDet.Order__c = 1;
        objSecDet.Component_Type__c = 'Input Field';
        objSecDet.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet.Field_API_Name__c = 'First_Name__c';
        objSecDet.Render_By_Default__c = false;
        objSecDet.Component_Label__c = 'Client';
        objSecDet.Field_Description__c = 'Customer has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section__c objSec1 = new Section__c();
        objSec1.Page__c = objPg.Id;
        objSec1.Name = 'Page1 Section2';
        objSec1.Section_Description__c = 'Test';
        objSec1.Default_Rendering__c = false;
        objSec1.Layout__c = '1';
        objSec1.Order__c = 2;
        objSec1.Section_Title__c = 'Test Type';
        objSec1.Section_Type__c = 'CommandButtonSection';
        insert objSec1;



        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec1.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Last_Name__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'Client';
        objSecDet1.Field_Description__c = 'Customer has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        insert objSecDet1;



        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg.Id;
        objNextAct.Section_Detail__c = objSecDet.Id;
        objNextAct.S_No__c = 1;
        insert objNextAct;



        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = objSec.Id;
        SecRenRule1.Section_Detail__c = objSecDet.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;



        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section__c = objSec1.Id;
        objCon.Section_Detail__c = objSecDet1.Id;
        objCon.Page__c = objPg.Id;
        objCon.Field_Name__c = 'Last_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;


        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', SR.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = objSecDet.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();
        cls.getTopButtonsPB();
        PreparePageBlockUtil.ActionId = objSecDet1.Id;
        cls.getTopButtonsPB();
        objSec.Default_Rendering__c = true;
        update objSec;
        objSec1.Default_Rendering__c = true;
        update objSec1;
        cls.getTopButtonsPB();

        objSecDet.Render_By_Default__c = true;
        update objSecDet;
        objSecDet1.Render_By_Default__c = true;
        update objSecDet1;
        cls.getTopButtonsPB();
        objSecDet.Commit_the_Record__c = true;
        update objSecDet;
        cls.getTopButtonsPB();

        objSecDet.Button_Location__c = 'Top';
        update objSecDet;
        cls.getTopButtonsPB();
        objSecDet.Button_Position__c = 'left';
        update objSecDet;
        cls.getTopButtonsPB();
        objSecDet.Button_Position__c = 'right';
        update objSecDet;
        cls.getTopButtonsPB();
        Test.stopTest();
    }

    @isTest static void test_getDyncPgMainPB() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'New';
        objSRStatus.HexaBPM__Code__c = 'CANCELLED';
        objSRStatus.HexaBPM__Type__c  = 'Cancel';
        insert objSRStatus;



        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createSR('Enrollment');
        SR.Student_Full_Name__c = 'Full Name';
        SR.Last_Name__c = 'Last Name';
        SR.Gender__c = '';
        SR.Staff_ID__c = '19399329';
        update SR;


        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Process_Flow';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow?';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Page__c objPg2 = new Page__c();
        objPg2.Name = 'Page2';
        objPg2.Page_Description__c = 'Page2';
        objPg2.Is_Custom_Component__c = true;
        objPg2.Page_Order__c = 2;
        objPg2.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg2.Render_By_Default__c = false;
        objPg2.No_Quick_navigation__c = false;
        objPg2.Page_Flow__c = objPF.Id;
        insert objPg2;

        Page__c objPg3 = new Page__c();
        objPg3.Name = 'Page2';
        objPg3.Page_Description__c = 'Page2';
        objPg3.Is_Custom_Component__c = true;
        objPg3.Page_Order__c = 2;
        objPg3.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg3.Render_By_Default__c = false;
        objPg3.No_Quick_navigation__c = true;
        objPg3.Page_Flow__c = objPF.Id;
        insert objPg3;

        Page__c objPg4 = new Page__c();
        objPg4.Name = 'Page2';
        objPg4.Page_Description__c = 'Page2';
        objPg4.Is_Custom_Component__c = false;
        objPg4.Page_Order__c = 2;
        objPg4.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg4.Render_By_Default__c = true;
        objPg4.No_Quick_navigation__c = true;
        objPg4.Page_Flow__c = objPF.Id;
        insert objPg4;

        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Default_Rendering__c = false;
        objSec.Layout__c = '1';
        objSec.Section_Description__c = 'Test';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'PageblockSection';
        insert objSec;

        Section__c objSec2 = new Section__c();
        objSec2.Page__c = objPg.Id;
        objSec2.Name = 'Page1 Section1';
        objSec2.Default_Rendering__c = false;
        objSec2.Layout__c = '1';
        objSec2.Section_Description__c = 'Test';
        objSec2.Order__c = 1;
        objSec2.Section_Title__c = 'Test Type';
        objSec2.Section_Type__c = 'PageblockSection';
        insert objSec2;

        Section__c ButtonSec = new Section__c();
        ButtonSec.Page__c = objPg.Id;
        ButtonSec.Name = 'Page1 Section2';
        ButtonSec.Section_Description__c = 'Test';
        ButtonSec.Default_Rendering__c = false;
        ButtonSec.Layout__c = '1';
        ButtonSec.Order__c = 2;
        ButtonSec.Section_Title__c = 'Test Type';
        ButtonSec.Section_Type__c = 'CommandButtonSection';
        insert ButtonSec;

        Section__c objSec3 = new Section__c();
        objSec3.Page__c = objPg4.Id;
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
        objSecDet.Field_API_Name__c = 'First_Name__c';
        objSecDet.Render_By_Default__c = false;
        objSecDet.Component_Label__c = 'Client';
        objSecDet.Field_Description__c = 'Customer has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Last_Name__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'Client';
        objSecDet1.Field_Description__c = 'Customer has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        objSecDet1.hasOnChange__c = true;
        objSecDet1.Re_render_Sections__c = 'All';
        insert objSecDet1;

        Section_Detail__c objSecDetCon = new Section_Detail__c();
        objSecDetCon.Section__c = objSec.Id;
        objSecDetCon.Order__c = 2;
        objSecDetCon.Component_Type__c = 'Input Field';
        objSecDetCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetCon.Field_API_Name__c = 'Student_Full_Name__c';
        objSecDetCon.Render_By_Default__c = false;
        objSecDetCon.Field_Description__c = 'Customer has to select';
        objSecDetCon.Mark_it_as_Required__c = false;
        objSecDetCon.hasOnChange__c = true;
        objSecDetCon.Re_render_Sections__c = 'a0f38838282928234w;a0f38838282928252w';
        insert objSecDetCon;

        Section_Detail__c objSecDetc = new Section_Detail__c();
        objSecDetc.Section__c = objSec.Id;
        objSecDetc.Order__c = 3;
        objSecDetc.Component_Type__c = 'Input Field';
        objSecDetc.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetc.Field_API_Name__c = 'Staff_ID__c';
        objSecDetc.Render_By_Default__c = false;
        objSecDetc.Field_Description__c = 'Customer has to select';
        objSecDetc.Mark_it_as_Required__c = false;
        insert objSecDetc;

        Section_Detail__c objSecDetOut = new Section_Detail__c();
        objSecDetOut.Section__c = objSec.Id;
        objSecDetOut.Order__c = 4;
        objSecDetOut.Render_By_Default__c = false;
        objSecDetOut.Component_Type__c = 'Output Field';
        objSecDetOut.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOut.Field_API_Name__c = 'Name';
        objSecDetOut.Component_Label__c = 'Client';
        objSecDetOut.Field_Description__c = 'Service Request No :';
        insert objSecDetOut;

        Section_Detail__c objSecDetOutStat = new Section_Detail__c();
        objSecDetOutStat.Section__c = objSec.Id;
        objSecDetOutStat.Order__c = 5;
        objSecDetOutStat.Render_By_Default__c = false;
        objSecDetOutStat.Component_Type__c = 'Output Field';
        objSecDetOutStat.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOutStat.Field_API_Name__c = 'Gender__c';
        objSecDetOutStat.Field_Description__c = 'Status';
        insert objSecDetOutStat;

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
        SaveBtn.Render_By_Default__c = false;
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

        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg2.Id;
        objNextAct.Section_Detail__c = NextBtn.Id;
        objNextAct.S_No__c = 1;
        insert objNextAct;



        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = objSec.Id;
        SecRenRule1.Section_Detail__c = objSecDet.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;

        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section_Detail__c = objSecDet.Id;
        objCon.Page__c = objPg.Id;
        objCon.Field_Name__c = 'Last_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;

        Page_Flow_Condition__c objCon1 = new Page_Flow_Condition__c();
        objCon1.Section_Detail__c = objSecDet.Id;
        objCon1.Page__c = objPg.Id;
        objCon1.Field_Name__c = 'Last_Name__c';
        objCon1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon1.Operator__c = '!=';
        objCon1.Value__c = '';
        insert objCon1;





        Page_Navigation_Rule__c objPNR = new Page_Navigation_Rule__c();

        objPNR.Rule_Name__c = 'Test';
        objPNR.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR.Rule_Condition__c = '2';
        insert objPNR;

        Page_Navigation_Rule__c objPNR1 = new Page_Navigation_Rule__c();
        objPNR1.Section_Detail__c = NextBtn.Id;
        objPNR1.Section__c = ButtonSec.Id;
        objPNR1.Rule_Name__c = 'Test';
        objPNR1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR1.Rule_Condition__c = '2';
        insert objPNR1;

        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', SR.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = objSecDet.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();
        cls.getDyncPgMainPB();

        objSec.Default_Rendering__c = true;
        update objSec;
        cls.getDyncPgMainPB();
        objSecDet.Render_By_Default__c = true;
        update objSecDet;
        cls.getDyncPgMainPB();

        objSecDet.Commit_the_Record__c = true;
        update objSecDet;
        cls.getDyncPgMainPB();
        objSecDet.Commit_the_Record__c = false;
        objSecDet.Cancel_Request__c = true;
        update objSecDet;
        cls.getDyncPgMainPB();
        objSecDet.Button_Location__c = 'Top';
        objSecDet.Button_Position__c = 'Left';
        update objSecDet;
        cls.getDyncPgMainPB();
        objSecDet.Button_Position__c = 'Right';
        update objSecDet;
        cls.getDyncPgMainPB();


        Test.stopTest();
    }
    @isTest static void test_getReviewFinalisePB() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'New';
        objSRStatus.HexaBPM__Code__c = 'CANCELLED';
        objSRStatus.HexaBPM__Type__c  = 'Cancel';
        insert objSRStatus;



        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createSR('Enrollment');
        SR.Student_Full_Name__c = 'Full Name';
        SR.Last_Name__c = 'Last Name';
        SR.Gender__c = '';
        SR.Staff_ID__c = '19399329';
        update SR;

//        SR.HexaBPM__Customer__c  = a.Id;
//        SR.HexaBPM__Email__c = 'test@nsigulf.com';
//        SR.HexaBPM__Send_SMS_to_Mobile__c = '12123';
//        SR.RecordtypeId = retObjectRecordTypeId(HexaBPM__Service_Request__c.sObjectType, 'General');
//        insert SR;


        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Page1';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow?';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Page__c objPg2 = new Page__c();
        objPg2.Name = 'Page2';
        objPg2.Page_Description__c = 'Page2';
        objPg2.Is_Custom_Component__c = true;
        objPg2.Page_Order__c = 2;
        objPg2.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg2.Render_By_Default__c = false;
        objPg2.No_Quick_navigation__c = false;
        objPg2.Page_Flow__c = objPF.Id;
        insert objPg2;

        Page__c objPg3 = new Page__c();
        objPg3.Name = 'Page2';
        objPg3.Page_Description__c = 'Page2';
        objPg3.Is_Custom_Component__c = true;
        objPg3.Page_Order__c = 2;
        objPg3.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg3.Render_By_Default__c = false;
        objPg3.No_Quick_navigation__c = true;
        objPg3.Page_Flow__c = objPF.Id;
        insert objPg3;

        Page__c objPg4 = new Page__c();
        objPg4.Name = 'Page2';
        objPg4.Page_Description__c = 'Page2';
        objPg4.Is_Custom_Component__c = false;
        objPg4.Page_Order__c = 2;
        objPg4.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg4.Render_By_Default__c = true;
        objPg4.No_Quick_navigation__c = true;
        objPg4.Page_Flow__c = objPF.Id;
        insert objPg4;

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
        objSec3.Page__c = objPg4.Id;
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
        objSecDet.Field_API_Name__c = 'First_Name__c';
        objSecDet.Render_By_Default__c = true;
        objSecDet.Component_Label__c = 'User';
        objSecDet.Field_Description__c = 'User has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec3.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Last_Name__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'User';
        objSecDet1.Field_Description__c = 'User has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        insert objSecDet1;

        Section_Detail__c objSecDetCon = new Section_Detail__c();
        objSecDetCon.Section__c = objSec.Id;
        objSecDetCon.Order__c = 2;
        objSecDetCon.Component_Type__c = 'Input Field';
        objSecDetCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetCon.Field_API_Name__c = 'Staff_ID__c';
        objSecDetCon.Render_By_Default__c = true;
        objSecDetCon.Field_Description__c = 'Staff ID';
        objSecDetCon.Mark_it_as_Required__c = false;
        objSecDetCon.hasOnChange__c = true;
        insert objSecDetCon;

        Section_Detail__c objSecDetc = new Section_Detail__c();
        objSecDetc.Section__c = objSec.Id;
        objSecDetc.Order__c = 3;
        objSecDetc.Component_Type__c = 'Input Field';
        objSecDetc.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetc.Field_API_Name__c = 'Student_Full_Name__c';
        objSecDetc.Render_By_Default__c = false;
        objSecDetc.Field_Description__c = 'Student';
        objSecDetc.Mark_it_as_Required__c = false;
        insert objSecDetc;

        Section_Detail__c objSecDetOut = new Section_Detail__c();
        objSecDetOut.Section__c = objSec.Id;
        objSecDetOut.Order__c = 4;
        objSecDetOut.Render_By_Default__c = true;
        objSecDetOut.Component_Type__c = 'Output Field';
        objSecDetOut.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOut.Field_API_Name__c = 'Name';
        objSecDetOut.Component_Label__c = 'User';
        objSecDetOut.Field_Description__c = 'Service Request No :';
        insert objSecDetOut;

        Section_Detail__c objSecDetOutStat = new Section_Detail__c();
        objSecDetOutStat.Section__c = objSec.Id;
        objSecDetOutStat.Order__c = 5;
        objSecDetOutStat.Render_By_Default__c = true;
        objSecDetOutStat.Component_Type__c = 'Output Field';
        objSecDetOutStat.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDetOutStat.Field_API_Name__c = 'Gender__c';
        objSecDetOutStat.Field_Description__c = 'Status';
        insert objSecDetOutStat;

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
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;

        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section_Detail__c = CancBtn.Id;
        objCon.Page__c = objPg2.Id;
        objCon.Field_Name__c = 'Student_Full_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        insert objCon;

        Page_Flow_Condition__c objCon1 = new Page_Flow_Condition__c();
        objCon1.Section_Detail__c = objSecDet1.Id;
        objCon1.Page__c = objPg4.Id;
        objCon1.Field_Name__c = 'Staff_ID__c';
        objCon1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon1.Operator__c = '!=';
        objCon1.Value__c = '';
        insert objCon1;





        Page_Navigation_Rule__c objPNR = new Page_Navigation_Rule__c();

        objPNR.Rule_Name__c = 'Test';
        objPNR.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR.Rule_Condition__c = '1';
        insert objPNR;

        Page_Navigation_Rule__c objPNR1 = new Page_Navigation_Rule__c();
        objPNR1.Section_Detail__c = objSecDet1.Id;
        objPNR1.Section__c = objSec3.Id;
        objPNR1.Rule_Name__c = 'Test';
        objPNR1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        objPNR1.Rule_Condition__c = '1';
        insert objPNR1;

        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', Sr.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        PreparePageBlockUtil.objSR = SR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = NextBtn.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();
        PreparePageBlockUtil.Cancel_SR('testSRID');
        PreparePageBlockUtil.Cancel_Open_SR(String.valueOf(SR.Id));
        cls.getProcessFlowReference();
        cls.getSideBarReference();
        objPg.Is_Custom_Component__c = true;
        update objPg;
        cls.getSideBarReference();
        cls.getReviewFinalisePB();
        objSec3.Default_Rendering__c = true;
        update objSec3;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSecDet1.Render_By_Default__c = true;
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        PreparePageBlockUtil.PageId = objPg4.Id;
        objSec3.Section_Type__c = 'CommandButtonSection';
        objSec3.Default_Rendering__c = false;
        objSecDet1.Render_By_Default__c = false;
        update objSec3;
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSec3.Default_Rendering__c = true;
        update objSec3;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSecDet1.Render_By_Default__c = true;
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSecDet1.Commit_the_Record__c = true;
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSecDet1.Commit_the_Record__c = false;
        objSecDet1.Cancel_Request__c = true;
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSecDet1.Button_Location__c = 'Top';
        objSecDet1.Button_Position__c = 'Left';
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();
        objSecDet1.Button_Position__c = 'Right';
        update objSecDet1;
        cls.getReviewFinalisePB();
        cls.getDyncPgMainPB();

        Test.stopTest();

    }
    @isTest static void test_getButtonAction(){
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'New';
        objSRStatus.HexaBPM__Code__c = 'CANCELLED';
        objSRStatus.HexaBPM__Type__c  = 'Cancel';
        insert objSRStatus;



//        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
//        SR.HexaBPM__Customer__c  = a.Id;
//        SR.HexaBPM__Email__c = 'test@nsigulf.com';
//        SR.HexaBPM__Send_SMS_to_Mobile__c = '12123';
//        SR.RecordtypeId = retObjectRecordTypeId(HexaBPM__Service_Request__c.sObjectType, 'General');
//        insert SR;
        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createSR('Enrollment');
        SR.Student_Full_Name__c = 'Full Name';
        SR.Last_Name__c = 'Last Name';
        SR.Gender__c = '';
        SR.Staff_ID__c = '19399329';
        update SR;

        HexaBPM__SR_Price_Item__c objPI =  new HexaBPM__SR_Price_Item__c();
        objPI.HexaBPM__ServiceRequest__c = SR.Id;
        objPI.Status__c = 'Added';
        insert objPI;


        Page_Flow__c objPF = new Page_Flow__c();
        objPF.Name = 'Test Flow';
        objPF.Master_Object__c = 'HexaBPM__Service_Request__c';
        objPF.Flow_Description__c = 'Test';
        insert objPF;

        Page__c objPg = new Page__c();
        objPg.Name = 'Page1';
        objPg.Page_Description__c = 'Page1';
        objPg.Is_Custom_Component__c = false;
        objPg.Page_Order__c = 1;
        objPg.What_Id__c = 'HexaBPM__Service_Request__c';
        objPg.Render_By_Default__c = false;
        objPg.No_Quick_navigation__c = false;
        objPg.VF_Page_API_Name__c = 'Process_Flow?';
        objPg.Page_Flow__c = objPF.Id;
        insert objPg;

        Section__c objSec = new Section__c();
        objSec.Page__c = objPg.Id;
        objSec.Name = 'Page1 Section1';
        objSec.Section_Description__c = 'Test';
        objSec.Default_Rendering__c = false;
        objSec.Layout__c = '1';
        objSec.Order__c = 1;
        objSec.Section_Title__c = 'Test Type';
        objSec.Section_Type__c = 'CommandButtonSection';
        insert objSec;



        Section_Detail__c objSecDet = new Section_Detail__c();
        objSecDet.Section__c = objSec.Id;
        objSecDet.Order__c = 1;
        objSecDet.Component_Type__c = 'Input Field';
        objSecDet.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet.Field_API_Name__c = 'Student_Full_Name__c';
        objSecDet.Render_By_Default__c = false;
        objSecDet.Component_Label__c = 'User';
        objSecDet.Field_Description__c = 'User has to select';
        objSecDet.Mark_it_as_Required__c = true;
        insert objSecDet;

        Section__c objSec1 = new Section__c();
        objSec1.Page__c = objPg.Id;
        objSec1.Name = 'Page1 Section2';
        objSec1.Section_Description__c = 'Test';
        objSec1.Default_Rendering__c = false;
        objSec1.Layout__c = '1';
        objSec1.Order__c = 2;
        objSec1.Section_Title__c = 'Test Type';
        objSec1.Section_Type__c = 'CommandButtonSection';
        insert objSec1;



        Section_Detail__c objSecDet1 = new Section_Detail__c();
        objSecDet1.Section__c = objSec1.Id;
        objSecDet1.Order__c = 1;
        objSecDet1.Component_Type__c = 'Input Field';
        objSecDet1.Object_Name__c = 'HexaBPM__Service_Request__c';
        objSecDet1.Field_API_Name__c = 'Staff_ID__c';
        objSecDet1.Render_By_Default__c = false;
        objSecDet1.Component_Label__c = 'Staff';
        objSecDet1.Field_Description__c = 'User has to select';
        objSecDet1.Mark_it_as_Required__c = true;
        insert objSecDet1;







        Page_Navigation_Rule__c SecRenRule1 = new Page_Navigation_Rule__c();
        SecRenRule1.Section__c = objSec.Id;
        SecRenRule1.Section_Detail__c = objSecDet.Id;
        SecRenRule1.Rule_Name__c = 'Test';
        SecRenRule1.Page__c = objPg.Id;
        SecRenRule1.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Name#!=#Null';
        SecRenRule1.Rule_Condition__c = '1';
        insert SecRenRule1;

        Page_Flow_Action__c objNextAct = new Page_Flow_Action__c();
        objNextAct.Is_Custom_Component__c = true;
        objNextAct.Page__c = objPg.Id;
        objNextAct.Section_Detail__c = objSecDet.Id;
        objNextAct.S_No__c = 1;
        objNextAct.Page_Navigation_Rule__c = SecRenRule1.Id;
        insert objNextAct;


        Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
        objCon.Section__c = objSec1.Id;
        objCon.Section_Detail__c = objSecDet1.Id;
        objCon.Page__c = objPg.Id;
        objCon.Field_Name__c = 'Last_Name__c';
        objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
        objCon.Operator__c = '!=';
        objCon.Value__c = '';
        objCon.Page_Navigation_Rule__c = SecRenRule1.Id;
        insert objCon;


        Test.startTest();
        PageReference OthersDetails = Page.Process_Flow;
        Test.setCurrentPageReference(OthersDetails);

        OthersDetails.getParameters().put('FlowId', objPF.Id);
        OthersDetails.getParameters().put('id', SR.Id);
        OthersDetails.getParameters().put('PageId', objPg.Id);

        HexaBPM__Service_Request__c objSR  =  [Select Name,Id from HexaBPM__Service_Request__c LIMIT 1];

        PreparePageBlockUtil.objSR = objSR;
        PreparePageBlockUtil.PageId = objPg.Id;
        PreparePageBlockUtil.ActionId = objSecDet.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id ;
        PreparePageBlockUtil.strReqFieldIds = '';
        PreparePageBlockUtil.pageDescription = '';
        PreparePageBlockUtil.FlowId = objPF.Id;
        PreparePageBlockUtil.strSideBarPageId = objPg.Id;
        PreparePageBlockUtil.PageName = 'Process_Flow';
        PreparePageBlockUtil.PageBlockTitle = 'Test Process Flow';
        //PreparePageBlockUtil.getHiddenPageIds(objPF.Id, SR);
        PreparePageBlockUtil.prepare_Page_Description(objPg.Id);

        PreparePageBlockUtil cls = new PreparePageBlockUtil();
        cls.getButtonAction();
        objPg.Is_Custom_Component__c = true;
        update objPg;
        cls.getButtonAction();
        SecRenRule1.Section__c = NULL;
        SecRenRule1.Section_Detail__c = NULL;
        update SecRenRule1;
        cls.getButtonAction();
        Test.stopTest();
    }


}