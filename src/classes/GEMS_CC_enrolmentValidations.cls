/*****************************************************************************************************************************
    Author      :   Swati sehrawat
    Date        :   2nd May 2017
    Description :   Custom Code to validate enrolment before closing
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    V1.0    Swati   8th Jan 2018    ticket:159712
    v1.1    Leeba   16th Jan 2018   Fees sponser mandatory before closure of Enrolment SR
    v1.2    Kim   7th Feb 2018   Nationality and Religion mandatory before closure of Enrolment SR
                                 Removed the validation for Fees Sponsor
    
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global without sharing class GEMS_CC_enrolmentValidations implements HexaBPM.iCustomCodeExecutable {
    
    global String EvaluateCustomCode(HexaBPM__Service_Request__c ServiceRequest, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step!=null && step.HexaBPM__SR__c!=null){
            string srId = step.HexaBPM__SR__c;
            HexaBPM__Service_Request__c objSR =  new HexaBPM__Service_Request__c();
            list<HexaBPM__Service_Request__c> tempSRList = new list<HexaBPM__Service_Request__c>(); 
            String query = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
            query += ' WHERE ID =:srId'  ;
            tempSRList = Database.query(query);
            if(tempSRList!=null && tempSRList.size()>0){
                objSR = tempSRList[0];  
            }
            
            if(step.Step_Name__c=='Enrolment'){
                if(objSR.Joining_Date__c==null){
                    return 'Please mention Joining Date of student before approving the step';  
                }
                
                
                if(objSR.Transfer_Type__c==null){
                    return 'Please mention transfer type before approving the step';    
                }
                
                if(string.isNotBlank(objSR.Sibling_Fee_ID__c) && (objSR.Sibling_Fee_Id_Verified__c== '' || objSR.Sibling_Fee_Id_Verified__c==null)){
                    return 'Please verify Sibling Fee Id before approving the step';    
                }
                
                //v1.2
                if(objSR.Nationality__c == null){
                    return 'Please mention Nationality before approving this step';
                }
                //v1.2
                if(objSR.Religion__c == null){
                    return 'Please mention Religion before approving this step';
                }
                //v1.3
                /*if(string.isBlank(objSR.Child_have_any_special_education_needs__c) || string.isBlank(objSR.Student_require_English_support__c) || string.isBlank(objSR.Is_the_child_gifted_and_talented__c)){
                    return 'Please provide SEND, ELL and child is gifted details before approving this step';
                }*///v1.3 ends
                
                /*list<HexaBPM__SR_Price_Item__c> tempPriceList = new list<HexaBPM__SR_Price_Item__c>();
                tempPriceList = [select id from HexaBPM__SR_Price_Item__c where Status__c='Added' and HexaBPM__ServiceRequest__c=:objSR.id];
                if(tempPriceList!=null && tempPriceList.size()>0){
                    return 'Fee pending, student cannot be enrolled.';  
                }*/
            }
            else if(step.Step_Name__c=='Assessment/Screening'){
                //V1.0
                if(step.HexaBPM__Step_Status__c == 'Verified' && (objSR.Assessment_Date__c ==null || string.isBlank(objSR.Has_met_assessment_criteria__c) || objSR.Has_met_assessment_criteria__c == 'No')){
                    return 'Please mention Assessment/Screening Date and mark Has met assessment/screening criteria as Yes before approving the step';  
                }
                
                if(step.HexaBPM__Step_Status__c == 'Rejected' && (string.isBlank(objSR.Has_met_assessment_criteria__c) || objSR.Has_met_assessment_criteria__c == 'Yes')){
                    return 'Please mark Has met assessment/screening criteria as No and provide rejection feedback';    
                }
                
            }
            else if(step.Step_Name__c=='Offer Letter'){
                if(objSR.accept_offer__c == '' || objSR.accept_offer__c == null){
                    return 'Offer has yet not been accepted by the parent'; 
                }   
                if(objSR.accept_offer__c == 'No'){
                    return 'Offer has been declined by the parent'; 
                }
                if(string.isBlank(objSR.Offer_Type__c)){
                    return 'Please provide offer type before approving the step';
                }
                
                /*if(objSR.Payment_Status__c=='Payment Pending' || 
                   objSR.Payment_Status__c=='Pay At School'){
                    
                    return 'Payment has not yet done by parent for the offer';
                }*/
            }
            else if(step.Step_Name__c=='Verification of Application'){
                if(string.isBlank(objSR.StudentId__c)){
                    return 'Please click on "Register" before approving the step';      
                }
                
                /*
                list<HexaBPM__SR_Price_Item__c> tempPriceList = new list<HexaBPM__SR_Price_Item__c>();
                tempPriceList = [select id from HexaBPM__SR_Price_Item__c where HexaBPM__SRPriceLine_Text__c = 'Registration Fee' and Status__c='Added' and HexaBPM__ServiceRequest__c=:objSR.id];
                if(tempPriceList!=null && tempPriceList.size()>0){
                    return 'Registration fee not paid by parent.';  
                }*/
            }
        }
        return strResult;
    }    
}