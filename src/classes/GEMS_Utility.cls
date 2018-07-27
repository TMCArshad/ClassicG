/**************************************************************************************************
* Name               : GEMS_Utility                                                               *
* Description        : Utility class with generic funtions                                        *
* Created Date       : 17/01/2017                                                                 *
* Created By         : Keerthan Tantry (PWC Digital)                                              *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         PWC         16/02/2017
* 1.1         PWC         07/03/2017
* 1.2         PWC         16/03/2017  
* 1.3		  Swati		  01/11/2017	                                                          *
* 1.4         Umair Khan  23/12/2017    Get only active schools
**************************************************************************************************/
public without sharing class GEMS_Utility {

  public static final String SCROLL_TOP_ON_ERROR_SCRIPT = '<script>if("parentIFrame" in window){window.parentIFrame.scrollTo(0,0);}</script>';
  public static final String SCROLL_TOP_ON_ERROR_SCRIPT_JS = 'if("parentIFrame" in window)window.parentIFrame.scrollTo(0,0);';

  public static string errorStr {get; set;}
  private static List<sObject> results;
  private static Map<Schema.SObjectType, Map<String, Id>> rtypesCache;
  public static boolean isOnline = false;
  static {
    rtypesCache = new Map<Schema.SObjectType, Map<String, Id>>(); //convenient map, formatted from results.
    results = new List<sObject>();//contains all recordtypes retrieved via SOQL
  }


  /**
      * [getGroupMembers Return List<Id> of users in the quename sent as param ]
      * @param [Queue Name]
      * @return [List<Id> user Id list]
    */
  public static List<Id> getGroupMembers(String QueueName) {
    List<Id> memberIdList = new List<Id>();
    Map<Id, String> queueIdToNameMap = getQueueIdToNameMap(new Set<String> {QueueName});
    for (GroupMember GM : [Select UserOrGroupId, GroupId From GroupMember where GroupId IN :queueIdToNameMap.keySet()]) {
      memberIdList.add(GM.UserOrGroupId);
    }
    return memberIdList;
  }

  /**
      * [getGroupMembersMap Return Map holding School code as Key and List Of Members for the Associated Queue defdined  ]
      * @return [Map<String,List<Id>]
    */
  public static Map<String, List<Id>> getGroupMembersMap(String QueueType) {

    //School Code ==> List<Users>
    Map<String, List<Id>> groupToMembersMap = new Map<String, List<Id>>();

    //QueueName ==> SchoolCode
    Map<String, String> queueNameToSchoolCodeMap = new map<String, String>();
    Map<String, GEMS_Queue_Config__c> QueueConfig = GEMS_Queue_Config__c.getAll();
    for (GEMS_Queue_Config__c CS : QueueConfig.values() ) {
      if (CS.Queue_Type__c == QueueType)
        queueNameToSchoolCodeMap.put(CS.Queue_Name__c, CS.School_Name__c);
    }

    Map<Id, String> queueIdToNameMap = getQueueIdToNameMap(queueNameToSchoolCodeMap.keySet());
    for (GroupMember GM : [Select UserOrGroupId, GroupId From GroupMember where GroupId IN :queueIdToNameMap.keySet()]) {
      if (groupToMembersMap.containsKey(queueIdToNameMap.get(GM.GroupId))) {
        List<Id> tempList = groupToMembersMap.get(queueNameToSchoolCodeMap.get(queueIdToNameMap.get(GM.GroupId)));
        tempList.add(GM.UserOrGroupId);
        groupToMembersMap.put(queueNameToSchoolCodeMap.get(queueIdToNameMap.get(GM.GroupId)), tempList);
      } else {
        groupToMembersMap.put(queueNameToSchoolCodeMap.get(queueIdToNameMap.get(GM.GroupId)), new List<Id> {GM.UserOrGroupId});
      }
    }
    System.debug('GEMS_Utility getGroupMembers groupToMembersMap: ' + groupToMembersMap);
    return groupToMembersMap;
  }

  /**
    * [getQueueIdToNameMap Create a Map of QueueId -> QueueName]
    * @param  queueNames [List of queueNames]
    * @return            [Map<Id,String> queueId ->queueName]
  */
  public static Map<Id, String> getQueueIdToNameMap(Set<String> queueNames) {

    Map<Id, String> queueIdToName_Map = new Map<Id, String>();
    for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue' and Name = :queueNames]) {
      queueIdToName_Map.put(grp.Id, grp.Name);
    }
    return queueIdToName_Map;
  }
  public static Map<Id, String> getAllSchoolIdtoCodeMap(List<Lead> Lead_List) {
    List<Id> schoolIdList = new List<Id>();
    for (Lead l : Lead_List) {
      schoolIdList.add(l.SchoolLookup__c);
    }
    Map<Id, String> IdtoCodeMap = new Map<Id, String>();
    for (School__c s : [Select Short_Name__c, Id from School__c WHERE ID IN :schoolIdList AND  Short_Name__c != NULL  ]) {
      IdtoCodeMap.put(s.Id, s.Short_Name__c);
    }
    return IdtoCodeMap;
  }
  /**
   * [getSchoolCodeToQueueIdMap Returns Map of School Code  --> QueueId map]
   * @param  QueueType [Type of Queue defined in Queue config ]
   * @return           [schoolCode --> QueueID ]
   */
  public static Map<String, Id> getSchoolCodeToQueueIdMap(String QueueType) {
    Map<String, Id> queueNameToIdMap = new Map<String, Id>();
    Map<String, id> schoolNameToQueueIdMap = new Map<String, Id>();
    Map<String, GEMS_Queue_Config__c> QueueConfig = GEMS_Queue_Config__c.getAll();
    List<String> queueNames = new List<String>();
    for (GEMS_Queue_Config__c CS : QueueConfig.values() ) {
      if (CS.Queue_Type__c == QueueType)
        queueNames.add(CS.Queue_Name__c);
    }
    for (Group grp : [Select Id, Name, DeveloperName from Group where type = 'Queue' and DeveloperName in :queueNames]) {
      queueNameToIdMap.put(grp.DeveloperName, grp.Id);
    }
    for (GEMS_Queue_Config__c CS : QueueConfig.values() ) {
      if (CS.Queue_Type__c == QueueType && CS.School_Code__c != NULL)
        schoolNameToQueueIdMap.put( CS.School_Code__c, queueNameToIdMap.get(CS.Queue_Name__c));
    }
    return schoolNameToQueueIdMap;
  }


  /**
    * [getAllFields Get All field for a sObject]
    * @param  describeResult [DescribeResult for sObject]
    * @return                [String value concatenated with all fields]
  */
  public static String getAllFields(DescribeSObjectResult describeResult) {
    String sObjectName = describeResult.getName();
    String query = ' SELECT ';
    List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
    List<RecordType> rts = [select Id from RecordType where SObjectType = :sObjectName];
    if (rts.size() > 0) {}
    query += (rts.size() > 0) ? 'RecordType.DeveloperName ,RecordType.Name , ' : '';
    query +=  String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
    return query;
  }

  /**
      * [LogException Capture Exception tnto Exception_Log__c Obj]
      * @param e [Exception obj ]
    */
  public static void LogException(Exception e) {
    System.debug('==>' + e.getLineNumber());
    Exception_Log__c EL =  new Exception_Log__c();
    EL.Cause__c = String.valueOf(e.getCause());
    EL.Line_Number__c = e.getLineNumber();
    EL.Message__c = e.getMessage();
    EL.Stack_Trace__c = e.getStackTraceString();
    EL.Type_Name__c = e.getTypeName();
    EL.User_Name__c = UserInfo.getName();
    insert EL;
  }

  /**
    * [addPageError -Add Page message with the error Mesage received as param]
    * @param errorMessage [Error message to be added to Page]
  */
  public static void addPageError(String errorMessage) {
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, string.valueOf(errorMessage)));
  }

  /**
   * [getLeadDetails Returns Lead details]
   * @param  LeadId [Id of Lead]
   * @return        [Lead record]
   */
  public static Lead getLeadDetails(Id LeadId) {
    List<Lead> leadList = new List<Lead>();
    String leadQueryStr = GEMS_Utility.getAllFields(Lead.getsObjectType().getDescribe());
    leadQueryStr += ' WHERE Id =: LeadId ';
    try {
      leadList =  Database.query(leadQueryStr);
      if (!leadList.isEmpty()) {
        return leadList[0];
      }
    } catch (Exception e) {
      LogException(e);
    }
    return NULL;
  }


  /**
    * [buildMapOfRecordTypes - creates a map of all Record Type Names to Ids based upon a passed Object]
    * @param  passedSobjectType [sObjectType]
    * @return                   [Map<String,Id>]
  */
  public static Map<String, Id> buildMapOfRecordTypes(String passedSobjectType) {
    Map<String, Id> returnMap = new Map<String, Id>(); //the return map variable
    for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = :passedSobjectType]) { //grab the recordtypes for the specified sObject
      returnMap.put(rt.Name, rt.Id); //put the details into our map (Name -> Id)
    }
    return returnMap; //return the map
  }

  public static Map<String, Id> GetRecordTypeIdsByDeveloperName(Schema.SObjectType token) {
    // Do we already have a result?
    Map<String, Id> mapRecordTypes = rtypesCache.get(token);

    // If not, build a map of RecordTypeIds keyed by DeveloperName
    if (mapRecordTypes == null) {
      mapRecordTypes = new Map<String, Id>();
      rtypesCache.put(token, mapRecordTypes);
    } else {
      // If we do, return our cached result immediately!
      return mapRecordTypes;
    }

    // Get the Describe Result
    Schema.DescribeSObjectResult obj = token.getDescribe();

    //Check if we already queried all recordtypes.
    if (results == null || results.isEmpty()) {
      // Obtain ALL Active Record Types, (We will filter out the Record Types that are unavailable to the Running User using Schema information)
      String soql = 'SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE';
      try {
        results = Database.query(soql);
      } catch (Exception ex) {
        results = new List<SObject>();
      }
    }

    // Obtain the RecordTypeInfos for this SObjectType token
    Map<Id, Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();

    // Loop through all of the Record Types we found, and weed out those that are unavailable to the Running User
    for (SObject rt : results) {
      if (recordTypeInfos.get(rt.Id) != null) {
        if (recordTypeInfos.get(rt.Id).isAvailable()) {
          // This RecordType IS available to the running user,so add it to our map of RecordTypeIds by DeveloperName
          mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')), rt.Id);
        } else {
          System.debug('The record type ' + rt.get('DeveloperName') + ' for object ' + rt.get('sObjectType') + ' is not availiable for the user.');
        }
      }
    }
    return mapRecordTypes;
  }

  /**
    * [getALlLeadsWithLeadRef - Retuen All the Lead records with Lead_Reference__c = leadRef]
    * @param  leadRef [Lead_Reference__c value]
    * @return         [List<Lead>]
  */
  public static List<Lead> getALlLeadsWithLeadRef(String leadRef) {
    List<Lead> retLeadObjList  = new List<Lead>();
    if (leadRef != null && !String.isBlank(leadRef)) {
      String leadQueryStr = GEMS_Utility.getAllFields(Lead.getsObjectType().getDescribe());
      leadQueryStr += ' WHERE Lead_Reference__c =: leadRef ';
      retLeadObjList = Database.query(leadQueryStr);
    }

    return retLeadObjList;
  }


  /**
    * [getAllServiceRequestsForleadReference - Return all the Service Requests which has Lead_Reference__c value equal to the parameter passed]
    * @param  leadRef [Lead_Reference__c value]
    * @return         [List<HexaBPM__Service_Request__c> - List of Service Requests]
  */
  public static List<HexaBPM__Service_Request__c> getAllServiceRequestsForleadReference(String leadRef) {
    List<HexaBPM__Service_Request__c> SRList = new List<HexaBPM__Service_Request__c>();
    String srQueryStr = GEMS_Utility.getAllFields(HexaBPM__Service_Request__c.getsObjectType().getDescribe());
    srQueryStr += ' WHERE Lead_Reference__c =:leadRef ';
    SRList = Database.query(srQueryStr);
    return SRList;
  }

  /**
    * [getPgReference - Return page reference for the page name passes as param]
    * @param  pageName [Name of the page where navigation is required]
    * @return          [PageReference to the page passed as param]
  */
  public static PageReference getPgReference(String pageName) {
    PageReference pg = new PageReference('/apex/' + pageName);
    pg.setRedirect(true);
    return pg;
  }

  //V1.1
  /*
    * name     : getRecordTypeId
    * param    : sobject Name, developerName
    * return   : recordTypeId
  */
  public static string getRecordTypeId (string sobjectName, string developerName) {
    string RecordTypeId = '';
    for (RecordType objRT : [select Id, Name from RecordType where DeveloperName = :developerName AND SobjectType = :sobjectName AND IsActive = true])
      RecordTypeId = objRT.Id;
    return  RecordTypeId;
  }

  /**
   * [getReferer Returns Referer information of the page]
   * @return [URL String]
   */
  public static string  getReferer() { 
    String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
    string pageURL = (Test.isRunningTest()) ? 'http://www.test.com' :  ApexPages.currentPage().getHeaders().get('Referer');
    URL currentPageURL = new URL(pageURL);
    return pageURL; 
  }

  /**
    * [getReferer Returns Referer information of the page]
    * @return [URL String]
    */
  public static string  getGEMSReferer() {
    String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
    string pageURL = ApexPages.currentPage().getHeaders().get('Referer');
    URL currentPageURL =(Test.isRunningTest()) ? new  URL('http://www.test.com') :   new URL(pageURL);
    return pageURL;
  }
  /**
   * [getEnctryptedURLparam Encrypts URL param ]
   * @param  phraseToEncrypt [Value to be encrypted]
   * @return                 [Encrypted String]
   */
  public static string getEnctryptedURLparam(String phraseToEncrypt ) {
    String encryptedString = Encodingutil.urlEncode(GEMS_Utility.encryptPhrase(phraseToEncrypt), 'UTF-8').replaceAll('%', '_');
    System.debug('Encrypted URL param : ' + encryptedString);
    return encryptedString;
  }

  /**
   * [getDecryptedURLParam Decrypts URL param]
   * @param  phraseToDecrypt [Value to be decrypted]
   * @return                 [Returns decrypted string]
   */
  public static string getDecryptedURLParam(String phraseToDecrypt ) {
    String decryptedString = Gems_utility.decryptPhrase(Encodingutil.urlDecode(phraseToDecrypt.replaceAll('_', '%'), 'UTF-8'));
    System.debug('Decrypted URL param : ' + decryptedString);
    return decryptedString;
  }
  /**
   * [getSiteURLConfig Returns Site URL configured in the custom settings]
   * @param  schoolCode [School code -Eg:  WEK,OOL]
   * @return            [URL defined in the custom setting]
   */
  public static GEMS_Site_Domain_Config__c getSiteURLConfig(String schoolCode) {
    Map<string, GEMS_Site_Domain_Config__c> siteConfig = GEMS_Site_Domain_Config__c.getAll();
    if (siteConfig.containsKey(schoolCode)) {
      return siteConfig.get(schoolCode);
    }
    return NULL;
  }

  public static HTTPResponse GetDummyResponse(String body,Integer StatusCode){
  HTTPResponse response = new HTTPResponse();
  response.setStatusCode(StatusCode);
  response.setbody(body);
  return response;
}
  /*
  public static String getSiteURL(String siteName){

         Site site = [
             SELECT GuestUserId
             FROM Site
             WHERE Name = :siteName
         ];

         String path = '/sites/servlet.SiteDebugMode';
         PageReference pr = new PageReference(path);
         pr.getParameters().put('guid', site.GuestUserId);
         pr.getParameters().put('sitedebugmode', 'x');
         String url = pr.getContent().toString().substringAfter('URL=').substringBefore(path);
         return url;
  }
  */
  /**
   * [generateLeadRefNumber Generrates Lead reference Number]
   * @return [Unique Lead reference number]
   */
  public static String generateLeadRefNumber() {
     Integer len = 4;
     String str = string.valueof(Math.abs(Crypto.getRandomLong()));
     String randomNumber = str.substring(0, len);
     system.debug('Random Number-' + randomNumber);
     
     String hashString = randomNumber + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
     Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
     String hexDigest = EncodingUtil.convertToHex(hash);
     return hexDigest;

  }
  /**
   * [generatePardotEnrollNowURL Generates pardot URL value to preppopulate the enrolment screen when landed from pardot Email]
   * @param  schoolCode    [School code value]
   * @param  leadRefNumber [Lead refernece value]
   * @param  domainConfig  [School specific site url]
   * @return               [Short form first screen with prepopulated value ]
   */
  public static string generatePardotEnrollNowURL(String schoolCode, String leadRefNumber, GEMS_Site_Domain_Config__c domainConfig) {
    String baseUrl = (domainConfig != NULL ) ? domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c   + '?' : NULL;
    String param = '/apex/' + GEMS_Constants.ENQUIRYDETAILS_PAGE;
    param += '?BSU=';
    param += schoolCode;
    param += '&RefId=';
    param += leadRefNumber;
    param += '&isPardotURL=';
    param += 'Yes';
    String finalUrl = baseUrl + EncodingUtil.base64Encode(Blob.valueOf(param));
    return finalUrl;
  }
  /**
   * [decryptPhrase Decrypts phrase using key defined in constants]
   * @param  phraseToDecrypt [Value to decrypt]
   * @return                 [Decdrypted value]
   */
  public  static String decryptPhrase(String phraseToDecrypt) {
    Blob keyblobval = Blob.valueOf(GEMS_Constants.CRYPTOKEY);
    Blob encodedEncryptedBlob = EncodingUtil.base64Decode(phraseToDecrypt);
    Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
    String decryptedPasswordText = decryptedBlob.toString();
    return decryptedPasswordText;
  }
  /**
   * [encryptPhrase Encrypts phrase using crypto key defined in the contants]
   * @param  phraseToEncrypt [Value to encrypt]
   * @return                 [Encrypted value]
   */
  public  static String encryptPhrase(String phraseToEncrypt) {
    Blob keyblobval = Blob.valueOf(GEMS_Constants.CRYPTOKEY);
    Blob phraseBlob = Blob.valueOf(phraseToEncrypt);
    Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, phraseBlob);
    String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
    return encryptedString;
  }

  /**
   * [getSchoolMap Returns School Id to school Map]
   * @return [School id--> School]
   */
  public static Map<Id, School__c> getSchoolMap() {

    Map<Id, School__c> schoolMap = new map<Id, School__c>();
    String schoolQueryStr = GEMS_Utility.getAllFields(School__c.getsobjectType().getDescribe());
    for (School__c s : Database.query(schoolQueryStr)) {
      schoolMap.put(s.Id, s);
    }
    return schoolMap;
  }

  public static Boolean checkIfUserIspartOfSchoolQueue(HexaBPM__Step__c step) {
    HexaBPM__Step__c stepOj = new HexaBPM__Step__c ();
    Boolean isQueueMember = false;
    for (HexaBPM__Step__c obj : [SELECT Id,
                                 HexaBPM__SR__c,
                                 HexaBPM__SR__r.School__r.Short_Name__c,
                                 OwnerID

                                 FROM HexaBPM__Step__c
                                 WHERE Id = : step.Id
                                            LIMIT 1]) {
      stepOj = obj;
    }
    if (string.valueOf(step.OwnerId).startsWith('00G'))
      for (GroupMember gm :  [SELECT GroupId ,
                              UserOrGroupId
                              FROM GroupMember
                              WHERE UserOrGroupId = : UserInfo.getUserID()
                                  AND GroupId = :step.OwnerId]) {
        isQueueMember  = true;

      }
      return isQueueMember;
  }


