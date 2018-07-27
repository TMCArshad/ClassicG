/*
Author      : PwC - Umair Khan
Date        : 26th November, 2017 
Description : To show all Relationship data related to Student or Parent/Guardian
Modification History :

*/



public without sharing class GEMS_RelationpShipCls{
  
  
  private ApexPages.StandardController stdController;  
  public boolean studentFlag{get;set;}
  public boolean parentFlag{get;set;}
  public string strAcctId{get;set;}
  public List<Account> lstAccount {get;set;}
  public List<Relationship__c> lstRelationship {get;set;}

  public GEMS_RelationpShipCls(ApexPages.StandardController controller){
       
     System.debug('>>>>>>>>>>ApexPages.StandardController>>>>>>>>>>>>>>>');
     this.stdController = controller;
     strAcctId= apexpages.currentpage().getparameters().get('id');   
     System.debug('>>>>>>>>>>strAcctId>>>>>>>>>>>>>>>'+strAcctId);
     studentFlag = false;
     parentFlag = false;
     getRelationshipData();
       
  }
  
  public void getRelationshipData(){
  
      try{
          
          lstAccount = [Select Id,Student_Id__c,Master_Student__c From Account Where Id =: strAcctId];
          
          
          if(lstAccount.size() > 0){
              
              if(lstAccount[0].Student_Id__c != null){
                  lstRelationship = [Select Id,Name,Object_Account__c,Object_Account__r.Name,Type__c,Active__c,Active_Image__c from Relationship__c 
                  Where Subject_Account__c=:strAcctId  and Active__c = true];
                  
                  studentFlag = true;
              }
              else if(lstAccount[0].Master_Student__c != null){
                  lstRelationship = [Select Id,Name,Subject_Account__c,Subject_Account__r.Name,Type__c,Active__c,Active_Image__c from Relationship__c 
                  Where Object_Account__c =:strAcctId  and Active__c = true];
                  
                  parentFlag = true;
              }
              
            
          }
          
      
      }
      catch(Exception ex){
          
          system.debug('Exception>>>>>>>' + ex.getMessage());
      
      }


 }
 
 
}