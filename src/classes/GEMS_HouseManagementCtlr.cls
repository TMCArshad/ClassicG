global without sharing class GEMS_HouseManagementCtlr {
    public school__c objSchool {get; set;}
    
    public list<SelectOption> academicYearList {get; set;}
    public list<SelectOption> curriculumList {get; set;}
    public list<SelectOption> streamList {get; set;}
    public list<SelectOption> gradeList {get; set;}
    public list<SelectOption> sectionList {get; set;}
    public list<SelectOption> actionList {get; set;}
    public list<SelectOption> houseList {get; set;}
    public list<relationship__c> siblingList {get; set;}
    
    public map<string, integer> houseCount {get;set;}
    public map<id, house_master__c> houseMap {get;set;}
    
    public string selectedAY {get; set;} 
    public string selectedGrade {get; set;}
    public string selectedSection {get; set;}
    public string selectedStream {get; set;}
    public string selectedCurriculum {get; set;}
    public string selectedAction {get; set;}
    public string selectedHouse {get; set;}
    public string studentID {get; set;}
    
    public boolean showStream {get;set;}
    public boolean showCurriculum {get;set;}
    public boolean houseAllocated {get;set;}
    public boolean selectAll {get; set;}
    public boolean displayPopup {get;set;}
    
    public House_Master__c objHouse{get;set;}
    
    public string searchStudentValue{get;set;}
    
    public list<studentWrapper> studentWrapperList {get; set;}
    
    string schoolId;
    public GEMS_HouseManagementCtlr(){
    	try{
	        schoolId = apexpages.currentPage().getparameters().get('schoolId');
	        if(string.isNotBlank(schoolId)){
	        	initiateValues();
		        getSchoolDetails();
		        getHouse();
		        getHouseDetails();
	        }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'---'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    }
    
    public void initiateValues(){
        showStream = false;
        showCurriculum = false;
        
        academicYearList = new list<SelectOption>();
        gradeList = new list<SelectOption>();
        streamList = new list<SelectOption>();
        sectionList = new list<SelectOption>();
        curriculumList = new list<SelectOption>();
        houseList = new list<SelectOption>();
        
	    selectedAY = '';
	    selectedGrade = '';
	    selectedStream = '';
	    selectedCurriculum = '';
	    selectedSection = '';
	    selectedAction = '';
	    searchStudentValue = '';
	    selectedHouse = '';
	    
	    actionList = new list<SelectOption>();
	    actionList.add(new SelectOption('', '--None--'));
	    actionList.add(new SelectOption('new', 'Create New House'));
	    actionList.add(new SelectOption('allocate', 'Allocate House'));
	    
	    objHouse = new House_Master__c();
	    
    }
    
    public void initiateAction(){
    	if(selectedAction == 'new'){
    		objHouse = new House_Master__c();
    		objHouse.School__c = objSchool.id;
    	}
    	else{
    		getAcademicYear();
    		getHouse();
    		studentWrapperList = new list<studentWrapper>();
    		selectAll = false;
    	}
    }
    
    public void getSchoolDetails(){
    	objSchool = new school__c();
		list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:schoolId];
		if(tempSchoolList!=null && tempSchoolList.size()>0){
			objSchool = tempSchoolList[0];
			getAcademicYear();
		}	
	}
	
	public void getHouseDetails(){
		houseCount = new map<string,integer>();
		AggregateResult[] groupedResults = [SELECT COUNT(Id), house__c
    										FROM Account WHERE Current_Status__c = 'EN' 
    										and school__c=:objSchool.id
    										and academic_year__c =: selectedAY and house__c!=null
    										group by house__c];
		
		system.debug('---groupedResults---'+groupedResults);
		if(groupedResults!=null && groupedResults.size()>0){
			houseAllocated = true;
			for (AggregateResult ar : groupedResults)  {
			    houseCount.put((string)ar.get('house__c'),(integer)ar.get('expr0'));
			}	
		}
		if(houseMap!=null && houseMap.size()>0){
			for(string obj : houseMap.keyset()){
				if(!houseCount.containsKey(obj)){
					houseCount.put(obj,0);	
				}
			}	
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
    
    public void getCurriculum(){
    	list<Academic_year__c> tempList = [Select Year__c from Academic_year__c where Id = :selectedAY AND Year__c != NULL];
    	Academic_year__c ay = new Academic_year__c ();
    	if(!tempList.isEmpty()){
    		ay = tempList[0];
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
		
		system.debug('---selectedGrade---'+selectedGrade);
    	system.debug('---gradeList---'+gradeList);
		getStreams();
    }
    
    public void getStreams(){
		streamList = new list<selectOption>();
		
		string AYLabel = getLookupValue(selectedAY,academicYearList);
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
		
		if(ay!=null)
			streamList = GEMS_Utility.getStreamsForSchool(objSchool.id__c, AY.id, getLookupValue(selectedGrade,gradeList));
		if(streamList!=null && streamList.size()>0){
			selectedStream = streamList[0].getValue();
			
		}else{
			selectedStream = '';
			streamList.add(new SelectOption('', '--None--'));
		}
		
		if(streamList!=null && streamList.size()>1)
			showStream = true;
		else
			showStream = false;
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
			}else{
				selectedSection = '';
				sectionList.add(new SelectOption('', '--None--'));
			}
		}else{
			selectedSection = '';
			sectionList.add(new SelectOption('', '--None--'));
		}
		
    }
    
    public void getExistingStudents(){
        try{

		    searchStudentValue = '';
	        
	        studentWrapperList = new list<studentWrapper>();
	        
	        string AYLabel = getLookupValue(selectedAY,academicYearList);
			Academic_year__c ay = new Academic_year__c ();
			ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
			
			string gradeLabel = getLookupValue(selectedgrade,gradeList);
			grade__c grade = new grade__c ();
			if(ay!=null)
				grade = GEMS_Utility.getgradeID(objSchool.id,ay.id ,selectedStream, gradeLabel);
			
	        list<Account> tempList = [select id, student_id__c, firstName, lastName,house__c,
	        						  		 house__r.house_description__c, house__r.house_color__c
	        						  from account where Record_Type_Name__c = 'Student' and
	                                  academic_year__c=:ay.id and GradeLookup__c=:grade.id
	                                  and Stream__c=:selectedStream and Section__c=:selectedSection
	                                  and school__c=:objSchool.id and current_Status__c='EN'];   
	        
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
    		
    		studentList = 	(List<Account>)[FIND : tempSearchTerm IN All Fields RETURNING Account(id, student_id__c, firstName, lastName,Academic_Year__c,GradeLookup__c, Section__c, Stream__c,gender__c, current_Status__c, school__c, house__c)][0];
    		if(studentList!=null && studentList.size()>0){
				
	            for(Account obj : studentList){
	            	if(obj.academic_year__c==selectedAY && obj.GradeLookup__c==selectedGrade && 
	                   obj.Stream__c==selectedStream && obj.Section__c==selectedSection && 
	                   obj.school__c==objSchool.id && obj.current_Status__c=='EN'){
		                
		                studentWrapper objStud = new studentWrapper(obj);
		                objStud.objAccount = obj;
		                studentWrapperList.add(objStud);
		            }
		        }
    		}
    		if(studentWrapperList!=null && studentWrapperList.size()>0){
    			
    		}
    		else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria')); 	
	        }
    	}
    }
    
    public void getHouse(){
    	houseList = new list<SelectOption>();
    	houseList.add(new SelectOption('','--None--'));
    	houseMap = new map<id, house_master__c>();
    	list<House_master__c> tempList = [select id, house_description__c,House_Color__c from House_master__c where school__c=:objSchool.id];
    	if(tempList!=null && tempList.size()>0){
    		for(House_master__c obj : tempList){
    			houseList.add(new SelectOption(obj.id, obj.house_description__c));
    			houseMap.put(obj.id,obj);
    		}
    	}
    }
    
    public void clearSearch(){
    	searchStudentValue = '';
    	getExistingStudents();
    }
    
    public void createHouse(){
    	try{
    		system.debug('----objHouse----'+objHouse);
    		objHouse.school__c = objSchool.id;
    		insert objHouse;	
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,  'House created successfully')); 
    		
    		list<house_master__c> tempList = [select id, house_color__c, house_description__c, school__c from house_master__c where id=:objHouse.id];
    		if(tempList!=null && tempList.size()>0){
    			objHouse = tempList[0];
    			getHouse();
    			getHouseDetails();
    		}
    	}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----msg----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
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
    
    public void allocateHouse(){
    	try{
	    	if(studentWrapperList!=null && studentWrapperList.size()>0){
	    		list<Account> studentToUpdate = new list<Account>();
	    		for(studentWrapper obj : studentWrapperList){
	    			if(obj.selectRecord == true){
	    				Account temp = new Account();
	    				temp = obj.objAccount;
	    				temp.house__c = selectedHouse;
	    				studentToUpdate.add(temp);
	    			}
	    		}
	    		
	    		if(studentToUpdate!=null && studentToUpdate.size()>0){
	    			update studentToUpdate;	
	    			getHouseDetails();
	    			getExistingStudents();
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'House allocated successfully.'));
	    		}
	    	}
	    }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
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
    	siblingList = new list<relationship__c>();
        list<relationship__c> tempRelList = [select id,object_account__r.house__r.House_Description__c,
        											object_account__r.Academic_Year_Display__c,
        											object_account__r.Grade_Display__c,
        											object_account__r.name
        								     from relationship__c 
        								     where type__c='Sibling' 
        								     and subject_account__c =: studentID 
        								     and active__c = true];
        if(tempRelList!=null && tempRelList.size()>0){
        	for(relationship__c obj : tempRelList){
        		if(obj.object_account__r.house__c!=null){
    				siblingList.add(obj);
        		}
        	}	
        }
        
        if(siblingList!=null && siblingList.size()>0){
        	displayPopup = true;
        }
    }
   
    public void closePopup(){displayPopup = false;}
}