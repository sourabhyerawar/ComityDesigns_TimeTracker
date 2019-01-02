public with sharing class TimeTrackerUserSettings {


    /**
    *   @Description : This method will return the boolean value whether to log-errors for user
    */
    public static boolean logErrorsForUser(){
        TimeTrackerUserSettings__c userSetting = TimeTrackerUserSettings__c.getInstance(UserInfo.getUserId());
        return userSetting.Server_Debug__c;
    }
  /**
  * @Description: Get max allowed duration in Minutes for Given Profile-instance, OWD and Last defaulted to 30
  */
  public static Integer getMaxAllowedMinutesDifference(){
    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUserSettings.getMaxAllowedMinutesDifference() method.',
        Datetime.now(), null, null, null, UserInfo.getUserId());
      Integer MaxTimeConsiderInMin = 30;
      try{
        TimeTrackerUserSettings__c userSetting = TimeTrackerUserSettings__c.getInstance();
          
          if(userSetting!=null && String.isNotBlank(String.valueOf(userSetting))){
              if(userSetting.Max_Duration_In_Minutes__c>0)       MaxTimeConsiderInMin = (Integer) userSetting.Max_Duration_In_Minutes__c; 
          }

      } catch(Exception e){
          System.debug('Invalid MaxTimeConsiderInMin supplied'+e);
          TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
           Datetime.now(), null, null, null, UserInfo.getUserId());
          MaxTimeConsiderInMin = 30;
      }
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUserSettings.getMaxAllowedMinutesDifference() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      return MaxTimeConsiderInMin;
  }    
}