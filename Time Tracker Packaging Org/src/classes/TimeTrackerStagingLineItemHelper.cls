public class TimeTrackerStagingLineItemHelper {

    /**
    * @description method to get locked timsheets of those users who created staging records
    * @param List<TimeTracker_StagingLineItem__c>: stagingLineItemsList
    * @return Map<Id,Timesheet__c>: 
    */
    public static Map<Id,Timesheet__c> getLockedTimesheetsOfStagingUser(List<TimeTracker_StagingLineItem__c> stagingLineItemsList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Start of TimeTrackerStagingLineItemHelper.getLockedTimesheetsOfStagingUser method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());

        Map<Id, Timesheet__c> tsToUnlock = new Map<Id,Timesheet__c>();
        Set<Id> userIdSet = new Set<Id>();

        for(TimeTracker_StagingLineItem__c stLineItem : stagingLineItemsList) {
            userIdSet.add(stLineItem.OwnerId);
        }
        tsToUnlock = TimeTrackerUtility.getLockedTimesheets(System.today(), userIdSet);

        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Locked Timesheets, tsToUnlock: ' + tsToUnlock ,
        Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItemHelper.getLockedTimesheetsOfStagingUser method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
        return tsToUnlock;
    }

    /**
    * @description method to change status of approved or rejected timesheets to New(temporary) so that we can roll-up satgin records to timesheet
    * @param Set<Id>: timesheetIdSet
    * @return Boolean: result of DML operation
    */
    public static Boolean temporaryChangeStatusOfLockedTimesheets(Set<Id> timesheetIdSet) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Start of TimeTrackerStagingLineItemHelper.temporaryChangeStatusOfLockedTimesheets method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());

        Boolean result = false;
        List<Timesheet__c> tsListBeforeBatchRun = new List<Timesheet__c>();
        for(Id tsId :timesheetIdSet) {
            Timesheet__c ts = new Timesheet__c();
            ts.Id = tsId;
            ts.Status__c = 'New';
            tsListBeforeBatchRun.add(ts);
        }
        try {
            update tsListBeforeBatchRun;
            result=true;
        } catch(DmlException  ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Exception found In TimeTrackerStagingLineItemHelper.temporaryChangeStatusOfLockedTimesheets : ' + ex ,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Timesheet update result before batch run: ' + result + ', Timesheet Details(tsListBeforeBatchRun): '+ tsListBeforeBatchRun ,
        Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItemHelper.temporaryChangeStatusOfLockedTimesheets method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
        return result;
    }

    /**
    * @description method to change status of timesheet to their original status 
    * @param Map<Id, Timesheet__c>: lockedTimesheetMap
    * @return Boolean: result of DML operation
    */
    public static Boolean reassignOriginalStatusForLockedTimesheet(Map<Id, Timesheet__c> lockedTimesheetMap) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Start of TimeTrackerStagingLineItemHelper.reassignOriginalStatusForLockedTimesheet method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());

        Boolean result = false;
        List<Timesheet__c> tsListAfterBatchRun = new List<Timesheet__c>();
        for(Timesheet__c oldTs: lockedTimesheetMap.values()) {
            Timesheet__c ts = new Timesheet__c();
            ts.Id = oldTs.Id;
            ts.Status__c = oldTs.Status__c;
            tsListAfterBatchRun.add(ts);
        }
        try {
            update tsListAfterBatchRun;
            result=true;
        } catch(DmlException ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Exception found In TimeTrackerStagingLineItemHelper.reassignOriginalStatusForLockedTimesheet : ' + ex ,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        } 
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Timesheet update result after batch run: ' + result +', Timesheets Details(tsListAfterBatchRun) : '+tsListAfterBatchRun ,
        Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItemHelper.reassignOriginalStatusForLockedTimesheet method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
        return result;
    }

	public static Map<Id,Time_Tracker__c> getTimeTrackersInsertList(List<TimeTracker_StagingLineItem__c> stagingLineItems){
        Map<Id,Time_Tracker__c> ttRecordsToUpsert = new Map<Id,Time_Tracker__c>();
        Map<Id,Time_Tracker__c> ttRecordsToUpsert_ForUser = new Map<Id,Time_Tracker__c>();


        Set<Id> allTimeTrackerIds = new Set<Id>();
        Map<Id,List<TimeTracker_StagingLineItem__c>> userVsStagingRecords = new Map<Id,List<TimeTracker_StagingLineItem__c>>();
        Map<Id,List<Time_Tracker__c>> userVsTimeTrackerRecords = new Map<Id,List<Time_Tracker__c>>();

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        
        for(TimeTracker_StagingLineItem__c stgRecord : stagingLineItems) {
            //Iterate and Get Staging-records having associated TimeTracker
            if(stgRecord.TimeTracker_Associated__c!=NULL){
                allTimeTrackerIds.add(stgRecord.TimeTracker_Associated__c);                    
            }

            //Create Map of User(owner)-vs-Staging records
            if(userVsStagingRecords.containsKey(stgRecord.OwnerId)) {
                userVsStagingRecords.get(stgRecord.OwnerId).add(stgRecord);
            } else {
                userVsStagingRecords.put(stgRecord.OwnerId, (new List<TimeTracker_StagingLineItem__c> { stgRecord }));
            }
        }

        //Retrieve all Time-trackers to be updated
        if(allTimeTrackerIds!=null){
            List<Time_Tracker__c> updTTLst = [SELECT Id,Duration__c,OwnerId FROM Time_Tracker__c WHERE Id In : allTimeTrackerIds];
            
            //Create Map of User(owner)-vs-TimeTracker records (to update)
            if(updTTLst!=null && updTTLst.size()>0){
                for(Time_Tracker__c ttRec: updTTLst){
                    if(userVsTimeTrackerRecords.containsKey(ttRec.OwnerId)) {
                        userVsTimeTrackerRecords.get(ttRec.OwnerId).add(ttRec);
                    } else {
                        userVsTimeTrackerRecords.put(ttRec.OwnerId, (new List<Time_Tracker__c> { ttRec }));
                    }
                }
            }
        }        
    
        //For all Owners Re-concile time
        for(Id owner:userVsStagingRecords.keyset()){
            ttRecordsToUpsert_ForUser = getTimeTrackersInsertList_ForUser(userVsStagingRecords.get(owner),userVsTimeTrackerRecords.get(owner));
            ttRecordsToUpsert.putAll(ttRecordsToUpsert_ForUser);
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());

        return ttRecordsToUpsert;
    }
    
    private static Map<Id,Time_Tracker__c> getTimeTrackersInsertList_ForUser(List<TimeTracker_StagingLineItem__c> stagingLineItems, List<Time_Tracker__c> updTTLstForUser){
        //Create Map of Staging-record-Id vs TimeTracker-record to insert/update
        Map<Id,Time_Tracker__c> ttRecordsToUpsert = new Map<Id,Time_Tracker__c>();
        
        //Used when we have to update associated TT-record
        Map<Id,Decimal> contextvsTimeToDeduct = new Map<Id,Decimal>();
        
        //Used when we have to update associated TT-record-having duration less than Exclude-time
        Map<Id,Decimal> considervsConsiderTime = new Map<Id,Decimal>();
        
        //Used to track all staging-records that overlaps with Given Staging-record
        Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap = new Map<Id,List<TimeTracker_StagingLineItem__c>>();
        
        Map<Id,Id> timeTrackerVsContext = new Map<Id,Id>();
        Map<Id,Time_Tracker__c> contextVsTTRec = new Map<Id,Time_Tracker__c>();
        
        try{
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList_ForUser method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'stagingLineItems: ' + stagingLineItems + ' \nupdTTLstForUser:: ' +updTTLstForUser,
                Datetime.now(), null, null, null, UserInfo.getUserId());
            
            //Iterate and Get Staging-records having associated TimeTracker
            for(TimeTracker_StagingLineItem__c context : stagingLineItems) {
                if(context.TimeTracker_Associated__c!=NULL){
                    timeTrackerVsContext.put(context.TimeTracker_Associated__c, context.Id);                    
                }
            }

            //Create Map of Context-vs-TimeTracker Record
            if(updTTLstForUser!=null && updTTLstForUser.size()>0){
                for(Time_Tracker__c ttRec: updTTLstForUser){                    
                    //Continue if No-context found for given Time-tracker record
                    if(timeTrackerVsContext.get(ttRec.Id)==null) {continue;}

                    contextVsTTRec.put(timeTrackerVsContext.get(ttRec.Id),ttRec);
                }
            }
            
            //Create TimeTracker-records list to be inserted
            for(TimeTracker_StagingLineItem__c context : stagingLineItems) {

                Boolean hasAssociatedTT = (context.TimeTracker_Associated__c!=NULL)?true:false;
                //Continue if Context has TT-associated
                if(hasAssociatedTT){continue;}

                Map<Datetime,Datetime> excludeMap = new Map<Datetime,Datetime>();

                //This will return updated excludeMap which we are passing by reference
                processForContext(context,stagingLineItems,hasAssociatedTT,excludeMap,contextVsConsiderSetMap);                
                
                //Calculate Exclude-time using Exclude-Map created above
                Decimal excludeTime = 0;
                for(Datetime startDt: excludeMap.keyset()){
                    excludeTime += (excludeMap.get(startDt).getTime() - startDt.getTime() )/1000;
                }
                
                //Create New Time-tracker record to be inserted
                Time_Tracker__c ttRecIns = TimeTrackerUtility.createTTFromStagingRecord(context,excludeTime);

                //If reconciled time is less than 1- Keep it one for documentation purpose
                ttRecIns.Duration__c = (ttRecIns.Duration__c<1)?1:ttRecIns.Duration__c;

                //insert Time-tracker record in list
                ttRecordsToUpsert.put(context.Id,ttRecIns);

                //Make Map-entry as Context-vs-ContextDuration
                considervsConsiderTime.put(context.Id,((context.End_Date__c.getTime() - context.Start_Date__c.getTime())/1000)-excludeTime);
            }


            //Create TimeTracker-records list to be updated
            for(TimeTracker_StagingLineItem__c context : stagingLineItems) {

                Boolean hasAssociatedTT = (context.TimeTracker_Associated__c!=NULL)?true:false;
                if(!hasAssociatedTT){continue;}

                Map<Datetime,Datetime> excludeMap = new Map<Datetime,Datetime>();

                //This will return updated excludeMap which we are passing by reference
                processForContext(context,stagingLineItems,hasAssociatedTT,excludeMap,contextVsConsiderSetMap);                
                
                //Calculate Exclude-time using Exclude-Map created above
                Decimal excludeTime = 0;
                for(Datetime startDt: excludeMap.keyset()){
                    excludeTime += (excludeMap.get(startDt).getTime() - startDt.getTime() )/1000;
                }
                
                Time_Tracker__c ttRecToUpdate = contextVsTTRec.get(context.Id);
                Decimal actualTTRecDuration = ttRecToUpdate.Duration__c;
                Decimal contextTime = ( context.End_Date__c.getTime() - context.Start_Date__c.getTime())/1000;
                
                //Check ExcludeTime is less than Actual-time TimeTracker-record 
                if(excludeTime<=actualTTRecDuration){
                    ttRecToUpdate.Duration__c = actualTTRecDuration - excludeTime;
                }else{
                    
                    List<TimeTracker_StagingLineItem__c> considerLst = contextVsConsiderSetMap.get(context.Id);
                    if(considerLst.size()>0){
                        //Sort the given Overlapsed staging records
                        considerLst.sort();
                        
                        Decimal finalTimeToDeduct = 0;
                        for(TimeTracker_StagingLineItem__c consider: considerLst){
                            //Break if Max-time that can be deducted is reached
                            if(finalTimeToDeduct==actualTTRecDuration) break;
                            
                            Decimal considerTime = considervsConsiderTime.get(consider.Id);
                            
                            if( (finalTimeToDeduct+considerTime)<=actualTTRecDuration){
                                finalTimeToDeduct+=considerTime;
                                considervsConsiderTime.put(consider.Id,0);
                            } //Partial deduction required
                            else{
                                Decimal temp = actualTTRecDuration - finalTimeToDeduct;
                                finalTimeToDeduct+=temp;
                                considervsConsiderTime.put(consider.Id,considerTime-temp);
                            }
                        }
                        ttRecToUpdate.Duration__c = actualTTRecDuration - finalTimeToDeduct;
                    }
                }
                
                ttRecToUpdate.Duration__c = (ttRecToUpdate.Duration__c<=0)?1:ttRecToUpdate.Duration__c;
                ttRecordsToUpsert.put(context.Id,ttRecToUpdate);
            }            

            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList_ForUser method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());            
        } catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        } finally {
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'TimeTracker records to insert'+ttRecordsToUpsert,
                Datetime.now(), null, null, null, UserInfo.getUserId());            
            TimeTrackerUtility.upsertLogRecord();
        }
        return ttRecordsToUpsert;
    }

    private static void processForContext(TimeTracker_StagingLineItem__c context,
                                          List<TimeTracker_StagingLineItem__c> stagingLineItems,
                                          Boolean hasAssociatedTT,
                                          Map<Datetime,Datetime> excludeMap,
                                          Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap){
                                              
                contextVsConsiderSetMap.put(context.Id, new List<TimeTracker_StagingLineItem__c>());
                                             
                //Iterate over all staging-records to check for Overlapping                              
      			for(TimeTracker_StagingLineItem__c consider: stagingLineItems){  
                    //system.debug('$$Consider:'+consider);
                    
                    //Skip Automated-activities
                    if(consider.TimeTracker_Associated__c!=NULL){
                    	continue;
                	}//Skip if same record
                    else if(context.Id == consider.Id){
                    	continue;
                    }//Skip Older staging-records Or Records created after Context-record
                    else if(consider.End_Date__c <= context.Start_Date__c || context.End_Date__c <= consider.Start_Date__c){
						continue;
                    } // Records which are elapsed throughout context-record 
                    else if(consider.Start_Date__c <= context.Start_Date__c 
                            && context.End_Date__c <= consider.End_Date__c){
                        
                        // Exclude entire Context-duration
                        if(hasAssociatedTT){
                            excludeMap.clear();
                            excludeMap.put(context.Start_Date__c,context.End_Date__c);
                            //Handle****
                            //contextVsConsiderSetMap.get(context.Id).add(context.Id);
                            break;
                        } //Continue When hasAssociatedTT-is-false
                        else {
                            continue;
                        }
                    }

                    //Records Starting and Ending within Context
                    if(consider.Start_Date__c > context.Start_Date__c && consider.End_Date__c <= context.End_Date__c){
                    	
                        //Process-records Starting and Ending within Context
                        processRecord_StartingAndEnding_WithinContext(excludeMap, context, consider,hasAssociatedTT,contextVsConsiderSetMap);

                    } //Records Starting within Context and ending after Context
                    else if( (context.Start_Date__c < consider.Start_Date__c   && consider.Start_Date__c < context.End_Date__c)
                    		&& context.End_Date__c < consider.End_Date__c){
                        
                        //Process-records Starting within Context and Ending after Context
                        processRecord_StartingWithinContext_EndingAfterContext(excludeMap, context, consider,hasAssociatedTT,contextVsConsiderSetMap);

                    }//Records Started earlier and Ending within Context are not processed
                    else  if(hasAssociatedTT
                            && consider.Start_Date__c < context.Start_Date__c 
                            && (context.Start_Date__c < consider.End_Date__c && consider.End_Date__c < context.End_Date__c)){
                        
                        //Process-records Starting Before Context and Ending Within Context
                        processRecord_StartingBeforeContext_EndingWithinContext(excludeMap, context, consider,hasAssociatedTT,contextVsConsiderSetMap);

                    }
                }
                //system.debug('##contextVsConsiderSetMap for ::'+ context + '=>'+contextVsConsiderSetMap.get(context.Id));
    }

    private static void processRecord_StartingAndEnding_WithinContext(Map<Datetime,Datetime> excludeMap, 
                                                                      TimeTracker_StagingLineItem__c context,
                                                                      TimeTracker_StagingLineItem__c consider,
                                                                      Boolean hasAssociatedTT,
                                                                      Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap){

        //Check if No-records present in Exclude-Map
        if(excludeMap.size()>0){
            
            //Iterate over Exclude-map record to check if there is some overlapping
            for(Datetime xmstartDt:excludeMap.keyset() ){

                Datetime xmendDt = excludeMap.get(xmstartDt);
                
                // Exit loop if Consider-Record falling totally within StartDt and EndDt
                if(xmstartDt<= consider.Start_Date__c && consider.End_Date__c <= xmendDt){
                    break;
                } //Record falling completely out of All StartDt and EndDt in Exclude-Map
                else if( consider.Start_Date__c < xmstartDt  && consider.End_Date__c < xmstartDt 
                    ||consider.Start_Date__c > xmendDt  && consider.End_Date__c > xmendDt){
                    
                    //Process-records that does-not overlap with any Exclude-map entry
                    processRecord_DoesnotOverlap_WithAny_ExcludeMapEntries(excludeMap,context,consider,hasAssociatedTT,contextVsConsiderSetMap);

                } //Record started between Exclude-map-entry-StartDt & Exclude-map-entry-EndDt but ended after Exclude-map-entry-EndDt  
                else if ((xmstartDt < consider.Start_Date__c && consider.Start_Date__c < xmendDt)
                         && consider.End_Date__c > xmendDt){
                    
                    //Process-records started between Exclude-map-entry-StartDt & EndDt but ended after Exclude-map-entry-EndDt  
                    processRecord_StartingWithinSome_ExcludeMapEntry_EndedAfter_ThatMapEntry(excludeMap,context,consider,xmendDt,hasAssociatedTT,contextVsConsiderSetMap);
                }
            } //End of Exclude-map For-loop
        } else{ 
            excludeMap.put(consider.Start_Date__c, consider.End_Date__c);
            contextVsConsiderSetMap.get(context.Id).add(consider);
        }
    
    }

    private static void processRecord_DoesnotOverlap_WithAny_ExcludeMapEntries(Map<Datetime,Datetime> excludeMap, 
                                                                            TimeTracker_StagingLineItem__c context,
                                                                            TimeTracker_StagingLineItem__c consider,
                                                                      		Boolean hasAssociatedTT,
                                                                      		Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap){
        Boolean doesNotOverlapse = true;

        //Check if Overlapses with any Entry
        for(Datetime tstartDt:excludeMap.keyset()){
            Datetime tendDt = excludeMap.get(tstartDt);

            if( (tstartDt < consider.Start_Date__c && consider.Start_Date__c < tendDt) 
                || (tstartDt < consider.End_Date__c && consider.End_Date__c < tendDt)){
                doesNotOverlapse = false;
                break;
            }

        }


        if(doesNotOverlapse){
            excludeMap.put(consider.Start_Date__c,consider.End_Date__c);
            contextVsConsiderSetMap.get(context.Id).add(consider);
        }        
    }

    private static void processRecord_StartingWithinSome_ExcludeMapEntry_EndedAfter_ThatMapEntry(Map<Datetime,Datetime> excludeMap, 
                                                                            TimeTracker_StagingLineItem__c context,
                                                                            TimeTracker_StagingLineItem__c consider,
                                                                            Datetime xmendDt,
                                                                      		Boolean hasAssociatedTT,
                                                                      		Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap){

        Boolean startpresentInMap = true;

        /*for(Datetime tstartDt:excludeMap.keyset()){
            Datetime tendDt = excludeMap.get(tstartDt);
            if(consider.End_Date__c > tendDt && 
                (tstartDt < consider.Start_Date__c && consider.Start_Date__c < tendDt)){
                startpresentInMap = true;
                system.debug('#4.4.0'+ consider);
                break;
            }
        }*/

        Boolean endpresentInMap = false;
        Datetime tempEndDateTime;
        if(startpresentInMap){ 

            
            for(Datetime tstartDt:excludeMap.keyset()){
                Datetime tendDt = excludeMap.get(tstartDt);
                if(consider.Start_Date__c < tstartDt && 
                    (tstartDt < consider.End_Date__c && consider.End_Date__c < tendDt)){
                    endpresentInMap = true;
                    tempEndDateTime = tstartDt;
                    break;
                }
            }
            //This is to handle scenario where Exclude-map entry 
            //has same Start-date but different End-date
            if(endpresentInMap){
                if(excludeMap.get(xmendDt)!=null){
                    //Keep maximum Exclude-time
                    if(tempEndDateTime>excludeMap.get(xmendDt)){
                        excludeMap.put(xmendDt,tempEndDateTime);
            			contextVsConsiderSetMap.get(context.Id).add(consider);
                    }
                } else {
                    excludeMap.put(xmendDt,tempEndDateTime);
            		contextVsConsiderSetMap.get(context.Id).add(consider);
                }
            }else{
                if(excludeMap.get(xmendDt)!=null){
                    //Keep maximum Exclude-time
                    if(consider.End_Date__c>excludeMap.get(xmendDt)){
                        excludeMap.put(xmendDt,consider.End_Date__c);
            			contextVsConsiderSetMap.get(context.Id).add(consider);
                    }
                } else {
                    excludeMap.put(xmendDt,consider.End_Date__c);
            		contextVsConsiderSetMap.get(context.Id).add(consider);
                }
            }
        }
    }

    private static void processRecord_StartingWithinContext_EndingAfterContext(Map<Datetime,Datetime> excludeMap, 
                                                                            TimeTracker_StagingLineItem__c context,
                                                                            TimeTracker_StagingLineItem__c consider,
                                                                      		Boolean hasAssociatedTT,
                                                                      		Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap){
                        
        //Check if No-records present in Exclude-Map                        
        if(excludeMap.size()>0){
            Boolean overlaps = false;

            //Iterate over Exclude-map record to check if there is some overlapping
            for(Datetime startDt:excludeMap.keyset()){
                Datetime endDt = excludeMap.get(startDt);

                //Record started between startDt and endDt
                if( startDt < consider.Start_Date__c && consider.Start_Date__c < endDt ){
                    overlaps = true;
                    excludeMap.put(endDt, context.End_Date__c);                    
            		contextVsConsiderSetMap.get(context.Id).add(consider);
                    break;
                }
            }

            if(!overlaps){
                excludeMap.put(consider.Start_Date__c, context.End_Date__c);
            	contextVsConsiderSetMap.get(context.Id).add(consider);
            }
        } else { 
            excludeMap.put(consider.Start_Date__c, context.End_Date__c);
            contextVsConsiderSetMap.get(context.Id).add(consider);
        }        
    }

    private static void processRecord_StartingBeforeContext_EndingWithinContext(Map<Datetime,Datetime> excludeMap, 
                                                                            TimeTracker_StagingLineItem__c context,
                                                                            TimeTracker_StagingLineItem__c consider,
                                                                      		Boolean hasAssociatedTT,
                                                                      		Map<Id,List<TimeTracker_StagingLineItem__c>> contextVsConsiderSetMap){
                        
        //Check if No-records present in Exclude-Map                        
        if(excludeMap.size()>0){
            Boolean overlaps = false;
            Datetime largestEndTimeInMap = context.Start_Date__c;

            //Iterate over Exclude-map record to check if there is some overlapping
            for(Datetime startDt:excludeMap.keyset()){
                Datetime endDt = excludeMap.get(startDt);

                largestEndTimeInMap = (endDt>largestEndTimeInMap)?endDt:largestEndTimeInMap;

                //Record ending between startDt and endDt
                if( startDt < consider.End_Date__c && consider.End_Date__c < endDt ){
                    overlaps = true;
                    break;
                }
            }

            if(!overlaps){  
                // Check for Greater Value
                excludeMap.put(largestEndTimeInMap, consider.End_Date__c);
            	contextVsConsiderSetMap.get(context.Id).add(consider);
            }
        } else { 
            excludeMap.put(context.Start_Date__c, consider.End_Date__c);
            contextVsConsiderSetMap.get(context.Id).add(consider);
        }        
    }    

}