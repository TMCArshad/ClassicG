@isTest
private class GEMS_ThankYouCntlrExtTest {
    static testmethod void GEMS_ThankYouCntlrExtTest(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	objSR.Primary_Contact__c = 'Father'; 
    	update objSR;
    	
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('REGISTRATION');
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('ENROLLMENT', objSR.stream__c, objSR.academic_year__c, objSr.school__c);
    	HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('Enrollment', 'Enrollment Fee', objSR.id);
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_Thank_You'));
    	System.currentPageReference().getParameters().put('BSU', objSR.School__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('Stage', 'Enrollment');
    	GEMS_ThankYouCntlrExt thankCtlr = new GEMS_ThankYouCntlrExt(); 
    	thankCtlr.payNow();
    	thankCtlr.payLater();
    	thankCtlr.cancelEnrollment();
    	thankCtlr.acceptOffer();
    	
    	
    	objSR.Primary_Contact__c = 'Mother'; 
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_Thank_You'));
    	System.currentPageReference().getParameters().put('BSU', objSR.School__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('Stage', 'Enrollment');
    	GEMS_ThankYouCntlrExt thankCtlr1 = new GEMS_ThankYouCntlrExt(); 
    	
    	objSR.Primary_Contact__c = 'Guardian'; 
    	update objSR;
    	
    	Test.setCurrentPageReference(new PageReference('Page.Gems_Thank_You'));
    	System.currentPageReference().getParameters().put('BSU', objSR.School__c);
    	System.currentPageReference().getParameters().put('Id', objSR.id);
    	System.currentPageReference().getParameters().put('Stage', 'Enrollment');
    	GEMS_ThankYouCntlrExt thankCtlr2 = new GEMS_ThankYouCntlrExt(); 
    	
    }
}