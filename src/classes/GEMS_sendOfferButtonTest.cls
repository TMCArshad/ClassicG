@isTest
private class GEMS_sendOfferButtonTest {
    static testMethod void GEMS_sendOfferButtonTest1(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Exclude_Fees__c = true;
        objSR.Fee_Exclusion_Reason__c = 'Emirati Scholarship';
        update objSR;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application', 'Verified');
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        //GEMS_sendOfferButton.generateOfferDetails(objSR.id);
    }
    
    static testMethod void GEMS_sendOfferButtonTest2(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Exclude_Fees__c = true;
        objSR.Fee_Exclusion_Reason__c = 'Emirati Scholarship';
        update objSR;
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
    }
    
    static testMethod void GEMS_sendOfferButtonTest3(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Exclude_Fees__c = true;
        objSR.Fee_Exclusion_Reason__c = 'Emirati Scholarship';
        update objSR;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application', 'Awaiting');
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
    }
    
    static testMethod void GEMS_sendOfferButtonTest4(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Exclude_Fees__c = true;
        objSR.Fee_Exclusion_Reason__c = 'Emirati Scholarship';
        update objSR;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application', 'Verified');
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Document_Master__c = objDocMaster.id;
        objSRDoc.HexaBPM__Service_Request__c = objSR.id;
        objSRDoc.HexaBPM__SR_Template_Doc__c = objTempDocs.id;
        insert objSRDoc;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
        
        GEMS_sendOfferButton.PrepareExceptionMsg('test,FIELD_CUSTOM_VALIDATION_EXCEPTION,test:HexaBPM.CommonCustomException:errormessage:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,FIELD_CUSTOM_VALIDATION_EXCEPTION,test:HexaBPM.CommonCustomException:FIELD_CUSTOM_VALIDATION_EXCEPTION:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,test:HexaBPM.CommonCustomException:HexaBPM.CommonCustomException::error:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,test:HexaBPM.CommonCustomException::HexaBPM.CommonCustomException::HexaBPM.CommonCustomException:error');

    }
    static testMethod void GEMS_sendOfferButtonTest5(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Exclude_Fees__c = true;
        objSR.Fee_Exclusion_Reason__c = 'Emirati Scholarship';
        update objSR;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application', 'Verified');
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
        objSRDoc.HexaBPM__Document_Master__c = objDocMaster.id;
        objSRDoc.HexaBPM__Service_Request__c = objSR.id;
        objSRDoc.HexaBPM__SR_Template_Doc__c = objTempDocs.id;
        //insert objSRDoc;
        
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Emirati PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Emirati PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Emirati PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Qatar PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
        
        GEMS_sendOfferButton.PrepareExceptionMsg('test,FIELD_CUSTOM_VALIDATION_EXCEPTION,test:HexaBPM.CommonCustomException:errormessage:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,FIELD_CUSTOM_VALIDATION_EXCEPTION,test:HexaBPM.CommonCustomException:FIELD_CUSTOM_VALIDATION_EXCEPTION:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,test:HexaBPM.CommonCustomException:HexaBPM.CommonCustomException::error:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,test:HexaBPM.CommonCustomException::HexaBPM.CommonCustomException::HexaBPM.CommonCustomException:error');

    }
    static testMethod void GEMS_sendOfferButtonTest6(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c,School__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
                 
        School__c objsch = new School__c(Id=objSR.School__c);
        objsch.Name = 'Test School';
        objsch.country__c = '97';
        upsert objsch;
        
        objSR.School__c = objsch.id;
        objSR.Exclude_Fees__c = false;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Fee_Exclusion_Reason__c = null;
        update objSR;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application', 'Verified');
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Emirati PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Emirati PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Emirati PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Qatar PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Abu Dhabi PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Abu Dhabi PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
        
        objsch = new School__c(Id=objSR.School__c);
        objsch.Name = 'Test School';
        objsch.country__c = '157';
        upsert objsch;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
        
        GEMS_sendOfferButton.PrepareExceptionMsg('test,FIELD_CUSTOM_VALIDATION_EXCEPTION,test:HexaBPM.CommonCustomException:errormessage:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,FIELD_CUSTOM_VALIDATION_EXCEPTION,test:HexaBPM.CommonCustomException:FIELD_CUSTOM_VALIDATION_EXCEPTION:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,test:HexaBPM.CommonCustomException:HexaBPM.CommonCustomException::error:HexaBPM.CommonCustomException:error');
        GEMS_sendOfferButton.PrepareExceptionMsg('test,test:HexaBPM.CommonCustomException::HexaBPM.CommonCustomException::HexaBPM.CommonCustomException:error');

    }
    static testMethod void GEMS_sendOfferButtonTest7(){
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
        objSR = GEMS_TestUtils.createSR('Enrollment');
        
        objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,
                        HexaBPM__Record_Type_Name__c,first_name__c,last_name__c,School__c
                 from HexaBPM__Service_Request__c
                 where id=:objSR.id];
                 
        School__c objsch = new School__c(Id=objSR.School__c);
        objsch.Name = 'Test School';
        objsch.country__c = '157';
        upsert objsch;
        
        objSR.School__c = objsch.id;
        objSR.Exclude_Fees__c = false;
        objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        objSR.Fee_Exclusion_Reason__c = null;
        update objSR;
        
        HexaBPM__Step__c objStep = new HexaBPM__Step__c();
        objStep = GEMS_TestUtils.createStep(objSR,'Verification of Application', 'Verified');
        
        HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Other PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Other PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Other PDF';
        insert objDocMaster;
        
        HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Emirati PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Emirati PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Emirati PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Qatar PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        objDocMaster = new HexaBPM__Document_Master__c();
        objDocMaster.Name = 'Offer Letter Qatar PDF';
        objDocMaster.HexaBPM__Code__c='Offer Letter Abu Dhabi PDF';
        objDocMaster.HexaBPM__Document_Index__c='Offer Letter Abu Dhabi PDF';
        insert objDocMaster;
        
        objTempDocs = new HexaBPM__SR_Template_Docs__c();
        objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
        insert objTempDocs;
        
        GEMS_sendOfferButton.sendOfferDetails(objSR.id);
        GEMS_sendOfferButton.generateOfferDetails(objSR.id);
        
        
    }
}