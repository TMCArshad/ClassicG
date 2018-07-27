/**************************************************************************************************
* Name               : GEMS_UpdateSR                                                               *
* Description        : This class implements all the logic required for cancellation  
*                                               *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017
  1.1         Leeba       20/12/2017 - changed the order of execution in CancelRequest Method to update the student first and 
                                       then update the SR. 
                                       Added the code to blank the Leave Date on Cancellation
  1.2         Kim Noceda  15/02/2018 - Added logic on registerSR method to check if the School Transfer waive of is flagged as true and
                                       Confirmed if GEMS Student field is blank. If true, return a message.
  1.3		  Swati		  15/03/2018		Ticket 189995
  1.4         Leeba       25/3/2018    CR 312 - Added the code to blank LDA on Cancellation in TC and blank LDA and Leave Date in SO
**************************************************************************************************/
global without sharing class GEMS_UpdateSR {
    public static String errorMessage {get;set;}

    public static String cancelRequest(String srId, String statusValue) {


        Savepoint sp = Database.setSavepoint(); 
        String result = 'Success';
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        String SRQueryStr = '';
        SRQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getSobjectType().getDescribe());
        SRQueryStr += ' WHERE Id=:srId ';
        for (HexaBPM__Service_Request__c obj: Database.Query(SRQueryStr)) {
            SR = obj;
        }
        Account student;

        System.debug('SR==>' + SR);
        try {

            if (SR.Student__c != NULL) {
                student = new Account(Id = SR.Student__c);
                student.current_Status__c = 'EN';
                if (SR.HexaBPM__Record_Type_Name__c.equals('TC_Request')) {
                    student.Cancelled_Transaction_Date__c = System.Today();
                    student.Cancel_Date__c = System.Today();
                    student.Leave_date__c = NULL;  //1.1  Clear leave date upon cancelling TC request
                    student.Last_Att_Date__c = NULL; //1.4 clear LDA upon cancelling TC request
                    student.TC_Cancel_Remarks__c = SR.TC_Cancel_Remarks__c;
                    UpdatePromotionForStudent(student.Id);

                } else if (SR.HexaBPM__Record_Type_Name__c.equals('Cancel_Admission')) {
                    student.Rejoin_Date__c = System.Today();
                    student.Rejoin_Remarks__c = SR.Reverse_Cancel_Admission_Remarks__c;
                } else if (SR.HexaBPM__Record_Type_Name__c.equals('Strike_Off')) {
                    student.SO_Cancel_Date__c = System.Today();
                    student.Leave_date__c = NULL;  //1.4  Clear leave date upon cancelling SO request
                    student.Last_Att_Date__c = NULL; //1.4 clear LDA upon cancelling SO request
                    student.Strike_Off_reason__c = NULL;//1.4 clear Strike off reason on cancelling SO request
                }
            } else {
                result = 'No student account associated with SR.';
                return result;
            }
            
            //Update student as enrolled
            update student;
            //updateSRStatus(srId,statusValue);
            result = updateSRStatus(srId, statusValue);
            updateAllSRSteps('CANCELLED', srId);

        } catch (Exception e) {
            Database.rollback(sp);
            GEMS_Utility.logException(e);
            return e.getMessage();
        }

        return result;
    }
   


    public static string cancelAdmission(String srId, String statusValue) {
        String result = 'Success';
        Account student;
        try {
            GEMS_FeeServiceUtility.studentLDAWrapper oasisDetails = new GEMS_FeeServiceUtility.studentLDAWrapper();
            HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
            for (HexaBPM__Service_Request__c obj: [SELECT ID,
                    Service_Request__c,
                    Service_Request__r.Student__c,
                    Student__c,
                    Student__r.Date_of_Join__c,
                    Academic_Year__r.Start_Date__c,
                    StudentId__c,
                    Cancel_Admission_Remarks__c,
                    Academic_Year__r.ACD_ID__c,
                    Oasis_Last_Date_of_Attendance__c,
                    Oasis_Total_Days__c,
                    Oasis_Total_PRS_Days__c

                    FROM HexaBPM__Service_Request__c Where Id =: srId
                ]) {
                SR = obj;
            }
            if (SR.Student__c == NULL) {
                result = 'No student associated with SR.';
                return result;
            }


            oasisDetails = GEMS_FeeServiceUtility.getStudentLDA(SR.StudentId__c, String.valueOf(SR.Academic_Year__r.ACD_ID__c));

            SR.Oasis_Last_Date_of_Attendance__c = (oasisDetails.LDA_DATE != NULL) ? Date.parse(oasisDetails.LDA_DATE) : NULL;
            SR.Oasis_Total_Days__c = oasisDetails.TOT_DAYS;
            SR.Oasis_Total_PRS_Days__c = oasisDetails.TOT_PRS_DAYS;
            update SR;

            if (Integer.valueOf(oasisDetails.TOT_PRS_DAYS) > 0 || (SR.Student__r.Date_of_Join__c!=null && SR.Student__r.Date_of_Join__c < SR.Academic_Year__r.Start_Date__c)) {
                result = 'You are not allowed to cancel the admission. Student has attended school.';
            } else {
                //Submit SR
                updateSRStatus(srId, 'SUBMITTED');
                updateSRStatus(srId, 'APPROVED');
                student = new Account(Id = SR.Student__c);
                student.current_Status__c = 'CN';
                student.Cancel_Date__c = System.today();
                student.Cancelled_Remarks__c = SR.Cancel_Admission_Remarks__c;  
                update student;
            }


        } catch (Exception e) {
            System.debug('Error:'+e.getMessage());
            GEMS_Utility.logException(e);
            result = e.getMessage();

        }


        return result;

    }
    Webservice static string cancelSR(String srId, String recTypeName) {

        String result;
        System.debug('Cancel SR==>' + recTypeName);
        //Requesting for cancel from the actual SR
        if (recTypeName == 'TC_Request' || recTypeName == 'Strike_Off' || recTypeName == 'Cancel_Admission') {

            result = cancelRequest(srId, 'CLOSED');
        }
        return result;
    }
    Webservice static string submitSR(String srId, String recTypeName) {

        String result;
        if (recTypeName == 'Enrollment') {

            result = updateSRStatus(srId, 'SUBMITTED');
           
        } else if (recTypeName == 'Cancel_Admission') {
            result = cancelAdmission(srId, 'SUBMITTED');
        } else if (recTypeName == 'Strike_Off') {

            result = updateOasisDetails(srId);


        } else if (recTypeName == 'TC_Request') {

            result = updateOasisDetails(srId);
            //updateStudent(srId, 'TC');

        } else {
            result = updateSRStatus(srId, 'SUBMITTED');
        }
        return result;
    }



    public static String updateOasisDetails(Id SrId) {
        String result = 'Success';
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        for (HexaBPM__Service_Request__c srObj: [SELECT Id,
                Student__c,
                Last_Date_of_Attendance__c,
                Academic_Year__c,Academic_Year__r.Sys_Active__c,Academic_Year__r.End_Date__c,
                Student__r.Student_Id__c,Service_Request__c,
                Student__r.Academic_Year__r.ACD_ID__c,Date_of_leaving__c
                FROM HexaBPM__Service_Request__c
                WHERE id =: SrId
            ]) {
            SR = srObj;

        }

        GEMS_FeeServiceUtility.studentLDAWrapper oasisDetails = new GEMS_FeeServiceUtility.studentLDAWrapper();
        oasisDetails = GEMS_FeeServiceUtility.getStudentLDA(SR.Student__r.Student_Id__c, String.valueOf(SR.Student__r.Academic_Year__r.ACD_ID__c));
        SR.Oasis_Last_Date_of_Attendance__c = (oasisDetails.LDA_DATE != NULL) ? Date.parse(oasisDetails.LDA_DATE) : NULL;
        SR.Oasis_Total_Days__c = oasisDetails.TOT_DAYS;
        SR.Oasis_Total_PRS_Days__c = oasisDetails.TOT_PRS_DAYS;
        //System.debug('SR.Last_Date_of_Attendance__c==>' + SR.Last_Date_of_Attendance__c);
        //System.debug('Date.parse(oasisDetails.LDA_DATE)==>' + Date.parse(oasisDetails.LDA_DATE));
        
        Academic_Year__c AY = getAcademicYear(SR.Academic_Year__c);
        //Validate entered LDA is within AY range
        if(SR.Last_Date_of_Attendance__c != NULL && !validateAcademicYearRange(SR.Last_Date_of_Attendance__c,AY) && SR.Service_Request__c==NULL 
        ){
            result = errorMessage;
        }
        //Validate entered LDA with OASIS LDA
        if (oasisDetails.LDA_DATE != NULL &&
                SR.Last_Date_of_Attendance__c != NULL &&
                SR.Last_Date_of_Attendance__c < Date.parse(oasisDetails.LDA_DATE)) {
                result = 'Last date of attendance is incorrect.';
        }
        
        if(SR.Date_of_leaving__c == null){
            if(SR.Academic_Year__c!=null && SR.Academic_Year__r.Sys_Active__c==false && SR.Academic_Year__r.End_Date__c!=null){
                SR.Date_of_leaving__c = SR.Academic_Year__r.End_Date__c;
            }else if(SR.Academic_Year__c!=null && SR.Academic_Year__r.Sys_Active__c && SR.Last_Date_of_Attendance__c!=null && SR.Last_Date_of_Attendance__c >= System.Today()) {
                SR.Date_of_leaving__c = SR.Last_Date_of_Attendance__c;
            }else{
                SR.Date_of_leaving__c = System.Today();
            }
        }
        System.debug('DOL==>'+SR.Date_of_leaving__c);
        
        if(result == 'Success'){
            for(HexaBPM__SR_Status__c srStatus: [select Id from HexaBPM__SR_Status__c where HexaBPM__Code__c =: 'SUBMITTED']) {
                SR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
                SR.HexaBPM__External_SR_Status__c = srStatus.Id;
                SR.Transaction_Date__c = system.today();
                SR.HexaBPM__Submitted_Date__c = system.today();
                SR.HexaBPM__Submitted_DateTime__c = system.now();
                try{
                    update SR;
                    result = 'Success';
                }catch(DMLException e) {
                    GEMS_Utility.LogException(e);
                    result = e.getDmlMessage(0);
                    return result;
                }
            }
        }
        return result;
    }
     public static String formatDate(Date d) {
         return  d.day()+ '-' + d.month() + '-' +  d.year();
      }
    public static String updateSRStatus(String srId, String statusValue) {
        String result;
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c(Id = srId);

        for (HexaBPM__SR_Status__c srStatus: [select Id from HexaBPM__SR_Status__c where HexaBPM__Code__c =: statusValue]) {
            SR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
            SR.HexaBPM__External_SR_Status__c = srStatus.Id;
            SR.Transaction_Date__c = system.today();

            if (statusValue == 'SUBMITTED') {
                SR.HexaBPM__Submitted_Date__c = system.today();
                SR.HexaBPM__Submitted_DateTime__c = system.now();
            }
                SR.Transaction_Date__c = System.Today();
        }
        try {
            update SR;
            result = 'Success';
        } catch (DMLException e) {
            GEMS_Utility.LogException(e);
            return (e.getDmlMessage(0));

        }
        return result;

    }


    static void updateAllSRSteps(String status, String srID) {

        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c();
        List < HexaBPM__Step__c > steps = new List < HexaBPM__Step__c > ();
        try {
            for (HexaBPM__Status__c obj: [SELECT Id, HexaBPM__Code__c FROM HexaBPM__Status__c WHERE HexaBPM__Code__c =: status]) {
                stepStatus = obj;
            }
            System.debug('==>' + stepStatus);
            for (HexaBPM__Step__c stepObj: [SELECT HexaBPM__Status__c,
                    HexaBPM__SR__c
                    FROM HexaBPM__Step__c
                    WHERE HexaBPM__SR__c =: srID
                ]) {

                stepObj.HexaBPM__Status__c = (stepStatus != NULL) ? stepStatus.Id : stepObj.HexaBPM__Status__c;
                stepObj.OwnerId = UserInfo.getUserId(); //Validation to accept Step before changing status
                steps.add(stepObj);
            }
            update steps;
        } catch (Exception e) {
            GEMS_Utility.logException(e);

        }
    }

    public static void updateStudent(String SrId, String status) {

        HexaBPM__Service_Request__c SR = [SELECT ID,
            Service_Request__c,
            Comments__c,
            Transfer_Reason__c,
            HexaBPM__Record_Type_Name__c,
            Student__c,
            Strike_Off_reason__c
            FROM HexaBPM__Service_Request__c
            WHERE Id =: srId
        ];
        if (SR.Student__c != NULL) {
            Account student = new Account(id = SR.Student__c);
            student.current_Status__c = status;
            student.Transfer_Reason__c = (status.equals('TC')) ? SR.Transfer_Reason__c : student.Transfer_Reason__c;

            update student;
        }

    }


    //If in case multiple fields to be pre populated


    Webservice static string getTCEditPageReference(String schoolId) {
        string url = '';
        String err = '';
        School__c school = new School__c();
        String schoolQueryStr = GEMS_Utility.getAllFields(School__c.getsObjectType().getDescribe());
        schoolQueryStr += ' WHERE Id=:schoolId ';
        for (School__c obj: Database.query(schoolQueryStr)) {
            school = obj;

        }
        
        try {
            if(validateSRCreation(school.Short_Name__c)){
            RecordType rt = [Select Id, developerName FROM RecordType WHERE developerName =: GEMS_Constants.SRRT_TCREQUEST];
            string objectKeyPrefix = GEMS_Utility.getObjectPrefix('HexaBPM__Service_Request__c');
            url += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectKeyPrefix + '/e?RecordType=' + rt.Id;
            Map < String, String > fieldMap = GEMS_Utility.getFieldElementMap('HexaBPM__Service_Request__c', GEMS_Constants.SRRT_TCREQUEST);
            for (String key: fieldMap.keySet()) {
                if (key.equals('School')) {
                    url += '&' + fieldMap.get(key) + '_lkid=' + school.Id;
                    url += '&' + fieldMap.get(key) + '=' + school.Name;
                }
            }
            }
            else{
                return 'SR creation is not allowed for this school.';
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            return (e.getMessage());
        }

        return url;

    }
    Webservice static string getSOEditPageReference(String schoolId) {
        string url = '';
        String err = '';
        School__c school = new School__c();
        String schoolQueryStr = GEMS_Utility.getAllFields(School__c.getsObjectType().getDescribe());
        schoolQueryStr += ' WHERE Id=:schoolId ';
        for (School__c obj: Database.query(schoolQueryStr)) {
            school = obj;

        }
        try {
            if(validateSRCreation(school.Short_Name__c)){
            RecordType rt = [Select Id, developerName FROM RecordType WHERE developerName =: GEMS_Constants.SRRT_STRIKEOFF];
            string objectKeyPrefix = GEMS_Utility.getObjectPrefix('HexaBPM__Service_Request__c');
            url += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectKeyPrefix + '/e?RecordType=' + rt.Id;
            Map < String, String > fieldMap = GEMS_Utility.getFieldElementMap('HexaBPM__Service_Request__c', GEMS_Constants.SRRT_STRIKEOFF);
            for (String key: fieldMap.keySet()) {
                if (key.equals('School')) {
                    url += '&' + fieldMap.get(key) + '_lkid=' + school.Id;
                    url += '&' + fieldMap.get(key) + '=' + school.Name;
                }
            }
            
           }else{
            return 'SR creation is not allowed for this school.';
           }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            return e.getMessage();
        }

        return url;

    }
    Webservice static string getCancelAdmissionEditPageReference(String schoolId) {

        string url = '';
        String err = '';
        School__c school = new School__c();
        String schoolQueryStr = GEMS_Utility.getAllFields(School__c.getsObjectType().getDescribe());
        schoolQueryStr += ' WHERE Id=:schoolId ';
        for (School__c obj: Database.query(schoolQueryStr)) {
            School = obj;

        }
        try {
            if(validateSRCreation(school.Short_Name__c)){
            RecordType rt = [Select Id, developerName FROM RecordType WHERE developerName =: GEMS_Constants.SRRT_CANCEL_ADMISSION];
            string objectKeyPrefix = GEMS_Utility.getObjectPrefix('HexaBPM__Service_Request__c');
            url += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectKeyPrefix + '/e?RecordType=' + rt.Id;
            Map < String, String > fieldMap = GEMS_Utility.getFieldElementMap('HexaBPM__Service_Request__c', GEMS_Constants.SRRT_CANCEL_ADMISSION);
            for (String key: fieldMap.keySet()) {
                if (key.equals('School')) {
                    url += '&' + fieldMap.get(key) + '_lkid=' + school.Id;
                    url += '&' + fieldMap.get(key) + '=' + school.Name;
                }
            }
            }else{
                return 'SR creation is not allowed for this school.';
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            return e.getMessage();
        }

        return url;


    }

    Webservice static string getSOToTCEditPageReference(String srId) {


        string url = '';
        String err = '';
        try {
            RecordType rt = [Select Id, developerName FROM RecordType WHERE developerName =: GEMS_Constants.SRRT_TCREQUEST];
            HexaBPM__Service_Request__c SOtoTC = new HexaBPM__Service_Request__c();
            String srQueryStr = '';
            srQueryStr += GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
            srQueryStr = srQueryStr.replace(' FROM HexaBPM__Service_Request__c', ',School__r.Name,Student__r.Name FROM HexaBPM__Service_Request__c ');
            System.debug('srQueryStr==>' + srQueryStr);
            srQueryStr += ' WHERE Id =: srId ';

            for (HexaBPM__Service_Request__c obj: Database.Query(srQueryStr)) {
                SOtoTC = obj;
            }

            string objectKeyPrefix = GEMS_Utility.getObjectPrefix('HexaBPM__Service_Request__c');
            url += System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectKeyPrefix + '/e?RecordType=' + rt.Id;
            Map < String, String > fieldMap = GEMS_Utility.getFieldElementMap('HexaBPM__Service_Request__c', GEMS_Constants.SRRT_TCREQUEST);
            for (String key: fieldMap.keySet()) {
                if (key.equals('School')) {
                    url += '&' + fieldMap.get(key) + '_lkid=' + SOtoTC.School__c;
                    url += '&' + fieldMap.get(key) + '=' + SOtoTC.School__r.Name;
                }
                if (key.equals('Student')) {
                    url += '&' + fieldMap.get(key) + '_lkid=' + SOtoTC.Student__c;
                    url += '&' + fieldMap.get(key) + '=' + SOtoTC.Student__r.Name;
                }

                if (key.equals('Last Date of Attendance')) {
                    String d = (SOtoTC.Last_Date_of_Attendance__c != NULL) ? SOtoTC.Last_Date_of_Attendance__c.format() : NULL;
                    url += '&' + fieldMap.get(key) + '=' + d;
                }


            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            return e.getMessage();
        }

        return url;

    }

 
    Webservice static GEMS_UpdateSR.resultWrapper SOtoTC(String srId,String recTypeName){
       String retStr = '';
       resultWrapper rw ;
       String srQueryStr = '';
       try{
       RecordType rt = [Select Id,developerName FROM RecordType WHERE developerName = 'TC_Request'];
       HexaBPM__SR_Template__c TCSRTemplate = [Select Id from HexaBPM__SR_Template__c WHERE HexaBPM__SR_RecordType_API_Name__c = 'TC_Request' LIMIT 1];
       HexaBPM__Service_Request__c SOtoTC = new HexaBPM__Service_Request__c();
       srQueryStr += GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
       srQueryStr = srQueryStr.replace('FROM HexaBPM__Service_Request__c',', HexaBPM__External_SR_Status__r.HexaBPM__Type__c FROM HexaBPM__Service_Request__c' );
       srQueryStr += ' WHERE Id =:srId '; 
        
       ID sosrId;
       for(HexaBPM__Service_Request__c SR : Database.query(srQueryStr)){
           if(SR.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'Cancel'){
           SOtoTC = SR.clone(false,true);
           sosrId = SR.Id;
           }else{
            rw = new resultWrapper('Invalid SR status : '+ SR.HexaBPM__External_Status_Name__c,false);
            return rw;
           }
       }
       
       
           for (HexaBPM__SR_Status__c srStatus: [select Id from HexaBPM__SR_Status__c where HexaBPM__Code__c = 'DRAFT']) {
            SOtoTC.HexaBPM__Internal_SR_Status__c = srStatus.Id;
            SOtoTC.HexaBPM__External_SR_Status__c = srStatus.Id;
           }
           SOToTC.HexaBPM__SR_Template__c = TCSRTemplate.Id;
           SOtoTC.RecordTypeId = rt.Id;
           SOtoTC.Service_Request__c = sosrId;
           insert SOtoTC;
           
           //retStr = updateSRStatus(SOtoTC.Id,'SUBMITTED');
           retStr = 'Success';
           if(retStr.equals('Success')){
               rw = new resultWrapper('/'+String.valueOf(SOtoTC.Id) + '/e?retURL=%2F' + String.valueOf(SOtoTC.Id) ,true);
               System.debug('rw:'+rw);
               return rw;
           }else{
               rw = new resultWrapper(retStr,false);
           }
           
           return rw;
       }
       catch(DMLException e){
           GEMS_Utility.logException(e);
           
           rw = new resultWrapper(e.getDMLMessage(0),false);
           return rw;
       }
    }
    
    /**
     * [createSR -Create SR based on the record type checking if user has access to the SR type by looking in to the Registrar queue]
     * @param  BSUID       [School Code]
     * @param  recTypeName [Record Type Name]
     * @return             [result]
     */
    Webservice static GEMS_UpdateSR.resultWrapper createSR(String BSUID, String recTypeName) {
        System.debug('==>createSO<==');
        resultWrapper rw;
        School__c school;
        try {
            school = GEMS_Utility.getSchool(BSUID);
            if (validateSRCreation(school.Short_Name__c)) {

                RecordType rt = [Select Id, developerName FROM RecordType WHERE developerName =: recTypeName];
                HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
                SR.RecordTypeId = rt.Id;
                SR.School__c = school.Id;
                insert SR;
                rw = new resultWrapper(String.valueOf(SR.Id), true);
            } else {
                rw = new resultWrapper('You are not allowed to create request for this school.', false);
                return rw;
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            rw = new resultWrapper(e.getMessage(), false);
        }

        return rw;
    }

    public static Boolean validateSRCreation(String shortName) {
        
        GEMS_Queue_Config__c customSettingsForQueue = GEMS_Queue_Config__c.getInstance(shortName+'-Registrar');
        system.debug('---customSettingsForQueue--'+customSettingsForQueue);
        set<id> groupMemberSet = new set<id>();
        if(customSettingsForQueue!=null && string.isNotBlank(customSettingsForQueue.Queue_Name__c)){
            for(Group grp : [Select Id,(select UserOrGroupId from GroupMembers),Name,DeveloperName from Group where type = 'Queue' and DeveloperName = :customSettingsForQueue.Queue_Name__c]){
                for(GroupMember obj : grp.GroupMembers){
                    groupMemberSet.add(obj.UserOrGroupId);
                }
            }
        }
        
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        if(profileName.equals('Corporate') || profileName.equals('System Administrator') || profileName.equals('Enrolments Centre') || (groupMemberSet!=null && groupMemberSet.contains(userInfo.getUserId()))){
            return true;    
        }
        return false;
    }
    
    Webservice static string allowedToAccessButtonOnSchool(String shortName) {
        boolean allowedToCreateSR = validateSRCreation(shortName);
        if(allowedToCreateSR==true){
            return 'True';
        }
        return 'False';
    }
    
    public static void updatePromotionForStudent(Id StudentId){
     List<Promotion__c> promotions = new List<Promotion__c>();
       for(Promotion__c promotionObj : [SELECT id,TC_Applied__c,Re_enrolment_Remark__c,Student__c,Active__c FROM Promotion__c WHERE Student__c =:StudentId AND Active__c = true]){
          promotionObj.TC_Applied__c = false;
          promotionObj.Re_enrolment_Remark__c = 'Pending'; //V1.3
          promotions.add(promotionObj);
       }
       if(!promotions.isEmpty()){
            update promotions;
       }

    }
    
    global class resultWrapper {
        Webservice String result {
            get;
            set;
        }
        Webservice Boolean successFlag {
            get;
            set;
        }
        public resultWrapper(String result, Boolean successFlag) {
            this.result = result;
            this.successFlag = successFlag;
        }
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
   
   
   
    //Added By Swati
    Webservice static string registerSR(String srID){
        string msg = 'Success';
        try{
            set<String> srStatusCodes = new Set<String>();
            srStatusCodes.add('REGISTERED');
            
            Map<String,String> srStatusMap = new Map<String,String>();
            if(!srStatusCodes.isEmpty()){
                for( HexaBPM__SR_Status__c srStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c IN :srStatusCodes] ){
                    srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
                }
            }
            
            list<HexaBPM__Service_Request__c> tempList = [select id, HexaBPM__External_SR_Status__c,
                                                                 HexaBPM__Internal_SR_Status__c,
                                                                 Payment_Status__c,HexaBPM__External_Status_Name__c,
                                                                 Transfer_Fee_Waive_Off__c,Existing_Student_Id__c,
                                                                 Confirmed_if_GEMS_Student__c
                                                          from HexaBPM__Service_Request__c where id=:srId];
                
            if(tempList!=null && tempList.size()>0){
                //V1.2
                if(tempList[0].Transfer_Fee_Waive_Off__c == true && string.isNotBlank(tempList[0].Existing_Student_Id__c) && string.isBlank(tempList[0].Confirmed_if_GEMS_Student__c)){
                   msg = 'Please confirm GEMS Student';
                }else if(tempList[0].HexaBPM__External_Status_Name__c!='Submitted'){
                    msg = 'SR can be registered only if it is submitted first.';    
                }
                else{
                    tempList[0].HexaBPM__External_SR_Status__c = srStatusMap.get('REGISTERED');
                    tempList[0].HexaBPM__Internal_SR_Status__c = srStatusMap.get('REGISTERED');
                    if(tempList[0].Transfer_Fee_Waive_Off__c == true && string.isNotBlank(tempList[0].Existing_Student_Id__c) && 
                       string.isNotBlank(tempList[0].Confirmed_if_GEMS_Student__c) && tempList[0].Confirmed_if_GEMS_Student__c == 'Yes'){
                    	tempList[0].Payment_Status__c = 'No Payment';
                    }
                    update tempList[0];
                }
                //END
            }
        }catch(exception e){
            return e.getMessage();
        }
        return msg;
    }
   
}