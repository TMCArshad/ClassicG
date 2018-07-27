global without sharing class Test_CheckCtlr {

public string schoolId;
  public string mymessage{get; set;}
  
  
public void Test_CheckCtlr()
    {
    schoolId=apexpages.currentpage().getparameters().get('id');
    mymessage='Hello SFDC'; 
    }
}