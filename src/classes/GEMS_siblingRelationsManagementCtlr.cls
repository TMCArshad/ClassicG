/*****************************************************************************************************************************
    Author      :   Swati Sehrawat 
    Date        :   7th March 2017
    Description :   Linking/Delinking of Accounts
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    V1.0    20th March 2018		Swati	Populate masterstudent for parent
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_siblingRelationsManagementCtlr {
    
    public string searchStudentId {get; set;}
    public string searchSiblingId {get; set;}
    public string selectedStudentId {get; set;}
    
    public string selectedAction {get; set;}
    public string yesOrNoForLinking {get; set;}
    public string yesOrNoForParent {get; set;} 
    public string searchRecord {get; set;}
    public string schoolId;
    
    public account studentRecord {get; set;}
    public account siblingRecord {get; set;}
    public account primaryContact {get; set;}
    public school__c objSchool {get; set;}
    
    public list<account> studentList {get; set;}
    
    public list<account> studentRelations {get; set;}
    public list<account> siblingRelations {get; set;}
    
    public list<SelectOption> yesOrNoList {get; set;}
    
    public list<relationship__c> inactiveParents {get;set;}
    
    public map<string, account> accountMap {get; set;}
    
    public boolean hideSiblingSection {get; set;}
    public boolean hideLinkButton {get; set;}
    public boolean hideDelinkButton {get; set;}
	public boolean displayPopup {get;set;}
	public boolean displayPopupSearch {get;set;}
	public boolean relationsExist {get;set;}
	public boolean linked {get;set;}
	public boolean delinked {get;set;}
    
    public GEMS_siblingRelationsManagementCtlr(){
        
	        searchStudentId = '';
	        searchSiblingId = '';
	        selectedAction = '';
	        searchRecord = '';
	        yesOrNoForLinking = 'Yes';
	        yesOrNoForParent = '';
	        selectedStudentId = '';
	        
	        hideSiblingSection = false;
	        hideLinkButton = false;
	        hideDelinkButton = false;
	        displayPopUp = false;
	        displayPopupSearch = false;
	        relationsExist = false;
	        linked = false;
	        delinked = false;
	        
	        yesOrNoList = new list<SelectOption>();
	        yesOrNoList.add(new SelectOption('Yes', 'Yes'));
			yesOrNoList.add(new SelectOption('No', 'No'));
			
			schoolId = apexpages.currentPage().getparameters().get('schoolId');
			if(string.isNotBlank(schoolId)){
		        getSchoolDetails();
	        }
    }
    
    public void getSchoolDetails(){
		list<school__c> tempSchoolList = [select id, name, logo__C from school__c where id=:schoolId];
		if(tempSchoolList!=null && tempSchoolList.size()>0){
			objSchool = tempSchoolList[0];
		}	
	}
	
	public void getStudentList(){
		if(string.isNotBlank(searchStudentId) || string.isNotBlank(searchSiblingId)){
    		string tempSearchTerm = '';
    		if(string.isNotBlank(searchStudentId) && searchRecord == 'Student'){
    			tempSearchTerm = '("' + searchStudentId + '")';
    		}
    		else if(string.isNotBlank(searchSiblingId) && searchRecord == 'Sibling'){
    			tempSearchTerm = '("' + searchSiblingId + '")';
    		}
    		
    		studentList = new list<account>();	
    		accountMap = new map<string,account>();
    		
    		list<account> tempList = new list<account>();
    		tempList  = (List<Account>)[FIND : tempSearchTerm IN All Fields RETURNING Account
    												 (id,firstName,school__r.name,lastName,
    												  Record_Type_Name__c,student_id__c,
    												  Academic_Year__c,GradeLookup__r.Grade_Display__c,
    												  GradeLookup__c, Section_Display__c,Section__c, Stream__c,
    												  gender__c, Current_Status__c, school__c,father__c,mother__c,
    												  primary_contact__c, Primary_Contact_Email__c, Primary_Contact_Name__c, 
    												  Emergency_Contact_Number__c, guardian_1__c, guardian_2__c,
    												  sibling_id__c,PersonMobilePhone,PersonEmail)][0];
    		if(tempList!=null && tempList.size()>0){
    			for(Account obj : tempList){
    				if(obj.school__c == objschool.id && obj.Current_Status__c=='EN' && obj.Record_Type_Name__c=='Student'){
    					studentList.add(obj);	
    					accountMap.put(obj.student_id__c,obj);
    				}	
    			}		
    		}
    		if(studentList!=null && studentList.size()>0){
    			
    		}
    		else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No students exist. Please refine your search criteria')); 	
	        }
    	}
	}
	
	public void getSelectedStudentFromSearch(){
		try{
			if(string.isNotBlank(selectedStudentId)){
				if(searchRecord == 'Sibling'){
					siblingRecord = new Account();
		            if(accountMap!=null && accountMap.size()>0 && accountMap.get(selectedStudentId)!=null)
		            	siblingRecord = accountMap.get(selectedStudentId);
					
					siblingRelations = new list<account> ();
					siblingRelations = getStudentRelations(siblingRecord.id);
					
					displayPopupSearch = false;		
				}else if(searchRecord == 'Student'){
					studentRecord = new Account();
		            if(accountMap!=null && accountMap.size()>0 && accountMap.get(selectedStudentId)!=null)
		            	studentRecord = accountMap.get(selectedStudentId);
					
					studentRelations = new list<account> ();
					studentRelations = getStudentRelations(studentRecord.id);
					displayPopupSearch = false;
				}
			}
		}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
            displayPopup = false;
        }
	}
	
	public list<account> getStudentRelations(string studentId){
        if(string.isNotBlank(studentId)){
            if(linked==true){
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,  'Students linked successfully')); 	
            }
            linked=false;
            
            if(delinked==true){
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,  'Student delinked successfully')); 	
            }
            delinked=false;
            
            list<id> tempObjectAccountId = new list<id>();
            for(relationship__c objRel : [select id,subject_account__c, object_account__c,subject_account__r.Father__c from relationship__c where subject_account__c =: studentId and type__c='Sibling' and active__c = true])
        		tempObjectAccountId.add(objRel.object_account__c);
            
            list<account> tempList = new list<account> ();
            if(tempObjectAccountId!=null && tempObjectAccountId.size()>0){
            	tempList = new list<Account>();
            	tempList = [select id, school__c, school__r.name, GradeLookup__r.grade_display__c, Section_Display__c, Stream__c ,Father__c, mother__c, 
								   firstName, lastName, PersonMobilePhone, PersonEmail, isPersonAccount,
								   sibling_id__c, student_id__c
                            from Account where Record_Type_Name__c='Student' and id IN : tempObjectAccountId];
                
                if(tempList!=null && tempList.size()>0){
                    
                	if(selectedAction=='Delink')
                		hideDelinkButton = false;
                		
                	if(selectedAction=='Link')		
                		hidelinkButton = false;
                	return tempList;
                }else{
                	if(selectedAction=='Delink')
                		hideDelinkButton = true;
                }
            }else{
            	if(selectedAction=='Delink')
            		hideDelinkButton = true;
            }
        }
        return null;
    }
    
    public void linkStudents(){
        Savepoint spdata = Database.setSavepoint();
        try{
        	boolean hasError = false;
        	
	    	if(studentRecord!=null && siblingRecord!=null){
				if(hasError == false){
		    		
		    		list<Account> siblingTotalList =  new list<Account>(); //combination of siblingRecord and its associated list
		    		siblingTotalList.add(siblingRecord);

		    		if(siblingRelations!=null && siblingRelations.size()>0){
		    			siblingTotalList.addAll(siblingRelations);
		    		}

		    		list<Account> studentTotalList =  new list<Account>(); //combination of studentRecord and its associated list
		    		studentTotalList.add(studentRecord);
		    		if(studentRelations!=null && studentRelations.size()>0){
		    			studentTotalList.addAll(studentRelations);
		    		}
		    		
	    			initiateLinkingProcess(studentRelations,siblingRelations,studentRecord,siblingRecord);	
		    		
		    		hideSiblingSection = true;
		    		linked = true;
		    		hideLinkButton = true;
		    		displayPopup = false;
		    		
		    		studentRelations = new list<account> ();
					studentRelations = getStudentRelations(studentRecord.id);
		    		siblingRecord = new account();
		    		siblingRelations = new list<account>();
	    		}
	    	}   
    	}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
            displayPopup = false;
            Database.rollback(spdata);
        }
    }
    
    public void clearValuesFromPage(){
        searchStudentId = '';
        searchSiblingId = '';
        
        studentRecord = new Account();
        siblingRecord = new Account();
        
        if(siblingRelations!=null && siblingRelations.size()>0){
    		siblingRelations.clear();
    	}
    	
    	if(studentRelations!=null && studentRelations.size()>0){
    		studentRelations.clear();
    	}
    }
    
    public void showPopUp(){
   		initiateDelinking();
   		displayPopup = true;
   		yesOrNoForLinking = 'Yes';
   		yesOrNoForParent = 'No';
    }
    
    public void showSearchPopUp(){
    	displayPopupSearch = true;
    	getStudentList();
    }
   
    public void closePopup() {
        displayPopup = false;
        displayPopupSearch = false;
    }
    
    
    public void initiateDelinking(){
    	primaryContact = new account();
        inactiveParents = new list<relationship__c>();
        
        inactiveParents = [select id,object_account__c, object_account__r.name, type__c from relationship__c where subject_account__c =: studentRecord.id and (type__c='Mother' or type__c='Father') and active__c=false];
    	if(inactiveParents!=null && inactiveParents.size()>0){
    		relationsExist = true;
    	}else{
    		relationsExist = false;
    		primaryContact = new account();
    		primaryContact.recordTypeID = GEMS_Utility.getRecordTypeId('Account','Parent_Guardian');
    	}
    }
    
    public void createParentAndDelink(){
    	Savepoint spdata = Database.setSavepoint();
    	try{
	    	if(string.isNotBlank(primaryContact.firstName) && string.isNotBlank(primaryContact.lastName)){
	    		list<relationship__c> getAllRelations = new list<relationship__c>();
	    		
	    		if(studentRelations!=null && studentRelations.size()>0){
		    		if(studentRecord.sibling_id__c == studentRecord.student_id__c){
		    			string newMasterStudentId = studentRelations[0].student_id__c;
		    			for(Account obj : studentRelations){
		    				obj.sibling_id__c = newMasterStudentId;	
		    			}	
		    		}
		    		for(relationship__c obj : [select id, active__c, type__c, object_account__c from relationship__c where subject_account__c =: studentRecord.id  or object_account__c=:studentRecord.id]){
	    				obj.Active__c = false;
		    			getAllRelations.add(obj);
		    		}	
	    		}
	    		primaryContact.Master_Student__c = studentRecord.sibling_id__c; //V1.0
	    		insert 	primaryContact;
	    		
	    		studentRecord.father__c = null;
				studentRecord.Mother__c = null;
			
	    		if(primaryContact.role__c == 'Father'){
	    			studentRecord.father__c = primaryContact.id;
	    		}
	    		else if(primaryContact.role__c == 'Mother'){
	    			studentRecord.Mother__c = primaryContact.id;
	    		}
	    		studentRecord.sibling_id__c = studentRecord.student_id__c;
	    		if(primaryContact!=null && string.isNotBlank(primaryContact.id)){
		    		relationship__c objRelation = new relationship__c();
		            objRelation.Subject_Account__c = studentRecord.id;    
		            objRelation.Object_Account__c = primaryContact.id;
		            objRelation.Type__c = primaryContact.Role__c;
		            objRelation.Created_From__c = 'Linking/Delinking';
		            getAllRelations.add(objRelation);
		            
		            if(getAllRelations!=null && getAllRelations.size()>0){
		            	upsert getAllRelations;
		            }
		            
		            if(studentRelations!=null && studentRelations.size()>0){
		            	update studentRelations;
		            }
		            update studentRecord;
		            
		            displayPopup = false;
		        	hideDelinkButton = true;
		        	delinked = true;
		        	
		        	studentRelations = new list<account> ();
					studentRelations = getStudentRelations(studentRecord.id);
		    		siblingRecord = new account();
		    		siblingRelations = new list<account>();
	    		}
	    	}	
    	}catch(exception e){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
            displayPopup = false;
            Database.rollback(spdata);
    	}	
    }
    
    public void activateOldRelationAndDelink(){
	    Savepoint spdata = Database.setSavepoint();
    	try{	
	    	list<relationship__c> getAllRelations = new list<relationship__c>();	
			studentRecord.father__c = null;
			studentRecord.Mother__c = null;
			studentRecord.sibling_id__c = studentRecord.student_id__c;
	    	
	    	if(studentRelations!=null && studentRelations.size()>0){
	    		if(studentRecord.sibling_id__c == studentRecord.student_id__c){
	    			string newMasterStudentId = studentRelations[0].student_id__c;
	    			for(Account obj : studentRelations){
	    				obj.sibling_id__c = newMasterStudentId;	
	    			}	
	    		}
			}	
	    	
	    	for(relationship__c obj : [select id, active__c, type__c, object_account__c from relationship__c where subject_account__c =: studentRecord.id  or object_account__c=:studentRecord.id]){
	    		if(obj.Active__c == true){
	    			obj.Active__c = false;
	    		}
	    		else if(obj.type__c!='Sibling'){
	    			obj.Active__c = true;
	    		}
	    		
	    		if(obj.type__c == 'Father' && obj.Active__c == true){
	    			studentRecord.father__c = obj.object_account__c;
	    		}
	    			
	    		if(obj.type__c == 'Mother' && obj.Active__c == true){
	    			studentRecord.Mother__c = obj.object_account__c;
	    		}
	    		getAllRelations.add(obj);
	    	}
			if(getAllRelations!=null && getAllRelations.size()>0){
				update studentRelations;
				
	        	hideDelinkButton = true;
				update studentRecord;
				update getAllRelations;
				displayPopup = false;
				delinked = true;
				
				studentRelations = new list<account> ();
				studentRelations = getStudentRelations(studentRecord.id);
	    		siblingRecord = new account();
	    		siblingRelations = new list<account>();
			}	
		}catch(exception e){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
            displayPopup = false;
            Database.rollback(spdata);
    	}
    }
    
    public void delinkIndividual(){
    	list<relationship__c> getAllRelations = new list<relationship__c>();	
		studentRecord.father__c = null;
		studentRecord.Mother__c = null;
		studentRecord.sibling_id__c = studentRecord.student_id__c;
    	
    	if(studentRelations!=null && studentRelations.size()>0){
    		if(studentRecord.sibling_id__c == studentRecord.student_id__c){
    			string newMasterStudentId = studentRelations[0].student_id__c;
    			for(Account obj : studentRelations){
    				obj.sibling_id__c = newMasterStudentId;	
    			}	
    		}
		}	
    	
    	for(relationship__c obj : [select id, active__c, type__c, object_account__c from relationship__c where subject_account__c =: studentRecord.id  or object_account__c=:studentRecord.id]){
    		if(obj.Active__c == true){
    			obj.Active__c = false;
    		}
    		getAllRelations.add(obj);
    	}
    	
		if(getAllRelations!=null && getAllRelations.size()>0){
			update studentRelations;
			if(studentRelations!=null && studentRelations.size()>0){
        		studentRelations.clear();
        	}
        	hideDelinkButton = true;
			update studentRecord;
			update getAllRelations;
			displayPopup = false;
		}	
    }
    
    public void initiateLinkingProcess(list<Account> accountListMaster, list<Account> accountListSibling, Account masterStudent, Account siblingStudent){
    	
    	list<relationship__c> relationToDeactivate =  new list<relationship__c>();
		list<relationship__c> relationToInsert =  new list<relationship__c>();
		list<Account> accountToUpdate =  new list<Account>();
		    		
    	//Deactivate all relationships of sibling with parents and leave only sibling relationships.
		for(relationship__c tempObj : [select id, active__c from relationship__c 
									   where Master_Student_from_Parent__c=:siblingStudent.sibling_id__c and type__c!='Sibling'
									   and active__c = true]){
			tempObj.active__c = false;
			relationToDeactivate.add(tempObj);
		}
	   	
	   	system.debug('--accountListMaster--'+accountListMaster);
	   	system.debug('--accountListSibling--'+accountListSibling);
	   	
	   	list<relationship__c> newParents =  new list<relationship__c>();
		newParents = [select id, type__c,active__c,object_account__c from relationship__c 
					  where subject_account__c=:masterStudent.id and type__c!='Sibling'
					  and active__c = true];
		
		system.debug('----newParents---'+newParents);
		relationship__c objRel1 = new relationship__c();
    	objRel1.Subject_Account__c = masterStudent.id;    
        objRel1.Object_Account__c = siblingStudent.id;
        objRel1.Type__c = 'Sibling';		
        objRel1.active__c = true;
        objRel1.Created_From__c = 'Linking/Delinking';
        relationToInsert.add(objRel1);
        
        relationship__c objRel2 = new relationship__c();
        objRel2.Subject_Account__c = siblingStudent.id;    
        objRel2.Object_Account__c = masterStudent.id;
        objRel2.Type__c = 'Sibling';		
        objRel2.active__c = true;
        objRel2.Created_From__c = 'Linking/Delinking';
        
        relationToInsert.add(objRel2);
        
        if(newParents!=null && newParents.size()>0){
    		for(relationship__c obj : newParents){
	        	relationship__c objRel8 = new relationship__c();
		        objRel8.Subject_Account__c = siblingStudent.id;    
		        objRel8.Object_Account__c = obj.object_account__c;
		        objRel8.Type__c = obj.type__c;		
		        objRel8.active__c = true;
		        objRel8.Created_From__c = 'Linking/Delinking';
		        
		        relationToInsert.add(objRel8);
        	}	
        }
	    
	    if(accountListMaster!=null && accountListMaster.size()>0){    
		    for(Account objStu : accountListMaster){
		    	relationship__c objRel3 = new relationship__c();
		    	objRel3.Subject_Account__c = objStu.id;    
		        objRel3.Object_Account__c = siblingStudent.id;
		        objRel3.Type__c = 'Sibling';		
		        objRel3.active__c = true;
		        objRel3.Created_From__c = 'Linking/Delinking';
		        relationToInsert.add(objRel3);
		        
		        relationship__c objRel4 = new relationship__c();
		        objRel4.Subject_Account__c = siblingStudent.id;    
		        objRel4.Object_Account__c = objStu.id;
		        objRel4.Type__c = 'Sibling';		
		        objRel4.active__c = true;
		        objRel4.Created_From__c = 'Linking/Delinking';
		        
		        relationToInsert.add(objRel4);
		    }
	    }
	    
	    if(accountListSibling!=null && accountListSibling.size()>0){  
		    for(Account objSib : accountListSibling){
		    	relationship__c objRel5 = new relationship__c();
		    	objRel5.Subject_Account__c = objSib.id;    
		        objRel5.Object_Account__c = masterStudent.id;
		        objRel5.Type__c = 'Sibling';		
		        objRel5.active__c = true;
		        objRel5.Created_From__c = 'Linking/Delinking';
		        relationToInsert.add(objRel5);
		        
		        relationship__c objRel6 = new relationship__c();
		        objRel6.Subject_Account__c = masterStudent.id;    
		        objRel6.Object_Account__c = objSib.id;
		        objRel6.Type__c = 'Sibling';		
		        objRel6.active__c = true;
		        objRel6.Created_From__c = 'Linking/Delinking';
		        
		        relationToInsert.add(objRel6);
		        
		        if(newParents!=null && newParents.size()>0){
        			for(relationship__c obj : newParents){
			        	relationship__c objRel7 = new relationship__c();
				        objRel7.Subject_Account__c = objSib.id;    
				        objRel7.Object_Account__c = obj.object_account__c;
				        objRel7.Type__c = obj.type__c;		
				        objRel7.active__c = true;
				        objRel7.Created_From__c = 'Linking/Delinking';
				        
				        relationToInsert.add(objRel7);
		        	}
        		}
		        
		        objSib.father__c = null;
				objSib.Mother__c = null;
	    		objSib.guardian_1__c = null;
	    		objSib.guardian_2__c = null;
	    		
	    		objSib.father__c = (masterStudent.father__c!=null)? masterStudent.father__c : null;
	    		objSib.Mother__c = (masterStudent.Mother__c!=null)? masterStudent.Mother__c : null;
	    		objSib.guardian_1__c = (masterStudent.guardian_1__c!=null)? masterStudent.guardian_1__c : null;
	    		objSib.guardian_2__c = (masterStudent.guardian_2__c!=null)? masterStudent.guardian_2__c : null;
	    		objSib.sibling_id__c = (masterStudent.sibling_id__c!=null)? masterStudent.sibling_id__c : null;
	    		objSib.primary_contact__c = masterStudent.primary_contact__c;
	            objSib.Primary_Contact_Email__c = masterStudent.Primary_Contact_Email__c;
	            objSib.Primary_Contact_Name__c = masterStudent.Primary_Contact_Name__c;
	            objSib.Emergency_Contact_Number__c = masterStudent.Emergency_Contact_Number__c;		    		
		    	
		    	accountToUpdate.add(objSib);
		    }
	    }
	    
	    if(accountListMaster!=null && accountListMaster.size()>0 &&
	       accountListSibling!=null && accountListSibling.size()>0){ 
	    
	    		for(Account objStu : accountListMaster){
			    	for(Account objSib : accountListSibling){
				    	relationship__c objRel8 = new relationship__c();
				    	objRel8.Subject_Account__c = objStu.id;    
				        objRel8.Object_Account__c = objSib.id;
				        objRel8.Type__c = 'Sibling';		
				        objRel8.active__c = true;
				        objRel8.Created_From__c = 'Linking/Delinking';
				        relationToInsert.add(objRel8);
				        
				        relationship__c objRel9 = new relationship__c();
				        objRel9.Subject_Account__c = objSib.id;    
				        objRel9.Object_Account__c = objStu.id;
				        objRel9.Type__c = 'Sibling';		
				        objRel9.active__c = true;
				        objRel9.Created_From__c = 'Linking/Delinking';
				        
				        relationToInsert.add(objRel9);
			    	}
			    }
	    }
	    
	    if(relationToInsert!=null && relationToInsert.size()>0){
			insert relationToInsert;
		}
		
		if(relationToDeactivate!=null && relationToDeactivate.size()>0){
			update relationToDeactivate;
		}
		
		siblingStudent.father__c = null;
		siblingStudent.Mother__c = null;
		siblingStudent.guardian_1__c = null;
		siblingStudent.guardian_2__c = null;
		
		siblingStudent.father__c = (masterStudent.father__c!=null)? masterStudent.father__c : null;
		siblingStudent.Mother__c = (masterStudent.Mother__c!=null)? masterStudent.Mother__c : null;
		siblingStudent.guardian_1__c = (masterStudent.guardian_1__c!=null)? masterStudent.guardian_1__c : null;
		siblingStudent.guardian_2__c = (masterStudent.guardian_2__c!=null)? masterStudent.guardian_2__c : null;
		siblingStudent.sibling_id__c = (masterStudent.sibling_id__c!=null)? masterStudent.sibling_id__c : null;
		siblingStudent.primary_contact__c = masterStudent.primary_contact__c;
        siblingStudent.Primary_Contact_Email__c = masterStudent.Primary_Contact_Email__c;
        siblingStudent.Primary_Contact_Name__c = masterStudent.Primary_Contact_Name__c;
        siblingStudent.Emergency_Contact_Number__c = masterStudent.Emergency_Contact_Number__c;		    		
    	
    	accountToUpdate.add(siblingStudent);
		
		if(accountToUpdate!=null && accountToUpdate.size()>0){
			update accountToUpdate;
		}
    }
}