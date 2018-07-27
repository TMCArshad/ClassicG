/**************************************************************************************************
 * Name               : GEMS_SchoolTriggerHandler                                                    *
 * Description        : School Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                               *
 **************************************************************************************************/
public with sharing class GEMS_SchoolTriggerHandler {
	public GEMS_SchoolTriggerHandler() {
		
	}

	public  void execute_AU(List<School__c> school_List,Map<Id,School__c> oldMap){
        //delete records marked for deletion
        deleteSchools(school_List);
	}
   /**
    * [deleteSchools Delete schools thatare marked for deletion]
    * @param school_List [description]
    */
    public  void deleteSchools(List<School__c> school_List){
    	List<Id> deleteList = new List<Id>();
    	for(School__c schObj : school_List){
       
          if(schObj.sys_is_deleted__c){
            deleteList.add(schObj.id);
          }
    	}
    	if(!deleteList.isEmpty()){
           Database.delete(deleteList);
    	}
    }
}