public static Boolean checkIfPreviousSchoolIsGEMS(String schoolName) {
  Boolean isGEMS = false;
  for (School__c school : [SELECT Id, Name
                           FROM School__c
                           WHERE Name = : schoolName LIMIT 1]) {
    isGEMS =  true;
  }
  return isGEMS;
}
/**
 * [getSchool Returns School infomrtaion for a given school code]
 * @param  schoolCode [School code]
 * @return            [School record]
 */
public static School__c getSchool(String schoolCode) {
  List<School__c> schoolList = new List<School__c>();
  String schoolQueryStr = GEMS_Utility.getAllFields(School__c.getsobjectType().getDescribe());
  schoolQueryStr += ' WHERE ID__c =:schoolCode LIMIT 1';
  schoolList = Database.query(schoolQueryStr);
  if (!schoolList.isEmpty()) {
    return schoolList[0];
  }
  return NULL;
}

/**
 * [getAcademicYearsForSchool returns academic year for the school]
 * @param  BSUID      [School code -126008]
 * @param  Curriculum [Curriculum value]
 * @return            [Picklist containing all Academic year for the school]
 */
public static List<SelectOption> getAcademicYearsForSchool(String BSUID, String Curriculum) {
  System.debug('AY isOnline ==>'+isOnline);
  Map<String, String>dupMap = new Map<String, String>();
  List<SelectOption> options = new List<SelectOption>();
  Decimal currAY = 0 ;
  string currentAY = '';
  for(Academic_Year__c AY  : [SELECT ACD_ID__c,School__r.ID__c,Sys_Active__c,Sys_Academic_Year_Value__c from Academic_Year__c WHERE Sys_Active__c  = true AND School__r.ID__c =:BSUID and Curriculum__c =:Curriculum ORDER BY Sys_Academic_Year_Value__c DESC  ]){

  	currAY = AY.Sys_Academic_Year_Value__c;
  }
  
 

  map<string, string> academicYearNamelabelMap = new map<string, string>();
  Schema.DescribeFieldResult fieldResult =
  Academic_Year__c.Year__c.getDescribe();
  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  for ( Schema.PicklistEntry f : ple) {
    academicYearNamelabelMap.put( f.getValue(), f.getLabel());
  }



  String query = GEMS_Utility.getAllFields(Academic_Year__c.getsObjectType().getDescribe());

  //Adding all relationship fields

 
  query += ' WHERE Year__c != NULL ';
  query += (isOnline) ? ' AND Active__c = true ' : '';
  query += ' AND School__r.ID__c =: BSUID ';
  query += (Curriculum != NULL )  ? 'AND Curriculum__c =:Curriculum ' : '';
  query += (currAY > 0 && !isOnline) ? ' AND Sys_Academic_Year_Value__c >= :currAY ': '';
  query += ' ORDER BY Year__c ';
  
  list<Academic_Year__c> tempList = new list<Academic_Year__c>();
  tempList = Database.query(query);
  if(tempList!=null && tempList.size()>0){
	  //1.3
	  for (Academic_Year__c AY : tempList) {
		if(AY.Sys_Active__c){
			currentAY = AY.Academic_Year__c;
		}
	    String label = academicYearNamelabelMap.get(AY.Year__c);
	    if ((dupMap.isEmpty() || !dupMap.containsKey(label)) && label==currentAY) {
	      dupMap.put(label, label);
	      options.add(new SelectOption(AY.Id, label));
	    }
	  }
	  
	  for (Academic_Year__c AY : tempList) {
	    String label = academicYearNamelabelMap.get(AY.Year__c);
	    if (dupMap.isEmpty() || !dupMap.containsKey(label)) {
	      dupMap.put(label, label);
	      options.add(new SelectOption(AY.Id, label));
	    }
	  }
  }
  return options;
}



