@isTest
private class GEMS_SRTriggerTest {
    static testMethod void GEMS_SRTriggerTest1(){
        List<User> users = GEMS_TestUtils.createUsers('System Administrator');
        
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Registered');
        HexaBPM__SR_Status__c srStatus2 = GEMS_TestUtils.createSRStatus('Approved');
        HexaBPM__SR_Status__c srStatus3 = GEMS_TestUtils.createSRStatus('Rejected');
        
        HexaBPM__Status__c stepStatus1 = GEMS_TestUtils.createStepStatus('APPROVED');
        HexaBPM__Status__c stepStatus2 = GEMS_TestUtils.createStepStatus('REJECTED');
        
        list<school__c> schoolList = new list<school__c>();
        schoolList.add(objSchool);
        
        GEMS_TestUtils.createQueueConfig(schoolList);
        GEMS_TestUtils.createQueuesForSchools(schoolList, users);
        
        HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
        objSR1 = GEMS_TestUtils.createSR('Edit_Critical_Data');
        
        objSR1 = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c 
                 where id=:objSR1.id];
                 
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR1,'VERIFICATION_OF_APPLICATION','Awaiting Verification');
        
        objSR1.sys_Edit_Critical_details_Approved__c = true;
        update objSR1;
        
        objSR1.sys_Edit_Critical_details_Rejected__c = true;
        update objSR1;
    }
    
    static testMethod void GEMS_SRTriggerTest2(){
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
        Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
        objStudent.school__c = objSchool.id;
        objStudent.academic_year__c = objAy.id;
        objStudent.gradeLookup__c = objGrade.id;
        objStudent.Current_Status__c = 'EN';
        update objStudent;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Account Acc = new Account(LastName = 'sdsdsdsd', recordtypeid = AccountRecordTypeInfo.get('Student').getRecordTypeId());
        acc.Emirates_Full_Name__c = 'Full Name';
        acc.Country__c = '172';
        Acc.school__c = objSchool.id;
        Acc.academic_year__c = objAy.id;
        Acc.gradeLookup__c = objGrade.id;
        Acc.Current_Status__c = 'EN';
        insert Acc;
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'TC_Request' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        
        HexaBPM__Service_Request__c objSR1 = new HexaBPM__Service_Request__c();
        objSR1.Transfer_school_name__c = objSchool.id;
        objSR1.recordTypeId = recordTypeId;
        objSR1.school__c = objSchool.id;
        objSR1.Student__c = objStudent.id;
        objSR1.HexaBPM__Customer__c = objStudent.id;
        objSR1.Academic_Year__c = objAy.id;
        insert objSR1;
        
        list<string> lstSRS = new list<string>();
        lstSRS.add(objSR1.Id);
        GEMS_SRTriggerHelper.UpdateInformaticaCheckBox_NonFuture(lstSRS);
        
        objSR1.student__c = Acc.id;
        update objSR1;
    }
    
    static testMethod void GEMS_SRTriggerTest3(){
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('Registration - Fee', objGrade.stream__c, objAY.id, objSchool.id);
        
        Enquiry__c objEnq = new Enquiry__c();
        objEnq.FirstName__c = 'Test';
        objEnq.lastname__c = 'Test';
        
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
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Draft');

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
        objSR.Service_Type__c = 'Enrollment Short Form';
        objSR.Lead_Reference__c = '1111111111111';
        objSR.Primary_Contact__c = 'Father';
        objSR.Last_Name_Father__c = 'Test FName';
        objSR.First_Name_Father__c = 'Test LName';
        objSR.enquiry__c = objEnq.id;
        insert objSR;
        
        HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('ENROLLMENT', 'ENROLLMENT', objSR.id);
        
        grade__c objGrade1 = new grade__c();
        objGrade1.Academic_Year__c = objAy.id;
        objGrade1.School__c = objSchool.id;
        objGrade1.Age_Cut_off_Date__c = system.today();
        objGrade1.Grade_Display__c = '02';
        objGrade1.grade__c = '2';
        objGrade1.GRM_ID__c = 123456;
        objGrade1.Maximum_Age__c = 18;
        objGrade1.Minimum_Age__c = 3;
        objGrade1.Active__c = true;
        objGrade1.Open_Online_Payment__c = 'Yes';
        objGrade1.Stream__c = '1';

        insert objGrade1;
        
        objSR.gradeLookup__c = objGrade1.id;
        update objSR;
        
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Registered');
        objSR.HexaBPM__Internal_SR_Status__c = srStatus1.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus1.id;
        objSR.Update_SR_Status_to_Assessment__c = true;
        objSR.Update_status_to_registered__c = true;
        update objSR;
    } 
    
    static testMethod void GEMS_SRTriggerTest4(){
        school__c objSchool = GEMS_TestUtils.createSchool();
        academic_year__c objAy = GEMS_TestUtils.createAcademicYear(objSchool);
        grade__c objGrade = GEMS_TestUtils.createGrade(objSchool, objAy);
        
        Amount__c objAmount = GEMS_TestUtils.createAmount('Registration - Fee', objGrade.stream__c, objAY.id, objSchool.id);
        
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Enrollment' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Draft');

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
        objSR.Primary_Contact__c = 'Mother';
        objSR.Last_Name_Mother__c = 'Test Lname';
        objSR.First_Name_Mother__c = 'Test FName';
        objSR.First_Name__c = 'Fname';
        objSR.Last_Name__c = 'LName';
        objSR.HexaBPM__Email__c = 'testemail@gems.com';
        objSR.Service_Type__c = 'Enrollment Short Form';
        objSR.Lead_Reference__c = '1111111111111';
        insert objSR;
        
        HexaBPM__SR_Price_Item__c objSRItem = GEMS_testUtils.createPricing('ENROLLMENT', 'ENROLLMENT', objSR.id);
        
        grade__c objGrade1 = new grade__c();
        objGrade1.Academic_Year__c = objAy.id;
        objGrade1.School__c = objSchool.id;
        objGrade1.Age_Cut_off_Date__c = system.today();
        objGrade1.Grade_Display__c = '02';
        objGrade1.grade__c = '2';
        objGrade1.GRM_ID__c = 123456;
        objGrade1.Maximum_Age__c = 18;
        objGrade1.Minimum_Age__c = 3;
        objGrade1.Active__c = true;
        objGrade1.Open_Online_Payment__c = 'Yes';
        objGrade1.Stream__c = '1';

        insert objGrade1;
        
        objSR.last_name_mother__c = 'Test MName';
        
        objSR.gradeLookup__c = objGrade1.id;
        update objSR;
        
        HexaBPM__SR_Status__c srStatus1 = GEMS_TestUtils.createSRStatus('Registered');
        objSR.HexaBPM__Internal_SR_Status__c = srStatus1.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus1.id;
        objSR.Update_SR_Status_to_Assessment__c = true;
        objSR.Update_status_to_registered__c = true;
        objSR.mobile__c = '+971555555555';
        update objSR;
    } 
    
    static testMethod void GEMS_SRTrigger_UnCovered(){
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        string recordTypeId = '';
        string devName = '';
        for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Inter_Unit_Student_Transfer' and sObjectType = 'HexaBPM__Service_Request__c']) {
            recordTypeId = rectyp.Id;
            devName = rectyp.DeveloperName;
        }
        objSR.recordTypeId = recordTypeId;
        objSR.occupation__c = 'Test';
        objSR.Update_SR_Status_to_Assessment__c = false;
        objSR.Update_status_to_registered__c = false;
        objSR.Primary_Contact__c = 'Guardian';
        objSR.First_Name_Guardian__c = 'Test FName';
        objSR.Last_Name_Guardian__c = 'Test LName';
        insert objSR;
        
        Product2 objProd = new Product2(Name='registration',ProductCode='registration');
        insert objProd;
        
        HexaBPM__Pricing_Line__c PL = new HexaBPM__Pricing_Line__c();
        PL.HexaBPM__Active__c = true;
        PL.HexaBPM__Product__c = objProd.Id;
        PL.HexaBPM__Priority__c = 1;
        insert PL;
        
        list<HexaBPM__SR_Price_Item__c> lstSRPs = new list<HexaBPM__SR_Price_Item__c>();
        HexaBPM__SR_Price_Item__c SRP = new HexaBPM__SR_Price_Item__c();
        SRP.HexaBPM__ServiceRequest__c = objSR.Id;
        SRP.HexaBPM__Non_Reevaluate__c = true;
        SRP.HexaBPM__Product__c = objProd.Id;
        SRP.HexaBPM__Sys_Added_through_Code__c = true;
        SRP.HexaBPM__Base_Price__c = 100;
        SRP.Status__c = 'Added';
        SRP.HexaBPM__Pricing_Line__c = PL.Id;
        lstSRPs.add(SRP);
        
        insert lstSRPs;
        
        list<HexaBPM__Service_Request__c> listSR = new list<HexaBPM__Service_Request__c>();
        listSR.add(objSR);
        list<string> lstSRS = new list<string>();
        lstSRS.add(objSR.Id);
        GEMS_SRTriggerHelper.UpdateInformaticaCheckBox_NonFuture(lstSRS);
        GEMS_SRTriggerHelper.getErrorMessage('End','Enrollment','SR-00001');
        
        
        map<Id,HexaBPM__Service_Request__c> MapSR = new map<Id,HexaBPM__Service_Request__c>();
        MapSR.put(objSR.Id,new HexaBPM__Service_Request__c(Update_status_to_registered__c=true,Update_SR_Status_to_Assessment__c=false));
        GEMS_SRTriggerHelper.UpdateSRPriceItemStatus(listSR,MapSR);
    }
    static testMethod void GEMS_SRTrigger_UnCovered2(){
        list<profile> tempProfile = new list<profile>();
        tempProfile = [select id from profile where Name='GEMS API'];
        
        User user = new User(alias = 'test', email = 'test@noemail.com',
                               emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                               localesidkey = 'en_US', profileid =tempProfile[0].id , country = 'United States', IsActive = true,
                               timezonesidkey = 'America/Los_Angeles', username = 'tester' + Integer.valueOf(math.rint(math.random()*1000000))+'@noemail.com');
        
        insert user;
        System.runAs(user){
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
            string recordTypeId = '';
            string devName = '';
            for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Inter_Unit_Student_Transfer' and sObjectType = 'HexaBPM__Service_Request__c']) {
                recordTypeId = rectyp.Id;
                devName = rectyp.DeveloperName;
            }
            objSR.recordTypeId = recordTypeId;
            objSR.occupation__c = 'Test';
            try{
                insert objSR;
            }catch(Exception e){}
            
        }
    }
    static testMethod void GEMS_SRTrigger_UnCovered3(){
        
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
            string recordTypeId = '';
            string devName = '';
            for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Inter_Unit_Student_Transfer' and sObjectType = 'HexaBPM__Service_Request__c']) {
                recordTypeId = rectyp.Id;
                devName = rectyp.DeveloperName;
            }
            objSR.recordTypeId = recordTypeId;
            objSR.occupation__c = 'Test';
            insert objSR;
            
            
            list<HexaBPM__Status__c> lstStatus = new list<HexaBPM__Status__c>();
            HexaBPM__Status__c objStatus = new HexaBPM__Status__c();
            objStatus.Name = 'APPROVED';
            objStatus.HexaBPM__Code__c = 'APPROVED';
            lstStatus.add(objStatus);
            objStatus = new HexaBPM__Status__c();
            objStatus.Name = 'REJECTED';
            objStatus.HexaBPM__Code__c = 'REJECTED';
            lstStatus.add(objStatus);
            
            insert lstStatus;
            
            list<HexaBPM__SR_Status__c> lstSRStatus = new list<HexaBPM__SR_Status__c>();
            HexaBPM__SR_Status__c srstatus = new HexaBPM__SR_Status__c();
            srstatus.Name = 'Approved';
            srstatus.HexaBPM__Code__c = 'Approved';
            lstSRStatus.add(srstatus);
            
            srstatus = new HexaBPM__SR_Status__c();
            srstatus.Name = 'Rejected';
            srstatus.HexaBPM__Code__c = 'Rejected';
            lstSRStatus.add(srstatus);
            
            insert lstSRStatus;
            
            
            HexaBPM__Step_Template__c objStepTemplate = new HexaBPM__Step_Template__c();
            objStepTemplate.Name = 'VERIFICATION_OF_APPLICATION';
            objStepTemplate.HexaBPM__Code__c = 'VERIFICATION_OF_APPLICATION';
            objStepTemplate.HexaBPM__Step_RecordType_API_Name__c = 'General';
            insert objStepTemplate;
            
            HexaBPM__SR_Steps__c SRStep = new HexaBPM__SR_Steps__c();
            SRStep.HexaBPM__Step_Template__c = objStepTemplate.Id;
            SRStep.HexaBPM__Active__c = true;
            SRStep.HexaBPM__Step_RecordType_API_Name__c = 'General';
            SRStep.HexaBPM__Summary__c = 'Verify Application';
            insert SRStep;
            
            HexaBPM__Step__c objstp = new HexaBPM__Step__c();
            objstp.HexaBPM__SR__c = objSR.Id;
            objstp.HexaBPM__SR_Step__c = SRStep.Id;
            insert objstp;
            
            objSR.sys_Edit_Critical_details_Approved__c = true;
            update objSR;
            
            objSR.sys_Edit_Critical_details_Rejected__c = true;
            update objSR;
    }
    static testMethod void GEMS_SRTrigger_UnCovered4(){
        
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
            string recordTypeId = '';
            string devName = '';
            for (RecordType rectyp: [select id, DeveloperName from RecordType where DeveloperName = 'Inter_Unit_Student_Transfer' and sObjectType = 'HexaBPM__Service_Request__c']) {
                recordTypeId = rectyp.Id;
                devName = rectyp.DeveloperName;
            }
            objSR.recordTypeId = recordTypeId;
            objSR.occupation__c = 'Test';
            insert objSR;
            
            
            list<HexaBPM__Status__c> lstStatus = new list<HexaBPM__Status__c>();
            HexaBPM__Status__c objStatus = new HexaBPM__Status__c();
            objStatus.Name = 'APPROVED';
            objStatus.HexaBPM__Code__c = 'APPROVED';
            lstStatus.add(objStatus);
            objStatus = new HexaBPM__Status__c();
            objStatus.Name = 'REJECTED';
            objStatus.HexaBPM__Code__c = 'REJECTED';
            lstStatus.add(objStatus);
            
            insert lstStatus;
            
            list<HexaBPM__SR_Status__c> lstSRStatus = new list<HexaBPM__SR_Status__c>();
            HexaBPM__SR_Status__c srstatus = new HexaBPM__SR_Status__c();
            srstatus.Name = 'Approved';
            srstatus.HexaBPM__Code__c = 'Approved';
            lstSRStatus.add(srstatus);
            
            srstatus = new HexaBPM__SR_Status__c();
            srstatus.Name = 'Rejected';
            srstatus.HexaBPM__Code__c = 'Rejected';
            lstSRStatus.add(srstatus);
            
            insert lstSRStatus;
            
            
            HexaBPM__Step_Template__c objStepTemplate = new HexaBPM__Step_Template__c();
            objStepTemplate.Name = 'VERIFICATION_OF_APPLICATION';
            objStepTemplate.HexaBPM__Code__c = 'VERIFICATION_OF_APPLICATION';
            objStepTemplate.HexaBPM__Step_RecordType_API_Name__c = 'General';
            insert objStepTemplate;
            
            HexaBPM__SR_Steps__c SRStep = new HexaBPM__SR_Steps__c();
            SRStep.HexaBPM__Step_Template__c = objStepTemplate.Id;
            SRStep.HexaBPM__Active__c = true;
            SRStep.HexaBPM__Step_RecordType_API_Name__c = 'General';
            SRStep.HexaBPM__Summary__c = 'Verify Application';
            insert SRStep;
            
            HexaBPM__Step__c objstp = new HexaBPM__Step__c();
            objstp.HexaBPM__SR__c = objSR.Id;
            objstp.HexaBPM__SR_Step__c = SRStep.Id;
            insert objstp;
            
            objSR.sys_Edit_Critical_details_Rejected__c = true;
            update objSR;
    }
}