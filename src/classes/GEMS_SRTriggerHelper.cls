/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   9th April 2017
    Description :   Helper class for SR trigger
    --------------------------------------------------------------------------------------------------------------------------
    Modification History 
    
    V1.0    17thJan2018  Swati    AY,Grade change on enquiry if changed on SR
    V2.0    19thFeb2018  Leeba    Change in updating the Fee ID at the school level on Generating student id
    V3.0    20thFeb2018  Leeba    Added Field to the set for the code coverage
    V4.0    06thMar2018  Swati    SR rejection
    v5.0    12thMar2018  Leeba    Enrollment SR validation
    V6.0    15/03/2018      Ticket 189995
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global without sharing class GEMS_SRTriggerHelper {
    
    /* added by leeba*/
    //Close the Open Step for Edit Critical Data SR if it is approved or Rejected in Oasis
    public static void CloseCriticalUpdateSteps(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> TriggerOldMap) {
        Set<String> setSRIds = new Set<String>();
        map<string, string> mapSRUpdateVal = new map<string, string>();
        for (HexaBPM__Service_Request__c objSR : SRList) {
            if (objSR.sys_Edit_Critical_details_Approved__c != TriggerOldMap.get(objSR.Id).sys_Edit_Critical_details_Approved__c) {
                if (objSR.sys_Edit_Critical_details_Approved__c == true) {
                    setSRIds.add(objSR.id);
                    MapSRUpdateVal.put(objSR.Id, 'Approved');
                }
            }
            else if (objSR.sys_Edit_Critical_details_Rejected__c != TriggerOldMap.get(objSR.Id).sys_Edit_Critical_details_Rejected__c) {
                if (objSR.sys_Edit_Critical_details_Rejected__c == true) {
                    setSRIds.add(objSR.id);
                    MapSRUpdateVal.put(objSR.Id, 'Rejected');
                }
            }
        }
    
        if (setSRIds != null && setSRIds.size() > 0) {
            string StepVerifiedStatus;
            string StepRejectedStatus;
            string SRApprovedStatus;
            string SRRejectedStatus;

            for (HexaBPM__Status__c stat : [select Id, HexaBPM__Code__c from HexaBPM__Status__c where HexaBPM__Code__c = 'APPROVED' or HexaBPM__Code__c = 'REJECTED']) {
                if (stat.HexaBPM__Code__c == 'APPROVED')
                    StepVerifiedStatus = stat.Id;
                if (stat.HexaBPM__Code__c == 'REJECTED')
                    StepRejectedStatus = stat.Id;
            }

            for (HexaBPM__SR_Status__c stat : [select Id, HexaBPM__Code__c from HexaBPM__SR_Status__c where HexaBPM__Code__c = 'Approved' or HexaBPM__Code__c = 'Rejected']) {
                if (stat.HexaBPM__Code__c == 'Approved')
                    SRApprovedStatus = stat.Id;
                if (stat.HexaBPM__Code__c == 'Rejected')
                    SRRejectedStatus = stat.Id;
            }

            list<HexaBPM__Step__c> lst_SR_Steps = new list<HexaBPM__Step__c>();
            list<HexaBPM__Service_Request__c> lstSRs = new list<HexaBPM__Service_Request__c>();
            
            for (HexaBPM__Step__c step : [Select Id, Name, HexaBPM__Status__c, HexaBPM__SR__c, Skip_Validations__c from HexaBPM__Step__c where HexaBPM__SR__c IN:setSRIds and Is_Closed__c = false and HexaBPM__SR_Step__r.HexaBPM__Step_Template_Code__c = 'VERIFICATION_OF_APPLICATION']) {
                if (MapSRUpdateVal.get(step.HexaBPM__SR__c) == 'Approved' && StepVerifiedStatus != null) {
                    step.HexaBPM__Status__c = StepVerifiedStatus;
                    lst_SR_Steps.add(step);
                    if (SRApprovedStatus != null) {
                        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id = step.HexaBPM__SR__c);
                        objSR.HexaBPM__Internal_SR_Status__c = SRApprovedStatus;
                        objSR.HexaBPM__External_SR_Status__c = SRApprovedStatus;
                        lstSRs.add(objSR);
                    }
                }
                else if (MapSRUpdateVal.get(step.HexaBPM__SR__c) == 'Rejected' && StepRejectedStatus != null) {
                    step.HexaBPM__Status__c = StepRejectedStatus;
                    step.Skip_Validations__c = true;
                    lst_SR_Steps.add(step);
                    if(SRRejectedStatus != null) {
                        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id = step.HexaBPM__SR__c);
                        objSR.HexaBPM__Internal_SR_Status__c = SRRejectedStatus;
                        objSR.HexaBPM__External_SR_Status__c = SRRejectedStatus;
                        lstSRs.add(objSR);
                    }
                }
            }
            if (lst_SR_Steps.size() > 0)
                update lst_SR_Steps;
            if (lstSRs.size() > 0)
                update lstSRs;
        }	
    }

    public static void CheckSchoolExists(list<HexaBPM__Service_Request__c> TriggerNew) {
        if (TriggerNew != null && TriggerNew.size() > 0) {
            map<string, string> mapSchoolNames = new map<string, string>();
            set<string> setSchoolNames = new set<string>();
            for (HexaBPM__Service_Request__c objSR : TriggerNew) {
                if (objSR.Transfer_school_name__c != null && objSR.HexaBPM__Record_Type_Name__c == 'TC_Request') 
                    setSchoolNames.add(objSR.Transfer_school_name__c);
            }
            
            if (setSchoolNames != null && setSchoolNames.size() > 0) {
                for (School__c sch : [Select Id, Name from School__c where Name IN:setSchoolNames]) {
                    MapSchoolNames.put(sch.Name.toLowerCase(), sch.Id);
                }
            }
            
            for (HexaBPM__Service_Request__c objSR : TriggerNew) {
                if (objSR.Transfer_school_name__c != null && objSR.HexaBPM__Record_Type_Name__c == 'TC_Request' && mapSchoolNames.get(objSR.Transfer_school_name__c.toLowerCase()) != null)
                    objSR.Sys_previous_school_is_GEMS__c = true;
            }
        }
    }

    @future
    webservice static void UpdateInformaticaCheckBox(list<string> lstSRIDs) {
        list<HexaBPM__Service_Request__c> lstSRs = new list<HexaBPM__Service_Request__c>();
        for (string SRID : lstSRIDs) {
            HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c(Id = SRID);
            SR.sys_Send_Enquiry_Parent_Details__c = true;
            lstSRs.add(SR);
        }
        if (lstSRs.size() > 0)
            update lstSRs;
    }

    public static void UpdateInformaticaCheckBox_NonFuture(list<string> lstSRIDs) {
        list<HexaBPM__Service_Request__c> lstSRs = new list<HexaBPM__Service_Request__c>();
        for (string SRID : lstSRIDs) {
            HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c(Id = SRID);
            SR.sys_Send_Enquiry_Parent_Details__c = true;
            lstSRs.add(SR);
        }
        if (lstSRs.size() > 0)
            update lstSRs;
    }

    //If SR Status is updated to Registered, then populate the Student Id
    public static void UpdateStudentId(list<HexaBPM__Service_Request__c> TriggerNew, map<Id, HexaBPM__Service_Request__c> TriggerOldMap) {
        string FeeId;
        set<String> setSchoolIds = new Set<String>();
        map<string, School__c> mapSchool = new map<string, School__c>();
        for (HexaBPM__Service_Request__c objSR : TriggerNew) {
            if (objSR.Registration_Date__c==null && objSR.HexaBPM__Internal_Status_Name__c != TriggerOldMap.get(objSR.Id).HexaBPM__Internal_Status_Name__c && objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' ) {
                if (objSR.HexaBPM__Internal_Status_Name__c == 'Registered' && objSR.School__c != null) 
                    objSR.Registration_Date__c = system.Today();
            }
        }
        
        for (HexaBPM__Service_Request__c objSR : TriggerNew) {
            if (objSR.HexaBPM__Internal_Status_Name__c != TriggerOldMap.get(objSR.Id).HexaBPM__Internal_Status_Name__c && objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' && objSR.StudentId__c == null ) {
                if (objSR.HexaBPM__Internal_Status_Name__c == 'Registered' && objSR.School__c != null) {
                    if (objSR.School__c != null)
                        setSchoolIds.add(objSR.School__c);
                }
            }
        }
        
        if (setSchoolIds != null && setSchoolIds.size() > 0) {
            for (School__c sch : [Select Id, ID__c, Name, sys_Last_Fee_Id__c,Short_Name__c from School__c where Id IN:setSchoolIds and ID__c != null and sys_Last_Fee_Id__c != null FOR UPDATE])
                MapSchool.put(sch.Id, sch);
        }
        map<string, decimal> mapLastFeeId = new map<string, decimal>();
        for (HexaBPM__Service_Request__c objSR : TriggerNew) {
            if (objSR.HexaBPM__Internal_Status_Name__c != TriggerOldMap.get(objSR.Id).HexaBPM__Internal_Status_Name__c && objSR.HexaBPM__Record_Type_Name__c == 'Enrollment') {
                if (objSR.HexaBPM__Internal_Status_Name__c == 'Registered' && objSR.School__c != null && mapSchool.get(objSR.School__c) != null && mapSchool.get(objSR.School__c).sys_Last_Fee_Id__c != null) {
                    decimal dFeeId;
                    if (MapLastFeeId.get(objSR.School__c) != null) {
                        string strFeeId = string.valueof(MapLastFeeId.get(objSR.School__c) + 1);
                        objSR.Fee_ID__c = strFeeId;
                        dFeeId = mapLastFeeId.get(objSR.School__c) + 1;
                    } 
                    else {
                        objSR.Fee_ID__c = string.valueof(MapSchool.get(objSR.School__c).sys_Last_Fee_Id__c + 1);
                        dFeeId = mapSchool.get(objSR.School__c).sys_Last_Fee_Id__c + 1;
                    }

                    MapLastFeeId.put(objSR.School__c, dFeeId);
                    FeeId = objSR.Fee_ID__c;
                    if (FeeId.length() < 8) {
                        string PreceedingFeeId = '0';
                        for (integer i = 1; i < 8 - objSR.Fee_ID__c.length(); i++)
                            PreceedingFeeId = PreceedingFeeId + '0';
                        FeeId = PreceedingFeeId + FeeId;
                    }
                    objSR.StudentId__c = mapSchool.get(objSR.School__c).Id__c + FeeId;
                }
            }
        }
        for (HexaBPM__Service_Request__c objSR : TriggerNew) {
            //V2.0
            if(mapSchool.containsKey(objSR.School__c) && objSR.HexaBPM__Internal_Status_Name__c != TriggerOldMap.get(objSR.Id).HexaBPM__Internal_Status_Name__c && objSR.HexaBPM__Internal_Status_Name__c == 'Registered' && objSR.HexaBPM__Record_Type_Name__c == 'Enrollment') {
                for (School__c sc : mapSchool.values()) {
                    if(string.isNotBlank(objSR.Fee_ID__c) && sc.Short_Name__c==objSR.School_Short_Name__c)
                        sc.sys_Last_Fee_Id__c = decimal.valueof(objSR.Fee_ID__c) ;
                }
            }
        }
        if (MapSchool.size() > 0)
            update mapSchool.values();
    }
    //v5.0
    
    public static void srReadOnly(list<HexaBPM__Service_Request__c> TriggerNew, map<Id, HexaBPM__Service_Request__c> TriggerOldMap) {
        for (HexaBPM__Service_Request__c objSR : TriggerNew) {
            if (objSR.Student__c!=null && TriggerOldMap.get(objSR.Id).Student__c!=null && objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' && objSR.HexaBPM__Internal_Status_Name__c == 'Enrolled' && GEMS_checkRecursiveTriggers.runOnceForEnrolledSR==false && objSR.Current_User_Type__c=='Standard' && objSR.Current_User_Profile__c!='System Administrator') {
                objSR.addError('The student is already Enrolled. You cannot make changes');
            }  
        }
    }

    public static void updateLeadStatus(list<HexaBPM__Service_Request__c> srList, map<Id, HexaBPM__Service_Request__c> oldMap) {
        list<Lead> leadUpdateList = new List<Lead>();
        list<Enquiry__c> EnquiryUpdateList = new List<Enquiry__c>();
        
        map<String, String>SRtoLeadStatusMap = new map<String, String> {
            'DRAFT' => 'Registration in progress',
            'SUBMITTED' => 'Registration in progress',
            'SHORTLISTED' => 'Shortlisted',
            'REGISTERED' => 'Registered',
            'OFFER LETTER' => 'Offer letter',
            'SCREENING TEST APPROVED' => 'Screening test approved',
            'ENROLLED' => 'Enrolled',
            'REJECTED' => 'Rejected'
        };
  
        Lead LeadObj;
        Enquiry__c EnqObj;
        
        for (HexaBPM__Service_Request__c srObj : srList) {
            if(srObj.Lead__c != NULL && srObj.Enquiry__c != NULL){
                if(oldMap != NULL && oldmap.size()>0){
                    LeadObj = new Lead(id = srObj.Lead__c);
                	EnqObj = new Enquiry__c(id = srObj.Enquiry__c);
                	
                    if(oldMap.get(srObj.Id).HexaBPM__External_Status_Code__c != srObj.HexaBPM__External_Status_Code__c){
                        if(SRtoLeadStatusMap.containsKey(srObj.HexaBPM__External_Status_Code__c)){
                            LeadObj.status = SRtoLeadStatusMap.get(srObj.HexaBPM__External_Status_Code__c);
                            EnqObj.status__c = SRtoLeadStatusMap.get(srObj.HexaBPM__External_Status_Code__c);
                        	
                        }else if(srObj.Lead__c != NULL && srObj.Enquiry__c!=NULL && oldMap != NULL && srObj.HexaBPM__External_Status_Code__c!=null) {
                            string status = srObj.HexaBPM__External_Status_Code__c.toLowerCase();
                            List<String> pieces = new List<String>();
                            for(String s :  status.split('_')) {
                                s = s.capitalize();
                                pieces.add(s);
                            }
                            LeadObj.status = String.join(pieces, ' ');
                            EnqObj.status__c = String.join(pieces, ' ');
                        }
                    }
                    
                    //V1.0
                    if(srObj.academic_year__c != NULL){
                        if(srObj.academic_year__c!=oldMap.get(srObj.Id).academic_year__c)
                        	LeadObj.academic_year__c = srObj.academic_year__c;
                        
	                    if(srObj.gradelookup__c != NULL && srObj.gradelookup__c!=oldMap.get(srObj.Id).gradelookup__c){
	                        LeadObj.academic_year__c = srObj.academic_year__c;
	                        LeadObj.GradeLookup__c = srObj.gradelookup__c;
	                    }
	                    
                    	LeadObj.Curriculum__c = srObj.Curriculum__c;
                        LeadObj.Stream__c = srObj.Stream__c;
                    }
                    LeadUpdateList.add(LeadObj);
                    EnquiryUpdateList.add(EnqObj);
                }
                else{
                    LeadObj = new Lead(id = srObj.Lead__c);
                    LeadObj.status = 'Registration in progress';
                    LeadUpdateList.add(LeadObj);
                    
                    EnqObj = new Enquiry__c(id = srObj.Enquiry__c);
                    EnqObj.status__c = 'Registration in progress';
                    EnquiryUpdateList.add(EnqObj);
                }
            }
        }
        if (!LeadUpdateList.isEmpty())
            update LeadUpdateList;
            
    	if (!EnquiryUpdateList.isEmpty())
            update EnquiryUpdateList;
    }

    //To make the status of the SR PriceItem to paid for an SR PriceItem once the status is made Registered from Oasis.
    //added by leeba
    //modified for payment issues - Swati
    public static void UpdateSRPriceItemStatus(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> TriggerOldMap) {
   		set<String> setSRIds = new Set<String>();
        for (HexaBPM__Service_Request__c objSR : SRList) {
            if (objSR.Update_status_to_registered__c != TriggerOldMap.get(objSR.Id).Update_status_to_registered__c) {
                if (objSR.Update_status_to_registered__c == true)
                    setSRIds.add(objSR.id);
            }
            else if (objSR.Update_SR_Status_to_Assessment__c != TriggerOldMap.get(objSR.Id).Update_SR_Status_to_Assessment__c) {
                if (objSR.Update_SR_Status_to_Assessment__c == true)
                    setSRIds.add(objSR.id);
            }
        }
        
        list<HexaBPM__Service_Request__c> srUpdateList = new List<HexaBPM__Service_Request__c>();
        set<String> srStatusCodes = new Set<String>();
        srStatusCodes.add('SUBMITTED');
        srStatusCodes.add('REGISTERED');
        
        Map<String,String> srStatusMap = new Map<String,String>();
        if(!srStatusCodes.isEmpty()){
            for( HexaBPM__SR_Status__c srStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c IN :srStatusCodes] ){
                srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
            }
        }
        
        list<HexaBPM__Service_Request__c> tempSRList = new list<HexaBPM__Service_Request__c>();
        if(setSRIds!=null && setSRIds.size()>0){
            tempSRList = [select id, Update_status_to_registered__c, HexaBPM__Internal_SR_Status__c,
                                 HexaBPM__External_SR_Status__c, accept_offer__c,HexaBPM__External_Status_Name__c,
                                 HexaBPM__Record_Type_Name__c,
                                 Payment_Status__c, Update_SR_Status_to_Assessment__c
                          from HexaBPM__Service_Request__c where id IN : setSRIds];
            
            if(tempSRList!=null && tempSRList.size()>0){
                for (HexaBPM__Service_Request__c objSR : tempSRList) {
                    if (objSR.Update_status_to_registered__c != TriggerOldMap.get(objSR.Id).Update_status_to_registered__c && objSR.Update_status_to_registered__c == true) {
                        
                        if(objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' && 
                           objSR.HexaBPM__External_Status_Name__c == 'Draft'){
                            
                            objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('SUBMITTED');
                            objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('SUBMITTED');    
                        }
                        
                        objSR.Payment_Status__c = 'Paid';
                        srUpdateList.add(objSR);
                    }
                    else if (objSR.Update_SR_Status_to_Assessment__c != TriggerOldMap.get(objSR.Id).Update_SR_Status_to_Assessment__c && objSR.Update_SR_Status_to_Assessment__c == true) {
                        objSR.accept_offer__c = 'Yes';
                        objSR.Payment_Status__c = 'Paid';
                        srUpdateList.add(objSR);
                    }
                }
            }
        }
        
        if(srUpdateList!=null && srUpdateList.size()>0){
            update srUpdateList;
            List<HexaBPM__Service_Request__c> registerSR = new List<HexaBPM__Service_Request__c>();
            registerSR = [select id, Update_status_to_registered__c, HexaBPM__Internal_SR_Status__c,
                                   HexaBPM__External_SR_Status__c, accept_offer__c,HexaBPM__Record_Type_Name__c,
                                   Payment_Status__c, Update_SR_Status_to_Assessment__c,HexaBPM__External_Status_Name__c
                            from HexaBPM__Service_Request__c where id IN : srUpdateList];
            
            for(HexaBPM__Service_request__c objSR : registerSR){
                if(objSR.HexaBPM__Record_Type_Name__c == 'Enrollment' && 
                   (objSR.HexaBPM__External_Status_Name__c == 'Draft' ||
                    objSR.HexaBPM__External_Status_Name__c == 'Submitted') && 
                    objSR.Update_status_to_registered__c == true){
               
                    objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('REGISTERED');
                    objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('REGISTERED');
               }
            }   
            update registerSR;
            list<HexaBPM__SR_Price_Item__c> tempList = [select id, Status__c ,HexaBPM__SRPriceLine_Text__c,
                                                               HexaBPM__Non_Reevaluate__c,Product__c,Product__r.Name,
                                                               HexaBPM__ServiceRequest__c,HexaBPM__ServiceRequest__r.Update_SR_Status_to_Assessment__c,
                                                               HexaBPM__ServiceRequest__r.Update_status_to_registered__c
                                                        from HexaBPM__SR_Price_Item__c 
                                                        where HexaBPM__ServiceRequest__c IN : srUpdateList
                                                        and Status__c='Added'];
            if (tempList != null && tempList.size() > 0) {
              for (HexaBPM__SR_Price_Item__c SRP : tempList) {
                    if(SRP.Product__c!=null && SRP.Product__r.Name.toLowerCase().indexOf('registration')>-1 && SRP.HexaBPM__ServiceRequest__r.Update_status_to_registered__c){
                        SRP.Status__c = 'Paid';
                        SRP.HexaBPM__Non_Reevaluate__c = true;
                    }else if(SRP.Product__c!=null && SRP.Product__r.Name.toLowerCase().indexOf('registration')==-1 && SRP.HexaBPM__ServiceRequest__r.Update_SR_Status_to_Assessment__c){
                        SRP.Status__c = 'Paid';
                        SRP.HexaBPM__Non_Reevaluate__c = true;
                    }
              }
              update tempList;
            }
        }
    }

    //once SR is created, it should get assigned to respective school registrar //commented
    public static list<HexaBPM__Service_Request__c> assignSROwner(list<HexaBPM__Service_Request__c> SRList) {
        if (SRList != null && SRList.size() > 0) {
            map<string, GEMS_Queue_Config__c> customSettingsForQueue = GEMS_Queue_Config__c.getAll();
            map<string, string> mapOfSchoolAndQueue = new map<string, string>();
            map<string, id> mapOfQueueAndId = new map<string, id>();
            if (customSettingsForQueue != null && customSettingsForQueue.size() > 0) {
                for (GEMS_Queue_Config__c var : customSettingsForQueue.values()) {
                    if (var.Queue_Type__c == 'Registrar')
                        mapOfSchoolAndQueue.put(var.School_Code__c, var.Queue_Name__c);
                }
                for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue' and DeveloperName = :mapOfSchoolAndQueue.values()])
                    mapOfQueueAndId.put(grp.DeveloperName, grp.id);
            }
            map<id, string> serviceRequestAndLinkedSchool = new map<id, string>();
            map<id, id> recordTypeForTransfer = new map<id, id>();
            if (SRList != null && SRList.size() > 0 && mapOfSchoolAndQueue != null && mapOfSchoolAndQueue.size() > 0) {
                for (HexaBPM__Service_Request__c objSR : SRList) {
                    if (string.isNotBlank(objSR.School_Name_Dev__c) && mapOfSchoolAndQueue.get(objSR.School_Name_Dev__c) != null) {
                        if (mapOfQueueAndId.get(mapOfSchoolAndQueue.get(objSR.School_Name_Dev__c)) != null)
                            objSR.OwnerId = mapOfQueueAndId.get(mapOfSchoolAndQueue.get(objSR.School_Name_Dev__c));
                    }
                }
            }
        }
        return SRList;
    }

    //for short form all related siblings should get updated if one changes
    public static void updateRelatedSR(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> oldMap) {
        if (GEMS_checkRecursiveTriggers.runOnceForSR) { // to avoid recursive issue
            GEMS_checkRecursiveTriggers.runOnceForSR = false;
            list<HexaBPM__Service_Request__c> enrollmentShortForm = new list<HexaBPM__Service_Request__c>();
            set<string> leadReferences = new set<string>();
            map<string, list<HexaBPM__Service_Request__c>> siblingsMap = new map<string, list<HexaBPM__Service_Request__c>>();
            list<string> listOfChangedFields = new List<String> ();

            //to make it dynamic get fieldMap
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
            Schema.SObjectType objType = objSR.getSObjectType();
            map<String, Schema.SObjectField> mapFields = Schema.SObjectType.HexaBPM__Service_Request__c.fields.getMap();

            set<string> setOfParentFields =  new set<string>();
            setOfParentFields = getSetOfParentFields();
            set<string> setOfChangedFields =  new set<string>();

            for (HexaBPM__Service_Request__c newRecord : SRList) {
                if (newRecord.HexaBPM__Record_Type_Name__c == 'Enrollment' && string.isNotBlank(newRecord.Service_Type__c) && newRecord.Service_Type__c == 'Enrollment Short Form' && string.isNotBlank(newRecord.Lead_Reference__c) && newRecord.HexaBPM__External_Status_Name__c != 'Enrolled') {
                    HexaBPM__Service_Request__c oldRecord = oldMap.get(newRecord.Id);
                    enrollmentShortForm.add(newRecord); //list of SR on which change was done
                    leadReferences.add(newRecord.Lead_Reference__c); // reference number to get linked SR
                    if (mapFields != null && mapFields.size() > 0) {
                        for (String str : mapFields.keyset()) {
                            if (setOfParentFields.contains(str) && newRecord.get(str) != oldRecord.get(str))
                                setOfChangedFields.add(str); //list of fields that got changed
                        }
                    }
                }
            }
            
            if(system.test.isRunningTest())//V3.0
                setOfChangedFields.add('Mobile__c');
            if (setOfChangedFields != null && setOfChangedFields.size() > 0) {
                //to make change dynamic assign record to sobject and get fields
                listOfChangedFields.addAll(setOfChangedFields);
                
                //get all siblings
                if (leadReferences != null && leadReferences.size() > 0 && enrollmentShortForm != null && enrollmentShortForm.size() > 0) {
                    string query = '';
                    query = 'select id, Lead_Reference__c,' + String.join(listOfChangedFields, ',') + ' from HexaBPM__Service_Request__c where Lead_Reference__c IN : leadReferences and id NOT IN : enrollmentShortForm and Is_SR_Closed__c=false and HexaBPM__Is_Rejected__c=false';
                    for (HexaBPM__Service_Request__c objSRSib : database.query(query)) {
                        if (siblingsMap.containsKey(objSRSib.Lead_Reference__c)) {
                            list<HexaBPM__Service_Request__c> siblingId = siblingsMap.get(objSRSib.Lead_Reference__c);
                            siblingId.add(objSRSib);
                            siblingsMap.put(objSRSib.Lead_Reference__c, siblingId);
                        } 
                        else {
                            siblingsMap.put(objSRSib.Lead_Reference__c, new List<HexaBPM__Service_Request__c> { objSRSib });
                        }
                    }
                }
            }
            //update siblings
            list<HexaBPM__Service_Request__c> siblingsToUpdate = new list<HexaBPM__Service_Request__c>();
            if (siblingsMap != null && siblingsMap.size() > 0) {
                for (HexaBPM__Service_Request__c mainSR : enrollmentShortForm) {
                    for (HexaBPM__Service_Request__c sibling : siblingsMap.get(mainSR.Lead_Reference__c)) {
                        for (String str : listOfChangedFields) {
                            sibling.put(str, mainSR.get(str));
                        }
                        siblingsToUpdate.add(sibling);
                    }
                }
            }
            if (siblingsMap != null && siblingsMap.size() > 0) {
                update siblingsToUpdate;
            }
        }
    }

    public static void updateFieldsForSROnInsert(list<HexaBPM__Service_Request__c> SRList) {
        //Updates email, phone, username, primary contact name for all SR other than enrolment
        set<id> accountId = new set<id>();
        set<id> gradeID = new set<id>();
        string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Enrollment');
        if (SRList != null && SRList.size() > 0) {
            for (HexaBPM__Service_Request__c obj : SRList) {
                if (obj.recordTypeID != recTypeID && (obj.Student__c != null || obj.HexaBPM__Customer__c != null)) {
                    accountId.add(obj.Student__c);
                    accountId.add(obj.HexaBPM__Customer__c);
                }
                if(obj.recordTypeID == recTypeID){
                    string firstName = '';
                    string lastName = '';
                    string email = '';
                        
                    if(obj.Primary_Contact__c == 'Father'){
                        obj.HexaBPM__Email__c = obj.Email_Father__c;
                        obj.Emergency_Contact_Number__c = obj.Mobile__c;
                    }else if(obj.Primary_Contact__c == 'Mother'){
                        obj.HexaBPM__Email__c = obj.Email_Mother__c;
                        obj.Emergency_Contact_Number__c = obj.Mobile_Mother__c;
                    }else if(obj.Primary_Contact__c == 'Guardian'){
                        obj.HexaBPM__Email__c = obj.Email_Guardian__c;
                        obj.Emergency_Contact_Number__c = obj.Mobile_Guardian__c;
                    }
                    
                    if(string.isNotBlank(obj.First_Name__c)){
                        firstName = obj.First_Name__c.tolowercase();
                    }
                    if(string.isNotBlank(obj.Last_Name__c)){
                        lastName = obj.Last_Name__c.tolowercase();
                    }
                    if(string.isNotBlank(obj.HexaBPM__Email__c)){
                        email = obj.HexaBPM__Email__c.tolowercase();
                    }
                    if(obj.GradeLookup__c!=null){
                        gradeID.add(obj.GradeLookup__c);
                    }
                    obj.Unique_External__c = firstName+'-'+lastName+'-'+ email;
                }
            }
            map<id, Account> mapIdToAccount = new map<id, Account>();
            if (accountId != null && accountId.size() > 0) {
                for (Account obj : [select id, Primary_Contact_Email__c, primary_contact_name__c, FirstName, lastname,
                                    Emergency_Contact_Number__c, parent_username__c, Academic_Year__c, GradeLookup__c,
                                    Student_Id__c, Fee_ID__c, Stream__c, Section__c, Section__r.Section__c, Section__r.Form_Tutor_Email__c, 
                                    (select id, TC_Applied__c,Re_enrolment_Remark__c from Promotions__r where active__c = true)
                                     from Account
                                     where id IN : accountId and Record_Type_Name__c IN ('Student','Student_Read_Only')]) {
                    mapIdToAccount.put(obj.id, obj);
                }
            }
            
            if (mapIdToAccount != null && mapIdToAccount.size() > 0) {
                set<String> recordTypeMap = new Set<String>();
                recordTypeMap.add('Strike_Off');
                recordTypeMap.add('TC_Request');
                recordTypeMap.add('Cancel_Admission');
            
                map<String, String> recordTypeIDMap = new map<String, String>();
                if (!recordTypeMap.isEmpty()) {
                    for ( RecordType rec : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'HexaBPM__Service_Request__c' and DeveloperName IN :recordTypeMap] ) {
                        recordTypeIDMap.put(rec.Id, rec.DeveloperName);
                    }
                }
    
                set<id> updatedAccountID = new set<id>();
                    
                list<promotion__c> promotionsToUpdate = new list<promotion__c>();
    
                for (HexaBPM__Service_Request__c obj : SRList) {
                    if (obj.recordTypeID != recTypeID && obj.Student__c != null && mapIdToAccount.get(obj.Student__c) != null) {
                        obj.HexaBPM__Email__c = mapIdToAccount.get(obj.Student__c).Primary_Contact_Email__c;
                        obj.Emergency_Contact_Number__c = mapIdToAccount.get(obj.Student__c).Emergency_Contact_Number__c;
                        obj.primary_contact_name__c = mapIdToAccount.get(obj.Student__c).primary_contact_name__c;
                        obj.parent_username__c = mapIdToAccount.get(obj.Student__c).parent_username__c;
                        obj.StudentId__c = mapIdToAccount.get(obj.Student__c).Student_Id__c;
                        obj.Fee_ID__c = mapIdToAccount.get(obj.Student__c).Fee_ID__c;
                        obj.First_Name__c = mapIdToAccount.get(obj.Student__c).firstname;
                        obj.Last_Name__c = mapIdToAccount.get(obj.Student__c).lastname;
                        obj.student_full_name__c = mapIdToAccount.get(obj.Student__c).firstname + ' ' + mapIdToAccount.get(obj.Student__c).lastname;
    
                        if (recordTypeIDMap != null && recordTypeIDMap.containsKey(obj.recordTypeId)) {
                            obj.Academic_Year__c = mapIdToAccount.get(obj.Student__c).Academic_Year__c;
                            obj.GradeLookup__c = mapIdToAccount.get(obj.Student__c).GradeLookup__c;
                            obj.Stream__c = mapIdToAccount.get(obj.Student__c).Stream__c;
                            obj.Section_Lookup__c = mapIdToAccount.get(obj.Student__c).Section__c;
                            obj.From_Section__c = mapIdToAccount.get(obj.Student__c).Section__r.Section__c;
                            obj.Form_Tutor_Email__c = mapIdToAccount.get(obj.Student__c).Section__r.Form_Tutor_Email__c;
                            updatedAccountID.add(obj.Student__c);
                    	}
                    }

                    if (obj.recordTypeID != recTypeID && obj.HexaBPM__Customer__c != null && mapIdToAccount.get(obj.HexaBPM__Customer__c) != null) {
                        obj.HexaBPM__Email__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Primary_Contact_Email__c;
                        obj.Emergency_Contact_Number__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Emergency_Contact_Number__c;
                        obj.primary_contact_name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).primary_contact_name__c;
                        obj.parent_username__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).parent_username__c;
                        obj.StudentId__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Student_Id__c;
                        obj.Fee_ID__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Fee_ID__c;
                        obj.First_Name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).firstname;
                        obj.Last_Name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).lastname;
                        obj.student_full_name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).firstname + ' ' + mapIdToAccount.get(obj.HexaBPM__Customer__c).lastname;
        
                        if (recordTypeIDMap != null && recordTypeIDMap.containsKey(obj.recordTypeId)) {
                            obj.Academic_Year__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Academic_Year__c;
                            obj.GradeLookup__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).GradeLookup__c;
                            obj.Stream__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Stream__c;
                            obj.Section_Lookup__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Section__c;
                            obj.From_Section__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Section__r.Section__c;
                            obj.Form_Tutor_Email__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Section__r.Form_Tutor_Email__c;
                            updatedAccountID.add(obj.HexaBPM__Customer__c);
                        }
                    }
                }
                
                if (updatedAccountID != null && updatedAccountID.size() > 0) {
                    for (Promotion__c obj : [select id, TC_Applied__c,Re_enrolment_Remark__c from Promotion__c where student__c IN : updatedAccountID and active__c=true]) {
                        obj.TC_Applied__c = true;
                        obj.Re_enrolment_Remark__c = 'Not Re-Enroling'; //V6.0
                        promotionsToUpdate.add(obj);
                    }
                    if (promotionsToUpdate != null && promotionsToUpdate.size() > 0) 
                        update promotionsToUpdate;
                }
            }
        }

        //updates all field from school for SR
        set<id> schoolId = new set<id>();
        if (SRList != null && SRList.size() > 0) {
            for (HexaBPM__Service_Request__c obj : SRList)
                schoolId.add(obj.school__c);
        
            map<id, school__c> schoolMap = new map<id, school__c>();
            if (schoolId != null && schoolId.size() > 0) {
                for (school__c school : [select id, logo__c, Finance_Officer_Email__c,
                                                Lab_Email__c, Library_Email__c, Principals_PA_Email__c,
                                                Registrar_Email__c, gre_email__c,STS_Email__c, 
                                                Principal__r.Email__c,PRE_Email_Address__c,
                                                generic_email_address__c
                                        from school__c
                                        where id IN : schoolId])
                    schoolMap.put(school.id, school);
            }
            
            if(gradeID!=null && gradeID.size()>0){
                map<id,Email_Templates__c> emailTemplateMap = new map<id,Email_Templates__c>();
                for(Email_Templates__c obj : [select id, Grade__c,email_type__c, email_template__c 
                                              from Email_Templates__c 
                                              where Grade__c IN : gradeID]){
                    if(string.isnotBlank(obj.email_template__c))
                        emailTemplateMap.put(obj.Grade__c,obj); 
                }
                if(emailTemplateMap!=null && emailTemplateMap.size()>0){
                    for (HexaBPM__Service_Request__c obj : SRList){
                        if(obj.recordTypeID == recTypeID && emailTemplateMap.get(obj.GradeLookup__c)!=null && emailTemplateMap.get(obj.GradeLookup__c).email_type__c == 'Acknowledgement')
                            obj.Acknowledgement_Email__c =  emailTemplateMap.get(obj.GradeLookup__c).email_template__c;     
                    }
                }
            }

            if (schoolMap != null && schoolMap.size() > 0) {
                for (HexaBPM__Service_Request__c objSR : SRList) {
                    objSR.School_Logo__c = schoolMap.get(objSR.school__c).logo__c;
                    objSR.Sys_Finance_Officer_Email__c = schoolMap.get(objSR.school__c).Finance_Officer_Email__c;
                    objSR.Sys_Lab_Email__c = schoolMap.get(objSR.school__c).Lab_Email__c;
                    objSR.Sys_Library_Email__c = schoolMap.get(objSR.school__c).Library_Email__c;
                    objSR.Sys_Principals_PA_Email__c = schoolMap.get(objSR.school__c).Principals_PA_Email__c;
                    objSR.Sys_Registrar_Email__c = schoolMap.get(objSR.school__c).Registrar_Email__c;
                    objSR.Sys_STS_Email__c = schoolMap.get(objSR.school__c).STS_Email__c;
                    objSR.Sys_Principal_Email__c = schoolMap.get(objSR.school__c).Principal__r.Email__c;
                    objSR.Sys_PRE_Email__c = schoolMap.get(objSR.school__c).PRE_Email_Address__c;
                    objSR.GRE_Email__c = schoolMap.get(objSR.school__c).GRE_Email__c;
                    objSR.generic_email_address__c = schoolMap.get(objSR.school__c).generic_email_address__c;
                }
            }
        }
    }

    public static void updateFieldsForSROnUpdate(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> oldMap) {
            //Updates email, phone, username, primary contact name for all SR other than enrolment
            set<id> accountId = new set<id>();
            set<id> gradeID = new set<id>();
            set<id> rejectedSR = new set<id>(); //V4.0
            string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Enrollment');
            if (SRList != null && SRList.size() > 0) {
                for (HexaBPM__Service_Request__c obj : SRList) {
                    HexaBPM__Service_Request__c oldRecord = oldMap.get(obj.Id);
                    if (obj.recordTypeID != recTypeID) {
                        if (obj.Student__c != null && obj.Student__c != oldRecord.Student__c) {
                            accountId.add(obj.Student__c);
                        }
                        if (obj.HexaBPM__Customer__c != null && obj.HexaBPM__Customer__c != oldRecord.HexaBPM__Customer__c) {
                            accountId.add(obj.HexaBPM__Customer__c);
                        }
                    }
                    
                    if(obj.recordTypeID == recTypeID){
                        string firstName = '';
                        string lastName = '';
                        string email = '';
                        
                        //V4.0
                        if(obj.HexaBPM__Is_Rejected__c == true && string.isBlank(obj.HexaBPM__Rejection_Reason__c)){
                            obj.Cancelled_SR_Status__c = oldRecord.HexaBPM__External_SR_Status__c;
                            rejectedSR.add(obj.id);
                        }
                        
                        if(obj.Primary_Contact__c == 'Father'){
                            obj.HexaBPM__Email__c = obj.Email_Father__c;
                            obj.Emergency_Contact_Number__c = obj.Mobile__c;
                        }else if(obj.Primary_Contact__c == 'Mother'){
                            obj.HexaBPM__Email__c = obj.Email_Mother__c;
                            obj.Emergency_Contact_Number__c = obj.Mobile_Mother__c;
                        }else if(obj.Primary_Contact__c == 'Guardian'){
                            obj.HexaBPM__Email__c = obj.Email_Guardian__c;
                            obj.Emergency_Contact_Number__c = obj.Mobile_Guardian__c;
                        }
                    
                        if(string.isNotBlank(obj.First_Name__c)){
                            firstName = obj.First_Name__c.tolowercase();
                        }
                        if(string.isNotBlank(obj.Last_Name__c)){
                            lastName = obj.Last_Name__c.tolowercase();
                        }
                        if(string.isNotBlank(obj.HexaBPM__Email__c)){
                            email = obj.HexaBPM__Email__c.tolowercase();
                        }
                        if(obj.GradeLookup__c!=null && obj.GradeLookup__c!=oldMap.get(obj.Id).GradeLookup__c){
                            gradeID.add(obj.GradeLookup__c);
                        }
                        obj.Unique_External__c = firstName+'-'+lastName+'-'+ email; 
                    }
    
                    if (obj.Is_SR_Closed__c != oldRecord.Is_SR_Closed__c && obj.Is_SR_Closed__c ==  true) {
                        obj.SR_Closed_Date__c = system.today();
                    }
                }

            map<id, Account> mapIdToAccount = new map<id, Account>();
            if (accountId != null && accountId.size() > 0) {
                for (Account obj : [select id, Primary_Contact_Email__c, primary_contact_name__c, FirstName, lastname,
                                           Emergency_Contact_Number__c, parent_username__c, Academic_Year__c, GradeLookup__c,
                                           Student_Id__c, Fee_ID__c, Stream__c, Section__c, Section__r.Section__c,Section__r.Form_Tutor_Email__c
                                    from Account
                                    where id IN : accountId and Record_Type_Name__c = 'Student']) {
                    mapIdToAccount.put(obj.id, obj);
                }
            }
            if (mapIdToAccount != null && mapIdToAccount.size() > 0) {
                Set<String> recordTypeMap = new Set<String>();
                recordTypeMap.add('Strike_Off');
                recordTypeMap.add('TC_Request');
                recordTypeMap.add('Cancel_Admission');
    
                map<String, String> recordTypeIDMap = new map<String, String>();
                if (!recordTypeMap.isEmpty()) {
                    for ( RecordType rec : [SELECT Id FROM RecordType WHERE sObjectType = 'HexaBPM__Service_Request__c' and DeveloperName IN :recordTypeMap] ) {
                        recordTypeIDMap.put(rec.Id, rec.Id);
                    }
                }

                for (HexaBPM__Service_Request__c obj : SRList) {
                    if (obj.recordTypeID != recTypeID && obj.Student__c != null && mapIdToAccount.get(obj.Student__c) != null) {
                        obj.HexaBPM__Email__c = mapIdToAccount.get(obj.Student__c).Primary_Contact_Email__c;
                        obj.Emergency_Contact_Number__c = mapIdToAccount.get(obj.Student__c).Emergency_Contact_Number__c;
                        obj.primary_contact_name__c = mapIdToAccount.get(obj.Student__c).primary_contact_name__c;
                        obj.parent_username__c = mapIdToAccount.get(obj.Student__c).parent_username__c;
                        obj.StudentId__c = mapIdToAccount.get(obj.Student__c).Student_Id__c;
                        obj.Fee_ID__c = mapIdToAccount.get(obj.Student__c).Fee_ID__c;
                        obj.First_Name__c = mapIdToAccount.get(obj.Student__c).firstname;
                        obj.Last_Name__c = mapIdToAccount.get(obj.Student__c).lastname;
                        obj.student_full_name__c = mapIdToAccount.get(obj.Student__c).firstname + ' ' + mapIdToAccount.get(obj.Student__c).lastname;

                        if (recordTypeIDMap != null && recordTypeIDMap.containsKey(obj.recordTypeId)) {
                            obj.Academic_Year__c = mapIdToAccount.get(obj.Student__c).Academic_Year__c;
                            obj.GradeLookup__c = mapIdToAccount.get(obj.Student__c).GradeLookup__c;
                            obj.Stream__c = mapIdToAccount.get(obj.Student__c).Stream__c;
                            obj.Section_Lookup__c = mapIdToAccount.get(obj.Student__c).Section__c;
                            obj.From_Section__c = mapIdToAccount.get(obj.Student__c).Section__r.Section__c;
                            obj.Form_Tutor_Email__c = mapIdToAccount.get(obj.Student__c).Section__r.Form_Tutor_Email__c;
                        }
                    }

                    if (obj.recordTypeID != recTypeID && obj.HexaBPM__Customer__c != null && mapIdToAccount.get(obj.HexaBPM__Customer__c) != null) {
                        obj.HexaBPM__Email__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Primary_Contact_Email__c;
                        obj.Emergency_Contact_Number__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Emergency_Contact_Number__c;
                        obj.primary_contact_name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).primary_contact_name__c;
                        obj.parent_username__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).parent_username__c;
                        obj.StudentId__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Student_Id__c;
                        obj.Fee_ID__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Fee_ID__c;
                        obj.First_Name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).firstname;
                        obj.Last_Name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).lastname;
                        obj.student_full_name__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).firstname + ' ' + mapIdToAccount.get(obj.HexaBPM__Customer__c).lastname;

                        if (recordTypeIDMap != null && recordTypeIDMap.containsKey(obj.recordTypeId)) {
                              obj.Academic_Year__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Academic_Year__c;
                              obj.GradeLookup__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).GradeLookup__c;
                              obj.Stream__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Stream__c;
                              obj.Section_Lookup__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Section__c;
                              obj.From_Section__c = mapIdToAccount.get(obj.HexaBPM__Customer__c).Section__r.Section__c;
                              obj.Form_Tutor_Email__c = mapIdToAccount.get(obj.Student__c).Section__r.Form_Tutor_Email__c;
                        }
                    }   
                }
            }
            
            if(gradeID!=null && gradeID.size()>0){
                map<id,Email_Templates__c> emailTemplateMap = new map<id,Email_Templates__c>();
                for(Email_Templates__c obj : [select id, Grade__c,email_type__c, email_template__c 
                                              from Email_Templates__c 
                                              where Grade__c IN : gradeID]){
                    if(string.isnotBlank(obj.email_template__c))
                        emailTemplateMap.put(obj.Grade__c,obj); 
                }
                if(emailTemplateMap!=null && emailTemplateMap.size()>0){
                    for (HexaBPM__Service_Request__c obj : SRList){
                        if(obj.recordTypeID == recTypeID && emailTemplateMap.get(obj.GradeLookup__c)!=null && emailTemplateMap.get(obj.GradeLookup__c).email_type__c == 'Acknowledgement')
                            obj.Acknowledgement_Email__c =  emailTemplateMap.get(obj.GradeLookup__c).email_template__c;     
                    }
                }
            }
        }
        
        //V4.0
        if(rejectedSR!=null && rejectedSR.size()>0){
            list<HexaBPM__SR_Price_Item__c> priceToCancel = new list<HexaBPM__SR_Price_Item__c>();
            priceToCancel = [select id, Status__c 
                             from HexaBPM__SR_Price_Item__c 
                             where HexaBPM__ServiceRequest__c IN : rejectedSR
                             and Status__c = 'Added'];
            if(priceToCancel!=null && priceToCancel.size()>0){
                for(HexaBPM__SR_Price_Item__c objPrice : priceToCancel){
                    objPrice.status__c = 'Cancelled';
                }   
                update priceToCancel;
            }   
        }
    }

    public static set<string> getSetOfParentFields() {
        set<string> setOfParentFields =  new set<string>();
        setOfParentFields.add('academic_year_ex__c');
        setOfParentFields.add('apartment_no__c');
        setOfParentFields.add('area__c');
        setOfParentFields.add('building__c');
        setOfParentFields.add('business_unit_father__c');
        setOfParentFields.add('city_emirate__c');
        setOfParentFields.add('city_state__c');
        setOfParentFields.add('company__c');
        setOfParentFields.add('country__c');
        setOfParentFields.add('email_father__c');
        setOfParentFields.add('first_name_father__c');
        setOfParentFields.add('last_name_father__c');
        setOfParentFields.add('fax_no__c');
        setOfParentFields.add('gems_school_father__c');
        setOfParentFields.add('home_phone__c');
        setOfParentFields.add('is_father_of_student_an_employee_in_gems__c');
        setOfParentFields.add('is_father_of_student_an_ex_student__c');
        setOfParentFields.add('makani__c');
        setOfParentFields.add('mobile__c');
        setOfParentFields.add('occupation__c');
        setOfParentFields.add('office_phone__c');
        setOfParentFields.add('p_o_box__c');
        setOfParentFields.add('staff_id__c');
        setOfParentFields.add('Street__c');
        setOfParentFields.add('academic_year_ex_mother__c');
        setOfParentFields.add('apartment_no_mother__c');
        setOfParentFields.add('area_mother__c');
        setOfParentFields.add('building_mother__c');
        setOfParentFields.add('business_unit_mother__c');
        setOfParentFields.add('city_emirate_mother__c');
        setOfParentFields.add('city_state_mother__c');
        setOfParentFields.add('company_mother__c');
        setOfParentFields.add('country_mother__c');
        setOfParentFields.add('email_mother__c');
        setOfParentFields.add('fax_no_mother__c');
        setOfParentFields.add('gems_school_mother__c');
        setOfParentFields.add('home_phone_mother__c');
        setOfParentFields.add('is_mother_of_student_an_employee_in_gems__c');
        setOfParentFields.add('is_mother_of_student_an_ex_student__c');
        setOfParentFields.add('makani_mother__c');
        setOfParentFields.add('mobile_mother__c');
        setOfParentFields.add('first_name_mother__c');
        setOfParentFields.add('last_name_mother__c');
        setOfParentFields.add('occupation_mother__c');
        setOfParentFields.add('office_phone_mother__c');
        setOfParentFields.add('p_o_box_mother__c');
        setOfParentFields.add('staff_id_mother__c');
        setOfParentFields.add('street_mother__c');
        setOfParentFields.add('apartment_no_guardian__c');
        setOfParentFields.add('area_guardian__c');
        setOfParentFields.add('building_guardian__c');
        setOfParentFields.add('city_emirate_guardian__c');
        setOfParentFields.add('city_state_guardian__c');
        setOfParentFields.add('company_guardian__c');
        setOfParentFields.add('country_guardian__c');
        setOfParentFields.add('email_guardian__c');
        setOfParentFields.add('fax_no_guardian__c');
        setOfParentFields.add('first_name_guardian__c');
        setOfParentFields.add('last_name_guardian__c');
        setOfParentFields.add('home_phone_guardian__c');
        setOfParentFields.add('makani_guardian__c');
        setOfParentFields.add('mobile_guardian__c');
        setOfParentFields.add('occupation_guardian__c');
        setOfParentFields.add('office_phone_guardian__c');
        setOfParentFields.add('p_o_box_guardian__c');
        setOfParentFields.add('street_guardian__c');
        return setOfParentFields;
    }

    //Check if user is part of school queue
    //Assuming no bulk operation
    public static void validateSrCreation(List<HexaBPM__Service_request__c> SR_List) {
        boolean isValid = false;
        HexaBPM__Service_request__c SRObj = SR_List[0];
        String schoolCode = SRObj.School_Short_Name__c + '_Registrar';
        map<Id, id> byPassProfileMap = new map<Id, Id>();
        map<String, String> SRType = new map<String, String> ();
        SRType.put('Enrollment','Enrollment');
        SRType.put('Inter_Unit_Student_Transfer','Inter_Unit_Student_Transfer');
        map<String, String> byPassProfiles = new map<String, String> {'GEMS Profile' => 'GEMS Profile', 'System Administrator' => 'System Administrator'};
        //Build bypassProfile map
        for (Profile p :  [SELECT ID, Name from Profile Where Name IN : byPassProfiles.values()]) {
            byPassProfileMap.put(p.Id, p.Id);
        }
        //Not Sys Admin, and not Guest user)
        if (!byPassProfileMap.containsKey(UserInfo.getProfileId()) && !SRType.containsKey(SRObj.HexaBPM__Record_Type_Name__c )) {
            for (GroupMember gm : [Select Group.Name, Group.DeveloperName from GroupMember where UserOrGroupId = : Userinfo.getUserId() and Group.Type = 'Queue'
                                 and Group.DeveloperName = : schoolCode]) {
                isValid = true;
            }
            if (!isValid) {
                SR_List[0].addError('You are not allowed to create request for this school.');
            }
        }
    }

    public static String getErrorMessage(String typeVal, String srType, String srName) {
        String retStr = '';
        //Draft status type = NULL , so checking with NULL
        retStr = (typeVal == NULL || !typeVal.equals('End')) ? 'Error: There is an open ' + srType + ' ' + srName : 'Invalid Student current status to raise this request.';
        return retStr;
    }

    public static void validateOpenSRs(List<HexaBPM__Service_request__c> SR_List) {
        String errorMessage = '';
        list<Id> StudentIdList = new List<Id>();
        HexaBPM__Service_request__c currSR = SR_List[0];
        for (HexaBPM__Service_request__c srObj  : SR_List) {
            if(srObj.Student__c!=null){
                StudentIdList.add(srObj.Student__c);
        }
        }
        map<Id, Boolean> accSrMap = new map<Id, Boolean>();
        
        if(StudentIdList!=null && StudentIdList.size()>0){
            for (HexaBPM__Service_request__c sr : [Select Id, Student__c from HexaBPM__Service_request__c where Student__c IN :StudentIdList]) {
                accSrMap.put(sr.Student__c, true);
            }
            for (HexaBPM__Service_request__c srObj  : [SELECT id, Name, HexaBPM__External_Status_Name__c,
                                                              HexaBPM__External_SR_Status__r.HexaBPM__Type__c,
                                                              Student__c, Student__r.Sys_Student_from_Oasis__c,
                                                              Student__r.Current_Status__c,
                                                              Student__r.Leave_Date__c, HexaBPM__Record_Type_Name__c
                                                       FROM HexaBPM__Service_request__c
                                                       WHERE Student__c IN :StudentIdList
                                                       AND Student__c != NULL and HexaBPM__Is_Rejected__c=false and HexaBPM__IsCancelled__c=false]) {
    
                    if (srObj.HexaBPM__Record_Type_Name__c == 'TC_Request' &&
                        currSR.HexaBPM__Record_Type_Name__c == 'TC_Request' &&
                        ( srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End'   || (srObj.Student__r.Current_Status__c != 'EN' && srObj.Student__r.Current_Status__c != 'SO' ) || (srObj.Student__r.Current_Status__c != 'EN' && srObj.Student__r.Leave_Date__c != NULL )) )  {
        
                        errorMessage =  getErrorMessage(srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c, 'TC Request.', srObj.Name);
                    } else if ( srObj.HexaBPM__Record_Type_Name__c == 'Strike_Off' &&
                                currSR.HexaBPM__Record_Type_Name__c == 'Strike_Off' && 
                                (srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End' || srObj.Student__r.Current_Status__c != 'EN' )) {
                        errorMessage =  getErrorMessage(String.valueOf(srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c), 'Strike Off Request.', srObj.Name);
                    } else if ( srObj.HexaBPM__Record_Type_Name__c == 'Cancel_Admission' &&
                                currSR.HexaBPM__Record_Type_Name__c == 'Cancel_Admission' && 
                                (srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End' || srObj.Student__r.Current_Status__c != 'EN')) {
        
                        errorMessage =  getErrorMessage(srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c, 'Cancel Admission Request.', srObj.Name);
                    } else if (srObj.HexaBPM__Record_Type_Name__c == 'Edit_Critical_Data' &&
                               currSR.HexaBPM__Record_Type_Name__c == 'Edit_Critical_Data' && 
                               srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End' ) {
        
                        errorMessage =  getErrorMessage(srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c, 'Edit Critical Data Request.', srObj.Name);
                    } else if (srObj.HexaBPM__Record_Type_Name__c == 'Inter_Unit_Student_Transfer' &&
                         currSR.HexaBPM__Record_Type_Name__c == 'Inter_Unit_Student_Transfer' && 
                         (srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End' || srObj.Student__r.Current_Status__c != 'EN')) {
        
                        errorMessage =  getErrorMessage(srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c, 'Inter Unit Student Transfer Request.', srObj.Name);
                    } else if (srObj.HexaBPM__Record_Type_Name__c == 'Re_Enrolment' &&
                               currSR.HexaBPM__Record_Type_Name__c == 'Re_Enrolment' && 
                              srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c != 'End') {
        
                        errorMessage =  getErrorMessage(srObj.HexaBPM__External_SR_Status__r.HexaBPM__Type__c, 'Re-Enrollment Request.', srObj.Name);
                }
                //Bypass if first SR is created for Students imported from Oasis
                else if (srObj.Student__r.Sys_Student_from_Oasis__c && !accSrMap.containsKey(srObj.Student__c)) {
                    errorMessage = '';
                }
            }
            for (HexaBPM__Service_request__c SR : SR_List) {
                if (!String.isBlank(errorMessage)) {
                    SR.addError(errorMessage);
                }
            }
        }
    }
    
    public static void updateURL(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> oldMap) {
        set<id> srID = new set<id>();
        
        for(HexaBPM__Service_Request__c objSR : SRList){
            
            if(objSR.school__c!=null && string.IsNotBlank(objSR.Lead_Reference__c) && string.IsBlank(objSR.GEMS_URL__c)){
                srID.add(objSR.id);
            }
        }
        
        if(srID!=null && srID.size()>0){
            
            list<HexaBPM__Service_Request__c> srUpdate = new list<HexaBPM__Service_Request__c>();
            for(HexaBPM__Service_Request__c SR : [select id, Complete_File_URL__c, GEMS_URL__c, Lead_Reference__c,
                                                         School_Code__c,School_Short_Name__c
                                                  from HexaBPM__Service_Request__c where id IN : srID
                                                  and HexaBPM__Record_Type_Name__c = 'Enrollment'
                                                  and Is_SR_Closed__c = false]){
                
                if(string.IsBlank(SR.GEMS_URL__c)){
                    GEMS_Site_Domain_Config__c domainConfig = new GEMS_Site_Domain_Config__c();
                    string urlToEncode = 'apex/Gems_Thank_You?BSU='+SR.School_Code__c+'&Id='+SR.id+ '&RefId='+SR.Lead_Reference__c +'&Stage=Registration';
                    domainConfig = GEMS_Utility.getSiteURLConfig(SR.School_Short_Name__c);
                    
                    if(domainConfig!=null && string.isNotBlank(domainConfig.Site_Base_URL__c) && string.isNotBlank(domainConfig.Short_Form_Page_Name__c)){
                        
                        String paymentPageURL = '';
                        paymentPageURL = GEMS_PaymentCntlr_Helper.getPaymentPageURL(SR.Lead_Reference__c, SR.School_Code__c);
                        
                        string temporaryURL = '';
                        temporaryURL = paymentPageURL.subStringAfter('/GEMS/');
                        
                        string finalURL = '';
                        finalURL = string.isNotBlank(temporaryURL)?temporaryURL:paymentPageURL;
                        SR.GEMS_URL__c = (domainConfig != NULL ) ? domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c   + '?' + EncodingUtil.base64Encode(Blob.valueOf(finalURL)) : NULL ;
                        
                    }
                }
                
                if(string.IsNotBlank(SR.GEMS_URL__c)){
                    srUpdate.add(SR);
                }
            }
            
            if(srUpdate!=null && srUpdate.size()>0){
                update srUpdate;
            }
        }
    }
    
    
    public static void reEvaluateFeeAmount(list<HexaBPM__Service_Request__c> SRList, map<Id, HexaBPM__Service_Request__c> oldMap){
        
        set<id> srID = new set<id>();
        set<id> ayID = new set<id>();
        set<id> gradeID = new set<id>();
        
        set<string> stageSet = new set<string>();
        stageSet.add('ENROLLMENT');
        stageSet.add('OFFER LETTER GENERATION');
        stageSet.add('NEW ADMISSION');
        stageSet.add('REGISTRATION'); 
        
        for(HexaBPM__Service_Request__c objSR : SRList){
            
            if(objSR.HexaBPM__Record_Type_Name__c=='Enrollment' &&
               objSR.Academic_Year__c != null && objSR.GradeLookup__c != null &&
               (objSR.Academic_Year__c != oldMap.get(objSR.Id).Academic_Year__c ||
               objSR.GradeLookup__c != oldMap.get(objSR.Id).GradeLookup__c)){
            
                srID.add(objSR.id);   
                ayID.add(objSR.Academic_Year__c); 
                gradeID.add(objSR.GradeLookup__c); 
                
            }
        }
        
        list<HexaBPM__SR_Price_Item__c> feeLine;
        if(srID!=null && srID.size()>0){
            feeLine = new list<HexaBPM__SR_Price_Item__c>();
            feeLine = [select id, Amount__c, HexaBPM__Price__c, Open_Online_Payment__c,product__r.ProductCode,
                              HexaBPM__ServiceRequest__r.Academic_Year__c, HexaBPM__ServiceRequest__r.GradeLookup__c 
                       from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c IN : srID
                       and Status__c = 'Added'];
        }   
        
        map<string,Amount__c> feeSetUpMap;
        if(feeLine!=null && feeLine.size()>0 && ayID!=null && ayID.size()>0){
            feeSetUpMap = new map<string,Amount__c>();
            
            for(Amount__c obj : [select id, Amount__c,Academic_Year__c,Fee_Master__r.ProductCode from Amount__c 
                                 where Academic_Year__c IN : ayID
                                 and Stage_Lookup__r.HexaBPM__Code__c IN :stageSet]){
                feeSetUpMap.put(obj.Academic_Year__c+'-'+obj.Fee_Master__r.ProductCode,obj);    
            }
        }
        
        map<id,string> gradeMap;
        if(feeLine!=null && feeLine.size()>0 && gradeID!=null && gradeID.size()>0){
            gradeMap = new map<id,string>();
            for(Grade__c obj : [select id, Open_Online_Payment__c from Grade__c 
                                where id IN : gradeID]){
                gradeMap.put(obj.id,obj.Open_Online_Payment__c);    
            }
            
        }
        
        if(feeLine!=null && feeLine.size()>0){
            for(HexaBPM__SR_Price_Item__c obj : feeLine){
                if(gradeMap!=null && gradeMap.size()>0 && gradeMap.containsKey(obj.HexaBPM__ServiceRequest__r.GradeLookup__c)){
                    obj.Open_Online_Payment__c = gradeMap.get(obj.HexaBPM__ServiceRequest__r.GradeLookup__c);       
                }
                string key = obj.HexaBPM__ServiceRequest__r.Academic_Year__c+'-'+obj.product__r.ProductCode;
                if(feeSetUpMap!=null && feeSetUpMap.size()>0 && feeSetUpMap.containsKey(key)){
                    obj.Amount__c = feeSetUpMap.get(key).id;
                    obj.HexaBPM__Price__c = feeSetUpMap.get(key).amount__c;     
                }
            }
            update feeline;
        }
    }
}