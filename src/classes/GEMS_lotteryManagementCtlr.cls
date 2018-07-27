public without sharing class GEMS_lotteryManagementCtlr {
    public school__c objSchool {get; set;}
    public lottery_management__c objLot {get; set;}
    public string deleteLot {get; set;}
    
    public list<SelectOption> academicYearList {get; set;}
    public list<SelectOption> gradeList {get; set;}
    public list<SelectOption> stageList {get; set;}
    
    public list<HexaBPM__Service_Request__c> listOfSR {get; set;}
    public list<lottery_management__c> existingLot {get; set;}
    
    public integer lotNumber;
    
    string schoolId;
    public string stage {get; set;}
        
    public GEMS_lotteryManagementCtlr() {
       try{
	        schoolId = apexpages.currentPage().getparameters().get('schoolId');
	        if(string.isNotBlank(schoolId)){
	        	stage = '';
		        objLot = new lottery_management__c();
		        academicYearList = new List<SelectOption>();
	            gradeList = new List<SelectOption>();
	            stageList = new List<SelectOption>();
	                
		        getSchoolDetails();
		        
		        getStagesForLot();
		        
		        
	        }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
        }
    }
    
    public void getSchoolDetails(){
		list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:schoolId];
		if(tempSchoolList!=null && tempSchoolList.size()>0){
			objSchool = tempSchoolList[0];
		}	
		objLot.School__c = objSchool.id;
		academicYearList = GEMS_Utility.getAcademicYearsForSchool(objSchool.id__c, NULL);
    	objLot.Academic_year__c = (academicYearList.size() > 0) ? academicYearList[0].getValue() : NULL;
    	
    	if (objLot.Academic_year__c != NULL) {
    		getGradesforSchool();
        }
        
        getExistingLot();
	}
	
	public void getGradesforSchool(){
		if (objLot.Academic_year__c != NULL) {
			gradeList = GEMS_Utility.getGradesForSchool(objSchool.id__c, getLookupValue(objLot.Academic_year__c,academicYearList), NULL);
	    	objLot.Grade__c = (gradeList.size()>0)  ? gradeList[0].getValue() :NULL ;
		}	
	}
	
	public void getStagesForLot(){
		set<string> stagesRequired = new set<string>();
		stagesRequired.add('REGISTERED');
		stagesRequired.add('SUBMITTED');
		stagesRequired.add('SCREENING TEST APPROVED');
		
		for(HexaBPM__SR_Status__c objStatus : [select id, name,Stage__c ,HexaBPM__Code__c from HexaBPM__SR_Status__c where HexaBPM__Code__c IN : stagesRequired]){
			stageList.add(new SelectOption(objStatus.Id, objStatus.name));	
		}
		stageList.add(new SelectOption('Waitlist', 'Waitlist'));	
	}
	
	public void generateLot(){
		try{
			
			if(listOfSR!=null && listOfSR.size()>0)
				listOfSR.clear();
				
			listOfSR = new list<HexaBPM__Service_Request__c>();
			
			if(objLot.Academic_Year__c==null || string.isBlank(objLot.Gender__c) || 
			   objLot.Grade__c==null || string.isBlank(objLot.Lot_Allocation__c) || 
			   objLot.Lot_Capacity__c==null || objLot.Lot_Capacity__c == 0 ||
			   objLot.Lottery_Date__c==null || string.isBlank(stage) ||
			   objLot.School__c==null){
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  'Please fill in all required fields')); 	
			}
			else{
				string academicYear = objLot.Academic_Year__c;
				string grade = objLot.Grade__c;
				string gender = objLot.Gender__c;
				string school = objLot.School__c;
				string lotAllocation = objLot.Lot_Allocation__c;
				string recordTypeName = 'Enrollment';
				integer capacity = integer.valueOf(objLot.Lot_Capacity__c);
				
				string query = 'select id, name, Passport_No__c, Lottery_Management__c ,first_name__c, last_name__c, createdDate from HexaBPM__Service_Request__c'+
							   ' where Academic_Year__c =: academicYear and GradeLookup__c=: grade'+
							   ' and School__c=: school and Lottery_Management__c=null'+
							   ' and HexaBPM__Record_Type_Name__c=:recordTypeName';
				if(gender!='All'){
					query = query+' and gender__c=: gender';
				}
				
				if(lotAllocation!='All' && lotAllocation=='Sibling Same School'){
					query = query+ ' and Siblings_studying_in_a_GEMS_school__c=true and Sys_GEMS_School_Sibling__c=:school';	
				}
				
				if(lotAllocation!='All' && lotAllocation=='Sibling All School'){
					query = query+ ' and Siblings_studying_in_a_GEMS_school__c=true';
				}
				
				if(lotAllocation!='All' && lotAllocation=='General Public'){
					query = query+ ' and Sys_GEMS_School_Sibling__c!=:school';
				}
				
				if(stage == 'Waitlist'){
					query = query+ ' and Registration_Type__c =: stage';	
				}else{
					string Current = 'Current';
					query = query+ ' and HexaBPM__Internal_SR_Status__c =: stage and Registration_Type__c =: Current';
				}
				
				list<HexaBPM__Service_Request__c> tempList = new list<HexaBPM__Service_Request__c>();
				tempList = database.query(query);
				if(tempList!=null && tempList.size()>0 && tempList.size()>capacity){
					integer offSet = 0;
					integer range = tempList.size()-capacity;
					offSet = Math.mod(Math.round(Math.random()*range+1), range);
					
					if(offset>2000)
						offSet = Math.mod(Math.round(Math.random()*capacity+1), capacity);
						
					query = query+' Order By random__c LIMIT '+capacity+ ' OFFSET '+OFFSET;	
				}else{
					query = query+' Order By random__c LIMIT '+capacity;	
				}
				
				listOfSR = database.query(query);	
				if(listOfSR!=null && listOfSR.size()>0){
					
				}
				else{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,  'No Enquiry exist, Please refine your search criteria.'));	
				}
			}
		}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
        }
	}
	
	public void saveLot(){
		try{
			if(listOfSR!=null && listOfSR.size()>0){
				if(existingLot!=null && existingLot.size()>0){
					objLot.lot_number__c = existingLot.size()+1;		
				}
				else{
					objLot.lot_number__c = 1;
				}
				
				if(stage == 'Waitlist'){
					objLot.Lottery_Type__c = 'Waiting List';	
				}else{
					objLot.stage__c = stage;
				}
				insert objLot;
				for(HexaBPM__Service_Request__c obj : listOfSR){
					obj.Lottery_Management__c = objLot.id;	
				}	
				update listOfSR;
				listOfSR = new list<HexaBPM__Service_Request__c>();
				objLot = new lottery_management__c();
				objLot.gender__c = 'All';
				objLot.lot_allocation__c = 'All';
				objLot.School__c = schoolId;
				getExistingLot();
			}
		}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage())); 
            system.debug('----msg----'+e.getLineNumber());
        }	
	}
	
	public void cancelLot(){
		listOfSR = new list<HexaBPM__Service_Request__c>();
	}
	
	public void getExistingLot(){
		existingLot = new list<lottery_management__c>();
		existingLot = [select id, CreatedDate, name, lot_Number__c,Report_URL__c ,Academic_Year__r.Academic_Year__c, Grade__r.Grade_Display__c, Lot_Allocation__c, Lot_Capacity__c
					   from lottery_management__c 
					   where school__c =: schoolId];
		if(existingLot!=null && existingLot.size()>0)
			lotNumber = existingLot.size();
	}
	
	public void deleteLot(){
		lottery_management__c objDel = new lottery_management__c();
		boolean firstLotDeleted = false;
		for(lottery_management__c obj : existingLot){
			if(obj.id==deleteLot){
				objDel = obj;
				if(obj.lot_Number__c == 1){
					firstLotDeleted = true;		
				} 		
				break;
			}	
		}
		delete objDel;
		getExistingLot();
		if(existingLot!=null && existingLot.size()>0){
			for(lottery_management__c obj : existingLot){
				if(firstLotDeleted ==  true){
					obj.lot_Number__c = obj.lot_Number__c-1;	
				}
				else{
					if(obj.lot_Number__c!=1){
						obj.lot_Number__c = obj.lot_Number__c-1;
					}
				}
				
			}
			update 	existingLot;
		}
	}
	
	public String getLookupValue(string key, List<SelectOption>soList) {
        String retStr;
        for (SelectOption so : soList) {
            if (so.getValue() == key) {
                retStr = so.getLabel();
            }
        }
        return retStr;
    }
}