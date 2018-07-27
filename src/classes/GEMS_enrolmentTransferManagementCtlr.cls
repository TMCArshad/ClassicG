/*****************************************************************************************************************************
    Author      :   Swati sehrawat
    Description :   Enrolment transfer between schools
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    V1.0    Swati   8th Jan 2018    ticket:160953
    v2.0    Leeba   13 Jan 2018     ticket:176677  - populate curriculum

    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_enrolmentTransferManagementCtlr {
    public school__c objSchoolTransfer {get; set;}
    public school__c objSchoolCurrent {get; set;}
    string schoolId;
    
    public string selectedAYTransfer {get; set;}
    public string selectedAYCurrent {get; set;}
    
    public string selectedGradeTransfer {get; set;}
    public string selectedGradeCurrent {get; set;}
    
    public string selectedCurriculumTransfer {get; set;}
    public string selectedCurriculumCurrent {get; set;}
    
    public string selectedStreamTransfer {get; set;}
    public string selectedStreamCurrent {get; set;}
    
    public string selectedSchool {get; set;}
    public string searchStudentValue{get;set;}
    public string selectedStatus {get; set;}
    
    public boolean selectAll {get; set;}
    public boolean transferred {get; set;}
    public boolean breakJob {get; set;}
    public boolean performedSearch {get;set;}
    public boolean showStream {get; set;}
    public boolean showCurriculum {get; set;}
    public boolean isPartOfSchoolQueue {get; set;}
    
    public list<SelectOption> academicYearListTransfer {get; set;}
    public list<SelectOption> gradeListTransfer {get; set;}
    public list<SelectOption> streamListTransfer {get; set;}
    public list<SelectOption> curriculumListTransfer {get; set;}
    
    public list<SelectOption> academicYearListCurrent {get; set;}
    public list<SelectOption> gradeListCurrent {get; set;}
    public list<SelectOption> streamListCurrent {get; set;}
    public list<SelectOption> curriculumListCurrent {get; set;}
    
    public list<SelectOption> schoolList {get; set;}
    
    public list<studentWrapper> studentWrapperList {get; set;}
    
    Id batchId;
    
    public GEMS_enrolmentTransferManagementCtlr() {
       try{
            schoolId = apexpages.currentPage().getparameters().get('schoolId');
            if(string.isNotBlank(schoolId)){
                initiateValues();
                
                getCurrentSchool();
                isPartOfSchoolQueue = isPartOfSchoolQueue();
                getTransferSchool();
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    }
    
    public void initiateValues(){
        selectAll = false;
        transferred =  false;  
        breakJob = false;  
        showStream = false;
        showCurriculum = false;
        isPartOfSchoolQueue = false;
        
        academicYearListCurrent = new list<SelectOption>();
        gradeListCurrent = new list<SelectOption>();
        streamListCurrent = new list<SelectOption>();
        curriculumListCurrent = new list<SelectOption>();
        
        academicYearListTransfer = new list<SelectOption>();
        gradeListTransfer = new list<SelectOption>();
        streamListTransfer = new list<SelectOption>();
        curriculumListTransfer = new list<SelectOption>();
        
        studentWrapperList = new list<studentWrapper>();
        
        schoolList = new list<SelectOption>();
        performedSearch = false;
        
        searchStudentValue = '';
        
        selectedAYTransfer = '';
        selectedAYCurrent = '';
        
        selectedGradeTransfer = '';
        selectedGradeCurrent = '';
        
        selectedStreamTransfer = '';
        selectedStreamCurrent = '';
        
        selectedSchool = '';
        
        selectedStatus = '';
    }

/*************************************Current School********************************************************************/    
    public void getCurrentSchool(){
        list<school__c> tempSchoolList = [select id,id__c, short_name__c,name, logo__C from school__c where id=:schoolId];
        if(tempSchoolList!=null && tempSchoolList.size()>0){
            objSchoolCurrent = tempSchoolList[0];   
        }
        getAYCurrent();
    }
    
    public void getAYCurrent(){
        academicYearListCurrent = new list<selectOption>();
        academicYearListCurrent = GEMS_Utility.getAcademicYearsForSchool(objSchoolCurrent.id__c, NULL);
        if(academicYearListCurrent!=null && academicYearListCurrent.size()>0){
            selectedAYCurrent = academicYearListCurrent[0].getValue();
        }else{
            selectedAYCurrent = '';
            academicYearListCurrent.add(new SelectOption('', '--None--'));
        }
        
        getCurriculumCurrent();
    }
    
    public void getCurriculumCurrent(){
        
        list<Academic_year__c> tempList = [Select Year__c from Academic_year__c where Id = :selectedAYCurrent AND Year__c != NULL];
        Academic_year__c ay = new Academic_year__c ();
        if(!tempList.isEmpty()){
            ay = tempList[0];
        }
            
        curriculumListCurrent = new list<selectOption>();
        curriculumListCurrent = GEMS_Utility.getCurriculumsForSchool(objSchoolCurrent.id__c, ay.year__c);
        if(curriculumListCurrent!=null && curriculumListCurrent.size()>0){
            selectedCurriculumCurrent = curriculumListCurrent[0].getValue();
        }else{
            selectedCurriculumCurrent = '';
            curriculumListCurrent.add(new SelectOption('', '--None--'));
        }
        
        if(curriculumListCurrent!=null && curriculumListCurrent.size()>1)
            showCurriculum = true;
        
        getGradesCurrent();
        
        system.debug('---selectedCurriculumCurrent---'+selectedCurriculumCurrent);
        system.debug('---curriculumListCurrent---'+curriculumListCurrent);
    }
    
    public void getGradesCurrent(){
        gradeListCurrent = new list<selectOption>();
        gradeListCurrent = GEMS_Utility.getGradesForSchool(objSchoolCurrent.id__c, getLookupValue(selectedAYCurrent,academicYearListCurrent), selectedCurriculumCurrent);
        if(gradeListCurrent!=null && gradeListCurrent.size()>0){
            selectedGradeCurrent = gradeListCurrent[0].getValue();
        }else{
            selectedGradeCurrent = '';
            gradeListCurrent.add(new SelectOption('', '--None--'));
        }
        
        system.debug('---selectedGradeCurrent---'+selectedGradeCurrent);
        system.debug('---gradeListCurrent---'+gradeListCurrent);
        getStreamscurrent();
    }
    
    public void getStreamscurrent(){
        streamListCurrent = new list<selectOption>();
        string AYLabel = getLookupValue(selectedAYCurrent,academicYearListCurrent);
        Academic_year__c ay = new Academic_year__c ();
        ay = GEMS_Utility.getAcademicYearID(objSchoolCurrent.id,AYLabel,selectedCurriculumCurrent);
        
        if(ay!=null)
            streamListCurrent = GEMS_Utility.getStreamsForSchool(objSchoolCurrent.id__c, Ay.id, getLookupValue(selectedGradeCurrent,gradeListCurrent));
        
        if(streamListCurrent!=null && streamListCurrent.size()>0){
            selectedStreamCurrent = streamListCurrent[0].getValue();
            
        }else{
            selectedStreamCurrent = '';
            streamListCurrent.add(new SelectOption('', '--None--'));
        }
        
        if(streamListCurrent!=null && streamListCurrent.size()>1)
            showStream = true;
            
        system.debug('---selectedStreamCurrent---'+selectedStreamCurrent);
        system.debug('---streamListCurrent---'+streamListCurrent);
    }
    
