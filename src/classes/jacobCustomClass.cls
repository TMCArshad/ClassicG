global without sharing class jacobCustomClass{
private string schoolId;
public string message {get;set;}
public void jacobCustomClass(){
schoolId=apexpages.Currentpage().getparameters().get('id');
message='Hello World';
}

}