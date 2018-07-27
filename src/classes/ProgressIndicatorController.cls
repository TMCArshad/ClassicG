/*
 * Created on Thu Apr 13 2017
 * Author: Rajil Ravindran
 * Gets the Step Processes and the Time specs of the Service Requests 
 */
public with sharing class ProgressIndicatorController{
    public string strTemplateId = '';
    public string strSRID = '';
    public map<string,string> MapGroupData{get;set;}
    public list<StepGroupWrap> lstGroupWrap{get;set;}
    public string GroupWidth{get;set;} //Steps Group width to align on the SR Page
    public string totalTime {get;set;} //Total Timetaken for SR
    public string totalSLA {get;set;}  // SLA for the Serive Request
    public string srStatus {get;set;} //Serivce Request Status
    public string SRType {get; set;}

    public ProgressIndicatorController(ApexPages.StandardController stdController) {
        MapGroupData = new map<string,string>();
        Datetime submittedDateTime;
        lstGroupWrap = new list<StepGroupWrap>();
        if(apexpages.currentPage().getParameters().get('Id')!=null){
            strSRID = apexpages.currentPage().getParameters().get('Id');
            for(HexaBPM__Service_Request__c sr:[select id,HexaBPM__SR_Template__c,SR_Type__c, HexaBPM__Submitted_DateTime__c,HexaBPM__External_SR_Status__r.Name from HexaBPM__Service_Request__c where Id=:strSRID]){
              strTemplateId = sr.HexaBPM__SR_Template__c;
              submittedDateTime = sr.HexaBPM__Submitted_DateTime__c;
              srStatus=sr.HexaBPM__External_SR_Status__r.Name;
                SRType = sr.SR_Type__c;
            }
            Datetime currentDateTime = DateTime.now();
            if(submittedDateTime != null)
            {
              Long seconds = (currentDateTime.getTime() - submittedDateTime.getTime()) / 1000;
              Long minutes = seconds / 60;
              Long hours = minutes / 60;
              totalTime = String.valueOf(hours)+ ' hour(s)';
            }
            //Prepares the Step Group 
            PrepareGroups();
          }
    }
    public void PrepareGroups(){
      if(strTemplateId!=null && strTemplateId!=''){
        StepGroupWrap objGrpWrap;
        map<string,integer> mapGroupIndex = new map<string,integer>();
        map<string,list<HexaBPM__SR_Steps__c>> MapGroupSteps = new map<string,list<HexaBPM__SR_Steps__c>>();
        for(HexaBPM__SR_Steps__c SRStp : [select Id,Name,HexaBPM__Step_No__c,HexaBPM__Summary__c,groupname__c,HexaBPM__SR_template__r.HexaBPM__Estimated_Hours__c,(select Id,HexaBPM__SR__c,Step_SLA__c,ActualTimeTakenMins__c,HexaBPM__Closed_Date__c,HexaBPM__Status_Type__c,HexaBPM__SR_Step__c,HexaBPM__Sys_Step_Loop_No__c,HexaBPM__Summary__c from HexaBPM__Steps__r where HexaBPM__SR__c=:strSRID) from HexaBPM__SR_Steps__c where HexaBPM__SR_Template__c=:strTemplateId and groupname__c!=null order by HexaBPM__Step_No__c]){
            list<HexaBPM__SR_Steps__c> lstSRSteps = new list<HexaBPM__SR_Steps__c>();
            if(MapGroupSteps.get(SRStp.groupname__c)==null){
              objGrpWrap = new StepGroupWrap();
              objGrpWrap.GroupLabel = SRStp.groupname__c;
              objGrpWrap.GroupShortLabel = string.valueOf(lstGroupWrap.size()+1);
              totalSLA = SRStp.HexaBPM__SR_template__r.HexaBPM__Estimated_Hours__c != null ? string.valueOf(SRStp.HexaBPM__SR_template__r.HexaBPM__Estimated_Hours__c) + ' hour(s)' : '0';
              lstGroupWrap.add(objGrpWrap);
            }else{
              lstSRSteps = MapGroupSteps.get(SRStp.groupname__c); 
            }
            lstSRSteps.add(SRStp);
            MapGroupSteps.put(SRStp.groupname__c,lstSRSteps);
          }
          if(lstGroupWrap!=null && lstGroupWrap.size()>0 && MapGroupSteps!=null && MapGroupSteps.size()>0){
            for(StepGroupWrap SGW:lstGroupWrap){
              list<StepGroupChildData> lstChilds = new list<StepGroupChildData>();
              for(HexaBPM__SR_Steps__c SRStep:MapGroupSteps.get(SGW.GroupLabel)){
                if(SRStep.HexaBPM__Steps__r!=null && SRStep.HexaBPM__Steps__r.size()>0){
                  for(HexaBPM__Step__c stp:SRStep.HexaBPM__Steps__r){
                    StepGroupChildData CD = new StepGroupChildData();
                    CD.hasStep = true;
                    //if(SRStep.HexaBPM__Step_Type__c!=null && SRStep.HexaBPM__Step_Type__c=='Document Check')
                        //CD.DocumentCheckStep = true;
                    //else if(SRStep.HexaBPM__Step_Type__c!=null && SRStep.HexaBPM__Step_Type__c=='Quick Action')
                        CD.QuickActionStep = true;
                    CD.StepSummary = stp.HexaBPM__Summary__c;
                    CD.StepId = stp.Id;
                    CD.ActionType = 'Quick Action';
                    CD.SRID = stp.HexaBPM__SR__c;
                    CD.StepLoop = stp.HexaBPM__Sys_Step_Loop_No__c;
                    if(stp.HexaBPM__Status_Type__c!='End'){
                        SGW.CurrentGroup = true;
                        CD.IsOpen = true;
                    }else if(stp.HexaBPM__Status_Type__c=='End'){
                        CD.IsClosed = true;
                    }
                    if(stp.ActualTimeTakenMins__c!=null && stp.ActualTimeTakenMins__c > 59) //Consider only hours, ignoring minutes
                    {
                      decimal actualTimeInMins = stp.ActualTimeTakenMins__c/60;
                      CD.SLA = string.valueOf(math.floor(actualTimeInMins))+' hour(s)';
                    }
                    lstChilds.add(CD);
                  }
                }else{
                  StepGroupChildData CD = new StepGroupChildData();
                  SGW.Passed_Group = false;
                  CD.hasStep = false;
                  CD.StepSummary = SRStep.HexaBPM__Summary__c;
                  lstChilds.add(CD);
                }
              }
              SGW.lstChilds = lstChilds;
            }
          }
          system.debug('lstGroupWrap===>'+lstGroupWrap);
          if(lstGroupWrap!=null && lstGroupWrap.size()>0)
          {
            Decimal dLstGroupSize = lstGroupWrap.size();
            Decimal dGroupWidth = 100/dLstGroupSize;
            GroupWidth = String.valueOf(dGroupWidth.setScale(3))+'%';
          }
          system.debug('GroupWidth===>'+GroupWidth);
      }
    }
    public class StepGroupWrap{
        public string GroupLabel{get;set;}
        public string GroupShortLabel{get;set;}
        public boolean CurrentGroup{get;set;}
        public boolean Passed_Group{get;set;}
        public list<StepGroupChildData> lstChilds{get;set;}
        public StepGroupWrap(){
            lstChilds = new list<StepGroupChildData>();
            CurrentGroup = false;
            Passed_Group = true;
        }
    }
    public class StepGroupChildData{
        public string StepSummary{get;set;}
        public string StepId{get;set;}
        public string SRID{get;set;}
        public string StepLoop{get;set;}
        public boolean hasStep{get;set;}
        public boolean IsOpen{get;set;}
        public string helpText {get;set;}
        public boolean IsClosed{get;set;}
        public string SLA{get;set;}
        public boolean QuickActionStep{get;set;}
        public boolean DocumentCheckStep{get;set;}
        public string ActionType{get;set;}
        public StepGroupChildData(){
          IsOpen = false;
          IsClosed = false;
          DocumentCheckStep = false;
          QuickActionStep = false;
          ActionType = '';
          helpText = '';
        }  
    }
}