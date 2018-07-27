/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   25 April 2017
    Description :   Class to trigger the informatica job from custom buttons in salesforce
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
     1.1         Leeba-PWC          7/5/2018   added custom label for username password
    
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

global without sharing class GEMS_InformaticaJobInvocation{
    public static boolean isTestInvoke = false;
    WebService static string StartDSSJob(string DSSJobId){
        string CurrentSessionId = '';
        string strResponse = '';
        if(Informatica_SessionId__c.getAll()!=null){
            for(Informatica_SessionId__c objInfSetting:Informatica_SessionId__c.getAll().values()){
                CurrentSessionId = objInfSetting.Name;
            }
        }
        if(CurrentSessionId=='')
            CurrentSessionId = getInformaticaSessionId();
        strResponse = RunInformaticaDSSTask(DSSJobId,CurrentSessionId);
        return strResponse;
    }
    public static string getInformaticaSessionId(){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        
        //1.1
        string uname = label.Informatica_Username;
        string pword = label.Informatica_Password;
        string InformaticaSessionId;//= 'PNegSFm1yYZg9kAZ';//session id will be valid for 2 hours
        string calltype = 'login';//logout in case of logout call
        string postData='{\"@type\": \"'+calltype+'\",\"username\": \"'+uname+'\",\"password\": \"'+pword+'\"}';
        system.debug('postData==>'+postData);
        
        req.setHeader('content-type','application/json');
        req.setBody(postData);
        
        /* Code to Invoke the Login call and get the Session Id of Informatica */
        req.setEndpoint('https://app.informaticaondemand.com/ma/api/v2/user/login');
        req.setMethod('POST');
        try{
            if(!system.test.isRunningTest())
                res = http.send(req);
            else
                InformaticaSessionId   = 'PNegSFm1yYZg9kAZ';
            system.debug('res==>'+res);
            system.debug('res==>'+res.getBody());
            if(res!=null && res.getStatusCode()==200){
                string responseval = res.getBody()+'';
                map<string,Object> MapJsonResponse = (map<string,Object>)JSON.deserializeUntyped(responseval);
                if(MapJsonResponse.get('icSessionId')!=null)
                    InformaticaSessionId = string.valueof(MapJsonResponse.get('icSessionId'));
                system.debug('SessionId==>'+InformaticaSessionId);
            }
        }catch(System.CalloutException e){
            System.debug('Job Error: '+ e);
            System.debug(res.toString());
        }
        return InformaticaSessionId;
    }
    public static string RunInformaticaDSSTask(string InfDSSJobId,string strSessionId) {
        string icErrorMessage = '';
        String taskID = '';
        String jobType = '';
        string InfSessionId = strSessionId;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        taskID = InfDSSJobId;//Sandbox - Update Enquiries from Oasis to Salesforce
        jobType = 'DSS';
        req.setEndPoint('https://app3.informaticacloud.com/saas/api/v2/job');
        req.setHeader('HTTP', '1.0');
        req.setHeader('Content-Type', 'application/xml');
        req.setHeader('Accept', 'application/xml');
        req.setHeader('icSessionId', InfSessionId); 
        req.setBody('<job>' + '<taskId>' + taskID + '</taskId>' + '<taskType>' + jobType + '</taskType>' + '</job>');
        req.setMethod('POST');
        try{
            if(!system.test.isRunningTest())
                res = http.send(req); //If successful there will be no response 
            if(res!=null && res.getBody()!=null && res.getBody() <> ''){
                icErrorMessage = res.getBody(); 
            } 
        }catch(Exception e){
            icErrorMessage = e + ' - Response: ' + res.ToString();
        }
        system.debug('icErrorMessage==>'+icErrorMessage);
        if(isTestInvoke==true)
            icErrorMessage = 'icSessionId is not valid';
        if(icErrorMessage!=null && icErrorMessage.indexof('icSessionId')>-1 && icErrorMessage.indexof('is not valid')>-1){
            string newSessionId = getInformaticaSessionId();
            if(newSessionId!=null && isTestInvoke==false)
                RunInformaticaDSSTask(InfDSSJobId,newSessionId);
        }else{
            if(strSessionId!=null && Informatica_SessionId__c.getAll()!=null){
                delete Informatica_SessionId__c.getAll().values();
                Informatica_SessionId__c objNewSession = new Informatica_SessionId__c();
                objNewSession.Name = strSessionId;
                insert objNewSession;
                icErrorMessage = 'Success';
            }
        }
        if(icErrorMessage==null || (icErrorMessage!=null && icErrorMessage.trim()==''))
            icErrorMessage = 'Success';
        return icErrorMessage;
    }
}