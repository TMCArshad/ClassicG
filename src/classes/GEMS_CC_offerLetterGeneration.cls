global without sharing class GEMS_CC_offerLetterGeneration implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        String msg = 'success';
        Savepoint spdata = Database.setSavepoint();
        try {
        	
            list<HexaBPM__Service_Request__c> tempSRList = new list<HexaBPM__Service_Request__c> ();
            GEMS_Site_Domain_Config__c domainConfig;
            
            tempSRList = [select id,Enrollment_Offer_URL__c,school__r.Short_Name__c ,HexaBPM__Customer__c, student__c,school__r.ID__c
            			  from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c];  
            if(tempSRList!=null && tempSRList.size()>0){
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                objSR = tempSRList[0];
                string urlToEncode = 'apex/Gems_Thank_You?BSU='+objSR.school__r.ID__c+'&Id='+objSR.id+'&Stage=Enrollment';
                
				domainConfig = GEMS_Utility.getSiteURLConfig(objSR.school__r.Short_Name__c);
				if(domainConfig!=null && string.isNotBlank(domainConfig.Site_Base_URL__c) && string.isNotBlank(domainConfig.Short_Form_Page_Name__c)){
					objSR.Enrollment_Offer_URL__c = domainConfig.Site_Base_URL__c + domainConfig.Thank_You_Page__c  + '?' + EncodingUtil.base64Encode(Blob.valueOf(urlToEncode));		
				}
                update objSR;
            }   
        }catch (Exception e) {
            msg = e.getMessage()+ '--sda---' + e.getLineNumber();
            Database.rollback(spdata);
        }
        return msg;
    }
}