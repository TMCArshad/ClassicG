public without sharing class GEMS_interUnitTransferManagementCtlr {
    
    public school__c objSchoolTransfer {get; set;}
    public school__c objSchoolCurrent {get; set;}
    string schoolId;
    
    public string selectedAYTransfer {get; set;}
    public string selectedAYCurrent {get; set;}
    
    public string selectedCurriculumTransfer {get; set;}
    public string selectedCurriculumCurrent {get; set;}
    
    public string selectedGradeTransfer {get; set;}
    public string selectedGradeCurrent {get; set;}
    
    public string selectedStreamTransfer {get; set;}
    public string selectedStreamCurrent {get; set;}
    
    public string selectedSectionTransfer {get; set;}
    public string selectedSectionCurrent {get; set;}
    
    public string selectedGender {get; set;}
    public string selectedSchool {get; set;}
    
    public string searchStudentValue{get;set;}
    
    public date transferDate {get; set;}
    
    public boolean selectAll {get; set;}
    public boolean transferred {get; set;}
    public boolean breakJob {get; set;}
    public boolean performedSearch {get;set;}
    public boolean showStream {get;set;}
    public boolean showCurriculum {get;set;}

    public HexaBPM__Service_Request__c objSR {get; set;}
    
    public list<SelectOption> academicYearListTransfer {get; set;}
    public list<SelectOption> curriculumListTransfer {get; set;}
    public list<SelectOption> gradeListTransfer {get; set;}
    public list<selectOption> sectionListTransfer {get; set;}
    public list<SelectOption> streamListTransfer {get; set;}
    
    public list<SelectOption> academicYearListCurrent {get; set;}
    public list<SelectOption> curriculumListCurrent {get; set;}
    public list<SelectOption> gradeListCurrent {get; set;}
    public list<selectOption> sectionListCurrent {get; set;}
    public list<SelectOption> streamListCurrent {get; set;}
    
    public list<SelectOption> genderList {get; set;}
    public list<SelectOption> schoolList {get; set;}
    
    public list<studentWrapper> studentWrapperList {get; set;}
    
    Id batchId;
    
    public GEMS_interUnitTransferManagementCtlr() {
       try{
           objSR = new HexaBPM__Service_Request__c();

            schoolId = apexpages.currentPage().getparameters().get('schoolId');
            if(string.isNotBlank(schoolId)){
                initiateValues();
                getCurrentSchool();
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
        performedSearch = false;
        breakJob = false; 
        showCurriculum = false;
        showStream = false;
        
        searchStudentValue = '';
               
        academicYearListCurrent = new list<SelectOption>();
        curriculumListCurrent = new list<SelectOption>();
        gradeListCurrent = new list<SelectOption>();
        sectionListCurrent = new list<SelectOption>();
        streamListCurrent = new list<SelectOption>();
        
        academicYearListTransfer = new list<SelectOption>();
        curriculumListTransfer = new list<SelectOption>();
        gradeListTransfer = new list<SelectOption>();
        sectionListTransfer = new list<SelectOption>();
        streamListTransfer = new list<SelectOption>();
        
        studentWrapperList = new list<studentWrapper>();
        
        schoolList = new list<SelectOption>();
        genderList = new list<SelectOption>();
        
        genderList.add(new SelectOption('Male', 'Male'));
		genderList.add(new SelectOption('Female', 'Female'));
		
		selectedAYTransfer = '';
	    selectedAYCurrent = '';
	    
	    selectedCurriculumTransfer = '';
	    selectedCurriculumCurrent = '';
	    
	    selectedGradeTransfer = '';
	    selectedGradeCurrent = '';
	    
	    selectedStreamTransfer = '';
	    selectedStreamCurrent = '';
	    
	    selectedSectionTransfer = '';
	    selectedSectionCurrent = '';
	    
	    selectedGender = '';
	    selectedSchool = '';
                
    }
    

/*************************************Current School********************************************************************/    
    public void getCurrentSchool(){
        list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:schoolId];
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
			streamListCurrent = GEMS_Utility.getStreamsForSchool(objSchoolCurrent.id__c, ay.id, getLookupValue(selectedGradeCurrent,gradeListCurrent));
		if(streamListCurrent!=null && streamListCurrent.size()>0){
			selectedStreamCurrent = streamListCurrent[0].getValue();
			
		}else{
			selectedStreamCurrent = '';
			streamListCurrent.add(new SelectOption('', '--None--'));
		}
		
		if(streamListCurrent!=null && streamListCurrent.size()>1)
			showStream = true;
			
		getSectionsCurrent();
    }
    
    public void getSectionsCurrent(){
		
		string AYLabel = getLookupValue(selectedAYCurrent,academicYearListCurrent);
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchoolCurrent.id,AYLabel,selectedCurriculumCurrent);
		
		string gradeLabel = getLookupValue(selectedgradeCurrent,gradeListCurrent);
		grade__c grade = new grade__c ();
		if(ay!=null)
			grade = GEMS_Utility.getgradeID(objSchoolCurrent.id,ay.id ,selectedStreamCurrent, gradeLabel);
		
		if(ay!=null && grade!=null){
			sectionListCurrent = new list<selectOption>();
			sectionListCurrent = GEMS_Utility.getSectionsForSchool(objSchoolCurrent.id__c, ay.id,grade.id, selectedStreamCurrent);
			if(sectionListCurrent!=null && sectionListCurrent.size()>0){
				selectedSectionCurrent = sectionListCurrent[0].getValue();
			}else{
				selectedSectionCurrent = '';
				sectionListCurrent.add(new SelectOption('', '--None--'));
			}
		}else{
			selectedSectionCurrent = '';
			sectionListCurrent.add(new SelectOption('', '--None--'));
		}
		
    }
    
/******************************************Transfer School*****************************************************************/
    public void getTransferSchool(){
        schoolList.add(new SelectOption('', '--None--'));
	    academicYearListTransfer.add(new SelectOption('', '--None--'));
	    gradeListTransfer.add(new SelectOption('', '--None--'));
	    StreamListTransfer.add(new SelectOption('', '--None--'));
	    sectionListTransfer.add(new SelectOption('', '--None--'));
	    curriculumListTransfer.add(new SelectOption('', '--None--'));
        
        for (School__c school : [SELECT id, Name FROM School__c where id!=: objSchoolCurrent.id ORDER BY Name]) {
        //Both name and Value is school name because Transfer school is saved as text on Lead
            schoolList.add(new SelectOption(school.id, school.Name));
        }
        
        selectedSchool = (schoolList.size() > 0) ? schoolList[0].getValue() : NULL;
    }
    
    public void getTransferSchoolSelected(){
        for (School__c school : [SELECT id, Name FROM School__c where id!=: objSchoolCurrent.id ORDER BY Name]) {
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
		getStreamsTransfer();
    }
    
    public void getStreamsTransfer(){
		streamListTransfer = new list<selectOption>();
		
		string AYLabel = getLookupValue(selectedAYTransfer,academicYearListTransfer);
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchoolTransfer.id,AYLabel,selectedCurriculumTransfer);
		
		if(ay!=null)
			streamListTransfer = GEMS_Utility.getStreamsForSchool(objSchoolTransfer.id__c, AY.id, getLookupValue(selectedGradeTransfer,gradeListTransfer));
		if(streamListTransfer!=null && streamListTransfer.size()>0){
			selectedStreamTransfer = streamListTransfer[0].getValue();
		}else{
			selectedStreamTransfer = '';
			streamListTransfer.add(new SelectOption('', '--None--'));
		}
		
		if(streamListTransfer!=null && streamListTransfer.size()>1)
			showStream = true;
				
		getSectionsTransfer();
    }
    
    public void getSectionsTransfer(){
		string AYLabel = getLookupValue(selectedAYTransfer,academicYearListTransfer);
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchoolTransfer.id,AYLabel,selectedCurriculumTransfer);
		
		string gradeLabel = getLookupValue(selectedgradeTransfer,gradeListTransfer);
		grade__c grade = new grade__c ();
		if(ay!=null)
			grade = GEMS_Utility.getgradeID(objSchoolTransfer.id,ay.id ,selectedStreamTransfer, gradeLabel);
		
		if(ay!=null && grade!=null){
			sectionListTransfer = new list<selectOption>();
			sectionListTransfer = GEMS_Utility.getSectionsForSchool(objSchoolTransfer.id__c, AY.id, grade.id, selectedStreamTransfer);
			if(sectionListTransfer!=null && sectionListTransfer.size()>0){
				selectedSectionTransfer = sectionListTransfer[0].getValue();
			}else{
				selectedSectionTransfer = '';
				sectionListTransfer.add(new SelectOption('', '--None--'));
			}
		}else{
			selectedSectionTransfer = '';
			sectionListTransfer.add(new SelectOption('', '--None--'));
		}
		system.debug('---sectionListTransfer---'+sectionListTransfer);	
    }
    
