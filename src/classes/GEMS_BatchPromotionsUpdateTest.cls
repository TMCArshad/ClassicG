@IsTest
private class GEMS_BatchPromotionsUpdateTest{

      static testmethod void testBatch1(){           
         list<promotion__c> promotionList = new list<promotion__c> ();
         
         school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	objAY.Re_Enrolment_Prior_Notification_Date__c  = system.today();
       objAY.Re_Enrolment_Start_Date__c  = system.today();
       objAY.Re_Enrolment_End_Date__c =  system.today();
       
       objAY.Re_Enrolment_Payment_Delay_Date__c =  system.today();
       objAY.Re_Enrolment_1st_Notification__c =  system.today();
       objAY.Re_Enrolment_2nd_Notification__c =  system.today();
       objAY.Re_Enrolment_3rd_Notification__c =  system.today();
       
       objAY.Payment_1st_Notification__c =  system.today();
       objAY.Payment_2nd_Notification__c =  system.today();
       objAY.Payment_3rd_Notification__c =  system.today();
    	
    	update objAY;
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	Section_Master__c objSec = GEMS_TestUtils.createSection(objSchool,objAY,objGrade);
    	
    	Amount__c objAmount = GEMS_TestUtils.createAmount('Re-Enroll', objGrade.stream__c, objAY.id, objSchool.id);
    	
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
		objStudent.Primary_Contact_Email__c = 'abc@abc.com';
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
    	objPromo.Re_Enrolment_Prior_Notification__c = false;
       objPromo.Re_Enrolment_Start_Notification__c = false;
       objPromo.Re_Enrolment_End_Notification__c = false;
       objPromo.Re_Enrolment_Payment_Delay_Notification__c = false;
       objPromo.Re_Enrolment_1st_Notification__c = false;
       objPromo.Re_Enrolment_2nd_Notification__c = false;
       objPromo.Re_Enrolment_3rd_Notification__c = false;
       objPromo.Payment_1st_Notification__c = false;
       objPromo.Payment_2nd_Notification__c = false;
       objPromo.Payment_3rd_Notification__c = false;
       
       objPromo.Student_Email_Address__c = 'abc@abc.com';
       
    	insert objPromo;
         promotionList.add(objPromo);
        
                  
         GEMS_BatchPromotionsUpdate b1 = new GEMS_BatchPromotionsUpdate();      
         DataBase.executeBatch(b1); 
         
     
     }
     
}