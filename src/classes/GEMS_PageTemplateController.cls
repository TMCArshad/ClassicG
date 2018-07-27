/**
 * Created by bilalnazir on 3/8/17.
 */

public with sharing class GEMS_PageTemplateController {

    public String domainReferer {get; set;}

    private GEMS_SiteSecurity siteSecurity;

    public List<Page_Tracking__c> pageTrackings {get; set;}
    public Boolean hasPayment{get; set;}
    public String PaymentStatus{get; set;}

    public GEMS_PageTemplateController() {

        try {
            siteSecurity = new GEMS_SiteSecurity();

//            siteSecurity.Enable_GEMSSiteFrameProtection();
//            domainReferer = siteSecurity.getSiteReferer();
        }catch(Exception ex){
            System.debug('Framing validating failed: ' + ex.getStackTraceString());
        }

        loadPageTrackings();
    }

    public void loadPageTrackings(){

        hasPayment = false;
        PaymentStatus = 'N/A';

        pageTrackings = null;
        try{

            List<HexaBPM__Service_Request__c> service_requests = null;
            String leadRefId = null;

            if(ApexPages.currentPage().getParameters().containsKey('RefId')){
                leadRefId = ApexPages.CurrentPage().getParameters().get('RefId');
            }

            loadTrackingScripts();
            loadPaymentInfo(leadRefId);

        }catch(Exception ex){
            System.debug(ex.getMessage());
        }

    }

    private void loadTrackingScripts(){
        String currentPageURL = ApexPages.currentPage().getUrl();
        System.debug('Current Page ==>' + currentPageURL);

        //get page name
            /*
            currentPageURL.replaceAll('\\?', '-');
            pattern pageNamePattern = pattern.compile('/apex/(\\w{1,})');
            matcher pageNameMatcher = pageNamePattern.matcher(currentPageURL);

            String currentPageName = '';
            if(pageNameMatcher.matches() && pageNameMatcher.hitEnd() ){
                if(pageNameMatcher.groupCount() >= 2)
                    currentPageName = pageNameMatcher.group(2);
            }*/

        String currentPageName = String.valueOf(currentPageURL.split('apex/')[1].replaceAll('\\?', '-')).split('-')[0];
        System.debug('Page Tracking == page name ' + currentPageName);
        pageTrackings = [
                SELECT id, page_api_name__c, Header_Tracking_Code__c, Body_Tracking_Code__c, Footer_Tracking_Code__c
                FROM Page_Tracking__c
                WHERE Active__c = true and (page_api_name__c = null or page_api_name__c = :currentPageName)
        ];
    }

    private void loadPaymentInfo(String leadRefId){

        try {
            if(leadRefId != null) {
                for( HexaBPM__Service_Request__c sr: [SELECT id, (SELECT Status__c FROM HexaBPM__SR_Price_Items1__r)
                FROM HexaBPM__Service_Request__c
                WHERE Lead_Reference__c =: leadRefId

                ]){
                    if(sr.HexaBPM__SR_Price_Items1__r!=null && sr.HexaBPM__SR_Price_Items1__r.size()>0){
                        hasPayment = true;

                        for(HexaBPM__SR_Price_Item__c price_item : sr.HexaBPM__SR_Price_Items1__r){
                            if(price_item.Status__c != 'Paid')
                                PaymentStatus = 'Pending';
                        }
                        if(PaymentStatus != 'Pending'){
                            PaymentStatus = 'Paid';
                        }
                    }
                }

            }
        }catch(Exception ex){
            System.debug('Loading Payment info failed ==>' + ex.getMessage());
        }

    }

}