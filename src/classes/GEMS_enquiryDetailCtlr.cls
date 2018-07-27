public without sharing class GEMS_enquiryDetailCtlr {
	
	private ApexPages.StandardController controller {get; set;}
  	private HexaBPM__Service_Request__c SR ;
	private Enquiry__c objEnquiry;
	
	public List<Account> duplicateAccountList {get; set;}
	public List<Enquiry__c> duplicateEnquiryList {get; set;}
	public GEMS_enquiryDetailCtlr(ApexPages.StandardController controller) {
	    try{
		    duplicateAccountList = new List<Account>();
		    duplicateEnquiryList = new List<Enquiry__c>();
		
		    //initialize the stanrdard controller
		    this.controller = controller;
		    SObjectType sObjectType = controller.getRecord().getSObjectType();
		    if(sObjectType == HexaBPM__Service_Request__c.sObjectType){
		    	this.SR  = (HexaBPM__Service_Request__c)Controller.getRecord();
		  		  
		  	    	this.SR =  [Select Lead__c,Enquiry__c  from HexaBPM__Service_Request__c Where Id = :  SR.Id LIMIT 1];
		        	system.debug('SR==>'+SR.Enquiry__c);
		        	this.objEnquiry =   [Select FirstName__c, LastName__c, Date_of_Birth__c, Parent_Name__c, mobilePhone__c, SchoolLookup__r.Name,
					               	    		Email__c, Passport_Number__c, Gender__c, ConvertedAccountId__c, Id 
					            		 from Enquiry__c Where Id = : SR.Enquiry__c limit 1];          
			    	getDuplicateEnquiry('Service Request');
			    	getDuplicateAccounts();
		    }
		    else{
		     	System.debug('sObjectType==>'+sObjectType);
		    	this.objEnquiry = (Enquiry__c)Controller.getRecord();
		    	this.objEnquiry =   [Select FirstName__c, LastName__c, Date_of_Birth__c, Parent_Name__c, mobilePhone__c, Email__c, ConvertedAccountId__c,
					               	        Passport_Number__c, SchoolLookup__r.Name, Gender__c, Id 
					        		 from Enquiry__c Where Id = :this.objEnquiry.Id limit 1];
				   getDuplicateEnquiry('Enquiry');
				   getDuplicateAccounts();
		    }
	    }
	 	catch(Exception e){
	 		GEMS_Utility.addPageError('Error:'+e.getMessage()+'----'+e.getLineNumber());
	 	}
	}

	public void getDuplicateEnquiry(String sObjectName) {
    	List<Id> enquiryIdList = new list<Id>();
    	if(sObjectName.equals('Service Request')){
    		System.debug('objEnquiry.id==>'+objEnquiry.id);
    		
    		for (HexaBPM__Service_Request__c SR  : [ SELECT  Id, First_Name__c, Last_Name__c, First_Name_Father__c,
											                 Last_Name_Father__c, First_Name_Mother__c, Last_Name_Mother__c,
											         		 Date_Of_Birth__c, Gender__c, Mobile__c, Mobile_Mother__c,
											         		 Email_Father__c, Email_Mother__c, Passport_No__c, Lead__c,enquiry__c
											         from HexaBPM__Service_Request__c
											         WHERE enquiry__c != : objEnquiry.id LIMIT 50000]) {
      
		    	if (SR.Date_Of_Birth__c != NULl && SR.Gender__c != NULL && SR.Date_Of_Birth__c == objEnquiry.Date_Of_Birth__c   && SR.Gender__c == objEnquiry.Gender__c && SR.First_Name__c == objEnquiry.FirstName__c && SR.Last_Name__c == objEnquiry.LastName__c ) {
		       		System.debug('Condition 1');
		        	enquiryIdList.add(SR.enquiry__c);
		      	} else if (SR.Date_Of_Birth__c != NULl && SR.Gender__c != NULL && SR.Passport_No__c != NULL && SR.Date_of_Birth__c == objEnquiry.Date_of_Birth__c && SR.Gender__c == objEnquiry.Gender__c && SR.Passport_No__c == objEnquiry.Passport_Number__c ) {
		        	System.debug('Condition 2');
		        	enquiryIdList.add(SR.enquiry__c);
		      	} else if (SR.Date_Of_Birth__c != NULl && SR.Gender__c != NULL && SR.Date_of_Birth__c == objEnquiry.Date_of_Birth__c && SR.Gender__c == objEnquiry.Gender__c && ((SR.Mobile__c == objEnquiry.MobilePhone__c && SR.Mobile__c != NULL ) || (SR.Mobile_Mother__c != NULL && SR.Mobile_Mother__c == objEnquiry.MobilePhone__c ))) {
		        	System.debug('Condition 3');
		        	enquiryIdList.add(SR.enquiry__c);
		      	} else if (SR.Date_Of_Birth__c != NULl && SR.Gender__c != NULL && SR.Date_of_Birth__c == objEnquiry.Date_of_Birth__c && SR.Gender__c == objEnquiry.Gender__c && (SR.Email_Father__c == objEnquiry.Email__c || SR.Email_Mother__c == objEnquiry.Email__c)) {
		        	System.debug('Condition 4');
		        	enquiryIdList.add(SR.enquiry__c);
		      	}
			}
    		for (Enquiry__c enq : [Select FirstName__c, LastName__c, Date_of_Birth__c, Parent_Name__c, MobilePhone__c, Email__c, Gender__c,
                      				 	  Passport_Number__c, SchoolLookup__r.Name, Id, IsConverted__c 
	                      		  FROM Enquiry__c
	                      		  WHERE Id in :enquiryIdList
	                      		  AND IsConverted__c = false]) {

      			duplicateEnquiryList.add(enq);
    		}
    	}
    	
    	for (Enquiry__c enq : [Select FirstName__c, LastName__c, Date_of_Birth__c, Parent_Name__c, Passport_Number__c, MobilePhone__c, Gender__c,
                      			 schoolLookup__r.Name, Email__c, Id, IsConverted__c
	                      	  FROM Enquiry__c WHERE Id != :objEnquiry.id AND ID NOT IN :enquiryIdList AND IsConverted__c  = false
	                      	  AND (
		                      	(FirstName__c != NULL AND LastName__c != NULL AND Date_of_Birth__c != NULl AND Gender__c != NULL AND   FirstName__c = : objEnquiry.FirstName__c AND LastName__c = : objEnquiry.LastName__c AND Date_of_Birth__c = : objEnquiry.Date_of_Birth__c AND Gender__c = : objEnquiry.Gender__c)
		                        	OR (Passport_Number__c != NULL AND Date_of_Birth__c != NULL AND Gender__c != NULL AND  Passport_Number__c = : objEnquiry.Passport_Number__c AND Date_of_Birth__c = : objEnquiry.Date_of_Birth__c AND Gender__c = : objEnquiry.Gender__c  )
		                        	OR (Date_of_Birth__c != NULL AND Gender__c != NULL  AND MobilePhone__c != NULL AND Date_of_Birth__c  =: objEnquiry.Date_of_Birth__c AND Gender__c = : objEnquiry.Gender__c AND  MobilePhone__c = : objEnquiry.MobilePhone__c)
		                        	OR (Date_of_Birth__c != NULL AND Gender__c != NULL  AND Email__c != NULL AND Date_of_Birth__c = : objEnquiry.Date_of_Birth__c AND Gender__c = : objEnquiry.Gender__c AND  Email__c = : objEnquiry.Email__c)
		                    	)]) {

      		duplicateEnquiryList.add(enq);
    	}
  	}

	public void getDuplicateAccounts() {
    	for (Account acc : [Select ID, FirstName, LastName, Date_Of_Birth__c, Gender__c, Passport_No__c, PersonMobilePhone,
                                   PersonEmail, IsPersonAccount, School__r.Name
                            FROM Account WHERE IsPersonAccount = true AND Id != :objEnquiry.ConvertedAccountId__c
                            AND
                            (  (FirstName != NULL AND LastName != NULL AND Date_of_Birth__c != NULL AND Gender__c != NULL AND FirstName = : objEnquiry.FirstName__c AND LastName = : objEnquiry.LastName__c AND Date_of_Birth__c = : objEnquiry.Date_of_Birth__c AND Gender__c = :objEnquiry.Gender__c)
                               OR ( Date_of_Birth__c != NULL AND Gender__c != NULL AND Date_of_Birth__c != NULL AND Gender__c != NULL AND Date_of_Birth__c != NULL AND Passport_No__c != NULL AND  Gender__c = : objEnquiry.Gender__c AND Date_of_Birth__c = :objEnquiry.Date_of_Birth__c AND Passport_No__c = : objEnquiry.Passport_Number__c )
                               OR (Date_of_Birth__c != NULL AND Gender__c != NULL AND  Gender__c = : objEnquiry.Gender__c AND Date_of_Birth__c = :objEnquiry.Date_of_Birth__c AND PersonMobilePhone = : objEnquiry.MobilePhone__c )
                               OR (Date_of_Birth__c != NULL AND Gender__c != NULL AND  Gender__c = : objEnquiry.Gender__c AND Date_of_Birth__c = :objEnquiry.Date_of_Birth__c AND PersonEmail  = : objEnquiry.Email__c)
                            )]) {

      		duplicateAccountList.add(acc);
    	}
  	}
}