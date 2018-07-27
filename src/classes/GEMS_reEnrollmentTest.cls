@isTest
private class GEMS_reEnrollmentTest {
	static testMethod void GEMS_reEnrollmentTest1(){
		school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '11111111';
		objStudent.Re_enrolment_Status__c = 'Blocked';
		objStudent.Curriculum_Current__c = objAY.curriculum__c;
		update objStudent;
		
		Promotion__c objPromo = new Promotion__c();
    	objPromo.Academic_Year__c = objAY.id;
    	objPromo.Active__c = true;
    	objPromo.Curriculum__c = objAY.curriculum__c;
    	objPromo.Grade__c = objGrade.id;
    	objPromo.Section__c = objSec.id;
    	objPromo.Re_enrolment_Remark__c = 'Fee Pending';
    	objPromo.School__c = objSchool.id;
    	objPromo.Student__c = objStudent.id;
    	objPromo.sys_Primary_Key__c = '1';
    	insert objPromo;
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = createSR(objSchool,objAY,objGrade,objStudent.id);
		
		createEmployee('11111111','Male');
		
		academic_year__c objAYFuture = createFutureAcademicYear(objSchool);
		grade__c objGradeFuture = createFutureGrade(objSchool,objAYFuture);
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('CLOSED');
		
		Amount__c objAmount = GEMS_TestUtils.createAmount('RE-ENROL', objStudent.stream__c, objAYFuture.id, objStudent.school__c);
		
		Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrollment'));
    	System.currentPageReference().getParameters().put('studentId', GEMS_Utility.getEnctryptedURLparam(objStudent.student_id__c));
    	GEMS_reEnrollmentCtlr reEnrolCtlr = new GEMS_reEnrollmentCtlr();
    	
    	reEnrolCtlr.upsertReEnrollmentSR();
	}
	
	static testMethod void GEMS_reEnrollmentTest2(){
		school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '11111111';
		objStudent.Re_enrolment_Status__c = 'Blocked';
		objStudent.Curriculum_Current__c = objAY.curriculum__c;
		update objStudent;
		
		Promotion__c objPromo = new Promotion__c();
    	objPromo.Academic_Year__c = objAY.id;
    	objPromo.Active__c = true;
    	objPromo.Curriculum__c = objAY.curriculum__c;
    	objPromo.Grade__c = objGrade.id;
    	objPromo.Section__c = objSec.id;
    	objPromo.Re_enrolment_Remark__c = 'Fee Pending';
    	objPromo.School__c = objSchool.id;
    	objPromo.Student__c = objStudent.id;
    	objPromo.sys_Primary_Key__c = '1';
    	insert objPromo;
		
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = createSR(objSchool,objAY,objGrade,objStudent.id);
        
        createEmployee('22222222','Female');
        
        academic_year__c objAYFuture = createFutureAcademicYear(objSchool);
		grade__c objGradeFuture = createFutureGrade(objSchool,objAYFuture);
		
		Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrollment'));
    	System.currentPageReference().getParameters().put('studentId', GEMS_Utility.getEnctryptedURLparam(objStudent.student_id__c));
    	GEMS_reEnrollmentCtlr reEnrolCtlr = new GEMS_reEnrollmentCtlr();
    	
    	reEnrolCtlr.submitReEnrollmentSR();
    	
    	reEnrolCtlr.upsertReEnrollmentSR();
	}
	
	static testMethod void GEMS_reEnrollmentTest3(){
		school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '11111111';
		objStudent.Re_enrolment_Status__c = 'Blocked';
		objStudent.Curriculum_Current__c = objAY.curriculum__c;
		update objStudent;
		
		Promotion__c objPromo = new Promotion__c();
    	objPromo.Academic_Year__c = objAY.id;
    	objPromo.Active__c = true;
    	objPromo.Curriculum__c = objAY.curriculum__c;
    	objPromo.Grade__c = objGrade.id;
    	objPromo.Section__c = objSec.id;
    	objPromo.Re_enrolment_Remark__c = 'Fee Pending';
    	objPromo.School__c = objSchool.id;
    	objPromo.Student__c = objStudent.id;
    	objPromo.sys_Primary_Key__c = '1';
    	insert objPromo;
		
		HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = createSR(objSchool,objAY,objGrade,objStudent.id);
        
        createEmployee('22222222','Female');
        academic_year__c objAYFuture = createFutureAcademicYear(objSchool);
		grade__c objGradeFuture = createFutureGrade(objSchool,objAYFuture);
		
		Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrollment'));
    	System.currentPageReference().getParameters().put('studentId', GEMS_Utility.getEnctryptedURLparam(objStudent.student_id__c));
    	GEMS_reEnrollmentCtlr reEnrolCtlr = new GEMS_reEnrollmentCtlr();
    	
    	reEnrolCtlr.payAtSchool();
	}
	
