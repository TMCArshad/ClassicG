/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GEMS_InvokeSMS_ES_Test {
    static testMethod void Tes_SMS() {
        GEMS_InvokeSMS_ES objsms = new GEMS_InvokeSMS_ES ();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email.subject =  'Customer SMS Phone=+971528120660';
        email.plainTextBody = 'test';
        envelope.fromAddress = 'maf@cloudsocius.com';
        objsms.handleInboundEmail(email, envelope);
        /*
        string strEmailBody;
        string strEmailSubject;
        string phoneNumber;
        if(phoneNumber!=null && phoneNumber!='' && strEmailBody!=null && strEmailBody!=''){
            system.debug('Send SMS Invoking===>');
            GEMS_SendSMSUtil.sendsms(phoneNumber,strEmailBody); 
        }
        */
    }
}