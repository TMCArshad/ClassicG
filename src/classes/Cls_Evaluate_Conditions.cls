/*
  Author    :  Durga Prasad
  Description  :  This is an Utility class where we will re-use the method to
          evaluate the conditions.
*/
public without sharing class Cls_Evaluate_Conditions {
  
  public static boolean Check_each_Condition(sObject DyncObject,string ObjectName,string FieldName,string Operator,string Value){
    system.debug('ObjectName==>'+ObjectName); 
        system.debug('FieldName==>'+FieldName); 
        system.debug('Operator==>'+Operator);
        system.debug('Value==>'+Value);
        system.debug('DyncObject==>'+DyncObject);
        boolean ConditionMet = false;
        string ObjectValue;
        string ConditionValue;
        if(Value!=null){ 
            ConditionValue = Value;
        }else{
            ConditionValue = 'null';
        }
        system.debug('ConditionValue==>'+ConditionValue);
        if(DyncObject!=null && ObjectName=='HexaBPM__Service_Request__c'){
            if(DyncObject.get(FieldName)!=null){
                ObjectValue = string.valueOf(DyncObject.get(FieldName));
            }else{
                ObjectValue = 'null';
            }
            system.debug('ObjectValue==>'+ObjectValue);
            if(Operator=='=' && ConditionValue==ObjectValue){
                ConditionMet = true;
            }else if(Operator=='!=' && ConditionValue!=ObjectValue){
                ConditionMet = true;
            }else if(Operator=='>=' && ConditionValue>=ObjectValue){
                ConditionMet = true;
            }else if(Operator=='<=' && ConditionValue<=ObjectValue){
                ConditionMet = true;
            }
        }
        system.debug('ConditionMet==>'+ConditionMet);
        return ConditionMet;
  }
  public static boolean Check_PageNavigation_Conditions(list<Page_Flow_Condition__c> lstCond,sObject DyncObject){
    boolean result = false;
    if(lstCond!=null && lstCond.size()>0 && DyncObject!=null){
      for(Page_Flow_Condition__c objCon:lstCond){
        if(objCon.Object_Name__c!=null && objCon.Field_Name__c!=null && objCon.Operator__c!=null){
          boolean eachCond = Check_each_Condition(DyncObject,objCon.Object_Name__c,objCon.Field_Name__c,objCon.Operator__c,objCon.Value__c);
          if(eachCond==true)
            result = true;
        }
      }
    }
    return result;
  }
  
  public static boolean executeNavigationRules(string strTextCondition,sObject DyncObject){
     system.debug('strTextCondition===>'+strTextCondition);
     system.debug('DyncObject===>'+DyncObject);
     if(DyncObject!=null && strTextCondition!=null && strTextCondition!=''){
          Boolean FieldParseFlag=true;
       Boolean ConditionParseFlag=false;
       Boolean combinedConditionFlag=false;
       Boolean ValueParseFlag=false;
       Boolean parseResult;
       Boolean lastParseResult;
       Boolean combinedConditionResult;
       String SRFieldValue;
       String valueName;
       String operator;
       String condition;
       String combinedConditionStrng;
       
       //set of predefined operators
       Set<String> operatorSet = new Set<String>{'=','>=','<=','CONTAINS','STARTS','!='};
       
       //set of predefined conditions
       Set<String> conditionSet = new Set<String>{'AND','OR'};
       
       //string to be executed
       string conditionStrng = strTextCondition;
       
       //split the condition string by #
       list<String> conditionStringLstRaw = new list<string>();
       list<String> conditionStringLst = new list<string>();
       if(conditionStrng!=null && conditionStrng.trim()!='')
            conditionStringLstRaw = conditionStrng.split('#');
       if(conditionStringLstRaw!=null && conditionStringLstRaw.size()>0){
            for(string str:conditionStringLstRaw){
                if(str!=null && str!='' && str.trim()!=''){
                    conditionStringLst.add(str.trim());
                }
            }
       }
       
       system.debug('conditionStringLst===>'+conditionStringLst);
       
       for(String eachString:conditionStringLst){
          system.debug('eachString===>'+eachString);
          if(eachString=='('){
             parseResult=null;
             lastparseResult=null;
             ValueParseFlag=false;
             FieldParseFlag=true;
             continue;
          }else if(eachString==')'){
             if(combinedConditionStrng==null){
                combinedConditionResult=parseResult;
             }else{
                combinedConditionResult = parseConditions(combinedConditionResult,parseResult,combinedConditionStrng);
                parseResult=combinedConditionResult;
             }
             combinedConditionFlag=true;
             continue;
          }else if(combinedConditionFlag){
             combinedConditionStrng=eachString;
             combinedConditionFlag=false;   
             continue; 
          }else if(FieldParseFlag){
                if(operatorSet.contains(eachString)){
                    operator=eachString;
                    FieldParseFlag=false;
                    ValueParseFlag=true;      
                }else{
                    system.debug('Navigation Cond string before Split===>'+eachString);
                    list<string> lstObjectFld = new list<string>();
                    if(eachString!=null && eachString!=''){
                        eachString = eachString.replace('->','#');
                        lstObjectFld = eachString.split('#');
                        system.debug('lstObjectFld===>'+lstObjectFld);
                        if(lstObjectFld!=null && lstObjectFld.size()>=2){
                            eachString = lstObjectFld[1];
                        }
                    }
                    system.debug('Navigation Cond string after split===>'+eachString);
                    if(lstObjectFld!=null && lstObjectFld.size()>=2){
                        system.debug('1');
                        if(lstObjectFld[0].tolowercase()=='HexaBPM__service_request__c'){
                            system.debug('2');
                            if(DyncObject!=null){
                                system.debug('3');
                                SRFieldValue = String.valueOf(DyncObject.get(eachString));
                            }
                        }
                    }
                }
          }else if(ValueParseFlag){
                if(conditionSet.contains(eachString)){
                    condition=eachString;
                    ValueParseFlag=false;
                    FieldParseFlag=true;      
                }else{
                    valueName=eachString;
                    if(parseResult!=null){
                        lastParseResult=parseResult;
                    }
                    if(SRFieldValue==null){
                        SRFieldValue = 'null';
                    }
                    parseResult = parseEachCondition(SRFieldValue,operator,valueName); 
                    if(lastParseResult!=null){
                        parseResult = parseConditions(lastParseResult,parseResult,condition);
                    }
                }
          }
          system.debug('parseResult====>'+parseResult);
       }
       system.debug('final parseResult====>'+parseResult);
       return parseResult;
     }
     return false;
  }
  //method executes one condition and returns True/False
  public static boolean parseEachCondition(String SRVal,String oprtr,String conditionVal){
      system.debug('SRVal=>'+SRVal+', oprtr=>'+oprtr+', conditionVal=>'+conditionVal+';');
      boolean EachCondResult = false;
      if(oprtr=='='){
          if(SRVal==conditionVal){
              EachCondResult = true;
          }else{
              EachCondResult = false;
          }
      }else if(oprtr=='>='){
          if(integer.valueOf(SRVal)>=integer.valueOf(conditionVal)){
              EachCondResult = true;
          }else{
              EachCondResult = false;
          }
      }else if(oprtr=='<='){
          if(integer.valueOf(SRVal)<=integer.valueOf(conditionVal)){
              EachCondResult = true;
          }else{
              EachCondResult = false;
          }
      }else if(oprtr=='!='){
          if(SRVal!=conditionVal){
              EachCondResult = true;
          }else{
              EachCondResult = false;
          }
      }
      system.debug('EachCondResult==>('+ SRVal+' '+oprtr+' '+conditionVal+') = '+EachCondResult);
      return EachCondResult;
  }
  public static boolean parseConditions(Boolean lastConditionResult,Boolean conditionResult,String conditionStrng){
      system.debug('lastConditionResult==>'+lastConditionResult+' **conditionStrng** '+conditionStrng+' **conditionResult** '+conditionResult);
      if(conditionStrng=='AND'){
          return lastConditionResult && conditionResult;
      }else if(conditionStrng=='OR'){
          return lastConditionResult || conditionResult;
      }
      return false;
  }
  
  public static set<string> FetchObjectFields(string strFlowId,string strObjectName){
    set<string> setFields = new set<string>();
    if(strFlowId!=null && strFlowId!='' && strFlowId.length()==18)
      strFlowId = strFlowId.substring(0,15);
    map<string,string> mapUniqueFlds = new map<string,string>();
    if(strFlowId!=null && strFlowId!='' && strObjectName!=null && strObjectName!=''){
      //fields to be displayed 
      for(Section_Detail__c Fld:[select id,Name,Field_API_Name__c,Object_Name__c from Section_Detail__c where Section__r.Page__r.Page_Flow__c=:strFlowId and Object_Name__c=:strObjectName and Field_API_Name__c!=null and (Component_Type__c='Input Field' or Component_Type__c='Output Field')]){
        string strFldName = Fld.Field_API_Name__c;
        strFldName = strFldName.toLowerCase();
        if(mapUniqueFlds.get(strFldName)==null)
          setFields.add(Fld.Field_API_Name__c.toLowerCase());
      }
      // fields to be included conditions
      for(Page_Flow_Condition__c Condfld:[select id,Name,Field_Name__c,Object_Name__c from Page_Flow_Condition__c where Object_Name__c=:strObjectName and Flow_Id__c=:strFlowId and Field_Name__c!=null]){
        string strFldName = Condfld.Field_Name__c;
        strFldName = strFldName.toLowerCase();
        if(mapUniqueFlds.get(strFldName)==null)
          setFields.add(Condfld.Field_Name__c.toLowerCase());
      }
    }
    return setFields;
  }
}