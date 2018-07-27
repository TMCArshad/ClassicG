public with sharing class GEMS_ThankYouCntlrExt {
    
    public HexaBPM__Service_Request__c objSR {get;set;}
    public List<HexaBPM__SR_Price_Item__c> priceItem {get;set;}
    public string basicInfoPageURl {get;set;}
    
    public string curriculum {get;set;}
    
    public string studentName {get;set;}
    public string parentName {get;set;}
    public string parentCountry {get;set;}
    public string parentCity {get;set;}
    public string parentPhone {get;set;}
    public string parentEmail {get;set;}
    public string siblingDetails {get;set;}
    public string stage {get;set;}
    public string academicYear {get; set;}
    
    public String SRId;
    public string BSUID;
    
    public decimal totalPrice;
    
    public map<string,string> mapParameters;
    
    public boolean noPayment {get;set;}
    public boolean offerAccepted {get;set;}
    public boolean offerRejected {get;set;}
    
    public List<SelectOption> cancelOfferLetter {get;set;}
    public string cancelOfferLetterValue {get;set;}
    
    public GEMS_ThankYouCntlrExt () {
        SRId = '';
        BSUID = '';
        totalPrice = 0;
        stage = '';
        String pricingLine = '';
        noPayment = false;
        mapParameters = new map<string,string>();
        academicYear = '';
        offerAccepted = false;
        offerRejected = false;
        
        if(apexpages.currentPage().getParameters()!=null && apexpages.currentPage().getParameters().size()>0)
            mapParameters = apexpages.currentPage().getParameters();
        
        SRId = MapParameters.get('Id');
        stage = MapParameters.get('Stage');
        
        if(stage == 'Registration'){
            pricingLine = 'Registration Fee';
        }
        else if (stage == 'Enrollment'){
            pricingLine = 'Enrollment Fee';
        }
        
        cancelOfferLetter = new List<SelectOption>();
        cancelOfferLetterValue = '';
        
        if(string.isNotBlank(SRId)){
            list<HexaBPM__Service_Request__c> tempSRList = [select id, first_name__c, last_name__c, curriculum__c, academic_year__c, Grade_Display__c, stream__c, 
                                                                   school__c, Fee_Exclusion_Reason__c,school__r.name, school__r.id__c, Service_Type__c , Name, Lead__c,
                                                                   Academic_Year__r.year__c,Conditions__c,Emirates_ID__c,school__r.country__c,
                                                                   Sibling_Name__c, Sibling_Fee_ID__c, Siblings_studying_in_a_GEMS_school__c,
                                                                   date_Of_birth__c,  First_Name_Father__c, Last_Name_Father__c,
                                                                   Country__c,Mobile__c,Email_Father__c, Primary_Contact__c, City_Emirate_Guardian__c,
                                                                   Country_Mother__c, Email_Mother__c, First_Name_Mother__c, Last_Name_Mother__c,
                                                                   Mobile_Mother__c,City_Emirate__c,  Country_Guardian__c, Email_Guardian__c, City_Emirate_Mother__c ,
                                                                   First_Name_Guardian__c, Last_Name_Guardian__c, Mobile_Guardian__c, Accept_Offer__c,
                                                                   (select id,HexaBPM__SRPriceLine_Text__c ,name,Open_Online_Payment__c , HexaBPM__Price__c, product__c,Product__r.name,HexaBPM__Product__r.name, Status__c,Amount__c 
                                                                    from HexaBPM__SR_Price_Items1__r where (Status__c='Added' or status__c = 'Pay At School') and HexaBPM__SRPriceLine_Text__c =:pricingLine) 
                                                            from HexaBPM__Service_Request__c where id =: SRId
                                                            and HexaBPM__IsCancelled__c = false
                                                            and HexaBPM__Is_Rejected__c = false];
            
            
            system.debug('---tempSRList--'+tempSRList);
            if(tempSRList!=null && tempSRList.size()>0){
                objSR = tempSRList[0];
                if(objSR.HexaBPM__SR_Price_Items1__r!=null && objSR.HexaBPM__SR_Price_Items1__r.size()>0){
                    priceItem = new List<HexaBPM__SR_Price_Item__c>();
                    priceItem = objSR.HexaBPM__SR_Price_Items1__r;
                    totalPrice = priceItem[0].HexaBPM__Price__c;
                    
                    if(string.isNotBlank(objSR.Fee_Exclusion_Reason__c) && 
                       objSR.Fee_Exclusion_Reason__c=='Paid By Company' &&
                       priceItem[0].HexaBPM__SRPriceLine_Text__c == 'Enrollment Fee'){
                    	noPayment =true;	
                    }
                }
                else{
                    noPayment =true;
                }
                
                academicYear = GEMS_utility.getLabelFromAcademicYear(objSR.Academic_Year__r.year__c);
                
                Schema.DescribeFieldResult F = academic_year__c.curriculum__c.getDescribe();
        
                map<string,string> mapOfCurriculum = new map<string,string>();
                for(Schema.PicklistEntry obj : F.getPicklistValues()){
                    mapOfCurriculum.put(obj.getValue(),obj.getLabel());     
                }
                if(mapOfCurriculum!=null && mapOfCurriculum.size()>0){
                    curriculum = mapOfCurriculum.get(objSR.curriculum__c);
                }
                
                studentName = objSR.first_name__c + ' ' + objSR.last_name__c;
                if(objSR.Primary_Contact__c == 'Father'){
                    parentName = objSR.First_Name_Father__c + ' ' + objSR.Last_Name_Father__c;
                    parentCountry =  getLabelFromCountry(objSR.country__c); 
                    parentCity = objSR.City_Emirate__c; 
                    parentPhone = objSR.Mobile__c;  
                    parentEmail = objSR.Email_Father__c;   
                }
                else if(objSR.Primary_Contact__c == 'Mother'){
                    parentName = objSR.First_Name_Mother__c + ' ' + objSR.Last_Name_Mother__c;
                    parentCountry =  getLabelFromCountry(objSR.Country_Mother__c);  
                    parentCity = objSR.City_emirate_Mother__c;    
                    parentPhone = objSR.Mobile_Mother__c;   
                    parentEmail = objSR.Email_Mother__c;
                }
                
                else if(objSR.Primary_Contact__c == 'Guardian'){
                    parentName = objSR.First_Name_Guardian__c + ' ' + objSR.Last_Name_Guardian__c;
                    parentCountry = getLabelFromCountry(objSR.Country_Guardian__c); 
                    parentCity = objSR.City_emirate_Guardian__c;  
                    parentPhone = objSR.Mobile_Guardian__c; 
                    parentEmail = objSR.Email_Guardian__c;
                }
                
                siblingDetails = objSR.Sibling_Name__c + '-' + objSR.Sibling_Fee_ID__c;
            }
            
            cancelOfferLetter.add(new SelectOption('','--None--'));
            cancelOfferLetter.add(new SelectOption('Yes','Yes'));
            cancelOfferLetter.add(new SelectOption('No','No'));
        }
        
        BSUID = apexpages.currentPage().getParameters().get('BSUID');
        if(string.isBlank(BSUID) && objSR!=null && string.isNotBlank(objSR.school__r.ID__c)){
            BSUID = objSR.school__r.ID__c;
        }
        String RefId = apexpages.currentPage().getParameters().get('RefId');
        if(string.isBlank(RefId) && objSR!=null && string.isNotBlank(objSR.Lead__c)){
            RefId = objSR.Lead__c;
        }
        String hostVal = ApexPages.currentPage().getHeaders().get('Host');
        basicInfoPageURl = '/apex/' + GEMS_Constants.PAYMENT_PAGE +  '?BSU=' + BSUID + '&RefId=' + RefId;
    }
    
    public PageReference payNow(){
        
        String paymentRedirectPageURL = getRedirectURL();
        System.debug('paymentRedirectPageURL:'+paymentRedirectPageURL);
    
        GEMS_MiGS_Utility.SRIds = SRId; //Setting list of SR ids if in case multiple SRs are paid once
        GEMS_MiGS_Utility.retURLVal = GEMS_Utility.getReferer(); // Setting value so that once transion is complete we know where to redirect
        GEMS_MiGS_Utility.schoolCode = BSUID; //Setting school code to get apprropriate merchent details from custom metadata type
        String url = '';
        
        if(priceItem!=null && priceItem.size()>0){
	        if(priceItem[0].HexaBPM__SRPriceLine_Text__c == 'Registration Fee'){
	            url = GEMS_MiGS_Utility.getMiGSPaymentURL(string.valueOf(totalPrice),'Registration - Fee',paymentRedirectPageURL);
	        }
	        else if(priceItem[0].HexaBPM__SRPriceLine_Text__c == 'Enrollment Fee'){
	            url = GEMS_MiGS_Utility.getMiGSPaymentURL(string.valueOf(totalPrice),'Enrollment - Fee ',paymentRedirectPageURL);
	        }
        }
        PageReference pg ;
        pg = new PageReference(url);
        pg.setRedirect(true);
        system.debug('--url--'+url);
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
    
    public PageReference payLater(){
        PageReference thankyou = null;
        if(priceItem!=null && priceItem.size()>0){
            priceItem[0].Status__c  = 'Pay At School';  
            update priceItem;
        }   
        thankyou = new pagereference('/apex/gems_Thank_you');
        thankyou = new pagereference('/apex/gems_Thank_you?Id='+objSR.Id+'&BSU='+BSUID+'&FlowId='+MapParameters.get('FlowId')+'&RefId='+objSR.lead__c+'&stage=Registration');
        thankyou.setRedirect(true);
        return thankyou;
    }
    
    public void cancelEnrollment(){
        objSR.Accept_Offer__c = cancelOfferLetterValue;
        offerRejected = true;
        update objSR;
        cancelOfferLetterValue= '';
    }
    
    public void acceptOffer(){
    	offerAccepted = true;
        objSR.Accept_Offer__c = 'Yes';
        update objSR;
        cancelOfferLetterValue = '';
    }
    
    
    public static String getLabelFromCountry(string key){
        String retStr;
        Schema.DescribeFieldResult F = HexaBPM__Service_Request__c.Country__c.getDescribe();
        
        map<string,string> mapOfAY = new map<string,string>();
        for(Schema.PicklistEntry obj : F.getPicklistValues()){
            mapOfAY.put(obj.getValue(),obj.getLabel());     
        }
        
        if(string.isNotBlank(key) && mapOfAY!= null && mapOfAY.size()>0){
            retStr = mapOfAY.get(key);
        }
        return retStr;
    }
}