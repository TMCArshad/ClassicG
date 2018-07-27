/**
 * Created by bilalnazir on 4/5/17.
 */

public with sharing class GEMS_LongFormPageTemplateController {
    public boolean IsForceComReferer{get; set;}
    private GEMS_SiteSecurity siteSecurity;
    public String domainReferer {get; set;}

    public List<Page_Tracking__c> pageTrackings {get; set;}
    public Boolean hasPayment{get; set;}
    public String PaymentStatus{get; set;}

    public String SR_ServiceType {get; set;}

    public GEMS_LongFormPageTemplateController() {

        SR_ServiceType = '';

        String srId;
        if(ApexPages.currentPage().getParameters().containsKey('Id')){

            srId = ApexPages.currentPage().getParameters().get('Id');
            if(String.isNotBlank(srId)){
                for(HexaBPM__Service_Request__c sr: [SELECT id, Service_Type__c FROM HexaBPM__Service_Request__c WHERE id=:srId LIMIT 1 ]){
                    SR_ServiceType = sr.Service_Type__c;
                }
            }
        }

        String pageReferrer = ApexPages.currentPage().getHeaders().get('Referer');
        IsForceComReferer = true;
        if(pageReferrer!= null && pageReferrer.length() > 0) {
            IsForceComReferer = false;
        }

        try {
            siteSecurity = new GEMS_SiteSecurity();

            siteSecurity.Enable_GEMSSiteFrameProtection();
            domainReferer = siteSecurity.getSiteReferer();

            loadPageTrackings();
            loadPaymentInfo();

        }catch(Exception ex){
            System.debug('Framing validating failed: ' + ex.getStackTraceString());
        }

    }

    public void loadPageTrackings(){

        String currentPageURL = ApexPages.currentPage().getUrl();
        System.debug('Current Page ==>' + currentPageURL);

        pageTrackings = null;
        try{

            String currentPageName = String.valueOf(currentPageURL.split('apex/')[1].replaceAll('\\?', '-')).split('-')[0];
            System.debug('Page Tracking == page name ' + currentPageName);
            pageTrackings = [
                    SELECT id, page_api_name__c, Header_Tracking_Code__c, Body_Tracking_Code__c, Footer_Tracking_Code__c
                    FROM Page_Tracking__c
                    WHERE Active__c = true and (page_api_name__c = null or page_api_name__c = :currentPageName)
            ];

        }catch(Exception ex){
            System.debug(ex.getMessage());
        }

    }

    private void loadPaymentInfo(){

        String SRId = null;
        try {
            if(ApexPages.currentPage().getParameters().containsKey('id')){
                SRId = ApexPages.CurrentPage().getParameters().get('id');
            }

            if(SRId != null) {
                for( HexaBPM__Service_Request__c sr: [SELECT id, (SELECT Status__c FROM HexaBPM__SR_Price_Items1__r)
                FROM HexaBPM__Service_Request__c
                WHERE id =: SRId

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