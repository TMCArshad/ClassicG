/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   9th April 2017
    Description :   Handler for SR trigger
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
     v1.0    12thMar2018  Leeba    Enrollment SR validation
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_SRTriggerHandler {
    public GEMS_SRTriggerHandler() { 
        
    }
    
    /**
     * [Execute_BI Execute before insert operations]
     * @param SRList
     */
    public void Execute_BI(list<HexaBPM__Service_Request__c> SRList) {
           GEMS_SRTriggerHelper.updateLeadStatus(SRList,NULL); //Sync Lead status 
           GEMS_SRTriggerHelper.assignSROwner(SRList); //calling method to insert owner depending on school
           GEMS_SRTriggerHelper.validateSrCreation(SRList);
           GEMS_SRTriggerHelper.validateOpenSRs(SRList); 
           //Copy fields on SR from related Objects -End 
           GEMS_SRTriggerHelper.updateFieldsForSROnInsert(SRList);
           GEMS_SRTriggerHelper.CheckSchoolExists(SRList);
    }
    
    /**
     * [Execute_AI Execute after insert operations]
     * @param SRList 
    */
    public void Execute_AI(list<HexaBPM__Service_Request__c> SRList) {
        list<string> lstSRIDs = new list<string>();
        for(HexaBPM__Service_Request__c objSR : SRList){
            if(objSR.HexaBPM__Record_Type_Name__c=='Enrollment' && objSR.Enquiry_from_Oasis__c==false && objSR.sys_Send_Enquiry_Parent_Details__c==false)
                lstSRIDs.add(objSR.Id);
        }
        if(lstSRIDs.size()>0 && system.isFuture()==false && System.isBatch()==false)
            GEMS_SRTriggerHelper.UpdateInformaticaCheckBox(lstSRIDs);
    }
    
    
    /**
     * [Execute_BU Execute before update operations]
     * @param SRList,Map<Id,HexaBPM__Service_Request__c>oldMap
    */
    public void Execute_BU(list<HexaBPM__Service_Request__c> TriggerNew, map<Id, HexaBPM__Service_Request__c> oldMap) {
        //updateDateOfLeaving 
        //Upadte date of leaving if registrar enters LDA (Oasis)
        //GEMS_SRTriggerHelper.updateDateOfLeaving(TriggerNew);
         
         
        GEMS_SRTriggerHelper.UpdateStudentId(TriggerNew,oldMap);// calling the method to update the Student Id
        GEMS_SRTriggerHelper.updateFieldsForSROnUpdate(TriggerNew,oldMap);
        GEMS_SRTriggerHelper.updateLeadStatus(TriggerNew,oldMap); //Sync Lead status 
        GEMS_SRTriggerHelper.updateRelatedSR(TriggerNew,oldMap); //calling method to update all related SR with parent details
                
        
    }
    
    /**
     * [Execute_AU Execute after update operations]
     * @param SRList,Map<Id,HexaBPM__Service_Request__c>oldMap
    */
    public void Execute_AU(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> oldMap) {
        
        GEMS_SRTriggerHelper.UpdateSRPriceItemStatus(SRList,oldMap); // calling method to update the status of SR PriceItem on update from Oasis on Registration and Assessment fees paid at the counter
        GEMS_SRTriggerHelper.CloseCriticalUpdateSteps(SRList,oldMap); // calling the method to update the status of Step and SR after the Edit Critical details is approved or rejected by Finance in Oasis
        
        GEMS_SRTriggerHelper.reEvaluateFeeAmount(SRList,oldMap);
        GEMS_SRTriggerHelper.srReadOnly(SRList,oldMap);//to check if the Enrollment SR is Enrolled.If yes throw error--v1.0
    }   
    
    public void Execute_IA(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> oldMap) {
        GEMS_SRTriggerHelper.updateURL(SRList,oldMap);
    }   
    
    
}