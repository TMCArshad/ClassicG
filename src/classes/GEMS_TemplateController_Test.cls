/**
 * Created by bilalnazir on 5/31/17.
 */

@IsTest
private class GEMS_TemplateController_Test {


    static testMethod void testShortFormPageTemplateController() {
        Page_Tracking__c page_tracking = new Page_Tracking__c(page_api_name__c = 'tracking');
        page_tracking.Active__c = true;
        insert page_tracking;


        HexaBPM__Service_Request__c sr = GEMS_TestUtils.createStudentSR('test');
        sr.Lead_Reference__c = '292922';
        update sr;

        HexaBPM__SR_Price_Item__c price_item = new HexaBPM__SR_Price_Item__c();
        price_item.Status__c = 'Paid';
        price_item.HexaBPM__ServiceRequest__c = sr.Id;
        insert price_item;

        HexaBPM__SR_Price_Item__c price_item2 = new HexaBPM__SR_Price_Item__c();
        price_item2.Status__c = 'Added';
        price_item2.HexaBPM__ServiceRequest__c = sr.Id;
        insert price_item2;

        Test.setCurrentPage(new PageReference('apex/GEMS_EmiratesIDSFReader'));
        System.currentPageReference().getParameters().put('RefId', sr.Lead_Reference__c);

        GEMS_PageTemplateController shortFormTemplateController = new GEMS_PageTemplateController();
    }

    static testMethod void testLongFormPageTemplateController() {
        Page_Tracking__c page_tracking = new Page_Tracking__c(page_api_name__c = 'tracking');
        page_tracking.Active__c = true;
        insert page_tracking;


        HexaBPM__Service_Request__c sr = GEMS_TestUtils.createStudentSR('test');
        sr.Lead_Reference__c = '292922';
        update sr;

        HexaBPM__SR_Price_Item__c price_item = new HexaBPM__SR_Price_Item__c();
        price_item.Status__c = 'Paid';
        price_item.HexaBPM__ServiceRequest__c = sr.Id;
        insert price_item;

        HexaBPM__SR_Price_Item__c price_item2 = new HexaBPM__SR_Price_Item__c();
        price_item2.Status__c = 'Added';
        price_item2.HexaBPM__ServiceRequest__c = sr.Id;
        insert price_item2;

        Test.setCurrentPage(new PageReference('/apex/GEMS_Thank_You'));
        System.currentPageReference().getParameters().put('id', sr.id);
        System.currentPageReference().getHeaders().put('Referer', 'http://www.google.com');


        GEMS_LongFormPageTemplateController longFormTemplateController = new GEMS_LongFormPageTemplateController();
    }

    static testMethod void testSiteSecurity(){

        String school_website = 'https://migs.mastercard.com.au/vpcdps';
        GEMS_Site_Domain_Config__c site_domain_config = new GEMS_Site_Domain_Config__c(Name='wek');
        site_domain_config.Site_Base_URL__c = school_website;
        insert site_domain_config;


        GEMS_SiteSecurity siteSecurity = new GEMS_SiteSecurity();

        Test.setCurrentPageReference(new PageReference('Page.GEMS_EmiratesIDSFReader'));
        System.currentPageReference().getHeaders().put('referer', '');
        siteSecurity.Enable_GEMSSiteFrameProtection();

        Test.setCurrentPageReference(new PageReference('Page.GEMS_EmiratesIDSFReader'));
        System.currentPageReference().getHeaders().put('referer', school_website);
        siteSecurity.Enable_GEMSSiteFrameProtection();

        Test.setCurrentPageReference(new PageReference('Page.GEMS_EmiratesIDSFReader'));
        System.currentPageReference().getHeaders().put('referer', 'http:/www.xyz.com');
        siteSecurity.Enable_GEMSSiteFrameProtection();

        siteSecurity.getSiteReferer();

    }
}