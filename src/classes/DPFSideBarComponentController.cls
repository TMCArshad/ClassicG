/*
  Author    :  Durga Prasad
  Description  :  Controller which will prepares the Sidebar data configured as in Process Flow.
*/
public without sharing class DPFSideBarComponentController{

    public string strPageId {get;set;}//variable to hold the current page ID.
    public boolean isSubmitted{get;set;}//boolean variable to check whether the SR is submitted or not.
    map<string,string> mapURLParams = new map<string,string>();
    public boolean ishomepage{get;set;}

    public Page__c currentStepPage {get; set;}

    public DPFSideBarComponentController(){
        strPageId = '';
        if(apexpages.currentPage().getparameters().get('PageId')!=null){
          strPageId = apexpages.currentPage().getparameters().get('PageId');
        }
        if(apexpages.currentPage().getparameters()!=null)
        mapURLParams = apexpages.currentPage().getparameters();

        for(Page__c pg: [select id, Name from Page__c
                            where id=:strPageId]) {
            currentStepPage = pg;
        }
    }
    
    /*
    Method Name  :  getLstPageWrap
    Description  :  Method which will prepares the sidebar data.
    */
    public list<PageWrap> getLstPageWrap(){
      ishomepage = false;
      isSubmitted = false;
      if(apexpages.currentPage().getparameters().get('PageId')!=null){
          strPageId = apexpages.currentPage().getparameters().get('PageId');
        }
        string pageflowId = apexpages.currentPage().getparameters().get('FlowId');
        system.debug('strPageId==>'+strPageId);
        system.debug('mapURLParams==>'+mapURLParams);
        list<PageWrap> lstPageDetails = new list<PageWrap>();
        if(pageflowId!=null && pageflowId!=''){
          PageWrap objWrap;
          map<string,string> mapFilledPageIds = new map<string,string>();
          if(mapURLParams.get('Id')!=null){
            for(HexaBPM__Service_Request__c objSR:[Select id,Filled_Page_Ids__c,HexaBPM__Internal_Status_Name__c from HexaBPM__Service_Request__c where Id=:mapURLParams.get('Id')]){
              list<string> lstPageIds = new list<string>();
              system.debug('===>'+objSR.HexaBPM__Internal_Status_Name__c);
              if(objSR.HexaBPM__Internal_Status_Name__c!='Draft'){
                isSubmitted = true;
                //strPageId = '';
              }
              if(objSR.Filled_Page_Ids__c!=null && objSR.Filled_Page_Ids__c!=''){
                //tick mark to indicate the page has already been filled
                if(objSR.Filled_Page_Ids__c.indexOf(';')>-1){
                  lstPageIds = objSR.Filled_Page_Ids__c.split(';');
                }else{
                  lstPageIds.add(objSR.Filled_Page_Ids__c);
                }
                for(string strPageId:lstPageIds){
                  mapFilledPageIds.put(strPageId.trim(),strPageId.trim());
                }
              }

            }
          }
          string strRecordTypeName = '';
          //query all pages for the side bar
            for (Page__c objPg: [select id, No_Quick_navigation__c, Page_Flow__c, VF_Page_API_Name__c, Page_Flow__r.Record_Type_API_Name__c,
                    Name, Page_Order__c, Page_Flow__r.Name, Render_By_Default__c,
                    (select id, Section_Detail__c, Object_Name__c, Field_Name__c, Operator__c, Value__c from Page_Flow_Conditions__r)
                from Page__c
                where Page_Flow__c = :pageflowId
                order by Page_Order__c]) {

                objWrap = new PageWrap();
                objWrap.pageId = objPg.Id;
                strRecordTypeName = objPg.Page_Flow__r.Record_Type_API_Name__c;
                //set the tick mark based on the filled page map which was built above
                //if(mapFilledPageIds.get(objPg.Id)!=null || isSubmitted==true)
                //objWrap.isPageFilled = true;
                objWrap.pageName = objPg.Name;
                objWrap.pageOrder = objPg.Page_Order__c;
                objWrap.pageFlowId = objPg.Page_Flow__c;
                objWrap.PageFlowName = objPg.Page_Flow__r.Name;
                lstPageDetails.add(objWrap);
            }
        }
        return lstPageDetails;
    }
    public list<StepPagesWrap> getStepPages(){
      list<StepPagesWrap> lstStepPages = new list<StepPagesWrap>();
      return lstStepPages;
    }
    public class PageWrap{
      public string pageName{get;set;}
      public string pageId{get;set;}
      public decimal pageOrder{get;set;}
      public string pageFlowId{get;set;}
      public string PageFlowName{get;set;}
      public boolean NoQuickNavigation{get;set;}
      public boolean isPageFilled{get;set;}
      public PageWrap(){
        isPageFilled = false;
      }
    }
    public class StepPagesWrap{
      public string StepName{get;set;}
      public boolean isDisabled{get;set;}
      public string PageURL{get;set;}
      public boolean isCompleted{get;set;}
    }
}