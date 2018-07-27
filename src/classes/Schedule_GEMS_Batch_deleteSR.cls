/*********************************************************************************************************************
 *  Name        : Schedule_GEMS_Batch_deleteSR
 *  Author      : Leeba Shibu
 *  Date        : 19th March 2017    
 *  Purpose     : This is a Scheduler class to schedule the GEMS_Batch_deleteSR class
 --------------------------------------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No    Date        Updated By    Description
 ----------------------------------------------------------------------------------------  
****************************************************************************************************/
global with sharing class Schedule_GEMS_Batch_deleteSR implements Schedulable {
     global void execute(SchedulableContext SC) {
         GEMS_Batch_deleteSR objBtchSR = new GEMS_Batch_deleteSR();
         database.executebatch(objBtchSR);
     }
}