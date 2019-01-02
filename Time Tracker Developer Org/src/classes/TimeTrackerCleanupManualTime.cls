/**
 * @description a class implementing Batchable to clean up Manual Time records
 *
 */
global class TimeTrackerCleanupManualTime implements Database.Batchable<sObject> {
	
	String query;
	Set<Id> errorIds;
	
	/**
   * @description constructor used to set the query string
   */
	global TimeTrackerCleanupManualTime() {
		String namespacePrefix = TimeTrackerUtility.getNamespace();
        query = 'SELECT Id, Name, Engage_Time__c, Disengage_Time__c FROM ' + namespacePrefix + 
                    'ManualLineItem__c WHERE ' + 'Engage_Time__c < LAST_N_DAYS:7 OR Disengage_Time__c < LAST_N_DAYS:7';
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'TimeTrackerCleanupManualTime: query: ' + query,
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }
	
	/**
    * @description method start
    * @param Database.BatchableContext: BC
    * @return List<ManualLineItem__c>
    */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/**
    * @description method execute
    * @param Database.BatchableContext: BC
    * @param List<sObject>: scope
    */
   	global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        try
        {
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerCleanupManualTime.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'scope: ' + scope,
                Datetime.now(), null, null, null, UserInfo.getUserId());
            errorIds = new Set<Id>();
            List<Database.DeleteResult> resultList = Database.delete(scope, false);
            
            // Iterate through each returned result
            for(Database.DeleteResult dr : resultList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    //System.debug('Successfully deleted ManualLineItem__c record with Id: ' + dr.getId());
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Deleted: ' + dr.getId(),
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                } else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : dr.getErrors()) {
                        TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Error Message: ' + err.getMessage(),
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                        //System.debug('The following error has occurred.');                   
                        //System.debug('ManualLineItem__c fields that affected this error: ' + err.getFields());
                    }
                }
            }
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerCleanupManualTime.execute method.',
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
	
	global void finish(Database.BatchableContext BC) {}
}