/*******************************************Get Existing Students***************************************************************/    
    public void getExistingStudents(){
        try{

            transferDate = objSR.Transfer_date__c;

	        if(transferred==true){
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'SR for transfer raised successfully.'));	
	        }
		    transferred=false; 
		    searchStudentValue = '';
	        
	        studentWrapperList = new list<studentWrapper>();
	        
	        list<Account> tempList = [select id, student_id__c, firstName, lastName from account where Record_Type_Name__c = 'Student' and
	                                  academic_year__c=:selectedAYCurrent and GradeLookup__c=:selectedGradeCurrent
	                                  and Stream__c=:selectedStreamCurrent and Section__c=:selectedSectionCurrent
	                                  and gender__c=:selectedGender and school__c=:objSchoolCurrent.id and Current_Status__c='EN'
	                                  and id NOT IN (select HexaBPM__Customer__c from HexaBPM__Service_Request__c where HexaBPM__Record_Type_Name__c='Inter_Unit_Student_Transfer')];   
	        
	        if(tempList!=null && tempList.size()>0){
	            for(Account obj : tempList){
	                studentWrapper objStud = new studentWrapper(obj);
	                objStud.objAccount = obj;
	                studentWrapperList.add(objStud);
	            }
	        }
	        else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria')); 	
	        }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }

    }
    
    public void searchStudents(){
    	if(string.isNotBlank(searchStudentValue)){
    		studentWrapperList = new list<studentWrapper>();
    		list<Account> studentList = new list<Account>();
    		string tempSearchTerm = '("' + searchStudentValue + '")';
    		
    		studentList = 	(List<Account>)[FIND : tempSearchTerm IN All Fields RETURNING Account(id, student_id__c, firstName, lastName,Academic_Year__c,GradeLookup__c, Section__c, Stream__c,gender__c, Current_Status__c, school__c)][0];
    		if(studentList!=null && studentList.size()>0){
				
				map<id,id> srExistMap = new map<id,id>();
				for(HexaBPM__Service_Request__c obj : [select id from HexaBPM__Service_Request__c where HexaBPM__Record_Type_Name__c='Inter_Unit_Student_Transfer' and (student__c IN : studentList or HexaBPM__Customer__c IN : studentList)]){
					srExistMap.put(obj.HexaBPM__Customer__c,obj.id);
				}
				
	            for(Account obj : studentList){
	            	if(obj.academic_year__c==selectedAYCurrent && obj.GradeLookup__c==selectedGradeCurrent && 
	                   obj.Stream__c==selectedStreamCurrent && obj.Section__c==selectedSectionCurrent && 
	                   obj.gender__c==selectedGender && obj.school__c==objSchoolCurrent.id && obj.Current_Status__c=='EN'){
		                
		                if(srExistMap!=null && !(srExistMap.containsKey(obj.id))){
			                studentWrapper objStud = new studentWrapper(obj);
			                objStud.objAccount = obj;
			                studentWrapperList.add(objStud);
		                }
		            }
		        }
    		}
    		if(studentWrapperList!=null && studentWrapperList.size()>0){
    			
    		}
    		else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria')); 	
	        	performedSearch = true;
	        }
    	}
    }
    
    public void clearSearch(){
    	searchStudentValue = '';
    	getExistingStudents();
    }
    
