public with sharing class AmitDevStaging {
	static Set<Id> errorIds;

	    public static integer execute(List<sObject> scope)
    {
    	try{
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerStagingLineItem.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'scope: ' + scope,
                Datetime.now(), null, null, null, UserInfo.getUserId());

            errorIds = new Set<Id>();
            Map<Id,Time_Tracker__c> ttRecordsToInsert = new Map<Id,Time_Tracker__c>();


            List<TimeTracker_StagingLineItem__c> stagingLineItems = (List<TimeTracker_StagingLineItem__c>) scope;
            system.debug('!!!!Without'+ stagingLineItems);

            ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingLineItems);
            List<TimeTracker_StagingLineItem__c> onlyProcess = [SELECT End_Date__c,Start_Date__c,Object_Id__c,Object_Name__c,Id, Name, Activity_Name__c FROM TimeTracker_StagingLineItem__c ORDER BY Start_Date__c];

    
            //Create TimeTracker-records list to be inserted
            for(TimeTracker_StagingLineItem__c context : stagingLineItems) {

                Map<Datetime,Datetime> excludeMap = new Map<Datetime,Datetime>();

                  for(TimeTracker_StagingLineItem__c consider:onlyProcess){  
                    system.debug('$$Consider:'+consider);
                    
                    //Skip if same record
                    if(context.Id == consider.Id){
                        continue;
                    }//Skip Older staging-records Or Records created after Context-record
                    else if(consider.End_Date__c < context.Start_Date__c || context.End_Date__c < consider.Start_Date__c){
						system.debug('#0 Skip Older staging-records');
                        continue;
                    } // Skip Records which are elapsed throughout context-record
                    else if(consider.Start_Date__c < context.Start_Date__c && context.End_Date__c < consider.Start_Date__c){
                        system.debug('#1 Skip Records which are elapsed throughout context-record');
                        continue;
                    }

                    //Records Starting and Ending within Context
                    if(consider.Start_Date__c > context.Start_Date__c && consider.End_Date__c < context.End_Date__c){
                    	system.debug('#4'+ consider);
                        if(excludeMap.size()>0){
                            
                            //Iterate over Exclude-map record to check if there is some overlapping
                            for(Datetime xmstartDt:excludeMap.keyset()){
                            	Datetime xmendDt = excludeMap.get(xmstartDt);
                                
                                // Exit loop if Consider-Record falling totally within StartDt and EndDt
                                if(xmstartDt< consider.Start_Date__c && consider.End_Date__c < xmendDt){
                                    system.debug('#4.1'+ consider); 
                                	break;
                                } //Record falling completely out of All StartDt and EndDt in Exclude-Map
                                else if( consider.Start_Date__c < xmstartDt  && consider.End_Date__c < xmstartDt 
                                	||consider.Start_Date__c > xmendDt  && consider.End_Date__c > xmendDt){
                                    system.debug('#4.2'+ consider);

                                    Boolean doesNotOverlapse = true;

                                    //Check if Overlapses with any Entry
                                    for(Datetime tstartDt:excludeMap.keyset()){
                                        Datetime tendDt = excludeMap.get(tstartDt);
                                        system.debug('###!Start'+tstartDt +'!!End'+tendDt );
                                        if( (tstartDt < consider.Start_Date__c && consider.Start_Date__c < tendDt) 
                                            || (tstartDt < consider.End_Date__c && consider.End_Date__c < tendDt)){
                                            doesNotOverlapse = false;
                                            system.debug('#4.2.0'+ consider);
                                            break;
                                        }
                                    }


                                    if(doesNotOverlapse){ 
                                        system.debug('#4.2.1'+ consider);
                                        system.debug('@B4'+excludeMap);
                                        excludeMap.put(consider.Start_Date__c,consider.End_Date__c);
                                        system.debug('@After'+excludeMap);
                                    }
                                } //Record started between Exclude-map-entry-StartDt & Exclude-map-entry-EndDt but ended after Exclude-map-entry-EndDt  
                                else if ((xmstartDt < consider.Start_Date__c && consider.Start_Date__c < xmendDt)
                                         && consider.End_Date__c > xmendDt){
                                	system.debug('#4.4'+ consider);
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

                                        system.debug('#4.4.1'+ consider);
                                        
                                        for(Datetime tstartDt:excludeMap.keyset()){
                                            Datetime tendDt = excludeMap.get(tstartDt);
                                            if(consider.Start_Date__c < tstartDt && 
                                                (tstartDt < consider.End_Date__c && consider.End_Date__c < tendDt)){
                                                endpresentInMap = true;
                                                tempEndDateTime = tstartDt;
                                                system.debug('#4.4.2'+ consider);
                                                break;
                                            }
                                        }
                                        //This is to handle scenario where Exclude-map entry 
                                        //has same Start-date but different End-date
                                        system.debug('@B4'+excludeMap);
                                        if(endpresentInMap){
                                            if(excludeMap.get(xmendDt)!=null){
                                                //Keep maximum Exclude-time
                                                if(tempEndDateTime>excludeMap.get(xmendDt)){
                                                    excludeMap.put(xmendDt,tempEndDateTime);
                                                }
                                            } else {
                                                excludeMap.put(xmendDt,tempEndDateTime);
                                            }
                                        }else{
                                            if(excludeMap.get(xmendDt)!=null){
                                                //Keep maximum Exclude-time
                                                if(consider.End_Date__c>excludeMap.get(xmendDt)){
                                                    excludeMap.put(xmendDt,consider.End_Date__c);
                                                }
                                            } else {
                                                excludeMap.put(xmendDt,consider.End_Date__c);
                                            }
                                        }
                                        system.debug('@After'+excludeMap);
                                    }
                                }

                            }

                    	}else{ system.debug('#4.0'+ consider);
                    		excludeMap.put(consider.Start_Date__c, consider.End_Date__c);
                   		}
                    } //Records Starting within Context and ending later
                    else if( (context.Start_Date__c < consider.Start_Date__c   && consider.Start_Date__c < context.End_Date__c)
                    		&& context.End_Date__c < consider.End_Date__c){
                        
                        system.debug('#6'+ consider);
                        
                        if(excludeMap.size()>0){
 							Boolean overlaps = false;

                            //Iterate over Exclude-map record to check if there is some overlapping
                            for(Datetime startDt:excludeMap.keyset()){
                            	Datetime endDt = excludeMap.get(startDt);

                            	//Record started between startDt and endDt
                                if( startDt < consider.Start_Date__c && consider.Start_Date__c < endDt ){
                                    system.debug('#6.1'+ consider);
                                    overlaps = true;
                                    excludeMap.put(endDt, context.End_Date__c);
                                    break;
                                }
                            }

                            if(!overlaps){ 
                                system.debug('#6.2'+ consider);
                            	excludeMap.put(consider.Start_Date__c, context.End_Date__c);
                            }
                        } else { 
                            system.debug('#6.0'+ consider);
                            excludeMap.put(consider.Start_Date__c, context.End_Date__c);
                        }
                    }/*Records Started earlier and Ending within Context are not processed
                    else  if(consider.Start_Date__c < context.Start_Date__c 
                            && (context.Start_Date__c < consider.End_Date__c && consider.End_Date__c < context.End_Date__c)){
                    }*/
                    system.debug('%%updated excludeMap:'+excludeMap);
                }

                Decimal timeExclude = 0;
                for(Datetime startDt: excludeMap.keyset()){
                    system.debug('!!'+startDt +'-' + excludeMap.get(startDt));
                    timeExclude += (excludeMap.get(startDt).getTime() - startDt.getTime() )/1000;
                }
                Decimal elapsedTime = ((context.End_Date__c.getTime()-context.Start_Date__c.getTime()))/1000;
                system.debug('######'+context.Activity_Name__c+'::Exclude-Time:'+timeExclude + '$$elapsedTime:' + elapsedTime + '<<Final:'+ (elapsedTime-timeExclude));
                //add TimeTracker-record to List
            	//ttRecordsToInsert.add(createTTFromStagingRecord(context));
                return (integer) (elapsedTime-timeExclude);
            }

            List<Database.SaveResult> resultList = Database.insert(ttRecordsToInsert.values(), false);
            for(Database.SaveResult result : resultList) {
                if(!result.isSuccess()){
                    errorIds.add(result.getId());
                    //get IDs of the errorneous records
                    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Error while Inserting Time-Tracker-records ' + result.getErrors(),
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                }
            }

            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerStagingLineItem.execute method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());            
    	} catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        } finally {
            TimeTrackerUtility.upsertLogRecord();
        } 
        return 0;
    }

       public static Time_Tracker__c createTTFromStagingRecord(TimeTracker_StagingLineItem__c sli){
        Time_Tracker__c ttRec = new Time_Tracker__c();

        //ttRec.Owner = sli.Owner;

        ttRec.Action__c = sli.Activity_Name__c;
        ttRec.Opening_Action__c = sli.Activity_Name__c;

        ttRec.Object_Id__c = (sli.Object_Id__c!=null?sli.Object_Id__c:null);
        ttRec.Object_Name__c = (sli.Object_Name__c!=null?sli.Object_Name__c:null);

        ttRec.Activity_Date__c = sli.End_Date__c;
        ttRec.Activity_Time__c = sli.End_Date__c.getTime();

        ttRec.Opening_Activity_Date__c = sli.Start_Date__c;
        ttRec.Opening_Activity_Time__c = sli.Start_Date__c.getTime();

        ttRec.Duration__c = (ttRec.Activity_Time__c - ttRec.Opening_Activity_Time__c)/1000;

        return ttRec;        
    }
}