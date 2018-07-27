@isTest
private class GEMS_MiGS_Utility_Test {
	
    public static List<School__c> createSchools(Integer n ){
    	List<School__c> schoolList = new List<School__c>();
    	School__c schObj;
    	for(Integer i =0 ; i<n;i++){
    		schObj = new School__c();
    		schObj.Name = 'SCHOOL_'+i;
    		schObj.Short_Name__c = 'SN'+i;
    		schObj.ID__c = '11111'+i;
    		schoolList.add(schObj);
    	}
    	insert schoolList;
    	return schoolList;
    }
	

	public static List<Reciept__c> createReciepts(Integer n){
      List<Reciept__c> receiptList = new List<Reciept__c>();
      Reciept__c receiptObj; 
      for(Integer  i=0;i<n;i++){
         receiptObj = new Reciept__c();
         receiptList.add(receiptObj);
      }
     insert receiptList;
     return receiptList;
	}
	
	public static Map<String,String> getResponseMap(String receiptId){
	Map<String,String> responseMap = new Map<String,String>();
	responseMap.put('vpc_AcqAVSRespCode','vpc_AcqAVSRespCode');
    responseMap.put('vpc_AcqCSCRespCode','vpc_AcqCSCRespCode');
    responseMap.put('vpc_AcqResponseCode','vpc_AcqResponseCode');
    responseMap.put('vpc_Amount','1000');
    responseMap.put('vpc_AuthorizeId','211036');
    responseMap.put('vpc_AVSResultCode','Unsupported');
    responseMap.put('vpc_BatchNo','20170524');
    responseMap.put('vpc_Command','pay');
    responseMap.put('vpc_Card','VC');
    responseMap.put('vpc_CSCResultCode','Unsupported');
    responseMap.put('vpc_Currency','AED');
    responseMap.put('vpc_Locale','en');
    responseMap.put('vpc_Merchant','TEST825866000');
    responseMap.put('vpc_MerchTxnRef',receiptId);
    responseMap.put('vpc_Message','Approved');
    responseMap.put('vpc_OrderInfo','Registration Fee');
    responseMap.put('vpc_ReceiptNo','714418211036');
    responseMap.put('vpc_RiskOverallResult','ACC');
    responseMap.put('vpc_SecureHash','6D004264CE6155C11FDA4C54E8AB846EF8CE5F6764528679D7B7C2619D05D49E');
    responseMap.put('vpc_SecureHashType','SHA256');
    responseMap.put('vpc_TransactionNo','979');
    responseMap.put('vpc_TxnResponseCode','0');
    responseMap.put('vpc_Version','1');
    responseMap.put('vpc_Message','Approved');
   
    responseMap.put('vpc_VerType','');
    responseMap.put('vpc_VerStatus','');
    responseMap.put('vpc_Token','');
    responseMap.put('vpc_VerSecurLevel','');
    responseMap.put('vpc_Enrolled','');
    responseMap.put('vpc_Xid','');
    responseMap.put('vpc_AcqECI','');
    responseMap.put('vpc_AuthStatus','');

    ////////QueryDR status
    responseMap.put('vpc_RiskOverallResult','');
    responseMap.put('vpc_FoundMultipleDRs','');
    return responseMap;
	}
	@isTest static void test_method_one() {
		// Implement test code
		// Create School data
		List<School__c> schoolList = createSchools(10);
		//Create Receipt data
        List<Reciept__c> receiptList =  createReciepts(10);

		GEMS_MiGS_Utility obj = new GEMS_MiGS_Utility();
		GEMS_MiGS_Utility.schoolCode = schoolList[0].ID__c;
		Test.startTest();
		GEMS_MiGS_Utility.getActiveMigsConfig();
		String MigsPaymentURl = GEMS_MiGS_Utility.getMiGSPaymentURL('1000', 'orderName','http://www.google.com');
		Map<String,String> respMap = GEMS_MiGS_Utility.getReceiptStatusResponse(receiptList[0].Id,null);
		String MD5signature =  GEMS_MiGS_Utility.generateMD5Signature('generateMD5Signature'); 
		Map<String,String> respMap1 = getResponseMap(receiptList[0].Id);
		GEMS_MiGS_Utility.updateReceipt(respMap1);
		GEMS_MiGS_Utility.getResponseCodes();
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}