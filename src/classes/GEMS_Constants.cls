public without sharing class GEMS_Constants {
	/*
	Lead status values - Start
	 */
    public static final string UNINTERESTED ='Not Interested';
	public static final string TOUR_NOT_ATTENDED ='Tour Not Attended';
	public static final string TOUR_BOOKED = 'Tour Booked';
	public static final string ASSIGNED_TO_ANOTHER_SCHOOL ='Assigned to Another School'; 
	public static final string CONTACTED_ONCE = 'Contacted 1';
	public static final string CONTACTED_TWO_TIMES = 'Contacted 2';
	public static final string CONTACTED_THREE_TIMES = 'Contacted 3';
   /*
	Lead status values - End
	 */
     
    public static final string SRTYPE_ENROLLMENT_SHORT_FORM  ='Enrollment Short Form';
	public static final string REGISTRATION_PRODUCT_CODE  = 'REGISTRATION FEE'; // Registration process product code

	public static final string PAYMENT_PAGE  = 'GEMS_PaymentPage'; //Payment page API name
	public static final string PAYMENTCOMPLETE_PAGE  = 'GEMS_PaymentCompletePage'; //Payment page API name 
	
	public static final string PAYMENT_REDIRECTION_PAGE  = 'GEMS_PaymentRedirectPage'; //Payment Gateway lsnding page
	public static final string ENQUIRYDETAILS_PAGE  = 'GEMS_EnquiryDetailsPage'; // Enquiry Detail Page API Name
    public static final string COMPLETE_FILE_PAGE  = 'GEMS_CompleteFilePage';
	public static final String CRYPTOKEY = '12341544566467678798791237868947'; //Key used for encryption and decryption
	public static final String AES128SALT16 = '1234567890234516'; 

	public static final string SRRT_ENROLLMENT = 'Enrollment'; //Service request Record Type
	public static final string SRRT_TCREQUEST = 'TC_Request'; //TC Request Record Type
	public static final String SRRT_EDIT_CRITICAL_DATA = 'Edit_Critical_Data';
	public static final String SRRT_CANCEL_ADMISSION = 'Cancel_Admission'; 
	public static final String SRRT_STRIKEOFF = 'Strike_Off'; 
	public static final Blob AES128KEY = Crypto.generateAesKey(128);


	public static final String GEMS_TC_PAYMENTEMAIL = 'GEMS_TC_Payment';
	public static final String GEMS_TC_CEARANCE_INTERNAL = 'GEMS_TC_Clearance_Email_Internal';
	public static final String GEMS_TC_CEARANCE = 'GEMS_TC_Clearance_Email';
	public static final String GEMS_PAYMENTEMAIL = 'GEMS_Complete_Payment';
}