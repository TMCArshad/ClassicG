/**************************************************************************************************
 * Name               : GEMS_CC_InsertPriceItem                                                    *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         Swati-PWC         	25/12/2017                                              *
 **************************************************************************************************/
global without sharing class GEMS_CC_InsertPriceItem implements HexaBPM.iCustomCodeExecutable { 
    
    global String EvaluateCustomCode(HexaBPM__Service_Request__c objSR, HexaBPM__Step__c step) {
        String msg = 'Failure';
        
        try {
            HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
            if(objSR!=null && string.isNotBlank(objSR.id)){
                SR = objSR; 
            }
            else if(step!=null && string.isNotBlank(step.id)){
                list<HexaBPM__Service_Request__c> tempSRList = [select id,HexaBPM__Record_Type_Name__c,HexaBPM__External_Status_Name__c,GradeLookup__c,
                                                                       Grade_Original__c, stream__c, academic_year__c, school__c
                                                                from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c];
                SR = tempSRList[0];
            }
            
            set<string> stageSet = new set<string>();
            
            if(SR.HexaBPM__Record_Type_Name__c == 'Enrollment' && (SR.HexaBPM__External_Status_Name__c=='Draft' || SR.HexaBPM__External_Status_Name__c=='Submitted')){
                stageSet.add('REGISTRATION');
            }
            else if(SR.HexaBPM__Record_Type_Name__c == 'Enrollment' && SR.HexaBPM__External_Status_Name__c!='Draft' && SR.HexaBPM__External_Status_Name__c!='Submitted'){
                stageSet.add('ENROLLMENT');
                stageSet.add('OFFER LETTER GENERATION');
                stageSet.add('NEW ADMISSION');
            }
            
            else if(SR.HexaBPM__Record_Type_Name__c == 'Re_Enrolment'){
                stageSet.add('RE-ENROL');
            }
            else if(SR.HexaBPM__Record_Type_Name__c == 'TC_Request'){
                stageSet.add('TC');
            }
            else{
                stageSet.add('SR.HexaBPM__External_Status_Name__c');
            }
            
            system.debug('--stageSet--'+stageSet);
            system.debug('--stageSet--'+SR.GradeLookup__c);
            system.debug('--stageSet--'+SR.Academic_Year__c);
            system.debug('--stageSet--'+SR.school__c);
            system.debug('--stageSet--'+SR.stream__c);
            
            list<Amount__c> amountList = new list<Amount__c>();
            
            if(stageSet.contains('REGISTRATION') || stageSet.contains('ENROLLMENT') || 
               stageSet.contains('OFFER LETTER GENERATION') || stageSet.contains('NEW ADMISSION')){
                amountList = [select id,Tution_fee_percentage__c,Tuition_Fee_Amount__c,Grade__c ,Amount__c, School__c, Stream__c,Fee_Master__c,Stage_Lookup__c,Stage_Lookup__r.HexaBPM__Code__c
	                          from Amount__c where ((Stage_Lookup__r.HexaBPM__Code__c IN :stageSet) OR (Stage_Lookup__r.HexaBPM__Code__c ='STUDENT' AND Tution_fee_percentage__c!=0 AND Tution_fee_percentage__c!=NULL)) 
	                          and (By_Grade__c=false or (By_Grade__c=true and Grade_lookup__c = : SR.GradeLookup__c))
	                          and Academic_Year__c = : SR.Academic_Year__c and School__c = : SR.school__c]; //checking if record exist in amount object depending on grade, stream and fee type on SR  
			}
	        else if(stageSet.contains('RE-ENROL')){
	        	amountList = [select id,Tution_fee_percentage__c,Tuition_Fee_Amount__c,Grade__c ,Amount__c, School__c, Stream__c,Fee_Master__c,Stage_Lookup__c,Stage_Lookup__r.HexaBPM__Code__c
	                          from Amount__c where Stage_Lookup__r.HexaBPM__Code__c IN :stageSet 
	                          and By_Grade__c=true and Grade_lookup__c = : SR.GradeLookup__c
	                          and Stream__c = : SR.stream__c and Academic_Year__c = : SR.Academic_Year__c 
	                          and School__c = : SR.school__c]; //checking if record exist in amount object depending on grade, stream and fee type on SR
	        }
            //1.0
            system.debug('--amountList--'+amountList);
            if(amountList!=null && amountList.size()>0){
                for(Amount__c obj : amountList){
                	if(stageSet.contains('REGISTRATION') && obj.Stage_Lookup__r.HexaBPM__Code__c =='STUDENT'){
                		return 'Failure';	
                	}else{
                		return 'Success';	
                	}
                	
                }
            }
            else{
                return 'Failure';
            }
        }catch (Exception e) {
            msg = e.getMessage()+ '-----' + e.getLineNumber();
        }
        return msg;
    }
    
}