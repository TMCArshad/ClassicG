global without sharing class testCustomButton{
    
    public string schoolId;
    public string testing {get;set;}
    
    public void testCustomButton(){
        schoolId = apexpages.currentPage().getparameters().get('id');
        testing = 'Hello';
    }
}