/******************************************Transfer School*****************************************************************/
    public void getTransferSchool(){
        schoolList.add(new SelectOption('', '--None--'));
        academicYearListTransfer.add(new SelectOption('', '--None--'));
        gradeListTransfer.add(new SelectOption('', '--None--'));
        StreamListTransfer.add(new SelectOption('', '--None--'));
        curriculumListTransfer.add(new SelectOption('', '--None--'));
        
        for (School__c school : [SELECT id,short_name__c, Name FROM School__c where id!=: objSchoolCurrent.id ORDER BY Name]) {
        //Both name and Value is school name because Transfer school is saved as text on Lead
            schoolList.add(new SelectOption(school.id, school.Name));
        }
        
        selectedSchool = (schoolList.size() > 0) ? schoolList[0].getValue() : NULL;
    }
    
    public void getTransferSchoolSelected(){
        for (School__c school : [SELECT id,short_name__c, Name FROM School__c where id!=: objSchoolCurrent.id ORDER BY Name]) {
        //Both name and Value is school name because Transfer school is saved as text on Lead
            schoolList.add(new SelectOption(school.id, school.Name));
        }
        
        if(string.isNotBlank(selectedSchool)){
            list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:selectedSchool];
            if(tempSchoolList!=null && tempSchoolList.size()>0){
                objSchoolTransfer = tempSchoolList[0];  
            }
            getAYTransfer();
        } 
    }
    
    public void getAYTransfer(){
        academicYearListTransfer = new list<selectOption>();
        academicYearListTransfer = GEMS_Utility.getAcademicYearsForSchool(objSchoolTransfer.id__c, NULL);
        if(academicYearListTransfer!=null && academicYearListTransfer.size()>0){
            selectedAYTransfer = academicYearListTransfer[0].getValue();
        }else{
            selectedAYTransfer = '';
            academicYearListTransfer.add(new SelectOption('', '--None--'));
        }
        
        getCurriculumTransfer();
        system.debug('---selectedAYTransfer---'+selectedAYTransfer);
        system.debug('---academicYearListTransfer---'+academicYearListTransfer);
    }
    
    public void getCurriculumTransfer(){
        
        list<Academic_year__c> tempList = [Select Year__c from Academic_year__c where Id = :selectedAYTransfer AND Year__c != NULL];
        Academic_year__c ay = new Academic_year__c ();
        if(!tempList.isEmpty()){
            ay = tempList[0];
        }
        
        curriculumListTransfer = new list<selectOption>();
        curriculumListTransfer = GEMS_Utility.getCurriculumsForSchool(objSchoolTransfer.id__c, ay.year__c);
        if(curriculumListTransfer!=null && curriculumListTransfer.size()>0){
            selectedCurriculumTransfer = curriculumListTransfer[0].getValue();
        }else{
            selectedCurriculumTransfer = '';
            curriculumListTransfer.add(new SelectOption('', '--None--'));
        }
        
        if(curriculumListTransfer!=null && curriculumListTransfer.size()>1)
            showCurriculum = true;
            
        system.debug('---selectedCurriculumTransfer---'+selectedCurriculumTransfer);
        system.debug('---curriculumListTransfer---'+curriculumListTransfer);
        getGradesTransfer();
    }
    
    public void getGradesTransfer(){
        gradeListTransfer = new list<selectOption>();
        gradeListTransfer = GEMS_Utility.getGradesForSchool(objSchoolTransfer.id__c, getLookupValue(selectedAYTransfer,academicYearListTransfer), selectedCurriculumTransfer);
        if(gradeListTransfer!=null && gradeListTransfer.size()>0){
            selectedGradeTransfer = gradeListTransfer[0].getValue();
        }else{
            selectedGradeTransfer = '';
            gradeListTransfer.add(new SelectOption('', '--None--'));
        }
        
        system.debug('---selectedGradeTransfer---'+selectedGradeTransfer);
        system.debug('---gradeListTransfer---'+gradeListTransfer);
        getStreamsTransfer();
    }
    
    public void getStreamsTransfer(){
        streamListTransfer = new list<selectOption>();
        
        string AYLabel = getLookupValue(selectedAYTransfer,academicYearListTransfer);
        Academic_year__c ay = new Academic_year__c ();
        ay = GEMS_Utility.getAcademicYearID(objSchoolTransfer.id,AYLabel,selectedCurriculumTransfer);
        
        if(ay!=null)
            streamListTransfer = GEMS_Utility.getStreamsForSchool(objSchoolTransfer.id__c, ay.id, getLookupValue(selectedGradeTransfer,gradeListTransfer));
        
        if(streamListTransfer!=null && streamListTransfer.size()>0){
            selectedStreamTransfer = streamListTransfer[0].getValue();
        }else{
            selectedStreamTransfer = '';
            streamListTransfer.add(new SelectOption('', '--None--'));
        }
        
        if(streamListTransfer!=null && streamListTransfer.size()>1)
            showStream = true;
            
        system.debug('---selectedStreamTransfer---'+selectedStreamTransfer);
        system.debug('---streamListTransfer---'+streamListTransfer);
    }
    