public static List<SelectOption> getGradesForSchool( String BSUID, String academicYear, String curriculum) {
  System.debug('G isOnline ==>'+isOnline);
  Map<String, String>dupMap = new Map<String, String>();
  List<SelectOption> options = new List<SelectOption>();
  
  String query = getAllFields(Grade__c.getsObjectType().getDescribe());

  //Adding all relationship fields
  query = query.replace('FROM Grade__c', ',School__r.ID__c,Academic_Year__r.curriculum__c FROM Grade__c ');
  query += ' WHERE School__r.ID__c =: BSUID ';
  query += (academicYear != NULL )  ? 'AND Academic_Year_Display__c =:academicYear ' : '';
  query += (curriculum != NULL )  ? 'AND Academic_Year__r.curriculum__c =: curriculum ' : '';
  query += (isOnline) ? ' AND Active__c = true ' : '';
  query += ' ORDER BY Sys_Sort_Val__c ';
  System.debug('query ==>'+query);
  for (Grade__c grade : Database.query(query)) {
    System.debug('grade ==>'+grade);
    if (dupMap.isEmpty() || !dupMap.containsKey(grade.Grade_Display__c)) {
      dupMap.put(grade.Grade_Display__c, grade.Grade_Display__c);
      options.add(new SelectOption(grade.Id, grade.Grade_Display__c));
    }
  }
  return options;
}
/**
 * [getCurriculumsForSchool Returns all curriculum for the school]
 * @param  BSUID [School code value]
 * @param  Year  [Year for which curriculun is expected]
 * @return       [Curriculum picklist values]
 */
