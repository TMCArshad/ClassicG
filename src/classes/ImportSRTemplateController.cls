/*
    Author      : Durga Prasad
    Date        : 15-Feb-2015
    Description : This is an fetches the SR Process records from another Org.

*/
public with sharing class ImportSRTemplateController {
    public static boolean isApexTest = false;//Variable used for CodeCoverage
    public string username {get; set;}
    public string password {get; set;}
    public string clientId = '';
    public string ConsumerKey = '';
    public string RestClsURL = '';
    public string accsToken = '';
    public string strTemplateName {get; set;}
    public SRProcessWrap objProcess {get; set;}
    public boolean showPnl {get; set;}
    map<string, string> mapEmail_Sms_Templates = new map<string, string>();
    map<string, string> map_QueueName_Id = new map<string, string>(); //to store the Queue Ids for Assigning the SR-Step Owner Ids
    public list<selectOption> lstSelectOption {get; set;}
    public string selSandBox {get; set;}
    public map<id, Process_Migration_Setup__c> mapLoginDetailsCS = new map<id, Process_Migration_Setup__c>();
    public Process_Migration_Setup__c objCS = new Process_Migration_Setup__c();
    public ImportSRTemplateController() {
        strTemplateName = '';
        username = '';
        password = '';
        showPnl = false;
        selSandBox = '';
        lstSelectOption = new list<selectoption>();
        lstSelectOption.add(new selectoption('', '--None--'));
        if (FLSCheckUtil.queryStr1AfterFLS('id,Name,FolderId', 'EmailTemplate')) {
            for (EmailTemplate et : [select id, Name, Folder.Name from EmailTemplate where isActive = true limit 50000 ]) {
                mapEmail_Sms_Templates.put(et.Name, et.Id);
            }
        }
        // to verify whether queue is already available in destin. prepare this map
        if(FLSCheckUtil.queryStr1AfterFLS('QueueId,SobjectType', 'QueueSobject')) {
          for (QueueSobject objQueue : [Select Queue.Name, Queue.DeveloperName, SobjectType, QueueId From QueueSobject where sObjectType = 'HexaBPM__SR_Steps__c' ]) {
              map_QueueName_Id.put(objQueue.Queue.DeveloperName, objQueue.QueueId);
          }
        }
        // get the Org Details for connecting to source org from custom setting Process_Migration_Setup__c which is protected.
        string UserName = '';
        string Password = '';
        string SecurityToken = '';
        if (FLSCheckUtil.queryStr1AfterFLS('Id,Name,User_Name__c,Password__c,Production_Instance__c,Instance_URL__c,Security_Token__c', 'Migration_Settings__c')) {
            for (Process_Migration_Setup__c Mig : [select Id, Name, User_Name__c, Password__c, Production_Instance__c, Instance_URL__c, Security_Token__c from Process_Migration_Setup__c where User_Name__c != null and Password__c != null and IsDeleted = false]) {
                UserName = Mig.User_Name__c;
                Password = Mig.Password__c;
                SecurityToken = Mig.Security_Token__c;
                lstSelectOption.add(new selectoption(Mig.Id, Mig.Name));
                mapLoginDetailsCS.put(Mig.Id, Mig);
            }
        }
        objProcess = new SRProcessWrap();
    }

    public void FetchAccesToken() {
        if (selSandBox != null && mapLoginDetailsCS.get(selSandBox) != null) {
            objCS = mapLoginDetailsCS.get(selSandBox);
            ConnectionError = '';
            try {
                accsToken = AcessToken(objCS.User_Name__c, objCS.Password__c, objCS.Security_Token__c, objCS.Production_Instance__c);
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, string.valueOf(e.getMessage())));
            }
            if (accsToken != null && accsToken != '') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, 'Connection created Successfully, Please provide the SR RecordType API Name to proceed.'));
            } else {
                if (ConnectionError != null && ConnectionError != '') {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, '[ Unable to Connect ' + objCS.Name + ' ] : ' + ConnectionError));
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Failed to create an Connection for ' + objCS.Name + ', Please try again.'));
                }
            }
        }
    }
    // click of fetch process button
    public void ImportProcess() {
        RestClsURL = objCS.Instance_URL__c + '/services/apexrest/HexaBPM/Fetch_SR_Process/GetSRProcess';
        //RestClsURL = objCS.Instance_URL__c+'/services/apexrest/SRProcessMigration/GetSRProcess';
        boolean templateExists = false;
        string strExistingTemplateId = '';
        string TemplateName = '';
        if (strTemplateName != null && strTemplateName != '') {
            if (FLSCheckUtil.queryStr1AfterFLS('Id,Name,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Active__c', 'HexaBPM__SR_Template__c')) {
                list<HexaBPM__SR_Template__c> lstSRTemplate = [select id, Name from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c = :strTemplateName and HexaBPM__Active__c = true and IsDeleted = false];
                if (lstSRTemplate != null && lstSRTemplate.size() > 0) {
                    templateExists = true;
                    strExistingTemplateId = lstSRTemplate[0].Id;
                    TemplateName = lstSRTemplate[0].Name;
                }
            }
        }
        if (templateExists == true) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'SR-Template exists with the Record Type ' + strTemplateName + '. Please click "Deep Delete" button on<a href="/' + strExistingTemplateId + '" target="_blank" class="actionLink">' + TemplateName + '</a>Template.'));
        } else if (templateExists == false && strTemplateName != null && strTemplateName != '') {
            string postData = '{\"SRTemplateName\": \"' + strTemplateName + '\"}';
            JSONParser parser;
            string responseString;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(RestClsURL);
            req.setMethod('POST');
            req.setHeader('Authorization', 'OAuth ' + accsToken);
            req.setHeader('content-type', 'application/json');
            req.setBody(postData);
            Http http = new Http();
            if (!isApexTest) {
                HTTPResponse res = http.send(req);
                responseString = string.valueOf(res.getBody());
                system.debug('responseString===>' + responseString);
            } else {
                responseString = '{"SRtemplate":{"attributes":{"type":"HexaBPM__SR_Template__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Template__c/a0Nj00000010E8jEAE"},"HexaBPM__Sub_menu_section__c":"HR Requests","HexaBPM__Do_not_use_owner__c":false,"HexaBPM__Menu__c":"HR Requests","HexaBPM__Is_Letter_Process__c":false,"HexaBPM__Available_for_menu__c":true,"HexaBPM__Sub_menu__c":"General","HexaBPM__Menutext__c":"New Employee Onboarding","Name":"New Employee Onboarding","HexaBPM__Active__c":true,"HexaBPM__Template_Sequence_No__c":1,"HexaBPM__SR_RecordType_API_Name__c":"Employee_on_BoardingTest","HexaBPM__SR_Template_Code__c":"Employee_on_Boarding","Id":"a0Nj00000010E8jEAE","HexaBPM__Is_through_Flow__c":false,"HexaBPM__Priority__c":100,"HexaBPM__Portal_Service_Request_Name__c":"New Employee Onboarding"},"lstStepTransitions":[{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvKEAW"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQeEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Medical Completed","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00009","HexaBPM__SR_Step__c":"a0Kj0000001dEwCEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Medical Completed","Id":"a0Tj0000001TYvKEAW","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvAEAW"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQUEAY","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Application Submitted","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00007","HexaBPM__SR_Step__c":"a0Kj0000001dEwCEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Application Submitted","Id":"a0Tj0000001TYvAEAW","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvUEAW"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQoEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Completed","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00011","HexaBPM__SR_Step__c":"a0Kj0000001dEwvEAE","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Completed","Id":"a0Tj0000001TYvUEAW","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYqZEAW"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQPEAY","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Approved","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00005","HexaBPM__SR_Step__c":"a0Kj0000001dErCEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-APPROVED","Id":"a0Tj0000001TYqZEAW","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYqoEAG"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000001jJTOEA2","HexaBPM__Transition__c":"a0Vj00000021uQyEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"Rejected","HexaBPM__To__c":"Rejected","HexaBPM__SR_Status_External_Code__c":"Rejected","Name":"ST-00006","HexaBPM__SR_Step__c":"a0Kj0000001dErCEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000001jJTOEA2","HexaBPM__Transition_Code__c":"Pending-Rejected","Id":"a0Tj0000001TYqoEAG","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvoEAG"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQoEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Completed","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00014","HexaBPM__SR_Step__c":"a0Kj0000001dEz1EAE","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Completed","Id":"a0Tj0000001TYvoEAG","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYveEAG"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQoEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Completed","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00012","HexaBPM__SR_Step__c":"a0Kj0000001dExPEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Completed","Id":"a0Tj0000001TYveEAG","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvPEAW"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQjEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Stamping Completed","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00010","HexaBPM__SR_Step__c":"a0Kj0000001dEwCEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Stamping Completed","Id":"a0Tj0000001TYvPEAW","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvFEAW"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQZEAY","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Entry Permit Received","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00008","HexaBPM__SR_Step__c":"a0Kj0000001dEwCEAU","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Entry Permit Received","Id":"a0Tj0000001TYvFEAW","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYw3EAG"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000001jJYpEAM","HexaBPM__Transition__c":"a0Vj00000021uQoEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"Completed","HexaBPM__To__c":"Completed","HexaBPM__SR_Status_External_Code__c":"Completed","Name":"ST-00015","HexaBPM__SR_Step__c":"a0Kj0000001dEz6EAE","HexaBPM__SR_Status_Internal__c":"a0Jj0000001jJYpEAM","HexaBPM__Transition_Code__c":"Pending-Completed","Id":"a0Tj0000001TYw3EAG","HexaBPM__Evaluate_Refund__c":false},{"attributes":{"type":"HexaBPM__Step_Transition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Step_Transition__c/a0Tj0000001TYvjEAG"},"HexaBPM__Display_on_Portal__c":true,"HexaBPM__SR_Status_External__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition__c":"a0Vj00000021uQoEAI","HexaBPM__From__c":"Pending","HexaBPM__SR_Status_Internal_Code__c":"SUBMITTED","HexaBPM__To__c":"Completed","HexaBPM__SR_Status_External_Code__c":"SUBMITTED","Name":"ST-00013","HexaBPM__SR_Step__c":"a0Kj0000001dEycEAE","HexaBPM__SR_Status_Internal__c":"a0Jj0000000LVbGEAW","HexaBPM__Transition_Code__c":"Pending-Completed","Id":"a0Tj0000001TYvjEAG","HexaBPM__Evaluate_Refund__c":false}],"lstSRTemplDocs":[{"attributes":{"type":"HexaBPM__SR_Template_Docs__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Template_Docs__c/a0Lj0000001VnmAEAS"},"HexaBPM__Document_Master__c":"a06j0000003Hwo0AAC","HexaBPM__Requirement__c":"Copy Required","HexaBPM__Group_No__c":3,"HexaBPM__Validate_only__c":false,"HexaBPM__Document_Description__c":"Please upload the Passport Copy","HexaBPM__Optional__c":true,"HexaBPM__Added_through_Code__c":false,"Name":"SR-000006","HexaBPM__Document_Description_External__c":"Passport Copy","HexaBPM__Document_Master_Code__c":"Passport Copy","Id":"a0Lj0000001VnmAEAS","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Generate_Document__c":false,"HexaBPM__On_Submit__c":true,"HexaBPM__Original_Doc_Required__c":false},{"attributes":{"type":"HexaBPM__SR_Template_Docs__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Template_Docs__c/a0Lj0000001VnlWEAS"},"HexaBPM__Document_Master__c":"a06j0000003HwpKAAS","HexaBPM__Requirement__c":"Copy Required","HexaBPM__Group_No__c":2,"HexaBPM__Validate_only__c":false,"HexaBPM__Document_Description__c":"Please upload the Latest Passport size photo","HexaBPM__Optional__c":true,"HexaBPM__Added_through_Code__c":false,"Name":"SR-000005","HexaBPM__Document_Description_External__c":"Latest Passport size photo","HexaBPM__Document_Master_Code__c":"Latest Passport size photo","Id":"a0Lj0000001VnlWEAS","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Generate_Document__c":false,"HexaBPM__On_Submit__c":true,"HexaBPM__Original_Doc_Required__c":false}],"lstSRTemplateItems":[{"attributes":{"type":"HexaBPM__SR_Template_Item__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Template_Item__c/a0Mj0000001NoEeEAK"},"Name":"SR-Temp-009","Id":"a0Mj0000001NoEeEAK","HexaBPM__Product_Code__c":"12345","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Product__c":"01tj0000000gkyvAAA","HexaBPM__On_Submit__c":true}],"lstSRSteps":[{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dErCEAU"},"HexaBPM__Step_No__c":10.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"HR_Admin","HexaBPM__Sys_Default_Actions__c":false,"HexaBPM__Sys_Create_Condition__c":false,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-11","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Initial Approval","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Initial Approval","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":true,"HexaBPM__Step_Template__c":"a0Sj0000001VpYWEA0","Id":"a0Kj0000001dErCEAU","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false},{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dEwCEAU"},"HexaBPM__Step_No__c":20.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"PRO","HexaBPM__Sys_Default_Actions__c":false,"HexaBPM__Sys_Create_Condition__c":true,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-12","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Initiate Visa Process","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Initiate Visa Process","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":false,"HexaBPM__Step_Template__c":"a0Sj0000001VpYlEAK","Id":"a0Kj0000001dEwCEAU","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false},{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dEwvEAE"},"HexaBPM__Step_No__c":30.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"IT_Admin","HexaBPM__Sys_Default_Actions__c":false,"HexaBPM__Sys_Create_Condition__c":true,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-13","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Issue Laptop","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Issue Laptop","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":false,"HexaBPM__Step_Template__c":"a0Sj0000001VpYvEAK","Id":"a0Kj0000001dEwvEAE","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false},{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dExPEAU"},"HexaBPM__Step_No__c":40.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"IT_Admin","HexaBPM__Sys_Default_Actions__c":true,"HexaBPM__Sys_Create_Condition__c":false,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-14","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Create Email Account","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Create Email Account","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":true,"HexaBPM__Step_Template__c":"a0Sj0000001VpZ5EAK","Id":"a0Kj0000001dExPEAU","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false},{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dEycEAE"},"HexaBPM__Step_No__c":50.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"HR_Admin","HexaBPM__Sys_Default_Actions__c":false,"HexaBPM__Sys_Create_Condition__c":false,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-15","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Send Welcome Pack","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Send Welcome Pack","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":true,"HexaBPM__Step_Template__c":"a0Sj0000001VpZAEA0","Id":"a0Kj0000001dEycEAE","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false},{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dEz1EAE"},"HexaBPM__Step_No__c":60.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"IT_Admin","HexaBPM__Sys_Default_Actions__c":false,"HexaBPM__Sys_Create_Condition__c":false,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-16","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Assign Workstation","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Assign Workstation","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":true,"HexaBPM__Step_Template__c":"a0Sj0000001VpZFEA0","Id":"a0Kj0000001dEz1EAE","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false},{"attributes":{"type":"HexaBPM__SR_Steps__c","url":"/services/data/v29.0/sobjects/HexaBPM__SR_Steps__c/a0Kj0000001dEz6EAE"},"HexaBPM__Step_No__c":70.0,"HexaBPM__Do_not_use_owner__c":false,"HexaBPM__SR_Template_Name__c":"New Employee Onboarding","HexaBPM__Owner_Queue_Name__c":"HR_Admin","HexaBPM__Sys_Default_Actions__c":false,"HexaBPM__Sys_Create_Condition__c":false,"HexaBPM__Start_Status__c":"a0Rj0000001FjaCEAS","Name":"SRStep-17","HexaBPM__Active__c":true,"HexaBPM__Step_RecordType_API_Name__c":"General","HexaBPM__Summary__c":"Collect Bank Details","HexaBPM__Start_Status_Code__c":"Pending","HexaBPM__Step_Template_Code__c":"Collect Bank Details","HexaBPM__Sanction_SR_Step__c":false,"HexaBPM__Execute_on_Submit__c":true,"HexaBPM__Step_Template__c":"a0Sj0000001VpZKEA0","Id":"a0Kj0000001dEz6EAE","HexaBPM__SR_Template__c":"a0Nj00000010E8jEAE","HexaBPM__Sys_Custom_Conditions_Actions__c":false}],"lstSRDocConditions":[],"lstPricingRange":[],"lstPricingConditions":[],"lstDatedPricing":[],"lstBRConditions":[{"attributes":{"type":"HexaBPM__Condition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Condition__c/a03j0000004GnVjAAK"},"Name":"C-000031","HexaBPM__Value__c":"Approved","HexaBPM__S_No__c":1,"HexaBPM__Business_Rule__c":"a01j0000004LWB8AAO","HexaBPM__BRCondition__c":"1 AND 2","HexaBPM__Operator__c":"=","Id":"a03j0000004GnVjAAK","HexaBPM__Object_Name__c":"Step Status","HexaBPM__Field_Name__c":"10.0"},{"attributes":{"type":"HexaBPM__Condition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Condition__c/a03j0000004GnVkAAK"},"Name":"C-000032","HexaBPM__Value__c":"001001","HexaBPM__S_No__c":2,"HexaBPM__Conditional_Operator__c":"AND","HexaBPM__Business_Rule__c":"a01j0000004LWB8AAO","HexaBPM__BRCondition__c":"1 AND 2","HexaBPM__Field_Type__c":"STRING","HexaBPM__Operator__c":"=","Id":"a03j0000004GnVkAAK","HexaBPM__Object_Name__c":"Account","HexaBPM__Field_Name__c":"AccountNumber"},{"attributes":{"type":"HexaBPM__Condition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Condition__c/a03j0000004GnVoAAK"},"Name":"C-000033","HexaBPM__Value__c":"Entry Permit Received","HexaBPM__S_No__c":1,"HexaBPM__Business_Rule__c":"a01j0000004LWCZAA4","HexaBPM__BRCondition__c":"1 AND 2","HexaBPM__Operator__c":"=","Id":"a03j0000004GnVoAAK","HexaBPM__Object_Name__c":"Step Status","HexaBPM__Field_Name__c":"20.0"},{"attributes":{"type":"HexaBPM__Condition__c","url":"/services/data/v29.0/sobjects/HexaBPM__Condition__c/a03j0000004GnVpAAK"},"Name":"C-000034","HexaBPM__Value__c":"Prasad","HexaBPM__S_No__c":2,"HexaBPM__Conditional_Operator__c":"AND","HexaBPM__Business_Rule__c":"a01j0000004LWCZAA4","HexaBPM__BRCondition__c":"1 AND 2","HexaBPM__Field_Type__c":"STRING","HexaBPM__Operator__c":"=","Id":"a03j0000004GnVpAAK","HexaBPM__Object_Name__c":"Contact","HexaBPM__Field_Name__c":"LastName"}],"lstBRActions":[{"attributes":{"type":"HexaBPM__Action__c","url":"/services/data/v29.0/sobjects/HexaBPM__Action__c/a0Wj0000002BRq2EAG"},"Name":"A-000020","HexaBPM__Action_Type__c":"Custom Code","HexaBPM__Business_Rule__c":"a01j0000004NTInAAO","HexaBPM__Value_or_Field__c":"Value","HexaBPM__Custom_Method__c":"EvaluateCustomCode","HexaBPM__SR_Template_Code__c":"Employee_on_Boarding","Id":"a0Wj0000002BRq2EAG","HexaBPM__Field_Name__c":"EvaluateCustomCode","HexaBPM__Class_Name__c":"CC_UpdateSREmail","HexaBPM__BR_Action_Type__c":"Default Actions"}],"lstBR":[{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004LWB8AAO"},"Name":"New Employee Onboarding-SRStep-12-Create Conditions","HexaBPM__Business_Rule_Condition__c":"1 AND 2","HexaBPM__Action_Type__c":"Create Conditions","HexaBPM__Text_Condition__c":"Step Status->10.0#=#Approved#AND#Account->AccountNumber#=#001001","HexaBPM__SR_Steps__c":"a0Kj0000001dEwCEAU","HexaBPM__Description__c":"Create on Approval of Initial Approval","Id":"a01j0000004LWB8AAO","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false},{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004LWCZAA4"},"Name":"New Employee Onboarding-SRStep-13-Create Conditions","HexaBPM__Business_Rule_Condition__c":"1 AND 2","HexaBPM__Action_Type__c":"Create Conditions","HexaBPM__Text_Condition__c":"Step Status->20.0#=#Entry Permit Received#AND#Contact->LastName#=#Prasad","HexaBPM__SR_Steps__c":"a0Kj0000001dEwvEAE","HexaBPM__Description__c":"Create on Application Submitted of step Initiate Visa Process","Id":"a01j0000004LWCZAA4","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false},{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004LWD8AAO"},"Name":"New Employee Onboarding-SRStep-14-Create Conditions","HexaBPM__Action_Type__c":"Create Conditions","HexaBPM__SR_Steps__c":"a0Kj0000001dExPEAU","HexaBPM__Description__c":"Create on Issue Laptop step","Id":"a01j0000004LWD8AAO","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false},{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004NTInAAO"},"Name":"New Employee Onboarding-SRStep-14-Default Actions","HexaBPM__Action_Type__c":"Default Actions","HexaBPM__SR_Steps__c":"a0Kj0000001dExPEAU","Id":"a01j0000004NTInAAO","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false},{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004LWDIAA4"},"Name":"New Employee Onboarding-SRStep-15-Create Conditions","HexaBPM__Action_Type__c":"Create Conditions","HexaBPM__SR_Steps__c":"a0Kj0000001dEycEAE","Id":"a01j0000004LWDIAA4","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false},{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004LWG0AAO"},"Name":"New Employee Onboarding-SRStep-16-Create Conditions","HexaBPM__Action_Type__c":"Create Conditions","HexaBPM__SR_Steps__c":"a0Kj0000001dEz1EAE","Id":"a01j0000004LWG0AAO","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false},{"attributes":{"type":"HexaBPM__Business_Rule__c","url":"/services/data/v29.0/sobjects/HexaBPM__Business_Rule__c/a01j0000004LWI9AAO"},"Name":"New Employee Onboarding-SRStep-17-Create Conditions","HexaBPM__Action_Type__c":"Create Conditions","HexaBPM__SR_Steps__c":"a0Kj0000001dEz6EAE","Id":"a01j0000004LWI9AAO","HexaBPM__Execute_on_Update__c":false,"HexaBPM__SR_Template__c":"Employee_on_Boarding","HexaBPM__Execute_on_Insert__c":false}]}';
            }
            objProcess = new SRProcessWrap();
            if (responseString != null && responseString != '') {
                objProcess = (SRProcessWrap)JSON.deserialize(responseString, SRProcessWrap.class);
            }
            if (objProcess != null && objProcess.SRtemplate != null && objProcess.SRtemplate.Id != null) {
                showPnl = true;
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'SR Template not found in ' + objCS.Name + ' environment with "' + strTemplateName + '" Record type API Name'));
            }
        }
    }
    public string strNewSRTemplId {get; set;}
    /*
        Method Name : ConfirmSave
        Description : This Method will saves the entire process into this Org.
    */
    public pagereference ConfirmSave() {
        strNewSRTemplId = '';
        boolean subSRNotFound = false;
        map<string, string> mapSubSrIds = new map<string, string>();
        string SUB_SR_DEV_Id = '';
        if (objProcess != null && objProcess.lstBRActions != null && objProcess.lstBRActions.Size() > 0) {
            set<string> setSubSRIds = new set<string>();
            for (HexaBPM__Action__c act : objProcess.lstBRActions) {
                if (act.HexaBPM__Action_Type__c == 'Initiate SubSR' || act.HexaBPM__Action_Type__c == 'Linked SR') {
                    if (act.HexaBPM__Field_Value__c != '') {
                        setSubSRIds.add(act.HexaBPM__Field_Value__c);
                        if (SUB_SR_DEV_Id == '') {
                            SUB_SR_DEV_Id = act.HexaBPM__Field_Value__c;
                        } else {
                            SUB_SR_DEV_Id = SUB_SR_DEV_Id + ',' + act.HexaBPM__Field_Value__c;
                        }
                    }
                }
            }
            if (setSubSRIds != null && setSubSRIds.size() > 0) {
                list<HexaBPM__SR_Template__c> lstSubSRtempl = new list<HexaBPM__SR_Template__c>();
                if(FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Sys_Previous_Id__c,HexaBPM__Active__c', 'HexaBPM__SR_Template__c')) {
                    lstSubSRtempl = [select id, HexaBPM__Sys_Previous_Id__c from HexaBPM__SR_Template__c where HexaBPM__Sys_Previous_Id__c IN:setSubSRIds and HexaBPM__Active__c = true and IsDeleted = false];
                    if (lstSubSRtempl != null && lstSubSRtempl.size() > 0 && setSubSRIds.size() == lstSubSRtempl.size()) {
                        for (HexaBPM__SR_Template__c SrTempl : lstSubSRtempl) {
                            mapSubSrIds.put(SrTempl.HexaBPM__Sys_Previous_Id__c, string.valueOf(SrTempl.Id));
                        }
                        subSRNotFound = false;
                    } else {
                        subSRNotFound = true;
                    }
                } else {
                    subSRNotFound = false;
                }
            }
        }
        if (subSRNotFound == false) {
            /* Start of Preparing the Save Point */
            Savepoint Stat_svpoint = Database.setSavepoint();
            /* End of Preparing the Save Point */
            try {
                if (objProcess.SRtemplate != null) {
                    map<string, string> mapStepTemplateId = new map<string, string>();
                    map<string, string> mapTemplDocsIds = new map<string, string>();
                    map<string, string> mapTemplItemsIds = new map<string, string>();
                    map<string, string> mapSRStepIds = new map<string, string>();
                    map<string, string> mapProductIds = new map<string, string>();
                    map<string, string> mapBRIds = new map<string, string>();
                    map<string, string> mapStepTransitionsIds = new map<string, string>();
                    map<string, string> MapStepStatusIds = new map<string, string>();
                    map<string, string> MapSRStatusIds = new map<string, string>();
                    map<string, string> MapTransitionIds = new map<string, string>();
                    map<string, string> mapDocMasterIds = new map<string, string>();
                    HexaBPM__SR_Template__c objSRtempl = new HexaBPM__SR_Template__c();
                    objSRtempl = objProcess.SRtemplate;
                    if (objProcess.SRtemplate.HexaBPM__Refund_Item__c != null) {
                        if(FLSCheckUtil.queryStr1AfterFLS('id,ProductCode','Product2')){
                        list<Product2> lstRefundItem = [select id, ProductCode from Product2 where ProductCode = :objProcess.SRtemplate.HexaBPM__Refund_Item_Code__c and IsDeleted = false];
                        if (Schema.sObjectType.HexaBPM__SR_Template__c.fields.HexaBPM__Refund_Item__c.isCreateable()) {
                            if (lstRefundItem != null && lstRefundItem.size() > 0 && Schema.sObjectType.HexaBPM__SR_Template__c.fields.HexaBPM__Refund_Item__c.isCreateable()) {
                                objSRtempl.HexaBPM__Refund_Item__c = lstRefundItem[0].Id;
                            } else {
                                throw new HexaBPM.CommonCustomException('Refund Item not found for this SR-Template.');
                            }
                        }
                    }
                    }
                    if (Schema.sObjectType.HexaBPM__SR_Template__c.fields.HexaBPM__Sys_Previous_Id__c.isCreateable())
                        objSRtempl.HexaBPM__Sys_Previous_Id__c = string.valueOf(objProcess.SRtemplate.Id);
                    //if(Schema.sObjectType.HexaBPM__SR_Template__c.fields.Id.isCreateable())
                    objSRtempl.Id = null;
                    if (HexaBPM__SR_Template__c.SObjectType.getDescribe().isCreateable())
                        insert objSRtempl;
                    pagereference pg = new pagereference('/' + objSRtempl.Id);
                    pg.setRedirect(true);
                    /* Code to Insert SR-Steps */
                    if (objSRtempl != null && objSRtempl.Id != null && objProcess.lstSRSteps != null && objProcess.lstSRSteps.size() > 0) {
                        list<HexaBPM__SR_Steps__c> lstSRSteps = new list<HexaBPM__SR_Steps__c>();
                        set<string> setStatusId = new set<string>();
                        set<string> setStepTemplateId = new set<string>();
                        for (HexaBPM__SR_Steps__c srStep : objProcess.lstSRSteps) {
                            if (srStep.HexaBPM__Start_Status_Code__c != null) {
                                setStatusId.add(srStep.HexaBPM__Start_Status_Code__c);
                            }
                            if (srStep.HexaBPM__Step_Template_Code__c != null) {
                                setStepTemplateId.add(srStep.HexaBPM__Step_Template_Code__c);
                            }
                        }
                        if (setStepTemplateId != null && setStepTemplateId.size() > 0) {
                            if (FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Code__c', 'HexaBPM__Step_Template__c')) {
                                for (HexaBPM__Step_Template__c StpTempl : [select id, HexaBPM__Code__c from HexaBPM__Step_Template__c where HexaBPM__Code__c IN:setStepTemplateId and IsDeleted = false]) {
                                    mapStepTemplateId.put(StpTempl.HexaBPM__Code__c, StpTempl.Id);
                                }
                            }
                        }
                        if (setStatusId != null && setStatusId.size() > 0) {
                            if (FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Code__c', 'HexaBPM__Status__c')) {
                                for (HexaBPM__Status__c status : [select id, HexaBPM__Code__c from HexaBPM__Status__c where HexaBPM__Code__c IN:setStatusId and IsDeleted = false]) {
                                    MapStepStatusIds.put(status.HexaBPM__Code__c, status.Id);
                                }
                            }
                        }
                        for (HexaBPM__SR_Steps__c srStep : objProcess.lstSRSteps) {
                            HexaBPM__SR_Steps__c objStep = new HexaBPM__SR_Steps__c();
                            if (Schema.sObjectType.HexaBPM__SR_Steps__c.fields.HexaBPM__Start_Status__c.isCreateable())
                                srStep.HexaBPM__Start_Status__c = null;
                            if (Schema.sObjectType.HexaBPM__SR_Steps__c.fields.HexaBPM__Start_Status__c.isCreateable()) {
                                if (srStep.HexaBPM__Start_Status_Code__c != null) {
                                    if (MapStepStatusIds.get(srStep.HexaBPM__Start_Status_Code__c) != null) {
                                        srStep.HexaBPM__Start_Status__c = MapStepStatusIds.get(srStep.HexaBPM__Start_Status_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Step Status not found for the SR Step. i.e.' + srStep.HexaBPM__Start_Status_Code__c);
                                    }
                                }
                            }
                            objStep = srStep;
                            if (Schema.sObjectType.HexaBPM__SR_Steps__c.fields.OwnerId.isCreateable()) {
                                if (srStep.HexaBPM__Owner_Queue_Name__c != null && srStep.HexaBPM__Owner_Queue_Name__c != '') {
                                    if (map_QueueName_Id.get(srStep.HexaBPM__Owner_Queue_Name__c) != null) {
                                        objStep.OwnerId = map_QueueName_Id.get(srStep.HexaBPM__Owner_Queue_Name__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Queue is missing which is being configured for SR-Step(s). i.e.' + srStep.HexaBPM__Owner_Queue_Name__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Steps__c.fields.HexaBPM__Sys_SR_Step_Name__c.isCreateable())
                                objStep.HexaBPM__Sys_SR_Step_Name__c = srStep.Id;
                            if (Schema.sObjectType.HexaBPM__SR_Steps__c.fields.HexaBPM__SR_Template__c.isCreateable())
                                objStep.HexaBPM__SR_Template__c = objSRtempl.Id;
                            if (Schema.sObjectType.HexaBPM__SR_Steps__c.fields.HexaBPM__Step_Template__c.isCreateable()) {
                                if (srStep.HexaBPM__Step_Template_Code__c != null) {
                                    if (mapStepTemplateId.get(srStep.HexaBPM__Step_Template_Code__c) != null) {
                                        objStep.HexaBPM__Step_Template__c = mapStepTemplateId.get(srStep.HexaBPM__Step_Template_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Step-Template not found for the SR Step. i.e.<b>' + srStep.HexaBPM__Step_Template_Code__c + '</b>');
                                    }
                                }
                            }
                            //if(Schema.sObjectType.HexaBPM__SR_Steps__c.fields.Id.isCreateable())
                            objStep.Id = null;
                            lstSRSteps.add(objStep);
                        }
                        if (HexaBPM__SR_Steps__c.SObjectType.getDescribe().isCreateable())
                            insert lstSRSteps;
                        for (HexaBPM__SR_Steps__c srStep : lstSRSteps) {
                            if (srStep.HexaBPM__Sys_SR_Step_Name__c != null)
                                mapSRStepIds.put(srStep.HexaBPM__Sys_SR_Step_Name__c, srStep.Id);
                        }
                    }

                    list<HexaBPM__SR_Template_Item__c> lstNewSRtemplItems = new list<HexaBPM__SR_Template_Item__c>();
                    set<string> setDevProdIds = new set<string>();
                    list<HexaBPM__SR_Template_Item__c> lstTemplItems = new list<HexaBPM__SR_Template_Item__c>();

                    /* Code to Insert SR-Template Items */
                    if (objProcess.lstSRTemplateItems != null && objProcess.lstSRTemplateItems.size() > 0) {
                        for (HexaBPM__SR_Template_Item__c srTemplItem : objProcess.lstSRTemplateItems) {
                            setDevProdIds.add(srTemplItem.HexaBPM__Product_Code__c);
                        }
                        if (setDevProdIds != null && setDevProdIds.size() > 0) {
                            if (FLSCheckUtil.queryStr1AfterFLS('id,ProductCode', 'Product2')) {
                                for (Product2 prod : [select id, ProductCode from Product2 where ProductCode IN:setDevProdIds and IsDeleted = false]) {
                                    mapProductIds.put(prod.ProductCode, prod.Id);
                                }
                            }
                        }
                        for (HexaBPM__SR_Template_Item__c srTemplItem : objProcess.lstSRTemplateItems) {
                            HexaBPM__SR_Template_Item__c objTemplItem = new HexaBPM__SR_Template_Item__c();
                            objTemplItem = srTemplItem;
                            if (Schema.sObjectType.HexaBPM__SR_Template_Item__c.fields.HexaBPM__Sys_Template_Name__c.isCreateable())
                                objTemplItem.HexaBPM__Sys_Template_Name__c = srTemplItem.Id;
                            if (Schema.sObjectType.HexaBPM__SR_Template_Item__c.fields.HexaBPM__SR_Template__c.isCreateable())
                                objTemplItem.HexaBPM__SR_Template__c = objSRtempl.Id;
                            if (Schema.sObjectType.HexaBPM__SR_Template_Item__c.fields.HexaBPM__Consumed_at__c.isCreateable()) {
                                if (srTemplItem.HexaBPM__Consumed_at__c != null) {
                                    if (mapSRStepIds.get(srTemplItem.HexaBPM__Consumed_at__c) != null) {
                                        objTemplItem.HexaBPM__Consumed_at__c = mapSRStepIds.get(srTemplItem.HexaBPM__Consumed_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('SR Step which is mentioned as "Consumed at" for the Template Item was not found i.e. ' + srTemplItem.HexaBPM__Consumed_at__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Item__c.fields.HexaBPM__Evaluated_at__c.isCreateable()) {
                                if (srTemplItem.HexaBPM__Evaluated_at__c != null) {
                                    if (mapSRStepIds.get(srTemplItem.HexaBPM__Evaluated_at__c) != null) {
                                        objTemplItem.HexaBPM__Evaluated_at__c = mapSRStepIds.get(srTemplItem.HexaBPM__Evaluated_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('SR Step which is mentioned as "Evaluated at" for the Template Item was not found i.e. ' + srTemplItem.HexaBPM__Evaluated_at__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Item__c.fields.HexaBPM__Product__c.isCreateable()) {
                                if (srTemplItem.HexaBPM__Product_Code__c != null && mapProductIds.get(srTemplItem.HexaBPM__Product_Code__c) != null) {
                                    objTemplItem.HexaBPM__Product__c = mapProductIds.get(srTemplItem.HexaBPM__Product_Code__c);
                                } else {
                                    throw new HexaBPM.CommonCustomException('Product linked to the TemplateItem is not exists i.e. ' + srTemplItem.HexaBPM__Product_Code__c);
                                }
                            }
                            objTemplItem.Id = null;
                            lstTemplItems.add(objTemplItem);
                        }
                        if (lstTemplItems != null && lstTemplItems.size() > 0 && HexaBPM__SR_Template_Item__c.SObjectType.getDescribe().isCreateable()) {
                            insert lstTemplItems;
                            for (HexaBPM__SR_Template_Item__c objTemplItem : lstTemplItems) {
                                if (objTemplItem.HexaBPM__Sys_Template_Name__c != null)
                                    mapTemplItemsIds.put(objTemplItem.HexaBPM__Sys_Template_Name__c, objTemplItem.Id);
                            }
                        }
                    }
                    list<HexaBPM__SR_Template_Docs__c> lstSRTemplDocs = new list<HexaBPM__SR_Template_Docs__c>();
                    set<string> setDevDocMstrIds = new set<string>();
                    /* Code to Insert SR-Template Docs */
                    if (objProcess.lstSRTemplDocs != null && objProcess.lstSRTemplDocs.size() > 0) {
                        for (HexaBPM__SR_Template_Docs__c TemplDocs : objProcess.lstSRTemplDocs) {
                            if (TemplDocs.HexaBPM__Document_Master_Code__c != null) {
                                setDevDocMstrIds.add(TemplDocs.HexaBPM__Document_Master_Code__c);
                            }
                        }
                        // prepare document master availability validation map
                        if (setDevDocMstrIds != null && setDevDocMstrIds.size() > 0) {
                            if (FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Code__c', 'HexaBPM__Document_Master__c')) {
                                for (HexaBPM__Document_Master__c docMstr : [select id, HexaBPM__Code__c from HexaBPM__Document_Master__c where HexaBPM__Code__c IN:setDevDocMstrIds and IsDeleted = false]) {
                                    mapDocMasterIds.put(docMstr.HexaBPM__Code__c, docMstr.Id);
                                }
                            }
                        }
                        for (HexaBPM__SR_Template_Docs__c TemplDocs : objProcess.lstSRTemplDocs) {
                            HexaBPM__SR_Template_Docs__c objNewTemplDoc = new HexaBPM__SR_Template_Docs__c();
                            objNewTemplDoc = TemplDocs;
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Sys_Template_Doc_Name__c.isCreateable())
                                objNewTemplDoc.HexaBPM__Sys_Template_Doc_Name__c = TemplDocs.Id;
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__SR_Template__c.isCreateable())
                                objNewTemplDoc.HexaBPM__SR_Template__c = objSRtempl.Id;
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Document_Master__c.isCreateable()) {
                                if (TemplDocs.HexaBPM__Document_Master_Code__c != null) {
                                    if (mapDocMasterIds.get(TemplDocs.HexaBPM__Document_Master_Code__c) != null) {
                                        objNewTemplDoc.HexaBPM__Document_Master__c = mapDocMasterIds.get(TemplDocs.HexaBPM__Document_Master_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Document Master not found for the SR-Template Doc, i.e.' + TemplDocs.HexaBPM__Document_Master_Code__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Courier_collected_at__c.isCreateable()) {
                                if (TemplDocs.HexaBPM__Courier_collected_at__c != null) {
                                    if (mapSRStepIds.get(TemplDocs.HexaBPM__Courier_collected_at__c) != null) {
                                        objNewTemplDoc.HexaBPM__Courier_collected_at__c = mapSRStepIds.get(TemplDocs.HexaBPM__Courier_collected_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Courier Collected Step was not found for the SR-Template Doc i.e.' + TemplDocs.HexaBPM__Courier_collected_at__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Courier_collected_at__c.isCreateable()) {
                                if (TemplDocs.HexaBPM__Courier_delivered_at__c != null) {
                                    if (mapSRStepIds.get(TemplDocs.HexaBPM__Courier_delivered_at__c) != null) {
                                        objNewTemplDoc.HexaBPM__Courier_delivered_at__c = mapSRStepIds.get(TemplDocs.HexaBPM__Courier_delivered_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Courier Devilered Step was not found for the SR-Template Doc i.e. ' + TemplDocs.HexaBPM__Courier_delivered_at__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Courier_collected_at__c.isCreateable()) {
                                if (TemplDocs.HexaBPM__Evaluated_at__c != null) {
                                    if (mapSRStepIds.get(TemplDocs.HexaBPM__Evaluated_at__c) != null) {
                                        objNewTemplDoc.HexaBPM__Evaluated_at__c = mapSRStepIds.get(TemplDocs.HexaBPM__Evaluated_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Evaluated at Step was not found for the SR-Template Doc i.e. ' + TemplDocs.HexaBPM__Evaluated_at__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Courier_collected_at__c.isCreateable()) {
                                if (TemplDocs.HexaBPM__Validated_at__c != null) {
                                    if (mapSRStepIds.get(TemplDocs.HexaBPM__Validated_at__c) != null) {
                                        objNewTemplDoc.HexaBPM__Validated_at__c = mapSRStepIds.get(TemplDocs.HexaBPM__Validated_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Validated at Step was not found for the SR-Template Doc i.e. ' + TemplDocs.HexaBPM__Validated_at__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__SR_Template_Docs__c.fields.HexaBPM__Courier_collected_at__c.isCreateable()) {
                                if (TemplDocs.HexaBPM__Original_Sighted_at__c != null) {
                                    if (mapSRStepIds.get(TemplDocs.HexaBPM__Original_Sighted_at__c) != null) {
                                        objNewTemplDoc.HexaBPM__Original_Sighted_at__c = mapSRStepIds.get(TemplDocs.HexaBPM__Original_Sighted_at__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Original Sighted was not found for the SR-Template Doc i.e.' + TemplDocs.HexaBPM__Original_Sighted_at__c);
                                    }
                                }
                            }
                            objNewTemplDoc.Id = null;
                            lstSRTemplDocs.add(objNewTemplDoc);
                        }

                        list<HexaBPM__Condition__c> lstDocCond = new list<HexaBPM__Condition__c>();
                        //if all the above validaitons passed then we are inserting the template docs
                        if (lstSRTemplDocs != null && lstSRTemplDocs.size() > 0 && HexaBPM__SR_Template_Docs__c.SObjectType.getDescribe().isCreateable()) {
                            insert lstSRTemplDocs;
                            for (HexaBPM__SR_Template_Docs__c tmplDoc : lstSRTemplDocs) {
                                mapTemplDocsIds.put(tmplDoc.HexaBPM__Sys_Template_Doc_Name__c, tmplDoc.Id);
                            }
                            // conditions related to the doc
                            if (mapTemplDocsIds != null && mapTemplDocsIds.size() > 0 && objProcess.lstSRDocConditions != null && objProcess.lstSRDocConditions.size() > 0) {
                                for (HexaBPM__Condition__c DocCon : objProcess.lstSRDocConditions) {
                                    HexaBPM__Condition__c objNewDocCon = new HexaBPM__Condition__c();
                                    objNewDocCon = DocCon;
                                    if (Schema.sObjectType.HexaBPM__Condition__c.fields.HexaBPM__SR_Template_Docs__c.isCreateable()) {
                                        if (DocCon.HexaBPM__SR_Template_Docs__c != null) {
                                            if (mapTemplDocsIds.get(DocCon.HexaBPM__SR_Template_Docs__c) != null) {
                                                objNewDocCon.HexaBPM__SR_Template_Docs__c = mapTemplDocsIds.get(DocCon.HexaBPM__SR_Template_Docs__c);
                                            } else {
                                                throw new HexaBPM.CommonCustomException('One of the SR Template-Doc not found for the Document Condition i.e.' + DocCon.HexaBPM__SR_Template_Docs__c);
                                            }
                                        }
                                    }
                                    // template docs does not have business rules
                                    if (Schema.sObjectType.HexaBPM__Condition__c.fields.HexaBPM__Business_Rule__c.isCreateable())
                                        objNewDocCon.HexaBPM__Business_Rule__c = null;
                                    if (Schema.sObjectType.HexaBPM__Condition__c.fields.HexaBPM__Pricing_Line__c.isCreateable())
                                        objNewDocCon.HexaBPM__Pricing_Line__c = null;
                                    //if(Schema.sObjectType.HexaBPM__Condition__c.fields.Id.isCreateable())
                                    objNewDocCon.Id = null;
                                    lstDocCond.add(objNewDocCon);
                                }
                                if (lstDocCond != null && lstDocCond.size() > 0 && HexaBPM__Condition__c.SObjectType.getDescribe().isCreateable())
                                    insert lstDocCond;
                            }
                        }
                    }

                    list<HexaBPM__Step_Transition__c> LstStepTransitions = new list<HexaBPM__Step_Transition__c>();
                    set<string> setStepStatusIds = new set<string>();
                    set<string> setSRStatusIds = new set<string>();
                    set<string> setTransitionIds = new set<string>();

                    /* Code to Insert Step Transitions */
                    if (mapSRStepIds != null && mapSRStepIds.size() > 0 && objProcess.lstStepTransitions != null && objProcess.lstStepTransitions.size() > 0) {
                        for (HexaBPM__Step_Transition__c stpTrans : objProcess.lstStepTransitions) {
                            if (stpTrans.HexaBPM__Transition_Code__c != null) {
                                setTransitionIds.add(stpTrans.HexaBPM__Transition_Code__c);
                            }
                            if (stpTrans.HexaBPM__Parent_Step_Status_Code__c != null) {
                                setStepStatusIds.add(stpTrans.HexaBPM__Parent_Step_Status_Code__c);
                            }
                            if (stpTrans.HexaBPM__Parent_SR_Status_Code__c != null) {
                                setSRStatusIds.add(stpTrans.HexaBPM__Parent_SR_Status_Code__c);
                            }
                            if (stpTrans.HexaBPM__SR_Status_External_Code__c != null) {
                                setSRStatusIds.add(stpTrans.HexaBPM__SR_Status_External_Code__c);
                            }
                            if (stpTrans.HexaBPM__SR_Status_Internal_Code__c != null) {
                                setSRStatusIds.add(stpTrans.HexaBPM__SR_Status_Internal_Code__c);
                            }
                        }
                        // verify the transitions already migrated thro informatica job
                        if (setTransitionIds != null && setTransitionIds.size() > 0) {
                            if (FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Code__c', 'HexaBPM__Transition__c')) {
                                for (HexaBPM__Transition__c Trans : [select id, HexaBPM__Code__c from HexaBPM__Transition__c where HexaBPM__Code__c IN:setTransitionIds and IsDeleted = false]) {
                                    MapTransitionIds.put(Trans.HexaBPM__Code__c, Trans.Id);
                                }
                            }
                        }
                        if (setStepStatusIds != null && setStepStatusIds.size() > 0) {
                            if (FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Code__c', 'HexaBPM__Status__c')) {
                                for (HexaBPM__Status__c StpStat : [select id, HexaBPM__Code__c from HexaBPM__Status__c where HexaBPM__Code__c IN:setStepStatusIds and IsDeleted = false]) {
                                    MapStepStatusIds.put(StpStat.HexaBPM__Code__c, StpStat.Id);
                                }
                            }
                        }
                        if (setSRStatusIds != null && setSRStatusIds.size() > 0) {
                            If(FLSCheckUtil.queryStr1AfterFLS('id,HexaBPM__Code__c', 'HexaBPM__SR_Status__c')) {
                                for (HexaBPM__SR_Status__c SRStat : [select id, HexaBPM__Code__c from HexaBPM__SR_Status__c where HexaBPM__Code__c IN:setSRStatusIds and IsDeleted = false]) {
                                    MapSRStatusIds.put(SRStat.HexaBPM__Code__c, SRStat.Id);
                                }
                            }
                        }
                        for (HexaBPM__Step_Transition__c stpTrans : objProcess.lstStepTransitions) {
                            HexaBPM__Step_Transition__c objStpTrans = new HexaBPM__Step_Transition__c();
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__SR_Template__c.isCreateable())
                                objStpTrans.HexaBPM__SR_Template__c = objSRtempl.Id;
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__SR_Step__c.isCreateable()) {
                                if (stpTrans.HexaBPM__SR_Step__c != null) {
                                    if (mapSRStepIds.get(stpTrans.HexaBPM__SR_Step__c) != null) {
                                        // pass the dev id and return current org sr step id
                                        objStpTrans.HexaBPM__SR_Step__c = mapSRStepIds.get(stpTrans.HexaBPM__SR_Step__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('SR Step not found for the Step Transition.');
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__Transition__c.isCreateable()) {
                                if (stpTrans.HexaBPM__Transition_Code__c != null) {
                                    if (MapTransitionIds.get(stpTrans.HexaBPM__Transition_Code__c) != null) {
                                        objStpTrans.HexaBPM__Transition__c = MapTransitionIds.get(stpTrans.HexaBPM__Transition_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Transition not found for the SR-Step i.e. ' + stpTrans.HexaBPM__Transition_Code__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__Parent_Step_Status__c.isCreateable()) {
                                if (stpTrans.HexaBPM__Parent_Step_Status_Code__c != null) {
                                    if (MapStepStatusIds.get(stpTrans.HexaBPM__Parent_Step_Status_Code__c) != null) {
                                        objStpTrans.HexaBPM__Parent_Step_Status__c = MapStepStatusIds.get(stpTrans.HexaBPM__Parent_Step_Status_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Parent Step Status not found for the SR-Step Transition.' + stpTrans.HexaBPM__Parent_Step_Status_Code__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__Parent_SR_Status__c.isCreateable()) {
                                if (stpTrans.HexaBPM__Parent_SR_Status_Code__c != null) {
                                    if (MapSRStatusIds.get(stpTrans.HexaBPM__Parent_SR_Status_Code__c) != null) {
                                        objStpTrans.HexaBPM__Parent_SR_Status__c = MapSRStatusIds.get(stpTrans.HexaBPM__Parent_SR_Status_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Parent SR Status not found for the SR-Step Transition.' + stpTrans.HexaBPM__Parent_SR_Status_Code__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__SR_Status_External__c.isCreateable()) {
                                if (stpTrans.HexaBPM__SR_Status_External_Code__c != null) {
                                    if (MapSRStatusIds.get(stpTrans.HexaBPM__SR_Status_External_Code__c) != null) {
                                        objStpTrans.HexaBPM__SR_Status_External__c = MapSRStatusIds.get(stpTrans.HexaBPM__SR_Status_External_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('External SR Status not found for the SR-Step Transition.' + stpTrans.HexaBPM__SR_Status_External_Code__c);
                                    }
                                }
                            }
                            if (Schema.sObjectType.HexaBPM__Step_Transition__c.fields.HexaBPM__SR_Status_Internal__c.isCreateable()) {
                                if (stpTrans.HexaBPM__SR_Status_Internal_Code__c != null) {
                                    if (MapSRStatusIds.get(stpTrans.HexaBPM__SR_Status_Internal_Code__c) != null) {
                                        objStpTrans.HexaBPM__SR_Status_Internal__c = MapSRStatusIds.get(stpTrans.HexaBPM__SR_Status_Internal_Code__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('Internal SR Status not found for the SR-Step Transition.' + stpTrans.HexaBPM__SR_Status_Internal_Code__c);
                                    }
                                }
                            }
                            //if(Schema.sObjectType.HexaBPM__Step_Transition__c.fields.Id.isCreateable())
                            objStpTrans.Id = null;
                            LstStepTransitions.add(objStpTrans);
                        }
                        if (LstStepTransitions != null && LstStepTransitions.size() > 0 && HexaBPM__Step_Transition__c.SObjectType.getDescribe().isCreateable())
                            insert LstStepTransitions;
                    }
                    /* Code to Insert Business Rules and Its Condition,Actions */
                    if (objProcess.lstBR != null && objProcess.lstBR.size() > 0) {
                        list<HexaBPM__Business_Rule__c> lstBR = new list<HexaBPM__Business_Rule__c>();
                        for (HexaBPM__Business_Rule__c BR : objProcess.lstBR) {
                            HexaBPM__Business_Rule__c objNewBr = new HexaBPM__Business_Rule__c();
                            objNewBr = BR;
                            if (Schema.sObjectType.HexaBPM__Business_Rule__c.fields.HexaBPM__Sys_BR_Name__c.isCreateable())
                                objNewBr.HexaBPM__Sys_BR_Name__c = BR.Id;
                            if (Schema.sObjectType.HexaBPM__Business_Rule__c.fields.HexaBPM__SR_Steps__c.isCreateable()) {
                                if (objNewBr.HexaBPM__SR_Steps__c != null) {
                                    if (mapSRStepIds.get(BR.HexaBPM__SR_Steps__c) != null) {
                                        objNewBr.HexaBPM__SR_Steps__c = mapSRStepIds.get(BR.HexaBPM__SR_Steps__c);
                                    } else {
                                        throw new HexaBPM.CommonCustomException('SR Step not found for the Business Rule.');
                                    }
                                }
                            }
                            //if(Schema.sObjectType.HexaBPM__Business_Rule__c.fields.Id.isCreateable())
                            objNewBr.Id = null;
                            lstBR.add(objNewBr);
                        }
                        if (lstBR != null && lstBR.size() > 0 && HexaBPM__Business_Rule__c.SObjectType.getDescribe().isCreateable()) {
                            insert lstBR;
                            for (HexaBPM__Business_Rule__c objBR : lstBR) {
                                if (objBR.HexaBPM__Sys_BR_Name__c != null)
                                    mapBRIds.put(objBR.HexaBPM__Sys_BR_Name__c, objBR.Id);
                            }
                        }
                        if (mapBRIds != null && mapBRIds.size() > 0 && objProcess.lstBRConditions != null && objProcess.lstBRConditions.size() > 0) {
                            list<HexaBPM__Condition__c> lstBrCond = new list<HexaBPM__Condition__c>();
                            for (HexaBPM__Condition__c objCon : objProcess.lstBRConditions) {
                                HexaBPM__Condition__c objNewCon = new HexaBPM__Condition__c();
                                objNewCon = objCon;
                                if (Schema.sObjectType.HexaBPM__Condition__c.fields.HexaBPM__Business_Rule__c.isCreateable()) {
                                    if (objCon.HexaBPM__Business_Rule__c != null) {
                                        if (mapBRIds.get(objCon.HexaBPM__Business_Rule__c) != null) {
                                            objCon.HexaBPM__Business_Rule__c = mapBRIds.get(objCon.HexaBPM__Business_Rule__c);
                                        } else {
                                            throw new HexaBPM.CommonCustomException('Business Rule not found for one of the Condition.');
                                        }
                                    }
                                }
                                if (Schema.sObjectType.HexaBPM__Condition__c.fields.HexaBPM__SR_Template_Docs__c.isCreateable())
                                    objCon.HexaBPM__SR_Template_Docs__c = null;
                                if (Schema.sObjectType.HexaBPM__Condition__c.fields.HexaBPM__Pricing_Line__c.isCreateable())
                                    objCon.HexaBPM__Pricing_Line__c = null;
                                objCon.Id = null;
                                lstBrCond.add(objCon);
                            }
                            if (lstBrCond != null && lstBrCond.size() > 0 && HexaBPM__Condition__c.SObjectType.getDescribe().isCreateable())
                                insert lstBrCond;
                        }
                        list<HexaBPM__Action__c> lstBrActns = new list<HexaBPM__Action__c>();
                        if (mapBRIds != null && mapBRIds.size() > 0 && objProcess.lstBRActions != null && objProcess.lstBRActions.size() > 0) {
                            for (HexaBPM__Action__c objAct : objProcess.lstBRActions) {
                                HexaBPM__Action__c objNewActn = new HexaBPM__Action__c();
                                objNewActn = objAct;
                                if (Schema.sObjectType.HexaBPM__Action__c.fields.HexaBPM__Action_Type__c.isCreateable()) {
                                    if ((objAct.HexaBPM__Action_Type__c == 'Initiate SubSR' || objAct.HexaBPM__Action_Type__c == 'Linked SR') && objAct.HexaBPM__Field_Value__c != '') {
                                        if (mapSubSrIds.get(objAct.HexaBPM__Field_Value__c) != null) {
                                            objNewActn.HexaBPM__Field_Value__c = mapSubSrIds.get(objAct.HexaBPM__Field_Value__c);
                                        } else {
                                            throw new HexaBPM.CommonCustomException('SR-Template not found which is configured as Sub SR (or) Linked SR.');
                                        }
                                    }
                                }
                                if (Schema.sObjectType.HexaBPM__Action__c.fields.HexaBPM__Field_Value__c.isCreateable()) {
                                    if ((objAct.HexaBPM__Action_Type__c == 'Send SMS' || objAct.HexaBPM__Action_Type__c == 'Send Email') && objAct.HexaBPM__Field_Value__c != null && objAct.HexaBPM__Field_Value__c != '' && objAct.HexaBPM__Field_Name__c != null && objAct.HexaBPM__Field_Name__c != '') {
                                        if (mapEmail_Sms_Templates.get(objAct.HexaBPM__Field_Name__c) != null) {
                                            objNewActn.HexaBPM__Field_Value__c = mapEmail_Sms_Templates.get(objAct.HexaBPM__Field_Name__c);
                                        } else {
                                            throw new HexaBPM.CommonCustomException('Email templates not found which is configured as Send SMS (or) Send Email.' + 'DEV Action ID = ' + objNewActn.Id + ' & Email/SMS Template ID = ' + objAct.HexaBPM__Field_Value__c);
                                        }
                                    }
                                }
                                if (Schema.sObjectType.HexaBPM__Action__c.fields.HexaBPM__Business_Rule__c.isCreateable()) {
                                    if (objNewActn.HexaBPM__Business_Rule__c != null) {
                                        if (mapBRIds.get(objNewActn.HexaBPM__Business_Rule__c) != null) {
                                            objNewActn.HexaBPM__Business_Rule__c = mapBRIds.get(objNewActn.HexaBPM__Business_Rule__c);
                                        } else {
                                            throw new HexaBPM.CommonCustomException('Business Rule not found for one of the Action.');
                                        }
                                    }
                                }
                                //if(Schema.sObjectType.HexaBPM__Action__c.fields.id.isCreateable())
                                objNewActn.Id = null;
                                lstBrActns.add(objNewActn);
                            }
                            if (lstBrActns != null && lstBrActns.size() > 0 && HexaBPM__Action__c.SObjectType.getDescribe().isCreateable())
                                insert lstBrActns;
                        }
                    }
                    return pg;
                } else {
                    return null;
                }
            } catch (Exception e) {
                Database.rollback(Stat_svpoint);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                return null;
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Sub-SR which is linked to the Template is not found, please Import Sub-SR.<br/>SUB-SR / Linked SR DEV ID = ' + SUB_SR_DEV_Id));
            return null;
        }
    }
    public string ConnectionError;
    /*
        Method Name : AcessToken
        Description : This Method Will Return the AccessToken by connecting with User Defined SFDC Org
    */
    public string AcessToken(string userName, string Password, string SecurityToken, boolean IsProduction) {
        string strEnvironment = '';
        if (IsProduction != null && IsProduction == true)
            strEnvironment = 'login';
        else
            strEnvironment = 'test';
        if (SecurityToken != null && SecurityToken != '' && SecurityToken.trim() != '')
            Password = Password + '' + SecurityToken.trim();
        string clientId = '3MVG9lcxCTdG2VbtL4GfIDMFScimbUuD1RH.UKpyOH7AfH_O9u9SCvDyPOndFRIZWVXTvFl22k5QWafJywdUw';
        string ConsumerKey = '1992870805511170638';
        //clientId = '3MVG9lcxCTdG2VbtL4GfIDMFSchNrAzMepE8f16B.PxjLRT6weYmnhB8I8mYK2EaYpPg6YasWotMyxooHFDCg';
        //ConsumerKey = '8229005901033125610';
        string URI = 'https://' + strEnvironment + '.salesforce.com/services/oauth2/token?grant_type=password&' + 'client_id=' + clientId + '&' + 'client_secret=' + ConsumerKey + '&' + 'username=' + username + '&' + 'password=' + password;
        system.debug('URI==>'+URI);
        JSONParser parser1;
        accsToken = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URI);
        req.setMethod('POST');
        Http http = new Http();
        if (!isApexTest) {
            HTTPResponse res = http.send(req);
            parser1 = JSON.createParser(res.getBody());
        } else {
            String result = '{"id":"https://test.salesforce.com/id/00Dg0000003L0MREA0/005g0000000vZSKAA2","issued_at":"1398932139767","token_type":"Bearer","instance_url":"https://cs17.salesforce.com","signature":"oQ7eOe8SIHMoqZw6XTX7qsoalf43WPMfJG9foXDhph8=","access_token":"00Dg0000003L0MR!AQUAQPMYBxWQE7EQj8U6q17.6IHneCQ0Fj.N2Reek.i5xA8Z.UFol_.v7iypTySMU1nKaEg0tciXmKyCwCGFPdZtuk_M5dQr"}';
            parser1 = JSON.createParser(result);
            return result;
        }
        if (parser1 != null) {
            while (parser1.nextToken() != null) {
                if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'access_token')) {
                    parser1.nextToken();
                    accsToken = parser1.getText();
                }
                if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'error_description')) {
                    parser1.nextToken();
                    ConnectionError = parser1.getText();
                }
            }
        }
        return accsToken;
    }
    public class SRProcessWrap {
        public HexaBPM__SR_Template__c SRtemplate {get; set;}
        public list<HexaBPM__SR_Steps__c> lstSRSteps {get; set;}
        public list<HexaBPM__SR_Template_Item__c> lstSRTemplateItems {get; set;}
        public list<HexaBPM__SR_Template_Docs__c> lstSRTemplDocs {get; set;}
        public list<HexaBPM__Business_Rule__c> lstBR {get; set;}
        public list<HexaBPM__Step_Transition__c> lstStepTransitions {get; set;}
        public list<HexaBPM__Condition__c> lstBRConditions {get; set;}
        public list<HexaBPM__Action__c> lstBRActions {get; set;}
        public list<HexaBPM__Condition__c> lstSRDocConditions {get; set;}
        public list<HexaBPM__Condition__c> lstPricingConditions {get; set;}
        public list<HexaBPM__Dated_Pricing__c> lstDatedPricing {get; set;}
        public list<HexaBPM__Pricing_Range__c> lstPricingRange {get; set;}
        public SRProcessWrap() {
            SRtemplate = new HexaBPM__SR_Template__c();
            lstSRSteps = new list<HexaBPM__SR_Steps__c>();
            lstSRTemplateItems = new list<HexaBPM__SR_Template_Item__c>();
            lstSRTemplDocs = new list<HexaBPM__SR_Template_Docs__c>();
            lstBR = new list<HexaBPM__Business_Rule__c>();
            lstStepTransitions = new list<HexaBPM__Step_Transition__c>();
            lstBRConditions = new list<HexaBPM__Condition__c>();
            lstBRActions = new list<HexaBPM__Action__c>();
            lstSRDocConditions = new list<HexaBPM__Condition__c>();
            lstPricingConditions = new list<HexaBPM__Condition__c>();
            lstDatedPricing = new list<HexaBPM__Dated_Pricing__c>();
            lstPricingRange = new list<HexaBPM__Pricing_Range__c>();
        }
    }
}