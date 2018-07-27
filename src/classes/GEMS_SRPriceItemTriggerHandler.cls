/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Trigger Handler for trigger written on SR price item.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_SRPriceItemTriggerHandler {
	
    public GEMS_SRPriceItemTriggerHandler() {
    }
    
    /**
     * [Execute_BI Execute before insert operations]
     * @param priceItemList
     */
    public void Execute_BI(list<HexaBPM__SR_Price_Item__c> priceItemList) {
		GEMS_SRPriceItemTriggerHelper.insertPriceItemForEnrollment(priceItemList); //calling method to insert price item depending on amount record and SR details
    }
    
    /**
     * [Execute_AI Execute after insert operations]
     * @param priceItemList
    */
    public void Execute_AI(list<HexaBPM__SR_Price_Item__c> priceItemList) {
        GEMS_SRPriceItemTriggerHelper.updateSRWithFee(priceItemList);
    }
    
    /**
     * [Execute_AU Execute after update operations]
     * @param priceItemList,Map<Id,HexaBPM__SR_Price_Item__c>oldMap
    */
    public void Execute_AU(list<HexaBPM__SR_Price_Item__c> priceItemList, map<Id, HexaBPM__SR_Price_Item__c> oldMap) {
    }   
}