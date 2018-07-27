/**************************************************************************************************
* Name               : GEMS_EnquiryDuplicateCntlr                                                               *
* Description        : Implements logic to display duplicate Enquirys/Accounts on Enquiry page layout                                        *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017 
* 1.1         Kim Noceda  13/02/2018 -  Added these fields in the query on getDuplicateAccounts method: 
                                        Gender__c, PersonEmail, Date_Of_Birth__c, School__c, Passport_No__c, PersonMobilePhone
                                        
**************************************************************************************************/
public without sharing class GEMS_EnquiryDuplicateCntlr { 

    public  ApexPages.StandardController controller { get; set; }
    public  HexaBPM__Service_Request__c SR ;
    public  Enquiry__c EnquiryObj;
    
    public List<Account> duplicateAccountList { get; set; }
    public List<Enquiry__c> duplicateEnquiryList { get; set; }
    
    public GEMS_EnquiryDuplicateCntlr(ApexPages.StandardController controller) {
        duplicateAccountList = new List<Account>();
        duplicateEnquiryList = new List<Enquiry__c>();

        //initialize the stanrdard controller
        this.controller = controller;
        SObjectType sObjectType = controller.getRecord().getSObjectType();
        //Determine sObject Type
        if (sObjectType == HexaBPM__Service_Request__c.sObjectType) {
            this.SR = (HexaBPM__Service_Request__c) Controller.getRecord();
            try {
                this.SR = [Select Enquiry__c from HexaBPM__Service_Request__c Where Id = :SR.Id LIMIT 1];
                this.EnquiryObj = [Select id, FirstName__c, gender__c, Date_Of_Birth__c, SchoolLookup__c, Status__c, Passport_Number__c,LastName__c, mobilePhone__c, Email__c, ConvertedAccountId__c
                                from Enquiry__c Where Id =: SR.Enquiry__c limit 1];
                getDuplicateEnquirys('Service Request');
                getDuplicateAccounts();
            } catch (Exception e) {
                GEMS_Utility.addPageError('Error:' + e.getMessage());
            }

        } else {
            //The sObject Type is Enquiry
            try {
                this.EnquiryObj = (Enquiry__c) Controller.getRecord();
                this.EnquiryObj = [select id, FirstName__c, LastName__c,gender__c, Date_Of_Birth__c, SchoolLookup__c, Status__c, Passport_Number__c, mobilePhone__c, Email__c, ConvertedAccountId__c
                                from Enquiry__c where Id =: this.EnquiryObj.Id limit 1];
                getDuplicateEnquirys('Enquiry');
                getDuplicateAccounts();
            } catch (Exception e) {
                GEMS_Utility.addPageError('Error:' + e.getMessage());
            }
        }
    }
    
    /**
     * [getDuplicateEnquirys - Get all duplicat Enquirys]
     * @param sObjectName [Name of sObject - Enquiry/Service Request]
     */
    public void getDuplicateEnquirys(String sObjectName) {
        List<Id> EnquiryIdList = new list<Id>();
        if (sObjectName.equals('Service Request')) {
            //Capture all the Ids of duplicate Enquirys associated with SR
            for (HexaBPM__Service_Request__c SR : [SELECT Id, First_Name__c, Last_Name__c,
                                                          Mobile__c, Mobile_Mother__c,
                                                          Email_Father__c, Email_Mother__c,
                                                          HexaBPM__Email__c, Enquiry__c,gender__c
                                                   from HexaBPM__Service_Request__c
                                                   WHERE Enquiry__c != :EnquiryObj.id LIMIT 50000]) {
                if ((SR.HexaBPM__Email__c == EnquiryObj.Email__c || SR.Email_Father__c == EnquiryObj.email__c || SR.Email_Mother__c == EnquiryObj.Email__c || SR.Email_Guardian__c == EnquiryObj.Email__c)&&
                   (SR.Mobile__c == EnquiryObj.MobilePhone__c || SR.Mobile_Mother__c == EnquiryObj.MobilePhone__c || SR.Mobile_Guardian__c == EnquiryObj.MobilePhone__c) &&
                    SR.First_Name__c == EnquiryObj.FirstName__c && SR.Last_Name__c == EnquiryObj.LastName__c) {
                
                    EnquiryIdList.add(SR.Enquiry__c);
                }
            }
            //Duplicate Enquirys created with SR
            for (Enquiry__c Enquiry : [select id, firstName__c, LastName__c, gender__c, Date_Of_Birth__c, SchoolLookup__c, Status__c, Passport_Number__c,MobilePhone__c, Email__c, IsConverted__c
                              from Enquiry__c where Id in : EnquiryIdList AND IsConverted__c = false]) {

                duplicateEnquiryList.add(Enquiry);
            }
        }
        
        //Duplicate Enquirys created without SR
        for (Enquiry__c Enquiry : [select id, FirstName__c, gender__c, Date_Of_Birth__c, SchoolLookup__c, Status__c, Passport_Number__c,LastName__c, MobilePhone__c, Email__c, IsConverted__c
                          FROM Enquiry__c WHERE Id !=: EnquiryObj.id AND ID NOT IN : EnquiryIdList
                          AND IsConverted__c = false
                          AND FirstName__c =: EnquiryObj.FirstName__c AND LastName__c =: EnquiryObj.LastName__c
                          AND email__c =: Enquiryobj.email__c AND MobilePhone__c =: Enquiryobj.MobilePhone__c]) {

            duplicateEnquiryList.add(Enquiry);
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
                            AND Id != :EnquiryObj.ConvertedAccountId__c
                            AND FirstName =: EnquiryObj.FirstName__c AND LastName =: EnquiryObj.LastName__c
                            AND Primary_Contact_Email__c =: Enquiryobj.email__c AND Emergency_Contact_Number__c =: Enquiryobj.MobilePhone__c]) {

            duplicateAccountList.add(acc);

        }
    }


}