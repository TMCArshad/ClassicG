public without sharing class GEMS_Training2{


    public static void trainingMethod1(integer countStudents, list<string> trainLst){
    
        system.debug('list returned->'+trainLst);
        
        list<Account> accLst = new list<Account>();
        accLst = [SELECT id, name from Account];
    }
}