/******************************************************************************************
*  Author         :   Durga
*  Company        :   HexaBPM
*  Date           :   11-April-2017
*  Description    :   Apex Controller for Step Transition Window
*  Version        :   1.0
********************************************************************************************/
public without sharing class QuickStepTransitionController{
    public HexaBPM__Step__c step{get;set;}
    public string SRID{get;set;}
    public string StepID{get;set;}
    public boolean hasAccess{get;set;}
    User objCurrentUser;
    public map<string,string> MapDelegatedUsers;
    public string userType{get;set;}
    public list<TransitionWrapper> lstTrnsWrap{get;set;}
    public Integer iListSize{get;set;}
    map<id,HexaBPM__Step_Transition__c> mapStepTransition;
    public QuickStepTransitionController(ApexPages.StandardController controller){
        lstTrnsWrap = new list<TransitionWrapper>();
        iListSize = 0;
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
        }
        step = new HexaBPM__Step__c();
        if(apexpages.currentpage().getParameters().get('StepId')!=null){
           StepID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('StepId'));
           
               for(HexaBPM__Step__c stp:[select Id,Name,
                                                HexaBPM__Summary__c,
                                                RecordTypeId,
                                                HexaBPM__Step_Status__c,
                                                RecordType.DeveloperName,
                                                OwnerId,Owner.Name,
                                                RecordType.Name,
                                                HexaBPM__Parent_Step__c,
                                                HexaBPM__SR__c,
                                                HexaBPM__SR__r.HexaBPM__SR_Template__c,
                                                HexaBPM__Status__c,
                                                HexaBPM__SR_Step__c,
                                                HexaBPM__Rejection_Reason__c,
                                                HexaBPM__Status__r.Name 
                                        from HexaBPM__Step__c
                                        where   Id=:StepID
                                                and HexaBPM__SR__c!=null
                                                and HexaBPM__SR__r.HexaBPM__SR_Template__c!=null 
                                                and IsDeleted=false]){
                   step = stp;
               }
           
        }
        hasAccess = false;
        objCurrentUser = new User();
        
            for(User curUser:[select Id,ContactId,ProfileId,Profile.UserLicenseId,Profile.UserLicense.Name,Profile.UserLicense.LicenseDefinitionKey,Profile.Name from User where Id=:userInfo.getUserId() and IsActive=true]){
                objCurrentUser = curUser;
                if(curUser.ContactId==null){
                    userType = 'salesforce';
                }else{
                    userType = 'Community';
                }
            }
        
    }
    /**
     * Method Name : Spin
     * Description : Method for simulating an online service check callout.  
     **/ 
    public void spin() {
        if(step.HexaBPM__Summary__c =='Online System Check'){
            long now = datetime.now().gettime();
            while(datetime.now().gettime()-now<1500); // Busy loop for 5000 ms
        }
        Check_Permissions();
    }
    /**
     * Method Name : Check_Permissions
     * Desription : Checks if the current user has access to make the required transition selection or not.
     **/
    public void Check_Permissions(){
        MapDelegatedUsers = new map<string,string>();
        MapDelegatedUsers = SetupObjectDataHelper.GetDelegatedUsers(objCurrentUser.Id);
        if(step.OwnerId==userinfo.getUserId() || (MapDelegatedUsers!=null && MapDelegatedUsers.get(step.OwnerId)!=null) || (objCurrentUser!=null && string.valueof(objCurrentUser.Profile.Name).indexof('System Administrator')>-1)){
            hasAccess = true;
        }else if(userType!=null && userType=='Community'){
            hasAccess = true;
        }else{
            if(string.valueOf(step.OwnerId).substring(0,3)=='00G'){
                 for(SetupObjectDataHelper.GroupDetails GD:SetupObjectDataHelper.getGroupData(step.OwnerId)){
                    if(GD.GroupOrUserId==userinfo.getUserId()){
                        hasAccess = true;
                        break;
                    }
                }
            }
        }
        //hasAccess = false;
        Prepare_Transitions();
    }
    /**
     * Method Name : Prepare_Transitions
     * Description : Queries all transitions from the current step and sets the valid possible transitions and maps it to a map value
     **/
    public void Prepare_Transitions(){
        set<id> setValidSteps = new set<id>();
        mapStepTransition = new map<id,HexaBPM__Step_Transition__c>();
        if(userType=='salesforce'){
            for(HexaBPM__Step_Transition__c trans:[select HexaBPM__From__c,HexaBPM__To__c,HexaBPM__Transition__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__SR_Step__c,HexaBPM__SR_Status_External__c,HexaBPM__SR_Status_Internal__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__From__c=:step.HexaBPM__Status__r.Name and HexaBPM__SR_Step__c=:step.HexaBPM__SR_Step__c and IsDeleted=false]){
                setValidSteps.add(trans.HexaBPM__Transition__r.HexaBPM__To__c);
                mapStepTransition.put(trans.HexaBPM__Transition__r.HexaBPM__To__c,trans);
            }
        }else{
            for(HexaBPM__Step_Transition__c trans:[select HexaBPM__From__c,HexaBPM__To__c,HexaBPM__Transition__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__SR_Step__c,HexaBPM__SR_Status_External__c,HexaBPM__SR_Status_Internal__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__From__c=:step.HexaBPM__Status__r.Name and HexaBPM__SR_Step__c=:step.HexaBPM__SR_Step__c and HexaBPM__Display_on_Portal__c=true and IsDeleted=false]){
                setValidSteps.add(trans.HexaBPM__Transition__r.HexaBPM__To__c);
                mapStepTransition.put(trans.HexaBPM__Transition__r.HexaBPM__To__c,trans);
            }
        }
        if(setValidSteps!=null && setValidSteps.size()>0){
            TransitionWrapper objWrap;
            for(HexaBPM__Status__c objstat:[Select Id,Name,HexaBPM__Type__c,HexaBPM__Rejection__c,HexaBPM__SR_Closed_Status__c,HexaBPM__Code__c from HexaBPM__Status__c where ID IN:setValidSteps and IsDeleted=false order by HexaBPM__Code__c desc]){
                objWrap = new TransitionWrapper();
                objWrap.objStatus = objstat;
                objWrap.objSRStepTrans = new HexaBPM__Step_Transition__c();
                if(mapStepTransition.get(objstat.id)!=null)
                    objWrap.objSRStepTrans = mapStepTransition.get(objstat.id);
                lstTrnsWrap.add(objWrap);                     
            }
            iListSize = lstTrnsWrap.size();
        }
    }
    public string selTransition{get;set;}
    public string RejReason{get;set;}
    public string StepNotes{get;set;}
    /**
     * Method Name : SaveChanges
     * Description : Method invoked on click of proceed button. Updates the status of the step to the selected step transition value.
     **/
    public pagereference SaveChanges(){
        pagereference pg;
        if(selTransition!=null && mapStepTransition.get(selTransition)!=null){
            Savepoint Stat_svpoint = Database.setSavepoint();
            try{
                pg = new PageReference('/'+SRID);
                pg.setRedirect(true);
                if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c!=null && mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c!=null){
                    HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=SRID);
                    if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c!=null
                        && Schema.sObjectType.HexaBPM__Service_Request__c.fields.HexaBPM__Internal_SR_Status__c.isUpdateable())
                        objSR.HexaBPM__Internal_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c;
                    if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c!=null
                        && Schema.sObjectType.HexaBPM__Service_Request__c.fields.HexaBPM__External_SR_Status__c.isUpdateable())
                        objSR.HexaBPM__External_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c;
                   if(HexaBPM__Service_Request__c.sObjectType.getDescribe().isUpdateable())
                    update objSR;
                }
                if(Schema.sObjectType.HexaBPM__Step__c.fields.HexaBPM__Status__c.isUpdateable())
                step.HexaBPM__Status__c = mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__c;
                if(Schema.sObjectType.HexaBPM__Step__c.fields.HexaBPM__Step_Notes__c.isUpdateable())
                step.HexaBPM__Step_Notes__c = StepNotes;
                if(Schema.sObjectType.HexaBPM__Step__c.fields.HexaBPM__Rejection_Reason__c.isUpdateable())
                step.HexaBPM__Rejection_Reason__c = RejReason;
                System.debug('RejReason=>'+RejReason);
                if(HexaBPM__Step__c.sObjectType.getDescribe().isUpdateable())
                update step;
            }catch(DMLException e){
                string DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage()+'';
                }
                selTransition = null;
                Database.rollback(Stat_svpoint);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select the status to proceed.'));
            return null;
        }
        return pg;
    }
    /**
     * Method Name : ViewStep
     * Description : Method invoked on click of the View Step button. Redirects the page to the Step Detail page
     **/    
    public pagereference ViewStep(){
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
    /**
     * Wrapper Class
     **/
    public class TransitionWrapper{
        public HexaBPM__Status__c objStatus{get;set;}
        public HexaBPM__Step_Transition__c objSRStepTrans{get;set;}
    }
}