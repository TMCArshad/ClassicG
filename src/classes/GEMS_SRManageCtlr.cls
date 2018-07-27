/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   6th Mar 2018
    Description :   sr reopen and cancellation controller
   
    --------------------------------------------------------------------------------------------------------------------------
	V1.0 Swati	reOpenSR
*****************************************************************************************************************************/

global without sharing class GEMS_SRManageCtlr {
    
    public string SRID{get;set;}
    public static HexaBPM__Service_Request__c SR {get; set;}
    public HexaBPM__Service_Request__c objSR {get; set;}
    
    
    public GEMS_SRManageCtlr(ApexPages.StandardController controller){
        try {
	        SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
	    	if(string.isNotBlank(SRID)){
	    		objSR = new HexaBPM__Service_Request__c();
	    		objSR = getSRDetails(SRID);	
	    	}
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'---'+e.getLineNumber())); 
        } 
    }
    
    Webservice static string checkValidations(string srId){
    	string msg = 'Success';
    	try {
	    	if(string.isNotBlank(SRID)){
	    		SR = new HexaBPM__Service_Request__c();
	    		SR = getSRDetails(SRID);	
	    		
	    		if(SR.HexaBPM__External_Status_Name__c == 'Cancelled'){
	    			msg = 'SR is already cancelled.';	
	    		}
	    		
	    		if(SR.HexaBPM__Is_Rejected__c == true){
	    			msg = 'SR is already rejected. It cannot be cancelled';	
	    		}
	    		
	    		if(SR.HexaBPM__External_Status_Name__c == 'Enrolled'){
	    			msg = 'Student has been already enrolled.';	
	    		}
	    	}
    	}catch (Exception e) {
            system.debug('----msg----'+msg);
            msg = e.getMessage()+'---'+e.getLineNumber();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'---'+e.getLineNumber())); 
        }
    	return msg;
    }
    
    public static HexaBPM__Service_Request__c getSRDetails(string SRID){
    	try {
	    	list<HexaBPM__Service_Request__c> tempSRList = new list<HexaBPM__Service_Request__c>(); 
	        String query = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
	        query += ' WHERE ID =:SRID'  ;
	        tempSRList = Database.query(query);
	        if(tempSRList!=null && tempSRList.size()>0){
	            return tempSRList[0];  
	        }
        }catch (Exception e) {
        }	
        return null;
    }
    
    public pageReference cancelSR(){
    	try{
	    	pageReference pg = null;
	    	if(objSR.Reason_for_cancellation__c!=null){
	    		if(objSR.Reason_for_cancellation__c == 'Other' &&
	    			string.isBlank(objSR.Enrolment_Cancellation_Remark__c)){
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'If chosen others please give detail'));		
	    		}else{
	    			
	    			set<String> srStatusCodes = new Set<String>();
		            srStatusCodes.add('CANCELLED');
		            
		            Map<String,String> srStatusMap = new Map<String,String>();
		            if(!srStatusCodes.isEmpty()){
		                for( HexaBPM__SR_Status__c srStatus : [select Id, HexaBPM__Code__c 
		                						  			   from HexaBPM__SR_Status__c 
		                						  			   where HexaBPM__Code__c IN :srStatusCodes] ){
		                    srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
		                }
		            }
		            
		            Map<String,String> stepStatusMap = new Map<String,String>();
		            if(!srStatusCodes.isEmpty()){
		                for( HexaBPM__Status__c stepStatus : [select Id, HexaBPM__Code__c 
		                									  from HexaBPM__Status__c 
		                									  where HexaBPM__Code__c IN :srStatusCodes] ){
		                    stepStatusMap.put(stepStatus.HexaBPM__Code__c,stepStatus.Id);
		                }
		            }
		            
		            objSR.Cancelled_SR_Status__c = objSR.HexaBPM__External_SR_Status__c;
		            objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('CANCELLED');
		            objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('CANCELLED');
		            
		            update objSR;
		            
		            list<HexaBPM__Step__c> stepsToOpen = new list<HexaBPM__Step__c>();
		            stepsToOpen = [select id, Cancelled_Step_Status__c,HexaBPM__Status__c 
		            				 from HexaBPM__Step__c 
		            				 where HexaBPM__SR__c =: objSR.id
		            				 and Is_Closed__c = false];
					if(stepsToOpen!=null && stepsToOpen.size()>0){
						for(HexaBPM__Step__c objStep : stepsToOpen){
							objStep.Cancelled_Step_Status__c = objStep.HexaBPM__Status__c;
							objStep.HexaBPM__Status__c = stepStatusMap.get('CANCELLED');
						}	
						update stepsToOpen;
					}	            
		            
		            list<HexaBPM__SR_Price_Item__c> priceToAdd = new list<HexaBPM__SR_Price_Item__c>();
	            	priceToAdd = [select id, Status__c 
		            				 from HexaBPM__SR_Price_Item__c 
		            				 where HexaBPM__ServiceRequest__c =: objSR.id
		            				 and Status__c = 'Added'];
					if(priceToAdd!=null && priceToAdd.size()>0){
						for(HexaBPM__SR_Price_Item__c objPrice : priceToAdd){
							objPrice.status__c = 'Cancelled';
						}	
						update priceToAdd;
					}	
	            	
	    			pg = new PageReference('/'+objSR.id);
	    		}	
	    	}else{
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please provide reason for cancellation'));	
	    	}
	    	return pg;
    	}catch (Exception e) {
        }
        return null;
    }
    
    //V1.0
    Webservice static string reOpenSR(string srId){
    	string msg = 'Success';
    	try {
    		if(string.isNotBlank(SRID)){
	    		SR = new HexaBPM__Service_Request__c();
	    		SR = getSRDetails(SRID);	
	    		
	    		if(SR.Is_SR_Closed__c == false){
	    			msg = 'SR is already opened.';	
	    		}
	    		
	    		/*if(SR.HexaBPM__Is_Rejected__c == true){
	    			msg = 'SR is rejected. Please contact support to reopen.';	
	    		}*/
	    		
	    		if(msg=='Success'){
		    		SR.HexaBPM__External_SR_Status__c = SR.Cancelled_SR_Status__c;
			        SR.HexaBPM__Internal_SR_Status__c = SR.Cancelled_SR_Status__c;
			        SR.Reason_for_cancellation__c = '';
			        SR.Enrolment_Cancellation_Remark__c = '';
			        SR.HexaBPM__Rejection_Reason__c = '';
			        update SR;
			        
			        list<HexaBPM__Step__c> stepsToOpen = new list<HexaBPM__Step__c>();
			        stepsToOpen = [select id, Cancelled_Step_Status__c,HexaBPM__Status__c,HexaBPM__Step_Status__c
			        				 from HexaBPM__Step__c 
			        				 where HexaBPM__SR__c =: SR.id];
					if(stepsToOpen!=null && stepsToOpen.size()>0){
						for(HexaBPM__Step__c objStep : stepsToOpen){
							if(objStep.HexaBPM__Step_Status__c == 'Cancelled' ||
							   objStep.HexaBPM__Step_Status__c.contains('Rejected')){
								
								objStep.HexaBPM__Status__c = objStep.Cancelled_Step_Status__c;
							}
						}	
						update stepsToOpen;
					}	            
		        
			        list<HexaBPM__SR_Price_Item__c> priceToAdd = new list<HexaBPM__SR_Price_Item__c>();
			    	priceToAdd = [select id, Status__c 
			        				 from HexaBPM__SR_Price_Item__c 
			        				 where HexaBPM__ServiceRequest__c =: SR.id
			        				 and Status__c = 'Cancelled'];
					if(priceToAdd!=null && priceToAdd.size()>0){
						for(HexaBPM__SR_Price_Item__c objPrice : priceToAdd){
							objPrice.status__c = 'Added';
						}	
						update priceToAdd;
					}	
					msg = 'SR reopened successfully.';
	    		}
	    	}
		}catch (Exception e) {
            msg = e.getMessage()+'---'+e.getLineNumber();
        }
    	return msg;
    }
    
    public pageReference closePopup(){
    	pageReference pg = null;
    	pg = new PageReference('/'+objSR.id);
    	return pg;
    }
}