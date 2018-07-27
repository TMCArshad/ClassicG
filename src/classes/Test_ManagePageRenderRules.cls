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
private class Test_ManagePageRenderRules {

    static testMethod void myUnitTest() {
        Page_Flow__c pgFlow = new Page_Flow__c();
        pgFlow.Name = 'Test';
        pgFlow.Master_Object__c = 'Service_Request__c';
        pgFlow.Flow_Description__c = 'Sample Desc';
        insert pgFlow;
        
        Page__c objPG = new Page__c();
        objPG.Name = 'Test Page';
        objPG.Is_Custom_Component__c = true;
        objPG.VF_Page_API_Name__c = 'DocumentViewer';
        objPG.Page_Flow__c = pgFlow.Id;
        insert objPG;
        
        Section__c objSec = new Section__c();
        objSec.Name = 'Test Sec';
        objSec.Layout__c = '1';
        objSec.Page__c = objPG.Id;
        objSec.Section_Type__c = 'PageBlockSection';
        objSec.Section_Title__c = 'Sample Section';
        objSec.Default_Rendering__c = true;
        insert objSec;
        
        Section_Detail__c objSD = new Section_Detail__c();
        objSD.Section__c = objSec.Id;
        objSD.Name = 'Test SD';
        insert objSD;
        
        Page_Navigation_Rule__c pgRule = new Page_Navigation_Rule__c();
        pgRule.Page__c = objPG.Id;
        pgRule.Rule_Name__c = 'Test Rule';
        pgRule.Rule_Description__c = 'Test Desc';
        insert pgRule;
        
        
        
        apexpages.currentPage().getParameters().put('Id',objPG.Id);
        apexpages.currentPage().getParameters().put('Type','CommandButton');
        
        ManagePageRenderRules obj = new ManagePageRenderRules();
        obj.ClearRelatedLists();
        obj.CancelCondActions();
        obj.AddRule();
        obj.RuleIndex = 0;
        obj.SavePGRule();
        obj.RuleIndex = 0;
        obj.EditPGRule();
        obj.RuleIndex = 0;
        obj.CancelPGRule();
        obj.strNavigRuleId = pgRule.Id;
        obj.AddCondition();
        
        list<Page_Flow_Condition__c> lst = new list<Page_Flow_Condition__c>();
        
        for(integer i=0;i<3;i++){
            Page_Flow_Condition__c pg1 = new Page_Flow_Condition__c();
            pg1.Object_Name__c = 'Service_Request__c';
            pg1.Field_Name__c = 'Name';
            pg1.Value__c = 'Durga';
            pg1.Operator__c = '=';
            pg1.Page_Navigation_Rule__c = pgRule.Id;
            lst.add(pg1);
        }
        obj.objNavigRule.Rule_Condition__c = '(1 AND 2) OR (1 AND 3) OR (2 AND 3)';
        obj.lstPgCond = lst;
        obj.SaveCondition();
        obj.strNavigRuleId = pgRule.Id;
        obj.Prepare_Conditions_Actions();
        obj.objNavigRule.Rule_Condition__c = '';
        obj.lstPgCond = lst;
        obj.SaveCondition();
        obj.CondRowIndex = 0;
        obj.RemoveCondition();
        obj.ManagePGRule();
        obj.strNavigRuleId = pgRule.Id;
        obj.DelPGRule();
        obj.Back_to_SectionDetail();
    }
}