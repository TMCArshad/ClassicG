global without sharing class GEMS_AccountTriggerHelper {

    @future
    webservice static void UpdateInformaticaCheckBox(list<string> lstAccids){
        list<Account> listAccountUpdate = new list<Account>();
        if(lstAccids!=null && lstAccids.size()>0) {
            for(string a:lstAccids){
                Account acc = new Account(Id=a);
                acc.sys_Send_Student_Parent_details__c = true;
                listAccountUpdate.add(acc);
            }
            if(listAccountUpdate.size()>0 && !Test.isRunningTest())
                update listAccountUpdate;
        }
    } 
    
    public static void CreateRelationships(list<Account> TriggerNew) {
        // To create Parent Relationship records on insert of Parent Account and sibling relationship on insert of Sibling records from oasis
        set<string> setSiblingIds = new set<string>();
        Map<string, list<Account>> mapStdAccount = new Map<string, list<Account>>();
        list<Account> Account_List = new list<Account>();

        list<Account> StudentAccount_List = new list<Account>();
        map<string,list<Account>> mapParentAccount = new map<string,list<Account>>();
        
        set<string> setStudentAccIds = new set<string>();
        set<string> setStudentSiblingIds = new set<string>();
        for (Account acc : TriggerNew) {
            if (acc.Record_Type_Name__c == 'Parent_Guardian' && acc.Role__c != null && acc.Master_Student__c != null && acc.Master_Student__c != '' && acc.sys_fromSRClosure__c == False && acc.Sys_Parent_from_Oasis__c == True) {
                setSiblingIds.add(acc.Master_Student__c);
                Account_List.add(acc);
            }
            if (acc.Sibling_ID__c != null && acc.Sys_Student_from_Oasis__c == true && (acc.Record_Type_Name__c == 'Student' || acc.Record_Type_Name__c =='Student_Read_Only')) {
                setStudentSiblingIds.add(acc.Sibling_ID__c);
                setStudentAccIds.add(acc.Id);
                
                StudentAccount_List.add(acc);//Added to create the parent relationships for new students with existing parents
            }
        }
        if (setSiblingIds != null && setSiblingIds.size() > 0) {
            for (Account acc : [Select Id, Sibling_ID__c, Name, Record_Type_Name__c,Role__c,PersonEmail,FirstName,LastName from Account where Sibling_ID__c IN:setSiblingIds and Sys_Student_from_Oasis__c = True and (Record_Type_Name__c = 'Student' or Record_Type_Name__c = 'Student_Read_Only') ]) {
                list<Account> lstAcc = new list<Account>();
                if (mapStdAccount.get(acc.Sibling_ID__c) != null)
                    lstAcc = mapStdAccount.get(acc.Sibling_ID__c);
                lstAcc.add(acc);
                mapStdAccount.put(acc.Sibling_ID__c, lstAcc);
            }
            
            
        }
        if(setStudentSiblingIds!=null && setStudentSiblingIds.size()>0){
            for (Account acc : [Select Id,Master_Student__c,Name, Record_Type_Name__c,Role__c,PersonEmail,FirstName,LastName from Account where Master_Student__c IN:setStudentSiblingIds and Sys_Student_from_Oasis__c = True and Record_Type_Name__c = 'Parent_Guardian' ]) {
                list<Account> lstAcc = new list<Account>();
                if (mapParentAccount.get(acc.Master_Student__c) != null)
                    lstAcc = mapParentAccount.get(acc.Master_Student__c);
                lstAcc.add(acc);
                mapParentAccount.put(acc.Master_Student__c, lstAcc);
            }
        }
        list<Relationship__c> listRelation =  new List<Relationship__c>();
        for (Account acc : Account_List) {
            if (mapStdAccount.get(acc.Master_Student__c) != null && mapStdAccount.get(acc.Master_Student__c).size() > 0) {
                for (Account stdAcc : mapStdAccount.get(acc.Master_Student__c)) {
                    Relationship__c rel = new Relationship__c();
                    rel.Subject_Account__c = stdAcc.id;
                    rel.Object_Account__c  = acc.id;
                    rel.Type__c = acc.Role__c;
                    rel.Active__c = true;
                    rel.Email__c = acc.PersonEmail;
                    rel.First_Name__c = acc.FirstName;
                    rel.Last_Name__c = acc.LastName;
                    rel.Created_From__c = 'Informatica';
                    listRelation.add(rel);
                }
            }
        }
        
        for (Account acc : StudentAccount_List) {
            if (mapParentAccount.get(acc.Sibling_ID__c) != null && mapParentAccount.get(acc.Sibling_ID__c).size() > 0) {
                for (Account ParentAcc : mapParentAccount.get(acc.Sibling_ID__c)) {
                    Relationship__c rel = new Relationship__c();
                    rel.Subject_Account__c = acc.id;
                    rel.Object_Account__c  = ParentAcc.id;
                    rel.Type__c = ParentAcc.Role__c;
                    rel.Active__c = true;
                    rel.Email__c = ParentAcc.PersonEmail;
                    rel.First_Name__c = ParentAcc.FirstName;
                    rel.Last_Name__c = ParentAcc.LastName;
                    rel.Created_From__c = 'Informatica';
                    listRelation.add(rel);
                }
            }
        }
        
        map<string, list<Account>> MapStudentSiblings = new map<string, list<Account>>();
        if (setStudentSiblingIds != null && setStudentSiblingIds.size() > 0 && setStudentAccIds != null && setStudentAccIds.size() > 0) {
            for (Account acc : [Select Id, Sibling_ID__c, Role__c, PersonEmail, FirstName, LastName from Account where Sibling_ID__c IN:setStudentSiblingIds and Id NOT IN:setStudentAccIds and Sys_Student_from_Oasis__c = true and (Record_Type_Name__c = 'Student' or Record_Type_Name__c = 'Student_Read_Only' )]) {
                list<Account> lstAcc = new list<Account>();
                if (MapStudentSiblings.get(acc.Sibling_ID__c) != null)
                    lstAcc = MapStudentSiblings.get(acc.Sibling_ID__c);
                lstAcc.add(acc);
                MapStudentSiblings.put(acc.Sibling_ID__c, lstAcc);
            }
        }
        for (Account acc : TriggerNew) {
            if (acc.Sibling_ID__c != null && (acc.Record_Type_Name__c == 'Student'|| acc.Record_Type_Name__c == 'Student_Read_Only') && MapStudentSiblings.get(acc.Sibling_ID__c) != null && acc.Sys_Student_from_Oasis__c == true) {
                for (Account SibAcc : MapStudentSiblings.get(acc.Sibling_ID__c)) {
                    Relationship__c rel = new Relationship__c();
                    rel.Subject_Account__c = acc.id;
                    rel.Object_Account__c  = SibAcc.id;
                    rel.Type__c = 'Sibling';
                    rel.Active__c = true;
                    rel.First_Name__c = SibAcc.FirstName;
                    rel.Last_Name__c = SibAcc.LastName;
                    rel.Created_From__c = 'Informatica';
                    listRelation.add(rel);

                    rel = new Relationship__c();
                    rel.Subject_Account__c = SibAcc.id;
                    rel.Object_Account__c  = acc.id;
                    rel.Type__c = 'Sibling';
                    rel.Active__c = true;
                    rel.First_Name__c = acc.FirstName;
                    rel.Last_Name__c = acc.LastName;
                    rel.Created_From__c = 'Informatica';
                    listRelation.add(rel);
                }
            }
        }
        if (listRelation.size() > 0) {
            insert listRelation;
        }
    }

    public static void CalculateAllocationCount(set<string> setSectionIds) {
        map<string, list<Account>> MapSectionAccounts = new map<string, list<Account>>();
        list<Section_Master__c> listSection = new list<Section_Master__c>();
        if (setSectionIds != null && setSectionIds.size() > 0) {
            listSection = [Select Id, Section__c, Alloted__c, Boys__c, Girls__c, First_Language_English__c, SEN__c from Section_Master__c where Id IN:setSectionIds];
            for (Account acc : [Select Id, Gender__c, Current_Status__c, Section__c, Child_have_any_special_education_needs__c, First_Language__c from Account where Section__c IN:setSectionIds and Current_Status__c = 'EN']) {
                list<Account> lstAccs = new list<Account>();
                if (MapSectionAccounts.get(acc.Section__c) != null)
                    lstAccs = MapSectionAccounts.get(acc.Section__c);
                lstAccs.add(acc);
                MapSectionAccounts.put(acc.Section__c, lstAccs);
            }
        }
        list<Section_Master__c> listSectionUpdate =  new List<Section_Master__c>();
        if (listSection != null && listSection.size() > 0) {
            for (Section_Master__c sec : listSection) {
                sec.Alloted__c = 0;
                sec.Boys__c = 0;
                sec.Girls__c = 0;
                sec.First_Language_English__c = 0;
                sec.SEN__c = 0;
                if (MapSectionAccounts.get(sec.Id) != null) {
                    for (Account objacc : MapSectionAccounts.get(sec.Id)) {
                        if (objacc.Gender__c == 'Male' || objacc.Gender__c == 'M') {
                            sec.Boys__c = sec.Boys__c + 1;
                            sec.Alloted__c = sec.Alloted__c + 1;
                        }
                        if (objacc.Gender__c == 'Female' || objacc.Gender__c == 'F') {
                            sec.Girls__c = sec.Girls__c + 1;
                            sec.Alloted__c = sec.Alloted__c + 1;
                        }
                        if (objacc.First_Language__c == 'English') {
                            sec.First_Language_English__c = sec.First_Language_English__c + 1;
                        }
                        if (objacc.Child_have_any_special_education_needs__c == 'Yes') {
                            sec.SEN__c = sec.SEN__c + 1;
                        }
                    }
                }
                listSectionUpdate.add(sec);
            }
        }
        if (listSectionUpdate.Size() > 0)
            update listSectionUpdate;
    }

    public static void CalculateAllocationCount_Delete(set<string> setSectionIds, set<string> AccountToExclude) {
        map<string, list<Account>> MapSectionAccounts = new map<string, list<Account>>();
        list<Section_Master__c> listSection = new list<Section_Master__c>();
        if (setSectionIds != null && setSectionIds.size() > 0 && AccountToExclude != null && AccountToExclude.size() > 0) {
            listSection = [Select Id, Section__c, Alloted__c, Boys__c, Girls__c, First_Language_English__c, SEN__c from Section_Master__c where Id IN:setSectionIds];
            for (Account acc : [Select Id, Gender__c, Current_Status__c, Section__c, Child_have_any_special_education_needs__c, First_Language__c from Account where Section__c IN:setSectionIds and Id Not IN:AccountToExclude and Current_Status__c = 'EN']) {
                list<Account> lstAccs = new list<Account>();
                if (MapSectionAccounts.get(acc.Section__c) != null)
                    lstAccs = MapSectionAccounts.get(acc.Section__c);
                lstAccs.add(acc);
                MapSectionAccounts.put(acc.Section__c, lstAccs);
            }
        }
        list<Section_Master__c> listSectionUpdate =  new List<Section_Master__c>();
        if (listSection != null && listSection.size() > 0) {
            for (Section_Master__c sec : listSection) {
                sec.Alloted__c = 0;
                sec.Boys__c = 0;
                sec.Girls__c = 0;
                sec.First_Language_English__c = 0;
                sec.SEN__c = 0;
                if (MapSectionAccounts.get(sec.Id) != null) {
                    for (Account objacc : MapSectionAccounts.get(sec.Id)) {
                        if (objacc.Gender__c == 'Male' || objacc.Gender__c == 'M') {
                            sec.Boys__c = sec.Boys__c + 1;
                            sec.Alloted__c = sec.Alloted__c + 1;
                        }
                        if (objacc.Gender__c == 'Female' || objacc.Gender__c == 'F') {
                            sec.Girls__c = sec.Girls__c + 1;
                            sec.Alloted__c = sec.Alloted__c + 1;
                        }
                        if (objacc.First_Language__c == 'English') {
                            sec.First_Language_English__c = sec.First_Language_English__c + 1;
                        }
                        if (objacc.Child_have_any_special_education_needs__c == 'Yes') {
                            sec.SEN__c = sec.SEN__c + 1;
                        }
                    }
                }
                listSectionUpdate.add(sec);
            }
        }
        if (listSectionUpdate.Size() > 0)
            update listSectionUpdate;
    }
   
   
    /**Swati**/
    //Sync Account primary contact Information
    public static void syncPrimaryContactInformation(List<Account> Account_List, Map<id, Account> oldMap) {
		
		if(GEMS_checkRecursiveTriggers.runOnceForAccount){
            GEMS_checkRecursiveTriggers.runOnceForAccount = false;	
			map<id,Account> studentId = new map<id,Account>();
			map<id,Account> parentUpdatedId = new map<id,Account>();
			set<id> parentId = new set<id>();
			set<string> masterSiblingId = new set<string>();
			set<string> masterParentId = new set<string>();
			
			if(Account_List!=null && Account_List.size()>0){
				for(Account obj : Account_List){
					if(obj.Record_type_name__c == 'Student'){
						if(obj.Primary_Contact__c != oldMap.get(obj.id).Primary_Contact__c){
							system.debug('---obj.id--'+obj.id);
							
							if(obj.father__c!=null)
								parentId.add(obj.father__c);
							if(obj.mother__c!=null)
								parentId.add(obj.mother__c);
							if(obj.Guardian_1__c!=null)
								parentId.add(obj.Guardian_1__c);
							if(obj.Guardian_2__c!=null)
								parentId.add(obj.Guardian_2__c);
								
							studentId.put(obj.id,obj);
							masterSiblingId.add(obj.Sibling_ID__c);
						}
					}
					
					if(obj.Record_type_name__c == 'Parent_Guardian' &&
					   (obj.PersonEmail != oldMap.get(obj.id).PersonEmail ||
					    obj.PersonMobilePhone != oldMap.get(obj.id).PersonMobilePhone ||
					    obj.firstName != oldMap.get(obj.id).firstName ||
					    obj.lastName != oldMap.get(obj.id).lastName ||
					    obj.middleName != oldMap.get(obj.id).middleName)){
						parentUpdatedId.put(obj.id, obj);
						masterParentId.add(obj.master_student__c);
					}
				}
			}   
			
			map<id,Account> mapOfParent = new map<id,Account>();
			if(parentId!=null && parentId.size()>0){
				system.debug('---parentId--'+parentId);
				for(Account obj : [select id,Primary_Contact_Name__c, Primary_Contact_Email__c, 
										  Emergency_Contact_Number__c,primary_contact__c,
										  PersonEmail, PersonMobilePhone, Sibling_ID__c,
										  firstName, lastName ,role__c, middlename,Record_Type_Name__c
								   from Account 
								   where id IN : parentId]){		
			
					mapOfParent.put(obj.id,obj);		
				}
			}	
			system.debug('---mapOfParent--'+mapOfParent);
			if(mapOfParent!=null && mapOfParent.size()>0){
				for(account obj : studentId.values()){
					if(obj.primary_contact__c == 'Father' && mapOfParent.get(obj.father__c)!=null){
						
						string name = '';
						if(string.isNotBlank(mapOfParent.get(obj.father__c).firstName)){
							name = 	mapOfParent.get(obj.father__c).firstName;
						}
						
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.father__c).middleName)){
							name = 	name+' '+mapOfParent.get(obj.father__c).middleName;
						}
						
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.father__c).lastName)){
							name = 	name+' '+mapOfParent.get(obj.father__c).lastName;
						}
					
						obj.Primary_Contact_Name__c = name;
						obj.Primary_Contact_Email__c = mapOfParent.get(obj.father__c).PersonEmail;
						obj.Emergency_Contact_Number__c = mapOfParent.get(obj.father__c).PersonMobilePhone;
						
					}
					
					else if(obj.primary_contact__c == 'Mother' && mapOfParent.get(obj.mother__c)!=null){
						string name;
						if(string.isNotBlank(mapOfParent.get(obj.mother__c).firstName)){
							name = 	mapOfParent.get(obj.mother__c).firstName;
						}
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.mother__c).middleName)){
							name = 	name+' '+mapOfParent.get(obj.mother__c).middleName;
						}
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.mother__c).lastName)){
							name = 	name+' '+mapOfParent.get(obj.mother__c).lastName;
						}
						obj.Primary_Contact_Name__c = Name;
						obj.Primary_Contact_Email__c = mapOfParent.get(obj.mother__c).PersonEmail;
						obj.Emergency_Contact_Number__c = mapOfParent.get(obj.mother__c).PersonMobilePhone;
					}
					
					else if(obj.primary_contact__c == 'Guardian' && mapOfParent.get(obj.Guardian_1__c)!=null){
						string name;
						if(string.isNotBlank(mapOfParent.get(obj.Guardian_1__c).firstName)){
							name = 	mapOfParent.get(obj.Guardian_1__c).firstName;
						}
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.Guardian_1__c).middleName)){
							name = 	name+' '+mapOfParent.get(obj.Guardian_1__c).middleName;
						}
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.Guardian_1__c).lastName)){
							name = 	name+' '+mapOfParent.get(obj.Guardian_1__c).lastName;
						}
						obj.Primary_Contact_Name__c = name;
						obj.Primary_Contact_Email__c = mapOfParent.get(obj.Guardian_1__c).PersonEmail;
						obj.Emergency_Contact_Number__c = mapOfParent.get(obj.Guardian_1__c).PersonMobilePhone;
					}
					
					else if(obj.primary_contact__c == 'Guardian' && mapOfParent.get(obj.Guardian_2__c)!=null){
						string name;
						if(string.isNotBlank(mapOfParent.get(obj.Guardian_2__c).firstName)){
							name = 	mapOfParent.get(obj.Guardian_2__c).firstName;
						}
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.Guardian_2__c).middleName)){
							name = 	name+' '+mapOfParent.get(obj.Guardian_2__c).middleName;
						}
						if(string.isNotBlank(name) && string.isNotBlank(mapOfParent.get(obj.Guardian_2__c).lastName)){
							name = 	name+' '+mapOfParent.get(obj.Guardian_2__c).lastName;
						}
						obj.Primary_Contact_Name__c = name;
						obj.Primary_Contact_Email__c = mapOfParent.get(obj.Guardian_2__c).PersonEmail;
						obj.Emergency_Contact_Number__c = mapOfParent.get(obj.Guardian_2__c).PersonMobilePhone;
					}else{
						obj.Primary_Contact_Name__c = '';
						obj.Primary_Contact_Email__c = '';
						obj.Emergency_Contact_Number__c = '';
					}	
				}
			}
			
			system.debug('---studentId--'+studentId);
			map<string, list<Account>> mapOfSibling = new map<string, list<Account>>();
			if(studentId!=null && studentId.size()>0 && 
			   masterSiblingId!=null && masterSiblingId.size()>0){
				
				system.debug('---masterSiblingId--'+masterSiblingId);
				list<account> tempList = [select id,Primary_Contact_Name__c, Primary_Contact_Email__c, 
												  	Emergency_Contact_Number__c,primary_contact__c,
												  	PersonEmail, PersonMobilePhone, Sibling_ID__c,
												  	firstName, lastName ,role__c, middlename,Record_Type_Name__c
										  from Account where Record_Type_Name__c = 'Student'
										  and Sibling_ID__c IN : masterSiblingId and id Not IN : studentId.keyset()];		
				
				system.debug('---tempList--'+tempList);
				if(tempList!=null && tempList.size()>0){
					for(account obj : tempList){
						if(mapOfSibling.containsKey(obj.Sibling_ID__c)){
							list<Account> listSibling = mapOfSibling.get(obj.Sibling_ID__c);
							listSibling.add(obj);
						}
						else{
							list<Account> listSibling = new list<Account>();
							listSibling.add(obj);
							mapOfSibling.put(obj.Sibling_ID__c,listSibling);
						}
					}
				}
			}
			
			set<account> accountToUpdate = new set<account>();
			if(mapOfSibling!=null && mapOfSibling.size()>0 && 
			   studentId!=null && studentId.size()>0){
				for(Account stu : studentId.values()){
					for(account sib : mapOfSibling.get(stu.Sibling_ID__c)){
						sib.primary_contact__c = stu.primary_contact__c;
						sib.Primary_Contact_Name__c = stu.Primary_Contact_Name__c;
						sib.Primary_Contact_Email__c = stu.Primary_Contact_Email__c;
						sib.Emergency_Contact_Number__c = stu.Emergency_Contact_Number__c;
						
						accountToUpdate.add(sib);
					}	
				}	
			}
			
			system.debug('---masterParentId--'+masterParentId);
			map<string,list<Account>> mapSibling = new map<string,list<Account>>();
			if(parentUpdatedId!=null && parentUpdatedId.size()>0 &&
			   masterParentId!=null && masterParentId.size()>0){
			   	
				for(Account obj : [select id,Primary_Contact_Name__c, Primary_Contact_Email__c, 
											  	Emergency_Contact_Number__c,primary_contact__c,
											  	PersonEmail, PersonMobilePhone, Sibling_ID__c,
											  	firstName, lastName ,role__c, middlename,Record_Type_Name__c
										  from Account where sibling_id__c IN : masterParentId]){
										  	
					if(mapSibling.containsKey(obj.Sibling_ID__c)){
						list<Account> listSibling = mapSibling.get(obj.Sibling_ID__c);
						listSibling.add(obj);
					}
					else{
						list<Account> listSibling = new list<Account>();
						listSibling.add(obj);
						mapSibling.put(obj.Sibling_ID__c,listSibling);
					}
					
				}
			}
			
			system.debug('---mapSibling--'+mapSibling);
			if(mapSibling!=null && mapSibling.size()>0){
				for(Account par : parentUpdatedId.values()){
					system.debug('---par--'+par);
					for(Account child : mapSibling.get(par.master_student__c)){
						system.debug('---child--'+child);
						if(child.primary_contact__c == par.role__c){
							string name;
							if(string.isNotBlank(par.firstName)){
								name = 	par.firstName;
							}
							if(string.isNotBlank(name) && string.isNotBlank(par.middleName)){
								name = 	name+' '+par.middleName;
							}
							if(string.isNotBlank(name) && string.isNotBlank(par.lastName)){
								name = 	name+' '+par.lastName;
							}
							
							child.Primary_Contact_Name__c = name;
							child.Primary_Contact_Email__c = par.personEmail;
							child.Emergency_Contact_Number__c = par.PersonMobilePhone;
							
							accountToUpdate.add(child);		
						}
					}
				}	
			}
			
			
			system.debug('---accountToUpdate----'+accountToUpdate);
			if(accountToUpdate!=null && accountToUpdate.size()>0){
				list<account> finalUpdate = new list<account>();
				finalUpdate.addAll(accountToUpdate);
				update finalUpdate;
			}
		}
    }

}