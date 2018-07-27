/* Modification History
---------------------------------------------------------------------------------------------------------------
    Version  |  Author     |   Date       | Description
    V1.0     |  Umair Khan |  29-Nov-2017 | Map Other Parent Company and Other School field on Lead/SR object
    V1.1     |  Umair Khan |  05-Dec-2017 | Link Family Details with SR
    V1.2     |  Kim Noceda |  15-Feb-2018 | Populate Existing STudent Id field. Mark checkbox is New Form as TRUE
**************************************************************************************************/

public without sharing class GEMS_EnquiryDetailsCntlr_Helper {

   public static Map<String,Id> getCompanyMap(List<Lead>leadList){
     List<Integer> companyNames = new List<Integer>();
     Map<String,Id>companyMap =  new Map<String,Id>();
     for(Lead l : LeadList){
        companyNames.add(Integer.valueOf(l.Parent_Company__c)); 
     }
     for(Company__c cmp : [SELECT Name,Id__c,Id from Company__c WHERE ID__c IN :companyNames]){
      companyMap.put(String.valueOf(cmp.ID__c),cmp.id);
     }
     return companyMap;
   }
   
  /** 
   * [createSRforLeads Creates SR for every lead created in the enquiryDetails Page]
   * @param Lead_List         [List<lead>]
   * @param RecordTypeAPIName [RT name of the SR to be created]
   */
    public static void createSRforLeads(List<Lead> Lead_List, String RecordTypeAPIName) {
        
        Map<Id, HexaBPM__Service_Request__c> leadToOpenSRMap = getSRDupCheckMap(Lead_List);
        Map<String,Id>companyMap =  new Map<String,Id>();
        
        //V1.1
        Map<Id,List<EnquiryRelationship__c>> leadToER = getEnquiryRelationship(Lead_List);
        //End
        
        Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get(RecordTypeAPIName);
        List<HexaBPM__Service_Request__c> SR_List = new List<HexaBPM__Service_Request__c>();
        HexaBPM__Service_Request__c SR;
        
        companyMap = getCompanyMap(Lead_List);
        for (lead lead : Lead_List) {
            //No open SR of Enrollment RT
                 SR = (leadToOpenSRMap.containsKey(lead.Id))  ? new HexaBPM__Service_request__c(Id =leadToOpenSRMap.get(lead.Id).Id) : new HexaBPM__Service_request__c();
                //Include Logic to populate other fields from PrimaryContact
                  
                  SR.Primary_Contact__c = lead.Relation_to_student__c; 
                  SR.HexaBPM__Email__c =  lead.Email;
                  SR.Primary_Contact_Name__c = lead.Parent_First_Name__c + ' ' +  lead.Parent_Last_Name__c;
                  
                  SR.First_Name_Father__c = (lead.Relation_to_student__c.equals('Father')) ? lead.Parent_First_Name__c : NULL;
                  SR.Last_Name_Father__c =  (lead.Relation_to_student__c.equals('Father')) ? lead.Parent_Last_Name__c : NULL;
                  SR.country__c = (lead.Relation_to_student__c.equals('Father')) ? lead.Country__c : NULL;
                  SR.City_Emirate__c = (lead.Relation_to_student__c.equals('Father')) ? lead.State__c : NULL;
                  SR.Mobile__c = (lead.Relation_to_student__c.equals('Father')) ?  lead.MobilePhone : NULL;
                  SR.Email_Father__c = (lead.Relation_to_student__c.equals('Father')) ?  lead.Email : NULL;
                  SR.Company__c = (lead.Relation_to_student__c.equals('Father')) ?  lead.Parent_Company__c : NULL;
                  SR.Company_lookup_father__c = (lead.Relation_to_student__c.equals('Father') && lead.Parent_Company__c != NULL && companyMap.containsKey(lead.Parent_Company__c) )  ? companyMap.get(lead.Parent_Company__c) : NULL ; 
                  //Umair
                  SR.Other_Company_Father__c = (lead.Relation_to_student__c.equals('Father')) ?  lead.Parent_Other_Company__c : NULL;
                  //End
                  
                  SR.First_Name_Mother__c = (lead.Relation_to_student__c.equals('Mother')) ? lead.Parent_First_Name__c : NULL;
                  SR.Last_Name_Mother__c =  (lead.Relation_to_student__c.equals('Mother')) ? lead.Parent_Last_Name__c : NULL;
                  SR.Country_Mother__c = (lead.Relation_to_student__c.equals('Mother')) ? lead.Country__c : NULL;
                  SR.City_emirate_Mother__c = (lead.Relation_to_student__c.equals('Mother')) ? lead.State__c : NULL;
                  SR.Mobile_Mother__c = (lead.Relation_to_student__c.equals('Mother')) ?  lead.MobilePhone : NULL;
                  SR.Email_Mother__c = (lead.Relation_to_student__c.equals('Mother')) ?  lead.Email : NULL;
                  SR.Company_Mother__c = (lead.Relation_to_student__c.equals('Mother')) ?  lead.Parent_Company__c : NULL;
                  SR.Company_lookup_mother__c = (lead.Relation_to_student__c.equals('Mother') && lead.Parent_Company__c != NULL && companyMap.containsKey(lead.Parent_Company__c) )  ? companyMap.get(lead.Parent_Company__c) : NULL ;
                  
                  SR.First_Name_Guardian__c = (lead.Relation_to_student__c.equals('Guardian')) ? lead.Parent_First_Name__c : NULL;
                  SR.Last_Name_Guardian__c =  (lead.Relation_to_student__c.equals('Guardian')) ? lead.Parent_Last_Name__c : NULL;
                  SR.Country_Guardian__c = (lead.Relation_to_student__c.equals('Guardian')) ? lead.Country__c : NULL;
                  SR.City_Emirate_Guardian__c = (lead.Relation_to_student__c.equals('Guardian')) ? lead.State__c : NULL; 
                  SR.Mobile_Guardian__c = (lead.Relation_to_student__c.equals('Guardian')) ? lead.MobilePhone : NULL;
                  SR.Email_Guardian__c = (lead.Relation_to_student__c.equals('Guardian')) ?   lead.Email : NULL;
                  SR.Company_Guardian__c = (lead.Relation_to_student__c.equals('Guardian')) ?  lead.Parent_Company__c : NULL;
                  SR.Company_lookup_guardian__c = (lead.Relation_to_student__c.equals('Guardian') && lead.Parent_Company__c != NULL && companyMap.containsKey(lead.Parent_Company__c) ) ?  companyMap.get(lead.Parent_Company__c) : NULL;
                  SR.Referral_Email__c = Lead.Referral_Email__c;
                  SR.Referral_School__c = Lead.Referral_School__c;
                  SR.Referral_Student__c = Lead.Referral_Student__c;
                  SR.Referring_Parent__c = Lead.Referring_Parent__c;
                  SR.Eligible_for_Referral_Program__c = Lead.Eligible_for_Referral_Program__c;
                  SR.Employee__c = Lead.Employee__c;
                //
                //Populate Sibling Information ON SR From lead - Start
                //
                SR.Siblings_studying_in_a_GEMS_school__c = lead.has_sibling_in_GEMS__c;
                SR.Sibling_Name__c = lead.Sibling_name__c;
                SR.Sys_GEMS_School_Sibling__c = lead.Sibling_School__c;
                SR.Sibling_Fee_ID__c =  lead.Sibling_Fee_ID__c;
                SR.Sibling_Date_of_Birth__c = lead.Sibling_Date_of_Birth__c;
                //
                //Populate Sibling Information ON SR From lead - End
                //
                 
                //Populate UTM Fields
                SR.Google_Analytics_gclid__c = lead.Google_Analytics_gclid__c;
                SR.Google_Analytics_Campaign__c  = lead.Google_Analytics_Campaign__c;
                SR.Google_Analytics_Client_Id__c = lead.Google_Analytics_Client_Id__c;
                SR.Google_Analytics_Content__c = lead.Google_Analytics_Content__c; 
                SR.Google_Analytics_Medium__c = lead.Google_Analytics_Medium__c; 
                SR.Google_Analytics_Source__c = lead.Google_Analytics_Source__c;
                SR.Google_Analytics_Term__c = lead.Google_Analytics_Term__c;
            
                SR.Lead__c = lead.Id;
                SR.enquiry__c = lead.enquiry__c!=null?lead.enquiry__c:null;
                SR.First_Name__c = lead.Firstname;
                SR.Last_Name__c = lead.LastName;
                SR.Registration_Number__c = Lead.Registration_Number__c;
                SR.Lead_Reference__c = lead.Lead_Reference__c;
                SR.School__c = lead.SchoolLookup__c;
                SR.GradeLookup__c = lead.GradeLookup__c;
                SR.Religion__c = lead.Religion__c;
                SR.First_Language__c = lead.First_Language__c;
                SR.Academic_Year__c = lead.Academic_Year__c;
                SR.Stream__c = lead.Stream__c;
                SR.Curriculum__c = lead.Curriculum__c;
                SR.Gender__c = Lead.Gender__c;
                SR.Date_Of_Birth__c = lead.Date_Of_Birth__c;
                SR.Nationality__c = lead.Nationality__c;
                SR.School_Name__c = lead.Previous_School__c;
                //Umair
                SR.Other_Previous_School__c = (lead.Other_Previous_School__c !=null)?lead.Other_Previous_School__c: NULL;
                //End
                
                SR.Service_Type__c = GEMS_Constants.SRTYPE_ENROLLMENT_SHORT_FORM;
                SR.RecordTypeID = recTypeID;
                SR.Support_User__c = Lead.Support_User__c;
                SR.SR_No__c = lead.Lead_No__c;
                SR.Sys_previous_school_is_GEMS__c = lead.Sys_previous_school_is_GEMS__c;
                SR.Offer_Period__c = '7';//Defaulting offer period to 7 
                
                //V1.2
                SR.Existing_Student_Id__c = lead.Existing_Student_Id__c;
                SR.Student_Id__c = lead.Existing_Student_Id__c;
                SR.is_New_Form_SR__c = false;
                if(lead.Existing_Student_Id__c != '' && lead.Existing_Student_Id__c != null){
                    SR.is_New_Form_SR__c = true;
                }
                //END
               
                SR_List.add(SR);
            
        }
        //upsert SR_List;
        
        //V1.1
        List<Database.UpsertResult> results = Database.upsert(SR_List, false );
        Set<Id> SRIds = new Set<Id>();
        
        for(Database.UpsertResult theResult:results) {
          if(theResult.isSuccess())
            SRIds.add(theResult.getId());
        }
        
        system.debug('SRIds>>>>' + SRIds);
        system.debug('leadToER>>>>' + leadToER);
        
        updateEnquiryRelationship(SRIds,leadToER);
        
        /*Map<Id, HexaBPM__Service_request__c> mapServiceRequest = new Map<Id, HexaBPM__Service_request__c>();
        
        for(HexaBPM__Service_request__c srObj : [Select Id,Lead__c, Lead__r.Id,enquiry__c From HexaBPM__Service_request__c Where Id IN : SRIds ]){
            mapServiceRequest.put(srObj.Lead__r.Id,srObj);
        }
        
        for(EnquiryRelationship__c eRel : leadToER.values()){
            
            if(mapServiceRequest.containsKey(eRel.Lead__c)){
                
                eRel.Service_Request__c = mapServiceRequest.get(eRel.Lead__c).Id;
                
            }
        }
        
        update leadToER.values();*/
        //End

    }
    /**
     * [createSiblingEnquiryRelationships - Create Sibling Enquiry Relation ship records for every new lead added with the lead already created]
     * @param Lead_List [Lead already added]
     * @param newLead   [new lead record]
     */
    public static void createSiblingEnquiryRelationships(List<Lead> Lead_List, Lead newLead) {
        List<EnquiryRelationship__c> ER_List = new List<EnquiryRelationship__c>();
        EnquiryRelationship__c ER;
        for (Lead l : Lead_List) {
            ER = new EnquiryRelationship__c();
            ER.Sibling_Lead__c = l.Id;
            ER.Lead__c = newLead.Id;
            ER.Relationship_Type__c = 'Sibling';
            ER_List.add(ER);

        }

        for (Lead l : Lead_List) {
            ER = new EnquiryRelationship__c();
            ER.Sibling_Lead__c = newLead.Id;
            ER.Lead__c = l.Id;
            ER.Relationship_Type__c = 'Sibling';
            ER_List.add(ER);
        }
        insert ER_List;

    }
/*
    public static List<Lead> updateLeadsWIthSiblingInfo(List<lead>Lead_List, siblingInfoWrapper siblingInfo) {
        List<lead> leadUpdate_List = new List<Lead>();

        for (Lead l : Lead_List) {
            l.Sibling_name__c = siblingInfo.siblingName;
            l.Sibling_Fee_ID__c = siblingInfo.siblingFeeID;
//            l.Sibling_Date_of_Birth__c = siblingInfo.siblingDOB;
            l.Sibling_School__c = siblingInfo.siblingSchool;
            leadUpdate_List.add(l);
        }
        //update leadUpdate_List;
        return leadUpdate_List;

    }
*/
    /**
     * [updateLeadDeatilsBeforePay Update Lead deatils before proceeding to payment]
     * @param  Lead_List          [List of Lead records]
     * @param  siblingInfo        [Sibling Details]
     * @param  primaryContactLead [Primary contact information]
     * @param  hasSibling         [has sibling check]
     * @return                    [List of leads with updated information]
     */
    public static List<Lead> updateLeadDeatilsBeforePay(List<lead> Lead_List,GEMS_EnquiryDetailsCntlr_Helper.siblingInfoWrapper siblingInfo,Lead primaryContactLead,Boolean hasSibling){
       List<Lead> leadRetList = new List<lead>();
       for(Lead leadObj : Lead_List){
           //Copy Sibling Info
            leadObj.has_sibling_in_GEMS__c = hasSibling;
            leadObj.Sibling_name__c = (hasSibling) ? SiblingInfo.siblingName : NULL;
            leadObj.Sibling_Fee_ID__c = (hasSibling) ? SiblingInfo.siblingFeeID : NULL;
            leadObj.Sibling_Date_of_Birth__c = (hasSibling) ? primaryContactLead.Sibling_Date_of_Birth__c : NULL;
            leadObj.Sibling_School__c = (hasSibling) ? SiblingInfo.siblingSchool : NULL;

            //Copy parent details
            leadObj = setParentDetails(leadObj,primaryContactLead);
            leadObj.hasSR__c = true;
            leadRetList.add(leadObj);
       } 
       return leadRetList;
    }
    /**
     * [setParentDetails Sets parent details ]
     * @param  leadObj            [Lead object]
     * @param  primaryContactLead [Primary contact lead]
     * @return                    [Lead record]
     */
    public static Lead setParentDetails(Lead leadObj, Lead primaryContactLead){
            leadObj.Parent_Title__c =   primaryContactLead.Parent_Title__c;
            leadObj.Parent_First_Name__c = primaryContactLead.Parent_First_Name__c;
            leadObj.Parent_last_Name__c  = primaryContactLead.Parent_last_Name__c;
            //leadObj.Parent_name__c = primaryContactLead.Parent_First_Name__c + ' ' + primaryContactLead.Parent_last_Name__c;
            
            //Using lead fields to capture prima
            leadObj.Relation_to_student__c = primaryContactLead.Relation_to_student__c;
            leadObj.Email = primaryContactLead.Email;
            leadObj.Parent_Company__c  = primaryContactLead.Parent_Company__c;
            leadObj.mobilePhone = primaryContactLead.mobilePhone;
            
            
            
            leadObj.Parent_nationality__c = primaryContactLead.Parent_nationality__c;
            leadObj.Country__c  = primaryContactLead.Country__c;
            leadObj.State__c  = primaryContactLead.State__c;
            leadObj.Area__c  = primaryContactLead.Area__c;
            
            leadObj.Parent_Other_Company__c = primaryContactLead.Parent_Other_Company__c;
            leadObj.Parent_Other_State__c =primaryContactLead.Parent_Other_State__c;
            leadObj.Parent_Other_Area__c = primaryContactLead.Parent_Other_Area__c;
            return LeadObj;
    }
    
    /**
     * [getSRDupCheckMap Builds SR dup check Map to make sure duplicate Srs are not created]
     * @param  Lead_List [List of Leads]
     * @return           [SRid to SR map]
     */
    public static Map<Id, HexaBPM__Service_Request__c> getSRDupCheckMap(List<Lead> Lead_List) {
        Map<Id, HexaBPM__Service_Request__c> leadToOpenSRMap = new Map<Id, HexaBPM__Service_Request__c>();
        List<Id> leadId_List = new List<Id>();
        for (Lead l : Lead_List) {
            leadId_List.add(l.Id);
        }
        //Check if open SR for Enrollment
        for (HexaBPM__Service_Request__c SR : [
                SELECT
                        Id,
                        Lead__c,
                        HexaBPM__External_Status_Name__c
                FROM
                        HexaBPM__Service_Request__c
                WHERE Lead__c IN :leadId_List
                AND HexaBPM__External_Status_Name__c != 'Approved'
                AND HexaBPM__External_Status_Name__c != 'Rejected'
                AND HexaBPM__Record_Type_Name__c = 'Enrollment'

        ]) {

            leadToOpenSRMap.put(SR.Lead__c, SR);

        }
        return leadToOpenSRMap;


    }
    
    //V1.1
     /**
     * [getEnquiryRelationship Get All EnquiryRelationship]
     * @param  Lead_List [List of Leads]
     * @return           [Leadid to ER map]
     */
    public static Map<Id, List<EnquiryRelationship__c>> getEnquiryRelationship(List<Lead> Lead_List){
        
        //Map<Id, EnquiryRelationship__c> leadToER = new Map<Id, EnquiryRelationship__c>();
        List<EnquiryRelationship__c> lstER  = new List<EnquiryRelationship__c>();
        List<Id> leadId_List = new List<Id>();
        
        for (Lead l : Lead_List) {
            leadId_List.add(l.Id);
        }
      
        for (EnquiryRelationship__c ER : [
                SELECT
                        Id,
                        Lead__c,
                        Service_Request__c
                FROM
                        EnquiryRelationship__c
                WHERE Lead__c IN :leadId_List
              

        ]) {
            lstER.add(ER);
            //leadToER.put(ER.Lead__c, ER);

        }
        
        Map<Id, List<EnquiryRelationship__c>> leadToER = new Map<Id, List<EnquiryRelationship__c>>();
        
        for(EnquiryRelationship__c er :lstER ){
            List<EnquiryRelationship__c> temp = leadToER.get(er.Lead__c);
            
            if(temp == null) {
                leadToER.put(er.Lead__c, new List<EnquiryRelationship__c>{er});
            } else {
                temp.add(er);
            }
            
        }
        
      return leadToER;
        
        
    }
    
    /**
     * [updateEnquiryRelationship ]
     * @param  Lead_List [List of Leads]
     * Desc : Link Family Details with SR
     */
      public static Boolean updateEnquiryRelationship( Set<Id> SRIds ,Map<Id, List<EnquiryRelationship__c>> leadToER){
          
        Map<Id, HexaBPM__Service_request__c> mapServiceRequest = new Map<Id, HexaBPM__Service_request__c>();
        
        for(HexaBPM__Service_request__c srObj : [Select Id,Lead__c, Lead__r.Id,enquiry__c From HexaBPM__Service_request__c Where Id IN : SRIds ]){
            mapServiceRequest.put(srObj.Lead__r.Id,srObj);
        }
        
        
        
        /*for(EnquiryRelationship__c eRel : leadToER.values()){
            
            if(mapServiceRequest.containsKey(eRel.Lead__c)){
                eRel.Service_Request__c = mapServiceRequest.get(eRel.Lead__c).Id;
            }
        }*/
        
        List<EnquiryRelationship__c> lstUpateER = new List<EnquiryRelationship__c>();
        for (Id key : leadToER.keySet()) {
            
            List<EnquiryRelationship__c> eRel = leadToER.get(key);
            
            for(EnquiryRelationship__c e : eRel){
                
                if(mapServiceRequest.containsKey(e.Lead__c)){
                    e.Service_Request__c = mapServiceRequest.get(e.Lead__c).Id;
                    
                    lstUpateER.add(e);
                    
                }
            
            }
          
            
        }
        
        //system.debug('updated leadToER>>>>>'+leadToER);
        //update leadToER.values();
        
        system.debug('updated lstUpateER>>>>>'+lstUpateER);
        if(lstUpateER.size() > 0)
            update lstUpateER;
            
            
        return true;
        
      }
     
    //End
    
    
    
/**
 * Wrapper class storing sibling information
 */
    public class siblingInfoWrapper {
    /* Sibling details */
   /* Sibling Info will be populated across all leads **/
        public String siblingName { get; set; }
        public String siblingSchool { get; set; }
        public String siblingFeeID { get; set; }
        public date siblingDOB { get; set; }
    }

}