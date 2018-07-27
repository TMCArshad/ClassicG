/**************************************************************************************************
* Name               : GEMS_EnquiryDetailsCntlr                                                               *
* Description        : Implements all the logic for GEMS Short Form enquiry page                                       *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017
* 
* Modification History
    Version  |  Author     |   Date       | Description
    V1.1     |  Umair Khan |  29-Nov-2017 | Map Other school field on Lead object
    V1.2     |  Umair Khan |  19-Dec-2017 | Replace 'Non-Digital' with 'Short Form' only when value is assigning.
    V1.3     |  Kim Noceda |  14-Feb-2018 | Added a method to check if the parameters from exsiting student is valid
                                            Search for the existing Student and populate the values in the page
	V1.4	 |	Swati	   |  21-Mar-2018 | Ticket: 192263
**************************************************************************************************/
public without sharing class GEMS_EnquiryDetailsCntlr {

    public Lead primaryContactLead { get; set; }
    public Lead leadObj { get; set; }
    public School__c school { get; set; }
    
    public list<Lead> lead_List { get; set; }

    public boolean leadEditFlag { get; set; }
    public boolean hasSibling { get; set; } 
    public boolean validationError {get; set;}
    public boolean showErrorMsg { get; set; }
    public boolean isValidCaptcha {get; set;}
    public boolean transfer {get;set;}
    
    public String transferValue {get;set;}
    public string invalidCaptchaErrorMsg { get; set; }
    public string isPardotURL{get;set;}
    public string pardotLeadId{get;set;}
    public string BSUID { get; set; }
    public string leadReferenceNumber { get; set; }
    public string validateStr { get; set; }
    public string ErrorMsg { get; set; }
    public string hasChanged { get; set; }
    
    public Lead objLeadDate {get;set;}
    
    //Transfer Student Fields
    public String existSchoolName{get;set;}
    public String existStudentId{get;set;}
    public String existDOB{get;set;}
    public String studentIdOld{get;set;}
    public String oldStudentId{get;set;}
    public Boolean hasExistStudent{get;set;}
    public Boolean displayExistingStudentError{get;set;}
    
    // Analytics UTM Fields
    public string Google_Analytics_Campaign {get; set;}
    public string Google_Analytics_Client_Id {get; set;}
    public string Google_Analytics_Content {get; set;}
    public string Google_Analytics_gclid {get; set;}
    public string Google_Analytics_Medium {get; set;}
    public string Google_Analytics_Source {get; set;}
    public string Google_Analytics_Term {get; set;}
    
    public GEMS_EnquiryDetailsCntlr_Helper.siblingInfoWrapper siblingInfo { get; set; }

    public list<SelectOption> academicYearList { get; set; }
    public list<SelectOption> gradeList { get; set; }
    public list<SelectOption> curriculumList { get; set; }
    public list<Selectoption> streamList { get; set; }
    public list<Selectoption> genderList { get; set; }
    public list<SelectOption> siblingSchools { get; set; } //GEMS Schools
    public list<SelectOption> currentSchools { get; set; } //GEMS + Other Schools
    public list<SelectOption> gemsSchools { get; set; } //GEMS Schools
    public list<SelectOption> transferExist { get; set; }
    
    public list<map<string,string>>fieldsValidationErrors {get; set;}

    private static final string INVALID_CAPTCHA_ERROR = 'Please fill in the captcha.';
    
    map<string, GEMS_Site_Domain_Config__c> siteConfig {get;set;}

    public GEMS_EnquiryDetailsCntlr() {
        GEMS_Utility.isOnline = true;
        leadEditFlag = true ;
        isValidCaptcha = false;
        
        invalidCaptchaErrorMsg = null;
        pardotLeadId =  NULL;
        hasChanged = 'false';
        leadReferenceNumber = '';
        isPardotURL = '';
        
        objLeadDate = new Lead();
        leadObj = new Lead();
        primaryContactLead = new Lead();
        lead_List = new List<Lead>();
        siblingInfo = new GEMS_EnquiryDetailsCntlr_Helper.siblingInfoWrapper();

        academicYearList = new List<SelectOption>();
        gradeList = new List<SelectOption>();
        curriculumList = new List<SelectOption>();
        streamList = new List<SelectOption>();
        genderList = new List<SelectOption>();
        siblingSchools = new List<SelectOption>();
        currentSchools = new List<SelectOption>();
        gemsSchools = new List<SelectOption>();
        transferExist = new List<SelectOption>();
        
        siteConfig =  GEMS_Site_Domain_Config__c.getAll();

        leadReferenceNumber = ApexPages.CurrentPage().getParameters().get('RefId');
        BSUID = ApexPages.CurrentPage().getParameters().get('BSU');
        isPardotURL = ApexPages.CurrentPage().getParameters().get('isPardotURL');
        
        hasExistStudent = false;
        displayExistingStudentError = false;
        
        if(string.isNotBlank(leadReferenceNumber)){
            init();    
        }
        
        if(string.isNotBlank(BSUID) && BSUID.length()==6 && BSUID.isNumeric()) {
            try {
                school = GEMS_Utility.getSchool(BSUID);
                currentSchools = GEMS_Utility.getAllCurrentSchools();
                siblingSchools = GEMS_Utility.getAllGemsSchools();
                transferExist.add(new SelectOption('', '--None--'));
                transferExist.add(new SelectOption('Yes', 'Yes'));
                transferExist.add(new SelectOption('No', 'No'));
                setLeadDetails();
            } catch (Exception e) {
                ErrorMsg = 'Something went wrong. Please contact your system administrator.';
                ErrorMsg += e.getMessage();
                showErrorMsg = true;
            }
        }
    }
    
    public void init(){
        getAllLeadsWithLeadRef(leadReferenceNumber);
        if(Lead_List!=null && Lead_List.size()>0){
            getparentDetails();
            //ifthe short form is landed using pardot email prepopulate data on lead and parent section 
            if(string.isNotBlank(isPardotURL) && isPardotURL.equals('Yes'))
              preparePageFromPardotURL();
        }  
    }
    
    /**
     * [preparePageFromPardotURL -Prepare the page to display pre popultaed values captured form pardot form]
     */
    public void preparePageFromPardotURL(){
        invalidCaptchaErrorMsg = 'Success';
        isValidCaptcha  =true;
        pardotLeadId = Lead_List[0].Id;
        
        if(string.isNotBlank(Lead_List[0].Existing_Student_Id__c)){
        	transferValue = 'Yes';	
        	objLeadDate.Date_of_Birth__c = Lead_List[0].Date_of_Birth__c;
        	oldStudentId = Lead_List[0].Existing_Student_Id__c;
        }else{
        	transferValue = 'No';	
        }
        leadObj.firstName = Lead_List[0].FirstName;
        leadObj.LastName = Lead_List[0].LastName;
        leadObj.academic_year__c = Lead_List[0].academic_year__c;
        leadObj.gradelookup__c = Lead_List[0].gradelookup__c;
        leadObj.stream__c = Lead_List[0].stream__c;
        
        if(Lead_List[0].curriculum__c!=null)
            leadObj.curriculum__c = Lead_List[0].curriculum__c;
        else
            leadObj.curriculum__c = Lead_List[0].Curriculum_from_AY__c;
        
        leadObj.gender__c = Lead_List[0].gender__c;
        leadObj.Date_Of_birth__c = Lead_List[0].Date_Of_birth__c;
        leadObj.Google_Analytics_Campaign__c = Lead_List[0].Google_Analytics_Campaign__c;
        leadObj.Google_Analytics_Client_Id__c = Lead_List[0].Google_Analytics_Client_Id__c;
        leadObj.Google_Analytics_Content__c = Lead_List[0].Google_Analytics_Content__c;
        leadObj.Google_Analytics_gclid__c = Lead_List[0].Google_Analytics_gclid__c;
        leadObj.Google_Analytics_Medium__c = Lead_List[0].Google_Analytics_Medium__c;
        leadObj.Google_Analytics_Source__c = Lead_List[0].Google_Analytics_Source__c;
        leadObj.Google_Analytics_Term__c = Lead_List[0].Google_Analytics_Term__c;
        Lead_List.clear();  
        lead_List = new List<Lead>();       
    }
    
    /**
     * [setLeadDetails Build all the picklist values on short form]
     */
    public void setLeadDetails(){
        getGendersForSchool();
        getAcademicYearsForSchool();
    }
    
    /**
     * @return [Save Lead record] Performs all valiadations before saving lead record
     */
    public PageReference saveLead() {
        boolean isNewLead = false;
        validationError = false;
                
        leadObj.SchoolLookup__c = School.Id;
        fieldsValidationErrors = new List<Map<string,string>>();
        Savepoint sp;
        if(pardotLeadId!=null)
            isNewLead = true;
        
        try {
            if( !isValidCaptcha  && GEMS_Utility.VerifyCurrentPageCaptcha() != 'success'){
                isValidCaptcha = false;
                validationError = true;
                invalidCaptchaErrorMsg = INVALID_CAPTCHA_ERROR;
                Map<string,string>error = new Map<string, string>();
                error.put('field', '[id$="GEMS_EnquiryDetails_Form:gCaptcha"]');
                error.put('error', validateStr);
                fieldsValidationErrors.add(error);

                GEMS_Utility.addPageError(invalidCaptchaErrorMsg);
            }else {
                isValidCaptcha = true;
                invalidCaptchaErrorMsg = null;
            }
          
            //Age cutoff validation
            validateStr = GEMS_Validations.validateAgeCutOff(leadObj, getLookupValue(leadObj.GradeLookup__c,gradeList));
            if(validateStr != 'Success') {
                validationError = true;
                Map<string,string>error = new Map<string, string>();
                error.put('field', '[id$="GEMS_EnquiryDetails_Form:dateOfBirth"]');
                error.put('error', validateStr);
                fieldsValidationErrors.add(error);
                GEMS_Utility.addPageError(validateStr);
            }
            
            if(leadObj.Previous_School__c == 'Other' && string.isBlank(leadObj.Other_Previous_School__c)){
            	validationError = true;
            	Map<string,string>error = new Map<string, string>();
                error.put('field', '[id$="GEMS_EnquiryDetails_Form:otherCurrentSchool"]');
                error.put('error', 'Please specify name if selected Other.');
                fieldsValidationErrors.add(error);
                GEMS_Utility.addPageError('Please specify name if selected Other.');
            }

            // Show Form validation erros altogether
            if(validationError){
                return NULL;
            }
            sp = Database.setSavepoint();

            // copy utm fields on each new lead.
            copyUTMFieldsToLead(leadObj);

            setParentDetails();
            setSiblingDetails();
            leadObj.Sys_previous_school_is_GEMS__c = GEMS_Utility.checkIfPreviousSchoolIsGEMS(leadObj.Previous_School__c);
            //V1.1
            leadObj.Other_Previous_School__c = leadObj.Other_Previous_School__c;
            //End
            
            //V1.4
            if(string.isNotBlank(leadObj.Previous_School__c)){
            	leadObj.Previous_School__c = getLookupValue(leadObj.Previous_School__c,siblingSchools);	
            }
            
            leadObj.Lead_No__c = lead_List.Size() + 1;
            leadReferenceNumber = string.isEmpty(leadReferenceNumber) ? GEMS_Utility.generateLeadRefNumber() : leadReferenceNumber;
            leadObj.Lead_Reference__c = leadReferenceNumber;
            leadObj.Pardot_EnrollNow_URL__c = getPardotEnrollNowUrl(siteConfig.get(school.Short_Name__c));
            
            string AYLabel = getLookupValue(leadObj.Academic_Year__c,academicYearList);
            Academic_year__c ay = new Academic_year__c ();
            ay = GEMS_Utility.getAcademicYearID(School.id,AYLabel,leadObj.Curriculum__c);
            
            string gradeLabel = getLookupValue(leadObj.GradeLookup__c,gradeList);
            grade__c grade = new grade__c ();
            if(ay!=null){
                grade = GEMS_Utility.getgradeID(School.id,ay.id ,leadObj.Stream__c, gradeLabel);
            }else{
                GEMS_Utility.addPageError('Academic year is not open for enrolment.');
                return NULL;
            }   
            if(ay!=null)
                leadObj.Academic_Year__c = ay.id;
            
            if(grade!=null){
                leadObj.GradeLookup__c = grade.id;
            }else{
                GEMS_Utility.addPageError('Grade is not open for enrolment.');
                return NULL;
            }
            
            Lead ObjLeadTemp = new Lead();
            ObjLeadTemp = leadObj;
            ObjLeadTemp.Id = pardotLeadId;
            
            upsert ObjLeadTemp;

            //Build Sibling Enquiry relationships
            GEMS_EnquiryDetailsCntlr_Helper.createSiblingEnquiryRelationships(Lead_List, leadObj);
            leadObj = new Lead(); 
            isPardotURL = 'No';
            pardotLeadId =  NULL;
            init();
            setLeadDetails();
            transferValue = '';
            oldStudentId = '';
            objLeadDate = new lead();
        } catch (Exception e) {
            validationError =true;
            GEMS_Utility.logException(e);
            string message = (e.getTypeName().equals('System.DmlException')) ? e.getDMLMessage(0)  : e.getMessage() ;
           
            GEMS_Utility.addPageError(message);
            Database.rollback(sp);
            if(isNewLead)
                leadObj.Id = null;
            return NULL;
        }
        return NULL;
    }

    /**
     * [getPardotEnrollNowUrl - Generate PardotEnrollNow URL]
     * @param  domainConfig [Site Domain Config]
     * @return              [pardotEnrollNowURL string]
     */
    public  string getPardotEnrollNowUrl(GEMS_Site_Domain_Config__c domainConfig){
        string baseUrl = (domainConfig != NULL ) ? domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c   + '?' : NULL;
        string param = '/apex/' + GEMS_Constants.ENQUIRYDETAILS_PAGE;
        param += '?BSU=';
        param += domainConfig.School_Code__c;
        param += '&RefId=';
        param += leadReferenceNumber;
        string finalUrl = baseUrl + EncodingUtil.base64Encode(Blob.valueOf(param));
        return finalUrl;
    }

    /**
     * [getparentDetails Populate parent details section from lead record]
     */
    public void getparentDetails() {
        if(lead_List!=null && lead_List.size()>0) {
            primaryContactLead.Parent_Title__c = lead_List[0].Parent_Title__c;
            primaryContactLead.Parent_First_Name__c = lead_List[0].Parent_First_Name__c;
            primaryContactLead.Parent_Last_Name__c = lead_List[0].Parent_Last_Name__c;
            primaryContactLead.Relation_to_student__c = lead_List[0].Relation_to_student__c;
            primaryContactLead.Email = lead_List[0].Email;
            primaryContactLead.Parent_Company__c = lead_List[0].Parent_Company__c;
            primaryContactLead.mobilePhone = lead_List[0].mobilePhone;
            primaryContactLead.Parent_nationality__c = lead_List[0].Parent_nationality__c;
            primaryContactLead.Country__c = lead_List[0].Country__c;
            primaryContactLead.State__c = lead_List[0].State__c;
            primaryContactLead.Area__c = lead_List[0].Area__c;
            primaryContactLead.Parent_Other_Company__c = lead_List[0].Parent_Other_Company__c;
            primaryContactLead.Parent_Other_State__c = lead_List[0].Parent_Other_State__c;
            primaryContactLead.Parent_Other_Area__c = lead_List[0].Parent_Other_Area__c;
        }

    }
    
    /**
     * [setParentDetails -Sets parennt details on lead record from primaryContactLead ]
     * @return [void]
     */
    public void setParentDetails() {
        leadObj = GEMS_EnquiryDetailsCntlr_Helper.setParentDetails(leadObj, primaryContactLead);
    }
    
    /**
     * [setSiblingDetails -Set sibling details on lead Record]
     */
    public void setSiblingDetails() {
        leadObj.SchoolLookup__c = (school != NULL) ? school.Id : NULL;
        //V1.1
        leadObj.leadSource = string.isBlank(leadObj.leadSource) ? 'Short Form' : leadObj.leadSource;
        leadObj.has_sibling_in_GEMS__c = hasSibling;
        leadObj.Sibling_name__c = (hasSibling) ? SiblingInfo.siblingName : NULL;
        leadObj.Sibling_Fee_ID__c = (hasSibling) ? SiblingInfo.siblingFeeID : NULL;
        leadObj.Sibling_Date_of_Birth__c = (hasSibling) ? primaryContactLead.Sibling_Date_of_Birth__c : NULL;
        leadObj.Sibling_School__c = (hasSibling) ? SiblingInfo.siblingSchool : NULL;
    }
    
    /**
     * [proceedToPay - creates new lead ifedit mode = true
     *               - Updates all leads with parent info,sibling info
     *               - Creates SRs for all Leads 
     *               - Navigates to payment page ]
     * @return [PageReference to payment page]
     */
    public PageReference proceedToPay() {
        Savepoint sp;
        try {
            if(leadEditFlag){
                ApexPages.getMessages().clear();
                saveLead();
                if(!ApexPages.getMessages().isEmpty()){
                    return NULL;
                }
            }
            if(lead_List.isEmpty() && ApexPages.getMessages().isEmpty()){
                GEMS_Utility.addPageError('Please add at least one child.');
                invalidCaptchaErrorMsg = 'Please fill in the captcha.';
                showErrorMsg = true;
                return null;
            }
            sp = Database.setSavepoint();
            system.debug('---Lead_List1---'+Lead_List);
            system.debug('---siblingInfo---'+siblingInfo);
            system.debug('---primaryContactLead---'+primaryContactLead);
            system.debug('---hasSibling---'+hasSibling);
            
            Lead_List = GEMS_EnquiryDetailsCntlr_Helper.updateLeadDeatilsBeforePay(Lead_List, siblingInfo, primaryContactLead, hasSibling);
            system.debug('---Lead_List---'+Lead_List);
            update Lead_List;
            
            //Create SR records for all the new leads
            //No SR is created ifthere is any open SR  q enrollmemt for the same lead
            GEMS_EnquiryDetailsCntlr_Helper.createSRforLeads(Lead_List, GEMS_Constants.SRRT_ENROLLMENT);
            
            PageReference PaymentPage = GEMS_Utility.getPgReference(GEMS_Constants.PAYMENT_PAGE);
            PaymentPage.getParameters().put('RefId', leadReferenceNumber); // Add RefId as param when navigating to the payment page
            PaymentPage.getParameters().put('BSU', school.ID__c);
            return PaymentPage;
        } catch (Exception e) {
            validationError =true;
            GEMS_Utility.logException(e);
            string message = (e.getTypeName().equals('System.DmlException')) ? e.getDMLMessage(0)  : e.getMessage() ;
            GEMS_Utility.addPageError(message +GEMS_Utility.SCROLL_TOP_ON_ERROR_SCRIPT );
            Database.rollback(sp);
        }
        return NULL;
    }
    
    /**
     * [addLead -Enables lead edit flag]
     */
    public void addLead() {
        leadEditFlag = true;
    }
    
   /**
    * [resetSiblingDetails - Resets all sibling detials entered ]
    */
   public void resetSiblingDetails(){
    siblingInfo = new GEMS_EnquiryDetailsCntlr_Helper.siblingInfoWrapper ();
   }

    public void cancelLead() {
        leadEditFlag = false;
    }
    
   /**
    * [getAllLeadsWithLeadRef - Prepares Lead_List for all leads with same leadReferenceNumber]
    * @param leadRef [description]
    */
    public void getAllLeadsWithLeadRef(string leadRef) {
        Lead_List = GEMS_Utility.getALlLeadsWithLeadRef(leadRef);
    }
    
  /**
   * [getAcademicYearsForSchool -Prepares Academic Year picklist for the school]
   */
    public void getAcademicYearsForSchool() {
        GEMS_Utility.isOnline = true;
        try {
            academicYearList = new List<SelectOption>();
            academicYearList = GEMS_Utility.getAcademicYearsForSchool(BSUID,NULL);
            if(haschanged=='true' || isPardotURL == null || LeadObj.Academic_year__c==null)
                LeadObj.Academic_year__c = (academicYearList.size() > 0) ? academicYearList[0].getValue() : NULL;
            
            getCurriculumsForSchool();
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
  /**
   * [getGradesforSchool -Prepares Grades for selected Academic year and Curricullum]
   */
    public void getGradesforSchool() {
        GEMS_Utility.isOnline = true;
        try {
            gradeList = new List<SelectOption>();
            if(leadObj.Academic_year__c != NULL && leadObj.Curriculum__c != NULL) {
                gradeList = GEMS_Utility.getGradesForSchool(BSUID, getLookupValue(leadObj.Academic_year__c,academicYearList),leadObj.Curriculum__c);
                if(haschanged=='true' || isPardotURL == null)
                    leadObj.GradeLookup__c = (gradeList.size()>0)  ? gradeList[0].getValue() :NULL ;
                
                getStreamsForSchool();
            }
            
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getCurriculumsForSchool -Prepares Curricullum picklist for selected Academic year]
    */
    public void getCurriculumsForSchool() {
        GEMS_Utility.isOnline = true;
        try {
            curriculumList = new List<SelectOption>();
            if(leadObj.Academic_year__c != NULL ) {
                Academic_year__c ay = [Select Year__c from Academic_year__c where Id = :leadObj.Academic_year__c AND Year__c != NULL];
                curriculumList = GEMS_Utility.getCurriculumsForSchool(BSUID, ay.Year__c);
                if(haschanged=='true' || isPardotURL == null || LeadObj.Curriculum__c==null){
                    LeadObj.Curriculum__c = (curriculumList.size() > 0) ? curriculumList[0].getValue() : NULL; 
                }
                getGradesForSchool();
            }
            
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }

    }
    
    /**
     * [getStreamsForSchool -Prepares Stream picklist for the selected Academic year and Grade]
     */
    public void getStreamsForSchool() {
        GEMS_Utility.isOnline = true;
        try {
            streamList = new List<SelectOption>();
            if(leadObj.GradeLookup__c != null && leadObj.Academic_year__c != null) {
                
                string AYLabel = getLookupValue(leadObj.Academic_Year__c,academicYearList);
                Academic_year__c ay = new Academic_year__c ();
                ay = GEMS_Utility.getAcademicYearID(School.id,AYLabel,leadObj.Curriculum__c);
                if(ay!=null)
                    StreamList = GEMS_Utility.getStreamsForSchool(BSUID, ay.id, getLookupValue(leadObj.GradeLookup__c,gradeList));
                
                if(haschanged=='true' || isPardotURL == null || LeadObj.Stream__c==null)
                    LeadObj.Stream__c = (streamList.size() > 0) ? streamList[0].getValue() : NULL; 
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
        * [getGendersForSchool -prepares gender picklist for the school]
    */
    public void getGendersForSchool() {
        try {
            genderList = (school != NULL) ? GEMS_Utility.getGendersForSchool(school) : genderList;
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
  /**
   * [getLookupValue Returns label for the selected picklist ]
   * @param  key                      [Selected picklist value]
   * @param  List<SelectOption>soList [List of select Option]
   * @return                          [Label value of selected picklist]
   */
    public string getLookupValue(string key, List<SelectOption>soList) {
        string retStr;
        for (SelectOption so : soList) {
            if(so.getValue() == key) {
                retStr = so.getLabel();
            }
        }
        return retStr;
    }
    
    /**
    * [copyUTMFieldsToLead - Copies the analytics UTM data to lead
    * @param childLead - target lead to copy into
    */
    public void copyUTMFieldsToLead(Lead childLead){
        childLead.Google_Analytics_Campaign__c = Google_Analytics_Campaign;
        childLead.Google_Analytics_Client_Id__c = Google_Analytics_Client_Id;
        childLead.Google_Analytics_Content__c = Google_Analytics_Content;
        childLead.Google_Analytics_gclid__c = Google_Analytics_gclid;
        childLead.Google_Analytics_Medium__c = Google_Analytics_Medium;
        childLead.Google_Analytics_Source__c = Google_Analytics_Source;
        childLead.Google_Analytics_Term__c = Google_Analytics_Term;
    }
    
    /**
    * V1.3
    * populateTransferStudentDetails - populate details if the details provided has an existing student
    * 
    */
    public void populateTransferStudentDetails(){
        studentIdOld = '';
        leadObj.Existing_Student_Id__c = '';
        existSchoolName = Apexpages.currentPage().getParameters().get('exSchoolNameParam');
        existStudentId = Apexpages.currentPage().getParameters().get('exStudentNameParam');
        existDOB = Apexpages.currentPage().getParameters().get('exDOBParam');
        
        String[] dateStr ;
        string formattedDate = '';
        if(string.isNotBlank(existDOB)){
        	dateStr = existDOB.split('/');
	        formattedDate = dateStr[2]+'-'+dateStr[1]+'-'+dateStr[0];
        }
        
        displayExistingStudentError = false;
        
        List<Account> existStudent = new List<Account>();
        if(string.isNotBlank(existStudentId) && string.isNotBlank(existSchoolName)){
	        if(existStudentId.length() == 14){
	            existStudent = [SELECT Id, FirstName, LastName, Date_Of_Birth__c, Gender__c, Student_Id__c 
	                            FROM Account 
	                            WHERE Student_Id__c = :existStudentId 
	                            AND school__c = :existSchoolName 
	                            AND Date_Of_Birth_String__c = :formattedDate 
	                            AND Current_Status__c = 'EN' 
	                            LIMIT 1];
	        } else{
	            existStudent = [SELECT Id, FirstName, LastName, Date_Of_Birth__c, Gender__c, Student_Id__c 
	                            FROM Account 
	                            WHERE Fee_ID__c = :existStudentId 
	                            AND school__c = :existSchoolName 
	                            AND Date_Of_Birth_String__c = :formattedDate 
	                            AND Current_Status__c = 'EN' 
	                            LIMIT 1];
	        }
        }
        if(!existStudent.isEmpty()){
            leadObj.FirstName = existStudent[0].FirstName;
            leadObj.LastName = existStudent[0].LastName;
            leadObj.Gender__c = existStudent[0].Gender__c;
            leadObj.Date_of_Birth__c = existStudent[0].Date_Of_Birth__c;
            leadObj.Existing_Student_Id__c = existStudent[0].Student_Id__c;
            hasExistStudent = true;
        } else{
            leadObj.FirstName = null;
            leadObj.LastName = null;
            leadObj.Gender__c = null;
            leadObj.Date_of_Birth__c = null;
            hasExistStudent = false;
            oldStudentId = '';
            leadObj.Previous_School__c = null;
            objLeadDate.Date_of_Birth__c = null;
            displayExistingStudentError = true;
        }
    }
    
    public void clearValues(){
        leadObj = new lead();
        getAcademicYearsForSchool();
        oldStudentId = '';
        leadObj.Previous_School__c = null;
        objLeadDate.Date_of_Birth__c = null;
        hasExistStudent = false;
    }
}