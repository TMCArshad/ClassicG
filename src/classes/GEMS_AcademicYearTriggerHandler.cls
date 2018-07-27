/**************************************************************************************************
 * Name               : GEMS_AcademicYearTriggerHandler                                                    *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         Swati-PWC         	25/12/2017                                              *
 **************************************************************************************************/

public  class GEMS_AcademicYearTriggerHandler {
	GEMS_AcademicYearTriggerHelper helper= new GEMS_AcademicYearTriggerHelper();
    
    public void Execute_BI(list<Academic_Year__c> AY_list) {
         helper.populateAcademicYearDisplayName(AY_list);
    }

    public void Execute_AI(list<Academic_Year__c> AY_list) {
    }

    public void Execute_BU(list<Academic_Year__c> AY_list, map<Id, Academic_Year__c> oldMap) {
	   	helper.populateAcademicYearDisplayName(AY_list);
	   	//1.0 
	   	helper.validateReEnrolmentFee(AY_list,oldMap);
    }

    public void Execute_AU(list<Academic_Year__c> AY_list, map<Id, Academic_Year__c> oldMap) {
    	helper.deleteAcademicYears(AY_list);
    }
}