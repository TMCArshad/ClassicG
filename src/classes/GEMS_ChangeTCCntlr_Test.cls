@isTest
public class GEMS_ChangeTCCntlr_Test {
		public static List<User> createUsers(String profileName) {
    List<User> User_List = new List<User>();
    Map<String, Id> profileMap = new Map<String, Id>();
    for (Profile p : [Select Id,Name from Profile]) {
      profileMap.put(p.Name, p.Id);
    }
    for (Integer i = 0; i <10; i++) {
      User user = new User(alias = 'test' + i, email = 'test' + i + '@noemail.com',Employee_Number__c = Integer.valueOf(math.rint(math.random()*1000000))+ i, 
                           emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                           localesidkey = 'en_US', profileid = profileMap.get(profileName) , country = 'United States', IsActive = true,
                           timezonesidkey = 'America/Los_Angeles', username = 'tester' + Integer.valueOf(math.rint(math.random()*1000000))+ i + '@noemail.com');
      User_List.add(user);
    }
    insert User_List;
    return User_List;
  }
  
 
    
    public static List<Group> createQueuesForSchools(List<School__c> schools,List<user> users){
       List<String> sObjectTypeList = new List<String>{'HexaBPM__Service_Request__c','Lead','HexaBPM__SR_Steps__c','HexaBPM__Step__c','HexaBPM__SR_Steps__c','HexaBPM__SR_Template__c','HexaBPM__Step_Template__c'};
    	List<Group> queuelist = new List<Group>();
    	List<QueueSobject> sObjectList = new List<QueueSobject>();
    	List<GroupMember> groupMembers = new List<GroupMember>();
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
        
        groupObj = new Group();
        groupObj.type = 'Queue';
        //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
        groupObj.Name = 'Parent Relations Officer';
        queuelist.add(groupObj);
        
        groupObj = new Group();
        groupObj.type = 'Queue';
        //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
        groupObj.Name = 'GEMS Corporate Office';
        queuelist.add(groupObj);
    	
    	groupObj = new Group();
        groupObj.type = 'Queue';
        //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
        groupObj.Name = 'Registrar';
        queuelist.add(groupObj);
    
     	groupObj = new Group();
        groupObj.type = 'Queue';
        //groupObj.SobjectType = 'HexaBPM__Service_Request__c';
        groupObj.Name = 'Registrar2';
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
    	
    	 GroupMember gm ;
    for(Group queueObj : queuelist){
        gm = new GroupMember();
        gm.GroupId = queueObj.Id;
        gm.UserOrGroupId = UserInfo.getUserId();
        groupMembers.adD(gm);
        
    }
    insert groupMembers;
   
    	}
    return queuelist;  
    
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
	
