/************************************************************************************
* Name               : GEMS_CopyAddressCls                                                              *
* Description        : Implements logic for copy address data functionality                                       *
* Created Date       : 14/03/2018                                                                *
* Created By         : Leeba Shibu (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Leeba       14/03/2018

**************************************************************************************************/

public without sharing class GEMS_CopyAddressCls{
	
  public string SubjectAccountId{get;set;}
  public string SubjectRelation{get;set;}
  public String MasterStudentId{get;set;}
  public list<SelectOption> roleList{get; set;}
  public string selectedRole{get;set;}
  
  public GEMS_CopyAddressCls(){
  	//setting the values
    if(apexpages.currentPage().getParameters().get('Id')!=null){
            SubjectAccountId = apexpages.currentPage().getParameters().get('Id');
            SubjectRelation = apexpages.currentPage().getParameters().get('Role');
            MasterStudentId = apexpages.currentPage().getParameters().get('MasterStudent');
            system.debug(SubjectRelation);
            prepareRole();
         
    }
  }
  
  public List<SelectOption> prepareRole(){
        roleList = new List<SelectOption>();
        //display the picklist options according to the selected Role
        if (SubjectRelation =='Father'){
            roleList.add(new SelectOption('Mother','Mother'));
            roleList.add(new SelectOption('Guardian','Guardian'));
        }
        else  if (SubjectRelation =='Mother'){
            roleList.add(new SelectOption('Father','Father'));
            roleList.add(new SelectOption('Guardian','Guardian'));
        
        }
        else  if (SubjectRelation =='Guardian'){
            roleList.add(new SelectOption('Father','Father'));
            roleList.add(new SelectOption('Mother','Mother'));
         } 
         return roleList;
        
  } 
  public pagereference SaveDetails(){
       Pagereference pg;
       if(selectedRole!=null && selectedRole!='' && SubjectAccountId!=null){ 
          list<Account> lstObjectAccounts = new list<Account>();
          Account objSubjectAccount = new Account();
          map<string,string> MapObjectAccounts = new map<string,string>();
          //get the account that needs to be updated by querying the relation object
          for(Relationship__c rel:[select Id,Object_Account__c from Relationship__c where Master_Student_from_Parent__c=:MasterStudentId and Type__c=:selectedRole and Active__c=true]){
              if(MapObjectAccounts.get(rel.object_Account__c)==null){
                  Account objObjectAccount = new Account(Id=rel.object_Account__c);
                  objObjectAccount.Id = rel.Object_Account__c;
                  lstObjectAccounts.add(objObjectAccount);
                  MapObjectAccounts.put(rel.object_Account__c,rel.object_Account__c);
              }
              system.debug (lstObjectAccounts);
          }
          if(lstObjectAccounts.size()==0){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'No Active Relationhsip of type '+selectedRole+' found.'));
              return null;
          }
          
          // get the current fields that needs to be copied from the custom setting "Copy Parent Details"
          string strQuery = 'Select Id';
          if(lstObjectAccounts.size()>0 && Copy_Parent_Details__c.getAll()!=null && Copy_Parent_Details__c.getAll().values()!=null){
              for(Copy_Parent_Details__c cs:Copy_Parent_Details__c.getAll().values()){
                  strQuery = strQuery+','+cs.Subject_Acc_Apiname__c;
              }
              strQuery = strQuery+' from Account where Id=:SubjectAccountId';
              objSubjectAccount = database.query(strQuery);
              for(Account objObjectAccount:lstObjectAccounts){
                  for(Copy_Parent_Details__c cs:Copy_Parent_Details__c.getAll().values()){
                      objObjectAccount.put(cs.Object_Acc_Apiname__c,objSubjectAccount.get(cs.Subject_Acc_Apiname__c));
                  }
              }
              update lstObjectAccounts;
              
              pg = new pagereference('/'+SubjectAccountId);
              pg.setredirect(true);
          }
       }
       return pg;
  }
  
  public pagereference CancelDetails(){
        Pagereference pg = new Pagereference('/'+SubjectAccountId);
        pg.setredirect(true);
        return pg;
    }
   

}