/**************************************************************************************************
* Name               : GEMS_LeadDuplicateCntlr                                                               *
* Description        : Implements logic to display duplicate Leads/Accounts on Lead page layout                                        *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017 
**************************************************************************************************/
public without sharing class GEMS_LeadDuplicateCntlr {

    public  ApexPages.StandardController controller { get; set; }
    public  HexaBPM__Service_Request__c SR ;
    public  Lead leadObj;
    
    public List<Account> duplicateAccountList { get; set; }
    public List<Lead> duplicateLeadList { get; set; }
    
    public GEMS_LeadDuplicateCntlr(ApexPages.StandardController controller) {
        duplicateAccountList = new List<Account>();
        duplicateLeadList = new List<Lead>();

        //initialize the stanrdard controller
        this.controller = controller;
        SObjectType sObjectType = controller.getRecord().getSObjectType();
        //Determine sObject Type
        if (sObjectType == HexaBPM__Service_Request__c.sObjectType) {
            this.SR = (HexaBPM__Service_Request__c) Controller.getRecord();
            try {
                this.SR = [Select Lead__c from HexaBPM__Service_Request__c Where Id = :SR.Id LIMIT 1];
                this.leadObj = [Select id, FirstName, LastName, gender__c, Date_Of_Birth__c, SchoolLookup__c, Status, Passport_Number__c,mobilePhone, Email, ConvertedAccountId
                                from Lead Where Id =: SR.Lead__c limit 1];
                getDuplicateLeads('Service Request');
                getDuplicateAccounts();
            } catch (Exception e) {
                GEMS_Utility.addPageError('Error:' + e.getMessage());
            }

        } else {
            //The sObject Type is Lead
            try {
                this.leadObj = (Lead) Controller.getRecord();
                this.leadObj = [select id, FirstName, gender__c, Date_Of_Birth__c, SchoolLookup__c, Status, Passport_Number__c,LastName, mobilePhone, Email, ConvertedAccountId
                                from Lead where Id =: this.leadObj.Id limit 1];
                getDuplicateLeads('Lead');
                getDuplicateAccounts();
            } catch (Exception e) {
                GEMS_Utility.addPageError('Error:' + e.getMessage());
            }
        }
    }
    
    /**
     * [getDuplicateLeads - Get all duplicat Leads]
     * @param sObjectName [Name of sObject - Lead/Service Request]
     */
    public void getDuplicateLeads(String sObjectName) {
        List<Id> leadIdList = new list<Id>();
        if (sObjectName.equals('Service Request')) {
            //Capture all the Ids of duplicate leads associated with SR
            for (HexaBPM__Service_Request__c SR : [SELECT Id, First_Name__c, Last_Name__c,
                        								  Mobile__c, Mobile_Mother__c,
                        								  Email_Father__c, Email_Mother__c,
                        								  HexaBPM__Email__c, Lead__c,Gender__c
							                       from HexaBPM__Service_Request__c
							                       WHERE Lead__c != :leadObj.id LIMIT 50000]) {
                if ((SR.HexaBPM__Email__c == leadObj.Email || SR.Email_Father__c == leadObj.email || SR.Email_Mother__c == leadObj.Email || SR.Email_Guardian__c == leadObj.Email)&&
                   (SR.Mobile__c == leadObj.MobilePhone || SR.Mobile_Mother__c == leadObj.MobilePhone || SR.Mobile_Guardian__c == leadObj.MobilePhone) &&
                    SR.First_Name__c == leadObj.FirstName && SR.Last_Name__c == leadObj.LastName) {
                
                	leadIdList.add(SR.Lead__c);
                }
            }
            //Duplicate leads created with SR
            for (lead lead : [select id, firstName, gender__c, Date_Of_Birth__c, SchoolLookup__c,  Status,Passport_Number__c,LastName, MobilePhone, Email, IsConverted
                        	  from Lead where Id in : leadIdList AND IsConverted = false]) {

            	duplicateLeadList.add(lead);
            }
        }
        
        //Duplicate Leads created without SR
        for (lead lead : [select id, FirstName, gender__c, Date_Of_Birth__c, SchoolLookup__c,  Status,Passport_Number__c,LastName, MobilePhone, Email, IsConverted
                    	  FROM Lead WHERE Id !=: leadObj.id AND ID NOT IN : leadIdList
                    	  AND IsConverted = false
                          AND FirstName =: leadObj.FirstName AND LastName =: leadObj.LastName
                          AND email =: leadobj.email AND MobilePhone =: leadobj.MobilePhone]) {

            duplicateLeadList.add(lead);
        }
    }
    
    /**
     * [getDuplicateAccounts -Get Duplicate Accounts ]
     */
    public void getDuplicateAccounts() {
        for (Account acc : [Select ID, FirstName, LastName, Emergency_Contact_Number__c, Primary_Contact_Email__c, 
                            Gender__c, PersonEmail, Date_Of_Birth__c, School__c, Passport_No__c, PersonMobilePhone,
                                   IsPersonAccount FROM Account
                    		WHERE IsPersonAccount = true
                    		AND Id != :leadObj.ConvertedAccountId
                            AND FirstName =: leadObj.FirstName AND LastName =: leadObj.LastName
                          	AND Primary_Contact_Email__c =: leadobj.email AND Emergency_Contact_Number__c =: leadobj.MobilePhone]) {

            duplicateAccountList.add(acc);

        }
    }


}