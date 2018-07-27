global without sharing class GEMS_UpdateEnquiry {
   
   Webservice static String acceptEnquiry(String enId){

        String result = 'Success';
        try{
            Enquiry__c en = new Enquiry__c(id =enId);
            en.ownerId = UserInfo.getUserId();
            update en;
        }catch(Exception e){
               return e.getMessage();
        }
      return result;
    } 
     
}