	public static  GEMS_Site_Domain_Config__c createSiteConfig(School__c schObj){
      GEMS_Site_Domain_Config__c	sc = new GEMS_Site_Domain_Config__c();
      sc.Name = schObj.Short_Name__c;
      sc.School_Code__c = schObj.ID__c;
      
      sc.Short_Form_Page_Name__c = 'enrol-online';
      sc.Site_Base_URL__c = 'http://test.aaq.lb.live.gems.zone-preview.co.uk/admissions/';
      sc.Thank_You_Page__c = 'thank-you';
      insert sc;
      return sc;

    } 
    public static void createLeadEnquirySyncConfig(){
     Map<String,String> apiNameMap = new Map<String,String>
                                     {'lastName'=>'LastName__c',
                                      'MobilePhone'=>'mobilePhone__c',
                                      'leadSource'=>'leadSource__c',
                                      'status'=>'status__c'};

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
    
    public static List<HexaBPM__Status__c> createStepStatus(){
    Map<String,String> statusMap = new Map<String,String>
                                     {'Awaiting Verification'=>'AWAITING_VERIFICATIOn',
                                      'Awaiting Clearance'=>'AWAITING_CLEARANCE',
                                      'Verified'=>'VERIFIED',
                                      'Rejected'=>'REJECTED',
                                      'Cancelled' => 'CANCELLED',
                                      'Student Retained' => 'STUDENT_RETAINED',
                                      'Student Not Retained'=>'STUDENT_NOT_RETAINED'
                                     };
   Map<String,String> typeMap = new Map<String,String>
                                     {'Awaiting Verification'=>'Start',
                                      'Awaiting Clearance'=>'Start',
                                      'Verified'=>'End',
                                      'Rejected'=>'End',
                                      'Student Retained' => 'End',
                                      'Student Not Retained'=>'End'
                                     };
    HexaBPM__Status__c  status ;
    List<HexaBPM__Status__c> statusList =  new List<HexaBPM__Status__c>();
    for(String s :  statusMap.keySet()){
        status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = typeMap.get(s);
        status.HexaBPM__Code__c  = statusMap.get(s);
        status.Name = s;
        statusList.add(status);
    }
        insert statusList;
        return statusList;
    }
    
    public static List<HexaBPM__SR_Status__c> createSRStatus(){
    Map<String,String> statusMap = new Map<String,String>
                                     {'Draft'=>'DRAFT',
                                      'Submitted'=>'SUBMITTED',
                                      'Registered'=>'REGISTERED',
                                      'Closed'=>'CLOSED',
                                       'Reverse Cancel Admission' => 'REVERSE_CANCEL_ADMISSION_APPROVED',
                                       'Closed'=>'CLOSED',
                                       'Cancelled' => 'CANCELLED'
                                     };	
      List<HexaBPM__SR_Status__c>  statusList = new List<HexaBPM__SR_Status__c>();
      HexaBPM__SR_Status__c status ;
      for(String s :  statusMap.keySet()){
      	status =  new HexaBPM__SR_Status__c();
      	status.HexaBPM__Code__c =statusMap.get(s);
      	status.Name = s;
      	statusList.add(status);
      }                     
      insert statusList;
      return statusList;
    }
    
    public static  List<School__c> createSchools(Integer n ){
        
    	List<School__c> schoolList = new List<School__c>();
    	School__c schObj;
    	 Schema.DescribeFieldResult fieldResult =
         Lead.School_picklist__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    	
    	for(Integer i =0 ; i<n;i++){
    		schObj = new School__c();
    		schObj.Gender__c = 'Both';
    		schObj.Name = ple[i].getValue();
    		schObj.Short_Name__c = 'SN'+i;
    		schObj.ID__c = '11111'+i;
    		schObj.Sys_Last_Receipt_No__c = '000000000';
    		schObj.Lab_Email__c = 'lab@lab.com';
    		schObj.Finance_Officer_Email__c = 'finance@finance.com';
    		schObj.Library_Email__c  = 'lib@lib.com';
    		schObj.Registrar__c = UserInfo.getUserId();
    		schObj.STS_Email__c = 'sts@sts.com';
    		schObj.Principals_PA_Email__c = 'pa@pa.com';
    		schObj.active__c = true;
    		schoolList.add(schObj);
    	}
    	insert schoolList;
    	return schoolList;
    }
    public static List<Employee__c> createEmployeesForSchools(List<School__c> schools){
        Employee__c emp;
        List<Employee__c> empList = new List<Employee__c>();
        for(School__c sch : schools ){
             for(Integer i = 0;i<5;i++){
                 emp = new Employee__c();
                 emp.First_Name__c = sch.Short_Name__c + i + 'FN';
                 emp.last_Name__c= sch.Short_Name__c + 'i' + 'LN';
                 emp.School__c = sch.id;
                 emp.Email__c = sch.Short_Name__c + i + '@test.com'; 
                 empList.add(emp);
             }
        }
        insert empList;
        return empList;
    }
    public static  List<Lead> createLeads(School__c school){
        List<lead> leadList =  new List<Lead>();
        Lead leadObj ;
        
         Schema.DescribeFieldResult schoolPL =
         Lead.School_picklist__c.getDescribe();
         List<Schema.PicklistEntry> ple = schoolPL.getPicklistValues();
        
        Schema.DescribeFieldResult companyPL =
         Lead.Parent_Company__c.getDescribe();
         List<Schema.PicklistEntry> ple1 = companyPL.getPicklistValues();
         
        for(Integer i=0;i<10;i++){
         leadObj = new Lead();
         leadObj.School_picklist__c = ple[i].getValue();
         leadObj.lastName = 'Last Name'+ i;
         leadObj.mobilePhone = '+97155525165'+i;
         leadObj.Email = 'lead'+i+'@gemseducation.com';
         leadObj.leadSource ='Non-Digital';
         leadObj.Status = 'New';
         leadObj.Lead_Reference__c = GEMS_Utility.generateLeadRefNumber();
         leadObj.SchoolLookup__c  = school.Id;
         leadObj.has_sibling_in_GEMS__c = false;
         leadObj.Date_Of_Birth__c = System.Today().addYears(-10);
         leadObj.Parent_Company__c = ple1[i].getValue(); 
         leadList.add(leadObj);



        }
        insert leadList;
       return leadList;
    }  
     public static   List<Lead> updateLeadRef(List<Lead> lead_List){
     
    String leadRef =  lead_List[0].Lead_Reference__c;
    List<Lead> leadUpdateList = new List<Lead>();
    for(Lead l : Lead_List){
    	l.Lead_Reference__c = leadRef;
    	leadUpdateList.add(l);
    }
    update leadUpdateList;
    return leadUpdateList;
    	
    }
    
   public static List<Account> createStudents(){
       
      Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(Account.getsObjectType()).get('Student');
      Account objStudent;
      Grade__c g = new Grade__c();
      Section_Master__c sm = new Section_Master__c();
        //Get School information
        for(Grade__c gradeObj : [SELECT Id, Academic_Year__c,Academic_Year__r.School__c,Stream__c,Academic_Year__r.Curriculum__c FROM Grade__c LIMIT 1]){
            g= gradeObj;
        }
        for(Section_Master__c smObj : [SELECT Id,Grade__c,Grade__r.Academic_Year__c,Grade__r.Academic_Year__r.School__c,grade__r.Stream__c,Grade__r.Academic_Year__r.Curriculum__c From Section_Master__c LIMIT 1]){
          sm = smObj;
        }
       System.debug('createStudents Section Record==>'+sm.grade__r.Academic_Year__r.School__c); 
      List<Account> studentList = new List<Account>();
      for(Integer i=0;i<10;i++){
        objStudent = new Account(); 
        objStudent.lastName = 'Student' + i; 
        objStudent.Student_Id__c = '1210130006387' + i;
        objStudent.RecordTypeId = recTypeID;
        objStudent.school__c = sm.grade__r.Academic_Year__r.School__c;
    	objStudent.academic_year__c =sm.grade__r.Academic_Year__c;
    	objStudent.gradeLookup__c = sm.grade__c;
    	objStudent.current_Status__c = 'EN';
    	objStudent.Section__c = sm.id;
    	objStudent.stream__c = sm.grade__r.Stream__c;
    	objStudent.curriculum__c = sm.grade__r.Academic_Year__r.Curriculum__c;
    	objStudent.Is_primary_contact_employee_of_GEMS__c = 'Yes';
		objStudent.Primary_Contact__c = 'Mother';
		objStudent.Primary_Contact_Email__c = 'mother@mother.com';
		objStudent.Country__c = '172';
        studentList.add(objStudent); 
      }
     insert studentList;
     return studentList;
        
   }    
   
      public Static  List<HexaBPM__Service_Request__c> createSRForLead(List<Lead> lead_List,
                                                                      List<Account> students,
                                                                    School__c school,String RTName){
                                                                        
                                                                        
    	Id recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get(RTName);
        HexaBPM__Service_Request__c SR;
        Grade__c g = new Grade__c();
        Section_Master__c smObj =  new Section_Master__c();
        //Get School information
        
        for(Grade__c gradeObj : [SELECT Id, Academic_Year__c,Academic_Year__r.School__c,Stream__c,Academic_Year__r.Curriculum__c FROM Grade__c LIMIT 1]){
            g= gradeObj;
        }
        id schoolId = students[0].School__c;
        for(Section_Master__c sm :  [Select id,Grade__c,grade__r.Academic_Year__c,Grade__r.Academic_Year__r.School__c,Grade__r.Stream__c,grade__r.Academic_Year__r.Curriculum__c from Section_Master__c where Grade__r.Academic_Year__r.School__c = :schoolId  limit 1]){
            smObj =sm;
        }
        
        
        List<HexaBPM__Service_Request__c> SR_List = new List<HexaBPM__Service_Request__c>();
        Integer i = 0;
        for(Lead l :  lead_List){
        	SR = new HexaBPM__Service_Request__c();
        	SR.RecordTypeId = recTypeID;
        	SR.Lead__c = l.Id;
        	SR.Lead_Reference__c = l.Lead_Reference__c;
        	SR.School__c = smObj.Grade__r.Academic_Year__r.School__c;
        	SR.Academic_Year__c = smObj.Grade__r.Academic_Year__c;
        	SR.GradeLookup__c = smObj.Grade__c;
        	SR.Stream__c =  smObj.Grade__r.Stream__c;
        	SR.Curriculum__c = smObj.Grade__r.Academic_Year__r.Curriculum__c;
        	SR.Student__c = students[0].Id;
        	SR.HexaBPM__Customer__c = SR.Student__c;
        	SR.Payment_Status__c = 'Payment Pending';
            SR.HexaBPM__Email__c = 'hexabpm@hexabpm.com';  
        	SR_List.add(SR);
        	
        }
        insert SR_List;
        return SR_List;
    }  
 public static List<HexaBPM__Step__c>  createStepsForSR(List<HexaBPM__Service_Request__c> SR_List){
        
        
        List<HexaBPM__Status__c> statusList = [Select Id,HexaBPM__Code__c,Name from HexaBPM__Status__c];
	    HexaBPM__Step__c stp ;
	    List<HexaBPM__Step__c> stepList = new List<HexaBPM__Step__c>();
	    Integer i = 0;
	    for(HexaBPM__Service_Request__c srObj : SR_List ){
	        
	        stp = new HexaBPM__Step__c();
	        stp.HexaBPM__Step_No__c = i;
	        stp.HexaBPM__SR__c  = srObj.Id;
	        stp.HexaBPM__Status__c = statusList[0].Id;
	        stepList.add(stp);
	    }
	    insert stepList;
	    return stepList;
	    
	}
	 public static List<HexaBPM__Pricing_Line__c> createPricingLines(List<Product2> prodList){
    	List<HexaBPM__Pricing_Line__c> plList = new List<HexaBPM__Pricing_Line__c>();
    	HexaBPM__Pricing_Line__c pl;
    	for(Product2 p : prodList){
    		pl = new HexaBPM__Pricing_Line__c();
    		pl.HexaBPM__Product__c = p.Id;
    		pl.HexaBPM__Priority__c = 1;
    		plList.add(pl);
    	}
    	insert plList;
    	return plList;
    }
    public static List<Product2> createProducts(Integer n,String typeVal){
    	List<Product2> prodList =  new List<Product2>();
    	Product2 p ;
    	for(Integer i=1;i<=n;i++){
    		p = new Product2();
    		p.Name = typeVal;
    		p.isActive = true;
    	    p.Fee_Id__c = i;
    		prodList.add(p); 
    	}
    	insert prodList;
    	return prodList;
    }

    public static List<Academic_year__c>  createsAYs(Integer n,School__c school){
    	List<Academic_year__c> AYList = new List<Academic_year__c>();
    	Academic_year__c Ay ;
    	for(Integer i =0;i<n;i++){
    		Ay = new Academic_year__c();
    		AY.Year__c = '27';
	    	AY.ACD_ID__c = 1234;
	    	AY.Active__c = true;
	    	AY.Sys_Active__c = true;
	    	AY.Curriculum__c = '1';
	    	AY.School__c = school.Id;
	    	AY.Start_date__c = System.Today().addDays(-90);
	    	AY.End_Date__c = System.Today().addDays(90);
	    	AYList.add(AY);
    	}
    	try{
    	insert AYList;
    	}catch(Exception e)
    	{
    	    System.debug('Error occured when creating AY Records.');
    	    System.debug('==>'+e.getMessage());
    	}
    	return AYList;
    }
    
    public static List<Grade__c> createGrades(School__c school,List<Academic_year__c> AYList){
    	List<Grade__c> gradeList = new List<Grade__c>();
    	Grade__c grade ; 
    	for(Academic_year__c Ay : AYList){
    		grade = new Grade__c();
    		grade.GRM_ID__c = 1234;
	    	grade.School__c = school.Id;
	    	grade.Active__c = true;
	    	grade.Minimum_Age__c = 0;
	    	grade.Maximum_Age__c = 10;
	    	grade.Open_Online_Payment__c = 'Yes';
	    	grade.Academic_Year__c = AY.Id;
	    	grade.Age_Cut_off_Date__c = System.Today();
	    	grade.Grade_Display__c = '01';
	    	grade.Grade__c = '1';
	    	grade.Stream__c = '1';
	    	grade.Age_Cut_Off_Date__c  = System.Today();  
	    	gradeList.add(grade);
    	}
    	try{
    	insert gradeList;
    	}
    	catch(Exception e)
    	{
    	    System.debug('Error occured when creating Grade Records.');
    	    System.debug('==>'+e.getMessage());
    	}
    	return gradeList;
    }
    public static Integer randomWithLimit(Integer upperLimit){
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    }
    public static List<Section_Master__c> createSectionsForGrades(List<Grade__c> grades){
        Section_Master__c smObj ;
        List<String> sectionVals = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S'};
        List<Section_Master__c> smList = new List<Section_Master__c>();
        for(Grade__c gradeObj  : grades ){
            smObj = new Section_Master__c();
            smObj.Grade__c = gradeObj.id;
            smObj.School__c =  gradeObj.School__c;
            smObj.Academic_Year__c = gradeObj.Academic_Year__c;
            smObj.Section__c = sectionVals[randomWithLimit(17)];
            smList.add(smObj);
        }
        try{
        insert smList;
        }
        catch(Exception e)
    	{
    	    System.debug('Error occured when creating Section Records.');
    	    System.debug('==>'+e.getMessage());
    	}
        return smList;
        
        
    }
    
    public static List<Amount__c> createAmounts(List<Product2>pList){
    	Map<String,Id> statusMap = new Map<String,Id>();
    	for(HexaBPM__SR_Status__c st:[SELECT Id,Name,HexaBPM__Code__c FROM HexaBPM__SR_Status__c] ){
    		statusMap.put(st.Name,St.id);
    	}
    	Map<Id,Grade__c> gradeMap = new Map<Id,Grade__c>();
    
    	for(Grade__c g : [SELECT Id, Academic_Year__c,Grade__c,Academic_Year__r.School__c,School__c,Stream__c,Academic_Year__r.Curriculum__c,Grade_Display__c FROM Grade__c ] ){
    	    gradeMap.put(g.Id,g);
    	}
    	
    	
    	List<Amount__c> amountList = new List<Amount__c>();
    	Amount__c amount;
    	
    	Integer i = 0;
    	for(Grade__c gradeObj  : gradeMap.values()){
	    	amount = new Amount__c();
	        amount.Academic_Year__c = gradeObj.Academic_Year__c; 
	        amount.Amount__c = 100 + i;
	        amount.Fee_Master__c = pList[i].Id;
	        amount.School__c = 	gradeObj.Academic_Year__r.School__c;
	        amount.Stream__c = gradeObj.Stream__c;
	        amount.Grade__c = gradeObj.Grade__c;
	        amount.Stage_Lookup__c = statusMap.get('Registered');
	        amountList.add(amount);
        i++;
    	}
    	
    	insert amountList;
    	return amountList;
    }
    
    

    public static List<HexaBPM__SR_Price_Item__c> createPriceitems(List<HexaBPM__Service_Request__c> SR_List,List<Product2> prodList,List<HexaBPM__Pricing_Line__c> plList){
    	List<HexaBPM__SR_Price_Item__c> piList = new List<HexaBPM__SR_Price_Item__c>();
    	HexaBPM__SR_Price_Item__c pi ;
    	Integer i =0;
    	for(HexaBPM__Service_Request__c srObj : SR_List){
    		pi = new HexaBPM__SR_Price_Item__c();
    		pi.HexaBPM__ServiceRequest__c  = srObj.Id;
    		pi.HexaBPM__Product__c =  prodList[i].Id;
    		pi.Product__c = prodList[i].Id;
    		pi.HexaBPM__Pricing_Line__c = plList[i].Id;
    		pi.Open_Online_Payment__c = 'No';
    		pi.HexaBPM__Cost__c = 100;
    		pi.Status__c = 'Added';
    		pi.HexaBPM__Price_in_USD__c = 100;
    		piList.add(pi);
    		i++;
    	}
    	insert piList;
    	return piList;
    	
    }
	 public static List<HexaBPM__SR_Template__c> createSRTemplateRecords(Integer n, String RTAPI_Name) {
    List<HexaBPM__SR_Template__c> SRTemplate_List = new List<HexaBPM__SR_Template__c>();
    HexaBPM__SR_Template__c SRTemplate; 
    for (Integer i = 0; i < n; i++) {
      SRTemplate = new HexaBPM__SR_Template__c();
      SRTemplate.Name = 'SR Template Name_' + i;
      SRTemplate.HexaBPM__Active__c = true;
      SRTemplate.HexaBPM__SR_RecordType_API_Name__c = RTAPI_Name ;
      SRTemplate_List.add(SRTemplate);
    }
    insert SRTemplate_List;
    return SRTemplate_List;
  }

  public static List<HexaBPM__SR_Steps__c> createSRSteps(List<HexaBPM__SR_Template__c> SRTrmplate_List) {
    List<HexaBPM__SR_Steps__c> SRStep_List =  new List<HexaBPM__SR_Steps__c>();
    HexaBPM__SR_Steps__c SRStep ; 
    for (HexaBPM__SR_Template__c SRTemplate : SRTrmplate_List) {
      SRStep = new HexaBPM__SR_Steps__c();
      SRStep.HexaBPM__SR_Template__c = SRTemplate.Id; 
      SRStep_List.add(SRStep);

    }
    insert SRStep_List;
    return SRStep_List;

  }
  
  public static void createCompanyRecords(List<Lead> leadList){
         Company__c cmp ;
         List<Company__c> compList = new List<Company__c>();
         Schema.DescribeFieldResult companyPL =
         Lead.Parent_Company__c.getDescribe();
         List<Schema.PicklistEntry> ple1 = companyPL.getPicklistValues();
         Integer i = 0;
         for(Lead l : LeadList){
             cmp = new Company__c();
             cmp.Name  = ple1[i].getLabel();
             cmp.Id__c = Decimal.valueOf(ple1[i].getvalue());
             cmp.Country__c = '172';
             compList.add(cmp);
             i++;
         }
         insert compList;
      
  }
	@isTest static void test_method1() { 
		// Implement test code
		List<Product2> prodList = createProducts(10,'REGISTRATION FEE');
		List<HexaBPM__SR_Status__c> SRStatusList = createSRStatus();
		List<School__c> schoolList = createSchools(5);
		List<Academic_Year__c> academicYears = createsAYs(10,schoolList[0]);
		List<Grade__c> grades = createGrades(schoolList[0],academicYears);
		List<Amount__c> amounts = createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = createSiteConfig(schoolList[0]);
		createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = createPricingLines(prodList);
		List<Lead> LeadList = createLeads(schoolList[0]);
		LeadList = updateLeadRef(LeadList);
		
		List<Account> students = createStudents();
        List<HexaBPM__Service_Request__c> SR_List = createSRForLead(LeadList,students,schoolList[0],'TC_Request');
        List<HexaBPM__SR_Price_Item__c> piList =  createPriceitems(SR_List,prodList,plList);
		
		
		
		Test.startTest();
		    
            
			Test.setCurrentPageReference(new PageReference('Page.GEMS_ChangeTCPage')); 
            System.currentPageReference().getParameters().put('Id',SR_List[0].Id );
            System.currentPageReference().getParameters().put('reqType','Change_TC');
            
            ApexPages.StandardController stdCntlr = new ApexPages.StandardController(SR_List[0]);
            GEMS_ChangeTCCntlr obj = new GEMS_ChangeTCCntlr(stdCntlr);
            
            obj.updateSR();
            
            SR_List[0].Transfer_Reason__c =  'Our concerns were not addressed'; 
            SR_List[0].Transferring_to__c = 'A school in the same emirate';
        	SR_List[0].Transferring_to_Change__c = 'A school in a different emirate';
        	update SR_List[0];
        	
            ApexPages.StandardController stdCntlr1 = new ApexPages.StandardController(SR_List[0]);
            GEMS_ChangeTCCntlr obj1 = new GEMS_ChangeTCCntlr(stdCntlr1);
            
            obj1.updateSR();
            
		Test.stopTest();
		
	}
	
	@isTest static void test_method2() {
		// Implement test code
			// Implement test code
		List<Product2> prodList = createProducts(10,'REGISTRATION FEE');
		List<HexaBPM__SR_Status__c> SRStatusList = createSRStatus();
		List<School__c> schoolList = createSchools(5);
		List<Academic_Year__c> academicYears = createsAYs(10,schoolList[0]);
		List<Grade__c> grades = createGrades(schoolList[0],academicYears);
		List<Amount__c> amounts = createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = createSiteConfig(schoolList[0]);
		createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = createPricingLines(prodList);
		List<Lead> LeadList = createLeads(schoolList[0]);
		LeadList = updateLeadRef(LeadList);
		
		List<Account> students = createStudents();
        List<HexaBPM__Service_Request__c> SR_List = createSRForLead(LeadList,students,schoolList[0],'TC_Request');
        List<HexaBPM__SR_Price_Item__c> piList =  createPriceitems(SR_List,prodList,plList);
		
		
		
		Test.startTest();
		    
            
			Test.setCurrentPageReference(new PageReference('Page.GEMS_ChangeTCPage')); 
            System.currentPageReference().getParameters().put('Id',SR_List[0].Id );
            System.currentPageReference().getParameters().put('reqType','Cancel_TC_Request');
            
            ApexPages.StandardController stdCntlr = new ApexPages.StandardController(SR_List[0]);
            GEMS_ChangeTCCntlr obj = new GEMS_ChangeTCCntlr(stdCntlr);
            
            obj.updateSR();
            
		Test.stopTest();
		
	}
		@isTest static void test_method3() {
		// Implement test code
			// Implement test code
		List<Product2> prodList = createProducts(10,'REGISTRATION FEE');
		List<HexaBPM__SR_Status__c> SRStatusList = createSRStatus();
		List<School__c> schoolList = createSchools(5);
		List<Academic_Year__c> academicYears = createsAYs(10,schoolList[0]);
		List<Grade__c> grades = createGrades(schoolList[0],academicYears);
		List<Amount__c> amounts = createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = createSiteConfig(schoolList[0]);
		createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = createPricingLines(prodList);
		List<Lead> LeadList = createLeads(schoolList[0]);
		LeadList = updateLeadRef(LeadList);
		
		List<Account> students = createStudents();
        List<HexaBPM__Service_Request__c> SR_List = createSRForLead(LeadList,students,schoolList[0],'Strike_Off');
        List<HexaBPM__SR_Price_Item__c> piList =  createPriceitems(SR_List,prodList,plList);
		
		
		
		Test.startTest();
		    
            
			Test.setCurrentPageReference(new PageReference('Page.GEMS_ChangeTCPage')); 
            System.currentPageReference().getParameters().put('Id',SR_List[0].Id );
            System.currentPageReference().getParameters().put('reqType','Cancel_Strike_Off');
            
            ApexPages.StandardController stdCntlr = new ApexPages.StandardController(SR_List[0]);
            GEMS_ChangeTCCntlr obj = new GEMS_ChangeTCCntlr(stdCntlr);
            
            obj.updateSR();
            
            
		Test.stopTest();
		
	}
	@isTest static void test_method4() {
		// Implement test code
			// Implement test code
		List<Product2> prodList = createProducts(10,'REGISTRATION FEE');
		List<HexaBPM__SR_Status__c> SRStatusList = createSRStatus();
		List<School__c> schoolList = createSchools(5);
		List<Academic_Year__c> academicYears = createsAYs(10,schoolList[0]);
		List<Grade__c> grades = createGrades(schoolList[0],academicYears);
		List<Amount__c> amounts = createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = createSiteConfig(schoolList[0]);
		createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = createPricingLines(prodList);
		List<Lead> LeadList = createLeads(schoolList[0]);
		LeadList = updateLeadRef(LeadList);
		
		List<Account> students = createStudents();
        List<HexaBPM__Service_Request__c> SR_List = createSRForLead(LeadList,students,schoolList[0],'Strike_Off');
        List<HexaBPM__SR_Price_Item__c> piList =  createPriceitems(SR_List,prodList,plList);
		
		
		
		Test.startTest();
		    
            
			Test.setCurrentPageReference(new PageReference('Page.GEMS_ChangeTCPage')); 
            System.currentPageReference().getParameters().put('Id',SR_List[0].Id );
            System.currentPageReference().getParameters().put('reqType','Reverse_Cancel_Admission');
            
            ApexPages.StandardController stdCntlr = new ApexPages.StandardController(SR_List[0]);
            GEMS_ChangeTCCntlr obj = new GEMS_ChangeTCCntlr(stdCntlr);
            
            obj.updateSR();
            
            
            obj.SR = SR_List[0];
            obj.cancelSR();
            
		Test.stopTest();
		
	}
	@isTest static void test_method5() {
		// Implement test code
			// Implement test code
		List<Product2> prodList = createProducts(10,'REGISTRATION FEE');
		List<HexaBPM__SR_Status__c> SRStatusList = createSRStatus();
		List<School__c> schoolList = createSchools(5);
		List<Academic_Year__c> academicYears = createsAYs(10,schoolList[0]);
		List<Grade__c> grades = createGrades(schoolList[0],academicYears);
		List<Amount__c> amounts = createAmounts(prodList);
		GEMS_Site_Domain_Config__c sc = createSiteConfig(schoolList[0]);
		createLeadEnquirySyncConfig();
		List<HexaBPM__Pricing_Line__c> plList = createPricingLines(prodList);
		List<Lead> LeadList = createLeads(schoolList[0]);
		LeadList = updateLeadRef(LeadList);
		
		List<Account> students = createStudents();
        List<HexaBPM__Service_Request__c> SR_List = createSRForLead(LeadList,students,schoolList[0],'Strike_Off');
        List<HexaBPM__SR_Price_Item__c> piList =  createPriceitems(SR_List,prodList,plList);
		
		
		
		Test.startTest();
		    
            
			Test.setCurrentPageReference(new PageReference('Page.GEMS_ChangeTCPage')); 
            System.currentPageReference().getParameters().put('Id',NULL );
            System.currentPageReference().getParameters().put('reqType','Cancel_TC_Request');
            
            ApexPages.StandardController stdCntlr = new ApexPages.StandardController(SR_List[0]);
            GEMS_ChangeTCCntlr obj = new GEMS_ChangeTCCntlr(stdCntlr);
            
            obj.updateSR();
            
		Test.stopTest();
		
	}
	
}