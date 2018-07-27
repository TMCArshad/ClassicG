@isTest
private class GEMS_SchedulePromotionsUpdateBatchTest{

     static testmethod void  testschedule(){
         
         Test.StartTest();
         
         GEMS_SchedulePromotionsUpdateBatch sh1 = new GEMS_SchedulePromotionsUpdateBatch();      
         String sch = '0  00 1 3 * ?';
         system.schedule('Test', sch, sh1);
         
         
         Test.stopTest();
     
     }


}