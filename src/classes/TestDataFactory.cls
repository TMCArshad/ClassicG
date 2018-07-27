@isTest
public class TestDataFactory {
    
   public static Account createStudentAccount(){
       
       Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student').getRecordTypeId();
       
        Account objAccount = new Account(FirstName='test Student',LastName='Last',Student_Id__c='1112222333',RecordTypeId=acctRecordTypeId,Primary_Contact_Email__c = 'test@test.test');
        return objAccount;
   }
   
  public static Account createParentAccount(){
  
        Schema.DescribeSObjectResult acctSchema = Schema.SObjectType.Account;        
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = acctSchema.getRecordTypeInfosByName();
        Account objAccount = new Account(FirstName='test',LastName='Student',Master_Student__c='5555555',personemail = 'test@test.test',recordtypeid = AccountRecordTypeInfo.get('Parent/Guardian').getRecordTypeId());
        return objAccount;
   }
  
   
  public static School__c createSchool(){
       
       School__c  school = new School__c();
       
       school.Name = 'Test School';
       school.Short_Name__c = 'TS';
       school.Email__c = 'abc@abc.com';
       school.Active__c  = true;
       
       return school;
       
   }
   
   public static Academic_Year__c createAcademicYear(School__c school){
       
       Academic_Year__c academicYear = new Academic_Year__c();
       
       academicYear.Year__c = '28';
       academicYear.School__c = school.Id;
       academicYear.Active__c = true;
       academicYear.Curriculum__c = '2';
       academicYear.Re_Enrolment_Prior_Notification_Date__c  = system.today();
       academicYear.Re_Enrolment_Start_Date__c  = system.today();
       academicYear.Re_Enrolment_End_Date__c =  system.today();
       
       academicYear.Re_Enrolment_Payment_Delay_Date__c =  system.today();
       academicYear.Re_Enrolment_1st_Notification__c =  system.today();
       academicYear.Re_Enrolment_2nd_Notification__c =  system.today();
       academicYear.Re_Enrolment_3rd_Notification__c =  system.today();
       
       academicYear.Payment_1st_Notification__c =  system.today();
       academicYear.Payment_2nd_Notification__c =  system.today();
       academicYear.Payment_3rd_Notification__c =  system.today();
       
       academicYear.Sys_Active__c = true;
       
       return academicYear;
       
   }
   
   
    public static Promotion__c createPromotion(Academic_Year__c academicYear, Account student,School__c school){
       
       Promotion__c promo = new Promotion__c();
       
       promo.Student__c = student.Id;
       promo.School__c = school.Id;
       promo.Academic_Year__c = academicYear.Id;
       promo.Active__c = true;
       
       promo.Re_Enrolment_Prior_Notification__c = false;
       promo.Re_Enrolment_Start_Notification__c = false;
       promo.Re_Enrolment_End_Notification__c = false;
       promo.Re_Enrolment_Payment_Delay_Notification__c = false;
       promo.Re_Enrolment_1st_Notification__c = false;
       promo.Re_Enrolment_2nd_Notification__c = false;
       promo.Re_Enrolment_3rd_Notification__c = false;
       promo.Payment_1st_Notification__c = false;
       promo.Payment_2nd_Notification__c = false;
       promo.Payment_3rd_Notification__c = false;
       
       promo.Student_Email_Address__c = 'abc@abc.com';
     
       return promo;
       
   }
   


}