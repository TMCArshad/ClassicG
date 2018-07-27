/************************************************************************************
* Name               : GEMS_PaymentCntlr                                                               *
* Description        : Implements logic for Short Form payment page                                        *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Keerthan         16/02/2017
* 1.1         Keerthan         4/09/2017(#1133307)
**************************************************************************************************/
public without sharing class GEMS_PaymentCntlr {
    public string leadReferenceNumber { get; set; }
    public string leadReferenceNumberEncrypted { get; set; }
    public List<GEMS_PaymentCntlr_Helper.paymentWrapper> paymentWrappers { get; set; }
    public string totalPrice { get; set; }
    public boolean paymentComplete { get; set; }
    public boolean enablePayment { get; set; }
    public List<String> SRIds { get; set; }
    public string BSUID { get; set; }
    public School__c school { get; set; }
    public List<HexaBPM__Service_Request__c> lstSR { get; set; }
    public boolean payLaterFlag { get; set; } //Show/Hide Pay Later button
    public GEMS_Site_Domain_Config__c domainConfig {get; set;}
    public Decimal minimumDepositAmount { get; set; }

    public GEMS_PaymentCntlr() {
        SRIds = new List<String>();
        paymentComplete = false;
        paymentWrappers = new List<GEMS_PaymentCntlr_Helper.paymentWrapper>();
        leadReferenceNumber = ApexPages.CurrentPage().getParameters().get('RefId');
        BSUID = ApexPages.currentPage().getParameters().get('BSU');
        totalPrice = '0';
        
        try {
        	if(string.isNotBlank(BSUID) && BSUID.length()==6 && BSUID.isNumeric()) {
            school = GEMS_Utility.getSchool(BSUID);
            domainConfig = GEMS_Utility.getSiteURLConfig(school.Short_Name__c);
            if (leadReferenceNumber != NULL && leadReferenceNumber != '') {

                initPaymnetTable();
            }
        	}
        } catch (Exception e) {
        	system.debug('-----'+e.getLineNumber());
            GEMS_Utility.addPageError('Error: ' + e.getMessage());
        }

    }
    /**
     * [initPaymnetTable - Prepare payment table with SR information]
     */
    public void initPaymnetTable() {
        paymentWrappers = GEMS_PaymentCntlr_Helper.createPaymentWrapper(leadReferenceNumber, BSUID);
        paymentComplete = GEMS_PaymentCntlr_Helper.paymentComplete;
        enablePayment = GEMS_PaymentCntlr_Helper.enablePayment;
       
        minimumDepositAmount = 0;
        if (paymentWrappers.size() > 0) {
            minimumDepositAmount = paymentWrappers[0].SR_PriceItem.HexaBPM__Price__c;
        }
    }

    /**
     * [init Update all the SR with processFlow URL ]
     */
    public void init() {

        List<HexaBPM__Service_Request__c> SR_List = new List<HexaBPM__Service_Request__c>();
        //If payment wrappper is empty --> No SR Price Items
        //If no SR Price Items --> No Payment
        //Navigate to third page
        for (GEMS_PaymentCntlr_Helper.paymentWrapper pw : paymentWrappers) {
            pw.isSelected = (pw.SR_PriceItem.Status__c == 'Paid' || pw.SR_PriceItem.Open_Online_Payment__c != 'Yes') ? false : true;
            if (pw.SR.Process_Flow__c == NULL) {
            	//Bug Fix #1133307
                //Date 4/9/2017
                //Details - Ability to complete SR even when there is no PL associated
                pw.SR.Complete_File_URL__c = pw.completeFileURL;
                system.debug('---pw.paymentPageURL---'+pw.paymentPageURL);
                pw.SR.GEMS_URL__c = (domainConfig != NULL ) ? domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c   + '?' + EncodingUtil.base64Encode(Blob.valueOf(pw.paymentPageURL.subStringAfter('/GEMS/'))) : NULL ;
                if ( pw.SR.HexaBPM__Internal_Status_Name__c =='Draft' && (( pw.SR_PriceItem.Open_Online_Payment__c == 'No'  && pw.SR_PriceItem.HexaBPM__SRPriceLine_Text__c == 'Registration - Fee' ) || pw.SR_PriceItem == NULL)) {
                    //Auto submit if Price Item has no Online Payment option
                    for (HexaBPM__SR_Status__c srStatus : [select Id from HexaBPM__SR_Status__c where Name = 'Submitted']) {
                        pw.SR.HexaBPM__Internal_SR_Status__c = srStatus.Id;
                        pw.SR.HexaBPM__External_SR_Status__c = srStatus.Id;
                        pw.SR.HexaBPM__Submitted_Date__c = system.today();
                        pw.SR.HexaBPM__Submitted_DateTime__c = system.now();
                    }
                    
                }
                
            }
           SR_List.add(pw.SR);
        }

        calculateTotalPrice();
        if(!SR_List.isEmpty()){
        update SR_List;
        }
        
    }
    

    /**
     * [calculateTotalPrice - Calculate sum of price when multiple records are selected in the table]
     */
    public void calculateTotalPrice() {
        SRIds.clear();
        Integer totPrice = 0;
        for (GEMS_PaymentCntlr_Helper.paymentWrapper wrp : paymentWrappers) {
        	system.debug('--wrp--'+wrp.isSelected);
            system.debug('--wrp.SR.ID--'+wrp.SR.ID);
            if (wrp.isSelected) {
                SRIds.add(wrp.SR.ID);
                Integer priceVal = (wrp.SR_PriceItem.HexaBPM__Price__c != NULL) ? Integer.valueOf(wrp.SR_PriceItem.HexaBPM__Price__c) : 0;
                totPrice += priceVal;

            }
        }

        totalPrice = String.valueOf(totPrice.format());
    }

    /**
     * [payNow - Generates Payment URL and does and post cal to the payment gateway endpoint]
     * @return [ Pagereference to the payment gateway page]
     */
    public PageReference payNow() {

        String SRIdsStr = String.join(SRIds, ',');
        System.debug('SRIdsStr:'+SRIdsStr);
        initPaymnetTable();
        if (GEMS_Validations.validatePayment(SRIds) != 'Success') {

            GEMS_Utility.addPageError('Invalid payment request.');
            return NULL;
        }

        String paymentRedirectPageURL = getRedirectURL();

        GEMS_MiGS_Utility.SRIds = SRIdsStr; //Setting list of SR ids if in case multiple SRs are paid once
        GEMS_MiGS_Utility.retURLVal = GEMS_Utility.getReferer(); // Setting value so that once transion is complete we know where to redirect
        GEMS_MiGS_Utility.schoolCode = BSUID; //Setting school code to get apprropriate merchent details from custom metadata type
        String url = GEMS_MiGS_Utility.getMiGSPaymentURL(totalPrice.replace(',', ''), 'Registration - Fee ', paymentRedirectPageURL);
        try {
            PageReference pg ;
            pg = new PageReference(url);
            pg.setRedirect(true);
            return pg;
        } catch (Exception e) {
            GEMS_Utility.LogException(e);
            GEMS_Utility.addPageError(e.getMessage());
            return NULL;
        }


    }

    /**
     * [payLater - Changes the SR Payment Status to Pay At School and enable the Complete link ]
     * @return [ Pagereference to the payment gateway page]
     */
    public void payLater() {

        list<HexaBPM__Service_Request__c> lstUpdateSR = new list<HexaBPM__Service_Request__c>();
        for (GEMS_PaymentCntlr_Helper.paymentWrapper obj : paymentWrappers) {
            if (obj.isSelected) {
                HexaBPM__Service_Request__c objSR = obj.SR;
                objSR.Payment_Status__c = 'Pay At School';
                lstUpdateSR.add(objSR);
            }
        }
        try {
            if (lstUpdateSR != null && lstUpdateSR.size() > 0)
                upsert lstUpdateSR;

            paymentWrappers = GEMS_PaymentCntlr_Helper.createPaymentWrapper(leadReferenceNumber, BSUID);
            paymentComplete = GEMS_PaymentCntlr_Helper.paymentComplete;
            totalPrice = null;

        } catch (Exception e) {

        }


    }

    /**
     * [getRedirectURL Get redirection page URL]
     * @return [ redirection page URL]
     */
    public String getRedirectURL() {

        //String paymentRedirectPageURL  = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/' +  GEMS_Constants.PAYMENT_REDIRECTION_PAGE;
        String paymentRedirectPageURL = Site.getBaseUrl() + '/apex/' + GEMS_Constants.PAYMENT_REDIRECTION_PAGE;
        return paymentRedirectPageURL;
    }

    /**
     * [goToEnquiryDetailsPage - Allows navifgation back to Enquiry Details page]
     * @return [ Pagereference tp enquiry details page]
     */
    public PageReference goToEnquiryDetailsPage() {
        PageReference pg = GEMS_Utility.getPgReference(Site.getBaseUrl() + '/apex/' + GEMS_Constants.ENQUIRYDETAILS_PAGE);
        pg.getParameters().put('RefId', leadReferenceNumber);
        pg.getParameters().put('BSU', BSUID);
        return pg;


    }

}