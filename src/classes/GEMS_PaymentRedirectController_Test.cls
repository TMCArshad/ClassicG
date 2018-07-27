@isTest
private class GEMS_PaymentRedirectController_Test {
	
	public static list<Reciept__c> createReciepts(list<HexaBPM__Service_Request__c> SR_list){
    	list<Reciept__c> receiptlist = new list<Reciept__c>();
      	Reciept__c receiptObj; 
      	for(HexaBPM__Service_Request__c srObj : SR_list){
        	receiptObj = new Reciept__c();
         	receiptObj.SR_Ids__c = srObj.Id;
         	receiptObj.Return_URL__c = 'http://www.google.com';
         	receiptObj.Order_Info__c = 'Registration';
         	receiptObj.SR_Ids__c =srObj.id;
         	receiptlist.add(receiptObj);
      	}
     	insert receiptlist;
    	return receiptlist;
	}
	
	public static map<String,String> getResponsemap(String receiptId){
		map<String,String> responsemap = new map<String,String>();
		responsemap.put('vpc_AcqAVSRespCode','vpc_AcqAVSRespCode');
	    responsemap.put('vpc_AcqCSCRespCode','vpc_AcqCSCRespCode');
	    responsemap.put('vpc_AcqResponseCode','vpc_AcqResponseCode');
	    responsemap.put('vpc_Amount','1000');
	    responsemap.put('vpc_AuthorizeId','211036');
	    responsemap.put('vpc_AVSResultCode','Unsupported');
	    responsemap.put('vpc_BatchNo','20170524');
	    responsemap.put('vpc_Command','pay');
	    responsemap.put('vpc_Card','VC');
	    responsemap.put('vpc_CSCResultCode','Unsupported');
	    responsemap.put('vpc_Currency','AED');
	    responsemap.put('vpc_Locale','en');
	    responsemap.put('vpc_Merchant','TEST825866000');
	    responsemap.put('vpc_MerchTxnRef',receiptId);
	    responsemap.put('vpc_Message','Approved');
	    responsemap.put('vpc_OrderInfo','Registration Fee');
	    responsemap.put('vpc_ReceiptNo','714418211036');
	    responsemap.put('vpc_RiskOverallResult','ACC');
	    responsemap.put('vpc_SecureHash','6D004264CE6155C11FDA4C54E8AB846EF8CE5F6764528679D7B7C2619D05D49E');
	    responsemap.put('vpc_SecureHashType','SHA256');
	    responsemap.put('vpc_TransactionNo','979');
	    responsemap.put('vpc_TxnResponseCode','0');
	    responsemap.put('vpc_Version','1');
	    responsemap.put('vpc_Message','Approved');
	   
	    responsemap.put('vpc_VerType','');
	    responsemap.put('vpc_VerStatus','');
	    responsemap.put('vpc_Token','');
	    responsemap.put('vpc_VerSecurLevel','');
	    responsemap.put('vpc_Enrolled','');
	    responsemap.put('vpc_Xid','');
	    responsemap.put('vpc_AcqECI','');
	    responsemap.put('vpc_AuthStatus','');
	
	    ////////QueryDR status
	    responsemap.put('vpc_RiskOverallResult','');
	    responsemap.put('vpc_FoundMultipleDRs','');
	    return responsemap;
	}
	
	@isTest static void test_method1() {
		
		HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Registered');
        HexaBPM__SR_Status__c srStatus2 = GEMS_TestUtils.createSRStatus('Approved');
        HexaBPM__SR_Status__c srStatus3 = GEMS_TestUtils.createSRStatus('Rejected');
        
        HexaBPM__Status__c stepStatus1 = GEMS_TestUtils.createStepStatus('APPROVED');
        HexaBPM__Status__c stepStatus2 = GEMS_TestUtils.createStepStatus('REJECTED');
        
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        Product2 objProd = new Product2(Name='registration',ProductCode='registration');
        insert objProd;
        
        HexaBPM__Pricing_Line__c PL = new HexaBPM__Pricing_Line__c();
        PL.HexaBPM__Active__c = true;
        PL.HexaBPM__Product__c = objProd.Id;
        PL.HexaBPM__Priority__c = 1;
        insert PL;
        
        list<HexaBPM__SR_Price_Item__c> lstSRPs = new list<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c SRP = new HexaBPM__SR_Price_Item__c();
        SRP.HexaBPM__ServiceRequest__c = objSR.Id;
        SRP.HexaBPM__Non_Reevaluate__c = true;
        SRP.HexaBPM__Sys_Added_through_Code__c = true;
        SRP.HexaBPM__Base_Price__c = 100;
        SRP.HexaBPM__Product__c = objProd.Id;
        SRP.Status__c = 'Added';
        SRP.HexaBPM__Pricing_Line__c = PL.Id;
        lstSRPs.add(SRP);
        insert lstSRPs;
        
        list<HexaBPM__Service_Request__c> SR_list =  new list<HexaBPM__Service_Request__c>();
        list<Reciept__c> receipts = new list<Reciept__c> ();
        receipts = createReciepts(SR_list);
        if(receipts!=null && receipts.size()>0){
        	GEMS_PaymentRedirectController obj = new GEMS_PaymentRedirectController();
	        map<String,String> responsemap = getResponsemap(receipts[0].Id);
	        obj.handleRedirect();
        }
        
	}
	
}