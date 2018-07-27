/*****************************************************************************************************************************
    Author      :   Keerthan Tantry
    Date        :   
    Description :   Payment Gateway.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    V1.0	Swati	9th April 2017	Changes to comment SR submit
    V1.1	Swati	15th Feb 2018	Changes to avoid special characters in order info
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_PaymentRedirectController {
	
	public map<string, string> responseCodeMap {get; set;}
  	public string paymentPageURL {get;set;}
  	
  	public GEMS_PaymentRedirectController() {
    	responseCodeMap = new map<string, string>();
    	responseCodeMap = GEMS_MiGS_Utility.getResponseCodes(); 
  	}

  	/**
    * [handleRedirect - handles redirection once returned from payment gateway]
    * @return [Page reference to the page where the transaction was initiated]
    */
	public PageReference handleRedirect() {
   		pageReference pg = null;
    	try{
	   		map<string, string> paramMap = new map<string, string>();
	   		map<string, string> paramMapSorted = new map<string, string>();
	    	
	    	if(apexPages.currentPage().getParameters() != NULL) {
	      		paramMap = ApexPages.currentPage().getParameters();
	      		string respCode = paramMap.get('vpc_TxnResponseCode');
	      		Reciept__c receiptObj = new Reciept__c();
	      		if (string.isNotBlank(respCode) && respCode.equals('0')) {
	         		receiptObj =  GEMS_MiGS_Utility.updateReceipt(paramMap);
	        		//Successfull payment
	        		//Redirect to retURL
	        		if(receiptObj!=null){
		        		updateSRPriceItemStatus(receiptObj);
		        		
		        		splitReceipt(receiptObj);
		        		pg = new PageReference(receiptObj.Return_URL__c);
		        		pg.setRedirect(true);
		        		return pg;
	        		}
	      		}
	      		else {
	        		receiptObj =  GEMS_MiGS_Utility.updateReceipt(paramMap);
	      			if(receiptObj!=null){
	      				paymentPageURL = getPaymentpageURL(receiptObj.SR_Ids__c);
	        			apexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, GEMS_MiGS_Utility.getResponseCodes().get(respCode)));	
	      			}
	      		}
  			}
    	}catch(Exception e){
    		GEMS_Utility.logException(e);
    		system.debug('------'+e.getmessage() +'-----'+e.getLineNumber());
    	}
    	return pg;
	}

	public string getPaymentpageURL(string SRIds){
  		string paymentpage = '';
  		list<Id> SRId_List = SRIds.split(',');
  		if(SRId_List!=null && SRId_List.size()>0){
	  		for(HexaBPM__Service_request__c SR : [Select GEMS_URL__c from HexaBPM__Service_request__c Where Id in:SRId_List]){
	  			paymentpage = SR.GEMS_URL__c;
	  		}
  		}
  		return paymentpage;
  	}

	/**
    * [updateSRPriceItemStatus -Mark status as Paid if transaction was successfull]
    * @param  SRIds [string containing all te IDs of SR]
    * @return       [Void]
    */
	public void  updateSRPriceItemStatus(Reciept__c receiptObj) {
    	list<Id> SRId_List = receiptObj.SR_Ids__c.split(',');
    	if(SRId_List!=null && SRId_List.size()>0){
		    
		    set<id> studentID = new set<id>(); 
		    set<String> srStatusCodes = new Set<String>();
            srStatusCodes.add('SUBMITTED');
            srStatusCodes.add('REGISTERED');
            srStatusCodes.add('CLOSED');
            
            Map<String,String> srStatusMap = new Map<String,String>();
            if(!srStatusCodes.isEmpty()){
                for( HexaBPM__SR_Status__c srStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c IN :srStatusCodes] ){
                    srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
                }
            }
            list<HexaBPM__Service_Request__c> srUpdateList = new List<HexaBPM__Service_Request__c>();
            
		    for ( HexaBPM__Service_request__c objSR: [Select id, school__c, HexaBPM__Customer__c, student__c,
															 Lead__c, HexaBPM__Record_Type_Name__c,
															 HexaBPM__External_Status_Name__c,Reciept_ID__c,
															 HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c
												      from HexaBPM__Service_request__c
													  WHERE ID in :SRId_List ] ) {
      			
      			objSR.Reciept_ID__c = receiptObj.id;
                objSR.Payment_Status__c = 'Paid';
                
      			if(objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' && 
      			   (objSR.HexaBPM__External_Status_Name__c == '' || 
      			    objSR.HexaBPM__External_Status_Name__c == 'Draft' ||
      			    objSR.HexaBPM__External_Status_Name__c == 'Submitted') &&
      			    string.isNotBlank(receiptObj.Order_Info__c) &&
      			   receiptObj.Order_Info__c !=null &&
      			   receiptObj.Order_Info__c.contains('Registration')){
      				
      				objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('SUBMITTED');
                    objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('SUBMITTED');

      			}else if(objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' &&
      					 string.isNotBlank(receiptObj.Order_Info__c) &&
      					 receiptObj.Order_Info__c !=null &&
      			         receiptObj.Order_Info__c.contains('Enrollment')){
      				objSR.accept_offer__c = 'Yes';
      			}else if(objSR.HexaBPM__Record_Type_Name__c == 'Re_Enrolment' &&
      					 string.isNotBlank(receiptObj.Order_Info__c) &&
      					 receiptObj.Order_Info__c !=null &&
      			         receiptObj.Order_Info__c.contains('Re-Enrolment')){
      				objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('CLOSED');
                    objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('CLOSED');
                    studentID.add(objSR.student__c);
                    studentID.add(objSR.HexaBPM__Customer__c);
      			}
      			srUpdateList.add(objSR);
		  	}
		  	
		  	if(srUpdateList!=null && srUpdateList.size()>0){
		  		update srUpdateList;
		  		for(HexaBPM__Service_request__c objSR : srUpdateList){
		  			if(objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' && 
	      			   (objSR.HexaBPM__External_Status_Name__c == 'Draft' ||
	      			    objSR.HexaBPM__External_Status_Name__c == 'Submitted') &&
	      			   receiptObj.id==objSR.Reciept_ID__c){
				   
						objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('REGISTERED');
	                    objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('REGISTERED');
				   }
		  		}
		  		update srUpdateList;
		  		
		  		string pricingLine = '';
		  		if(string.isNotBlank(receiptObj.Order_Info__c) &&
  					receiptObj.Order_Info__c !=null){
  					if(receiptObj.Order_Info__c.contains('Registration')){
			  			pricingLine = 'Registration Fee';
			  		}else if(receiptObj.Order_Info__c.contains('Enrollment')){
			  			pricingLine = 'Enrollment Fee';
			  		}	
			  		else if(receiptObj.Order_Info__c.contains('Re-Enrolment')){
			  			pricingLine = 'Re-Enrolment';
			  		}	
  				} 
  					
		  		if(string.isNotBlank(pricingLine)){
			  		list<HexaBPM__SR_Price_Item__c> tempList = [select id, Status__c ,HexaBPM__SRPriceLine_Text__c,HexaBPM__Non_Reevaluate__c
		    													from HexaBPM__SR_Price_Item__c 
		    													where HexaBPM__ServiceRequest__c IN : srUpdateList
		    													and Status__c='Added'
		    													and HexaBPM__SRPriceLine_Text__c=:pricingLine];
				    if (tempList != null && tempList.size() > 0) {
				      for (HexaBPM__SR_Price_Item__c obj : tempList) {
				      		obj.Status__c = 'Paid';
				      		obj.HexaBPM__Non_Reevaluate__c = true;
				      		obj.Reciept_ID__c = receiptObj.id;
				      }
				      update tempList;
				    }
		  		}
		  		
		  		if(studentID!=null && studentID.size()>0){
		        	list<promotion__c> promoList = [select id, Re_enrolment_Remark__c,Re_Enroled__c 
	            									from promotion__c where student__c IN : studentID and active__c = true];
		        	if(promoList!=null && promoList.size()>0){
		        		for(promotion__c obj :promoList ){
	        				obj.Re_enrolment_Remark__c = 'Re-Enroled';
	        				obj.Re_Enroled__c = 'Yes';
		        		}	
		        		update promoList;
		        	}
		  		}
		  	}
    	}
  	}

  	  /**
    * [splitReceipt -Split bills for multi SR transactions]
    * @param receipt [main receipt]
    */
  	public void splitReceipt(Reciept__c receipt) {
    	map<Id, HexaBPM__SR_Price_Item__c> SRtoSRPriceItemMp = new map<Id, HexaBPM__SR_Price_Item__c>();
	    list<Reciept__c> receiptUpsertlist = new list<Reciept__c>();
	    list<Id> SRId_List = receipt.SR_Ids__c.split(',');
    	
    	integer i = 0;
		if(SRId_List!=null && SRId_List.size()>0){
    		
    		for (HexaBPM__SR_Price_Item__c pl :  [ SELECT HexaBPM__Price__c, Product__c,HexaBPM__SRPriceLine_Text__c,
														  HexaBPM__ServiceRequest__c, Id ,Reciept_ID__c
												   FROM   HexaBPM__SR_Price_Item__c
		                                           WHERE  HexaBPM__ServiceRequest__c IN :SRId_List
		                                           and Reciept_ID__c=:receipt.id]) {
		    	SRtoSRPriceItemMp.put(pl.HexaBPM__ServiceRequest__c, pl);
		    }
    		
    		for ( HexaBPM__Service_request__c srObj: [Select id, school__c, HexaBPM__Customer__c, student__c,
															 Lead__c, HexaBPM__Record_Type_Name__c,
															 HexaBPM__External_Status_Name__c
												      from HexaBPM__Service_request__c
													  WHERE ID in :SRId_List 
													  and Reciept_ID__c=:receipt.id] ) {
      			
      			if (i == 0) {
	        		//Transaction for a single SR
			        receipt.Lead__c = srObj.Lead__c;
			        if(SRtoSRPriceItemMp!=null && SRtoSRPriceItemMp.size()>0){
		        		receipt.Product__c = SRtoSRPriceItemMp.get(srObj.Id).Product__c;	
		        		receipt.Breakup_Amount__c = string.valueOf(SRtoSRPriceItemMp.get(srObj.Id).HexaBPM__Price__c);
			        }
			        receipt.Service_Request__c = srObj.Id;
      			    receipt.Account_Student__c = (srObj.HexaBPM__Record_Type_Name__c == 'Re_Enrolment') ? (String.isBlank(srObj.Student__c) ? srObj.HexaBPM__Customer__c : srObj.Student__c ): receipt.Account_Student__c;
				} else {
        			//Transaction for multiple Srs
			        Reciept__c receiptClone = receipt.clone(false, false, false, false);
			        receiptClone.Lead__c = srObj.Lead__c;
			        if(SRtoSRPriceItemMp!=null && SRtoSRPriceItemMp.size()>0){
		        		receipt.Product__c = SRtoSRPriceItemMp.get(srObj.Id).Product__c;
		        		receipt.Breakup_Amount__c = string.valueOf(SRtoSRPriceItemMp.get(srObj.Id).HexaBPM__Price__c);
			        }
			        receiptClone.Service_Request__c  = srObj.Id;
					receiptUpsertlist.add(receiptClone);
      			}
      			i++;
    		}
		}
   		receiptUpsertlist.add(receipt);
   		if(receiptUpsertlist!=null && receiptUpsertlist.size()>0){
   			upsert receiptUpsertlist;
   		}
	}
}