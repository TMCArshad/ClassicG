/**
* Created by bilalnazir on 4/17/17.
* @author PWC
* @date 4/17/17
*
* @group Accounts, HexaBPM__Service_Request__c
* @group-content /apex/GEMS_EmiratesIDSFReader
*
* @description This class syncs emirates Id details with account and service request of the user.
*/

public without sharing class GEMS_EmiratesIDSFReaderController {

    private final String DEFAULT_UAE_COUNTRY_CODE = '172';
    private final String DEFAULT_ACCOUNT_PHOTO_NAME = 'photo.jpeg';
    private final String DEFAULT_MOTHER_PHOTO_NAME = 'Mother.jpeg';
    private final String DEFAULT_FATHER_PHOTO_NAME = 'Father.jpeg';

    public String CARD_READ_STATUS_STARTED { set; get; }
    public String CARD_READ_STATUS_COMPLETED { set; get; }

    public String cardReadStatus {get; set;}

    public Account userAccount { get; set; }
    public HexaBPM__Service_Request__c serviceRequest { get; set; }

    public String AccountName { get; set; }
    public String photoBase64String { get; set; }
    private String oldPhotoId { get; set; }

    public String SRPrimaryContact { get; set; }

    public Boolean accountInsert {get; set;}

    public String studentName {get; set;}
    public String studentNumber {get; set;}

//    public EmiratesCardInfo emiratesCardInfo {get; set;}

    public GEMS_EmiratesIDSFReaderController() {

        SRPrimaryContact = 'Student';
        accountInsert = false;
        cardReadStatus = '';
        CARD_READ_STATUS_STARTED = 'STARTED';
        CARD_READ_STATUS_COMPLETED = 'COMPLETED';

        if (ApexPages.currentPage().getParameters().containsKey('srid'))
            initServiceRequest();
        else if (ApexPages.currentPage().getParameters().containsKey('id'))
            initAccount();
        else
                initParentAccount();

    }

    // To let user show message if Card Reader not supported on the browser
    public void NotSupport_ActiveX(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.Emirates_ID_Sync_Not_Supported));
    }

    /**************** Servcie Request Methods *****************/
    /** Init service request for Emirates ID card syncing **
        1) initialize default SR object from id parameeter
        2) Also initialize the target primary account to update
     */
    public void initServiceRequest() {
        String serviceRequestId;

        if (ApexPages.currentPage().getParameters().containsKey('srid'))
            serviceRequestId = ApexPages.currentPage().getParameters().get('srid');

        if (ApexPages.currentPage().getParameters().containsKey('update'))
            SRPrimaryContact = ApexPages.currentPage().getParameters().get('update');

        /*
        for(HexaBPM__Service_Request__c sr: [
                SELECT Primary_Contact__c FROM HexaBPM__Service_Request__c WHERE id=:serviceRequestId]){
            SRPrimaryContact = sr.Primary_Contact__c;
        }*/

        // Initlaize SR for respecitve account
        if (SRPrimaryContact == 'Mother') {
            for (HexaBPM__Service_Request__c sr: [
                    SELECT id, Student__r.name, Student__r.Student_Id__c, First_Name__c, Last_Name__c, Lead__c, Lead_Relation_to_Student__c, Mother_Name_in_Emirates_ID__c, Mother_Arabic_Name_in_Emriates_ID__c,Other_Company_Mother__c,
                            Country_Mother__c, City_Emirate_Mother__c, Area_Mother__c, Street_Mother__c, Apartment_No_Mother__c, Building_Mother__c, P_O_Box_Mother__c,
                            Emirates_ID_Mother__c, Emirates_ID_Expire_Date_Mother__c

                    FROM HexaBPM__Service_Request__c
                    WHERE id = :serviceRequestId
            ]) {
                serviceRequest = sr;
                serviceRequest.Country_Mother__c = (serviceRequest.Country_Mother__c == null || serviceRequest.Country_Mother__c == '' ? DEFAULT_UAE_COUNTRY_CODE : serviceRequest.Country_Mother__c);// United Arab Emirates
                //photoBase64String = getSourceOfHTMLImage(serviceRequest.Emirate_Mother_Photo__c);
            }

        } else if (SRPrimaryContact == 'Father') {
            for (HexaBPM__Service_Request__c sr: [
                    SELECT id, Student__r.name, Student__r.Student_Id__c, First_Name__c, Last_Name__c, Lead__c, Lead_Relation_to_Student__c, Father_Name_in_Emirates_ID__c, Father_Arabic_Name_in_Emirates_ID__c, Other_Company_Father__c,
                            Country__c, City_Emirate__c, Area__c, Street__c, Apartment_No__c, Building__c, P_O_Box__c,
                            Emirates_ID_Father__c, Emirates_ID_Expire_Date_Father__c


                    FROM HexaBPM__Service_Request__c
                    WHERE id = :serviceRequestId
            ]) {
                serviceRequest = sr;
                serviceRequest.Country__c = (serviceRequest.Country__c == null || serviceRequest.Country__c == ''  ? DEFAULT_UAE_COUNTRY_CODE : serviceRequest.Country__c);// United Arab Emirates
                //photoBase64String = getSourceOfHTMLImage(serviceRequest.Emirate_Father_Photo__c);
            }

        } else {
            for (HexaBPM__Service_Request__c sr: [
                    SELECT id, Student__r.name, Student__r.Student_Id__c, First_Name__c, Last_Name__c, StudentId__c, Lead__c, Lead_Relation_to_Student__c, Arabic_Name_in_Emirates_ID__c, Name_in_Emirates_ID__c,
                            Date_Of_Birth__c, Place_of_Birth__c, Gender__c,
//                           Country_Guardian__c, City_Emirate_Guardian__c, Street_Guardian__c, Apartment_No_Guardian__c,
//                           Area_Guardian__c,Building_Guardian__c,P_O_Box_Guardian__c,
                            Emirates_ID__c, Emirates_ID_Issue_Date__c, Emirates_ID_Expiry_Date__c,
                            Passport_No__c, Passport_Issue_Date__c, Passport_Issue_Place__c, Passport_Expiry_Date__c,
                            Visa_No__c, Visa_Expiry_Date__c

                    FROM HexaBPM__Service_Request__c
                    WHERE id = :serviceRequestId

            ]) {
                serviceRequest = sr;
                //photoBase64String = getSourceOfHTMLImage(serviceRequest.Emirate_Student_Photo__c);
            }
        }

        System.debug('Service Request ==>' + serviceRequest );


        // Read photo data of the account
        for(Attachment att: [SELECT Id, Body
        FROM Attachment
        WHERE ParentId=:serviceRequest.Id and Name=: SRPrimaryContact +'.jpeg']){

            oldPhotoId = att.Id;
            photoBase64String = EncodingUtil.base64Encode(att.Body);
        }

    }


    /**
        @Description - On card details read,
            Sync the Account details in Salesforce
     */
    public PageReference SyncSR_fromCard() {
        try {

            // First update the SR details
            System.debug('Saving form Card Update ==>' + serviceRequest);
            if (SRPrimaryContact == 'Mother') {
                serviceRequest.Last_Emirates_ID_Sync_Date_Mother__c = Date.today();
            } else if (SRPrimaryContact == 'Father') {
                serviceRequest.Last_Emirates_ID_Sync_Date_Father__c = Date.today();
            } else {
                serviceRequest.Last_Emirates_ID_Sync_Date__c = Date.today();
            }
            upsert serviceRequest;

            // and then update the attachment
            Attachment oldPhotoAttachment = null,
                    newPhotoAttachment;

            for(Attachment att: [SELECT Id, Body
            FROM Attachment
            WHERE ParentId=:serviceRequest.Id and Name=: SRPrimaryContact +'.jpeg']){
                oldPhotoAttachment = att;
            }

            if(String.isNotBlank(photoBase64String) && !String.isEmpty(photoBase64String)) {

                if (oldPhotoAttachment == null) {
                    newPhotoAttachment = new Attachment();
                    newPhotoAttachment.ContentType = 'image/jpg';
                    newPhotoAttachment.Name = SRPrimaryContact + '.jpeg';
                    newPhotoAttachment.Body = EncodingUtil.base64Decode(photoBase64String);
                    newPhotoAttachment.parentId = serviceRequest.Id;
                    insert newPhotoAttachment;
                } else {

                    newPhotoAttachment = oldPhotoAttachment;

                    newPhotoAttachment.ContentType = 'image/jpg';
                    newPhotoAttachment.Name = SRPrimaryContact + '.jpeg';
                    newPhotoAttachment.Body = EncodingUtil.base64Decode(photoBase64String);

                    update newPhotoAttachment;
                }
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Sync completed successfully!'));
        } catch (Exception ex) {
            System.debug('SR Update Failed ==>' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Sync failed :' + ex.getMessage()));

        }

        return NULL;
    }

    /**************** Account Syncing Methods *****************/
    /**
        @Description - Initializes the user account to read in
        the emirates id details to show if already captured.
    */
    public void initAccount() {
        String accountId;
        if (ApexPages.currentPage().getParameters().containsKey('id'))
            accountId = ApexPages.currentPage().getParameters().get('id');

        for (Account userAcc: [
                SELECT Photo__c, Name, Student_Id__c, Photo_URL__c, RecordType.DeveloperName, Role__c, Emirates_ID_Synced_Date__c, Emirates_Full_Name__c,
                        PersonContactId, isPersonAccount, Arabic_Name__c, Gender__c, Date_Of_Birth__c, Place_of_Birth__c,Other_Company__c,

                        Country__c, Apartment_No__c, Building__c, Street__c, Area__c, P_O_Box__c, City_State__c,
                        Emirates_ID__c, Emirates_ID_Issue_Date__c, Emirates_ID_Expiry_Date__c,
                        Passport_No__c, Passport_Issue_Place__c, Passport_Issue_Date__c, Passport_Expiry_Date__c,
                        Visa_No__c, Visa_Expiry_Date__c, Visa_Issue_Date__c

                FROM Account
                WHERE id = :accountId
                LIMIT 1
        ]) {
            userAccount = userAcc;
            userAccount.Country__c = (userAccount.Country__c == null ||  userAccount.Country__c == '' ? DEFAULT_UAE_COUNTRY_CODE : userAccount.Country__c);// United Arab Emirates
            AccountName = userAcc.Name;

            studentName = userAccount.Name;
            studentNumber = userAccount.Student_Id__c;

            for (Attachment att: [SELECT Id, Body FROM Attachment WHERE ParentId = :userAccount.Id and Name = 'photo.jpeg']) {

                photoBase64String = EncodingUtil.base64Encode(att.Body);
            }
        }

        if(userAccount !=null && userAccount.RecordType.DeveloperName != 'Student'){
            for(Relationship__c rel: [SELECT Subject_Account__r.Name, Subject_Account__r.Student_Id__c FROM Relationship__c WHERE Object_Account__r.Id=:accountId]){
                studentName = rel.Subject_Account__r.Name;
                studentNumber = rel.Subject_Account__r.Student_Id__c;
            }
        }

    }

    /**
        @Description -
        setup a new parent account in relation to the student
     */
    public void initParentAccount(){
        List<RecordType> parentRecordTypes = [SELECT id, IsPersonType, DeveloperName  FROM RecordType
        WHERE SobjectType='Account' and IsPersonType=True and DeveloperName='Parent_Guardian'];

        if(ApexPages.currentPage().getParameters().containsKey('studentId') && ApexPages.currentPage().getParameters().containsKey('add')){
            SRPrimaryContact = (ApexPages.currentPage().getParameters().get('add') == 'mother'
                    ? 'Mother'
                    : (ApexPages.currentPage().getParameters().get('add') == 'father' ? 'Father' : null)
            );

            // initalize parent user account
            if(SRPrimaryContact != null && parentRecordTypes.size() > 0){

                System.debug('New Account for ' + SRPrimaryContact);
                accountInsert = true;
                userAccount = new Account(RecordTypeId=parentRecordTypes[0].Id);
                userAccount.Country__c = DEFAULT_UAE_COUNTRY_CODE;// United Arab Emirates

                userAccount.Role__c = SRPrimaryContact;
            }

            // initialize the student
            for(Account acc: [SELECT IsPersonAccount, Name, Student_Id__c
            FROM Account
            WHERE Id=:ApexPages.currentPage().getParameters().get('studentId')]){
                studentName = acc.Name;
                studentNumber = acc.Student_Id__c;
            }
        }

    }

    /**
        @Descrption - Syncs emirates card details with account of the user
     */
    public PageReference SyncAccount_fromCard() {
        try {

            userAccount.Emirates_ID_Synced_Date__c = Date.today();

            if(accountInsert){
                add_parentAccount();
                PageReference accountView = new PageReference('/apex/GEMS_EmiratesIDSFReader?id=' + userAccount.Id);
                accountView.setRedirect(true);
                return accountView;

            }else{
                update_Account();
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Sync completed successfully!'));

        } catch (Exception ex) {
            System.debug('Account Update Failed ==>' + ex.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Sync failed :' + ex.getMessage()));

        }

        return NULL;
    }


    /**
        @Description: creates a parent account for the student
        and creates relations between them
     */
    public void add_parentAccount(){
        if(ApexPages.currentPage().getParameters().containsKey('studentId')){
            String studentId = ApexPages.currentPage().getParameters().get('studentId');

            List<Account> studentAccounts = [SELECT id, IsPersonAccount,Mother__c, Father__c, Sibling_ID__c FROM Account WHERE id=:studentId LIMIT 1];

            if(studentAccounts.size() > 0){

                userAccount.Master_Student__c = studentAccounts[0].Sibling_ID__c;

                //Split name on emirates id for new account
                String fullName = String.valueOf(userAccount.Emirates_Full_Name__c);
                integer firstWordEndIndex = fullName.indexOf(' ');
                String firstName = fullName.substring(0, firstWordEndIndex); //First word as first name
                String lastName = fullName.substring(firstWordEndIndex+1, fullName.length()); //later all as last name

                userAccount.FirstName = firstName;
                userAccount.LastName = lastName;

                System.debug('Before: Inserting new account ==>' + userAccount);
                // Update student for new parent


                userAccount.Role__c = SRPrimaryContact;
                userAccount.Skip_Emirates_Id_New_Account_Validation__c = true;
                upsert userAccount;

                userAccount.Skip_Emirates_Id_New_Account_Validation__c = false;
                update userAccount;

                if(SRPrimaryContact == 'Mother'){
                    studentAccounts[0].Mother__c = userAccount.Id;
                }
                else if(SRPrimaryContact == 'Father'){
                    studentAccounts[0].Father__c = userAccount.Id;
                }
                update studentAccounts;

                System.debug('After: Inserting new account ==>' + userAccount);

                //create new relationship
                Relationship__c relationship = new Relationship__c();
                relationship.Type__c = SRPrimaryContact;
                relationship.Object_Account__c = userAccount.Id;
                relationship.Subject_Account__c = studentAccounts[0].Id;
                relationship.Created_From__c = 'Emirates ID Scan';
                relationship.Active__c = true;

                insert relationship;

                update_Account();
            }
        }
    }

    /**
        @Description - updates account, photo etc.
    */
    private void update_Account(){

        if(String.isNotBlank(photoBase64String) && !String.isEmpty(photoBase64String)){

            //upsert userAccount;

            Attachment att = addAccountPhoto();
            if(att != null) {
                userAccount.Photo_URL__c = Label.Attachment_File_URL+'?file=' + att.Id;
                //userAccount.Photo__c = '<img src='+Label.Attachment_File_URL+'?file=' + att.Id + ' alt="photo"/>';
            }
        }

        System.debug('Saving form Card Update ==>' + userAccount);
        userAccount.Skip_Emirates_Id_New_Account_Validation__c = true;
        upsert userAccount;

        userAccount.Skip_Emirates_Id_New_Account_Validation__c = false;
        update userAccount;
    }


    /**
        @Description - Adds photo on account from the captured base64 string,
        updates the existing if one already is there.
    */
    public Attachment addAccountPhoto (){

        Attachment oldPhotoAttachment = null,
                newPhotoAttachment;

        for(Attachment att: [SELECT Id, Body FROM Attachment WHERE ParentId=:userAccount.Id and Name=:DEFAULT_ACCOUNT_PHOTO_NAME]){
            oldPhotoAttachment = att;
        }

        try {
            if(oldPhotoAttachment == null){
                newPhotoAttachment= new Attachment();
                newPhotoAttachment.ContentType = 'image/jpg';
                newPhotoAttachment.Name= DEFAULT_ACCOUNT_PHOTO_NAME;//'photo.jpeg';
                newPhotoAttachment.Body=EncodingUtil.base64Decode(photoBase64String);
                newPhotoAttachment.parentId=userAccount.Id;
                insert newPhotoAttachment;
            }else{

                newPhotoAttachment = oldPhotoAttachment;

                newPhotoAttachment.ContentType = 'image/jpg';
                newPhotoAttachment.Name= DEFAULT_ACCOUNT_PHOTO_NAME;//'photo.jpeg';
                newPhotoAttachment.Body=EncodingUtil.base64Decode(photoBase64String);

                update newPhotoAttachment;
            }
        }catch(Exception ex){
            System.debug('Attachment on SR failed ==>' + ex.getMessage());
        }

        return newPhotoAttachment;

    }


}