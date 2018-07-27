/**
 * Created by bilalnazir on 6/1/17.
 */

@isTest
public without sharing class GEMS_EmailHelper_Test {

    static testMethod void testBehavior(){
        String[] emailRecepients = new String[]{'bilal.nazir@nsigulf.com'};
        GEMS_EmailHelper emailHelper = new GEMS_EmailHelper(emailRecepients);
        List<EmailTemplate> templates = [SELECT id FROM EmailTemplate LIMIT 1];
        if(templates.size() > 0)
            emailHelper.TemplateID = templates[0].Id;
        emailHelper.build();
        emailHelper.sendEmail();
    }
}