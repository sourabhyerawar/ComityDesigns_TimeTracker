global with sharing class TimeTrackerConfigSettings {
  public static final Map<String, TimeTrackerConfigSettings__c> TT_CONFIG_SETTINGS = TimeTrackerConfigSettings__c.getAll();
  
  public static final Map<String, List<TimeTrackerConfigSettings__c>> STRATEGY_SETTINGS = getSettingsByType(TimeTrackerConstants.STRATEGY_TYPE, TimeTrackerConstants.TEXT1_FIELD);

  /**
  * @Description: Retrieve a map based on the fieldName of the Custom Setting:TimeTrackerConfigSettings__c
  */
  global static Map<String, List<TimeTrackerConfigSettings__c>> getSettingsByType(String type, String name) {
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getSettingsByType method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'type: ' + type + '; name: ' + name,
        Datetime.now(), null, null, null, UserInfo.getUserId());

    Map<String, List<TimeTrackerConfigSettings__c>> valueByType =
      new Map<String, List<TimeTrackerConfigSettings__c>>();
      //System.debug(LoggingLevel.ERROR, '--++--TT_CONFIG_SETTINGS : ' + TT_CONFIG_SETTINGS.size());

    if(TT_CONFIG_SETTINGS == null || TT_CONFIG_SETTINGS.isEmpty()) return valueByType;

    String fieldName = String.isNotBlank(name) ? name : 'name';
    for(TimeTrackerConfigSettings__c ttcs : TT_CONFIG_SETTINGS.values()){
      //Get only Active settings
      if(ttcs.Type__c.equalsIgnoreCase(type) && ttcs.IsActive__c){
        String key = String.valueOf(ttcs.get(fieldName));
        if(String.isBlank(key)) continue;
        if(valueByType!=null && valueByType.containsKey(key)) {
          valueByType.get(key).add(ttcs);
        } else {
          valueByType.put(key, new List<TimeTrackerConfigSettings__c> {ttcs});
        }
      }
    }
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerConfigSettings.getSettingsByType method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    return valueByType;
  }

  /**
  * @Description: Get List of Manual activities(Filtered by Permission-set) from custom setting
  */
  public static Map<String, TimeTrackerConfigSettings__c > MANUALACTIVITYSETTINGS = new Map<String, TimeTrackerConfigSettings__c>();
  
  public static Map<String, TimeTrackerConfigSettings__c > getManualSettings(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getManualSettings method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    if( MANUALACTIVITYSETTINGS.isEmpty()){
       setManualActivity_Type_Map();
       TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Active and Permited Manual-activities: '+ MANUALACTIVITYSETTINGS,
                        Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    if(MANUALACTIVITYSETTINGS.isEmpty() || MANUALACTIVITYSETTINGS.size()==0){
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR,'No Active Manual-activities configured in Custom-settings',
            DateTime.now(), '', '', TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
    }
    
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getManualSettings method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    return MANUALACTIVITYSETTINGS;
  }
    
    private static void setManualActivity_Type_Map() {
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.setManualActivity_Type_Map method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
        
        Map<String, List<TimeTrackerConfigSettings__c>> manualActivityLst = getSettingsByType(TimeTrackerConstants.MANUAL_TYPE, TimeTrackerConstants.TEXT1_FIELD);
        //system.debug('Manual-activities From Custom-setting'+manualActivityLst);

        Map<String, TimeTrackerConfigSettings__c > actity_Mmap = new Map<String, TimeTrackerConfigSettings__c>();

        //Get Permission-set assigned to user
        String usrId = userInfo.getUserId();
        Set<String> reqPermSetNames = TimeTrackerUtility.getPermissionSetAssignmentForUser(Id.valueOf(usrId));
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'reqPermSetNames: ' + reqPermSetNames,
                    Datetime.now(), null, null, null, UserInfo.getUserId());

        if(manualActivityLst != null && !manualActivityLst.isEmpty()) {
            
            String strAllPermissionSetName = 'All';
            for(List<TimeTrackerConfigSettings__c> lsts: manualActivityLst.values()) {

                TimeTrackerConfigSettings__c setting = lsts.get(0);

                string permName = setting.Text4__c;

                //Add to list if permission-name is blank in config-record or permission-name matches any Time-tracker permission(Assigned to user)
                if( String.isBlank( permName ) || strAllPermissionSetName.equalsIgnoreCase( permName ) || reqPermSetNames.contains( permName ) ) {
                  actity_Mmap.put(setting.Text1__c, setting);
                }
            }
        }

        //Set manualActivitySettings
        MANUALACTIVITYSETTINGS = actity_Mmap;
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.setManualActivity_Type_Map() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    }


  /**
  * @Description : Get Strategies for Automated-activities
  */
  public static Map<String, TimeTrackerConfigSettings__c> TIMETRACKERSTRATEGYLST = new Map<String, TimeTrackerConfigSettings__c>();
  public static Map<String, TimeTrackerConfigSettings__c> getTimeTrackerStrategies(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getTimeTrackerStrategies() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      if(TIMETRACKERSTRATEGYLST.isEmpty()){
       Map<String, List<TimeTrackerConfigSettings__c>> strategyLst = getSettingsByType(TimeTrackerConstants.STRATEGY_TYPE, TimeTrackerConstants.TEXT1_FIELD);
       //system.debug('Strategies From Custom-setting'+strategyLst);

       if(!strategyLst.isEmpty()){
          for(List<TimeTrackerConfigSettings__c> lsts: strategyLst.values()){
              TimeTrackerConfigSettings__c setting = lsts.get(0);
              TIMETRACKERSTRATEGYLST.put(setting.Text1__c, setting);
          }
       }
      }
      if(TIMETRACKERSTRATEGYLST.isEmpty() || TIMETRACKERSTRATEGYLST.size()==0){
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR,'No Active Strategies configured in Custom-settings',
            DateTime.now(), '', '', TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
      }
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerConfigSettings.getTimeTrackerStrategies() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return TIMETRACKERSTRATEGYLST;
   }

  /**
  * @Description : This method returns Activity(Both Manual & Automated) vs Activity-details
  */
  public static Map<String, TimeTrackerConfigSettings__c> ACTIVITYVSACTIVITYDETAILS = new Map<String,TimeTrackerConfigSettings__c>();
  public static Map<String, TimeTrackerConfigSettings__c> getactivityvsActivityDetails(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getactivityvsActivityDetails() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      if(ACTIVITYVSACTIVITYDETAILS.isEmpty()){
        //Get- Automated-activities
        ACTIVITYVSACTIVITYDETAILS = getTimeTrackerStrategies();
        //Get- Manual activities
        ACTIVITYVSACTIVITYDETAILS.putAll( getManualSettings() );
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ACTIVITYVSACTIVITYDETAILS: ' + ACTIVITYVSACTIVITYDETAILS,
                        Datetime.now(), null, null, null, UserInfo.getUserId());
      }
      if(ACTIVITYVSACTIVITYDETAILS.isEmpty() || ACTIVITYVSACTIVITYDETAILS.size()==0){
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR,'No Active Manual OR Strategies configured in Custom-settings',
            DateTime.now(), '', '', TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
      }
      //System.debug(LoggingLevel.ERROR, '--++--keys : ' + String.valueOf(ACTIVITYVSACTIVITYDETAILS.keySet()));
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerConfigSettings.getactivityvsActivityDetails() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return ACTIVITYVSACTIVITYDETAILS;    
  }

  /**
  * @Description : This method returns only URL-Pattern settings
  */
  public static Map<String, TimeTrackerConfigSettings__c> URLPATTERNDETAILS = new Map<String,TimeTrackerConfigSettings__c>();
  public static Map<String, TimeTrackerConfigSettings__c> getURLPatternDetails(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getURLPatternDetails() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      if(URLPATTERNDETAILS.isEmpty()){
        Map<String, List<TimeTrackerConfigSettings__c>> urlpatternLst = getSettingsByType(TimeTrackerConstants.URL_PATTERN_TYPE, TimeTrackerConstants.TEXT1_FIELD);
        //Get- Automated-activities
        if(!urlpatternLst.isEmpty()){
          for(List<TimeTrackerConfigSettings__c> lsts: urlpatternLst.values()){
              TimeTrackerConfigSettings__c setting = lsts.get(0);
              URLPATTERNDETAILS.put(setting.Text1__c, setting);
          }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ACTIVITYVSACTIVITYDETAILS: ' + URLPATTERNDETAILS,
                        Datetime.now(), null, null, null, UserInfo.getUserId());
      }
      if(URLPATTERNDETAILS.isEmpty() || URLPATTERNDETAILS.size()==0){
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR,'No URL-Pattern configured in Custom-settings',
            DateTime.now(), '', '', TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
      }
      //System.debug(LoggingLevel.ERROR, '--++--keys : ' + String.valueOf(URLPATTERNDETAILS.keySet()));
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerConfigSettings.getURLPatternDetails() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return URLPATTERNDETAILS;    
  }
    
  /* *
  * @Description : This method returns only Object settings
  *
  public static Map<String, TimeTrackerConfigSettings__c> OBJECTSETTINGS = new Map<String,TimeTrackerConfigSettings__c>();
  public static Map<String, TimeTrackerConfigSettings__c> getObjectSettings(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getObjectSettings() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      if(OBJECTSETTINGS.isEmpty()){
        Map<String, List<TimeTrackerConfigSettings__c>> objSettingsLst = getSettingsByType(TimeTrackerConstants.OBJECT_SETTINGS, TimeTrackerConstants.TEXT1_FIELD);
        //Get- Automated-activities
        if(!objSettingsLst.isEmpty()){
          for(List<TimeTrackerConfigSettings__c> lsts: objSettingsLst.values()){
              TimeTrackerConfigSettings__c setting = lsts.get(0);
              OBJECTSETTINGS.put(setting.Text1__c, setting);
          }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'OBJECTSETTINGS: ' + OBJECTSETTINGS,
                        Datetime.now(), null, null, null, UserInfo.getUserId());
      }
      if(OBJECTSETTINGS.isEmpty() || OBJECTSETTINGS.size()==0){
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR,'No Object-settings configured in Custom-settings',
            DateTime.now(), '', '', TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
      }
      System.debug(LoggingLevel.ERROR, '--++--keys : ' + String.valueOf(OBJECTSETTINGS.keySet()));
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerConfigSettings.getObjectSettings() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return OBJECTSETTINGS;    
  }*/

   /**
   *  @Description : Get URL-pattern vs Activity Map
   */
   public static Map<String,String> URLPATTERNVSACTIVITYMAP = new Map<String,String>();
   public static Map<String,String> geturlPatternvsActivityMap(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.geturlPatternvsActivityMap() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      if(URLPATTERNVSACTIVITYMAP == null || URLPATTERNVSACTIVITYMAP.isEmpty()){
          try{
             Map<String, List<TimeTrackerConfigSettings__c>> urlpatternLst = getSettingsByType(TimeTrackerConstants.URL_PATTERN_TYPE, TimeTrackerConstants.TEXT1_FIELD);
             TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'URLPattern: ' + urlpatternLst,
                        Datetime.now(), null, null, null, UserInfo.getUserId());

            if(!urlpatternLst.isEmpty()) {
                  for(List<TimeTrackerConfigSettings__c> lsts: urlpatternLst.values()) {
                      TimeTrackerConfigSettings__c setting = lsts.get(0);
                      if( String.isNotBlank(setting.Text1__c) && String.isNotBlank(setting.Code1__c) ){
                          URLPATTERNVSACTIVITYMAP.put(setting.Text1__c, setting.Code1__c);
                      }
                  }
              }
          } catch(Exception e){
            //System.debug('Invalid urlpattern supplied'+e);
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
              Datetime.now(), null, null, null, UserInfo.getUserId());
          }
      }
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.geturlPatternvsActivityMap() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return URLPATTERNVSACTIVITYMAP;
   }


  /**
  * @Description: Get max allowed duration in Minutes
  */
  global static Integer getMaxAllowedMinutesDifference(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getMaxAllowedMinutesDifference() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      Integer MaxTimeConsiderInMin = 30;
      try{
             Map<String, List<TimeTrackerConfigSettings__c>> miscellaneousLst = getSettingsByType(TimeTrackerConstants.MISCELLANEOUS, null);
              //system.debug('Custom-setting for Miscellaneous Time Window::'+ miscellaneousLst);
              TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'miscellaneousLst: ' + miscellaneousLst,
                        Datetime.now(), null, null, null, UserInfo.getUserId());

            if(!miscellaneousLst.isEmpty()) {
                  for(List<TimeTrackerConfigSettings__c> lsts: miscellaneousLst.values()) {
                      TimeTrackerConfigSettings__c setting = lsts.get(0);
                      if( TimeTrackerConstants.TIME_TRACKER_MAX_TIME_CONSIDER_IN_MIN.equalsIgnoreCase(setting.Text1__c)){
                          MaxTimeConsiderInMin = (String.isNotBlank( setting.Code1__c)? Integer.valueOf( setting.Code1__c) : 30);
                          //system.debug('MaxTimeConsiderInMin ::'+MaxTimeConsiderInMin);
                      }
                  }
              }

      } catch(Exception e){
          System.debug('Invalid MaxTimeConsiderInMin supplied'+e);
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
           Datetime.now(), null, null, null, UserInfo.getUserId());
          MaxTimeConsiderInMin = 30;
      }
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getMaxAllowedMinutesDifference() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return MaxTimeConsiderInMin;
  }

