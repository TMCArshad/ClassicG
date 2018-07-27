/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   13th April 2017
    Description :   GEMS_reEnrollmentCtlr used for VF page GEMS_reEnrollment.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    V1.0	20/12/2017		CR for Re-Enrolment
    V1.1	06/02/2018		Remove issue invoice button
    V1.2	13/02/2018		Removed future grade reference
    V1.3	29/03/2018		Removed outstanding check
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/

global without sharing class GEMS_reEnrollmentCtlr {
    
    public string schoolCode {get;set;} //school code available from URL
    public string studentId {get;set;}  // student ID available from URL
    public string studentName {get;set;}  // student name
    public string staffId {get;set;}    //if parent is in staff, staff id of same 
    
    //V1.0
    public static string otpGenerated {get;set;}
    public string otpProvided {get;set;}
    
    public map<string,string> mapParameters; // map to save all parameters available from URL
    
    public HexaBPM__Service_Request__c objSR {get;set;} //HexaBPM__Service_Request__c variable used on page
    public Account objStudent {get;set;} //Account variable used to populate student Account
    public Academic_Year__c objAcademicYear {get;set;} //Future academic year
    public Grade__c objGrade {get;set;}
    
    public List<SelectOption> gemsStaffExist {get; set;} //dropdown to get which of the parent is staff in gems school
    public List<SelectOption> applyForTC {get; set;} //dropdown to check TC Request
    
    public string selectedgemsStaffExist {get;set;}
    public string startMonth {get;set;}
    public string selectedTCrequest {get;set;}
    public string strActionId{get;set;}
    public string academicYear {get; set;}
    public string academicYearCurrent {get; set;}
    
    public boolean yes {get;set;} //if parent agree for reEnrolment
    public boolean no {get;set;}  // if parent doesn't agree for reEnrolment
    public boolean displayPopup {get;set;}
    public boolean isBlocked {get;set;}
    public boolean payAtSchool {get;set;}
    public boolean hasPriceItem {get;set;}
    public boolean reEnrolStarted {get;set;}
    
    public decimal totalPrice {get;set;}
    
    public Employee__c employee;
    
    public static OTP_Verification__c otp {get;set;} 
    
    public string schoolId;
    
    public  GEMS_reEnrollmentCtlr(){
        
        //initialize all variables
        schoolCode = '';
        studentId = '';
        studentName = '';
        selectedgemsStaffExist = '';
        selectedTCrequest = '';
        staffId = '';
        schoolId = '';
        startMonth = '';
        
        objSR = new HexaBPM__Service_Request__c();
        employee = new Employee__c();
        mapParameters = new map<string,string>();
        
        gemsStaffExist = new List<SelectOption>();
        applyForTC =  new List<SelectOption>();
        
        yes = false;
        no = false;
        displayPopUp = false;
        isBlocked = false;
        payAtSchool = false;
        reEnrolStarted = false;
        
        gemsStaffExist.add(new SelectOption('No', 'No'));
        gemsStaffExist.add(new SelectOption('Yes', 'Yes'));
        
        applyForTC.add(new SelectOption('Yes', 'Yes'));
        applyForTC.add(new SelectOption('No', 'No'));
        
        
        // all the parameters in the url are stored in this map
        mapParameters = apexpages.currentPage().getParameters();
        
        if(mapParameters!=null && mapParameters.size()>0){
			system.debug('---studentID--'+ApexPages.CurrentPage().getParameters().get('studentID'));
            studentID = GEMS_Utility.getDecryptedURLParam(ApexPages.CurrentPage().getParameters().get('studentID'));
            system.debug('---studentID--'+studentID);
        }
        system.debug('-------');
        if(string.isNotBlank(studentId)){
            checkExistingReEnrollmentSR(studentId); // check if parent has already raised any reEnrollment SR.
            
            if(objStudent!=null && string.isNotBlank(objStudent.id)){
                if(objSR!=null && string.isNotBlank(objSR.id) && objSR.HexaBPM__External_Status_Name__c!='Draft'){
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Re-Enrolment has been already submitted. Please contact Registrar'));     
                }
                
                system.debug('--objStudent-'+objStudent);
                list<promotion__c> tempList = [select id, Re_Enrolment_Remark__c from Promotion__c where student__c =: objStudent.id 
                									and academic_year__c=:objStudent.academic_year__c
                									and Grade__c =:objStudent.GradeLookup__c and active__c = true];
                if(tempList!=null && tempList.size()>0 && tempList[0].Re_Enrolment_Remark__c=='Blocked'){
                	isBlocked = true;
                	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Student cannot be re-enroled, Please contact registrar'));
                } 
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Student does not Exist for given student ID'));        
            }
            
            hasPriceItem = checkhasPriceItem();
        }
    } 
    
    
    
    public void checkExistingReEnrollmentSR(string studentId){
        list<Account> tempAccountlist =  new list<Account>(); 
        tempAccountlist = [select id, name, Re_enrolment_Status__c,father__c, mother__c, Guardian_1__c, father__r.FirstName, father__r.LastName, Primary_Contact_Email__c,
                                  mother__r.FirstName, mother__r.LastName, school__r.id__c,school__r.name,Primary_Contact__c,fee_id__c,
                                  Academic_Year__c,Academic_Year__r.Year__c,curriculum__c,Curriculum_Current__c,Stream__c,GradeLookup__r.Sys_Sort_Val__c,GradeLookup__c,
                                  Guardian_1__r.FirstName, Guardian_1__r.LastName, school__r.id,IsPersonAccount,Student_Id__c,GradeLookup__r.Enable_Re_Enrolment__c, 
                                  Academic_Year_Display__c,Grade_Display__c,Section__c,	Academic_Year__r.Re_Enrolment_Payment_Delay_Date__c,
                                  Academic_Year__r.Re_Enrolment_Start_Date__c,Academic_Year__r.Re_Enrolment_End_Date__c,
                                  (select id,HexaBPM__External_Status_Name__c ,Primary_Contact__c,Declaration__c,GradeLookup__r.Enable_Re_Enrolment__c,
                                    school__c,school__r.id__c,Is_father_of_Student_an_employee_in_GEMS__c,Apply_Gems_Credit_Card__c,
                                    Is_mother_of_Student_an_employee_in_GEMS__c, Academic_Year__r.Re_Enrolment_Payment_Delay_Date__c,Staff_ID__c,Staff_ID_Mother__c,Accept_Offer__c,createdDate,Payment_Status__c
                                   from HexaBPM__Service_Requests__r 
                                   where HexaBPM__Record_Type_Name__c='Re_Enrolment')  
                           from Account where Student_Id__c =: studentId];
        
        if(tempAccountlist!= null && tempAccountlist.size()>0){
            objStudent = tempAccountlist[0];
            schoolId = tempAccountlist[0].school__r.id;
            studentName = tempAccountlist[0].name;
            schoolCode = tempAccountlist[0].school__r.id__c;
            if(objStudent.HexaBPM__Service_Requests__r!=null && objStudent.HexaBPM__Service_Requests__r.size()>0){
                objSR = objStudent.HexaBPM__Service_Requests__r[0];
                if(objSR!=null && string.isNotBlank(objSR.id)){
                    selectedGemsStaffExist = 'No';  
                    if(objSR.Is_father_of_Student_an_employee_in_GEMS__c == 'Yes' ){
                        selectedGemsStaffExist = 'Yes'; 
                        employee = checkStaffExistInSchool(string.valueOf(objSR.Staff_ID__c));
                        staffId = objSR.Staff_ID__c;
                    }   
                    
                    if(objSR.Is_mother_of_Student_an_employee_in_GEMS__c == 'Yes'){
                        selectedGemsStaffExist = 'Yes'; 
                        employee = checkStaffExistInSchool(string.valueOf(objSR.Staff_ID_Mother__c));
                        staffId = objSR.Staff_ID_Mother__c;
                    }

                    if(objSR.accept_offer__c == 'Yes'){
                        yes = true;
                        no = false;
                        totalPrice = 0;
        
                        list<HexaBPM__SR_Price_Item__c> tempSRList = [select id,HexaBPM__SRPriceLine_Text__c ,name,Open_Online_Payment__c , HexaBPM__Price__c, HexaBPM__Product__r.name, Status__c,Amount__c 
                                                                      from HexaBPM__SR_Price_Item__c where (Status__c='Added' or status__c = 'Pay At School') and HexaBPM__SRPriceLine_Text__c ='Re-Enrolment'
                                                                      and HexaBPM__ServiceRequest__c =: objSR.id];
                            
                        if(tempSRList!=null && tempSRList.size()>0){
                            totalPrice = tempSRList[0].HexaBPM__Price__c;
                        }
                    
                    }
                    else{
                        no = true;
                        yes = false;
                    }
                }
            }

            if(objStudent.Academic_Year__c!=null){
                string academicYearTemp = '';
                academicYearTemp = string.valueOf(integer.valueOf(objStudent.Academic_Year__r.Year__c) + 1);

                list<Academic_Year__c> tempList = [select id,Re_Enrolment_Start_Date__c,
                										  Re_Enrolment_End_Date__c,
                										  Academic_Year__c,Start_Date__c, 
                										  End_Date__c,Year__c  
        										   from Academic_Year__c where School__c =: objStudent.school__c and Year__c=:academicYearTemp
                                                   and Curriculum__c =: objStudent.Curriculum_Current__c];

                if(tempList!=null && tempList.size()>0){
                    objAcademicYear = tempList[0];
                    academicYear = GEMS_utility.getLabelFromAcademicYear(objAcademicYear.year__c);
                    academicYearCurrent = objAcademicYear.Academic_Year__c.split('-')[0];
                    
                    Map < Integer, String > monthmap = new Map < Integer, String > ();
					monthmap.put(1, 'January');
					monthmap.put(2, 'February');
				    monthmap.put(3, 'March');
				    monthmap.put(4, 'April');
				    monthmap.put(5, 'May');
				    monthmap.put(6, 'June');
				    monthmap.put(7, 'July');
			  	    monthmap.put(8, 'August');
				    monthmap.put(9, 'September');
				    monthmap.put(10, 'October');
				    monthmap.put(11, 'November');
				    monthmap.put(12, 'December');

                    
                    startMonth = monthmap.get(objAcademicYear.Start_Date__c.month());
                	if((objStudent.academic_year__r.Re_Enrolment_Start_Date__c!=null && system.today()>=objStudent.academic_year__r.Re_Enrolment_Start_Date__c) &&
                	    (objStudent.academic_year__r.Re_Enrolment_End_Date__c!=null && system.today()<=objStudent.academic_year__r.Re_Enrolment_End_Date__c) && objStudent.GradeLookup__r.Enable_Re_Enrolment__c==true){
                		
                		reEnrolStarted = true;	
                	}
                }      
            }
            if(objStudent.GradeLookup__c!=null && objAcademicYear!=null){
                integer grade = 0;
                grade = integer.valueOf(objStudent.GradeLookup__r.Sys_Sort_Val__c + 1);
                list<grade__c> tempList = [select id, grade__c,Grade_Display__c from grade__c where School__c =: objStudent.school__c and Sys_Sort_Val__c=:decimal.valueOf(grade)
                                                   and Stream__c =: objStudent.stream__c and academic_year__c=:objAcademicYear.id];
                if(tempList!=null && tempList.size()>0){
                    objGrade = tempList[0];
                    
                }                                  
            }
        }
    }
    
    public boolean checkhasPriceItem(){
   		
   		set<string> stageSet = new set<string>();
		stageSet.add('RE-ENROL');
		
		if(objStudent!=null && objStudent.GradeLookup__c!=null && objStudent.Academic_Year__c!=null){
   		list<Amount__c> amountList = [select id, Stage_Lookup__c,
											 Stage_Lookup__r.HexaBPM__Code__c,Tution_fee_percentage__c
									  from Amount__c where Stage_Lookup__r.HexaBPM__Code__c IN :stageSet 
									  and By_Grade__c=true and grade__c=:objStudent.GradeLookup__c
									  and Stream__c =: objStudent.stream__c and Academic_Year__c=: objStudent.Academic_Year__c
									  and School__c=: objStudent.school__c]; //checking if record exist in amount object depending on grade, stream and fee type on SR
			system.debug('--amountList--'+amountList);
			if(amountList!=null && amountList.size()>0){
					
				if(amountList[0].Stage_Lookup__r.HexaBPM__Code__c == 'RE-ENROL'){
					
					return true;	
				}
			}
		}
   		return false;	
    }
    
    
    public pageReference upsertReEnrollmentSR(){
        displayPopup = false;
        Savepoint spdata = Database.setSavepoint();
        pageReference redirectPage = null;
        try{
            
            string errorMessage= 'Success';
            errorMessage = checkValidations();
            if(errorMessage !='Success'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errorMessage)); 
                return null;
            }
            
            else{
                if(employee!=null && string.isNotBlank(employee.id)){
                    if(string.isNotBlank(employee.gender__c) && employee.gender__c.contains('Male')){
                        objSR.Is_father_of_Student_an_employee_in_GEMS__c = 'Yes';
                        objSR.Staff_ID__c = staffId;
                        objSR.Sys_Business_Unit_Father__c = employee.school__c;
                        objSR.Business_Unit_Father__c = employee.school__r.id__c;
                    }   
                    else if(string.isNotBlank(employee.gender__c) && employee.gender__c.contains('Female')){
                        objSR.Is_mother_of_Student_an_employee_in_GEMS__c = 'Yes';
                        objSR.Staff_ID_Mother__c = staffId;
                        objSR.Sys_Business_Unit_Mother__c = employee.school__c;
                        objSR.Business_Unit_Mother__c = employee.school__r.id__c;
                    }
                }
                
                system.debug('----selectedGemsStaffExist---'+selectedGemsStaffExist);
                if(selectedGemsStaffExist=='No'){
                    objSR.Is_father_of_Student_an_employee_in_GEMS__c = 'No';
                    objSR.Is_mother_of_Student_an_employee_in_GEMS__c = 'No';
                    objSR.Staff_ID__c = '';
                    objSR.Business_Unit_Father__c = null;
                    objSR.Staff_ID_Mother__c = '';
                    objSR.Business_Unit_Mother__c = null;
                }
                
                if(yes==true){
                    objSR.accept_offer__c ='Yes';
                }
                else{
                    objSR.accept_offer__c ='No';
                }
                
                string recTypeID = GEMS_Utility.GetRecordTypeIdsByDeveloperName(HexaBPM__Service_Request__c.getsObjectType()).get('Re_Enrolment');
                if(string.isNotBlank(recTypeID)){
                    objSR.recordTypeId = recTypeID;
                }
                
                if(string.isNotBlank(schoolId)){
                    objSR.school__c = schoolId;
                }
                objSR.HexaBPM__Customer__c = objStudent.id;
                objSR.student__c = objStudent.id;
                objSR.stream__c = objStudent.stream__c;
                objSR.Academic_Year__c = objStudent.Academic_Year__c;    
                objSR.GradeLookup__c = objStudent.GradeLookup__c; 
                objSR.HexaBPM__Email__c = objStudent.Primary_Contact_Email__c;
                if(objStudent.Primary_Contact__c == 'Father' && string.isNotBlank(objStudent.father__c)){
                    objSR.Primary_Contact_Name__c = objStudent.father__r.FirstName + ' ' + objStudent.father__r.LastName;
                }
                else if(objStudent.Primary_Contact__c == 'Mother' && string.isNotBlank(objStudent.mother__c)){
                    objSR.Primary_Contact_Name__c = objStudent.mother__r.FirstName + ' ' + objStudent.mother__r.LastName;
                }
                else if(objStudent.Primary_Contact__c == 'Guardian' && string.isNotBlank(objStudent.Guardian_1__c)){
                    objSR.Primary_Contact_Name__c = objStudent.Guardian_1__r.FirstName + ' ' + objStudent.Guardian_1__r.LastName;
                }   
                objSR.student_Id__c = studentId;
                upsert objSR;
                
                if(objSR!=null && string.isNotBlank(objSR.id)){
                	
                	totalPrice = 0;
        
                    list<HexaBPM__SR_Price_Item__c> tempSRList = [select id,HexaBPM__SRPriceLine_Text__c ,name,Open_Online_Payment__c , HexaBPM__Price__c, HexaBPM__Product__r.name, Status__c,Amount__c 
                                                                  from HexaBPM__SR_Price_Item__c where (Status__c='Added' or status__c = 'Pay At School') and HexaBPM__SRPriceLine_Text__c ='Re-Enrolment'
                                                                  and HexaBPM__ServiceRequest__c =: objSR.id];
                        
                    if(tempSRList!=null && tempSRList.size()>0){
                        totalPrice = tempSRList[0].HexaBPM__Price__c;
                    }
                        
                    if((objSR.accept_offer__c == 'Yes' && totalPrice<=0) || objSR.accept_offer__c == 'No'){    
	                	HexaBPM__SR_Status__c objStatus = new HexaBPM__SR_Status__c();
		                objStatus = [select Id from HexaBPM__SR_Status__c where Name = 'CLOSED' and HexaBPM__Code__c = 'CLOSED' limit 1];
		                    
		                objSR.HexaBPM__Internal_SR_Status__c = objStatus.Id;
		                objSR.HexaBPM__External_SR_Status__c = objStatus.Id;
		                objSR.HexaBPM__Submitted_Date__c = system.today();
		                objSR.HexaBPM__Submitted_DateTime__c = system.now();    
		                objSR.HexaBPM__finalizeamendmentflg__c = true;
		                objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
		                objSR.Payment_Status__c = 'No Payment';
		                update objSR;
                    }
                    
                    if(objSR.accept_offer__c == 'Yes' && totalPrice>0){    
	                	objSR.Payment_Status__c = 'Payment Pending';
		                update objSR;
                    }
                    
                	list<promotion__c> promoList = [select id, Re_enrolment_Remark__c,Re_Enroled__c
                									from promotion__c where student__c =: objStudent.id 
                									and academic_year__c=:objStudent.academic_year__c
                									and Grade__c =:objStudent.GradeLookup__c and active__c = true];
                	if(promoList!=null && promoList.size()>0){
                		
                		for(promotion__c obj :promoList ){
                			if(objSR.accept_offer__c == 'Yes' && totalPrice<=0){
                				if(employee!=null && string.isNotBlank(employee.id)){
                					obj.Re_enrolment_Remark__c = 'GEMS Staff Re-Enroled	';	
                				}else{
                					obj.Re_enrolment_Remark__c = 'Re-Enroled';
                				}
                				obj.Re_Enroled__c = 'Yes';
                			}
                			else if(objSR.accept_offer__c == 'Yes' && totalPrice>0){
                				obj.Re_enrolment_Remark__c = 'Fee Pending';
                			}
                			else if(objSR.accept_offer__c == 'No'){
                				obj.Re_enrolment_Remark__c = 'Not Re-Enroling';
                				obj.Re_Enroled__c = 'No';
                			}
                		}	
                		update promoList;
                	}
                }
                
                if(objSR.accept_offer__c == 'Yes'){
                    redirectPage = page.GEMS_reEnrollment;
                    redirectPage.getParameters().put('studentId', ApexPages.CurrentPage().getParameters().get('studentID'));
                    redirectPage.setRedirect(true); 
                }
                else if(objSR.accept_offer__c == 'No' && selectedTCrequest=='Yes'){
                    redirectPage = page.GEMS_TCRequestPage;
                    redirectPage.getParameters().put('studentID', GEMS_Utility.getEnctryptedURLparam(objStudent.student_id__c));
                    redirectPage.getParameters().put('BSU', GEMS_Utility.getEnctryptedURLparam(objStudent.school__r.id__c));
                    redirectPage.setRedirect(true); 
                }
            }
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            system.debug('--line---'+ex.getLineNumber());
            Database.rollback(spdata);
        }   
        return redirectPage;
    }
    
    public void submitReEnrollmentSR(){
        if(objSR!=null && string.isNotBlank(objSR.id)){
	        HexaBPM__SR_Status__c objStatus = new HexaBPM__SR_Status__c();
	        objStatus = [select Id from HexaBPM__SR_Status__c where Name = 'Submitted' and HexaBPM__Code__c = 'SUBMITTED' limit 1];
	            
	        objSR.HexaBPM__Internal_SR_Status__c = objStatus.Id;
	        objSR.HexaBPM__External_SR_Status__c = objStatus.Id;
	        objSR.HexaBPM__Submitted_Date__c = system.today();
	        objSR.HexaBPM__Submitted_DateTime__c = system.now();    
	        objSR.HexaBPM__finalizeamendmentflg__c = true;
	        objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
	        
	        update objSR;
        }
    }
    
    //V1.1
    /*public void issueInvoice(){
		if(objSR!=null && string.isNotBlank(objSR.id)){
			objSR.Enrolment_Transferred__c = true;
			objSR.Invoice_Request_Date__c = system.today();
			update objSR;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,'Request has been send to finance officer to issue Invoice.'));
		}
    }*/
    
    public void payAtSchool(){
    	try{
	    	if(objSR!=null && string.isNotBlank(objSR.id) && objSR.accept_offer__c == 'Yes' && totalPrice>0){
		    	HexaBPM__SR_Status__c objStatus = new HexaBPM__SR_Status__c();
		        objStatus = [select Id from HexaBPM__SR_Status__c where Name = 'Submitted' and HexaBPM__Code__c = 'SUBMITTED' limit 1];
		            
		        objSR.HexaBPM__Internal_SR_Status__c = objStatus.Id;
		        objSR.HexaBPM__External_SR_Status__c = objStatus.Id;
		        objSR.HexaBPM__Submitted_Date__c = system.today();
		        objSR.HexaBPM__Submitted_DateTime__c = system.now();    
		        objSR.HexaBPM__finalizeamendmentflg__c = true;
		        objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
		    	objSR.Payment_Status__c = 'Pay At School';
		        update objSR;
		        payAtSchool = true;
	    	}
    	}catch(exception ex){
    		system.debug('-----'+ex.getLineNumber());
    	}
    }
    
    
    public string checkValidations(){
        if(selectedGemsStaffExist == 'Yes' && string.isBlank(staffId))
            return 'Please provide Staff Id';  
        
        if(string.isNotBlank(staffId) && staffId.length()!=8 && selectedGemsStaffExist == 'Yes')
            return 'Staff Id can only be 8 digits';
            
        if(string.isNotBlank(staffId) && selectedGemsStaffExist == 'Yes'){
            employee = checkStaffExistInSchool (staffId);
            if(employee!=null && string.isNotBlank(employee.id)){
                return 'Success';   
            }
            else{
                return 'Staff member does not exist.';  
            }
        }
        
        if(objSR.declaration__c == false)
            return 'Please confirm';
        
        if(yes==false && no == false)
            return 'Please select whether you wish to re-enrol.';
        
        list<HexaBPM__Service_Request__c> existingSR = [select id,HexaBPM__External_Status_Name__c from HexaBPM__Service_Request__c where Student_Id__c =: studentId and HexaBPM__Record_Type_Name__c ='Re_Enrolment' ];
        if(existingSR!=null && existingSR.size()>0){
            //return 'Request has already been submitted, Please contact Registrar';  
        }
        return 'Success';
    }
    
    public Employee__c checkStaffExistInSchool(string staffId){    
        if(string.isNotBlank(staffId)){
	        list<Employee__c> employeeList = [select id, Staff_Number__c, school__c,school__r.id__c, gender__c 
	                                          from Employee__c 
	                                          where Staff_Number__c=:staffId];
	                                          
	        if(employeeList!=null && employeeList.size()>0){
	            employee = employeeList[0];
	        }
	        return employee;
        }
        return null;
    }
    
    
    public PageReference payNow(){
        displayPopup = false;
        PageReference redirectPage = null;
       // GEMS_feeBalanceInfo objClass = new GEMS_feeBalanceInfo();
      //  list<GEMS_feeBalanceInfo.studentBalanceWrapper> studentBalanceList = new list<GEMS_feeBalanceInfo.studentBalanceWrapper>();
      //  studentBalanceList = objClass.getStudentBalance(objStudent.student_id__c,'');
      //  string feeType = '';
      //  string amount = '';
        //V1.3
       /* if(studentBalanceList!=null && studentBalanceList.size()>0){
            for(GEMS_feeBalanceInfo.studentBalanceWrapper objLoop : studentBalanceList){
                
                if(string.isNotBlank(objLoop.amount) && !(objLoop.amount.contains('-')) && objLoop.amount!='0.000' && objLoop.feeType.contains('TUITION')){
                    if(string.isNotBlank(feeType)){
                        feeType =   feeType + ' ,' +objLoop.feeType;    
                    }
                    else{
                        feeType = objLoop.feeType;
                    }   
                    amount = amount + integer.valueOf(objLoop.amount);
                }
            }   
        }
        if(string.isNotBlank(feeType) && string.isNotBlank(amount)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Student has outstanding payment of '+ amount+' for '+feeType));    
            
        }
        else{*/
        	
            String paymentRedirectPageURL = Site.getBaseUrl() + '/apex/' +  GEMS_Constants.PAYMENT_REDIRECTION_PAGE;
        
            GEMS_MiGS_Utility.SRIds = objSR.id; //Setting list of SR ids if in case multiple SRs are paid once
            GEMS_MiGS_Utility.retURLVal = GEMS_Utility.getReferer(); // Setting value so that once transion is complete we know where to redirect
            GEMS_MiGS_Utility.schoolCode = schoolCode; //Setting school code to get apprropriate merchent details from custom metadata type
            String url = '';
            
            url = GEMS_MiGS_Utility.getMiGSPaymentURL(string.valueOf(totalPrice),'Re-Enrolment Fee',paymentRedirectPageURL);
            redirectPage = new PageReference(url);
            redirectPage.setRedirect(true);
        //}
        return redirectPage;
   }
   
   public void showPopUp(){
        string msg = checkValidations();
        if(msg!='Success'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,msg)); 
            displayPopup = false;
        } 
        else{
            displayPopup = true;
        }
   }
   
    public void closePopup() {
        displayPopup = false;
        
    }
    
    @RemoteAction
    global static string generateOTP(String staffID, string studentID) {
        string msg = '';
        try{
	         if(string.isNotBlank(staffId)){
		        list<Employee__c> employeeList = [select id, Email__c,Staff_Number__c, school__c,school__r.id__c, gender__c 
		                                          from Employee__c 
		                                          where Staff_Number__c=:staffId];
		                                          
		        if(employeeList!=null && employeeList.size()>0){
		            otp = new OTP_Verification__c();
		            list<OTP_Verification__c> tempOTP = [select id,Send_OTP__c,OTP__c from OTP_Verification__c
		            									 where Staff_ID__c =: employeeList[0].Staff_Number__c
		            									 and Type__c = 'Re-Enrolment'
		            									 and Student_ID__c =: studentID
		            									 and Inactive__c = false]; 
		            
		            if(tempOTP!=null && tempOTP.size()>0){
		            	otp	= tempOTP[0];
		            	otp.Send_OTP__c = true;
		            	otpGenerated = tempOTP[0].OTP__c;
		            	update otp;
		            }
		            else{
		            	otpGenerated = string.valueOf(Math.round(Math.random()*10000));
		            	
			            otp.OTP__c = otpGenerated;
			            otp.Staff_ID__c = employeeList[0].Staff_Number__c;
			            otp.Student_ID__c = studentID;
			            otp.Type__c = 'Re-Enrolment';
			            otp.Email__c = employeeList[0].Email__c;
			            otp.Send_OTP__c = true;
			            
			            integer expirationTime = integer.valueOf(System.Label.OTP_Expiration_Time);
			            otp.OTP_Expiration_Time__c = system.now().addHours(expirationTime);
			            insert otp;
		            }
		            msg = 'Please enter OTP received on the official GEMS email address.';
		        }else{
		        	msg = 'Please provide correct staff ID.';	
		        }
	        }else{
	        	msg = 'Please provide staff ID';
	        }
	    }catch(exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            system.debug('--line---'+ex.getLineNumber());
        } 
        return msg;
    }
    
    @RemoteAction
    global static string validateOTP(string otpProvided, string staffID, string studentID) {
    	string msg = '';
        try{
	         if(string.isNotBlank(otpProvided)){
	            list<OTP_Verification__c> tempOTP = [select id,Send_OTP__c,OTP__c from OTP_Verification__c
	            									 where Staff_ID__c =: staffID
	            									 and Type__c = 'Re-Enrolment'
	            									 and Student_ID__c =: studentID
	            									 and Inactive__c = false
	            									 and OTP__c =: otpProvided]; 
	            
	            if(tempOTP!=null && tempOTP.size()>0){
	            	msg = 'Thank you for the verification.';
	            }
	            else{
	            	msg = 'Invalid OTP, Please try again.';
	            }
	        }else{
	        	msg = 'Please provide OTP';
	        }
	    }catch(exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            system.debug('--line---'+ex.getLineNumber());
        } 
        return msg;
    }
}