/*******************************************Get Existing Students***************************************************************/    
    public void getExistingStudents(){
        try{
            searchStudentValue = '';
            if(transferred==true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'SR raised successfully.'));    
            }
            transferred=false;  
            
            string Enrollment = 'Enrollment';
            string Enrolled = 'Enrolled';
            string  ApplicationTransferred =    'Application Transferred';
            string currentId = objSchoolCurrent.id;
            studentWrapperList = new list<studentWrapper>();
            list<HexaBPM__Service_Request__c> tempList = new list<HexaBPM__Service_Request__c>();
            String query = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
            query += ' where academic_year__c=:selectedAYCurrent and GradeLookup__c=:selectedGradeCurrent'+
                     ' and Stream__c=:selectedStreamCurrent and school__c=:currentId'+
                     ' and HexaBPM__Record_Type_Name__c=:Enrollment and ( HexaBPM__External_Status_Name__c !=: Enrolled and HexaBPM__External_Status_Name__c!=:ApplicationTransferred) order by HexaBPM__External_Status_Name__c DESC LIMIT 100 '  ;
            tempList = Database.query(query);
            
            system.debug('--tempList--'+tempList.size());
            if(tempList!=null && tempList.size()>0){
                for(HexaBPM__Service_Request__c obj : tempList){
                    studentWrapper objStud = new studentWrapper(obj);
                    objStud.objSR = obj;
                    studentWrapperList.add(objStud);
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No application exist. Please refine your search criteria.'));  
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }

    }
    
    public void searchStudents(){
        if(string.isNotBlank(searchStudentValue)){
            studentWrapperList = new list<studentWrapper>();
            list<HexaBPM__Service_Request__c> studentSearchList = new list<HexaBPM__Service_Request__c>();
            list<HexaBPM__Service_Request__c> studentList = new list<HexaBPM__Service_Request__c>();
            string tempSearchTerm = '("' + searchStudentValue + '")';
            studentSearchList = (List<HexaBPM__Service_Request__c>)[FIND : tempSearchTerm IN All Fields RETURNING HexaBPM__Service_Request__c(id)][0];
            
            if(studentSearchList!=null && studentSearchList.size()>0){
                string Enrollment = 'Enrollment';
                string Submitted = 'Submitted';
                string Registered = 'Registered';
                string currentId = objSchoolCurrent.id;
                studentWrapperList = new list<studentWrapper>();
                
                list<HexaBPM__Service_Request__c> tempList = new list<HexaBPM__Service_Request__c>();
                String query = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
                query += ' where academic_year__c=:selectedAYCurrent and GradeLookup__c=:selectedGradeCurrent'+
                         ' and Stream__c=:selectedStreamCurrent and school__c=:currentId and ID IN : studentSearchList'+
                         ' and HexaBPM__Record_Type_Name__c=:Enrollment and ( HexaBPM__External_Status_Name__c =: Submitted or HexaBPM__External_Status_Name__c =: Registered) order by HexaBPM__External_Status_Name__c DESC LIMIT 50 '  ;
                tempList = Database.query(query);
                
                system.debug('--tempList--'+tempList.size());
                if(tempList!=null && tempList.size()>0){
                    for(HexaBPM__Service_Request__c obj : tempList){
                        studentWrapper objStud = new studentWrapper(obj);
                        objStud.objSR = obj;
                        studentWrapperList.add(objStud);
                    }
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No application exist. Please refine your search criteria.'));  
                }       
            }
        }
    }
    
    public void clearSearch(){
        searchStudentValue = '';
        getExistingStudents();
    }
    
