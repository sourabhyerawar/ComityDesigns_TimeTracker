trigger ManualLineItemTrigger on ManualLineItem__c (after insert) {
    try
    {
      if(Trigger.isAfter) {
          if(Trigger.isInsert) {
              ManualLineItemTriggerHandler.processAfterInsert(Trigger.new);
            }
        }
    }
    catch(Exception ex)
    {
        TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
        Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    finally
    {
        TimeTrackerUtility.upsertLogRecord();
    }
}