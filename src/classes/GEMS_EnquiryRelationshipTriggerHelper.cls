/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   13th March 2017
    Description :   GEMS_EnquiryRelationshipTriggerHelper written on EnquiryRelationship__c.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_EnquiryRelationshipTriggerHelper {
    
	public static void updateEnquiryDetails(list<EnquiryRelationship__c> enquiryRelationList){
   		if(enquiryRelationList!=null && enquiryRelationList.size()>0){
   			set<id> leadSet = new set<id>();
   			for(EnquiryRelationship__c obj : enquiryRelationList){
   				if(obj.Lead__c!=null){
   					leadSet.add(obj.Lead__c);
   				}	
   				if(obj.Sibling_Lead__c!=null){
   					leadSet.add(obj.Sibling_Lead__c);
   				}	
   			}	
   			
   			map<id,id> mapLeadAndEnquiry = new map<id,id>();
   			if(leadSet!=null && leadSet.size()>0){
   				for(lead obj : [select id, enquiry__c from lead where id IN : leadSet]){
   					mapLeadAndEnquiry.put(obj.id, obj.enquiry__c);
   				}
   			}
   				
   			if(mapLeadAndEnquiry!=null && mapLeadAndEnquiry.size()>0){
   				for(EnquiryRelationship__c obj : enquiryRelationList){
   					obj.Enquiry__c = mapLeadAndEnquiry.get(obj.Lead__c)!=null ? mapLeadAndEnquiry.get(obj.Lead__c) : null;
   					obj.Sibling_Enquiry__c = mapLeadAndEnquiry.get(obj.Sibling_Lead__c)!=null ? mapLeadAndEnquiry.get(obj.Sibling_Lead__c) : null;
   				}
   			}
   		}
   	}
}