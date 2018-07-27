/**************************************************************************************************
 * Name               : GEMS_SectionMasterTriggerHandler                                                    *
 * Description        : Section Master Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                               *
 **************************************************************************************************/
public with sharing class GEMS_SectionMasterTriggerHandler {
	public GEMS_SectionMasterTriggerHandler() {
		
	}

	public void Execute_AU(List<Section_Master__c> sectionList , Map<Id,Section_Master__c> oldMap){
      deleteSectionMasters(sectionList);
	}
   /**
    * [deleteSectionMasters Delete records marked for deletion]
    * @param sectionList [description]
    */
	public void deleteSectionMasters(List<Section_Master__c> sectionList){
         List<Id> deletionList = new List<Id>();
         for(Section_Master__c sectionObj : sectionList){
             if(sectionObj.sys_is_deleted__c){
               deletionList.add(sectionObj.Id);
             }
         }
         if(!deletionList.isEmpty()){
            Database.delete(deletionList);
         }
	}
	
	public void Execute_BU(List<Section_Master__c> sectionList , Map<Id,Section_Master__c> oldMap){
		set<id> employeeID = new set<id>();
		for(Section_Master__c sectionObj : sectionList){
			if(sectionObj.Form_Tutor__c!=null)
				employeeID.add(sectionObj.Form_Tutor__c);
		}
		map<id,string> employeeName = new map<id,string>();
		if(employeeID!=null && employeeID.size()>0){
			for(Employee__c obj : [select id, Full_Name__c from Employee__c where id IN : employeeID]){
				employeeName.put(obj.id,obj.Full_Name__c);
			}
		}
		
		if(employeeName!=null && employeeName.size()>0){
			for(Section_Master__c sectionObj : sectionList){
				if(sectionObj.Form_Tutor__c!=null && employeeName.get(sectionObj.Form_Tutor__c)!=null && string.isNotBlank(employeeName.get(sectionObj.Form_Tutor__c)))
					sectionObj.Form_Tutor_Name__c = employeeName.get(sectionObj.Form_Tutor__c);
			}
		}
	}
}