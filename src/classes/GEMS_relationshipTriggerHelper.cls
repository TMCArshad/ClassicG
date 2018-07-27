/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   19th April 2017
    Description :   GEMS_relationshipTriggerHelper.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_relationshipTriggerHelper {
    
    
    //if relationship is created manually it update the same on student level in father, mother and guardian fields
    public static void updateStudentParentDetails(list<Relationship__c> relationshipList, boolean isUpdate){
    	try{
		
	    	map<id, Relationship__c> mapOfRelationship = new map<id, Relationship__c>();
	    	set<id> parentID = new set<id>();
	    	
	    	if(relationshipList!=null && relationshipList.size()>0){
	    		for(Relationship__c obj : relationshipList){
	    			if(string.isNotBlank(obj.Subject_Account__c) && obj.active__c == true){
	    				mapOfRelationship.put(obj.Subject_Account__c, obj);
	    				if(obj.type__c!='Sibling'){
	    					parentID.add(obj.object_account__c);
	    				}
	    			}	
	    		}
	    	}	
	    	
	    	string parentRecordTypeId = '';
			string studentRecordTypeId = '';
	        for (RecordType rectyp: [select id, DeveloperName from RecordType where sObjectType = 'Account']) {
	            if(rectyp.DeveloperName == 'Parent_Guardian')
	            	parentRecordTypeId = rectyp.Id;
	            else if(rectyp.DeveloperName == 'Student')
	            	studentRecordTypeId = rectyp.Id;
	        }
			
			
	    	map<id,Account> parentAccount = new map<id,Account>();
	    	if(parentID!=null && parentID.size()>0){
	    		for(Account objPar : [select id, personEmail,personMobilePhone, firstName, middleName,lastName from Account 
	    							  where recordTypeId =: parentRecordTypeId and 
	    							  id IN : parentID]){
	    			parentAccount.put(objPar.id,objPar);	
	    		}
	    	}
	    	
	    	if(mapOfRelationship!=null && mapOfRelationship.size()>0){
	    		list<Account> studentToUpdate = new list<Account>();
	    		
	    		for(Account objAcc : [select id, father__c, mother__c, guardian_1__c, guardian_2__c,
	    									 Primary_Contact__c,sys_fromSRClosure__c
	    							  from Account
	    							  where id IN : mapOfRelationship.keySet()]){
	    			
						if(mapOfRelationship.get(objAcc.id)!=null && mapOfRelationship.get(objAcc.id).type__c == 'Father'){
							objAcc.father__c = 	mapOfRelationship.get(objAcc.id).object_account__c;
							if(objAcc.Primary_Contact__c == 'Father' && !parentAccount.isEmpty() && parentAccount.get(objAcc.father__c)!=null){
					            
					            string name;
								if(string.isNotBlank(parentAccount.get(objAcc.father__c).firstName)){
									name = 	parentAccount.get(objAcc.father__c).firstName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.father__c).middleName)){
									name = 	name+' '+parentAccount.get(objAcc.father__c).middleName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.father__c).lastName)){
									name = 	name+' '+parentAccount.get(objAcc.father__c).lastName;
								}
					            
					            objAcc.Primary_Contact_Email__c = parentAccount.get(objAcc.father__c).personEmail;
					            objAcc.primary_contact_name__c = name;
					        	objAcc.Emergency_Contact_Number__c = parentAccount.get(objAcc.father__c).personMobilePhone;
					        }
						}
						
						else if(mapOfRelationship.get(objAcc.id)!=null && mapOfRelationship.get(objAcc.id).type__c == 'Mother'){
							objAcc.Mother__c = 	mapOfRelationship.get(objAcc.id).object_account__c;
							if(objAcc.Primary_Contact__c == 'Mother' && !parentAccount.isEmpty() && parentAccount.get(objAcc.Mother__c)!=null){
					            
					            string name;
								if(string.isNotBlank(parentAccount.get(objAcc.Mother__c).firstName)){
									name = 	parentAccount.get(objAcc.Mother__c).firstName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.Mother__c).middleName)){
									name = 	name+' '+parentAccount.get(objAcc.Mother__c).middleName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.Mother__c).lastName)){
									name = 	name+' '+parentAccount.get(objAcc.Mother__c).lastName;
								}
					            
					            objAcc.Primary_Contact_Email__c = parentAccount.get(objAcc.Mother__c).personEmail;
					            objAcc.primary_contact_name__c = name;
					        	objAcc.Emergency_Contact_Number__c = parentAccount.get(objAcc.mother__c).personMobilePhone;
					        }
						}
						
						else if(mapOfRelationship.get(objAcc.id)!=null && mapOfRelationship.get(objAcc.id).type__c == 'Guardian' && objAcc.guardian_1__c==null && objAcc.guardian_2__c==null){
							objAcc.guardian_1__c = 	mapOfRelationship.get(objAcc.id).object_account__c;
							if(objAcc.Primary_Contact__c == 'Guardian' && !parentAccount.isEmpty() && parentAccount.get(objAcc.guardian_1__c)!=null){
					            
					            string name;
								if(string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).firstName)){
									name = 	parentAccount.get(objAcc.guardian_1__c).firstName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).middleName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_1__c).middleName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).lastName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_1__c).lastName;
								}
							
					            objAcc.Primary_Contact_Email__c = parentAccount.get(objAcc.guardian_1__c).personEmail;
					            objAcc.primary_contact_name__c = name;
					        	objAcc.Emergency_Contact_Number__c = parentAccount.get(objAcc.guardian_1__c).personMobilePhone;
					        }
						}
						
						else if(mapOfRelationship.get(objAcc.id)!=null && mapOfRelationship.get(objAcc.id).type__c == 'Guardian' && objAcc.guardian_1__c!=null && objAcc.guardian_2__c==null){
							objAcc.guardian_2__c = 	mapOfRelationship.get(objAcc.id).object_account__c;
							if(objAcc.Primary_Contact__c == 'Guardian' && !parentAccount.isEmpty() && parentAccount.get(objAcc.guardian_2__c)!=null){
					            
					            string name;
								if(string.isNotBlank(parentAccount.get(objAcc.guardian_2__c).firstName)){
									name = 	parentAccount.get(objAcc.guardian_2__c).firstName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_2__c).middleName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_2__c).middleName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_2__c).lastName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_2__c).lastName;
								}
					            
					            objAcc.Primary_Contact_Email__c = parentAccount.get(objAcc.guardian_2__c).personEmail;
					            objAcc.primary_contact_name__c = name;
					        	objAcc.Emergency_Contact_Number__c = parentAccount.get(objAcc.guardian_2__c).personMobilePhone;
					        }
						}
						
						else if(mapOfRelationship.get(objAcc.id)!=null && mapOfRelationship.get(objAcc.id).type__c == 'Guardian' && objAcc.guardian_2__c!=null && objAcc.guardian_1__c == null){
							objAcc.guardian_1__c = 	mapOfRelationship.get(objAcc.id).object_account__c;
							if(objAcc.Primary_Contact__c == 'Guardian' && !parentAccount.isEmpty() && parentAccount.get(objAcc.guardian_1__c)!=null){
					            
					            string name;
								if(string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).firstName)){
									name = 	parentAccount.get(objAcc.guardian_1__c).firstName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).middleName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_1__c).middleName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).lastName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_1__c).lastName;
								}
					            
					            objAcc.Primary_Contact_Email__c = parentAccount.get(objAcc.guardian_1__c).personEmail;
					            objAcc.primary_contact_name__c = name;
					        	objAcc.Emergency_Contact_Number__c = parentAccount.get(objAcc.guardian_1__c).personMobilePhone;
					        }
						}
						
						else if(mapOfRelationship.get(objAcc.id)!=null && mapOfRelationship.get(objAcc.id).type__c == 'Guardian' && objAcc.guardian_2__c!=null && objAcc.guardian_1__c != null){
							objAcc.guardian_1__c = 	mapOfRelationship.get(objAcc.id).object_account__c;
							if(objAcc.Primary_Contact__c == 'Guardian' && !parentAccount.isEmpty() && parentAccount.get(objAcc.guardian_1__c)!=null){
					            
					            string name;
								if(string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).firstName)){
									name = 	parentAccount.get(objAcc.guardian_1__c).firstName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).middleName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_1__c).middleName;
								}
								
								if(string.isNotBlank(name) && string.isNotBlank(parentAccount.get(objAcc.guardian_1__c).lastName)){
									name = 	name+' '+parentAccount.get(objAcc.guardian_1__c).lastName;
								}
					            
					            objAcc.Primary_Contact_Email__c = parentAccount.get(objAcc.guardian_1__c).personEmail;
					            objAcc.primary_contact_name__c = name;
					        	objAcc.Emergency_Contact_Number__c = parentAccount.get(objAcc.guardian_1__c).personMobilePhone;
					        }
						}
					
	    			studentToUpdate.add(objAcc);	
	    		}	
	    		
	    		if(studentToUpdate!=null && studentToUpdate.size()>0){
	    			update studentToUpdate;
	    		}
	    	}
	    }catch(Exception e){
		  	GEMS_Utility.logException(e);
	  	}
    }
}