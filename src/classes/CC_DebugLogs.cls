global without sharing class CC_DebugLogs implements HexaBPM.iCustomCodeExecutable {
    global String EvaluateCustomCode(HexaBPM__Service_Request__c objSR, HexaBPM__Step__c step) {
        /*
        Exception_Log__c log = new Exception_Log__c();
        log.Cause__c = step.HexaBPM__SR__r.Lead_Reference__c;
        insert log;
        */
        
        return 'Success';
    }
}