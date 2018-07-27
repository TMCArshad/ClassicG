/**************************************************************************************************
* Name               : GEMS_ChangeTCCntlr                                                               *
* Description        : This class implements all the logic required for modification of TC Request  
*                      1) Change TC
*                      2) Cancel TC
*                      3) Cancel SO
*                      4) Reverse Cancel Admission                          *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017
**************************************************************************************************/
public without sharing class GEMS_ChangeTCCntlr {
    public string SRID {get; set;}
    public HexaBPM__Service_Request__c SR { get; set;}
    public String requestType {get; set;}
    public GEMS_ChangeTCCntlr(ApexPages.StandardController controller) {
        requestType = '';
        if (apexpages.currentpage().getParameters().get('Id') != null) {
            SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
            requestType = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('reqType'));
        }
 
        HexaBPM__Service_Request__c SOtoTC = new HexaBPM__Service_Request__c();
        String srQueryStr = '';
        srQueryStr += GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
        srQueryStr = srQueryStr.replace('FROM HexaBPM__Service_Request__c',', HexaBPM__External_SR_Status__r.HexaBPM__Type__c FROM HexaBPM__Service_Request__c' );
        srQueryStr += ' WHERE Id =: SRID '; 

        for (HexaBPM__Service_Request__c obj : Database.Query(srQueryStr)) {
            SR = obj;
        }
    }

    public pageReference updateSR() {
        String result = 'Success';
        savepoint sp =  Database.setSavepoint();//Define save point

        try {
        	if(string.isNotBlank(requestType) && requestType!=null){
        	
	            if (requestType.equals('Change_TC')) {
	                if (SR.Transferring_to_Change__c == SR.Transferring_to__c) {
	                    GEMS_Utility.addPageError('Invalid Transferring to selection.Please select a value other than -' + SR.Transferring_to__c);
	                    return Null;
	                }
	                SR.Transaction_Date__c = System.Today();
	                update SR;
	
	                PageReference ref = new PageReference('/' + SR.Id);
	                ref.setredirect(true);
	                return ref;
	            } else if (requestType.equals('Cancel_TC_Request')) {
	
	                //Update remarks
	                //update SR;
	                result = GEMS_UpdateSR.cancelRequest(SR.Id, 'CANCELLED');
	                
	                //Leeba Updating the Remarks and Reason after cancellation because of the validation 
	                HexaBPM__Service_Request__c objSRTBU = new HexaBPM__Service_Request__c(Id=SR.Id);
	                objSRTBU.TC_Cancel_Remarks__c = SR.TC_Cancel_Remarks__c;
	                objSRTBU.TC_Cancel_Reason__c = SR.TC_Cancel_Reason__c;
	                update objSRTBU;
	                
	                if (result == 'Success') {
	                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, string.valueOf('TC Cancelled successfully.')));
	                } else {
	                    GEMS_Utility.addPageError(result);
	                    Database.rollback(sp);
	                    return NULL;
	                }
	
	
	            } else if (requestType.equals('Cancel_Strike_Off')) {
	                //Update remarks
	                update SR;
	                result = GEMS_UpdateSR.cancelRequest(SR.Id, 'CANCELLED');
	
	                if (result == 'Success') {
	                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, string.valueOf('Strike Off Cancelled successfully.')));
	                } else {
	                    GEMS_Utility.addPageError(result);
	                    Database.rollback(sp);
	                }
	            } else if (requestType.equals('Reverse_Cancel_Admission')) {
	                update SR;
	                result = GEMS_UpdateSR.cancelRequest(SR.Id, 'REVERSE_CANCEL_ADMISSION_APPROVED');
	                if(result.equals('Success')){
	                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, string.valueOf('Admission reversed.')));
	                }else{
	                    GEMS_Utility.addPageError('Error:'+result);
	                }
	                
	            }
	            
	            if(requestType.equals('Cancel_Strike_Off') || requestType.equals('Cancel_TC_Request')){
	            	
	            	list<scholarship__c> scholarshipToUpdate = new list<scholarship__c>();
		    		for(scholarship__c obj : [select id,TC_SO_CN_Applied__c,active__c 
		    								  from scholarship__c where active__c = false 
		    								  and TC_SO_CN_Applied__c = true 
		    								  and student__c =: SR.student__c]){
	                	obj.TC_SO_CN_Applied__c = false;
	                	obj.active__c = true;
	                	scholarshipToUpdate.add(obj);
	                }
	                    
	                if (scholarshipToUpdate != null && scholarshipToUpdate.size() > 0) 
	                    update scholarshipToUpdate;
	            }
	            PageReference ref = new PageReference('/' + SR.Id);
		        ref.setredirect(true);
		        return ref;
        	}
        } catch (Exception e) {
        	system.debug('------'+e.getLineNumber()+'-----'+e.getmessage());
            String message = (e.getTypeName().equals('System.DmlException')) ? e.getDMLMessage(0)  : e.getMessage() ;
            GEMS_Utility.addPageError(message );
            Database.rollback(sp);
        }
        return NULL;
    }
    
    public pageReference cancelSR() {
        PageReference ref = new PageReference('/' + SR.Id);
        ref.setredirect(true);
        return ref;
    }
}