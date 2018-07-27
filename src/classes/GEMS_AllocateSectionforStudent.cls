/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   27th March 2017
    Description :   Re-Allocate the Section based to the Student. Controller to the GEMS_Allocate_Section_for_Student Page
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_AllocateSectionforStudent{
    map<string,string> MapUrlParameters = new map<string,string>();
    public list<SelectOption> SectionList{get;set;}
    public string selectedSection{get;set;}
    public string StudentId;
    public string GradeId;
    
    public string SchoolName{get;set;}
    public string Name{get;set;}
    public string AcademicYear{get;set;}
    public string GradeValue{get;set;}
    
    public list<Section_Master__c> lstSections{get;set;}
    public list<SectionDetailsWrap> lstSectionsWrap{get;set;}
    public GEMS_AllocateSectionforStudent(){
        MapUrlParameters = new map<string,string>();
        lstSections = new list<Section_Master__c>();
        if(apexpages.currentPage().getparameters()!=null)
            MapUrlParameters = apexpages.currentPage().getparameters();
            
        SectionList = new list<SelectOption>();
        if(MapUrlParameters.get('GradeId')!=null){
            GradeId = MapUrlParameters.get('GradeId');
            PrepareSections();
        }
        selectedSection = '';
        if(MapUrlParameters.get('StudentId')!=null){
            StudentId = MapUrlParameters.get('StudentId');
            map<string,string> MapAcademicYears = new map<string,string>();
            Schema.DescribeFieldResult AcademicYearfieldResult = Academic_Year__c.Year__c.getDescribe();
            list<Schema.PicklistEntry> YearOptions = AcademicYearfieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : YearOptions){
                MapAcademicYears.put(f.getValue(),f.getLabel());
            }
            for(Account acc:[Select Id,Section__c,Section_Display__c,Academic_Year__c,Academic_Year__r.Year__c,GradeLookup__c,GradeLookup__r.Grade_Display__c FROM Account where Id=:StudentId]){
                if(acc.Academic_Year__c!=null && acc.Academic_Year__r.Year__c!=null && MapAcademicYears.get(acc.Academic_Year__r.Year__c)!=null)
                    AcademicYear = MapAcademicYears.get(acc.Academic_Year__r.Year__c);
                GradeValue = acc.GradeLookup__r.Grade_Display__c;
                if(acc.Section__c!=null)
                    selectedSection = acc.Section__c;
            }
        }
        if(MapUrlParameters.get('School')!=null){
            SchoolName = MapUrlParameters.get('School');
        }
        if(MapUrlParameters.get('Name')!=null){
            Name = MapUrlParameters.get('Name');
        }
    }
    public void PrepareSections(){
        SectionList = new list<SelectOption>();
        if(GradeId!=null && GradeId!=''){
            for(Section_Master__c sc:[select Id,Name,Section__c from Section_Master__c where Grade__c=:GradeId and Section__c!= 'TEMP' and Section_ID__c!= null order by Section__c ]){
                SectionList.add(new SelectOption(sc.Id,sc.Section__c));
                if(selectedSection=='')
                    selectedSection = sc.Id;   
            }
            PrepareSectionDetails();
        }
        
            
    }
    public void PrepareSectionDetails(){
        lstSections = new list<Section_Master__c>();
        lstSectionsWrap = new list<SectionDetailsWrap>();
        if(GradeId!=null && GradeId!=''){
            set<string> setSectionIds = new set<string>();
            
            for(Section_Master__c sec : [Select Id,Name,Section__c,Alloted__c,Boys__c,Girls__c,Grade__c,Grade_Display__c,Max_Strength__c,Stream__c,SEN__c,First_Language_English__c from Section_Master__c where Grade__c=:GradeId and Section_ID__c!= null order by Section__c]){
                lstSections.add(sec);
                setSectionIds.add(sec.Id);
                
                SectionDetailsWrap  objSec = new SectionDetailsWrap();
                objSec.SecMaster = sec;
                lstSectionsWrap.add(objSec);
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
                for(SectionDetailsWrap objwrap:lstSectionsWrap){
                    if(MapTCRequestCount.get(objwrap.SecMaster.Id)!=null)
                        objwrap.TCReqCount = MapTCRequestCount.get(objwrap.SecMaster.Id);
                    else
                        objwrap.TCReqCount = 0;
                }
            }
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
    public pagereference allocateStudents(){
        system.debug('selectedSection==>'+selectedSection);
        pagereference pg;
        if(selectedSection!=null && selectedSection!='' && StudentId!=null && StudentId!=''){
            Account acc = new Account(Id=StudentId);
            acc.Section__c = selectedSection;
            try{
                update acc;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Section Alloted Successfully.'));
                pg = new pagereference('/'+StudentId);
                pg.setredirect(true);

            }catch(Exception ex){
                
            }
            PrepareSectionDetails();
        }
        return pg;
    }
    public pagereference CancelAllocation(){
        pagereference pg;
        pg = new pagereference('/'+StudentId);
        pg.setredirect(true);
        return pg;
    }
}