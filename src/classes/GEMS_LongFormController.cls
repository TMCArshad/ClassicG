/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Convert SR into person account.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_LongFormController {

    //public final String GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT = '<script>if("parentIFrame" in window)window.parentIFrame.scrollTo(0,0);</script>';

    public HexaBPM__Service_Request__c objSR{get;set;}
    public list<Page__c> lstPages{get;set;}
   
    public GEMS_LongFormController thisClass {get;set;}//not using
    
    public string strNavigatePageId{get;set;}
    
    public string strPageId{get;set;}
    public string stringActionId{get;set;}
    public string PageFlowId;
        
    public string pageTitle{get;set;}
    public string pageDescription{get;set;}
    public string pageName{get;set;}

    public string strHiddenPageIds{get;set;} 
    public string strSRID{get;set;}
    public string strReqFieldIds{get;set;}
    public map<string,string> mapParameters;
    public string strRecordType{get;set;}
    
    public string BSUID {get; set;}
    public School__c objSchool {get; set;}
    public List<SelectOption> academicYearList {get; set;}
    public List<SelectOption> gradeList {get; set;}
    public List<SelectOption> curriculumList {get; set;}
    public List<SelectOption> streamList {get; set;}
    public string leadId ;
    
    
    public boolean showStream {get; set;}
    public boolean showCurriculum {get; set;}
    public boolean disableSR {get; set;}
    public List<SelectOption> currentSchools {get; private set;}
    
   // public string strGeneralInstructions{get;set;}
    /*
        Constructor codes when the Page loads
    */
    public GEMS_LongFormController (){
         try{
            BSUID  = ApexPages.CurrentPage().getParameters().get('BSU');
            strPageId = '';
            strSRID = '';
            strHiddenPageIds = '';
            objSR = new HexaBPM__Service_Request__c();
            lstPages = new list<Page__c>();
            stringActionId = '';
            strReqFieldIds = '';
            strRecordType = '';
     
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
                if(lstPages[0].Page_Flow__r.Record_Type_API_Name__c!=null){
                    strRecordType = lstPages[0].Page_Flow__r.Record_Type_API_Name__c;
                    for(HexaBPM__SR_Template__c srtemp:[select id from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c=:lstPages[0].Page_Flow__r.Record_Type_API_Name__c]){
                        objSR.HexaBPM__SR_Template__c = srtemp.Id;
                    }
                }
                // page title and description are shown here
                if(strPageId!=null && strPageId!=''){
                    prepare_Page_Description();
                }
            }
            if(strSRID!=null && strSRID!=''){
                disableSR = false;
                if(pageflowId!=null && pageflowId!=''){
                    //query all the fields configured in the page are query here.
                    set<string> SetstrFields = Cls_Evaluate_Conditions.FetchObjectFields(pageflowId,'HexaBPM__Service_Request__c');
                    SetstrFields.add('academic_year__c');
                    SetstrFields.add('Grade_Display__c');
                    SetstrFields.add('stream__c');
                    SetstrFields.add('curriculum__c');
                    SetstrFields.add('tentative_joining_date__c');
                    SetstrFields.add('school__c');
                    SetstrFields.add('The_application_is_filled_by__c');
                    SetstrFields.add('Agent_Name__c');
                    SetstrFields.add('Agent_Mobile__c');
                    SetstrFields.add('GEMS_has_permission__c');
                    SetstrFields.add('Declaration__c');
                    SetstrFields.add('School__r.ID__c');
                    SetstrFields.add('lead__c');
                    SetstrFields.add('siblings_studying_in_a_gems_school__c');
                    SetstrFields.add('HexaBPM__External_Status_Name__c');
                    SetstrFields.add('Gradelookup__c');
                    SetstrFields.add('HexaBPM__email__c');
                    SetstrFields.add('date_of_birth__c');
                    string strQuery = 'select Id';
                    
                    for(String strFld:SetstrFields){
                        if(strFld.toLowerCase()!='id')
                            strQuery += ','+strFld.toLowerCase();
                    }
                    strQuery = strQuery+' from HexaBPM__Service_Request__c where Id=:strSRID';
                    for(HexaBPM__Service_Request__c SR:database.query(strQuery)){
                        objSR = SR;
                    }
                    
                    if(objSR.HexaBPM__External_Status_Name__c != 'Draft' || objSR.HexaBPM__External_Status_Name__c == ''){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Enrollment Enquiry is already submitted. Please create another SR'));  
                        disableSR = true;
                    }

                    if(objSR.School__r != null)
                        BSUID = objSR.School__r.ID__c;

                }
             }
            objSR.Is_Flow_Request__c = true;
            
            if(pageflowId!=NULL && pageflowId!='')
                objSR.flow_id__c = pageflowId;
            
            thisClass = this;
            
            if (BSUID != NULL && BSUID != '' && pageName == 'Applicant Details') {
                //get school details, academic year, grade and curriculum
                objSchool = new School__c();
                academicYearList = new List<SelectOption>();
                gradeList = new List<SelectOption>();
                curriculumList = new List<SelectOption>();
                streamList = new List<SelectOption>();
                currentSchools = new List<SelectOption>();
                
                objSchool = GEMS_Utility.getSchool(BSUID);
                
                showCurriculum = false;
                showStream = false;
                if(objSchool!=null){
                    if(string.isBlank(objSR.school__c)){
                        objSR.school__c = objSchool.id;     
                    }
                    
                    getAcademicYearsForSchool();    
                    if(string.isNotBlank(objSchool.gender__c) && objSchool.gender__c!='Both'){
                        objSR.gender__c = objSchool.gender__c;
                    }
                }
            }
            
            if(BSUID != NULL && BSUID != '' && pageName == 'Other Details'){
                currentSchools = GEMS_Utility.getAllCurrentSchools();
            }
            if(objSR!=null && string.isNotBlank(objSR.lead__c)){
                leadId = objSR.lead__c;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()+'----'+e.getLineNumber() + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
            system.debug('-----'+e.getMessage()+'----'+e.getLineNumber());
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
    public GEMS_LongFormController getClass(){
        return this;
    }
    
    /*
        Method Name :   getDyncPgMainPB
        Description :   Method which will creates the Dynamic VF Components based on the Configuration defined
    */
    public Component.Apex.PageBlock getDyncPgMainPB(){
        
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objSR;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        return objPB.getDyncPgMainPB();
        

    }
    
    /*
        Method Name :   RePrepareSection
        Description :   Dummy method which is used to refresh the Dynamic PB to re-prepare the Fields based on new Values
    */
    public void RePrepareSection(){
        if(pageName == 'Applicant Details' && objSR.Siblings_studying_in_a_GEMS_school__c == false){
            objSR.Sibling_Date_of_Birth__c = null;  
            objSR.Sibling_Name__c = ''; 
            objSR.Sibling_Fee_ID__c = '';
            objSR.Sibling_GEMS_School__c = '';
        }    
        
    }
    
    /*
        Method Name :   DynamicButtonAction
        Description :   Action Method which Dynamically Changes the layout & Actions based on the Configuration
    */
    public PageReference DynamicButtonAction(){
        string whatId = ''; 
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
                    if(pageName == 'Declaration'){
                        boolean allowUpdate = true;
                        if(string.isBlank(objSR.The_application_is_filled_by__c) || objSR.Declaration__c == false){
                            allowUpdate = false;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please fill in all required details.' + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                            return null;    
                        }
                            
                        if(objSR.The_application_is_filled_by__c == 'Relocation Agent'){
                            if(objSR.Agent_Mobile__c==null || string.isBlank(objSR.Agent_Name__c)){
                                allowUpdate = false;
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please fill in agent details.' + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                                return null;    
                            }   
                        }
                        if(allowUpdate == true){
                            string status = verify(); 
                            if(status=='Success'){
                                upsert objSR;   
                            }
                            else{
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please enter correct captcha for verification.' + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                                return null;
                            }
                        }
                    }
                    if(pageName == 'Applicant Details'){
                        string validationResult = 'Success';
                        validationResult = applicantDetailValidations(objSR);
                        if(validationResult!='Success'){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,validationResult + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                            return null;
                        }
                        else{
                            if(string.isNotBlank(objSchool.gender__c) && objSchool.gender__c!='Both'){
                                objSR.gender__c = objSchool.gender__c;
                            }
                            objSR.service_type__c = 'Enrollment Long Form';
                            objSR.SR_No__c = 1;
                            objSR.Offer_Period__c = '7';
                            
                            if(GEMS_utility.getAcademicYearID(objSchool.id__c,getLookupValue(objSR.Academic_year__c,academicYearList),objSR.curriculum__c )!=null)
                            	objSR.Academic_Year__c = GEMS_utility.getAcademicYearID(objSchool.id__c,getLookupValue(objSR.Academic_year__c,academicYearList),objSR.curriculum__c ).id;
                            
                            //if(GEMS_utility.getGradeID(objSchool.id__c,objSR.Academic_Year__c,objSR.curriculum__c )!=null)
                            //objSR.GradeLookup__c = GEMS_utility.getGradeID(objSchool.id__c,objSR.Academic_Year__c,objSR.curriculum__c ).id;
                            
                            upsert objSR;  
                            
                            String processFlowURL  = Site.getBaseUrl() + '/apex/Gems_SelectSchoolLongForm';
                            processFlowURL += '?';
                            processFlowURL += 'FlowId=' + PageFlowId + '&';
                            processFlowURL += 'Id=' + objSR.Id + '&';
                            processFlowURL += 'PageId=' + strPageId + '&';
                            processFlowURL += 'BSU=' + BSUID;
 
                            objSR.Process_Flow__c = processFlowURL;
                            update objSR;
                            
                            Lead obj = new lead();
                            if(string.isBlank(leadId)){
                                obj = upsertLeadForLongForm(objSR, null);
                                
                                obj  = gems_utility.getLeadDetails(obj.id);
                                objSR.lead__c = obj.id;
                                objSR.enquiry__c = obj.enquiry__c!=null?obj.enquiry__c:null;
                                update objSR;  
                            }
                            else{
                                obj  = gems_utility.getLeadDetails(leadId);
                                obj = upsertLeadForLongForm(objSR, obj);
                            }
                        }
                    }
                        
                    if(pageName == 'Other Details'){
                        if(string.isNotBlank(objSR.School_Name__c) && objSR.School_Name__c== 'Other' && string.isBlank(objSR.Other_Previous_School__c)){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'If you choose other, please specify the school name.' + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                            return null;    
                        }
                        else{
                            update objSR;   
                        }   
                    }
                    apexpages.currentPage().getParameters().put('Id',string.valueOf(objSR.Id));
                    apexpages.currentPage().getParameters().put('BSU',BSUID);
                }
                else{
                    upsert objSR;
                    apexpages.currentPage().getParameters().put('Id',string.valueOf(objSR.Id));
                    apexpages.currentPage().getParameters().put('BSU',BSUID);
                }
                PreparePageBlockUtil.FlowId = mapParameters.get('FlowId'); 
                PreparePageBlockUtil.PageId = mapParameters.get('PageId');
                PreparePageBlockUtil.objSR = objSR;
                PreparePageBlockUtil.ActionId = stringActionId;
                PreparePageBlockUtil objPB = new PreparePageBlockUtil();
                pagereference pg;
                pg = objPB.getButtonAction();
                if(pg!=null){
	                pg.getParameters().put('BSU',BSUID);
	                pg.setRedirect(true);
	                return pg;
                }
            }
        }catch(Exception e){
            system.debug('-------'+e.getMessage()+'---'+e.getLineNumber());    
        }
        return null;
    }
    
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getdmlMessage(0) + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage() + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
                return null;
            }
        }
         return null;
    }
    
    public Component.Apex.PageBlock getDyncPgMainPBBottom() { //to display the buttons which are configured
        
        PreparePageBlockUtil.FlowId = mapParameters.get('FlowId');
        PreparePageBlockUtil.PageId = mapParameters.get('PageId');
        PreparePageBlockUtil.objSR = objSR;
        PreparePageBlockUtil objPB = new PreparePageBlockUtil();
        return objPB.getBottomButtonsPB();
    }
    
    

    /**
        logic starts for captcha
     */
    public string verify() {
        return GEMS_Utility.VerifyCurrentPageCaptcha();
    }

    
    public void selectTypeMethod(){
        if(pageName == 'Declaration' && objSR.The_application_is_filled_by__c=='Parent'){
            objSR.Agent_Name__c = '';
            objSR.Agent_Mobile__c = ''; 
        }
    }
    
    public void getAcademicYearsForSchool() {
        try {
            if(academicYearList!=null && academicYearList.size()>0){
                academicYearList = new List<SelectOption>();
            }
            
            academicYearList = GEMS_Utility.getAcademicYearsForSchool(BSUID, NULL);
            if(string.isBlank(objSR.id)){
                objSR.Academic_year__c = (academicYearList.size() > 0) ? academicYearList[0].getValue() : NULL;
            }
            
            getCurriculumsForSchool();
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()+'----'+e.getLineNumber()));   
        }
    }

    public void getGradesforSchool() {
        try {
            if(gradeList!=null && gradeList.size()>0){
                gradeList = new List<SelectOption>();
            }
            
            if (objSR.Academic_year__c != NULL) {
                gradeList = GEMS_Utility.getGradesForSchool(BSUID, getLookupValue(objSR.Academic_year__c,academicYearList), NULL);
                if(string.isBlank(objSR.id)){
                    objSR.GradeLookup__c = (gradeList.size()>0)  ? gradeList[0].getValue() :NULL ;
                }
            }
            getStreamsForSchool();
        } catch (Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()+'----'+e.getLineNumber()));   
        }
    }

    public void getCurriculumsForSchool() {
        try {
            
            if(curriculumList!=null && curriculumList.size()>0){
                curriculumList = new List<SelectOption>();
            }
            if (objSR.Academic_year__c != NULL ) {
                Academic_year__c ay = [Select Year__c from Academic_year__c where Id = :objSR.Academic_year__c AND Year__c != NULL and active__c=true];
                curriculumList = GEMS_Utility.getCurriculumsForSchool(BSUID, ay.Year__c);
            }
            if(string.isBlank(objSR.id)){
                objSR.curriculum__c = (curriculumList.size() > 0) ? curriculumList[0].getValue() : NULL;
            }
            if(curriculumList!=null && curriculumList.size() > 1){
                showCurriculum=true;    
            }else{
                showCurriculum=false;
            }
            getGradesforSchool();
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()+'----'+e.getLineNumber()));   
        }
    }
    
    public void getStreamsForSchool() {
        try {
            showStream = false;
            if(StreamList!=null && StreamList.size()>0){
                StreamList = new List<SelectOption>();
            }
            objSR.Stream__c = '1';
            if (objSR.GradeLookup__c != null && objSR.Academic_year__c != null) {
                StreamList = GEMS_Utility.getStreamsForSchool(BSUID, getLookupValue(objSR.Academic_year__c,academicYearList), getLookupValue(objSR.GradeLookup__c,gradeList));
                if(string.isBlank(objSR.id)){
                    objSR.Stream__c = (streamList.size() > 0) ? streamList[0].getValue() : NULL; 
                }
            }
            
            if(streamList!=null && streamList.size() > 1){
                showStream=true;    
            }
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()+'----'+e.getLineNumber()));   
        }
    }
    
    /*
        Method Name :   upsertLeadForLongForm
        Description :   lead is inserted once applicant info is provided on long form
    */
    public lead upsertLeadForLongForm(HexaBPM__Service_Request__c objSR, lead objLead){
        Lead obj = new lead();
        if(objLead!=null && string.isNotBlank(objSR.Lead__c)){
            obj =   objLead;
        }
        try{
            obj.Academic_Year__c = (objSR.Academic_Year__c!=null)? objSR.Academic_Year__c : null;
            obj.LeadSource = 'Non-Digital';
            obj.Curriculum__c = (objSR.Curriculum__c!=null && objSR.Curriculum__c!='')? objSR.Curriculum__c : '';
            obj.Date_of_Birth__c = (objSR.Date_of_Birth__c!=null )? objSR.Date_of_Birth__c : null;
            obj.First_Language__c = (objSR.First_Language__c!=null && objSR.First_Language__c!='')? objSR.First_Language__c : '';
            obj.Gender__c = (objSR.Gender__c!=null && objSR.Gender__c!='')? objSR.Gender__c : '';
            obj.GradeLookup__c = (objSR.GradeLookup__c!=null )? objSR.GradeLookup__c : null;
            obj.Nationality__c = (objSR.Nationality__c!=null && objSR.Nationality__c!='')? objSR.Nationality__c : '';
            obj.SchoolLookup__c = (objSR.School__c!=null)? objSR.School__c : null;
            obj.School_Starting_Date__c = (objSR.Tentative_Joining_Date__c!=null )? objSR.Tentative_Joining_Date__c : null;
            obj.Firstname = (objSR.First_name__c!=null && objSR.First_name__c!='')? objSR.First_name__c : '';
            obj.Lastname = (objSR.Last_name__c!=null && objSR.Last_name__c!='')? objSR.Last_name__c : '';
            obj.School_Starting_Date__c = (objSR.Tentative_Joining_Date__c!=null )? objSR.Tentative_Joining_Date__c : null;
            obj.Religion__c = (objSR.Religion__c!=null && objSR.Religion__c!='')? objSR.Religion__c : '';
            obj.has_sibling_in_GEMS__c = objSR.Siblings_studying_in_a_GEMS_school__c;
            obj.Status = 'Registration in Progress';
            obj.Lead_No__c = 1;
            if(objSR.Siblings_studying_in_a_GEMS_school__c==true){
                obj.Sibling_Date_of_Birth__c = (objSR.Sibling_Date_of_Birth__c!=null )? objSR.Sibling_Date_of_Birth__c : null;
                obj.Sibling_Fee_ID__c = (objSR.Sibling_Fee_ID__c!=null && objSR.Sibling_Fee_ID__c!='')? objSR.Sibling_Fee_ID__c : '';
                obj.Sibling_name__c = (objSR.Sibling_name__c!=null && objSR.Sibling_name__c!='')? objSR.Sibling_name__c : '';
                obj.Sibling_School__c = (objSR.Sibling_GEMS_School__c!=null )? GEMS_Utility.getSchool(objSR.Sibling_GEMS_School__c).id : null;  
            }
            else{
                obj.Sibling_Date_of_Birth__c = null;
                obj.Sibling_Fee_ID__c = '';
                obj.Sibling_name__c = '';
                obj.Sibling_School__c =null;
            }
            obj.MobilePhone = objSR.Emergency_Contact_Number__c;
            obj.Email = objSR.HexaBPM__Email__c;
            obj.hasSR__c = true;
            upsert obj;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT));
        }
        
        return obj;
    }
    
    
    /*
        Method Name :   applicantDetailValidations
        Description :   validations related to applicant info page are performed in this method
    */
    public string applicantDetailValidations(HexaBPM__Service_Request__c objSR){
        
        if(objSR.passport_expiry_date__c!=null && objSR.passport_expiry_date__c<=system.today()){
            return 'Passport Expiry Date should be of future.';
        }
        
        if(objSR.visa_expiry_date__c!= null && objSR.visa_expiry_date__c<=system.today()){
            return 'Visa Expiry Date should be of future.';
        }
        
        if(objSR.Emirates_ID_Expiry_Date__c!= null && objSR.Emirates_ID_Expiry_Date__c<=system.today()){
            return 'Emirates ID Expiry Date should be of future.';
        }
        
        if(objSR.passport_expiry_date__c!=null && objSR.passport_expiry_date__c>=system.today()){
            if(objSR.passport_expiry_date__c < system.today().addDays(30)){
                return 'Passport Expiry Date should be valid for more then 30 days.';   
            }
        }
        
        if(objSR.visa_expiry_date__c!=null && objSR.visa_expiry_date__c>=system.today()){
            if(objSR.visa_expiry_date__c < system.today().addDays(30)){
                return 'Visa Expiry Date should be valid for more then 30 days.';   
            }
        }
        
        if(objSR.Emirates_ID_Expiry_Date__c!=null && objSR.Emirates_ID_Expiry_Date__c>=system.today()){
            if(objSR.Emirates_ID_Expiry_Date__c < system.today().addDays(30)){
                return 'Emirates ID Expiry Date should be valid for more then 30 days.';    
            }
        }
        
        
        if(objSR.date_of_birth__c!=null && objSR.date_of_birth__c>=system.today()){
            return 'Date Of Birth cannot be in future.';
        }
        
        if(objSR.visa_issue_date__c!= null && objSR.visa_issue_date__c>=system.today()){
            return 'Visa Issue Date cannot be in future.';
        }
        
        if(objSR.passport_issue_date__c!= null && objSR.passport_issue_date__c>=system.today()){
            return 'Passport Issue Date cannot be in future.';
        }
        
        if(objSR.Siblings_studying_in_a_GEMS_school__c == true && objSR.Sibling_Date_of_Birth__c!=null && objSR.Sibling_Date_of_Birth__c>=system.today()){
            return 'Sibling Date of Birth cannot be in future.';
        }   
        
        list<lead> tempLeadList = [select id from Lead where curriculum__c =: objSR.Curriculum__c and 
                                   GradeLookup__c =: objSR.GradeLookup__c and 
                                   Academic_Year__c =: objSR.Academic_Year__c and 
                                   SchoolLookup__c =: objSR.school__c and 
                                   FirstName =: objSR.First_Name__c and 
                                   lastName =: objSR.Last_Name__c and 
                                   Date_of_Birth__c =: objSR.date_of_birth__c and id!=:leadId];
       
        if(tempLeadList!=null && tempLeadList.size()>0){
            return 'Student already exist with same details';    
        }
        
         //Age cutoff validation
        boolean recordfound=false; 
        
        boolean hasValidAge = GEMS_Validations.CheckAgeCutOff(ObjSR.Date_Of_Birth__c,getLookupValue(ObjSR.GradeLookup__c,gradeList),ObjSR.School__c,ObjSR.Academic_Year__c); 
        if(hasValidAge==false){
                string Message = '';
                string grade = getLookupValue(ObjSR.GradeLookup__c,gradeList);
                for(Grade__c CutOff:[select Id,Academic_Year__c,Age_Cut_Off_Date__c,Maximum_Age__c,Minimum_Age__c from Grade__c where Academic_Year__c=:ObjSR.Academic_Year__c and Grade_Display__c=:grade and School__c=:ObjSR.School__c and Age_Cut_Off_Date__c!=null AND Maximum_Age__c!=NULL AND Minimum_Age__c!= NULL limit 1]){
                    recordfound = true;
                    Message = 'Age not valid.Applicants age should be between '+CutOff.Minimum_Age__c+' and '+CutOff.Maximum_Age__c+' as on '+formatDate(CutOff.Age_Cut_Off_Date__c);
                }
                for(Grade__c CutOff:[select Id,Academic_Year__c,Age_Cut_Off_Date__c,Maximum_Age__c,Minimum_Age__c from Grade__c where Academic_Year__c=:ObjSR.Academic_Year__c and Grade_Display__c=:grade and School__c=:ObjSR.School__c and Age_Cut_Off_Date__c!=null AND Maximum_Age__c!=NULL AND Minimum_Age__c= NULL limit 1]){
                    recordfound = true;
                    Message = 'Age not valid.Applicants age should be less than '+CutOff.Maximum_Age__c+' as on '+formatDate(CutOff.Age_Cut_Off_Date__c);
                }
                for(Grade__c CutOff:[select Id,Academic_Year__c,Age_Cut_Off_Date__c,Maximum_Age__c,Minimum_Age__c from Grade__c where Academic_Year__c=:ObjSR.Academic_Year__c and Grade_Display__c=:grade and School__c=:ObjSR.School__c and Age_Cut_Off_Date__c!=null AND Maximum_Age__c=NULL AND Minimum_Age__c!= NULL limit 1]){
                    recordfound = true;
                    Message = 'Age not valid.Applicants age should be more than '+CutOff.Minimum_Age__c+' as on '+formatDate(CutOff.Age_Cut_Off_Date__c);
                }                   
                if(recordfound==true){
                    Message = Message;  
                    return Message;
                }else
                
               return 'Success';
           }               
        
        return 'Success';
    }
    
    public static String formatDate(Date d) {
        return  d.day()+ '-' + d.month() + '-' +  d.year();
    }
   
    public String getLookupValue(string key, list<selectOption> gradeList){
        String retStr;
        for(SelectOption  so :  gradeList){
            if(so.getValue().equalsIgnoreCase(key)){
                retStr = so.getLabel();
            }
        }
        return retStr;
    }
    
}