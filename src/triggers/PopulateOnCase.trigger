/* This is a Trigger to auto populate details on Parent Complaints on Case
   Author : Khushboo Agarwal
   Date   : 04/05/2017
*/


trigger PopulateOnCase on Case (before insert) {
    
    map<id,account> newMap = new map<id,account>();
	Set<String> studName = new set<String>();
	for(Case cObj : trigger.new){
		if(cObj.Student_Name__c != null){
			studName.add(cObj.Student_Name__c);
		}}
		
		System.debug('StudNameSet---->'+studName);
		
	for(Account aObj : [select Id,Name,Student_Id__c,GradeLookup__c,School__c,School__r.name,School_Code__c,father__c, mother__c FROM Account where Id=:studname AND Record_Type_Name__c='Student'])
				newMap.put(aObj.id, aObj);	
	
	
		   
				
		if(newMap!=null && newMap.size()>0){
		for( Case c : trigger.new){
			
			
			
			if(newMap.get(c.Student_Name__c).Father__c !=null){
				c.Parent_Name__c=newMap.get(c.Student_Name__c).Father__c;
			}else{
				c.Parent_Name__c=newMap.get(c.Student_Name__c).Mother__c;
		   
			}
			
			c.Student_ID__c=newMap.get(c.Student_Name__c).Student_Id__c;
			c.GradeLookup__c=newMap.get(c.Student_Name__c).GradeLookup__c;
			c.School_Name__c=newMap.get(c.Student_Name__c).School__r.name;
			c.School_ID__c=newMap.get(c.Student_Name__c).School_Code__c;

		}
			
	}
}