/**************************************************************************************************
* Name               : GEMS_SectionManagementCtlr                                                               *
* Created Date       : 23/08/2017                                                                 *
* Created By         : Swati Sehrawat (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Swati       10/12/2017
* 1.2		  Swati		  4/2/2018 - Pagination
**************************************************************************************************/

public with sharing class GEMS_SectionManagementCtlr {
    public school__c objSchool {get; set;}
    public Section_Master__c objSection{get;set;}
    
    public list<SelectOption> academicYearList {get; set;}
    public list<SelectOption> curriculumList {get; set;}
    public list<SelectOption> streamList {get; set;}
    public list<SelectOption> gradeList {get; set;}
    public list<SelectOption> sectionList {get; set;}
    public list<SelectOption> sectionTrasferList {get; set;}
    public list<SelectOption> actionList {get; set;}
    
    public map<id, Section_Master__c> sectionMap {get; set;}
    
    public string selectedAY {get; set;} 
    public string selectedGrade {get; set;}
    public string selectedSection {get; set;}
    public string selectedSectionTransfer {get; set;}
    public string selectedStream {get; set;}
    public string selectedCurriculum {get; set;}
    public string selectedAction {get; set;}
    public string selectedID {get;set;}
    public string selectedAYID {get;set;}
    public string editDel {get;set;}
    
    public boolean showStream {get;set;}
    public boolean showCurriculum {get;set;}
    public boolean selectAll {get; set;}
    public boolean displayPopup {get;set;}
    public boolean sectionAllocated {get;set;}
    
    public string searchStudentValue {get;set;}
    
    //1.2
    public Paginate paginater {get;set;}
	public list<studentWrapper> studentWrapperList{get;set;}
	public List<List<studentWrapper>> fullstudentWrapperList{get;set;}
    
    string schoolId;
    public GEMS_SectionManagementCtlr(){
        try{
            selectedSection = '';
            schoolId = apexpages.currentPage().getparameters().get('schoolId');
            selectedAction =  apexpages.currentPage().getparameters().get('selectedAction');
            if(string.isNotBlank(schoolId)){
                getSchoolDetails();
                initiateValues();
            }
            if(selectedAction == 'assign'){
                getAcademicYear();
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'---'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    } 
    
    public void getSchoolDetails(){
        objSchool = new school__c();
        list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:schoolId];
        if(tempSchoolList!=null && tempSchoolList.size()>0){
            objSchool = tempSchoolList[0];
        }   
    }
    
    public void initiateValues(){
        selectedAY = '';
        selectedGrade = '';
        selectedStream = '';
        selectedCurriculum = '';
        selectedSectionTransfer = '';
        searchStudentValue = '';
        selectedID = '';
        editDel = '';
        
        if(apexpages.currentPage().getparameters().get('selectedAction')!=''){
            selectedAction = apexpages.currentPage().getparameters().get('selectedAction');
        }else{
            selectedAction =  '';
        }
        
        showStream = false;
        showCurriculum = false;
        displayPopUp = false;
        sectionAllocated = false;
        
        academicYearList = new list<SelectOption>();
        gradeList = new list<SelectOption>();
        streamList = new list<SelectOption>();
        sectionList = new list<SelectOption>();
        curriculumList = new list<SelectOption>();
        sectionTrasferList = new list<SelectOption>();
        
        actionList = new list<SelectOption>();
        actionList.add(new SelectOption('', '--None--'));
        actionList.add(new SelectOption('crud', 'Create/Edit/Delete Section'));
        actionList.add(new SelectOption('active', 'Section Allocation/Update for Active Students'));
        actionList.add(new SelectOption('inactive', 'Section Update for Inactive Students'));
        //actionList.add(new SelectOption('assign', 'Form Tutor Allocation'));
        
        objSection = new Section_Master__c();
        objSection.school__c = objSchool.id;
        
    }
    
    public pageReference initiateAction(){
        if(selectedAction != 'active'){
            sectionMap = new map<id, Section_Master__c>();
            getAcademicYear();  
        }else{
            pagereference redirectPage = new pagereference('/apex/GEMS_SectionAllotment?schoolId='+objSchool.id);
            return redirectPage;
        }
        return null;    
    }
    
    public void CRUDOperation(){
        try{
            if(string.isNotBlank(selectedID) && editDel != 'Upsert'){
                objSection = new section_master__c();
                list<section_master__c> tempList = [select id, Section__c, Alloted__c,Boys__c,
                                                        Girls__c,SEN__c,Max_Strength__c 
                                                 from section_master__c 
                                                 where id =: selectedID];
                if(tempList!=null && tempList.size()>0){
                    objSection = tempList[0];
                }
            }
            
            if(string.isNotBlank(editDel) && objSection!=null && editDel == 'Delete'){
                list<account> existingStudent= [select id,Section__c from account where Section__c =: selectedID];
                if(existingStudent!=null && existingStudent.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Section has student allocated, please allocate them to other section before deletion'));   
                }else{
                	if(objSection.Section__c == 'Temp'){
                		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Temp section cannot be deleted.'));   		
                	}
                	else{
                    	delete objSection;
	                    getSections();
	                    selectedID = '';
	                    editDel = '';
	                    objSection = new section_master__c();
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Section deleted successfully')); 
                	}
                }
            }   
            
            if(string.isNotBlank(editDel) && objSection!=null && editDel == 'Upsert'){
                
                //1.0
                string AYLabel = getLookupValue(selectedAY,academicYearList);
		        Academic_year__c ay = new Academic_year__c ();
		        ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
		        
		        string gradeLabel = getLookupValue(selectedgrade,gradeList);
		        grade__c grade = new grade__c ();
		        if(ay!=null)
            		grade = GEMS_Utility.getgradeID(objSchool.id,ay.id ,selectedStream, gradeLabel);
                //End
                
                list<section_master__c> tempList = [select id, Section__c, Alloted__c,Boys__c,
                                                        Girls__c,SEN__c,Max_Strength__c 
	                                                from section_master__c 
	                                                where section__c =: objSection.section__c
	                                                and school__c =: objschool.id
	                                                and Academic_Year__c =: ay.id //1.0
	                                                and Grade__c =: grade.id]; //1.0
                if(tempList!=null && tempList.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Section already exist.'));
                }
                else{
                	if(string.isNotBlank(objSection.section__c) && objSection.Max_Strength__c!=null && objSection.Max_Strength__c>0){
		                if(string.isBlank(objSection.id)){
		                    objSection.school__c = objschool.id;
		                    objSection.Academic_Year__c = ay.id; //1.0
		                    objSection.Grade__c = grade.id; //1.0
		                }
		                upsert  objSection;
		                displayPopUp = false;
		                getSections();
		                selectedID = '';
		                editDel = '';
		                objSection = new section_master__c();
                	}else{
                		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Please provide section name and max strength (greather than zero).'));
                	}
                }
            }
            
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----msg----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    }
    
    public void getAcademicYear(){
        academicYearList = new list<selectOption>();
        academicYearList = GEMS_Utility.getAcademicYearsForSchool(objSchool.id__c, NULL);
        if(academicYearList!=null && academicYearList.size()>0){
            selectedAY = academicYearList[0].getValue();
        }else{
            selectedAY = '';
            academicYearList.add(new SelectOption('', '--None--'));
        }
        
        getCurriculum();
    }
    
    public void assignFormTutor(){
        try{
            update objSection;
            getFormTutor();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Tutor assigned succesfully.'));
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----msg----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    }
    
    public void getCurriculum(){
        list<Academic_year__c> tempList = [Select Year__c from Academic_year__c where Id = :selectedAY AND Year__c != NULL];
        Academic_year__c ay = new Academic_year__c ();
        if(!tempList.isEmpty()){
            ay = tempList[0];
            selectedAYID = ay.id;
        }
            
        curriculumList = new list<selectOption>();
        curriculumList = GEMS_Utility.getCurriculumsForSchool(objSchool.id__c, ay.year__c);
        if(curriculumList!=null && curriculumList.size()>0){
            selectedCurriculum = curriculumList[0].getValue();
        }else{
            selectedCurriculum = '';
            curriculumList.add(new SelectOption('', '--None--'));
        }
        
        if(curriculumList!=null && curriculumList.size()>1)
            showCurriculum = true;
        
        getGrades();
    }
    
    public void getGrades(){
        gradeList = new list<selectOption>();
        gradeList = GEMS_Utility.getGradesForSchool(objSchool.id__c, getLookupValue(selectedAY,academicYearList), selectedCurriculum);
        if(gradeList!=null && gradeList.size()>0){
            selectedGrade = gradeList[0].getValue();
        }else{
            selectedGrade = '';
            gradeList.add(new SelectOption('', '--None--'));
        }
        
        getStreams();
    }
    
    public void getStreams(){
        streamList = new list<selectOption>();
        
        string AYLabel = getLookupValue(selectedAY,academicYearList);
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
		
		if(ay!=null)
        	streamList = GEMS_Utility.getStreamsForSchool(objSchool.id__c, ay.id, getLookupValue(selectedGrade,gradeList));
        if(streamList!=null && streamList.size()>0){
            selectedStream = streamList[0].getValue();
            
        }else{
            selectedStream = '';
            streamList.add(new SelectOption('', '--None--'));
        }
        
        if(streamList!=null && streamList.size()>1)
            showStream = true;
            
        getSections();
    }
    
    public void getSections(){
        string AYLabel = getLookupValue(selectedAY,academicYearList);
        Academic_year__c ay = new Academic_year__c ();
        ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
        
        string gradeLabel = getLookupValue(selectedgrade,gradeList);
        grade__c grade = new grade__c ();
        if(ay!=null)
            grade = GEMS_Utility.getgradeID(objSchool.id,ay.id ,selectedStream, gradeLabel);
        
        if(ay!=null && grade!=null){
            sectionList = new list<selectOption>();
            sectionList = GEMS_Utility.getSectionsForSchool(objSchool.id__c, ay.id,grade.id, selectedStream);
            if(sectionList!=null && sectionList.size()>0){
                selectedSection = sectionList[0].getValue();
                if(selectedAction == 'crud'){
	                set<string> sectionID = new set<string>();
	                for(SelectOption  sec :  sectionList){
	                    sectionID.add(sec.getValue());
	                }
	                
	                if(sectionID!=null && sectionID.size()>0){
	                    sectionMap = new map<id, Section_Master__c>();
	                    for(section_master__c obj : [select id, Section__c, Alloted__c,Boys__c,
	                                                        Girls__c,SEN__c 
	                                                 from section_master__c 
	                                                 where id IN : sectionID]){
	                        sectionMap.put(obj.id,obj); 
	                    }
	                }
	            }
            
	            if(selectedAction == 'assign'){
	                getFormTutor();
	            }
            }else{
                selectedSection = '';
                sectionList.add(new SelectOption('', '--None--'));
                if(selectedAction == 'assign'){
                	objSection = new section_master__c();
                }
                
                sectionMap = new map<id, Section_Master__c>(); //1.0
            }
        }else{
            selectedSection = '';
            sectionList.add(new SelectOption('', '--None--'));
            if(selectedAction == 'assign'){
            	objSection = new section_master__c();
            }
        }
    }
    
    public void getFormTutor(){
        if(selectedAction == 'assign'){
            objSection = new section_master__c();
            list<section_master__c> tempList = [select id, school__c, form_tutor__c,
                                                       form_tutor__r.Full_Name__c   ,
                                                       Form_Tutor__r.Staff_Number__c,
                                                       Form_Tutor__r.Designation__c
                                                from section_master__c 
                                                where id =: selectedSection];
            if(tempList!=null && tempList.size()>0){
                objSection = tempList[0];
            }
        }
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
    
    public void getInactiveStudents(){
        try{
            studentWrapperList = new list<studentWrapper>();
            list<Account> tempList = [select id, student_id__c, firstName, lastName,section__c,
                                             Gender__c,Current_Status__c,Leave_Date__c
                                      from account where Record_Type_Name__c = 'Student_Read_Only' and
                                      academic_year__c=:selectedAY and GradeLookup__c=:selectedGrade
                                      and Stream__c=:selectedStream and Section__c=:selectedSection
                                      and school__c=:objSchool.id and Current_Status__c!='EN'];   
            
            //1.2 start
            Integer pageSize = integer.valueOf(System.Label.Pagination_Size);
	    		
    		this.paginater = new Paginate(tempList.size(), pageSize);
    		
    		studentWrapperList = new list<studentWrapper>();
    		fullstudentWrapperList = new List<List<studentWrapper>>();
    		
    		list<studentWrapper> tempCC = new list<studentWrapper>();
    		Integer i = 0;
	    		
            if(tempList!=null && tempList.size()>0){
                for(Account obj : tempList){
                    studentWrapper objStud = new studentWrapper(obj);
                    objStud.objAccount = obj;
                    tempCC.add(objStud);
		    		
		    		i++;
		       		if(i == pageSize){
		       			this.fullStudentWrapperList.add(tempCC);
		       			tempCC = new List<studentWrapper>();
		       			i = 0;
		       		}
                }
                
                if(!tempCC.isEmpty()){
	       			this.fullStudentWrapperList.add(tempCC);
		       	}
		       	//Gets the correct list of data to show on the page
		       	this.studentWrapperList = this.fullStudentWrapperList.get(this.paginater.index);
		       	// 1.2 end
                string AYLabel = getLookupValue(selectedAY,academicYearList);
                Academic_year__c ay = new Academic_year__c ();
                ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
                
                string gradeLabel = getLookupValue(selectedgrade,gradeList);
                grade__c grade = new grade__c ();
                if(ay!=null)
                    grade = GEMS_Utility.getgradeID(objSchool.id,ay.id ,selectedStream, gradeLabel);
                
                if(ay!=null && grade!=null){
                    sectionTrasferList = new list<selectOption>();
                    sectionTrasferList = GEMS_Utility.getSectionsForSchool(objSchool.id__c, ay.id,grade.id, selectedStream);
                    if(sectionTrasferList!=null && sectionTrasferList.size()>0){
                        selectedSectionTransfer = sectionTrasferList[0].getValue();
                    }else{
                        selectedSectionTransfer = '';
                        sectionTrasferList.add(new SelectOption('', '--None--'));
                    }
                }else{
                    selectedSectionTransfer = '';
                    sectionTrasferList.add(new SelectOption('', '--None--'));
                }
            }
            else{
                if(sectionAllocated == false)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria'));  
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    }
    
    public void transferStudents(){
        if(fullstudentWrapperList!=null && fullstudentWrapperList.size()>0){
            list<Account> studentToUpdate = new list<Account>();
            list<studentWrapper> tempList = new list<studentWrapper>();
		    	
	    	for(integer i=0; i<=fullstudentWrapperList.size()-1; i++){
	    		for(studentWrapper obj : this.fullstudentWrapperList.get(i)){
	    				Account temp = new Account();
		                temp = obj.objAccount;
		                temp.section__c = selectedSectionTransfer;
		                studentToUpdate.add(temp);
	    		}	
	    	}
            
            if(studentToUpdate!=null && studentToUpdate.size()>0){
                update studentToUpdate; 
                sectionAllocated = true;
                getInactiveStudents();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Section allocated successfully.'));
            }   
        }
    }
    
    public class studentWrapper{
        public boolean selectRecord {get; set;}
        public Account objAccount {get;set;}
        
        public studentWrapper(Account objAccount){
            objAccount = new Account();
            selectRecord = false;
        }
    }
    
    public void showPopUp(){
        displayPopup = true;
        CRUDOperation();
    }
   
    public void closePopup(){displayPopup = false;}
    
    //1.2 start
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
    	this.studentWrapperList = this.fullStudentWrapperList.get(this.paginater.index);
    	return null;
    }
    //1.2 End
    
}