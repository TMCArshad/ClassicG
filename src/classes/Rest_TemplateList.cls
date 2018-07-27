@RestResource(urlMapping='/Rest_TemplateList/*')
global without sharing class Rest_TemplateList{
  @HttpPost
  global static list<TemplateWrap> GetSRTemplates(string ImportType) {
      list<TemplateWrap> lstTemplateWrap = new list<TemplateWrap>();
      for(HexaBPM__SR_Template__c templ:[Select Id,Name,HexaBPM__SR_RecordType_API_Name__c,HexaBPM__Active__c from HexaBPM__SR_Template__c where HexaBPM__Active__c=true limit 100]){
          TemplateWrap objwrap = new TemplateWrap();
          objwrap.TemplateName = templ.Name;
          objwrap.TemplateCode = templ.HexaBPM__SR_RecordType_API_Name__c;
          objwrap.IsActive = templ.HexaBPM__Active__c;
          lstTemplateWrap.add(objWrap);
          
      }
      return lstTemplateWrap;
  }
  global class TemplateWrap{
      public string TemplateName;
      public string TemplateCode;
      public boolean IsActive;
  }
  
}