/*****************************************************************************************************************************
    Author      :   Keerthan Tantry
    Date        :   19th March 2017
    Description :   Batch class to delete draft scholarship and inactive OTP's
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global without sharing class GEMS_Batch_deleteSR implements Database.Batchable<sObject>,Database.AllowsCallouts{ 
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String scholarshipSR = 'SELECT ID FROM HexaBPM__Service_Request__c WHERE HexaBPM__Record_Type_Name__c = \'Scholarship\' AND HexaBPM__External_Status_Name__c = \'Draft\'  ' ;
        return Database.getQueryLocator(scholarshipSR); 
    } 
    global void execute(Database.BatchableContext BC,list<HexaBPM__Service_Request__c> lstSR){ 
        try{ 
            if(lstSR!=null && lstSR.size()>0) 
                delete lstSR; 
        }catch(Exception e){ 

        } 

    } 
    global void finish(Database.BatchableContext BC){ 

    }        
}