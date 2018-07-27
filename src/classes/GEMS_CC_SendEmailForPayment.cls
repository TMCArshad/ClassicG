/**
*Author       : Keerthan Tantry
*Description  : Class implementing HexaBPM.iCustomCodeExecutable to send email with payment link to Father/Mother 
*               for Service Request with Record Type = 'TC Request'
*
*
*
***/
global without sharing class GEMS_CC_SendEmailForPayment implements HexaBPM.iCustomCodeExecutable {

	global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
		System.debug('step:'+step);
		HexaBPM__Step__c currStep;
        try{
		String stepId = step.Id;
		List<String> toAddresses = new List<String>();
		currStep = [Select Id,
		                             HexaBPM__SR__r.School__r.Id__c,
		                             HexaBPM__SR__c,
		                             HexaBPM__SR__r.HexaBPM__Customer__r.Primary_Contact__c,
		                             HexaBPM__SR__r.HexaBPM__Customer__r.Mother__r.PersonEmail,
		                             HexaBPM__SR__r.HexaBPM__Customer__r.Father__r.PersonEmail
		                             FROM HexaBPM__Step__c
		                             Where Id = : stepId];
		System.debug('currStep'+currStep);
		if (currStep.HexaBPM__SR__r.HexaBPM__Customer__r.Primary_Contact__c.equals('Father')) {
			toAddresses.add(currStep.HexaBPM__SR__r.HexaBPM__Customer__r.Father__r.PersonEmail);
		} else {
			toAddresses.add(currStep.HexaBPM__SR__r.HexaBPM__Customer__r.Mother__r.PersonEmail);
		}
		
		sendPaymentEmail(toAddresses, currStep);
        }
        Catch(Exception e){
         GEMS_Utility.LogException(e);
         
         return (e.getMessage());
        }

		return NULL;
	}

	public void sendPaymentEmail(List<String> toAddresses, HexaBPM__Step__c step) {  

		EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName =: GEMS_Constants.GEMS_TC_PAYMENTEMAIL];

		HexaBPM__SR_Price_Item__c PI = [Select HexaBPM__Price__c	from HexaBPM__SR_Price_Item__c WHERE HexaBPM__ServiceRequest__c = :step.HexaBPM__SR__c AND Status__c != 'Paid' LIMIT 1];
		String paymentRedirectPageURL = getRedirectURL();
		GEMS_MiGS_Utility.SRIds = step.HexaBPM__SR__c; //Setting list of SR ids if in case multiple SRs are paid once
		GEMS_MiGS_Utility.retURLVal = getReturnURL();  // Setting value so that once transion is complete we know where to redirect
		GEMS_MiGS_Utility.schoolCode = step.HexaBPM__SR__r.School__r.Id__c; //Setting school code to get apprropriate merchent details from custom metadata type
		String url = GEMS_MiGS_Utility.getMiGSPaymentURL(String.valueOf(PI.HexaBPM__Price__c), 'Transfer Request - Fee ', paymentRedirectPageURL);
        System.debug(' GEMS_CC_SendEmailForPayment sendPaymentEmail url:'+url);
		GEMS_EmailHelper EmailHelper = new GEMS_EmailHelper(toAddresses);
		String htmlBody = EmailTemplate.HtmlValue;
		EmailHelper.htmlBody = htmlBody.replace('Payment URL:', 'Payment URL:' + url);
		//EmailHelper.senderDisplayName = 'Test name';
		EmailHelper.subject = 'Please complete TC request payment';
		EmailHelper.useSignature = false;
		EmailHelper.sendEmail();
	}

	public String getRedirectURL() {

		String paymentRedirectPageURL  = Label.Site_base_URL + '/apex/' +  GEMS_Constants.PAYMENT_REDIRECTION_PAGE;
		System.debug('paymentRedirectPageURL:'+paymentRedirectPageURL);
		return paymentRedirectPageURL;
	}
    public String getReturnURL() {

		String returnURL  = Label.Site_base_URL + '/apex/' +  GEMS_Constants.PAYMENTCOMPLETE_PAGE;
		System.debug('returnURL:'+returnURL);
		return returnURL;
	}
}