public static List<SelectOption> getCurriculumsForSchool(String BSUID, String Year) {


  Map<String, String>dupMap = new Map<String, String>();
  List<SelectOption> options = new List<SelectOption>();
  
  String query = getAllFields(Academic_Year__c.getsObjectType().getDescribe());
  query = query.replace('FROM Academic_Year__c', ',School__r.ID__c FROM Academic_Year__c ');
  query += ' WHERE School__r.ID__c =: BSUID ';
  query += (isOnline) ? ' AND Active__c = true ' : '';
  query += (Year != NULL )  ? ' AND Year__c =:Year ' : '';

  query += ' ORDER BY Curriculum__c ';
  Schema.DescribeFieldResult F = academic_year__c.curriculum__c.getDescribe();

  map<string, string> mapOfCurriculum = new map<string, string>();
  for (Schema.PicklistEntry obj : F.getPicklistValues()) {
    mapOfCurriculum.put(obj.getValue(), obj.getLabel());
  }


  for (Academic_Year__c AY : Database.query(query)) {

    if (dupMap.isEmpty() || !dupMap.containsKey(AY.Curriculum__c)) {
      dupMap.put(AY.Curriculum__c, mapOfCurriculum.get(AY.Curriculum__c));
      if (mapOfCurriculum.get(AY.Curriculum__c) != null) {
        options.add(new SelectOption(AY.Curriculum__c, mapOfCurriculum.get(AY.Curriculum__c)));
      }
    }
  }
  return options;
}

