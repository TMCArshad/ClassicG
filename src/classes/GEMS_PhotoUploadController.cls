/**
 * Created by bilalnazir on 8/14/17.
 */

public without sharing class GEMS_PhotoUploadController {

    private final String DEFAULT_ACCOUNT_PHOTO_NAME = 'photo.jpeg';

    public string strCroppedData{get;set;}
    public string strAccountId{get;set;}
    public GEMS_PhotoUploadController(){
        if(apexpages.currentPage().getParameters().get('Id')!=null)
            strAccountId = apexpages.currentPage().getParameters().get('Id');
    }
    
    public pagereference SaveCroppedImage(){
        if(strCroppedData!=null && strAccountId!=null){
            addAccountPhoto(strAccountId);
            pagereference pg = new pagereference('/'+strAccountId);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
    /**
        @Description - Adds photo on account from the captured base64 string,
        updates the existing if one already is there.
    */
    public Attachment addAccountPhoto(string userAccount){

        Attachment oldPhotoAttachment = null,
                newPhotoAttachment;

        for(Attachment att: [SELECT Id, Body FROM Attachment WHERE ParentId=:userAccount and Name=:DEFAULT_ACCOUNT_PHOTO_NAME]){
            oldPhotoAttachment = att;
        }
        
        string strSplittedString = '';
        if(strCroppedData!=null && strCroppedData!='' && strCroppedData.indexOf('base64,')>-1){
            list<string> lstSplittedString = strCroppedData.split('base64,');
            if(lstSplittedString!=null && lstSplittedString.size()>=2)
                strSplittedString = lstSplittedString[1];
        }
        
        try {
            if(oldPhotoAttachment == null){
                newPhotoAttachment= new Attachment();
                newPhotoAttachment.ContentType = 'image/jpg';
                newPhotoAttachment.Name= DEFAULT_ACCOUNT_PHOTO_NAME;//'photo.jpeg';
                newPhotoAttachment.Body=EncodingUtil.base64Decode(strSplittedString);
                newPhotoAttachment.parentId=userAccount;
                insert newPhotoAttachment;
            }else{

                newPhotoAttachment = oldPhotoAttachment;

                newPhotoAttachment.ContentType = 'image/jpg';
                newPhotoAttachment.Name= DEFAULT_ACCOUNT_PHOTO_NAME;//'photo.jpeg';
                newPhotoAttachment.Body=EncodingUtil.base64Decode(strSplittedString);

                update newPhotoAttachment;
            }
        }catch(Exception ex){
            System.debug('Attachment on SR failed ==>' + ex.getMessage());
        }

        return newPhotoAttachment;

    }

    public PageReference cancel() {
        pagereference pg = new pagereference('/'+strAccountId);
        pg.setRedirect(true);
        return pg;
    }
}