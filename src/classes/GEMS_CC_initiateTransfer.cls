global without sharing class GEMS_CC_initiateTransfer implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
    	String msg = 'success';
    	if(step.HexaBPM__SR__c!=null){
    		
    		string srId = step.HexaBPM__SR__c;
        	HexaBPM__Service_Request__c objSR =  new HexaBPM__Service_Request__c();
	        	objSR = step.HexaBPM__SR__r;	
        	
        	if(objSR.HexaBPM__Customer__c!=null && objSR.Transfer_date__c!=null && objSR.Transfer_date__c==system.today()){
        		GEMS_initiateTransferBatch batchJob = new GEMS_initiateTransferBatch() ;
				Database.executeBatch(batchJob);
        	}
    	}	
        return msg;
    }
}