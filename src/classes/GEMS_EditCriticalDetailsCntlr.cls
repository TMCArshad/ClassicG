/************************************************************************************
* Name               : GEMS_EditCriticalDetailsCntlr                                                               *
* Description        : Implements logic for Edit Critical data functionality                                       *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Keerthan         16/02/2017
* 1.1         Leeba         11/1/2018 - populate the remarks entered in Comments field
* 1.2         Leeba       04/Mar/2018 added logic to auto populate TO Curriculam with From Curriculum 
                                      & prepared the To Grades according to that.
* 1.3         Leeba       19/Mar/2018 clearing the students search on change of the From options.
* 1.4         Leeba       25/Mar/2018 adding the condition that section cannot be changed in Edit critical if same DOJ selected
                                      adding condition that edit critical cannot be chnaged if no change in the values
* 1.5          Leeba      25/Mar/2018  check if the student's DOJ is between the student's current academic year start date and End date
* 1.6          Leeba      10/April/2018 allow change of stream if the student's DOJ is not between the student's current academic year start date and End Date
* 1.7          Leeba      12/April/2018 as reported by GEMS IT incase of multiple streams of Student search does not work with student ID
* 1.8          Leeba      12/April/2018 Incase of two curriculums to throw the proper DOJ error
* 1.9         Leeba       8/May/2018    In Search student method query did not have Date of Joining.
**************************************************************************************************/
public without sharing class GEMS_EditCriticalDetailsCntlr {
    
    public string BSUID {get; set;}
    public string remarks {get; set;}
    public string selectedFromAcademicYear {get; set;}
    public string selectedFromCurriculum {get; set;}
    public string selectedFromGrade {get; set;}
    public string selectedFromStream {get; set;}
    public string selectedFromSection {get; set;}
    public string selectedToAcademicYear {get; set;}
    public string selectedToCurriculum {get; set;}
    public string selectedToGrade {get; set;}
    public string selectedToStream {get; set;}
    public string selectedToSection {get; set;}
    public string searchStudentValue {get; set;}
    public string GradeToLabel{get;set;} //1.6
    public string GradeFromLabel{get;set;}//1.6
    
    public list<SelectOption> academicYearFromList { get; set; }
    public list<SelectOption> curriculumFromList { get; set; }
    public list<SelectOption> gradeFromList { get; set; }
    public list<Selectoption> streamFromList { get; set; }
    public list<Selectoption> sectionFromList { get; set; }
    public list<SelectOption> curriculumToList { get; set; }
    public list<SelectOption> gradeToList { get; set; }
    public list<Selectoption> streamToList { get; set; }
    public list<Selectoption> sectionToList { get; set; }

    public list<Account> studentList {get; set;}
    
    //1.3
    public Paginate paginater {get;set;}
    public list<studentWrapper> studentWrapperList{get;set;}
    public list<list<studentWrapper>> fullstudentWrapperList{get;set;}
    
    public School__c school {get; set;}
    public Date DOJ {get; set;}
    public HexaBPM__Service_Request__c objSR {get; set;}
    
    /**
     * [GEMS_EditCriticalDetailsCntlr - Contructor logic]
     * @return [description]
     */
    public GEMS_EditCriticalDetailsCntlr() {
        
        BSUID = ApexPages.CurrentPage().getParameters().get('BSU');
        
        academicYearFromList = new list<SelectOption>();
        curriculumFromList = new list<Selectoption>();
        gradeFromList = new list<SelectOption>();
        streamFromList = new list<SelectOption>();
        sectionFromList = new list<SelectOption>();
        curriculumToList = new list<Selectoption>();
        gradeToList = new list<SelectOption>();
        streamToList = new list<SelectOption>();
        sectionToList = new list<SelectOption>();

        studentList = new list<Account>();
        studentWrapperList = new list<studentWrapper>();

        objSR = new HexaBPM__Service_Request__c();
        school = new School__c();
        searchStudentValue = '';

        if (string.isNotBlank(BSUID))
            init();
    }
    
    //Set all picklist entries (To,From)
    public void init() {
        try{
              school = GEMS_Utility.getSchool(BSUID);
              getAcademicYearsForSchool();
        }catch(exception e){
          system.debug('-----'+e.getLineNumber());
        }
    }
    
    /**
     * [getAllStudents -Builds table of students matching the filter criteria]
     */
    public PageReference getAllStudents() {

        Section_Master__c smObj = getSectionInfo(selectedFromSection);
        studentWrapperList.clear();
        searchStudentValue = '';
        if (selectedFromAcademicYear == NULL || selectedFromGrade == '' || selectedFromStream == '' || selectedFromSection == '') {
            GEMS_Utility.addPageError('Please select at least one filter criteria.');
            return NULL;
        }

        map<Id, HexaBPM__Service_Request__c>accToSrMap = new map<Id, HexaBPM__Service_Request__c>();
        studentList.clear();

        //Open TC
        for (HexaBPM__Service_Request__c SR : [SELECT Id, Student__c, Name, HexaBPM__External_Status_Name__c, HexaBPM__Record_Type_Name__c, HexaBPM__External_SR_Status__r.SR_Closed_Status__c from HexaBPM__Service_Request__c WHERE HexaBPM__External_SR_Status__r.SR_Closed_Status__c != true AND HexaBPM__Record_Type_Name__c = : GEMS_Constants.SRRT_TCREQUEST ] ) {
            accToSrMap.put(SR.Student__c, SR);
        }

        //Open Edit Critical Details
        for (HexaBPM__Service_Request__c SR : [SELECT Id, Student__c, HexaBPM__External_Status_Name__c, HexaBPM__Record_Type_Name__c, HexaBPM__External_SR_Status__r.SR_Closed_Status__c from HexaBPM__Service_Request__c WHERE HexaBPM__External_SR_Status__r.SR_Closed_Status__c != true AND HexaBPM__Record_Type_Name__c = : 'Edit_Critical_Data' ] ) {
            accToSrMap.put(SR.Student__c, SR);
        }

        String AY =  smObj.Grade__r.Academic_year__c;
        String Grade = smObj.Grade__c;
        String Stream = smObj.Grade__r.Stream__c;

        String studentQueryStr = '';
        studentQueryStr += GEMS_Utility.getAllFields(Account.getSobjectType().getDescribe());
        studentQueryStr = studentQueryStr.replace('FROM Account', ',Academic_Year__r.ACD_ID__c,School__r.ID__c FROM Account ');
        studentQueryStr += ' WHERE isPersonAccount = true AND School__r.ID__c =: BSUID' ;
        studentQueryStr += ' AND Academic_Year__c =: AY' ;
        studentQueryStr += ' AND GradeLookup__c =: Grade';
        studentQueryStr += ' AND Stream__c =: Stream';
        studentQueryStr += ' AND Section__c =: selectedFromSection';
        studentQueryStr += ' AND Current_Status__c = \'EN\'';
        
        list<Account> tempStudentList = new list<Account>();    
        tempStudentList = Database.query(studentQueryStr);
        
        //1.3 Start
        Integer pageSize = integer.valueOf(System.Label.Pagination_Size);
        this.paginater = new Paginate(tempStudentList.size(), pageSize);
        
        studentWrapperList = new list<studentWrapper>();
        fullstudentWrapperList = new list<list<studentWrapper>>();
        
        list<studentWrapper> tempCC = new list<studentWrapper>();
        Integer j = 0;
        
        
        if(tempStudentList!=null && tempStudentList.size()>0){
            for (Account accObj : tempStudentList) {
                if (!accToSrMap.containsKey(accObj.Id)) {
                    tempCC.add(new studentWrapper(accObj));
                    j++;
                    if(j == pageSize){
                        this.fullstudentWrapperList.add(tempCC);
                        tempCC = new list<studentWrapper>();
                        j = 0;
                    }
                }
            }
            if(!tempCC.isEmpty()){
                this.fullstudentWrapperList.add(tempCC);
            }
            //Gets the correct list of data to show on the page
            this.studentWrapperList = this.fullstudentWrapperList.get(this.paginater.index);   
        }//1.3 End
        return NULL;
    }
    
    /**
     * [getSectionInfo Return section master record for a given section Id]
     * @param  secId [Id of Section Master]
     * @return       [Section master record]
     */
    public static Section_Master__c getSectionInfo(Id secId) {
        Section_Master__c sm = new Section_Master__c();
        for (Section_Master__c smObj : [SELECT Academic_Year__c, Grade__c, Grade__r.Academic_year__c, Grade__r.Stream__c, Academic_Year__r.Curriculum__c FROM Section_Master__c WHere Id = :secId]) {
            sm = smObj;
        }
        return sm;
    }

    /**
     * [searchStudents - Implements logic to search students in the table ]
     */
    public void searchStudents() {
        if (string.isNotBlank(searchStudentValue)) {
            studentWrapperList = new list<studentWrapper>();
            fullstudentWrapperList = new list<list<studentWrapper>>();
            
            list<Account> tempStudentList = new list<Account>();
            string tempSearchTerm = '("' + searchStudentValue + '")';
            tempStudentList =   (list<Account>)[FIND : tempSearchTerm IN All Fields RETURNING Account
                                            (id, school__r.id__c, student_id__c, Name, firstName, lastName,
                                             Academic_Year__c, GradeLookup__c, Grade_Display__c, Section_Display__c ,
                                             Section__c, Stream__c, gender__c, Current_Status__c, school__c)][0];
            if (tempStudentList != null && tempStudentList.size() > 0) {

                Map<Id, HexaBPM__Service_Request__c>accToSrMap = new Map<Id, HexaBPM__Service_Request__c>();
                //Open TC and Open Edit Critical Details
                for (HexaBPM__Service_Request__c SR : [SELECT Id, Student__c, Name, 
                                                              HexaBPM__External_Status_Name__c, 
                                                              HexaBPM__Record_Type_Name__c, HexaBPM__External_SR_Status__r.SR_Closed_Status__c 
                                                       from HexaBPM__Service_Request__c 
                                                       WHERE HexaBPM__External_SR_Status__r.SR_Closed_Status__c != true 
                                                       AND (HexaBPM__Record_Type_Name__c = : GEMS_Constants.SRRT_TCREQUEST 
                                                            OR HexaBPM__Record_Type_Name__c = : 'Edit_Critical_Data')] ) {
                    accToSrMap.put(SR.Student__c, SR);
                }

                //1.3 Start
                Integer pageSize = integer.valueOf(System.Label.Pagination_Size);
                this.paginater = new Paginate(tempStudentList.size(), pageSize);
                
                studentWrapperList = new list<studentWrapper>();
                fullstudentWrapperList = new list<list<studentWrapper>>();
                
                list<studentWrapper> tempCC = new list<studentWrapper>();
                Integer j = 0;
                
                for (Account obj : tempStudentList) {
                    if (obj.academic_year__c == selectedFromAcademicYear && obj.GradeLookup__c == selectedFromGrade &&
                        obj.Stream__c == selectedFromStream && obj.school__r.id__c == BSUID && obj.Current_Status__c == 'EN' && !accToSrMap.containsKey(obj.Id)) {

                        tempCC.add(new studentWrapper(obj));
                        j++;
                        if(j == pageSize){
                            this.fullstudentWrapperList.add(tempCC);
                            tempCC = new list<studentWrapper>();
                            j = 0;
                        }
                    }
                }
                if(!tempCC.isEmpty()){
                    this.fullstudentWrapperList.add(tempCC);
                }
                //Gets the correct list of data to show on the page
                this.studentWrapperList = this.fullstudentWrapperList.get(this.paginater.index);   
            }   
            if (studentWrapperList != null && studentWrapperList.size() > 0) {

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria'));
            }
        }
    }
    
    /**
     * [clearSearch - Clear search term]
     */
    public void clearSearch() {
        searchStudentValue = '';
        getAllStudents();
    }
    
    public void FromSectionChange(){
        studentWrapperList = new list<studentWrapper>();//v1.3 Added to hide the search section on change
    }
    
    /**
     * [getAcademicYearsForSchool -Prepare from academic year picklist]
     */
    public void getAcademicYearsForSchool() {
        academicYearFromList.clear();
        academicYearFromList.add(new SelectOption('', '--None--'));
        academicYearFromList.addAll(GEMS_Utility.getAcademicYearsForSchool(BSUID, NULL));

        selectedFromAcademicYear =  (academicYearFromList.size() > 0) ? academicYearFromList[1].getValue() : NULL;
        selectedToAcademicYear =  (academicYearFromList.size() > 0) ? academicYearFromList[1].getValue() : NULL;
  
        getCurriculumsForSchool();
        getToCurriculumsForSchool();
    }
    
    /**
     * [getGradesforSchool - Prepare From Grade picklist]
     */
    public void getGradesforSchool() {
        try {
            
            gradeFromList.clear();
            streamFromList.clear();
            studentWrapperList = new list<studentWrapper>();//v1.3 Added to hide the search section on change
            gradeFromList.add(new SelectOption('', '--None--'));
            if (selectedFromAcademicYear != NULL)
                gradeFromList.addAll(GEMS_Utility.getGradesForSchool(BSUID, getLookupValue(selectedFromAcademicYear, academicYearFromList), selectedFromCurriculum));
            
            getStreamsForSchool();
            selectedFromStream = (streamFromList.size() > 0 ) ? streamFromList[0].getValue() :  NULL;
            selectedToCurriculum = selectedFromCurriculum;//1.2
            
            getToGradesForSchool();//1.2
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getToGradesforSchool -Prepare to grades picklist]
     */
    public void getToGradesforSchool() {
        try {
            gradeToList.clear();
            streamToList.clear();
            gradeToList.add(new SelectOption('', '--None--'));
            if (selectedToAcademicYear != NULL)
                gradeToList.addAll(GEMS_Utility.getGradesForSchool(BSUID, getLookupValue(selectedToAcademicYear, academicYearFromList), selectedToCurriculum));
            
            getToStreamsForSchool();
            selectedToStream = (streamToList.size() > 0 ) ? streamToList[0].getValue() :  NULL;
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getStreamsForSchool -Prepare from Stream picklist]
     */
    public void getStreamsForSchool() {
        try {
            selectedFromStream = NULL;
            streamFromList.clear();
            sectionFromList.clear();
            studentWrapperList = new list<studentWrapper>();//v1.3 Added to hide the search section on change
            sectionFromList.add(new SelectOption('', '--None--'));
            
            if (!String.isBlank(selectedFromGrade) && !String.isBlank(selectedFromAcademicYear)) {
                string AYLabel = getLookupValue(selectedFromAcademicYear,academicYearFromList);
                Academic_year__c ay = new Academic_year__c ();
                ay = GEMS_Utility.getAcademicYearID(school.id,AYLabel,selectedFromCurriculum);
                if(ay!=null)
                    streamFromList.addAll(GEMS_Utility.getStreamsForSchool(BSUID, ay.id, getLookupValue(selectedFromGrade,gradeFromList)));
            
                selectedFromStream = (streamFromList.size() > 0) ? streamFromList[0].getValue() : NULL;
            }
            getSectionsForSchool();
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getToStreamsForSchool - Prepare to streams picklist]
     */
    public void getToStreamsForSchool() {
        try {
            selectedToStream = NULL;
            streamToList.clear();
            sectionToList.clear();
            sectionToList.add(new SelectOption('', '--None--'));

            if (!String.isBlank(selectedToGrade) && !String.isBlank(selectedToAcademicYear)) {
                string AYLabel = getLookupValue(selectedToAcademicYear,academicYearFromList);
                Academic_year__c ay = new Academic_year__c ();
                ay = GEMS_Utility.getAcademicYearID(school.id,AYLabel,selectedToCurriculum);
                if(ay!=null)
                    streamToList.addAll(GEMS_Utility.getStreamsForSchool(BSUID, ay.id, getLookupValue(selectedToGrade,gradeToList)));
                selectedToStream = (streamToList.size() > 0) ? streamToList[0].getValue() : NULL;
            }
            getToSectionsForSchool();
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getSectionsForSchool -Prepare from section picklist]
     */
    public void getSectionsForSchool() {
        try {
            selectedFromSection = NULL;
            sectionFromList.clear();
            studentWrapperList = new list<studentWrapper>();//v1.3 Added to hide the search section on change
            sectionFromList.add(new SelectOption('', '--None--'));
            if (selectedFromGrade != NULL && selectedFromAcademicYear != NULL && selectedFromStream != NULL) {
                string AYLabel = getLookupValue(selectedFromAcademicYear,academicYearFromList);
                Academic_year__c ay = new Academic_year__c ();
                ay = GEMS_Utility.getAcademicYearID(school.id,AYLabel,selectedFromCurriculum);
                string gradeLabel = getLookupValue(selectedFromGrade,gradeFromList);
                GradeFromLabel = gradeLabel;
                system.debug('gradeLabel===>'+gradeLabel);
                grade__c grade = new grade__c ();
                if(ay!=null)
                    grade = GEMS_Utility.getgradeID(school.id,ay.id ,selectedFromStream, gradeLabel);
        
                if(ay!=null && grade!=null){
                    sectionFromList.addAll(GEMS_Utility.getSectionsForSchool(BSUID, ay.id,grade.id,selectedFromStream));
                    selectedFromSection = (sectionFromList.size() > 0) ? sectionFromList[0].getValue() : NULL;
                }
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getToSectionsForSchool Prepare to Section picklist]
     */
    public void getToSectionsForSchool() {
        try {
            selectedToSection = NULL;
            sectionToList.clear();
            sectionToList = new list<SelectOption>();
            sectionToList.add(new SelectOption('', '--None--'));
            if (selectedToGrade != NULL && selectedToAcademicYear != '' && selectedToStream != NULL) {
                string AYLabel = getLookupValue(selectedToAcademicYear,academicYearFromList);
                Academic_year__c ay = new Academic_year__c ();
                ay = GEMS_Utility.getAcademicYearID(school.id,AYLabel,selectedToCurriculum);
                
                string gradeLabel = getLookupValue(selectedToGrade,gradeToList);
                GradeToLabel = gradeLabel;
                
                grade__c grade = new grade__c ();
                if(ay!=null)
                    grade = GEMS_Utility.getgradeID(school.id,ay.id ,selectedToStream, gradeLabel);
            
                if(ay!=null && grade!=null){
                  sectionToList.addAll(GEMS_Utility.getSectionsForSchool(BSUID, ay.id,grade.id,selectedToStream));
                  selectedToSection = (sectionFromList.size() > 0) ? sectionFromList[0].getValue() : NULL;
                }
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getCurriculumsForSchool -Prepare from Curricullum picklist]
     */
    public void getCurriculumsForSchool() {
        try {
            curriculumFromList.clear();
            selectedFromCurriculum = NULL;
            studentWrapperList = new list<studentWrapper>();//v1.3 Added to hide the search section on change
            curriculumFromList.add(new SelectOption('', '--None--'));
            if (!String.isBlank(selectedFromAcademicYear)) {
                string ayID = getAYID(selectedFromAcademicYear);
                curriculumFromList = GEMS_Utility.getCurriculumsForSchool(BSUID, ayID);
                selectedFromCurriculum  = (curriculumFromList.size() > 0) ? curriculumFromList[0].getValue() : NULL;
            }
            getGradesforSchool();
            selectedFromGrade =   (gradeFromList.size() > 0) ? gradeFromList[0].getValue() : NULL;
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    /**
     * [getToCurriculumsForSchool Prepare to cussicullum piklist]
     */
    public void getToCurriculumsForSchool() {
        try {
            curriculumToList.clear();
            selectedToCurriculum = NULL;
            curriculumToList.add(new SelectOption('', '--None--'));
            if (!String.isBlank(selectedToAcademicYear)) {
                string ayID = getAYID(selectedToAcademicYear);
                curriculumToList = GEMS_Utility.getCurriculumsForSchool(BSUID, ayID);
                selectedToCurriculum  = (curriculumToList.size() > 0) ? curriculumToList[0].getValue() : NULL;
            }
            selectedToCurriculum = selectedFromCurriculum;//1.2
            getToGradesforSchool();
            selectedToGrade =   (gradeToList.size() > 0) ? gradeToList[0].getValue() : NULL;
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
    
    
    /**
     * [getLookupValue Return label value of the picklist value passed as param]
     * @param  key                      [Key - Selected picklist entry]
     * @param  list<SelectOption>soList [Picklist ]
     * @return                          [Label value of the selected picklist]
     */
    public String getLookupValue(string key, list<SelectOption>soList) {
        String retStr = '';
        for (SelectOption so : soList) {
            if (so.getValue() == key)
                retStr = so.getLabel();
        }
        return retStr;
    }
    
    /**
     * [validateAcademicyear -Validate Academic year value]
     * @return [description]
     */
    public boolean validateAcademicyear() {
        boolean isvalid = true;
        /*
        Integer fromAY = Integer.valueOf(getLookupValue(selectedFromAcademicYear, academicYearFromList).subString(0, 4));
        Integer toAY =  Integer.valueOf(getLookupValue(selectedToAcademicYear, academicYearFromList).subString(0, 4));

        if (toAY < Date.Today().Year()) {
            isValid = false;
        }
        */
        return isValid;
    } 

    /**
     * [validateDateOfJoining - Implements logic for DOJ ]
     * @param  DOJ [Date of Joining  value]
     * @return     [DOJ validation boolean result]
     */
    public boolean validateDateOfJoining(date DOJ) {
        Integer toAYA = Integer.valueOf(getLookupValue(selectedToAcademicYear, academicYearFromList).substringBefore('-'));
        Integer toAYB =  Integer.valueOf(getLookupValue(selectedToAcademicYear, academicYearFromList).subStringAfter('-'));
        boolean isvalid = false;
        Integer year =  DOJ.year();
        if (year >= toAYA && year <= toAYB) {
            isValid =  true;
        }
        return isValid;
    }
    
    /**
     * [requestChange Implements logic to create Edit Critical Data Service Request]
     */
    public void requestChange() {
        Boolean validFlag = true;
        //Section_Master__c smObj ;
		Section_Master__c smObj = getSectionInfo(selectedToSection);//1.8
        String AY1 =  smObj.Grade__r.Academic_year__c;//1.8
        	 
        try {
            if (selectedFromAcademicYear == selectedToAcademicYear &&
                    selectedFromCurriculum == selectedToCurriculum &&
                    selectedFromGrade == selectedToGrade &&
                    selectedFromStream == selectedToStream &&
                    selectedFromSection == selectedToSection &&
                    objSR.Joining_Date__c == NULL
               ) {
                GEMS_Utility.addPageError('Invalid selection - there is no change in student information.');
                validFlag = false;
            }
            if (selectedFromAcademicYear == selectedToAcademicYear &&
                    selectedFromCurriculum == selectedToCurriculum &&
                    selectedFromGrade == selectedToGrade &&
                    selectedFromStream == selectedToStream &&
                    selectedFromSection != selectedToSection &&
                    (objSR.Joining_Date__c == NULL)
               ) {
                GEMS_Utility.addPageError('Invalid selection - you cannot make a change of section under Edit Critical Details.');
                validFlag = false;
            }
            
            if (string.isBlank(selectedToAcademicYear)) {
                GEMS_Utility.addPageError('Invalid selection - please select Change To Academic year.');
                validFlag = false;
            }
            if (string.isBlank(selectedToGrade)) {
                GEMS_Utility.addPageError('Invalid selection - please select Change To Grade.');
                validFlag = false;
            }
            if (string.isBlank(selectedToSection)) {
                GEMS_Utility.addPageError('Invalid selection - please select Change To Section.');
                validFlag = false;
            }
            /*
            if (!validateAcademicyear() && validFlag) {
                GEMS_Utility.addPageError('Invalid selection - Academic Year should not be of the past.');
                validFlag = false;

            }
            */
            if (objSR.Comments__c == NULL && validFlag) {
                GEMS_Utility.addPageError('Please enter Remarks.');
                objSR.Comments__c.addError('Please enter Remarks.');
                validFlag = false;
            }

            if (selectedFromAcademicYear != selectedToAcademicYear && objSR.Joining_Date__c == NULL && validFlag) {
                objSR.Joining_Date__c.addError('Please enter Date of joining.');
                validFlag = false;
            }
            date AYStartDate;
            date AYEndDate;
            if (objSR.Joining_Date__c != NULL  && validFlag) {
            	//1.8 - replaced selectedAcademicyear by AY1,queried from Section
                for (Academic_Year__c AY : [Select End_Date__c, Start_Date__c FROM Academic_Year__c WHERE Id = :AY1]) {
                    if (!(objSR.Joining_Date__c >= AY.Start_Date__c && objSR.Joining_Date__c <= AY.End_Date__c )) {
                        objSR.Joining_Date__c.addError('Date of joining should be in between ' + formatDate(AY.Start_Date__c) + ' and ' + formatDate(AY.End_Date__c) );
                        validFlag = false;
                    }else{
                        AYStartDate = AY.Start_Date__c;
                        AYEndDate = AY.End_Date__c;
                    }
                }
            }
            if (validFlag) {
                date tempDate = objSR.Joining_Date__c;
                string comments = objSR.Comments__c;
                //smObj = getSectionInfo(selectedToSection);//1.8 
                list<HexaBPM__Service_Request__c> SRList = new list<HexaBPM__Service_Request__c>();
                RecordType editCriticalDataRT = [SELECT Id, DeveloperName FROM RecordType Where DeveloperName = : GEMS_Constants.SRRT_EDIT_CRITICAL_DATA Limit 1];
                
                for(studentWrapper wrp : studentWrapperList){
                    if(wrp.isSelected){
                    	//1.4 start
                    	if(selectedFromAcademicYear==selectedToAcademicYear && selectedFromCurriculum==selectedToCurriculum && selectedFromGrade==selectedToGrade && selectedFromStream==selectedToStream && selectedFromSection != selectedToSection && objSR.Joining_Date__c == wrp.student.Date_of_Join__c) {
			                GEMS_Utility.addPageError('Invalid selection - you cannot make a change of section under Edit Critical Details.');
			                validFlag = false;
			                break;
			            }
			            if(selectedFromAcademicYear==selectedToAcademicYear && selectedFromCurriculum==selectedToCurriculum && selectedFromGrade==selectedToGrade && selectedFromStream==selectedToStream && selectedFromSection == selectedToSection && objSR.Joining_Date__c == wrp.student.Date_of_Join__c) {
			                GEMS_Utility.addPageError('Invalid selection - there is no change in student information.');
			                validFlag = false;
			                break;
			            }//1.4 End
			            
			           
			            
			            system.debug('GradeFRom====>'+GradeFromLabel);
			            system.debug('GradeTo====>'+GradeFromLabel);
            			
                        //Process Selected Students
                        //1.5 and 1.6 - check if the student's DOJ is between the student's current academic year start date and End date
                        if((wrp.student.Valid_DOJ__c) ||(wrp.student.Valid_DOJ__c== false && selectedFromAcademicYear==selectedToAcademicYear && GradeFromLabel==GradeToLabel && selectedFromStream!=selectedToStream)) { 
                            objSR =  new HexaBPM__Service_Request__c();
                            objSR.School__c = school.Id;
                            objSR.RecordtypeId  = editCriticalDataRT.Id;
                            objSR.Student__c = wrp.student.Id;
                            objSR.Academic_year__c = smObj.Grade__r.Academic_year__c;
                            objSR.GradeLookup__c = smObj.Grade__c;
                            objSR.Stream__c = smObj.Grade__r.Stream__c;
                            objSR.Section_Lookup__c = selectedToSection;
                            objSR.Curriculum__c = selectedToCurriculum;
                            objSR.Joining_Date__c = tempDate;
                            objSR.Comments__c = comments;
                            objSR.From_Academic_Year__c = getLookupValue(selectedFromAcademicYear, academicYearFromList);
                            objSR.To_Academic_Year__c = getLookupValue(selectedToAcademicYear, academicYearFromList);
                            objSR.From_Grade__c = getLookupValue(selectedFromGrade, gradeFromList);
                            objSR.To_Grade__c = getLookupValue(selectedToGrade, gradeToList);
                            objSR.From_Curriculum__c =  getLookupValue(selectedFromCurriculum, curriculumFromList);
                            objSR.To_Curriculum__c = getLookupValue(selectedToCurriculum, curriculumToList);
                            objSR.From_Section__c =  getLookupValue(selectedFromSection, sectionFromList);
                            objSR.To_Section__c = getLookupValue(selectedToSection, sectionToList);
                            SRList.add(objSR);
                        }else{
                            validFlag = false;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error, 'The selected student '+wrp.student.Name+' is an old Student and not a student joined in the current Academic year. You cannot Academic year, Grade or Date Of Joining through Edit critical request for this student.'));
                            break;
                        }
                    }
                }
                if(!SRList.isEMpty()){
                    if(validFlag){
                        insert SRList;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, 'Change request raised successfully.'));
                        SubmitSrs(SRList);
                        getAllStudents();
                        remarks = '';
                    }
                }else{
                    if(validFlag)
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error, 'Please select at least one student record.'));
                }
            }
        } catch (Exception e) {
            GEMS_Utility.logException(e);
            GEMS_Utility.addPageError(e.getMessage());
        }
    }
    
/**
 * [SubmitSrs - Implements logic to Submit all Srs]
 * @param srList [List of SRs after submission]
 */
    public static void SubmitSrs(List<HexaBPM__Service_Request__c> srList) {
        HexaBPM__SR_Status__c srStatus = [select Id from HexaBPM__SR_Status__c where HexaBPM__Code__c  = 'SUBMITTED'];
        list<HexaBPM__Service_Request__c> srUpdateList = new list<HexaBPM__Service_Request__c>();

        for (HexaBPM__Service_Request__c  SR : srList ) {
            SR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
            SR.HexaBPM__External_SR_Status__c = srStatus.Id;
            SR.Transaction_Date__c = system.today();
            SR.HexaBPM__Submitted_Date__c = system.today();
            SR.HexaBPM__Submitted_DateTime__c = system.now();
            srUpdateList.add(SR);
        }
        update srUpdateList;
    }
    
    /**
     * Student Wrapper class
     */
    public class studentWrapper {
        public Account student {get; set;}
        public Boolean isSelected {get; set;}
        public string serialNumber {get; set;}
        public studentWrapper(Account student) {
            this.student = student;
            this.serialNumber = serialNumber;
            this.isSelected = false;
        }
    }
    
    /**
     * [formatDate Method to format date value]
     * @param  d [Date value as param]
     * @return   [Formatted date as String value]
     */
    public static String formatDate(Date d) {
        return  d.day() + '-' + d.month() + '-' +  d.year();
    }
    
    public string getAYID(string selectedAY){
      string ayID = '';
      list<Academic_year__c> tempList = new list<Academic_year__c>();
      tempList = [Select Year__c from Academic_year__c where Id = :selectedAY AND Year__c != NULL];
      if(tempList!=null && tempList.size()>0)
        return tempList[0].Year__c;
      
      return ayID;
    }
    
    //1.3 Start
    public PageReference previousPage(){
        this.paginater.decrement();
        return changeData();
    }
    
    public PageReference nextPage(){
        this.paginater.increment();
        return changeData();
    }

    public PageReference updatePage(){
        this.paginater.updateNumbers();
        return changeData();
    }
    
    public PageReference changeData(){
        this.studentWrapperList = this.fullstudentWrapperList.get(this.paginater.index);
        return null;
    } //End
}