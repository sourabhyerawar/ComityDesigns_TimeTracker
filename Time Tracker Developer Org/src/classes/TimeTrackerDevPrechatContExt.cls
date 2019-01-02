public with sharing class TimeTrackerDevPrechatContExt {
  public User u {get;set;}
  public String nameOfUser {get;set;}
  public String emailOfUser {get;set;}
  public map <String, String> userInfoMap {get;set;}
  public TimeTrackerDevPrechatContExt (ApexPages.StandardController stdCon){
    userInfoMap = new map <String, String>();
    u = [SELECT Name, Email FROM User WHERE Id = :Userinfo.getUserId()];
    //apexpages.addMessage(new Apexpages.Message(apexpages.severity.info, 'The User: ' + u ));
    String curURL = apexpages.currentPage().getUrl().replace('%26', '&');  
    curURL = curURL.replace('%3D', '=');
    curURL = curURL.replace('%40', '@');
    curUrl = curUrl.split('\\?')[1];
    list <String> params = curUrl.split('&');
    nameOfUser = params[0]; 
    for (String s : params){
      String[] s1 = s.split('=');
      userInfoMap.put(s1[0], s1[1].replace('+', ' '));
    }
    nameOfUser = userInfoMap.get('userName');
    emailOfUser = userInfoMap.get('userEmail');
    
  }
}