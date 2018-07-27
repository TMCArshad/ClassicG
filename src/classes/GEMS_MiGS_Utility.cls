public with sharing class GEMS_MiGS_Utility {

  public static School__c school {get; set;}
  public static String SRIds {get; set;} //Used to split the bills when multiple SR payment is done
  public static String retURLVal {get; set;} // Return URL value
  public static String schoolCode {get; set;} //School code info for School specific payment
  public static GEMS_MiGS_Config__mdt MiGSDonfigObj;  //Custom Metadata Type with Config info
  public static GEMS_MiGS_Config__mdt getActiveMigsConfig() {

    school = GEMS_Utility.getSchool(schoolCode); 

    //Load payment Gateway config
    GEMS_MiGS_Config__mdt config  = new GEMS_MiGS_Config__mdt();
    String migsConfigQueryStr = GEMS_Utility.getAllFields(GEMS_MiGS_Config__mdt.getsObjectType().getDescribe());
    migsConfigQueryStr += (Test.isRunningTest() ) ? ' LIMIT 1 ' : ' WHERE isActive__c = true AND School_Code__c =:schoolCode LIMIT 1 ';
    //migsConfigQueryStr +=   ' WHERE isActive__c = true AND School_Code__c =:schoolCode LIMIT 1 ';
    config = Database.query(migsConfigQueryStr);
    return config;
  }
  /**
   * [getResponseCodes -returns all possible reponse codes from MiGS]
   * @return [Map<String,String> Map holding response Code and response code meaning]
   */
  public static Map<String, String> getResponseCodes() {

    Map<String, String> paramMap = new Map<String, String>();
    paramMap = new map<string, string>();
    paramMap.put('?', 'Response Unknown');
    paramMap.put('0', 'Transaction Successful');
    paramMap.put('1', 'Transaction could not be processed');
    paramMap.put('2', 'Transaction Declined - Contact Issuing Bank');
    paramMap.put('3', 'Transaction Declined - No reply from Bank');
    paramMap.put('4', 'Transaction Declined - Expired Card');
    paramMap.put('5', 'Transaction Declined - Insufficient credit');
    paramMap.put('6', 'Transaction Declined - Bank system error');
    paramMap.put('7', 'Payment Server Processing Error - invalid input data');
    paramMap.put('8', 'Transaction Declined - Transaction Type Not Supported');
    paramMap.put('9', 'Bank Declined Transaction (Do not contact Bank)');
    paramMap.put('A', 'Transaction Aborted');
    paramMap.put('B', 'Transaction Blocked');
    paramMap.put('C', 'Transaction Cancelled');
    paramMap.put('D', 'Deferred Transaction');
    paramMap.put('E', 'Transaction Declined - Refer to card issuer');
    paramMap.put('F', '3D Secure Authentication Failed');
    paramMap.put('I', 'Card Security Code Failed');
    paramMap.put('L', 'Shopping Transaction Locked');
    paramMap.put('N', 'Cardholder is not enrolled in 3D Secure');
    paramMap.put('P', 'Transaction is Pending');
    paramMap.put('R', 'Retry Limits Exceeded, Transaction Not Processed');
    paramMap.put('T', 'Address Verification Failed');
    paramMap.put('U', 'Card Security Code Failed');
    paramMap.put('V', 'Address Verification and Card Security Code Failed');
    return paramMap;
  }

  /**
   * [getHashMap -Builds hashMAP with key as name and value as value]
   * @param  TransactionID [ReceiptID]
   * @param  Amount        [Amount]
   * @param  orderName     [Name of the order eg :Registration Fee ]
   * @param  retURL        [Return URl info]
   * @return               [returns hashMap]
   */
  public static Map<String, String> getHashMap(String TransactionID, String Amount, String orderName , String retURL) {
    MiGSDonfigObj = getActiveMigsConfig();
    Map<String, String> paramMap = new Map<String, String>();
    paramMap.put('vpc_AccessCode', MiGSDonfigObj.Merchant_Access_Code__c);
    paramMap.put('vpc_Amount', Amount + '00');
    paramMap.put('vpc_Command', 'pay');
    paramMap.put('vpc_Currency', school.Currency__c);
    paramMap.put('vpc_Locale', 'en');
    paramMap.put('vpc_MerchTxnRef', TransactionID);
    paramMap.put('vpc_Merchant', MiGSDonfigObj.Merchant_ID__c);
    paramMap.put('vpc_OrderInfo', orderName.abbreviate(30));
    paramMap.put('vpc_ReturnURL', retURL);
    paramMap.put('vpc_Version', '1');
    return paramMap;
  }

  /**
   * [getHashString -Builds hashString from HashMap]
   * @param  paramMap   [HashMap]
   * @param  URLEncoded [Indicates wheather the returned String is to be URLEncoded or not]
   * @return            [Hash String]
   */
  public static String getHashString(Map<String, String> paramMap, Boolean URLEncoded) {
    String hashStr = '';
    for (String str : paramMap.Keyset()) {
      String name = str; 
      if(!String.isBlank(paramMap.get(str))){
      String value = (!URLEncoded) ? paramMap.get(str) : EncodingUtil.urlEncode(paramMap.get(str), 'UTF-8');
      
      hashStr += name + '=' + value;
      hashStr += '&';
      }
    }

    hashStr = hashStr.removeEnd('&');
    return hashStr;
  }


  /**
   * [getMiGSPaymentURL -Returns payment complete URL ]
   * @param  Amount    [Transaction amount information]
   * @param  orderName [Name of the order]
   * @param  retURL    [return URL]
   * @return           [payment URL string]
   */
  public static String getMiGSPaymentURL(String Amount, String orderName , String retURL) {

    Reciept__c receiptObj = getNewReceipt();
    Map<String, String> paramMap =  getHashMap(receiptObj.Id, Amount, orderName, retURL); //Generate hashMap
    String hashStr = getHashString(paramMap, false);   //Generate hashStr
    String Signature = generateSignature(hashStr, MiGSDonfigObj.Merchant_Secure_Secret__c);
    String paymentURL = generatePaymentURL(paramMap, Signature);
    System.debug('==>' + paymentURL);
    return paymentURL;
  }

  /**
   * [generateSignature -Generates signature using salt and key]
   * @param  salt []
   * @param  key  []
   * @return      []
   */
  public static String generateSignature(String salt, String key) {
    //HMAC SHA-256 Signature generator
    Blob targetBlob = Blob.valueOf(salt);
    Blob privateKeyBlob = EncodingUtil.convertFromHex(key);

    Blob hash = crypto.generateMac('HmacSHA256', targetBlob , privateKeyBlob);
    string Signature = EncodingUtil.convertToHex(hash).toUpperCase();
    return Signature;
  }
/////////
  public static String generateMD5Signature(String salt) {

    Blob targetBlob = Blob.valueOf(salt);
    Blob hash = Crypto.generateDigest('MD5', targetBlob);
    string result = EncodingUtil.convertToHex(hash);
    String Signature =  result.toUpperCase();
    return Signature;
  }
  public static Map<String, String> getAMAHashMap(Reciept__c receipt) {
    MiGSDonfigObj = getActiveMigsConfig();
    Map<String, String> paramMap = new Map<String, String>();

    paramMap.put('vpc_AccessCode', MiGSDonfigObj.Merchant_Access_Code__c);
    paramMap.put('vpc_Command', 'queryDR');
    paramMap.put('vpc_Merchant', MiGSDonfigObj.Merchant_Id__c);
    paramMap.put('vpc_MerchTxnRef', receipt.MerchTxnRef__c);
    paramMap.put('vpc_Password', MiGSDonfigObj.Password__c);
    paramMap.put('vpc_User', MiGSDonfigObj.Username__c);
    paramMap.put('vpc_Version', '1');
    return paramMap;
  }

	public static Map<String, String> getReceiptStatusResponse(String receiptId, Reciept__c receipt) {
    	map<String, String> responseMap = new map<String, String>();
    	try {
    		Reciept__c rec = new Reciept__c();
    		rec = receipt;
    		if(string.isNotBlank(receiptId)){
	      		string receiptQueryStr = GEMS_Utility.getAllFields(Reciept__c.getsObjectType().getDescribe());
	      		receiptQueryStr += ' WHERE Id =: receiptId ';
	      		for (Reciept__c obj : Database.query(receiptQueryStr)) {
	        		rec = obj;
	      		}
    		}
      		map<String, String> paramMap =  getAMAHashMap(rec);
      		string hashStr = getHashString(paramMap, true);
      		responseMap = getQueryDRResult(hashStr);
    	} catch (Exception e) {
      		GEMS_Utility.LogException(e);
    	}
    	return responseMap;
  	}

  public static Map<String, String> getQueryDRResult(String hashStr) {
    Map<String, String> responseMap = new map<String, String>();
    try {
      
      HttpRequest req = new HttpRequest();
      req.setEndpoint(MiGSDonfigObj.AMA_Transaction_URL__c);
      req.setMethod('POST');
      req.setbody(hashStr);
      Http http = new Http();
      HTTPResponse response = (Test.isRunningTest()) ? GEMS_Utility.GetDummyResponse('A=10&B=20',200) :  http.send(req); 
      if (response.getStatusCode() == 200) {
        for (String str : response.getBody().split('&') ) {
          responseMap.put(str.subStringBefore('='), str.subStringAfter('='));
        }
        
      }
    } catch (Exception e) {
      GEMS_Utility.LogException(e);

      System.debug('Exception ==> '+ e.getMessage());

    }
    return responseMap;
  }


//////
/**
 * [generatePaymentURL -generates paymentURL with signature value aand encryption algorithm name]
 * @param  Map<String,String>paramMap [hashMap]
 * @param  Signature                  [Signature information]
 * @return                            [paymentURL string]
 */
public static String generatePaymentURL(Map<String, String>paramMap, String Signature) {
  String URL = MiGSDonfigObj.Payment_URL__c;
  paramMap.put('vpc_SecureHash', Signature);
  paramMap.put('vpc_SecureHashType', 'SHA256');
  String encodedHashStr = getHashString(paramMap, true);
  URL += encodedHashStr;
  return URL;

}


/**
 * [getNewReceipt -Get new Receipt record]
 * @return [Receipt record]
 */
public static Reciept__c getNewReceipt() {
  Reciept__c receiptObj = new Reciept__c();
  receiptObj.SR_Ids__c = SRIds;
  receiptObj.School_Code__c = schoolCode;
  receiptObj.return_URL__c = retURLVal;
  insert receiptObj;
  receiptObj.MerchTxnRef__c = receiptObj.Id;
  update receiptObj;
  return receiptObj;

}

/**
 * [updateReceipt description]
 * @param  Map<String,String>responseMap [Map containing all the details returned from Payment Gateway]
 * @return                               [receipt record populated with response details]
 */
public static Reciept__c updateReceipt(Map<String, String>responseMap) {

  Id receiptId = responseMap.get('vpc_MerchTxnRef');
  String recieptQueryStr = GEMS_Utility.getAllFields(Reciept__c.getsObjectType().getDescribe());
  recieptQueryStr += ' WHERE Id=:receiptId LIMIT 1';
  list<Reciept__c> tempList = new list<Reciept__c>();
  tempList = Database.Query(recieptQueryStr);
  if(tempList!=null && tempList.size()>0){
  	Reciept__c receipt = new Reciept__c();
  	receipt = tempList[0];
	  if (receipt != NULL) {
	    receipt.AcqAVSRespCode__c = responseMap.get('vpc_AcqAVSRespCode');
	    receipt.AcqCSCRespCode__c = responseMap.get('vpc_AcqCSCRespCode');
	    receipt.AcqResponseCode__c = responseMap.get('vpc_AcqResponseCode');
	    receipt.Amount__c = responseMap.get('vpc_Amount').removeEnd('00');
	    receipt.AuthorizeId__c = responseMap.get('vpc_AuthorizeId');
	    receipt.AVSResult_Code__c = responseMap.get('vpc_AVSResultCode');
	    receipt.Batch_Number__c = responseMap.get('vpc_BatchNo');
	    receipt.Command__c = responseMap.get('vpc_Command');
	    receipt.Card__c = responseMap.get('vpc_Card');
	    receipt.CSCResultCode__c = responseMap.get('vpc_CSCResultCode');
	    receipt.Currency__c = responseMap.get('vpc_Currency');
	    receipt.Locale__c = responseMap.get('vpc_Locale');
	    receipt.Merchant__c = responseMap.get('vpc_Merchant');
	    receipt.MerchTxnRef__c = responseMap.get('vpc_MerchTxnRef');
	    receipt.Message__c = responseMap.get('vpc_Message');
	    receipt.Order_Info__c = responseMap.get('vpc_OrderInfo');
	    receipt.ReceiptNo__c = responseMap.get('vpc_ReceiptNo');
	    receipt.RiskOverallResult__c = responseMap.get('vpc_RiskOverallResult');
	    receipt.SecureHash__c = responseMap.get('vpc_SecureHash');
	    receipt.SecureHashType__c = responseMap.get('vpc_SecureHashType');
	    receipt.TransactionNo__c = responseMap.get('vpc_TransactionNo');
	    receipt.TxnResponseCode__c = responseMap.get('vpc_TxnResponseCode');
	    receipt.Version__c = responseMap.get('vpc_Version');
	    
	    if(receipt.Sys_Generate_Receipt__c == false)
	    	receipt.Sys_Generate_Receipt__c = (responseMap.containsKey('vpc_Message') &&  responseMap.get('vpc_Message').equals('Approved')) ? true :  false ;
	    //Asper Lebas request to populate additional field from response
	    //Values are null as of now
	    // 2-5-2017
	    receipt.VerType__c = responseMap.get('vpc_VerType');
	    receipt.VerStatus__c = responseMap.get('vpc_VerStatus');
	    receipt.Token__c = responseMap.get('vpc_Token');
	    receipt.VerSecurLevel__c = responseMap.get('vpc_VerSecurLevel');
	    receipt.Enrolled__c = responseMap.get('vpc_Enrolled');
	    receipt.Xid__c =  responseMap.get('vpc_Xid');
	    receipt.AcqECI__c = responseMap.get('vpc_AcqECI');
	    receipt.AuthStatus__c = responseMap.get('vpc_AuthStatus');
	
	    ////////QueryDR status
	    receipt.RiskOverallResult__c = responseMap.get('vpc_RiskOverallResult');
	    receipt.FoundMultipleDRs__c = responseMap.get('vpc_FoundMultipleDRs');
	    receipt.DRExists__c = responseMap.get('vpc_DRExists');
	
	    if(string.isNotBlank(receipt.Amount__c) && 
		   string.isNotBlank(receipt.Message__c) &&
		   receipt.Message__c=='Approved'){
			receipt.Transaction_Status__c = 'Completed';
	    }
	  }
	  update receipt;
	  return receipt;	
	  }
  return null;
}
}