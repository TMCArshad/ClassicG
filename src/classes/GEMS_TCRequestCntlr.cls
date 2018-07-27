/************************************************************************************
* Name               : GEMS_TCRequestCntlr                                                               *
* Description        : Implements logic for TC Request Service Request functionality                                       *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* V1.0        PWC         	16/02/2017
* V1.1 		  Leeba        23/10/2017 exclude cancelled SR from in getopenSR method
* V1.2        Umair        12/Dec/2017  "Name of the school to be transferred to" dropdown value should only "Other" in case of "Moving out of Country" reason or if School Country is Qatar
*         Swati        14/Dec/2017  "Other issue populate"
**************************************************************************************************/
public without sharing class GEMS_TCRequestCntlr {
    public string studentID { get; set; }
    public string BSUID { get; set; }
    public static String errorMessage {get;set;}
    public Account studentAccount { get; set; }
    public string otherSchool { get; set; }
    public String primaryContactName { get; set; }
    public string primaryContactMobileNumber { get; set; }
    public string primaryContactEmail { get; set; }
    public List<SelectOption> schoolList { get; set; }
    public List<SelectOption> otherschoolList { get; set; }
    public HexaBPM__Service_Request__c SR { get; set; }

    public string TCOptionsSelected { get; set; }
    public Employee__c principal { get; set; }

    public Boolean savedRequest {get; set;}

    //Error Message
    public Boolean hidePage {get; set;}

    public GEMS_TCRequestCntlr() {
  
        studentAccount = new Account();
        principal = new Employee__c();
        hidePage = false;
        
        SR = new HexaBPM__Service_Request__c();
        
     
        studentID = GEMS_Utility.getDecryptedURLParam(ApexPages.CurrentPage().getParameters().get('studentID'));
        //studentID = ApexPages.CurrentPage().getParameters().get('studentID');
        BSUID = GEMS_Utility.getDecryptedURLParam(ApexPages.CurrentPage().getParameters().get('BSU'));


    }

//V1.2
public void change(){
      schoolList = new List<SelectOption>();
     
     if(SR.Transfer_Reason__c == 'Moving out of country' || studentAccount.School__r.Country__c == 'Qatar'){
        schoolList.add(new SelectOption('Other','Other'));
     }
    else{
        schoolList = GEMS_Utility.getAllCurrentSchools();
        schoolList.sort();
    }
    
}


    public PageReference init() {
        //If Student ID is decrypted successfully
        if (studentID != NULL && studentID != '') {
            getStudentDetails();
            String URL = validateInit();
            
            //V1.2
            schoolList = new List<SelectOption>();
            
            if(studentAccount.School__r.Country__c == 'Qatar'){
                 schoolList.add(new SelectOption('Other','Other'));
            }
            else{
                schoolList = GEMS_Utility.getAllCurrentSchools();
            }
            
            schoolList.sort();
            //End
            
            if(String.isNotBlank(URL)){
                PageReference successPage = new  PageReference(URL);
                successPage.setRedirect(true);
                return successPage;
            } else { 
                 setPrimaryContactDetails(studentAccount);
                  if (studentAccount.School__c != NULL) {
                    principal = getSchoolPrincipal(studentAccount.School__c);
                }
               
            }
        } else {
            GEMS_Utility.addPageError('Invalid student Id.');
            hidePage = true;
        }
        return NULL;
    }
    public  string validateInit(){
        List<HexaBPM__Service_Request__c> openSrs = new List<HexaBPM__Service_Request__c>();
        openSrs = getOpenSrs(studentID);
        String URL = '';
        if (!openSrs.isEmpty()) {
            URL += '/apex/GEMS_TCSuccessPage?msg=' + 'Thank you for submitting your Transfer Certificate Request, your reference number is ' +openSrs[0].Name; 
           }
        else if( (studentAccount.Current_Status__c != 'EN') ||
                 (studentAccount.Current_Status__c == 'EN' && studentAccount.Leave_Date__c != NULL && studentAccount.Cancel_Date__c == NULL)){
            URL += '/apex/GEMS_TCSuccessPage?msg=' + 'TC Request can not be raised.';
            
        }
        else if(studentAccount.Date_of_Join__c > System.Today()){
            URL += '/apex/GEMS_TCSuccessPage?msg=' + 'TC Request can not be raised. Date Of Joining of the student is in the future.';
        }
        return URL;
       
    }
    public  List<HexaBPM__Service_Request__c> getOpenSrs(String StudentId) {

        List<HexaBPM__Service_Request__c> openSrs = new List<HexaBPM__Service_Request__c>();
        //Open TC
        for (HexaBPM__Service_request__c srObj  : [SELECT id,
                Name,
                HexaBPM__External_Status_Name__c,
                HexaBPM__External_SR_Status__r.HexaBPM__Type__c,
                Student__c,
                Student__r.Current_Status__c,
                HexaBPM__Record_Type_Name__c
                FROM HexaBPM__Service_request__c
                WHERE HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End'
                AND HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'Cancel'
                AND  HexaBPM__Record_Type_Name__c = 'TC_Request'
                AND StudentId__c = : StudentId]) {
                openSrs.add(srObj);
        }
        return openSrs;
    }
    /**
     * [getTCOptions Builds TC Option Picklist]
     * @return [Returns picklist]
     */
    public List<SelectOption> getTCOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('For Exit interview I will only complete the online form', 'For Exit interview I will only complete the online form'));
        options.add(new SelectOption('I would like a meeting with the Principal to complete the exit interview', 'I would like a meeting with the Principal to complete the exit interview'));
        options.add(new SelectOption('I would like a meeting with a member of Corporate Office customer care team to complete the exit interview', 'I would like a meeting with a member of Corporate Office customer care team to complete the exit interview'));
        return options;
    }
    /**
     * [getFeedbackOptions Build feedback options picklist]
     * @return [description]
     */

    public List<SelectOption> getFeedbackOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Strongly Agree', 'Strongly Agree'));
        options.add(new SelectOption('Agree', 'Agree'));
        options.add(new SelectOption('Disagree', 'Disagree'));
        options.add(new SelectOption('Strongly Disagree', 'Strongly Disagree'));
        options.add(new SelectOption('NA', 'NA'));
        return options;
    }
    /**
     * [getStudentDetails Gets student details for the given student ID]
     */
    public void getStudentDetails() {

        String accountQueryStr = '';
        accountQueryStr += GEMS_Utility.getAllFields(Account.getsObjectType().getDescribe());
        accountQueryStr = accountQueryStr.replace('FROM Account', ',Mother__r.Name,Mother__r.FirstName,Mother__r.Lastname,Mother__r.PersonEmail,Mother__r.PersonMobilePhone,Academic_Year__r.ACD_ID__c,School__r.Id__c ');
        accountQueryStr += ',Father__r.Name,Father__r.PersonEmail,Father__r.PersonMobilePhone,Father__r.FirstName,Father__r.LastName, tolabel(School__r.Country__c)';//V1.2 : Add tolabel(School__r.Country__c)
        accountQueryStr += ' FROM Account ';
        accountQueryStr += ' WHERE Student_Id__c =: studentID LIMIT 1';
        for (Account obj : Database.query(accountQueryStr)) {
            studentAccount = obj;
        }


    }

    /**
     * [setPrimaryContactDetails - Sets all primary contact information from the students Father/Mother details]
     * @param acc [description]
     */
    public void setPrimaryContactDetails(Account acc) {
        if (acc.Primary_Contact__c != NULL && acc.Primary_Contact__c.equals('Father')) {
            primaryContactName = acc.Father__r.Name;
            primaryContactMobileNumber = acc.Father__r.PersonMobilePhone;
            primaryContactEmail = acc.Father__r.PersonEmail;
        } else if (acc.Primary_Contact__c != NULL && acc.Primary_Contact__c.equals('Mother')) {
            primaryContactName = acc.Mother__r.Name;
            primaryContactMobileNumber = acc.Mother__r.PersonMobilePhone;
            primaryContactEmail = acc.Mother__r.PersonEmail;
        }
    }

    /**
     * [submitTCRequest Submit TC request]
     */
    public PageReference submitTCRequest() {
        savepoint sp;
        Map<Id, HexaBPM__Service_Request__c>accToSrMap = new Map<Id, HexaBPM__Service_Request__c>();
        accToSrMap = getOpenSRs();
        try {
            System.debug('studentAccount.Id==>' + studentAccount.Id);
            if (!accToSrMap.containsKey(studentAccount.Id) &&
                ( (studentAccount.Current_Status__c != 'EN') ||
                 (studentAccount.Current_Status__c != 'SO') ||
                 (studentAccount.Current_Status__c == 'EN' && studentAccount.Leave_Date__c == NULL))) {


                GEMS_FeeServiceUtility.studentLDAWrapper oasisDetails = new GEMS_FeeServiceUtility.studentLDAWrapper();
                oasisDetails = GEMS_FeeServiceUtility.getStudentLDA(studentAccount.Student_Id__c, String.valueOf(studentAccount.Academic_Year__r.ACD_ID__c));

                RecordType TCRecordType = [Select Id from RecordType Where developerName = :GEMS_Constants.SRRT_TCREQUEST Limit 1];
                
                SR.School__c = studentAccount.School__c;
                SR.Academic_Year__c = studentAccount.Academic_Year__c;
                SR.GradeLookup__c = studentAccount.GradeLookup__c;
                SR.Stream__c = studentAccount.Stream__c;
                System.debug('==>' + otherSchool);

				//V1.3
                if (SR.Transfer_school_name__c == 'Other' && String.isNotBlank(otherSchool)) {
                     SR.Transfer_School_Name_Non_GEMS__c = otherSchool;
                }
                
                SR.RecordTypeID = TCRecordType.ID;
                SR.Student__c = studentAccount.Id;

                SR.First_Name_Father__c = (studentAccount.Father__c != NULL) ? studentAccount.father__r.FirstName : NULL;
                SR.Last_Name_Father__c = (studentAccount.Father__c != NULL) ? studentAccount.father__r.LastName : NULL;
                SR.First_Name_Mother__c = (studentAccount.Mother__c != NULL) ? studentAccount.Mother__r.FirstName : NULL;
                SR.Last_Name_Mother__c = (studentAccount.Mother__c != NULL) ? studentAccount.Mother__r.FirstName : NULL;

                SR.Emergency_Contact_Number__c = (studentAccount.Emergency_Contact_Number__c != NULL) ?  studentAccount.Emergency_Contact_Number__c : NULL;
                SR.Parent_Username__c = (studentAccount.Parent_Username__c != NULL ) ?  studentAccount.Parent_Username__c : NULL;
                SR.Primary_Contact_Email__c = (studentAccount.Primary_Contact_Email__c != NULL ) ?  studentAccount.Primary_Contact_Email__c : NULL;

                SR.Oasis_Last_Date_of_Attendance__c = (oasisDetails.LDA_DATE != NULL) ? Date.parse(oasisDetails.LDA_DATE) : NULL ;
                SR.Oasis_Total_Days__c = oasisDetails.TOT_DAYS;
                SR.Oasis_Total_PRS_Days__c = oasisDetails.TOT_PRS_DAYS;

                Academic_Year__c AY = getAcademicYear(SR.Academic_Year__c);
                //Validate entered LDA is within AY range
                if(SR.Last_Date_of_Attendance__c != NULL && !validateAcademicYearRange(SR.Last_Date_of_Attendance__c,AY) && SR.Service_Request__c==NULL){
                    GEMS_Utility.addPageError(errorMessage);
                    return NULL;
                }
                //Validate entered LDA with OASIS LDA
                if (oasisDetails.LDA_DATE != NULL &&
                        SR.Last_Date_of_Attendance__c != NULL &&
                        SR.Last_Date_of_Attendance__c < Date.parse(oasisDetails.LDA_DATE)) {
                    GEMS_Utility.addPageError('Last date of attendance is incorrect. OASIS LDA is ' + Date.parse(oasisDetails.LDA_DATE));
                    return NULL;
                }
                Academic_year__c prevAY; 
                
                //Leeba Added new logic to populate the Date of Leaving
                if(SR.Date_of_leaving__c == null && AY!=null){
                    if(AY.Sys_Active__c==false && AY.End_Date__c!=null){
                        SR.Date_of_leaving__c = AY.End_Date__c;
                    }else if(AY.Sys_Active__c && SR.Last_Date_of_Attendance__c!=null && SR.Last_Date_of_Attendance__c >= System.Today()) {
                        SR.Date_of_leaving__c = SR.Last_Date_of_Attendance__c;
                    }else{
                        SR.Date_of_leaving__c = System.Today();
                    }
                }
                /* // Leeba Commented as part of the change
                if (SR.Date_of_leaving__c == NULL) {
                    
                        if (SR.Last_Date_of_Attendance__c >= System.Today() ) {
                            SR.Date_of_leaving__c = SR.Last_Date_of_Attendance__c;

                        } else {
                             SR.Date_of_leaving__c = System.Today();
                            
                        }
                    
                }
                */
                sp = Database.setSavepoint();
                insert SR;

                for (HexaBPM__SR_Status__c srStatus : [select Id, Name from HexaBPM__SR_Status__c where Name = 'Submitted']) {
                    SR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
                    SR.HexaBPM__External_SR_Status__c = srStatus.Id;
                    SR.HexaBPM__Submitted_Date__c = System.today();
                    SR.HexaBPM__Submitted_DateTime__c = System.now();
                }
                
                update SR;

                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'TC Request has been submitted successfully.'));
                PageReference successPage = new  PageReference('/apex/GEMS_TCSuccessPage?msg=TC Request has been submitted successfully.');
                successPage.setRedirect(true);
                return successPage;
            } else {
                GEMS_Utility.addpageError('There is an open TC SR with number ' + accToSrMap.get(studentAccount.Id).Name);
                return NULL;
            }

        } catch (Exception e) {
            Database.rollback(sp);
            GEMS_Utility.logException(e);
            String message = (e.getTypeName().equals('System.DmlException')) ? e.getDMLMessage(0)  : e.getMessage() ;
            GEMS_Utility.addPageError(message );
        }
        return NULL;
    }
    /**
     * [getOpenSRs - Gets all open TC Request]
     * @return [Map StudentID-->Service Request]
     */
    public Map<Id, HexaBPM__Service_Request__c>  getOpenSRs() {

        Map<Id, HexaBPM__Service_Request__c>accToSrMap = new Map<Id, HexaBPM__Service_Request__c>();

        for (HexaBPM__Service_request__c srObj  : [SELECT id,
                Name,
                HexaBPM__External_Status_Name__c,
                HexaBPM__External_SR_Status__r.HexaBPM__Type__c,
                Student__c,
                Student__r.Current_Status__c,
                HexaBPM__Record_Type_Name__c
                FROM HexaBPM__Service_request__c
                WHERE HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End'
                AND HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'Cancel'
                AND HexaBPM__Record_Type_Name__c = 'TC_Request']) {
                accToSrMap.put(srObj.Student__c, srObj);
        }
        return accToSrMap;
    }
    /**
     * [getSchoolPrincipal - Returns principal for the school]
     * @param  schoolId [School ID information]
     * @return          [Employee__c record]
     */
    public static Employee__c getSchoolPrincipal(Id schoolId) {
        Employee__c emp = new Employee__c();
        System.debug('School Id :' + schoolId);
        for (Employee__c empObj : [SELECT Id, Designation__c, School__c, First_Name__c, Last_Name__c FROM Employee__c WHERE School__c = :schoolId AND Designation__c = 'PRINCIPAL']) {
            emp = empObj;

        }
        return emp;
    }
    /**
     * [getAcademicYear Returns Academic year record]
     * @param  acdId [Academic year ID]
     * @return       [Academic year]
     */
    public static Academic_Year__c getAcademicYear(Id acdId) {
        Academic_year__c Ay = new Academic_year__c();
        for (Academic_Year__c obj : [Select Id,
                                            End_Date__c, 
                                            Start_Date__c, 
                                            Active__c,
                                            Year__c,
                                            Sys_Academic_Year_Value__c,
                                            Sys_Active__c,
                                            School__c
                                      FROM Academic_Year__c WHERE Id = :acdId LIMIT 1]) {
            ay = obj;
        }
        return ay;
    }
    /**
     * [validateAcademicYearRange -Academic Year validation ]
     * @param  dateVal [Date value to validate ]
     * @param  AY      [Academic Year]
     * @return         [Validation result]
     */
    public static  boolean validateAcademicYearRange(Date dateVal, Academic_year__c AY) {
        Boolean isValid = true;
        Academic_year__c prevAY = new Academic_year__c();
        System.debug('currAY Start Date  ==>'+AY.Start_Date__c);
        System.debug('currAY End Date  ==>'+AY.End_Date__c);
        
        for (Academic_Year__c obj : [Select Id,
                                            End_Date__c,
                                            Sys_Academic_Year_Value__c, 
                                            Start_Date__c, 
                                            Active__c,
                                            Year__c,
                                            School__c,
                                            Sys_Active__c
                                      FROM Academic_Year__c WHERE Sys_Academic_Year_Value__c  < :AY.Sys_Academic_Year_Value__c AND School__c =: AY.School__c ORDER BY Sys_Academic_Year_Value__c DESC LIMIT 1]) {
            prevAY = obj;
        }

        
        //Buffer
        if(!(System.today()  >= AY.Start_Date__c && System.today() <= AY.End_Date__c)){
            
            System.debug('**Buffer**');
            //Buffer ahead of active AY
            if(System.today() > AY.End_Date__c ){
                System.debug('**Buffer - Ahead**');
                //Not Promoted  - Validate if LDA is within current AY range
                 if (!(dateVal >= AY.Start_Date__c &&  dateVal <= AY.End_Date__c)) {
                      errorMessage = 'LDA should be within the Academic year range.';
                      isValid = false; 
                 }
                 
            }else{
                System.debug('**Buffer - Before - promoted**');
                //Promoted and in buffer - validate if the LDA is last date of Prev AY
                if (!(dateVal == prevAY.End_Date__c )) {
                      errorMessage = 'LDA should be last day of previous academic year.('+formatDate(prevAY.End_Date__c)+')';
                      isValid = false; 
                      
                 }
            }
            
        }else
        //No Buffer
        {
                System.debug('**No Buffer**');
            //Within Academic Year LDA should be within the AY range
            
            
            if(System.Today() >= AY.Start_Date__c && System.Today() <= AY.Start_Date__c.addDays(90)){
                
                System.debug('==> First 90 days of Active AY ');
                if ( !(dateVal >= prevAY.Start_Date__c &&  dateVal <= prevAY.End_Date__c) && !(dateVal >= AY.Start_Date__c &&  dateVal <= AY.End_Date__c)) {
                      errorMessage = 'LDA should be within curent or previous Academic year range.';
                      isValid = false; 
                      
                 }
            }
        
            else {
                System.debug('==> After 90 days of Active AY ');
                if(!(dateVal >= AY.Start_Date__c &&  dateVal <= AY.End_Date__c)) {
                      errorMessage = 'LDA should be within the Academic year range.';
                      isValid = false; 
                 }
            }
            
        }
        
        
       
        
        return isValid;
    }
     public static String formatDate(Date d) {
         return  d.day()+ '-' + d.month() + '-' +  d.year();
      }
}