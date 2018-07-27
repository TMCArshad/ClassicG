global without sharing class GEMS_CC_InterUnitTransfer implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        String msg = 'success';
        Savepoint spdata = Database.setSavepoint();
        try { 
        	
        	if(step.HexaBPM__SR__c!=null){
        		
        		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        		objSR = step.HexaBPM__SR__r;
        		if(objSR.transfer_date__c!=null && objSR.transfer_date__c<system.today()){
        			return 'Please provide transfer date of today or future when student will join the new school.';	
        		}
        	}
        }catch (Exception e) {
            msg = e.getMessage()+ '-----' + e.getLineNumber();
            system.debug('----msg----'+msg);
            Database.rollback(spdata);
        }
        return msg;
    }
}