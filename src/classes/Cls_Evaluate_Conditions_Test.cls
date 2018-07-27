@isTest
private class Cls_Evaluate_Conditions_Test {

    @testSetup static void setupData() {
        Page_Flow__c pf = new Page_Flow__c();
        pf.Name = 'Pre-Approval';
        pf.Flow_Description__c	 = 'Pre-Approval - Company Formation';
        pf.Master_Object__c  = 'HexaBPM__Service_Request__c';
        pf.Record_Type_API_Name__c  = 'Enrollment';
        pf.Requirements__c = 'Test';
        insert pf;

        Page__c	page = new Page__c();
        page.No_Quick_navigation__c = true;
        page.Is_Custom_Component__c = true;
        page.Migration_Rec_Id__c  = '';
        page.Page_Description__c = 'PRE-APPROVAL FOR VISA SERVICES';
        page.Page_Flow__c = pf.id;
        page.Page_Order__c = 1;
        page.Page_Title__c = 'Package';

        page.Render_By_Default__c = true;
        page.VF_Page_API_Name__c = 'Process_Flow';
        page.What_Id__c = '';
        insert page;

        Section__c	sec = new Section__c();
        sec.Name = 'Section name';
        sec.Order__c = 1;
        sec.Section_Title__c = 'Sectoin title';
        sec.Section_Type__c = 'PageBlockSection';
        sec.Layout__c  = '2';
        sec.Page__c = page.Id;
        insert sec;

        Section_Detail__c sd = new Section_Detail__c();
        sd.Order__c = 1;
        sd.Name = 'Save';
        sd.Navigation_Directions__c = 'Forward';
        sd.Component_Label__c	= 'Save';
        sd.Component_Type__c = 'Command Button';
        sd.Section__c = sec.Id;
        insert sd;
      
        Section_Detail__c sd1 = new Section_Detail__c();
        sd1.Order__c = 1;
        sd1.Name = 'Save';
        sd1.Object_Name__c = 'HexaBPM__Service_Request__c';
        sd1.Field_Api_Name__c  ='Name';
        sd1.Component_Label__c	= 'Name';
        sd1.Component_Type__c = 'Input Field';
        sd1.Section__c = sec.Id;
        insert sd1;    



        Account a = new Account();
        a.Name = 'Test Account';
        insert a;


        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        SR.HexaBPM__Customer__c	= a.Id;
        SR.HexaBPM__Email__c = 'test@nsigulf.com';
        SR.HexaBPM__Send_SMS_to_Mobile__c= '12123';
        insert SR;


        Page_Navigation_Rule__c PNR = new Page_Navigation_Rule__c();

        PNR.Rule_Description__c = 'If Outside UAE';
        PNR.Rule_Condition__c = '1';
        PNR.Rule_Name__c = 'If Outside UAE';
        PNR.Rule_Text_Condition__c = 'HexaBPM__Service_Request__c->Apartment_No__c#=#Outside UAE';
        PNR.Section__c = sec.Id;
        PNR.Section_Detail__c = sd.Id;
        PNR.Migration_Rec_Id__c = '';
        PNR.Page__c  = page.id;
        insert PNR;

        Page_Flow_Condition__c PFC =  new Page_Flow_Condition__c();
        PFC.Page_Navigation_Rule__c = PNR.Id;
        PFC.Class_Name__c = 'Section Render';
        PFC.Object_Name__c = 'HexaBPM__Service_Request__c';
        PFC.Field_Name__c = 'Apartment_No__c';
        PFC.Operator__c = '=';
        PFC.Value__c = 'Outside UAE';
        insert PFC;


    }

    @isTest static void test_method_one() {
        // Implement test code
        HexaBPM__Service_Request__c  SR = [Select Id,Apartment_No__c,name from HexaBPM__Service_Request__c];
        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];
        Page_Flow_Condition__c PFC =  [SELECT Class_Name__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Condition__c LIMIT 1];

        List<HexaBPM__SR_Doc__c> SRDoc_List = [Select Id from HexaBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);

        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('Type','Enrollment');
        Process_Flow.getParameters().put('id',SR.Id);
        Process_Flow.getParameters().put('PageId',p.Id);

        Test.startTest();
        Cls_Evaluate_Conditions cls = new Cls_Evaluate_Conditions();
        Cls_Evaluate_Conditions.Check_each_Condition(SR, PFC.Object_Name__c,'Id',PFC.Operator__c,PFC.Value__c);
        Cls_Evaluate_Conditions.Check_PageNavigation_Conditions(new List<Page_Flow_Condition__c>{PFC}, SR);
        List<string> slist = new string[]{'(','HexaBPM__Service_Request__c','->Name','!=','Null'};
        Cls_Evaluate_Conditions.executeNavigationRules('(#HexaBPM__Service_Request__c->Name#!=#Null#)',SR);
        Cls_Evaluate_Conditions.parseConditions(true,true,'AND');
        Cls_Evaluate_Conditions.parseEachCondition('1','>=','2');
        Cls_Evaluate_Conditions.parseEachCondition('11','>=','2');
        Cls_Evaluate_Conditions.parseEachCondition('1','=','1');
        Cls_Evaluate_Conditions.parseEachCondition('1','=','2');
        Cls_Evaluate_Conditions.parseEachCondition('1','<=','2');
        Cls_Evaluate_Conditions.parseEachCondition('1','!=','2');
        Cls_Evaluate_Conditions.parseConditions(true,true,'OR');
        Cls_Evaluate_Conditions.FetchObjectFields(pf.Id,'HexaBPM__Service_Request__c');
        Test.stopTest();
    }



}