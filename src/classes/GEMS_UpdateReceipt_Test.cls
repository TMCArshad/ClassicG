@isTest
private class GEMS_UpdateReceipt_Test {
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
	@isTest static void test_method_one() {
		// Implement test code
		List<School__c> schoolList = createSchools(10);
		List<Reciept__c> receiptList = createReciepts(10);
		
		Test.startTest();
             GEMS_UpdateReceipt.updateReceiptStatusFromMigs(receiptList[0].Id,schoolList[0].ID__c);
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}