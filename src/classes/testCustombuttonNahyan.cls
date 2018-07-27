global without sharing class testCustombuttonNahyan{
public string schoolId;
public string message {get;set;}
public void testCustomButton(){
schoolId  = apexpages.currentPage().getparameters().get('id');
message= 'hello world';
}
}