/*****************************************Save Transfer Requests*****************************************************************/    

    public void transferRequest(){
        Savepoint spdata = Database.setSavepoint();
        try{
            if(string.isBlank(selectedSchool) || string.isBlank(selectedAYCurrent) ||
               string.isBlank(selectedGradeCurrent) || string.isBlank(selectedStreamCurrent)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please provide all required values.'));   
            }else{
                map<id, school__c> schoolMap = new map<id, school__c>();
                for (school__c school : [select id, logo__c, Finance_Officer_Email__c,Short_Name__c,
                                         Lab_Email__c, Library_Email__c, Principals_PA_Email__c,
                                         Registrar_Email__c, STS_Email__c, Principal__r.Email__c,generic_email_address__c
                                         from school__c
                                         where id =: selectedSchool]){
                    schoolMap.put(school.id, school);
                }
                
                map<string, id> mapOfQueueAndId = new map<string, id>();
                GEMS_Queue_Config__c customSettingsForQueue = GEMS_Queue_Config__c.getValues(schoolMap.get(selectedSchool).Short_Name__c+'-Registrar');                
                map<string, string> mapOfSchoolAndQueue = new map<string, string>();
                mapOfSchoolAndQueue.put(customSettingsForQueue.School_Code__c, customSettingsForQueue.Queue_Name__c);
                for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue' and DeveloperName = :mapOfSchoolAndQueue.values()]) {
                  mapOfQueueAndId.put(grp.DeveloperName, grp.id);
                }
        
                list<HexaBPM__Service_Request__c> srList = new list<HexaBPM__Service_Request__c>();
                if(studentWrapperList!=null && studentWrapperList.size()>0){
                    
                    for(studentWrapper obj : studentWrapperList){
                        if(obj.selectRecord == true){
                            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                            objSR = obj.objSR.clone(false,false,false,false);
                            objSR.HexaBPM__Customer__c = obj.objSR.HexaBPM__Customer__c;
                            objSR.student__c = obj.objSR.student__c;
                            objSR.school__c = objSchoolTransfer.id;
                            objSR.Academic_Year__c = selectedAYTransfer;
                            objSR.Stream__c = selectedStreamTransfer;   
                            objSR.GradeLookup__c = selectedGradeTransfer;
                            objSR.HexaBPM__Linked_SR__c = obj.objSR.id;
                            objSR.Transferred_School__c = objSchoolCurrent.id;
                            objSR.StudentId__c = '';
                            objSR.Sibling_Fee_ID__c = '';
                            objSR.Complete_File_URL__c = '';
                            objSR.Enrollment_Offer_URL__c = '';
                            objSR.GEMS_URL__c = '';
                            objSR.Enquiry_Id_Oasis__c = '';
                            objSR.sys_Assessment_Fees_Paid__c = false;
                            objSR.sys_Edit_Critical_details_Rejected__c = false;
                            objSR.Enquiry_from_Oasis__c = false;
                            objSR.Oasis_Current_Status__c = '';
                            objSR.sys_Send_Enquiry_Parent_Details__c = false;
                            objSR.sys_Registration_Fees_Paid__c = false;
                            objSR.Update_SR_Status_to_Assessment__c = false;
                            objSR.Update_status_to_registered__c = false;
                            objSR.Reason_for_enquiry_transfer__c = obj.transferReason;
                            objSR.Registration_Type__c = 'Current';
                            objSR.Oasis_Current_Status__c = '';
                            objSR.payment_status__c = 'No Payment';
                            objSR.lead__c = null;
                            objSR.enquiry__c = null;
                            objSR.Offer_Fee_Conditions__c = '';
                            objSR.School_Logo__c = schoolMap.get(objSR.school__c).logo__c;
                            objSR.Sys_Finance_Officer_Email__c = schoolMap.get(objSR.school__c).Finance_Officer_Email__c;
                            objSR.Sys_Lab_Email__c = schoolMap.get(objSR.school__c).Lab_Email__c;
                            objSR.Sys_Library_Email__c = schoolMap.get(objSR.school__c).Library_Email__c;
                            objSR.Sys_Principals_PA_Email__c = schoolMap.get(objSR.school__c).Principals_PA_Email__c;
                            objSR.Sys_Registrar_Email__c = schoolMap.get(objSR.school__c).Registrar_Email__c;
                            objSR.Sys_STS_Email__c = schoolMap.get(objSR.school__c).STS_Email__c;
                            objSR.Sys_Principal_Email__c = schoolMap.get(objSR.school__c).Principal__r.Email__c;
                            
                            //V1.0
                            objSR.generic_email_address__c = schoolMap.get(objSR.school__c).generic_email_address__c;
                            
                            objSR.OwnerId = mapOfQueueAndId.get(mapOfSchoolAndQueue.get(schoolMap.get(selectedSchool).Short_Name__c));
                            
                            //v2.0
                            objSR.Curriculum__c = selectedCurriculumTransfer ;
            
                            if(isPartOfSchoolQueue==false){
                                objSR.Enrolment_Transferred__c = true;
                            }
                            srList.add(objSR);
                            system.debug('---srList---'+srList);
                        }
                    }
                }
                
                if(srList!=null && srList.size()>0){
                    GEMS_interUnitStudentTransferBatch batchJob = new GEMS_interUnitStudentTransferBatch(srList,selectedStatus, 'Enrollment') ;
                    batchId = Database.executeBatch(batchJob,1);
                    transferred = true;
                    selectAll = false;
                    getExistingStudents();
                }
           }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
            Database.rollback(spdata);
        }
    }
    