public static  List<SelectOption> getSectionsForSchool(String BSUID, String AcademicYear,String Grade, string stream){
 List<SelectOption> options = new List<SelectOption>();
 Map<String, String>dupMap = new Map<String, String>();
 
 String sectionQueryStr = '';
 sectionQueryStr += getAllFields(Section_Master__c.getsObjectType().getDescribe());
 sectionQueryStr = sectionQueryStr.replace('FROM Section_Master__c', ',School__r.ID__c,Grade__r.Academic_Year_Display__c FROM Section_Master__c ');
 sectionQueryStr += ' WHERE School__r.ID__c =: BSUID ';
 sectionQueryStr += (AcademicYear != NULL ) ? ' AND Academic_Year__c =: AcademicYear ' : '';
 sectionQueryStr += (Grade != NULL ) ?  ' AND Grade__c =: Grade ' : '';
 sectionQueryStr += (stream != NULL ) ?  ' AND Stream__c =: stream ' : '';
 sectionQueryStr += ' ORDER BY Section__c ';
 for(Section_Master__c sec :Database.query(sectionQueryStr) ){
   if (dupMap.isEmpty() || !dupMap.containsKey(sec.Section__c))
      {
        dupMap.put(sec.Section__c, sec.Section__c);
        options.add(new SelectOption(sec.Id, sec.Section__c));
      }

 }
 return options;
}

