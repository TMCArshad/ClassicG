/* Modification History
---------------------------------------------------------------------------------------------------------------
    Version  |  Author     |   Date       | Description
  //Commented  V1.0     |  Umair Khan |  05-Dec-2017 | Link Family Details with SR
**************************************************************************************************/

global class GEMS_CreateSRFromEnquiry {
    webservice static String createSRFromEnquiry(string enqID){
        string msg='Success';
        try{
            if(string.isNotBlank(enqID)){
                list<HexaBPM__Service_Request__c> srList = new list<HexaBPM__Service_Request__c>();
                srList = [select id, name from HexaBPM__Service_Request__c where enquiry__c =: enqID];  
                if(srList!=null && srList.size()>0){
                    return 'Service request already exist, Please refer '+srList[0].name;   
                }
                else{ 
                    
                    Enquiry__c objEnq =  new Enquiry__c();
                    list<Enquiry__c> tempEnquiryList = new list<Enquiry__c>(); 
                    String query = GEMS_Utility.getAllFields(Enquiry__c.getsObjectType().getDescribe());
                    query += ' WHERE ID =:enqID'  ;
                    tempEnquiryList = Database.query(query);
                    if(tempEnquiryList!=null && tempEnquiryList.size()>0){
                        objEnq = tempEnquiryList[0];  
                    }
                    
                    Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Enrollment');
            
                    HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                    objSR.enquiry__c = enqID;
                    objSR.Primary_Contact__c = objEnq.Relation_to_student__c; 
                    objSR.HexaBPM__Email__c =  objEnq.Email__c;
                    objSR.Primary_Contact_Name__c = objEnq.Parent_First_Name__c + ' ' +  objEnq.Parent_Last_Name__c;
                    objSR.First_Name_Father__c = (objEnq.Relation_to_student__c.equals('Father')) ? objEnq.Parent_First_Name__c : '';
                    objSR.Last_Name_Father__c =  (objEnq.Relation_to_student__c.equals('Father')) ? objEnq.Parent_Last_Name__c : '';
                    objSR.country__c = (objEnq.Relation_to_student__c.equals('Father')) ? objEnq.Country__c : '';
                    objSR.City_Emirate__c = (objEnq.Relation_to_student__c.equals('Father')) ? objEnq.State__c : '';
                    objSR.Mobile__c = (objEnq.Relation_to_student__c.equals('Father')) ?  objEnq.MobilePhone__c : '';
                    objSR.Email_Father__c = (objEnq.Relation_to_student__c.equals('Father')) ?  objEnq.Email__c : '';
                    objSR.Company__c = (objEnq.Relation_to_student__c.equals('Father')) ?  objEnq.Parent_Company__c : '';
                    objSR.Company_lookup_father__c = objEnq.Relation_to_student__c.equals('Father') && objEnq.Parent_Company__c != '' ? gems_Utility.getCompany(objEnq.Parent_Company__c) : null;
                     
                    objSR.First_Name_Mother__c = (objEnq.Relation_to_student__c.equals('Mother')) ? objEnq.Parent_First_Name__c : '';
                    objSR.Last_Name_Mother__c =  (objEnq.Relation_to_student__c.equals('Mother')) ? objEnq.Parent_Last_Name__c : '';
                    objSR.Country_Mother__c = (objEnq.Relation_to_student__c.equals('Mother')) ? objEnq.Country__c : '';
                    objSR.City_emirate_Mother__c = (objEnq.Relation_to_student__c.equals('Mother')) ? objEnq.State__c : '';
                    objSR.Mobile_Mother__c = (objEnq.Relation_to_student__c.equals('Mother')) ?  objEnq.MobilePhone__c : '';
                    objSR.Email_Mother__c = (objEnq.Relation_to_student__c.equals('Mother')) ?  objEnq.Email__c : '';
                    objSR.Company_Mother__c = (objEnq.Relation_to_student__c.equals('Mother')) ?  objEnq.Parent_Company__c : '';
                    objSR.Company_lookup_mother__c = objEnq.Relation_to_student__c.equals('Mother') && objEnq.Parent_Company__c != '' ? gems_Utility.getCompany(objEnq.Parent_Company__c) : null;
                    
                    objSR.First_Name_Guardian__c = (objEnq.Relation_to_student__c.equals('Guardian')) ? objEnq.Parent_First_Name__c : '';
                    objSR.Last_Name_Guardian__c =  (objEnq.Relation_to_student__c.equals('Guardian')) ? objEnq.Parent_Last_Name__c : NULL;
                    objSR.Country_Guardian__c = (objEnq.Relation_to_student__c.equals('Guardian')) ? objEnq.Country__c : '';
                    objSR.City_Emirate_Guardian__c = (objEnq.Relation_to_student__c.equals('Guardian')) ? objEnq.State__c : ''; 
                    objSR.Mobile_Guardian__c = (objEnq.Relation_to_student__c.equals('Guardian')) ? objEnq.MobilePhone__c : '';
                    objSR.Email_Guardian__c = (objEnq.Relation_to_student__c.equals('Guardian')) ?   objEnq.Email__c : '';
                    objSR.Company_Guardian__c = (objEnq.Relation_to_student__c.equals('Guardian')) ?  objEnq.Parent_Company__c : '';
                    objSR.Company_lookup_guardian__c = objEnq.Relation_to_student__c.equals('Guardian') && objEnq.Parent_Company__c != '' ? gems_Utility.getCompany(objEnq.Parent_Company__c) : null;

                    objSR.Siblings_studying_in_a_GEMS_school__c = objEnq.has_sibling_in_GEMS__c;
                    objSR.Sibling_Name__c = objEnq.Sibling_name__c;
                    objSR.Sys_GEMS_School_Sibling__c = objEnq.Sibling_School__c;
                    objSR.Sibling_Fee_ID__c =  objEnq.Sibling_Fee_ID__c;
                    objSR.Sibling_Date_of_Birth__c = objEnq.Sibling_Date_of_Birth__c;
                    objSR.Enquiry_from_Oasis__c = objEnq.sys_Enquiry_from_Oasis__c;
                    objSR.Enquiry_Id_Oasis__c = objEnq.sys_Enquiry_Id_Oasis__c;
              
                    objSR.Lead__c = objEnq.Lead__c;
                    objSR.enquiry__c = objEnq.id!=null?objEnq.id:null;
                    objSR.First_Name__c = objEnq.Firstname__c;
                    objSR.Last_Name__c = objEnq.LastName__c;
                    objSR.Registration_Number__c = objEnq.Registration_Number__c;
                    objSR.Lead_Reference__c = objEnq.Lead_Reference__c;
                    objSR.School__c = objEnq.SchoolLookup__c;
                    objSR.GradeLookup__c = objEnq.GradeLookup__c;
                    objSR.Religion__c = objEnq.Religion__c;
                    objSR.First_Language__c = objEnq.First_Language__c;
                    objSR.Academic_Year__c = objEnq.Academic_Year__c;
                    objSR.Stream__c = objEnq.Stream__c;
                    objSR.Curriculum__c = objEnq.Curriculum__c;
                    objSR.Gender__c = objEnq.Gender__c;
                    objSR.Date_Of_Birth__c = objEnq.Date_Of_Birth__c;
                    objSR.Nationality__c = objEnq.Nationality__c;
                    objSR.School_Name__c = objEnq.Previous_School__c;
                    objSR.Service_Type__c = GEMS_Constants.SRTYPE_ENROLLMENT_SHORT_FORM;
                    objSR.RecordTypeID = recTypeID;
                    objSR.Support_User__c = objEnq.Support_User__c;
                    objSR.SR_No__c = objEnq.Lead_No__c;
                    objSR.Sys_previous_school_is_GEMS__c = objEnq.Sys_previous_school_is_GEMS__c;
                    objSR.Offer_Period__c = '7';//Defaulting offer period to 7 
                    
                    objSR.Referral_School__c = objEnq.Referral_School__c!=null?objEnq.Referral_School__c:null;
                    objSR.Referral_Student__c = objEnq.Referral_Student__c!=null?objEnq.Referral_Student__c:null;
                    objSR.Referral_Email__c = objEnq.Referral_Email__c!=''?objEnq.Referral_Email__c:null;
                    objSR.Referring_Parent__c = objEnq.Referring_Parent__c!=''?objEnq.Referring_Parent__c:null;
                    objSR.RewardType__c = objEnq.RewardType__c;
                    objSR.Eligible_for_Referral_Program__c = objEnq.Eligible_for_Referral_Program__c;
                    objSR.employee__c = objEnq.employee__c;
                    /* Modified by - Arsad Shaikh
					   Date - 14th May 
					   Description - to copy Confirmed_if_GEMS_Student__c from Enquiry to SR */

                    objSR.Confirmed_if_GEMS_Student__c = objEnq.Confirmed_if_GEMS_Student__c!=null?objEnq.Confirmed_if_GEMS_Student__c:null;
                    insert objSR;
                    
                    srList = new list<HexaBPM__Service_Request__c>();
                    srList = [select id, name, school__r.ID__c, school__r.Short_Name__c,Lead_Reference__c
                    		  from HexaBPM__Service_Request__c 
                    		  where id =: objSR.id];   
                    if(srList!=null && srList.size()>0){
                        
                        objEnq.hasSR__c = true;
                    	update objEnq;
                    	
                       	//V1.0
                       /* Set<Id> SRIds = new Set<Id>();
                        SRIds.add(objSR.id);
                        
                        List<Lead> lstLead = new list<Lead>();
                        lstLead = [select id, name from Lead where Id =: objEnq.Lead__c];  
                
                        Map<Id,EnquiryRelationship__c> leadToER = GEMS_EnquiryDetailsCntlr_Helper.getEnquiryRelationship(lstLead);
                    	
                    	GEMS_EnquiryDetailsCntlr_Helper.updateEnquiryRelationship(SRIds,leadToER);
                    	*/
                    	//End
                    	
                    
                        return 'Service request created, Please refer '+srList[0].name+ ', If Payment already done click on Fetch oasis status on SR';  
                    }
                }
            }
        }catch(exception e){
            return e.getMessage();
        }
        return msg;
    }
}