/**
* @Description: Get Trigger-excution controlling Boolean value
*/
public static Boolean getRunTimeTrackerTriggers(){
  TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerConfigSettings.getRunTimeTrackerTriggers() method.',
      Datetime.now(), null, null, null, UserInfo.getUserId());
      Boolean runTimeTrackerTriggers = TRUE;

      try{
          Map<String, List<TimeTrackerConfigSettings__c>> miscellaneousLst = getSettingsByType(TimeTrackerConstants.MISCELLANEOUS, null);
              //system.debug('Custom-setting for (Miscellaneous)executeTriggers::'+ miscellaneousLst);
              TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'miscellaneousLst: ' + miscellaneousLst,
                        Datetime.now(), null, null, null, UserInfo.getUserId());

            if(!miscellaneousLst.isEmpty()) {
                  for(List<TimeTrackerConfigSettings__c> lsts: miscellaneousLst.values()) {
                      TimeTrackerConfigSettings__c setting = lsts.get(0);
                      if( TimeTrackerConstants.TIME_TRACKER_EXECUTE_TRIGGER.equalsIgnoreCase(setting.Text1__c)){
                          runTimeTrackerTriggers = setting.Flag1__c;
                          //system.debug('executeTriggers ::'+runTimeTrackerTriggers);
                      }
                  }
              }

      } catch(Exception e){
          //System.debug('Invalid Miscellaneous executeTriggers supplied'+e);
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
            Datetime.now(), null, null, null, UserInfo.getUserId());
          runTimeTrackerTriggers = TRUE;
      }
      TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Execute Trigger Flag is : ' + runTimeTrackerTriggers,
                        Datetime.now(), null, null, null, UserInfo.getUserId());
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Ended TimeTrackerConfigSettings.getRunTimeTrackerTriggers() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return runTimeTrackerTriggers;
  }
}