	static testMethod void GEMS_reEnrollmentTest4(){
		school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '11111111';
		objStudent.Re_enrolment_Status__c = 'Blocked';
		objStudent.Curriculum_Current__c = objAY.curriculum__c;
		update objStudent;
		
		Promotion__c objPromo = new Promotion__c();
    	objPromo.Academic_Year__c = objAY.id;
    	objPromo.Active__c = true;
    	objPromo.Curriculum__c = objAY.curriculum__c;
    	objPromo.Grade__c = objGrade.id;
    	objPromo.Section__c = objSec.id;
    	objPromo.Re_enrolment_Remark__c = 'Fee Pending';
    	objPromo.School__c = objSchool.id;
    	objPromo.Student__c = objStudent.id;
    	objPromo.sys_Primary_Key__c = '1';
    	insert objPromo;
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = createSR(objSchool,objAY,objGrade,objStudent.id);
    	
    	academic_year__c objAYFuture = createFutureAcademicYear(objSchool);
		grade__c objGradeFuture = createFutureGrade(objSchool,objAYFuture);
		
		Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrollment'));
    	System.currentPageReference().getParameters().put('studentId', GEMS_Utility.getEnctryptedURLparam(objStudent.student_id__c));
    	GEMS_reEnrollmentCtlr reEnrolCtlr = new GEMS_reEnrollmentCtlr();
    	reEnrolCtlr.selectedGemsStaffExist = 'No';
    	reEnrolCtlr.payNow();
    	reEnrolCtlr.showPopUp();
    	reEnrolCtlr.closePopup();
    	reEnrolCtlr.upsertReEnrollmentSR();
	}
	
	public static HexaBPM__Service_Request__c createSR(school__c objSchool, academic_year__c objAY, grade__c objGrade, string studentID){
		string recordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Re_Enrolment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
        }
         
        HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
        objSR1.recordTypeId = recordTypeId;

        objSR1.school__c = objSchool.id;
        objSR1.academic_year__c = objAY.id;
        objSR1.gradeLookup__c = objGrade.id;
        objSR1.curriculum__c = objAY.curriculum__c;
        objSR1.stream__c = objGrade.stream__c;
    	objSR1.first_name__c = 'Test';
    	objSR1.last_name__c = 'Test';
    	objSR1.HexaBPM__Customer__c = studentID;
        objSR1.student__c = studentID;
        objSR1.Is_father_of_Student_an_employee_in_GEMS__c = 'Yes';
        objSR1.Is_mother_of_Student_an_employee_in_GEMS__c = 'Yes';
        objSR1.Staff_ID__c = '11111111';
        objSR1.Staff_ID_Mother__c = '22222222';
        objSR1.accept_offer__c = 'Yes';
        objSR1.declaration__c = true;
        insert objSR1;
        
        
        
