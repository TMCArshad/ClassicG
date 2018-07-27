/*
    Author      :   Durga Prasad
    Description :   This class belongs to the Dynamic wizard which will constructs the Page elements from controller and defines 
                    the page flow.
    Modification
    History     :
*/
public without sharing class Process_FlowCls{
    
    public HexaBPM__Service_Request__c objSR{get;set;}
    public list<Page__c> lstPages{get;set;}
   
    public Process_FlowCls thisClass {get;set;}//not using
    
    public string strPageId{get;set;}
    public string stringActionId{get;set;}
    public string PageFlowId;
        
    public string pageTitle{get;set;}
    public string pageName{get;set;}
    public string pageDescription{get;set;}
    public string strHiddenPageIds{get;set;} 
    public string strSRID{get;set;}
    public string strReqFieldIds{get;set;}
    public map<string,string> mapParameters;
    public boolean isCommunity{get;set;}
    public string strRecordType{get;set;}

    
   // public string strGeneralInstructions{get;set;}
    /*
        Constructor codes when the Page loads
    */
    public Process_FlowCls(){
         strPageId = '';
         strSRID = '';
         strHiddenPageIds = '';
         objSR = new HexaBPM__Service_Request__c();
         lstPages = new list<Page__c>();
         stringActionId = '';
         strReqFieldIds = '';
         strRecordType = '';
         isCommunity = false;
         User objUser = new User();
         try{
         //if there is a contact for this logged in user, then it is a community user
         for(User objUsr:[select id,ContactId,Contact.Email,Contact.AccountId,Contact.FirstName,Contact.LastName,Contact.Account.Website from User where Id=:userinfo.getUserId()]){
            objUser = objUsr;
            if(objUsr.ContactId!=null)
                isCommunity = true;
         }
         mapParameters = new map<string,string>();
         // all the parameters in the url are stored in this map
         if(apexpages.currentPage().getParameters()!=null && apexpages.currentPage().getParameters().size()>0)
            mapParameters = apexpages.currentPage().getParameters();
            
         pageflowId = apexpages.currentPage().getparameters().get('FlowId');
         
         if(apexpages.currentPage().getParameters().get('Id')!=null){
            strSRID = apexpages.currentPage().getParameters().get('Id');
         }
         strPageId = mapParameters.get('PageId');
         // to highlight the current page passed in url or highlight the page which is marked as defualt in the setup
         if(mapParameters.get('PageId')!=null){
            lstPages = [select id,Name,Is_Custom_Component__c,Page_Order__c,Page_Description__c,Page_Flow__r.Name,Page_Flow__c,Page_Flow__r.Record_Type_API_Name__c,Render_By_Default__c,VF_Page_API_Name__c from Page__c where Page_Flow__c=:pageflowId and Id=:mapParameters.get('PageId') order by Page_Order__c];
         }else{
            lstPages = [select id,Name,Is_Custom_Component__c,Page_Order__c,Page_Description__c,Page_Flow__r.Name,Page_Flow__c,Page_Flow__r.Record_Type_API_Name__c,Render_By_Default__c,VF_Page_API_Name__c from Page__c where Page_Flow__c=:pageflowId order by Page_Order__c];
         }
         // get the SR template id for the given rec type api name 
         if(lstPages!=null && lstPages.size()>0){
            pageTitle = lstPages[0].Page_Flow__r.Name;
            System.debug('Page'+pageTitle);
            if(lstPages[0].Page_Flow__r.Record_Type_API_Name__c!=null){
                strRecordType = lstPages[0].Page_Flow__r.Record_Type_API_Name__c;
                for(HexaBPM__SR_Template__c srtemp:[select id from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c=:lstPages[0].Page_Flow__r.Record_Type_API_Name__c]){
                    objSR.HexaBPM__SR_Template__c = srtemp.Id;
                }
            }
            // page title and description are shown here
            if(strPageId == null || (strPageId!=null && strPageId == '')){
                if(lstPages[0].Render_By_Default__c==true){
                    apexpages.currentPage().getParameters().put('PageId',lstPages[0].id);
                    strPageId = lstPages[0].id;
                    pageDescription = lstPages[0].Page_Description__c;
                }
            }
            //for the given customer if there any Request of same type
            if(objUser!=null && objUser.ContactId!=null && objUser.Contact.AccountId!=null){
                for(HexaBPM__Service_Request__c SR:[select id from HexaBPM__Service_Request__c where (HexaBPM__Customer__c=:objUser.Contact.AccountId or student__c=:objUser.Contact.AccountId) and HexaBPM__internal_status_name__c='Draft' and HexaBPM__isClosedStatus__c=false and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false and RecordType.DeveloperName=:strRecordType]){
                    strSRID = SR.Id;
                    mapParameters.put('Id',strSRID);
                }
            }
        }
        if(strSRID!=null && strSRID!=''){
            if(pageflowId!=null && pageflowId!=''){
                //query all the fields configured in the page are query here.
                set<string> SetstrFields = Cls_Evaluate_Conditions.FetchObjectFields(pageflowId,'HexaBPM__Service_Request__c');
                string strQuery = 'select Id';
                if(SetstrFields==null || (SetstrFields!=null && SetstrFields.size()==0))
                    SetstrFields = new set<string>();
                SetstrFields.add('HexaBPM__customer__c');
                SetstrFields.add('Student__c');
                SetstrFields.add('is_flow_request__c');
                SetstrFields.add('filled_page_ids__c');
                SetstrFields.add('recordtypeid');
                SetstrFields.add('HexaBPM__record_type_name__c');
                SetstrFields.add('name');
                SetstrFields.add('flow_id__c');
                SetstrFields.add('HexaBPM__internal_status_name__c');
                SetstrFields.add('HexaBPM__sr_template__c');
                for(String strFld:SetstrFields){
                    if(strFld.toLowerCase()!='id')
                        strQuery += ','+strFld.toLowerCase();
                }
                strQuery = strQuery+' from HexaBPM__Service_Request__c where Id=:strSRID';
                for(HexaBPM__Service_Request__c SR:database.query(strQuery)){
                    objSR = SR;
                }
                
            }
         }else{
            if(strRecordType!=null && strRecordType!=''){
                for(RecordType rec:[Select Id,Name from RecordType where developerName=:strRecordType and sObjectType='HexaBPM__Service_Request__c']){
                    objSR.RecordTypeId = rec.Id;
                }
            }
         }
         system.debug('----objSR.RecordTypeId----'+objSR.RecordTypeId);
         if(objUser!=null && objUser.ContactId!=null && objUser.Contact.AccountId!=null){
            objSR.HexaBPM__Customer__c = objUser.Contact.AccountId;
            objSR.Student__c = objUser.Contact.AccountId;
            if(objUser.Contact.FirstName!=null)
            	objSR.First_Name__c = objUser.Contact.FirstName;
            if(objUser.Contact.LastName!=null)
            	objSR.Last_Name__c = objUser.Contact.LastName;
            if(objUser.Contact.Account.Website!=null)
            	objSR.Website__c = objUser.Contact.Account.Website;
            if(objUser.Contact.Email!=null)	
            	objSR.HexaBPM__Email__c = objUser.Contact.Email;
         }
         objSR.Is_Flow_Request__c = true;
         IF(pageflowId!=NULL && pageflowId!='')
            objSR.flow_id__c = pageflowId;
         thisClass = this;
     }
     catch(Exception e){
       
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));    
     }

    }
    public pagereference Redirect_DefaultCustomPage(){
        pagereference pg;
        
        return null;
    }
    
    
    /*
        Method Name :   prepare_Page_Description
        Description :   This will Re-prepares the Page title & Description for the Current Page.
    */
    public void prepare_Page_Description(){
        if(strPageId!=null && strPageId!=''){
            for(Page__c objPG:[select id,Name,Page_Description__c,Page_Flow__r.Name from Page__c where id=:strPageId]){
                pageTitle = objPG.Page_Flow__r.Name;
                pageName = objPG.Name;
                pageDescription = objPG.Page_Description__c;
            }
        }else{
            pageTitle = '';
            pageName = '';
            pageDescription = '';
        }
    }
    
    /*
        Method Name :   getClass
        Description :   This will returns the current Class Instance for the Sidebar Component.
    */
    public Process_FlowCls getClass(){
        return this;
    }
    
    /*
        Method Name :   getDyncPgMainPB
        Description :   Method which will creates the Dynamic VF Components based on the Configuration defined
    */
    public Component.Apex.PageBlock getDyncPgMainPB(){
        strHiddenPageIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        strPageId = mapParameters.get('PageId');
        if(strPageId!=null && strPageId!=''){
            prepare_Page_Description();
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            for(Section__c objSec:[select id,Name,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Cancel_Request__c,Object_Name__c,Order__c,Section__c,Field_Description__c,Default_Value__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c,Re_render_Sections__c from Section_Details__r order by Order__c),
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Page__c=:strPageId order by Order__c,Section_Type__c]){
                lstSec.add(objSec);
                if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                    for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                        if(objSecDet.Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Navigation_Rule__c SDRenRule:[select id,Rule_Text_Condition__c,Section_Detail__c from Page_Navigation_Rule__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Navigation_Rule__c> lstSDRenRules = new list<Page_Navigation_Rule__c>();
                    if(mapSecDetailRenderRules.get(SDRenRule.Section_Detail__c)!=null && mapSecDetailRenderRules.get(SDRenRule.Section_Detail__c).size()>0){
                        lstSDRenRules = mapSecDetailRenderRules.get(SDRenRule.Section_Detail__c);
                        lstSDRenRules.add(SDRenRule);
                    }else{
                        lstSDRenRules.add(SDRenRule);
                    }
                    mapSecDetailRenderRules.put(SDRenRule.Section_Detail__c,lstSDRenRules);
                }
            }
            //looping all section of the current page 
            for(Section__c objSec:lstSec){
                boolean bBuildSection = false;
                if(objSec.Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        //looping navig rule and evaluate the condit.
                        for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                            boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }
                }
                if(bBuildSection==true && objSec.Section_Type__c=='PageBlockSection'){
                    Component.Apex.PageBlockSection dycPB = new Component.Apex.PageBlockSection();
                    dycPB.Id = 'PBS_'+objSec.Id;
                    //no of columns in the layout 
                    dycPB.columns = Integer.valueOf(objSec.layout__c);
                    dycPB.Title = objSec.Name;
                    //Component.Apex.facet = new Component.Apex.Facet();

                    
                    Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                    pageBlockSectionWrapper.layout = 'block';
                    pageBlockSectionWrapper.styleClass = 'colLayout' + objSec.layout__c+' pageBlockSectionWrapper';
                    pageBlockSectionWrapper.childComponents.add(dycPB);
                    
                    if (objSec.Section_Description__c != '' && objSec.Section_Description__c != null){
                        Component.Apex.OutPutPanel sectDesc = new Component.Apex.OutPutPanel();
                        sectDesc.layout = 'block';
                        sectDesc.styleClass = 'sectionDescription';
                        Component.Apex.outputtext sectDescLabel = new Component.Apex.outputtext(escape=false);
                        sectDescLabel.value = objSec.Section_Description__c;
                        sectDesc.childComponents.add(sectDescLabel);
                        dycPB.childComponents.add(sectDesc);
                    }
                    // input or output field
                    if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        dycPB.Title = objSec.Name;
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = Cls_Evaluate_Conditions.executeNavigationRules(SDRendRule.Rule_Text_Condition__c,objSR);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;                         
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Input Field'){
                                pb.mode = 'Edit';
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper form-group';
                                
                                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                Schema.SObjectType ObjSchema;
                                
                                if(objSecDet.Default_Value__c!=null && objSR.get(objSecDet.Field_API_Name__c)==null)
                                    objSR.put(objSecDet.Field_API_Name__c,objSecDet.Default_Value__c);
                                    
                                Component.Apex.inputfield inpFld = new Component.Apex.inputfield();
                                inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                PBSItem.Id = 'PBSItem'+'_'+inpFld.Id;
                                if(objSecDet.Object_Name__c=='HexaBPM__Service_Request__c'){
                                    inpFld.expressions.value = '{!objSR.'+objSecDet.Field_API_Name__c+'}';
                                    ObjSchema = schemaMap.get('HexaBPM__Service_Request__c');
                                }
                                inpFld.styleClass='input';
                                //inpFld.expressions.put('html-pattern','test pattern');


                                // if label is not defined for a field then get it from definition
                                Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();

                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.Component_Label__c;
                                if (objSecDet.Component_Label__c == '' || objSecDet.Component_Label__c == null)
                                    Fldlabel.value = fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.Component_Label__c;

                                String fieldType = String.valueOf(fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getType());
                                PBSItemPnl.styleClass += ' type-' + fieldType;
                                
                                if(fieldType == 'EMAIL')
                                    inpFld.type = 'email';
                                else
                                    inpFld.styleClass += ' '+ fieldType.toLowerCase();

                                //help text after the field
                                Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel(escape=false);
                                FldDescription.value = objSecDet.Field_Description__c;
                                // three panels to display label field description
                                Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                labelPanel.layout = 'block';
                                labelPanel.styleClass = 'labelWrapper';
                                
                                Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                fieldPanel.layout = 'block';
                                fieldPanel.styleClass = 'fieldWrapper';
                                
                                Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                fDescPanel.layout = 'block';
                                fDescPanel.styleClass = 'descWrapper';

                                labelPanel.childComponents.add(Fldlabel);
                                // to bring the red bar for required field
                                if(objSecDet.Mark_it_as_Required__c){
                                    Component.Apex.OutPutPanel ReqBlockMainPnl = new Component.Apex.OutPutPanel();
                                    inpFld.styleClass = (inpFld.styleClass == null ? 'requiredInput' : inpFld.styleClass + ' requiredInput');
                                    ReqBlockMainPnl.styleClass = '';
                                    ReqBlockMainPnl.layout = 'block';
                                    
                                    Component.Apex.OutPutPanel ReqBlockFldPnl = new Component.Apex.OutPutPanel();
                                    ReqBlockFldPnl.id=inpFld.Id+'_ReqBlock';
                                    ReqBlockFldPnl.styleClass = 'requiredBlock';
                                    ReqBlockFldPnl.layout = 'block';
                                    
                                    ReqBlockMainPnl.childComponents.add(ReqBlockFldPnl);
                                    ReqBlockMainPnl.childComponents.add(inpFld);

                                    Fldlabel.title = 'required';
                                    labelPanel.styleClass += ' requiredInputLabel';

                                    fieldPanel.childComponents.add(ReqBlockMainPnl);
                                    if(strReqFieldIds==''){
                                        strReqFieldIds = inpFld.Id;
                                    }else{
                                        strReqFieldIds = strReqFieldIds+','+inpFld.Id;
                                    }
                                }else{
                                    fieldPanel.childComponents.add(inpFld);
                                }
                                
                                fDescPanel.childComponents.add(FldDescription);
                                
                                PBSItemPnl.childComponents.add(labelPanel);
                                
                                PBSItemPnl.childComponents.add(fieldPanel);
                                
                                if(objSec.layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);
                                
                                PBSItem.childComponents.add(PBSItemPnl);
                                
                                dycPB.childComponents.add(PBSItem);

                                // Bilal - capturing sections to re-render
                                //on change event is invoking the javascript method
                                if(objSecDet.hasOnChange__c==true){
                                    if(String.isNotBlank(objSecDet.Re_render_Sections__c)){
                                        if(String.valueOf(objSecDet.Re_render_Sections__c).contains('All')){
                                            if(objSecDet.hasOnChange__c==true)
                                                inpFld.onChange='if(typeof InvokeFieldChange!="undefined")InvokeFieldChange();InvokeChangeEvent();return false;';
                                            /*
                                            acFunc.name = 'InvokeChangeEvent_'+ pb.Id + objSecDet.Id;
                                            rerenderSectionSet.add(pb.Id);
                                            acFunc.reRender = rerenderSectionSet;
                                            inpFld.onChange='InvokeChangeEvent_'+ pb.Id + objSecDet.Id +'();return false;';
                                            */
                                        }else{
                                            //acFunc.expressions.action = '{!rerender}';
                                            Component.Apex.actionFunction acFunc = new Component.Apex.actionFunction();
                                            Set<String> rerenderSectionSet = new Set<String>();

                                            acFunc.name = 'InvokeChangeEvent_'+objSecDet.Id;
                                            for(String sectionId :objSecDet.Re_render_Sections__c.split(';')){
                                                if(sectionId.length() >= 16){
                                                    rerenderSectionSet.add('PBS_' + sectionId);//As the Id assigned above is in this format
                                                }
                                            }
                                            acFunc.reRender = rerenderSectionSet;
                                            inpFld.onChange='if(typeof InvokeFieldChange!="undefined")InvokeFieldChange();InvokeChangeEvent_'+objSecDet.Id+'();return false;';

                                            acFunc.status = 'pleasewait';
                                            //acFunc.action = new ApexPages.Action('{!getDyncPgMainPB}');
                                            acFunc.oncomplete='InvokeChangeEventComplete();';
                                            pb.childComponents.add(acFunc);
                                            //dycPB.childComponents.add(acFunc);
                                        }
                                    }
                                }
                                
                            }else if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Blank Space'){// && objSec.layout__c == '2'
                                
                                pb.mode = 'edit';
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';
                                PBSItem.childComponents.add(PBSItemPnl);
                                dycPB.childComponents.add(PBSItem);
                                
                            }else if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Output Field'){
                                pb.mode = 'Detail';
                                dycPB.collapsible = false;
                                Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                PBSItemPnl.layout = 'block';
                                PBSItemPnl.styleClass = 'rowWrapper';

                                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                Schema.SObjectType ObjSchema;
                                
                                //Component.Apex.Outputfield inpFld = new Component.Apex.Outputfield();
                                Component.Apex.InputText inpFld = new Component.Apex.InputText();
                                inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                inpFld.disabled=true;
                                inpFld.styleClass='input disabled';

                                if(objSecDet.Object_Name__c=='HexaBPM__Service_Request__c'){
                                    inpFld.expressions.value = '{!objSR.'+objSecDet.Field_API_Name__c+'}';
                                    ObjSchema = schemaMap.get('HexaBPM__Service_Request__c');
                                }

                                Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
                                PBSItemPnl.styleClass += ' type-' + fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getType();

                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.Component_Label__c;
                                if (objSecDet.Component_Label__c == '' || objSecDet.Component_Label__c == null)
                                    Fldlabel.value = fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.Component_Label__c;
                                
                                Component.Apex.outputlabel FldDescription = new Component.Apex.outputlabel();
                                FldDescription.value = objSecDet.Field_Description__c;
                                
                                Component.Apex.OutPutPanel labelPanel = new Component.Apex.OutPutPanel();
                                labelPanel.layout = 'block';
                                labelPanel.styleClass = 'labelWrapper';
                                
                                Component.Apex.OutPutPanel fieldPanel = new Component.Apex.OutPutPanel();
                                fieldPanel.layout = 'block';
                                fieldPanel.styleClass = 'fieldWrapper';
                                
                                Component.Apex.OutPutPanel fDescPanel = new Component.Apex.OutPutPanel();
                                fDescPanel.layout = 'block';
                                fDescPanel.styleClass = 'descWrapper';

                                labelPanel.childComponents.add(Fldlabel);
                                fieldPanel.childComponents.add(inpFld);
                                
                                fDescPanel.childComponents.add(FldDescription);
                                
                                PBSItemPnl.childComponents.add(labelPanel);
                                PBSItemPnl.childComponents.add(fieldPanel);
                                
                                if (objSec.layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);
                                
                                PBSItem.childComponents.add(PBSItemPnl);
                                
                                dycPB.childComponents.add(PBSItem);
                            }
                        }
                    }
                    pb.childComponents.add(pageBlockSectionWrapper);
                }else if(bBuildSection==true && objSec.Section_Type__c=='CommandButtonSection'){
                    if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = Cls_Evaluate_Conditions.executeNavigationRules(SDRendRule.Rule_Text_Condition__c,objSR);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;                         
                                    }
                                    bRenderSecDetail = RulesResult;
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width:70px;min-height:20px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                // on click of commit record = true  it is a save button
                                if(objSecDet.Commit_the_Record__c==false && objSecDet.Cancel_Request__c==false){
                                    //for prev button Ignore_Required_Fields__c is marked as true 
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }else if(objSecDet.Cancel_Request__c==true){
                                    dycBtn.onClick = 'CancelRequest();return false;';
                                }
                                //button locations                             
                                if(objSecDet.Button_Location__c!=null)
                                    PBtns.location = objSecDet.Button_Location__c;
                                if (objSecDet.Button_Position__c == 'left')
                                    dycBtn.styleClass = 'left';
                                else if (objSecDet.Button_Position__c == 'right')
                                    dycBtn.styleClass = 'right';

                                dycBtn.styleClass = (dycBtn.styleClass == null ? 'btn' : dycBtn.styleClass + ' btn');
                                PBtns.childComponents.add(dycBtn);
                            }
                        }
                    }
                }
            }
        }
        if(pageflowId==null || pageflowId==''){
            pageflowId = apexpages.currentPage().getparameters().get('FlowId');
        }
        if(pageflowId!=null && pageflowId!=''){
            strHiddenPageIds = PreparePageBlockUtil.getHiddenPageIds(pageflowId,objSR);
        }
        return pb;
    }
    /*
        Method Name :   RePrepareSection
        Description :   Dummy method which is used to refresh the Dynamic PB to re-prepare the Fields based on new Values
    */
    public void RePrepareSection(){
    	if(pageName == 'Primary Contact'){
    		
    		if(objSR.Primary_Contact__c!='Father' && objSR.Fees_Sponsor__c!='Father' && objSR.Fees_Sponsor__c!='Father\'s Company' && objSR.Show_Father_Contact_Details__c == false){
    			objSR.First_Name_Father__c	= '';
    			objSR.Last_Name_Father__c	= '';
    			objSR.Country__c	= '';
    			objSR.City_Emirate__c	= '';
    			objSR.Area__c	= '';
    			objSR.Street__c	= '';
    			objSR.Building__c	= '';
    			objSR.Apartment_No__c	= '';
    			objSR.P_O_Box__c	= '';
    			objSR.Home_Phone__c	= '';
    			objSR.Mobile__c	= '';
    			objSR.Office_Phone__c	= '';
    			objSR.Fax_No__c	= '';
    			objSR.Email_Father__c	= '';
    			objSR.Occupation__c	= '';
    			objSR.Makani__c	= '';
    			objSR.Company__c	= '';
    			objSR.Is_father_of_Student_an_employee_in_GEMS__c	= 'No';
    			objSR.Is_father_of_Student_an_Ex_Student__c	= 'No';
    			objSR.Academic_Year_Ex__c	= '';
    			objSR.GEMS_School_Father__c	= '';
    			objSR.Staff_ID__c	= '';
    			objSR.Business_Unit_Father__c	= '';	
    		}	
    		
    		if(objSR.Is_father_of_Student_an_Ex_Student__c== 'No'){
    			objSR.Academic_Year_Ex__c	= '';
    			objSR.GEMS_School_Father__c	= '';	
    		}
    		
    		if(objSR.Is_father_of_Student_an_employee_in_GEMS__c== 'No'){
    			objSR.Staff_ID__c	= '';
    			objSR.Business_Unit_Father__c	= '';	
    		}
    		
    		if(objSR.Primary_Contact__c!='Mother' && objSR.Fees_Sponsor__c!='Mother' && objSR.Fees_Sponsor__c!='Mother\'s Company' && objSR.Show_Mother_Contact_Details__c == false){
    			objSR.First_Name_Mother__c = '';
    			objSR.Last_Name_Mother__c = '';
    			objSR.Country_Mother__c	= '';
    			objSR.City_Emirate_Mother__c	= '';
    			objSR.Area_Mother__c	= '';
    			objSR.Street_Mother__c	= '';
    			objSR.Building_Mother__c	= '';
    			objSR.Apartment_No_Mother__c	= '';
    			objSR.P_O_Box_Mother__c	= '';
    			objSR.Home_Phone_Mother__c	= '';
    			objSR.Mobile_Mother__c	= '';
    			objSR.Office_Phone_Mother__c	= '';
    			objSR.Fax_No_Mother__c	= '';
    			objSR.Makani_Mother__c	= '';
    			objSR.Company_Mother__c	= '';
    			objSR.Email_Mother__c	= '';
    			objSR.Occupation_Mother__c	= '';
    			objSR.Is_mother_of_Student_an_Ex_Student__c	= 'No';
    			objSR.Is_mother_of_Student_an_employee_in_GEMS__c	= 'No';
    			objSR.Academic_Year_Ex_Mother__c	= '';
    			objSR.GEMS_School_Mother__c	= '';
    			objSR.Staff_id_Mother__c	= '';
    			objSR.Business_Unit_Mother__c	= '';	
    		}	
    		
    		if(objSR.Is_mother_of_Student_an_Ex_Student__c== 'No'){
    			objSR.Academic_Year_Ex_Mother__c	= '';
    			objSR.GEMS_School_Mother__c	= '';	
    		}
    		
    		if(objSR.Is_mother_of_Student_an_employee_in_GEMS__c== 'No'){
    			objSR.Staff_id_Mother__c	= '';
    			objSR.Business_Unit_Mother__c	= '';	
    		}
    		
    		if(objSR.Primary_Contact__c!='Guardian' && objSR.Fees_Sponsor__c!='Guardian' && objSR.Fees_Sponsor__c!='Guardian\'s Company' && objSR.Show_Guardian_Contact_Details__c == false){
    			objSR.First_Name_Guardian__c	= '';
    			objSR.Last_Name_Guardian__c	= '';
    			objSR.Country_Guardian__c	= '';
    			objSR.City_Emirate_Guardian__c	= '';
    			objSR.Area_Guardian__c	= '';
    			objSR.Street_Guardian__c	= '';
    			objSR.Building_Guardian__c	= '';
    			objSR.Apartment_No_Guardian__c	= '';
    			objSR.P_O_Box_Guardian__c	= '';
    			objSR.Home_Phone_Guardian__c	= '';
    			objSR.Mobile_Guardian__c	= '';
    			objSR.Office_Phone_Guardian__c	= '';
    			objSR.Fax_No_Guardian__c	= '';
    			objSR.Email_Guardian__c	= '';
    			objSR.Occupation_Guardian__c	= '';
    			objSR.Makani_Guardian__c	= '';
    			objSR.Company_Guardian__c	= '';
    		}	
    		
    		if(objSR.Is_father_of_Student_an_Ex_Student__c== 'No'){
    			objSR.Academic_Year_Ex__c	= '';
    			objSR.GEMS_School_Father__c	= '';	
    		}
    		
    		if(objSR.Is_father_of_Student_an_employee_in_GEMS__c== 'No'){
    			objSR.Staff_ID__c	= '';
    			objSR.Business_Unit_Father__c	= '';	
    		}
    	}  
    }
    /*
        Method Name :   DynamicButtonAction
        Description :   Action Method which Dynamically Changes the layout & Actions based on the Configuration
    */
    public PageReference DynamicButtonAction(){
        string whatId = '';
        System.debug('StringActionId ==>' + stringActionId);

        try{
            if(stringActionId!=null && stringActionId!=''){
                boolean hasPGNavRule = false;
                boolean isNext = false;
                for(Section_Detail__c objSecDtl:[select id,Name,Navigation_Direction__c,(select id from Page_Navigation_Rule__r) from Section_Detail__c where Id=:stringActionId]){
                    if(objSecDtl.Navigation_Direction__c=='Forward')
                        isNext = true;
                        
                    if(objSecDtl.Page_Navigation_Rule__r!=null && objSecDtl.Page_Navigation_Rule__r.size()>0){
                        hasPGNavRule = true;
                    }
                } 
                
                if(isNext==true){
                    if(objSR.filled_page_ids__c==null)
                        objSR.filled_page_ids__c = '';
                    if(objSR.filled_page_ids__c=='' || (objSR.filled_page_ids__c!=null && objSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                        if(objSR.filled_page_ids__c=='')
                            objSR.filled_page_ids__c = strPageId;
                        else
                            objSR.filled_page_ids__c = objSR.filled_page_ids__c+';'+strPageId;
                    }
                }
            	upsert objSR;
                apexpages.currentPage().getParameters().put('Id',string.valueOf(objSR.Id));
                
                PreparePageBlockUtil.FlowId = mapParameters.get('FlowId'); 
                PreparePageBlockUtil.PageId = mapParameters.get('PageId');
                PreparePageBlockUtil.objSR = objSR;
                PreparePageBlockUtil.ActionId = stringActionId;

                PreparePageBlockUtil objPB = new PreparePageBlockUtil();
                pagereference pg = objPB.getButtonAction();

                //Map<String, String> currentPageParams = ApexPages.currentPage().getParameters();
                //currentPageParams.remove('FlowId').remove('PageId').remove('Id');

                pg.getParameters().put('BSU', ApexPages.currentPage().getParameters().get('BSU'));
				pg.setRedirect(true);
                return pg;
                
            }
        }catch(Exception e){
            System.debug('ProcessFlow.DynamicButtonAction ==> ' + e.getStackTraceString());
        }
        return null;
    }
     
    /*
        Method Name :   CommitRecord
        Description :   This will saves the record i.e. Insert or Update.
    */
    public void CommitRecord(){
        try{
            if(objSR.filled_page_ids__c==null)
                objSR.filled_page_ids__c = '';
            if(objSR.filled_page_ids__c=='' || (objSR.filled_page_ids__c!=null && objSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                if(objSR.filled_page_ids__c=='')
                    objSR.filled_page_ids__c = strPageId;
                else
                    objSR.filled_page_ids__c = objSR.filled_page_ids__c+';'+strPageId;
            }
            upsert objSR;
        }catch(Exception e){
            string DMLError = e.getdmlMessage(0)+'';
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
        }
    }
    
    /*
        Method Name :   CancelSR
        Decription  :   This will cancel the Open SR and the PriceItems of the SR also get cancelled.
    */
    public pagereference CancelSR(){
        Pagereference pg = new PageReference('');
        pg.setRedirect(true); 
        return pg;
    }
    public string strNavigatePageId{get;set;}
    public pagereference goTopage(){
        //when user clicks on any of the side bar page, id will be assinged to this variable
        if(strNavigatePageId!=null && strNavigatePageId!=''){
            try{
                if(objSR.filled_page_ids__c==null)
                    objSR.filled_page_ids__c = '';
                if(objSR.filled_page_ids__c=='' || (objSR.filled_page_ids__c!=null && objSR.filled_page_ids__c.indexOf(strPageId)==-1)){
                    if(objSR.filled_page_ids__c=='')
                        objSR.filled_page_ids__c = strPageId;
                    else
                        objSR.filled_page_ids__c = objSR.filled_page_ids__c+';'+strPageId;
                }
                upsert objSR;
                PreparePageBlockUtil objSidebarRef = new PreparePageBlockUtil();
                PreparePageBlockUtil.strSideBarPageId = strNavigatePageId;
                PreparePageBlockUtil.objSR = objSR;
                return objSidebarRef.getSideBarReference(); // page reference is return dynamically
                
            }catch(dmlexception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getdmlMessage(0)+''));
                return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()+''));
                return null;
            }
        }
         return null;
    }
}