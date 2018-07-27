/**
 * Created by bilalnazir on 5/14/17.
 */

@IsTest
public class GEMS_TestUtils {

    public static Account createStudentAccount(string name) {

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Account Acc = new Account(LastName = name, recordtypeid = AccountRecordTypeInfo.get('Student').getRecordTypeId());
        acc.Emirates_Full_Name__c = 'Full Name';
        acc.Country__c = '172';
        insert Acc;

        return Acc;
    }
    
    public static Account createAccount(string recordTypeName) {
        string recordTypeId = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = :recordTypeName and sObjectType = 'Account']) {
            recordTypeId = rectyp.Id;
        }
        
        integer rand = integer.valueOf(Math.random());
        Account objAccount = new Account();
        objAccount.FirstName = 'Test '+rand;
        objAccount.LastName = 'Test '+rand;
        if(recordTypeName=='Student'){
            school__c objSchool = createSchool();
            academic_year__c objAy = createAcademicYear(objSchool);
            grade__c objGrade = createGrade(objSchool, objAy);
    
            objAccount.school__c = objSchool.id;
            objAccount.academic_year__c = objAy.id;
            objAccount.gradeLookup__c = objGrade.id;
            objAccount.curriculum__c = objAy.curriculum__c;
            objAccount.stream__c = objGrade.stream__c;
            objAccount.Current_Status__c = 'EN';
        }
        objAccount.PersonMobilePhone = '+971555259999';
        insert objAccount;
        return objAccount;
    }
    
    public static relationship__c createRelationship(Account subAcc, Account objAcc, string typeRel){
        relationship__c objRelationship = new relationship__c();
        objRelationship.subject_account__c = subAcc.id;
        objRelationship.object_account__c = objAcc.id;
        objRelationship.active__c = true;
        objRelationship.type__c = typeRel;
        insert objRelationship;
        return objRelationship;
    }

    public static HexaBPM__Service_Request__c createStudentSR(string name) {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HexaBPM__Service_Request__c;
        Map<String, Schema.RecordTypeInfo> SRRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(First_Name__c = name, recordtypeid = SRRecordTypeInfo.get('Enrollment').getRecordTypeId());
        insert sr;

        return sr;
    }
    
    public static lead createLead(school__c objSchool,academic_year__c objAy,grade__c objGrade){
        Lead objLead = new Lead();
        objLead.FirstName = 'Test';
        objLead.LastName = 'Test';
        
        objLead.schoollookup__c = objSchool.id;
        objLead.academic_year__c = objAy.id;
        objLead.gradeLookup__c = objGrade.id;
        objLead.curriculum__c = objAy.curriculum__c;
        objLead.stream__c = objGrade.stream__c;
        objLead.mobilePhone = '+971555259999';
        
        insert objLead;
        return objLead;
    }
    
    public static Enquiry__c createEnquiry(school__c objSchool, academic_year__c objAy, grade__c objGrade){
        Enquiry__c objEnq = new Enquiry__c();
        objEnq.FirstName__c = 'Test';
        objEnq.LastName__c = 'Test';
        
        objEnq.schoollookup__c = objSchool.id;
        objEnq.academic_year__c = objAy.id;
        objEnq.gradeLookup__c = objGrade.id;
        objEnq.curriculum__c = objAy.curriculum__c;
        objEnq.stream__c = objGrade.stream__c;
        objEnq.mobilePhone__c = '+971555259999';
        objEnq.Date_Of_Birth__c = system.today().addYears(-7);
        objEnq.gender__c = 'Male';
        objEnq.Passport_Number__c = '11111';
        objEnq.email__c = 'Non@Digital.com';
        objEnq.middlename__c = 'update';
        objEnq.phone__c = '+971555258999';
        objEnq.salutation__c = 'Master';
        insert objEnq;
        return objEnq;
    }
    
    public static user createRegistrar(){
        list<profile> tempProfile = new list<profile>();
        tempProfile = [select id from profile where Name='GEMS FOH'];
        
        User user = new User(alias = 'test', email = 'test@noemail.com',
                               emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                               localesidkey = 'en_US', profileid =tempProfile[0].id , country = 'United States', IsActive = true,
                               timezonesidkey = 'America/Los_Angeles', username = 'tester' + Integer.valueOf(math.rint(math.random()*1000000))+'@noemail.com');
        
        insert user;
        return user;
    }
    
    public static group createQueue(school__c objSchool){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            List<String> sObjectTypeList = new List<String>{'HexaBPM__Service_Request__c','Lead','Enquiry__c','HexaBPM__Step__c'};
            Group objGroup = new Group();
            objGroup.type = 'Queue';
            objGroup.Name = objSchool.Short_Name__c + '-Registrar';
            insert objGroup;
            List<QueueSobject> sObjectList = new List<QueueSobject>();
            for(String objType : sObjectTypeList){
                QueueSobject sObj =  new QueueSobject();
                sObj.QueueId = objGroup.Id;
                sObj.SobjectType = objType;
                sObjectList.add(sObj);
            }
            insert sObjectList;
            
            GroupMember objMember = new  GroupMember();
            objMember.GroupId = objGroup.Id;
            objMember.UserOrGroupId = createRegistrar().id;
            insert objMember;
            
            return objGroup;
        }   
        return null;
    }
    
    public static GEMS_Queue_Config__c createQueueConfig(school__c objSchool){
    
        GEMS_Queue_Config__c objConfig = new GEMS_Queue_Config__c();
        objConfig.Name =  objSchool.Short_Name__c + '-Registrar';
        objConfig.Queue_Type__c = 'Registrar';
        objConfig.Queue_Name__c = objSchool.Short_Name__c + '_Registrar';
        objConfig.School_Code__c = objSchool.Short_Name__c;
        objConfig.School_Name__c = objSchool.Name;
        insert objConfig;
        return objConfig;
    }

    public static HexaBPM__Service_Request__c createSR(string name) {
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = :name and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Draft');

        school__c objSchool = createSchool();
        academic_year__c objAy = createAcademicYear(objSchool);
        grade__c objGrade = createGrade(objSchool, objAy);
        
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR.recordTypeId = recordTypeId;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.school__c = objSchool.id;
        objSR.academic_year__c = objAy.id;
        objSR.gradeLookup__c = objGrade.id;
        objSR.curriculum__c = objAy.curriculum__c;
        objSR.stream__c = objGrade.stream__c;
        objSR.Sys_GEMS_School_Sibling__c = objSchool.id;
        
        if(name == 'Enrollment'){
            objSR.lead__c = createLead(objSchool,objAy,objGrade).id;
            objSR.first_name__c = 'Test';
            objSR.last_name__c = 'Test';
            objSR.First_Name_Father__c = 'Test';
            objSR.Last_Name_Father__c = 'Test';
            objSR.First_Name_Mother__c = 'Test';
            objSR.Last_Name_Mother__c = 'Test';
            objSR.First_Name_Guardian__c = 'Test';
            objSR.Last_Name_Guardian__c = 'Test';
            objSR.Date_Of_Birth__c = system.today().addYears(-7);
            objSR.gender__c = 'Male';
            objSR.Passport_No__c = '11111';
            objSR.Mobile__c = '+971555259999';
            objSR.Mobile_Mother__c = '+971555259999';
            objSR.Mobile_Guardian__c = '+971555259999';
            objSR.Email_Father__c = 'test@test.com';
            objSR.Email_Mother__c = 'test@test.com';
            objSR.Email_Guardian__c = 'test@test.com';
            objSR.country__c = '172';
            objSR.City_Emirate__c = '157';
            objSR.Country_Mother__c = '172';
            objSR.City_emirate_Mother__c = '157';
            objSR.Country_Guardian__c = '172';
            objSR.City_emirate_Guardian__c = '157';
            if(objSR.lead__c!=null){
            	list<enquiry__c> temp = new list<enquiry__c>();
                temp = [select id from enquiry__c where lead__c =: objSR.lead__c];
                if(temp!=null && temp.size()>0){
                    objSR.enquiry__c = temp[0].id;   
                }
            }
        }
        
        objSR.HexaBPM__SR_Template__c = createSRTemplate(devName,devName).id;
        insert objSR;

        return objSR;
    }
    
    public static HexaBPM__Step__c createStep(HexaBPM__Service_Request__c objSR,string stepName, string stepStatus){
        
        HexaBPM__SR_Steps__c objTemp = createSRStep(objSR.HexaBPM__Record_Type_Name__c,objSR.HexaBPM__Record_Type_Name__c,stepName);
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep.HexaBPM__SR__c = objSR.id;
        objStep.HexaBPM__SR_Step__c = objTemp.id;
        objStep.HexaBPM__Status__c = createStepStatus(stepStatus).id;
        objStep.HexaBPM__Step_Template__c = objTemp.HexaBPM__Step_Template__c;
        
        insert objStep;
        return objStep;
    }
    
    public static HexaBPM__Step_Template__c createStepTemplate(string stepName){
        HexaBPM__Step_Template__c objStepTemplate = new HexaBPM__Step_Template__c();
        objStepTemplate.name = stepName;
        objStepTemplate.HexaBPM__Code__c = stepName;
        objStepTemplate.HexaBPM__Step_RecordType_API_Name__c = 'General';
        insert objStepTemplate;
        return objStepTemplate;
    }
    
    public static HexaBPM__Status__c createStepStatus(string statusName){
        HexaBPM__Status__c objStepStatus = new HexaBPM__Status__c();
        objStepStatus.name = statusName;
        objStepStatus.HexaBPM__Code__c = statusName;
        objStepStatus.HexaBPM__Type__c = 'Start';
        insert objStepStatus;
        return objStepStatus;
    }
    
    public static HexaBPM__SR_Template__c createSRTemplate(string templateName, string RecType){
        HexaBPM__SR_Template__c objSRTemplate = new HexaBPM__SR_Template__c();
        objSRTemplate.Name = templateName;
        objSRTemplate.HexaBPM__SR_RecordType_API_Name__c = RecType;
        objSRTemplate.HexaBPM__Active__c = true;
        insert objSRTemplate;
        return objSRTemplate;
    }
    
    public static HexaBPM__SR_Steps__c createSRStep(string templateName,string RecType,string stepName){
        HexaBPM__SR_Steps__c objSRStep = new HexaBPM__SR_Steps__c();
        objSRStep.HexaBPM__Active__c = true;
        objSRStep.HexaBPM__Step_No__c = 10.0;
        objSRStep.HexaBPM__Step_RecordType_API_Name__c = 'General';
        objSRStep.HexaBPM__SR_Template__c = createSRTemplate(templateName,RecType).id;
        objSRStep.HexaBPM__Step_Template__c = createStepTemplate(stepName).id;
        insert objSRStep;
        return objSRStep;
    }
    
    public static HexaBPM__SR_Status__c createSRStatus(string statusCode) {
        HexaBPM__SR_Status__c objStatus = new HexaBPM__SR_Status__c();
        objStatus.HexaBPM__Code__c = statusCode.touppercase();
        objStatus.Name = statusCode;
        insert objStatus;
        return objStatus;
    }

    public static school__c createSchool() {
        double y = Math.random() ; 
        y = 999999 * y;
        integer index = math.round(y);
        
        school__c objSchool = new school__c();
        integer random = Math.mod(Math.round(Math.random()*10), 10);
        objSchool.name = 'Test School ' + random;
        objSchool.id__c = string.valueOf(index);
        objSchool.short_name__c = 'TS' + random;
        objSchool.sys_Last_Fee_Id__c = 0;
        objSchool.gender__c = 'Male';
        objSchool.Active__c = true;
        insert objSchool;
        return objSchool;
    }

    public static academic_year__c createAcademicYear(school__c objSchool) {
        academic_year__c objAY = new academic_year__c();
        objAY.year__c = '27';
        objAY.ACD_ID__c = 12345;
        objAY.Curriculum__c = '2';
        objAY.School__c = objSchool.id;
        objAY.Start_Date__c = system.today();
        objAY.End_Date__c = system.today().addDays(90);
        objAY.Active__c = true;
        objAY.Academic_Year__c = '2016-2017';
        objAY.Sys_Active__c = true;
        insert objAY;

        return objAY;
    }

    public static grade__c createGrade(school__c objSchool, academic_year__c objAY) {
        grade__c objGrade = new grade__c();
        objGrade.Academic_Year__c = objAY.id;
        objGrade.School__c = objSchool.id;
        objGrade.Age_Cut_off_Date__c = system.today();
        objGrade.Grade_Display__c = '01';
        objGrade.grade__c = '1';
        objGrade.GRM_ID__c = 12345;
        objGrade.Maximum_Age__c = 18;
        objGrade.Minimum_Age__c = 3;
        objGrade.Active__c = true;
        objGrade.Open_Online_Payment__c = 'Yes';
        objGrade.Stream__c = '1';

        insert objGrade;
        return objGrade;
    }

    public static Section_Master__c createSection(school__c objSchool, academic_year__c objAY, grade__c objGrade) {
        Section_Master__c objSec = new Section_Master__c();
        objSec.Academic_Year__c = objAY.id;
        objSec.Grade__c = objGrade.id;
        objSec.School__c = objSchool.id;
        objSec.Section__c = 'TEMP';
        objSec.Section_ID__c = 123;
        insert objSec;
        return objSec;
    }
    
    public static Amount__c createAmount(string stage, string stream, string AY, string school){
        Amount__c objAmount = new Amount__c();
        objAmount.Stage_Lookup__c = createSRStatus(stage).id;
        objAmount.Stream__c = stream;
        objAmount.Academic_Year__c = AY;
        objAmount.School__c = school;
        insert objAmount;
        return objAmount;
    }
    
    public static HexaBPM__SR_Price_Item__c createPricing(string productName, string pricingLine, string SRId){
        Product2 objProd = new Product2();
        objProd.Name = 'productName';
        objProd.ProductCode = 'productName';
        objProd.IsActive = true;
        insert objProd;     
        
        HexaBPM__Pricing_Line__c objPL = new HexaBPM__Pricing_Line__c();
        objPL.Name = pricingLine;
        objPL.HexaBPM__Product__c = objProd.Id;
        objPL.HexaBPM__Active__c = true;
        objPL.HexaBPM__Priority__c = 1;
        insert objPL;
        
        HexaBPM__Dated_Pricing__c objDP = new HexaBPM__Dated_Pricing__c();
        objDP.HexaBPM__Pricing_Line__c = objPL.Id;
        objDP.HexaBPM__Unit_Price__c = 1234;
        objDP.HexaBPM__Date_From__c = system.today().addMonths(-1);
        objDP.HexaBPM__Date_To__c = system.today().addYears(2);
        insert objDP;
        
        HexaBPM__SR_Price_Item__c objSRItem = new HexaBPM__SR_Price_Item__c();
        objSRItem.HexaBPM__ServiceRequest__c = SRId;
        objSRItem.HexaBPM__Status__c = 'Added';
        objSRItem.HexaBPM__Price__c = 1000;
        objSRItem.HexaBPM__Price__c = 1000;
        objSRItem.Open_Online_Payment__c = 'Yes';
        objSRItem.HexaBPM__Pricing_Line__c = objPL.id;
        objSRItem.Product__c = objProd.id;
        objSRItem.HexaBPM__Product__c = objProd.id;
        insert objSRItem;
        
        return objSRItem;
    }
    /* ==================================================
    *
    *  NOTE => DO NOT MODIFY UNLESS DISCUSSED BEFORE AS IT MAY BRAK OTHER CLASSES
    *
    *  Test Utility Methods
    *  Author - Keerthan
    *
    *  ==================================================
    */

    public static  GEMS_Site_Domain_Config__c createSiteConfig(School__c schObj){
        GEMS_Site_Domain_Config__c  sc = new GEMS_Site_Domain_Config__c();
        sc.Name = schObj.Short_Name__c;
        sc.School_Code__c = schObj.ID__c;
        sc.Short_Form_Page_Name__c = 'enrol-online';
        sc.Site_Base_URL__c = 'http://test.aaq.lb.live.gems.zone-preview.co.uk/admissions/';
        sc.Thank_You_Page__c = 'thank-you';
        insert sc;
        return sc;

    }
    public static void createLeadEnquirySyncConfig(){
        Map<String,String> apiNameMap = new Map<String,String>
        {'lastName'=>'LastName__c',
        'MobilePhone'=>'mobilePhone__c',
        'leadSource'=>'Enquiry_Source__c',
        'status'=>'status__c',
        'isconverted'=>'isconverted__c',
        'email'=>'email__c',
        'status'=>'status__c',
        'firstName'=>'firstname__c',
        'middleName'=>'middlename__c',
        'phone'=>'phone__c',
        'salutation'=>'salutation__c'};

        Lead_Enquiry_Sync__c cs ;
        List<Lead_Enquiry_Sync__c> csList = new List<Lead_Enquiry_Sync__c>();
        for(String leadField: apiNameMap.keySet()){
            cs = new Lead_Enquiry_Sync__c();
            cs.Name = leadField;
            cs.Enquiry_API_Name__c  = apiNameMap.get(leadField);
            cs.Lead_API_Name__c = leadField;
            csList.add(cs);

        }
        System.debug('==>'+csList);
        insert csList;

    }
    public static List<HexaBPM__SR_Status__c> createSRStatus(){
        Map<String,String> statusMap = new Map<String,String>
        {'Draft'=>'DRAFT',
        'Submitted'=>'SUBMITTED',
        'Registered'=>'REGISTERED',
        'Closed'=>'CLOSED',
        'Reverse Cancel Admission' => 'REVERSE_CANCEL_ADMISSION_APPROVED'
        };
        List<HexaBPM__SR_Status__c>  statusList = new List<HexaBPM__SR_Status__c>();
        HexaBPM__SR_Status__c status ;
        for(String s :  statusMap.keySet()){
            status =  new HexaBPM__SR_Status__c();
            status.HexaBPM__Code__c =statusMap.get(s);
            status.Name = s;
            statusList.add(status);
        }
        insert statusList;
        return statusList;
    }

    public static  List<School__c> createSchools(Integer n ){
        List<School__c> schoolList = new List<School__c>();
        School__c schObj;
        for(Integer i =0 ; i<n;i++){
            schObj = new School__c();
            schObj.Name = 'SCHOOL_'+i;
            schObj.Short_Name__c = 'SN'+i;
            schObj.ID__c = '11111'+i;
            schObj.active__c = true;
            schoolList.add(schObj);
        }
        insert schoolList;
        return schoolList;
    }

    public static  List<Lead> createLeads(School__c school){
        List<lead> leadList =  new List<Lead>();
        Lead leadObj ;
        for(Integer i=0;i<10;i++){
            leadObj = new Lead();
            leadObj.lastName = 'Last Name'+ i;
            leadObj.mobilePhone = '+971525251659'+i;
            leadObj.Email = 'lead'+i+'@gemseducation.com';
            leadObj.leadSource ='Non-Digital';
            leadObj.Status = 'New';
            leadObj.Lead_Reference__c = GEMS_Utility.generateLeadRefNumber();
            leadObj.SchoolLookup__c  = school.Id;
            leadList.add(leadObj);



        }
        insert leadList;
        return leadList;
    }


    public static  List<Enquiry__c> createEnquiries(School__c school){
        List<Enquiry__c> enquiriesList =  new List<Enquiry__c>();
        Enquiry__c enquiryObj ;
        for(Integer i=0;i<10;i++){
            enquiryObj = new Enquiry__c();
            enquiryObj.LastName__c = 'Last Name'+ i;
            enquiryObj.MobilePhone__c = '+971525251659'+i;
            enquiryObj.Email__c = 'lead'+i+'@gemseducation.com';
            enquiryObj.Enquiry_Source__c ='Non-Digital';
            enquiryObj.Status__c = 'New';
            enquiryObj.Lead_Reference__c = GEMS_Utility.generateLeadRefNumber();
            enquiryObj.SchoolLookup__c  = school.Id;
            enquiriesList.add(enquiryObj);
        }
        insert enquiriesList;
        return enquiriesList;
    }

    public static   List<Lead> updateLeadRef(List<Lead> lead_List){

        String leadRef =  lead_List[0].Lead_Reference__c;
        List<Lead> leadUpdateList = new List<Lead>();
        for(Lead l : Lead_List){
            l.Lead_Reference__c = leadRef;
            leadUpdateList.add(l);
        }
        update leadUpdateList;
        return leadUpdateList;

    }

    public static List<Account> createStudents(){

        Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(Account.getsObjectType()).get('Student');
        Account objStudent;
        Grade__c g = new Grade__c();
        //Get School information
        for(Grade__c gradeObj : [SELECT Id, Academic_Year__c,Academic_Year__r.School__c,Stream__c,Academic_Year__r.Curriculum__c FROM Grade__c LIMIT 1]){
            g= gradeObj;
        }
        List<Account> studentList = new List<Account>();
        for(Integer i=0;i<10;i++){
            objStudent = new Account();
            objStudent.lastName = 'Student' + i;
            objStudent.RecordTypeId = recTypeID;
            objStudent.school__c = g.Academic_Year__r.School__c;
            objStudent.academic_year__c =g.Academic_Year__c;
            objStudent.gradeLookup__c = g.Id;
            objStudent.current_Status__c = 'EN';
            //objStudent.Section__c = objSec.id;
            objStudent.stream__c = g.Stream__c;
            objStudent.curriculum__c = g.Academic_Year__r.Curriculum__c;
            objStudent.Is_primary_contact_employee_of_GEMS__c = 'Yes';
            objStudent.Primary_Contact__c = 'Mother';
            studentList.add(objStudent);
        }
        insert studentList;
        return studentList;

    }

    public Static  List<HexaBPM__Service_Request__c> createSRForLead(List<Lead> lead_List,
            List<Account> students,
            School__c school,String RTName){


        Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get(RTName);
        HexaBPM__Service_Request__c SR;
        Grade__c g = new Grade__c();
        //Get School information
        for(Grade__c gradeObj : [SELECT Id, Academic_Year__c,Academic_Year__r.School__c,Stream__c,Academic_Year__r.Curriculum__c FROM Grade__c LIMIT 1]){
            g= gradeObj;
        }
        System.debug('Grade Record==>'+g);

        List<HexaBPM__Service_Request__c> SR_List = new List<HexaBPM__Service_Request__c>();
        Integer i = 0;
        for(Lead l :  lead_List){
            SR = new HexaBPM__Service_Request__c();
            SR.RecordTypeId = recTypeID;
            SR.Lead__c = l.Id;
            SR.Lead_Reference__c = l.Lead_Reference__c;
            SR.School__c = g.Academic_Year__r.School__c;
            SR.Academic_Year__c = g.Academic_Year__c;
            SR.GradeLookup__c = g.Id;
            SR.Stream__c =  g.Stream__c;
            SR.Curriculum__c = g.Academic_Year__r.Curriculum__c;
            SR.Student__c = students[i++].Id;

            SR_List.add(SR);

        }
        insert SR_List;
        return SR_List;
    }


    public Static  List<HexaBPM__Service_Request__c> createSRForEnquiry(List<Enquiry__c> enquiriesList,
            List<Account> students,
            School__c school,String RTName){


        Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get(RTName);
        HexaBPM__Service_Request__c SR;
        Grade__c g = new Grade__c();
        //Get School information
        for(Grade__c gradeObj : [SELECT Id, Academic_Year__c,Academic_Year__r.School__c,Stream__c,Academic_Year__r.Curriculum__c FROM Grade__c LIMIT 1]){
            g= gradeObj;
        }
        System.debug('Grade Record==>'+g);

        List<HexaBPM__Service_Request__c> SR_List = new List<HexaBPM__Service_Request__c>();
        Integer i = 0;
        for(Enquiry__c l :  enquiriesList){
            SR = new HexaBPM__Service_Request__c();
            SR.RecordTypeId = recTypeID;
            SR.Enquiry__c = l.Id;
            SR.Lead_Reference__c = l.Lead_Reference__c;
            SR.School__c = g.Academic_Year__r.School__c;
            SR.Academic_Year__c = g.Academic_Year__c;
            SR.GradeLookup__c = g.Id;
            SR.Stream__c =  g.Stream__c;
            SR.Curriculum__c = g.Academic_Year__r.Curriculum__c;
            SR.Student__c = students[i++].Id;

            SR_List.add(SR);

        }
        insert SR_List;
        return SR_List;
    }

    public static List<HexaBPM__Pricing_Line__c> createPricingLines(List<Product2> prodList){
        List<HexaBPM__Pricing_Line__c> plList = new List<HexaBPM__Pricing_Line__c>();
        HexaBPM__Pricing_Line__c pl;
        for(Product2 p : prodList){
            pl = new HexaBPM__Pricing_Line__c();
            pl.HexaBPM__Product__c = p.Id;
            pl.HexaBPM__Priority__c = 1;
            plList.add(pl);
        }
        insert plList;
        return plList;
    }
    public static List<Product2> createProducts(Integer n,String typeVal){
        List<Product2> prodList =  new List<Product2>();
        Product2 p ;
        for(Integer i=1;i<=n;i++){
            p = new Product2();
            p.Name = typeVal;
            p.isActive = true;
            p.Fee_Id__c = i;
            prodList.add(p);
        }
        insert prodList;
        return prodList;
    }

    public static List<Academic_year__c>  createsAYs(Integer n,School__c school){
        List<Academic_year__c> AYList = new List<Academic_year__c>();
        Academic_year__c Ay ;
        for(Integer i =0;i<n;i++){
            Ay = new Academic_year__c();
            AY.Year__c = '27';
            AY.ACD_ID__c = 1234;
            AY.Active__c = true;
            AY.Curriculum__c = '1';
            AY.School__c = school.Id;
            AY.Start_date__c = System.Today().addDays(-90);
            AY.End_Date__c = System.Today().addDays(90);
            AYList.add(AY);
        }
        insert AYList;
        return AYList;
    }

    public static List<Grade__c> createGrades(School__c school,List<Academic_year__c> AYList){
        List<Grade__c> gradeList = new List<Grade__c>();
        Grade__c grade ;
        for(Academic_year__c Ay : AYList){
            grade = new Grade__c();
            grade.GRM_ID__c = 1234;
            grade.School__c = school.Id;
            grade.Active__c = true;
            grade.Minimum_Age__c = 0;
            grade.Maximum_Age__c = 10;
            grade.Open_Online_Payment__c = 'Yes';
            grade.Academic_Year__c = AY.Id;
            grade.Age_Cut_off_Date__c = System.Today();
            grade.Grade_Display__c = '01';
            grade.Grade__c = '1';
            grade.Stream__c = '1';
            gradeList.add(grade);
        }
        insert gradeList;
        return gradeList;
    }

    public static List<Amount__c> createAmounts(List<Product2>pList){
        Map<String,Id> statusMap = new Map<String,Id>();
        for(HexaBPM__SR_Status__c st:[SELECT Id,Name,HexaBPM__Code__c FROM HexaBPM__SR_Status__c] ){
            statusMap.put(st.Name,St.id);
        }
        Map<Id,Grade__c> gradeMap = new Map<Id,Grade__c>();

        for(Grade__c g : [SELECT Id, Academic_Year__c,Grade__c,Academic_Year__r.School__c,School__c,Stream__c,Academic_Year__r.Curriculum__c,Grade_Display__c FROM Grade__c ] ){
            gradeMap.put(g.Id,g);
        }


        List<Amount__c> amountList = new List<Amount__c>();
        Amount__c amount;

        Integer i = 0;
        for(Grade__c gradeObj  : gradeMap.values()){
            amount = new Amount__c();
            amount.Academic_Year__c = gradeObj.Academic_Year__c;
            amount.Amount__c = 100 + i;
            amount.Fee_Master__c = pList[i].Id;
            amount.School__c =  gradeObj.Academic_Year__r.School__c;
            amount.Stream__c = gradeObj.Stream__c;
            amount.Grade__c = gradeObj.Grade__c;
            amount.Stage_Lookup__c = statusMap.get('Registered');
            amountList.add(amount);
            i++;
        }
        insert amountList;
        return amountList;
    }



    public static List<HexaBPM__SR_Price_Item__c> createPriceitems(List<HexaBPM__Service_Request__c> SR_List,List<Product2> prodList,List<HexaBPM__Pricing_Line__c> plList){
        List<HexaBPM__SR_Price_Item__c> piList = new List<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c pi ;
        Integer i =0;
        for(HexaBPM__Service_Request__c srObj : SR_List){
            pi = new HexaBPM__SR_Price_Item__c();
            pi.HexaBPM__ServiceRequest__c  = srObj.Id;
            pi.HexaBPM__Product__c =  prodList[i].Id;
            pi.Product__c = prodList[i].Id;
            pi.HexaBPM__Pricing_Line__c = plList[i].Id;
            pi.Open_Online_Payment__c = 'No';
            pi.HexaBPM__Cost__c = 100;
            pi.HexaBPM__Price_in_USD__c = 100;
            piList.add(pi);
            i++;
        }
        insert piList;
        return piList;

    }

    public static List<User> createUsers(String profileName) {
        List<User> User_List = new List<User>();
        Map<String, Id> profileMap = new Map<String, Id>();
        for (Profile p : [Select Id,Name from Profile]) {
            profileMap.put(p.Name, p.Id);
        }
        for (Integer i = 0; i <10; i++) {
            User user = new User(alias = 'test' + i, email = 'test' + i + '@noemail.com',
                    emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                    localesidkey = 'en_US', profileid = profileMap.get(profileName) , country = 'United States', IsActive = true,
                    timezonesidkey = 'America/Los_Angeles', username = 'tester' + Integer.valueOf(math.rint(math.random()*1000000))+ i + '@noemail.com');
            User_List.add(user);
        }
        insert User_List;
        return User_List;
    }

    public static void createQueuesForSchools(List<School__c> schools,List<user> users){
        List<String> sObjectTypeList = new List<String>{'HexaBPM__Service_Request__c','Lead', 'HexaBPM__SR_Steps__c','HexaBPM__Step__c','Enquiry__c'};
        List<Group> queuelist = new List<Group>();
        List<QueueSobject> sObjectList = new List<QueueSobject>();
        QueueSobject sObj;
        Group groupObj;
        for(School__c s : schools){
            groupObj = new Group();
            groupObj.type = 'Queue';
            //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
            groupObj.Name = s.Short_Name__c + '-Registrar';
            queuelist.add(groupObj);
        }

        groupObj = new Group();
        groupObj.type = 'Queue';
        //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
        groupObj.Name = 'GEMS Central Enrollment Officer';
        queuelist.add(groupObj);

        insert queuelist;

        System.runAs(users[0]){
            for(Group queueObj : queuelist){
                for(String objType : sObjectTypeList){
                    sObj =  new QueueSobject();
                    sObj.QueueId = queueObj.Id;
                    sObj.SobjectType = objType;
                    sObjectList.add(sObj);
                }
            }
            insert sObjectList;
        }

    }
    public static void createQueueConfig(List<School__c> schoolList){
        List<GEMS_Queue_Config__c> registrarConfig = new List<GEMS_Queue_Config__c>();
        GEMS_Queue_Config__c cs;
        for(School__c s : schoolList){
            System.debug('==>'+s);
            cs= new GEMS_Queue_Config__c();
            cs.Name =  s.Short_Name__c + '-Registrar';
            cs.Queue_Type__c = 'Registrar';
            cs.Queue_Name__c = s.Short_Name__c + '_Registrar';
            cs.School_Code__c = s.Short_Name__c;
            cs.School_Name__c = s.Name;
            registrarConfig.add(cs);
        }

        insert registrarConfig;
        cs = new GEMS_Queue_Config__c();
        cs.Name = 'GEMS Central Enrollment Officer';
        cs.Queue_Type__c = 'Registrar';
        cs.Queue_Name__c = 'GEMS_Central_Enrollment_Officer';
        cs.School_Code__c = 'GEMS Central Enrollment Officer';
        cs.School_Name__c = 'GEMS Central Enrollment Officer';
        insert cs;


    }
}