/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   7th March 2017
    Description :   Convert SR into person account.
    --------------------------------------------------------------------------------------------------------------------------
    Modification History 
----------------------------------------------------------------------------------------------------------------------------
      Version  |  Author     |   Date       | Description
     V1.1      |  Umair Khan |  29-Nov-2017 | Map Second language field
     V1.2      |  Kim Noceda |  12-Feb-2018 | Added logic to set the Fees sponsor value from SR Primary Contact if SR Fee Sponsor is blank
     V1.3      |  Shadiya    |  4-32018     | Added ELL fields in SR to Account
     V1.4      |  Leeba      |  13-3-2018   | Added the ARP field in SR to Account CR - 226
     V1.5      |  Swati      |  22-3-2018   | Scholarship CR
*****************************************************************************************************************************/
global without sharing class GEMS_CC_ConvertLeadIntoAccount implements HexaBPM.iCustomCodeExecutable {
    map<id,Account> existingSiblingMap = new map<id,Account>();
    
    global String EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        String msg = 'success';
        Savepoint spdata = Database.setSavepoint();
        try {
            
            if(step.HexaBPM__SR__r!=null){
                Account student = new Account();
                list<Account> parentGuardianList = new list<Account>();
                
                map<id,Account> attachMap = new map<id,Account>();
                
                student = createStudentAccountOnApproval(step);
                if(student!=null && string.isNotBlank(student.id)){
                    updateSRandReceiptwithStudent(step,student);
                    closeOtherLeadAndConvertMainLead(step,student);
                    parentGuardianList = createParentGuardianAccountOnApproval(step, student);   
                    attachMap.put(student.id,student);  
                }  
                
                if(parentGuardianList!=null && parentGuardianList.size()>0 && string.isNotBlank(student.id)){
                    for(Account objAcc : parentGuardianList){
                        attachMap.put(objAcc.id,objAcc);    
                    }
                    createRelationshipsBetweenStudentAndPG(student,parentGuardianList,step); 
                }
                if(student!=null && string.isNotBlank(student.id)){
                    moveAttachmentsToAccount(step,student,attachMap);
                    moveScholarshipRecord(student,step); ////V1.5
                }
            }   
        }catch (Exception e) {
            msg = e.getMessage()+ '-----' + e.getLineNumber();
            system.debug('----msg----'+msg);
            Database.rollback(spdata);
        }
        return msg;
    }
    
    
    /*
     * name     : moveAttachmentsToAccount
     * param    : Account record
     * return   : void
    */
    public void moveAttachmentsToAccount(HexaBPM__Step__c step,account student,map<id,account> attachMap){
        list<attachment> attachmentToDelete = new list<attachment>();
        attachmentToDelete = [Select ID, ParentID, body, Name from Attachment Where ParentID =: step.HexaBPM__SR__c];
        list<attachment> attachmentToInsert = new list<attachment>();
        if(attachmentToDelete!=null && attachmentToDelete.size()>0){
            set<id> setOfAccount = new set<id>();
            for(attachment att : attachmentToDelete){
                Attachment obj = New Attachment();
                if(att.Name.contains('Mother') && student.mother__c!=null){
                    obj.name =  att.name;
                    obj.body =  att.body;
                    obj.parentID = student.mother__c;
                    attachmentToInsert.add(obj);
                }   
                else if(att.Name.contains('Father') && student.father__c!=null){
                    obj.name =  att.name;
                    obj.body =  att.body;
                    obj.parentID = student.father__c;
                    attachmentToInsert.add(obj);
                }
                else if(att.Name.contains('Guardian') && student.guardian_1__c!=null){
                    obj.name =  att.name;
                    obj.body =  att.body;
                    obj.parentID = student.guardian_1__c;
                    attachmentToInsert.add(obj);
                }
                else if(att.Name.contains('Student')){
                    obj.name =  att.name;
                    obj.body =  att.body;
                    obj.parentID = student.id;
                    attachmentToInsert.add(obj);
                }
            }
        }
        if(attachmentToInsert!=null && attachmentToInsert.size()>0){
            insert attachmentToInsert;
        }
        if(attachmentToDelete!=null && attachmentToDelete.size()>0){
            delete attachmentToDelete;
        }
        
        if(attachmentToInsert!=null && attachmentToInsert.size()>0 && attachMap!=null && attachMap.size()>0){
            for(attachment att : attachmentToInsert){
                if(att.Name.contains('Mother') && string.isNotBlank(student.mother__c) && attachMap.get(student.mother__c)!=null){
                    attachMap.get(student.mother__c).photo__c = '<img src=https://c.cs88.content.force.com/servlet/servlet.FileDownload?file=' + att.Id + ' alt="photo"/>';
                }   
                else if(att.Name.contains('Father') && string.isNotBlank(student.father__c) && attachMap.get(student.father__c)!=null){
                    attachMap.get(student.father__c).photo__c = '<img src=https://c.cs88.content.force.com/servlet/servlet.FileDownload?file=' + att.Id + ' alt="photo"/>';
                }
                else if(att.Name.contains('Guardian') && string.isNotBlank(student.guardian_1__c) && attachMap.get(student.guardian_1__c)!=null){
                    attachMap.get(student.guardian_1__c).photo__c = '<img src=https://c.cs88.content.force.com/servlet/servlet.FileDownload?file=' + att.Id + ' alt="photo"/>';
                }
                else if(att.Name.contains('Student')  && attachMap.get(student.id)!=null){
                    attachMap.get(student.id).photo__c = '<img src=https://c.cs88.content.force.com/servlet/servlet.FileDownload?file=' + att.Id + ' alt="photo"/>';
                }       
            }   
            update attachMap.values();
        }
    }
    
    
    /*
     * name     : updateSRwithStudent
     * param    : step record, Account record
     * return   : void
    */
    public void updateSRandReceiptwithStudent(HexaBPM__Step__c step, Account student){
        list<HexaBPM__Service_Request__c> tempSRList = new list<HexaBPM__Service_Request__c> ();
        tempSRList = [select id, student__c,(select id, HexaBPM__Customer__c from HexaBPM__SR_Docs__r) from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c];   
        if(tempSRList!=null && tempSRList.size()>0){
            tempSRList[0].student__c =    student.id;
            update tempSRList;
            if(tempSRList[0].HexaBPM__SR_Docs__r!=null && tempSRList[0].HexaBPM__SR_Docs__r.size()>0){
                for(HexaBPM__SR_Doc__c obj : tempSRList[0].HexaBPM__SR_Docs__r){
                    obj.HexaBPM__Customer__c = student.id;
                }   
                update tempSRList[0].HexaBPM__SR_Docs__r;
            }
        }
        
        if(step.HexaBPM__SR__r!=null && string.isNotBlank(step.HexaBPM__SR__c)){
          list<Reciept__c> tempRecieptSRList = new list<Reciept__c>();
          tempRecieptSRList = [select id, Account_Student__c from Reciept__c where Service_Request__c =: step.HexaBPM__SR__c];
          if(tempRecieptSRList!=null && tempRecieptSRList.size()>0){
              for(Reciept__c obj : tempRecieptSRList){
                  obj.Account_Student__c = student.id;
              }
              update  tempRecieptSRList;
          }
        }
    }
    
    /*
     * name     : closeOtherLead
     * param    : step record, Account record
     * return   : void
    */
    
    public void closeOtherLeadAndConvertMainLead(HexaBPM__Step__c step, Account student){
        list<lead> tempLeadListWithSR = new list<lead>();   
        list<lead> tempLeadListWithoutSR = new list<lead>();
        for(lead obj : [select id, Status, (select id from Service_Requests__r) 
                        from Lead where curriculum__c =: student.Curriculum_Current__c 
                        and Grade_Display__c =: student.GradeLookup__r.grade__c
                        and academic_year__c =: student.academic_year__c 
                        and Date_of_Birth__c =: student.Date_of_Birth__c 
                        and firstName =: student.firstName 
                        and lastName =: student.lastName]){
            
            if(obj.Service_Requests__r!=null && obj.Service_Requests__r.size()>0){
                tempLeadListWithSR.add(obj);    
            }
            else{
                obj.Status = 'Closed';
                tempLeadListWithoutSR.add(obj);
            }
                            
        }
        if(tempLeadListWithoutSR!=null && tempLeadListWithoutSR.size()>0){
            update tempLeadListWithoutSR;
        }
        if(string.isNotBlank(step.HexaBPM__SR__r.lead__c)){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.ownerid = userinfo.getuserId();
            lc.setLeadId(step.HexaBPM__SR__r.lead__c);
            lc.setConvertedStatus('Enrolled');
            lc.setDoNotCreateOpportunity(true);
            if(student.id != NULL){
                lc.setAccountId(student.id);  //Merge Operation  
            }
            //Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
    }
     
     
    /*
     * name     : createStudentAccountOnApproval
     * param    : step record
     * return   : account with recordTypeStudent
    */
    public Account createStudentAccountOnApproval(HexaBPM__Step__c step ){
        Account student = new Account();
        //custom field update
        student.Academic_Year__c = (step.HexaBPM__SR__r.Academic_Year__c!=null)? step.HexaBPM__SR__r.Academic_Year__c : null;
        student.Join_Academic_Year__c = (step.HexaBPM__SR__r.Academic_Year__c!=null)? step.HexaBPM__SR__r.Academic_Year__c : null;
        student.Agent_Mobile__c = (step.HexaBPM__SR__r.Agent_Mobile__c!=null && step.HexaBPM__SR__r.Agent_Mobile__c!='')? step.HexaBPM__SR__r.Agent_Mobile__c : '';
        student.Agent_Name__c = (step.HexaBPM__SR__r.Agent_Name__c!=null && step.HexaBPM__SR__r.Agent_Name__c!='')? step.HexaBPM__SR__r.Agent_Name__c : '';
        student.Allergies_Notes__c = (step.HexaBPM__SR__r.Allergies_Notes__c!=null && step.HexaBPM__SR__r.Allergies_Notes__c!='')? step.HexaBPM__SR__r.Allergies_Notes__c : '';
        student.Allergies__c = (step.HexaBPM__SR__r.Allergies__c!=null && step.HexaBPM__SR__r.Allergies__c!='')? step.HexaBPM__SR__r.Allergies__c : '';
        student.Any_other_information_related_to_health__c = (step.HexaBPM__SR__r.Any_other_information_related_to_health__c!=null && step.HexaBPM__SR__r.Any_other_information_related_to_health__c!='')? step.HexaBPM__SR__r.Any_other_information_related_to_health__c : '';
        student.Any_sort_of_learning_support_or_therapy__c = (step.HexaBPM__SR__r.Any_sort_of_learning_support_or_therapy__c!=null && step.HexaBPM__SR__r.Any_sort_of_learning_support_or_therapy__c!='')? step.HexaBPM__SR__r.Any_sort_of_learning_support_or_therapy__c : '';
        student.Any_specific_enrichment_activities__c = (step.HexaBPM__SR__r.Any_specific_enrichment_activities__c!=null && step.HexaBPM__SR__r.Any_specific_enrichment_activities__c!='')? step.HexaBPM__SR__r.Any_specific_enrichment_activities__c : '';
        student.Are_there_any_family_circumstances__c = (step.HexaBPM__SR__r.Are_there_any_family_circumstances__c!=null && step.HexaBPM__SR__r.Are_there_any_family_circumstances__c!='')? step.HexaBPM__SR__r.Are_there_any_family_circumstances__c : '';
        student.Behaviour_been_any_cause_for_concern__c = (step.HexaBPM__SR__r.Behaviour_been_any_cause_for_concern__c!=null && step.HexaBPM__SR__r.Behaviour_been_any_cause_for_concern__c!='')? step.HexaBPM__SR__r.Behaviour_been_any_cause_for_concern__c : '';
        student.Child_ever_repeated_failed_a_grade__c = (step.HexaBPM__SR__r.Child_ever_repeated_failed_a_grade__c!=null && step.HexaBPM__SR__r.Child_ever_repeated_failed_a_grade__c!='')? step.HexaBPM__SR__r.Child_ever_repeated_failed_a_grade__c : '';
        student.Child_have_any_special_education_needs__c = (step.HexaBPM__SR__r.Child_have_any_special_education_needs__c!=null && step.HexaBPM__SR__r.Child_have_any_special_education_needs__c!='')? step.HexaBPM__SR__r.Child_have_any_special_education_needs__c : '';
        student.Curriculum_Current__c = (step.HexaBPM__SR__r.Curriculum_Current__c!=null && step.HexaBPM__SR__r.Curriculum_Current__c!='')? step.HexaBPM__SR__r.Curriculum_Current__c : '';
        student.Curriculum_Current__c = (step.HexaBPM__SR__r.Curriculum__c!=null && step.HexaBPM__SR__r.Curriculum__c!='')? step.HexaBPM__SR__r.Curriculum__c : '';
        student.Date_Of_Birth__c = (step.HexaBPM__SR__r.Date_Of_Birth__c!=null)? step.HexaBPM__SR__r.Date_Of_Birth__c : null;
        student.Disabilities_Notes__c = (step.HexaBPM__SR__r.Disabilities_Notes__c!=null && step.HexaBPM__SR__r.Disabilities_Notes__c!='')? step.HexaBPM__SR__r.Disabilities_Notes__c : '';
        student.Disabilities__c = (step.HexaBPM__SR__r.Disabilities__c!=null && step.HexaBPM__SR__r.Disabilities__c!='')? step.HexaBPM__SR__r.Disabilities__c : '';
        student.Do_you_require_school_transportation__c = (step.HexaBPM__SR__r.Do_you_require_school_transportation__c!=null)? step.HexaBPM__SR__r.Do_you_require_school_transportation__c : null;
        student.Emergency_Contact_Number__c = (step.HexaBPM__SR__r.Emergency_Contact_Number__c!=null && step.HexaBPM__SR__r.Emergency_Contact_Number__c!='')? step.HexaBPM__SR__r.Emergency_Contact_Number__c : '';
        student.English_Support_Notes__c = (step.HexaBPM__SR__r.English_Support_Notes__c!=null && step.HexaBPM__SR__r.English_Support_Notes__c!='')? step.HexaBPM__SR__r.English_Support_Notes__c : '';
        student.Extra_Curriculars_child_is_interested_in__c = (step.HexaBPM__SR__r.Extra_Curriculars_child_is_interested_in__c!=null && step.HexaBPM__SR__r.Extra_Curriculars_child_is_interested_in__c!='')? step.HexaBPM__SR__r.Extra_Curriculars_child_is_interested_in__c : '';
        //V1.2
        //student.Fees_Sponsor__c = (step.HexaBPM__SR__r.Fees_Sponsor__c!=null && step.HexaBPM__SR__r.Fees_Sponsor__c!='')? step.HexaBPM__SR__r.Fees_Sponsor__c : '';
        if(step.HexaBPM__SR__r.Fees_Sponsor__c!=null && step.HexaBPM__SR__r.Fees_Sponsor__c!=''){
            student.Fees_Sponsor__c = step.HexaBPM__SR__r.Fees_Sponsor__c;
        } else{
            student.Fees_Sponsor__c = step.HexaBPM__SR__r.Primary_Contact__c;
        }
        //END
        student.Gender__c = (step.HexaBPM__SR__r.Gender__c!=null && step.HexaBPM__SR__r.Gender__c!='')? step.HexaBPM__SR__r.Gender__c : '';
        student.Grade_Year__c = (step.HexaBPM__SR__r.Grade_Year__c!=null && step.HexaBPM__SR__r.Grade_Year__c!='')? step.HexaBPM__SR__r.Grade_Year__c : '';
        student.Join_Grade__c = (step.HexaBPM__SR__r.GradeLookup__c!=null)? step.HexaBPM__SR__r.GradeLookup__c : null;
        student.GradeLookup__c = (step.HexaBPM__SR__r.GradeLookup__c!=null)? step.HexaBPM__SR__r.GradeLookup__c : null;
        student.How_did_you_hear_about_this_GEMS_School__c = (step.HexaBPM__SR__r.How_did_you_hear_about_this_GEMS_School__c!=null && step.HexaBPM__SR__r.How_did_you_hear_about_this_GEMS_School__c!='')? step.HexaBPM__SR__r.How_did_you_hear_about_this_GEMS_School__c : '';
        student.If_chosen_others_please_give_detail__c = (step.HexaBPM__SR__r.If_chosen_others_please_give_detail__c!=null && step.HexaBPM__SR__r.If_chosen_others_please_give_detail__c!='')? step.HexaBPM__SR__r.If_chosen_others_please_give_detail__c : '';
        student.If_separated_divorced_who_has_custody__c = (step.HexaBPM__SR__r.If_separated_divorced_who_has_custody__c!=null && step.HexaBPM__SR__r.If_separated_divorced_who_has_custody__c!='')? step.HexaBPM__SR__r.If_separated_divorced_who_has_custody__c : '';
        student.If_Yes_Which_Grade__c = (step.HexaBPM__SR__r.If_Yes_Which_Grade__c!=null && step.HexaBPM__SR__r.If_Yes_Which_Grade__c!='')? step.HexaBPM__SR__r.If_Yes_Which_Grade__c : '';
        student.If_yes__c = (step.HexaBPM__SR__r.If_yes__c!=null && step.HexaBPM__SR__r.If_yes__c!='')? step.HexaBPM__SR__r.If_yes__c : '';
        student.Is_your_child_musically_proficient__c = (step.HexaBPM__SR__r.Is_your_child_musically_proficient__c!=null && step.HexaBPM__SR__r.Is_your_child_musically_proficient__c!='')? step.HexaBPM__SR__r.Is_your_child_musically_proficient__c : '';
        student.Learning_support_or_therapy_notes__c = (step.HexaBPM__SR__r.Learning_support_or_therapy_notes__c!=null && step.HexaBPM__SR__r.Learning_support_or_therapy_notes__c!='')? step.HexaBPM__SR__r.Learning_support_or_therapy_notes__c : '';
        student.Musically_proficient_notes__c = (step.HexaBPM__SR__r.Musically_proficient_notes__c!=null && step.HexaBPM__SR__r.Musically_proficient_notes__c!='')? step.HexaBPM__SR__r.Musically_proficient_notes__c : '';
        student.Nationality__c = (step.HexaBPM__SR__r.Nationality__c!=null && step.HexaBPM__SR__r.Nationality__c!='')? step.HexaBPM__SR__r.Nationality__c : '';
        student.Other_information_related_to_health_note__c = (step.HexaBPM__SR__r.Other_information_related_to_health_note__c!=null && step.HexaBPM__SR__r.Other_information_related_to_health_note__c!='')? step.HexaBPM__SR__r.Other_information_related_to_health_note__c : '';
        student.Passport_Expiry_Date__c = (step.HexaBPM__SR__r.Passport_Expiry_Date__c!=null)? step.HexaBPM__SR__r.Passport_Expiry_Date__c : null;
        student.Passport_Issue_Date__c = (step.HexaBPM__SR__r.Passport_Issue_Date__c!=null)? step.HexaBPM__SR__r.Passport_Issue_Date__c : null;
        student.Passport_Issue_Place__c = (step.HexaBPM__SR__r.Passport_Issue_Place__c!=null && step.HexaBPM__SR__r.Passport_Issue_Place__c!='')? step.HexaBPM__SR__r.Passport_Issue_Place__c : '';
        student.Passport_No__c = (step.HexaBPM__SR__r.Passport_No__c!=null && step.HexaBPM__SR__r.Passport_No__c!='')? step.HexaBPM__SR__r.Passport_No__c : '';
        student.Physical_Education_Restrictions_Notes__c = (step.HexaBPM__SR__r.Physical_Education_Restrictions_Notes__c!=null && step.HexaBPM__SR__r.Physical_Education_Restrictions_Notes__c!='')? step.HexaBPM__SR__r.Physical_Education_Restrictions_Notes__c : '';
        student.Physical_Education_Restrictions__c = (step.HexaBPM__SR__r.Physical_Education_Restrictions__c!=null && step.HexaBPM__SR__r.Physical_Education_Restrictions__c!='')? step.HexaBPM__SR__r.Physical_Education_Restrictions__c : '';
        //student.P_O_Box_Zip_Code__c = (step.HexaBPM__SR__r.P_O_Box_Zip_Code__c!=null && step.HexaBPM__SR__r.P_O_Box_Zip_Code__c!='')? step.HexaBPM__SR__r.P_O_Box_Zip_Code__c : '';
        student.Referral_Promotion_Code__c = (step.HexaBPM__SR__r.Referral_Promotion_Code__c!=null && step.HexaBPM__SR__r.Referral_Promotion_Code__c!='')? step.HexaBPM__SR__r.Referral_Promotion_Code__c : '';
        student.Religion__c = (step.HexaBPM__SR__r.Religion__c!=null && step.HexaBPM__SR__r.Religion__c!='')? step.HexaBPM__SR__r.Religion__c : '';
        student.School_Name__c = (step.HexaBPM__SR__r.School_Name__c!=null && step.HexaBPM__SR__r.School_Name__c!='')? step.HexaBPM__SR__r.School_Name__c : '';
        student.School__c = (step.HexaBPM__SR__r.School__c!=null)? step.HexaBPM__SR__r.School__c : null;
        student.Special_Education_Needs_Note__c = (step.HexaBPM__SR__r.Special_Education_Needs_Note__c!=null && step.HexaBPM__SR__r.Special_Education_Needs_Note__c!='')? step.HexaBPM__SR__r.Special_Education_Needs_Note__c : '';
        student.Special_Medication_Notes__c = (step.HexaBPM__SR__r.Special_Medication_Notes__c!=null && step.HexaBPM__SR__r.Special_Medication_Notes__c!='')? step.HexaBPM__SR__r.Special_Medication_Notes__c : '';
        student.Special_Medication__c = (step.HexaBPM__SR__r.Special_Medication__c!=null && step.HexaBPM__SR__r.Special_Medication__c!='')? step.HexaBPM__SR__r.Special_Medication__c : '';
        student.Specific_enrichment_activities_notes__c = (step.HexaBPM__SR__r.Specific_enrichment_activities_notes__c!=null && step.HexaBPM__SR__r.Specific_enrichment_activities_notes__c!='')? step.HexaBPM__SR__r.Specific_enrichment_activities_notes__c : '';
        student.Sports_child_is_interested_in__c = (step.HexaBPM__SR__r.Sports_child_is_interested_in__c!=null && step.HexaBPM__SR__r.Sports_child_is_interested_in__c!='')? step.HexaBPM__SR__r.Sports_child_is_interested_in__c : '';
        student.Stream__c = (step.HexaBPM__SR__r.Stream__c!=null && step.HexaBPM__SR__r.Stream__c!='')? step.HexaBPM__SR__r.Stream__c : '';
        student.Join_Stream__c = (step.HexaBPM__SR__r.Stream__c!=null && step.HexaBPM__SR__r.Stream__c!='')? step.HexaBPM__SR__r.Stream__c : '';
        student.Student_Id_Prev__c = (step.HexaBPM__SR__r.Student_Id__c!=null && step.HexaBPM__SR__r.Student_Id__c!='')? step.HexaBPM__SR__r.Student_Id__c : '';
        student.Student_require_English_support__c = (step.HexaBPM__SR__r.Student_require_English_support__c!=null && step.HexaBPM__SR__r.Student_require_English_support__c!='')? step.HexaBPM__SR__r.Student_require_English_support__c : '';
        student.Tentative_Joining_Date__c = (step.HexaBPM__SR__r.Tentative_Joining_Date__c!=null)? step.HexaBPM__SR__r.Tentative_Joining_Date__c : null;
        student.Country_Previous_School__c = (step.HexaBPM__SR__r.Country_Previous_School__c!=null && step.HexaBPM__SR__r.Country_Previous_School__c!='')? step.HexaBPM__SR__r.Country_Previous_School__c : '';
        student.Visa_Expiry_Date__c = (step.HexaBPM__SR__r.Visa_Expiry_Date__c!=null)? step.HexaBPM__SR__r.Visa_Expiry_Date__c : null;
        student.Visa_Issue_Date__c = (step.HexaBPM__SR__r.Visa_Issue_Date__c!=null)? step.HexaBPM__SR__r.Visa_Issue_Date__c : null;
        student.Visa_No__c = (step.HexaBPM__SR__r.Visa_No__c!=null && step.HexaBPM__SR__r.Visa_No__c!='')? step.HexaBPM__SR__r.Visa_No__c : '';
        student.First_Language__c = (step.HexaBPM__SR__r.First_Language__c!=null && step.HexaBPM__SR__r.First_Language__c!='')? step.HexaBPM__SR__r.First_Language__c : '';
        //V1.1
        student.Second_Language__c = (step.HexaBPM__SR__r.Second_Language__c!=null && step.HexaBPM__SR__r.Second_Language__c!='')? step.HexaBPM__SR__r.Second_Language__c : '';
        //End
        student.Siblings_studying_in_a_GEMS_school__c =  step.HexaBPM__SR__r.Siblings_studying_in_a_GEMS_school__c;
        student.Primary_Contact__c = (step.HexaBPM__SR__r.Primary_Contact__c!=null && step.HexaBPM__SR__r.Primary_Contact__c!='')? step.HexaBPM__SR__r.Primary_Contact__c : '';
        student.sys_fromSRClosure__c = true;
        student.GEMS_has_permission__c = step.HexaBPM__SR__r.GEMS_has_permission__c;
        student.Publication_Promotion_Photos_Videos__c = step.HexaBPM__SR__r.Publication_Promotion_Photos_and_Video__c;
        student.Student_Id__c = (step.HexaBPM__SR__r.StudentId__c!=null && step.HexaBPM__SR__r.StudentId__c!='')? step.HexaBPM__SR__r.StudentId__c : '';
        student.Arabic_Name__c = (step.HexaBPM__SR__r.Arabic_Name_in_Emirates_ID__c!=null && step.HexaBPM__SR__r.Arabic_Name_in_Emirates_ID__c!='')? step.HexaBPM__SR__r.Arabic_Name_in_Emirates_ID__c : '';                    
        student.Emirates_Full_Name__c = (step.HexaBPM__SR__r.Name_in_Emirates_ID__c!=null && step.HexaBPM__SR__r.Name_in_Emirates_ID__c!='')? step.HexaBPM__SR__r.Name_in_Emirates_ID__c : '';
        student.Place_of_Birth__c = (step.HexaBPM__SR__r.Place_of_Birth__c!=null && step.HexaBPM__SR__r.Place_of_Birth__c!='')? step.HexaBPM__SR__r.Place_of_Birth__c : '';
        student.Emirates_ID__c = (step.HexaBPM__SR__r.Emirates_ID__c!=null && step.HexaBPM__SR__r.Emirates_ID__c!='')? step.HexaBPM__SR__r.Emirates_ID__c : '';
        student.Emirates_ID_Expiry_Date__c = (step.HexaBPM__SR__r.Emirates_ID_Expiry_Date__c!=null)? step.HexaBPM__SR__r.Emirates_ID_Expiry_Date__c : null;
        student.Emirates_ID_Issue_Date__c = (step.HexaBPM__SR__r.Emirates_ID_Issue_Date__c!=null)? step.HexaBPM__SR__r.Emirates_ID_Issue_Date__c : null;
        student.Emirates_ID_Synced_Date__c = (step.HexaBPM__SR__r.Last_Emirates_ID_Sync_Date__c!=null)? step.HexaBPM__SR__r.Last_Emirates_ID_Sync_Date__c : null;
        student.Sibling_ID__c = (step.HexaBPM__SR__r.Sibling_Fee_ID__c!=null)? step.HexaBPM__SR__r.Sibling_Fee_ID__c: null;
        student.Date_of_Join_Ministry__c= (step.HexaBPM__SR__r.Joining_Date__c!=null)? step.HexaBPM__SR__r.Joining_Date__c: null;
        student.Date_of_Join__c= (step.HexaBPM__SR__r.Joining_Date__c!=null)? step.HexaBPM__SR__r.Joining_Date__c: null;
        student.MOE_Reg__c= (step.HexaBPM__SR__r.fee_id__c!=null)? step.HexaBPM__SR__r.fee_id__c: null;
        student.sys_Enrollment_SR_No__c= (step.HexaBPM__SR__r.name!=null)? step.HexaBPM__SR__r.name: null;
        
        student.recordTypeID = GEMS_Utility.getRecordTypeId('Account','Student');
        student.firstName =  (step.HexaBPM__SR__r.first_name__c!=null && step.HexaBPM__SR__r.first_name__c!='')? step.HexaBPM__SR__r.first_name__c : '';
        student.lastName =  (step.HexaBPM__SR__r.last_name__c!=null && step.HexaBPM__SR__r.last_name__c!='')? step.HexaBPM__SR__r.last_name__c : '';
        student.Pending_Offer_Reasons__c =  (step.HexaBPM__SR__r.Pending_Offer_Reasons__c!=null && step.HexaBPM__SR__r.Pending_Offer_Reasons__c!='')? step.HexaBPM__SR__r.Pending_Offer_Reasons__c : '';
        student.Pending_Offer_Conditions__c = step.HexaBPM__SR__r.Pending_Offer_Conditions__c;
        student.fee_id__c =  (step.HexaBPM__SR__r.fee_id__c!=null && step.HexaBPM__SR__r.fee_id__c!='')? step.HexaBPM__SR__r.fee_id__c : '';
        student.Transfer_Type__c =  (step.HexaBPM__SR__r.Transfer_Type__c!=null && step.HexaBPM__SR__r.Transfer_Type__c!='')? step.HexaBPM__SR__r.Transfer_Type__c : '';
        
        student.MAP_Language__c =  (step.HexaBPM__SR__r.MAP_Language__c!=null && step.HexaBPM__SR__r.MAP_Language__c!='')? step.HexaBPM__SR__r.MAP_Language__c : '';
        student.MAP_Math__c =  (step.HexaBPM__SR__r.MAP_Math__c!=null && step.HexaBPM__SR__r.MAP_Math__c!='')? step.HexaBPM__SR__r.MAP_Math__c : '';
        student.MAP_Reading__c =  (step.HexaBPM__SR__r.MAP_Reading__c!=null && step.HexaBPM__SR__r.MAP_Reading__c!='')? step.HexaBPM__SR__r.MAP_Reading__c : '';
        student.CAT4_level_completed__c =  (step.HexaBPM__SR__r.CAT4_level_completed__c!=null)? step.HexaBPM__SR__r.CAT4_level_completed__c : null;
        student.Nonverbal_CAT4__c =  (step.HexaBPM__SR__r.Nonverbal_CAT4__c!=null)? step.HexaBPM__SR__r.Nonverbal_CAT4__c : null;
        student.Overall_CAT4__c =  (step.HexaBPM__SR__r.Overall_CAT4__c!=null)? step.HexaBPM__SR__r.Overall_CAT4__c : null;
        student.Quantitate_CAT4__c =  (step.HexaBPM__SR__r.Quantitate_CAT4__c!=null)? step.HexaBPM__SR__r.Quantitate_CAT4__c : null;
        student.Spatial_CAT4__c =  (step.HexaBPM__SR__r.Spatial_CAT4__c!=null)? step.HexaBPM__SR__r.Spatial_CAT4__c : null;
        student.Verbal_CAT4__c =  (step.HexaBPM__SR__r.Verbal_CAT4__c!=null)? step.HexaBPM__SR__r.Verbal_CAT4__c : null;
        student.Current_Status__c = 'EN';
        student.Exclude_Fees__c = step.HexaBPM__SR__r.Exclude_Fees__c;
        student.Fee_Exclusion_Reason__c = (step.HexaBPM__SR__r.Fee_Exclusion_Reason__c!=null && step.HexaBPM__SR__r.Fee_Exclusion_Reason__c!='')? step.HexaBPM__SR__r.Fee_Exclusion_Reason__c : '';
        student.Ministry_List__c = 'Observer';
        student.Other_Previous_School__c = (step.HexaBPM__SR__r.Other_Previous_School__c!=null && step.HexaBPM__SR__r.Other_Previous_School__c!='')? step.HexaBPM__SR__r.Other_Previous_School__c : '';
        student.Referral_School__c = step.HexaBPM__SR__r.Referral_School__c!=null?step.HexaBPM__SR__r.Referral_School__c:null;
        student.Referral_Student__c = step.HexaBPM__SR__r.Referral_Student__c!=null?step.HexaBPM__SR__r.Referral_Student__c:null;
        student.Reward_Type__c = step.HexaBPM__SR__r.RewardType__c;
        student.Referral_Email__c = step.HexaBPM__SR__r.Referral_Email__c;
        //student.Referring_Parent__c = step.HexaBPM__SR__r.Referring_Parent__c;
        //student.Eligible_for_Referral_Program__c = step.HexaBPM__SR__r.Eligible_for_Referral_Program__c;
        //student.Employee__c    = step.HexaBPM__SR__r.Employee__c;
        student.VIP_Placement__c = step.HexaBPM__SR__r.VIP_Placement__c;
                    
        if(student.Primary_Contact__c == 'Father'){
            student.Primary_Contact_Email__c = (step.HexaBPM__SR__r.Email_Father__c!=null && step.HexaBPM__SR__r.Email_Father__c!='')? step.HexaBPM__SR__r.Email_Father__c : null;
            student.primary_contact_name__c = step.HexaBPM__SR__r.First_Name_Father__c+ ' ' +step.HexaBPM__SR__r.Last_Name_Father__c;
        }
        else if(student.Primary_Contact__c == 'Mother'){
            student.Primary_Contact_Email__c = (step.HexaBPM__SR__r.Email_Mother__c!=null && step.HexaBPM__SR__r.Email_Mother__c!='')? step.HexaBPM__SR__r.Email_Mother__c : null;
            student.primary_contact_name__c = step.HexaBPM__SR__r.First_Name_Mother__c+ ' ' +step.HexaBPM__SR__r.Last_Name_Mother__c;
        }
        else if(student.Primary_Contact__c == 'Guardian'){
            student.Primary_Contact_Email__c = (step.HexaBPM__SR__r.Email_Guardian__c!=null && step.HexaBPM__SR__r.Email_Guardian__c!='')? step.HexaBPM__SR__r.Email_Guardian__c : null;
            student.primary_contact_name__c = step.HexaBPM__SR__r.First_Name_Guardian__c+ ' ' +step.HexaBPM__SR__r.Last_Name_Guardian__c;
        }
        
        if(step.HexaBPM__SR__r.school__c!=null && step.HexaBPM__SR__r.Academic_Year__c!=null && step.HexaBPM__SR__r.GradeLookup__c!=null){
            list<Section_Master__c> tempSectionList = new   list<Section_Master__c>();
            tempSectionList = [select id from Section_Master__c where School__c=:step.HexaBPM__SR__r.school__c and
                               Grade__c=:step.HexaBPM__SR__r.GradeLookup__c and Academic_Year__c=:step.HexaBPM__SR__r.Academic_Year__c and Section__c='TEMP'];
        
            if(tempSectionList!=null && tempSectionList.size()>0){
                student.Section__c = tempSectionList[0].id; 
            }
        }
         //V1.3
        student.Is_the_child_gifted_and_talented__c = step.HexaBPM__SR__r.Is_the_child_gifted_and_talented__c;
        student.SEND_Wave__c = step.HexaBPM__SR__r.SEND_Wave__c;
        student.SEND_Category__c = step.HexaBPM__SR__r.SEND_Category__c;
        student.ELL_Wave__c = step.HexaBPM__SR__r.ELL_Wave__c;
        //V1.3 ends
        
        //V1.4
        student.ARP_Client__c = step.HexaBPM__SR__r.ARP_Client__c;
        //V1.4 ends
        insert student;
        return student;
    }
    
    
    /*
     * name     : createParentGuardianAccountOnApproval
     * param    : step record
     * return   : list of account for parent and guardian
    */
    public list<Account> createParentGuardianAccountOnApproval(HexaBPM__Step__c step, Account student){
        
        map<string,Account> existingFatherMap = new map<string,Account>();
        map<string,Account> existingMotherMap = new map<string,Account>();
        system.debug('---step.HexaBPM__SR__r.Sibling_Fee_ID__c----'+step.HexaBPM__SR__r.Sibling_Fee_ID__c);
        
        list<Account> parentGuardianListToInsert = new list<Account>();
        
        if(string.isNotBlank(step.HexaBPM__SR__r.Sibling_Fee_ID__c)){
            for(Account obj : [select id, Student_Id__c,father__c, mother__c, Record_Type_Name__c,
                                      firstName, lastName, role__c,primary_contact__c,Master_Student__c,
                                      Primary_Contact_Email__c, Primary_Contact_Name__c, Emergency_Contact_Number__c
                               from Account 
                               where school__c=:step.HexaBPM__SR__r.school__c
                               and id!=:student.id
                               and (Record_Type_Name__c = 'Student' or Record_Type_Name__c = 'Parent_Guardian' or Record_Type_Name__c = 'Student_Read_Only')
                               and (Master_Student__c=:step.HexaBPM__SR__r.Sibling_Fee_ID__c or Sibling_ID__c=:step.HexaBPM__SR__r.Sibling_Fee_ID__c)]){
                
                if(obj.Record_Type_Name__c == 'Parent_Guardian'){
                    if(obj.role__c == 'Father')
                        existingFatherMap.put(obj.Master_Student__c,obj);   
                        
                    if(obj.role__c == 'Mother')
                        existingMotherMap.put(obj.Master_Student__c,obj);   
                }
                
                if(obj.Record_Type_Name__c == 'Student'){
                    existingSiblingMap.put(obj.id,obj);     
                }
            }       
        }
        
        system.debug('---existingFatherMap----'+existingFatherMap);
        system.debug('---existingMotherMap----'+existingMotherMap);
        
        Account fatherAccount = new Account();
        if(string.isNotBlank(step.HexaBPM__SR__r.Sibling_Fee_ID__c) && 
           existingFatherMap!=null && existingFatherMap.size()>0 &&
           existingFatherMap.get(step.HexaBPM__SR__r.Sibling_Fee_ID__c)!=null){
                fatherAccount = existingFatherMap.get(step.HexaBPM__SR__r.Sibling_Fee_ID__c);
        }
        system.debug('---fatherAccount----'+fatherAccount);
        if(fatherAccount!=null && fatherAccount.id!=null){
            parentGuardianListToInsert.add(fatherAccount);
        }else{
            if(string.isNotBlank(step.HexaBPM__SR__r.Last_Name_Father__c)){
                fatherAccount.Master_Student__c = student.sibling_id__c;        
                fatherAccount.recordTypeID = GEMS_Utility.getRecordTypeId('Account','Parent_Guardian');
                fatherAccount.firstName =  (step.HexaBPM__SR__r.First_Name_Father__c!=null && step.HexaBPM__SR__r.First_Name_Father__c!='')? step.HexaBPM__SR__r.First_Name_Father__c : '';
                fatherAccount.lastName =  (step.HexaBPM__SR__r.Last_Name_Father__c!=null && step.HexaBPM__SR__r.Last_Name_Father__c!='')? step.HexaBPM__SR__r.Last_Name_Father__c : '';
                fatherAccount.role__c = 'Father';
                fatherAccount.PersonEmail = (step.HexaBPM__SR__r.Email_Father__c!=null && step.HexaBPM__SR__r.Email_Father__c!='')? step.HexaBPM__SR__r.Email_Father__c : null;
                
                fatherAccount.Apartment_No__c = (step.HexaBPM__SR__r.Apartment_No__c!=null && step.HexaBPM__SR__r.Apartment_No__c!='')? step.HexaBPM__SR__r.Apartment_No__c : '';
                fatherAccount.Area__c = (step.HexaBPM__SR__r.Area__c!=null && step.HexaBPM__SR__r.Area__c!='')? step.HexaBPM__SR__r.Area__c : '';
                fatherAccount.Business_Unit__c = (step.HexaBPM__SR__r.Sys_Business_Unit_Father__c!=null)? step.HexaBPM__SR__r.Sys_Business_Unit_Father__c : null;
               // fatherAccount.City_Emirate__c = (step.HexaBPM__SR__r.City_Emirate__c!=null && step.HexaBPM__SR__r.City_Emirate__c!='')? step.HexaBPM__SR__r.City_Emirate__c : '';
                fatherAccount.City_State__c = (step.HexaBPM__SR__r.City_Emirate__c!=null && step.HexaBPM__SR__r.City_Emirate__c!='')? step.HexaBPM__SR__r.City_Emirate__c : '';
                fatherAccount.Company__c = (step.HexaBPM__SR__r.Company__c!=null && step.HexaBPM__SR__r.Company__c!='')? step.HexaBPM__SR__r.Company__c : '';
                fatherAccount.Company_lookup__c = (step.HexaBPM__SR__r.Company_lookup_father__c!=null)? step.HexaBPM__SR__r.Company_lookup_father__c : null;
                fatherAccount.Country__c = (step.HexaBPM__SR__r.Country__c!=null && step.HexaBPM__SR__r.Country__c!='')? step.HexaBPM__SR__r.Country__c : '';
                fatherAccount.Building__c = (step.HexaBPM__SR__r.Building__c!=null && step.HexaBPM__SR__r.Building__c!='')? step.HexaBPM__SR__r.Building__c : '';
                fatherAccount.GEMS_School__c = (step.HexaBPM__SR__r.Sys_GEMS_School_Father__c!=null)? step.HexaBPM__SR__r.Sys_GEMS_School_Father__c : null;
                fatherAccount.PersonHomePhone = (step.HexaBPM__SR__r.Home_Phone__c!=null && step.HexaBPM__SR__r.Home_Phone__c!='')? step.HexaBPM__SR__r.Home_Phone__c : '';
                fatherAccount.Makani__c = (step.HexaBPM__SR__r.Makani__c!=null)? step.HexaBPM__SR__r.Makani__c : null;
                fatherAccount.PersonMobilePhone = (step.HexaBPM__SR__r.Mobile__c!=null && step.HexaBPM__SR__r.Mobile__c!='')? step.HexaBPM__SR__r.Mobile__c : '';
                fatherAccount.Occupation__c = (step.HexaBPM__SR__r.Occupation__c!=null && step.HexaBPM__SR__r.Occupation__c!='')? step.HexaBPM__SR__r.Occupation__c : '';
                fatherAccount.Office_Phone__c = (step.HexaBPM__SR__r.Office_Phone__c!=null && step.HexaBPM__SR__r.Office_Phone__c!='')? step.HexaBPM__SR__r.Office_Phone__c : '';
                fatherAccount.P_O_Box__c = (step.HexaBPM__SR__r.P_O_Box__c!=null && step.HexaBPM__SR__r.P_O_Box__c!='')? step.HexaBPM__SR__r.P_O_Box__c : '';
                fatherAccount.Staff_ID__c = (step.HexaBPM__SR__r.Staff_ID__c!=null)? step.HexaBPM__SR__r.Staff_ID__c : null;
                fatherAccount.Street__c = (step.HexaBPM__SR__r.Street__c!=null && step.HexaBPM__SR__r.Street__c!='')? step.HexaBPM__SR__r.Street__c : '';
                fatherAccount.Is_primary_contact_employee_of_GEMS__c = (step.HexaBPM__SR__r.Is_father_of_Student_an_employee_in_GEMS__c!=null && step.HexaBPM__SR__r.Is_father_of_Student_an_employee_in_GEMS__c!='')? step.HexaBPM__SR__r.Is_father_of_Student_an_employee_in_GEMS__c : '';
                fatherAccount.Is_primary_contact_ex_student_of_GEMS__c = (step.HexaBPM__SR__r.Is_father_of_Student_an_Ex_Student__c!=null && step.HexaBPM__SR__r.Is_father_of_Student_an_Ex_Student__c!='')? step.HexaBPM__SR__r.Is_father_of_Student_an_Ex_Student__c : '';    
                fatherAccount.Academic_Year_Parent__c = (step.HexaBPM__SR__r.Academic_Year_Ex__c!=null && step.HexaBPM__SR__r.Academic_Year_Ex__c!='')? step.HexaBPM__SR__r.Academic_Year_Ex__c : '';   
                fatherAccount.sys_fromSRClosure__c = true; 
                
                fatherAccount.Arabic_Name__c = (step.HexaBPM__SR__r.Father_Arabic_Name_in_Emirates_ID__c!=null && step.HexaBPM__SR__r.Father_Arabic_Name_in_Emirates_ID__c!='')? step.HexaBPM__SR__r.Father_Arabic_Name_in_Emirates_ID__c : '';                 
                fatherAccount.Emirates_Full_Name__c = (step.HexaBPM__SR__r.Father_Name_in_Emirates_ID__c!=null && step.HexaBPM__SR__r.Father_Name_in_Emirates_ID__c!='')? step.HexaBPM__SR__r.Father_Name_in_Emirates_ID__c : '';
                fatherAccount.Place_of_Birth__c = (step.HexaBPM__SR__r.Place_of_Birth__c!=null && step.HexaBPM__SR__r.Place_of_Birth__c!='')? step.HexaBPM__SR__r.Place_of_Birth__c : '';
                fatherAccount.Emirates_ID__c = (step.HexaBPM__SR__r.Emirates_ID_Father__c!=null && step.HexaBPM__SR__r.Emirates_ID_Father__c!='')? step.HexaBPM__SR__r.Emirates_ID_Father__c : '';
                fatherAccount.Emirates_ID_Expiry_Date__c = (step.HexaBPM__SR__r.Emirates_ID_Expire_Date_Father__c!=null)? step.HexaBPM__SR__r.Emirates_ID_Expire_Date_Father__c : null;
                fatherAccount.Emirates_ID_Issue_Date__c = (step.HexaBPM__SR__r.Emirates_ID_Issue_Date__c!=null)? step.HexaBPM__SR__r.Emirates_ID_Issue_Date__c : null;
                fatherAccount.Emirates_ID_Synced_Date__c = (step.HexaBPM__SR__r.Last_Emirates_ID_Sync_Date_Father__c!=null)? step.HexaBPM__SR__r.Last_Emirates_ID_Sync_Date_Father__c : null;
                fatherAccount.Other_Company__c = (step.HexaBPM__SR__r.Other_Company_Father__c!=null)? step.HexaBPM__SR__r.Other_Company_Father__c : '';
                fatherAccount.Other_Area__c = (step.HexaBPM__SR__r.Father_Other_Area__c!=null)? step.HexaBPM__SR__r.Father_Other_Area__c : '';
                fatherAccount.Other_City_State__c = (step.HexaBPM__SR__r.Father_Other_City_State__c!=null)? step.HexaBPM__SR__r.Father_Other_City_State__c : '';
                fatherAccount.School__c = (step.HexaBPM__SR__r.School__c!=null)? step.HexaBPM__SR__r.School__c : null;
            
                parentGuardianListToInsert.add(fatherAccount);
            }
        }
    
        Account motherAccount = new Account();
        if(string.isNotBlank(step.HexaBPM__SR__r.Sibling_Fee_ID__c) && 
           existingMotherMap!=null && existingMotherMap.size()>0 &&
           existingMotherMap.get(step.HexaBPM__SR__r.Sibling_Fee_ID__c)!=null){
            
            motherAccount = existingMotherMap.get(step.HexaBPM__SR__r.Sibling_Fee_ID__c);
        }
        
        system.debug('---motherAccount----'+motherAccount);
        if(motherAccount!=null && motherAccount.id!=null){
            parentGuardianListToInsert.add(motherAccount);  
        }else{
            if(string.isNotBlank(step.HexaBPM__SR__r.Last_Name_Mother__c)){
                motherAccount.Master_Student__c = student.sibling_id__c;        
                motherAccount.recordTypeID = GEMS_Utility.getRecordTypeId('Account','Parent_Guardian');
                motherAccount.firstName =  (step.HexaBPM__SR__r.First_Name_Mother__c!=null && step.HexaBPM__SR__r.First_Name_Mother__c!='')? step.HexaBPM__SR__r.First_Name_Mother__c : '';
                motherAccount.lastName =  (step.HexaBPM__SR__r.Last_Name_Mother__c!=null && step.HexaBPM__SR__r.Last_Name_Mother__c!='')? step.HexaBPM__SR__r.Last_Name_Mother__c : '';
                motherAccount.role__c = 'Mother';
                motherAccount.PersonEmail = (step.HexaBPM__SR__r.Email_Mother__c!=null && step.HexaBPM__SR__r.Email_Mother__c!='')? step.HexaBPM__SR__r.Email_Mother__c : '';
                motherAccount.Apartment_No__c = (step.HexaBPM__SR__r.Apartment_No_Mother__c!=null && step.HexaBPM__SR__r.Apartment_No_Mother__c!='')? step.HexaBPM__SR__r.Apartment_No_Mother__c : '';
                motherAccount.Area__c = (step.HexaBPM__SR__r.Area_Mother__c!=null && step.HexaBPM__SR__r.Area_Mother__c!='')? step.HexaBPM__SR__r.Area_Mother__c : '';
                motherAccount.Business_Unit__c = (step.HexaBPM__SR__r.Sys_Business_Unit_Mother__c!=null)? step.HexaBPM__SR__r.Sys_Business_Unit_Mother__c : null;
                //motherAccount.City_Emirate__c = (step.HexaBPM__SR__r.City_Emirate_Mother__c!=null && step.HexaBPM__SR__r.City_Emirate_Mother__c!='')? step.HexaBPM__SR__r.City_Emirate_Mother__c : '';
                motherAccount.City_State__c = (step.HexaBPM__SR__r.City_Emirate_Mother__c!=null && step.HexaBPM__SR__r.City_Emirate_Mother__c!='')? step.HexaBPM__SR__r.City_Emirate_Mother__c : '';
                motherAccount.Company__c = (step.HexaBPM__SR__r.Company_Mother__c!=null && step.HexaBPM__SR__r.Company_Mother__c!='')? step.HexaBPM__SR__r.Company_Mother__c : '';
                motherAccount.Company_lookup__c = (step.HexaBPM__SR__r.Company_lookup_Mother__c!=null)? step.HexaBPM__SR__r.Company_lookup_Mother__c : null;
                motherAccount.Country__c = (step.HexaBPM__SR__r.Country_Mother__c!=null && step.HexaBPM__SR__r.Country_Mother__c!='')? step.HexaBPM__SR__r.Country_Mother__c : '';
                motherAccount.Building__c = (step.HexaBPM__SR__r.Building_Mother__c!=null && step.HexaBPM__SR__r.Building_Mother__c!='')? step.HexaBPM__SR__r.Building_Mother__c : '';
                motherAccount.GEMS_School__c = (step.HexaBPM__SR__r.Sys_GEMS_School_Mother__c!=null)? step.HexaBPM__SR__r.Sys_GEMS_School_Mother__c : null;
                motherAccount.PersonHomePhone = (step.HexaBPM__SR__r.Home_Phone_Mother__c!=null && step.HexaBPM__SR__r.Home_Phone_Mother__c!='')? step.HexaBPM__SR__r.Home_Phone_Mother__c : '';
                motherAccount.Makani__c = (step.HexaBPM__SR__r.Makani_Mother__c!=null)? step.HexaBPM__SR__r.Makani_Mother__c : null;
                motherAccount.PersonMobilePhone = (step.HexaBPM__SR__r.Mobile_Mother__c!=null && step.HexaBPM__SR__r.Mobile_Mother__c!='')? step.HexaBPM__SR__r.Mobile_Mother__c : '';
                motherAccount.Occupation__c = (step.HexaBPM__SR__r.Occupation_Mother__c!=null && step.HexaBPM__SR__r.Occupation_Mother__c!='')? step.HexaBPM__SR__r.Occupation_Mother__c : '';
                motherAccount.Office_Phone__c = (step.HexaBPM__SR__r.Office_Phone_Mother__c!=null && step.HexaBPM__SR__r.Office_Phone_Mother__c!='')? step.HexaBPM__SR__r.Office_Phone_Mother__c : '';
                motherAccount.P_O_Box__c = (step.HexaBPM__SR__r.P_O_Box_Mother__c!=null && step.HexaBPM__SR__r.P_O_Box_Mother__c!='')? step.HexaBPM__SR__r.P_O_Box_Mother__c : '';
                motherAccount.Staff_ID__c = (step.HexaBPM__SR__r.Staff_ID_Mother__c!=null)? step.HexaBPM__SR__r.Staff_ID_Mother__c : null;
                motherAccount.Street__c = (step.HexaBPM__SR__r.Street_Mother__c!=null && step.HexaBPM__SR__r.Street_Mother__c!='')? step.HexaBPM__SR__r.Street_Mother__c : '';
                motherAccount.Is_primary_contact_employee_of_GEMS__c = (step.HexaBPM__SR__r.Is_mother_of_Student_an_employee_in_GEMS__c!=null && step.HexaBPM__SR__r.Is_mother_of_Student_an_employee_in_GEMS__c!='')? step.HexaBPM__SR__r.Is_mother_of_Student_an_employee_in_GEMS__c : '';
                motherAccount.Is_primary_contact_ex_student_of_GEMS__c = (step.HexaBPM__SR__r.Is_mother_of_Student_an_Ex_Student__c!=null && step.HexaBPM__SR__r.Is_mother_of_Student_an_Ex_Student__c!='')? step.HexaBPM__SR__r.Is_mother_of_Student_an_Ex_Student__c : '';    
                motherAccount.Academic_Year_Parent__c = (step.HexaBPM__SR__r.Academic_Year_Ex_Mother__c!=null && step.HexaBPM__SR__r.Academic_Year_Ex_Mother__c!='')? step.HexaBPM__SR__r.Academic_Year_Ex_Mother__c : '';  
                motherAccount.sys_fromSRClosure__c = true;
                
                motherAccount.Arabic_Name__c = (step.HexaBPM__SR__r.Mother_Arabic_Name_in_Emriates_ID__c!=null && step.HexaBPM__SR__r.Mother_Arabic_Name_in_Emriates_ID__c!='')? step.HexaBPM__SR__r.Mother_Arabic_Name_in_Emriates_ID__c : '';                 
                motherAccount.Emirates_Full_Name__c = (step.HexaBPM__SR__r.Mother_Name_in_Emirates_ID__c!=null && step.HexaBPM__SR__r.Mother_Name_in_Emirates_ID__c!='')? step.HexaBPM__SR__r.Mother_Name_in_Emirates_ID__c : '';
                motherAccount.Place_of_Birth__c = (step.HexaBPM__SR__r.Place_of_Birth__c!=null && step.HexaBPM__SR__r.Place_of_Birth__c!='')? step.HexaBPM__SR__r.Place_of_Birth__c : '';
                motherAccount.Emirates_ID__c = (step.HexaBPM__SR__r.Emirates_ID_Mother__c!=null && step.HexaBPM__SR__r.Emirates_ID_Mother__c!='')? step.HexaBPM__SR__r.Emirates_ID_Mother__c : '';
                motherAccount.Emirates_ID_Expiry_Date__c = (step.HexaBPM__SR__r.Emirates_ID_Expire_Date_Mother__c!=null)? step.HexaBPM__SR__r.Emirates_ID_Expire_Date_Mother__c : null;
                motherAccount.Emirates_ID_Issue_Date__c = (step.HexaBPM__SR__r.Emirates_ID_Issue_Date__c!=null)? step.HexaBPM__SR__r.Emirates_ID_Issue_Date__c : null;
                motherAccount.Emirates_ID_Synced_Date__c = (step.HexaBPM__SR__r.Last_Emirates_ID_Sync_Date_Mother__c!=null)? step.HexaBPM__SR__r.Last_Emirates_ID_Sync_Date_Mother__c : null;
                motherAccount.Other_Company__c = (step.HexaBPM__SR__r.Other_Company_Mother__c!=null)? step.HexaBPM__SR__r.Other_Company_Mother__c : '';
                motherAccount.Other_Area__c = (step.HexaBPM__SR__r.Mother_Other_Area__c!=null)? step.HexaBPM__SR__r.Mother_Other_Area__c : '';
                motherAccount.Other_City_State__c = (step.HexaBPM__SR__r.Mother_Other_City_State__c!=null)? step.HexaBPM__SR__r.Mother_Other_City_State__c : '';
                motherAccount.School__c = (step.HexaBPM__SR__r.School__c!=null)? step.HexaBPM__SR__r.School__c : null;
            
                parentGuardianListToInsert.add(motherAccount);
            }
        }
        
        if(string.isNotBlank(step.HexaBPM__SR__r.Last_Name_Guardian__c)){
            Account guardianAccount = new Account();
            guardianAccount.Master_Student__c = student.sibling_id__c; 
            guardianAccount.recordTypeID = GEMS_Utility.getRecordTypeId('Account','Parent_Guardian');
            guardianAccount.firstName =  (step.HexaBPM__SR__r.First_Name_Guardian__c!=null && step.HexaBPM__SR__r.First_Name_Guardian__c!='')? step.HexaBPM__SR__r.First_Name_Guardian__c : '';
            guardianAccount.lastName =  (step.HexaBPM__SR__r.Last_Name_Guardian__c!=null && step.HexaBPM__SR__r.Last_Name_Guardian__c!='')? step.HexaBPM__SR__r.Last_Name_Guardian__c : '';
            guardianAccount.role__c = 'Guardian';
            guardianAccount.PersonEmail = (step.HexaBPM__SR__r.Email_Guardian__c!=null && step.HexaBPM__SR__r.Email_Guardian__c!='')? step.HexaBPM__SR__r.Email_Guardian__c : '';
            guardianAccount.Apartment_No__c = (step.HexaBPM__SR__r.Apartment_No_Guardian__c!=null && step.HexaBPM__SR__r.Apartment_No_Guardian__c!='')? step.HexaBPM__SR__r.Apartment_No_Guardian__c : '';
            guardianAccount.Area__c = (step.HexaBPM__SR__r.Area_Guardian__c!=null && step.HexaBPM__SR__r.Area_Guardian__c!='')? step.HexaBPM__SR__r.Area_Guardian__c : '';
            //guardianAccount.City_Emirate__c = (step.HexaBPM__SR__r.City_Emirate_Guardian__c!=null && step.HexaBPM__SR__r.City_Emirate_Guardian__c!='')? step.HexaBPM__SR__r.City_Emirate_Guardian__c : '';
            guardianAccount.City_State__c = (step.HexaBPM__SR__r.City_Emirate_Guardian__c!=null && step.HexaBPM__SR__r.City_Emirate_Guardian__c!='')? step.HexaBPM__SR__r.City_Emirate_Guardian__c : '';
            guardianAccount.Company__c = (step.HexaBPM__SR__r.Company_Guardian__c!=null && step.HexaBPM__SR__r.Company_Guardian__c!='')? step.HexaBPM__SR__r.Company_Guardian__c : '';
            guardianAccount.Company_lookup__c = (step.HexaBPM__SR__r.Company_lookup_Guardian__c!=null)? step.HexaBPM__SR__r.Company_lookup_Guardian__c : null;
            guardianAccount.Country__c = (step.HexaBPM__SR__r.Country_Guardian__c!=null && step.HexaBPM__SR__r.Country_Guardian__c!='')? step.HexaBPM__SR__r.Country_Guardian__c : '';
            guardianAccount.Building__c = (step.HexaBPM__SR__r.Building_Guardian__c!=null && step.HexaBPM__SR__r.Building_Guardian__c!='')? step.HexaBPM__SR__r.Building_Guardian__c : '';
            guardianAccount.PersonHomePhone = (step.HexaBPM__SR__r.Home_Phone_Guardian__c!=null && step.HexaBPM__SR__r.Home_Phone_Guardian__c!='')? step.HexaBPM__SR__r.Home_Phone_Guardian__c : '';
            guardianAccount.Makani__c = (step.HexaBPM__SR__r.Makani_Guardian__c!=null)? step.HexaBPM__SR__r.Makani_Guardian__c : null;
            guardianAccount.PersonMobilePhone = (step.HexaBPM__SR__r.Mobile_Guardian__c!=null && step.HexaBPM__SR__r.Mobile_Guardian__c!='')? step.HexaBPM__SR__r.Mobile_Guardian__c : '';
            guardianAccount.Occupation__c = (step.HexaBPM__SR__r.Occupation_Guardian__c!=null && step.HexaBPM__SR__r.Occupation_Guardian__c!='')? step.HexaBPM__SR__r.Occupation_Guardian__c : '';
            guardianAccount.Office_Phone__c = (step.HexaBPM__SR__r.Office_Phone_Guardian__c!=null && step.HexaBPM__SR__r.Office_Phone_Guardian__c!='')? step.HexaBPM__SR__r.Office_Phone_Guardian__c : '';
            guardianAccount.P_O_Box__c = (step.HexaBPM__SR__r.P_O_Box_Guardian__c!=null && step.HexaBPM__SR__r.P_O_Box_Guardian__c!='')? step.HexaBPM__SR__r.P_O_Box_Guardian__c : '';
            guardianAccount.Street__c = (step.HexaBPM__SR__r.Street_Guardian__c!=null && step.HexaBPM__SR__r.Street_Guardian__c!='')? step.HexaBPM__SR__r.Street_Guardian__c : '';  
            guardianAccount.sys_fromSRClosure__c = true;
            guardianAccount.Other_Area__c = (step.HexaBPM__SR__r.Guardian_Other_Area__c!=null)? step.HexaBPM__SR__r.Guardian_Other_Area__c : '';
            guardianAccount.Other_City_State__c = (step.HexaBPM__SR__r.Guardian_Other_City_State__c!=null)? step.HexaBPM__SR__r.Guardian_Other_City_State__c : '';
            guardianAccount.School__c = (step.HexaBPM__SR__r.School__c!=null)? step.HexaBPM__SR__r.School__c : null;
            parentGuardianListToInsert.add(guardianAccount);
        }
        system.debug('---parentGuardianListToInsert----'+parentGuardianListToInsert);
        if(parentGuardianListToInsert!=null && parentGuardianListToInsert.size()>0){
            upsert parentGuardianListToInsert;
        }
        return parentGuardianListToInsert;
    }
    
    /*
     * name     : createRelationshipsBetweenStudentAndPG
     * param    : student account and list of parent/guardian
     * return   : void
    */
    public void createRelationshipsBetweenStudentAndPG(Account student, list<Account> parentGuardianList, HexaBPM__Step__c step){
        list<Relationship__c> relationshipList = new list<Relationship__c>();
        
        for(Account obj : parentGuardianList){
            Relationship__c objRelation = new Relationship__c();
            objRelation.Created_From__c = 'SR to Account';
            objRelation.Subject_Account__c = student.id;    
            objRelation.Object_Account__c = obj.id;
            if(obj.role__c == 'Father'){
                objRelation.Type__c = 'Father';
                student.father__c = obj.id; 
            }
            else if(obj.role__c == 'Mother'){
                objRelation.Type__c = 'Mother';
                student.mother__c = obj.id; 
            }
            else if(obj.role__c == 'Guardian' && student.guardian_1__c==null && student.guardian_2__c==null){
                objRelation.Type__c = 'Guardian';
                student.guardian_1__c =obj.id;  
            }
            else if(obj.role__c == 'Guardian' && student.guardian_1__c!=null && student.guardian_2__c==null){
                objRelation.Type__c = 'Guardian';
                student.guardian_2__c =obj.id;
            }
            else if(obj.role__c == 'Guardian' && student.guardian_2__c!=null && student.guardian_1__c == null ){
                objRelation.Type__c = 'Guardian';
                student.guardian_1__c =obj.id;  
            }
            
            relationshipList.add(objRelation);
        }   

        if(existingSiblingMap!=null && existingSiblingMap.size()>0){
            for(Account temp : existingSiblingMap.values()){
                if(temp.id!=student.id){
                  Relationship__c objRelation1 = new Relationship__c();
                  objRelation1.Created_From__c = 'SR to Account';
                  objRelation1.Subject_Account__c = student.id;    
                  objRelation1.Object_Account__c = temp.id;
                  objRelation1.Type__c = 'Sibling';
                  relationshipList.add(objRelation1);
                  
                  Relationship__c objRelation2 = new Relationship__c();
                  objRelation2.Created_From__c = 'SR to Account';
                  objRelation2.Subject_Account__c = temp.id;    
                  objRelation2.Object_Account__c = student.id;
                  objRelation2.Type__c = 'Sibling';
                  relationshipList.add(objRelation2);
                }
                student.primary_contact__c = temp.primary_contact__c;
                student.Primary_Contact_Email__c = temp.Primary_Contact_Email__c;
                student.Primary_Contact_Name__c = temp.Primary_Contact_Name__c;
                student.Emergency_Contact_Number__c = temp.Emergency_Contact_Number__c;
                
                if(student.father__c!=null && temp.father__c == null){
                    Relationship__c objRelation3 = new Relationship__c();
                    objRelation3.Created_From__c = 'SR to Account';
                    objRelation3.Subject_Account__c = temp.id;    
                    objRelation3.Object_Account__c = student.father__c;
                    objRelation3.Type__c = 'Father';
                    relationshipList.add(objRelation3); 
                }
                
                if(student.mother__c!=null && temp.mother__c == null){
                    Relationship__c objRelation4 = new Relationship__c();
                    objRelation4.Created_From__c = 'SR to Account';
                    objRelation4.Subject_Account__c = temp.id;    
                    objRelation4.Object_Account__c = student.mother__c;
                    objRelation4.Type__c = 'Mother';
                    relationshipList.add(objRelation4); 
                }
            }
        }
        if(relationshipList!=null && relationshipList.size()>0){
            insert relationshipList;
            update student;
        }
    }
    
    //V1.5
    
    public void moveScholarshipRecord(Account student, HexaBPM__Step__c step){
        list<scholarship__c> scholarship = [select id, student__c from scholarship__c where Enrolment_SR__c=:step.HexaBPM__SR__r.Service_Request__c];   
        if(scholarship!=null && scholarship.size()>0){
            for(scholarship__c obj : scholarship){
                obj.student__c = student.id;
            }
            update scholarship;
        }
    }
    
}