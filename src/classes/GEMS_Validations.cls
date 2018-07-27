/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   13th March 2017
    Description :   all validations related to lead, SR.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    V1.0 11th Sept  Cirrculum Fix           Swati
    V1.1 25th Sept  Duplicate Check Update  Swati
    v1.2 22nd Oct   Age cut off validation fix for decimal  Leeba
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
public with sharing class GEMS_Validations {
    
    public static boolean checkForDuplicates(Lead leadObj){
        if(leadObj!=null && leadObj.GradeLookup__c!=null && leadObj.academic_Year__c!=null &&
           leadObj.SchoolLookup__c!=null && leadObj.firstName!=null && leadObj.lastName!=null &&
           leadObj.email!=null){
            list<lead> tempLeadList = [select id from Lead where GradeLookup__c =: leadObj.GradeLookup__c and academic_Year__c =: leadObj.academic_Year__c and SchoolLookup__c =: leadObj.SchoolLookup__c and FirstName =: leadObj.firstName and lastName =: leadObj.lastName and email =: leadObj.email];
            if(tempLeadList!=null && tempLeadList.size()>0){
                return true;    
            }
        }
        return false; 
    }
    
    
    public static boolean checkForDuplicates(Enquiry__c EnquiryObj){
        if(EnquiryObj!=null && EnquiryObj.GradeLookup__c!=null && EnquiryObj.academic_Year__c!=null &&
           EnquiryObj.SchoolLookup__c!=null && EnquiryObj.firstName__c!=null && EnquiryObj.lastName__c!=null &&
           EnquiryObj.email__c!=null){
            
            list<Enquiry__c> tempEnquiryList = [select id from Enquiry__c where GradeLookup__c =: EnquiryObj.GradeLookup__c and academic_Year__c =: EnquiryObj.academic_Year__c and SchoolLookup__c =: EnquiryObj.SchoolLookup__c and FirstName__c =: EnquiryObj.firstName__c and lastName__c =: EnquiryObj.lastName__c and email__c =: EnquiryObj.email__c];
            if(tempEnquiryList!=null && tempEnquiryList.size()>0){
                return true;    
            }
        }
        return false;
    }
    
    //Validate Multiple Open SR
    //Assuming no bulk Operation
    public static void validateOpenSR(List<HexaBPM__Service_Request__c> SR_List){
        Boolean hasOpenSR = false;
        HexaBPM__Service_Request__c srObj = SR_List[0];
        for(HexaBPM__Service_Request__c SR : [SELECT Id, Student__c, Name, HexaBPM__External_Status_Name__c, HexaBPM__Record_Type_Name__c, HexaBPM__External_SR_Status__r.SR_Closed_Status__c 
                                              FROM HexaBPM__Service_Request__c 
                                              WHERE HexaBPM__External_SR_Status__r.SR_Closed_Status__c != true
                                              AND HexaBPM__Record_Type_Name__c =: srObj.HexaBPM__Record_Type_Name__c 
                                              AND Student__c =:srObj.Student__c ]){
                                                
            hasOpenSR = true;
        }
        
    }
    
    
    
     /*
        Method Name : CheckAgeCutOff
        Description : Checks the AgeCutOff matched record is there or not and returns true if found.
        Input Params : DateofBirth, Grade Value, School Id, Academic Year Id
        Return Value : Boolean value True or False
        
    */
    public static boolean CheckAgeCutOff(Date DOB,string Grade,string SchoolId,string AcademicYear){
        boolean ResultValue = false;
        system.debug('SchoolId==>'+SchoolId);
        system.debug('Grade==>'+Grade);
        system.debug('DOB==>'+DOB);
        system.debug('AcademicYear==>'+AcademicYear);
        if(DOB!=null && Grade!=null && SchoolId!=null && AcademicYear!=null){
            for(Grade__c CutOff:[select Id,Academic_Year__c,Age_Cut_Off_Date__c,Maximum_Age__c,Minimum_Age__c from Grade__c where Academic_Year__c=:AcademicYear and Grade_Display__c=: Grade and School__c=:SchoolId and Age_Cut_Off_Date__c!=null limit 1]){
                decimal NumberOfMonths = DOB.monthsBetween(CutOff.Age_Cut_Off_Date__c);//integer.valueof(CutOff.Age_Cut_Off_Date__c - DOB);
                /* v1.2 Start code for Handling the Days difference */
                decimal NumberOfMonths_MinAgeCheck = DOB.monthsBetween(CutOff.Age_Cut_Off_Date__c);
                integer Number_of_Days = 0;
                if(CutOff.Age_Cut_Off_Date__c!=null && DOB!=null)
                    Number_of_Days = CutOff.Age_Cut_Off_Date__c.day() - DOB.day();
                system.debug('Number_of_Days==>'+Number_of_Days);
                if(Number_of_Days!=0)
                    NumberOfMonths = NumberOfMonths+1;
                /* v1.2 End code for Handling the Days difference */
                
                decimal DiffValue = NumberOfMonths/12.0;//v1.2 changed type from Integer to decimal and replaced 12 with 12.0 to check exact difference
                decimal DiffValue_MinAgeCheck = NumberOfMonths_MinAgeCheck / 12.0;
                system.debug('DiffValue==>'+DiffValue);
                if(CutOff.Maximum_Age__c!=null && CutOff.Minimum_Age__c!=null){
                    if(DiffValue_MinAgeCheck >= CutOff.Minimum_Age__c && DiffValue<=CutOff.Maximum_Age__c)
                        ResultValue = true;
                    else
                        ResultValue = false;
                }else if(CutOff.Maximum_Age__c!=null && CutOff.Minimum_Age__c==null && DiffValue<=CutOff.Maximum_Age__c){
                    ResultValue = true;
                }else if (CutOff.Maximum_Age__c==null && CutOff.Minimum_Age__c!=null && DiffValue_MinAgeCheck>=CutOff.Minimum_Age__c){
                    ResultValue = true;
                }
            }
        } 
        System.debug('Resultcheckage==>'+ResultValue);       
        return ResultValue;
        
    }

    /*
        Method Name : CheckAgeCutOff
        Description : Checks the AgeCutOff matched record is there or not and returns true if found.
        Input Params : DateofBirth, Grade Value, School Id, Academic Year Id
        Return Value : validateStr (Success/Error Message)
        
    */
    
    //V1.0
    public static String validateAgeCutOff(Lead leadObj,String Grade){
       
        boolean isValid = false;
        String validateStr = 'Success';
            
          Grade__c gradeInfo = new Grade__c (); 
          gradeInfo = getGradeInfo(leadObj.GradeLookup__c);
          if(leadObj!=null && leadObj.Date_Of_Birth__c!=null && string.isNotBlank(Grade)){    //String reason = 'No matching record found for Age Cutoff.';
            String reason = '';
            if(gradeInfo!=null && string.isNotBlank(gradeInfo.id)){ 
                decimal NumberOfMonths = leadObj.Date_Of_Birth__c.monthsBetween(gradeInfo.Age_Cut_Off_Date__c);//integer.valueof(gradeInfo.Age_Cut_Off_Date__c - DOB);
                /* v1.2 Start code for Handling the Days difference */
                decimal NumberOfMonths_MinAgeCheck = leadObj.Date_Of_Birth__c.monthsBetween(gradeInfo.Age_Cut_Off_Date__c);
                integer Number_of_Days = 0;
                if(gradeInfo.Age_Cut_Off_Date__c!=null && leadObj.Date_Of_Birth__c!=null)
                    Number_of_Days = gradeInfo.Age_Cut_Off_Date__c.day() - leadObj.Date_Of_Birth__c.day();
                system.debug('Number_of_Days==>'+Number_of_Days);
                if(Number_of_Days!=0)
                    NumberOfMonths = NumberOfMonths+1;
                /* v1.2 End code for Handling the Days difference */
                decimal DiffValue = NumberOfMonths / 12.0;//v1.2 changed type from Integer to decimal and replaced 12 with 12.0 to check exact difference
                decimal DiffValue_MinAgeCheck = NumberOfMonths_MinAgeCheck / 12.0;
                System.debug('gradeInfo.Maximum_Age__c**'+gradeInfo);
                if((gradeInfo.Maximum_Age__c!=null && gradeInfo.Minimum_Age__c!=null && DiffValue_MinAgeCheck >= gradeInfo.Minimum_Age__c && DiffValue<=gradeInfo.Maximum_Age__c) ||
                   (gradeInfo.Maximum_Age__c!=null && gradeInfo.Minimum_Age__c==null && DiffValue <= gradeInfo.Maximum_Age__c) ||
                   (gradeInfo.Maximum_Age__c==null && gradeInfo.Minimum_Age__c!=null && DiffValue_MinAgeCheck >= gradeInfo.Minimum_Age__c ) ||
                   (gradeInfo.Maximum_Age__c==null && gradeInfo.Minimum_Age__c==null)    ){
                    isValid = true;
                }
                else if(gradeInfo.Maximum_Age__c==null && gradeInfo.Minimum_Age__c!=null ){
                    reason = 'Applicants age should be more  than '+ gradeInfo.Minimum_Age__c +' as on '+formatDate(gradeInfo.Age_Cut_Off_Date__c);
                }
                else if(gradeInfo.Maximum_Age__c!=null && gradeInfo.Minimum_Age__c==null ){
                    reason = 'Applicants age should be less  than '+ gradeInfo.Maximum_Age__c +' as on '+formatDate(gradeInfo.Age_Cut_Off_Date__c);
                }
                else if(gradeInfo.Maximum_Age__c!=null && gradeInfo.Minimum_Age__c!=null){
                    reason = 'Applicants age should be in  between '+gradeInfo.Minimum_Age__c+' and '+gradeInfo.Maximum_Age__c+' as on '+formatDate(gradeInfo.Age_Cut_Off_Date__c);
                }
            }
            if(!isValid)
                validateStr = 'Age not valid. ' + reason;
        }
        return validateStr;     
    }
    //If at least one pending SR reload table and proceed to pay.
    //Else error message to user saying paymnet was already completed
    public static String validatePayment(List<Id> SRIDList){
        String validateStr  ='Invalid Payment request.';
        for(HexaBPM__Service_Request__c SR  : [SELECT Payment_Status__c from HexaBPM__Service_Request__c WHERE ID IN :SRIDList ]){
            validateStr = (SR.Payment_Status__c.equals('Payment Pending')) ? 'Success' : validateStr; 
        }
        return validateStr;
    }

   /**
    * [validateSiblingFeeId Validates the Sibling Fee Id]
    * @param  feeID [Fee Id ]
    * @return       [Validation result - Success/ Invalid fee Id]
    */
    public static String validateSiblingFeeId(String feeID){
     String validateStr = 'Invalid Fee ID.';
     for(Account a : [Select Record_type_Name__c,Student_Id__c from Account where Record_type_Name__c = 'Student' and   Student_Id__c =: feeID ]){
         validateStr = 'Success';
     }
    return validateStr;
    }
    
    public static String formatDate(Date d) {
    return  d.day()+ '-' + d.month() + '-' +  d.year();
}

    public static Grade__c getGradeInfo(ID gradeID){
        Grade__c gradeObj = new Grade__c();
        for(Grade__c g :[Select Id,Academic_Year__c,Academic_Year__r.Curriculum__c,Age_Cut_Off_Date__c,Maximum_Age__c,Minimum_Age__c FROM Grade__c WHERE Id = : gradeID]){
            gradeObj = g;
        }
        return gradeObj;
    }
}