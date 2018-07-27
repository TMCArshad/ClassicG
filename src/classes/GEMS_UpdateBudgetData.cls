global without sharing class GEMS_UpdateBudgetData {
    
    public static map<id,capacity_master__c> capacityMap;
    public static set<capacity_master__c> updateBudgetMaster;
    	
    webservice static String updateSchoolBudget(string schoolID){
    	string msg = 'Success';
    	try{
    		capacityMap = new map<id,capacity_master__c>();
    		updateBudgetMaster = new set<capacity_master__c>();
    		
    		getCapacity(schoolID);
    		
    		getCurrenEnrolmentStatus(schoolID);	
    		
    		getReEnroledStudents(schoolID);
    		
    		getNewAcceptance(schoolID);
    		
    		getWaitList(schoolID);
    		
    		getWaitlistDueToSEN(schoolID);
    		
    		getOffersSentWithin7Days(schoolID);
    		
    		getAssessmentPending(schoolID);
    		
    		getRegistrations(schoolID);
    		
    		getEnquiries(schoolID);
    		
    		getFutureDatedTC(schoolID);
    		
    		if(capacityMap!=null && capacityMap.size()>0){
    			system.debug('---capacityMap---'+capacityMap);
    			update capacityMap.values();
    		}
    		
    	}catch(exception ex){
    		msg = ex.getMessage()+'----'+ex.getLineNumber();
    	}
    	return msg;
    }	
    
    public static void getCapacity(string schoolID){
    	String query = GEMS_Utility.getAllFields(capacity_master__c.getsObjectType().getDescribe());
    	query += ' WHERE school__c =: schoolID and active__c=true';
    	
    	if(Database.query(query)!=null && Database.query(query).size()>0){
    		for(capacity_master__c obj : Database.query(query)){
    			capacityMap.put(obj.grade__c,obj);	
    		}
    		system.debug('---capacityMap.keyset()---'+capacityMap.keyset());	
    	}
    }
    
    public static void getCurrenEnrolmentStatus(string schoolID){
    	map<ID,integer> currentEnrolledCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM Account WHERE Current_Status__c = 'EN' 
    										and school__c=:schoolId
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    currentEnrolledCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}	
		}
		
		system.debug('---currentEnrolledCount---'+currentEnrolledCount);
		if(currentEnrolledCount!=null && currentEnrolledCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(currentEnrolledCount.get(obj)>0){
					capacityMap.get(obj).Current_Enrolment__c = currentEnrolledCount.get(obj);
				}
				else{
					capacityMap.get(obj).Current_Enrolment__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}
    }
    
    public static void getReEnroledStudents(string schoolID){
    	map<ID,integer> currentReEnrolledCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), Grade__c 
    										FROM Promotion__c WHERE (Re_Enroled__c = 'Yes' or Re_enrolment_Remark__c='Re-Enroled')
    										and school__c=:schoolId
    										and Grade__c IN : capacityMap.keyset()
    										group by Grade__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    currentReEnrolledCount.put((ID)ar.get('Grade__c'),(integer)ar.get('expr0'));
			}	
		}
		
		system.debug('---currentReEnrolledCount---'+currentReEnrolledCount);
		if(currentReEnrolledCount!=null && currentReEnrolledCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(currentReEnrolledCount.get(obj)>0){
					capacityMap.get(obj).Re_Enroled__c = currentReEnrolledCount.get(obj);
				}else{
					capacityMap.get(obj).Re_Enroled__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
    }
    
    public static void getNewAcceptance(string schoolID){
		date dateOfJoin = system.today();
		map<ID,integer> newAcceptanceCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM Account WHERE Current_Status__c = 'EN' 
    										and school__c=:schoolId and Date_of_Join__c>:dateOfJoin
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    newAcceptanceCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---newAcceptanceCount---'+newAcceptanceCount);
		if(newAcceptanceCount!=null && newAcceptanceCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(newAcceptanceCount.get(obj)>0){
					capacityMap.get(obj).New_Acceptances__c = newAcceptanceCount.get(obj);
				}
				else{
					capacityMap.get(obj).New_Acceptances__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}
    }
    
    public static void getWaitList(string schoolID){
    	map<ID,integer> waitListCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM HexaBPM__Service_Request__c WHERE school__c=:schoolId 
    										and HexaBPM__Record_Type_Name__c='Enrollment'
    										and Is_SR_Closed__c = false
    										and Registration_Type__c = 'Waitlist'
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    waitListCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---waitListCount---'+waitListCount);
		if(waitListCount!=null && waitListCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(waitListCount.get(obj)>0){
					capacityMap.get(obj).Waitlist__c = waitListCount.get(obj);
				}
				else{
					capacityMap.get(obj).Waitlist__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
    }
    
    public static void getWaitlistDueToSEN(string schoolID){
    	map<ID,integer> waitListCountDueToSEN = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM HexaBPM__Service_Request__c WHERE school__c=:schoolId 
    										and HexaBPM__Record_Type_Name__c='Enrollment'
    										and Is_SR_Closed__c = false
    										and Registration_Type__c = 'Waitlist'
    										and Child_have_any_special_education_needs__c = 'Yes'
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    waitListCountDueToSEN.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---waitListCountDueToSEN---'+waitListCountDueToSEN);
		if(waitListCountDueToSEN!=null && waitListCountDueToSEN.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(waitListCountDueToSEN.get(obj)>0){
					capacityMap.get(obj).Waitlist_due_to_SEN__c = waitListCountDueToSEN.get(obj);
				}
				else{
					capacityMap.get(obj).Waitlist_due_to_SEN__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
    }
    		
	public static void getOffersSentWithin7Days(string schoolID){
		map<ID,integer> OffersSentCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM HexaBPM__Service_Request__c WHERE school__c=:schoolId 
    										and HexaBPM__Record_Type_Name__c='Enrollment'
    										and Is_SR_Closed__c = false
    										and Offer_Send_Date__c = LAST_N_DAYS:7
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    OffersSentCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---OffersSentCount---'+OffersSentCount);
		if(OffersSentCount!=null && OffersSentCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(OffersSentCount.get(obj)>0){
					capacityMap.get(obj).Offers_Sent_in_7Days__c = OffersSentCount.get(obj);
				}
				else{
					capacityMap.get(obj).Offers_Sent_in_7Days__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
	}
	
	public static void getAssessmentPending(string schoolID){
		map<ID,integer> assessmentPendingCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), HexaBPM__SR__r.GradeLookup__c 
    										FROM HexaBPM__Step__c WHERE school__c=:schoolId 
    										and HexaBPM__SR__r.HexaBPM__Record_Type_Name__c='Enrollment'
    										and HexaBPM__SR__r.Is_SR_Closed__c = false
    										and HexaBPM__SR__r.GradeLookup__c IN : capacityMap.keyset()
    										and Step_Name__c = 'Assessment/Screening'
    										and Is_Closed__c = false
    										and HexaBPM__Status_Type__c != 'End'
    										group by HexaBPM__SR__r.GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    assessmentPendingCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---assessmentPendingCount---'+assessmentPendingCount);
		if(assessmentPendingCount!=null && assessmentPendingCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(assessmentPendingCount.get(obj)>0){
					capacityMap.get(obj).Assessments_Pending__c = assessmentPendingCount.get(obj);
				}
				else{
					capacityMap.get(obj).Assessments_Pending__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
	}
	
	public static void getRegistrations(string schoolID){
		map<ID,integer> RegistrationsCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM HexaBPM__Service_Request__c WHERE school__c=:schoolId 
    										and HexaBPM__Record_Type_Name__c='Enrollment'
    										and Is_SR_Closed__c = false
    										and HexaBPM__External_Status_Name__c != 'Draft'
    										and HexaBPM__External_Status_Name__c != 'Submitted'
    										and HexaBPM__External_Status_Name__c != 'Enrolled'
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    RegistrationsCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---RegistrationsCount---'+RegistrationsCount);
		if(RegistrationsCount!=null && RegistrationsCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(RegistrationsCount.get(obj)>0){
					capacityMap.get(obj).Registrations__c = RegistrationsCount.get(obj);
				}
				else{
					capacityMap.get(obj).Registrations__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
	}
	
	public static void getEnquiries(string schoolID){
		map<ID,integer> enquiriesCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM Enquiry__c WHERE SchoolLookup__c=:schoolId 
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    enquiriesCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---enquiriesCount---'+enquiriesCount);
		if(enquiriesCount!=null && enquiriesCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(enquiriesCount.get(obj)>0){
					capacityMap.get(obj).Enquiries__c = enquiriesCount.get(obj);
				}
				else{
					capacityMap.get(obj).Enquiries__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
	}
	
	public static void getFutureDatedTC(string schoolID){
		date dateOfLeaving = system.today();
		map<ID,integer> futureDatedTCCount = new map<ID,integer>();
    	AggregateResult[] groupedResults = [SELECT COUNT(Id), GradeLookup__c 
    										FROM HexaBPM__Service_Request__c WHERE school__c=:schoolId 
    										and HexaBPM__Record_Type_Name__c='TC_Request'
    										and (Date_of_Leaving__c>=:dateOfLeaving or Date_of_Leaving__c=null)
    										and GradeLookup__c IN : capacityMap.keyset()
    										group by GradeLookup__c];
		
		if(groupedResults!=null && groupedResults.size()>0){
			for (AggregateResult ar : groupedResults)  {
			    futureDatedTCCount.put((ID)ar.get('GradeLookup__c'),(integer)ar.get('expr0'));
			}
		}
		
		system.debug('---futureDatedTCCount---'+futureDatedTCCount);
		if(futureDatedTCCount!=null && futureDatedTCCount.size()>0 &&
		   capacityMap!=null && capacityMap.size()>0){
			
			for(string obj : capacityMap.keyset()){
				if(futureDatedTCCount.get(obj)>0){
					capacityMap.get(obj).Future_Dated_TC__c = futureDatedTCCount.get(obj);
				}
				else{
					capacityMap.get(obj).Future_Dated_TC__c = 0;
				}
				updateBudgetMaster.add(capacityMap.get(obj));
			}
		}	
	}
}