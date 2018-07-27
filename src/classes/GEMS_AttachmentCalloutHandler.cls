public class GEMS_AttachmentCalloutHandler {
    
    @future(callout=true)
    public static void makeCalloutToInformatica(){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint('https://ps1w2.rt.informaticacloud.com/active-bpel/public/rt/001OL7/SFDC-Attachment-To-SQLSERVER');
        req.setMethod('GET');
        try{
            if(!system.test.isRunningTest()){
                res = http.send(req);
            }
            system.debug('res==>'+res);
            system.debug('res==>'+res.getBody());
        }catch(System.CalloutException e){
            System.debug('Job Error: '+ e);
            System.debug(res.toString());
        }
    }

}