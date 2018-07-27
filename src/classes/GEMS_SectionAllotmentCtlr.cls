/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   27th March 2017
    Description :  Allot Section based to the selected Students. Controller to the GEMS_SectionAllotmentPage
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    Version    Date          Name    Description
    ==================================================
    v1.0       16-Oct-2017   Leeba   Added Section_ID__c not null check in the SOQL Query
    v1.1	   04-Feb-2018	 Swati	 Pagination
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

public without sharing class GEMS_SectionAllotmentCtlr {

    public string selectedAcademicYear{get;set;}
    public string selectedAcademicYear1{get;set;}
    public string selectedGrade{get;set;}    
    public string selectedStream{get;set;}
    public string selectedSection{get;set;}
    public string selectedSectionTo{get;set;}
    public string schoolId{get;set;}
    
    public list<SelectOption> academicYearList{get; set;}
    public list<SelectOption> gradeList{get; set;}
    public list<SelectOption> StreamList{get; set;}
    public list<SelectOption> SectionList{get;set;}
    public list<SelectOption> SectionList1{get;set;}
    public list<SelectOption> CurriculumList{get;set;}
    
    public string SelectedSchool{get;set;}
    public Grade__c objGrade{get;set;}
    public map<string,string> MapStreamPickList{get;set;}
    map<string,string> MapCurriculumPicklist = new map<string,string>();
    
    public list<Section_Master__c> lstSections{get;set;}
    public list<Account> lstStudents{get;set;}
    
    //v1.1
    public Paginate paginater {get;set;}
	public list<StudentWrap> lstStudentsWrap{get;set;}
	public List<List<StudentWrap>> fulllstStudentsWrap{get;set;}
        
    public string StudentId{get;set;}
    public string StudentName{get;set;}
    public string gradevalue;
    public string selectedGrade1;
    
    public boolean showList{get;set;}
    map<string,string> MapAcademicYearPicklist = new map<string,string>();
    map<string,string> MapUrlParameters = new map<string,string>();
    public list<SelectOption> AllotSectionList{get;set;}
    
    public list<SectionDetailsWrap> lstSectionDetails{get;set;}
    map<string,string> MapGradeLkpVals = new map<string,string>();
    map<string,string> MapGradeLkpValsWithStreams = new map<string,string>();
    
    public GEMS_SectionAllotmentCtlr(){
        lstSectionDetails = new list<SectionDetailsWrap>();
        lstStudentsWrap = new list<StudentWrap>();
        selectedAcademicYear1 = '';
        MapStreamPickList = new map<string,string>();
        showList = false;
        try{
            MapUrlParameters = new map<string,string>();
            if(apexpages.currentPage().getparameters()!=null)
                MapUrlParameters = apexpages.currentPage().getparameters();
            Schema.DescribeFieldResult fieldResult = Grade__c.Stream__c.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple){
                MapStreamPickList.put(f.getValue(),f.getLabel());
            } 

            Schema.DescribeFieldResult fieldResult1 = Academic_Year__c.Curriculum__c.getDescribe();
            list<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
            for(Schema.PicklistEntry f : ple1){
                MapCurriculumPicklist.put(f.getValue(),f.getLabel());
            }   
            
            Schema.DescribeFieldResult AcademicYearfieldResult1 = Academic_Year__c.Year__c.getDescribe();
            list<Schema.PicklistEntry> YearOptions = AcademicYearfieldResult1.getPicklistValues();
            for(Schema.PicklistEntry f : YearOptions){
                MapAcademicYearPicklist.put(f.getValue(),f.getLabel());
            }
            
            selectedAcademicYear = '';
            selectedGrade = '';
            selectedStream = '';
            selectedSection = '';
            selectedSectionTo = '';
            objGrade = new Grade__c();
            schoolId = apexpages.currentPage().getparameters().get('schoolId');
            prepareAcademicYears();
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));    
        }   
    
    }   
    public void prepareAcademicYears(){
        academicYearList = new List<SelectOption>();
        if(schoolId!=null && schoolId!=''){
            for(school__c sch:[select id, name, id__c from school__c where id=:schoolId]){
                selectedSchool = sch.Name;
            }
            list<Academic_Year__c> lstAYs = new list<Academic_Year__c>();
            integer ActiveAYStart;
            for(Academic_Year__c AY:[select Id,Name,Year__c,Active__c,Sys_Active__c from Academic_Year__c where School__c=:schoolId and Year__c!=null order by Year__c]){
                if(AY.Sys_Active__c && AY.Year__c!=null && AY.Year__c!=''){
                    integer CurYearVal = integer.valueOf(AY.Year__c);
                    if(ActiveAYStart==null || (ActiveAYStart!=null && ActiveAYStart>CurYearVal)){
                        ActiveAYStart = CurYearVal;
                    }
                }
                lstAYs.add(AY);
            }
            map<string,string> MapAcademicYear = new map<string,string>();
            for(Academic_Year__c AY:lstAYs){//Active__c=true and
                integer CurrentYear;
                if(AY.Year__c!=null && AY.Year__c!='')
                    CurrentYear = integer.valueOf(AY.Year__c);
                if(ActiveAYStart!=null && CurrentYear!=null && ActiveAYStart<=CurrentYear){
                    if(MapAcademicYear.get(AY.Year__c)==null){
                        if(selectedAcademicYear1=='')
                            selectedAcademicYear1 = AY.Year__c;
                        if(MapAcademicYearPicklist.get(AY.Year__c)!=null)
                            academicYearList.add(new selectoption(AY.Year__c,MapAcademicYearPicklist.get(AY.Year__c)));
                    }
                    MapAcademicYear.put(AY.Year__c,AY.Year__c);
                }
                //MapGradeId.put(gd.Grade__c,gd.Id);
            }
            if(selectedAcademicYear1!=null && selectedAcademicYear1!=''){
                PrepareCurriculum();
            }
        }
    }
    public void PrepareCurriculum(){
        CurriculumList = new list<SelectOption>();
        selectedAcademicYear = '';
        if(selectedAcademicYear1!=null && selectedAcademicYear1!=''){
            //PrepareSectionDetails();   
            for(Academic_Year__c ac:[select Id,Name,Curriculum__c,Year__c from Academic_Year__c where School__c=:schoolId and Year__c=:selectedAcademicYear1 and Curriculum__c!=null]){//Active__c = true and 
                if(MapCurriculumPickList.get(ac.Curriculum__c)!=null){
                    CurriculumList.add(new selectoption(ac.Id,MapCurriculumPickList.get(ac.Curriculum__c)));
                    if(selectedAcademicYear=='')
                        selectedAcademicYear = ac.Id;
                }
            }
            if(selectedAcademicYear!=null && selectedAcademicYear!='')
                PrepareGrades();
        }
    }
    public void PrepareGrades(){
        gradeList = new List<SelectOption>();
        selectedGrade = '';
        MapGradeLkpVals = new map<string,string>();
        if(selectedAcademicYear!=null && selectedAcademicYear!=''){
            map<string,string> MapGrades = new map<String,string>();
            map<string,string> MapGradeId = new map<string,string>();
            for(Grade__c gd:[select Id,Name,Grade__c,Grade_Display__c,Sys_Sort_Val__c,Stream__c from Grade__c where School__c=:schoolId and Academic_Year__c=:selectedAcademicYear order by Sys_Sort_Val__c]){
                if(MapGrades.get(gd.Grade_Display__c)==null){
                    if(selectedGrade=='')
                        selectedGrade = gd.Grade_Display__c;
                    //selectedGrade1 = gd.Id;
                    MapGradeLkpVals.put(gd.Grade_Display__c,gd.Id);            
                    gradeList.add(new selectoption(gd.Grade_Display__c,gd.Grade_Display__c));
                }
                MapGradeLkpValsWithStreams.put(gd.Grade_Display__c+'_'+gd.Stream__c,gd.Id);
                MapGrades.put(gd.Grade_Display__c,gd.Grade_Display__c);
                //MapGradeId.put(gd.Grade__c,gd.Id);
            }
            if(selectedGrade!=null && selectedGrade!=''){
                PrepareStreams();
                //PrepareSections();
            }
        }
    }
    public void PrepareStreams(){
        StreamList = new list<SelectOption>();
        selectedStream = '';
        if(selectedGrade!=null && selectedGrade!=''){
            //PrepareSectionDetails();   
            for(Grade__c gd:[select Id,Name,Stream__c,Grade__c,Grade_Display__c from Grade__c where Grade_Display__c=:selectedGrade and Academic_Year__c=:selectedAcademicYear and Stream__c!=null]){
                if(MapStreamPickList.get(gd.Stream__c)!=null){
                    StreamList.add(new selectoption(gd.Stream__c,MapStreamPickList.get(gd.Stream__c)));
                    selectedStream = gd.Stream__c; 
                }
            }
             if(selectedStream!=null && selectedStream!='')
                PrepareSections();
        }
    }
    
    map<string,string> MapSections = new map<string,string>();
    public void PrepareSections(){
        SectionList = new list<SelectOption>();
        MapSections = new map<string,string>();
        selectedSection = '';
        selectedSectionTo = '';
        //SectionList.add(new SelectOption('','--None--'));
        if(selectedStream!=null && selectedStream!=''){
            PrepareSectionDetails();
            //v1.0
            for(Section_Master__c sc:[select Id,Name,Section__c from Section_Master__c where Grade__r.Academic_Year__c=:selectedAcademicYear and Grade__r.Grade_Display__c=:selectedGrade and Grade__r.Stream__c=:selectedStream and Section_ID__c!= null order by Section__c]){
                SectionList.add(new SelectOption(sc.Id,sc.Section__c));
                MapSections.put(sc.Id,sc.Section__c);
                //if(selectedSection=='')
                    //selectedSection = sc.Id;   
            }
            RePrepareAllotSectionList();
        }
    }
    
    public void PrepareSectionsforAssigning(){
        SectionList = new list<SelectOption>();
        //selectedSection = '';
        selectedSectionTo = '';
        SectionList.add(new SelectOption('','--None--'));
        if(selectedStream!=null && selectedStream!=''){
            //v1.0
            for(Section_Master__c sc:[select Id,Name,Section__c from Section_Master__c where Grade__r.Academic_Year__c=:selectedAcademicYear and Grade__r.Grade_Display__c=:selectedGrade and Grade__r.Stream__c=:selectedStream and Section_ID__c!= null order by Section__c]){
                SectionList1.add(new SelectOption(sc.Id,sc.Section__c));
                //if(selectedSection=='')
                    //selectedSection = sc.Id;   
            }
        }
    }
    
    public void RePrepareAllotSectionList(){
        AllotSectionList = new list<SelectOption>();
        AllotSectionList.add(new SelectOption('','--None--'));
        for(string sec : MapSections.keySet()){
            if(selectedSection!=sec && MapSections.get(sec)!='TEMP')
                AllotSectionList.add(new SelectOption(sec,MapSections.get(sec)));
        }
    }
    
    public void PrepareSectionDetails(){
        lstSections = new list<Section_Master__c>();
        lstSectionDetails = new list<SectionDetailsWrap>();
        if(selectedStream!=null && selectedStream!=''){
            set<string> setSectionIds = new set<string>();
            for(Section_Master__c sec : [Select Id,Name,Section__c,Alloted__c,Boys__c,Girls__c,Grade__c,
            Grade_Display__c,Max_Strength__c,Stream__c,SEN__c,First_Language_English__c from Section_Master__c where Grade__r.Academic_Year__c=:selectedAcademicYear and Grade__r.Grade_Display__c=:selectedGrade and Grade__r.Stream__c=:selectedStream order by Section__c]){
                lstSections.add(sec);
                setSectionIds.add(sec.Id);
                
                SectionDetailsWrap  objSec = new SectionDetailsWrap();
                objSec.SecMaster = sec;
                lstSectionDetails.add(objSec);
            }
            
            /* Code to Calculate the TC Requests count for each section*/
            set<string> setStudentIds = new set<string>();
            if(setSectionIds.size()>0){
                for(Account acc:[Select Id from Account where Section__c IN:setSectionIds and Recordtype.DeveloperName='Student' and Current_Status__c='EN']){
                    setStudentIds.add(acc.Id);
                }
            }
            map<string,integer> MapTCRequestCount = new map<string,integer>();
            if(setStudentIds.size()>0){
                for(HexaBPM__Service_Request__c SR:[Select Id,Student__c,Is_SR_Closed__c,Student__r.Section__c from HexaBPM__Service_Request__c where Student__c IN:setStudentIds and Is_SR_Closed__c=false and Recordtype.DeveloperName='TC_Request' and Student__r.Section__c!=null]){
                    integer RecCount = 0;
                    if(MapTCRequestCount.get(SR.Student__r.Section__c)!=null)
                        RecCount = MapTCRequestCount.get(SR.Student__r.Section__c);
                    RecCount = RecCount + 1;
                    MapTCRequestCount.put(SR.Student__r.Section__c,RecCount);
                }
                
                for(SectionDetailsWrap objwrap:lstSectionDetails){
                    if(MapTCRequestCount.get(objwrap.SecMaster.Id)!=null)
                        objwrap.TCReqCount = MapTCRequestCount.get(objwrap.SecMaster.Id);
                    else
                        objwrap.TCReqCount = 0;
                }
            }
        }
    }
    public void ListStudents(){
        showList = true;
        selectedSectionTo = '';
        lstStudents = new list<Account>();
        lstStudentsWrap = new list<StudentWrap>();

        if(selectedSection=='')
            selectedSection=null;

        if(selectedGrade!=null && selectedstream!=null && MapGradeLkpValsWithStreams.get(selectedGrade+'_'+selectedstream)!=null)
            selectedGrade1 = MapGradeLkpValsWithStreams.get(selectedGrade+'_'+selectedstream);
            
        if(StudentId!='' && StudentName!=''){
            for(Account student:[Select Id,Name,Section_Display__c,Tentative_Joining_Date__c,Date_of_Join__c,Student_Id__c,Gender__c,Stream__c,FirstName,LastName,Child_have_any_special_education_needs__c,First_Language__c,Current_Status__c from Account where School__c=:schoolId and  RecordType.DeveloperName='Student' and Academic_Year__c =:selectedAcademicYear and Stream__c=:selectedstream and GradeLookup__c=:selectedGrade1 and Student_Id__c=:StudentId and Name like:('%'+StudentName+'%') and Section__c=:selectedSection and Current_Status__c = 'EN']){
                lstStudents.add(student);
            }
        }else if(StudentId!='' && StudentName==''){
            for(Account student:[Select Id,Name,Section_Display__c,Tentative_Joining_Date__c,Date_of_Join__c,Student_Id__c,Gender__c,Stream__c,FirstName,LastName,Child_have_any_special_education_needs__c,First_Language__c,Current_Status__c from Account where School__c=:schoolId and  RecordType.DeveloperName='Student' and Academic_Year__c =:selectedAcademicYear and Stream__c=:selectedstream and GradeLookup__c=:selectedGrade1 and Student_Id__c=:StudentId and Section__c=:selectedSection and Current_Status__c = 'EN']){
                lstStudents.add(student);
            }
        }else if(StudentName!='' && StudentId==''){
            for(Account student:[Select Id,Name,Section_Display__c,Tentative_Joining_Date__c,Date_of_Join__c,Student_Id__c,Gender__c,Stream__c,FirstName,LastName,Child_have_any_special_education_needs__c,First_Language__c,Current_Status__c from Account where School__c=:schoolId and  RecordType.DeveloperName='Student' and Academic_Year__c =:selectedAcademicYear and Stream__c=:selectedstream and GradeLookup__c=:selectedGrade1 and Name like:('%'+StudentName+'%') and Section__c=:selectedSection and Current_Status__c = 'EN']){
                lstStudents.add(student);
            }
        }else if(StudentName=='' && StudentId==''){
            for(Account student:[Select Id,Name,Section_Display__c,Tentative_Joining_Date__c,Date_of_Join__c,Student_Id__c,Gender__c,Stream__c,FirstName,LastName,Child_have_any_special_education_needs__c,First_Language__c,Current_Status__c from Account where School__c=:schoolId and  RecordType.DeveloperName='Student' and Academic_Year__c=:selectedAcademicYear and Stream__c=:selectedstream and GradeLookup__c=:selectedGrade1 and Section__c=:selectedSection and Current_Status__c = 'EN']){
                lstStudents.add(student);
            }
        }
        
        //v1.1 Start
        Integer pageSize = integer.valueOf(System.Label.Pagination_Size);
	    		
		this.paginater = new Paginate(lstStudents.size(), pageSize);
		
		lstStudentsWrap = new list<StudentWrap>();
		fulllstStudentsWrap = new List<List<StudentWrap>>();
		
		list<StudentWrap> tempCC = new list<StudentWrap>();
		Integer i = 0;	

        for(Account student:lstStudents){
            StudentWrap objwrap = new StudentWrap();
            objwrap.std = student;
            objwrap.IsSelected = false;
            
            tempCC.add(objwrap);
		    		
			i++;
			if(i == pageSize){
				this.fulllstStudentsWrap.add(tempCC);
				tempCC = new List<StudentWrap>();
				i = 0;
			}
        }
        if(!tempCC.isEmpty()){
			this.fulllstStudentsWrap.add(tempCC);
		}
		//Gets the correct list of data to show on the page
		this.lstStudentsWrap = this.fulllstStudentsWrap.get(this.paginater.index);
		//v1.1 end
    }
    
    
    public void allocateStudents(){
        system.debug('selectedSection==>'+selectedSection);
        if(lstStudentsWrap!=null && lstStudentsWrap.size()>0){
            if(selectedSectionTo!=null && selectedSectionTo!=''){
                list<Account> lstStudentsUpdt = new list<Account>();
                
                //v1.1 Start
                list<StudentWrap> tempList = new list<StudentWrap>();
		    	
		    	for(integer i=0; i<=fulllstStudentsWrap.size()-1; i++){
		    		for(StudentWrap obj : this.fulllstStudentsWrap.get(i)){
		    			if(obj.IsSelected == true){
		    				tempList.add(obj);
		    			}
		    		}	
		    	}
		    	
                for(StudentWrap stdwrap:tempList){
                    system.debug('stdwrap==>'+stdwrap.IsSelected);
                    if(stdwrap.IsSelected && selectedSectionTo!=null && selectedSectionTo!=''){
                        Account acc = new Account();
                        acc.Id = stdwrap.std.Id;
                        acc.Section__c = selectedSectionTo;
                        lstStudentsUpdt.add(acc);
                    }
                }
                try{
                    if(lstStudentsUpdt!=null && lstStudentsUpdt.size()>0){
                        upsert lstStudentsUpdt;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Section Alloted Successfully.'));
                    }
                    listStudents();
                    PrepareSectionDetails();
                }catch(Exception e){
                    
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select value in "Allocate Section" for Section Allocation.'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please select atleast one student for Section Allocation.'));
        }
    }
    
    public pagereference CancelChanges(){
        Pagereference pg = new pagereference('/'+schoolId);
        pg.setredirect(true);
        return pg;
    }
    
    public pageReference RedirectToMainActionPage(){
        pagereference redirectPage = new pagereference('/apex/GEMS_SectionManagement?schoolId='+schoolId);
        redirectPage.setredirect(true);
        return redirectPage;
    }
    
    public class StudentWrap{
        public Account std{get;set;}
        public boolean isSelected{get;set;}
        public StudentWrap(){
            std = new Account();
            isSelected = false;
        }
    }
    /* Wrapper Class to store the Section Details and TC Requests count */
    public class SectionDetailsWrap{
        public Section_Master__c SecMaster{get;set;}
        public integer TCReqCount{get;set;}
        public SectionDetailsWrap(){
            TCReqCount = 0;
            SecMaster = new Section_Master__c();
        }
    }
    
    //v1.1  start
    public PageReference previousPage(){
		this.paginater.decrement();
		return changeData();
	}

	public PageReference nextPage(){
		this.paginater.increment();
		return changeData();
	}
	
	public PageReference updatePage(){
		this.paginater.updateNumbers();
		return changeData();
	}
	
	public PageReference changeData(){
		this.lstStudentsWrap = this.fulllstStudentsWrap.get(this.paginater.index);
		return null;
	} //v1.1 End
	
}