public static List<SelectOption> getStreamsForSchool( String BSUID, String academicYear, String grade) {

  Schema.DescribeFieldResult F = grade__c.Stream__c.getDescribe();
  map<string, string> mapOfStream = new map<string, string>();
  for (Schema.PicklistEntry obj : F.getPicklistValues()) {
    mapOfStream.put(obj.getValue(), obj.getLabel());
  }

  Map<String, String>dupMap = new Map<String, String>();
  List<SelectOption> options = new List<SelectOption>();
  String query = getAllFields(Grade__c.getsObjectType().getDescribe());
  
  //Adding all relationship fields
  query += ' WHERE School__r.ID__c =: BSUID ';
  query += (academicYear != NULL )  ? 'AND Academic_Year__c =:academicYear ' : '';
  query += (grade != NULL )  ? ' AND Grade_Display__c =:grade ' : '';
  query += ' ORDER BY Grade__c ';

  for (Grade__c Stream : Database.query(query)) {
    if (dupMap.isEmpty() || !dupMap.containsKey(Stream.Stream__c)) {
      dupMap.put(Stream.Stream__c, Stream.Stream__c);
      options.add(new SelectOption(Stream.Stream__c, mapOfStream.get(Stream.Stream__c)));
    }
  }
  return options;
}

//1.2
public static string getCompany(string companyName) {
  list<company__c> tempCompanyList = new list<company__c>();
  tempCompanyList = [select id, name from company__c where name = :companyName];
  if (tempCompanyList != null && tempCompanyList.size() > 0) {
    return tempCompanyList[0].id;
  }
  return null;
}

/**
 * [getGendersForSchool Returns all genders defined for the school]
 * @param  school [School record]
 * @return        [Gender picklist]
 */
public static List<SelectOption> getGendersForSchool(School__c school) {
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption('', '--None--'));
  if (school.Gender__c != NULL && school.Gender__c.equals('Both')) {
    
    options.add(new SelectOption('Male', 'Male'));
    options.add(new SelectOption('Female', 'Female'));
  } else if(school.Gender__c != NULL && !school.Gender__c.equals('Both')){
    //Show only specific gender open for that school
    options.add(new SelectOption(school.Gender__c, school.Gender__c));
  }
  return options;

}


/**
 * [getAllGemsSchools Returns all GEMS school]
 * @return [Picklist with All GEMS Schools]
 */
public static List<SelectOption> getAllGemsSchools() {
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption('', '--None--'));
  //1.4
  for (School__c school : [SELECT id, Name FROM School__c Where Active__c = true ORDER BY Name]) {
    options.add(new SelectOption(school.Id, school.Name));
  }

  return options;
}
/**
 * [getAllCurrentSchools Returns GEMS and Non-GEMS Schools]
 * @return [Picklist showing all GEMS and non GEMS Schools]
 */
public static List<SelectOption> getAllCurrentSchools() {
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption('', '--None--'));
  //1.4
  
  if(isOnline==false){
	  for (School__c school : [SELECT id, Name FROM School__c Where Active__c = true ORDER BY Name]) {
	    //Both name and Value is school name because Current school is saved as text on Lead
	    options.add(new SelectOption(school.Name, school.Name));
	  }
  }
  Map<String, BSU_COMPETITORS__c> Competitors = BSU_COMPETITORS__c.getAll();
  for (BSU_COMPETITORS__c competitor : Competitors.values()) {
    options.add(new SelectOption(competitor.School_Name__c.toUpperCase(), competitor.School_Name__c));

  }
  options.add(new SelectOption('Other', 'Other'));
  system.debug('-----'+options);
  return options;
}

/**
 * [getLabelFromAcademicYear Returns Label value for the Year picklist]
 * @param  key [Key Value]
 * @return     [Label value ]
 */
public static String getLabelFromAcademicYear(string key) {
  String retStr;
  Schema.DescribeFieldResult F = academic_year__c.year__c.getDescribe();

  map<string, string> mapOfAY = new map<string, string>();
  for (Schema.PicklistEntry obj : F.getPicklistValues()) {
    mapOfAY.put(obj.getValue(), obj.getLabel());
  }

  if (string.isNotBlank(key) && mapOfAY != null && mapOfAY.size() > 0) {
    retStr = mapOfAY.get(key);
  }
  return retStr;
}


/*=============== Captcha Variables by Bilal's ID =============*/
public static final String CAPTCHA_BASEURL = 'https://www.google.com/recaptcha/api/siteverify';
public static final String CAPTCHA_PRIVATE_KEY = '6LepEfwSAAAAAASNFNew1-039Uf-Seykvch5_FUu';
public String CAPTCHA_PUBLIC_KEY {
  get { return '6LepEfwSAAAAADUgZe2xPK8Kmmrn4B0RsCz827oo'; }
}


public Static String VerifyCurrentPageCaptcha() {
  System.debug('reCAPTCHA verification attempt');
  String retStr = '';
  String response = ApexPages.currentPage().getParameters().get('g-recaptcha-response');
  HttpResponse r = makeRequest(CAPTCHA_BASEURL, 'secret=' + CAPTCHA_PRIVATE_KEY + '&remoteip='  + remoteHost + '&response='  + response);

  boolean verified = false;
  if ( r != null ) {
    //verified = (r.getBody().startsWithIgnoreCase('true'));
    try {
      Map<String, String> responseMap = (Map<String, String>)JSON.deserialize(String.valueOf(r.getBody()), Map<String, String>.class);
      if (responseMap != null && responseMap.containsKey('success'))
        verified = Boolean.valueOf(responseMap.get('success'));
    } catch (Exception ex) {
      System.debug('Captcah Verify failed, Response =' + r.getBody());
    }
    System.debug('Captcha Response' + r.getStatus());
  }
  retStr = (verified) ? 'Success' : 'Error';
  return retStr;
}

/* Private helper methods */
private static HttpResponse makeRequest(string url, string body)  {
  HttpResponse response = null;
  HttpRequest req = new HttpRequest();
  req.setEndpoint(url);
  req.setMethod('POST');
  req.setBody (body);
  try {
    Http http = new Http();
    response = (Test.isRunningTest()) ?  GetDummyResponse('{"error": true}',200): http.send(req);
  } catch (System.Exception e) {
    System.debug('ERROR: ' + e);
  }
  return response;
}

