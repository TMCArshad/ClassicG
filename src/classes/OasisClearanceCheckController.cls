/******************************************************************************************
*  Author         :   Durga
*  Company        :   HexaBPM
*  Date           :   11-April-2017
*  Description    :   Apex Controller for Oasis Clearance Check
*  Version        :   1.0
********************************************************************************************/
public with sharing class OasisClearanceCheckController{
    public HexaBPM__Step__c step{get;set;}
    public string SRID{get;set;}
    public string StepID{get;set;}
    public string userType{get;set;}
    public OasisClearanceCheckController(ApexPages.StandardController controller){
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
        }
        step = new HexaBPM__Step__c();
        if(apexpages.currentpage().getParameters().get('StepId')!=null){
           StepID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('StepId'));
           for(HexaBPM__Step__c stp:[select Id,Name,Step_Name__c,HexaBPM__Step_No__c,OASIS_Clearance_Status__c,HexaBPM__Summary__c,HexaBPM__Step_Status__c,HexaBPM__SR__c,HexaBPM__Status__c,HexaBPM__SR_Step__c,HexaBPM__Rejection_Reason__c,
               HexaBPM__Status__r.Name,HexaBPM__SR__r.Student__c,HexaBPM__SR__r.Student__r.Student_Id__c from HexaBPM__Step__c where Id=:StepID and HexaBPM__SR__c!=null and HexaBPM__SR__r.HexaBPM__SR_Template__c!=null]){
               step = stp;
           }
        }
    }
    public void CheckClearance(){
        if(step!=null && step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r.Student__c!=null && step.HexaBPM__SR__r.Student__r.Student_Id__c != NULL ){
           string clearance = GEMS_FeeServiceUtility.checkStatusForTCClearance(step.HexaBPM__SR__r.Student__r.Student_Id__c);
           step.OASIS_Clearance_Status__c = clearance;
           update step;
         }
    }
    public string RejReason{get;set;}
    public pagereference ApproveStep(){
        pagereference pg;
        Savepoint Stat_svpoint = Database.setSavepoint();
        try{
            pg = new PageReference('/'+SRID);
            pg.setRedirect(true);
            
        }catch(DMLException e){
            string DMLError = e.getdmlMessage(0)+'';
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            Database.rollback(Stat_svpoint);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
            return null;
        }
        return pg;
    }
  
    public pagereference RejectStep(){
        Pagereference pg = new Pagereference('/'+StepID);
        pg.setredirect(true);
        return pg;
    }
    /**
     * Method Name : CancelAction
     * Description : Method invoked on click of the cancel button. Redirects the page back to the SR Detail page
     **/
    public pagereference CancelAction(){
        Pagereference pg = new Pagereference('/'+SRID);
        pg.setredirect(true);
        return pg;
    }
}