/*****************************************Save Transfer Requests*****************************************************************/    

	public void transferRequest(){
		try{
			system.debug('--selectedStreamTransfer---'+selectedStreamTransfer);
			system.debug('--selectedSchool---'+selectedSchool);
			system.debug('--selectedAYTransfer---'+selectedAYTransfer);
			system.debug('--selectedGradeTransfer---'+selectedGradeTransfer);
			system.debug('--selectedSectionTransfer---'+selectedSectionTransfer);
			system.debug('--transferDate---'+transferDate);
			
            if(string.isBlank(selectedSchool) || string.isBlank(selectedAYTransfer) ||
	           string.isBlank(selectedGradeTransfer) || string.isBlank(selectedStreamTransfer) ||
	           string.isBlank(selectedSectionTransfer) || objSR.Transfer_date__c==null){
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please provide all required values'));	
	        }else{
	            transferDate = objSR.Transfer_date__c;
	
				list<HexaBPM__Service_Request__c> srList = new list<HexaBPM__Service_Request__c>();
				if(studentWrapperList!=null && studentWrapperList.size()>0){
					string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Inter_Unit_Student_Transfer');
					for(studentWrapper obj : studentWrapperList){
						if(obj.selectRecord == true){
							objSR = new HexaBPM__Service_Request__c();
							objSR.HexaBPM__Customer__c = obj.objAccount.id;
							//objSR.student__c = obj.objAccount.id;
							objSR.School__c = objSchoolTransfer.id;
							objSR.Academic_Year__c = selectedAYTransfer;
							objSR.Stream__c = selectedStreamTransfer;	
							objSR.GradeLookup__c = selectedGradeTransfer;
							objSR.Section_Lookup__c = selectedSectionTransfer;
							objSR.Transfer_date__c = transferDate;
							objSR.recordTypeId = recTypeID;
							objSR.gender__c = selectedGender;
							objSR.StudentId__c = obj.objAccount.student_id__c;
							srList.add(objSR);
						}
					}
				}
				system.debug('---srList---'+srList);
				if(srList!=null && srList.size()>0){
					GEMS_interUnitStudentTransferBatch batchJob = new GEMS_interUnitStudentTransferBatch(srList,'','Inter_Unit_Student_Transfer') ;
	    			batchId = Database.executeBatch(batchJob,1);
	    			transferred = true;
		            selectAll = false;
		            getExistingStudents();	
				}
	    	}
			
		}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
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
        public Account objAccount {get;set;}
        
        public studentWrapper(Account objAccount){
        	objAccount = new Account();
            selectRecord = false;
        }
    }
}