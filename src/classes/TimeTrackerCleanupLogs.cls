/**
 * @description a class implementing Batchable to clean up logging records
 *
 */
global class TimeTrackerCleanupLogs implements Database.Batchable<sObject> {
    Set<Id> errorIds;
    global final String query;

   /**
   * @description constructor used to set the query string
   */
    global TimeTrackerCleanupLogs() {
        String namespacePrefix = TimeTrackerUtility.getNamespace();
        query = 'SELECT Id, Name FROM ' + namespacePrefix + 'Time_Tracker_Log__c WHERE '
                + namespacePrefix + 'Activity_Date__c  < LAST_N_DAYS:7';
        /*query = 'SELECT Id, Name FROM ' + namespacePrefix + 'Time_Tracker_Log__c WHERE '
                + namespacePrefix + 'Activity_Date__c  < LAST_N_DAYS:3 LIMIT 10';*/

        System.debug(LoggingLevel.ERROR, '--++--query : ' + query);
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'TimeTrackerCleanupLogs: query: ' + query,
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /**
    * @description method start
    * @param Database.BatchableContext: BC
    * @return List<Time_Tracker_Log__c>
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /**
    * @description method execute
    * @param Database.BatchableContext: BC
    * @param List<sObject>: scope
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug(LoggingLevel.ERROR, '--++--scope : ' + scope);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerCleanupLogs.execute method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'scope: ' + scope,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        try{
        	errorIds = new Set<Id>();
            List<Database.DeleteResult> resultList = Database.delete(scope, false);
            // Iterate through each returned result

            for(Database.DeleteResult dr : resultList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Deleted: ' + dr.getId(),
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                } else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : dr.getErrors()) {
                        TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createErrorLogString(err),
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                        System.debug(LoggingLevel.ERROR, 'The following error has occurred.');
                        System.debug(LoggingLevel.ERROR, 'Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerCleanupLogs.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }catch(Exception ex){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }finally
        {
            TimeTrackerUtility.upsertLogRecord();
        }

    }
    
    /**
    * @description method finish
    */
    global void finish(Database.BatchableContext BC) {}
}