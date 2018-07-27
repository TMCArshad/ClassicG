@IsTest
private class GEMS_updateBudgetDataTest {
    static testMethod void GEMS_updateBudgetDataTest1(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Capacity_Master__c objBudget = new Capacity_Master__c();
    	objBudget.Academic_Year__c = objAY.id;
    	objBudget.Active__c = true;
    	objBudget.Grade__c = objGrade.id;
    	objBudget.School__c = objSchool.id;
    	insert objBudget;
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.school__c = objSchool.id;
    	objStudent.academic_year__c = objAY.id;
    	objStudent.gradeLookup__c = objGrade.id;
    	objStudent.Section__c = objSec.id;
    	objStudent.stream__c = objGrade.stream__c;
    	objStudent.curriculum__c = objAY.curriculum__c;
    	objStudent.Current_Status__c = 'EN';
    	objStudent.Date_of_Join__c = system.today()+1;
    	update objStudent;
    	
    	Promotion__c objPromo = new Promotion__c();
    	objPromo.Academic_Year__c = objAY.id;
    	objPromo.Active__c = true;
    	objPromo.Curriculum__c = objAY.curriculum__c;
    	objPromo.Grade__c = objGrade.id;
    	objPromo.Section__c = objSec.id;
    	objPromo.Re_enrolment_Remark__c = 'Re-Enroled';
    	objPromo.School__c = objSchool.id;
    	objPromo.Student__c = objStudent.id;
    	objPromo.sys_Primary_Key__c = '1';
    	insert objPromo;
    	
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Registration_Type__c = 'Waitlist';
        objSR.Child_have_any_special_education_needs__c = 'Yes';
        objSR.Offer_Send_Date__c = system.today()-1;
        update objSR;
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        
        HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
        objSR1.recordTypeId = recordTypeId;
        objSR1.Registration_Type__c = 'Waitlist';
        objSR1.Child_have_any_special_education_needs__c = 'Yes';
        objSR1.Offer_Send_Date__c = system.today()-1;
        objSR1.School__c = objSchool.id;
        objSR1.Academic_Year__c = objAY.id;
        objSR1.GradeLookup__c = objGrade.id;
        insert objSR1;
        
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR1;
        
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Test');
        HexaBPM__Service_Request__c objSR2 = new HexaBPM__Service_Request__c();
        objSR2.recordTypeId = recordTypeId;
        objSR2.Registration_Type__c = 'Waitlist';
        objSR2.Child_have_any_special_education_needs__c = 'Yes';
        objSR2.Offer_Send_Date__c = system.today()-1;
        objSR2.School__c = objSchool.id;
        objSR2.Academic_Year__c = objAY.id;
        objSR2.GradeLookup__c = objGrade.id;
        insert objSR2;
        
        objSR2.HexaBPM__Internal_SR_Status__c = srStatus1.id;
        objSR2.HexaBPM__External_SR_Status__c = srStatus1.id;
        update objSR2;
        
    	GEMS_UpdateBudgetData.updateSchoolBudget(objSchool.id);
    }
}