private static String remoteHost {
  get {
    String ret = '127.0.0.1';
    // also could use x-original-remote-host
    Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
    if (hdrs.get('x-original-remote-addr') != null)
      ret =  hdrs.get('x-original-remote-addr');
    else if (hdrs.get('X-Salesforce-SIP') != null)
      ret =  hdrs.get('X-Salesforce-SIP');
    return ret;
  }
}

/**============================= Captcha End =====================**/

/*
    Method to get the grades for the Particular School and Academic Year
    Input Params : List of AcademicYear Lookup Ids, list of School RecordIds
    Return Value : map with key as "SchoolRecId_AcademicYearLkpId" and value as "Map<GradePicklist,GradeLkpId>"
*/
public static map<string, map<string, string>> getSchoolGrades(list<string> lstAcademicYearIds, list<string> lstSchoolIds) {
  map<string, map<string, string>> MapSchoolAcademicYearGrades = new map<string, map<string, string>>();
  if (lstAcademicYearIds != null && lstAcademicYearIds.size() > 0 && lstSchoolIds != null && lstSchoolIds.size() > 0) {
    for (Grade__c GD : [Select Id, Academic_Year__c, School__c, Grade__c from Grade__c where Academic_Year__c IN:lstAcademicYearIds and School__c IN:lstSchoolIds and Active__c = true and Academic_Year__c != null and School__c != null]) {
      map<string, string> MapGradeCodeIds = new map<string, string>();
      if (MapSchoolAcademicYearGrades.get(GD.School__c + '_' + GD.Academic_Year__c) != null)
        MapGradeCodeIds = MapSchoolAcademicYearGrades.get(GD.School__c + '_' + GD.Academic_Year__c);
      MapGradeCodeIds.put(GD.Grade__c, GD.Id);

      MapSchoolAcademicYearGrades.put(GD.School__c + '_' + GD.Academic_Year__c, MapGradeCodeIds);
    }
  }
  return MapSchoolAcademicYearGrades;
}

/*
    Method to get the Academic Year lookup map for all the schools from
    Input Params :
    Return Value : map with key as "SchoolRecId" and value as "Map<AcademicYearPicklist,AcademicYearLkpId>"
*/
public static map<string, map<string, string>> getAllSchoolAcademicYears() {
  map<string, map<string, string>> MapSchoolAcademicYearLookups = new map<string, map<string, string>>();
  for (Academic_Year__c AY : [Select Id, Year__c, School__c from Academic_Year__c where Active__c = true and Year__c != null and School__c != null]) {
    map<string, string> MapAcademicYearLookups = new map<string, string>();
    if (MapSchoolAcademicYearLookups.get(AY.School__c) != null)
      MapAcademicYearLookups = MapSchoolAcademicYearLookups.get(AY.School__c);
    MapAcademicYearLookups.put(AY.Year__c, AY.Id);
    MapSchoolAcademicYearLookups.put(AY.School__c, MapAcademicYearLookups);
  }
  return MapSchoolAcademicYearLookups;
}

/**
 * [generateCompleteFileURLForSRs - Generate Complete file Urls for SR List]
 * @param SR_List         [List of SRs]
 * @param SchoolShortName [School Short Name]
 */
public static void generateCompleteFileURLForSRs(List<HexaBPM__Service_Request__c> SR_List,String SchoolShortName){
    Page__c completeFilePage = new Page__c();
    GEMS_Site_Domain_Config__c domainConfig = new GEMS_Site_Domain_Config__c();
    List<ID> srIds = new List<ID>();
    List<HexaBPM__Service_Request__c> srUpdateList = new List<HexaBPM__Service_Request__c>();
    
    domainConfig = GEMS_Utility.getSiteURLConfig(SchoolShortName);
    for (Page__c p :  [SELECT ID, Page_Flow__c, Page_Flow__r.Record_Type_API_Name__c FROM Page__c WHERE Page_Flow__r.Record_Type_API_Name__c = : GEMS_Constants.SRRT_ENROLLMENT ]) {
      completeFilePage = p;
    }
    
    
    for(HexaBPM__Service_Request__c obj : SR_List){
        srIds.add(obj.Id);
    }
    String completeFileURL;
    String completeFileURLEncoded;
    for(HexaBPM__Service_Request__c obj : [SELECT Id,
                                                  School__c, 
                                                  School__r.ID__c
                                           FROM   HexaBPM__Service_Request__c
                                           WHERE  Id IN :srIds  ]){
        completeFileURL  = '/apex/' +  GEMS_Constants.COMPLETE_FILE_PAGE;
        completeFileURL += '?';
        completeFileURL += 'FlowId=' + GEMS_Utility.getEnctryptedURLparam(completeFilePage.Page_Flow__c) + '&';
        completeFileURL += 'Id=' + GEMS_Utility.getEnctryptedURLparam(obj.Id) + '&';
        completeFileURL += 'PageId=' + GEMS_Utility.getEnctryptedURLparam(completeFilePage.Id) + '&';
        completeFileURL += 'RefId=' + NULL + '&';
        completeFileURL += 'BSU=' + obj.School__r.ID__c;
        completeFileURLEncoded = (domainConfig != NULL ) ? domainConfig.Site_Base_URL__c + domainConfig.Short_Form_Page_Name__c   + '?' + EncodingUtil.base64Encode(Blob.valueOf(completeFileURL)) : NULL ;
        obj.Complete_File_URL__c = completeFileURLEncoded;
        srUpdateList.add(obj);
         
    }
    
    update srUpdateList;
    
    
}
public static map<string,string> getFieldElementMap(string strObjectName,String recTypeName){
    
    RecordType rt = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName =:recTypeName LIMIT 1 ];
    string objectKeyPrefix = getObjectPrefix(strObjectName);
    PageReference p = new PageReference('/'+ objectKeyPrefix +'/e?nooverride=1&RecordType='+rt.Id);
    p.setRedirect(true);
    String html = '';

    if (Test.IsRunningTest()){
        html = '<label for="CF00N11000000qRuU"><span class="requiredMark">*</span>Client</label>';
    }
    else
            html = p.getContent().toString();

    Map<String, String> labelToId = new Map<String, String>();
    Matcher m = Pattern.compile('<label for="(.*?)">(?:<span class="assistiveText">\\*</span>)?(.*?)</label>').matcher(html);

    while (m.find()) {
        String label = m.group(2);
        String id = m.group(1);
        labelToId.put(label.trim(), id.trim());
    }
    
    
    return labelToId;
}


