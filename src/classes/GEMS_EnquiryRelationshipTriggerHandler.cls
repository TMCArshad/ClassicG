/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   13th March 2017
    Description :   Trigger Handler for trigger written on EnquiryRelationship__c.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public with sharing class GEMS_EnquiryRelationshipTriggerHandler {
    
    /**
     * [Execute_BI Execute before insert operations]
     * @param enquiryRelationList
     */
    public void Execute_BI(list<EnquiryRelationship__c> enquiryRelationList) {
    	GEMS_EnquiryRelationshipTriggerHelper.updateEnquiryDetails(enquiryRelationList);
    }
     
}