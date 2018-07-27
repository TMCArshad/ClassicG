public class MiGS_Payment{


public PageReference payNow(){
	GEMS_MiGS_Utility.SRIds = ''; //Setting list of SR ids if in case multiple SRs are paid once
    GEMS_MiGS_Utility.retURLVal = 'http://www.google.com'; // Setting value so that once transion is complete we know where to redirect
    GEMS_MiGS_Utility.schoolCode = '121013';//'126008';
    String url = GEMS_MiGS_Utility.getMiGSPaymentURL('300','Test','https://cs88.salesforce.com/apex/GEMS_PaymentRedirectpage?');
    PageReference pg ;
                            system.debug('Url is : '+url);
                            pg = new PageReference(url);
                            pg.setRedirect(true);
                            return pg;
 }
}