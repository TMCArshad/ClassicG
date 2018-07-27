/*****************************************************************************************************************************
    Author      :   Swati Sehrawat
    Date        :   9th April 2017
    Description :   class used to generate and send offer letter
    --------------------------------------------------------------------------------------------------------------------------
    Modification History
    
    V1.0    27thJan2018     abu dhabi offer letter changes
    V1.1    17thFeb2018     non UAE offer letter changes
    v1.2    23April2018     method to return meaningful exception messages
    --------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************/
global class GEMS_sendOfferButton {
    
    //from Enrollment Service request registrar can send offer letter email
    webservice static String sendOfferDetails(string srID){
        string msg='Success';
        try{
            if(string.isNotBlank(srID)){
                
                list<HexaBPM__Service_Request__c> tempSRlist = [select id,Offer_Send_Date__c,HexaBPM__External_Status_Name__c,
                                                                (select id,HexaBPM__Step_Status__c from HexaBPM__Steps_SR__r where 
                                                                 Step_Name__c='Verification of Application')
                                                                from HexaBPM__Service_Request__c 
                                                                where id=:srID];
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                if(tempSRlist!=null && tempSRlist.size()>0){
                    objSR = tempSRlist[0];
                    if(objSR.HexaBPM__Steps_SR__r!=null && objSR.HexaBPM__Steps_SR__r.size()>0){
                        if(objSR.HexaBPM__Steps_SR__r[0].HexaBPM__Step_Status__c=='Verified'){
                            objSR.Offer_Send_Date__c = system.today();
                            objSR.Sys_Generate_Document__c = true;
                            update objSR;   
                            
                            
                        }else{
                            return 'Please verify the Verification of Application step';
                        }
                    }
                    else{
                        return 'SR should be registered before sending mail';
                    }
                }
            }   
        }catch(DMLexception e){
            String errormessage = e.getMessage();
            string FormattedMessage = PrepareExceptionMsg(errormessage);
            return FormattedMessage;
        }
        return msg;
    }
    
    //from Enrollment Service request registrar can send offer letter email
    webservice static String generateOfferDetails(string srID){
        string msg='Success';
        try{
            if(string.isNotBlank(srID)){
                list<HexaBPM__Service_Request__c> tempSRlist = [select id,HexaBPM__External_Status_Name__c,school__r.country__c,
                                                                       Exclude_Fees__c,Fee_Exclusion_Reason__c,school__r.city__c,
                                                                (select id,HexaBPM__Step_Status__c from HexaBPM__Steps_SR__r where 
                                                                 Step_Name__c='Verification of Application')
                                                                from HexaBPM__Service_Request__c 
                                                                where id=:srID];
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                if(tempSRlist!=null && tempSRlist.size()>0){
                    objSR = tempSRlist[0];
                    if(objSR.HexaBPM__Steps_SR__r!=null && objSR.HexaBPM__Steps_SR__r.size()>0){
                        if(objSR.HexaBPM__Steps_SR__r[0].HexaBPM__Step_Status__c=='Verified'){
                            map<string, HexaBPM__Document_Master__c> docMaster = new map<string, HexaBPM__Document_Master__c>();
                            for(HexaBPM__Document_Master__c obj : [select id,HexaBPM__Code__c,
                                                                          name,HexaBPM__LetterTemplate__c, 
                                                                          (select id from HexaBPM__SR_Template_Docs__r) 
                                                                   from HexaBPM__Document_Master__c 
                                                                   where (HexaBPM__Code__c='Offer Letter Dubai PDF' 
                                                                   or HexaBPM__Code__c='Offer Letter Qatar PDF'
                                                                   or HexaBPM__Code__c='Offer Letter Emirati PDF'
                                                                   or HexaBPM__Code__c='Offer Letter Abu Dhabi PDF'
                                                                   or HexaBPM__Code__c='Offer Letter Other PDF')]){
                                docMaster.put(obj.HexaBPM__Code__c, obj);
                            }
                            if(docMaster!=null && docMaster.size()>0){
                                list<HexaBPM__SR_Doc__c> oldSRDoc = [select id,HexaBPM__Generate_Document__c,HexaBPM__Sys_IsGenerated_Doc__c from HexaBPM__SR_Doc__c where HexaBPM__Document_Master__r.HexaBPM__Code__c IN :docMaster.keyset() and HexaBPM__Service_Request__c=:objSR.id];
                                if(oldSRDoc!=null && oldSRDoc.size()>0){
                                    oldSRDoc[0].HexaBPM__Generate_Document__c = true;
                                    oldSRDoc[0].HexaBPM__Sys_IsGenerated_Doc__c = true;
                                    update oldSRDoc[0];
                                }
                                else{
                                    HexaBPM__SR_Doc__c objSRDoc = new HexaBPM__SR_Doc__c();
                                    objSRDoc.HexaBPM__Service_Request__c =  srID;
                                    objSRDoc.HexaBPM__Generate_Document__c = true;
                                    objSRDoc.HexaBPM__Sys_IsGenerated_Doc__c = true;
                                    objSRDoc.HexaBPM__Status__c = 'Generated';
                                    
                                    if(objSR.Exclude_Fees__c == true && objSR.Fee_Exclusion_Reason__c == 'Emirati Scholarship'){
                                        objSRDoc.HexaBPM__Document_Master__c = docMaster.get('Offer Letter Emirati PDF').id;
                                        objSRDoc.HexaBPM__SR_Template_Doc__c = docMaster.get('Offer Letter Emirati PDF').HexaBPM__SR_Template_Docs__r[0].id;    
                                        objSRDoc.HexaBPM__Letter_Template_Id__c = docMaster.get('Offer Letter Emirati PDF').HexaBPM__LetterTemplate__c;
                                        objSRDoc.Name = docMaster.get('Offer Letter Emirati PDF').name;
                                    }else if(objSR.school__r.country__c == '97'){
                                        objSRDoc.HexaBPM__Document_Master__c = docMaster.get('Offer Letter Qatar PDF').id;
                                        objSRDoc.HexaBPM__SR_Template_Doc__c = docMaster.get('Offer Letter Qatar PDF').HexaBPM__SR_Template_Docs__r[0].id;  
                                        objSRDoc.HexaBPM__Letter_Template_Id__c = docMaster.get('Offer Letter Qatar PDF').HexaBPM__LetterTemplate__c;
                                        objSRDoc.Name = docMaster.get('Offer Letter Qatar PDF').name;
                                    }else if(objSR.school__r.city__c == '157'){//V1.0
                                        objSRDoc.HexaBPM__Document_Master__c = docMaster.get('Offer Letter Abu Dhabi PDF').id;
                                        objSRDoc.HexaBPM__SR_Template_Doc__c = docMaster.get('Offer Letter Abu Dhabi PDF').HexaBPM__SR_Template_Docs__r[0].id;  
                                        objSRDoc.HexaBPM__Letter_Template_Id__c = docMaster.get('Offer Letter Abu Dhabi PDF').HexaBPM__LetterTemplate__c;
                                        objSRDoc.Name = docMaster.get('Offer Letter Abu Dhabi PDF').name;
                                    }else if(objSR.school__r.city__c == '159'){//V1.1
                                        objSRDoc.HexaBPM__Document_Master__c = docMaster.get('Offer Letter Dubai PDF').id;
                                        objSRDoc.HexaBPM__SR_Template_Doc__c = docMaster.get('Offer Letter Dubai PDF').HexaBPM__SR_Template_Docs__r[0].id;  
                                        objSRDoc.HexaBPM__Letter_Template_Id__c = docMaster.get('Offer Letter Dubai PDF').HexaBPM__LetterTemplate__c;
                                        objSRDoc.Name = docMaster.get('Offer Letter Dubai PDF').name;
                                    }else{//V1.1
                                        objSRDoc.HexaBPM__Document_Master__c = docMaster.get('Offer Letter Other PDF').id;
                                        objSRDoc.HexaBPM__SR_Template_Doc__c = docMaster.get('Offer Letter Other PDF').HexaBPM__SR_Template_Docs__r[0].id;  
                                        objSRDoc.HexaBPM__Letter_Template_Id__c = docMaster.get('Offer Letter Other PDF').HexaBPM__LetterTemplate__c;
                                        objSRDoc.Name = docMaster.get('Offer Letter Other PDF').name;
                                    }
                                    
                                    insert objSRdoc;
                                }
                            }
                            objSR.HexaBPM__Required_Docs_not_Uploaded__c = false;
                            update objSR;
                                
                        }else{
                            return 'Please verify the Verification of Application step';
                        }
                    }
                    else{
                        return 'SR should be registered before generating offer';
                    }
                }                   
            }   
        }catch(Exception e){
            String errormessage = e.getMessage();
            string FormattedMessage = PrepareExceptionMsg(errormessage);
            if(FormattedMessage.indexof('Trigger.')>-1)
                FormattedMessage = FormattedMessage.split('Trigger.')[0];
            return FormattedMessage;
        }
        return msg;
    }
    //v1.2
    
    //Method truncates unwanted text from the error message displayed in case of exception 
    public static string PrepareExceptionMsg(string strException){
        string strDMLError = strException;
        if(strDMLError!=null && strDMLError!='' && strDMLError.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')>-1){
            list<string> lstMsg = strDMLError.split('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            if(lstMsg!=null && lstMsg.size()>=2){
                if(lstMsg.size()==3){
                    strDMLError = lstMsg[2];
                }else{
                    strDMLError = lstMsg[1];
                }
            }
        }else 
        if(strDMLError!=null && strDMLError!='' && strDMLError.indexOf('HexaBPM.CommonCustomException:')>-1){
            list<string> lstMsg = strDMLError.split('HexaBPM.CommonCustomException:'); 
            if(lstMsg!=null && lstMsg.size()>=2){
                if(lstMsg.size()==3){
                    strDMLError = lstMsg[2];
                }else{
                    strDMLError = lstMsg[1];
                }
            }
        }
        if(strDMLError!=null && strDMLError!='')
            strDMLError = strDMLError.replace(': []','');
            
        if(strDMLError!=null && strDMLError!='')
            strDMLError = strDMLError.replace(',','');
        return strDMLError;
    }
}