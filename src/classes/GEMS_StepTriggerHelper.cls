/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   6th Mar 2018
    Description :   Helper class for step trigger
   
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_StepTriggerHelper {
    
    public static void handleRejection(list<HexaBPM__Step__c> stepList, map<Id, HexaBPM__Step__c> OldMap){
    	map<id,string> rejectionReason = new map<id,string>();
    	for (HexaBPM__Step__c objStep : stepList) {
    		HexaBPM__Step__c oldRecord = oldMap.get(objStep.Id);
    		if(string.isNotBlank(objStep.HexaBPM__Rejection_Reason__c) && string.isBlank(oldRecord.HexaBPM__Rejection_Reason__c)){
        		objStep.Cancelled_Step_Status__c = oldRecord.HexaBPM__Status__c;
        		rejectionReason.put(objStep.HexaBPM__SR__c,objStep.HexaBPM__Rejection_Reason__c);
    		}
    	}
    	
    	if(rejectionReason!=null && rejectionReason.size()>0){
    		list<HexaBPM__Service_Request__c> rejectedSR = [select id, HexaBPM__Rejection_Reason__c 
    														from HexaBPM__Service_Request__c
    														where id IN : rejectionReason.keyset()];	
    		if(rejectedSR!=null && rejectedSR.size()>0){
    			for(HexaBPM__Service_Request__c objSR : rejectedSR){
    				objSR.HexaBPM__Rejection_Reason__c = rejectionReason.get(objSR.id);
    			}
    			update 	rejectedSR;
    		}
    		
    	}
    }
}