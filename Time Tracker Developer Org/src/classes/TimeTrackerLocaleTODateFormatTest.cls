@isTest
private class TimeTrackerLocaleTODateFormatTest
{
	private static Map<String, Id> ProfileName2Id = new Map<String, Id>();
	private static User createUserObject(String profileName, String mylocale) {

  Long rand = Crypto.getRandomLong();
  rand = (rand < 0 ? rand * -1 : rand);

  // check if we have retrieved this profile before
  if (String.isNotBlank(profileName) && !ProfileName2Id.containsKey(profileName)) {
      Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
      ProfileName2Id.put(profileName, p.Id);
  }

  // required fields: Username, Last Name, E-mail, Alias, Nickname, Time Zone, Locale, Email Encoding, Profile, Language
  User u = new User(
      Email = 'testuser@test.sfdc.' + rand,
      Username = 'testuser@test.sfdc.' + rand,
      LastName = 'user' + rand,
      Alias = 'testUsr',
      TimeZoneSidKey = 'America/Denver',
      LocaleSidKey = mylocale,
      EmailEncodingKey = 'ISO-8859-1',
      ProfileId = ProfileName2Id.get(profileName),
      LanguageLocaleKey = 'en_US'
  		);
  		return u;
	}

  public static testMethod void testRunAs() {
		// Setup test data
	  // This code runs as the system user
	  Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
    String[] locales1 = new String[] {'ar_AE','ar_BH','ar_EG','ar_IQ','ar_JO','ar_KW','ar_LB','ar_LY','ar_MA',
														'ar_OM','ar_QA','ar_SA','ar_SD','ar_SY','ar_TN','ar_YE','az_AZ','be_BY','bg_BG',
														'bn_BD','bs_BA','ca_ES','cs_CZ','cy_GB','da_DK','de_AT','de_CH','de_DE','de_LU',
														'el_GR','en_AG','en_AU','en_BB','en_BM','en_BS','en_BW','en_BZ','en_CA',
														'en_CM','en_ER','en_FJ','en_FK','en_GB','en_GH','en_GI','en_GM','en_GY','en_HK',
														'en_ID','en_IE','en_IN','en_JM','en_KE','en_KY','en_LR','en_MG','en_MU','en_MW',
														'en_MY','en_NA','en_NG','en_NZ','en_PG','en_PH','en_PK','en_RW','en_SB','en_SC',
														'en_SG','en_SH','en_SL','en_SX','en_SZ','en_TO'
											};
	  List<User> ul = new List<User>();

    Test.startTest();
    for(String loc: locales1){
    	ul.add(createUserObject('Standard User', loc));
    }

		try{
			for(Integer i=0; i<locales1.size() && i<80 ;i++){
				System.runAs(ul.get(i)) {
					System.debug('Current locale: ' + UserInfo.getLocale());

					//System.debug('System date format: '+System.now().format());
					//System.debug('Parsed System date: '+Datetime.parse(System.now().format()));
					String x = '01/27/2017 02:30 PM';
					//System.debug('----------'+DateTime.parse(x));
	//System.debug('----------'+TimeTrackerController.convertAndParse(x));
					System.debug('----------'+TimeTrackerLocaleToDateFormat.convertStringToDate(x));
          System.assertEquals( Datetime.newInstance(2017, 1, 27, 14, 30, 00), TimeTrackerLocaleToDateFormat.convertStringToDate(x));
				}
			}
		} catch(Exception ex){
			System.debug('EXCEPTION: '+ex);
		}
    Test.stopTest();
	}

