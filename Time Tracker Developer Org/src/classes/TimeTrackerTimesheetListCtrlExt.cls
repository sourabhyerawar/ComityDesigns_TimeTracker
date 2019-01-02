/*
    @ Purpose : 1. Controls the visualforce page --> TimesheetBulkApproval
                2. Displays only submitted records from selected timesheet records.
                3. Mass approves or rejects records.
*/

global class TimeTrackerTimesheetListCtrlExt {
      
    public List<Timesheet__c> listOfTimesheetsToUpdate { get; set; }
    
    public Boolean areButtonsDisabled { get; set; }
    
    public TimeTrackerTimesheetListCtrlExt() {
        
        this.initializePage();
    }
    
    public TimeTrackerTimesheetListCtrlExt( ApexPages.StandardSetController controller ) {
        
        this();
        TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'Selected:-\n' + JSON.serialize( controller.getSelected() ), Datetime.now(), null, null, null, UserInfo.getUserId() );
        
        List<Timesheet__c> listOfSelectedTimesheets = ( List<Timesheet__c> ) controller.getSelected();
        TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'listOfSelectedTimesheets:-\n' + JSON.serialize( listOfSelectedTimesheets ), Datetime.now(), null, null, null, UserInfo.getUserId() );
        
        this.filterSelectedTimesheets( listOfSelectedTimesheets );
        TimeTrackerUtility.upsertLogRecord();
    }
    
    public PageReference approveAll() {
        
        if( !listOfTimesheetsToUpdate.isEmpty() ) { 
            
            Set<ID> setOfTimesheetsForApproval = new Set<ID>();
            for( Timesheet__c timesheet: listOfTimesheetsToUpdate ) {
                setOfTimesheetsForApproval.add( timesheet.Id );
            }

            Map<String, Object> approvalResponse = TimeTrackerTimesheetApproval.bulkApproveOrReject( setOfTimesheetsForApproval, 'Approve', 'Approve Comment' );
            TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'approvalResponse:-\n' + JSON.serialize( approvalResponse ), Datetime.now(), null, null, null, UserInfo.getUserId() );
            
            if( approvalResponse.get( 'status' ) == '200' ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, System.Label.SUCCESS_Bulk_Approval_Timesheet ) );
            } 
            else if( approvalResponse.get('status') == '500' ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.ERR_Bulk_Approval_Timesheet + approvalResponse.get( 'error' )));
            }
            areButtonsDisabled = TRUE;
            TimeTrackerUtility.upsertLogRecord();
        }
        return NULL;
    }
    
    public PageReference rejectAll() {
        
        if( !listOfTimesheetsToUpdate.isEmpty() ) { 
            
            Set<ID> setOfTimesheetsForRejection = new Set<ID>();
            for( Timesheet__c timesheet: listOfTimesheetsToUpdate ) {
                setOfTimesheetsForRejection.add( timesheet.Id );
            }

            Map<String, Object> rejectionResponse = TimeTrackerTimesheetApproval.bulkApproveOrReject( setOfTimesheetsForRejection, 'Reject', 'Reject Comment' );
            TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'rejectionResponse:-\n' + JSON.serialize( rejectionResponse ), Datetime.now(), null, null, null, UserInfo.getUserId() );
            
            if( rejectionResponse.get( 'status' ) == '200' ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, System.Label.SUCCESS_Bulk_Rejection_Timesheet ) );
            } 
            else if( rejectionResponse.get('status') == '500' ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.ERR_Bulk_Rejection_Timesheet + rejectionResponse.get( 'error' )));
            }
            areButtonsDisabled = TRUE;
            TimeTrackerUtility.upsertLogRecord();
        }
        return NULL;
    }
    
    private void initializePage() {
        
        this.listOfTimesheetsToUpdate = new List<Timesheet__c>();
        this.areButtonsDisabled = TRUE;
    }
    
    private void filterSelectedTimesheets( List<Timesheet__c> listOfSelectedTimesheets ) {
        
        Boolean isAdminPermissionSetAssigned = this.checkBulkApprovalPermissions();
        TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'isAdminPermissionSetAssigned:-\n' + isAdminPermissionSetAssigned, Datetime.now(), null, null, null, UserInfo.getUserId() );
        
        if( isAdminPermissionSetAssigned ) {
            this.listOfTimesheetsToUpdate = this.getListOfSubmittedTimesheets( listOfSelectedTimesheets );
            this.areButtonsDisabled = this.listOfTimesheetsToUpdate.isEmpty();
        }
        else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.ERR_Bulk_Approval_Permission ) );
        }
    }
    
    private Boolean checkBulkApprovalPermissions() {
        
        Integer intCountOfPermissionSetAssignments = [ SELECT COUNT() FROM PermissionSetAssignment
                                                       WHERE 
                                                       PermissionSet.Name = 'Time_Tracker_Admin_Permission_Set'
                                                        AND
                                                       AssigneeId = :UserInfo.getUserId()
                                                     ];
        return intCountOfPermissionSetAssignments > 0;
    }
    
    private List<Timesheet__c> getListOfSubmittedTimesheets( List<Timesheet__c> listOfSelectedTimesheets ) {
        
        List<Timesheet__c> listOfSubmittedTimesheets = new List<Timesheet__c>();
        if( listOfSelectedTimesheets != NULL && !listOfSelectedTimesheets.isEmpty() ) {
            List<ProcessInstanceWorkitem> listOfWorkItems = [ SELECT ProcessInstance.TargetObjectId
                                                              FROM ProcessInstanceWorkitem
                                                              WHERE ActorId = :UserInfo.getUserId()
                                                              AND 
                                                              IsDeleted = false
                                                              AND 
                                                              ProcessInstance.TargetObjectId IN : listOfSelectedTimesheets 
                                                            ];
            TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'listOfWorkItems:-\n' + JSON.serialize( listOfWorkItems ), Datetime.now(), null, null, null, UserInfo.getUserId() );
            
            if( listOfWorkItems.isEmpty() ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.No_Pending_Timesheets_Found ) );
            }
            else {
                Set<ID> pendingTimesheetsForCurrentUser = new Set<ID>();
                for( ProcessInstanceWorkitem workItem : listOfWorkItems ) {
                    pendingTimesheetsForCurrentUser.add( workItem.ProcessInstance.TargetObjectId );
                }
                TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'pendingTimesheetsForCurrentUser:-\n' + JSON.serialize( pendingTimesheetsForCurrentUser ),Datetime.now(), null, null, null, UserInfo.getUserId() );
                
                listOfSubmittedTimesheets = [ SELECT ID, Name, Status__c, Comment__c FROM Timesheet__c WHERE ID IN : pendingTimesheetsForCurrentUser AND Status__c = 'Submitted' ];
                if( listOfSubmittedTimesheets.isEmpty() ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.No_Pending_Timesheets_Found ) );
                }
            }
        }
        else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.Select_at_least_one_time_sheet ) );
        }
        TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'listOfSubmittedTimesheets:-\n' + JSON.serialize( listOfSubmittedTimesheets ), Datetime.now(), null, null, null, UserInfo.getUserId() );
        return listOfSubmittedTimesheets;
    }
}