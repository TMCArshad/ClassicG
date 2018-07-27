global without sharing class GEMS_initiateTransferBatch implements Database.Batchable<sObject>,database.stateful {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        string recordType = 'Inter_Unit_Student_Transfer';
        string status = 'Approved';
        date todayDate = system.today();
        string query = 'select id,student__c,HexaBPM__Customer__r.Current_Status__c,school__c,Section_Lookup__c,stream__c,GradeLookup__c,HexaBPM__Customer__c,Academic_Year__c from HexaBPM__Service_Request__c where '+
        			   'HexaBPM__Record_Type_Name__c =:recordType and HexaBPM__External_Status_Name__c =: status AND '+
        			   'HexaBPM__Customer__c != NULL and Transfer_date__c!=NULL and Transfer_date__c=:todayDate and Student__c=Null' ;
        
        system.debug('---query---'+query);
        return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<HexaBPM__Service_Request__c> scope) {
		Savepoint spdata = Database.setSavepoint();
		try{
			set<id> accountIDSet = new set<id>();
			system.debug('---scope---'+scope);
			if(scope!= null && scope.size()>0){
				for(HexaBPM__Service_Request__c objSR : scope){
					system.debug('--objSR----'+objSR);
					if(objSR.HexaBPM__Customer__c!=NULL && objSR.HexaBPM__Customer__r.Current_Status__c=='EN')
						accountIDSet.add(objSR.HexaBPM__Customer__c);		
				}
			}
			system.debug('---accountIDSet---'+accountIDSet);
			
			map<id,account> accountMap = new map<id,account>();
			map<id,id> relationsToClone = new map<id,id>();
			
			list<account> accountList = new list<account>();
			list<account> accountToInsertList = new list<account>();
			list<account> accountToUpdateList = new list<account>();
			list<relationship__c> listRelations = new list<relationship__c>();
			
			if(accountIDSet!=null && accountIDSet.size()>0){
				listRelations = [select Object_Account__c,subject_account__c,type__c,active__c 
								 from relationship__c where active__c=true 
								 and subject_account__c IN : accountIDSet];
				
				system.debug('---listRelations---'+listRelations);
				if(listRelations!=null && listRelations.size()>0){
					for(relationship__c rel : listRelations){
						relationsToClone.put(rel.Object_Account__c, rel.subject_account__c);
						rel.active__c = false;
						
						if(rel.Object_Account__c!=null && rel.type__c!='Sibling')
							accountIDSet.add(rel.Object_Account__c);
					}
				}
				system.debug('---accountIDSet---'+accountIDSet);
				String query = GEMS_Utility.getAllFields(Account.getsObjectType().getDescribe());
	            query += ' WHERE ID IN :accountIDSet'  ;
	            accountList = Database.query(query);
			}
			
			system.debug('---accountList---'+accountList);
			if(accountList!=null && accountList.size()>0){
				for(Account acc : accountList){
					accountMap.put(acc.id,acc);
				}
			}
			system.debug('---accountMap---'+accountMap);
			
			if(scope!= null && scope.size()>0 && accountMap!= null && accountMap.size()>0){
				for(HexaBPM__Service_Request__c objSR : scope){
					if(objSR.HexaBPM__Customer__c!=NULL){
						if(accountMap.get(objSR.HexaBPM__Customer__c)!=null){
							account newStudent = new account();
							account oldStudent = new account();
							
							oldStudent = accountMap.get(objSR.HexaBPM__Customer__c);
							
							newStudent = oldStudent.clone(false,true,false,false);
							newStudent.school__c = objSR.school__c;
							newStudent.Academic_Year__c = objSR.Academic_Year__c;
							newStudent.GradeLookup__c = objSR.GradeLookup__c;
							newStudent.stream__c = objSR.stream__c;
							newStudent.Section__c = objSR.Section_Lookup__c;
							newStudent.current_status__c = 'EN';
							newStudent.student_id__c = '';
							newStudent.fee_id__c = '';
							system.debug('---newStudent---'+newStudent);
							accountToInsertList.add(newStudent);
							
							system.debug('---oldStudent---'+oldStudent);
							oldStudent.current_status__c = 'TF';
							accountToUpdateList.add(oldStudent);
							
							if(relationsToClone!=null && relationsToClone.size()>0){
								if(oldStudent.father__c!= null && relationsToClone.containsKey(oldStudent.father__c) && 
								   relationsToClone.get(oldStudent.father__c)!=null && 
								   relationsToClone.get(oldStudent.father__c)==oldStudent.id){
									
									account newFather = new account();
									account oldFather = new account();
									
									oldFather = accountMap.get(oldStudent.father__c);
									newFather = oldFather.clone(false,true,false,false);
									newFather.Master_Student__c = '';
									newFather.sys_Father_Unique_Key__c = '';
									system.debug('--newFather---'+newFather);
									accountToInsertList.add(newFather);
								}	
							
								if(oldStudent.Mother__c!= null && relationsToClone.containsKey(oldStudent.Mother__c) && 
								   relationsToClone.get(oldStudent.Mother__c)!=null && 
								   relationsToClone.get(oldStudent.Mother__c)==oldStudent.id){
									
									account newMother = new account();
									account oldMother = new account();
									
									oldMother = accountMap.get(oldStudent.Mother__c);
									newMother = oldMother.clone(false,true,false,false);
									newMother.Master_Student__c = '';
									newMother.sys_Mother_Unique_Key__c = '';
									system.debug('--newMother---'+newMother);
									accountToInsertList.add(newMother);
								}	
							
								if(oldStudent.guardian_1__c!= null && relationsToClone.containsKey(oldStudent.guardian_1__c) && 
								   relationsToClone.get(oldStudent.guardian_1__c)!=null && 
								   relationsToClone.get(oldStudent.guardian_1__c)==oldStudent.id){
									
									account newGuardian = new account();
									account oldGuardian = new account();
									
									oldGuardian= accountMap.get(oldStudent.Guardian_1__c);
									newGuardian = oldGuardian.clone(false,true,false,false);
									newGuardian.Master_Student__c = '';
									newGuardian.sys_Guardian_Unique_Key__c = '';
									system.debug('--newguardian---'+newguardian);
									accountToInsertList.add(newGuardian);
								}	
							
								if(oldStudent.guardian_2__c!= null && relationsToClone.containsKey(oldStudent.guardian_2__c) && 
								   relationsToClone.get(oldStudent.guardian_2__c)!=null && 
								   relationsToClone.get(oldStudent.guardian_2__c)==oldStudent.id){
									
									account newguardian = new account();
									account oldguardian = new account();
									
									oldguardian = accountMap.get(oldStudent.guardian_2__c);
									newguardian = oldguardian.clone(false,true,false,false);
									newGuardian.Master_Student__c = '';
									newGuardian.sys_Guardian_Unique_Key__c = '';
									system.debug('--newguardian---'+newguardian);
									accountToInsertList.add(newguardian);
								}
							}	
						}
					}	
				}
			}
			system.debug('--accountToInsertList---'+accountToInsertList);
			map<id,Account> oldNewAccountMap = new map<id,Account>();
			if(accountToInsertList!=null && accountToInsertList.size()>0){
				insert accountToInsertList;
				for(account acc : accountToInsertList){
					oldNewAccountMap.put(acc.getCloneSourceId(),acc);
					UpdateStudentId(acc,oldNewAccountMap);
				}
			}
			
			system.debug('---accountToUpdateList---'+accountToUpdateList);
			if(accountToUpdateList!=null && accountToUpdateList.size()>0){
				update accountToUpdateList;
			}
			
			system.debug('---listRelations---'+listRelations);
			if(listRelations!=null && listRelations.size()>0){
				update listRelations;
			}
			
			list<relationship__c> listRelationToInsert = new list<relationship__c>();
			system.debug('---relationsToClone---'+relationsToClone);
			if(relationsToClone!=null && relationsToClone.size()>0 && oldNewAccountMap!=null && oldNewAccountMap.size()>0){
				for(string objRel : relationsToClone.keySet()){
					if(relationsToClone.get(objRel)!=null && 
					   oldNewAccountMap.get(relationsToClone.get(objRel))!=null &&
					   oldNewAccountMap.get(objRel)!=null){
						relationship__c newRel = new relationship__c();
						newRel.subject_account__c = oldNewAccountMap.get(relationsToClone.get(objRel)).id;
						newRel.object_account__c = oldNewAccountMap.get(objRel).id;
						newRel.active__c = true;
						newRel.Created_From__c = 'Transferred';
						newRel.type__c = oldNewAccountMap.get(objRel).role__c;
						listRelationToInsert.add(newRel);
					}
				}	
			}
			system.debug('---listRelationToInsert---'+listRelationToInsert);
			if(listRelationToInsert!=null && listRelationToInsert.size()>0){
				insert listRelationToInsert;
			}
			
			if(scope!= null && scope.size()>0 && accountMap!= null && accountMap.size()>0){
				for(HexaBPM__Service_Request__c objSR : scope){
					if(objSR.HexaBPM__Customer__c!=NULL){
						objSR.student__c = 	oldNewAccountMap.get(objSR.HexaBPM__Customer__c).id;
					}
					system.debug('---objSR.student__c---'+objSR.student__c);
				}
				update scope;
			}
		}catch(exception e) {
			GEMS_Utility.LogException(e);
			Database.rollback(spdata);
		}
	}

	global void finish(Database.BatchableContext BC) {
	}  
	
	public void UpdateStudentId(Account objStudent, map<id,Account> oldNewAccountMap){
		string FeeId;
		decimal dFeeId;
        map<string,decimal> MapLastFeeId = new map<string,decimal>();
        system.debug('----objStudent---'+objStudent);
        map<string,School__c> MapSchool = new map<string,School__c>();
        system.debug('----objStudent.school__c---'+objStudent.school__c);      
       	if(objStudent.school__c!=null){
            for(School__c sch:[Select Id,ID__c,Name,sys_Last_Fee_Id__c from School__c where Id =:objStudent.school__c and ID__c!=null and sys_Last_Fee_Id__c!=null]){
                MapSchool.put(sch.Id,sch);
            }   
       	}
       	
       	if(MapSchool!=null && MapSchool.size()>0){
	        system.debug('----MapSchool---'+MapSchool);
	        objStudent.Fee_ID__c = string.valueof(MapSchool.get(objStudent.School__c).sys_Last_Fee_Id__c+1);
	        dFeeId = MapSchool.get(objStudent.School__c).sys_Last_Fee_Id__c+1;
        
	        FeeId = objStudent.Fee_ID__c;
	        if(FeeId.length()<8){
	            string PreceedingFeeId = '0';
	            for(integer i=1;i<8-objStudent.Fee_ID__c.length();i++){
	                PreceedingFeeId = PreceedingFeeId+'0';
	            }
	            FeeId = PreceedingFeeId+FeeId;
	        }
	        
	        
	        objStudent.Student_Id__c = MapSchool.get(objStudent.School__c).Id__c+FeeId;
	        objStudent.Sibling_ID__c = MapSchool.get(objStudent.School__c).Id__c+FeeId;
	        
	        if(oldNewAccountMap.get(objStudent.father__c)!=null)
	        	objStudent.father__c = oldNewAccountMap.get(objStudent.father__c).id;
	        
	        if(oldNewAccountMap.get(objStudent.mother__c)!=null)
	        	objStudent.mother__c = oldNewAccountMap.get(objStudent.mother__c).id;
	        
	        if(oldNewAccountMap.get(objStudent.guardian_1__c)!=null)
	        	objStudent.guardian_1__c = oldNewAccountMap.get(objStudent.guardian_1__c).id;
	        
	        if(oldNewAccountMap.get(objStudent.guardian_2__c)!=null)
	        	objStudent.guardian_2__c = oldNewAccountMap.get(objStudent.guardian_2__c).id;
	      	
	      	update objStudent;
	      	
       	} 	
		list<School__c> lstschool = new list<School__c>();
       	lstschool =  [Select Id,ID__c,Name,sys_Last_Fee_Id__c from School__c where Id =: objStudent.school__c];
       	if(lstschool!=null && lstschool.size()>0){
			for(School__c sc: lstschool){
		        if(string.isNotBlank(objStudent.Fee_ID__c)){
		            sc.sys_Last_Fee_Id__c = decimal.valueof(objStudent.Fee_ID__c) ;
		        }
		    }
		    update lstschool;
        }
    }
}