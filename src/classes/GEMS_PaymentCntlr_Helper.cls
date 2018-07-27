/************************************************************************************
* Name               : GEMS_PaymentCntlr_Helper                                                               *
* Description        : Helper Class for GEMS_PaymentCntlr                                        *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Keerthan         16/02/2017
* 1.1         Keerthan         4/09/2017(#1133307)
* 1.2		  Swati		  Ticket:180290 (19th March 2018)
**************************************************************************************************/
public without sharing class GEMS_PaymentCntlr_Helper {

  public static Page__c completeFilePage {get; set;}
  public static boolean paymentComplete {get; set;} //Identifieer to see if all the applicant payment is complete
  public static boolean enablePayment {get; set;} //Identifier to see if atleast one SR has with SR price Item enabled with pay online
  public GEMS_PaymentCntlr_Helper() {
    paymentComplete  = true;
    enablePayment = false;
    completeFilePage = getCompleteFilePage();
  }
  /**
   * [getAllServiceRequestsForleadReference Returns all SRs with same LeadRefNumber]
   * @param  leadRef [LeadReferenceNumber]
   * @return         [List of Service Requests]
   */
  public static List<HexaBPM__Service_Request__c> getAllServiceRequestsForleadReference(String leadRef) {

    List<HexaBPM__Service_Request__c> SRList = new List<HexaBPM__Service_Request__c>();
    SRList = GEMS_Utility.getAllServiceRequestsForleadReference(leadRef);
    return SRList;


  }
  /**
   * [getPaymentPageURL Builds URL for payment page -Short Form]
   * @param  leadRef [LeadReferenceNumber]
   * @param  BSUID   [School Code]
   * @return         [URL String to payment Page -Short Form]
   */
  public static String getPaymentPageURL(String leadRef, String BSUID) {
    String paymentPageURL  = Site.getBaseUrl() + '/apex/' + GEMS_Constants.PAYMENT_PAGE;
    paymentPageURL += '?';
    paymentPageURL += 'BSU=' + BSUID  + '&';
    paymentPageURL += 'RefId=' + leadRef;
    return paymentPageURL;
  }
  /**
   * [getCompleteFileURL Builds URL String to CompleteFile Page for individual SR]
   * @param  SR      [Service Request]
   * @param  leadRef [Lead Reference Number]
   * @param  BSUID   [School Code]
   * @return         [Complete File URL]
   */
  public static String getCompleteFileURL(HexaBPM__Service_Request__c SR, String leadRef, String BSUID) {

    //String completeFileURL  = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/' +  GEMS_Constants.COMPLETE_FILE_PAGE;
    String completeFileURL  = Site.getBaseUrl() + '/apex/' +  GEMS_Constants.COMPLETE_FILE_PAGE;
    completeFileURL += '?';
    completeFileURL += 'FlowId=' + GEMS_Utility.getEnctryptedURLparam(completeFilePage.Page_Flow__c) + '&';
    completeFileURL += 'Id=' + GEMS_Utility.getEnctryptedURLparam(SR.Id) + '&';
    completeFileURL += 'PageId=' + GEMS_Utility.getEnctryptedURLparam(completeFilePage.Id) + '&';
    completeFileURL += 'RefId=' + leadRef + '&';
    completeFileURL += 'BSU=' + BSUID;

    return completeFileURL;
  }
  /**
   * [getCompleteFilePage - Build completefile page Flow page]
   * @return [Complete File page]
   */
  public static Page__c getCompleteFilePage() {
    Page__c cmpleteFilePage = new Page__c();

    for (Page__c p :  [SELECT ID, Page_Flow__c, Page_Flow__r.Record_Type_API_Name__c FROM Page__c WHERE Page_Flow__r.Record_Type_API_Name__c = : GEMS_Constants.SRRT_ENROLLMENT ]) {
      cmpleteFilePage = p;
    }
    return cmpleteFilePage;
  }
  /**
   * [createPaymentWrapper Build Payment table for GEMS Short form payment page]
   * @param  leadRef [LeadreferenceNumber]
   * @param  BSUID   [School Code]
   * @return         [Payment Wrapper table]
   */
  public static List<paymentWrapper> createPaymentWrapper(String leadRef, String BSUID) {

    paymentComplete  = true;
    enablePayment = false;
    List<Id> SRIdList = new List<Id>();
    completeFilePage = getCompleteFilePage();

    Map<Id, HexaBPM__Service_Request__c> SRIdtoSRMap = new Map<Id, HexaBPM__Service_Request__c>();
    Map<Id, HexaBPM__SR_Price_Item__c> SRIdtoPriceItemMap = new Map<Id, HexaBPM__SR_Price_Item__c>();
    List<paymentWrapper> paymentWrapper_List =  new List<paymentWrapper>();

    List<HexaBPM__Service_Request__c> SR_List = getAllServiceRequestsForleadReference(leadRef);
    System.debug('GEMS_PaymentCntlr_Helper createPaymentWrapper SR_List : ' + SR_List.Size());
     System.debug('GEMS_PaymentCntlr_Helper createPaymentWrapper Lead_Reference__c : ' + SR_List[0].Lead_Reference__c);
    for (HexaBPM__Service_Request__c SR : SR_List) {
      if(SR.HexaBPM__External_Status_Name__c!='Cancelled'){
      SRIdList.add(SR.Id);
      SRIdtoSRMap.put(SR.ID, SR);
     }
    }

    //Create SRID to SR PriceItemMap
    //One SR will have one SR PriceItem for a specific Product Code
	
	//1.2
	string pricingLine = 'Registration Fee';
    for (HexaBPM__SR_Price_Item__c pl : [SELECT
                                         HexaBPM__Price__c,
                                         Product__c,
                                         Product__r.ProductCode,
                                         Product__r.Name,
                                         HexaBPM__SRPriceLine_Text__c,
                                         HexaBPM__Price_in_USD__c,
                                         HexaBPM__ServiceRequest__c,
                                         HexaBPM__Discount_Amount__c,
                                         Status__c,
                                         Open_Online_Payment__c
                                         FROM  HexaBPM__SR_Price_Item__c
                                         WHERE HexaBPM__ServiceRequest__c IN:SRIdList
                                         and HexaBPM__SRPriceLine_Text__c =:pricingLine and status__c!='Cancelled']) {//V1.2

      SRIdtoPriceItemMap.put(pl.HexaBPM__ServiceRequest__c, pl);
    }
    System.debug('PI :'+SRIdtoPriceItemMap);
    //Create SR to SR Price Item Map
    paymentWrapper pw ;
    HexaBPM__Service_Request__c SR;
    HexaBPM__SR_Price_Item__c SR_PriceItem = new HexaBPM__SR_Price_Item__c();
    for (Id SRId  : SRIdtoSRMap.keySet() ) {
      SR = SRIdtoSRMap.get(SRId);
      SR_PriceItem =  SRIdtoPriceItemMap.get(SRId);
      System.debug('pw.SR_PriceItem:'+SR_PriceItem);
      //Bug Fix #1133307
      //Date 4/9/2017
      //Details - Ability to complete SR even when there is no PL associated
      if (SR != NULL && SR.HexaBPM__External_Status_Name__c!='Cancelled') {
        pw = new paymentWrapper(SR, SR_PriceItem, leadRef, BSUID);
        paymentComplete = (SR_PriceItem != NULL && pw.SR_PriceItem.Status__c.equals('Added')) ? false : paymentComplete;
        enablePayment = (SR_PriceItem != NULL && pw.SR_PriceItem.Open_Online_Payment__c != NULL && pw.SR_PriceItem.Open_Online_Payment__c.equals('Yes')) ? true : enablePayment;
        paymentWrapper_List.add(pw);

      }
    }
    System.debug('paymentWrapper_List==>'+paymentWrapper_List);
    return paymentWrapper_List;

  }

  /**
   * Wrapper class for payment information
   */
  public class paymentWrapper {
    public Boolean isSelected {get; set;}
    public HexaBPM__Service_Request__c SR {get; set;}
    public HexaBPM__SR_Price_Item__c SR_PriceItem {get; set;}
    public String completeFileURL {get; set;}
    public string paymentPageURL {get; set;}
    public paymentWrapper(HexaBPM__Service_Request__c SR, HexaBPM__SR_Price_Item__c SR_PriceItem, String leadRef, String BSUID) {
      isSelected = false;
      this.SR = SR;
      this.SR_PriceItem = SR_PriceItem;
      this.completeFileURL  = getCompleteFileURL(SR, leadRef, BSUID);
      this.paymentPageURL = getPaymentPageURL(leadRef, BSUID);
    }

  }


}