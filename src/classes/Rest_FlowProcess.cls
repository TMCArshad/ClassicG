/*
    Author      : Durga Prasad
    Date        : 18-Sep-2016
    Description : This is an REST API class which will returns the Flow Process records.
                  This class exists in the target where user want to fetch the process 

*/
@RestResource(urlMapping='/Fetch_Flow_Process/*')
global with sharing class Rest_FlowProcess {
    @HttpPost
    global static FlowProcessWrap GetFlowProcess(String SR_RecordType_API_Name) {
        system.debug('RecordType API Name===>'+SR_RecordType_API_Name);
        FlowProcessWrap objWrap = new FlowProcessWrap();
        if(SR_RecordType_API_Name!=null && SR_RecordType_API_Name!=''){
            string FlowId = '';
            string FlowQuery = getAccessibleFieldsSoql('Page_Flow__c','');
            if(FlowQuery!=null && FlowQuery!=''){
                FlowQuery += ' where Record_Type_API_Name__c=:SR_RecordType_API_Name';
                system.debug('FlowQuery===>'+FlowQuery);
                for(Page_Flow__c flow:Database.query(FlowQuery)){
                    objWrap.PageFlow = flow;
                    FlowId = flow.Id;
                }
                if(FlowId!=null && FlowId!=''){
                    string PageQuery = getAccessibleFieldsSoql('Page__c','');
                    PageQuery += ' where Page_Flow__c=:FlowId order by Page_Order__c';
                    list<Page__c> lstPgs = new list<Page__c>();
                    set<id> PageIds = new set<id>();
                    set<id> setRuleIds = new set<id>();
                    for(Page__c pg:Database.query(PageQuery)){
                        lstPgs.add(pg);
                        PageIds.add(pg.Id);
                    }
                    objWrap.lstPages = lstPgs;
                    if(PageIds!=null && PageIds.size()>0){
                        string SectionQuery = getAccessibleFieldsSoql('Section__c','');
                        SectionQuery += ' where Page__c IN:PageIds order by Order__c';
                        list<Section__c> lstSec = new list<Section__c>();
                        set<Id> SecIds = new set<Id>();
                        for(Section__c sec:Database.query(SectionQuery)){
                            lstSec.add(sec);
                            SecIds.add(sec.Id);
                        }
                        objWrap.lstSections = lstSec;
                        
                        string PageRuleQuery = getAccessibleFieldsSoql('Page_Navigation_Rule__c','');
                        PageRuleQuery += ' where Page__c IN:PageIds';
                        list<Page_Navigation_Rule__c> lstPgRules = new list<Page_Navigation_Rule__c>();
                        for(Page_Navigation_Rule__c PGRule:Database.query(PageRuleQuery)){
                            lstPgRules.add(PGRule);
                            setRuleIds.add(PGRule.Id);
                        }
                        objwrap.lstPgRules = lstPgRules;
                        
                        if(SecIds!=null && SecIds.size()>0){
                            string SectionDetailQuery = getAccessibleFieldsSoql('Section_Detail__c','');
                            SectionDetailQuery += ' where Section__c IN:SecIds order by Order__c';
                            list<Section_Detail__c> lstSecDetail = new list<Section_Detail__c>();
                            set<Id> SecDetailsIds = new set<Id>();
                            for(Section_Detail__c secDet:Database.query(SectionDetailQuery)){
                                lstSecDetail.add(secDet);
                                SecDetailsIds.add(secDet.Id);
                            }
                            objWrap.lstSecDetails = lstSecDetail;
                            
                            string SecRuleQuery = getAccessibleFieldsSoql('Page_Navigation_Rule__c','');
                            SecRuleQuery += ' where Section__c IN:SecIds';
                            list<Page_Navigation_Rule__c> lstSecRules = new list<Page_Navigation_Rule__c>();
                            for(Page_Navigation_Rule__c SecRule:Database.query(SecRuleQuery)){
                                lstSecRules.add(SecRule);
                                setRuleIds.add(SecRule.Id);
                            }
                            objwrap.lstSecRules = lstSecRules;
                            
                            if(SecDetailsIds!=null && SecDetailsIds.size()>0){
                                string SecDetailRuleQuery = getAccessibleFieldsSoql('Page_Navigation_Rule__c','');
                                SecDetailRuleQuery += ' where Section_Detail__c IN:SecDetailsIds';
                                list<Page_Navigation_Rule__c> lstSecDetRules = new list<Page_Navigation_Rule__c>();
                                for(Page_Navigation_Rule__c SecDetRule:Database.query(SecDetailRuleQuery)){
                                    lstSecDetRules.add(SecDetRule);
                                    setRuleIds.add(SecDetRule.Id);
                                }
                                objwrap.lstSecDeatilRules = lstSecDetRules;
                                
                                string BtnActnQuery = getAccessibleFieldsSoql('Page_Flow_Action__c','');
                                BtnActnQuery += ' where Section_Detail__c IN:SecDetailsIds';
                                list<Page_Flow_Action__c> lstBtnActn = new list<Page_Flow_Action__c>();
                                for(Page_Flow_Action__c BtnActn:Database.query(BtnActnQuery)){
                                    lstBtnActn.add(BtnActn);
                                }
                                objwrap.lstBtnActions = lstBtnActn;
                            }
                        }
                        if(setRuleIds!=null && setRuleIds.size()>0){
                            string NavigRuleCondQuery = getAccessibleFieldsSoql('Page_Flow_Condition__c','');
                            NavigRuleCondQuery += ' where Page_Navigation_Rule__c IN:setRuleIds';
                            list<Page_Flow_Condition__c> lstRuleCond = new list<Page_Flow_Condition__c>();
                            for(Page_Flow_Condition__c RuleCond:Database.query(NavigRuleCondQuery)){
                                lstRuleCond.add(RuleCond);
                            }
                            objwrap.lstRuleConds = lstRuleCond;
                            
                            string NavigRuleActnQuery = getAccessibleFieldsSoql('Page_Flow_Action__c','');
                            NavigRuleActnQuery += ' where Page_Navigation_Rule__c IN:setRuleIds';
                            list<Page_Flow_Action__c> lstRuleActn = new list<Page_Flow_Action__c>();
                            for(Page_Flow_Action__c RuleActn:Database.query(NavigRuleActnQuery)){
                                lstRuleActn.add(RuleActn);
                            }
                            objwrap.lstRuleActions = lstRuleActn;
                        }
                    }
                }
            }
        }
        return objWrap;
    }
    global class FlowProcessWrap{
        public Page_Flow__c PageFlow;
        public list<Page__c> lstPages;
        public list<Section__c> lstSections;
        public list<Section_Detail__c> lstSecDetails;
        
        public list<Page_Navigation_Rule__c> lstPgRules;
        public list<Page_Navigation_Rule__c> lstSecRules;
        public list<Page_Navigation_Rule__c> lstSecDeatilRules;
        public list<Page_Navigation_Rule__c> lstNavigRules;
        
        public list<Page_Flow_Condition__c> lstRuleConds;
        
        public list<Page_Flow_Action__c> lstRuleActions;
        public list<Page_Flow_Action__c> lstBtnActions;
        
        
        public FlowProcessWrap(){
            PageFlow = new Page_Flow__c();
            lstPages = new list<Page__c>();
            lstSections = new list<Section__c>();
            lstSecDetails = new list<Section_Detail__c>();
            
            lstPgRules = new list<Page_Navigation_Rule__c>();
            lstSecRules = new list<Page_Navigation_Rule__c>();
            lstSecDeatilRules = new list<Page_Navigation_Rule__c>();
            lstNavigRules = new list<Page_Navigation_Rule__c>();
            
            lstRuleConds = new list<Page_Flow_Condition__c>();
            
            lstRuleActions = new list<Page_Flow_Action__c>();
            lstBtnActions = new list<Page_Flow_Action__c>();
            
        }
    }
    global static String getAccessibleFieldsSoql(String obj, String whereClause){
          String sql = '';
          String fieldString = '';
          list<String> fieldList = new list<string>();
          MAP<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(obj.toLowerCase()).getDescribe().fields.getMap();
          if (fieldMap != null){
             for (Schema.SObjectField f : fieldMap.values()){
                Schema.DescribeFieldResult fd = f.getDescribe();
                if (fd.isAccessible() && fd.isCustom()){
                   fieldList.add(fd.getName());
                }
             }
          }
          if(!fieldList.isEmpty()){
             fieldList.sort();
             for (string s : fieldList){
                fieldString += s + ', ';
             }
          }
          fieldString += 'Name,Id, ';
          if (fieldString.endsWith(', ')) 
             fieldString = fieldString.substring(0, fieldString.lastIndexOf(','));
             
          sql = 'SELECT ' + fieldString + ' FROM ' + obj;
          
          if (whereClause != null && whereClause != '') 
            sql += ' WHERE ' + whereClause;
            
          return sql;
   }
}