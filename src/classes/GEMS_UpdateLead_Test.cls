@isTest
private class GEMS_UpdateLead_Test {
	public static List<User> createUsers(String profileName) {
    List<User> User_List = new List<User>();
    Map<String, Id> profileMap = new Map<String, Id>();
    for (Profile p : [Select Id,Name from Profile]) {
      profileMap.put(p.Name, p.Id);
    }
    for (Integer i = 0; i <10; i++) {
      User user = new User(alias = 'test' + i, email = 'test' + i + '@noemail.com',
                           emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = profileMap.get(profileName) , country = 'United States', IsActive = true,
                           timezonesidkey = 'America/Los_Angeles', username = 'tester' + Integer.valueOf(math.rint(math.random()*1000000))+ i + '@noemail.com');
      User_List.add(user);
    }
    insert User_List;
    return User_List;
  }
  
	public static GEMS_Site_Domain_Config__c createSiteConfig(School__c schObj){
      GEMS_Site_Domain_Config__c	sc = new GEMS_Site_Domain_Config__c();
      sc.Name = schObj.Short_Name__c;
      sc.School_Code__c = schObj.ID__c;
      sc.Short_Form_Page_Name__c = 'enrol-online';
      sc.Site_Base_URL__c = 'http://test.aaq.lb.live.gems.zone-preview.co.uk/admissions/';
      sc.Thank_You_Page__c = 'thank-you';
      insert sc;
      return sc; 

    }
    
    public static void createQueuesForSchools(List<School__c> schools,List<user> users){
       List<String> sObjectTypeList = new List<String>{'HexaBPM__Service_Request__c','Lead','HexaBPM__SR_Steps__c','HexaBPM__Step__c'};
    	List<Group> queuelist = new List<Group>();
    	List<QueueSobject> sObjectList = new List<QueueSobject>();
    	QueueSobject sObj;
    	Group groupObj;
    	for(School__c s : schools){
          groupObj = new Group();
          groupObj.type = 'Queue';
          //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
          groupObj.Name = s.Short_Name__c + '-Registrar';
          queuelist.add(groupObj);
    	}
    	
    	groupObj = new Group();
        groupObj.type = 'Queue';
        //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
        groupObj.Name = 'GEMS Central Enrollment Officer';
        queuelist.add(groupObj);
    	
    	insert queuelist;
    	
    	System.runAs(users[0]){
    	for(Group queueObj : queuelist){
    	    for(String objType : sObjectTypeList){
    	        sObj =  new QueueSobject();
    	        sObj.QueueId = queueObj.Id;
    	        sObj.SobjectType = objType;
    	        sObjectList.add(sObj);
    	    }
    	}
    	insert sObjectList;
    	}

    }
    public static void createQueueConfig(List<School__c> schoolList){
      List<GEMS_Queue_Config__c> registrarConfig = new List<GEMS_Queue_Config__c>();
      GEMS_Queue_Config__c cs;
      for(School__c s : schoolList){
      	System.debug('==>'+s);
      	  cs= new GEMS_Queue_Config__c();
          cs.Name =  s.Short_Name__c + '-Registrar';
          cs.Queue_Type__c = 'Registrar';
          cs.Queue_Name__c = s.Short_Name__c + '_Registrar';
          cs.School_Code__c = s.Short_Name__c;
          cs.School_Name__c = s.Name;
          registrarConfig.add(cs);
      }
      
      insert registrarConfig;
      cs = new GEMS_Queue_Config__c();
      cs.Name = 'GEMS Central Enrollment Officer';
      cs.Queue_Type__c = 'Registrar';
      cs.Queue_Name__c = 'GEMS_Central_Enrollment_Officer';
      cs.School_Code__c = 'GEMS Central Enrollment Officer';
      cs.School_Name__c = 'GEMS Central Enrollment Officer';
      insert cs;
      
      
   } 
    public static void createLeadEnquirySyncConfig(){
     Map<String,String> apiNameMap = new Map<String,String>
                                     {'lastName'=>'LastName__c',
                                      'MobilePhone'=>'mobilePhone__c',
                                      'leadSource'=>'leadSource__c',
                                      'status'=>'status__c',
                                      'Tour_Date__c' => 'Tour_Date__c'
                                     };

     Lead_Enquiry_Sync__c cs ;
     List<Lead_Enquiry_Sync__c> csList = new List<Lead_Enquiry_Sync__c>();
     for(String leadField: apiNameMap.keySet()){ 
           cs = new Lead_Enquiry_Sync__c();
     	   cs.Name = leadField;
           cs.Enquiry_API_Name__c  = apiNameMap.get(leadField);
           cs.Lead_API_Name__c = leadField;    
           csList.add(cs);

     }
     System.debug('==>'+csList);
     insert csList;
     
    }
	public static List<School__c> createSchools(Integer n ){
    	List<School__c> schoolList = new List<School__c>();
    	School__c schObj;
    	for(Integer i =0 ; i<n;i++){
    		schObj = new School__c();
    		schObj.Name = 'SCHOOL_'+i;
    		schObj.Short_Name__c = 'SN'+i;
    		schObj.ID__c = '11111'+i;
    		schObj.Active__c = true;
    		schoolList.add(schObj);
    	}
    	insert schoolList;
    	return schoolList;
    }

    public static List<Lead> createLeads(School__c school){
        List<lead> leadList =  new List<Lead>();
        Lead leadObj ;
        for(Integer i=0;i<10;i++){
         leadObj = new Lead();
         leadObj.lastName = 'Last Name'+ i;
         leadObj.mobilePhone = '+97155525165'+i;
         leadObj.Email = 'lead'+i+'@gemseducation.com';
         leadObj.leadSource ='Email';
         leadObj.Status = 'New';
         leadObj.Lead_Reference__c = GEMS_Utility.generateLeadRefNumber();
         if(i<5){
         leadObj.SchoolLookup__c  = school.Id;
         }
         leadList.add(leadObj);



        }
       insert leadList;
       return leadList;
    }
	@isTest static void test_method_one() {
		// Implement test code
		
	 List<user> users = createUsers('System Administrator');
     List<School__c> schoolList = createSchools(5);
     createQueuesForSchools(schoolList,users);
     createQueueConfig(schoolList);
     GEMS_Site_Domain_Config__c sc = createSiteConfig(schoolList[0]);
	 createLeadEnquirySyncConfig();
	 List<Lead> LeadList = createLeads(schoolList[0]);
	 
	 Test.startTest();
	 GEMS_UpdateLead.acceptLead(LeadList[0].Id);
	 GEMS_UpdateLead.acceptLead('errorId');
	 
	 
	 Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}