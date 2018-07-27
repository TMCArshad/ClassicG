/**************************************************************************************************
* Name               : GEMS_ReferCls                                                 
* Description        : An apex page controller for GEMS_Refer                                             
* Created Date       : PWC - Sandeep                                                                        
* Created By         : 24/SEP/2017                                                                  
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         PWC - Sandeep           24/SEP/2017  
* 1.1         PWC - Swati             21/JAN/2018     Changes to controller                                              
**************************************************************************************************/
public class GEMS_ReferCls {

/**************************************************************************************************
            Variables used in the class
**************************************************************************************************/
    public enquiry__c refer_lead{set;get;}
    public school__c objSchool {get; set;}
    
    public set<string> referLeads;
    public list<enquiry__c> addedReferrals{set;get;}
    
    public boolean hidePage {get; set;}
    public boolean showStream {get;set;}
    public boolean showCurriculum {get;set;}
    public boolean isNonGemsRefferalSchool{get;set;}
    
    public string toDeleteEmail{set;get;}
    public string selectedSchool {get; set;} 
    public string selectedAY {get; set;} 
    public string selectedGrade {get; set;}
    public string selectedStream {get; set;}
    public string selectedCurriculum {get; set;}
    
    public string studentID ='';
    public string parentID ='';
    public string BSUID ='';
    
    public list<SelectOption> schoolList {get; set;}
    public list<SelectOption> academicYearList {get; set;}
    public list<SelectOption> curriculumList {get; set;}
    public list<SelectOption> streamList {get; set;}
    public list<SelectOption> gradeList {get; set;}
/**************************************************************************************************
    Method:         GEMS_ReferCls
    Description:    Constructor executing model of the class 
**************************************************************************************************/
	public GEMS_ReferCls(){
	    GEMS_Utility.isOnline = true;
	    
	    if(ApexPages.CurrentPage().getParameters().get('studentID')!=null)
	        studentID = GEMS_Utility.getDecryptedURLParam(ApexPages.CurrentPage().getParameters().get('studentID'));
	    
	    if(ApexPages.CurrentPage().getParameters().get('BSU')!=null)
	        BSUID = GEMS_Utility.getDecryptedURLParam(ApexPages.CurrentPage().getParameters().get('BSU'));
		
		if(ApexPages.CurrentPage().getParameters().get('parentID')!=null)
			parentID = GEMS_Utility.getDecryptedURLParam(ApexPages.CurrentPage().getParameters().get('parentID'));
			
		if((string.isNotBlank(studentID) && string.isNotBlank(BSUID)) ||
		   (string.isNotBlank(parentID) && string.isNotBlank(BSUID))){
			initiateValues();
	    	getParticipatingSchools();
		}
		system.debug('@@@studentID: '+studentID);
	    system.debug('@@@parentID: '+parentID);
	    system.debug('@@@BSU: '+BSUID);
	}
	
