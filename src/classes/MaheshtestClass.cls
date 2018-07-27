global without sharing class MaheshtestClass{
public string schoolId;
public string mymsg{get;set;}

    
    public void testCustomButton(){
        schoolId = apexpages.currentPage().getparameters().get('id');
        mymsg='Hello';
    }


}