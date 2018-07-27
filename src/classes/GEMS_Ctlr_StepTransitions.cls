public without sharing class GEMS_Ctlr_StepTransitions{
    public HexaBPM__Step__c step{get;set;}
    public String CancelLink {get;set;}
    public String StepLink {get;set;}
    public string SRID{get;set;}
    public string StepID{get;set;}
    public boolean hasAccess{get;set;}
    User objCurrentUser;
    public map<string,string> MapDelegatedUsers;
    public string userType{get;set;}
    public list<TransitionWrapper> lstTrnsWrap{get;set;}
    public Integer iListSize{get;set;}
    map<id,HexaBPM__Step_Transition__c> mapStepTransition;
    public GEMS_Ctlr_StepTransitions(ApexPages.StandardController controller){
        lstTrnsWrap = new list<TransitionWrapper>();
        iListSize = 0;
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            SRID = apexpages.currentpage().getParameters().get('Id');
        }
        step = new HexaBPM__Step__c();
        if(apexpages.currentpage().getParameters().get('StepId')!=null){
           StepID = apexpages.currentpage().getParameters().get('StepId');
           for(HexaBPM__Step__c stp:[SELECT Id, Name, HexaBPM__Summary__c, RecordTypeId, HexaBPM__Step_Status__c,  
           									RecordType.DeveloperName, OwnerId, Owner.Name, RecordType.Name, HexaBPM__Parent_Step__c, 
           									HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__SR_Template__c, HexaBPM__Status__c, HexaBPM__SR_Step__c, 
           									HexaBPM__Rejection_Reason__c, HexaBPM__Status__r.Name 
           							FROM HexaBPM__Step__c 
									WHERE id!=null and Id=:StepID and HexaBPM__SR__c!=null and HexaBPM__SR__r.HexaBPM__SR_Template__c!=null and IsDeleted=false]){
               step = stp;
           }
        }
        hasAccess = false;
        objCurrentUser = new User();
        for(User curUser:[select Id,ContactId,ProfileId,Profile.UserLicenseId,Profile.UserLicense.Name,Profile.UserLicense.LicenseDefinitionKey,Profile.Name from User where id!=null and Id=:userInfo.getUserId() and IsActive=true]){
            objCurrentUser = curUser;
            if(curUser.ContactId==null){
                userType = 'salesforce';
                CancelLink = '/'+SRID;
                StepLink =  '/'+StepId;
            }else{
                userType = 'Community';
                CancelLink = '/GEMS/'+SRID;
                StepLink =  '/GEMS/'+StepId;
            }
        }
    }
    public void Check_Permissions(){
        MapDelegatedUsers = new map<string,string>();
        MapDelegatedUsers = GetDelegatedUsers(objCurrentUser.Id);
        if(step.OwnerId==userinfo.getUserId() || MapDelegatedUsers.get(step.OwnerId)!=null || (objCurrentUser!=null && objCurrentUser.Profile.Name=='System Administrator')){
            hasAccess = true;
        }else if(userType!=null && userType=='Community'){
            hasAccess = true;
        }else{
            if(string.valueOf(step.OwnerId).substring(0,3)=='00G'){
                getGroupData(step.OwnerId);
                system.debug('#### lstGroupsData = '+lstGroupsData);
                for(GroupDetails GD:lstGroupsData){
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
            for(HexaBPM__Status__c objstat:[Select Id,Name,HexaBPM__Type__c,HexaBPM__Rejection__c,HexaBPM__SR_Closed_Status__c,HexaBPM__Code__c from HexaBPM__Status__c where ID!=null and ID IN:setValidSteps and IsDeleted=false]){
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
    public pagereference SaveChanges(){
        pagereference pg;
        if(selTransition!=null && mapStepTransition.get(selTransition)!=null){
            /* Savepoint can only be set after making the callout*/
	        Savepoint Stat_svpoint = Database.setSavepoint();
            try{
                pg = new PageReference('/'+SRID);
                pg.setRedirect(true);
                if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c!=null && mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c!=null){
                    HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=SRID);
                    if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c!=null)
                        objSR.HexaBPM__Internal_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__SR_Status_Internal__c;
                    if(mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c!=null)
                        objSR.HexaBPM__External_SR_Status__c = mapStepTransition.get(selTransition).HexaBPM__SR_Status_External__c;
                    update objSR;
                }
                step.HexaBPM__Status__c = mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__c;
                step.HexaBPM__Step_Notes__c = StepNotes;
                step.HexaBPM__Rejection_Reason__c = RejReason;
                Boolean isReuploadStat = true;
                HexaBPM__Status__c stpStatus = [Select Id,Name,HexaBPM__Type__c,HexaBPM__Rejection__c,HexaBPM__SR_Closed_Status__c,HexaBPM__Code__c from HexaBPM__Status__c where id!=null and id=:(mapStepTransition.get(selTransition).HexaBPM__Transition__r.HexaBPM__To__c) and IsDeleted=false];
                      if(stpStatus!=null && (stpStatus.HexaBPM__Code__c=='REUPLOAD_DOCUMENT'||stpStatus.HexaBPM__Code__c=='DOCUMENT_RE_UPLOADED') && step.HexaBPM__SR__c!=null){
				           /* isReuploadStat = true;
				            set<Id> setSRIDs = new set<Id>();
				            setSRIDs.add(step.SR__c);
				            if(step.SR__r.Parent_SR__c!=null)
				                setSRIDs.add(step.SR__r.Parent_SR__c);*/
				                boolean isReuploadRequired = false; 
				            for(HexaBPM__SR_Doc__c srDoc:[select id from HexaBPM__SR_Doc__c where id!=null and HexaBPM__Service_Request__c =:step.HexaBPM__SR__c and HexaBPM__Status__c = 'Re-upload' limit 1]){
				                isReuploadRequired = true;
				                break;
				            }
				            if(isReuploadRequired!=true && stpStatus.HexaBPM__Code__c=='REUPLOAD_DOCUMENT'){
					            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please change at least one document to “re-upload” status in SR Documents before changing the step status to Re-upload Document.'));
					        	isReuploadStat = false;
					        	return null;
					        }
							else if(isReuploadRequired==true && stpStatus.HexaBPM__Code__c=='DOCUMENT_RE_UPLOADED'){
					            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Re-upload the required document and click “Save” button in SR Documents screen.'));
					        	isReuploadStat = false;
					        	return null;
					        }
														            
				      }
				if(isReuploadStat==true)             
                	update step;
                
            }catch(DMLException e){
                string DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage() +' ';
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
    public static map<string,string> GetDelegatedUsers(string CurrentUserId){
        map<string,string> MapDelegatedUsers = new map<string,string>();
        for(User usr:[select Id,DelegatedApproverId from User where id!=null AND DelegatedApproverId=:CurrentUserId]){
            MapDelegatedUsers.put(usr.Id,usr.DelegatedApproverId);
        }
        return MapDelegatedUsers;
    }
    public static list<GroupDetails> lstGroupsData = new list<GroupDetails>();
    public static list<GroupDetails> getGroupData(string strGroupId){
        if(lstGroupsData.size()==0){
            set<string> setInnerGrps = new set<string>();
            for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where id!=null AND GroupId=:strGroupId]){
                GroupDetails objGrp = new GroupDetails();
                objGrp.GroupOrUserId = GrpMem.UserOrGroupId;
                if(string.valueOf(GrpMem.UserOrGroupId).substring(0,3)=='00G')
                    setInnerGrps.add(GrpMem.UserOrGroupId);
                lstGroupsData.add(objGrp);
            }
            if(setInnerGrps!=null && setInnerGrps.size()>0){
                for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where id!=null AND GroupId IN:setInnerGrps]){
                    GroupDetails objGrp = new GroupDetails();
                    objGrp.GroupOrUserId = GrpMem.UserOrGroupId;
                    lstGroupsData.add(objGrp);
                }
            }
        }
        return lstGroupsData;
    }
    public class TransitionWrapper{
        public HexaBPM__Status__c objStatus{get;set;}
        public HexaBPM__Step_Transition__c objSRStepTrans{get;set;}
    }
    public class GroupDetails{
        public string GroupOrUserId;
    }
}