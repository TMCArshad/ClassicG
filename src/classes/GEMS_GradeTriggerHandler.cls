/**************************************************************************************************
 * Name               : GEMS_GradeTriggerHandler                                                    *
 * Description        : Grade Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                               *
 **************************************************************************************************/
public with sharing class GEMS_GradeTriggerHandler {
	public GEMS_GradeTriggerHandler() {
		
	}
	public void execute_AU(List<Grade__c> grade_List,Map<Id,Grade__c> oldMap){
    deleteGrades(grade_List);
	}
	public void deleteGrades(List<Grade__c> grade_List){
     list<Id> deletionList = new List<Id>();
     for(Grade__c gradeObj : grade_List){
              if(gradeObj.sys_is_deleted__c){
                 deletionList.add(gradeObj.Id);
              }

     }
     if(!deletionList.isEmpty()){
       Database.delete(deletionList);
     }
	}
}