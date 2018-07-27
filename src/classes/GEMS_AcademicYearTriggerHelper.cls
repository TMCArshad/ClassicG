/**************************************************************************************************
 * Name               : GEMS_AcademicYearTriggerHelper                                                    *
 * Description        : Academic Year Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         Keerthan-PWC         16/02/2017 
 * 1.1         Swati-PWC         	25/12/2017                                              *
 **************************************************************************************************/
public with sharing class GEMS_AcademicYearTriggerHelper {
	
	/**
	 * [populateAcademicYearDisplayName - Populate Academic year objects Year__c picklist label as display  name]
	 * @param  AY_List [Acadmic_year__c list]
	 * @return         [Void]
	 */
	 public  void  populateAcademicYearDisplayName(list<Academic_year__c> AY_List) {
     	try{
			map<string, string> academicYearNamelabelMap = new map<string, string>();
			schema.DescribeFieldResult fieldResult =
			Academic_Year__c.Year__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for ( Schema.PicklistEntry f : ple) 
				academicYearNamelabelMap.put( f.getValue(), f.getLabel());
			
			for (Academic_Year__c AY :  AY_List) 
				AY.Academic_Year__c = (AY.Year__c != NULL) ? academicYearNamelabelMap.get(AY.Year__c) : NULL;
      	}catch(Exception e){
        	GEMS_Utility.logException(e);
      	}
	}
	
	/**
    * [deleteAcademicYears -Delete recordsmarked for deletion]
    * @param AY_List [description]
    */
	public void deleteAcademicYears(list<Academic_Year__c> AY_List){
    	list<Id> deletionList = new list<Id>();
        for(Academic_Year__c ayObj  : AY_List){
        	if(ayObj.Sys_is_Deleted__c)
            	deletionList.add(ayObj.Id);
		}
		
        if(!deletionList.isEmpty())
        	database.delete(deletionList);
	}

	
	//V1.1 - Re-Enrolment Fee setup check
	public void validateReEnrolmentFee(list<Academic_year__c> AY_List, map<id,Academic_Year__c> oldMap){
		
		map<id,Academic_Year__c> updatedAY = new map<id,Academic_Year__c>();
		if(AY_List!=null && AY_List.size()>0 && 
		   oldMap!=null && oldMap.size()>0){
			
			for(Academic_Year__c ayObj  : AY_List){
				if(ayObj.Re_Enrolment_Start_Date__c!=null &&
				   ayObj.Re_Enrolment_Start_Date__c!=oldmap.get(ayObj.id).Re_Enrolment_Start_Date__c){
					
					updatedAY.put(ayObj.id,ayObj);	
				}		
			}		
		}	
		
		map<id,id> feeSetupMap = new map<id,id>();
		set<id> AYwithoutFee = new set<id>();
		set<id> AYToCheck = new set<id>();
			
		if(updatedAY!=null && updatedAY.size()>0){
			system.debug('---updatedAY---'+updatedAY);
			for(Amount__c obj : [select id,grade_lookup__c,By_Grade__c,Academic_Year__c from Amount__c where Academic_Year__c IN : updatedAY.keySet()
			 				     and Stage_Formula__c='RE-ENROL' and grade_lookup__r.Enable_Re_Enrolment__c=true]){
				if(obj.grade_lookup__c!=null && obj.By_Grade__c == true){
					feeSetupMap.put(obj.grade_lookup__c,obj.id);	
					AYToCheck.add(obj.Academic_Year__c);
				}							 	
 			}
 			
		}
		
		if(AYToCheck!=null && AYToCheck.size()>0){
			string gradeMissing = '';
			system.debug('---feeSetupMap---'+feeSetupMap);
			for(Grade__c obj : [select id,Academic_Year__c,Grade_Display__c from Grade__c where Academic_Year__c IN : AYToCheck and Enable_Re_Enrolment__c=true]){
				if(feeSetupMap!=null && feeSetupMap.size()>0 && 
				   feeSetupMap.containsKey(obj.id)){
						
				}else{
					AYwithoutFee.add(obj.Academic_Year__c);
				}
			}
		}
		
		if(AYwithoutFee!=null && AYwithoutFee.size()>0){
			for(string temp : AYwithoutFee){
				updatedAY.get(temp).addError('Fee Setup is not configured for few grades, Please check.');
			}	
		}
	}

}