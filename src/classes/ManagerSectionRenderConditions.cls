public with sharing class ManagerSectionRenderConditions {
    
    public list<Page_Flow_Condition__c> lstPgCond{get;set;}
    public list<NavigationRulesWrap> lstNavRules{get;set;}
    public string strNavigRuleId{get;set;}
    public string strNavigRuleType{get;set;}
    public string strParentObjectId{get;set;}
    public integer RuleIndex{get;set;}
    public integer CondRowIndex{get;set;}
    public Page_Navigation_Rule__c objNavigRule{get;set;}
    
    public ManagerSectionRenderConditions(){
        
        strNavigRuleType = apexpages.currentPage().getParameters().get('Type');
        strParentObjectId = apexpages.currentPage().getParameters().get('Id');
        
        lstPgCond = new list<Page_Flow_Condition__c>();
        objNavigRule = new Page_Navigation_Rule__c();
        
        lstNavRules = new list<NavigationRulesWrap>();
        
        system.debug('strNavigRuleType==>'+strNavigRuleType);
        system.debug('strParentObjectId==>'+strParentObjectId);
        PrepareNavigRuleData();
    }
    
    public void PrepareNavigRuleData(){
        lstPgCond = new list<Page_Flow_Condition__c>();
        
        lstNavRules = new list<NavigationRulesWrap>();
        
        if(strParentObjectId!=null && strParentObjectId!=''){
            for(Page_Navigation_Rule__c objPGR:[select id,Name,Rule_Condition__c,Rule_Description__c,Rule_Name__c,Rule_Text_Condition__c,Section__c from Page_Navigation_Rule__c where Section__c=:strParentObjectId order by createdDate]){
                NavigationRulesWrap objAddRule = new NavigationRulesWrap();
                objAddRule.isEdit = false;
                objAddRule.objRule = objPGR;
                objAddRule.RuleIndex = lstNavRules.size();
                lstNavRules.add(objAddRule);
            }
        }
    }
    
    public void Prepare_Conditions_Actions(){
        lstPgCond = new list<Page_Flow_Condition__c>();
        for(Page_Flow_Condition__c Cond:[select id,Name,S_No__c,Object_Name__c,Field_Name__c,Operator__c,Value__c,Page_Navigation_Rule__c from Page_Flow_Condition__c where Page_Navigation_Rule__c=:strNavigRuleId]){
            lstPgCond.add(Cond);
        }
    }
    
    public void SavePGRule(){ 
        ClearRelatedLists();
        if(lstNavRules!=null && RuleIndex<lstNavRules.size()){
            try{
                upsert lstNavRules[RuleIndex].objRule;
                lstNavRules[RuleIndex].isEdit = false;
            }catch(Exception e){
                
            }
        }
    }
    
    public void EditPGRule(){
        ClearRelatedLists();
        system.debug('RuleIndex==>'+RuleIndex);
        system.debug('lstNavRules==>'+lstNavRules.Size());
        if(RuleIndex!=null && RuleIndex<lstNavRules.size()){
            lstNavRules[RuleIndex].isEdit = true;
        }
    }
    
    public void DelPGRule(){
        if(strNavigRuleId!=null && strNavigRuleId!=''){
            list<Page_Navigation_Rule__c> LstPNRule = [select id from Page_Navigation_Rule__c where Id=:strNavigRuleId];
            list<Page_Flow_Condition__c> lstPFCond = [select id from Page_Flow_Condition__c where Page_Navigation_Rule__c=:strNavigRuleId];
            list<Page_Flow_Action__c> lstPFAct = [select id from Page_Flow_Action__c where Page_Navigation_Rule__c=:strNavigRuleId];
            try{
                if(lstPFAct!=null && lstPFAct.size()>0){
                    try{
                        delete lstPFAct;
                    }catch(Exception e){
                    
                    }
                }
                if(lstPFCond!=null && lstPFCond.size()>0){
                    try{
                        delete lstPFCond;
                    }catch(Exception e){
                    
                    }
                }
                if(LstPNRule!=null && LstPNRule.size()>0){
                    try{
                        delete LstPNRule;
                    }catch(Exception e){
                    
                    }
                }
            }catch(Exception e){
                
            }
            PrepareNavigRuleData();
        }
    }
    
    public void CancelPGRule(){
        ClearRelatedLists();
        if(RuleIndex!=null && RuleIndex<lstNavRules.size()){
            if(lstNavRules[RuleIndex].objRule.Id!=null){
                lstNavRules[RuleIndex].isEdit = false;
            }else{
                lstNavRules.remove(RuleIndex);
                PrepareNavigRuleData();
            }
        }
    }
    
    public void ManagePGRule(){
        lstPgCond = new list<Page_Flow_Condition__c>();
        if(strNavigRuleId!=null && strNavigRuleId!=''){
            objNavigRule = new Page_Navigation_Rule__c();
            for(Page_Navigation_Rule__c objRule:[Select id,Rule_Condition__c,Rule_Text_Condition__c from Page_Navigation_Rule__c where Id=:strNavigRuleId]){
                objNavigRule = objRule;
            }
            for(Page_Flow_Condition__c Cond:[select id,Name,S_No__c,Object_Name__c,Field_Name__c,Operator__c,Value__c,Page_Navigation_Rule__c from Page_Flow_Condition__c where Page_Navigation_Rule__c=:strNavigRuleId]){
                lstPgCond.add(Cond);
            }
            if(lstPgCond==null || (lstPgCond!=null && lstPgCond.size()==0)){
                AddCondition();
            }
        }
    }
    
    public void SaveCondition(){
        if(lstPgCond!=null && lstPgCond.size()>0){
            integer Row = 1;
            string strFilterCondition = '';
            if(objNavigRule.Rule_Condition__c!=null && objNavigRule.Rule_Condition__c!='' && objNavigRule.Rule_Condition__c.trim()!=''){
                string trimmedFilterCond = objNavigRule.Rule_Condition__c.replaceAll('\\s+','');
                trimmedFilterCond = trimmedFilterCond.toUpperCase();
                
                system.debug('trimmedFilterCond==>'+trimmedFilterCond);
                
                string actOpen = '(';
                string actClose = ')';
                //to split that based on ( open and ) close and operator and logical expressions we are using # key))
                string open = '#(#';
                string closed = '#)#';
                if(trimmedFilterCond.indexOf(actOpen)>-1)
                    trimmedFilterCond = trimmedFilterCond.replace(actOpen,open);
                if(trimmedFilterCond.indexOf(actClose)>-1)
                    trimmedFilterCond = trimmedFilterCond.replace(actClose,closed);
                    
                
                if(trimmedFilterCond.indexOf('AND')>-1)
                    trimmedFilterCond = trimmedFilterCond.replaceAll('AND','#'+'AND'+'#');
                if(trimmedFilterCond.indexOf('OR')>-1)
                // user enters OR THEN it becomes #OR#
                    trimmedFilterCond = trimmedFilterCond.replaceAll('OR','#'+'OR'+'#');
                
                Page_Flow_Condition__c objCondition;
                map<string,string> mapFilterConditions = new map<string,string>();
                for(Page_Flow_Condition__c objWrap : lstPgCond){
                    objCondition = objWrap;
                    objCondition.S_No__c = Row;
                    string strrow = Row+'';
                    string fldcon;
                    if(objCondition.Object_Name__c!='Custom Code'){
                        fldcon = objCondition.Object_Name__c+'->'+objCondition.Field_Name__c+'#'+objCondition.Operator__c+'#'+objCondition.Value__c;
                    }else{
                        fldcon = objCondition.Class_Name__c+'->'+objCondition.Field_Name__c+'#'+objCondition.Operator__c+'#'+objCondition.Value__c;
                    }
                    system.debug('fldcon==>'+fldcon);
                    system.debug('trimmedFilterCond==>'+trimmedFilterCond);
                    system.debug('strrow==>'+strrow);
                    mapFilterConditions.put(strrow,fldcon);
                    system.debug('trimmedFilterCond After ReplaceAll==>'+trimmedFilterCond);
                    Row++;
                }
                string StrTextCondition = '';
                //VALIDATING THE FILTER CONDITION IF THERE IS ANY ILLEGAL CHARACTERS OR ERRORS
                if(trimmedFilterCond!=null && trimmedFilterCond!='' && trimmedFilterCond.trim()!=''){
                    list<string> lststr = new list<string>();
                    lststr = trimmedFilterCond.split('');
                    if(lststr!=null && lststr.size()>0){
                        for(integer i=0;i<lststr.size();i++){
                            if(lststr[i].isNumeric() && mapFilterConditions.get(lststr[i])!=null){
                                if(StrTextCondition==''){
                                    StrTextCondition = mapFilterConditions.get(lststr[i]);
                                }else{
                                    StrTextCondition += mapFilterConditions.get(lststr[i]);
                                }
                            }else{
                                StrTextCondition += lststr[i];
                            }
                        }
                    }
                }
                system.debug('StrTextCondition==>'+StrTextCondition);
                strFilterCondition = StrTextCondition;
                system.debug('strFilterCondition==>'+strFilterCondition);
            }else{ // IF USER DONT ENTER ANY VALUE IN THE FILTER CONDITION THEN TREAT AS 1 AND 2 AND 3 AND 4 STD SALESFORCE METHOD 
                Page_Flow_Condition__c objCondition;
                objNavigRule.Rule_Condition__c = '';
                strFilterCondition = '';
                for(Page_Flow_Condition__c objWrap : lstPgCond){
                    objCondition = objWrap;
                    objCondition.S_No__c = Row;
                    if(objCondition.S_No__c!=1){
                        objNavigRule.Rule_Condition__c = objNavigRule.Rule_Condition__c+' AND '+string.valueOf(objCondition.S_No__c);
                        strFilterCondition += '#'+'AND'+'#';
                        if(objCondition.Object_Name__c!='Custom Code'){
                            strFilterCondition += objWrap.Object_Name__c+'->'+objWrap.Field_Name__c;
                        }else{
                            strFilterCondition += objWrap.Class_Name__c+'->'+objWrap.Field_Name__c;
                        }
                        strFilterCondition += '#'+objWrap.Operator__c+'#'+objWrap.Value__c;
                    }else{
                         objNavigRule.Rule_Condition__c = string.valueOf(objCondition.S_No__c);
                         if(objCondition.Object_Name__c!='Custom Code'){
                            strFilterCondition = objCondition.Object_Name__c+'->'+objCondition.Field_Name__c+'#'+objCondition.Operator__c+'#'+objCondition.Value__c;
                         }else{
                            strFilterCondition = objCondition.Class_Name__c+'->'+objCondition.Field_Name__c+'#'+objCondition.Operator__c+'#'+objCondition.Value__c;
                         }
                    }
                    Row++;
                }
            }
            
            list<string> lstVals = new list<string>();
            lstVals = strFilterCondition.split('#');
            system.debug('lstVals==>'+lstVals);
            system.debug('lstVals size==>'+lstVals.size());
            system.debug('strFilterCondition==>'+strFilterCondition);
            if(lstPgCond!=null && lstPgCond.size()>0){
                try{
                    upsert lstPgCond;
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,string.valueOf(e.getMessage())));
                }
            }
            try{
                objNavigRule.Rule_Text_Condition__c = strFilterCondition;
                upsert objNavigRule;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,string.valueOf(e.getMessage())));
            }
            PrepareNavigRuleData();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Conditions & Actions for the Navigation rules saved.'));
            
        }else{
            string strMessage = '';
            if(lstPgCond==null || (lstPgCond!=null && lstPgCond.size()==0)){
                strMessage = 'Please provide atleast one condition';
            }
            if(strMessage!=''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,strMessage));
            }
        }
    }
    
    public void RemoveCondition(){
        if(CondRowIndex!=null && lstPgCond!=null && CondRowIndex<lstPgCond.size()){
            if(lstPgCond[CondRowIndex].Id!=null){
                Page_Flow_Condition__c objCond = lstPgCond[CondRowIndex]; 
                lstPgCond.remove(CondRowIndex);
                delete objCond;
            }else{
                lstPgCond.remove(CondRowIndex);
            }
        }
    }
    public void CancelCondActions(){
        ClearRelatedLists();
    }
    public pagereference Back_to_SectionDetail(){
        pagereference pg = new pagereference('/'+strParentObjectId);
        pg.setRedirect(true);
        return pg;
    }
    public void ClearRelatedLists(){
        strNavigRuleId = null;
        lstPgCond = new list<Page_Flow_Condition__c>();
    }
    public void AddRule(){
        ClearRelatedLists();
        
        NavigationRulesWrap objAddRule = new NavigationRulesWrap();
        objAddRule.isEdit = true;
        objAddRule.objRule = new Page_Navigation_Rule__c();
        objAddRule.objRule.Section__c = strParentObjectId;
        
        objAddRule.RuleIndex = lstNavRules.size();
        lstNavRules.add(objAddRule);
    }
    public void AddCondition(){
        if(strNavigRuleId!=null && strNavigRuleId!=''){
            Page_Flow_Condition__c objCon = new Page_Flow_Condition__c();
            objCon.Page_Navigation_Rule__c = strNavigRuleId;
            objCon.Object_Name__c = 'HexaBPM__Service_Request__c';
            objCon.Condition_Type__c = 'Section Render';
            lstPgCond.add(objCon);
        }
    }
    public class NavigationRulesWrap{
        public Page_Navigation_Rule__c objRule{get;set;}
        public boolean isEdit{get;set;}
        public integer RuleIndex{get;set;}
        public NavigationRulesWrap(){
            objRule = new Page_Navigation_Rule__c();
            isEdit = false;
        }
    }
}