public with sharing class TimeTrackerStagingLineItemTriggerHandler {

	public static void processBeforeInsert(List<TimeTracker_StagingLineItem__c> newList){}

	public static void processAfterInsert(List<ManualLineItem__c> manualList) {
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started ManualLineItemTriggerHandler.processAfterInsert method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'manualList: ' + manualList,
        Datetime.now(), null, null, null, UserInfo.getUserId());
    /***************************************************************/

    Long last24Time = Datetime.now().addHours(-24).getTime();
    Map<Id, Time_Tracker__c> ttMap = new Map<Id, Time_Tracker__c>([SELECT Id, Duration__c, Activity_Date__c, Opening_Activity_Date__c,
                                                                  Activity_Time__c, Opening_Activity_Time__c, MLI__c
                                                                  FROM Time_Tracker__c WHERE CreatedById = :UserInfo.getUserId()
                                                                  AND Opening_Action__c != null
                                                                  AND Activity_Time__c >= :last24Time]);

    System.debug('Manual Line Item Trigger ::: Evalute Time Tracker Records :::' + ttMap);
    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'SOQL-result ' + ttMap,
        Datetime.now(), null, null, null, UserInfo.getUserId());

    if(ttMap == null || ttMap.isEmpty()) return;
    Map<Id, List<ManualLineItem__c>> ttToMLIMap = buildTimeTrackerMLIMap(manualList, ttMap.values());
    System.debug('TTracket TO List <MLI> MAP :: :::' + ttToMLIMap);
    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'After buildTimeTrackerMLIMap()- ttToMLIMap ::' + ttToMLIMap,
        Datetime.now(), null, null, null, UserInfo.getUserId());

    if(ttToMLIMap.isEmpty()) return;

    List<Time_Tracker__c> updateTTList = new List<Time_Tracker__c>();
    for(Id ttId : ttToMLIMap.keySet()) {
      Time_Tracker__c tt  = ttMap.get(ttId);
      System.debug('Before Duration=='+tt.Duration__c);
      tt.Duration__c = excludeManualLineItemTime(tt, ttToMLIMap.get(ttId));
      tt.Time_Spent__c = TimeTrackerUtility.calculateTimeSpent(tt.Duration__c);
      System.debug('After Duration=='+tt.Duration__c);
      updateTTList.add(tt);
    }
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'After Iterating ttToMLIMap we get updateTTList(Before-update)::' + updateTTList,
        Datetime.now(), null, null, null, UserInfo.getUserId());

    System.debug('Update TimeTracket Records :: :::' + updateTTList);
    if(updateTTList.isEmpty()) return;

    try {
      update updateTTList;
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'updateTTList(After-update)::' + updateTTList,
          Datetime.now(), null, null, null, UserInfo.getUserId());
    } catch(Exception e) {
      System.debug(e.getMessage());
      TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
      Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /***************************************************************/
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of ManualLineItemTriggerHandler.processAfterInsert method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
  }

  public static Decimal excludeManualLineItemTime (Time_Tracker__c tt, List<ManualLineItem__c> mItems) {
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started ManualLineItemTriggerHandler.excludeManualLineItemTime method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tt: ' + tt + '; mItems:' + mItems,
        Datetime.now(), null, null, null, UserInfo.getUserId());
      /***************************************************************/

      Decimal duration = tt.Duration__c;
      Datetime startTime = tt.Opening_Activity_Date__c;
      Datetime endTime = tt.Activity_Date__c;

      if(startTime == null || endTime == null || mItems == null || mItems.isEmpty()) return duration;

      Decimal excludeTime = 0;
      Long startTimeLg =  startTime.getTime();
      Long endTimeLg =  endTime.getTime();
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Entering Manual-line-item Loop:',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      for(ManualLineItem__c mi : mItems){
        System.debug('startTime===='+startTime);
        System.debug('endTime===='+endTime);
        System.debug('engageTime===='+mi.Engage_Time__c);
        System.debug('disengageTime===='+mi.Disengage_Time__c );
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Manual-line-item:-'+mi,
            Datetime.now(), null, null, null, UserInfo.getUserId());

          Long engageTimeLg =  mi.Engage_Time__c.getTime();
          Long disEngageTimeLg = mi.Disengage_Time__c.getTime();
          if(startTime > mi.Engage_Time__c && endTime < mi.Disengage_Time__c) {
              duration = 0;
              addManualLineItem(tt, mi);
              TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Exiting Manual-line-item loop with break:-'+mi,
                  Datetime.now(), null, null, null, UserInfo.getUserId());
              break;
          }
          if(startTime < mi.Engage_Time__c && endTime < mi.Engage_Time__c ||
             startTime > mi.Disengage_Time__c && endTime > mi.Disengage_Time__c) continue;

          if(startTime < mi.Engage_Time__c  && endTime > mi.Disengage_Time__c) {
              excludeTime += (disEngageTimeLg - engageTimeLg);
              addManualLineItem(tt, mi);
          } else if (startTime < mi.Engage_Time__c  && endTime < mi.Disengage_Time__c){
              excludeTime += (endTimeLg - engageTimeLg);
              addManualLineItem(tt, mi);
          } else if(startTime > mi.Engage_Time__c && endTime > mi.Disengage_Time__c){
              excludeTime += (disEngageTimeLg - startTimeLg);
              addManualLineItem(tt, mi);
          }
              TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'excludeTime collected:-'+excludeTime,
                  Datetime.now(), null, null, null, UserInfo.getUserId());
      }
      Decimal finalDuraction = duration - (excludeTime/1000);

      /***************************************************************/
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Final excludeTime collected:-'+finalDuraction,
          Datetime.now(), null, null, null, UserInfo.getUserId());
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of ManualLineItemTriggerHandler.excludeManualLineItemTime method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());


      return (finalDuraction < 0 ? 0 : finalDuraction);

  }

  public static void addManualLineItem(Time_Tracker__c tt, ManualLineItem__c mi){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of ManualLineItemTriggerHandler.addManualLineItem method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tt: ' + tt + '; mi:' + mi,
      Datetime.now(), null, null, null, UserInfo.getUserId());
    /***************************************************************/

    if(String.isBlank(tt.MLI__c)) {
      tt.MLI__c = mi.Id;
      return;
    }
    tt.MLI__c += ';' + mi.Id;

    /***************************************************************/
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of ManualLineItemTriggerHandler.addManualLineItem method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
  }

  private static Map<Id, List<ManualLineItem__c>> buildTimeTrackerMLIMap (List<ManualLineItem__c> manualList, List<Time_Tracker__c> ttList) {
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of ManualLineItemTriggerHandler.buildTimeTrackerMLIMap method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
   TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'manualList: ' + manualList + '; ttList:' + ttList,
     Datetime.now(), null, null, null, UserInfo.getUserId());
   /***************************************************************/

    Map<Id, List<ManualLineItem__c>> ttToMLIMap = new Map<Id, List<ManualLineItem__c>>();
    for(ManualLineItem__c mli : manualList) {
      for(Time_Tracker__c tt: ttList){
        System.debug('mli.Engage_Time__c==='+mli.Engage_Time__c);
        System.debug('mli.Disengage_Time__c==='+mli.Disengage_Time__c);
        System.debug('tt.Activity_Date__c==='+tt.Activity_Date__c);
        System.debug('tt.Opening_Activity_Date__c==='+tt.Opening_Activity_Date__c);
        //if((tt.Closing_Created_Date__c > mli.Disengage_Time__c) ||
        //   (tt.Closing_Created_Date__c < mli.Engage_Time__c)){
        //    System.debug('Ignored the mli::::');
        //    continue;
        //  }

        if(String.isNotBlank(tt.MLI__c) && tt.MLI__c.contains(mli.Id)) {
          System.debug('Ignored the mli::::');
          continue;
        }

        /*if( (tt.Activity_Date__c < mli.Engage_Time__c && tt.Closing_Created_Date__c > mli.Engage_Time__c) ||
           (tt.Activity_Date__c > mli.Engage_Time__c && tt.Closing_Created_Date__c < mli.Disengage_Time__c)) {
          if(ttToMLIMap.containsKey(tt.Id)) {
            ttToMLIMap.get(tt.Id).add(mli);
          } else {
            ttToMLIMap.put(tt.Id, new List<ManualLineItem__c>{mli});
          }
        }*/

        /**
        * **Activity-sequence
        * 1. TT-start->MLI-engage->MLI-disengage->TT-Close
        * 2. MLI-engage->TT-start->TT-Close->MLI-disengage
        */
        if( (tt.Opening_Activity_Date__c < mli.Engage_Time__c && tt.Activity_Date__c > mli.Engage_Time__c) ||
           (tt.Opening_Activity_Date__c > mli.Engage_Time__c && tt.Activity_Date__c < mli.Disengage_Time__c)) {
          if(ttToMLIMap.containsKey(tt.Id)) {
            ttToMLIMap.get(tt.Id).add(mli);
          } else {
            ttToMLIMap.put(tt.Id, new List<ManualLineItem__c>{mli});
          }
        }
      }
    }

    /***************************************************************/
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of ManualLineItemTriggerHandler.buildTimeTrackerMLIMap method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    
    return ttToMLIMap;
  }
}