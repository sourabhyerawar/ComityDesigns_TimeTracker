global class TimeTrackerTriggerUtility {

   global static void excludeTime(Time_Tracker__c closingRecord) {
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.excludeTime method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'closingRecord: ' + closingRecord,
        Datetime.now(), null, null, null, UserInfo.getUserId());

      TimeTrackerConfigSettings__c setting = TimeTrackerConfigSettings.getactivityvsActivityDetails().get(closingRecord.Opening_Action__c);

      if(setting == null) { return; }

      //Get Activity details
      String excludeActionString = (String.isNotBlank(setting.Text5__c) ? setting.Text5__c : '') + ';' +(String.isNotBlank(setting.Text6__c) ? setting.Text6__c : '');
      Set<String> excludeActions = TimeTrackerUtility.getExcludeActions(excludeActionString);
      TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'excludeActions: ' + excludeActions,
          Datetime.now(), null, null, null, UserInfo.getUserId());
      String parentId= null;

      //Check for child activities that result in opening of new-tab eg. Task-creation
      if(closingRecord.Parent_Object_Id__c != null){
        parentId = String.valueOf(closingRecord.Parent_Object_Id__c);
      } else if (closingRecord.Object_Id__c != null){
        parentId = String.valueOf(closingRecord.Object_Id__c);
      }

      if(String.isNotBlank(parentId)) {
          Decimal deduct = TimeTrackerutility.getExcludeAcionsDuration_UsingTimestampNParentId((Long)closingRecord.Opening_Activity_Time__c, (Long)closingRecord.Activity_Time__c,
                                                        parentId, excludeActions);
          TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'deduct: ' + deduct,
              Datetime.now(), null, null, null, UserInfo.getUserId());
          closingRecord.Duration__c = closingRecord.Duration__c - deduct;
      }
     TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.excludeTime method.',
         Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /*private static set<Date> getAllActivityDates(List<Time_Tracker__c> ttList){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getAllActivityDates method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        set<Date> activityDateSet = new set<Date>();
        for(Time_Tracker__c closingTTRec : ttList){
            if(String.isNotBlank(closingTTRec.Opening_Action__c)) {
                Date actDate = Date.newInstance(closingTTRec.Activity_Date__c.year(), closingTTRec.Activity_Date__c.month(), closingTTRec.Activity_Date__c.day());
                activityDateSet.add(actDate);
            }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.getAllActivityDates method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activityDateSet: ' + activityDateSet,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return activityDateSet;
    }*/

    private static Map<Id,set<Date>> getUserWiseAllActivityDates(List<Time_Tracker__c> ttList){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getUserWiseAllActivityDates method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        Map<Id,set<Date>> activityDateSet = new Map<Id,set<Date>>();
        for(Time_Tracker__c closingTTRec : ttList){
            if(String.isNotBlank(closingTTRec.Opening_Action__c)) {
                Date actDate = Date.newInstance(closingTTRec.Activity_Date__c.year(), closingTTRec.Activity_Date__c.month(), closingTTRec.Activity_Date__c.day());
                Id userid = closingTTRec.OwnerId;
                if(activityDateSet.containsKey(userid)){
                    activityDateSet.get(userid).add(actDate);
                } else{
                    activityDateSet.put(userid, new set<Date>{actDate});
                }
            }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.getUserWiseAllActivityDates method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activityDateSet: ' + activityDateSet,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return activityDateSet;
    }

    private static Set<String> getUniqueKeys(List<Time_Tracker__c> ttList){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getUniqueKeys method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        Set<String> uniqueKeySet = new Set<String>();
        Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails = TimeTrackerConfigSettings.getactivityvsActivityDetails();

        String actionCategory = '';
        for(Time_Tracker__c closingTTRec : ttList){
            if(String.isBlank(closingTTRec.Opening_Action__c)) { continue; }

            TimeTrackerConfigSettings__c activityDetails  = mapOfActivityDetails.get(closingTTRec.Opening_Action__c);
            if(activityDetails == null) { continue; }
            actionCategory = String.isNotBlank(activityDetails.Text7__c) && closingTTRec.Action__c.equalsIgnoreCase(activityDetails.Text7__c) ? activityDetails.Text8__c : activityDetails.Text3__c;
            if(String.isBlank(actionCategory)) { continue; }

            Date actDate = Date.newInstance(closingTTRec.Activity_Date__c.year(), closingTTRec.Activity_Date__c.month(), closingTTRec.Activity_Date__c.day());
            Datetime actDtTm = Datetime.newInstance(actDate, Time.newInstance(0,0,0,0));
            uniqueKeySet.add(actDtTm.format(TimeTrackerConstants.TIMESHEETENTRY_UNIQUE_DATE_FORMAT) + '-' + closingTTRec.OwnerId + '-' + actionCategory.trim());
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.getUniqueKeys method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'uniqueKeySet: ' + uniqueKeySet,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return uniqueKeySet;
    }

    /*private static void createRequiredMaps(List<Timesheet_Entry__c> tseList, Map<Date,Id> datevsTimesheetMap,
                                    Map<Date, Map<String, Timesheet_Entry__c>> dateTseMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.createRequiredMaps method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tseList: ' + tseList + '; datevsTimesheetMap: ' + datevsTimesheetMap
            + '; dateTseMap: ' + dateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        for(Timesheet_Entry__c tse: tseList){
            Date actDate = Date.newInstance(tse.Activity_Date__c.year(), tse.Activity_Date__c.month(), tse.Activity_Date__c.day());

            //Create Activity-date vs Timesheet-Id map
            datevsTimesheetMap.put(actDate, tse.Timesheet__c);

            //Create Activity-date vs Action Category vs Timesheet-Entry map
            if(dateTseMap.containsKey(actDate)){
                dateTseMap.get(actDate).put(tse.Activity__c,tse);
            } else{
                dateTseMap.put(actDate, new Map<String,Timesheet_Entry__c>{tse.Activity__c => tse});
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.createRequiredMaps method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }*/

    private static void createRequiredMapsForAllUser(List<Timesheet_Entry__c> tseList, Map<Id,Map<Date,Id>> uservsdatevsTimesheetMap,
                                    Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> uservsdateTseMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.createRequiredMapsForAllUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tseList: ' + tseList + '; uservsdatevsTimesheetMap: ' + uservsdatevsTimesheetMap
            + '; uservsdateTseMap: ' + uservsdateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        for(Timesheet_Entry__c tse: tseList){
            Date actDate = Date.newInstance(tse.Activity_Date__c.year(), tse.Activity_Date__c.month(), tse.Activity_Date__c.day());
            Id usrId = (Id) tse.Unique_TimesheetEntry_Identifier__c.split('-').get(1);
            //Create User vs Activity-date vs Timesheet-Id map
            if(uservsdatevsTimesheetMap.containsKey(usrId)){
                uservsdatevsTimesheetMap.get(usrId).put(actDate, tse.Timesheet__c);
            } else{
                uservsdatevsTimesheetMap.put(usrId, new Map<Date,Id>{actDate => tse.Timesheet__c});
            }
            //Create Activity-date vs Action Category vs Timesheet-Entry map
            if(uservsdateTseMap.containsKey(usrId) && uservsdateTseMap.get(usrId).containsKey(actDate)){
                uservsdateTseMap.get(usrId).get(actDate).put(tse.Activity__c,tse);
            } else if(uservsdateTseMap.containsKey(usrId)) {
                uservsdateTseMap.get(usrId).put(actDate, new Map<String, Timesheet_Entry__c>{tse.Activity__c => tse});
            } else {
                uservsdateTseMap.put(usrId, new Map<Date, Map<String, Timesheet_Entry__c>>());
                uservsdateTseMap.get(usrId).put(actDate, new Map<String, Timesheet_Entry__c>{tse.Activity__c => tse});
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.createRequiredMapsForAllUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, '### Updated uservsdatevsTimesheetMap: ' + uservsdatevsTimesheetMap
            + '; uservsdateTseMap: ' + uservsdateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /*private static void createMissingTimesheetRecords(set<Date> activityDateSet, Map<Date,Id> datevsTimesheetMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.createMissingTimesheetRecords method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activityDateSet: ' + activityDateSet
            + '; datevsTimesheetMap: ' + datevsTimesheetMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        for(Date actDate: activityDateSet){
            //Check if required Timesheet is not present
            if(!datevsTimesheetMap.containsKey(actDate)){
                //Create Timesheet if not present
                Id tsId = TimeTrackerUtility.getTimesheetRecordId(actDate);
                system.debug('@@Newly Created Timesheet::'+tsId+'##actDate'+actDate);
                //Update the datevsTimesheetMap with newly inserted Timesheet-id for given activity-date
                datevsTimesheetMap.put(actDate, tsId);
            }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.createMissingTimesheetRecords method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }*/

    private static void createMissingTimesheetRecordsForUser(Map<Id,set<Date>> useractivityDateSet, Map<Id,Map<Date,Id>> userdatevsTimesheetMap, Id userid){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.createMissingTimesheetRecordsForUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activityDateSet: ' + useractivityDateSet
            + '; datevsTimesheetMap: ' + userdatevsTimesheetMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        set<Date> activityDateSet = useractivityDateSet.get(userId);
        Map<Date,Id> datevsTimesheetMap = userdatevsTimesheetMap.get(userId);

        if(datevsTimesheetMap==null){
            datevsTimesheetMap = new Map<Date,Id>();
        }

        for(Date actDate: activityDateSet){

            //Check if required Timesheet is not present
            if(datevsTimesheetMap!=null && !datevsTimesheetMap.containsKey(actDate)){
                //Create Timesheet if not present
                Id tsId = TimeTrackerUtility.getTimesheetRecordIdForUser(actDate, userid);
                system.debug('@@Newly Created Timesheet::'+tsId+'##actDate'+actDate);
                //Update the datevsTimesheetMap with newly inserted Timesheet-id for given activity-date
                datevsTimesheetMap.put(actDate, tsId);
            }
        }

        userdatevsTimesheetMap.put( userId, datevsTimesheetMap);

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.createMissingTimesheetRecordsForUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /*private static List<Timesheet_Entry__c> getTimesheetEntriesToInsert(List<Time_Tracker__c> ttList, Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails,
                                                                           Map<Date,Id> datevsTimesheetMap, Map<Date, Map<String, Timesheet_Entry__c>> dateTseMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getTimesheetEntriesToInsert method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList + '; mapOfActivityDetails: ' + mapOfActivityDetails
            + '; datevsTimesheetMap: ' + datevsTimesheetMap + '; dateTseMap: ' + dateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        List<Timesheet_Entry__c> tseToInsert = new List<Timesheet_Entry__c>();
        //alreadyInListToInsert set- is Used to check No-duplicate TSE are inserted
        set<String> alreadyInListToInsert = new set<String>();


        for(Time_Tracker__c closingTTRec : ttList){
            if(String.isNotBlank(closingTTRec.Opening_Action__c)) {
                Id usrId = closingTTRec.OwnerId;
                Date actDate = Date.newInstance(closingTTRec.Activity_Date__c.year(), closingTTRec.Activity_Date__c.month(), closingTTRec.Activity_Date__c.day());

                //Get Activity-details from Custom-settings
                TimeTrackerConfigSettings__c activityDetails  = mapOfActivityDetails.get(closingTTRec.Opening_Action__c);

                if(activityDetails!=null){

                    String actionCategory = '';
                    //Check Activity falls under Cancel-type Action-category
                    if(String.isNotBlank(activityDetails.Text7__c) && closingTTRec.Action__c.equalsIgnoreCase(activityDetails.Text7__c)){
                        actionCategory = activityDetails.Text8__c;
                    } else{
                        actionCategory = activityDetails.Text3__c;
                    }

                    if(String.isNotBlank(actionCategory)) {
                        if(!dateTseMap.isEmpty()){
                            Map<String,Timesheet_Entry__c> tempMap = dateTseMap.get(actDate);
                            //Check if required Action-Category(Timesheet-entry for given date) is not present
                            if(!tempMap.isEmpty()){
                                if(!tempMap.containsKey(actionCategory)){
                                    //Create TSE for Action-category and given Date
                                    Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(actionCategory, actDate,
                                                                                        TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE,
                                                                                        datevsTimesheetMap.get(actDate),usrId);
                                    tse.isUtilized__c =  activityDetails != null ? activityDetails.Flag2__c : false;
                                    if(!alreadyInListToInsert.contains(''+usrId+actDate+actionCategory)){
                                        tseToInsert.add(tse);
                                        alreadyInListToInsert.add(''+usrId+actDate+actionCategory);
                                    }
                                }
                            } else {
                                //Create TSE for Action-category and given Date
                                Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(actionCategory, actDate,
                                                                                    TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE,
                                                                                    datevsTimesheetMap.get(actDate),usrId);
                                tse.isUtilized__c =  activityDetails != null ? activityDetails.Flag2__c : false;
                                if(!alreadyInListToInsert.contains(''+usrId+actDate+actionCategory)){
                                        tseToInsert.add(tse);
                                        alreadyInListToInsert.add(''+usrId+actDate+actionCategory);
                                }
                            }
                        } else {
                                //Create TSE for Action-category and given Date
                                Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(actionCategory, actDate,
                                                                                    TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE,
                                                                                    datevsTimesheetMap.get(actDate),usrId);
                              tse.isUtilized__c =  activityDetails != null ? activityDetails.Flag2__c : false;
                                if(!alreadyInListToInsert.contains(''+usrId+actDate+actionCategory)){
                                        tseToInsert.add(tse);
                                        alreadyInListToInsert.add(''+usrId+actDate+actionCategory);
                                }
                        }
                    } // Handle scenario where Custom-setting does not have Action-categoy value for given opening-action
                } // Handle scenario where Custom-setting is not present for given opening-action
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'end of TimeTrackerTriggerUtility.getTimesheetEntriesToInsert method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tseToInsert: ' + tseToInsert,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return  tseToInsert;
    }*/

    private static List<Timesheet_Entry__c> getTimesheetEntriesToInsertForAllUsers(List<Time_Tracker__c> ttList, Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails,
                                                                           Map<Id,Map<Date,Id>> datevsTimesheetMap, Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> dateTseMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getTimesheetEntriesToInsertForAllUsers method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList + ';\n\n mapOfActivityDetails: ' + mapOfActivityDetails
            + ';\n\n datevsTimesheetMap: ' + datevsTimesheetMap + ';\n\n dateTseMap: ' + dateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        List<Timesheet_Entry__c> tseToInsert = new List<Timesheet_Entry__c>();
        //alreadyInListToInsert set- is Used to check No-duplicate TSE are inserted
        set<String> alreadyInListToInsert = new set<String>();

        if(dateTseMap.isEmpty() || dateTseMap==null) dateTseMap = new Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>>();

        for(Time_Tracker__c closingTTRec : ttList){
            if(String.isNotBlank(closingTTRec.Opening_Action__c)) {
                Id usrId = closingTTRec.OwnerId;
                Date actDate = Date.newInstance(closingTTRec.Activity_Date__c.year(), closingTTRec.Activity_Date__c.month(), closingTTRec.Activity_Date__c.day());

                //Get Activity-details from Custom-settings
                TimeTrackerConfigSettings__c activityDetails  = mapOfActivityDetails.get(closingTTRec.Opening_Action__c);

                if(activityDetails!=null){

                    String actionCategory = '';
                    //Check Activity falls under Cancel-type Action-category
                    if(String.isNotBlank(activityDetails.Text7__c) && closingTTRec.Action__c.equalsIgnoreCase(activityDetails.Text7__c)){
                        actionCategory = activityDetails.Text8__c;
                    } else{
                        actionCategory = activityDetails.Text3__c;
                    }
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, '++--actionCategory : '+actionCategory,
                                                     Datetime.now(), null, null, null, UserInfo.getUserId());

                    if(String.isNotBlank(actionCategory)) {
                        if(dateTseMap.containsKey(usrId) && !dateTseMap.get(usrId).isEmpty()){
                            Map<String,Timesheet_Entry__c> tempMap = dateTseMap.get(usrId).get(actDate);
                            //Check if required Action-Category(Timesheet-entry for given date) is not present
                            if(tempMap!=null && !tempMap.isEmpty()){
                                if(!tempMap.containsKey(actionCategory)){
                                    //Create TSE for Action-category and given Date
                                    Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(actionCategory, actDate,
                                                                                        TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE,
                                                                                        datevsTimesheetMap.get(usrId).get(actDate),usrId);
                                    tse.isUtilized__c =  activityDetails != null ? activityDetails.Flag2__c : false;
                                    if(!alreadyInListToInsert.contains(''+usrId+actDate+actionCategory)){
                                        tseToInsert.add(tse);
                                        alreadyInListToInsert.add(''+usrId+actDate+actionCategory);
                                    }
                                }
                            } else {
                                //Create TSE for Action-category and given Date
                                Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(actionCategory, actDate,
                                                                                    TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE,
                                                                                    datevsTimesheetMap.get(usrId).get(actDate),usrId);
                                tse.isUtilized__c =  activityDetails != null ? activityDetails.Flag2__c : false;
                                if(!alreadyInListToInsert.contains(''+usrId+actDate+actionCategory)){
                                        tseToInsert.add(tse);
                                        alreadyInListToInsert.add(''+usrId+actDate+actionCategory);
                                }
                            }
                        } else {
                                //Create TSE for Action-category and given Date
                                Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(actionCategory, actDate,
                                                                                    TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE,
                                                                                    datevsTimesheetMap.get(usrId).get(actDate),usrId);
                                tse.isUtilized__c =  activityDetails != null ? activityDetails.Flag2__c : false;
                                if(!alreadyInListToInsert.contains(''+usrId+actDate+actionCategory)){
                                        tseToInsert.add(tse);
                                        alreadyInListToInsert.add(''+usrId+actDate+actionCategory);
                                }
                        }
                    } // Handle scenario where Custom-setting does not have Action-categoy value for given opening-action
                } // Handle scenario where Custom-setting is not present for given opening-action
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'end of TimeTrackerTriggerUtility.getTimesheetEntriesToInsertForAllUsers method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tseToInsert: ' + tseToInsert,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return  tseToInsert;
    }


    /*public static Map<Date, Map<String, Timesheet_Entry__c>> getMapOfDatevsActivityCategoryvsTimesheetEntries(List<Time_Tracker__c> ttList){
        // map of Timesheet Entries with Activity-Category as key
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getMapOfDatevsActivityCategoryvsTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Map<Date, Map<String, Timesheet_Entry__c>> dateTseMap = new Map<Date,Map<String, Timesheet_Entry__c>>();
        Map<Date,Id> datevsTimesheetMap = new Map<Date,Id>();
        List<Timesheet_Entry__c> tseToInsert = new List<Timesheet_Entry__c>();

        //Create set of Activity-dates
        set<Date> activityDateSet = getAllActivityDates(ttList);
        system.debug('##FirstLoop'+activityDateSet);

        Set<String> uniqueKeySet = getUniqueKeys(ttList);
        system.debug('##uniqueKeySet'+uniqueKeySet);

        //Get All Timesheet-entries for given set of Activity-dates
        List<Timesheet_Entry__c> tseList = new List<Timesheet_Entry__c>();
        tseList = [Select Id, Activity__c, Activity_Date__c, Timesheet__c, Unique_TimesheetEntry_Identifier__c From Timesheet_Entry__c
                    Where Unique_TimesheetEntry_Identifier__c IN :uniqueKeySet];
        system.debug('##ReturnedListofTSE'+tseList);

        //Create map of (Activity-date vs Timesheet-Id) and map of (Activate-Date vs ActionCategory vs TSE)
        createRequiredMaps(tseList, datevsTimesheetMap, dateTseMap);
        system.debug('##dateTseMap'+dateTseMap);
        system.debug('##datevsTimesheetMap'+datevsTimesheetMap);

        //Check for all Activity-dates we have required Timesheet-id and create if we don't
        createMissingTimesheetRecords(activityDateSet, datevsTimesheetMap);
        system.debug('@@updated datevsTimesheetMap'+ datevsTimesheetMap);

        //Get Map of Activity-details:
        Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails = TimeTrackerConfigSettings.getactivityvsActivityDetails();

        //Finally check for all Timesheet-entries we require and get list of Timesheet-entries to be inserted if don't have them
        tseToInsert = getTimesheetEntriesToInsert(ttList, mapOfActivityDetails, datevsTimesheetMap, dateTseMap);
        system.debug('##tseToInsert'+tseToInsert);

        // insert tseToInsert and update dateTseMap
        insertNewTimesheetEntriesForGivenDates(tseToInsert, dateTseMap);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.getMapOfDatevsActivityCategoryvsTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'dateTseMap: ' + dateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return dateTseMap;
    }*/

    public static Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> getUserSpecificDatevsActivityCategoryvsTimesheetEntries(List<Time_Tracker__c> ttList){
        // map of Timesheet Entries with Activity-Category as key
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.getUserSpecificDatevsActivityCategoryvsTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> userdateTseMap = new Map<Id,Map<Date,Map<String, Timesheet_Entry__c>>>();
        //Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> userdateTseMap = new Map<Id,Map<Date,Map<String, Timesheet_Entry__c>>>();
        Map<Id,Map<Date,Id>> userdatevsTimesheetMap = new Map<Id,Map<Date,Id>>();
        List<Timesheet_Entry__c> tseToInsert = new List<Timesheet_Entry__c>();

        //Create set of Activity-dates
        Map<Id,set<Date>> useractivityDateSet = getUserWiseAllActivityDates(ttList);
        system.debug('##FirstLoop'+useractivityDateSet);

        Set<String> uniqueKeySet = getUniqueKeys(ttList);
        system.debug('##uniqueKeySet'+uniqueKeySet);

        //Get All Timesheet-entries for given set of Activity-dates
        List<Timesheet_Entry__c> tseList = new List<Timesheet_Entry__c>();
        tseList = [Select Id, Activity__c, Activity_Date__c, Timesheet__c, Unique_TimesheetEntry_Identifier__c From Timesheet_Entry__c
                    Where Unique_TimesheetEntry_Identifier__c IN :uniqueKeySet];
        system.debug('##ReturnedListofTSE'+tseList);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, '#ReturnedListofTSE'+tseList,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        //Create map of (Activity-date vs Timesheet-Id) and map of (Activate-Date vs ActionCategory vs TSE)
        createRequiredMapsForAllUser(tseList, userdatevsTimesheetMap, userdateTseMap);
        system.debug('##userdateTseMap'+userdateTseMap);
        system.debug('##userdatevsTimesheetMap'+userdatevsTimesheetMap);

        //Check for all Activity-dates we have required Timesheet-id and create if we don't
        for(Id userId : useractivityDateSet.keySet()){
            if(useractivityDateSet.get(userId)==null ) continue;
            createMissingTimesheetRecordsForUser(useractivityDateSet, userdatevsTimesheetMap,userId);
        }
        system.debug('@@updated userdatevsTimesheetMap'+ userdatevsTimesheetMap);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, '#updated userdatevsTimesheetMap'+userdatevsTimesheetMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        //Get Map of Activity-details:
        Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails = TimeTrackerConfigSettings.getactivityvsActivityDetails();

        //Finally check for all Timesheet-entries we require and get list of Timesheet-entries to be inserted if don't have them
        tseToInsert = getTimesheetEntriesToInsertForAllUsers(ttList, mapOfActivityDetails, userdatevsTimesheetMap, userdateTseMap);
        system.debug('##tseToInsert'+tseToInsert);

        // insert tseToInsert and update dateTseMap
        insertNewTimesheetEntriesForGivenDatesForAllUsers(tseToInsert, userdateTseMap);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.getUserSpecificDatevsActivityCategoryvsTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'dateTseMap: ' + userdateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return userdateTseMap;
    }

    private static Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> insertNewTimesheetEntriesForGivenDatesForAllUsers(List<Timesheet_Entry__c> tseToInsert, Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> uservsdateTseMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.insertNewTimesheetEntriesForGivenDatesForAllUsers method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tseToInsert: ' + tseToInsert + '; uservsdateTseMap: ' + uservsdateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Set<Id> newtseIds = new Set<Id>();

        if(!tseToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(tseToInsert, false);
            for(Database.SaveResult sr : results) {
                // check if the insert was successful
                if (!sr.isSuccess()) {
                    system.debug('Timesheet Entry Records Insert failed! Id: [' + sr.getId() + '], Error: ' + sr.getErrors());
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Error while creating TSE in insertNewTimesheetEntriesForGivenDatesForAllUsers method.',
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                    TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Error: ' + sr.getErrors(),
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                } else {
                    newtseIds.add(sr.getId());
                }
            }
        }

        // get the the most recent Timesheet Entry record(s) that are inserted
        if(!newtseIds.isEmpty()) {
            List<Timesheet_Entry__c> newtseList = [Select Id, Activity__c, Activity_Date__c, Timesheet__c, Unique_TimesheetEntry_Identifier__c From Timesheet_Entry__c
                                                Where Id IN :newtseIds];

            if(newtseList != null && !newtseList.isEmpty()) {
                for(Timesheet_Entry__c tse : newtseList) {
                    Date actDate = Date.newInstance(tse.Activity_Date__c.year(), tse.Activity_Date__c.month(), tse.Activity_Date__c.day());
                    Id usrId = (Id) tse.Unique_TimesheetEntry_Identifier__c.split('-').get(1);

                    if(uservsdateTseMap.containsKey(usrId) && uservsdateTseMap.get(usrId).containsKey(actDate)){
                        uservsdateTseMap.get(usrId).get(actDate).put(tse.Activity__c,tse);
                    } else if(uservsdateTseMap.containsKey(usrId)) {
                        uservsdateTseMap.get(usrId).put(actDate, new Map<String, Timesheet_Entry__c>{tse.Activity__c => tse});
                    } else {
                        uservsdateTseMap.put(usrId, new Map<Date, Map<String, Timesheet_Entry__c>>());
                        uservsdateTseMap.get(usrId).put(actDate, new Map<String, Timesheet_Entry__c>{tse.Activity__c => tse});
                    }
                }
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.insertNewTimesheetEntriesForGivenDatesForAllUsers method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'uservsdateTseMap: ' + uservsdateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return uservsdateTseMap;
    }

    /*private static Map<Date, Map<String, Timesheet_Entry__c>> insertNewTimesheetEntriesForGivenDates(List<Timesheet_Entry__c> tseToInsert, Map<Date, Map<String, Timesheet_Entry__c>> dateTseMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerUtility.insertNewTimesheetEntriesForGivenDates method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tseToInsert: ' + tseToInsert + '; dateTseMap: ' + dateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Set<Id> newtseIds = new Set<Id>();

        if(!tseToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(tseToInsert, false);
            for(Database.SaveResult sr : results) {
                // check if the insert was successful
                if (!sr.isSuccess()) {
                    system.debug('Timesheet Entry Records Insert failed! Id: [' + sr.getId() + '], Error: ' + sr.getErrors());
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Error while creating TSE in insertNewTimesheetEntriesForGivenDates method.',
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                    TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Error: ' + sr.getErrors(),
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                } else {
                    newtseIds.add(sr.getId());
                }
            }
        }

        // get the the most recent Timesheet Entry record(s) that are inserted
        if(!newtseIds.isEmpty()) {
            List<Timesheet_Entry__c> newtseList = [Select Id, Activity__c, Activity_Date__c, Timesheet__c, Unique_TimesheetEntry_Identifier__c From Timesheet_Entry__c
                                                Where Id IN :newtseIds];

            if(newtseList != null && !newtseList.isEmpty()) {
                for(Timesheet_Entry__c tse : newtseList) {
                    Date actDate = Date.newInstance(tse.Activity_Date__c.year(), tse.Activity_Date__c.month(), tse.Activity_Date__c.day());
                    if(dateTseMap.containsKey(actDate)){
                        dateTseMap.get(actDate).put(tse.Activity__c,tse);
                    } else{
                        dateTseMap.put(actDate, new Map<String,Timesheet_Entry__c>{tse.Activity__c => tse});
                    }
                }
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerUtility.insertNewTimesheetEntriesForGivenDates method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'dateTseMap: ' + dateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return dateTseMap;
    }*/
}