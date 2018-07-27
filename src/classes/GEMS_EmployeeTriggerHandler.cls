/**************************************************************************************************
 * Name               : GEMS_EmployeeTriggerHandler                                                    *
 * Description        : Employee Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                               *
 **************************************************************************************************/
public with sharing class GEMS_EmployeeTriggerHandler {
	public GEMS_EmployeeTriggerHandler() {
		
	}

	public void Ececute_AU(List<Employee__c> employees,Map<Id,Employee__c> oldMap){
     
    deleteEmployees(employees);
	}

	public void deleteEmployees(List<Employee__c> employees){
		List<Id> deletionList =  new List<Id>();
		for(Employee__c emp : employees ){
            if(emp.Sys_is_deleted__c){
                deletionList.add(emp.Id);
            }
		}
		if(!deletionList.isEmpty()){
           Database.delete(deletionList);
		}
	}
}