public static string getObjectPrefix(string strObjectName){
    Schema.SObjectType ObjectType = Schema.getGlobalDescribe().get(strObjectName);//From the Object Api name retrieving the SObject
    Sobject Object_name = ObjectType.newSObject();
    Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
    Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
    string objectKeyPrefix = sobject_describe.getKeyPrefix();
    return objectKeyPrefix;
}   
public static  void shareAccountsWithRegistrar(List<Account> Account_List) {
    List < Id > schoolIDList = new List < Id > ();
    List < String > masterStudentList = new List < String > ();
    List < String > schoolShortNameList = new List < String > ();
    Map < String, Id > groupNameToIDMap = new Map < String, Id > ();
    List < AccountShare > accShareList = new List < AccountShare > ();
    Map < String, String > masterStudentToShortNameMap = new map < String, String > ();

    for (Account acc: Account_List) {
        if (acc.School__c != NULL) {
            schoolIDList.add(acc.School__c);
        } else if (acc.Master_Student__c != NULL) {
            masterStudentList.add(acc.Master_Student__c);
        } else if (acc.School_Short_Name__c != NULL) {
            schoolShortNameList.add(acc.School_Short_Name__c);
        }

    }

   for (Account acc: [SELECT Id, School__c, School__r.Short_Name__c, Student_id__c from Account Where Student_id__c IN: masterStudentList]) {
        schoolIDList.add(acc.School__c);
        masterStudentToShortNameMap.put(acc.Student_id__c, acc.School__r.Short_Name__c);
    }
    Map < ID, School__c > schoolIDtoSchoolMap = new Map < ID, School__c > ();
    for (School__c school: [SELECT Id, Short_Name__c, ID__c FROM School__c WHERE Id IN: schoolIDList OR Short_name__c IN: schoolShortNameList]) {
        schoolIDtoSchoolMap.put(school.Id, School);
 
    }
    for (Group g: [SELECT Id, DeveloperName from Group]) {
        groupNameToIDMap.put(g.DeveloperName, g.Id);
    }
    AccountShare ashare;
    for (Account acc: Account_List) {
        String key;
        ashare = new AccountShare();
        ashare.AccountId = acc.Id;
        if (acc.School__c != NULL) {
            key = schoolIDtoSchoolMap.get(acc.School__c).Short_name__c + '_Registrar';
            System.debug('Key:'+Key);
            ashare.UserOrGroupId = groupNameToIDMap.get(key);
        } else if (acc.School_Short_Name__c != NULL) {
            key = acc.School_Short_Name__c + '_Registrar';
            ashare.UserOrGroupId = groupNameToIDMap.get(key);
        } else if (acc.Master_Student__c != NULL) {
            key = masterStudentToShortNameMap.get(acc.Master_Student__c) + '_Registrar';
            ashare.UserOrGroupId = groupNameToIDMap.get(key);
        }else{
        	ashare.UserOrGroupId = userInfo.getUserId();
        }

        ashare.AccountAccessLevel  = 'edit';
        ashare.OpportunityAccessLevel = 'edit';
        if(!Test.isRunningTest())
        {
          accShareList.add(ashare);
           }


    }
    if(!accShareList.isEmpty()){
      insert accShareList;
    }
    
}

    public static academic_year__c getAcademicYearID(string schoolId, string academicYearLabel, string curriculum){
        if(string.isNotBlank(schoolId) && string.isNotBlank(academicYearLabel) && string.isNotBlank(curriculum)){
            list<academic_year__c> tempList = new list<academic_year__c>();
            if(isOnline == true){
            	tempList = [select id from academic_year__c where school__r.id =: schoolId
                       	    and Academic_Year__c=:academicYearLabel and Curriculum__c=:curriculum
                       	    and Active__c = true];
            }else{
            	tempList = [select id from academic_year__c where school__r.id =: schoolId
                       	    and Academic_Year__c=:academicYearLabel and Curriculum__c=:curriculum];
            }
            
        
            if(!tempList.isEmpty()){
                return tempList[0]; 
            }
        }
        return null;
    }
    
    public static grade__c getGradeID(string schoolId, string academicYearID, string stream, string gradeLabel){
        if(string.isNotBlank(schoolId) && string.isNotBlank(academicYearID) && string.isNotBlank(stream)){
            list<grade__c> tempList = new list<grade__c>();
            if(isOnline == true){
            	tempList = [select id from grade__c where school__r.id =: schoolId
	                                       and Academic_Year__c=:academicYearID and stream__c=:stream 
	                                       AND Grade_Display__c =: gradeLabel and  Active__c = true];
            }else{
            	tempList = [select id from grade__c where school__r.id =: schoolId
	                                       and Academic_Year__c=:academicYearID and stream__c=:stream 
	                                       AND Grade_Display__c =: gradeLabel];
            }
            if(!tempList.isEmpty()){
                return tempList[0]; 
            }
        }
        return null;
    }
}