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
private class Test_Import_FlowCls {

    static testMethod void myUnitTest() {
        Process_Migration_Setup__c objCS = new Process_Migration_Setup__c();
        objCS.Name = 'TEST UAT';
        objCS.User_Name__c = 'test@test.com';
        objCS.Password__c = 'salesforce@123';
        objCS.Instance_URL__c = 'https://cs5.salesforce.com';
        objCS.Security_Token__c = '';
        insert objCS;
        
        Import_FlowCls.isApexTest = true;
        Import_FlowCls obj = new Import_FlowCls();
        Import_FlowCls.FlowProcessWrap objwrap =  new Import_FlowCls.FlowProcessWrap();
        obj.strTemplateName = 'New_Company_Application';
        obj.selSandBox = objCS.Id;
        obj.FetchAccesToken();
        obj.ImportProcess();
        obj.ConfirmSave();
        
        Rest_FlowProcess.GetFlowProcess(obj.strTemplateName);
    }
}