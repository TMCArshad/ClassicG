/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   27th April 2017
    Description :   Custom Code to update the Sibling Id on Service Request
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    Version      Author     Date               Description
    v1.0        Leeba      17/01/2018      Added the check to link sibling only if the Sibling's GEMS school is same as the Application school
    v1.1        Leeba      29/4/2018       Made Lead Reference as External Id,removed the sibling id condition and created a custom label to store the Enrolled status 
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global without sharing class GEMS_CC_Update_SR_SiblingId implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c ServiceRequest, HexaBPM__Step__c step) {
        string strResult = 'Success';
        GEMS_checkRecursiveTriggers.runOnceForEnrolledSR=true;
        if(step!=null && step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r!=null){
            HexaBPM__Service_Request__c objSR = step.HexaBPM__SR__r;
            map<string,HexaBPM__Service_Request__c> MapLeafRef = new map<string,HexaBPM__Service_Request__c>();
            /*
            for(HexaBPM__Service_Request__c Sr:[Select Id,Lead_Reference__c,Sibling_Fee_Id_Verified__c,Sibling_Fee_ID__c,Sys_GEMS_School_Sibling__c from HexaBPM__Service_Request__c where Id!=:step.HexaBPM__SR__c and Lead_Reference__c=:step.HexaBPM__SR__r.Lead_Reference__c and Sibling_Fee_ID__c!=null and HexaBPM__External_Status_Name__c='Enrolled']){
                MapLeafRef.put(sr.Lead_Reference__c,Sr);
            }
            */
            //v1.1
            string EnrolledStatus = label.EnrolledStatusId;
            if(step.HexaBPM__SR__r.Lead_Reference__c!=null && step.HexaBPM__SR__r.Lead_Reference__c!=''){
            
                for(HexaBPM__Service_Request__c Sr:[Select Id,Lead_Reference__c,Sibling_Fee_Id_Verified__c,Sibling_Fee_ID__c,Sys_GEMS_School_Sibling__c from HexaBPM__Service_Request__c where Lead_Reference__c=:step.HexaBPM__SR__r.Lead_Reference__c and HexaBPM__External_SR_Status__c=:EnrolledStatus and Id!=:step.HexaBPM__SR__c]){
                    MapLeafRef.put(sr.Lead_Reference__c,Sr);
                }
            }
            boolean checkOtherConditions = true;
            //v1.0 - check for sibling school same as application school
            
            if(objSR.Sibling_Fee_Id_Verified__c!=null && objSR.School__c!=null && objSR.Sibling_Fee_Id_Verified__c=='Yes'&& objSR.Sibling_Fee_ID__c!=null && objSR.Sibling_Fee_ID__c!='' && objSR.Sys_GEMS_School_Sibling__c == objSR.School__c ){
                objSR.Sibling_Fee_ID__c = objSR.Sibling_Fee_ID__c;
                if(objSR.Sibling_Fee_ID__c!=null && objSR.Sibling_Fee_ID__c.length()==14){
                    for(Account acc:[Select id,Sibling_ID__c from Account where School__c=:objSR.School__c and Student_Id__c=:objSR.Sibling_Fee_ID__c and (RecordType.DeveloperName='Student' or RecordType.DeveloperName='Student_Read_Only')]){
                        objSR.Sibling_Fee_ID__c = acc.Sibling_ID__c;
                        checkOtherConditions = false;
                    }
                }else{
                    for(Account acc:[Select id,Sibling_ID__c from Account where School__c=:objSR.School__c and Fee_ID__c=:objSR.Sibling_Fee_ID__c and (RecordType.DeveloperName='Student' or RecordType.DeveloperName='Student_Read_Only')]){
                        objSR.Sibling_Fee_ID__c = acc.Sibling_ID__c;
                        checkOtherConditions = false;
                    }
                }
            }
            if(checkOtherConditions){
                if(objSR.Lead_Reference__c!=null && MapLeafRef.get(objSR.Lead_Reference__c)!=null && MapLeafRef.get(objSR.Lead_Reference__c).Sibling_Fee_ID__c!=null){
                     objSR.Sibling_Fee_ID__c = MapLeafRef.get(objSR.Lead_Reference__c).Sibling_Fee_ID__c;
                }else{
                    objSR.Sibling_Fee_ID__c = objSR.StudentId__c;
                    objSR.Sibling_Fee_Id_Verified__c = 'No';
                }
            }
            try{
                update objSR;
            }catch(Exception e){
                strResult = e.getMessage()+'';
            }
        }
        return strResult;
    }
}