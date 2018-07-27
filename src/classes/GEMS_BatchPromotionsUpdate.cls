/**************************************************************************************************
* Name               : GEMS_BatchPromotionsUpdate                                                 *
* Description        : Implements logic for Promotions update                                     *
* Created Date       : 21/12/2017                                                                 *
* Created By         : Umair Khan (PWC Digital)                                                   *
* ----------------------------------------------------------------------------------------------- */

global class GEMS_BatchPromotionsUpdate implements Database.Batchable<sObject> {
     
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        string studentStatus = 'EN';
        string remark = 'Blocked';
        date todayDate = system.today();
        string query = GEMS_Utility.getAllFields(Promotion__c.getsObjectType().getDescribe());
        
        query = query.replace('FROM Promotion__c', ', Student__r.Current_Status__c,student__r.Primary_Contact_Email__c,student__r.School__r.Logo__c,school__r.Principal__r.Email__c FROM Promotion__c '); 
        query += ' Where active__c = true and Enable_Re_enrolment__c = true and Student__r.Current_Status__c =: studentStatus'+
				 ' and Re_Enrolment_Remark__c!=:remark and TC_Applied__c = false'+
		         ' and (Payment_Reminder_1__c=:todayDate or Payment_Reminder_2__c=:todayDate or Payment_Reminder_3__c=:todayDate ' +
		         ' or Re_Enrolment_End_Date__c=:todayDate or Re_Enrolment_Payment_Delay_Date__c=:todayDate or Re_Enrolment_Prior_Notification_Date__c=:todayDate or Re_Enrolment_Reminder_1__c=:todayDate ' +
		         ' or Re_Enrolment_Reminder_2__c=:todayDate or Re_Enrolment_Reminder_3__c=:todayDate or Re_Enrolment_Start_Date__c=:todayDate )';
        
        system.debug('---query----'+query);
        return Database.getQueryLocator(query);
    }


	global void execute(Database.BatchableContext BC, list<promotion__c> promotionList) {
        updatePromotion(promotionList);
	}
     
	global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    
    public void updatePromotion(list<promotion__c> promotionList){
        
        set<id> academyYear = new set<id>();
        map<id, decimal> priceByAY = new map<id, decimal>();
    	map<string, decimal> priceByGrade = new map<string, decimal>();
	    	
       	list<Promotion__c> lstPromotions = new list<Promotion__c>();
        
        try{
            
            if(promotionList!=null && promotionList.size()>0){
	            for(Promotion__c pr: promotionList){
	                academyYear.add(pr.Academic_Year__c);
	            }
            }	
            
            if(academyYear!=null && academyYear.size()>0){
	            
				for(Amount__c obj : [select id,grade_lookup__c,Amount__c,By_Grade__c,Academic_Year__c from Amount__c where Academic_Year__c IN : academyYear
				 				     and Stage_Formula__c='RE-ENROL']){
					if(obj.grade_lookup__c!=null && obj.By_Grade__c == true)
						priceByGrade.put(obj.Academic_Year__c+'-'+obj.grade_lookup__c,obj.Amount__c);	
					
					if(obj.By_Grade__c == false)
						priceByAY.put(obj.Academic_Year__c,obj.Amount__c);
	 			}
		 			
            }
           
           	list<Promotion__c> updatedPromotions = new list<Promotion__c>();
            
            if(promotionList!=null && promotionList.size()>0){
	                
				for(Promotion__c prm: promotionList){
	                system.debug('---prm---'+prm.Student_Email_Address__c);
	                prm.Student_Email_Address__c = prm.student__r.Primary_Contact_Email__c;
	                prm.School_Logo__c = prm.student__r.School__r.Logo__c;
	                prm.Principal_Email__c = prm.school__r.Principal__r.Email__c;
	                
	                if(string.isNotBlank(prm.Student_Email_Address__c)){   
	                	if(prm.Re_Enrolment_Prior_Notification_Date__c != null && prm.Re_Enrolment_Prior_Notification__c == false && prm.Re_Enrolment_Prior_Notification_Date__c == System.today())
	                    	prm.Re_Enrolment_Prior_Notification__c = true;
	                            
						if(prm.Re_Enrolment_Start_Date__c != null &&  prm.Re_Enrolment_Start_Notification__c == false && prm.Re_Enrolment_Start_Date__c == System.today())
	                    	prm.Re_Enrolment_Start_Notification__c = true;
	
	                    if(prm.Re_Enrolment_End_Date__c != null && prm.Re_Enrolment_End_Notification__c == false && prm.Re_Enrolment_End_Date__c == System.today())
	                    	prm.Re_Enrolment_End_Notification__c = true;
	                            
	                    if(prm.Re_Enrolment_Payment_Delay_Date__c != null && prm.Re_Enrolment_Payment_Delay_Notification__c == false && prm.Re_Enrolment_Payment_Delay_Date__c == System.today())
	                    	prm.Re_Enrolment_Payment_Delay_Notification__c = true;
	                        
	                    if(prm.Re_Enrolment_Remark__c =='Pending' && prm.Re_Enrolment_Reminder_1__c != null && prm.Re_Enrolment_1st_Notification__c == false && prm.Re_Enrolment_Reminder_1__c == System.today())
	                        prm.Re_Enrolment_1st_Notification__c = true;
	                            
	                    if(prm.Re_Enrolment_Remark__c =='Pending' && prm.Re_Enrolment_Reminder_2__c != null && prm.Re_Enrolment_2nd_Notification__c == false && prm.Re_Enrolment_Reminder_2__c == System.today())
	                        prm.Re_Enrolment_2nd_Notification__c = true;
	
	                    if(prm.Re_Enrolment_Remark__c =='Pending' && prm.Re_Enrolment_Reminder_3__c != null && prm.Re_Enrolment_3rd_Notification__c == false && prm.Re_Enrolment_Reminder_3__c == System.today())
	                        prm.Re_Enrolment_3rd_Notification__c = true;
	                        
	                    if(prm.Re_Enrolment_Remark__c =='Fee Pending' && prm.Payment_Reminder_1__c != null &&  prm.Payment_1st_Notification__c == false && prm.Payment_Reminder_1__c == System.today())
	                        prm.Payment_1st_Notification__c = true;
	                            
	                    if(prm.Re_Enrolment_Remark__c =='Fee Pending' && prm.Payment_Reminder_2__c != null &&  prm.Payment_2nd_Notification__c == false && prm.Payment_Reminder_2__c == System.today())
	                        prm.Payment_2nd_Notification__c = true;
	
	                    if(prm.Re_Enrolment_Remark__c =='Fee Pending' && prm.Payment_Reminder_3__c != null && prm.Payment_3rd_Notification__c == false && prm.Payment_Reminder_3__c == System.today())
	                        prm.Payment_3rd_Notification__c = true;
	                }
	                
	                if(priceByAY!=null && priceByAY.size()>0 && priceByAY.containsKey(prm.Academic_Year__c))
	    				prm.Re_Enrol_Fee__c = priceByAY.get(prm.Academic_Year__c);
	    				
	    			if(priceByGrade!=null && priceByGrade.size()>0 && priceByGrade.containsKey(prm.Academic_Year__c+'-'+prm.Grade__c))
	    				prm.Re_Enrol_Fee__c = priceByGrade.get(prm.Academic_Year__c+'-'+prm.Grade__c);
	                
	                updatedPromotions.add(prm);
	            }
        	}
            system.debug('updatedPromotions = ' +updatedPromotions);
            if(!updatedPromotions.isEmpty())
                update updatedPromotions;
                
        	
        	list<OTP_Verification__c> deleteInactiveOTP = [select id from OTP_Verification__c where Inactive__c = true];
        	if(deleteInactiveOTP!=null && deleteInactiveOTP.size()>0){
           		delete deleteInactiveOTP;
           	}
        }
        catch(Exception ex){
            system.debug('Exception GEMS_BatchPromotionsUpdateHandler  >>>>>>' + ex.getMessage());
        }
    }

}