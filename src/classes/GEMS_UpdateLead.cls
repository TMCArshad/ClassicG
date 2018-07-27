global without sharing class GEMS_UpdateLead {
    
    
    Webservice static String acceptLead(String leadId){
    	String result='Success';
    	try{
    		Lead l =  new lead(Id = leadId);
    		l.OwnerId = UserInfo.getUserId();
    		update l; 
    	}catch(Exception e){
    		GEMS_Utility.logException(e);
    		result = e.getMessage();
    	}
    	return result;
    }
}