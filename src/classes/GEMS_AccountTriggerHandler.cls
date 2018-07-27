/*****************************************************************************************************************************
    Author      :   Leeba Shibu
    Date        :   29th March 2017
    Description :   Handler class for account trigger
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    --------------------------------------------------------------------------------------------------------------------------
    Version  |  Author     |   Date       | Description
    V1.0     |  Umair Khan |  26-Nov-2017 | Update the value of the field "Ministry List" to "Regular" when "Approval Status" is changed to "Approved"
    V1.1     |  Umair Khan |  14-Dev-2017 | Update Country Group and Country Corporate Group based on Nationality
    V1.2     |  Leeba      |  18-Apr-2018 | Call the informatica update checkbox method only incase of non future account creation.Excluding Interunit Student Creation from batch
*****************************************************************************************************************************/

public without sharing class GEMS_AccountTriggerHandler{
    public Gems_AccountTriggerHandler(){
    
    }
    /**
     * [Execute_BI Execute before insert operations]
     * @param Account_List
     */
    public void Execute_BI(list<Account> Account_List) {
        
        //V1.2
        Map<string,GEMS_OASIS_CountryGroup__c> mapCountryGrp = getGEMSCountryGroup();
        //End
        
        for(Account acc:Account_List){
            if(acc.Photo_URL__c!=null && acc.Photo_URL__c!=''){
                acc.Photo__c = '<img src="'+acc.Photo_URL__c+'" height="154" width="130"></img>';
            }
            string firstName = '';
            string lastName = '';
            string email = '';
            if(string.isNotBlank(acc.FirstName)){
                firstName = acc.FirstName.tolowercase();
            }
            if(string.isNotBlank(acc.LastName)){
                lastName = acc.LastName.tolowercase();
            }
            if(string.isNotBlank(acc.Primary_Contact_Email__c)){
                email = acc.Primary_Contact_Email__c.tolowercase();
            }
            acc.Unique_External__c = firstName+'-'+lastName+'-'+ email;
        
           //V1.2
           if(mapCountryGrp!=null && mapCountryGrp.containsKey(acc.Nationality__c) && acc.Nationality__c != null){
               
               acc.Country_Group__c = mapCountryGrp.get(acc.Nationality__c).CTY_GROUP__c;
               acc.Country_Corporate_Group__c = mapCountryGrp.get(acc.Nationality__c).CTY_CORP_GROUP__c;
           }
           //End
            
        }
    }
    
    /**
    *
    */
    private Map<string,GEMS_OASIS_CountryGroup__c> getGEMSCountryGroup(){
         Map<string,GEMS_OASIS_CountryGroup__c> mapCountryGrp = new Map<string,GEMS_OASIS_CountryGroup__c>();
        
        for(GEMS_OASIS_CountryGroup__c CG : [Select Name,CTY_CORP_GROUP__c,CTY_GROUP__c, CTY_NATIONALITY__c,NATIONALITY_API__c From GEMS_OASIS_CountryGroup__c]){
            mapCountryGrp.put(CG.Name,CG);
        }
        
        return mapCountryGrp;
    }
    
    /**
     * [Execute_AI Execute after insert operations]
     * @param Account_List
     */
    public void Execute_AI(list<Account> Account_List) {
        try{
            list<string> listAccountIds = new list<string>();
            for(Account acc:Account_List){
                if(acc.Record_Type_Name__c=='Parent_Guardian')
                    listAccountIds.add(acc.Id);
            }
            //V1.2
            if(listAccountIds.size()>0 && system.isFuture()==false && System.isBatch()==false)
                GEMS_AccountTriggerHelper.UpdateInformaticaCheckBox(listAccountIds);
                
            //Code to calculate total students,number of girls and boys in a section when a student gets created and Section is not blank
            set<string> setSectionIds = new set<string>();
            for(Account acc:Account_List){
                if(acc.Record_Type_Name__c =='Student' && acc.Section__c!=null && acc.Current_Status__c=='EN'){
                    setSectionIds.add(acc.Section__c);
                }
            }
            if(setSectionIds.size()>0){
                GEMS_AccountTriggerHelper.CalculateAllocationCount(setSectionIds);
            } 
            GEMS_Utility.shareAccountsWithRegistrar(Account_List);
        }catch(Exception e){
            GEMS_Utility.LogException(e);
        }
        
        // To create Parent Relationship records on insert of Parent Account and sibling relationship on insert of Sibling records from oasis
        try{
            GEMS_AccountTriggerHelper.CreateRelationships(Account_List);                      
        }catch(Exception e){
            GEMS_Utility.LogException(e);
        }
        
        /*
        for(Account objAcc : Account_List){
            if(objAcc.Record_Type_Name__c=='Student' && objAcc.Sys_Student_from_Oasis__c==false)
                GEMS_AccountTriggerHelper.UpdateInformaticaCheckBox(Account_List);
        }
        */
    }
    /**
     * [Execute_BU Execute before update operations]
     * @param Account_List
     * @param Map<Id,Account> oldMap
     */
    public void Execute_BU(List<Account> Account_List,Map<Id,Account> oldMap) {
        try {
            
            Schema.DescribeSObjectResult acctSchema = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = acctSchema.getRecordTypeInfosByName();
            
             //V1.2
            Map<string,GEMS_OASIS_CountryGroup__c> mapCountryGrp = getGEMSCountryGroup();
            //End
            
            for(Account acc:Account_List){
                if(acc.Photo_URL__c!=null && acc.Photo_URL__c!=''){
                    acc.Photo__c = '<img src="'+acc.Photo_URL__c+'" height="154" width="130"></img>';
                }
                string firstName = '';
                string lastName = '';
                string email = '';
                if(string.isNotBlank(acc.FirstName)){
                    firstName = acc.FirstName.tolowercase();
                }
                if(string.isNotBlank(acc.LastName)){
                    lastName = acc.LastName.tolowercase();
                }
                if(string.isNotBlank(acc.Primary_Contact_Email__c)){
                    email = acc.Primary_Contact_Email__c.tolowercase();
                }
                acc.Unique_External__c = firstName+'-'+lastName+'-'+ email; 
                
                //V1.0  : Update the value of the field "Ministry List" to "Regular" when "Approval Status" is changed to "Approved"
                if(string.isNotBlank(acc.Approval_Status__c) && acc.Approval_Status__c == 'Approved' &&  (AccountRecordTypeInfo.get('Student').getRecordTypeId() == acc.RecordTypeId ||
                    AccountRecordTypeInfo.get('Student Read Only').getRecordTypeId() == acc.RecordTypeId)){
                    acc.Ministry_List__c = 'Regular';
                }
                
                if(acc.Ministry_List__c == 'Regular'){
                    acc.Ministry_list_type__c = 'Regular';
                }
                else if(acc.Ministry_List__c == 'Observer'){
                   acc.Ministry_list_type__c = 'Observer - Doc';
                }
                //End
                
               //V1.2
               if(acc.Nationality__c == null){
                   acc.Country_Group__c = '';
                   acc.Country_Corporate_Group__c ='';
              }
               if(mapCountryGrp.containsKey(acc.Nationality__c) && acc.Nationality__c != null){// &&  acc.Nationality__c != oldMap.get(acc.Id).Nationality__c
                   acc.Country_Group__c = mapCountryGrp.get(acc.Nationality__c).CTY_GROUP__c;
                   acc.Country_Corporate_Group__c = mapCountryGrp.get(acc.Nationality__c).CTY_CORP_GROUP__c;
              }
              
              //End
            }
            
            
            GEMS_AccountTriggerHelper.syncPrimaryContactInformation(Account_List,oldMap);
            
   
        }catch(Exception e) {
            GEMS_Utility.LogException(e);
        }
    }
    /**
     * [Execute_AU Execute after update operations]
     * @param Account_List
     * @param Map<Id,Account>oldMap
    */
    public void Execute_AU(list<Account> Account_List,Map<Id,Account> oldMap){
        try{
            
            set<string> setSectionIds = new set<string>();
            for(Account acc:Account_List){
                //Logic when the Section value is Assigning or Re-Assigning for the Account to calculate the current count for Section
                if(acc.Record_Type_Name__c =='Student' && (oldMap.get(acc.Id).Section__c!=acc.Section__c || oldMap.get(acc.Id).Current_Status__c!=acc.Current_Status__c)){
                    if(oldMap.get(acc.Id).Section__c!=null)
                        setSectionIds.add(oldMap.get(acc.Id).Section__c);
                    if(acc.Section__c!=null)
                        setSectionIds.add(acc.Section__c);
                }
            }
            if(setSectionIds.size()>0)
                GEMS_AccountTriggerHelper.CalculateAllocationCount(setSectionIds);
        }catch(Exception e){
            GEMS_Utility.LogException(e);
        }
    }
    /**
     * [Execute_BD Execute Before Delete operations]
     * @param Map<Id,Account>oldMap
    */
    public void Execute_BD(Map<Id,Account> oldMap){
        //code to reduce the number of alloted students from Section if a student is deleted.
        try{
            map<string,list<Account>> MapStudent = new map<string,list<Account>>();
            
            set<string> setSectionIds = new set<string>();
            set<string> setAccountIds = new set<string>();
            for(Account acc:oldMap.values()){
                if(acc.Record_Type_Name__c =='Student' && acc.Section__c!=null){
                    setSectionIds.add(acc.Section__c);
                    setAccountIds.add(acc.Id);
                }
            }
            if(setSectionIds.size()>0 && setAccountIds.size()>0)
                GEMS_AccountTriggerHelper.CalculateAllocationCount_Delete(setSectionIds,setAccountIds);
            
        }catch(Exception e){
            GEMS_Utility.LogException(e);
        }
    }
    
   
}