/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Convert SR into person account.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    V.No    Date        Updated By    Description
---------------------------------------------------------------------------------------------------------------------             
    V1.1    27-09-2017  Shadiya        Flag added - "Open_Online_Payment__c" to exclude SR price items where online payment is disabled.
*****************************************************************************************************************************/
public without sharing class GEMS_EnrollmentCtlrHelper {
    
    public GEMS_EnrollmentCtlrHelper(){
        
    }
    
    public static string saveAndRedirect(HexaBPM__Service_Request__c objSR){
        string message = 'Success';
        if(objSR!=null){
            message = submitSR(objSR);
        }
        return message;
    }
    
    public static string submitSR(HexaBPM__Service_Request__c objSR){
        string message = 'Success';
        Savepoint spdata = Database.setSavepoint();
        try{
            //V1.1
            list<HexaBPM__SR_Price_Item__c> priceList = [select id from HexaBPM__SR_Price_Item__c where status__c ='Added' and HexaBPM__ServiceRequest__c=:objSR.id  AND Open_Online_Payment__c='Yes'];
            
            Set<String> srStatusCodes = new Set<String>();
            srStatusCodes.add('SUBMITTED');
            srStatusCodes.add('REGISTERED');
            
            Map<String,String> srStatusMap = new Map<String,String>();
            if(!srStatusCodes.isEmpty()){
                for( HexaBPM__SR_Status__c srStatus : [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c IN :srStatusCodes] ){
                    srStatusMap.put(srStatus.HexaBPM__Code__c,srStatus.Id);
                }
            }
            
            if(priceList!=null && priceList.size()>0){
                
            }
            else{
                objSR.HexaBPM__Internal_SR_Status__c = srStatusMap.get('SUBMITTED');
                objSR.HexaBPM__External_SR_Status__c = srStatusMap.get('SUBMITTED');
                objSR.HexaBPM__Submitted_Date__c = system.today();
                objSR.HexaBPM__Submitted_DateTime__c = system.now();
            }
            /**/
            
            objSR.company_lookup_father__c = (objSR.company__c!=null && objSR.company__c!='') ? gems_Utility.getCompany(objSR.company__c) : null;
            objSR.company_lookup_mother__c = (objSR.company_mother__c!=null && objSR.company_mother__c!='') ? gems_Utility.getCompany(objSR.company_mother__c) : null;
            objSR.company_lookup_guardian__c = (objSR.company_guardian__c!=null && objSR.company_guardian__c!='') ? gems_Utility.getCompany(objSR.company_guardian__c) : null;
            
            
            objSR.Sys_Business_Unit_Father__c = (objSR.Business_Unit_Father__c!=null && objSR.Business_Unit_Father__c!='') ? gems_Utility.getSchool(objSR.Business_Unit_Father__c).id : null;
            objSR.Sys_Business_Unit_Mother__c = (objSR.Business_Unit_Mother__c!=null && objSR.Business_Unit_Mother__c!='') ? gems_Utility.getSchool(objSR.Business_Unit_Mother__c).id : null;
            objSR.Sys_GEMS_School_Father__c = (objSR.GEMS_School_Father__c!=null && objSR.GEMS_School_Father__c!='') ? gems_Utility.getSchool(objSR.GEMS_School_Father__c).id : null;
            objSR.Sys_GEMS_School_Mother__c = (objSR.GEMS_School_Mother__c!=null && objSR.GEMS_School_Mother__c!='') ? gems_Utility.getSchool(objSR.GEMS_School_Mother__c).id : null;
            objSR.Sys_GEMS_School_Sibling__c = (objSR.Sibling_GEMS_School__c!=null && objSR.Sibling_GEMS_School__c!='') ? gems_Utility.getSchool(objSR.Sibling_GEMS_School__c).id : null;
            
            if(objSR.Primary_Contact__c == 'Father'){
                objSR.Primary_Contact_Name__c = objSR.First_Name_Father__c + ' ' + objSR.Last_Name_Father__c;
            }
            else if(objSR.Primary_Contact__c == 'Mother'){
                objSR.Primary_Contact_Name__c = objSR.First_Name_Mother__c + ' ' + objSR.Last_Name_Mother__c;
            }
            else if(objSR.Primary_Contact__c == 'Guardian'){
                objSR.Primary_Contact_Name__c = objSR.First_Name_Guardian__c + ' ' + objSR.Last_Name_Guardian__c;
            }   
                
            update objSR;
            
            if(priceList!=null && priceList.size()>0){
                
            }
            
        }catch(exception ex){
            message = ex.getMessage()+ '------'+ ex.getLineNumber();
            Database.rollback(spdata);
        }
        return message;
    }
    
    
    
    
}