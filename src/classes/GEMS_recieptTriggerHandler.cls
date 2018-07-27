public without sharing class GEMS_recieptTriggerHandler {
 	 
 	public void Execute_BI(list<Reciept__c> recieptList){
 		GEMS_recieptTriggerHelper.setReceiptNumber(recieptList);  
 	} 
 	    
    /** 
     * [Execute_BU Execute before update operations]
     * @param recieptList,Map<Id,Reciept__c>oldMap
    */
    public void Execute_BU(list<Reciept__c> recieptList, map<Id, Reciept__c> oldMap) {
    	GEMS_recieptTriggerHelper.updateRecieptDetails(recieptList);
    }
        
}