/**************************************************************************************************
 * Name               : GEMS_AmountTriggerHandler                                                    *
 * Description        : Amount Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                               *
 **************************************************************************************************/
public with sharing class GEMS_AmountTriggerHandler {
	public GEMS_AmountTriggerHandler() {
		
	}

	public void Execute_AU(List<Amount__c> amounts,Map<Id,Amount__c>oldMap){
      deleteAmounts(amounts);
	}

	public void deleteAmounts(List<Amount__c>amounts){
		List<Id> deletionList = new list<Id>();
		for(Amount__c amtObj : amounts){
           if(amtObj.sys_is_deleted__c){
              deletionList.add(amtObj.Id);
           }
		}

		if(!deletionList.isEmpty()){
           Database.delete(deletionList);
		}
	} 
}