        return objSR1;
	}
	
	public static void createEmployee(string employeeId, string gender){
		Employee__c objEmp = new Employee__c();
		objEmp.Staff_id__c = employeeId;
		objEmp.Staff_Number__c	= employeeId;
		objEmp.First_Name__c = 'Test';
		objEmp.Last_Name__c = 'Test';
		objEmp.gender__c = gender;
		insert objEmp;
	}
	
	public static academic_year__c createFutureAcademicYear(school__c objSchool) {
        academic_year__c objAY = new academic_year__c();
        objAY.year__c = '28';
        objAY.ACD_ID__c = 12345;
        objAY.Curriculum__c = '2';
        objAY.School__c = objSchool.id;
        objAY.Start_Date__c = system.today().addYears(1);
        objAY.End_Date__c = system.today().addYears(2);
        objAY.Active__c = true;
        objAY.Academic_Year__c = '2017-2017';
        insert objAY;

        return objAY;
    }

    public static grade__c createFutureGrade(school__c objSchool, academic_year__c objAY) {
        grade__c objGrade = new grade__c();
        objGrade.Academic_Year__c = objAY.id;
        objGrade.School__c = objSchool.id;
        objGrade.Age_Cut_off_Date__c = system.today().addDays(90);
        objGrade.Grade_Display__c = '02';
        objGrade.grade__c = '2';
        objGrade.GRM_ID__c = 12345;
        objGrade.Maximum_Age__c = 6;
        objGrade.Minimum_Age__c = 4;
        objGrade.Active__c = true;
        objGrade.Open_Online_Payment__c = 'Yes';
        objGrade.Stream__c = '1';

        insert objGrade;
        return objGrade;
    }
	
	static testMethod void GEMS_reEnrollmentTest5(){
				
		Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrollment'));
    	System.currentPageReference().getParameters().put('studentId', GEMS_Utility.getEnctryptedURLparam('sdasdsad'));
    	GEMS_reEnrollmentCtlr reEnrolCtlr = new GEMS_reEnrollmentCtlr();
    	
    	reEnrolCtlr.upsertReEnrollmentSR();
	}
	
	static testMethod void GEMS_reEnrollmentTest6(){
		school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Section__c = objSec.id;
    	objStudent.Current_Status__c = 'EN';
		objStudent.student_id__c = '11111111';
		objStudent.Re_enrolment_Status__c = 'Blocked';
		objStudent.Curriculum_Current__c = objAY.curriculum__c;
		update objStudent;
		
		Promotion__c objPromo = new Promotion__c();
    	objPromo.Academic_Year__c = objAY.id;
    	objPromo.Active__c = true;
    	objPromo.Curriculum__c = objAY.curriculum__c;
    	objPromo.Grade__c = objGrade.id;
    	objPromo.Section__c = objSec.id;
    	objPromo.Re_enrolment_Remark__c = 'Fee Pending';
    	objPromo.School__c = objSchool.id;
    	objPromo.Student__c = objStudent.id;
    	objPromo.sys_Primary_Key__c = '1';
    	insert objPromo;
		
		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = createSR(objSchool,objAY,objGrade,objStudent.id);
    	
    	objSR.accept_offer__c = 'No';
    	update objSR;
    	academic_year__c objAYFuture = createFutureAcademicYear(objSchool);
		grade__c objGradeFuture = createFutureGrade(objSchool,objAYFuture);
		
		Test.setCurrentPageReference(new PageReference('Page.GEMS_reEnrollment'));
    	System.currentPageReference().getParameters().put('studentId', GEMS_Utility.getEnctryptedURLparam(objStudent.student_id__c));
    	GEMS_reEnrollmentCtlr reEnrolCtlr = new GEMS_reEnrollmentCtlr();
    	reEnrolCtlr.selectedGemsStaffExist = 'No';
    	reEnrolCtlr.selectedTCrequest = 'Yes';
    	reEnrolCtlr.yes = true;
    	reEnrolCtlr.upsertReEnrollmentSR();
    	
    	GEMS_reEnrollmentCtlr.generateOTP('11111111', '111111111');
    	GEMS_reEnrollmentCtlr.validateOTP('1111','11111111', '111111111');
	}
	
		static testMethod void payAtSchoolTest()
	    {
	        // Test Data
	        GEMS_reEnrollmentCtlr gemReEnrol = new GEMS_reEnrollmentCtlr();
	        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
	       
	        school__c objSchool = GEMS_TestUtils.createSchool();
        	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
        	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
        	
       	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
        	objStudent.school__c = objSchool.id;
        	objStudent.academic_year__c = objAY.id;
        	objStudent.gradeLookup__c = objGrade.id;
        	objStudent.stream__c = objGrade.stream__c;
        	objStudent.curriculum__c = objAY.curriculum__c;
        	objStudent.Section__c = objSec.id;
        	objStudent.Current_Status__c = 'EN';
    		objStudent.student_id__c = '11111111';
    		objStudent.Re_enrolment_Status__c = 'Blocked';
    		objStudent.Curriculum_Current__c = objAY.curriculum__c;
    		update objStudent;
    	 /*	
    		Promotion__c objPromo = new Promotion__c();
        	objPromo.Academic_Year__c = objAY.id;
        	objPromo.Active__c = true;
        	objPromo.Curriculum__c = objAY.curriculum__c;
        	objPromo.Grade__c = objGrade.id;
        	objPromo.Section__c = objSec.id;
        	objPromo.Re_enrolment_Remark__c = 'Fee Pending';
        	objPromo.School__c = objSchool.id;
        	objPromo.Student__c = objStudent.id;
        	objPromo.sys_Primary_Key__c = '1';
        	insert objPromo;*/
    		
    		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(accept_offer__c = 'Yes');
        	objSR = createSR(objSchool,objAY,objGrade,objStudent.id);
        	gemReEnrol.objSR = objSR;
        	gemReEnrol.totalPrice = 100;
        	gemReEnrol.payAtSchool();
    	
	        
	        
	    }   
	    
	    static testMethod void generateOTPTest()
	    {
	          GEMS_reEnrollmentCtlr gemReEnrol = new GEMS_reEnrollmentCtlr();
	          List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(1);
              List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
              String staffID = 'staffID';
              Employee__c emp = employees[0];
              emp.Staff_Number__c = staffID;
              update emp;
              
              GEMS_reEnrollmentCtlr.generateOTP(staffID,'');
              
              
	        
	    }
	
}