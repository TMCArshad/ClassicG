public without sharing class GEMS_BudgetMasterCtlr {
	
	public list<grade__c> gradeList {get; set;}
	public list<monthlyCapacityWrapper> monthlyCapacity {get; set;}
	
	public list<selectOption> AYList {get; set;}
    public list<selectOption> curriculumList {get; set;}
    
    public map<string,string> monthMap {get; set;}
    public list<string> inputMonthsList {get; set;}
    public map<string,string> yearMap {get; set;}
    
    public string selectedAY {get; set;}
    public string selectedCurriculum {get; set;}
    
    public string currentAY {get; set;}
    public string futureAY {get; set;}
    
    public school__c objSchool {get; set;}
    public Capacity_Master__c objCM {get; set;}
    
    public boolean showCurriculum {get;set;}
    public boolean showGradeTable {get;set;}
    
    public Academic_year__c AY {get; set;}
    
    public list<Monthly_Capacity__c> monthlyCapacityForDelete;
    
    public GEMS_BudgetMasterCtlr(){
    	try{
	    	string schoolId = apexpages.currentPage().getparameters().get('schoolId');
	    	if(string.isNotBlank(schoolId)){
	    		initializeValues();
	    		getSchoolDetails(schoolId);	
	    	}
    	}catch(exception e){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
    	}
    }
    
    public void initializeValues(){
    	selectedAY = '';
    	selectedCurriculum = '';
    	
    	showCurriculum = false;
    	showGradeTable = false;
    	
    	objCM = new Capacity_Master__c();
    	AY = new Academic_year__c ();
    	
    	monthMap = new map<string,string>();
    	monthMap.put('1','Jan');
    	monthMap.put('2','Feb');
    	monthMap.put('3','Mar');
    	monthMap.put('4','Apr');
    	monthMap.put('5','May');
    	monthMap.put('6','Jun');
    	monthMap.put('7','Jul');
    	monthMap.put('8','Aug');
    	monthMap.put('9','Sep');
    	monthMap.put('10','Oct');
    	monthMap.put('11','Nov');
    	monthMap.put('12','Dec');
    }
    
    public void getSchoolDetails(string schoolId){
    	list<school__c> tempSchoolList = [select id,id__c, name, logo__C from school__c where id=:schoolId];
		if(tempSchoolList!=null && tempSchoolList.size()>0){
			objSchool = tempSchoolList[0];
			getAcademicYear();
		}
    }
    
    public void getAcademicYear(){
    	AYList = new list<selectOption>();
    	AYList = GEMS_Utility.getAcademicYearsForSchool(objSchool.id__c, NULL);
        if(AYList!=null && AYList.size()>0){
			selectedAY = AYList[0].getValue();
		}else{
			selectedAY = '';
			AYList.add(new SelectOption('', '--None--'));
		}
        
    	getCurriculum();
    }
    
    public void getCurriculum(){
	    	
    	curriculumList = new list<selectOption>();
    	
    	list<Academic_year__c> tempList = [Select id, Start_Date__c, End_Date__c, Year__c,
				 								  Academic_Year__c
										   from Academic_year__c 
										   where Id = :selectedAY AND Year__c != NULL];
    	if(!tempList.isEmpty()){
    		ay = tempList[0];
    		
    		currentAY = ay.Academic_Year__c.substring(0,4); 
    		futureAY = ay.Academic_Year__c.substring(5,9);
    	}
	    	
		curriculumList = GEMS_Utility.getCurriculumsForSchool(objSchool.id__c, ay.year__c);
		if(curriculumList!=null && curriculumList.size()>0){
			selectedCurriculum = curriculumList[0].getValue();
		}else{
			selectedCurriculum = '';
			curriculumList.add(new SelectOption('', '--None--'));
		}
		
		if(curriculumList!=null && curriculumList.size()>1)
			showCurriculum = true;
		
		getGrades();
    }
    
    public void getGrades(){
    	
    	if(gradeList!=null && gradeList.size()>0){
    		gradeList.clear();
    		showGradeTable=false;
    	}
    	
    	gradeList = new list<grade__c>();
        string query = GEMS_Utility.getAllFields(Grade__c.getsObjectType().getDescribe());
        string selectedSchoolCode = objSchool.ID__c;
        string academicYear = AY.academic_year__c;

        query = query.replace('FROM Grade__c', ',School__r.ID__c,Academic_Year__r.curriculum__c FROM Grade__c ');
		query += ' WHERE School__r.ID__c =: selectedSchoolCode ';
		query += (academicYear != NULL )  ? 'AND Academic_Year_Display__c =:academicYear ' : '';
		query += (selectedCurriculum != NULL )  ? 'AND Academic_Year__r.curriculum__c =: selectedCurriculum ' : '';
		query += ' AND Active__c = true ';
		query += ' ORDER BY Sys_Sort_Val__c ';
        
        for (Grade__c grade : Database.query(query))
        	gradeList.add(grade);
        
        if(gradeList!=null && gradeList.size()>0){
        	showGradeTable=true;
        	initializeCapacityWrapper();
        }
    }
    
    public void initializeCapacityWrapper(){
    	monthlyCapacity = new list<monthlyCapacityWrapper>();
    	inputMonthsList = new list<string>();
		yearMap = new map<string,string>();
    	
    	Integer startMonth = AY.start_date__c.Month();
    	Integer endMonth = AY.end_date__c.Month();
    	Integer monthsBetween = AY.start_date__c.monthsBetween(AY.end_date__c);
    	
    	system.debug('---AY---'+AY);
    	system.debug('---currentAY---'+currentAY);
    	system.debug('---futureAY---'+futureAY);
    	system.debug('---startMonth---'+startMonth);
    	system.debug('---endMonth---'+endMonth);
    	system.debug('---monthsBetween---'+monthsBetween);
    	
    	string getMonth = '';
        integer newMonth = 0;
        for(integer i=0; i<=monthsBetween; i++){
        	getMonth = string.valueOf(startMonth+i);
        	if(integer.valueOf(getMonth)>12){
        		newMonth = newMonth+1;
        		inputMonthsList.add(string.valueOf(newMonth));
        		yearMap.put(string.valueOf(newMonth), futureAY);
        	}else{
        		inputMonthsList.add(getMonth);	
        		yearMap.put(getMonth, currentAY);
        	}
        }
    	system.debug('---inputMonthsList---'+inputMonthsList);
    	system.debug('---yearMap---'+yearMap);
    	map<string,Capacity_Master__c> existingCapacity = new map<string,Capacity_Master__c>();
    	monthlyCapacityForDelete = new list<Monthly_Capacity__c>();
    	
    	for(Capacity_Master__c objTemp : [select id, budget__c, capacity__c,grade__c,active__c,
    							   (select id, month__c, year__c,budget__c, 
    							   		   capacity__c
    							   	from Monthly_Capacity__r) 
    						from Capacity_Master__c where Academic_Year__c=:AY.id
    						and School__c=:objSchool.id and Curriculum__c=:selectedCurriculum
    						and grade__c!=null]){
    		
    		existingCapacity.put(objTemp.grade__c, objTemp);
    		monthlyCapacityForDelete.addAll(objTemp.Monthly_Capacity__r);
    	}
    	
    	map<string,string> tempMonthMap = new map<string,string>();
    	if(existingCapacity!=null && existingCapacity.size()>0){
	    	tempMonthMap.put('Jan','1');
	    	tempMonthMap.put('Feb','2');
	    	tempMonthMap.put('Mar','3');
	    	tempMonthMap.put('Apr','4');
	    	tempMonthMap.put('May','5');
	    	tempMonthMap.put('Jun','6');
	    	tempMonthMap.put('Jul','7');
	    	tempMonthMap.put('Aug','8');
	    	tempMonthMap.put('Sep','9');
	    	tempMonthMap.put('Oct','10');
	    	tempMonthMap.put('Nov','11');
	    	tempMonthMap.put('Dec','12');	
    	}
    	
    	if(gradeList!=null && gradeList.size()>0){
	    	for(grade__c obj : gradeList){
	    		
	    		if(existingCapacity!=null && existingCapacity.size()>0){
	    			monthlyCapacityWrapper MC = new monthlyCapacityWrapper();	
	    			MC.Grade = obj;
	    			MC.capacityMaster = existingCapacity.get(obj.id);
	    			MC.Capacity = existingCapacity.get(obj.id).Capacity__c;
	    			MC.Budget = existingCapacity.get(obj.id).Budget__c;
	    			for(Monthly_Capacity__c s :MC.capacityMaster.Monthly_Capacity__r){
		        		MC.inputMonthsBudget.put(tempMonthMap.get(s.month__c),s.capacity__c);
		            }
		    		monthlyCapacity.add(MC);
	    			
	    		}else{
		    		monthlyCapacityWrapper MC = new monthlyCapacityWrapper();
		    		MC.Grade = obj;
		    		for(string s :inputMonthsList){
		        		MC.inputMonthsBudget.put(s,0.0);
		            }
		    		monthlyCapacity.add(MC);
	    		}
	    	}
    	}
    }
    
    public class monthlyCapacityWrapper{
        public grade__c grade {get; set;}
        public map<string, decimal> inputMonthsBudget {get; set;}
        public decimal Capacity {get; set;}
        public decimal Budget {get; set;}
        public Capacity_Master__c capacityMaster {get; set;}
        
        public monthlyCapacityWrapper(){
            
            grade = new grade__c();
            Capacity = 0;
            Budget = 0;
            capacityMaster = new Capacity_Master__c();
            inputMonthsBudget = new map<string, decimal>();
        }
    }
    
    public pagereference saveCapacity(){
    	pagereference pg = null;
    	try{
    		
    		if(monthlyCapacity!=null && monthlyCapacity.size()>0){
    			list<Capacity_Master__c> listMaster = new list<Capacity_Master__c>();
    			list<Monthly_Capacity__c> listMonthly = new list<Monthly_Capacity__c>();
    			for(monthlyCapacityWrapper obj : monthlyCapacity){
    				
    				Capacity_Master__c objCapMaster = new Capacity_Master__c();
		    		objCapMaster.Academic_Year__c = AY.id;
		    		objCapMaster.Curriculum__c = selectedCurriculum;
		    		objCapMaster.School__c = objSchool.id;
		    		objCapMaster.Grade__c = obj.grade.id;
		    		objCapMaster.Capacity__c =  obj.capacity;
		    		objCapMaster.Budget__c = obj.Budget;
		    		objCapMaster.active__c = true;
		    		if(obj.capacityMaster!=null && string.isNotBlank(obj.capacityMaster.id)){
		    			objCapMaster.id = obj.capacityMaster.id;
		    		}
    				listMaster.add(objCapMaster);
    				
    			}	
    			
    			map<string,string> linkedMaster = new map<string,string>();
    			if(listMaster!=null && listMaster.size()>0){
    				upsert listMaster;
    				for(Capacity_Master__c obj : listMaster){
    					linkedMaster.put(obj.grade__c,obj.id);
    				}
    			}
    			
    			if(linkedMaster!=null && linkedMaster.size()>0){
    				if(monthlyCapacityForDelete!=null && monthlyCapacityForDelete.size()>0){
    					delete monthlyCapacityForDelete;
    				}
    				
    				for(monthlyCapacityWrapper obj : monthlyCapacity){
    					if(obj.inputMonthsBudget!=null && obj.inputMonthsBudget.size()>0){
		    				for(string month : obj.inputMonthsBudget.keyset()){
			    				Monthly_Capacity__c objMonthly = new Monthly_Capacity__c();
			    				objMonthly.Month__c = monthMap.get(month);
			    				objMonthly.Budget__c = obj.inputMonthsBudget.get(month);
			    				objMonthly.Capacity__c = obj.capacity;
			    				objMonthly.Capacity_Master__c = linkedMaster.get(obj.grade.id);
			    				objMonthly.Grade__c = obj.grade.id;
			    				objMonthly.Year__c = yearMap.get(month);
		    					listMonthly.add(objMonthly);
		    				}
	    				}
    				}	
    			}
    			
    			if(listMonthly!=null && listMonthly.size()>0){
    				insert listMonthly;
    				pg = page.GEMS_budgetMaster;
    				pg.getParameters().put('schoolId', objSchool.id);
                    pg.setRedirect(true); 
    			}
    		}
    	}catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,  e.getMessage()+'----'+e.getLineNumber())); 
            system.debug('----msg----'+e.getLineNumber());
        }
        return pg;
    }
}