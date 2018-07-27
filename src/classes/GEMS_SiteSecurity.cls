/**
 * Created by bilalnazir on 4/30/17.
 */

public with sharing class GEMS_SiteSecurity {

    private String domainReferer;
    public GEMS_SiteSecurity(){
        domainReferer = null;
    }

    public void Enable_GEMSSiteFrameProtection(){
        Boolean IsForceComReferer = false;
        Boolean allowFraming = false;

        if(ApexPages.currentPage().getHeaders().containsKey('Referer')){
            domainReferer = ApexPages.currentPage().getHeaders().get('Referer');

            if(domainReferer == null || domainReferer == '' || domainReferer.indexOf(URL.getSalesforceBaseUrl().toExternalForm()) >= 0)
                IsForceComReferer = true;

            List<GEMS_Site_Domain_Config__c> allGEMS_SchoolSitesConfigs = [SELECT Site_Base_URL__c FROM GEMS_Site_Domain_Config__c];
            List<GEMS_MiGS_Config__mdt>gemsPaymentGatewaysList = [SELECT Payment_URL__c FROM GEMS_MiGS_Config__mdt];

            //First check - if school site is verified
            for(GEMS_Site_Domain_Config__c siteConfig : allGEMS_SchoolSitesConfigs){
                if(domainReferer.indexOf(siteConfig.Site_Base_URL__c) >= 0)
                    allowFraming = true;
            }

            //Second check - check if referred by accepted payment gateways
            for(GEMS_MiGS_Config__mdt migConfig: gemsPaymentGatewaysList){
                if(domainReferer.indexOf(migConfig.Payment_URL__c) >= 0)
                    allowFraming = true;
            }

        }

        if(!IsForceComReferer && !allowFraming)
            ApexPages.currentPage().getHeaders().put('X-Frame-Options', 'DENY');
    }

    public String getSiteReferer(){
        return domainReferer;
    }


}