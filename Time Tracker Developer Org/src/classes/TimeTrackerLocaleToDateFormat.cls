public with sharing class TimeTrackerLocaleToDateFormat {

	private static Map<String,String>  localeToDateTimeFmtMap;

	public static String getUserDateTimeFormat(String userLocale) {
		String dateFormat = '';
		TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerLocaleToDateFormat.getUserDateTimeFormat() method.',
		Datetime.now(), null, null, null, UserInfo.getUserId());

		//System.debug('Inside getUserDateTimeFormat with locale: '+userLocale);
    localeToDateTimeFmtMap = getLocaleToDateTimeFmtMap();
		//System.debug(localeToDateTimeFmtMap.get(userLocale));
    if (!localeToDateTimeFmtMap.containsKey(userLocale)) {
			TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Current user locale is not present in TimeTrackerLocaleToDateFormat.localeToDateTimeFmtMap: ',
			Datetime.now(), null, null, null, UserInfo.getUserId());
			return 'yyyy-mm-dd hh.mm.ss';
		}
		TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Ended TimeTrackerLocaleToDateFormat.getUserDateTimeFormat() method.',
		Datetime.now(), null, null, null, UserInfo.getUserId());
		TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: date fmt: ' + localeToDateTimeFmtMap.get(userLocale),
		Datetime.now(), null, null, null, UserInfo.getUserId());
		//System.debug('returning getUserDateTimeFormat with format: '+localeToDateTimeFmtMap.get(userLocale));
    return localeToDateTimeFmtMap.get(userLocale);
	}

	public static Map<String,String> getLocaleToDateTimeFmtMap () {
    if (localeToDateTimeFmtMap == null)
        localeToDateTimeFmtMap  = new Map<String,String> {
						'ar'            => 'dd/MM/yyyy hh:mm a',
						'ar_AE'         => 'dd/MM/yyyy hh:mm a',
						'ar_BH'         => 'dd/MM/yyyy hh:mm a',
						'ar_EG'		=> 'dd/MM/yyyy hh:mm a',
						'ar_IQ'		=> 'dd/MM/yyyy hh:mm a',
						'ar_JO'         => 'dd/MM/yyyy hh:mm a',
						'ar_KW'         => 'dd/MM/yyyy hh:mm a',
						'ar_LB'		=> 'dd/MM/yyyy hh:mm a',
						'ar_LY'		=> 'dd/MM/yyyy hh:mm a',
						'ar_MA'		=> 'dd/MM/yyyy hh:mm a',
						'ar_OM'		=> 'dd/MM/yyyy hh:mm a',
						'ar_QA'		=> 'dd/MM/yyyy hh:mm a',
						'ar_SA'         => 'dd/MM/yyyy hh:mm a',
						'ar_SD'         => 'dd/MM/yyyy hh:mm a',
						'ar_SY'         => 'dd/MM/yyyy hh:mm a',
						'ar_TN'         => 'dd/MM/yyyy hh:mm a',
						'ar_YE'         => 'dd/MM/yyyy hh:mm a',
						'az_AZ'         => 'dd.MM.yyyy HH:mm',

						'be_BY'         => 'dd.MM.yyyy HH.mm',
						'bg_BG'         => 'dd.MM.yyyy HH:mm',
						'bn_BD'         => 'dd/MM/yyyy hh:mm a',
						'bs_BA'         => 'dd.MM.yyyy. HH:mm',

						'ca'            => 'dd/MM/yyyy HH:mm',
						'ca_ES'         => 'dd/MM/yyyy HH:mm',
						'ca_ES_EURO'    => 'dd/MM/yyyy HH:mm',
						'cs'            => 'dd.MM.yyyy HH:mm',
						'cs_CZ'         => 'dd.MM.yyyy HH:mm',
						'cy_GB'		=> 'dd/MM/yyyy HH:mm',

						'da'            => 'dd-MM-yyyy HH:mm',
						'da_DK'         => 'dd-MM-yyyy HH:mm',
						'de'            => 'dd.MM.yyyy HH:mm',
						'de_AT'         => 'dd.MM.yyyy HH:mm',
						'de_AT_EURO'    => 'dd.MM.yyyy HH:mm',
						'de_CH'         => 'dd.MM.yyyy HH:mm',
						'de_DE'         => 'dd.MM.yyyy HH:mm',
						'de_DE_EURO'    => 'dd.MM.yyyy HH:mm',
						'de_LU'         => 'dd.MM.yyyy HH:mm',
						'de_LU_EURO'    => 'dd.MM.yyyy HH:mm',
						//'dz_BT'					=>	'',									//Not able to identify format

						'el_GR'         => 'dd/MM/yyyy hh:mm a',
						'en_AG'         => 'dd/MM/yyyy, hh:mm a',
						'en_AU'         => 'dd/MM/yyyy hh:mm a',
						'en_BB'         => 'dd/MM/yyyy HH:mm',
						'en_BM'         => 'dd/MM/yyyy HH:mm',
						'en_BS'         => 'dd/MM/yyyy, hh:mm a',
						'en_BW'         => 'dd/MM/yyyy, hh:mm a',
						'en_BZ'         => 'dd/MM/yyyy, HH:mm',
						'en_CA'         => 'dd/MM/yyyy hh:mm a',
						'en_CM'         => 'dd/MM/yyyy, hh:mm a',
						'en_ER'         => 'dd/MM/yyyy, hh:mm a',
						'en_FJ'         => 'dd/MM/yyyy, hh:mm a',
						'en_FK'         => 'dd/MM/yyyy, hh:mm a',
						'en_GB'         => 'dd/MM/yyyy HH:mm',
						'en_GH'         => 'dd/MM/yyyy HH:mm',
						'en_GI'         => 'dd/MM/yyyy, hh:mm a',
						'en_GM'         => 'dd/MM/yyyy, hh:mm a',
						'en_GY'         => 'dd/MM/yyyy, hh:mm a',
						'en_HK'         => 'dd/MM/yyyy, hh:mm a',
						'en_ID'         => 'dd/MM/yyyy HH:mm',
						'en_IE'         => 'dd/MM/yyyy HH:mm',
						'en_IE_EURO'    => 'dd/MM/yyyy HH:mm',
						'en_IN'		=> 'dd/MM/yyyy hh:mm a',
						'en_JM'		=> 'dd/MM/yyyy, hh:mm a',
						'en_KE'		=> 'dd/MM/yyyy, hh:mm a',
						'en_KY'		=> 'dd/MM/yyyy, hh:mm a',
						'en_LR'		=> 'dd/MM/yyyy, hh:mm a',
						'en_MG'         => 'dd/MM/yyyy, hh:mm a',
						'en_MU'         => 'dd/MM/yyyy, hh:mm a',
						'en_MW'         => 'dd/MM/yyyy, hh:mm a',
						'en_MY'         => 'dd/MM/yyyy HH:mm',
						'en_NA'         => 'dd/MM/yyyy, hh:mm a',
						'en_NG'         => 'dd/MM/yyyy HH:mm',
						'en_NZ'         => 'dd/MM/yyyy hh:mm a',
						'en_PG'         => 'dd/MM/yyyy, hh:mm a',
						'en_PH'         => 'MM/dd/yyyy hh:mm a',
						'en_PK'         => 'dd/MM/yyyy, hh:mm a',
						'en_RW'         => 'dd/MM/yyyy, hh:mm a',
						'en_SB'         => 'dd/MM/yyyy, hh:mm a',
						'en_SC'         => 'dd/MM/yyyy, hh:mm a',
						'en_SG'         => 'dd/MM/yyyy HH:mm',
						'en_SH'         => 'dd/MM/yyyy, hh:mm a',
						'en_SL'         => 'dd/MM/yyyy, hh:mm a',
						'en_SX'         => 'dd/MM/yyyy, hh:mm a',
						'en_SZ'         => 'dd/MM/yyyy, hh:mm a',
						'en_TO'         => 'dd/MM/yyyy, hh:mm a',
						'en_TT'         => 'dd/MM/yyyy, hh:mm a',
						'en_TZ'         => 'dd/MM/yyyy, hh:mm a',
						'en_UG'         => 'dd/MM/yyyy, hh:mm a',
						'en_US'         => 'MM/dd/yyyy hh:mm a',
						'en_VU'         => 'dd/MM/yyyy, hh:mm a',
						'en_WS'         => 'dd/MM/yyyy, hh:mm a',
						'en_ZA'         => 'yyyy/MM/dd hh:mm a',

						'es'            => 'dd/MM/yyyy HH:mm',
						'es_AR'         => 'dd/MM/yyyy HH:mm',
						'es_BO'         => 'dd-MM-yyyy hh:mm a',
						'es_CL'         => 'dd-MM-yyyy HH:mm',
						'es_CO'         => 'dd/MM/yyyy hh:mm a',
						'es_CR'         => 'dd/MM/yyyy hh:mm a',
						'es_CU'         => 'dd/MM/yyyy hh:mm a',
						'es_DO'         => 'dd/MM/yyyy hh:mm a',
						'es_EC'         => 'dd/MM/yyyy HH:mm',
						'es_ES'         => 'dd/MM/yyyy HH:mm',
						'es_ES_EURO'    => 'dd/MM/yyyy HH:mm',
						'es_GT'         => 'dd/MM/yyyy hh:mm a',
						'es_HN'         => 'MM-dd-yyyy hh:mm a',
						'es_MX'         => 'dd/MM/yyyy hh:mm a',
						'es_NI'         => 'MM-dd-yyyy hh:mm a',
						'es_PA'		=> 'MM/dd/yyyy hh:mm a',
						'es_PE'         => 'dd/MM/yyyy hh:mm a',
						'es_PR'         => 'MM-dd-yyyy hh:mm a',
						'es_PY'         => 'dd/MM/yyyy hh:mm a',
						'es_SV'         => 'MM-dd-yyyy hh:mm a',
						'es_US'         => 'MM/dd/yyyy hh:mm a',
						'es_UY'         => 'dd/MM/yyyy hh:mm a',
						'es_VE'         => 'dd/MM/yyyy hh:mm a',
						'et_EE'         => 'dd.MM.yyyy HH:mm',
						'eu_ES'         => 'yyyy/MM/dd HH:mm',

						//'fa_IR'	=> '',									//salesforce error
						'fi'            => 'dd.MM.yyyy HH:mm',
						'fi_FI'         => 'dd.MM.yyyy HH:mm',
						'fi_FI_EURO'    => 'dd.MM.yyyy HH:mm',
						'fr'            => 'dd/MM/yyyy HH:mm',
						'fr_BE'         => 'dd/MM/yyyy HH:mm',
						'fr_CA'         => 'yyyy-MM-dd HH:mm',
						'fr_CH'         => 'dd.MM.yyyy HH:mm',
						'fr_FR'         => 'dd/MM/yyyy HH:mm',
						'fr_FR_EURO'    => 'dd/MM/yyyy HH:mm',
						'fr_GN'         => 'dd/MM/yyyy HH:mm',
						'fr_HT'         => 'dd/MM/yyyy HH:mm',
						'fr_KM'         => 'dd/MM/yyyy HH:mm',
						'fr_LU'         => 'dd/MM/yyyy HH:mm',
						'fr_MC'         => 'dd/MM/yyyy HH:mm',
						'fr_MR'         => 'dd/MM/yyyy HH:mm',
						'fr_WF'         => 'dd/MM/yyyy HH:mm',

						'ga_IE'		=> 'dd/MM/yyyy HH:mm',
						'hi_IN'		=> 'dd/MM/yyyy hh:mm a',
						'hr_HR'         => 'dd.MM.yyyy. HH:mm',
						'hu'            => 'yyyy.MM.dd. HH:mm',
						'hu_HU'         => 'yyyy.MM.dd. HH:mm',
						'hy_AM'         => 'dd.MM.yyyy, HH:mm',

						'in_ID'		=> 'dd/MM/yyyy HH:mm',
						'is_IS'         => 'dd.MM.yyyy HH:mm',
						'it'            => 'dd/MM/yyyy HH.mm',
						'it_CH'         => 'dd.MM.yyyy HH:mm',
						'it_IT'         => 'dd/MM/yyyy HH.mm',
						'iw'            => 'HH:mm dd/MM/yyyy',
						'iw_IL'         => 'HH:mm dd/MM/yyyy',

						'ja'            => 'yyyy/MM/dd HH:mm',
						'ja_JP'         => 'yyyy/MM/dd HH:mm',
						'ka_GE'         => 'dd.MM.yyyy, HH:mm',
						'kk_KZ'         => 'dd/MM/yyyy HH:mm',
						'km_KH'         => 'dd/MM/yyyy, hh:mm a',
						'ko'            => 'yyyy. MM. dd a hh:mm',
						'ko_KP'         => 'yyyy. MM. dd. a hh:mm',
						'ko_KR'         => 'yyyy. MM. dd a hh:mm',
						'ky_KG'		=> 'dd.MM.yyyy HH:mm',

						'lb_LU'		=> 'dd.MM.yyyy HH:mm',
						'lo_LA'		=> 'dd/MM/yyyy, HH:mm',
						'lt_LT'         => 'yyyy.MM.dd HH.mm',
						'lu_CD'		=> 'dd/MM/yyyy HH:mm',
						'lv_LV'         => 'dd.MM.yyyy HH:mm',

						'mk_MK'		=> 'dd.MM.yyyy HH:mm',
						'ms_BN'         => 'dd/MM/yyyy hh:mm a',
						'ms_MY'         => 'dd/MM/yyyy hh:mm a',
						'mt_MT'         => 'dd/MM/yyyy HH:mm',
						'my_MM'					=> 'dd-MM-yyyy HH:mm',

						'ne_NP'					=> 'yyyy-MM-dd, HH:mm',
						'nl'            => 'dd-MM-yyyy HH:mm',
						'nl_AW'         => 'dd-MM-yyyy HH:mm',
						'nl_BE'         => 'dd/MM/yyyy HH:mm',
						'nl_NL'         => 'dd-MM-yyyy HH:mm',
						'nl_SR'         => 'dd-MM-yyyy HH:mm',
						'no'            => 'dd.MM.yyyy HH:mm',
						'no_NO'         => 'dd.MM.yyyy HH:mm',

						'pl'            => 'yyyy-MM-dd HH:mm',
						'pl_PL'         => 'dd.MM.yyyy HH:mm',
						'pt'            => 'dd-MM-yyyy HH:mm',
						'pt_AO'         => 'dd/MM/yyyy, HH:mm',
						'pt_BR'         => 'dd/MM/yyyy HH:mm',
						'pt_CV'         => 'dd/MM/yyyy, HH:mm',
						'pt_MZ'         => 'dd/MM/yyyy, HH:mm',
						'pt_PT'         => 'dd-MM-yyyy HH:mm',
						'pt_ST'         => 'dd/MM/yyyy, HH:mm',

						'rm_CH'		=> 'dd-MM-yyyy HH:mm',
						'rn_BI'		=> 'dd/MM/yyyy HH:mm',
						'ro_MD'         => 'dd.MM.yyyy, HH:mm',
						'ro_RO'         => 'dd.MM.yyyy HH:mm',
						'ru'            => 'dd.MM.yyyy HH:mm',
						'ru_RU'         => 'dd.MM.yyyy HH:mm',

						'sh_BA'		=> 'dd.MM.yyyy. HH:mm',
						'sh_CS'		=> 'dd.MM.yyyy. HH:mm',
						'sh_ME'		=> 'dd.MM.yyyy. HH:mm',
						'sk_SK'         => 'dd.MM.yyyy HH:mm',
						'sl_SI'         => 'dd.MM.yyyy HH:mm',
						'so_DJ'		=> 'dd/MM/yyyy hh:mm a',
						'so_SO'		=> 'dd/MM/yyyy hh:mm a',
						'sq'		=> 'yyyy-MM-dd hh.mm.a',
						'sq_AL'		=> 'yyyy-MM-dd hh.mm.a',
						'sr_BA'		=> 'yyyy-MM-dd HH:mm',
						'sr_CS'		=> 'dd.MM.yyyy. HH.mm',
						'sr_RS'		=> 'dd.MM.yyyy. HH.mm',
						'sv'            => 'yyyy-MM-dd HH:mm',
						'sv_SE'         => 'yyyy-MM-dd HH:mm',

						'ta_IN'		=> 'dd-MM-yyyy, hh:mm a',
						'ta_LK'		=> 'dd-MM-yyyy, hh:mm a',
						'tg_TJ'		=> 'MM/dd/yyyy hh:mm a',
						//'th'          => 'MM/dd/yyyy hh:mm a',	Not working bcz of special characters
						//'th_TH'       => 'dd/MM/yyyy, H:mm ?.',	Not working bcz of special characters
						'ti_ET'		=> 'dd/MM/yyyy hh:mm a',
						'tl_PH'		=> 'MM/dd/yyyy hh:mm a',
						'tr_TR'		=> 'dd.MM.yyyy HH:mm',
						'tr'            => 'dd.MM.yyyy HH:mm',

						'uk_UA'		=> 'dd.MM.yyyy HH:mm',
						'ur_PK'         => 'dd/MM/yyyy hh:mm a',
						'uz_LATN_UZ'	=> 'yyyy/MM/dd HH:mm',

						'vi_VN'         => 'HH:mm dd/MM/yyyy',
						'yo_BJ'		=> 'dd/MM/yyyy hh:mm a',

						'zh'            => 'yyyy-MM-dd ahh:mm',
						'zh_CN'         => 'yyyy-MM-dd ahh:mm',
						'zh_CN_PINYIN'	=> 'yyyy/MM/dd ahh:mm',
						'zh_CN_STROKE'  => 'yyyy/MM/dd ahh:mm',
						//'zh_HK'       => 'yyyy-MM-dd ahh:mm',  Not working bcz of special characters
						'zh_HK_STROKE'  => 'dd/MM/yyyy ahh:mm',
						'zh_MO'         => 'dd/MM/yyyy ahh:mm',
						'zh_SG'         => 'dd/MM/yyyy a hh:mm',
						'zh_TW'         => 'yyyy/MM/dd a hh:mm',
						'zh_TW_STROKE'  => 'yyyy/MM/dd ahh:mm'
        };
        return localeToDateTimeFmtMap;
	}

	public static Datetime convertStringToDate(String activityDateStr ) {
    String day, month, year, ampm, tm, t24, t12;
    String strDate = '';
    List<String> dateList = activityDateStr.split('/');
    dateList = activityDateStr.split('/');
    month = dateList[0];
    day = dateList[1];
    String[] yearTmList = dateList[2].split(' ');
    year = yearTmList[0];
    tm = yearTmList[1];
    ampm = yearTmList[2];

    //System.debug('day : '+day+', month : '+month+', year : '+year+', tm : '+tm+', ampm : '+ampm);

    t12 = tm + ' ' +ampm;
    //System.debug('t12 : '+t12+' tm : '+tm);
    t24 = tm;
    //System.debug('t24 b4 processing : '+t24+' tm : '+tm);
    if(ampm.contains('AM')){
      t24 = t24.replace('AM', '');
      String[] timeArr = t24.split(':');
      if(timeArr[0].equals('12')){
        timeArr[0] = '00';
      }
      t24 = timeArr[0]+':'+timeArr[1];
    } else if(ampm.contains('PM')){
      t24 = t24.replace('PM', '');
      String[] timeArr = t24.split(':');
      if(!timeArr[0].equals('12')){
        timeArr[0] = String.valueOf(Integer.valueOf(timeArr[0])+12);
      }
      t24 = timeArr[0]+':'+timeArr[1];
    }
    //System.debug('t12 : '+t12+', t24 : '+t24+', ampm : '+ampm+' tm : '+tm);


    String format = TimeTrackerLocaleToDateFormat.getUserDateTimeFormat(UserInfo.getLocale());
    //System.debug('locale : '+UserInfo.getLocale()+', format : ' + format);

    if(format=='dd/MM/yyyy hh:mm a') 			{	strDate = day+'/'+month+'/'+year+' '+ t12; }
		else if(format=='dd/MM/yyyy HH:mm')		{ strDate = day+'/'+month+'/'+year+' '+ t24; }
		else if(format=='dd.MM.yyyy hh:mm a')	{ strDate = day+'.'+month+'.'+year+' '+ t12; }
		else if(format=='dd.MM.yyyy HH:mm') 	{ strDate = day+'.'+month+'.'+year+' '+ t24; }
		else if(format=='dd-MM-yyyy hh:mm a') { strDate = day+'-'+month+'-'+year+' '+ t12; }
		else if(format=='dd-MM-yyyy HH:mm') 	{ strDate = day+'-'+month+'-'+year+' '+ t24; }

		else if(format=='MM/dd/yyyy hh:mm a') { strDate = month+'/'+day+'/'+year+' '+ t12; }
		else if(format=='MM/dd/yyyy HH:mm') 	{ strDate = month+'/'+day+'/'+year+' '+ t24; }
		else if(format=='MM.dd.yyyy hh:mm a') { strDate = month+'.'+day+'.'+year+' '+ t12; }
		else if(format=='MM.dd.yyyy HH:mm') 	{ strDate = month+'.'+day+'.'+year+' '+ t24; }
		else if(format=='MM-dd-yyyy hh:mm a') { strDate = month+'-'+day+'-'+year+' '+ t12; }
		else if(format=='MM-dd-yyyy HH:mm') 	{ strDate = month+'-'+day+'-'+year+' '+ t24; }

		else if(format=='yyyy/MM/dd hh:mm a') { strDate = year+'/'+month+'/'+day+' '+ t12; }
		else if(format=='yyyy/MM/dd HH:mm') 	{ strDate = year+'/'+month+'/'+day+' '+ t24; }
		else if(format=='yyyy.MM.dd hh:mm a') { strDate = year+'.'+month+'.'+day+' '+ t12; }
		else if(format=='yyyy.MM.dd HH:mm') 	{ strDate = year+'.'+month+'.'+day+' '+ t24; }
		else if(format=='yyyy-MM-dd hh:mm a') { strDate = year+'-'+month+'-'+day+' '+ t12; }
		else if(format=='yyyy-MM-dd HH:mm') 	{ strDate = year+'-'+month+'-'+day+' '+ t24; }
		else if(format=='yyyy-MM-dd, HH:mm')  { strDate = year+'-'+month+'-'+day+', '+ t24; }

		else if(format=='dd.MM.yyyy. HH:mm') 	{ strDate = day+'.'+month+'.'+year+'. '+ t24; }
		else if(format=='dd.MM.yyyy, HH:mm') 	{ strDate = day+'.'+month+'.'+year+', '+ t24; }
		else if(format=='dd-MM-yyyy, hh:mm a'){ strDate = day+'-'+month+'-'+year+', '+ t12; }
		else if(format=='yyyy.MM.dd. HH:mm') 	{ strDate = year+'.'+month+'.'+day+'. '+ t24; }
		else if(format=='dd/MM/yyyy, hh:mm a'){ strDate = day+'/'+month+'/'+year+', '+ t12; }
		else if(format=='dd/MM/yyyy, HH:mm')	{ strDate = day+'/'+month+'/'+year+', '+ t24; }
		else if(format=='HH:mm dd/MM/yyyy') 	{ strDate = t24 + ' '+day+'/'+month+'/'+year; }

		else if(format=='yyyy-MM-dd ahh:mm')  { strDate = year+'-'+month+'-'+day+' '+ ampm + tm; }
		else if(format=='yyyy/MM/dd ahh:mm')  { strDate = year+'/'+month+'/'+day+' '+ ampm + tm; }
		else if(format=='dd/MM/yyyy ahh:mm')  { strDate = day+'/'+month+'/'+year+' '+ ampm + tm; }
		else if(format=='dd/MM/yyyy a hh:mm')  { strDate = day+'/'+month+'/'+year+' '+ ampm +' '+ tm; }
		else if(format=='yyyy/MM/dd a hh:mm')  { strDate = year+'/'+month+'/'+day+' '+ ampm +' '+ tm; }
		else if(format=='yyyy. MM. dd a hh:mm')  { strDate = year+'. '+month+'. '+day+' '+ ampm +' '+ tm; }
		else if(format=='yyyy. MM. dd. a hh:mm')  { strDate = year+'. '+month+'. '+day+'. '+ ampm +' '+ tm; }

		else if(format=='dd/MM/yyyy HH.mm') { strDate = day+'/'+month+'/'+year+' '+ t24.replace(':','.'); }
		else if(format=='yyyy.MM.dd HH.mm') { strDate = year+'.'+month+'.'+day+' '+ t24.replace(':','.'); }
		else if(format=='dd.MM.yyyy HH.mm') { strDate = day+'.'+month+'.'+year+' '+ t24.replace(':','.'); }
		else if(format=='dd.MM.yyyy. HH.mm'){ strDate = day+'.'+month+'.'+year+'. '+ t24.replace(':','.'); }
		else if(format=='yyyy-MM-dd hh.mm.a'){strDate = year+'-'+month+'-'+day+' '+ t12.replace(':','.').replace(' ','.'); }

    System.debug('strDate b4 parse: '+strDate);
    return DateTime.parse(strDate);
  }
}