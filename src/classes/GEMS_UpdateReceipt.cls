global without sharing class GEMS_UpdateReceipt {
  Webservice static string updateReceiptStatusFromMigs(String receiptId, String schoolCode) {

    String retStr = '';
    Map<String, String> responseMap = new Map<String, String>();
    try {
      GEMS_MiGS_Utility.schoolCode = schoolCode;
      responseMap = GEMS_MiGS_Utility.getReceiptStatusResponse(receiptId,null);
      responseMap.put('vpc_MerchTxnRef',receiptId);
      System.debug('responseMap==>'+responseMap);
      Reciept__c receipt = GEMS_MiGS_Utility.updateReceipt(responseMap);
      retstr = 'Success';

    } catch (Exception e) {
      GEMS_Utility.LogException(e);
      retStr = e.getMessage();

    }
    return retStr;

  }


}