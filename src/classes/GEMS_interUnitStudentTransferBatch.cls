global without sharing class GEMS_interUnitStudentTransferBatch implements Database.Batchable<sObject>,database.stateful {
   
    
    list<HexaBPM__Service_Request__c> SRToProcess = new list<HexaBPM__Service_Request__c>();
    list<Id> lstSRIds = new list<Id>();
    string statusToUpdateForEnquiry = '';
    string SRType = '';
    
    global GEMS_interUnitStudentTransferBatch(list<HexaBPM__Service_Request__c> lstSRs, string statusToUpdate, string Type){
    	SRToProcess = lstSRs;
    	statusToUpdateForEnquiry = statusToUpdate;
    	SRType = Type;
    	system.debug('---statusToUpdateForEnquiry----'+statusToUpdateForEnquiry);
    	system.debug('---SRType----'+SRType);
    	
    }
    
	global list<HexaBPM__Service_Request__c> start(Database.BatchableContext BC ){
        return SRToProcess;
    }
    
    global void execute(Database.BatchableContext BC, list<HexaBPM__Service_Request__c> srList){
    		insert srList;
			Set<String> srStatusCodes = new Set<String>();
			srStatusCodes.add('SUBMITTED');
			srStatusCodes.add('APPLICATION TRANSFERRED');
			srStatusCodes.add('CLOSED');
			
			system.debug('---statusToUpdateForEnquiry----'+statusToUpdateForEnquiry);
    		system.debug('---SRType----'+SRType);
    	
			Map<String,String> srStatusMap = new Map<String,String>();
			if(!srStatusCodes.isEmpty()){
	        	for( HexaBPM__SR_Status__c srStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c IN :srStatusCodes] ){
		        	srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
		        }
	        }
			for(HexaBPM__Service_Request__c objSR : srList){
				objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('SUBMITTED');
                objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('SUBMITTED');
                objSR.HexaBPM__Submitted_Date__c = system.today();
                objSR.HexaBPM__Submitted_DateTime__c = system.now();	
                objSR.HexaBPM__finalizeamendmentflg__c = true;
                objSR.Batch_Cleared__c = true;
  				objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;		
			}
			update srList;
			if(SRType == 'Enrollment'){
				map<id, HexaBPM__Service_Request__c> newOldSR= new map<id, HexaBPM__Service_Request__c>();
				if(!srList.isEmpty()){
			    	for(HexaBPM__Service_Request__c obj : srList){
						if(obj.isClone())
							newOldSR.put(obj.getCloneSourceId(),obj);
					}
				}
				
				list<HexaBPM__Service_Request__c> updateExistingSR = new list<HexaBPM__Service_Request__c>();
				if(newOldSR!=null && newOldSR.size()>0){
					updateExistingSR = [select id, HexaBPM__Internal_SR_Status__c, 
											   HexaBPM__External_SR_Status__c 
									  	from HexaBPM__Service_Request__c where id IN : newOldSR.keyset()];	
				}	
				
				list<HexaBPM__Step__c> stepList = new list<HexaBPM__Step__c>();
				if(updateExistingSR!=null && updateExistingSR.size()>0){
					for(HexaBPM__Service_Request__c obj : updateExistingSR){
						obj.Transferred_School__c = newOldSR.get(obj.id).school__c;
						obj.HexaBPM__Linked_SR__c = newOldSR.get(obj.id).id;
						if(string.isNotBlank(statusToUpdateForEnquiry) && statusToUpdateForEnquiry.contains('Application Transferred')){
							obj.HexaBPM__Internal_SR_Status__c = srStatusMap.get('APPLICATION TRANSFERRED');
							obj.HexaBPM__External_SR_Status__c = srStatusMap.get('APPLICATION TRANSFERRED');
						}
					}
					update updateExistingSR;
					if(string.isNotBlank(statusToUpdateForEnquiry) && statusToUpdateForEnquiry.contains('Application Transferred')){
						stepList = [select id, HexaBPM__Status__c 
									from HexaBPM__Step__c where HexaBPM__SR__c IN : updateExistingSR];
					    if(stepList!=null && stepList.size()>0){
					    	Map<String,String> stepStatusMap = new Map<String,String>();
				        	for( HexaBPM__Status__c stepStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__Status__c WHERE HexaBPM__Code__c =:'TRANSFERRED'] ){
					        	stepStatusMap.put(stepStatus.HexaBPM__Code__c,stepStatus.Id);
					        }	
					        for(HexaBPM__Step__c step : stepList){
					        	step.HexaBPM__Status__c = stepStatusMap.get('TRANSFERRED');
					        }	
					        update stepList;
					    }
					}
				}
				
	    		map<string,Attachment> mapOfDocAndAttachment = new map<string,Attachment>();
	    		map<string,HexaBPM__SR_Doc__c> mapOfDocIDandName = new map<string,HexaBPM__SR_Doc__c>();
	    		set<string> docName = new set<string>();
	    		if(newOldSR!=null && newOldSR.size()>0){
	    			for(HexaBPM__SR_Doc__c obj : [select id, HexaBPM__Document_Name__c,HexaBPM__Doc_ID__c 
												  from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN : newOldSR.keyset()
												  and HexaBPM__Status__c='Uploaded' and HexaBPM__Doc_ID__c!='']){
				  		mapOfDocIDandName.put(obj.id,obj);
	    			}	
	    		}
	    		system.debug('---mapOfDocIDandName----'+mapOfDocIDandName);
	    		if(mapOfDocIDandName!=null && mapOfDocIDandName.size()>0){
	    			for(attachment att : [select id, name, body,parentId, ContentType from attachment where parentId IN : mapOfDocIDandName.keyset()]){
			  			if(mapOfDocIDandName.get(att.parentId).HexaBPM__Doc_ID__c == att.id){
			  				mapOfDocAndAttachment.put(mapOfDocIDandName.get(att.parentId).HexaBPM__Document_Name__c,att);	
			  			}
			  		}
	    		}
	    		
	    		system.debug('---mapOfDocAndAttachment----'+mapOfDocAndAttachment);
	    		list<attachment> attachmentToInsert = new list<attachment>();
	    		list<HexaBPM__SR_Doc__c> srDocToUpdate = new list<HexaBPM__SR_Doc__c>();
	    		
	    		if(mapOfDocAndAttachment!=null && mapOfDocAndAttachment.size()>0){
		    		map<id,list<HexaBPM__SR_Doc__c>> mapOfSRDocAndSR = new map<id,list<HexaBPM__SR_Doc__c>>();
	    			list<HexaBPM__Service_Request__c> tempSRList = [select id, (select id,HexaBPM__Status__c,HexaBPM__Document_Name__c from HexaBPM__SR_Docs__r) from HexaBPM__Service_Request__c where id IN : srList];
	    			
	    			for(HexaBPM__Service_Request__c obj : tempSRList){
	    				system.debug('---obj----'+obj);
	    				for(HexaBPM__SR_Doc__c objDoc : obj.HexaBPM__SR_Docs__r){
				  			system.debug('---objDoc----'+objDoc);
				  			if(objDoc.HexaBPM__Status__c=='Pending Upload' && mapOfDocAndAttachment.containsKey(objDoc.HexaBPM__Document_Name__c)){
					  			system.debug('---objDoc----'+objDoc);
		    					attachment attach = new attachment();
		    					attach.name = mapOfDocAndAttachment.get(objDoc.HexaBPM__Document_Name__c).name;
		    					attach.body = mapOfDocAndAttachment.get(objDoc.HexaBPM__Document_Name__c).body;
		    					attach.parentId = objDoc.id;
		    					
		    					objDoc.HexaBPM__Status__c = 'Uploaded';
				  				objDoc.HexaBPM__Doc_Type__c = mapOfDocAndAttachment.get(objDoc.HexaBPM__Document_Name__c).ContentType;
		    					attachmentToInsert.add(attach);
		    					srDocToUpdate.add(objDoc);
				  			}
				  			
	    				}	
	    			}
	    		}
	    		system.debug('---attachmentToInsert----'+attachmentToInsert);
				if(attachmentToInsert!=null && attachmentToInsert.size()>0){
					insert attachmentToInsert;
				}
				
				system.debug('---srDocToUpdate----'+srDocToUpdate);
				if(srDocToUpdate!=null && srDocToUpdate.size()>0){
					update srDocToUpdate;
				}
			}
			
			
			if(SRType == 'Re_Enrolment'){
				for(HexaBPM__Service_Request__c objSR : srList){
	    			if(objSR.payment_status__c == 'No Payment'){
		    			objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('CLOSED');
		                objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('CLOSED');
		                objSR.HexaBPM__Submitted_Date__c = system.today();
		                objSR.HexaBPM__Submitted_DateTime__c = system.now();    
		                objSR.HexaBPM__finalizeamendmentflg__c = true;
		                objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
	    			}
	    		}
	    		update srList;		
			}
    }
    
    global void finish(Database.BatchableContext BC){
    	
    }
}