  public static testMethod void testRunAs2() {
		// Setup test data
	  // This code runs as the system user
		Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
    String[] locales2 = new String[] {'en_TT','en_TZ','en_UG','en_US','en_VU','en_WS','en_ZA','es_AR','es_BO',
														'es_CL','es_CO','es_CR','es_CU','es_DO','es_EC','es_ES','es_GT','es_HN','es_MX',
														'es_NI','es_PA','es_PE','es_PR','es_PY','es_SV','es_US','es_UY','es_VE','et_EE',
														'eu_ES','fi_FI','fr_BE','fr_CA','fr_CH','fr_FR','fr_GN','fr_HT','fr_KM',
														'fr_LU','fr_MC','fr_MR','fr_WF','ga_IE','hi_IN','hr_HR','hu_HU','hy_AM','in_ID',
														'is_IS','it_CH','it_IT','iw_IL','ja_JP','ka_GE','kk_KZ','km_KH','ko_KP','ko_KR',
														'ky_KG','lb_LU','lo_LA','lt_LT','lu_CD','lv_LV','mk_MK','ms_BN','ms_MY','mt_MT',
														'my_MM','ne_NP','nl_AW','nl_BE','nl_NL','nl_SR','no_NO'
											};//'en_CA','en_GB','fr','fr_FR','de','de_DE','es_PR','es_ES','ar_AE','el_GR','en_AU','ky_KG','en_SG','ga_IE'};
	  List<User> ul = new List<User>();

    Test.startTest();
    for(String loc: locales2){
    	ul.add(createUserObject('Standard User', loc));
    }

		try {
			for(Integer i=0; i<locales2.size() && i<75 ;i++){
				System.runAs(ul.get(i)) {
					System.debug('Current locale: ' + UserInfo.getLocale());

					//System.debug('System date format: '+System.now().format());
					//System.debug('Parsed System date: '+Datetime.parse(System.now().format()));
					String x = '01/27/2017 02:30 PM';
					//System.debug('----------'+DateTime.parse(x));
          //System.debug('----------'+TimeTrackerController.convertAndParse(x));
					System.debug('----------'+TimeTrackerLocaleToDateFormat.convertStringToDate(x));
          System.assertEquals( Datetime.newInstance(2017, 1, 27, 14, 30, 00), TimeTrackerLocaleToDateFormat.convertStringToDate(x));
				}
			}
		} catch(Exception ex) {
			System.debug('EXCEPTION: '+ex);
		}
    Test.stopTest();
  }

  public static testMethod void testRunAs3() {
 		// Setup test data
 	  // This code runs as the system user
 		Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
     String[] locales2 = new String[] {'pl_PL','pt_AO',
 														'pt_BR','pt_CV','pt_MZ','pt_PT','pt_ST','rm_CH','rn_BI','ro_MD','ro_RO','ru_RU',
 														'sh_BA','sh_CS','sh_ME','sk_SK','sl_SI','so_DJ','so_SO','sq_AL','sr_BA','sr_CS',
 														'sr_RS','sv_SE','ta_IN','ta_LK','tg_TJ','ti_ET','tl_PH','tr_TR','uk_UA',
 														'ur_PK','uz_LATN_UZ','vi_VN','yo_BJ','zh_CN','zh_CN_PINYIN','zh_CN_STROKE',
 														'zh_HK_STROKE','zh_MO','zh_SG','zh_TW','zh_TW_STROKE'
 											};//'en_CA','en_GB','fr','fr_FR','de','de_DE','es_PR','es_ES','ar_AE','el_GR','en_AU','ky_KG','en_SG','ga_IE'};
 	  List<User> ul = new List<User>();

     Test.startTest();
     for(String loc: locales2){
     	ul.add(createUserObject('Standard User', loc));
     }

 		try{
 			for(Integer i=0; i<locales2.size() && i<75 ;i++){
 				System.runAs(ul.get(i)) {
 					System.debug('Current locale: ' + UserInfo.getLocale());

 					//System.debug('System date format: '+System.now().format());
 					//System.debug('Parsed System date: '+Datetime.parse(System.now().format()));
 					String x = '01/27/2017 02:30 PM';
 					//System.debug('----------'+DateTime.parse(x));
					//System.debug('----------'+TimeTrackerController.convertAndParse(x));
 					System.debug('----------'+TimeTrackerLocaleToDateFormat.convertStringToDate(x));
					System.assertEquals( Datetime.newInstance(2017, 1, 27, 14, 30, 00), TimeTrackerLocaleToDateFormat.convertStringToDate(x));
 				}
 			}
 		} catch(Exception ex){
 			System.debug('EXCEPTION: '+ex);
 		}
    Test.stopTest();
 	}
}