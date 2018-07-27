public  class GEMS_PaymentComponentCntlr {
    
    public List<GEMS_PaymentCntlr_Helper.paymentWrapper> paymentWrappers {get;set;}
    public string totalPrice {get;set;}
    public boolean paymentComplete {get;set;}
    public boolean enablePayment {get;set;}
    public List<String> SRIds {get;set;}
    public string BSUID{get;set;}
    public School__c school { get; set; }
    public GEMS_Site_Domain_Config__c domainConfig{get;set;}
    public string leadReferenceNumber{
        get{
            return leadReferenceNumber;
        }
        set{
            leadReferenceNumber = value;
            if(BSUID != NULL && leadReferenceNumber != NULL){
            init();
            }
        }
    }
    public List<HexaBPM__Service_Request__c> lstSR{get;set;}
    public boolean payLaterFlag {get; set;} //Show/Hide Pay Later button

 
    public GEMS_PaymentComponentCntlr() {
        System.debug('==>'+leadReferenceNumber);
        System.debug('==>'+BSUID);

        SRIds =  new List<String>();
        paymentComplete = false;
        paymentWrappers =  new List<GEMS_PaymentCntlr_Helper.paymentWrapper>();
        //leadReferenceNumber = ApexPages.CurrentPage().getParameters().get('RefId');
        //BSUID = ApexPages.currentPage().getParameters().get('BSU');
        totalPrice = '0';
        
        if(leadReferenceNumber != NULL && leadReferenceNumber != ''){   
             
             paymentWrappers = GEMS_PaymentCntlr_Helper.createPaymentWrapper(leadReferenceNumber,BSUID);
             paymentComplete  = GEMS_PaymentCntlr_Helper.paymentComplete;
             enablePayment = GEMS_PaymentCntlr_Helper.enablePayment;
        }
    }


    public void init(){
              school = GEMS_Utility.getSchool(BSUID);
              paymentWrappers = GEMS_PaymentCntlr_Helper.createPaymentWrapper(leadReferenceNumber,BSUID);
              paymentComplete  = GEMS_PaymentCntlr_Helper.paymentComplete;
              enablePayment = GEMS_PaymentCntlr_Helper.enablePayment;
              System.debug('paymentWrappers==>'+paymentWrappers);
              List<HexaBPM__Service_Request__c> SR_List = new List<HexaBPM__Service_Request__c>();
              for(GEMS_PaymentCntlr_Helper.paymentWrapper pw : paymentWrappers ){
                  pw.isSelected = (pw.SR.Payment_Status__c == 'Paid' || pw.SR_PriceItem.Open_Online_Payment__c != 'Yes' )? false : true;
                  if(pw.SR.Process_Flow__c == NULL){
                  pw.SR.Process_Flow__c = pw.completeFileURL;
                  pw.SR.GEMS_URL__c =  domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c    + '?' + pw.completeFileURL.subStringAfter('?');
                  SR_List.add(pw.SR);
                }
                
              }
              calculateTotalPrice();
              update SR_List;
    }

    /**
    * [calculateTotalPrice - Calculate sum of price when multiple records are selected in the table]
    */
   public void calculateTotalPrice(){
    SRIds.clear();
    Integer totPrice = 0;
    for(GEMS_PaymentCntlr_Helper.paymentWrapper wrp : paymentWrappers){
        if(wrp.isSelected){
        SRIds.add(wrp.SR.ID);
        Integer priceVal = (wrp.SR_PriceItem.HexaBPM__Price__c != NULL) ? Integer.valueOf(wrp.SR_PriceItem.HexaBPM__Price__c) : 0;
            totPrice += priceVal;
            
        }
    }
    
    totalPrice = String.valueOf(totPrice);
   }

   /**
    * [payNow - Generates Payment URL and does and post cal to the payment gateway endpoint]
    * @return [ Pagereference to the payment gateway page]
    */
   public PageReference payNow(){

    String SRIdsStr = String.join(SRIds,',');
    
    String paymentRedirectPageURL = getRedirectURL();
    System.debug('paymentRedirectPageURL:'+paymentRedirectPageURL);

    GEMS_MiGS_Utility.SRIds = SRIdsStr; //Setting list of SR ids if in case multiple SRs are paid once
    GEMS_MiGS_Utility.retURLVal = GEMS_Utility.getReferer(); // Setting value so that once transion is complete we know where to redirect
    GEMS_MiGS_Utility.schoolCode = BSUID; //Setting school code to get apprropriate merchent details from custom metadata type
    String url = GEMS_MiGS_Utility.getMiGSPaymentURL(totalPrice,'Registration - Fee ',paymentRedirectPageURL);
    
    PageReference pg ;
    pg = new PageReference(url);
    pg.setRedirect(true);
    return pg;

   }

   /**
   * [getRedirectURL Get redirection page URL]
   * @return [ redirection page URL]
   */
   public String getRedirectURL(){

       //String paymentRedirectPageURL  = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/' +  GEMS_Constants.PAYMENT_REDIRECTION_PAGE;
       String paymentRedirectPageURL  = Site.getBaseUrl() + '/apex/' +  GEMS_Constants.PAYMENT_REDIRECTION_PAGE;
       return paymentRedirectPageURL;
   }
 
   /**
    * [goToEnquiryDetailsPage - Allows navifgation back to Enquiry Details page]
    * @return [ Pagereference tp enquiry details page]
    */
   public PageReference goToEnquiryDetailsPage(){
   PageReference pg = GEMS_Utility.getPgReference(Site.getBaseUrl() + '/apex/' + GEMS_Constants.ENQUIRYDETAILS_PAGE);
   pg.getParameters().put('RefId',leadReferenceNumber);
   pg.getParameters().put('BSU',BSUID);
   return pg;


   }
}