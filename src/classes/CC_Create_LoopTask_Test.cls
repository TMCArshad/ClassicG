@isTest
private class CC_Create_LoopTask_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
	   /***/
	    List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		
		List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5,'Enrollment');
		List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);
		
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
		List<Group> queues  = GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList,users);
	   /***/
		
      Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
      HexaBPM__SR_Template__c objsrtemlate = new HexaBPM__SR_Template__c(name = 'New Registration');
         objsrtemlate.HexaBPM__Portal_Service_Request_Name__c = 'test';
         objsrtemlate.HexaBPM__Do_not_use_owner__c = false;
         
         objsrtemlate.HexaBPM__SR_RecordType_API_Name__c= 'General';
         objsrtemlate.ownerid = UserInfo.getUserId();
         insert objsrtemlate; 
         objsrtemlate.ownerid = UserInfo.getUserId();
         update objsrtemlate;
         
      HexaBPM__Step_Template__c ST = new HexaBPM__Step_Template__c(name = 'Registrar Review');
         ST.HexaBPM__DEV_Id__c = 'testdev';
         ST.HexaBPM__Code__c = 'REGISTRAR_REVIEW1';
         ST.HexaBPM__Step_RecordType_API_Name__c= 'General';
         ST.ownerid = UserInfo.getUserId();
      Insert ST;         
         
      HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        SR.HexaBPM__Customer__c  = a.Id;
      //SR.Sys_License_Application__c = l1.Id;
        SR.School__c = schoolList[0].Id;
        SR.HexaBPM__Email__c = 'test@nsigulf.com';
        SR.HexaBPM__Send_SMS_to_Mobile__c= '12123';
        insert SR;
         
      
         
       HexaBPM__Action__c Action = New HexaBPM__Action__c();
          Action.HexaBPM__Field_Value__c = '10.0';
          Action.HexaBPM__Action_Type__c = 'HexaBPM__Service_Request__c';
          //Action.HexaBPM__Step_Template__c = SRT.id;
          Action.HexaBPM__Field_Name__c = 'Agent_Name__c';
          Action.HexaBPM__Field_Type__c = 'TEXT';
          Action.HexaBPM__Value_or_Field__c = 'Value';
          insert Action;
          
       HexaBPM__Status__c status = new HexaBPM__Status__c();
            status.Name ='Awaiting Approval';
            status.HexaBPM__Code__c ='AWAITING_APPROVAL1';
            status.HexaBPM__DEV_Id__c ='567890';
            insert status;
                      
         HexaBPM__SR_Steps__c SRS = new HexaBPM__SR_Steps__c();
         SRS.HexaBPM__Step_No__c =10.0;
         SRS.HexaBPM__Step_Template__c = ST.id;
         SRS.HexaBPM__Start_Status__c = status.id;
         SRS.HexaBPM__SR_Template__c = objsrtemlate.Id;
         SRS.ownerid = UserInfo.getUserId(); 
         SRS.HexaBPM__SR_Template__c = objsrtemlate.id;
         SRS.HexaBPM__Do_not_use_owner__c = false;
         insert SRS;
         
        
         
         
     
        
         
       HexaBPM__Step__c St1 = new  HexaBPM__Step__c();
         st1.HexaBPM__Step_No__c =10.0;
         st1.HexaBPM__SR__c = SR.id;
         st1.HexaBPM__Step_Template__c = ST.id;
         
         st1.HexaBPM__Status__c = status.id;
         st1.HexaBPM__SR_Step__c = SRS.id;
         st1.HexaBPM__Sys_Step_Loop_No__c ='10.0_1';
         st1.HexaBPM__Step_Notes__c = 'test area';
         st1.ownerid = UserInfo.getUserId();
         insert St1;
         
          HexaBPM__Step__c St2 = new  HexaBPM__Step__c();
         st2.HexaBPM__Step_No__c =10.0;
         st2.HexaBPM__SR__c = SR.id;
         st2.HexaBPM__Step_Template__c = ST.id;
         st2.HexaBPM__Status__c = status.id;
         st2.HexaBPM__SR_Step__c = SRS.id;
         st2.HexaBPM__Sys_Step_Loop_No__c ='10.0_1';
         st2.HexaBPM__Step_Notes__c = 'test area';
         st2.ownerid = UserInfo.getUserId();
         insert St2;
         
         
       Contact con = new Contact();
         con.AccountId = a.Id;
         con.email = 'test@gmail.com';
         con.FirstName =  'Fname';
         con.LastName = 'LName';
         insert con;
        
       
        list<HexaBPM__Step__c> lstExistingSteps = new list<HexaBPM__Step__c>();
        lstExistingSteps.add(St1);
        map<string,Id> mapStepQueues =  new map<string,Id>();
        map<Id,string> mapStepTemplateQueues = new map<Id,string>();
        map<Id,string> mapSRStepQueues = new map<Id,string>();
        map<Id,string> mapSRTemplateQueues = new map<Id,String>();
            map<id,id> mapSROwner = new map<id,id>();
            map<id,string> mapUserLicense = new map<id,string>();
            map<string,Id> mapStepRecType = new map<string,Id>();
            list<HexaBPM__SR_Steps__c> lstSRSteps = new list<HexaBPM__SR_Steps__c>();
            String srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ', HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
            
    
    
  
            CC_Create_LoopTask LoopTask = new CC_Create_LoopTask();
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                      mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
                                
            SRS.OwnerId = queues[0].Id;                       
            update SRS;
      
            srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ',HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
            
            
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                        mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
            
            SRS.HexaBPM__Do_not_use_owner__c = true;                  
            SRS.OwnerId = queues[0].Id;                       
            update SRS;       
            
            srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ',HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
            
            
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                        mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
                                        
            SRS.HexaBPM__Do_not_use_owner__c = true;                  
            SRS.OwnerId = UserInfo.getUserId();                       
            update SRS;       
            
            srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ',HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
            
            
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                        mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
                                        
            SRS.HexaBPM__Do_not_use_owner__c = true;                  
            objsrtemlate.OwnerId = queues[0].Id;                       
             update objsrtemlate;       
            
            srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ',HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
            
            
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                        mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
                                
	}
	
	@isTest static void test_method_two() {
			// Implement test code
	   /***/
	    List<user> users = GEMS_ChangeTCCntlr_Test.createUsers('System Administrator');
		List<Product2> prodList = GEMS_ChangeTCCntlr_Test.createProducts(10,'REGISTRATION FEE');
		
		List<HexaBPM__SR_Template__c> SRTemplates = GEMS_ChangeTCCntlr_Test.createSRTemplateRecords(5,'Enrollment');
		List<HexaBPM__SR_Steps__c> SRSteps = GEMS_ChangeTCCntlr_Test.createSRSteps(SRTemplates);
		
		List<HexaBPM__SR_Status__c> SRStatusList = GEMS_ChangeTCCntlr_Test.createSRStatus();
		List<HexaBPM__Status__c> stepStatusList = GEMS_ChangeTCCntlr_Test.createStepStatus(); 
		List<School__c> schoolList = GEMS_ChangeTCCntlr_Test.createSchools(5);
		List<Employee__c> employees = GEMS_ChangeTCCntlr_Test.createEmployeesForSchools(schoolList);
		GEMS_ChangeTCCntlr_Test.createQueueConfig(schoolList);
		List<Group> queues  = GEMS_ChangeTCCntlr_Test.createQueuesForSchools(schoolList,users);
	   /***/
		
		
	
        
      Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
      HexaBPM__SR_Template__c objsrtemlate = new HexaBPM__SR_Template__c(name = 'New Registration');
         objsrtemlate.HexaBPM__Portal_Service_Request_Name__c = 'test';
         objsrtemlate.HexaBPM__Do_not_use_owner__c = false;
         
         objsrtemlate.HexaBPM__SR_RecordType_API_Name__c= 'General';
         objsrtemlate.ownerid = UserInfo.getUserId();
         insert objsrtemlate; 
         objsrtemlate.ownerid = UserInfo.getUserId();
         update objsrtemlate;
         
      HexaBPM__Step_Template__c ST = new HexaBPM__Step_Template__c(name = 'Registrar Review');
         ST.HexaBPM__DEV_Id__c = 'testdev';
         ST.HexaBPM__Code__c = 'REGISTRAR_REVIEW1';
         ST.HexaBPM__Step_RecordType_API_Name__c= 'General';
         ST.ownerid = UserInfo.getUserId();
      Insert ST;         
         
      HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        SR.HexaBPM__Customer__c  = a.Id;
      //SR.Sys_License_Application__c = l1.Id;
        SR.School__c = schoolList[0].Id;
        SR.HexaBPM__Email__c = 'test@nsigulf.com';
        SR.HexaBPM__Send_SMS_to_Mobile__c= '12123';
        insert SR;
         
      
         
       HexaBPM__Action__c Action = New HexaBPM__Action__c();
          Action.HexaBPM__Field_Value__c = '10.0';
          Action.HexaBPM__Action_Type__c = 'HexaBPM__Service_Request__c';
          //Action.HexaBPM__Step_Template__c = SRT.id;
          Action.HexaBPM__Field_Name__c = 'Agent_Name__c';
          Action.HexaBPM__Field_Type__c = 'TEXT';
          Action.HexaBPM__Value_or_Field__c = 'Value';
          insert Action;
          
       HexaBPM__Status__c status = new HexaBPM__Status__c();
            status.Name ='Awaiting Approval';
            status.HexaBPM__Code__c ='AWAITING_APPROVAL1';
            status.HexaBPM__DEV_Id__c ='567890';
            insert status;
                      
         HexaBPM__SR_Steps__c SRS = new HexaBPM__SR_Steps__c();
         SRS.HexaBPM__Step_No__c =10.0;
         SRS.HexaBPM__Step_Template__c = ST.id;
         SRS.HexaBPM__Start_Status__c = status.id;
         SRS.HexaBPM__SR_Template__c = objsrtemlate.Id;
         SRS.ownerid = UserInfo.getUserId(); 
         SRS.HexaBPM__SR_Template__c = objsrtemlate.id;
         SRS.HexaBPM__Do_not_use_owner__c = false;
         SRS.HexaBPM__Estimated_Hours__c  =100; 
         insert SRS;
         
        
         
         
     
        
         
       HexaBPM__Step__c St1 = new  HexaBPM__Step__c();
         st1.HexaBPM__Step_No__c =10.0;
         st1.HexaBPM__SR__c = SR.id;
         st1.HexaBPM__Step_Template__c = ST.id;
         
         st1.HexaBPM__Status__c = status.id;
         st1.HexaBPM__SR_Step__c = SRS.id;
         st1.HexaBPM__Sys_Step_Loop_No__c ='10.0_1';
         st1.HexaBPM__Step_Notes__c = 'test area';
         st1.ownerid = UserInfo.getUserId();
         insert St1;
         
          HexaBPM__Step__c St2 = new  HexaBPM__Step__c();
         st2.HexaBPM__Step_No__c =10.0;
         st2.HexaBPM__SR__c = SR.id;
         st2.HexaBPM__Step_Template__c = ST.id;
         st2.HexaBPM__Status__c = status.id;
         st2.HexaBPM__SR_Step__c = SRS.id;
         st2.HexaBPM__Sys_Step_Loop_No__c ='10.0_1';
         st2.HexaBPM__Step_Notes__c = 'test area';
         st2.ownerid = UserInfo.getUserId();
         insert St2;
         
         
       Contact con = new Contact();
         con.AccountId = a.Id;
         con.email = 'test@gmail.com';
         con.FirstName =  'Fname';
         con.LastName = 'LName';
         insert con;
        
       
        list<HexaBPM__Step__c> lstExistingSteps = new list<HexaBPM__Step__c>();
        lstExistingSteps.add(St1);
        map<string,Id> mapStepQueues =  new map<string,Id>();
        map<Id,string> mapStepTemplateQueues = new map<Id,string>();
        map<Id,string> mapSRStepQueues = new map<Id,string>();
        map<Id,string> mapSRTemplateQueues = new map<Id,String>();
            map<id,id> mapSROwner = new map<id,id>();
            map<id,string> mapUserLicense = new map<id,string>();
            map<string,Id> mapStepRecType = new map<string,Id>();
            list<HexaBPM__SR_Steps__c> lstSRSteps = new list<HexaBPM__SR_Steps__c>();
            
            
            SRS.HexaBPM__Do_not_use_owner__c = true; 
            objsrtemlate.HexaBPM__Do_not_use_owner__c = true;
            SRS.OwnerId = UserInfo.getUserId();                       
            update SRS;
            update objsrtemlate;  
            
            String srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ', HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c,HexaBPM__Step_Template__r.OwnerId FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
	       
	       
	       
	       CC_Create_LoopTask LoopTask = new CC_Create_LoopTask();
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                      mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
                                      
                                      SRS.HexaBPM__Do_not_use_owner__c = true; 
            objsrtemlate.HexaBPM__Do_not_use_owner__c = true;
            SRS.OwnerId = UserInfo.getUserId();  
            ST.OwnerId = queues[0].Id;
            update SRS;
            update objsrtemlate;  
            srsQuery = GEMS_Utility.getAllFields(HexaBPM__SR_Steps__c.getsObjectType().getdescribe());
            srsQuery = srsQuery.replace('FROM HexaBPM__SR_Steps__c', ', HexaBPM__SR_Template__r.HexaBPM__Do_not_use_owner__c,HexaBPM__SR_Template__r.OwnerId,HexaBPM__Step_Template__r.HexaBPM__Step_RecordType_API_Name__c,HexaBPM__Step_Template__r.OwnerId FROM HexaBPM__SR_Steps__c');
            lstSRSteps = Database.query(srsQuery);
	       
	       
	       
	        LoopTask = new CC_Create_LoopTask();
            LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                      mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
	}
	
}