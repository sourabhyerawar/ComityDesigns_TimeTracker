/**
 * @description a class implementing Batchable to clean up orphan time tracker records
 *
 */
global class TimeTrackerCleanupOrphans implements Database.Batchable<sObject> {
    Set<Id> errorIds;
    global final String query;

   /**
   * @description constructor used to set the query string
   *
   */
    global TimeTrackerCleanupOrphans() {
        String namespacePrefix = TimeTrackerUtility.getNamespace();
        query = 'SELECT Id, Name FROM ' + namespacePrefix + 'Time_Tracker__c WHERE '
                + namespacePrefix + 'Duration__c = null AND  ' + namespacePrefix + 'Activity_Date__c  <= YESTERDAY';
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'TimeTrackerCleanupOrphans: query: ' + query,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        //System.debug(LoggingLevel.ERROR, '--++--query : ' + query);
        //System.debug(LoggingLevel.ERROR, '--++--Database.query(query) : ' + Database.query(query));
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        try
        {            
            //System.debug(LoggingLevel.ERROR, '--++--scope : ' + scope);
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerCleanupOrphans.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'scope: ' + scope,
                Datetime.now(), null, null, null, UserInfo.getUserId());
            errorIds = new Set<Id>();
            List<Database.DeleteResult> resultList = Database.delete(scope, false);
            //System.debug(LoggingLevel.ERROR, '--++--resultList : ' + resultList);
            for(Database.DeleteResult result : resultList) {
                if(!result.isSuccess()){
                    errorIds.add(result.getId());
                    //get IDs of the errorneous records
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Error while deleting orphan: ' + result.getErrors(),
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                }
            }
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerCleanupOrphans.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}