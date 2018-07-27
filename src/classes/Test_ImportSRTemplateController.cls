/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_ImportSRTemplateController{

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        map<string,string> mapQueue = new map<string,string>();
        for(Group grp:[select id,name,developername from Group where type='Queue']){
            mapQueue.put(grp.developername,grp.Id);
        }
        
        Group g1 = new Group(Name='HR Admin',DeveloperName='HR_Admin',type='Queue');
        if(mapQueue.get('HR_Admin')!=null)
            g1.Id = mapQueue.get('HR_Admin');
        upsert g1;
        
        Group g2 = new Group(Name='IT Admin',DeveloperName='IT_Admin',type='Queue');
        if(mapQueue.get('IT_Admin')!=null)
            g2.Id = mapQueue.get('IT_Admin');
        upsert g2;
        
        Group g3 = new Group(Name='PRO',DeveloperName='PRO', type='Queue');
        if(mapQueue.get('PRO')!=null)
            g3.Id = mapQueue.get('PRO');
        upsert g3;
        
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'HexaBPM__Step__c');
        insert q1;
        
        QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'HexaBPM__SR_Steps__c');
        insert q2;
        
        QueuesObject q3 = new QueueSObject(QueueID = g1.id, SobjectType = 'HexaBPM__Step_Template__c');
        insert q3;
        
        QueuesObject ITq1 = new QueueSObject(QueueID = g2.id, SobjectType = 'HexaBPM__Step__c');
        insert ITq1;
        
        QueuesObject ITq2 = new QueueSObject(QueueID = g2.id, SobjectType = 'HexaBPM__SR_Steps__c');
        insert ITq2;
        
        QueuesObject ITq3 = new QueueSObject(QueueID = g2.id, SobjectType = 'HexaBPM__Step_Template__c');
        insert ITq3;
        
        QueuesObject proq1 = new QueueSObject(QueueID = g3.id, SobjectType = 'HexaBPM__Step__c');
        insert proq1;
        
        QueuesObject proq2 = new QueueSObject(QueueID = g3.id, SobjectType = 'HexaBPM__SR_Steps__c');
        insert proq2;
        
        QueuesObject proqq3 = new QueueSObject(QueueID = g3.id, SobjectType = 'HexaBPM__Step_Template__c');
        insert proqq3;
        
        System.runAs(new User(Id = UserInfo.getUserId()) ) {
            Process_Migration_Setup__c objCS = new Process_Migration_Setup__c();
            objCS.Name = 'Durga';
            objCS.User_Name__c = 'durga.prasad@nsigulf.com';
            objCS.Password__c = 'test@123';
            objCS.Security_Token__c = '';
            objCS.Instance_URL__c = 'https://na16.salesforce.com';
            objCS.Production_Instance__c = false;
            insert objCS;
            
            list<HexaBPM__Step_Template__c> lstStpTmpls = new list<HexaBPM__Step_Template__c>();
            HexaBPM__Step_Template__c stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Initial Approval';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Initial Approval';
            lstStpTmpls.add(stpTempl);
            
            stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Initiate Visa Process';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Initiate Visa Process';
            lstStpTmpls.add(stpTempl);
            
            stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Issue Laptop';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Issue Laptop';
            lstStpTmpls.add(stpTempl);
            
            stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Create Email Account';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Create Email Account';
            lstStpTmpls.add(stpTempl);
            
            stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Send Welcome Pack';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Send Welcome Pack';
            lstStpTmpls.add(stpTempl);
            
            stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Assign Workstation';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Assign Workstation';
            lstStpTmpls.add(stpTempl);
            
            stpTempl = new HexaBPM__Step_Template__c();
            stpTempl.Name = 'Collect Bank Details';
            stpTempl.HexaBPM__Step_RecordType_API_Name__c = 'General';
            stpTempl.HexaBPM__Code__c = 'Collect Bank Details';
            lstStpTmpls.add(stpTempl);
            
            insert lstStpTmpls;
            
            HexaBPM__Document_Master__c objDM = new HexaBPM__Document_Master__c();
            objDM.Name = 'Latest Passport size photo';
            objDM.HexaBPM__Code__c = 'Latest Passport size photo';
            insert objDM;
            
            HexaBPM__Document_Master__c objDocMaster = new HexaBPM__Document_Master__c();
            objDocMaster.Name = 'Passport Copy';
            objDocMaster.HexaBPM__Code__c = 'Passport Copy';
            insert objDocMaster;
            
            list<HexaBPM__Status__c> lstSTepStatus = new list<HexaBPM__Status__c>();
            list<HexaBPM__SR_Status__c> lstSRStatus = new list<HexaBPM__SR_Status__c>();
            
            HexaBPM__Status__c objStat = new HexaBPM__Status__c();
            objStat.Name = 'AWAITING_APPROVAL';
            objStat.HexaBPM__Code__c = 'AWAITING_APPROVAL';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Approved';
            objStat.HexaBPM__Code__c = 'APPROVED';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Rejected';
            objStat.HexaBPM__Type__c = 'End';
            objStat.HexaBPM__Code__c = 'Rejected';
            lstSTepStatus.add(objStat);
            
            
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Pending';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Pending';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Application Submitted';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Application Submitted';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Entry Permit Received';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Entry Permit Received';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Stamping Completed';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Stamping Completed';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Stamping Completed';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Stamping Completed';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Medical Completed';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Medical Completed';
            lstSTepStatus.add(objStat);
            
            objStat = new HexaBPM__Status__c();
            objStat.Name = 'Completed';
            objStat.HexaBPM__Type__c = '';
            objStat.HexaBPM__Code__c = 'Completed';
            lstSTepStatus.add(objStat);
            
            Database.SaveResult[] LstStepStatusInsertResult = Database.insert(lstSTepStatus, false);
            
            map<string,string> mapStepStatus = new map<String,string>();
            for(HexaBPM__Status__c stepstat:[select id,Name,HexaBPM__Code__c from HexaBPM__Status__c]){
                mapStepStatus.put(stepstat.Name,stepstat.Id);
            }
            
            list<HexaBPM__Transition__c> lstTransitionsInsert = new list<HexaBPM__Transition__c>();
            
            HexaBPM__Transition__c objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Approved');
            lstTransitionsInsert.add(objTransitn);
            
            objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Rejected');
            lstTransitionsInsert.add(objTransitn);
            
            objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Application Submitted');
            lstTransitionsInsert.add(objTransitn);
            
            objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Entry Permit Received');
            lstTransitionsInsert.add(objTransitn);
            
            objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Medical Completed');
            lstTransitionsInsert.add(objTransitn);
            
            objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Stamping Completed');
            lstTransitionsInsert.add(objTransitn);
            
            objTransitn = new HexaBPM__Transition__c();
            objTransitn.HexaBPM__From__c = mapStepStatus.get('Pending');
            objTransitn.HexaBPM__To__c = mapStepStatus.get('Completed');
            lstTransitionsInsert.add(objTransitn);
            
            insert lstTransitionsInsert;
            
            HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Awaiting Approval';
            objSRStatus.HexaBPM__Code__c = 'AWAITING_APPROVAL';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Completed';
            objSRStatus.HexaBPM__Code__c = 'Completed';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Draft';
            objSRStatus.HexaBPM__Code__c = 'DRAFT';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Rejected';
            objSRStatus.HexaBPM__Code__c = 'Rejected';
            lstSRStatus.add(objSRStatus);
            
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Submitted';
            objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
            lstSRStatus.add(objSRStatus);
            
            list<HexaBPM__Transition__c> lstTransitions = new list<HexaBPM__Transition__c>();
            HexaBPM__Transition__c objTrans = new HexaBPM__Transition__c();
            objTrans.HexaBPM__From__c = lstSTepStatus[0].Id;
            objTrans.HexaBPM__To__c = lstSTepStatus[1].Id;
            lstTransitions.add(objTrans);
            
            //insert lstTransitions;
            
            HexaBPM__Step_Template__c objSTM = new HexaBPM__Step_Template__c();
            objSTM.Name = 'General';
            objSTM.HexaBPM__Code__c = 'General';
            objSTM.HexaBPM__Step_RecordType_API_Name__c = 'General';
            insert objSTM;
            
            HexaBPM__SR_Template__c objTemplate = new HexaBPM__SR_Template__c();
            objTemplate.Name = 'Sample_Test_RecType';
            objTemplate.HexaBPM__SR_RecordType_API_Name__c = 'General';
            objTemplate.HexaBPM__Active__c = true;
            insert objTemplate;
            
            HexaBPM__Step_Template__c objStepType = new HexaBPM__Step_Template__c();
            objStepType.Name = 'Approve Sample_Test_RecType';
            objStepType.HexaBPM__Code__c = 'Sample_Test_RecType';
            objStepType.HexaBPM__Step_RecordType_API_Name__c = 'Sample_Test_RecType';
            objStepType.HexaBPM__Summary__c = 'Sample_Test_RecType';
            insert objStepType;
            
            
            
            Product2 objProd = new Product2();
            objProd.Name = 'Sample Test';
            objProd.ProductCode = 'SampleTest';
            objProd.IsActive = true;
            insert objProd;
            
            Product2 objProd2 = new Product2();
            objProd2.Name = 'On Boarding Charges';
            objProd2.ProductCode = '12345';
            objProd2.IsActive = true;
            insert objProd2;
            
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Closed';
            objSRStatus.HexaBPM__Code__c = 'CLOSED';
            objSRStatus.HexaBPM__Type__c = 'End';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Rejected';
            objSRStatus.HexaBPM__Code__c = 'REJECTED';
            objSRStatus.HexaBPM__Type__c = 'Rejected';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Awaiting Approval';
            objSRStatus.HexaBPM__Code__c = 'AWAITING_APPROVAL';
            objSRStatus.HexaBPM__Type__c = 'Start';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Approved';
            objSRStatus.HexaBPM__Code__c = 'APPROVED';
            objSRStatus.HexaBPM__Type__c = 'Intermediate';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Submitted';
            objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
            lstSRStatus.add(objSRStatus);
            
            objSRStatus = new HexaBPM__SR_Status__c();
            objSRStatus.Name = 'Draft';
            objSRStatus.HexaBPM__Code__c = 'DRAFT';
            lstSRStatus.add(objSRStatus);
            
            
            Database.SaveResult[] LstSRStatusInsertResult = Database.insert(lstSRStatus, false);
            
            
            //list<HexaBPM__Transition__c> lstTransitions = new list<HexaBPM__Transition__c>();
            HexaBPM__Transition__c objTransition = new HexaBPM__Transition__c();
            objTransition.HexaBPM__From__c = lstSTepStatus[0].Id; // awaiting approval
            objTransition.HexaBPM__To__c = lstSTepStatus[1].Id; // approved
            lstTransitions.add(objTransition);
            
            objTransition = new HexaBPM__Transition__c();
            objTransition.HexaBPM__From__c = lstSTepStatus[1].Id; // approved
            objTransition.HexaBPM__To__c = lstSTepStatus[2].Id; // Rejected
            lstTransitions.add(objTransition);
            
            insert lstTransitions;
            
            HexaBPM__SR_Steps__c objSRStep = new HexaBPM__SR_Steps__c();
            objSRStep.HexaBPM__SR_Template__c = objTemplate.Id;
            objSRStep.HexaBPM__Step_RecordType_API_Name__c = 'General';
            objSRStep.HexaBPM__Step_Template__c = objStepType.Id; // Step Type
            objSRStep.HexaBPM__Summary__c = 'Approve Request';
            objSRStep.HexaBPM__Step_No__c = 1.0;
            objSRStep.HexaBPM__Start_Status__c = lstSTepStatus[0].Id; // Default Step Status
            insert objSRStep;
            
            HexaBPM__SR_Template_Docs__c objTempDocs = new HexaBPM__SR_Template_Docs__c();
            objTempDocs.HexaBPM__SR_Template__c = objTemplate.Id;
            objTempDocs.HexaBPM__Document_Master__c = objDocMaster.Id;
            objTempDocs.HexaBPM__On_Submit__c = true;
            objTempDocs.HexaBPM__Evaluated_at__c = objSRStep.Id;
            objTempDocs.HexaBPM__Validated_at__c = objSRStep.Id;
            objTempDocs.HexaBPM__Original_Sighted_at__c = objSRStep.Id;
            objTempDocs.HexaBPM__Courier_collected_at__c = objSRStep.Id;
            objTempDocs.HexaBPM__Courier_delivered_at__c = objSRStep.Id;
            objTempDocs.HexaBPM__Generate_Document__c = true;
            insert objTempDocs;
            
            
            HexaBPM__SR_Template_Item__c objTemplItem = new HexaBPM__SR_Template_Item__c();
            objTemplItem.HexaBPM__Consumed_at__c = objSRStep.Id;
            objTemplItem.HexaBPM__Evaluated_at__c = objSRStep.Id;
            objTemplItem.HexaBPM__On_Submit__c = true;
            objTemplItem.HexaBPM__Product__c = objProd.Id;
            objTemplItem.HexaBPM__SR_Template__c = objTemplate.Id;
            insert objTemplItem;
            
            
            list<HexaBPM__Step_Transition__c> lstStepTransitions = new list<HexaBPM__Step_Transition__c>();
            HexaBPM__Step_Transition__c objStepTran;
            objStepTran = new HexaBPM__Step_Transition__c();
            objStepTran.HexaBPM__SR_Step__c = objSRStep.Id;
            objStepTran.HexaBPM__SR_Status_Internal__c = lstSRStatus[0].Id;
            objStepTran.HexaBPM__SR_Status_External__c = lstSRStatus[0].Id;
            objStepTran.HexaBPM__Transition__c = lstTransitions[0].Id;
            lstStepTransitions.add(objStepTran);
            
            objStepTran = new HexaBPM__Step_Transition__c();
            objStepTran.HexaBPM__SR_Step__c = objSRStep.Id;
            objStepTran.HexaBPM__SR_Status_Internal__c = lstSRStatus[1].Id;
            objStepTran.HexaBPM__SR_Status_External__c = lstSRStatus[1].Id;
            objStepTran.HexaBPM__Transition__c = lstTransitions[1].Id;
            lstStepTransitions.add(objStepTran);
                
            HexaBPM__Business_Rule__c objBR = new HexaBPM__Business_Rule__c();
            objBR.HexaBPM__Action_Type__c = 'Custom Conditions Actions';
            objBR.HexaBPM__Execute_on_Insert__c = true;
            objBR.HexaBPM__Execute_on_Update__c = true;
            objBR.HexaBPM__SR_Steps__c = objSRStep.Id;
            insert objBR;
            
            list<HexaBPM__Condition__c> lstCond = new list<HexaBPM__Condition__c>();
            
            HexaBPM__Condition__c objCon = new HexaBPM__Condition__c();
            objCon.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
            objCon.HexaBPM__Field_Name__c = 'Name';
            objCon.HexaBPM__Operator__c = '!=';
            objCon.HexaBPM__Value__c = 'null';
            objCon.HexaBPM__Business_Rule__c = objBR.Id;
            lstCond.add(objCon);
            
            objCon = new HexaBPM__Condition__c();
            objCon.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
            objCon.HexaBPM__Field_Name__c = 'Name';
            objCon.HexaBPM__Operator__c = '!=';
            objCon.HexaBPM__Value__c = 'null';
            objCon.HexaBPM__SR_Template_Docs__c = objTempDocs.Id;
            lstCond.add(objCon);
            
            insert lstCond;
            
            list<HexaBPM__Action__c> lstActions = new list<HexaBPM__Action__c>();
            HexaBPM__Action__c objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'HexaBPM__Service_Request__c';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            lstActions.add(objAction);
            
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'Account';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'Contact';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'Step';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            lstActions.add(objAction);
            
            insert lstActions;
            
            //HexaBPM__Business_Rule__c objBR = new HexaBPM__Business_Rule__c();
            objBR.HexaBPM__Action_Type__c = 'Custom Conditions Actions';
            objBR.HexaBPM__Execute_on_Insert__c = true;
            objBR.HexaBPM__Execute_on_Update__c = true;
            objBR.HexaBPM__SR_Steps__c = objSRStep.Id;
            upsert objBR;
            
            list<HexaBPM__Business_Rule__c> lstBR = new list<HexaBPM__Business_Rule__c>();
            
            //lstBR.add(objBR);
            //list<HexaBPM__Condition__c> lstCond = new list<HexaBPM__Condition__c>();
            
            objCon = new HexaBPM__Condition__c();
            objCon.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
            objCon.HexaBPM__Field_Name__c = 'Name';
            objCon.HexaBPM__Operator__c = '!=';
            objCon.HexaBPM__Value__c = 'null';
            objCon.HexaBPM__Business_Rule__c = objBR.Id;
            lstCond.add(objCon);
            
            objCon = new HexaBPM__Condition__c();
            objCon.HexaBPM__Object_Name__c = 'HexaBPM__Service_Request__c';
            objCon.HexaBPM__Field_Name__c = 'Name';
            objCon.HexaBPM__Operator__c = '!=';
            objCon.HexaBPM__Value__c = 'null';
            objCon.HexaBPM__SR_Template_Docs__c = objTempDocs.Id;
            lstCond.add(objCon);
            upsert lstCond;
            
            //list<HexaBPM__Action__c> lstActions = new list<HexaBPM__Action__c>();
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'HexaBPM__Service_Request__c';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            lstActions.add(objAction);
            
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'Account';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'Contact';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            
            objAction = new HexaBPM__Action__c();
            objAction.HexaBPM__Business_Rule__c = objBR.Id;
            objAction.HexaBPM__Action_Type__c = 'Step';
            objAction.HexaBPM__Field_Name__c = objStepType.Id;
            objAction.HexaBPM__Field_Type__c = 'string';
            lstActions.add(objAction);
            
            upsert lstActions;
            
            HexaBPM__SR_Template__c objSRTemplateTest = new HexaBPM__SR_Template__c();
            objSRTemplateTest.HexaBPM__SR_RecordType_API_Name__c = 'GeneralTest';
            objSRTemplateTest.Name = 'GeneralTest';
            objSRTemplateTest.HexaBPM__Active__c = true;
            
            ImportSRTemplateController.isApexTest = true;
            ImportSRTemplateController obj = new ImportSRTemplateController();
            ImportSRTemplateController.SRProcessWrap objwrap =  new ImportSRTemplateController.SRProcessWrap();
            obj.strTemplateName = 'GeneralTest';
            obj.selSandBox = objCS.Id;
            obj.FetchAccesToken();
            obj.ImportProcess();
            System.assertNOTEquals(null,obj.objProcess);
            //objwrap.SRtemplate = objSRTemplateTest;
            //objwrap.lstBR = lstBR;
            obj.ConfirmSave();
        }
        
    }
}