	public void initiateValues(){
		hidePage=false;
	    refer_lead = new enquiry__c(); 
	    addedReferrals = new list<enquiry__c>();
	    referLeads = new set<string>();
	    
	    selectedSchool = '';
	    selectedAY = '';
	    selectedGrade = '';
	    selectedStream = '';
	    selectedCurriculum = '';
	    
	    showStream = false;
        showCurriculum = false;
        isNonGemsRefferalSchool = false;
        
        schoolList = new list<SelectOption>();
        academicYearList = new list<SelectOption>();
        gradeList = new list<SelectOption>();
        streamList = new list<SelectOption>();
        curriculumList = new list<SelectOption>();
        
        schoolList.add(new SelectOption('', '----------------Choose School----------------'));
        academicYearList.add(new SelectOption('', '--None--'));
        gradeList.add(new SelectOption('', '--None--'));
        streamList.add(new SelectOption('', '--None--'));
        curriculumList.add(new SelectOption('', '--None--'));
        
	}


/**************************************************************************************************
    Method:         CreateReferLeads
**************************************************************************************************/
	public void CreateReferLeads(){
	    try{
		        
	        if(string.isNotBlank(refer_lead.FirstName__c) && string.isNotBlank(refer_lead.LastName__c) &&
	           string.isNotBlank(refer_lead.Parent_First_Name__c) && string.isNotBlank(refer_lead.Parent_Last_Name__c) &&
	           refer_lead.email__C!=null && refer_lead.MobilePhone__c!=null && 
	           string.isNotBlank(selectedSchool)){
	        	
	        	list<Academic_year__c> tempAYList = [Select Year__c from Academic_year__c where Id = :selectedAY AND Year__c != NULL];
	        	refer_lead.SchoolLookup__c = selectedSchool;
	        	refer_lead.Academic_Year__c = tempAYList[0].id;
	        	refer_lead.GradeLookup__c = selectedGrade;
	        	refer_lead.Curriculum__c = selectedCurriculum;
	        	//refer_lead.Confirmed_if_GEMS_Student__c = isGemsStudent;
	        	
	        	if(string.isNotBlank(selectedStream)){
	        		refer_lead.Stream__c = selectedStream;
	        	}else{
	        		refer_lead.Stream__c = '1';
	        	}
	        	list<Account> tempAccountList = new list<Account>();
				List<Employee__c> tempEmployeeList = new List<Employee__c>();
	        	Account referralStudent = new Account();
	        	system.debug('--parentID---'+parentID);
	        	
	        	if(string.isNotBlank(parentID)){
					if(parentID.isNumeric() && parentID.length() == 8){
						tempEmployeeList = [SELECT Id, School__c, Email__c,Designation__c
											FROM Employee__c
											WHERE Staff_Number__c = :parentID];
					}else{
						tempAccountList = [select id,School__c, Current_Status__c,Date_Of_Birth__c,
												  Primary_Contact_Email__c, Primary_Contact_Name__c 
										   from Account where Parent_Username__c =: parentID
										   and (Record_Type_Name__c = 'Student' or Record_Type_Name__c = 'Student_Read_Only')
										   order by Date_Of_Birth__c DESC];	
					}
	        	}else{
	    			tempAccountList = [select id,School__c, Current_Status__c, Primary_Contact_Email__c, 
	    			                          Primary_Contact_Name__c
	    			                   from Account where Student_Id__c =: studentID
	    			                   and (Record_Type_Name__c = 'Student' or Record_Type_Name__c = 'Student_Read_Only')];
	        	}
	        	
	        	refer_lead.Enquiry_Source__c = 'Ambassador Program';
	        	System.debug('@@TEMP_EMPLOYEE: '+tempEmployeeList);
	        	if(string.isNotBlank(parentID)){
					refer_lead.Google_Analytics_Source__c = 'GEMS_Rewards';
					refer_lead.Google_Analytics_Medium__c = 'mobile_app';
					refer_lead.Google_Analytics_Campaign__c = 'Ambassador_GEMS_Rewards_App';
				}
	    			
	        	if((tempAccountList!=null && tempAccountList.size()>0) ||
	        	   (tempEmployeeList != null && tempEmployeeList.size() > 0)){
	    			
	    			if(tempAccountList!=null && tempAccountList.size()>0){
		    			refer_lead.Referral_Student__c = tempAccountList[0].id;
			        	refer_lead.Referral_School__c = tempAccountList[0].School__c;
			        	refer_lead.Referral_Email__c = tempAccountList[0].Primary_Contact_Email__c;
			        	refer_lead.Referring_Parent__c = tempAccountList[0].Primary_Contact_Name__c;
		    			
		    			if(tempAccountList[0].Current_Status__c!='EN')
							refer_lead.Manually_Update_Referral__c = true;
	    			}
	    			
	    			if(tempEmployeeList != null && tempEmployeeList.size() > 0){
		    			map<String, Ambassador_Category__c> staffCategory = Ambassador_Category__c.getAll();
						system.debug('---staffCategory---'+staffCategory);
						if(staffCategory.containsKey(tempEmployeeList[0].Designation__c)){
							refer_lead.Eligible_for_Referral_Program__c = true;	
						}
		    			refer_lead.Employee__c = tempEmployeeList[0].Id;
		    			refer_lead.Referral_School__c = tempEmployeeList[0].School__c;
		    			refer_lead.Referral_Email__c = tempEmployeeList[0].Email__c;
		    		}
	    		}else{
	    			refer_lead.Manually_Update_Referral__c = true;
	    		}
	    		
	    		upsert refer_lead;
	        	
	        	system.debug('--refer_lead---'+refer_lead);
	        	initiateValues();
	    		getParticipatingSchools();
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Thank you for being a GEMS Ambassador, we will be in touch with you to update you on the status of your referral.'));
	        }
	        else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide all the details	.'));
	        }
	        
        	
	    }catch(exception ex){
	    	system.debug('-------'+ex.getMessage()+'--------'+ex.getLineNumber());
	        if(!ex.getMessage().contains('Enquiry already exist for the mentioned child.')){
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in creating referral, Please try again or contact GEMS Enrolment Center.'));	
	        }
	    }
	}
/**************************************************************************************************
    Method:         fetchAcademicYear
    Description:    Method to fetch AcademicYear Options by School
**************************************************************************************************/
	
	public void getParticipatingSchools(){
		for (School__c school : [SELECT id, Name,Non_Gems_Referral__c FROM School__c where Is_School_participating_in_Ambassador_pr__c = true ORDER BY Name]) {
        //Both name and Value is school name because Transfer school is saved as text on Lead
            schoolList.add(new SelectOption(school.id, school.Name));
        }
         
        if(schoolList!=null && schoolList.size()>0){
			selectedSchool = schoolList[0].getValue();
			getSchoolDetails();
			getAcademicYear();
		}
	}
	
	public void getSchoolDetails(){
    	objSchool = new school__c();
        refer_lead.Confirmed_if_GEMS_Student__c = null;
        
		list<school__c> tempSchoolList = [select id,id__c, name, logo__C, Non_Gems_Referral__c from school__c where id=:selectedSchool];
		System.debug('tempSchoolList-->'+tempSchoolList);
		if(tempSchoolList!=null && tempSchoolList.size()>0){
			objSchool = tempSchoolList[0];
			isNonGemsRefferalSchool = tempSchoolList[0].Non_Gems_Referral__c; 
		}	
		getAcademicYear();
	}
 
	public void getAcademicYear(){
		GEMS_Utility.isOnline = true;
    	academicYearList = new list<selectOption>();
    	academicYearList.add(new SelectOption('', '--None--'));
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
    	GEMS_Utility.isOnline = true;
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
    	GEMS_Utility.isOnline = true;
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
    	GEMS_Utility.isOnline = true;
		streamList = new list<selectOption>();
		string AYLabel = getLookupValue(selectedAY,academicYearList);
		Academic_year__c ay = new Academic_year__c ();
		ay = GEMS_Utility.getAcademicYearID(objSchool.id,AYLabel,selectedCurriculum);
		
		if(ay!=null)
			streamList = GEMS_Utility.getStreamsForSchool(objSchool.id__c, getLookupValue(selectedAY,academicYearList), getLookupValue(selectedGrade,gradeList));
		if(streamList!=null && streamList.size()>0){
			selectedStream = streamList[0].getValue();
			
		}else{
			selectedStream = '';
			streamList.add(new SelectOption('', '--None--'));
		}
		
		if(streamList!=null && streamList.size()>1)
			showStream = true;
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
}