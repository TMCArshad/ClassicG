/************************************************************************************
* Name               : GEMS_ClasswiseStrengthCntlr                                                               *
* Description        : Implements logic for Classwise Strength page                                    *
* Created Date       : 11/04/2018                                                               *
* Created By         : Leeba Shibu (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 
**************************************************************************************************/

public without sharing class GEMS_ClasswiseStrengthCntlr{
    public Account objAcc{get;set;}
    public string SchoolId{get;set;}
    public string SchoolName{get;set;}
    transient public list<Account> lstAcc{get;set;}
    transient public list<Promotion__c> lstPromo{get;set;}
    public list<Grade> lstGrades{get;set;}
    public string sDate;
    Public string selectedcurriculum{get;set;}
    public List<SelectOption> CurriculumList { get;set; }
    public Academic_Year__c AY{get;set;}
    public GEMS_ClasswiseStrengthCntlr(){
        objAcc = new Account();
        sDate = ApexPages.currentPage().getParameters().get('DOJ');
        SchoolId = apexpages.currentPage().getParameters().get('Id');
        lstAcc = new list<Account>();
        AY = new Academic_Year__c();
        if(ApexPages.currentPage().getParameters().get('Curriculum')!=null)
            AY.Curriculum__c = ApexPages.currentPage().getParameters().get('Curriculum');
        if(sDate!=null && sDate!=''){
            objAcc.Date_of_Join__c = Date.parse(sDate);
            FetchRecords();
        }
        
        getCurriculumList();
        
    }
    //display the curriculum list
    public List<SelectOption> getCurriculumList(){    
        List<SelectOption> options =  new List<SelectOption>();    
        options.add(new selectOption('None','--- None ---'));    
        Schema.DescribeFieldResult fieldResult = School__c.Curriculum__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        for(Schema.picklistEntry f:ple){    
            options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }    
        return Options;    
    }      
    public void FetchRecords(){
        lstAcc = new list<Account>();
        lstGrades = new list<Grade>();
        string AcademicYearId;
        system.debug('==>'+objAcc.Date_of_Join__c);
        
        if(objAcc.Date_of_Join__c==null){
            GEMS_Utility.addPageError('Please provide an As on Date');
        }
        
        //Get the Academic year Id based on the "As on date" and the Curriculum
        if(AY.Curriculum__c!=null && AY.Curriculum__c!=''){
            for(Academic_Year__c AY:[Select Id from Academic_Year__c where School__c=:SchoolId and Start_Date__c<=:objAcc.Date_of_Join__c and End_Date__c>=:objAcc.Date_of_Join__c and Curriculum__c=:AY.Curriculum__c]){
                AcademicYearId = AY.Id;
            }
        }else{
            GEMS_Utility.addPageError('Please choose a Curriculum');
        }
         // If no Academic year exists with the given date and curriculum give error
        if(AcademicYearId==null){
            GEMS_Utility.addPageError('No Academic year exists with the chosen curriculum and Date');
        }
        
        system.debug('Academic year===>'+AcademicYearId);
        
         //Get the Cancel TC during that period meaning the Students would be Enrolled now but were TC during the "As on Date"      
        map<Id, HexaBPM__Service_Request__c> accToSrMap = new map<Id, HexaBPM__Service_Request__c>();       
        for(HexaBPM__Service_Request__c SR : [SELECT Id, Student__c, Name, HexaBPM__External_Status_Name__c, HexaBPM__Record_Type_Name__c, HexaBPM__External_SR_Status__r.SR_Closed_Status__c from HexaBPM__Service_Request__c WHERE School__c =:SchoolId  AND HexaBPM__Record_Type_Name__c = 'TC_Request' AND HexaBPM__External_Status_Name__c = 'Cancelled' AND Transaction_Date__c < :objAcc.Date_of_Join__c AND Transaction_Date__c >= :objAcc.Date_of_Join__c AND sys_check_cancel_date_is_leave_date__c = false  ] ) {
            accToSrMap.put(SR.Student__c, SR);
        }
        map<string,set<string>> mapGradeSections = new map<string,set<string>>();
        map<string,integer> MapSectionFemaleCount = new map<string,integer>();
        map<string,integer> MapSectionMaleCount = new map<string,integer>();
        
        //If the Cancel TC query returns rows then exclude those students while querying the accounts.
        if(accToSrMap.size()>0){
            for(Account acc:[Select Id,Name,Date_of_Join__c,IsPersonAccount,Student_Id__c,School__c,Current_Status__c,Academic_Year__c,GradeLookup__c,Section__c,Section__r.Section__c,GradeLookup__r.Grade_Display__c,Gender__c from Account where Id NOT IN:accToSrMap.keyset() and Date_of_Join__c<=:objAcc.Date_of_Join__c AND School__c =:SchoolId AND ((Current_Status__c != 'CN' OR Current_Status__c!='TF') OR (Current_Status__c= 'CN' AND Cancel_Date__c > :objAcc.Date_of_Join__c)) AND (Leave_Date__c>=:objAcc.Date_of_Join__c OR Leave_Date__c = NULL ) limit 10000]){
                lstAcc.add(acc);                
            }
        }else{
        	//If Cancel TC query did not return any rows then this query
            for(Account acc:[Select Id,Name,Date_of_Join__c,IsPersonAccount,Student_Id__c,School__c,Current_Status__c,Academic_Year__c,GradeLookup__c,Section__c,Section__r.Section__c,GradeLookup__r.Grade_Display__c,Gender__c from Account where Date_of_Join__c<=:objAcc.Date_of_Join__c AND School__c =:SchoolId AND ((Current_Status__c != 'CN' OR Current_Status__c!='TF') OR (Current_Status__c= 'CN' AND Cancel_Date__c > :objAcc.Date_of_Join__c)) AND (Leave_Date__c>=:objAcc.Date_of_Join__c OR Leave_Date__c = NULL) and Section__c!=null limit 10000]){
                lstAcc.add(acc);
            }
        }
        
        system.debug('list of accounts===>'+lstAcc);
        lstPromo = new list<Promotion__c>();
        map<string,Promotion__c> MapStudentPromotion = new map<string,Promotion__c>();
        map<string,string> MapGradeNames = new map<string,string>();
        map<string,string> MapGradeStream = new map<string,string>();
        map<string,string> MapSectionNames = new map<string,string>();
        map<string,string> MapStreamLabels = new map<string,string>();
        //To the the stream label
        
        Schema.DescribeFieldResult fieldResult = Grade__c.Stream__c.getDescribe();
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            MapStreamLabels.put(f.getValue(),f.getLabel());
        } 
        
        // To get the Promotion records belonging to the Students got in the above query for the Academic year Id that we got above
        if(lstAcc.size()>0 && AcademicYearId!=null){
            for(Promotion__c pm:[Select Id,Academic_Year__c,Grade__c,Section__c,Student_Gender__c,Section__r.Alloted__c,Section__r.Section__c,Student__c,Grade__r.Grade_Display__c,Grade__r.Stream__c from Promotion__c where Student__c IN:lstAcc and Academic_Year__c=:AcademicYearId and Section__c!=null and Grade__c!=null]){
                lstPromo.add(pm);
                MapStudentPromotion.put(pm.Student__c,pm); 
                system.debug('mappromotion===>'+MapStudentPromotion);
                set<string> setGrades = new set<string>();
                if(mapGradeSections.get(pm.Grade__c)!=null)
                    setGrades = mapGradeSections.get(pm.Grade__c);
                setGrades.add(pm.Section__c);
                mapGradeSections.put(pm.Grade__c,setGrades);
                MapGradeNames.put(pm.Grade__c,pm.Grade__r.Grade_Display__c);
                MapSectionNames.put(pm.Section__c,pm.Section__r.Section__c);
                if(pm.Grade__c!=null && pm.Grade__r.Stream__c!=null && MapStreamLabels.get(pm.Grade__r.Stream__c)!=null){
                    string StreamLabel = MapStreamLabels.get(pm.Grade__r.Stream__c);
                    MapGradeStream.put(pm.Grade__c,StreamLabel);
                }
                //Based on the gender of the student calculaitng the count for each section
                if(MapStudentPromotion.size()>0){
                        if(pm.Student_Gender__c=='Male'){
                            integer MaleCount = 0;
                            if(MapSectionMaleCount.get(pm.Section__c)!=null)
                                MaleCount = MapSectionMaleCount.get(pm.Section__c);
                            MaleCount = MaleCount+1;
                            MapSectionMaleCount.put(pm.Section__c,MaleCount);
                        }else{
                            integer FemaleCount = 0;
                            if(MapSectionFemaleCount.get(pm.Section__c)!=null)
                                FemaleCount = MapSectionFemaleCount.get(pm.Section__c);
                            FemaleCount = FemaleCount+1;
                            MapSectionFemaleCount.put(pm.Section__c,FemaleCount);
                        }
                }else{
                    GEMS_Utility.addPageError('No record exist for the chosen date and curriculum');
                    
                }
            }
        }
        system.debug('AcademicYearId===>'+AcademicYearId);
        system.debug('MapGradeNames===>'+MapGradeNames);
        system.debug('MapSectionNames===>'+MapSectionNames);
        list<string> lstGradesBySort = new list<string>();
        for(string GradeId : MapGradeNames.keyset()){
            lstGradesBySort.add(GradeId);
        }
        lstGradesBySort.sort();
        //Calculating the Grade Strength
        for(string GradeId : lstGradesBySort){
            Grade objGrd = new Grade();
            objGrd.GradeName = MapGradeNames.get(GradeId);
            objGrd.Stream = MapGradeStream.get(GradeId);
            integer GradeStrength = 0;
            integer GradeMaleStrength = 0;
            integer GradeFemaleStrength = 0;
            list<Section> lstSections = new list<Section>();
            for(string SecId : mapGradeSections.get(GradeId)){
                if(MapSectionNames.get(SecId)!=null){
                    Section objSec = new Section();
                    objSec.SectionName = MapSectionNames.get(SecId);
                    objSec.MaleCount = 0;
                    objSec.FemaleCount = 0;
                    if(MapSectionMaleCount.get(SecId)!=null){
                        objSec.MaleCount = MapSectionMaleCount.get(SecId);
                        GradeMaleStrength = GradeMaleStrength + objSec.MaleCount;
                    }
                    if(MapSectionFemaleCount.get(SecId)!=null){
                        objSec.FemaleCount = MapSectionFemaleCount.get(SecId);
                        GradeFemaleStrength = GradeFemaleStrength + objSec.FemaleCount;
                    }
                    objSec.Strength = objSec.MaleCount+objSec.FemaleCount;
                    GradeStrength = GradeStrength + objSec.Strength;
                    objSec.SNo = lstSections.size()+1;
                    lstSections.add(objSec);
                }
            }
            objGrd.lstSections = lstSections;
            system.debug('lstSections==>'+lstSections);
            objGrd.TotalGradeStrength = GradeStrength;
            objGrd.TotalGradeMaleCount = GradeMaleStrength;
            objGrd.TotalGradeFemaleCount = GradeFemaleStrength;
            lstGrades.add(objGrd);
        }
        system.debug('lstGrades==>'+lstGrades);
        //lstAcc = new list<Account>();
    }
    
    // Exporting the results to Excel
    
    public pagereference ExportResults(){
        string FormattedDOJ;
        if(objAcc.Date_of_Join__c!=null)
            FormattedDOJ = objAcc.Date_of_Join__c.format();
        pagereference pg = new pagereference('/apex/GEMS_ClasswiseStrengthExport?DOJ='+FormattedDOJ+'&Curriculum='+AY.Curriculum__c+'&Id='+SchoolId);
        pg.setRedirect(true);
        return pg;
    }
    
    //Wrapper class for Grade
    public class Grade{
        public string GradeName{get;set;}
        public string Stream{get;set;}
        public list<Section> lstSections{get;set;}
        public integer TotalGradeStrength{get;set;}
        public integer TotalGradeMaleCount{get;set;}
        public integer TotalGradeFemaleCount{get;set;}
    }
    
    //Wrapper class for Section
    public class Section{
        public string SectionName{get;set;}
        public integer Strength{get;set;}
        public integer SNo{get;set;}
        public integer MaleCount{get;set;}
        public integer FemaleCount{get;set;}
        public Section(){
            SectionName = '';
        }
    }
}