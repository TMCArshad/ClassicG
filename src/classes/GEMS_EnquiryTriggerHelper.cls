/*****************************************************************************************************************************
       Modification History
--------------------------------------------------------------------------------------------------------------------------
	Version		Author		Date			Description
	V1.0		Umair Khan	18-Dec-2017		Remove condition 'Non-Digital' to create task for Tour Booked
    V1.1		Umair Khan  19-Dec-2017		1.Replace 'Non-Digital' with 'Short Form' and 'Long Form' in conditions
                                            2. Replace 'Non-Digital' with 'Short Form' only when value is assigning.
	V1.2		Swati		31-Jan-2017		remove delete access for corporate
*****************************************************************************************************************************/

public without sharing class GEMS_EnquiryTriggerHelper {
    
    public static Date activityDate {get; set;}
    public static String activityDatefieldName {get; set;}
    public static String subjectVal {get; set;}
    
    public GEMS_EnquiryTriggerHelper() {} 

    public static void assignEnquiryToQueue(list <Enquiry__c> Enquiry_List, String queueType , boolean changeOwner) {
        map<string, GEMS_Site_Domain_Config__c> siteConfig = GEMS_Site_Domain_Config__c.getAll();
        map<String, Id> schoolToQueueIdMap = GEMS_Utility.getSchoolCodeToQueueIdMap(queueType);
        map<Id,String> schoolIdtoCodeMap = new map<Id,String>();
        map<Id,School__c> schoolMap = new map<Id,School__c>();
       
        system.debug('schoolToQueueIdMap>>>>>>' + schoolToQueueIdMap);
        system.debug('Enquiry_List>>>>>>' + Enquiry_List);
        
        
	    list<Id> schoolIdList = new list<Id>();
	    for (Enquiry__c obj : Enquiry_List) {
	      schoolIdList.add(obj.SchoolLookup__c);
	    }
	    for (School__c s : [Select Short_Name__c,logo__c,generic_email_address__c, Id from School__c WHERE ID IN :schoolIdList AND  Short_Name__c != NULL  ]) {
	      schoolIdtoCodeMap.put(s.Id, s.Short_Name__c);
	      schoolMap.put(s.Id, s);
	    }
	    if(Enquiry_List!=null && Enquiry_List.size()>0){
	    	map<id, id> enquiryToSRMap = new map<id, id>();
	    	if(changeOwner == true){
		    	list<HexaBPM__Service_Request__c> tempList = [select id, enquiry__c from HexaBPM__Service_Request__c where enquiry__c IN : Enquiry_List];
	    		if(tempList!=null && tempList.size()>0){
		    		for(HexaBPM__Service_Request__c obj : tempList){
		    			enquiryToSRMap.put(obj.enquiry__c, obj.id);
		    		}
	    		}			
	    	}
	    	for (Enquiry__c objEnquiry : Enquiry_List) {
	        	//Set Lead reference number 
	        	objEnquiry.Lead_Reference__c = GEMS_Utility.generateLeadRefNumber(); 
	            objEnquiry.Pardot_EnrollNow_URL__c = GEMS_Utility.generatePardotEnrollNowURL(objEnquiry.School_Code__c,objEnquiry.Lead_Reference__c,siteConfig.get(objEnquiry.School_Short_Name__c));
	            objEnquiry.Lead_No__c  = 1;
	            if(changeOwner == false){
	                //V1.1
		            if (objEnquiry.Enquiry_Source__c != 'Short Form' || objEnquiry.Enquiry_Source__c != 'Long Form') {//objEnquiry.Enquiry_Source__c != 'Non-Digital'
		            	//If Shchool is associated  AND School associated with the lead has a config then pick the queue and set it as Owner
		                if (schoolToQueueIdMap.containsKey(schoolIdtoCodeMap.get(objEnquiry.SchoolLookup__c))) 
		                    objEnquiry.OwnerId = schoolToQueueIdMap.get(schoolIdtoCodeMap.get(objEnquiry.SchoolLookup__c));
		                else if(objEnquiry.SchoolLookup__c == NULL) 
		                    objEnquiry.OwnerId = schoolToQueueIdMap.get('GEMS Central Enrollment Officer'); 
		            }
	            }else{
	            	if(enquiryToSRMap!=null && enquiryToSRMap.size()>0 && enquiryToSRMap.get(objEnquiry.id)!=null){
	            		objEnquiry.addError('SR has been created for this enquiry, Please do cross-sell referral using button on school.');		
	            	}
	            	else{
		            	//If Shchool is associated  AND School associated with the lead has a config then pick the queue and set it as Owner
		                if (schoolToQueueIdMap.containsKey(schoolIdtoCodeMap.get(objEnquiry.SchoolLookup__c))) 
		                    objEnquiry.OwnerId = schoolToQueueIdMap.get(schoolIdtoCodeMap.get(objEnquiry.SchoolLookup__c));
		                else if(objEnquiry.SchoolLookup__c == NULL)  
		                    objEnquiry.OwnerId = schoolToQueueIdMap.get('GEMS Central Enrollment Officer'); 
	            	}
	            }
	            
	            if(schoolMap!=null && schoolMap.size()>0 && schoolMap.get(objEnquiry.SchoolLookup__c)!=null){
	            	
	            	objEnquiry.School_Logo__c = schoolMap.get(objEnquiry.SchoolLookup__c).logo__c;	
	            	objEnquiry.Sys_Registrar_Email__c = schoolMap.get(objEnquiry.SchoolLookup__c).generic_email_address__c;
	            }
	        }	
	    }
    }
    
	public static void assignSupportUserFromSchool(list <Enquiry__c> Enquiry_List){
		List<Id> schoolId_List = new list<Id>();
		map<Id,Id> schoolIdtoRegistrarIdMap = new map<Id,Id>();
		//get all school Ids
		for(Enquiry__c obj : Enquiry_List){
			schoolId_List.add(obj.SchoolLookup__c);
		}
		//Get school --> registrar user map 
		for(School__c s : [SELECT Id,Registrar__c FROM School__c WHERE ID IN:schoolId_List]){
			schoolIdtoRegistrarIdMap.put(s.Id,s.Registrar__c);
		}
		for(Enquiry__c obj : Enquiry_List){
			//If School has registrar assign it as support user on lead
			obj.Support_User__c = (obj.SchoolLookup__c != NULL && schoolIdtoRegistrarIdMap.containsKey(obj.SchoolLookup__c)) ? schoolIdtoRegistrarIdMap.get(obj.SchoolLookup__c) :  obj.Support_User__c;
		}
	}

	public static void assignEnquiryToCentralEnrolmentOfficerQueue(list <Enquiry__c> Enquiry_List,String queueType ) {
        map<String, Id> schoolToQueueIdMap = GEMS_Utility.getSchoolCodeToQueueIdMap(queueType);
        for (Enquiry__c obj : Enquiry_List) {
            //V1.1
            if(obj.Enquiry_Source__c != 'Short Form' || obj.Enquiry_Source__c != 'Long Form')//obj.Enquiry_Source__c != 'Non-Digital'
            	obj.OwnerId = schoolToQueueIdMap.get('GEMS Central Enrollment Officer'); 
        }
    }

    public static void createTaskandAssignitToOwner(list <Enquiry__c> Enquiry_List) {
        list<task> TaskCreate_List = new list<task>();
        for (Enquiry__c Obj :  Enquiry_List) {
             //V1.0 
            //If(Obj.Enquiry_Source__c != 'Non-Digital')
            TaskCreate_List.add(createTask(Obj, Obj.OwnerId, 'Normal', 'Open'));
        }
        if (TaskCreate_List.size() > 0) {
            insert TaskCreate_List;
        }
        activityDate = NULL;
        activityDatefieldName = NULL;
        subjectVal = NULL;
    }

    public static list<Enquiry__c> getAllEnquiryAcceptedByUser(list<Enquiry__c> Enquiry_List, map<id, Enquiry__c> oldMap) {
        list<Enquiry__c> enquiryReturnList = new list<Enquiry__c>();
        for (Enquiry__c Obj :  Enquiry_List) {
            if (String.valueOf(oldMap.get(Obj.Id).OwnerId).startsWith('00G')  && String.valueOf(Obj.OwnerId).startsWith('005') ) {
                enquiryReturnList.add(Obj);
            }
        }
        return enquiryReturnList;
    }

    public static list<Enquiry__c> getAllEnquiryWithStatus(list <Enquiry__c> Enquiry_List, map<Id,Enquiry__c> oldMap, String statusVal, String subStatusVal, Boolean skipChangeOfStatus, Boolean skipChangeOfSubStatus) {
        list <Enquiry__c> enquiryReturnList = new list <Enquiry__c>();
        list <Enquiry__c> EnquiryList = new list <Enquiry__c>();
        for (Enquiry__c obj : Enquiry_List) {
            if (obj.status__c == statusVal && !(string.valueOf(obj.ownerId).startsWith('00G')) && (skipChangeOfStatus || (oldMap.get(obj.id).Status__c != obj.status__c))) {
                EnquiryList.add(obj);
            }
        }
        if (subStatusVal == '') {
            enquiryReturnList = EnquiryList;
        } else {
            enquiryReturnList = getAllEnquiryWithSubstatus(EnquiryList, oldMap, subStatusVal, skipChangeOfSubStatus);
        }
        return enquiryReturnList;
    }

   public static void checkForDuplicates(Enquiry__c Obj){
   	        //Assuming no bulk operation 
	         if(GEMS_Validations.checkForDuplicates(Obj)){
	              Obj.addError('Enquiry already exist for the mentioned child.');
	         }
   }
   
   public static list <Enquiry__c> getEnquiryAssignedToAnotherSchool(list <Enquiry__c> Enquiry_List, map <Id, Enquiry__c> oldmap) {

        list <Enquiry__c> enquiryListForTaskAssignment = new list <Enquiry__c>();
        //List < Lead > leadList = getAllLeadsWithStatus(lead_list, oldMap, GEMS_Constants.ASSIGNED_TO_ANOTHER_SCHOOL, '', false, false);
        for (Enquiry__c Obj: Enquiry_List) {
            //School code was updated
            if (Obj.School_Name__c != oldMap.get(Obj.Id).School_Name__c) {
                enquiryListForTaskAssignment.add(Obj);
            }
        }
        return enquiryListForTaskAssignment;
    }

    public static list <Enquiry__c> getAllEnquiryWithSubstatus(list <Enquiry__c> Enquiry_List, map<id,Enquiry__c> oldMap, String statusVal, Boolean skipChangeOfSubStatus) {
        list <Enquiry__c> enquiryReturnList = new list <Enquiry__c>();
        for (Enquiry__c Obj : Enquiry_List) {
            if (Obj.Sub_Status__c == statusVal && (skipChangeOfSubStatus || (oldMap.get(Obj.Id).Sub_Status__c != Obj.Sub_Status__c))) {
                enquiryReturnList.add(Obj);
            }
        }
        return enquiryReturnList;
    }

    public static Task createTask(Enquiry__c Obj, Id OwnerId, String Priority, String Status) {
        //Either use same value for all tasks or use from leadobj
        Date dueDate = (activityDate == NULL) ? Date.valueOf(Obj.get(activityDatefieldName)) : activityDate;
        Task taskObj = new task();
        taskObj.WhatId = Obj.Id;
        taskObj.OwnerId = OwnerId;
        taskObj.Priority = Priority;
        taskObj.Status = Status;
        taskObj.Subject = subjectVal;
        taskObj.ActivityDate = dueDate;
        return taskObj;
    }
    
    public static list <Enquiry__c> syncLeadAndEnquiryOnInsert(list <Enquiry__c> enquiryList){
		//to make it dynamic get fieldMap
        Enquiry__c objEnquiry = new Enquiry__c(); 
        Schema.SObjectType objType = objEnquiry.getSObjectType(); 
        map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Enquiry__c.fields.getMap(); 
		
		//get custom setting from Lead_Enquiry_Sync__c to get field that needs to be copied
		map<String, Lead_Enquiry_Sync__c> LeadEnquirySync = Lead_Enquiry_Sync__c.getAll();
		//map of lead API name and enquiry API name
		map<string, string> leadEnquiryAPImap = new map<string, string>();
		for(string test : LeadEnquirySync.keySet()){
			if(LeadEnquirySync.get(test).Lead_API_Name__c!=null && LeadEnquirySync.get(test).Enquiry_API_Name__c!=null){
				leadEnquiryAPImap.put(LeadEnquirySync.get(test).Enquiry_API_Name__c.toLowerCase(), LeadEnquirySync.get(test).Lead_API_Name__c.toLowerCase());
			}
		}
		system.debug('---leadEnquiryAPImap---'+leadEnquiryAPImap);
		list<Lead> listOfLead = new list<Lead>();
		for(Enquiry__c enquiryObj : enquiryList){
			if(enquiryObj.lead__c!=null){
				
			}
			else{
    			Lead objLead = new Lead();
    			objLead.enquiry__c = enquiryObj.id;
                for (String str : mapFields.keySet()) {
                    string strEnquiry = str.toLowerCase();
                    //check if field is populated
                    //check if field exist in custom setting
                    //check if field is updateable
                    if(enquiryObj.get(strEnquiry)!=null && leadEnquiryAPImap.get(strEnquiry)!=null){
                    	string strLead = '';
                    	if(strEnquiry.containsIgnoreCase('pi_')){//remove __ from pardot fields
                    		strLead = strEnquiry.remove('pi_');
                    		strLead = 'pi__'+strLead;
                    	}
                    	else{
                    		strLead = strEnquiry;
                    	}
                    	
                    	//put values in respective fields
                    	if(strEnquiry == 'Enquiry_Source__c'){
                    		objLead.put('leadsource',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'isconverted__c'){
                    	}else if(strEnquiry == 'email__c'){
                    		objLead.put('email',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'ownerid__c'){
                    		objLead.put('ownerid',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'status__c'){
                    		objLead.put('status',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'mobilephone__c'){
                    		objLead.put('mobilephone',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'firstname__c'){
                    		objLead.put('firstname',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'lastname__c'){
                    		objLead.put('lastname',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'middlename__c'){
                    		objLead.put('middlename',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'phone__c'){
                    		objLead.put('phone',enquiryObj.get(strEnquiry));		
                    	}else if(strEnquiry == 'salutation__c'){
                    		objLead.put('salutation',enquiryObj.get(strEnquiry));		
                    	}
                    	else{
                    		objLead.put(strLead,enquiryObj.get(strEnquiry));	
                    	}
                    }
                }   
                listOfLead.add(objLead);
			}
		}
		
        map<id,id> mapLeadEnquiry = new map<id,id>();  
        if(listOfLead!=null && listOfLead.size()>0){
        	insert listOfLead;	
        	for(Lead obj : listOfLead){
        		mapLeadEnquiry.put(obj.enquiry__c, obj.id);	
        	}
        }
        //once enquiry get inserted same needs to be copied back to the lead.
    	if(mapLeadEnquiry!=null && mapLeadEnquiry.size()>0){
    		list<Enquiry__c> EnquiryToUpdate = new list<Enquiry__c>();
    		for(Enquiry__c enquiryObj : [select id, lead__c from Enquiry__c where id IN : mapLeadEnquiry.keyset()]){
    			enquiryObj.lead__c = mapLeadEnquiry.get(enquiryObj.id)!=null ? mapLeadEnquiry.get(enquiryObj.id) : null;	
    			EnquiryToUpdate.add(enquiryObj);
    		}
    		update 	EnquiryToUpdate;
    	}
	
    	return 	enquiryList;
    }
    
    public static list <Enquiry__c> syncLeadAndEnquiryOnUpdate(list<Enquiry__c> enquiryList, map<Id, Enquiry__c> oldMap){
    	
        //to make it dynamic get fieldMap
        Enquiry__c objEnquiry = new Enquiry__c(); 
        Schema.SObjectType objType = objEnquiry.getSObjectType(); 
        map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Enquiry__c.fields.getMap(); 
		//get custom setting from Lead_Enquiry_Sync__c to get field that needs to be copied
		map<String, Lead_Enquiry_Sync__c> LeadEnquirySync = Lead_Enquiry_Sync__c.getAll();

		//map of lead API name and enquiry API name
		map<string, string> leadEnquiryAPImap = new map<string, string>();
		for(string test : LeadEnquirySync.keySet()){
			if(LeadEnquirySync.get(test)!=null && LeadEnquirySync.get(test).Lead_API_Name__c!=null && LeadEnquirySync.get(test).Enquiry_API_Name__c!=null){
				leadEnquiryAPImap.put(LeadEnquirySync.get(test).Enquiry_API_Name__c.toLowerCase(), LeadEnquirySync.get(test).Lead_API_Name__c.toLowerCase());
			}
		}
		system.debug('---leadEnquiryAPImap---'+leadEnquiryAPImap);
		set<string> setOfChangedFields =  new set<string>();        
        list<Enquiry__c> Enquiry_List = new list<Enquiry__c>();
        for(Enquiry__c newRecord : EnquiryList){
            if(newRecord.lead__c != null){
                Enquiry__c oldRecord = oldMap.get(newRecord.Id);
                Enquiry_List.add(newRecord); //list of lead on which change was done
                if(mapFields!=null && mapFields.size()>0){
                    for (String str : mapFields.keyset()) {
                    	if(newRecord.get(str)!=null && leadEnquiryAPImap.get(str)!=null){
                        	
                        	if(leadEnquiryAPImap.get(str)!=null && newRecord.get(str) != oldRecord.get(str)){
                            	system.debug('---str---'+str);
                            	setOfChangedFields.add(str); //list of fields that got changed
                        	}
                    	}
                    }
                }
            }       
        }
        map<id,Lead> existingLeadForEnquiry = new map<id,Lead>();
        for(Lead obj : [select id, enquiry__c from Lead where enquiry__c in : Enquiry_List]){
        	existingLeadForEnquiry.put(obj.enquiry__c, obj);	
        }
        system.debug('---setOfChangedFields---'+setOfChangedFields);
        system.debug('---existingLeadForEnquiry---'+existingLeadForEnquiry);
        
        list<Lead> leadToUpdate = new list<Lead>();
        if(existingLeadForEnquiry!=null && existingLeadForEnquiry.size()>0){
            for(Enquiry__c enquiryObj : Enquiry_List){
                if(existingLeadForEnquiry.get(enquiryObj.id)!=null){
                	Lead objLead = new Lead();
                	objLead = existingLeadForEnquiry.get(enquiryObj.id);	
	                for (String strEnquiry : setOfChangedFields) {
	                	string strLead = '';
	                	if(strEnquiry.containsIgnoreCase('pi_')){//remove __ from pardot fields
	                		strLead = strEnquiry.remove('pi_');
	                		strLead = 'pi__'+strLead;
	                	}
	                	else{
	                		strLead = strEnquiry;
	                	}
	                	
	                	//put values in respective fields
	                	if(strEnquiry == 'Enquiry_Source__c'){
	                		objLead.put('leadsource',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'isconverted__c'){
	                	}else if(strEnquiry == 'email__c'){
	                		objLead.put('email',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'ownerid__c'){
	                		objLead.put('ownerid',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'status__c'){
	                		objLead.put('status',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'mobilephone__c'){
	                		objLead.put('mobilephone',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'firstname__c'){
	                		objLead.put('firstname',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'lastname__c'){
	                		objLead.put('lastname',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'middlename__c'){
	                		objLead.put('middlename',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'phone__c'){
	                		objLead.put('phone',enquiryObj.get(strEnquiry));		
	                	}else if(strEnquiry == 'salutation__c'){
	                		objLead.put('salutation',enquiryObj.get(strEnquiry));		
	                	}
	                	else{
	                		objLead.put(strLead,enquiryObj.get(strEnquiry));	
	                	}
	                }   
	                leadToUpdate.add(objLead); 
                }         
            }
        }
        system.debug('---leadToUpdate---'+leadToUpdate);
        if(leadToUpdate!=null && leadToUpdate.size()>0){
            update leadToUpdate;
        }
    	return 	enquiryList;
    }
    
    public static void deleteRelatedRecords(List <Enquiry__c> Enquiry_List){
    	set<id> setOfEnquiryId = new set<id>();
    	set<id> setOfLeadId = new set<id>();
    	list<Lead> listOfLead = new list<Lead>();
    	list<HexaBPM__Service_Request__c> listOfSR = new list<HexaBPM__Service_Request__c>();
    	list<HexaBPM__Step__c> listOfStep = new list<HexaBPM__Step__c>();
    	list<EnquiryRelationship__c> listOfFamilyDetail = new list<EnquiryRelationship__c>();
    	
    	if(Enquiry_List!=null && Enquiry_List.size()>0){
    		for(Enquiry__c obj : Enquiry_List){
    			if(obj.lead__c!=null){
    				setOfLeadId.add(obj.lead__c);
    			}	
    			setOfEnquiryId.add(obj.id);
    		}	
    	}	
    	
    	if(setOfLeadId!=null && setOfLeadId.size()>0 && setOfEnquiryId!=null && setOfEnquiryId.size()>0){
    		listOfSR = [select id from HexaBPM__Service_Request__c where lead__c IN : setOfLeadId or enquiry__c IN : setOfEnquiryId];		
    		listOfStep = [select id from HexaBPM__Step__c where HexaBPM__SR__c IN : listOfSR];
    		listOfLead = [select id from lead where id IN : setOfLeadId];
    		listOfFamilyDetail = [select id from EnquiryRelationship__c 
    							  where lead__c IN : setOfLeadId or 
    							  enquiry__c IN : setOfEnquiryId or 
    							  Sibling_Lead__c IN : setOfLeadId or 
    							  Sibling_Enquiry__c IN : setOfEnquiryId];	
    		
    		if (listOfStep != null && listOfStep.size() > 0) {
                delete listOfStep;
            }
            
    		if(listOfSR!=null && listOfSR.size()>0){
    			delete listOfSR;	
    		}
    		if(listOfLead!=null && listOfLead.size()>0){
    			delete listOfLead;
    		}
    		if(listOfFamilyDetail!=null && listOfFamilyDetail.size()>0){
    			delete listOfFamilyDetail;
    		}
    	}
    }
    
    public static void checkDuplicatesAmongSchool(List <Enquiry__c> Enquiry_List){
    	
    	map<string, string>	uniqueEnquiryMap= new map<string, string>();
    	map<string, string>	uniqueSRMap= new map<string, string>();
    	map<string, string>	uniqueAccountMap= new map<string, string>();
    	
    	list<id> enquiryIdList = new list<id>();
    	set<string> uniqueKeySet = new set<string>();
    	for(Enquiry__c enq : Enquiry_List){
			
			string firstName = '';
        	string lastName = '';
        	string email = '';
        	if(string.isNotBlank(enq.FirstName__c)){
        		firstName = enq.FirstName__c.tolowercase();
        	}
        	if(string.isNotBlank(enq.LastName__c)){
        		lastName = enq.LastName__c.tolowercase();
        	}
        	if(string.isNotBlank(enq.email__c)){
        		email = enq.email__c.tolowercase();
        	}
        	enq.Unique_External__c = firstName+'-'+lastName+'-'+ email;	
			
			uniqueKeySet.add(enq.Unique_External__c);
    	}
    	
		for(Enquiry__c obj : [select id, Unique_External__c,unique__c
							  from Enquiry__c 
    						  where Unique_External__c IN : uniqueKeySet
    						  and id NOT IN : Enquiry_List
    						  and unique__c = true]){
    			uniqueEnquiryMap.put(obj.Unique_External__c, obj.id);	
    	}
    	
    	Id enrolRecordType = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('Enrollment').getRecordTypeId();
    	for(HexaBPM__Service_Request__c obj : [select id, enquiry__c,recordTypeId,Unique_External__c from HexaBPM__Service_Request__c 
    						  where recordTypeId =:enrolRecordType and Unique_External__c IN : uniqueKeySet and enquiry__c Not IN : Enquiry_List]){
    			if(obj.enquiry__c!=null){
    			}else{
    				uniqueSRMap.put(obj.Unique_External__c, obj.id);
    			}	
    	} 
    	
    	Id studentRecordType1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    	Id studentRecordType2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Read Only').getRecordTypeId();
    	for(Account obj : [select id, recordTypeId,Unique_External__c
    					   from Account where (recordTypeId =:studentRecordType1 or recordTypeId =:studentRecordType2) and Unique_External__c IN : uniqueKeySet]){
    		
    			uniqueAccountMap.put(obj.Unique_External__c, obj.id);
    	}
    	
    	if(Enquiry_List!=null && Enquiry_List.size()>0){
    		for(Enquiry__c enq : Enquiry_List){
    			string firstName = '';
	        	string lastName = '';
	        	string email = '';
    			if(string.isNotBlank(enq.FirstName__c)){
	        		firstName = enq.FirstName__c.tolowercase();
	        	}
	        	if(string.isNotBlank(enq.LastName__c)){
	        		lastName = enq.LastName__c.tolowercase();
	        	}
	        	if(string.isNotBlank(enq.email__c)){
	        		email = enq.email__c.tolowercase();
	        	}
	        	string uniqueKey = '';
	    		uniqueKey = firstName+'-'+lastName+'-'+ email;	
	    		enq.Unique_External__c = uniqueKey;
	    		if(uniqueEnquiryMap!=null && uniqueEnquiryMap.size()>0 && uniqueEnquiryMap.get(uniqueKey)!=null){
	    			enq.Unique_Enquiry__c = uniqueEnquiryMap.get(uniqueKey);	
	    			enq.Unique__c = false;
	    		}
	    		
				if(uniqueSRMap!=null && uniqueSRMap.size()>0 && uniqueSRMap.get(uniqueKey)!=null){
	    			enq.Unique_SR__c = uniqueSRMap.get(uniqueKey);	
	    			enq.Unique__c = false;
	    		}
	    		
	    		if(uniqueAccountMap!=null && uniqueAccountMap.size()>0 && uniqueAccountMap.get(uniqueKey)!=null){
	    			enq.Unique_Account__c = uniqueAccountMap.get(uniqueKey);
	    			enq.Unique__c = false;	
	    		}
	    		
	    		if(enq.Unique_Enquiry__c==null && enq.Unique_SR__c == null && enq.Unique_Account__c == null){
	    			enq.Unique__c = true;	
	    			enq.Unique_Enquiry__c = null;
	    			enq.Unique_SR__c = null;
	    			enq.Unique_Account__c = null;
	    			
	    		}
	    	}	
    	}
    }
    
    //V1.2
    public static void  hasDeleteAccess(List <Enquiry__c> Enquiry_List){
    	if(Enquiry_List!=null && Enquiry_List.size()>0){
    		list<Profile> tempProfileList = [SELECT id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
    		if(tempProfileList!=null && tempProfileList.size()>0 && tempProfileList[0].name!='System Administrator'){
    			
    			for(Enquiry__c objEnquiry : Enquiry_List){
    				objEnquiry.addError('Enquiry cannot be deleted.');		
    			}	
    		}
    	}
    }
}