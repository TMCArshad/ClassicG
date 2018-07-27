/**
 * Created by bilalnazir on 5/30/17.
 */

@IsTest
private class GEMS_EmiratesIDSFReaderController_Test {

    static testMethod void testEmiratesIDReader() {



        Test.setCurrentPageReference(new PageReference('Page.GEMS_EmiratesIDSFReader'));

        Account account = GEMS_TestUtils.createStudentAccount('test');

//        Test.StartTest();
        account = GEMS_TestUtils.createStudentAccount('test');
        System.currentPageReference().getParameters().put('studentId', account.Id);
        System.currentPageReference().getParameters().put('add', 'mother');
        GEMS_EmiratesIDSFReaderController eidReaderController = new GEMS_EmiratesIDSFReaderController();
        eidReaderController.accountInsert = true;
        eidReaderController.SRPrimaryContact = 'Mother';
        eidReaderController.userAccount.Emirates_Full_Name__c = 'First Last Name';
        update account;
        eidReaderController.SyncAccount_fromCard();
//        Test.StopTest();

        System.currentPageReference().getParameters().put('id', account.Id);

        account.Country__c = '172';
        update account;

        Attachment newPhotoAttachment= new Attachment();
        newPhotoAttachment.ContentType = 'image/jpg';
        newPhotoAttachment.Name= 'photo.jpeg';
        newPhotoAttachment.Body=Blob.valueof('data:image/jpeg;base64,');
        newPhotoAttachment.parentId=account.Id;
        insert newPhotoAttachment;
        testSyncFromAccount(account);



        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createStudentSR('Student');
        System.currentPageReference().getParameters().put('srid', SR.Id);
        System.currentPageReference().getParameters().put('update', 'Student');

        Attachment newPhotoAttachment1= new Attachment();
        newPhotoAttachment1.ContentType = 'image/jpg';
        newPhotoAttachment1.Name= 'Student.jpeg';
        newPhotoAttachment1.Body=Blob.valueof('data:image/jpeg;base64,');
        newPhotoAttachment1.parentId=sr.Id;
        insert newPhotoAttachment1;

        Attachment newPhotoAttachment2= new Attachment();
        newPhotoAttachment2.ContentType = 'image/jpg';
        newPhotoAttachment2.Name= 'Mother.jpeg';
        newPhotoAttachment2.Body=Blob.valueof('data:image/jpeg;base64,');
        newPhotoAttachment2.parentId=sr.Id;
        insert newPhotoAttachment2;

        Attachment newPhotoAttachment3= new Attachment();
        newPhotoAttachment3.ContentType = 'image/jpg';
        newPhotoAttachment3.Name= 'Father.jpeg';
        newPhotoAttachment3.Body=Blob.valueof('data:image/jpeg;base64,');
        newPhotoAttachment3.parentId=sr.Id;
        insert newPhotoAttachment3;


        testSyncFromSR(sr);
    }

    static void testSyncFromAccount(Account acc) {

        GEMS_EmiratesIDSFReaderController eidReaderController = new GEMS_EmiratesIDSFReaderController();
        eidReaderController.initAccount();

        eidReaderController.photoBase64String = 'data:image/jpeg;base64,';
        eidReaderController.SyncAccount_fromCard();
        //ApexPages.currentPage().getParameters().put('srid', 'UK');
    }

    static void testSyncFromSR(HexaBPM__Service_Request__c sr) {

        GEMS_EmiratesIDSFReaderController eidReaderController = new GEMS_EmiratesIDSFReaderController();
        eidReaderController.NotSupport_ActiveX();

        eidReaderController.photoBase64String = 'data:image/jpeg;base64,';

        try{

            eidReaderController.SRPrimaryContact = 'Student';
            List<Attachment> Attachments = [SELECT Name FROM Attachment WHERE ParentId=:SR.Id];
            delete Attachments;
            eidReaderController.initServiceRequest();
            eidReaderController.photoBase64String = '75AB5A8A66A07BF8E97A06DAB1EEB8';//data:image/jpeg;base64,
            eidReaderController.SyncSR_fromCard();


            eidReaderController.SRPrimaryContact = 'Father';
            Attachments = [SELECT Name FROM Attachment WHERE ParentId=:SR.Id and Name='Father.jpeg'];
            delete Attachments;
            eidReaderController.photoBase64String = '75AB5A8A66A07BF8E97A06DAB1EEB8';//data:image/jpeg;base64,
            eidReaderController.initServiceRequest();
            eidReaderController.SyncSR_fromCard();
            eidReaderController.addAccountPhoto();

        }catch(Exception ex){

        }

        //ApexPages.currentPage().getParameters().put('srid', 'UK');
    }

    static testMethod void test_syncMother_FromSR(){
        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createStudentSR('Student');
        System.currentPageReference().getParameters().put('srid', SR.Id);
        System.currentPageReference().getParameters().put('update', 'Mother');

        GEMS_EmiratesIDSFReaderController eidReaderController = new GEMS_EmiratesIDSFReaderController();

        eidReaderController.SRPrimaryContact = 'Mother';
        List<Attachment> Attachments = [SELECT Name FROM Attachment WHERE ParentId=:SR.Id];
        delete Attachments;
        eidReaderController.initServiceRequest();
        eidReaderController.photoBase64String = '75AB5A8A66A07BF8E97A06DAB1EEB8';//data:image/jpeg;base64,
        eidReaderController.SyncSR_fromCard();
    }

    static testMethod void test_syncFather_FromSR(){
        HexaBPM__Service_Request__c SR = GEMS_TestUtils.createStudentSR('Student');
        System.currentPageReference().getParameters().put('srid', SR.Id);
        System.currentPageReference().getParameters().put('update', 'Father');

        GEMS_EmiratesIDSFReaderController eidReaderController = new GEMS_EmiratesIDSFReaderController();

        eidReaderController.SRPrimaryContact = 'Father';
        List<Attachment> Attachments = [SELECT Name FROM Attachment WHERE ParentId=:SR.Id];
        delete Attachments;
        eidReaderController.initServiceRequest();
        eidReaderController.photoBase64String = '75AB5A8A66A07BF8E97A06DAB1EEB8';//data:image/jpeg;base64,
        eidReaderController.SyncSR_fromCard();
    }

}