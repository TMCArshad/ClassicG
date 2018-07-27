/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   1st August 2017
    Description :   Helper class for Promotion Trigger
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
     1.0         Swati-PWC          25/12/2017   
     1.1         Leeba-PwC          27/01/2018  Logic to close the Reenrolment SR when ReenrolmentFee is paid at school
     1.2         Leeba-PWC          14/2/2018   removed condition that checks Draft SR. Draft SR should also be closed. Ticket No - 177511
     1.3         Leeba-PWC          2/4/2018   added the logic to deactivate the scholarship records of previous year when new promotion gets created
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_PromotionTriggerHelper {
    // Logic to deactivate the earlier promotion records of the student whenevr a new promotion record is created
    public static void DeactivatePromotions(set<string> setStudent, set<string> setPromotionIds) {
        List<Promotion__c> lstpromo = new List<Promotion__c>();
        if(setStudent != null && setStudent.size() > 0) {
            for(Promotion__c pr:[Select Id,Active__c from Promotion__c where Id NOT IN:setPromotionIds and Student__c IN:setStudent and Active__c=true]){
                pr.Active__c = false;
                lstpromo.add(pr);
            }
            
            for(Promotion__c pr:[Select Id,Active__c,School__r.Logo__c,student__r.School__r.Logo__c,
                                        student__r.Primary_Contact_Email__c 
                                 from Promotion__c where Id IN:setPromotionIds and Student__c IN:setStudent and Active__c=true]){
                
                pr.Student_Email_Address__c = pr.student__r.Primary_Contact_Email__c;
                pr.School_Logo__c = pr.student__r.School__r.Logo__c;
                lstpromo.add(pr);
            }
            
            if(lstpromo.size()>0)
                update lstpromo;
        }
        
    }
    
    //1.3
     public static void DeactivateScholarships(set<string> setStudent, set<string> setPromotionIds, set<string>setAcademicyrId) {
     	List<Scholarship__c> lstscholarship = new List<Scholarship__c>();
        if(setStudent != null && setStudent.size() > 0 && setAcademicyrId != null && setAcademicyrId.size() > 0 ) {
            for(Scholarship__c sc:[Select Id,Active__c,Academic_Year__c,Student__c from Scholarship__c where Academic_Year__c NOT IN:setAcademicyrId and Student__c IN:setStudent and Active__c=true]){
                sc.Active__c = false;
                lstscholarship.add(sc);
            }
        if(lstscholarship.size()>0)
                update lstscholarship;
        }
     }
     
    //1.0
    public static void updateFee(list<Promotion__c> Promotion_List) {
        set<id> setAY = new set<id>();
        if(Promotion_List!=null && Promotion_List.size()>0){
            for(promotion__c obj : Promotion_List){
                setAY.add(obj.Academic_Year__c);    
            }
        }
        
        map<id, decimal> priceByAY = new map<id, decimal>();
        map<string, decimal> priceByGrade = new map<string, decimal>();
        
        if(setAY!=null && setAY.size()>0){
            for(Amount__c obj : [select id,grade_lookup__c,Amount__c,By_Grade__c,Academic_Year__c from Amount__c where Academic_Year__c IN : setAY
                                 and Stage_Formula__c='RE-ENROL']){
                if(obj.grade_lookup__c!=null && obj.By_Grade__c == true)
                    priceByGrade.put(obj.Academic_Year__c+'-'+obj.grade_lookup__c,obj.Amount__c);   
                
                if(obj.By_Grade__c == false)
                    priceByAY.put(obj.Academic_Year__c,obj.Amount__c);
            }
            
        }
        
        if(Promotion_List!=null && Promotion_List.size()>0){
            for(promotion__c obj : Promotion_List){
                
                if(priceByAY!=null && priceByAY.size()>0 && priceByAY.containsKey(obj.Academic_Year__c))
                    obj.Re_Enrol_Fee__c = priceByAY.get(obj.Academic_Year__c);
                    
                if(priceByGrade!=null && priceByGrade.size()>0 && priceByGrade.containsKey(obj.Academic_Year__c+'-'+obj.Grade__c))
                    obj.Re_Enrol_Fee__c = priceByGrade.get(obj.Academic_Year__c+'-'+obj.Grade__c);
            }
        }
    }
    //1.1 logic to close the Enrollment SR and the Price Item status as Payed if ReEnrollment Fee paid at school
    public static void ReEnrollmentFeePaid_Actions(set<string> StudentIds) {
        list<HexaBPM__Service_Request__c> lstSRTBU = new list<HexaBPM__Service_Request__c>();
        list<HexaBPM__SR_Price_Item__c> lstSRPTBU = new list<HexaBPM__SR_Price_Item__c>();
        string SRStatusId;
        for(HexaBPM__SR_Status__c status:[Select Id from HexaBPM__SR_Status__c where HexaBPM__Code__c='CLOSED']){
            SRStatusId = status.Id;
        }
        //1.2 logic to close draft SR as well
        for(HexaBPM__Service_Request__c SR:[select Id,HexaBPM__Internal_SR_Status__c,HexaBPM__External_SR_Status__c,(Select Id,HexaBPM__Status__c,Status__c from HexaBPM__SR_Price_Items1__r) from HexaBPM__Service_Request__c where Student__c IN:StudentIds and HexaBPM__Record_Type_Name__c='Re_Enrolment' and HexaBPM__IsClosedStatus__c=false and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false]){
            if(SR.HexaBPM__SR_Price_Items1__r!=null && SR.HexaBPM__SR_Price_Items1__r.size()>0){
                for(HexaBPM__SR_Price_Item__c SRP:SR.HexaBPM__SR_Price_Items1__r){
                    SRP.Status__c = 'Paid';
                    SRP.HexaBPM__Status__c = 'Paid';
                    lstSRPTBU.add(SRP);
                }
            }
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=SR.Id);
            objSR.HexaBPM__Internal_SR_Status__c = SRStatusId;
            objSR.HexaBPM__External_SR_Status__c = SRStatusId;
            objSR.Payment_Status__c = 'Paid';
            lstSRTBU.add(objSR);
        }
        if(lstSRPTBU.size()>0)
            upsert lstSRPTBU;
        if(lstSRTBU.size()>0)
            update lstSRTBU;
    }
}