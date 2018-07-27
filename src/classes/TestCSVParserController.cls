public without sharing Class TestCSVParserController
{

public blob fileContent{get;set;}
public String fileName{get;set;}

public TestCSVParserController()
{
    
}

public void parseCSV()
{
    List<School__c> lSchool = new List<School__c>();
    List<List<String>> lls= new List<List<String>>();
    SSSCsvReader ssscsreder = new SSSCsvReader(fileContent.toString());
    lls = ssscsreder.parseBlob();
    
   
   for (integer i = 1; i < lls.size(); i++) 
   {
        School__c sch = new School__c();
        for (integer j = 0; j < lls[0].size(); j++) 
        {
           system.debug('$$$$ field '+lls[0][j]+' Value '+lls[i][j]);
           String fieldName = lls[0][j].toLowerCase();
           
           fieldName = fieldName.replace('\r\n', '');
           fieldName = fieldName.replace('\n', '');
           fieldName = fieldName.replace('\r', '');
          
           system.debug('@@@@@'+fieldName+'@@@@');
           String value = lls[i][j];
           Boolean checkField = Schema.getGlobalDescribe().get('School__c').getDescribe().fields.getMap().containsKey(fieldName);
           system.debug('$$$$$$$ checkField '+checkField);
           sch.put(fieldName,value);
        }
        
        system.debug('$$$$### Sch'+sch);
        lSchool.add(sch);
            
   }
   
   insert lSchool;
   
    
  
}


}