/**
 * Created by bilalnazir on 6/1/17.
 */

@IsTest
private class GEMS_UpdateReceiptSchedule_Test {
    static testMethod void testReceiptScheduler() {
        List<Reciept__c>reciepts = new List<Reciept__c>();

        Reciept__c reciept = null;

        reciept = new Reciept__c(
                AcqAVSRespCode__c = '1234',
                AcqCSCRespCode__c = '13434',
                Amount__c = '100,00',
                AuthorizeId__c='48839',
                AVSResult_Code__c='13345',
                Batch_Number__c = '384893',
                Card__c = '13883839394883',
                Command__c = 'Add',
                CSCResultCode__c = '2949393',
                Currency__c = 'AED',
                Merchant__c = '19393993',
                MerchTxnRef__c = ' 292921_ref',
                Order_Info__c='39393',
                ReceiptNo__c='23992929',
                TransactionNo__c='2993922',
                TxnResponseCode__c='293933',
                school_code__c = '3939393',
                Transaction_Status__c = 'Initiated'
        );

            reciepts.add(reciept);
        insert reciepts;

        Test.startTest();
        GEMS_UpdateReceiptSchedule receiptSchedule = new GEMS_UpdateReceiptSchedule();
        receiptSchedule.execute(null);
        Test.stopTest();

    }
}