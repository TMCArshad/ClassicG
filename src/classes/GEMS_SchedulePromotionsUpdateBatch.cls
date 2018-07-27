/**************************************************************************************************
* Name               : GEMS_BatchPromotionsUpdate                                                 *
* Description        : Schedular which runs promotions update batch                               *
* Created Date       : 21/12/2017                                                                 *
* Created By         : Umair Khan (PWC Digital)                                                   *
* ----------------------------------------------------------------------------------------------- */


global class GEMS_SchedulePromotionsUpdateBatch  implements schedulable{
    
     global void execute(SchedulableContext sc){
         
        GEMS_BatchPromotionsUpdate b = new GEMS_BatchPromotionsUpdate();
        Database.executebatch(b,500);
     }
     
     Webservice static void runFromButton(){
     	GEMS_BatchPromotionsUpdate obj = new GEMS_BatchPromotionsUpdate();
		database.executeBatch(obj);
     }

}