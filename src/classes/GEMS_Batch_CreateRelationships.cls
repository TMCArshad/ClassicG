/*****************************************************************************************************************************
    Author      :   Leeba
    Date        :   2nd August 2017
    Description :   Batch class to create missing Parent Relationships 
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public without sharing class GEMS_Batch_CreateRelationships implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        String StrQuery = 'select Id,Sibling_ID__c from Account where RecordType.DeveloperName \'Student\' and Sibling_ID__c!=null and Father__c=null and Mother__c=null and Guardian_1__c=null and Guardian_2__c=null and Sys_Student_from_Oasis__c=true' ;
        if(system.test.isRunningTest())
            StrQuery = 'select Id,Sibling_ID__c from Account where Sys_Student_from_Oasis__c=true';
        return Database.getQueryLocator(StrQuery); 
    } 
    public void execute(Database.BatchableContext BC,list<Account> lstStudents){ 
        try{ 
            set<string> setSiblingIds = new set<string>();//Sibling_ID__c
            map<string,list<string>> mapStudentSibling = new maP<string,list<string>>();
            for(Account acc:lstStudents){
                setSiblingIds.add(acc.Sibling_ID__c);
                list<string> StudentAccounts = new list<string>();
                if(mapStudentSibling.get(acc.Sibling_ID__c)!=null)
                    StudentAccounts = mapStudentSibling.get(acc.Sibling_ID__c);
                StudentAccounts.add(acc.Id);
                mapStudentSibling.put(acc.Sibling_ID__c,StudentAccounts);
            }
            if(setSiblingIds.size()>0){
                list<Relationship__c> lstRel = new list<Relationship__c>();
                for(Account acc:[select id,Master_Student__c,RecordType.DeveloperName,Role__c,PersonEmail,FirstName,LastName from Account where Master_Student__c IN:setSiblingIds and Sys_Parent_from_Oasis__c=true and Role__c!=null and Role__c!='Sibling']){
                    for(string StudentAccount:mapStudentSibling.get(acc.Master_Student__c)){
                        Relationship__c rel = new Relationship__c();
                        rel.Active__c = true;
                        rel.Subject_Account__c = StudentAccount;
                        rel.Object_Account__c = acc.Id;
                        rel.Type__c = acc.Role__c;
                        rel.Email__c = acc.PersonEmail;
                        rel.First_Name__c = acc.FirstName;
                        rel.Last_Name__c = acc.LastName;
                        rel.Created_From__c = 'Batch';                  
                        lstRel.add(rel);
                    }
                }
                if(lstRel.size()>0)
                    insert lstRel;
            }
        }catch(Exception e){ 

        } 

    } 
    public void finish(Database.BatchableContext BC){ 

    }    
}