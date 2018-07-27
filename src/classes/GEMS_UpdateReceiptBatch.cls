/**************************************************************************************************
* Name               : GEMS_UpdateReceiptBatch                                                               *
* Description        : Runs query DR for failed receipts                                          *
* Created Date       : 23/5/2017                                                                  *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017
* 1.1        Leeba        26/3/2018 CR -added sys generate receipt to true when approved by batch
**************************************************************************************************/

global class GEMS_UpdateReceiptBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public string query;

    global GEMS_UpdateReceiptBatch(string queryStr) {
        this.query = queryStr;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Get all receipts with status = "Initiated" meaning transaction was initiated but not completed due to failure
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Reciept__c> scope) {
        map<string, string> responseMap;
        list<Reciept__c> receiptUpdateList = new list<Reciept__c>();
        try {
            for (Reciept__c receipt : scope) {
                responseMap = new map<string, string>();
                GEMS_MiGS_Utility.schoolCode = receipt.School_code__c;
                responseMap = GEMS_MiGS_Utility.getReceiptStatusResponse('',receipt);
                receiptUpdateList.add(setReceiptDetails(receipt, responseMap)); 
            }
            if (!receiptUpdateList.isEmpty()) {
                update receiptUpdateList;
                
                for(Reciept__c receipt : receiptUpdateList){
                    if(string.isNotBlank(receipt.Amount__c) && 
                       string.isNotBlank(receipt.Transaction_Status__c) &&
                       receipt.Transaction_Status__c=='Completed' &&
                       string.isNotBlank(receipt.Message__c) &&
                       receipt.Message__c=='Approved'){
                        
                        GEMS_PaymentRedirectController obj = new GEMS_PaymentRedirectController();
                        obj.updateSRPriceItemStatus(receipt);   
                        obj.splitReceipt(receipt);  
                    }
                }
            }
        }catch (Exception e) {
            system.debug('-----'+e.getMessage()+'----'+e.getLinenumber());
            GEMS_Utility.logException(e);
        }
    }

    global void finish(Database.BatchableContext BC) {
        try{
        }catch(Exception e){
            GEMS_Utility.logException(e);
        }
    }
    
    public Reciept__c setReceiptDetails(Reciept__c receipt, map<string, string> responseMap) {
        
        receipt.AcqAVSRespCode__c = (string.isBlank(receipt.AcqAVSRespCode__c))  ? responseMap.get('vpc_AcqAVSRespCode') : receipt.AcqAVSRespCode__c ;
        receipt.AcqCSCRespCode__c = (string.isBlank(receipt.AcqCSCRespCode__c)) ? responseMap.get('vpc_AcqCSCRespCode') : receipt.AcqCSCRespCode__c ;
        receipt.AcqResponseCode__c = (string.isBlank(receipt.AcqResponseCode__c)) ? responseMap.get('vpc_AcqResponseCode') : receipt.AcqResponseCode__c;
        receipt.Amount__c = (string.isBlank(receipt.Amount__c) && responseMap.containsKey('vpc_Amount'))  ? responseMap.get('vpc_Amount').removeEnd('00') : receipt.Amount__c ;
        receipt.AuthorizeId__c = (string.isBlank(receipt.AuthorizeId__c)) ? responseMap.get('vpc_AuthorizeId') :receipt.AuthorizeId__c ;
        receipt.AVSResult_Code__c = (string.isBlank(receipt.AVSResult_Code__c)) ?  responseMap.get('vpc_AVSResultCode') : receipt.AVSResult_Code__c;
        receipt.Batch_Number__c = (string.isBlank(receipt.Batch_Number__c)) ? responseMap.get('vpc_BatchNo') : receipt.Batch_Number__c;
        receipt.Command__c = (string.isBlank(receipt.Command__c)) ? responseMap.get('vpc_Command') : receipt.Command__c;
        receipt.Card__c =(string.isBlank(receipt.Card__c)) ? responseMap.get('vpc_Card') : receipt.Card__c;
        receipt.CSCResultCode__c =(string.isBlank(receipt.CSCResultCode__c))? responseMap.get('vpc_CSCResultCode') : receipt.CSCResultCode__c;
        receipt.Currency__c = (string.isBlank(receipt.Currency__c)) ? responseMap.get('vpc_Currency')  : receipt.Currency__c;
        receipt.Locale__c = (string.isBlank(receipt.Locale__c)) ? responseMap.get('vpc_Locale') : receipt.Locale__c;
        receipt.Merchant__c = (string.isBlank(receipt.Merchant__c)) ? responseMap.get('vpc_Merchant') : receipt.Merchant__c;
        receipt.MerchTxnRef__c = (string.isBlank(receipt.MerchTxnRef__c)) ?  responseMap.get('vpc_MerchTxnRef') :receipt.MerchTxnRef__c ;
        receipt.Message__c = (string.isBlank(receipt.Message__c)) ? responseMap.get('vpc_Message') : receipt.Message__c;
        receipt.Order_Info__c =(string.isBlank(receipt.Order_Info__c)) ? responseMap.get('vpc_OrderInfo') : receipt.Order_Info__c;
        receipt.ReceiptNo__c = (string.isBlank(receipt.ReceiptNo__c)) ? responseMap.get('vpc_ReceiptNo') :  receipt.ReceiptNo__c;
        receipt.RiskOverallResult__c = (string.isBlank(receipt.RiskOverallResult__c)) ? responseMap.get('vpc_RiskOverallResult') : receipt.RiskOverallResult__c;
        receipt.SecureHash__c = (string.isBlank(receipt.SecureHash__c)) ? responseMap.get('vpc_SecureHash') : receipt.SecureHash__c;
        receipt.SecureHashType__c = (string.isBlank(receipt.SecureHashType__c)) ? responseMap.get('vpc_SecureHashType') : receipt.SecureHashType__c;
        receipt.TransactionNo__c = (string.isBlank(receipt.TransactionNo__c)) ? responseMap.get('vpc_TransactionNo') : receipt.TransactionNo__c;
        receipt.TxnResponseCode__c = (string.isBlank(receipt.TxnResponseCode__c)) ? responseMap.get('vpc_TxnResponseCode') :  receipt.TxnResponseCode__c;
        receipt.Version__c = (string.isBlank(receipt.Version__c)) ? responseMap.get('vpc_Version') :  receipt.Version__c;
        
        //Asper Lebas request to populate additional field from response
        //Values are null as of now
        // 2-5-2017
        receipt.VerType__c = (string.isBlank(receipt.VerType__c)) ? responseMap.get('vpc_VerType') :  receipt.VerType__c;
        receipt.VerStatus__c =(string.isBlank(receipt.VerStatus__c)) ? responseMap.get('vpc_VerStatus') : receipt.VerStatus__c;
        receipt.Token__c =(string.isBlank(receipt.Token__c)) ? responseMap.get('vpc_Token') :  receipt.Token__c;
        receipt.VerSecurLevel__c = (string.isBlank(receipt.VerSecurLevel__c)) ?responseMap.get('vpc_VerSecurLevel') : receipt.VerSecurLevel__c;
        receipt.Enrolled__c = (string.isBlank(receipt.Enrolled__c)) ? responseMap.get('vpc_Enrolled') : receipt.Enrolled__c;
        receipt.Xid__c =  (string.isBlank(receipt.Xid__c)) ? responseMap.get('vpc_Xid') : receipt.Xid__c;
        receipt.AcqECI__c = (string.isBlank(receipt.AcqECI__c)) ? responseMap.get('vpc_AcqECI') : receipt.AcqECI__c;
        receipt.AuthStatus__c =(string.isBlank(receipt.AuthStatus__c)) ?  responseMap.get('vpc_AuthStatus') : receipt.AuthStatus__c;

        ////////QueryDR status
        receipt.RiskOverallResult__c =  responseMap.get('vpc_RiskOverallResult');
        receipt.FoundMultipleDRs__c = responseMap.get('vpc_FoundMultipleDRs');
        receipt.DRExists__c = responseMap.get('vpc_DRExists');
        //Update receipt transaction status
        
        if(string.isNotBlank(receipt.Amount__c) &&
           string.isNotBlank(receipt.Message__c) &&
           receipt.Message__c=='Approved'){
            
            receipt.Transaction_Status__c = 'Completed';
            receipt.Update_through_Receipt_Batch__c = true; 
            //1.1
            receipt.Sys_Generate_Receipt__c = true;
        }
        
        return receipt;
    }
}