public without sharing class GEMS_recieptTriggerHelper {
 	
	
	public static void setReceiptNumber(List<Reciept__c> receiptList){
		Map<String,String>schoolToLastReceiptNumberMap = new Map<String,String>();
		List<School__c> schoolUpdateList = new List<School__c>();
		List<String>schoolCodes = new List<String>();
		for(Reciept__c rObj :  receiptList){
			if(!String.isBlank(rObj.School_Code__c)){
			schoolCodes.add(rObj.School_Code__c);
			}
			
		}
		
		for(School__c sObj : [SELECT 
		                            Id__c,
		                            Id,
		                            Short_Name__c,
		                            Sys_Last_Receipt_No__c
		                      FROM School__c
		                      WHERE ID__c
		                      IN :schoolCodes 
		                      AND Sys_Last_Receipt_No__c != '']){ 
		                      	
			schoolToLastReceiptNumberMap.put(sObj.Id__c,sObj.Sys_Last_Receipt_No__c);
		}
		
		Integer rNumber;
		for(Reciept__c rObj :  receiptList){ 
			
			if(!String.isBlank(rObj.School_Code__c) && schoolToLastReceiptNumberMap.containsKey(rObj.School_Code__c))
			{
				rNumber =  Integer.valueOf(schoolToLastReceiptNumberMap.get(rObj.School_Code__c));
			
			    rObj.Sys_Receipt_No__c = String.valueOf(++rNumber).leftpad(8,'0');
		        schoolToLastReceiptNumberMap.put(rObj.School_Code__c,rObj.Sys_Receipt_No__c);
			}
		}
		
		for(School__c sObj : [SELECT 
		                            Id__c,
		                            Id,
		                            Short_Name__c,
		                            Sys_Last_Receipt_No__c
		                      FROM School__c
		                      WHERE ID__c
		                      IN :schoolCodes  ]){
		    sObj.Sys_Last_Receipt_No__c =  schoolToLastReceiptNumberMap.get(sObj.ID__c);             	
			schoolUpdateList.add(sObj);
			
		}
		if(!schoolUpdateList.isEmpty()){
			update schoolUpdateList;
		}
	}
	
	
	public static void updateRecieptDetails(list<Reciept__c> recieptList){
		map<string,id> mapOfRecordAndSchool = new map<string,id>();
		set<string> schoolCodeSet = new set<string>();
		
		for(Reciept__c obj : recieptList){
			if(string.isNotBlank(obj.School_Code__c)){
				schoolCodeSet.add(obj.School_Code__c);	
			}
		}	
		
		if(schoolCodeSet!=null && schoolCodeSet.size()>0){
			for(school__c obj : [select id,Id__c from school__c where Id__c IN : schoolCodeSet]){
				mapOfRecordAndSchool.put(obj.id__c, obj.id);	
			}	
		}
		
		system.debug('--mapOfRecordAndSchool--'+mapOfRecordAndSchool);
		if(mapOfRecordAndSchool!=null && mapOfRecordAndSchool.size()>0){
			for(Reciept__c obj : recieptList){
				if(string.isNotBlank(obj.School_Code__c))
					obj.school__c = mapOfRecordAndSchool.get(obj.School_Code__c);	
			}	
		}
	}    
}