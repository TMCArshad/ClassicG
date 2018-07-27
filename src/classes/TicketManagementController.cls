/**************************************************************************************************
* Name               : TicketManagementController                                                 *
* Description        : This is a controller class for ticket management page. Has below function  *
*                       - Displays all the tickets created in the system.                         *
*                       - Filter for tickets based on user.                                       *
*                       - Create new tickets in the system.                                       *
* Created Date       : 09/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date : 09/01/2017                                                                 *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE              COMMENTS                                              *
* 1.0         NSI         09/01/2017        Initial Draft                                         *
**************************************************************************************************/
public class TicketManagementController {
    
    public Boolean showTickets {get; set;}
    public Boolean showFilter {get; set;}
    public String selectedView {get; set;}
    public String selectedStatus {get; set;}
    public String objectKeyPrefix {get; set;}
    public List<Issue__c> bugList {get; set;}
    private Map<String, List<Issue__c>> filterTicketListMap = new Map<String, List<Issue__c>>();
    
    /*********************************************************************************************
    * @Description : Controller.                                                                 *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public TicketManagementController(){  
        try{
            // Calling method to get ticket list
            filterTicketListMap = getTicketsList('Name');
            selectedView = 'All Tickets';
            selectedStatus = 'None';
            if(filterTicketListMap != null && filterTicketListMap.containsKey(selectedView)){
                bugList = new List<Issue__c>(filterTicketListMap.get(selectedView));    
                showTickets = true;
                showFilter = true;
            }
            objectKeyPrefix = Issue__c.SObjectType.getDescribe().getKeyPrefix();
        }catch(Exception ex){
            throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }    
    
    /*********************************************************************************************
    * @Description : Get all status *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getAllStatus(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None', 'None'));   
        options.add(new SelectOption('New', 'New'));   
        options.add(new SelectOption('Accepted', 'Accepted'));   
        options.add(new SelectOption('Awaiting clarifications', 'Awaiting clarifications'));   
        options.add(new SelectOption('Enhancement', 'Enhancement'));   
        options.add(new SelectOption('Awaiting user retest', 'Awaiting user retest'));   
        options.add(new SelectOption('Awaiting production deployment', 'Awaiting production deployment'));   
        options.add(new SelectOption('Deployed production retest', 'Deployed production retest'));   
        options.add(new SelectOption('User understanding issue', 'User understanding issue'));   
        options.add(new SelectOption('Invalid', 'Invalid'));   
        options.add(new SelectOption('Fixed', 'Fixed'));   
        options.add(new SelectOption('User understanding - closed', 'User understanding - closed'));   
        options.add(new SelectOption('Duplicate', 'Duplicate'));   
        options.add(new SelectOption('Re-opened', 'Re-opened'));   
        options.add(new SelectOption('Closed - no action', 'Closed - no action'));       
        return options;
    }
    
     /*********************************************************************************************
    * @Description : Get assigned to user configured in custom setting TicketManagementTeam__c.  *
    * @Params      : void                                                                        *
    * @Return      : List<SelectOption>                                                          *
    *********************************************************************************************/
    public List<SelectOption> getAssignedTos(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All Tickets', 'All Tickets'));
        options.add(new SelectOption('Unassigned', 'Unassigned'));
        for(TicketManagementTeam__c thisUser : TicketManagementTeam__c.getAll().Values()){
            options.add(new SelectOption(thisUser.Name, thisUser.Name));
        }             
        return options;
    }
    
    /*********************************************************************************************
    * @Description : Get relevant tickets on filter change.                                      *  
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getFilteredTickets(){
        try{
            selectedStatus = 'None';
            filterTicketListMap = getTicketsList('Name');
            if(String.isNotBlank(selectedView) && filterTicketListMap.containsKey(selectedView)){
                bugList = new List<Issue__c>(filterTicketListMap.get(selectedView));
                showTickets = true;
            }else{
                bugList = new List<Issue__c>();
                showTickets = false;
            }
        }catch(Exception ex){
            throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }
    
    /*********************************************************************************************
    * @Description : Get relevant tickets on status change.                                      *  
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void getFilteredStatusTickets(){
        try{
            selectedView = 'All Tickets';
            filterTicketListMap = getTicketsList('Status');
            if(String.isNotBlank(selectedStatus) && filterTicketListMap.containsKey(selectedStatus)){
                bugList = new List<Issue__c>(filterTicketListMap.get(selectedStatus));
                showTickets = true;
            }else{
                bugList = new List<Issue__c>();
                showTickets = false;
            }
        }catch(Exception ex){
            throwError('Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }
    
    /*********************************************************************************************
    * @Description : Method to get ticket details in the system.                                 *
    * @Params      : void                                                                        *
    * @Return      : Map<String, List<Issue__c>>                                                 *
    *********************************************************************************************/
    private Map<String, List<Issue__c>> getTicketsList(string filterType){ 
        Id loggedInUserId = UserInfo.getUserId();
        List<Issue__c> allBugsList = new List<Issue__c>();
        List<Issue__c> unassignedBugsList = new List<Issue__c>();
        Map<String, List<Issue__c>> filterTicketListMap = new Map<String, List<Issue__c>>();
        for(Issue__c thisTicket : [SELECT Id, Name, Assigned_To__c, Issue_Type__c ,Severity__c, Assigned_To_Email__c,
                                          Status__c, Completed_Date__c, CreatedDate, LastModifiedDate, 
                                          CreatedById, CreatedBy.Name, Issue_Description__c, 
                                          Expected_End_Date__c, Issue_Summary__c,
                                          (SELECT Id, Name, CreatedById, CreatedBy.Name, CreatedDate,
                                                  Comment_Description__c, Related_Ticket__c 
                                           FROM Related_Comments__r),
                                          (SELECT Id, Title, Body, CreatedById, CreatedBy.Name FROM Notes) 
                                   FROM Issue__c 
                                   ORDER BY Name DESC]){
            allBugsList.add(thisTicket);
            if(filterType=='Name'){
            if(String.isNotBlank(thisTicket.Assigned_To__c)){
                if(filterTicketListMap.containsKey(thisTicket.Assigned_To__c)){
                    filterTicketListMap.get(thisTicket.Assigned_To__c).add(thisTicket);
                }else{
                    filterTicketListMap.put(thisTicket.Assigned_To__c, new List<Issue__c>{thisTicket});
                }
            }else{
                unassignedBugsList.add(thisTicket);  
            }
           }else{
              if(filterTicketListMap.containsKey(thisTicket.Status__c)){
                filterTicketListMap.get(thisTicket.Status__c).add(thisTicket);
              }else{
                filterTicketListMap.put(thisTicket.Status__c, new List<Issue__c>{thisTicket});
              }
           }
        }
        if(!allBugsList.isEmpty()){
            filterTicketListMap.put('All Tickets', allBugsList);    
        }
        if(!unassignedBugsList.isEmpty()){
            filterTicketListMap.put('Unassigned', unassignedBugsList);  
        }
        return filterTicketListMap;
    }
        
    /*********************************************************************************************
    * @Description : Handle Exception and show an error message on page.                         *
    * @Params      : String                                                                      *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void throwError(String error){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, error);
        ApexPages.addMessage(myMsg);
    }
}// End of class.