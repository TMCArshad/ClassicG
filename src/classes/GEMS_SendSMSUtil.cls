/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   12th April 2017
    Description :   Webservice class for SMS Integration
    Modification History
*****************************************************************************************************************************/
global with sharing class GEMS_SendSMSUtil{
    @future (callout=true)
    webservice static void sendsms(String SRMob,string strMessage){
        system.debug('SRMob==>'+SRMob);
        system.debug('strMessage==>'+strMessage);
        
        //Make the mobile number in required format
        String mobileNo = '971'+SRMob.right(9);
        system.debug('MMMMM'+mobileNo);
        
        string SMSMessage = '';
        //SMSMessage = strMessage;
        SMSMessage = EncodingUtil.URLENCODE(strMessage,'UTF-8');
        
        string strUName = label.SMS_Username;
        string strPassword = label.SMS_Password;
        //targetString = EncodingUtil.URLENCODE(targetString,'UTF-8');
 
        string SMSEndPoint = 'http://www.netpipersms.com/website/sendsms.asp?UserName='+strUName+'&Password='+strPassword+'&Message='+SMSMessage+'&MobNumber='+mobileNo+'&MsgType=SMS&From=6367&Test=0&Store=1';
        
        
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000);//milliseconds
        //req.setHeader('Content-Length', '512');
        req.setEndpoint(SMSEndPoint);
        req.setMethod('GET');
        
        try{
            if(!system.test.isRunningTest())
                res = http.send(req);
            system.debug('***Body was:' + res.getBody());
        }catch(Exception e){
            
        }
    }
}