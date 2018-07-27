/**********************************************************
    Author      :   Durga Prasad
    Company     :   NSI Middle East
    Description :   -This Class is used to insert the documents based on the type of document.
                    -It will display the documents inserted related to the current object and provided option for viewing, editing and deleting the document.
                    -The selected document can be viewed in a frame. 
                    -Defaulted Folder in which documents has to be uploaded based on the object name     
    Date        :   08-Mar-2015
*************************************************************/
global with sharing class DocumentViewer {
    /*Global Declaration*/            
        public Attachment document{get;set;}
        public boolean isPortalUser{get;set;}
        public list<HexaBPM__SR_Doc__c> ltGeneratedDocs{get;set;}
        public string DocIDs='';
        string FrameDisplay='None';
        string ImgDisplay='None';
        string displayTable='block';
        string DocumentID='';
        string Imagesrc;
        string dvDocsVisibility='';
        boolean blnDisableControls=false;
        list<Attachment> lstDoc; 
        list<SelectOption> lstFolderList = new list<SelectOption>(); 
        public string strObjectId {get; set;}
        string strObjectName='';
        public HexaBPM__SR_Doc__c objSRDoc{get;set;}
        public string strLastDocId{get;set;}
        public string strLastDocName{get;set;}
        public HexaBPM__SR_Doc__c objRelatedAttach{get;set;}
        public string strDocumentName{get;set;}
        public string FileName{get;set;}
        public string AgrDocId{get;set;}
        public string strSRDocId{get;set;}
        public string userType{get;set;}
        public HexaBPM__SR_Doc__c objSRDocEdit{get;set;}
        public string strError{get;set;}
        public string strComments{get;set;}
        public string strExternalComments{get;set;}
        public string strAttachmentName{get;set;}
        public set<id> setsrids{get;set;}
        public void setstrObjectName(string value){
            strObjectName=value;
        }
        public string getstrObjectName(){
            return strObjectName;
        }
        
        public list<HexaBPM__SR_Doc__c> lstDocPreviewSlide{get;set;}
        public Boolean firstOff{set;get;}    // previous part
        public Boolean lastOff{set;get;}     // next part
    /* End of Global Declarations*/
       
       /*
            Construtor Definition:- DocumentViewer()
            This constructor is used to gets the Id of the Object from the current page reference and assigns it to the local variable        
       */
       public DocumentViewer(){
           firstOff = false;
           lastOff = false;
           lstDocPreviewSlide = new list<HexaBPM__SR_Doc__c>();
           offsetVal = 0;
           /* Start of Properties Initialization for Dynamic Flow */
           setsrids = new set<id>();
           objSRDoc = new HexaBPM__SR_Doc__c();
           document = new Attachment();
           ltGeneratedDocs = new list<HexaBPM__SR_Doc__c>();
           isPortalUser = true;
           strComments = '';
           strExternalComments = '';
           userType = 'salesforce';
           for(User curUser:[select id,ContactId,ProfileId,Profile.UserLicenseId,Profile.UserLicense.Name,Profile.UserLicense.LicenseDefinitionKey from User where Id=:userInfo.getUserId() and IsActive=true]){
                if(curUser.Profile.UserLicense.Name=='Salesforce'){
                    userType = 'salesforce';
                }else{
                    userType = 'Community';
                }
                if(curUser.ContactId!=null){
                    isPortalUser = true;
                }else{
                    isPortalUser = false;
                }
           }
           if(apexpages.currentpage().getParameters().get('Id')!=null)
                strObjectId = string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id'));
           if(strObjectId!=null)
                setsrids.add(strObjectId);
           PrepareGenDocs();
           retriveDocument();//calling the Retrieve document method to retrieve the documents of the object if exist on page load
           objRelatedAttach = new HexaBPM__SR_Doc__c();
           Prepare_Preview_Documents();
        }
        
        public integer offsetVal{get;set;}
        public integer TotalListSize{get;set;}
        public pagereference Prepare_Preview_Documents(){
            TotalListSize = 0;
            lstDocPreviewSlide = new list<HexaBPM__SR_Doc__c>();
            if(strObjectId!=null && strObjectId!=''){
                for(HexaBPM__SR_Doc__c doc:[select Id,Name,HexaBPM__Doc_ID__c,HexaBPM__Doc_Type__c from HexaBPM__SR_Doc__c where HexaBPM__Doc_ID__c!=null and HexaBPM__Service_Request__c=:strObjectId and isDeleted=false order by LastModifiedDate desc limit 1 offset:offsetVal]){
                    lstDocPreviewSlide.add(doc);
                }
                for(HexaBPM__SR_Doc__c doc:[select Id,Name,HexaBPM__Doc_ID__c,HexaBPM__Doc_Type__c from HexaBPM__SR_Doc__c where HexaBPM__Doc_ID__c!=null and HexaBPM__Service_Request__c=:strObjectId and isDeleted=false order by CreatedDate asc]){
                    TotalListSize = TotalListSize + 1;
                }
                if(TotalListSize!=null && TotalListSize>1) 
                    lastOff = true;
                else 
                    lastOff = false;
            }
            return null;
        }
        public void PreviousPage(){
            lstDocPreviewSlide = new list<HexaBPM__SR_Doc__c>();
            if(offsetVal-1 <= 0){
                offsetVal = 0;
                firstOff = false;
            }else{
                offsetVal -= 1;
            }
            lastOff = true;
            Prepare_Preview_Documents();
        }
        public void NextPage(){
            lstDocPreviewSlide = new list<HexaBPM__SR_Doc__c>();
            offsetVal += 1;
            if(offsetVal>2000){
                offsetVal=2000;
            }
            firstOff = true;
            Prepare_Preview_Documents();
            if(TotalListSize!=null && TotalListSize>0){
                if(offsetVal+1>=TotalListSize) 
                    lastOff = false;
                firstOff = true;
            }else{
                firstOff = false;
                lastOff = false;
            }
        }
    
        public void PrepareGenDocs(){
            ltGeneratedDocs = new list<HexaBPM__SR_Doc__c>();
            if(setsrids!=null && setsrids.size()>0){
                ltGeneratedDocs = [select id,createddate,lastmodifieddate,HexaBPM__Doc_Type__c,HexaBPM__Is_Not_Required__c,HexaBPM__Requirement__c,HexaBPM__Document_Description_External__c,HexaBPM__Preview_Download_Document__c,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Received_Physically__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Document_Type__c,HexaBPM__Original_Verified__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=true and IsDeleted=false order by CreatedDate asc];
            } 
        }
        
       /*
         Method Definition:- cancel()
         This is used to cancel the operation          
       */ 
       public void Cancel() {
            document = new Attachment();
       }
       /*
         * Method Definition:- upload()
         * This is used to Upload the document into the document object and related documents custom object.
         *      
       */ 
       
        public transient String docBody{get; set;}
       
        public void Upload() {
            if(docBody != null && docBody != '')
                document.body = EncodingUtil.base64Decode(docBody);
            if(strAttachmentName != null)
                FileName = strAttachmentName;
            if(strObjectId!=null && strObjectId!=''){
                HexaBPM__SR_Doc__c objRA = new HexaBPM__SR_Doc__c();    
                try{
                    document.Name = FileName;
                    if(FileName!=null && FileName.indexof('.')>-1 && FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){
                        string contyp = FileName.SubString(FileName.indexof('.')+1,FileName.length());
                        if(contyp!=null && contyp.toLowerCase()=='pdf'){
                            document.ContentType = 'application/pdf';
                        }else{
                            //document.ContentType = contyp;
                        }
                    }
                    if(document!=null){
                        if(document.body!=null){
                            document.parentId = strSRDocId;
                        if(Attachment.sObjectType.getDescribe().isCreateable() && Attachment.sObjectType.getDescribe().isUpdateable())
                            upsert document;//Inserting the document 
                        /*Creating the related document attachment record */
                        objRA.Id = strSRDocId;
                        if(document.Id!=null){
                            objRA.HexaBPM__Doc_ID__c = string.valueOf(document.Id);
                            objRA.HexaBPM__Status__c = 'Uploaded';
                            objRA.HexaBPM__Doc_Type__c = document.ContentType;
                        }
                        if(strComments!=null && strComments!='' && strComments.trim()!='')
                            objRA.HexaBPM__Comments__c = strComments;
                        if(strExternalComments!=null && strExternalComments!='' && strExternalComments.trim()!='')
                            objRA.HexaBPM__Customer_Comments__c = strExternalComments;
                        if(strObjectId!=null && strObjectId!=''){
                            objRA.HexaBPM__Service_Request__c = strObjectId;
                            objRA.HexaBPM__Document_Type__c = document.ContentType;
                            //try{
                                if(HexaBPM__SR_Doc__c.sObjectType.getDescribe().isUpdateable())
                                    update objRA;
                            //}catch(DMLException e){
                                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getdmlMessage(0)));
                            //}
                        }
                        if(FileName!=null && FileName!=''){
                            /*Checking the file format whether it is valid or no */
                            if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pdf'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='rtf'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='txt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='jpg'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='gif'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='bmp'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='png'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='tif' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='TIF' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='doc'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='docx'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='ppt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pptx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xls'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xlsx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xml')
                            {
                                blnDisableControls=true;//once it is uploaded then assigning the flag value to true for displaying the block with document information                          
                            }else{//If the file format is not supported then throwing the exception
                               //ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Uploaded file format is not supported');
                               //ApexPages.addmessage(errorMsg); 
                            } 
                        }
                        if(document != null){ 
                           if(DocIDs != null)                        
                                DocIDs =DocIDs+';'+document.Id;//Appending all the document Id's to a String to display all the documents into the Datatable
                           else
                                DocIDs = document.id;                            
                           /*The below If block checks for whether the file format is valid format or not*/
                           if(FileName!=null && FileName!=''){
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='jpg'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='gif'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='bmp'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='png'){
                               }
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='rtf' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='tif' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='TIF' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='doc'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='docx'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='ppt'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pptx' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xls'|| FileName.SubString(FileName.indexof('.')+1,FileName.length())=='xlsx'){
                               }                                                                                  
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())=='pdf' || FileName.SubString(FileName.indexof('.')+1,FileName.length())=='txt' ){
                               }
                               if(FileName.SubString(FileName.indexof('.')+1,FileName.length())!=''){
                               }
                           }
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Please specify a file to upload.'));
                    }
                 }
                }catch(DMLException e) {//To catch the DML exception while uploading the file
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getdmlMessage(0)));
                        document = new Attachment();
                }finally {
                   document = new Attachment();
                   Prepare_Preview_Documents();
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'There is no Object Id'));   
            }
        }
    
    /*
         * Method Definition:- retriveDocument()
         * This is used to Retrieve the document related to the object and displays it on page load as well as on insertion of the document.
         *      
    */      
    public void retriveDocument(){
        try{
            strObjectId = system.currentPageReference().getParameters().get('id');
            if(setsrids!=null && setsrids.size()>0){//Checking for whether the objectId is mentioned or not
                /*Querying on Related Attachement based on object Id to display the document in the data table on Vf page Loading*/
                list<HexaBPM__SR_Doc__c> lstRA=[select HexaBPM__Doc_ID__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and IsDeleted=false];
                if(lstRA.size()>0){
                    for(integer i=0;i<lstRA.size();i++)
                        DocIDs =DocIDs+';'+lstRA[i].HexaBPM__Doc_ID__c;//Appending all the document Id's to the String
                    blnDisableControls=true;
                }
                getlstDoc();
            }   
        }catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no records to display');
            ApexPages.addmessage(errorMsg);         
        }   
    }
        
     /*
         * Method Definition:- getlstDoc()
         * This is used to return the document list to be displayed in the datatable on page load as well as on insertion and deletion
         *      
    */
    public list<HexaBPM__SR_Doc__c> getlstDoc(){
        try{
            strObjectId = system.currentPageReference().getParameters().get('id');
            list<HexaBPM__SR_Doc__c> lstDoc = new list<HexaBPM__SR_Doc__c>();
            list<string> lstDocid = new list<string>();        
            if(setsrids != null && setsrids.size()>0){
                if(DocIDs!=null && DocIDs!='')
                    lstDocid = DocIDs.split(';'); 
                /*Querying the Document based on the document Id's which has been received from Related Attachment Object*/            
                lstDoc = [select id,createddate,HexaBPM__Doc_Type__c,lastmodifieddate,HexaBPM__Is_Not_Required__c,HexaBPM__Requirement__c,HexaBPM__Document_Description_External__c,HexaBPM__Document_Master__r.Name,HexaBPM__Service_Request__c,HexaBPM__Service_Request__r.HexaBPM__Internal_Status_Name__c,HexaBPM__Service_Request__r.HexaBPM__External_Status_Name__c,name,HexaBPM__Doc_ID__c,HexaBPM__Received_Physically__c,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Document_Type__c,HexaBPM__Original_Verified__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c from HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c IN:setsrids and HexaBPM__Sys_IsGenerated_Doc__c=false and IsDeleted=false order by CreatedDate asc];
                if(lstDoc.size()>0){
                    strLastDocId = lstDoc[lstDoc.size()-1].HexaBPM__Doc_ID__c;
                    strLastDocName = lstDoc[lstDoc.size()-1].name;
                    return lstDoc;
                }else{
                    strLastDocId = '';
                    strLastDocName = '';
                }    
              }
         }catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage());
            ApexPages.addmessage(errorMsg);         
          }
       return null;
    }   
    public void EditDoc(){
        objSRDocEdit = new HexaBPM__SR_Doc__c();
        strError='';
        if(AgrDocId!=null && AgrDocId!=''){
            list<HexaBPM__SR_Doc__c> lstSRDoc = [select id,Name,HexaBPM__Customer_Comments__c,HexaBPM__Comments__c,HexaBPM__Doc_ID__c,HexaBPM__Document_Type__c,HexaBPM__Original_Verified__c,HexaBPM__Rejection_Reason__c,HexaBPM__Status__c from HexaBPM__SR_Doc__c where Id=:AgrDocId and IsDeleted=false];
            if(lstSRDoc!=null && lstSRDoc.size()>0)
                objSRDocEdit = lstSRDoc[0];
        }
    }
    public void SaveDoc(){
        try{
            if(objSRDocEdit!=null && objSRDocEdit.id!=null){
                if((objSRDocEdit.HexaBPM__Status__c=='Rejected' || objSRDocEdit.HexaBPM__Status__c=='Re-upload') && (objSRDocEdit.HexaBPM__Rejection_Reason__c==null || (objSRDocEdit.HexaBPM__Rejection_Reason__c!=null && objSRDocEdit.HexaBPM__Rejection_Reason__c.trim()=='') || objSRDocEdit.HexaBPM__Rejection_Reason__c=='')){
                    strError = 'Reason for Rejection is Required';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Comments for customer should be provided before changing status to '+objSRDocEdit.HexaBPM__Status__c));
                }else{
                    strError = '';
                    if(HexaBPM__SR_Doc__c.sObjectType.getDescribe().isUpdateable())
                        update objSRDocEdit;
                }
            }
        }catch(DMLException e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0));
            ApexPages.addmessage(errorMsg);     
        }
    }
    public pagereference Back_To_SR(){
        HexaBPM__Step__c Reuplodstp = new HexaBPM__Step__c();
        HexaBPM__Status__c objstatus = new HexaBPM__Status__c();
        boolean hasReuploadDocs = false;
        pagereference pg = new pagereference('/'+strObjectId);
        pg.setRedirect(true);
        return pg;
    }
}