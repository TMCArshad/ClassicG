/*
    Author      :   Durga Prasad
    Description :   Utility class to prepare the Configured Sections and pages of Process Flow.
*/
public without sharing class PreparePageBlockUtil {
    public static string FlowId;
    public static string PageId;
    public static sObject objSR;
    public static string strReqFieldIds;
    public static string pageTitle;
    public static string pageDescription;
    public static string ActionId;
    public static string strSideBarPageId;
    public static string PageName;
    public static string PageBlockTitle;
    public HexaBPM__Service_Request__c objFinSR;
    public PreparePageBlockUtil(){
        objFinSR = new HexaBPM__Service_Request__c();
    }
    /*
        Method Name :   getReviewFinalisePB
        Description :   Method to prepare the Review and finalise page.
    */  
    public Component.Apex.PageBlock getReviewFinalisePB(){
        string pageflowId = FlowId;
        string strPageId = PageId;
        strReqFieldIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        //pb.Title = 'Service Request Detail';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        if(FlowId!=null && FlowId!=''){
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            map<id,id> mapHiddenPageIDs = new map<id,id>();
            string strHiddenPageIDS = getHiddenPageIds(FlowId,objSR);
            if(strHiddenPageIDS!=null && strHiddenPageIDS!=''){
                if(strHiddenPageIDS.indexOf(',')>-1){
                    for(string PgID:strHiddenPageIDS.split(',')){
                        mapHiddenPageIDs.put(PgID,PgID);
                    }
                }else if(strHiddenPageIDS.indexOf(',')==-1){
                    mapHiddenPageIDs.put(strHiddenPageIDS,strHiddenPageIDS);
                }
            }
            System.debug('***mapHiddenPageIDs:'+mapHiddenPageIDs);
            for(Section__c objSec:[select id,Name,Page__r.Is_Custom_Component__c,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Cancel_Request__c,Object_Name__c,Order__c,Section__c,Field_Description__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c from Section_Details__r order by Order__c), 
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Page__r.Page_Flow__c=:FlowId order by Page__r.Page_Order__c,Order__c,Section_Type__c]){
                if(mapHiddenPageIDs.get(objSec.Page__c)==null){
                    lstSec.add(objSec);
                    if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            if(objSecDet.Render_By_Default__c==false)
                                setSectionDetailIds.add(objSecDet.Id);
                        }
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Flow_Condition__c ObjPFCond:[select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Condition__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Flow_Condition__c> lstCond = new list<Page_Flow_Condition__c>();
                    if(mapSecDetailCond.get(ObjPFCond.Section_Detail__c)!=null && mapSecDetailCond.get(ObjPFCond.Section_Detail__c).size()>0){
                        lstCond = mapSecDetailCond.get(ObjPFCond.Section_Detail__c);
                        lstCond.add(ObjPFCond);
                    }else{
                        lstCond.add(ObjPFCond);
                    }
                    mapSecDetailCond.put(ObjPFCond.Section_Detail__c,lstCond);
                }
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
            
            for(Section__c objSec:lstSec){
                if(objSec.Section_Type__c=='PageBlockSection' && objSec.Page__r.Is_Custom_Component__c==false){
                    boolean bBuildSection = false;
                    if(objSec.Default_Rendering__c==true){
                        bBuildSection = true;
                    }else{
                        if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                            boolean RulesResult = false;
                            for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                                boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                                if(eachCondition!=null && eachCondition==true)
                                    RulesResult = true;                         
                            }
                            bBuildSection = RulesResult;
                        }else if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                            for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                                if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                    bBuildSection = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                                    system.debug('bBuildSection==>'+bBuildSection);
                                }
                            }
                        }
                    }
                    if(bBuildSection==true){
                        Component.Apex.PageBlockSection dycPB = new Component.Apex.PageBlockSection();
                        dycPB.columns = 2;
                        dycPB.collapsible = false;
                        dycPB.Title = objSec.Name;
                        Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                        pageBlockSectionWrapper.layout = 'block';
                        pageBlockSectionWrapper.styleClass = 'colLayout' + objSec.layout__c+' pageBlockSectionWrapper';
                        pageBlockSectionWrapper.childComponents.add(dycPB);
                        if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                            boolean RenderPBS = objSec.Default_Rendering__c;
                            if(RenderPBS!=null && RenderPBS==false){
                                if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                                    for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                                        if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                            RenderPBS = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                                        }
                                    }
                                }
                            }
                            dycPB.Title = objSec.Name;
                            dycPB.rendered = RenderPBS;
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
                                    }else if(mapSecDetailCond!=null && mapSecDetailCond.get(objSecDet.Id)!=null){
                                        for(Page_Flow_Condition__c SCDetailCond:mapSecDetailCond.get(objSecDet.Id)){
                                            if(SCDetailCond.Object_Name__c!=null && SCDetailCond.Field_Name__c!=null && SCDetailCond.Operator__c!=null){
                                                bRenderSecDetail = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SCDetailCond.Object_Name__c,SCDetailCond.Field_Name__c,SCDetailCond.Operator__c,SCDetailCond.Value__c);
                                            }
                                        }
                                    }
                                }
                                System.debug('objSecDet.Component_Type__c==>'+objSecDet.Component_Type__c);
                                System.debug('bRenderSecDetail==>'+bRenderSecDetail);
                                if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Input Field' || objSecDet.Component_Type__c=='Output Field'){
                                    pb.mode = 'detail';
                                    Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                    Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                    PBSItemPnl.layout = 'block';
                                    PBSItemPnl.styleClass = 'rowWrapper';
                                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                    Schema.SObjectType ObjSchema;
                                    Component.Apex.outputfield inpFld = new Component.Apex.outputfield();
                                    inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                    if(objSecDet.Object_Name__c=='HexaBPM__Service_Request__c'){
                                        inpFld.expressions.value = '{!objSR.'+objSecDet.Field_API_Name__c+'}';
                                        ObjSchema = schemaMap.get('HexaBPM__Service_Request__c');
                                    }
                                    Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
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
                                    PBSItemPnl.childComponents.add(labelPanel);
                                    PBSItemPnl.childComponents.add(fieldPanel);
                                    PBSItem.childComponents.add(PBSItemPnl);
                                    dycPB.childComponents.add(PBSItem);
                                }
                            }
                        }
                        pb.childComponents.add(pageBlockSectionWrapper);
                    }
                }else if(PageId==objSec.Page__c && objSec.Section_Type__c=='CommandButtonSection'){
                    boolean bBuildSection = false;
                    if(objSec.Default_Rendering__c==true){
                        bBuildSection = true;
                    }else{
                        if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                            boolean RulesResult = false;
                            for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                                boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                                if(eachCondition!=null && eachCondition==true)
                                    RulesResult = true;                         
                            }
                            bBuildSection = RulesResult;
                        }else if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                            for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                                if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                    bBuildSection = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                                }
                            }
                        }
                    }
                    if(bBuildSection==true && objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
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
                                }else if(mapSecDetailCond!=null && mapSecDetailCond.get(objSecDet.Id)!=null){
                                    for(Page_Flow_Condition__c SCDetailCond:mapSecDetailCond.get(objSecDet.Id)){
                                        if(SCDetailCond.Object_Name__c!=null && SCDetailCond.Field_Name__c!=null && SCDetailCond.Operator__c!=null){
                                            bRenderSecDetail = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SCDetailCond.Object_Name__c,SCDetailCond.Field_Name__c,SCDetailCond.Operator__c,SCDetailCond.Value__c);
                                        }
                                    }
                                }
                            }
                            if(bRenderSecDetail){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width: 70px;min-height:20px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                if(objSecDet.Commit_the_Record__c==false && objSecDet.Cancel_Request__c==false){
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }else if(objSecDet.Cancel_Request__c==true){
                                    dycBtn.onClick = 'CancelRequest();return false;';
                                }
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
            if(pageflowId==null || pageflowId==''){
                pageflowId = apexpages.currentPage().getparameters().get('FlowId');
            }
        }
        return pb;
    }
    
    
    public Component.Apex.PageBlock getConfirmationPB(){
        string pageflowId = FlowId;
        string strPageId = PageId;
        strReqFieldIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        pb.mode = 'detail';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        if(FlowId!=null && FlowId!=''){
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            map<id,id> mapHiddenPageIDs = new map<id,id>();
            string strHiddenPageIDS = getHiddenPageIds(FlowId,objFinSR);
            if(strHiddenPageIDS!=null && strHiddenPageIDS!=''){
                if(strHiddenPageIDS.indexOf(',')>-1){
                    for(string PgID:strHiddenPageIDS.split(',')){
                        mapHiddenPageIDs.put(PgID,PgID);
                    }
                }else if(strHiddenPageIDS.indexOf(',')==-1){
                    mapHiddenPageIDs.put(strHiddenPageIDS,strHiddenPageIDS);
                }
            }
            System.debug('Hidden Page IDs ==> ' + strHiddenPageIDS);
            for(Section__c objSec:[select id,Name,Page__r.Is_Custom_Component__c,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Cancel_Request__c,Object_Name__c,Order__c,Section__c,Field_Description__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c from Section_Details__r order by Order__c), 
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Page__r.Page_Flow__c=:FlowId order by Page__r.Page_Order__c,Order__c,Section_Type__c]){
                System.debug('Section ==>' + objSec );
                if(mapHiddenPageIDs.get(objSec.Page__c)==null){
                    lstSec.add(objSec);
                    if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            if(objSecDet.Render_By_Default__c==false)
                                setSectionDetailIds.add(objSecDet.Id);
                        }
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Flow_Condition__c ObjPFCond:[select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Condition__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Flow_Condition__c> lstCond = new list<Page_Flow_Condition__c>();
                    if(mapSecDetailCond.get(ObjPFCond.Section_Detail__c)!=null && mapSecDetailCond.get(ObjPFCond.Section_Detail__c).size()>0){
                        lstCond = mapSecDetailCond.get(ObjPFCond.Section_Detail__c);
                        lstCond.add(ObjPFCond);
                    }else{
                        lstCond.add(ObjPFCond);
                    }
                    mapSecDetailCond.put(ObjPFCond.Section_Detail__c,lstCond);
                }
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
            
            for(Section__c objSec:lstSec){
                System.debug('Rendering Section ==>' + objSec);

                if(objSec.Section_Type__c=='PageBlockSection' && objSec.Page__r.Is_Custom_Component__c==false){
                    boolean bBuildSection = false;
                    if(objSec.Default_Rendering__c==true){
                        bBuildSection = true;
                    }else{
                        if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                            boolean RulesResult = false;
                            for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                                boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                                if(eachCondition!=null && eachCondition==true)
                                    RulesResult = true;                         
                            }
                            bBuildSection = RulesResult;
                        }
                    }
                    if(bBuildSection==true){
                        Component.Apex.PageBlockSection dycPB = new Component.Apex.PageBlockSection();
                        dycPB.columns = 2;
                        dycPB.collapsible = false;
                        dycPB.Title = objSec.Name;
                        Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                        pageBlockSectionWrapper.layout = 'block';
                        pageBlockSectionWrapper.styleClass = 'colLayout' + objSec.layout__c+' pageBlockSectionWrapper';
                        pageBlockSectionWrapper.childComponents.add(dycPB);
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
                                if(bRenderSecDetail==true && objSecDet.Component_Type__c=='Input Field' || objSecDet.Component_Type__c=='Output Field'){
                                    pb.mode = 'detail';
                                    Component.Apex.PageBlockSectionItem PBSItem = new Component.Apex.PageBlockSectionItem();
                                    Component.Apex.OutPutPanel PBSItemPnl = new Component.Apex.OutPutPanel();
                                    PBSItemPnl.layout = 'block';
                                    PBSItemPnl.styleClass = 'rowWrapper';
                                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                    Schema.SObjectType ObjSchema;
                                    Component.Apex.outputfield inpFld = new Component.Apex.outputfield();
                                    inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                    if(objSecDet.Object_Name__c=='HexaBPM__Service_Request__c'){
                                        inpFld.expressions.value = '{!objFinSR.'+objSecDet.Field_API_Name__c+'}';
                                        ObjSchema = schemaMap.get('HexaBPM__Service_Request__c');
                                    }
                                    Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
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
                                    PBSItemPnl.childComponents.add(labelPanel);
                                    PBSItemPnl.childComponents.add(fieldPanel);
                                    PBSItem.childComponents.add(PBSItemPnl);
                                    dycPB.childComponents.add(PBSItem);
                                }
                            }
                        }
                        pb.childComponents.add(pageBlockSectionWrapper);
                    }
                }else if(PageId==objSec.Page__c && objSec.Section_Type__c=='CommandButtonSection'){
                    /*
                    boolean bBuildSection = false;
                    if(objSec.Default_Rendering__c==true){
                        bBuildSection = true;
                    }else{
                        if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                            boolean RulesResult = false;
                            for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                                boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objFinSR);
                                if(eachCondition!=null && eachCondition==true)
                                    RulesResult = true;                         
                            }
                            bBuildSection = RulesResult;
                        }else if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                            for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                                if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                    bBuildSection = Cls_Evaluate_Conditions.Check_each_Condition(objFinSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                                }
                            }
                        }
                    }
                    if(bBuildSection==true && objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                        for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                            boolean bRenderSecDetail = false;
                            if(objSecDet.Render_By_Default__c==true){
                                bRenderSecDetail = true;
                            }else{
                                if(mapSecDetailRenderRules!=null && mapSecDetailRenderRules.get(objSecDet.Id)!=null){
                                    boolean RulesResult = false;
                                    for(Page_Navigation_Rule__c SDRendRule:mapSecDetailRenderRules.get(objSecDet.Id)){
                                        boolean eachRule = Cls_Evaluate_Conditions.executeNavigationRules(SDRendRule.Rule_Text_Condition__c,objFinSR);
                                        if(eachRule!=null && eachRule==true)
                                            RulesResult = true;
                                    }
                                    bRenderSecDetail = RulesResult;
                                }else if(mapSecDetailCond!=null && mapSecDetailCond.get(objSecDet.Id)!=null){
                                    for(Page_Flow_Condition__c SCDetailCond:mapSecDetailCond.get(objSecDet.Id)){
                                        if(SCDetailCond.Object_Name__c!=null && SCDetailCond.Field_Name__c!=null && SCDetailCond.Operator__c!=null){
                                            bRenderSecDetail = Cls_Evaluate_Conditions.Check_each_Condition(objFinSR,SCDetailCond.Object_Name__c,SCDetailCond.Field_Name__c,SCDetailCond.Operator__c,SCDetailCond.Value__c);
                                        }
                                    }
                                }
                            }
                            if(bRenderSecDetail){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width: 70px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                if(objSecDet.Commit_the_Record__c==false && objSecDet.Cancel_Request__c==false){
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }else if(objSecDet.Cancel_Request__c==true){
                                    dycBtn.onClick = 'CancelRequest();return false;';
                                }
                                if(objSecDet.Button_Location__c!=null)
                                    PBtns.location = objSecDet.Button_Location__c;
                                if (objSecDet.Button_Position__c == 'left')
                                    dycBtn.styleClass = 'left';
                                else if (objSecDet.Button_Position__c == 'right')
                                    dycBtn.styleClass = 'right';
                                PBtns.childComponents.add(dycBtn);
                            }
                        }
                    }
                    */
                }
            }
            if(pageflowId==null || pageflowId==''){
                pageflowId = apexpages.currentPage().getparameters().get('FlowId');
            }
        }
        return pb;
    }
    /*
        Method Name :   getDyncPgMainPB
        Description :   Method to prepare the Standard fields
    */  
    public Component.Apex.PageBlock getDyncPgMainPB(){
        string strHiddenPageIds = '';
        string pageflowId = FlowId;
        string strPageId = PageId;
        strReqFieldIds = '';
        strHiddenPageIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock pb = new Component.Apex.PageBlock();
        pb.Id = 'MainPB';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        pb.childComponents.add(PBtns);
        System.debug('Page ID ==>' + strPageId);

        if(strPageId!=null && strPageId!=''){
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
                    
                    Component.Apex.OutputPanel pageBlockSectionWrapper = new Component.Apex.OutputPanel();
                    pageBlockSectionWrapper.layout = 'block';
                    pageBlockSectionWrapper.styleClass = 'colLayout' + objSec.layout__c+' pageBlockSectionWrapper';
                    pageBlockSectionWrapper.childComponents.add(dycPB);

                    pageBlockSectionWrapper.styleClass += ' ' + string.valueOf(objSec.Name).replaceAll(' ', '-');
                    
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

                                /*
                                //on change event is invoking the javascript method
                                if(objSecDet.hasOnChange__c==true)
                                    inpFld.onChange='InvokeChangeEvent();return false;';
                                */


                                // if label is not defined for a field then get it from definition
                                Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();

                                String fieldType = String.valueOf(fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getType());
                                PBSItemPnl.styleClass += ' type-' + fieldType;

                                if(fieldType == 'EMAIL'){
                                    inpFld.type = 'email';
                                }else if(fieldType == 'PHONE'){
                                    inpFld.styleClass += ' phone';
                                }

                                PBSItemPnl.styleClass += ' type-' + fieldType;


                                Component.Apex.outputlabel Fldlabel = new Component.Apex.outputlabel();
                                Fldlabel.value = objSecDet.Component_Label__c;
                                if (objSecDet.Component_Label__c == '' || objSecDet.Component_Label__c == null)
                                    Fldlabel.value = fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getLabel();
                                else
                                    Fldlabel.value = objSecDet.Component_Label__c;


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
                                    //inpFld.styleClass = (inpFld.styleClass == null ? 'requiredInput' : inpFld.styleClass + ' requiredInput');
                                    //ReqBlockMainPnl.styleClass = 'requiredInput';
                                    inpFld.styleClass='input requiredInput';

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


                                // Bilal - capturing sections to re-render
                                //on change event is invoking the javascript method
                                if(objSecDet.hasOnChange__c==true){
                                    if(String.isBlank(objSecDet.Re_render_Sections__c) || String.valueOf(objSecDet.Re_render_Sections__c).contains('All')){
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
                                        rerenderSectionSet.add('mainForm');
                                        acFunc.reRender = rerenderSectionSet;
                                        inpFld.onChange='if(typeof InvokeFieldChange!="undefined")InvokeFieldChange();InvokeChangeEvent_'+objSecDet.Id+'();return false;';

                                        acFunc.status = 'pleasewait';
                                        //acFunc.expressions.action = '{!reloadFlowComponent}';
                                        acFunc.oncomplete='InvokeChangeEventComplete();';
                                        acFunc.immediate = false;
                                        acFunc.timeout = 10000;
                                        PBSItemPnl.childComponents.add(acFunc);
                                    }
                                }

                                fDescPanel.childComponents.add(FldDescription);

                                PBSItemPnl.childComponents.add(labelPanel);

                                PBSItemPnl.childComponents.add(fieldPanel);

                                if(objSec.layout__c == '1')
                                    PBSItemPnl.childComponents.add(fDescPanel);

                                PBSItem.childComponents.add(PBSItemPnl);

                                dycPB.childComponents.add(PBSItem);
                                
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

                                if(objSecDet.Object_Name__c=='HexaBPM__Service_Request__c'){
                                    ObjSchema = schemaMap.get('HexaBPM__Service_Request__c');
                                }


                                Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
                                String fieldType = String.valueOf(fieldMap.get(objSecDet.Field_API_Name__c).getDescribe().getType());
                                PBSItemPnl.styleClass += ' type-' + fieldType;


                                Component.Apex.Outputfield inpFld = new Component.Apex.Outputfield();

                                inpFld.Id = objSecDet.Field_API_Name__c.ReplaceAll('_','');
                                inpFld.expressions.value = '{!objSR.'+objSecDet.Field_API_Name__c+'}';
                                inpFld.styleClass='input disabled';


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
                                fieldPanel.styleClass = 'fieldWrapper readonly disabled';
                                
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
        if(pageflowId!=null && pageflowId!=''){
            strHiddenPageIds = PreparePageBlockUtil.getHiddenPageIds(pageflowId,objSR);
        }
        return pb;
    }
    
    /*
        Method Name :   getProcessFlowReference
        Description :   Not using.
    */  
    public PageReference getProcessFlowReference(){
        return null;
    }
    
    /*
        Method Name :   getButtonAction
        Description :   Preparing the pagereference based on the button action.
    */
    public PageReference getButtonAction(){
        string stringActionId = ActionId;
        string whatId = ''; 
        string strPageId;
        try{
            if(stringActionId!=null && stringActionId!=''){
                boolean hasPGNavRule = false;
                for(Section_Detail__c objSecDtl:[select id,(select id from Page_Navigation_Rule__r) from Section_Detail__c where Id=:stringActionId]){
                    if(objSecDtl.Page_Navigation_Rule__r!=null && objSecDtl.Page_Navigation_Rule__r.size()>0){
                        hasPGNavRule = true;
                    }
                }
                if(hasPGNavRule==true){
                    for(Page_Navigation_Rule__c PGNRule:[select id,Name,Rule_Text_Condition__c,(select id,Is_Custom_Component__c,Page__c,Page__r.Is_Custom_Component__c,Page__r.VF_Page_API_Name__c,Page__r.What_Id__c,Page__r.Page_Flow__c from Page_Flow_Actions__r),(select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) from Page_Navigation_Rule__c where Section_Detail__c=:stringActionId]){
                        if(PGNRule!=null && PGNRule.Page_Flow_Conditions__r!=null && PGNRule.Page_Flow_Conditions__r.size()>0){
                            System.debug('getButtonAction > PGNRule.Rule_Text_Condition__c ==>'+PGNRule.Rule_Text_Condition__c);
                            boolean BRRuleResult = Cls_Evaluate_Conditions.executeNavigationRules(PGNRule.Rule_Text_Condition__c,objSR);
                            System.debug('getButtonAction > BRRuleResult ==>'+BRRuleResult);
                            System.debug('getButtonAction > PGNRule.PFR SIZE ==>'+PGNRule.Page_Flow_Actions__r.size());
                            if(BRRuleResult!=null && BRRuleResult==true && PGNRule.Page_Flow_Actions__r!=null && PGNRule.Page_Flow_Actions__r.size()>0){
                                for(Page_Flow_Action__c PGAct:PGNRule.Page_Flow_Actions__r){
                                    if(PGAct.Page__c!=null){
                                        if(PGAct.Page__r.What_Id__c=='HexaBPM__Service_Request__c'){
                                            whatId = string.valueOf(objSR.get('Id'));
                                        }else{
                                            whatId = string.valueOf(objSR.get('Id'));
                                        }
                                        if(PGAct.Page__c!=null && PGAct.Page__r.Is_Custom_Component__c && PGAct.Page__r.VF_Page_API_Name__c!=null){
                                            if(whatId==null || (whatId!=null && whatId=='')){
                                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Save the Record to proceed.'));
                                                return null;
                                            }
                                            strPageId = PGAct.Page__c;
                                            Pagereference pg;
                                            if(PGAct.Page__r.VF_Page_API_Name__c.indexof('?')>-1){
                                                pg = new PageReference('/apex/'+PGAct.Page__r.VF_Page_API_Name__c+'&Id='+whatId+'&FlowId='+PGAct.Page__r.Page_Flow__c+'&PageId='+PGAct.Page__c);
                                            }else{
                                                pg = new PageReference('/apex/'+PGAct.Page__r.VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+PGAct.Page__r.Page_Flow__c+'&PageId='+PGAct.Page__c);
                                            }
                                            pg.setRedirect(true);
                                            return pg;
                                        }else if(PGAct.Page__c!=null && PGAct.Page__r.Is_Custom_Component__c==false && PGAct.Page__r.VF_Page_API_Name__c!=null){
                                            strPageId = PGAct.Page__c;
                                            Pagereference pg = new PageReference('/apex/'+PGAct.Page__r.VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+PGAct.Page__r.Page_Flow__c+'&PageId='+PGAct.Page__c);
                                            pg.setRedirect(true);
                                            return pg;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else{
                    for(Page_Flow_Action__c objActCond:[select id,Is_Custom_Component__c,Page__r.Is_Custom_Component__c,Page__c,Page__r.VF_Page_API_Name__c,Page__r.What_Id__c,Page__r.Page_Flow__c from Page_Flow_Action__c where Section_Detail__c=:stringActionId]){
                        if(objActCond.Id!=null){
                            if(objActCond.Page__r.What_Id__c=='HexaBPM__Service_Request__c'){
                                whatId = string.valueOf(objSR.get('Id'));
                            }else{
                                whatId = string.valueOf(objSR.get('Id'));
                            }
                            boolean ConditionMet = false;
                            ConditionMet = true;
                            if(ConditionMet){
                                if(objActCond.Page__c!=null && objActCond.Page__r.Is_Custom_Component__c){
                                    if(whatId==null || (whatId!=null && whatId=='')){
                                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Save the Record to proceed.'));
                                        return null;
                                    }
                                    strPageId = objActCond.Page__c;
                                    Pagereference pg;
                                    if(objActCond.Page__r.VF_Page_API_Name__c.indexof('?')>-1){
                                        pg = new PageReference('/apex/'+objActCond.Page__r.VF_Page_API_Name__c+'&Id='+whatId+'&FlowId='+objActCond.Page__r.Page_Flow__c+'&PageId='+objActCond.Page__c);
                                    }else{
                                        pg = new PageReference('/apex/'+objActCond.Page__r.VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+objActCond.Page__r.Page_Flow__c+'&PageId='+objActCond.Page__c);                                 
                                    }
                                    pg.setRedirect(true);
                                    return pg;
                                }
                                /*
                                else{
                                    strPageId = objActCond.Page__c;
                                    Pagereference pg = new PageReference('/apex/Process_Flow?Id='+whatId+'&FlowId='+objActCond.Page__r.Page_Flow__c+'&PageId='+objActCond.Page__c);
                                    pg.setRedirect(true);
                                    return pg;
                                }
                                */
                                else if(objActCond.Page__c!=null && objActCond.Page__r.Is_Custom_Component__c==false && objActCond.Page__r.VF_Page_API_Name__c!=null){
                                    strPageId = objActCond.Page__c;
                                    Pagereference pg = new PageReference('/apex/'+objActCond.Page__r.VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+objActCond.Page__r.Page_Flow__c+'&PageId='+objActCond.Page__c);
                                    pg.setRedirect(true);
                                    return pg;
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
        }
        return null;
    }
    
    /*
        Method Name :   getButtonsPB
        Description :   Preparing the Command buttons for an Custom Page.
    */
    public Component.Apex.PageBlock getButtonsPB(){
        string strHiddenPageIds = '';
        string pageflowId = FlowId;
        string strPageId = PageId;
        strReqFieldIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock Btnspb = new Component.Apex.PageBlock();
        Btnspb.Id = 'MainPB';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        Btnspb.childComponents.add(PBtns);
        if(strPageId!=null && strPageId!=''){
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            
            for(Section__c objSec:[select id,Name,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Object_Name__c,Order__c,Section__c,Field_Description__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c from Section_Details__r order by Order__c), 
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Section_Type__c='CommandButtonSection' and Page__c=:strPageId order by Order__c,Section_Type__c]){
                lstSec.add(objSec);
                if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                    for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                        if(objSecDet.Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Flow_Condition__c ObjPFCond:[select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Condition__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Flow_Condition__c> lstCond = new list<Page_Flow_Condition__c>();
                    if(mapSecDetailCond.get(ObjPFCond.Section_Detail__c)!=null && mapSecDetailCond.get(ObjPFCond.Section_Detail__c).size()>0){
                        lstCond = mapSecDetailCond.get(ObjPFCond.Section_Detail__c);
                        lstCond.add(ObjPFCond);
                    }else{
                        lstCond.add(ObjPFCond);
                    }
                    mapSecDetailCond.put(ObjPFCond.Section_Detail__c,lstCond);
                }
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
            for(Section__c objSec:lstSec){
                boolean bBuildSection = false;
                if(objSec.Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                            boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }else if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                        for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                            if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                bBuildSection = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                            }
                        }
                    }
                }
                if(bBuildSection==true && objSec.Section_Type__c=='CommandButtonSection'){
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
                                }else if(mapSecDetailCond!=null && mapSecDetailCond.get(objSecDet.Id)!=null){
                                    for(Page_Flow_Condition__c SCDetailCond:mapSecDetailCond.get(objSecDet.Id)){
                                        if(SCDetailCond.Object_Name__c!=null && SCDetailCond.Field_Name__c!=null && SCDetailCond.Operator__c!=null){
                                            bRenderSecDetail = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SCDetailCond.Object_Name__c,SCDetailCond.Field_Name__c,SCDetailCond.Operator__c,SCDetailCond.Value__c);
                                        }
                                    }
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width:70px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                if(objSecDet.Commit_the_Record__c==false){
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }
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
        return Btnspb;
    }
    /*
        Method Name :   getBottomButtonsPB
        Description :   Preparing the Command buttons which will display in bottom of an Custom Page.
    */
    public Component.Apex.PageBlock getBottomButtonsPB(){
        string strHiddenPageIds = '';
        string pageflowId = FlowId;
        string strPageId = PageId;
        strReqFieldIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock Btnspb = new Component.Apex.PageBlock();
        Btnspb.Id = 'MainPBBottom';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        Btnspb.childComponents.add(PBtns);
        if(strPageId!=null && strPageId!=''){
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            
            for(Section__c objSec:[select id,Name,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Object_Name__c,Order__c,Section__c,Field_Description__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c from Section_Details__r order by Order__c), 
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Section_Type__c='CommandButtonSection' and Page__c=:strPageId order by Order__c,Section_Type__c]){
                lstSec.add(objSec);
                if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                    for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                        if(objSecDet.Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Flow_Condition__c ObjPFCond:[select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Condition__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Flow_Condition__c> lstCond = new list<Page_Flow_Condition__c>();
                    if(mapSecDetailCond.get(ObjPFCond.Section_Detail__c)!=null && mapSecDetailCond.get(ObjPFCond.Section_Detail__c).size()>0){
                        lstCond = mapSecDetailCond.get(ObjPFCond.Section_Detail__c);
                        lstCond.add(ObjPFCond);
                    }else{
                        lstCond.add(ObjPFCond);
                    }
                    mapSecDetailCond.put(ObjPFCond.Section_Detail__c,lstCond);
                }
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
            for(Section__c objSec:lstSec){
                boolean bBuildSection = false;
                if(objSec.Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                            boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }else if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                        for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                            if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                bBuildSection = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                            }
                        }
                    }
                }
                if(bBuildSection==true && objSec.Section_Type__c=='CommandButtonSection'){
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
                                }else if(mapSecDetailCond!=null && mapSecDetailCond.get(objSecDet.Id)!=null){
                                    for(Page_Flow_Condition__c SCDetailCond:mapSecDetailCond.get(objSecDet.Id)){
                                        if(SCDetailCond.Object_Name__c!=null && SCDetailCond.Field_Name__c!=null && SCDetailCond.Operator__c!=null){
                                            bRenderSecDetail = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SCDetailCond.Object_Name__c,SCDetailCond.Field_Name__c,SCDetailCond.Operator__c,SCDetailCond.Value__c);
                                        }
                                    }
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width:70px;min-height:20px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                if(objSecDet.Commit_the_Record__c==false){
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }
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
                }else{
                    Btnspb.rendered = bBuildSection;
                }
            }
        }
        if(pageflowId==null || pageflowId==''){
            pageflowId = apexpages.currentPage().getparameters().get('FlowId');
        }
        return Btnspb;
    }
    
    /*
        Method Name :   getTopButtonsPB
        Description :   Preparing the Command buttons which will display in top of an Custom Page.
    */
    public Component.Apex.PageBlock getTopButtonsPB(){
        string strHiddenPageIds = '';
        string pageflowId = FlowId;
        string strPageId = PageId;
        strReqFieldIds = '';
        Component.Apex.OutputPanel OpPanel = new Component.Apex.OutputPanel();
        Component.Apex.PageBlock Btnspb = new Component.Apex.PageBlock();
        Btnspb.Id = 'MainPBTop';
        Component.Apex.PageBlockButtons PBtns = new Component.Apex.PageBlockButtons();
        Btnspb.childComponents.add(PBtns);
        if(strPageId!=null && strPageId!=''){
            list<Section__c> lstSec = new list<Section__c>();
            map<id,list<Page_Flow_Condition__c>> mapSecDetailCond = new map<id,list<Page_Flow_Condition__c>>();
            map<id,list<Page_Navigation_Rule__c>> mapSecDetailRenderRules = new map<id,list<Page_Navigation_Rule__c>>();
            set<Id> setSectionDetailIds = new set<Id>();
            for(Section__c objSec:[select id,Name,Order__c,Page__c,Section_Type__c,Section_Description__c,Default_Rendering__c,layout__c,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Name,Button_Location__c,
                                   Component_Label__c,Component_Type__c,Field_API_Name__c,button_position__c,Commit_the_Record__c,Disabled__c,Object_Name__c,Order__c,Section__c,Field_Description__c,hasOnChange__c,Mark_it_as_Required__c,Render_By_Default__c,Ignore_Required_Fields__c from Section_Details__r order by Order__c), 
                                   (select id,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) 
                                   from Section__c where Section_Type__c='CommandButtonSection' and Page__c=:strPageId order by Order__c,Section_Type__c]){
                lstSec.add(objSec);
                if(objSec.Section_Details__r!=null && objSec.Section_Details__r.size()>0){
                    for(Section_Detail__c objSecDet:objSec.Section_Details__r){
                        if(objSecDet.Render_By_Default__c==false)
                            setSectionDetailIds.add(objSecDet.Id);
                    }
                }
            }
            if(setSectionDetailIds!=null && setSectionDetailIds.size()>0){
                for(Page_Flow_Condition__c ObjPFCond:[select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Condition__c where Section_Detail__c IN:setSectionDetailIds]){
                    list<Page_Flow_Condition__c> lstCond = new list<Page_Flow_Condition__c>();
                    if(mapSecDetailCond.get(ObjPFCond.Section_Detail__c)!=null && mapSecDetailCond.get(ObjPFCond.Section_Detail__c).size()>0){
                        lstCond = mapSecDetailCond.get(ObjPFCond.Section_Detail__c);
                        lstCond.add(ObjPFCond);
                    }else{
                        lstCond.add(ObjPFCond);
                    }
                    mapSecDetailCond.put(ObjPFCond.Section_Detail__c,lstCond);
                }
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
            System.debug('***lstSec:'+lstSec);
            for(Section__c objSec:lstSec){
                boolean bBuildSection = false;
                if(objSec.Default_Rendering__c==true){
                    bBuildSection = true;
                }else{
                    System.debug('SECTION NAME==>'+objSec.Name);
                    System.debug('PNR SiZE==>'+objSec.Page_Navigation_Rule__r.size());
                    System.debug('PFC SiZE==>'+objSec.Page_Flow_Conditions__r.size());
                    if(objSec.Page_Navigation_Rule__r!=null && objSec.Page_Navigation_Rule__r.size()>0){
                        boolean RulesResult = false;
                        for(Page_Navigation_Rule__c SRendRule:objSec.Page_Navigation_Rule__r){
                            boolean eachCondition = Cls_Evaluate_Conditions.executeNavigationRules(SRendRule.Rule_Text_Condition__c,objSR);
                            if(eachCondition!=null && eachCondition==true)
                                RulesResult = true;                         
                        }
                        bBuildSection = RulesResult;
                    }else if(objSec.Page_Flow_Conditions__r!=null && objSec.Page_Flow_Conditions__r.size()>0){
                        for(Page_Flow_Condition__c SRC:objSec.Page_Flow_Conditions__r){
                            if(SRC.Object_Name__c!=null && SRC.Field_Name__c!=null && SRC.Operator__c!=null){
                                bBuildSection = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SRC.Object_Name__c,SRC.Field_Name__c,SRC.Operator__c,SRC.Value__c);
                            }
                        }
                    }
                }
                if(bBuildSection==true && objSec.Section_Type__c=='CommandButtonSection'){
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
                                }else if(mapSecDetailCond!=null && mapSecDetailCond.get(objSecDet.Id)!=null){
                                    for(Page_Flow_Condition__c SCDetailCond:mapSecDetailCond.get(objSecDet.Id)){
                                        if(SCDetailCond.Object_Name__c!=null && SCDetailCond.Field_Name__c!=null && SCDetailCond.Operator__c!=null){
                                            bRenderSecDetail = Cls_Evaluate_Conditions.Check_each_Condition(objSR,SCDetailCond.Object_Name__c,SCDetailCond.Field_Name__c,SCDetailCond.Operator__c,SCDetailCond.Value__c);
                                        }
                                    }
                                }
                            }
                            if(bRenderSecDetail==true){
                                Component.Apex.CommandButton dycBtn = new Component.Apex.CommandButton();
                                dycBtn.value = objSecDet.Component_Label__c;
                                dycBtn.style = 'min-width:70px;min-height:20px;';
                                dycBtn.Disabled = objSecDet.Disabled__c;
                                if(objSecDet.Commit_the_Record__c==false){
                                    dycBtn.onClick='DoAction("'+objSecDet.Id+'","'+objSecDet.Ignore_Required_Fields__c+'");return false;';
                                }else if(objSecDet.Commit_the_Record__c==true){
                                    dycBtn.onClick='SaveDetails();return false;';
                                }
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
                }else{
                    Btnspb.rendered = bBuildSection;
                }
            }
        }
        if(pageflowId==null || pageflowId==''){
            pageflowId = apexpages.currentPage().getparameters().get('FlowId');
        }
        return Btnspb;
    }
    /*
        Method Name :   getSideBarReference
        Description :   Preparing the pagereference when user clicks on the sidebar.
    */
    public pagereference getSideBarReference(){
        if(strSideBarPageId!=null && strSideBarPageId!=''){
            string whatId;
            if(objSR!=null && objSR.get('Id')!=null)
                whatId = string.valueOf(objSR.get('Id'));
            Page__c pgFlow = new Page__c();
            for(Page__c page:[select Id,VF_Page_API_Name__c,What_Id__c,Page_Flow__c,Is_Custom_Component__c from Page__c where Id=:strSideBarPageId]){
                pgFlow = page;
            }
            if(pgFlow.Is_Custom_Component__c){
                if(whatId==null || (whatId!=null && whatId=='')){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Save the Record to proceed.'));
                    return null;
                }
                Pagereference pg;
                if(pgFlow.VF_Page_API_Name__c.indexof('?')>-1){
                    pg = new PageReference('/apex/'+pgFlow.VF_Page_API_Name__c+'&Id='+whatId+'&FlowId='+pgFlow.Page_Flow__c+'&PageId='+pgFlow.Id);
                }else{
                    pg = new PageReference('/apex/'+pgFlow.VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+pgFlow.Page_Flow__c+'&PageId='+pgFlow.Id);                                  
                }
                pg.setRedirect(true);
                return pg;
            }else{
                Pagereference pg = new PageReference('/apex/'+pgFlow.VF_Page_API_Name__c+'?Id='+whatId+'&FlowId='+pgFlow.Page_Flow__c+'&PageId='+pgFlow.Id);
                pg.setRedirect(true);
                return pg;
            }
        }
        return null;
    }
    
    /*
        Method Name :   getHiddenPageIds
        Description :   Preparing the page Id's which should hide based on the conditions.
    */
    public static string getHiddenPageIds(string strFlowId,sObject objDycObject){
        string strHiddenPageElemIds = '';
        if(strFlowId!=null && strFlowId!='' && objDycObject!=null){
            for(Page__c pg:[select id,Name,(select id,Rule_Text_Condition__c from Page_Navigation_Rule__r),(select id,Section_Detail__c,Object_Name__c,Field_Name__c,Operator__c,Value__c from Page_Flow_Conditions__r) from Page__c where Page_Flow__c=:strFlowId]){
                if(pg.Page_Navigation_Rule__r!=null && pg.Page_Navigation_Rule__r.size()>0){
                    boolean bShowPage = false;
                    for(Page_Navigation_Rule__c PRR:pg.Page_Navigation_Rule__r){
                        if(PRR.Rule_Text_Condition__c!=null && PRR.Rule_Text_Condition__c!=''){
                                bShowPage = Cls_Evaluate_Conditions.executeNavigationRules(PRR.Rule_Text_Condition__c,objDycObject);
                                if(bShowPage==true)
                                    break;
                        }
                    }
                    if(bShowPage==false){
                        if(strHiddenPageElemIds==''){
                            strHiddenPageElemIds = pg.Id;
                        }else{
                            strHiddenPageElemIds = strHiddenPageElemIds+','+pg.Id;
                        }
                    }
                }else if(pg.Page_Flow_Conditions__r!=null && pg.Page_Flow_Conditions__r.size()>0){
                    if(pg.Page_Flow_Conditions__r!=null && pg.Page_Flow_Conditions__r.size()>0){
                        boolean MainCond = false;
                        for(Page_Flow_Condition__c PFC:pg.Page_Flow_Conditions__r){
                            if(PFC.Object_Name__c!=null && PFC.Field_Name__c!=null && PFC.Operator__c!=null){
                                boolean bCondResult = Cls_Evaluate_Conditions.Check_each_Condition(objDycObject,PFC.Object_Name__c,PFC.Field_Name__c,PFC.Operator__c,PFC.Value__c);
                                if(bCondResult!=null && bCondResult==true)
                                    MainCond = true;
                            } 
                        }
                        if(MainCond==false){
                            if(strHiddenPageElemIds==''){
                                strHiddenPageElemIds = pg.Id;
                            }else{
                                strHiddenPageElemIds = strHiddenPageElemIds+','+pg.Id;
                            }
                        }
                    }else{
                        if(strHiddenPageElemIds==''){
                            strHiddenPageElemIds = pg.Id;
                        }else{
                            strHiddenPageElemIds = strHiddenPageElemIds+','+pg.Id;
                        }
                    }
                }
            }
        }
        return strHiddenPageElemIds;
    }
    /*
        Method Name :   prepare_Page_Description
        Description :   Prepares the list of strings which stores the Page Description.
    */
    public static list<String> prepare_Page_Description(string strPageId){
        list<string> lstTitleDesc = new list<string>();
        if(strPageId!=null && strPageId!=''){ 
            for(Page__c objPG:[select id,Name,Page_Description__c from Page__c where id=:strPageId]){
                lstTitleDesc.add(objPG.Name);
                if(objPG.Page_Description__c!=null)
                    lstTitleDesc.add(objPG.Page_Description__c);
            }
        }
        return lstTitleDesc;
    }
    
     /*
        Method Name :   Cancel_SR
        Description :   Not Using.
    */
    public static pagereference Cancel_SR(string strSRID){
        return null;
    }
    public static string Cancel_Open_SR(string SRID){
        string strResult = 'Success';
        try{
            HexaBPM__Service_Request__c objCancelSR = new HexaBPM__Service_Request__c(Id=SRID);
            for(HexaBPM__SR_Status__c srStatus:[select id from HexaBPM__SR_Status__c where HexaBPM__Code__c='CANCELLED' limit 1]){
                objCancelSR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
                objCancelSR.HexaBPM__External_SR_Status__c = srStatus.Id;
            }
            HexaBPM.RecursiveControl.isUpdatedAlready = true;
            update objCancelSR;
            list<HexaBPM__SR_Price_Item__c> lstBlocked_AddedPriceItems = new list<HexaBPM__SR_Price_Item__c>();
            for(HexaBPM__SR_Price_Item__c SRPI:[select id,HexaBPM__Status__c from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c=:SRID and (HexaBPM__Status__c='Blocked' OR HexaBPM__Status__c='Added')]){
                lstBlocked_AddedPriceItems.add(SRPI);
            }
            if(lstBlocked_AddedPriceItems != null && lstBlocked_AddedPriceItems.size() > 0){
                for(integer i=0;i<lstBlocked_AddedPriceItems.size();i++){
                    lstBlocked_AddedPriceItems[i].HexaBPM__Status__c = 'Cancelled';
                }
                update lstBlocked_AddedPriceItems;
            }
        }catch(Exception e){
            strResult = e.getMessage()+'';
        }
        return strResult;
    }
}