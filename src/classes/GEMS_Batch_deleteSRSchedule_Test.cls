@isTest
private class GEMS_Batch_deleteSRSchedule_Test
{
	static testMethod void test_method_one() {
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
		
		string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Scholarship' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        
        objSR.recordTypeId = recordTypeId;
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Draft');
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        insert objSR;
        
		Test.startTest();
        GEMS_Batch_deleteSRSchedule obj = new GEMS_Batch_deleteSRSchedule();
        obj.execute(null);
        Test.stopTest();
	}
}