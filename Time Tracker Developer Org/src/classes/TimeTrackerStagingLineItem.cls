/**
 * @description a class implementing Batchable to create time tracker records
 *
 */
global class TimeTrackerStagingLineItem implements Database.Batchable<sObject> {
    Set<Id> errorIds;
    global final String query;
    global static List<TimeTracker_StagingLineItem__c> stagingLineItems;

   /**
   * @description constructor used to set the query string
   *
   */
	global TimeTrackerStagingLineItem() {
		String namespacePrefix = TimeTrackerUtility.getNamespace();
        query = 'SELECT Id, Name, OwnerId,'
        		+ namespacePrefix + 'Activity_Name__c, '
        		+ namespacePrefix + 'End_Date__c, '
        		+ namespacePrefix + 'Object_Id__c, '
        		+ namespacePrefix + 'Object_Name__c, '
        		+ namespacePrefix + 'Start_Date__c, '
                + namespacePrefix + 'TimeTracker_Associated__c '
        		+ 'FROM ' + namespacePrefix + 'TimeTracker_StagingLineItem__c '
                + 'WHERE CreatedDate  > YESTERDAY '
                + 'ORDER BY Start_Date__c ';
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'TimeTrackerStagingLineItem: query: ' + query,
            Datetime.now(), null, null, null, UserInfo.getUserId());
	}

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<Id, Timesheet__c> tsToUnlock = new Map<Id, Timesheet__c>();
    	try{

            stagingLineItems = (List<TimeTracker_StagingLineItem__c>) scope;
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Staging Scope-records' + stagingLineItems,
                Datetime.now(), null, null, null, UserInfo.getUserId());

            if(stagingLineItems!=null){

                //Check if timesheet for any user is submitted if yes change status temporary so we can 
                tsToUnlock = TimeTrackerStagingLineItemHelper.getLockedTimesheetsOfStagingUser(stagingLineItems);
                if(tsToUnlock!= null && !tsToUnlock.isEmpty()) {
                    Boolean result = TimeTrackerStagingLineItemHelper.temporaryChangeStatusOfLockedTimesheets(tsToUnlock.keySet());
                    if(!result) { return; }
                }
                //System.debug('tsToUnlock : '+tsToUnlock);

                //Get list of TimeTracker records to be inserted
                Map<Id,Time_Tracker__c> ttRecordsToUpsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingLineItems);

                //Insert TimeTracker records
                List<Database.UpsertResult> resultList = Database.upsert(ttRecordsToUpsert.values(), false);
                for(Database.UpsertResult result : resultList) {
                    if(!result.isSuccess()){
                        errorIds = new Set<Id>();
                        errorIds.add(result.getId());
                        //get IDs of the errorneous records
                        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Error while Inserting Time-Tracker-records ' + result.getErrors(),
                                Datetime.now(), null, null, null, UserInfo.getUserId());
                    }
                }
                //Delete Staging-records
                Delete stagingLineItems;
                TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Staging records deleted',
                                                 Datetime.now(), null, null, null, UserInfo.getUserId());
            }

            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItem.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
    	} catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        } finally {
            //re-assign original status to timsheet
            if(tsToUnlock!= null && !tsToUnlock.isEmpty()) {
                Boolean result = TimeTrackerStagingLineItemHelper.reassignOriginalStatusForLockedTimesheet(tsToUnlock);
            }
            TimeTrackerUtility.upsertLogRecord();
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}