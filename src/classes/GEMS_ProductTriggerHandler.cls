/**************************************************************************************************
 * Name               : GEMS_ProductTriggerHandler                                                    *
 * Description        : Product Trigger Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017                                               *
 **************************************************************************************************/
public with sharing class GEMS_ProductTriggerHandler {
	public GEMS_ProductTriggerHandler() {
		
	}

   public void Execute_AU(List<Product2>productList, Map<Id,Product2> oldMap){
      deleteProducts(productList);
   }
   public void deleteProducts(List<Product2> productList){

   List<Id> deletionList = new List<Id>();
   for(Product2 prodObj : productList){
          if(prodObj.sys_is_deleted__c){
             deletionList.add(prodObj.Id);
          }
   }

   if(!deletionList.isEmpty()){
      Database.delete(deletionList);
   }

   }
}