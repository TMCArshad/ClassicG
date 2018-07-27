/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   1st August 2017
    Description :   Handler class for Promotion Trigger
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
     1.1         Leeba-PWC          2/4/2018   added the logic to deactivate the scholarship records of previous year when new promotion gets created
     1.2         Leeba-PWC          26/4/2018  capture the Re-enrol date when the Re-enrolment remark becomes Re-enroled,Company Fee Sponsered Re-enroled,GEMS Staff Renroled.
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_PromotionTriggerHandler {
    
    public void Execute_BI(list<Promotion__c> Promotion_List) {
    	GEMS_PromotionTriggerHelper.updateFee(Promotion_List); 
    }
    public void Execute_AI(list<Promotion__c> Promotion_List) {
     // Whenever a new Promotion is created for a Student execute the logic
        try{
            set<string> setStudent = new set<string>();
            set<string> setPromotionIds = new set<string>();
            set<string> setAcademicyrId = new set<string>();
            for(Promotion__c p:Promotion_List){
                if(p.Student__c!=null){
                    setStudent.add(p.Student__c);
                    setPromotionIds.add(p.Id);
                    setAcademicyrId.add(p.Academic_Year__c);
                }
            }
            if(setStudent.size()>0 && setPromotionIds.size()>0)
                GEMS_PromotionTriggerHelper.DeactivatePromotions(setStudent,setPromotionIds);
                GEMS_PromotionTriggerHelper.DeactivateScholarships(setStudent,setPromotionIds,setAcademicyrId);  //1.1
        }catch(Exception e){
            GEMS_Utility.LogException(e);   
        }
    }
    public void Execute_BU(list<Promotion__c> Promotion_List,Map<Id,Promotion__c> oldMap) {
        set<string> setStudentIds = new set<string>();
        for(Promotion__c pr:Promotion_List){
        	if(pr.Student__c!=null && pr.Reenrolment_fee_paid_at_School__c && oldMap.get(pr.Id).Reenrolment_fee_paid_at_School__c!=pr.Reenrolment_fee_paid_at_School__c)
        		setStudentIds.add(pr.Student__c);
        }
        if(setStudentIds.size()>0){
        	try{
            	GEMS_PromotionTriggerHelper.ReenrollmentFeePaid_Actions(setStudentIds); 
	        }catch(Exception e){
	            GEMS_Utility.LogException(e);   
	        }
        }
        //1.2
         for(Promotion__c pr:Promotion_List){
        	if(pr.Student__c!=null &&(pr.Re_Enrolment_Remark__c=='Company Fee Sponsored Re-Enroled'|| pr.Re_Enrolment_Remark__c=='GEMS Staff Re-Enroled'|| pr.Re_Enrolment_Remark__c=='Re-Enroled' || pr.Re_Enrolment_Remark__c=='Full Year Tuition Fee Paid' || pr.Re_Enrolment_Remark__c=='Fee Override') && oldMap.get(pr.Id).Re_Enrolment_Remark__c!=pr.Re_Enrolment_Remark__c){ 
        	 pr.Re_Enroled_Date__c = system.today();	  
            }
    
        }
    }
    public void Execute_AU(list<Promotion__c> Promotion_List,Map<Id,Promotion__c> oldMap) {    
       
    }
    public void Execute_BD(Map<Id,Promotion__c> oldMap){
    	
    }
       
}