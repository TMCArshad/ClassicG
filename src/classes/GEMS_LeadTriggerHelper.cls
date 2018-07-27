/**************************************************************************************************
 * Name               : GEMS_LeadTriggerHelper                                                    *
 * Description        : Lead Trigger  Handler                          *
 * Created Date       : 17/01/2017                                                                 *
 * Created By         : Keerthan Tantry (PWC Digital)                                                                        *
 * ----------------------------------------------------------------------------------------------- *
 * VERSION     AUTHOR      DATE                                                                    *
 * 1.0         PWC         16/02/2017
 * 1.2         Swati (PWC)  26/03/2017                                                             *
 * 1.3         Umair Khan  | 19-Dec-2017 | 1. Replace 'Non-Digital' with 'Short Form' and 'Long Form' in conditions
                                           2. Replace 'Non-Digital' with 'Short Form' only when value is assigning.
                                           3. Comment out creation of 'Call to Book Tour Task
 * 1.4		   Swati	   |31-Jan-2018  | remove delete access for corporate
 **************************************************************************************************/
public without sharing class GEMS_LeadTriggerHelper {
    public static Date activityDate {get; set;}
    public static String activityDatefieldName {get; set;}
    public static String subjectVal {get; set;}

    public GEMS_LeadTriggerHelper() {}

    /**
     * [assignLeadToQueue -Assigns Leads to the queue depending on associated school ]
     * @param Lead_List [List of Leads]
     * @param queueType [Type of queue]
     */
    public static void assignLeadToQueue(List < Lead > Lead_List, String queueType, boolean changeOwner ) {
        /**
         * Getting Domain information from site config
         */
        Map<string, GEMS_Site_Domain_Config__c> siteConfig = GEMS_Site_Domain_Config__c.getAll();
        Map<String, Id> schoolToQueueIdMap = GEMS_Utility.getSchoolCodeToQueueIdMap(queueType);
        Map<Id, String> schoolIdtoCodeMap = GEMS_Utility.getAllSchoolIdtoCodeMap(Lead_List);
        
        if(Lead_List!=null && Lead_List.size()>0){
	    	map<id, id> enquiryToSRMap = new map<id, id>();
	    	if(changeOwner == true){
		    	list<HexaBPM__Service_Request__c> tempList = [select id, lead__c from HexaBPM__Service_Request__c where lead__c IN : Lead_List];
	    		if(tempList!=null && tempList.size()>0){
		    		for(HexaBPM__Service_Request__c obj : tempList){
		    			enquiryToSRMap.put(obj.lead__c, obj.id);
		    		}
	    		}			
	    	}
	        for (Lead leadObj : Lead_List) {
	
	            //Set Lead reference number
	            leadObj.Lead_Reference__c = (String.isBlank(leadObj.Lead_Reference__c)) ? GEMS_Utility.generateLeadRefNumber() : leadObj.Lead_Reference__c ;
	            leadObj.Pardot_EnrollNow_URL__c = GEMS_Utility.generatePardotEnrollNowURL(leadObj.School_Code__c, leadObj.Lead_Reference__c, siteConfig.get(leadObj.School_Short_Name_L__c));
	            leadObj.Lead_No__c  = (leadObj.Lead_No__c == NULL) ? 1 : leadObj.Lead_No__c ;
	            System.debug('leadSource ==> '+leadObj.LeadSource);
	            if(changeOwner == false){
	                //1.3
		            if (leadObj.LeadSource != 'Short Form' || leadObj.LeadSource != 'Long Form' ) {//leadObj.LeadSource != 'Non-Digital'
		                //If Shchool is associated  AND School associated with the lead has a config then pick the queue and set it as Owner
		                if (schoolToQueueIdMap.containsKey(schoolIdtoCodeMap.get(leadObj.SchoolLookup__c))) {
		                    leadObj.OwnerId = schoolToQueueIdMap.get(schoolIdtoCodeMap.get(leadObj.SchoolLookup__c));
		                } else if (leadObj.SchoolLookup__c == NULL) {
		                    leadObj.OwnerId = schoolToQueueIdMap.get('GEMS Central Enrollment Officer');
		                }
		            }
	            }
	            else{
	            	if(enquiryToSRMap!=null && enquiryToSRMap.size()>0 && enquiryToSRMap.get(leadObj.id)!=null){
	            		leadObj.addError('SR has been created for this enquiry, Please do cross-sell referral using button on school.');		
	            	}
	            	else{
		            	//If Shchool is associated  AND School associated with the lead has a config then pick the queue and set it as Owner
		                if (schoolToQueueIdMap.containsKey(schoolIdtoCodeMap.get(leadObj.SchoolLookup__c))) {
		                    leadObj.OwnerId = schoolToQueueIdMap.get(schoolIdtoCodeMap.get(leadObj.SchoolLookup__c));
		                } else if (leadObj.SchoolLookup__c == NULL) {
		                    leadObj.OwnerId = schoolToQueueIdMap.get('GEMS Central Enrollment Officer');
		                }
	            	}
	            }
	        }
        }
    }
    /**
     * [assignSupportUserFromSchool -Assign support user lookup from associated school]
     * @param Lead_List [List of Leads]
     */
    public static void assignSupportUserFromSchool(List < Lead > Lead_List) {
        List<Id> schoolId_List = new List<Id>();
        Map<Id, Id> schoolIdtoRegistrarIdMap = new Map<Id, Id>();
        //get all school Ids
        for (Lead l : Lead_List) {
            schoolId_List.add(l.SchoolLookup__c);
        }
        //Get school --> registrar user map
        for (School__c s : [SELECT Id, Registrar__c FROM School__c WHERE ID IN:schoolId_List]) {
            schoolIdtoRegistrarIdMap.put(s.Id, s.Registrar__c);
        }
        for (Lead l : Lead_List) {
            //If School has registrar assign it as support user on lead
            l.Support_User__c = (l.SchoolLookup__c != NULL && schoolIdtoRegistrarIdMap.containsKey(l.SchoolLookup__c)) ? schoolIdtoRegistrarIdMap.get(l.SchoolLookup__c) :  l.Support_User__c;
        }
    }
    /**
     * [assignLeadToCentralEnrolmentOfficerQueue - Assign the lead to Central Enrollment officer Queue]
     * @param Lead_List [List of Leads]
     * @param queueType [Type of Queue]
     */
    public static void assignLeadToCentralEnrolmentOfficerQueue(List < Lead > Lead_List, String queueType ) {
        Map<String, Id> schoolToQueueIdMap = GEMS_Utility.getSchoolCodeToQueueIdMap(queueType);
        System.debug('==>' + schoolToQueueIdMap);
        for (Lead leadObj : Lead_List) {
            //1.3
            if (leadObj.LeadSource != 'Short Form' || leadObj.LeadSource != 'Long Form' )//leadObj.LeadSource != 'Non-Digital'
                leadObj.OwnerId = schoolToQueueIdMap.get('GEMS Central Enrollment Officer');
        }
    }
    /**
     * [createTaskandAssignitToOwner -Create task and assign it to the Lead owner(If LeadSource != 'Non-Digital')]
     * @param Lead_List [List of Leads]
     */
    public static void createTaskandAssignitToOwner(List < Lead > Lead_List) {
        List < Task > TaskCreate_List = new List < Task > ();
        for (Lead leadObj :  Lead_List) {
           
           //1.3  
           //If(leadObj.LeadSource != 'Non-Digital')
            TaskCreate_List.add(createTask(leadObj, leadObj.OwnerId, 'Normal', 'Open'));
        }
        if (TaskCreate_List.size() > 0) {
            insert TaskCreate_List;
        }
        activityDate = NULL;
        activityDatefieldName = NULL;
        subjectVal = NULL;
    }

    /**
     * [getAllLeadsAcceptedByUser -Get all leads accepted by Queue Member]
     * @param  Lead_List [List of Leads]
     * @param  oldMap    [Map containing old lead records]
     * @param  status    [Lead status ]
     * @return           [List of Leads ]
     */
    public static List<lead> getAllLeadsAcceptedByUser(List < Lead > Lead_List, Map < Id, Lead > oldMap, String status) {
        List<lead> leadreturnList = new List<Lead>();
        for (Lead leadObj :  Lead_List) {
            if ( String.valueOf(oldMap.get(leadObj.Id).OwnerId).startsWith('00G')  && String.valueOf(leadObj.OwnerId).startsWith('005') && leadObj.status == status) {
                leadreturnList.add(leadObj);
            }
        }
        return leadreturnList;
    }

    /**
    * [getAllLeadsWithStatus         -Return filtered list of leads with status value equal to param provided]
    * @param  List<Lead>Lead_List    [List<Lead>]
    * @param  Map<Id,Lead>oldMap     [Map<Id,Lead> map containing values before update happened]
    * @param  statusVal              [status value to filter leads in the param]
    * @param  subStatusVal           [Substatus value to filter leads in the param]
    * @param  skipChangeOfStatus     [For Status : If true --> Edit/Save will be ignored else - Edit/Save is not Ignored ]
    * @param  skipChangeOfSubStatus  [For SubStatus : If true --> Edit/Save will be ignored else - Edit/Save is not Ignored ]
    * @return                        [List<Lead> with status ='statusval' and subStatus='subStatusVal']
    *
    */
    public static List < Lead > getAllLeadsWithStatus(List < Lead > Lead_List, Map < Id, Lead > oldMap, String statusVal, String subStatusVal, Boolean skipChangeOfStatus, Boolean skipChangeOfSubStatus) {
        List < Lead > leadRet_List = new List < Lead > ();
        List < Lead > leads_List = new List < Lead > ();
        for (Lead leadObj : Lead_List) {

            if (leadObj.status == statusVal && !(string.valueOf(leadObj.ownerId).startsWith('00G')) && (skipChangeOfStatus || (oldMap.get(leadObj.id).Status != leadObj.status))) {

                leads_List.add(leadObj);
            }
        }
        if (subStatusVal == '') {
            leadRet_List = leads_List;
        } else {
            leadRet_List = getAllLeadsWithSubstatus(leads_List, oldMap, subStatusVal, skipChangeOfSubStatus);
        }
        return leadRet_List;
    }
    /*
    public static List<Lead> getAllLeadsWithStatus(List<Lead> lead_list,String Status){
     List<Lead> leadRetList = new List<Lead>();
     for(Lead obj : lead_list){
         if(obj.status == Status && !string.valueOf(obj.OwnerId).startsWith('00G')){
             leadRetList.add(obj);

         }
     }
     return leadRetList;

    }
    */
    /**
     * [checkForDuplicates - Lead duplication check]
     * @param leadObj [Current lead object]
     */
    public static void checkForDuplicates(Lead leadObj) {
        //Assuming no bulk operation
        if (GEMS_Validations.checkForDuplicates(leadObj)) {
            leadObj.addError('Enquiry already exist for the mentioned child.');
        }

    }
    /**
     * [validateAgeCutOff - Validate age cutoff walk-in leads]
     * @param leadList [List of leads(Assuming no bulk operation)]
     */
    public static void validateAgeCutOff(List<Lead> leadList){
         //Assuming no bulk operation
         Grade__c grade = new Grade__c();
         for(Grade__c g : [Select Id,Grade_Display__c from Grade__c WHERE Id=: leadList[0].GradeLookup__c]){
             grade = g;
         }
     String validateStr = GEMS_Validations.validateAgeCutOff(leadList[0],grade.Grade_Display__c);
     if( validateStr != 'Success'){
         leadList[0].addError(validateStr);
     }

    }
    /**
     * [getLeadsAssignedToAnotherSchool -Get all the leads assigned to another School]
     * @param  lead_list [List of Leads]
     * @param  oldmap    [Map<Id,Lead> map containing values before update happened]
     * @return           [List of Leads]
     */
    public static List < Lead > getLeadsAssignedToAnotherSchool(List < Lead > lead_list, Map < Id, Lead > oldmap) {

        List < Lead > leadListForTaskAssignment = new List < Lead > ();
        //List < Lead > leadList = getAllLeadsWithStatus(lead_list, oldMap, GEMS_Constants.ASSIGNED_TO_ANOTHER_SCHOOL, '', false, false);
        for (Lead leadObj : lead_list) {
            //School code was updated
            System.debug('Old School==>' + oldMap.get(leadObj.Id).School_Name__c);
            System.debug('New School==>' + leadObj.School_Name__c);
            if (leadObj.School_Name__c != oldMap.get(leadObj.Id).School_Name__c) {
                leadListForTaskAssignment.add(leadObj);
            }
        }
        return leadListForTaskAssignment;
    }
    /**
     * [getAllLeadsWithSubstatus -get all leads with sub status value passed as argument]
     * @param  Lead_List             [List of Leads]
     * @param  oldMap                [Map<Id,Lead> map containing values before update happened]
     * @param  statusVal             [Sub Status value]
     * @param  skipChangeOfSubStatus [Boolean indicator to skip change of sub status value]
     * @return                       [List of leads]
     */
    public static List < Lead > getAllLeadsWithSubstatus(List < Lead > Lead_List, Map < Id, Lead > oldMap, String statusVal, Boolean skipChangeOfSubStatus) {
        List < Lead > leadRet_List = new List < Lead > ();
        for (Lead leadObj : Lead_List) {
            if (leadObj.Sub_Status__c == statusVal && (skipChangeOfSubStatus || (oldMap.get(leadObj.Id).Sub_Status__c != leadObj.Sub_Status__c))) {
                leadRet_List.add(leadObj);
            }
        }
        return leadRet_List;
    }

    /**
     * [createTask Create Task Record ]
     * @param  WhoID   [Related To ID]
     * @param  OwnerId [Owner ID]
     * @return         [Task Record]
     */
    public static Task createTask(Lead leadObj, Id OwnerId, String Priority, String Status) {
        
        //Either use same value for all tasks or use from leadobj
        Date dueDate = (activityDate == NULL) ? Date.valueOf(leadObj.get(activityDatefieldName)) : activityDate;
        Task taskObj = new task();
        taskObj.WhoId = leadObj.Id;
        taskObj.OwnerId = OwnerId;
        taskObj.Priority = Priority;
        taskObj.Status = Status;
        taskObj.Subject = subjectVal;
        taskObj.ActivityDate = dueDate;
        return taskObj;
    }


    //On lead insert, enquiry needs to be created as a clone of lead

    public static list <Lead> syncLeadAndEnquiryOnInsert(list <Lead> Lead_List) {
        if (Lead_List != null && Lead_List.size() > 0) {
            //to make it dynamic get fieldMap
            Lead objLead = new Lead();
            Schema.SObjectType objType = objLead.getSObjectType();
            map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Lead.fields.getMap();

            //get custom setting from Lead_Enquiry_Sync__c to get field that needs to be copied
            map<String, Lead_Enquiry_Sync__c> LeadEnquirySync = Lead_Enquiry_Sync__c.getAll();
            //map of lead API name and enquiry API name
            map<string, string> leadEnquiryAPImap = new map<string, string>();
            for (string test : LeadEnquirySync.keySet()) {
                if (LeadEnquirySync.get(test).Lead_API_Name__c != null && LeadEnquirySync.get(test).Enquiry_API_Name__c != null) {
                    leadEnquiryAPImap.put(LeadEnquirySync.get(test).Lead_API_Name__c.toLowerCase(), LeadEnquirySync.get(test).Enquiry_API_Name__c.toLowerCase());
                }
            }
            list<enquiry__c> listOfEnquiry = new list<enquiry__c>();
            for (lead leadObj : Lead_List) {
                
                if (leadObj.enquiry__c != null) {

                } else {
                    enquiry__c objEnquiry = new enquiry__c();
                    objEnquiry.lead__c = leadObj.id;
                    for (String str : mapFields.keySet()) {
                        string strLead = str.toLowerCase();
                        //check if field is populated
                        //check if field exist in custom setting
                        //check if field is updateable

                        if (leadObj.get(strLead) != null && leadEnquiryAPImap.get(strLead) != null) {
                            string strEnquiry = '';
                            if (!(strLead.containsIgnoreCase('__c'))) { //append __c for standard fields
                                strEnquiry = strLead + '__c';
                            } else if (strLead.containsIgnoreCase('pi__')) { //remove __ from pardot fields
                                strEnquiry = strLead.remove('pi__');
                                strEnquiry = 'pi_' + strEnquiry;
                            } else {
                                strEnquiry = strLead;
                            }
                            //put values in respective fields
                            if (strLead == 'leadsource') {
                                objEnquiry.put('Enquiry_Source__c', leadObj.get(strLead));
                            } else if (strLead == 'ownerid') {
                                objEnquiry.put('ownerid', leadObj.get(strLead));
                            } else {
                                objEnquiry.put(strEnquiry, leadObj.get(strLead));
                            }
                            //objEnquiry.put('name',leadObj.get('firstname')+' '+leadObj.get('lastname'));
                        }
                    }
                    listOfEnquiry.add(objEnquiry);
                }
            }
            map<id, id> mapLeadEnquiry = new map<id, id>();
            if (listOfEnquiry != null && listOfEnquiry.size() > 0) {
                System.debug('=>' + listOfEnquiry[0].mobilePhone__c);
                insert listOfEnquiry;
                system.debug('----listOfEnquiry---' + listOfEnquiry);
                for (enquiry__c obj : listOfEnquiry) {
                    mapLeadEnquiry.put(obj.lead__c, obj.id);
                }
            }
            //once enquiry get inserted same needs to be copied back to the lead.
            if (mapLeadEnquiry != null && mapLeadEnquiry.size() > 0) {
                list<lead> leadToUpdate = new list<lead>();
                for (lead leadObj : [select id, enquiry__c from lead where id IN : mapLeadEnquiry.keyset()]) {
                    leadObj.enquiry__c = mapLeadEnquiry.get(leadObj.id) != null ? mapLeadEnquiry.get(leadObj.id) : null;
                    leadToUpdate.add(leadObj);
                }
                update  leadToUpdate;
            }
        }
        return  Lead_List;
    }

    
    public static list <Lead> syncLeadAndEnquiryOnUpdate(list <Lead > Lead_List, map <id, Lead> oldMap) {


        //to make it dynamic get fieldMap
        Lead objLead = new Lead();
        Schema.SObjectType objType = objLead.getSObjectType();
        map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Lead.fields.getMap();

        //get custom setting from Lead_Enquiry_Sync__c to get field that needs to be copied
        map<String, Lead_Enquiry_Sync__c> LeadEnquirySync = Lead_Enquiry_Sync__c.getAll();
        //map of lead API name and enquiry API name
        map<string, string> leadEnquiryAPImap = new map<string, string>();
        for (string test : LeadEnquirySync.keySet()) {
            if (LeadEnquirySync.get(test).Lead_API_Name__c != null && LeadEnquirySync.get(test).Enquiry_API_Name__c != null) {
                leadEnquiryAPImap.put(LeadEnquirySync.get(test).Lead_API_Name__c.toLowerCase(), LeadEnquirySync.get(test).Enquiry_API_Name__c.toLowerCase());
            }
        }

        set<string> setOfChangedFields =  new set<string>();
        list<Lead> LeadList = new list<Lead>();
        for (Lead newRecord : Lead_List) {
            if (newRecord.enquiry__c != null) {
                Lead oldRecord = oldMap.get(newRecord.Id);
                LeadList.add(newRecord); //list of lead on which change was done
                if (mapFields != null && mapFields.size() > 0) {
                    for (String str : mapFields.keyset()) {
                        if (newRecord.get(str) != null && leadEnquiryAPImap.get(str) != null) {
                            System.debug('str:' + str);
                            System.debug('newRecord.get(str):' + newRecord.get(str));
                            System.debug('oldRecord.get(str):' + oldRecord.get(str));
                            if (leadEnquiryAPImap.get(str) != null && newRecord.get(str) != oldRecord.get(str)) {
                                setOfChangedFields.add(str); //list of fields that got changed
                            }
                        }
                    }
                }
            }
        }
        map<id, enquiry__c> existingEnquiryForLead = new map<id, enquiry__c>();
        for (enquiry__c obj : [select id, lead__c from enquiry__c where lead__c in : LeadList]) {
            existingEnquiryForLead.put(obj.lead__c, obj);
        }

        //update siblings
        list<enquiry__c> enquiryToUpdate = new list<enquiry__c>();
        if (existingEnquiryForLead != null && existingEnquiryForLead.size() > 0 && setOfChangedFields != null && setOfChangedFields.size() > 0) {
            for (Lead obj : LeadList) {
                enquiry__c objEnquiry = new enquiry__c();
                objEnquiry = existingEnquiryForLead.get(obj.id);
                for (String strLead : setOfChangedFields) {
                    string strEnquiry = '';
                    if (!(strLead.containsIgnoreCase('__c'))) { //append __c for standard fields
                        strEnquiry = strLead + '__c';
                    } else if (strLead.containsIgnoreCase('pi__')) { //remove __ from pardot fields
                        strEnquiry = strLead.remove('pi__');
                        strEnquiry = 'pi_' + strEnquiry;
                    } else {
                        strEnquiry = strLead;
                    }

                    //put values in respective fields
                    if (strLead == 'leadsource') {
                        objEnquiry.put('Enquiry_Source__c', obj.get(strLead));
                    } else if (strLead == 'ownerid') {
                        objEnquiry.put('ownerId', obj.get(strLead));
                    } else {
                        objEnquiry.put(strEnquiry, obj.get(strLead));
                    }
                    //objEnquiry.name = obj.get('firstname')+' '+obj.get('lastname');
                }
                enquiryToUpdate.add(objEnquiry);
            }
        }
        if (enquiryToUpdate != null && enquiryToUpdate.size() > 0) {
            update enquiryToUpdate;
        }
        return  Lead_List;
    }
    
    public static void deleteRelatedRecords(list <Lead> Lead_List) {
        set<id> setOfLeadId = new set<id>();
        set<id> setOfEnquiryId = new set<id>();
        list<Enquiry__c> listOfEnquiry = new list<Enquiry__c>();
        list<HexaBPM__Service_Request__c> listOfSR = new list<HexaBPM__Service_Request__c>();
        list<HexaBPM__Step__c> listOfStep = new list<HexaBPM__Step__c>();
        list<EnquiryRelationship__c> listOfFamilyDetail = new list<EnquiryRelationship__c>();

        if (Lead_List != null && Lead_List.size() > 0) {
            for (Lead obj : Lead_List) {
                if (obj.Enquiry__c != null) {
                    setOfEnquiryId.add(obj.Enquiry__c);
                }
                setOfLeadId.add(obj.id);
            }
        }
        system.debug('--setOfLeadId---' + setOfLeadId);
        system.debug('--setOfEnquiryId---' + setOfEnquiryId);
        if (setOfLeadId != null && setOfLeadId.size() > 0 && setOfEnquiryId != null && setOfEnquiryId.size() > 0) {
            listOfSR = [select id from HexaBPM__Service_Request__c where lead__c IN : setOfLeadId or enquiry__c IN : setOfEnquiryId];
            listOfStep = [select id from HexaBPM__Step__c where HexaBPM__SR__c IN : listOfSR];
            listOfEnquiry = [select id from Enquiry__c where lead__c IN : setOfLeadId or id IN : setOfEnquiryId];
            listOfFamilyDetail = [select id from EnquiryRelationship__c
                                  where lead__c IN : setOfLeadId or
                                  enquiry__c IN : listOfEnquiry or
                                  Sibling_Lead__c IN : setOfLeadId or
                                  Sibling_Enquiry__c IN : listOfEnquiry];


            if (listOfStep != null && listOfStep.size() > 0) {
                delete listOfStep;
            }
            if (listOfSR != null && listOfSR.size() > 0) {
                delete listOfSR;
            }
            if (listOfEnquiry != null && listOfEnquiry.size() > 0) {
                delete listOfEnquiry;
            }
            if (listOfFamilyDetail != null && listOfFamilyDetail.size() > 0) {
                delete listOfFamilyDetail;
            }
        }
    }
    
    public static void updateSchoolLogoOnInsert(list<Lead> Lead_List) {
        //updates all field from school for SR
        set<id> schoolId = new set<id>();
        if (Lead_List != null && Lead_List.size() > 0) {
            for (Lead obj : Lead_List)
                schoolId.add(obj.SchoolLookup__c);

            map<id, school__c> schoolMap = new map<id, school__c>();
            if (schoolId != null && schoolId.size() > 0) {
                for (school__c school : [select id, logo__c from school__c where id IN : schoolId])
                    schoolMap.put(school.id, school);
            }

            if (schoolMap != null && schoolMap.size() > 0) {
                for (Lead obj : Lead_List)
                    //Updated by Keerthan -  Null Check
                    //31/5/2017
                    obj.School_Logo__c = (obj.SchoolLookup__c != NULL) ? schoolMap.get(obj.SchoolLookup__c).logo__c : NULL;
            }
        }
    }

    public static void updateSchoolLogoOnUpdate(list<Lead> Lead_List, map <id, Lead> oldMap) {
        //updates all field from school for SR
        set<id> schoolId = new set<id>();
        if (Lead_List != null && Lead_List.size() > 0) {
            for (Lead obj : Lead_List) {
                Lead oldRecord = oldMap.get(obj.Id);
                if (obj.SchoolLookup__c != null && obj.SchoolLookup__c != oldRecord.SchoolLookup__c)
                    schoolId.add(obj.SchoolLookup__c);
            }
            map<id, school__c> schoolMap = new map<id, school__c>();
            if (schoolId != null && schoolId.size() > 0) {
                for (school__c school : [select id, logo__c from school__c where id IN : schoolId])
                    schoolMap.put(school.id, school);
            }
            if (schoolMap != null && schoolMap.size() > 0) {
                for (Lead obj : Lead_List)
                    //Updated by Keerthan -  Null Check
                    //31/5/2017
                    obj.School_Logo__c = (obj.SchoolLookup__c != NULL) ? schoolMap.get(obj.SchoolLookup__c).logo__c : NULL;
            }
        }
    }
    
    //V1.4
    public static void  hasDeleteAccess(List <Lead> Lead_List){
    	if(Lead_List!=null && Lead_List.size()>0){
    		list<Profile> tempProfileList = [SELECT id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
    		if(tempProfileList!=null && tempProfileList.size()>0 && tempProfileList[0].name!='System Administrator'){
    			
    			for(Lead objLead : Lead_List){
    				objLead.addError('Lead cannot be deleted.');		
    			}	
    		}
    	}
    }
}