/******************************************************************************************************/    
    public String getLookupValue(string key, list<selectOption> gradeList){
        String retStr;
        for(SelectOption  so :  gradeList){
            if(so.getValue().equalsIgnoreCase(key)){
                retStr = so.getLabel();
            }
        }
        return retStr;
    }
    
    public class studentWrapper{
        public boolean selectRecord {get; set;}
        public HexaBPM__Service_Request__c objSR {get;set;}
        public string transferReason {get; set;}
        
        public studentWrapper(HexaBPM__Service_Request__c objSR){
            objSR = new HexaBPM__Service_Request__c();
            selectRecord = false;
            transferReason = '';
        }
    }
    
    public boolean isPartOfSchoolQueue(){
        GEMS_Queue_Config__c customSettingsForQueue = GEMS_Queue_Config__c.getInstance(objSchoolCurrent.short_name__c+'-Registrar');
        set<id> groupMemberSet = new set<id>();
        if(customSettingsForQueue!=null && string.isNotBlank(customSettingsForQueue.Queue_Name__c)){
            for(Group grp : [Select Id,(select UserOrGroupId from GroupMembers),Name,DeveloperName from Group where type = 'Queue' and DeveloperName = :customSettingsForQueue.Queue_Name__c]){
                for(GroupMember obj : grp.GroupMembers){
                    groupMemberSet.add(obj.UserOrGroupId);
                }
            }
        }
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        if(profileName.equals('System Administrator') || (groupMemberSet!=null && groupMemberSet.contains(userInfo.getUserId()))){
            return true;    
        }
        return false;
    }
}