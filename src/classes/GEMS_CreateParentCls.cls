public without sharing class GEMS_CreateParentCls {
    public Relationship__c rel{get;set;}
    public string SubjectAccountId{get;set;}
    public boolean CreateSiblings{get;set;}
    public GEMS_CreateParentCls(){
        rel = new Relationship__c();
        CreateSiblings = true;
        if(apexpages.currentPage().getParameters().get('Id')!=null)
            SubjectAccountId = apexpages.currentPage().getParameters().get('Id');
    }
    public pagereference SaveDetails(){
        Pagereference pg;
        if(SubjectAccountId!=null){
            if(rel.Type__c==null || (rel.Type__c!=null && rel.Type__c=='')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Relationship.'));
                return null;
            }else if(rel.Type__c=='Guardian'){
                list<Relationship__c> lstRel = [Select Id from Relationship__c where Subject_Account__c=:SubjectAccountId and Active__c=true and Type__c='Guardian'];
                if(lstRel!=null && lstRel.size()>=2){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Not more than two Gaurdians allowed.'));
                    return null;
                }
            }else{
                list<Relationship__c> lstRel = [Select Id from Relationship__c where Subject_Account__c=:SubjectAccountId and Active__c=true and Type__c=:rel.Type__c];
                if(lstRel!=null && lstRel.size()>=1){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Only one '+rel.Type__c+' allowed.'));
                    return null;
                }
            }
            try{
	            Account acc = new Account();
	            for(Account Student:[Select Id,Sibling_ID__c,School__c from Account where Id=:SubjectAccountId]){
	                acc.Master_Student__c = Student.Sibling_ID__c;
	                acc.School__c = Student.School__c;
	            }
	            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent/Guardian').getRecordTypeId();
	            acc.FirstName = rel.First_Name__c;
	            acc.LastName = rel.Last_Name__c;
	            acc.PersonEmail = rel.Email__c;
	            acc.Role__c = rel.Type__c;
	            acc.PersonMobilePhone = rel.Mobile__c;
	            insert acc;
	            
	            rel.Subject_Account__c = SubjectAccountId;
	            rel.Object_Account__c = acc.Id;
	            rel.Active__c = true;
	            rel.Created_From__c = 'Create Parent Button';
	            insert rel; 
	            
	            if(CreateSiblings){
		            list<Relationship__c> lstRelSiblings = new list<Relationship__c>();
		            for(Account Sibling:[Select Id,Sibling_ID__c,School__c from Account where Id!=:SubjectAccountId and Sibling_ID__c=:acc.Master_Student__c and (Recordtype.DeveloperName='Student' or Recordtype.DeveloperName='Student_Read_Only')]){
		                Relationship__c objrel = new Relationship__c();
		                objrel.Subject_Account__c = Sibling.Id;
		                objrel.Object_Account__c = acc.Id;
		            	objrel.Active__c = true;
		            	objrel.Type__c = rel.Type__c;
		            	objrel.First_Name__c = rel.First_Name__c;
		            	objrel.Last_Name__c = rel.Last_Name__c;
		            	objrel.Email__c = rel.Email__c;
		            	objrel.Mobile__c = rel.Mobile__c;
		            	objrel.Created_From__c = 'Create Parent Button';
		            	lstRelSiblings.add(objrel);
		            }
		            if(lstRelSiblings.size()>0)
		            	insert lstRelSiblings;
	            }
            }catch(Exception e){
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
            
            pg = new Pagereference('/'+SubjectAccountId);
            pg.setredirect(true);
        }
        return pg;
    }
    public pagereference CancelDetails(){
        Pagereference pg = new Pagereference('/'+SubjectAccountId);
        pg.setredirect(true);
        return pg;
    }
}