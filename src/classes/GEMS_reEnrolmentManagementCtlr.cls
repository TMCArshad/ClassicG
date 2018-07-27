/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   13th April 2017
    Description :   GEMS_reEnrolmentManagementCtlr used for VF page GEMS_reEnrolmentManagement.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    V1.0	08/03/2018		status changed
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_reEnrolmentManagementCtlr {
    
    public list<selectOption> reEnrolmentStatus {get; set;}// picklist to show available reEnrolment Status 
    public list<selectOption> gradeList {get; set;}
    public list<selectOption> curriculumList {get; set;}
    public list<selectOption> streamList {get; set;}
    public list<selectOption> sectionList {get; set;}
    public list <selectOption> blockRemark {get; set;}
    public list <selectOption> reEnrolmentRemark {get; set;}
    public list<selectOption> searchCriteria {get; set;}    
    
    public list<Account> studentList;
    public list<Promotion__c> promotionList;
    
    public Paginate paginater {get;set;}
	public list<promotionWrapper> promotionWrapperList{get;set;}
	public list<List<promotionWrapper>> fullPromotionWrapperList{get;set;}
    
    public string selectedEnrolmentStatus {get; set;}
    public string selectedGrade {get; set;}
    public string selectedCurriculum {get; set;}
    public string selectedStream {get; set;}
    public string selectedSection {get; set;} 
    public string actionToPerform {get; set;}
    public string blockObj {get;set;}
    public string blockAction {get;set;}
    public string blockReason{get;set;}
    public string blockStudent{get;set;}
    public string searchStudentValue{get;set;}
    public string selectedEnrolmentRemark {get; set;}
    public string selectedBlockRemark {get; set;}
    public string academicYearLabel{get; set;}
    public string selectedCriteria {get; set;}
    public string academicYearAPI;
    public string academicYearID;
    public string schoolId;
    public string FutureAYID;
    public string FutureGradeID;
    Id batchId;
    
    public boolean selectAll {get; set;}
    public boolean transferred {get; set;}
    public boolean breakJob {get; set;}
    public boolean displayPopup {get;set;}
    public boolean performedSearch {get;set;}
    public boolean blocked {get;set;}
    
    public map<id,account> idToAccount;
    
    public school__c objSchool {get; set;}
    
    public GEMS_reEnrolmentManagementCtlr() {
    	blockobj='';
    	blockAction = '';
    	blockReason = '';
    	blockStudent = '';
    	searchStudentValue = '';
    	
        schoolId = apexpages.currentPage().getparameters().get('schoolId');
        selectAll = false;
        displayPopUp = false;
        performedSearch = false;
        transferred =  false;
        breakJob = false; 
        blocked = false;
        
        if(string.isNotBlank(schoolId)){
        	getSchoolDetails();
        	getAcademicYear();
	        getReEnrolmentStatus(); //getting populated from promotion object renrolment status field
	        getReEnrolmentRemark();
	        getSearchCriteria();	
        }
        
        selectedBlockRemark = '';
		blockRemark = new list <selectOption>();
		
		Schema.DescribeFieldResult fieldResult = Promotion__c.Block_Reason__c.getDescribe();
	    list<Schema.PicklistEntry> promotions = fieldResult.getPicklistValues();
	    blockRemark.add(new SelectOption('', '--None--'));
	    for(Schema.PicklistEntry  so :  promotions){
  			blockRemark.add(new SelectOption(so.getValue(), so.getLabel()));
    	}
    }
    
    //method to create dropdown from searchCriteria to show on page
	public void getSearchCriteria(){
		searchCriteria = new  List<SelectOption>();
		searchCriteria.add(new SelectOption('', '--None--'));
		searchCriteria.add(new SelectOption('Name', 'Name'));
		searchCriteria.add(new SelectOption('Mobile', 'Mobile'));
		searchCriteria.add(new SelectOption('Email','Email'));
		searchCriteria.add(new SelectOption('Student ID', 'Student ID'));
	} 
    
    //method to create dropdown from reEnrolement status to show on page
	public void getReEnrolmentStatus(){
		reEnrolmentStatus = new  List<SelectOption>();
		reEnrolmentStatus.add(new SelectOption('Pending', 'Pending'));
		reEnrolmentStatus.add(new SelectOption('Blocked', 'Blocked'));
		reEnrolmentStatus.add(new SelectOption('Fee Pending', 'Fee Pending'));
		reEnrolmentStatus.add(new SelectOption('GEMS Staff Re-Enroled / Fee Override', 'GEMS Staff Re-Enroled / Fee Override'));
    	reEnrolmentStatus.add(new SelectOption('Not Re-Enroling', 'Not Re-Enroling'));
    	reEnrolmentStatus.add(new SelectOption('Re-Enroled', 'Re-Enroled'));
    	reEnrolmentStatus.add(new SelectOption('TC Students', 'TC Students'));
    	reEnrolmentStatus.add(new SelectOption('Full Year Tuition Fee Paid', 'Full Year Tuition Fee Paid'));
    	
    	if(reEnrolmentStatus!=null && reEnrolmentStatus.size()>0){
    		selectedEnrolmentStatus = reEnrolmentStatus[0].getValue();
    	}
	} 
	
	//V1.0
	public void getReEnrolmentRemark(){
		reEnrolmentRemark = new List<SelectOption>();
		reEnrolmentRemark.add(new SelectOption('', '--None--'));
		Schema.DescribeFieldResult F = promotion__c.Re_enrolment_Remark__c.getDescribe();
        
        map<string,string> mapOfAY = new map<string,string>();
        if(selectedEnrolmentStatus!='Blocked'){ 
	     	for(Schema.PicklistEntry obj : F.getPicklistValues()){
	     		if(selectedEnrolmentStatus!=obj.getValue() && obj.getValue()!='Re-Enroled'){
	     			
	     			if(selectedEnrolmentStatus=='Pending' && obj.getValue()!='Company Fee Sponsored Pending' && 
	     			   obj.getValue()!='Full Year Tuition Fee Paid')
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
					
	     			if(selectedEnrolmentStatus=='Fee Pending' && obj.getValue()!='Pending')
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
					
					if(selectedEnrolmentStatus=='GEMS Staff Re-Enroled / Fee Override' && obj.getValue()!='Fee Override' && 
					   obj.getValue()!='GEMS Staff Re-Enroled')
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
					
					if(selectedEnrolmentStatus=='Not Re-Enroling' && (obj.getValue()=='Blocked' ||
					   obj.getValue()=='Fee Pending' || obj.getValue()=='Pending'))
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
					
					if(selectedEnrolmentStatus=='Re-Enroled' && obj.getValue()!='Fee Pending' &&
					   obj.getValue()!='Full Year Tuition Fee Paid')
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
					
					if(selectedEnrolmentStatus=='TC Students' && (obj.getValue()=='Blocked' ||
					   obj.getValue()=='Not Re-Enroling' || obj.getValue()=='Pending'))
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
					
					if(selectedEnrolmentStatus=='Full Year Tuition Fee Paid' && obj.getValue()!='Pending')
						reEnrolmentRemark.add(new SelectOption(obj.getLabel(), obj.getValue()));
	     		}
	     	}   
        }
        else{
			reEnrolmentRemark.add(new SelectOption('Unblock', 'Unblock'));	
		}
	}
	
	public void getSchoolDetails(){
		list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:schoolId];
		if(tempSchoolList!=null && tempSchoolList.size()>0){
			objSchool = tempSchoolList[0];
		}	
	}
    
    
    public void getAcademicYear(){
    	list<academic_year__c> tempAYList = [select id, Academic_Year__c from Academic_Year__c where Sys_Active__c = true and School__c=:objSchool.id];
    	if(tempAYList!=null && tempAYList.size()>0)
    		academicYearLabel = tempAYList[0].Academic_Year__c;
    	
    	Schema.DescribeFieldResult F = academic_year__c.year__c.getDescribe();
        
        map<string,string> mapOfAY = new map<string,string>();
        for(Schema.PicklistEntry obj : F.getPicklistValues()){
            mapOfAY.put(obj.getLabel(), obj.getValue());     
        }
        
        if(mapOfAY!=null && mapOfAY.size()>0 && string.isNotBlank(academicYearLabel)){
        	academicYearAPI = mapOfAY.get(academicYearLabel);
        	string futureAYAPI = mapOfAY.get(string.valueOf(integer.valueOf(academicYearAPI)+1));

        	list<academic_year__c> tempList = [select id,year__c from academic_year__c where (year__c=:academicYearAPI or year__c=: futureAYAPI) and Sys_Active__c=true and school__c=:schoolId limit 1];
        	if(tempList!=null && tempList.size()>0){
        		for(academic_year__c ay : tempList){
        			if(ay.year__c == academicYearAPI){
        				academicYearID = ay.id;
        			}
        			else if(ay.year__c == futureAYAPI){
        				FutureAYID = ay.id;	
        			}	
        		}
        	}
        }
        getCurriculumForSchool();
    }
    
    public void getCurriculumForSchool(){
		curriculumList = new list<selectOption>();
		curriculumList = GEMS_Utility.getCurriculumsForSchool(objSchool.id__c, academicYearAPI);
		if(curriculumList!=null && curriculumList.size()>0){
			selectedCurriculum = curriculumList[0].getValue();
		}else{
			selectedCurriculum = '';
			curriculumList.add(new SelectOption('', '--None--'));
		}
		getGradesForSchool();
    }
    
    public void getGradesForSchool(){
		gradeList = new list<selectOption>();
		gradeList = GEMS_Utility.getGradesForSchool(objSchool.id__c, academicYearLabel, selectedCurriculum);
		if(gradeList!=null && gradeList.size()>0){
			selectedGrade = gradeList[0].getValue();
			
			if(string.isNotBlank(selectedGrade)){
               list<grade__c> tempList = [select id, grade__c,Grade_Display__c,Sys_Sort_Val__c from grade__c where id=:selectedGrade];                                
            	if(tempList!=null && tempList.size()>0){
            		integer grade = 0;
	                grade = integer.valueOf(tempList[0].Sys_Sort_Val__c + 1);
	                list<grade__c> tempListGrade = [select id, grade__c,Grade_Display__c from grade__c where Active__c = true
	                                                   and School__c =: objSchool.id and Sys_Sort_Val__c=:decimal.valueOf(grade)
	                                                   and academic_year__c=:futureAYid];
	                if(tempListGrade!=null && tempListGrade.size()>0){
	                    FutureGradeID = tempListGrade[0].id;
	                    
	                }  	
            	}
            }
		}else{
			selectedGrade = '';
			gradeList.add(new SelectOption('', '--None--'));
		}
		
		getStreamsForSchool();
    }
    
    public void getStreamsForSchool(){
		streamList = new list<selectOption>();
		streamList = GEMS_Utility.getStreamsForSchool(objSchool.id__c, futureAYid, getLookupValue(selectedGrade,gradeList));
		if(streamList!=null && streamList.size()>0){
			selectedStream = streamList[0].getValue();
			
		}else{
			selectedStream = '';
			streamList.add(new SelectOption('', '--None--'));
		}
		
		getSectionsForSchool();
    }
    
    public void getSectionsForSchool(){
		sectionList = new list<selectOption>();
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchool.id,academicYearLabel,selectedCurriculum);
		
		string gradeLabel = getLookupValue(selectedgrade,gradeList);
		grade__c grade = new grade__c ();
		if(ay!=null)
			grade = GEMS_Utility.getgradeID(objSchool.id,ay.id ,selectedStream, gradeLabel);
		
		if(ay!=null && grade!=null){
			sectionList = GEMS_Utility.getSectionsForSchool(objSchool.id__c, ay.id,grade.id, selectedStream);
			sectionList.add(new SelectOption('All', 'All'));
			if(sectionList!=null && sectionList.size()>0){
				integer index = sectionList.size();
				selectedSection = sectionList[index-1].getValue();
			}else{
				sectionList = new list<selectOption>();
				selectedSection = '';
				sectionList.add(new SelectOption('', '--None--'));
			}
		}else{
			selectedSection = '';
			sectionList.add(new SelectOption('', '--None--'));
		}
    }
    
    public void clearSearch(){
    	searchStudentValue = '';
    	getStudents();
    }
    
    public void getStudents(){
		try{
	    	academic_year__c ay =  new academic_year__c();
	    	if(string.isNotBlank(academicYearLabel) && string.isNotBlank(selectedCurriculum)){
	    		ay = GEMS_Utility.getAcademicYearID(objSchool.id,academicYearLabel,selectedCurriculum);	
	    	}
	    	
	    	if(string.isNotBlank(selectedGrade) && string.isNotBlank(selectedSection) && ay!=null && string.isNotBlank(schoolId)){
	    		studentList = new list<Account>();
	    		promotionList = new list<promotion__c>();
	    		promotionWrapperList = new list<promotionWrapper>();
	    		
	    		string ayID = ay.id;
	    		string status = 'EN';
	    		string query = '';
	    		
	    		if(selectedSection!='All'){
	    			query = 'select id,Stream__c,GradeLookup__c,Academic_Year__c,firstName,Re_enrolment_Status__c,lastName,middleName '+
					    'from Account where Academic_Year__c=:ayID and school__c=:schoolId '+
					    'and GradeLookup__c =: selectedGrade and Section__c=:selectedSection and Current_Status__c=:status';
	    		}else{
	    			query = 'select id,Stream__c,GradeLookup__c,Academic_Year__c,firstName,Re_enrolment_Status__c,lastName,middleName '+
					    'from Account where Academic_Year__c=:ayID and school__c=:schoolId '+
					    'and GradeLookup__c =: selectedGrade and Current_Status__c=:status';
	    		}
	    		
	    		idToAccount = new map<id,account>();
	    		for(Account tempAcc : Database.query(query)){
	    			studentList.add(tempAcc);
	    			idToAccount.put(tempAcc.id, tempAcc);
	    		}
	    		if(studentList!=null && studentList.size()>0){
					getPromotions(); 
	    		}
	    		else{
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,  'No Students exist, please refine your search criteria.'));
	    		}
	    	}
	    	else{
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  'Please provide all the values'));	
	    	}
    	}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
        }	
    }
    
    public void searchStudents(){
    	if(string.isNotBlank(searchStudentValue)){
    		studentList = new list<Account>();
    		string tempSearchTerm = '("' + searchStudentValue + '")';
    		studentList = 	(List<Account>)[FIND : tempSearchTerm IN All Fields RETURNING Account(id,Stream__c,GradeLookup__c,Academic_Year__c,firstName,Re_enrolment_Status__c,lastName,middleName where Academic_Year__c=:academicYearID and school__c=:schoolId and GradeLookup__c =: selectedGrade and Current_Status__c='EN')][0];
    		if(studentList!=null && studentList.size()>0){
				getPromotions();
    		} else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria'));
            }
    	}
    }
    
    public list<promotionWrapper> getPromotions(){
    	try{
	    	displayPopup = false;
	    	if(studentList!=null && studentList.size()>0){
	    		if(transferred==true){
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Students Updated Successfully.'));	
		        }
			    transferred=false; 
			    
			    if(blocked==true){
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Student Updated Successfully.'));	
		        }
			    blocked=false;
	    		
	    		if(promotionList!=null && promotionList.size()>0){
	    			promotionList.clear();
	    		}
	    		
	    		getReEnrolmentRemark();
	    		
	    		promotionList = new list<promotion__c>();
	    		
	    		string query = 'select id,student__r.student_id__c, student__c, student__r.middleName,student__r.firstName,'+
					  	  'student__r.LastName,student__r.Section_Display__c,Block_Reason__c,Remark__c,'+
					  	  'grade__c, student__r.staff_id__c,Grade__r.grade__c,Re_enrolment_Remark__c,student__r.Primary_Contact__c,'+
					  	  'student__r.Primary_Contact_Email__c,student__r.Is_primary_contact_employee_of_GEMS__c,'+
					  	  'student__r.stream__c, student__r.GradeLookup__c, student__r.academic_year__c'+
					      ' from promotion__c where Student__c IN : studentList and Active__c=true';
	    		
	    		if(selectedEnrolmentStatus=='GEMS Staff Re-Enroled / Fee Override'){
	    			list<string> statusToQuery1 = new list<string>();
	    			statusToQuery1.add('GEMS Staff Re-Enroled');
	    			statusToQuery1.add('Fee Override');
	    		 	
	    		 	query=query+' and Re_enrolment_Remark__c IN : statusToQuery1';
	    		}
	    		else if(selectedEnrolmentStatus == 'TC Students'){
	    			query=query+' and TC_Applied__c=true';	
	    		}
	    		else if(selectedEnrolmentStatus == 'Re-Enroled'){
	    			list<string> statusToQuery2 = new list<string>();
	    			statusToQuery2.add('GEMS Staff Re-Enroled');
	    			statusToQuery2.add('Re-Enroled');
	    			statusToQuery2.add('Company Fee Sponsored Re-Enroled');
	    			statusToQuery2.add('Fee Override');
	    			string Yes = 'Yes';
	    			
	    			query=query+' and Re_enrolment_Remark__c IN : statusToQuery2 and Re_Enroled__c=:Yes';	
	    		}
	    		else if(selectedEnrolmentStatus == 'Fee Pending'){
	    			list<string> statusToQuery3 = new list<string>();
	    			statusToQuery3.add('Fee Pending');
	    			statusToQuery3.add('Company Fee Sponsored Pending');
	    			
	    			query=query+' and Re_enrolment_Remark__c IN : statusToQuery3';
	    		}else{
	    			query=query+' and Re_enrolment_Remark__c=:selectedEnrolmentStatus';
	    		}
	    		system.debug('---query---'+query);
	    		promotionList = Database.query(query);
	    	}

	    	if(promotionList!=null && promotionList.size()>0){
	    		system.debug('---promotionList---'+promotionList);
	    		Integer pageSize = integer.valueOf(System.Label.Pagination_Size);
	    		
	    		this.paginater = new Paginate(promotionList.size(), pageSize);
	    		
	    		promotionWrapperList = new list<promotionWrapper>();
	    		fullPromotionWrapperList = new List<List<promotionWrapper>>();
	    		
	    		list<promotionWrapper> tempCC = new list<promotionWrapper>();
	    		Integer i = 0;
	    		
	    		for(promotion__c obj : promotionList){
		    		
		    		promotionWrapper objPro = new promotionWrapper(obj);
		    		objPro.studentNo = obj.student__r.student_id__c;
		    		if(string.isNotBlank(obj.student__r.FirstName))
		    			objPro.studentName = obj.student__r.FirstName;
		    		
		    		if(string.isNotBlank(obj.student__r.middleName))
		    			objPro.studentName = objPro.studentName +' '+ obj.student__r.middleName;
		    			
		    		if(string.isNotBlank(obj.student__r.lastName))
		    			objPro.studentName = objPro.studentName +' '+obj.student__r.lastName;
		    		
		    		objPro.gradeSection = obj.Grade__r.grade__c+' & '+obj.student__r.Section_Display__c;
		    		objPro.status = obj.Re_enrolment_Remark__c;
		    		
		    		if(objPro.status=='Blocked'){
		    			objPro.block = 'Unblock';	
		    		}
		    		objPro.blockReason = obj.Block_Reason__c;
		    		tempCC.add(objPro);
		    		
		    		i++;
		       		if(i == pageSize){
		       			this.fullPromotionWrapperList.add(tempCC);
		       			tempCC = new List<promotionWrapper>();
		       			i = 0;
		       		}
	    		}
	    		
	    		if(!tempCC.isEmpty()){
	       			this.fullPromotionWrapperList.add(tempCC);
		       	}
		       	//Gets the correct list of data to show on the page
		       	this.PromotionWrapperList = this.fullPromotionWrapperList.get(this.paginater.index);
	    	}
	    	else{
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,  'No Students exist, please refine your search criteria.'));
	    		promotionWrapperList = new list<promotionWrapper>();
    			performedSearch = true;
	    	}
	    	
    	}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    	return promotionWrapperList;	
    }
    
    public void updatePromotions(){
    	Savepoint spdata = Database.setSavepoint();
        try{
	    	if(selectedEnrolmentRemark== 'Blocked'){
	    		displayPopup = true;	
	    	}
	    	else{
	    		boolean noUpdate = false;
		    	list<promotion__c> promotionToUpdate = new list<promotion__c>();
		    	string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Re_Enrolment');
				        
		        list<HexaBPM__Service_Request__c> srToInsert = new list<HexaBPM__Service_Request__c>();
		    	list<promotionWrapper> tempList = new list<promotionWrapper>();
		    	
		    	set<id> studentID = new set<id>();
		    	
		    	for(integer i=0; i<=fullpromotionWrapperList.size()-1; i++){
		    		for(promotionWrapper obj : this.fullPromotionWrapperList.get(i)){
		    			if(obj.selectRecord == true){
		    				tempList.add(obj);
		    			}
		    		}	
		    	}
		    	
		    	
		    	for(promotionWrapper objTemp : tempList){
	    			if(string.isNotBlank(selectedEnrolmentRemark)){
		    			objTemp.objPromo.Remark__c = objTemp.Remark;
		    			if(selectedEnrolmentRemark!= 'Unblock'){
		    				
		    				if(selectedEnrolmentStatus=='Re-Enroled' && selectedEnrolmentRemark== 'Pending'){
		    					studentID.add(objTemp.objPromo.student__c);	
		    					objTemp.objPromo.Re_Enroled__c = '';	
		    				}	
		    				if(selectedEnrolmentStatus=='Fee Pending' && selectedEnrolmentRemark!= 'Company Fee sponsored Pending'){
		    					studentID.add(objTemp.objPromo.student__c);	
		    					objTemp.objPromo.Re_Enroled__c = '';	
		    				}	
		    				if(selectedEnrolmentStatus=='GEMS Staff Re-Enroled / Fee Override' && selectedEnrolmentRemark!= 'Company Fee sponsored Pending' &&
		    				   selectedEnrolmentRemark != 'Company Fee sponsored Re enrolled'){
		    					studentID.add(objTemp.objPromo.student__c);	
		    					objTemp.objPromo.Re_Enroled__c = '';	
		    				}    					
		    				objTemp.objPromo.Re_enrolment_Remark__c = selectedEnrolmentRemark;	
		    			}else{
		    				objTemp.objPromo.Re_enrolment_Remark__c = 'Pending';
							objTemp.objPromo.Block_Reason__c = '';	
		    			}
		    			
		    			if(selectedEnrolmentRemark== 'GEMS Staff Re-Enroled' || selectedEnrolmentRemark== 'Re-Enroled' || selectedEnrolmentRemark== 'Company Fee Sponsored Re-Enroled'){
		    				objTemp.objPromo.Re_Enroled__c = 'Yes';
		    			}
		    			
		    			system.debug('---selectedEnrolmentRemark---'+selectedEnrolmentRemark);
			    		if(selectedEnrolmentRemark == 'Fee Pending'){
			    			objTemp.objPromo.Re_enrolment_Remark__c = 'Fee Pending';
			    			HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
			    			objSR.recordTypeId = recTypeID;
			    			objSR.accept_offer__c ='Yes';
			    			objSR.school__c = objSchool.id;
			    			objSR.student__c = objTemp.objPromo.Student__c;
			    			objSR.HexaBPM__Customer__c = objTemp.objPromo.Student__c;
			                objSR.student__c = objTemp.objPromo.Student__c;
			                objSR.stream__c = objTemp.objPromo.Student__r.stream__c;
			                objSR.Academic_Year__c = objTemp.objPromo.Student__r.Academic_Year__c;    
			                objSR.GradeLookup__c = objTemp.objPromo.Student__r.GradeLookup__c; 
			                objSR.student_Id__c = objTemp.objPromo.Student__r.student_Id__c;
			                objSR.HexaBPM__Email__c = 	objTemp.objPromo.Student__r.Primary_Contact_Email__c;
			                if(objTemp.objPromo.Student__r.Is_primary_contact_employee_of_GEMS__c=='No' || string.isBlank(objTemp.objPromo.Student__r.Is_primary_contact_employee_of_GEMS__c)){
			                	objSR.Is_father_of_Student_an_employee_in_GEMS__c = 'No';
			                	objSR.Is_mother_of_Student_an_employee_in_GEMS__c = 'No';	
			                }
			                else{
			                	if(objTemp.objPromo.student__r.Primary_Contact__c == 'Father'){
			                		objSR.Is_father_of_Student_an_employee_in_GEMS__c = 'Yes';
			                		objSR.Staff_ID__c = objTemp.objPromo.student__r.staff_id__c;
			                		objSR.Is_mother_of_Student_an_employee_in_GEMS__c = 'No';
			                	}
			                	if(objTemp.objPromo.student__r.Primary_Contact__c == 'Mother'){
			                		objSR.Is_father_of_Student_an_employee_in_GEMS__c = 'No';
			                		objSR.Is_mother_of_Student_an_employee_in_GEMS__c = 'Yes';
			                		objSR.Staff_ID_Mother__c = objTemp.objPromo.student__r.staff_id__c;
			                	}
			                }
			                srToInsert.add(objSR);	
			    		}	
			    		promotionToUpdate.add(objTemp.objPromo);
		    		}
		    	}
		    	
		    	system.debug('---studentID---'+studentID);
		    	
		    	if(studentID!=null && studentID.size()>0){
		    		Academic_year__c ay = new Academic_year__c ();
						ay = GEMS_Utility.getAcademicYearID(objSchool.id,academicYearLabel,selectedCurriculum);
					
					string gradeLabel = getLookupValue(selectedgrade,gradeList);
					grade__c grade = new grade__c ();
					if(ay!=null)
						grade = GEMS_Utility.getgradeID(objSchool.id,ay.id ,selectedStream, gradeLabel);
		    		
		    		list<HexaBPM__Service_Request__c> listSR = [select id,StudentId__c,Accept_Offer__c,
		    														   HexaBPM__Internal_SR_Status__c,HexaBPM__External_SR_Status__c,Payment_Status__c,
		    														   (Select Id,HexaBPM__Status__c,Status__c from HexaBPM__SR_Price_Items1__r)
		    												    from HexaBPM__Service_Request__c
		    													where (HexaBPM__Customer__c IN : studentID or student__c IN : studentID)
		    													and Academic_Year__c=: ay.id and GradeLookup__c=:grade.id and HexaBPM__Record_Type_Name__c='Re_Enrolment'];	
		    	
		    		if(listSR!=null && listSR.size()>0){
		    			set<String> srStatusCodes = new Set<String>();
			            srStatusCodes.add('CANCELLED');
			            
			            Map<String,String> srStatusMap = new Map<String,String>();
			            if(!srStatusCodes.isEmpty()){
			                for( HexaBPM__SR_Status__c srStatus : [select Id, HexaBPM__Code__c 
			                						  			   from HexaBPM__SR_Status__c 
			                						  			   where HexaBPM__Code__c IN :srStatusCodes] ){
			                    srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
			                }
			            }
		    			
		    			list<HexaBPM__SR_Price_Item__c> lstSRPTBU = new list<HexaBPM__SR_Price_Item__c>();
		    			for(HexaBPM__Service_Request__c obj : listSR){
	    					if(obj.HexaBPM__SR_Price_Items1__r!=null && obj.HexaBPM__SR_Price_Items1__r.size()>0 &&
	    					   obj.HexaBPM__SR_Price_Items1__r[0].Status__c == 'Paid'){
	    					   	noupdate=true;
	    						ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,  obj.StudentId__c+' has paid the fee already. Please remove the student and try again.'));			
		    				}else{
		    					obj.Accept_Offer__c = '';
		    					obj.HexaBPM__External_SR_Status__c = srStatusMap.get('CANCELLED');
		            			obj.HexaBPM__Internal_SR_Status__c = srStatusMap.get('CANCELLED');
		            			obj.Payment_Status__c = 'No Payment';
		            			if(obj.HexaBPM__SR_Price_Items1__r!=null && obj.HexaBPM__SR_Price_Items1__r.size()>0){
					                    obj.HexaBPM__SR_Price_Items1__r[0].Status__c = 'Cancelled';
					                    obj.HexaBPM__SR_Price_Items1__r[0].HexaBPM__Status__c = 'Cancelled';
					                    lstSRPTBU.add(obj.HexaBPM__SR_Price_Items1__r[0]);
		    					}
			    			}
		    			}
		    			update listSR;
		    			if(lstSRPTBU!=null && lstSRPTBU.size()>0){
		    				update lstSRPTBU;
		    			}
		    		}
		    	}
		    	system.debug('---promotionToUpdate---'+promotionToUpdate);
		    	system.debug('---noUpdate---'+noUpdate);
		    	if(promotionToUpdate!=null && promotionToUpdate.size()>0 && noUpdate==false){
		    		if(string.isNotBlank(selectedEnrolmentRemark) && selectedEnrolmentRemark!='Pending'){
		    			selectedEnrolmentRemark = 'Pending';	
		    		}
		    		
		    		system.debug('---srToInsert---'+srToInsert);
		    		if(srToInsert!=null && srToInsert.size()>0){
						GEMS_interUnitStudentTransferBatch batchJob = new GEMS_interUnitStudentTransferBatch(srToInsert,'','Re_Enrolment') ;
		    			batchId = Database.executeBatch(batchJob,1);
		    		}
		    		update promotionToUpdate;	
		    		transferred = true;
		            selectAll = false;
		            getPromotions();
		    	}
	    	}
    	}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
            Database.rollback(spdata);
        }
    	
    }
    
    public void blockStudent(){
    	Savepoint spdata = Database.setSavepoint();
        try{
	    	
	    	if(string.isNotBlank(blockObj)){
	    		promotion__c objUpdate = new promotion__c();
				objUpdate.id = blockObj;
				if(string.isNotBlank(selectedBlockRemark) && string.isNotBlank(blockAction) && blockAction=='Block'){
					objUpdate.Re_enrolment_Remark__c = 'Blocked';
					objUpdate.Block_Reason__c = selectedBlockRemark;
				}
				
				if(string.isNotBlank(blockAction) && blockAction=='Unblock' && string.isNotBlank(blockReason)){
					objUpdate.Re_enrolment_Remark__c = 'Pending';
					objUpdate.Block_Reason__c = '';	
				}
				update objUpdate;
				
				account accountToUpdate = [select id, Re_enrolment_Status__c from account where id=:blockStudent limit 1];
				accountToUpdate.Re_enrolment_Status__c = objUpdate.Re_enrolment_Remark__c;
				update accountToUpdate;
	    	}
	    	else{
		    	list<promotionWrapper> tempList = new list<promotionWrapper>();
		    	for(integer i=0; i<=fullpromotionWrapperList.size()-1; i++){
		    		for(promotionWrapper obj : this.fullPromotionWrapperList.get(i)){
		    			if(obj.selectRecord == true){
		    				tempList.add(obj);
		    			}
		    		}	
		    	}
		    	system.debug('---tempList----'+tempList);
		    	list<promotion__c> promotionToUpdate = new list<promotion__c>();
		    	for(promotionWrapper objTemp : tempList){
		    		objTemp.objPromo.Re_enrolment_Remark__c = 'Blocked';
					objTemp.objPromo.Block_Reason__c = selectedBlockRemark;	
					promotionToUpdate.add(objTemp.objPromo);
		    	}
		    	update promotionToUpdate;
	    	}
			
			displayPopup = false;
			blocked = true;
			blockObj = '';
			selectedBlockRemark = '';
			getPromotions();
		}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
            Database.rollback(spdata);
        }
    }
    
    public void showPopUp(){
   		displayPopup = true;
   		
   }
   
    public void closePopup() {
        displayPopup = false;
        
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
    
    public class promotionWrapper{
    	public promotionWrapper(promotion__c obj){
    		objPromo = obj;
    		selectRecord = false;
    		studentNo = '';
    		studentName = '';
    		gradeSection = '';
    		block = 'Block';
    		blockReason = '';
    		status = '';
    		remark = '';
    	}
    	
    	public promotion__c objPromo {get;set;}
    	public boolean selectRecord {get; set;}
    	public string studentNo {get; set;}
    	public string studentName {get; set;}
    	public string gradeSection {get; set;}
    	public string status {get; set;}
    	public string block {get; set;}
    	public string blockReason {get; set;}
    	public string remark {get; set;}
    }
    
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
    	this.PromotionWrapperList = this.fullPromotionWrapperList.get(this.paginater.index);
    	return null;
    }
}