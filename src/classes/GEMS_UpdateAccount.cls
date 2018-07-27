public without sharing class GEMS_UpdateAccount {
   
   
   public static void updateStudent(Id srId){
   	
   	HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
		String SRQueryStr = '';
		SRQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getSobjectType().getDescribe());
		SRQueryStr += ' WHERE Id=:srId ';
		for(HexaBPM__Service_Request__c obj : Database.Query(SRQueryStr)){
			SR = obj;
		}
	Account student;	
	if(SR.HexaBPM__Record_Type_Name__c == 'Edit_Critical_Data'){
		if(SR.Student__c != NULL){
			student = new Account(id = SR.Student__c);
			student.Academic_Year__c = SR.Academic_Year__c;
			student.Curriculum__c = SR.Curriculum__c;
			student.GradeLookup__c = SR.GradeLookup__c;
			student.Stream__c = SR.Stream__c;
			student.Section__c = SR.Section_Lookup__c;
		}
		update student;
		
	}	
		
   } 
}