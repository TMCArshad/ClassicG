global without sharing class GEMS_CC_deActivateScholarship implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        String msg = 'success';
        Savepoint spdata = Database.setSavepoint();
        try {
        	if(step.HexaBPM__SR__c!=null){
	        	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
	    		objSR = step.HexaBPM__SR__r;
	    		list<scholarship__c> scholarshipToUpdate = new list<scholarship__c>();
	    		for(scholarship__c obj : [select id,TC_SO_CN_Applied__c,active__c from scholarship__c where active__c = true and student__c =: objSR.student__c]){
                	obj.TC_SO_CN_Applied__c = true;
                	obj.active__c = false;
                	scholarshipToUpdate.add(obj);
                }
                    
                if (scholarshipToUpdate != null && scholarshipToUpdate.size() > 0) 
                    update scholarshipToUpdate;
        	}
    		
    	}catch (Exception e) {
            Database.rollback(spdata);
            msg = e.getMessage()+ '-----' + e.getLineNumber();
            system.debug('----msg----'+msg);
        }
        return msg;
    }
}