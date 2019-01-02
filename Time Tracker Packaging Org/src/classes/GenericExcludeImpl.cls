global class GenericExcludeImpl implements ITimeTrackerService {

           /**
    * @description method to associate Start and End Action
    * @param Time_Tracker__c: closingActionRecord
    * @param List<Time_Tracker__c>: associatedList
    */
    public static void associateStartAndEndAction(Time_Tracker__c closingRecord, Time_Tracker__c openingRecord) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started GenericExcludeImpl.associateStartAndEndAction method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'closingRecord: ' + closingRecord + '; openingRecord: ' + openingRecord,
          Datetime.now(), null, null, null, UserInfo.getUserId());

        Integer elapsedTimeInMin = (Integer) (Math.abs( closingRecord.Duration__c ) / 60);
        //system.debug('@@@Elapsed Minutes::'+elapsedTimeInMin);
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Original closingRecord Duration: ' + closingRecord.Duration__c,
          Datetime.now(), null, null, null, UserInfo.getUserId());
        //closingRecord.Duration__c = elapsedTimeInMin < TimeTrackerConfigSettings.getMaxAllowedMinutesDifference() ? closingRecord.Duration__c : TimeTrackerConfigSettings.getMaxAllowedMinutesDifference()*60;
        Integer MaxtimeInMin = TimeTrackerUserSettings.getMaxAllowedMinutesDifference();
        closingRecord.Duration__c = elapsedTimeInMin < MaxtimeInMin? closingRecord.Duration__c : MaxtimeInMin*60;  
        //system.debug('@@@Final seconds::'+closingRecord.Duration__c);
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ClosingRecord Duration Neutrlized against Max-allowed-time: ' + closingRecord.Duration__c + ' vs Max-time' + MaxtimeInMin,
          Datetime.now(), null, null, null, UserInfo.getUserId());

        try {
          
          //Exclude Activities-time
          TimeTrackerTriggerUtility.excludeTime(closingRecord);
          TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'After excludeTime()- closingRecord duration: ' + closingRecord.Duration__c,
            Datetime.now(), null, null, null, UserInfo.getUserId());

          // Exclude Manual Line Items Time
          closingRecord.Duration__c = TimeTrackerUtility.excludeManualLineItemTime(closingRecord, closingRecord.Opening_Activity_Date__c);
          TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'After excludeManualLineItemTime()- closingRecord duration: ' + closingRecord.Duration__c,
            Datetime.now(), null, null, null, UserInfo.getUserId());

          closingRecord.Time_Spent__c = TimeTrackerUtility.calculateTimeSpent(closingRecord.Duration__c);
          closingRecord.Action_Closed__c = true;

          //URL-Pattern processing
          TimeTrackerConfigSettings__c urlSetting = TimeTrackerConfigSettings.getURLPatternDetails().get(closingRecord.Opening_Action__c);
          TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'URL-Settings: ' + urlSetting,
            Datetime.now(), null, null, null, UserInfo.getUserId());

          if(urlSetting!=null && (urlSetting.Text2__c!=null || urlSetting.Text3__c!=null)){

            Map<String, Object> jMap = (Map<String, Object>) JSON.deserializeUntyped(closingRecord.TabInfo__c);
            String tablink = (String)jMap.get('tabLink');

            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, '@@tablink' + tabLink,
            Datetime.now(), null, null, null, UserInfo.getUserId());

            if(tabLink!=null){
              String objectIdParam = '' + urlSetting.Text2__c + '=';
              String parentIdParam = '' + urlSetting.Text3__c + '=';

              //Get object_id (Skip if Text-2 is Null && tablink-doesn't have object-Id-param)
              if(urlSetting.Text2__c!=null && tabLink.contains(objectIdParam) ){
                Integer indexOfParam = tablink.indexOfIgnoreCase(objectIdParam);
                Integer paramValStart = indexOfParam + objectIdParam.length();
                String valueString = tablink.substring(paramValStart);
                ClosingRecord.Object_Id__c = valueString.split('&').get(0);
                 TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Retrived Object_Id__c' + ClosingRecord.Object_Id__c + ' For Param:' + objectIdParam,
                  Datetime.now(), null, null, null, UserInfo.getUserId());                
              }

              //Get parent-Id (Skip if Text-3 is Null && tablink-doesn't have Parent-Id-param)
              if(urlSetting.Text3__c!=null && tablink.contains(parentIdParam) ){
                Integer indexOfParam = tablink.indexOfIgnoreCase(parentIdParam);
                Integer paramValStart = indexOfParam + parentIdParam.length();
                String valueString = tablink.substring(paramValStart);
                ClosingRecord.Parent_Object_Id__c = valueString.split('&').get(0);
                 TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Retrived Parent_Object_Id__c' + ClosingRecord.Parent_Object_Id__c + ' For Param:' + parentIdParam,
                  Datetime.now(), null, null, null, UserInfo.getUserId());
              }

            }
          }
        } catch(Exception e) {
                TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of GenericExcludeImpl.associateStartAndEndAction method',
          Datetime.now(), null, null, null, UserInfo.getUserId());
    }

}