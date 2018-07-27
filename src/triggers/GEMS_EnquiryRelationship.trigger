/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   13th March 2017
    Description :   Trigger written on EnquiryRelationship__c.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
trigger GEMS_EnquiryRelationship on EnquiryRelationship__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    GEMS_EnquiryRelationshipTriggerHandler handler = new GEMS_EnquiryRelationshipTriggerHandler();
    
    //Execute Before Insert Operations
    if(Trigger.isBefore && Trigger.isInsert){
        handler.Execute_BI(Trigger.New);
    }
    
}