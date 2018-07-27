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
private class GEMS_Batch_CreateRelationships_Test {

    static testMethod void myUnitTest() {
        map<string,string> MapRecordTypes = new map<string,string>();
        for(RecordType rec:[select Id,DeveloperName from RecordType where sObjectType='Account' and isActive=true]){
            MapRecordTypes.put(rec.DeveloperName,rec.Id);
        }
        Account acc = new Account();
        acc.RecordTypeId = MapRecordTypes.get('Student');
        acc.FirstName = 'Student';
        acc.LastName = 'One';
        acc.Sibling_ID__c = '123456';
        acc.Sys_Student_from_Oasis__c = true;
        insert acc;
        
        Account acc2 = new Account();
        acc2.RecordTypeId = MapRecordTypes.get('Parent_Guardian');
        acc2.FirstName = 'Parent';
        acc2.LastName = 'One';
        acc2.Master_Student__c = '123456';
        acc2.Role__c = 'Father';
        acc2.Sys_Parent_from_Oasis__c = true;
        insert acc2;
        
        list<Relationship__c> lstRel = [select Id from Relationship__c limit 100];
        delete lstRel;
        
        acc.Father__c = null;
        acc.Mother__c = null;
        acc.Guardian_1__c = null;
        acc.Guardian_1__c = null;
        update acc;
        
        GEMS_Batch_CreateRelationships objBtch = new GEMS_Batch_CreateRelationships();
        database.executebatch(objBtch,200);
    }
}