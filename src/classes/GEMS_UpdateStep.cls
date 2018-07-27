/*****************************************************************************************************************************
    Author      :   Keerthan Tantry
    Date        :   7th March 2017
    Description :   Class used to invoke action from Step of  SR to check OASIS clearance status for the given Student ID
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global without sharing class GEMS_UpdateStep {
    /**
     * [GEMS_UpdateStep Updates  Clearance status on Step ]
     * @param  stepId    [Id of the step where  clearance is expected]
     * @param  studentID [Student ID information]
     * @return           [clearance status]
     */
    Webservice static resultWrapper updateClearanceStatus(String stepId){
        resultWrapper resultW = new resultWrapper();
        try{
         
         GEMS_FeeServiceUtility.TCClearanceWrapper tw = new GEMS_FeeServiceUtility.TCClearanceWrapper();
         HexaBPM__Step__c step = [Select ID,OASIS_Clearance_Status__c,HexaBPM__SR__r.StudentId__c from HexaBPM__Step__c Where Id=: stepId];
         System.debug('==>'+step.HexaBPM__SR__r.StudentId__c);
         if(step.HexaBPM__SR__r.StudentId__c != NULL ){ 
           tw = GEMS_FeeServiceUtility.checkStatusForTCClearance(step.HexaBPM__SR__r.StudentId__c);
           
           resultW.result = (tw.clearanceStatus == 'NO' ) ?  tw.clearanceMessage  : 'No pending amount to clear.';
           resultW.successFlag = (tw.clearanceStatus == 'YES' ) ? true :false;
           step.OASIS_Clearance_Status__c= tw.clearanceStatus;
           step.OASIS_Clearance_Message__c = tw.clearanceMessage; 
           update step;
           
         }
         else{
            step.OASIS_Clearance_Status__c= NULL;
            update step;
            resultW.successFlag =false;
            resultW.result = 'Invalid Student ID.';
             
         }
         
         }catch(Exception e){
            GEMS_Utility.LogException( e);
            resultW.successFlag = false;
            resultW.result = e.getMessage();
            return NULL;
         }
      return resultW;   
    } 

    Webservice static String acceptStep(String stepId){

        String result = 'Success';
        try{
            HexaBPM__Step__c step = new HexaBPM__Step__c(id =stepId);
            step.ownerId = UserInfo.getUserId();
            update step;
        }catch(Exception e){
               
               GEMS_Utility.LogException(e);
               result = e.getMessage();
               return result;
        }

      return result;
    }
   global class resultWrapper{
    Webservice String result {get;set;}
    Webservice Boolean successFlag {get;set;}
    public resultWrapper(){
        
    }
    public resultWrapper(String result, Boolean successFlag){
        this.result = result;
        this.successFlag = successFlag;
    }
 }   
}