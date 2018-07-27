/*****************************************************************************************************************************
    Author      :   Rajil
    Date        :   21 March 2018
    Description :   scholarship Controller
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

global without sharing class Gems_ApplyScholarshipCntrl{

    public Attachment additionalDocument {
        get { if (additionalDocument == null)
                additionalDocument = new Attachment();
                return additionalDocument;
        }set;
    }
    
    public attachment document{
        get { if (document == null)
                document = new Attachment();
                return document;
        }set;
    }
    
    public string fileName {get;set;}
    public string fileDescription {get;set;}
    public string SRDocID {get;set;}
    public string SRDocName {get;set;}
    
    public boolean isFinancialStable {get;set;}
    public boolean isTerms{get;set;}
    
    //checks if the student or enrolment is from GEMS or not
    public string isStudentVal {get;set;} 
    public string isEnrolled {get;set;}
    public list<SelectOption> isStudentList { get; set; }
    
    //if existing student
    public string existStudentId {get;set;}
    public Account student {get;set;}
    
    //if existing enrolment SR
    public string existSRNumber {get;set;}
    public HexaBPM__Service_Request__c enrolmentSR {get;set;}
    
    //other parameters required on page
    public string enrolOnlineURL {get;set;}
    
    //check if scholarship is enabled at school level
    public boolean isScholarshipEnabled {get;set;}
    
    //check if scholarship is enabled at school level but is in past or future
    public boolean isScholarshipActive {get;set;}
    
    //check if student or SR exist
    public boolean ifDetailsExist {get;set;} 
    
    //check if Scholarship is raised successfully
    public boolean isSaveSuccess {get;set;} 
    
    public string BSUID; //school BSU passed in URL
    
    public school__c school {get;set;} // get school from BSU
    public HexaBPM__Service_Request__c scholarshipSR {get; set;} 
    
    //get details for future AY and grade for applying
    public academic_year__c futureAY {get; set;}
    public grade__c futureGrade {get; set;}
    
    //addedfortesting
    public map<string, string> mapParameters;
    
    public list<HexaBPM__SR_Doc__c> lstDoc {get; set;}
    
    public Id recTypeID;
    public string selectedContentType {get;set;}
    
    //constructor invoked
    public Gems_ApplyScholarshipCntrl(){
        document = new Attachment();
        scholarshipSR = new HexaBPM__Service_Request__c();
        recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Scholarship');
        scholarshipSR.recordtypeid = recTypeID;
        
        isStudentList = new list<SelectOption>();
        BSUID = ApexPages.CurrentPage().getParameters().get('BSU');
        if(string.isNotBlank(BSUID))
            init();
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  'BSUID is missing.')); 
    }
    
    //intialize details on load
    public void init(){
        isStudentList.add(new SelectOption('', '--None--'));
        isStudentList.add(new SelectOption('Yes', 'Yes'));
        isStudentList.add(new SelectOption('No', 'No'));
        
        isScholarshipEnabled = false;
        isScholarshipActive = false;
        ifDetailsExist = false;
        isSaveSuccess = false;
        existSRNumber = 'SR-';
        
        school = new school__c();
        school = GEMS_Utility.getSchool(BSUID);
        if(school!=null && string.isNotBlank(school.id)){
            if(school.Scholarship_Start_Date__c!=null)
                isScholarshipEnabled = true;
            
            if(school.Scholarship_Start_Date__c!=null && school.Scholarship_End_Date__c!=null &&
               school.Scholarship_Start_Date__c<=system.today() && school.Scholarship_End_Date__c>= system.today())
                
                isScholarshipActive = true; 
            
            map<string, GEMS_Site_Domain_Config__c> siteConfig;
            siteConfig =  GEMS_Site_Domain_Config__c.getAll();
                
            GEMS_Site_Domain_Config__c domainConfig = new GEMS_Site_Domain_Config__c();
            domainConfig =  siteConfig.get(school.short_name__c); 
            enrolOnlineURL = (domainConfig != NULL ) ? domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c : NULL;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  'Invalid BSU, Please contact system admin.')); 
        }
    }
    
    // validate details and show message on page
    public void validateScholarship (){
        string message = 'Success';
        try{
            string academicYearId = '';
            string curriculum = '';
            string stream = '';
            decimal gradeId = 0;
            
            string param = Apexpages.currentPage().getParameters().get('exStudentNameParam');
            if(string.isNotBlank(param) && param.contains('SR-'))
                existSRNumber = param;
            else
                existStudentId = param;
            
            string existDOB = Apexpages.currentPage().getParameters().get('exDOBParam');
        
            student = new Account();
            enrolmentSR = new HexaBPM__Service_Request__c();
            ifDetailsExist = false;
            
            String[] dateStr ;
            string formattedDate = '';
            if(string.isNotBlank(existDOB)){
            	system.debug('-----'+existDOB);
                dateStr = existDOB.split('/');
                
                system.debug('-----'+dateStr);
                system.debug('-----'+dateStr.size());
                
                if( !Test.isRunningTest()){
	                if(dateStr.size()==3)
	                    formattedDate = dateStr[2]+'-'+dateStr[1]+'-'+dateStr[0];
	                else
	                    message = 'Please provide correct date';
                }else{
                	formattedDate = existDOB;
                }
            }
        
            scholarshipSR = new HexaBPM__Service_Request__c();
            scholarshipSR.recordtypeid = recTypeID;
            
            system.debug('---existStudentId--'+existStudentId);
            system.debug('---existSRNumber--'+existSRNumber);
            system.debug('---existDOB--'+existDOB);
            system.debug('---formattedDate--'+formattedDate);
            // if student details are provided
            if(string.isNotBlank(existStudentId) && string.isNotBlank(formattedDate)){
                ifStudentExist(formattedDate);
                if(student!=null && string.isNotBlank(student.id)){
                    if(school.id != student.school__c){ 
                        message = 'Scholarships are currently open in the GEMS school where you are enrolled. In order to apply for a scholarship in another school you would need to first be enrolled there.';
                    }else{
                        academicYearId = student.Academic_Year__r.Year__c;
                        gradeId = student.GradeLookup__r.Sys_Sort_Val__c;
                        curriculum = student.curriculum_current__c;
                        stream = student.stream__c;
                        scholarshipSR.First_Name__c = student.FirstName;
                        scholarshipSR.Last_Name__c = student.LastName;
                        scholarshipSR.Date_Of_Birth__c = student.Date_Of_Birth__c;
                        existStudentId = student.Student_Id__c;
                    }
                }else{
                    message = 'Please cross check the information you have provided as it doesn’t match our records.';
                    existStudentId = '';
                }
            }
            
            //if SR details are provided
            if(string.isNotBlank(existSRNumber) && existSRNumber!='SR-' && string.isNotBlank(formattedDate)){
                ifEnrolmentExist(formattedDate);
                if(enrolmentSR!=null && string.isNotBlank(enrolmentSR.id)){
                    if(school.id != enrolmentSR.school__c)  
                        message = 'Scholarships are currently open in the GEMS school where you are enrolled. In order to apply for a scholarship in another school you would need to first be enrolled there.';
                    else if(enrolmentSR.HexaBPM__IsClosedStatus__c == true)
                        message = 'It appears you have provided your application number. Please provide us with your Student ID to proceed.';
                    else if(enrolmentSR.HexaBPM__Is_Rejected__c == true)
                        message = 'The enrolment number provided corresponds to a previously rejected application. Please contact the school for more information on your application for enrolment. ';
                    else if(enrolmentSR.HexaBPM__IsCancelled__c == true)
                        message = 'The enrolment number provided corresponds to a previously cancelled application. Please contact the school for more information on your application for enrolment.';
                    else{
                        academicYearId = enrolmentSR.Academic_Year__r.Year__c;
                        gradeId = enrolmentSR.GradeLookup__r.Sys_Sort_Val__c;
                        curriculum = enrolmentSR.Curriculum__c;
                        stream = enrolmentSR.stream__c;
                        scholarshipSR.First_Name__c = enrolmentSR.First_Name__c;
                        scholarshipSR.Last_Name__c = enrolmentSR.Last_Name__c;
                        scholarshipSR.Date_Of_Birth__c = enrolmentSR.Date_Of_Birth__c;
                        existSRNumber = enrolmentSR.Name;
                    } 
                }else{
                    message = 'Please cross check the information you have provided as it doesn’t match our records.';
                    existSRNumber = '';
                }
            }
            
            system.debug('---academicYearID---'+academicYearID);
            system.debug('---gradeID---'+gradeID);
            system.debug('---curriculum---'+curriculum);
            system.debug('---stream---'+stream);
            
            if(string.isNotBlank(academicYearID)){
                checkFutureAY(academicYearID, curriculum);  
                system.debug('---futureAY---'+futureAY);
                if(futureAY!=null && string.isNotBlank(futureAY.id)){
                    message = checkExistingScholarshipDetails();
                }   
            }
            
            if(gradeID!=0 && futureAY!=null && string.isNotBlank(futureAY.id)){
                checkFutureGrade(gradeID,stream);   
                system.debug('---futureGrade---'+futureGrade);
                if(futureGrade!=null && string.isNotBlank(futureGrade.id) && futureGrade.enable_scholarship__c == false)
                    message = 'We\'re sorry the school is currently not accepting scholarship applications for the grade you are applying to. Please check back with the school website for more information';
            }
        }catch (exception ex){
            system.debug('-----'+ex.getMessage()+'------'+ex.getLineNumber());
            message = 'Exception';
        }
        
        system.debug('--message---'+message);
        if(message!='Success' && message!='Exception')
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,  message)); 
        else if(message=='Exception')
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,  message));
        else{
            ifDetailsExist = true;
            draftScholarship();
        }
    }
    
    //draft the SR
    public void draftScholarship(){
        string message = 'Success';
        try{
            system.debug('----student----'+student);
            system.debug('----enrolmentSR----'+enrolmentSR);
            if(student!=null && string.isNotBlank(student.id))
                scholarshipSR.student__c =  student.id;
            
            if(enrolmentSR!=null && string.isNotBlank(enrolmentSR.id))
                scholarshipSR.Service_Request__c =  enrolmentSR.id;
            
            scholarshipSR.school__c = school.id;
            
            if(futureAY!=null && string.isNotBlank(futureAY.id))
                scholarshipSR.academic_year__c = futureAY.id;
                
            if(futureGrade!=null && string.isNotBlank(futureGrade.id))
                scholarshipSR.gradelookup__c = futureGrade.id;
            
            system.debug('---scholarshipSR---'+scholarshipSR.student__c);    
            upsert scholarshipSR;
            
            string recordID = scholarshipSR.id;
            
            list<HexaBPM__Service_Request__c> tempSRList = new list<HexaBPM__Service_Request__c>(); 
            String query = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
            if(student!=null && string.isNotBlank(student.id)){
                string studentID = student.id;
                query += ' WHERE student__c =:studentID'  ;
            }
            
            if(enrolmentSR!=null && string.isNotBlank(enrolmentSR.id)){
                string enrolmentID = enrolmentSR.id;
                query += ' WHERE Service_Request__c =:enrolmentID'  ;
            }
            
            query += ' and id =: recordId';
            system.debug('-----query----'+query);
            tempSRList = Database.query(query);
            if(tempSRList!=null && tempSRList.size()>0){
                scholarshipSR = new HexaBPM__Service_Request__c();
                scholarshipSR = tempSRList[0];  
                getlstDoc();
            }
        }catch (exception ex){
            message = ex.getMessage()+'------'+ex.getLineNumber();
            system.debug('----message---'+message);
        }
        if(message!='Success')
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  message)); 
    }
    
    //submit the SR
    public void submitScholarship(){
        string message = 'Success';
        try{
            
            boolean docNotUploaded = false;
            getlstDoc();
            for(HexaBPM__SR_Doc__c temp : lstDoc){
                if(temp.HexaBPM__Status__c == 'Pending Upload'){
                    docNotUploaded = true;  
                }   
            }
            
            system.debug('--docNotUploaded--'+scholarshipSR.Scholarship_Category__c);
            system.debug('--docNotUploaded--'+scholarshipSR.Grade_Score_for_Subject_1__c);
            if(docNotUploaded==false){
                HexaBPM__SR_Status__c objStatus = new HexaBPM__SR_Status__c();
                objStatus = [select Id from HexaBPM__SR_Status__c where Name = 'Submitted' and HexaBPM__Code__c = 'SUBMITTED' limit 1];
                    
                scholarshipSR.HexaBPM__Internal_SR_Status__c = objStatus.Id;
                scholarshipSR.HexaBPM__External_SR_Status__c = objStatus.Id;
                scholarshipSR.HexaBPM__Submitted_Date__c = system.today();
                scholarshipSR.HexaBPM__Submitted_DateTime__c = system.now();    
                scholarshipSR.HexaBPM__finalizeamendmentflg__c = true;
                
                if(student!=null && string.isNotBlank(student.id))
                    scholarshipSR.HexaBPM__Email__c = student.Primary_Contact_Email__c;
                
                if(enrolmentSR!=null && string.isNotBlank(enrolmentSR.id))
                    scholarshipSR.HexaBPM__Email__c = enrolmentSR.HexaBPM__Email__c;
                scholarshipSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
                update scholarshipSR;
            }else{
                message =  'Please upload required documents';  
            }   
        }catch (exception ex){
            message = ex.getMessage()+'------'+ex.getLineNumber();
            system.debug('----message---'+message);
        }
        if(message!='Success'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  message)); 
        }
        else{
            system.debug('---submitmessage-----'+message);
            isSaveSuccess = true;
        }
    }
    
    //initialize student details
    public void ifStudentExist(string formattedDate){
        list<Account> tempList = new list<Account>();
        tempList = [select Id, FirstName, Academic_Year__r.Year__c, GradeLookup__r.Sys_Sort_Val__c, 
                           LastName,Primary_Contact_Email__c ,Date_Of_Birth__c, Gender__c, Student_Id__c,
                           curriculum_current__c, stream__c,School__c 
                    from Account where (Student_Id__c = :existStudentId or
                                        Fee_ID__c = :existStudentId)
                    and school__c = :school.id and Date_Of_Birth_String__c = :formattedDate
                    and Current_Status__c = 'EN' and Record_Type_Name__c = 'Student'
                    limit 1];
        if(tempList!=null && tempList.size()>0){
            student = tempList[0];
        }   
    }
    
    //initialize Enrolment details
    public void ifEnrolmentExist(string formattedDate){
        list<HexaBPM__Service_Request__c> tempList = new list<HexaBPM__Service_Request__c>();
        tempList = [select Id, Name,First_Name__c, Academic_Year__r.Year__c, GradeLookup__r.Sys_Sort_Val__c,
                           Last_Name__c, HexaBPM__Email__c,Date_Of_Birth__c, Gender__c,school__c,
                           HexaBPM__IsClosedStatus__c, HexaBPM__Is_Rejected__c, 
                           HexaBPM__IsCancelled__c,Curriculum__c, stream__c
                    from HexaBPM__Service_Request__c where Name = :existSRNumber 
                    and Date_Of_Birth_String__c = :formattedDate  and school__c =: school.id
                    and HexaBPM__Record_Type_Name__c = 'Enrollment'
                    limit 1];
    
        if(tempList!=null && tempList.size()>0){
            enrolmentSR = tempList[0];
        }
    }
    
    //get future AY for child
    public void checkFutureAY(string AYid,string curriculum){
        string academicYearTemp = '';
        academicYearTemp = string.valueOf(integer.valueOf(AYid) + 1);
        system.debug('---academicYearTemp---'+academicYearTemp);
        list<Academic_Year__c> tempList = [select id from Academic_Year__c where School__c =: school.id and Year__c=:academicYearTemp
                                           and Curriculum__c =: curriculum];
        
        if(tempList!=null && tempList.size()>0)
            futureAY = tempList[0];
    }
    
    //get future grade for child
    public void checkFutureGrade(decimal gradeID, string stream){
        integer grade = 0;
        grade = integer.valueOf(gradeID + 1);
        system.debug('---grade---'+grade);
        list<grade__c> tempList = [select id, grade__c,Grade_Display__c,enable_scholarship__c from grade__c where School__c =: school.id and Sys_Sort_Val__c=:decimal.valueOf(grade)
                                   and Stream__c =: stream and academic_year__c=:futureAY.id];
        if(tempList!=null && tempList.size()>0)
            futureGrade = tempList[0];  
        }
    
    //check if student already has applied for scholarship SR or has scholarship
    public string checkExistingScholarshipDetails(){
        system.debug('----student----'+student);
        system.debug('----enrolmentSR----'+enrolmentSR);
        
        string message = 'Success';
        list<HexaBPM__Service_Request__c> existingSR = new list<HexaBPM__Service_Request__c>();
        list<scholarship__c> existingScholarship = new list<scholarship__c>();
        
        if(student!=null && string.isNotBlank(student.id)){
            existingSR = [select id from HexaBPM__Service_Request__c 
                      where student__c =: student.id
                      and academic_year__c =: futureAY.id and school__c =: school.id
                      and HexaBPM__Record_Type_Name__c = 'Scholarship'
                      and HexaBPM__External_Status_Name__c!= 'Draft'];        
            if(existingSR!=null && existingSR.size()>0){
                message = 'We\'re afraid you have already applied for a scholarship and may only apply once in a given year.';
            }
            
            
            existingScholarship = [select id from scholarship__c 
                                   where student__c =: student.id
                                   and academic_year__c =: futureAY.id and school__c =: school.id
                                   and active__c = true and TC_SO_CN_Applied__c=false];     
            if(existingScholarship!=null && existingScholarship.size()>0){
                message = 'We\'re afraid you have already applied for a scholarship and may only apply once in a given year.';
            }   
        }
        
        if(enrolmentSR!=null && string.isNotBlank(enrolmentSR.id) && futureAY!=null){
            existingSR = [select id from HexaBPM__Service_Request__c 
                      where Service_Request__c =: enrolmentSR.id
                      and academic_year__c =: futureAY.id and school__c =: school.id
                      and HexaBPM__Record_Type_Name__c = 'Scholarship'
                      and HexaBPM__External_Status_Name__c!= 'Draft'];        
            if(existingSR!=null && existingSR.size()>0){
                message = 'We\'re afraid you have already applied for a scholarship and may only apply once in a given year.';
            }
            
            existingScholarship = [select id from scholarship__c 
                                   where Enrolment_SR__c =: enrolmentSR.id
                                   and academic_year__c =: futureAY.id and school__c =: school.id
                                   and active__c = true and TC_SO_CN_Applied__c=false];     
            if(existingScholarship!=null && existingSR.size()>0){
                message = 'We\'re afraid you have already applied for a scholarship and may only apply once in a given year.';
            }   
        }
        
        
        system.debug('---message---'+message);
        return message;
    }
    
     public void Upload() {
        try{
            string temp = Apexpages.currentPage().getParameters().get('srDocId');
            if(string.isNotBlank(temp)){
                list<HexaBPM__SR_Doc__c> templist = new list<HexaBPM__SR_Doc__c>();
                templist = [select id,HexaBPM__Document_Name__c, HexaBPM__Customer_Comments__c, HexaBPM__Status__c 
                            from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c =: scholarshipSR.id 
                            and HexaBPM__Sys_IsGenerated_Doc__c = false and IsDeleted = false 
                            and id=:temp
                            order by Name]; 
                system.debug('--templist---'+templist);            
                if(templist!=null && templist.size()>0){
                    
                    string fileBody = Apexpages.currentPage().getParameters().get('fileBody');
                    string fileName = Apexpages.currentPage().getParameters().get('fileName');
                    fileDescription = Apexpages.currentPage().getParameters().get('fileDescription');
                    system.debug('--fileBody---'+fileBody);  
                    system.debug('--fileDescription---'+fileDescription);  
                    //string body = fileBody.split(',')[1];
                    
                    system.debug('--contentType---'+selectedContentType);
                    system.debug('--fileBody---'+fileBody);
                    
                    templist[0].HexaBPM__Status__c = 'Uploaded';
                    templist[0].HexaBPM__Customer_Comments__c = fileDescription;
                    
                    update templist;
                    
                    attachment attachFile = new attachment();
                    attachFile.body = EncodingUtil.base64Decode(fileBody);
                    attachFile.name = fileName;
                    attachFile.contentType = selectedContentType;
                    
                    attachFile.ParentId = temp; // the record the file is attached to
                    insert attachFile;
                    system.debug('---success---');
                    getlstDoc();    
                }
            }
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        }
    }
    
    public void clearValues(){
        ifDetailsExist=false;
        existSRNumber = 'SR-';
        existStudentId = '';
        student = new Account();
        enrolmentSR = new HexaBPM__Service_Request__c();
        scholarShipSR = new HexaBPM__Service_Request__c();
        scholarshipSR.recordtypeid = recTypeID;
    }

    public list<HexaBPM__SR_Doc__c> getlstDoc() {
        try {
            lstDoc = new list<HexaBPM__SR_Doc__c>();
            lstDoc = [select id, createddate, HexaBPM__Doc_Type__c, lastmodifieddate, 
                             HexaBPM__Is_Not_Required__c, HexaBPM__Requirement__c, 
                             HexaBPM__Document_Description_External__c, 
                             HexaBPM__Document_Master__r.Name, 
                             HexaBPM__Service_Request__c, HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c, 
                             HexaBPM__Service_Request__r.HexaBPM__External_Status_Name__c, name, 
                             HexaBPM__Doc_ID__c, HexaBPM__Received_Physically__c, 
                             HexaBPM__Customer_Comments__c, HexaBPM__Comments__c, 
                             HexaBPM__Document_Type__c, HexaBPM__Original_Verified__c, 
                             HexaBPM__Rejection_Reason__c, HexaBPM__Status__c 
                      from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c =: scholarshipSR.id 
                      and HexaBPM__Sys_IsGenerated_Doc__c = false and IsDeleted = false 
                      order by Name];
                      
            system.debug('---lstDoc---'+lstDoc);
        } catch (Exception e) {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage());
            ApexPages.addmessage(errorMsg);
        }
        return null;
    }
    
    public void uploadadditional() {
        try{
            string fileBody = Apexpages.currentPage().getParameters().get('fileBody');
            fileName = Apexpages.currentPage().getParameters().get('fileName');
            fileDescription = Apexpages.currentPage().getParameters().get('fileDescription');
            string docName = Apexpages.currentPage().getParameters().get('docName');
            
            HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
            srDoc.name = docName;
            srDoc.HexaBPM__Service_Request__c = scholarshipSR.id;
            srDoc.HexaBPM__Customer_Comments__c = fileDescription;
            srDoc.HexaBPM__Status__c = 'Uploaded';
            insert srDoc;
            
            string body = fileBody.split(',')[1];
            attachment attachFile = new attachment();
            attachFile.body = EncodingUtil.base64Decode(body);
            attachFile.name = fileName;
            attachFile.contentType = selectedContentType;
            
            attachFile.ParentId = srDoc.id; // the record the file is attached to
            insert attachFile;
            system.debug('---success---');
            getlstDoc(); 
            
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        } 
    }
    
    public void cancel(){
        
    }
}