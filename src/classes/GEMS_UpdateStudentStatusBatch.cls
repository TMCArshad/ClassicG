global  without sharing class GEMS_UpdateStudentStatusBatch implements Database.Batchable<sObject> {
    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String TCSRQueryStr = 'SELECT Id,Current_Status__c,Leave_Date__c,Cancel_Date__c,SO_Cancel_Date__c FROM Account WHERE Current_Status__c = \'EN\' AND Leave_Date__c != NULL' ;
        return Database.getQueryLocator(TCSRQueryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('**GEMS_UpdateStudentStatusBatch execute **');
        
        List<Account> studentList = new List<Account>();
        try {
            for (Account acc :  scope) {
                boolean flag = false;
                if(acc.Leave_Date__c != null && acc.Cancel_Date__c != null && acc.SO_Cancel_Date__c != null && acc.Leave_Date__c > acc.Cancel_Date__c && acc.Leave_Date__c > acc.SO_Cancel_Date__c){
                    acc.Current_Status__c = 'TC';
                    flag = true;
                }else if(acc.Leave_Date__c <= System.Today() && acc.SO_Cancel_Date__c == null  && acc.Cancel_Date__c != null && acc.Leave_Date__c > acc.Cancel_Date__c) {
                    acc.Current_Status__c = 'TC';
                    flag = true;
                } else if(acc.Leave_Date__c <= System.Today() && acc.Cancel_Date__c == null && acc.SO_Cancel_Date__c != null && acc.Leave_Date__c > acc.SO_Cancel_Date__c) {
                    acc.Current_Status__c = 'TC';
                    flag = true;
                } else if(acc.Leave_Date__c <= System.Today() && acc.Cancel_Date__c == null && acc.SO_Cancel_Date__c == null){
                    acc.Current_Status__c = 'TC';
                    flag = true;
                }
                if(flag){
                	studentList.add(acc);    
                }
                
                
            }
            
            System.debug('studentList==>' + studentList.size());
            if (!studentList.isEmpty()) {
                update studentList;
            }
        } catch (Exception e) {
            GEMS_Utility.LogException(e);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        /*try{
            //System.abortJob(bc.getJobId());
        }catch(Exception e){
            //GEMS_Utility.logException(e);
        }*/
    }
    
}