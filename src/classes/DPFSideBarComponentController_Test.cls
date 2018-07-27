/**
 * Created by bilalnazir on 6/3/17.
 */

@isTest
private class DPFSideBarComponentController_Test {

    @testSetup static void setupData() {
        Page_Flow__c pf = new Page_Flow__c();
        pf.Name = 'Long Form Flow';
        pf.Flow_Description__c	 = '';
        pf.Master_Object__c  = 'HexaBPM__Service_Request__c';
        pf.Record_Type_API_Name__c  = 'Long_Form';
        pf.Requirements__c = 'Test';
        insert pf;

        Page__c	page = new Page__c();
        page.No_Quick_navigation__c = true;
        page.Is_Custom_Component__c = true;
        page.Migration_Rec_Id__c  = '';
        page.Page_Description__c = 'Applicant Info';
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

        HexaBPM__Document_Master__c Dm = new HexaBPM__Document_Master__c();
        Dm.Name = 'Test DM';
        Dm.HexaBPM__Code__c = 'Bank Statement';
        Dm.HexaBPM__Document_Type_Code__c = 'Doc Type';
        insert Dm;

        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createSR('Enrollment');
        List<HexaBPM__SR_Doc__c> SRDoc_List = createSRDocs(SR.Id, Dm);



    }

    public static List<HexaBPM__SR_Doc__c> createSRDocs(Id SRId,HexaBPM__Document_Master__c Dm)
    {
        List<HexaBPM__SR_Doc__c> SRDoc_List = new List<HexaBPM__SR_Doc__c>();
        HexaBPM__SR_Doc__c SRDoc;
        for(Integer i=0;i<10;i++)
        {
            SRDoc = new HexaBPM__SR_Doc__c();
            SRDoc.Name = 'Test' + i;
            SRDoc.HexaBPM__Document_Master__c = Dm.Id;
            SRDoc.HexaBPM__Service_Request__c = SRId;
            SRDoc_List.add(SRDoc);
        }
        insert SRDoc_List;
        return SRDoc_List;
    }

    @isTest static void test_method_one() {
        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createStudentSR('Enrollment');

        // Implement test code
        //HexaBPM__Service_Request__c  SR = [Select Id from HexaBPM__Service_Request__c WHERE id];
        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];

        List<HexaBPM__SR_Doc__c> SRDoc_List = [Select Id from HexaBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);

        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('id',SR.Id);
        Process_Flow.getParameters().put('PageId',p.Id);
        Test.startTest();
        DPFSideBarComponentController cls = new DPFSideBarComponentController();
        DPFSideBarComponentController.PageWrap  PageWrap = new DPFSideBarComponentController.PageWrap();
        PageWrap.NoQuickNavigation = false;
        Test.stopTest();
    }

    @isTest static void test_getLstPageWrap() {
        // Implement test code
        //HexaBPM__Service_Request__c  SR = [Select Id from HexaBPM__Service_Request__c];
        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createStudentSR('Enrollment');
        SR.Filled_Page_Ids__c = 'a0f393939299fads;a0f393939299fads;';
        update SR;

        Page_Flow__c pf = [Select id From Page_Flow__c LIMIT 1 ];
        Page__c p =  [Select Id from Page__c LIMIT 1];
        Section__c sec = [Select id from Section__c LIMIT 1];
        Section_Detail__c sd =  [Select id from Section_Detail__c LIMIT 1];

        List<HexaBPM__SR_Doc__c> SRDoc_List = [Select Id from HexaBPM__SR_Doc__c];
        PageReference Process_Flow = Page.Process_Flow;
        Test.setCurrentPageReference(Process_Flow);

        Process_Flow.getParameters().put('FlowId',pf.Id);
        Process_Flow.getParameters().put('id',SR.Id);
        Process_Flow.getParameters().put('PageId',p.Id);
        Test.startTest();
        DPFSideBarComponentController cls = new DPFSideBarComponentController();
        cls.getLstPageWrap();
        DPFSideBarComponentController.StepPagesWrap wrap1 = new DPFSideBarComponentController.StepPagesWrap();
        wrap1.StepName = 'StepName';
        wrap1.isDisabled = true;
        wrap1.PageURL = 'PageURL' ;
        wrap1.isCompleted = true;

        cls.getStepPages();
        Test.stopTest();
    }


}