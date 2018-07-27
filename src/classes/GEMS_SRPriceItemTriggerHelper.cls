/*****************************************************************************************************************************
    Author      :   Swati Sehrawat 
    Date        :   7th March 2017
    Description :   Convert SR into person account.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    V1.0    27thJan2018     abu dhabi offer letter changes
    V1.1    14thFeb2018    Kim Noceda: Logic to make set the Open Online Payment to No if the Scchool WAive of checkbox is true and is a Transfer Student
    V1.2    15-02-18       made the fee name dynamic in the Offer Conditions text
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_SRPriceItemTriggerHelper {

    public static void insertPriceItemForEnrollment(list<HexaBPM__SR_Price_Item__c> priceItemList){
        list<id> srList = new list<id>();
        set<string> tempGradeList = new set<string>(); //set of grades on SR
        set<string> tempSchoolList = new set<string>();//set of school on SR
        set<string> tempStreamList = new set<string>();//set of stream on SR
        set<string> tempAYList = new set<string>();//set of Academic Year on SR
        set<string> stageSet = new set<string>();
        
        map<string, string> gradeMap = new map<string, string>();
        map<string, string> SRGrade = new map<string, string>();
        
        map<string, string> SRRecordType = new map<string, string>();
        
        string stage = '';

        for(HexaBPM__SR_Price_Item__c obj : priceItemList){
            srList.add(obj.HexaBPM__serviceRequest__c);
        }
        if(srList!=null && srList.size()>0){
            for(HexaBPM__service_Request__c obj : [select id,school__r.fee_type__c ,Offer_Fee_Conditions__c,
                                                          HexaBPM__External_Status_Name__c,HexaBPM__Record_Type_Name__c ,
                                                          Grade_Original__c, Academic_Year__c, School__c, Stream__c,GradeLookup__c 
                                                   from HexaBPM__service_Request__c where id IN : srList]){
                tempGradeList.add(obj.GradeLookup__c);
                tempSchoolList.add(obj.School__c);
                tempStreamList.add(obj.Stream__c);
                tempAYList.add(obj.Academic_Year__c);
                SRGrade.put(obj.id, obj.GradeLookup__c);
                SRRecordType.put(obj.id,obj.HexaBPM__Record_Type_Name__c);
                
                if(obj.HexaBPM__Record_Type_Name__c == 'Enrollment' && (obj.HexaBPM__External_Status_Name__c=='Draft' || obj.HexaBPM__External_Status_Name__c=='Submitted'))
                    stageSet.add('REGISTRATION');
                else if(obj.HexaBPM__Record_Type_Name__c == 'Enrollment' && obj.HexaBPM__External_Status_Name__c!='Draft' && obj.HexaBPM__External_Status_Name__c!='Submitted'){
                    stageSet.add('ENROLLMENT');
                    stageSet.add('OFFER LETTER GENERATION');
                    stageSet.add('NEW ADMISSION');
                    
                }else if(obj.HexaBPM__Record_Type_Name__c == 'Re_Enrolment'){
                    stageSet.add('RE-ENROL');
                }
                else if(obj.HexaBPM__Record_Type_Name__c == 'TC_Request')
                    stageSet.add('TC');
                else
                    stageSet.add('SR.HexaBPM__External_Status_Name__c');
            }
        }
        system.debug('---stageSet---'+stageSet);
        system.debug('---tempGradeList---'+tempGradeList);
        system.debug('---tempSchoolList---'+tempSchoolList);
        system.debug('---tempAYList---'+tempAYList);
        
        list<Amount__c> amountList = new list<Amount__c>();
        if(tempGradeList!=null && tempGradeList.size()>0 && tempSchoolList!=null && tempSchoolList.size()>0 &&
           tempAYList !=null && tempAYList.size()>0){
          
            for(Grade__c objGrade : [select id,Grade__c, Open_Online_Payment__c from grade__c where id IN : tempGradeList 
                                     and school__c IN : tempSchoolList and academic_year__c IN : tempAYList]){
                gradeMap.put(objGrade.id, objGrade.Open_Online_Payment__c);   
            }
        }
        
        
        if(tempGradeList!=null && tempGradeList.size()>0 && tempSchoolList!=null && tempSchoolList.size()>0 &&
           tempAYList !=null && tempAYList.size()>0){
            if(stageSet.contains('REGISTRATION') || stageSet.contains('ENROLLMENT') || stageSet.contains('OFFER LETTER GENERATION') ||
               stageSet.contains('NEW ADMISSION') ){
                amountList = [select id,Tution_fee_percentage__c,Tuition_Fee_Amount__c,Grade__c ,Amount__c, School__c, Stream__c,Fee_Master__c,Stage_Lookup__c,Stage_Lookup__r.HexaBPM__Code__c
                              from Amount__c where (Stage_Lookup__r.HexaBPM__Code__c IN :stageSet OR (Stage_Lookup__r.HexaBPM__Code__c ='STUDENT' AND Tution_fee_percentage__c!=0 AND Tution_fee_percentage__c!=NULL))
                              and (By_Grade__c=false or (By_Grade__c=true and Grade_lookup__c IN : tempGradeList)) and Academic_Year__c IN : tempAYList
                              and School__c IN : tempSchoolList]; //checking if record exist in amount object depending on grade, stream and fee type on SR  
            }
            else if(stageSet.contains('RE-ENROL')){
                amountList = [select id,Tution_fee_percentage__c,Tuition_Fee_Amount__c,Grade__c ,Amount__c, School__c, Stream__c,Fee_Master__c,Stage_Lookup__c,Stage_Lookup__r.HexaBPM__Code__c
                              from Amount__c where Stage_Lookup__r.HexaBPM__Code__c IN :stageSet 
                              and By_Grade__c=true and Grade_lookup__c IN : tempGradeList
                              and Stream__c IN : tempStreamList and Academic_Year__c IN : tempAYList 
                              and School__c IN : tempSchoolList]; //checking if record exist in amount object depending on grade, stream and fee type on SR
            }
        }
        
        system.debug('---gradeMap---'+gradeMap);
        system.debug('---amountList---'+amountList);
        system.debug('---SRRecordType---'+SRRecordType);
        
        if(!amountList.isEmpty() && !SRRecordType.isEmpty() ){
            for(HexaBPM__SR_Price_Item__c obj : priceItemList){
                obj.HexaBPM__Non_Reevaluate__c = true;
                obj.HexaBPM__Price__c = amountList[0].Amount__c; // if exist update the price on price item.
                obj.Amount__c = amountList[0].id;
                obj.Status__c = 'Added';
                //obj.Open_Online_Payment__c = gradeMap.get(SRGrade.get(obj.HexaBPM__serviceRequest__c));
                //V1.1
                if(obj.is_School_Transfer_Waived_Off__c == true && obj.is_Old_Transfer_Student__c == true && stageSet.contains('REGISTRATION')){
                    obj.Open_Online_Payment__c = 'No';
                } else {
                    obj.Open_Online_Payment__c = gradeMap.get(SRGrade.get(obj.HexaBPM__serviceRequest__c)); 
                }
                //END
                obj.Product__c = amountList[0].Fee_Master__c;  
                if(amountList[0].Tution_fee_percentage__c>0 && amountList[0].Stage_Lookup__r.HexaBPM__Code__c=='STUDENT') 
                    obj.HexaBPM__Price__c = amountList[0].Tuition_Fee_Amount__c; // if exist update the price on price item.
            } //for loop ends 
        } // if ends
    }
  
    public static void updateSRWithFee(list<HexaBPM__SR_Price_Item__c> priceItemList){
        list<HexaBPM__service_Request__c> srUpdated = new list<HexaBPM__service_Request__c>();
        decimal Amount = 0;
        decimal enrolAmount = 0;
        set<id>setOfSR = new set<id>();
        Map<String,String> srStatusMap = new Map<String,String>();
        set<id> setOfOnlinePaymentDisabled = new set<id>();
        set<id> setOfEnrolment = new set<id>();
        //V1.2
        Map<String,String> SRFeeTypeMap = new Map<String,String>();
        //V1.2 ends
        for(HexaBPM__SR_Price_Item__c obj : priceItemList){
            if(obj.Product__c!=null && obj.HexaBPM__Pricing_Line__c!=null){
                if(obj.HexaBPM__Price__c!=null){
                    setOfSR.add(obj.HexaBPM__ServiceRequest__c);    
                    Amount = Amount + obj.HexaBPM__Price__c;
                    SRFeeTypeMap.put(obj.HexaBPM__ServiceRequest__c,obj.Products_Name__c);
                }
                
                if(obj.HexaBPM__SRPriceLine_Text__c.contains('Enrollment')){
                    setOfEnrolment.add(obj.HexaBPM__ServiceRequest__c);
                    enrolAmount = enrolAmount + obj.HexaBPM__Price__c;
                }
                if(obj.Open_Online_Payment__c=='No'){
                    setOfOnlinePaymentDisabled.add(obj.HexaBPM__ServiceRequest__c);
                } 
            }
        }
        
        if(setOfOnlinePaymentDisabled!=null && setOfOnlinePaymentDisabled.size()>0){
            for( HexaBPM__SR_Status__c srStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'SUBMITTED'] ){
                srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
            }
        }
        string feeType = 'admission fee';
        string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Enrollment');
        for(HexaBPM__service_Request__c objSR : [select id,RecordTypeId,school__r.fee_type__c ,Offer_Fee_Conditions__c,HexaBPM__External_Status_Name__c,HexaBPM__Record_Type_Name__c ,Grade_Display__c, Academic_Year__c, School__r.City__c,School__r.country__c,School__c, Stream__c from HexaBPM__service_Request__c where id IN : setOfSR]){
             //V1.2 - feeType is added
            if(SRFeeTypeMap.containsKey(objSR.id)){ 
                feeType = SRFeeTypeMap.get(objSR.id);
            }//V1.2 ends
            string currencyType = objSR.School__r.country__c == '97' ? 'QAR' : 'AED';
            //V1.2 - feeType is added
            string schoolCity = objSR.School__r.City__c == '157' ? ' tuition fee of ' : ' '+feeType+' of ';
            if(amount>0){
                if(recTypeID == objSR.recordTypeId && objSR.HexaBPM__External_Status_Name__c!='Draft' && objSR.HexaBPM__External_Status_Name__c!='Submitted' &&
                    setOfEnrolment.contains(objSR.id)){
                    if(objSR.School__r.City__c == '157'){ //V1.0
                        objSR.Offer_Fee_Conditions__c = 'Please note, a non-refundable deposit of 5% tuition fees totaling ' + 
                                                         currencyType+ ' ' + enrolAmount +'  is required upon acceptance of the offer.'+
                                                         ' This is adjustable from the first term fees and follows the ADEC policy for schools.';   
                    }else{
                        objSR.Offer_Fee_Conditions__c = 'You will also be required to pay the ' + objSR.school__r.fee_type__c + schoolCity + 
                                                         enrolAmount+ ' ' + currencyType +' at the time of acceptance.';            
                    }
                   
                }
                objSR.payment_status__c = 'Payment Pending';
            }
            else{
                objSR.payment_status__c = 'No Payment';
            }
            if(srStatusMap!=null && objSR.HexaBPM__External_Status_Name__c=='Draft' && ((setOfOnlinePaymentDisabled!=null && setOfOnlinePaymentDisabled.contains(objSR.id)) || (objSR.payment_status__c == 'No Payment'))) {
                objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('SUBMITTED');
                objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('SUBMITTED');
                objSR.HexaBPM__Submitted_Date__c = system.today();
                objSR.HexaBPM__Submitted_DateTime__c = system.now();    
                objSR.HexaBPM__finalizeamendmentflg__c = true;
                objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
            }
            srUpdated.add(objSR);   
        }
        
        if(srUpdated!=null && srUpdated.size()>0){
            update srUpdated;   
        }
    }
}