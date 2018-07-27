global without sharing Class rajeshCustomButtonClass{

public string SchoolId;
public string message {get;set;}

public void rajeshCustomButtonClass()
{

SchoolId=apexpages.currentpage().getparameters().get('id');
message ='Hello';

}

}