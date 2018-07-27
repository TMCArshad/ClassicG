public with sharing class GEMS_GoogleCaptchaController{

    /*
    private static String baseUrl = 'https://www.google.com/recaptcha/api/verify'; 

    private static String privateKey = '6LeLLxgUAAAAAPpJHMjlGt55NWjbHaCu7w5jWBpK';
    public String publicKey { 
        get { return '6LdnLxgUAAAAAMUgGqOCnhL710KDtmdhtNeWybPP'; }
    } 
    */

    //Bilal's New Captcah keys
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
    private static String privateKey = '6LepEfwSAAAAAASNFNew1-039Uf-Seykvch5_FUu';
    public String publicKey {
        get { return '6LepEfwSAAAAADUgZe2xPK8Kmmrn4B0RsCz827oo'; }
    }
    
    /* Implementation */
    
    // Simple form fields for the example form
    public String myName { get; set; }
    public String myEmail { get; set; }
    
    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    public String challenge {
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
//    public String response  {
//        get {
//            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
//        }
//    }
    public String response  {
        get {   return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); }
    }
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    
    public GEMS_GoogleCaptchaController() {
        this.verified = false;
    }

    /*
    public PageReference verify() {
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if ( challenge == null || response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return null; 
        }
        system.debug('---1---'+challenge);    
        system.debug('---2---'+response);         
        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&remoteip='  + remoteHost + 
            '&challenge=' + challenge +
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }
        
        if(this.verified) {
            // If they pass verification, you might do something interesting here
            // Or simply return a PageReference to the "next" page
            return null;
        }
        else {
            // stay on page to re-try reCAPTCHA
            return null; 
        }
    }*/
    public string verify() {
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if (response == null){
            System.debug('reCAPTCHA verification attempt with empty form');
            return null;
        }

        HttpResponse r = makeRequest(baseUrl,'secret=' +privateKey+ '&remoteip='  +remoteHost+ '&response='  +response);

        boolean verified = false;
        if ( r!= null ) {
            //verified = (r.getBody().startsWithIgnoreCase('true'));
            try{
                Map<String, String> response = (Map<String, String>)JSON.deserialize(String.valueOf(r.getBody()), Map<String, String>.class);
                if(response != null && response.containsKey('success'))
                    verified = Boolean.valueOf(response.get('success'));
            }catch(Exception ex){
                System.debug('Captcah Verify failed, Response =' + r.getBody());
            }
            System.debug('Captcha Response' + r.getStatus());
        }

        if(verified) {
            // If they pass verification
            return 'Success';
        }
        else {
            // stay on page to re-try reCAPTCHA
            return 'Error';
        }
    }

    public PageReference reset() {
        return null; 
    }   

    /* Private helper methods */
    
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            system.debug('---ret---'+ret);
            return ret;
        }
    }
}