/**
* Created by bilalnazir on 4/22/17.
* @author PWC
* @date 4/22/17
*
* @group Accounts
* @group-content /apex/GEMS_EmiratesID
*
* @description This class handles searching for students/guradian accounts.
*/

public without sharing class GEMS_EmiratesIDController {
    public String searchType { get; set; }
    public String updated { get; set; }
    public String studentName { get; set; }
    public String studentNumber { get; set; }
    public String academicYear { get; set; }
    public String grade { get; set; }
    public String section { get; set; }
    public String selectedSchool { get; set; }

    public List<StudentEmiratesIDAccount> studentEmiratesIDAccounts { get; set; }
    public List<StudentEmiratesIDSR> studentEmiratesIDServiceRequests { get; set; }

    public List<SelectOption>allGEMSSchoolListOptions { get; set; }
    public List<SelectOption>academicYearsListOptions { get; set; }
    public List<SelectOption>gradesListOptions { get; set; }
    public List<SelectOption>sectionsListOptions { get; set; }
	
	public school__c objSchool {get; set;}
	public string schoolId;
    public GEMS_EmiratesIDController() {
        loadSearchOptions();
    }


    public PageReference loadSearchOptions() {

        searchType = 'enrollment';
        updated = 'All';
        studentName = '';
        studentNumber = '';
        academicYear = '';
        grade = '';
        section = '';
        selectedSchool = '';

        studentEmiratesIDAccounts = null;
        studentEmiratesIDServiceRequests = null;
		
		schoolId = apexpages.currentPage().getparameters().get('schoolId');
        if(string.isNotBlank(schoolId)){
            getAllGemsSchools();
	        getAllAcademicYears();
	        getGradesForAcademicYear();
	        getSectionsForGrade();
        }
        return null;
    }


    /*******************************************************************************************************
    * @description perform search based on search type 'enrollment/enquiries'
    * @return None
    */
    public void search(){
        if(searchType == 'enrollment'){
            studentEmiratesIDServiceRequests = null;
            searchEnrollments();
        }
        else{
            studentEmiratesIDAccounts = null;
            searchEnquiries();
        }
    }

    public void searchEnrollments() {

        String queyrString = 'SELECT id, IsPersonAccount, Emirates_ID_Synced_Date__c, Emirates_ID_Expiry_Date__c, RecordType.DeveloperName, ' +
                'Student_Id__c, Name, firstName, lastName, Academic_Year__r.Academic_Year__c, Grade_Display__c, ' +
                'Father__r.Emirates_ID_Synced_Date__c, Father__r.Emirates_ID_Expiry_Date__c, Mother__r.Emirates_ID_Synced_Date__c, Mother__r.Emirates_ID_Expiry_Date__c ';

        queyrString += ' FROM Account WHERE RecordType.DeveloperName=\'Student\'';

        queyrString += (String.isNotBlank(selectedSchool) ? ' AND School__r.ID__c=\'' + String.escapeSingleQuotes(selectedSchool) + '\'' : '');
        queyrString += (String.isNotBlank(studentName) ? ' AND Name LIKE \'%' + String.escapeSingleQuotes(studentName) + '%\'' : '');
        queyrString += (String.isNotBlank(studentNumber) ? ' AND Student_Id__c LIKE \'%' + String.escapeSingleQuotes(studentNumber) + '%\'' : '');
        queyrString += String.isNotBlank(academicYear) ? ' AND Academic_Year__c=\'' + String.escapeSingleQuotes(academicYear) + '\'' : '';
        queyrString += String.isNotBlank(grade) ? ' AND GradeLookup__r.Name=\'' + String.escapeSingleQuotes(grade)+ '\'' : '';
        queyrString += String.isNotBlank(section) ? ' AND  GradeLookup__c in (select Grade__c FROM Section_Master__c WHERE Name=\'' + String.escapeSingleQuotes(section) + '\' )' : '';
        queyrString += (updated == 'Yes' ?
                ' AND (Emirates_ID_Synced_Date__c !=null OR Father__r.Emirates_ID_Synced_Date__c != null OR Mother__r.Emirates_ID_Synced_Date__c != null) ' : '');
        queyrString += (String.isNotBlank(section) ? ' AND (Section__c != null AND Section__r.Name=\'' + String.escapeSingleQuotes(section) +'\') ': '');

        queyrString += ' ORDER BY Name';

        try {
            //queyrString = escapeSosl(queyrString);

            studentEmiratesIDAccounts = new List<StudentEmiratesIDAccount>();
            List<Account> searchResults = (List<Account>) Database.query(queyrString);

            for (Account acc: searchResults) {
                studentEmiratesIDAccounts.add(new StudentEmiratesIDAccount(acc));
            }

        } catch (Exception ex) {
            System.debug('Query String ==>' + queyrString);
            System.debug('Exception ==>' + ex.getMessage());
        }

    }

    /*******************************************************************************************************
    * @description Search student information enqiries on Service Request object.
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    */
    public void searchEnquiries() {

        String queyrString = 'SELECT id, Last_Emirates_ID_Sync_Date__c, Emirates_ID_Expiry_Date__c, RecordType.DeveloperName, ' +
                'StudentId__c, Student__r.Name, First_Name__c, Last_Name__c, Academic_Year__r.Academic_Year__c, Grade_Display__c, ' +
                'Last_Emirates_ID_Sync_Date_Father__c, Emirates_ID_Expire_Date_Father__c, Last_Emirates_ID_Sync_Date_Mother__c, Emirates_ID_Expire_Date_Mother__c ';

        queyrString += ' FROM HexaBPM__Service_Request__c WHERE HexaBPM__IsClosedStatus__c=false ';//

        queyrString += (String.isNotBlank(selectedSchool) ? ' AND School__r.ID__c=\'' + String.escapeSingleQuotes(selectedSchool) + '\'' : '');
        queyrString += (String.isNotBlank(studentName) ? ' AND First_Name__c LIKE \'%' + String.escapeSingleQuotes(studentName) + '%\'' : '');
        queyrString += (String.isNotBlank(studentNumber) ? ' AND StudentId__c LIKE \'%' + String.escapeSingleQuotes(studentNumber) + '%\'' : '');
        queyrString += String.isNotBlank(academicYear) ? ' AND Academic_Year__c=\'' + String.escapeSingleQuotes(academicYear) + '\'' : '';

//        queyrString += String.isNotBlank(grade) ? ' AND GradeLookup__r.Name=\'' + grade + '\'' : '';
//        queyrString += String.isNotBlank(section) ? ' AND  GradeLookup__c in (select Grade__c FROM Section_Master__c WHERE Name=\'' + section + '\' )' : '';

        queyrString += String.isNotBlank(grade) ? ' AND (GradeLookup__c = null OR ( GradeLookup__c != null AND GradeLookup__r.Name=\'' + String.escapeSingleQuotes(grade) + '\' ))' : '';
        queyrString += String.isNotBlank(section) ? ' AND (GradeLookup__c = null OR ( GradeLookup__c != null AND  GradeLookup__c in (select Grade__c FROM Section_Master__c WHERE Name=\'' + String.escapeSingleQuotes(section) + '\' )))' : '';

        queyrString += (updated == 'Yes' ?
                ' AND (Emirates_ID_Synced_Date__c !=null OR Last_Emirates_ID_Sync_Date_Father__c != null OR Last_Emirates_ID_Sync_Date_Mother__c != null) ' : '');

        queyrString += ' AND RecordType.DeveloperName=\'Enrollment\' ORDER BY First_Name__c';
        System.debug('Search SR Query String ==>' + queyrString);

        try {
            //queyrString = escapeSosl(queyrString);

            studentEmiratesIDServiceRequests = new List<StudentEmiratesIDSR>();
            List<HexaBPM__Service_Request__c> searchResults = (List<HexaBPM__Service_Request__c>) Database.query(queyrString);

            for (HexaBPM__Service_Request__c sr: searchResults) {
                studentEmiratesIDServiceRequests.add(new StudentEmiratesIDSR(sr));
            }

        } catch (Exception ex) {
            System.debug('Query String ==>' + queyrString);
            System.debug('Exception ==>' + ex.getMessage());
        }

    }



    public void getAllGemsSchools() {
		
		list<school__c> tempList = [select id, id__c,logo__c, name from school__c where id=:schoolId];
        if(tempList!=null && tempList.size()>0){
        	selectedSchool = tempList[0].id__c;
        	objSchool = tempList[0];
        }
    }

    public void getAllAcademicYears() {
        List<SelectOption> academicYearsOptions = new List<SelectOption>();
        /*
        Schema.DescribeFieldResult fieldResult =
                Academic_Year__c.Year__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (integer index = (ple.size() - 1); index >= 0; index--) {
            PicklistEntry f = ple.get(index);
            academicYearsOptions.add(new SelectOption(f.getValue(), f.getLabel()));
            //academicYearsOptions.add(new SelectOption(f.getLabel(),f.getLabel()));
        }

        if (academicYearsOptions.size() > 0)
            academicYear = academicYearsOptions[0].getValue();
        */
        academicYearsOptions = GEMS_Utility.getAcademicYearsForSchool(selectedSchool, null);
        if (academicYearsOptions.size() > 0)
            academicYear = academicYearsOptions[0].getValue();
        academicYearsListOptions = academicYearsOptions;
        //return academicYearsListOptions;
        //return academicYearsOptions;

        getGradesForAcademicYear();
    }

    public void getGradesForAcademicYear() {

        System.debug('getGradesForAcademicYear() ==>' + academicYear + ' School,' + selectedSchool);

        List<SelectOption> gradesOptions = new List<SelectOption>();
        //gradesOptions.add(new SelectOption('All', '-All-'));
        for (Grade__c grade: [
                SELECT Name, Grade__c, Grade_Display__c
                FROM Grade__c
                WHERE Academic_Year__c = :academicYear and School__r.ID__c = :selectedSchool
        ]) {
            gradesOptions.add(new SelectOption(grade.Name, grade.Grade_Display__c));
        }

        if (gradesOptions.size() > 0)
            grade = gradesOptions[0].getValue();


        //return gradesOptions;
        gradesListOptions = gradesOptions;
        //return gradesListOptions;

        getSectionsForGrade();
    }

    public void getSectionsForGrade() {

        System.debug('getSectionsForGrade() ==>' + grade);

        List<SelectOption> sectionsOptions = new List<SelectOption>();
//        sectionsOptions.add(new SelectOption('', '-All-'));

        for (Section_Master__c section: [
                SELECT Name, Section__c
                FROM Section_Master__c
                WHERE Grade__r.Name = :grade
        ]) {
            sectionsOptions.add(new SelectOption(section.Name, section.Section__c));
        }

        sectionsListOptions = sectionsOptions;
        if (sectionsOptions.size() > 0)
            section = sectionsOptions[0].getValue();
        //return sectionsOptions;
        //return sectionsListOptions;
    }


    /**************** Helper Wrapper Classes ****************/

    public class StudentEmiratesIDAccount {
        public Account account { get; set; }

        public StudentEmiratesIDAccount(Account studentAccount) {
            this.account = studentAccount;
        }

        public Boolean getIsStudentEmiratesIDFilled() {
            return account.Emirates_ID_Synced_Date__c != null;
        }
        public Boolean getIsStudentEmiratesIdExpired() {
            if (getIsStudentEmiratesIDFilled()) {
                Date expireDate = account.Emirates_ID_Expiry_Date__c;
                return (expireDate == null || Date.today().daysBetween(expireDate) < 0);
            }
            return true;
        }

        //Mother
        public Boolean getIsMotherEmiratesIDFilled() {
            return (account.Mother__r != null && account.Mother__r.Emirates_ID_Synced_Date__c != null);
        }
        public Boolean getIsMotherEmiratesIdExpired() {
            if (getIsMotherEmiratesIDFilled()) {
                Date expireDate = account.Mother__r.Emirates_ID_Expiry_Date__c;
                return (expireDate == null || Date.today().daysBetween(expireDate) < 0);
            }
            return true;
        }

        //Father
        public Boolean getIsFatherEmiratesIDFilled() {
            return (account.Father__r != null && account.Father__r.Emirates_ID_Synced_Date__c != null);
        }
        public Boolean getIsFatherEmiratesIdExpired() {
            if (getIsFatherEmiratesIDFilled()) {
                Date expireDate = account.Father__r.Emirates_ID_Expiry_Date__c;
                return (expireDate == null || Date.today().daysBetween(expireDate) < 0);
            }
            return true;
        }
    }

    public class StudentEmiratesIDSR {
        public HexaBPM__Service_Request__c studentSR { get; set; }

        public StudentEmiratesIDSR(HexaBPM__Service_Request__c sr) {
            this.studentSR = sr;
        }

        public Boolean getIsStudentEmiratesIDFilled() {
            return studentSR.Last_Emirates_ID_Sync_Date__c != null;
        }
        public Boolean getIsStudentEmiratesIdExpired() {
            if (getIsStudentEmiratesIDFilled()) {
                Date expireDate = studentSR.Emirates_ID_Expiry_Date__c;
                return (expireDate == null || Date.today().daysBetween(expireDate) < 0);
            }
            return true;
        }

        //Mother, , Last_Emirates_ID_Sync_Date_Mother__c, Emirates_ID_Expire_Date_Mother__c
        public Boolean getIsMotherEmiratesIDFilled() {
            return (studentSR.Last_Emirates_ID_Sync_Date_Mother__c != null);
        }
        public Boolean getIsMotherEmiratesIdExpired() {
            if (getIsMotherEmiratesIDFilled()) {
                Date expireDate = studentSR.Emirates_ID_Expire_Date_Mother__c;
                return (expireDate == null || Date.today().daysBetween(expireDate) < 0);
            }
            return true;
        }

        //Father
        public Boolean getIsFatherEmiratesIDFilled() {
            return (studentSR.Last_Emirates_ID_Sync_Date_Father__c != null);
        }
        public Boolean getIsFatherEmiratesIdExpired() {
            if (getIsFatherEmiratesIDFilled()) {
                Date expireDate = studentSR.Emirates_ID_Expire_Date_Father__c;
                return (expireDate == null || Date.today().daysBetween(expireDate) < 0);
            }
            return true;
        }
    }

}