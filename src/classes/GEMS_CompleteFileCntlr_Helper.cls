public without sharing class GEMS_CompleteFileCntlr_Helper {
	public static PageReference submitSR(HexaBPM__Service_Request__c objSR,String BSUID){

            for(HexaBPM__SR_Status__c srStatus : [select Id from HexaBPM__SR_Status__c where Name = 'Submitted']) {
                    objSR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
                    objSR.HexaBPM__External_SR_Status__c = srStatus.Id;
                    objSR.HexaBPM__Submitted_Date__c = system.today();
                    objSR.HexaBPM__Submitted_DateTime__c = system.now();
                }
                objSR.HexaBPM__finalizeamendmentflg__c = true;
                objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
                update objSR;
                
                PageReference thankyou = new PageReference('/apex/GEMS_Thank_You?Id='+ objSR.Id  +'&BSU=' + BSUID + '&RefId='+objSR.Lead_Reference__c + '&Stage=Registration'  );
                thankyou.setRedirect(true);
                return thankyou;

	}
}