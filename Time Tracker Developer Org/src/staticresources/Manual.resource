let manualDisengageTime, manualEngageTime = [];

String.prototype.toHHMMSS = function() {
  const sec_num = parseInt(this, 10); // don't forget the second parm
  let hours = Math.floor(sec_num / 3600);
  let minutes = Math.floor((sec_num - (hours * 3600)) / 60);
  let seconds = sec_num - (hours * 3600) - (minutes * 60);

  if (hours < 10) {
    hours = "0" + hours;
  }
  if (minutes < 10) {
    minutes = "0" + minutes;
  }
  if (seconds < 10) {
    seconds = "0" + seconds;
  }
  return hours + ':' + minutes + ':' + seconds;
}

function timer() {
  let count = $('#timer').attr('data-count');
  const temp = count.toHHMMSS();
  count = (parseInt(count) + 1).toString();
  $('#timer').attr('data-count', count);
  $('#timer').val(temp);
  $('#hiddentimer').val(count);
  $('#timer').prop('disabled', true);
  $('#submitBtn').prop('disabled', true);
}

function resetTimer() {
  $('#timer').attr('data-count', '0');
  $('#timer').prop('disabled', false);
  $('#submitBtn').prop('disabled', false);
}

const setActivity = function() {
  let reqLst;

  timetracker.TimeTrackerController.getactivityLst(null,
  function(result, e) {
    if (e.status && result) {
      reqLst = result.toString();
      var str_array = reqLst.split(',');
      var options = '';
      options += '<option value=""></option>'
      for (var i = 0; i < str_array.length; i++) {
        options += '<option value="' + str_array[i] + '">' + str_array[i] + '</option>';
      }
      $("#activitytype").html(options);
    }
  });
}
var displayCaseLinkFor = '';
var displayAccountLinkFor = '';

var setDisplayCaseLinkFor = function(forCase) {
  displayCaseLinkFor = forCase;
}
var setDisplayAccountLinkFor = function(forAct) {
  displayAccountLinkFor = forAct;
}
var getObjectMap = function() {
  timetracker.TimeTrackerController.getObjectMap(null,
    function(result, e) {
      if (e.status && result) {
        var xyz = result.toString().split('###');
        setDisplayCaseLinkFor(xyz[0]);
        setDisplayAccountLinkFor(xyz[1]);
      }
    });
}


$(document).ready(function() {
  // It doesn't, so create an object with that name
  if (typeof timetracker === 'undefined') {
    window['timetracker'] = {};
    timetracker.TimeTrackerController = TimeTrackerController;
  }

  var counter;
  $("#start").show();
  $('#errormessage').addClass('hidden');
  $('#successmessage').addClass('hidden');
  $("#searchaccount").hide();

  // init activity date
  $("#datepicker").datepicker({
    format: 'mm/dd/yyyy',
    autoclose: true
  }).datepicker('update', new Date());

  // init select2 for activitytype
  $("#activitytype").select2({
    placeholder: "Select",
    allowClear: true
  });
  //Get Activities from Controller
  setActivity();
  getObjectMap();

  $(".btn-start").click(function(e) {
    e.preventDefault();
    if ($(this).parent().find('label').text() == 'Start') {
      manualDisengageTime = [];
      manualEngageTime = [];
    }
    counter = setInterval(timer, 1000);
    $(this).prop('disabled', true);
    $(this).parent().find('label').text('Start');
    $(".btn-pause").removeAttr('disabled');
    $(".btn-stop").removeAttr('disabled');
    $('#submitBtn').prop('disabled', true);
    pushTime(manualEngageTime);
  });
  $(".btn-pause").click(function(e) {
    e.preventDefault();
    $(this).prop('disabled', true);
    $(".btn-start").removeAttr('disabled');
    $('.btn-start').parent().find('label').text('Resume');
    $(".btn-stop").removeAttr('disabled');
    clearInterval(counter);
    pushTime(manualDisengageTime);
  });
  $(".btn-stop").click(function(e) {
    e.preventDefault();
    $(this).prop('disabled', true);
    $(".btn-start").removeAttr('disabled');
    $('.btn-start').parent().find('label').text('Start');
    $(".btn-pause").prop('disabled', true);
    clearInterval(counter);
    resetTimer();
    $('#submitBtn').prop('disabled', false);
    if (manualEngageTime.length != manualDisengageTime.length) pushTime(manualDisengageTime);
  });

  var setAccountId = function setAccountId(result) {
    if (result.success && result.id != "") {
      sforce.console.getPageInfo(result.id, setAccountPageInfo);
    }
  };

  var setCaseId = function setCaseId(result) {
    if (result.success && result.id != "") {
      sforce.console.getPageInfo(result.id, setCasePageInfo);
    }
  };

  var setAccountPageInfo = function setAccountPageInfo(result) {
    if (result.success && typeof(result.pageInfo) != 'undefined') {
      var tempPageInfo = JSON.parse(result.pageInfo);
      if (tempPageInfo.object.toLowerCase() == "account") {
        $("#accountid").val(tempPageInfo.objectId);
        $("#accountname").val(tempPageInfo.objectName);
      }
    }
  };

  var pushTime = function(timeArray) {
    var dt = new Date();
    timeArray.push(dt.getTime());
  };

  var setCasePageInfo = function setCasePageInfo(result) {
    if (result.success && typeof(result.pageInfo) != 'undefined') {
      var tempPageInfo = JSON.parse(result.pageInfo);
      var objectDefined = tempPageInfo.object;
      if (objectDefined != undefined) {
        if (tempPageInfo.object.toLowerCase() == "case") {
          $("#caseid").val(tempPageInfo.objectId);
          $("#casenumber").val(tempPageInfo.objectName);
        }
      } else if (tempPageInfo.objectId.indexOf('500') == 0) {
        var caseId = tempPageInfo.objectId;
        timetracker.TimeTrackerController.getCaseNoFromCaseId(
          caseId,
          function(remoteresult, e) {
            var tcaseNo = remoteresult.toString();
            $("#caseid").val(caseId);
            $("#casenumber").val(tcaseNo);
          }, { escape: false }
        );

      }
    }
  };

  $("#autofillaccount").click(function() {
    sforce.console.getFocusedSubtabId(setAccountId);
    if ($("#accountid").val().trim() == "") {
      sforce.console.getFocusedPrimaryTabId(setAccountId);
    }
  });

  $("#autofillcase").click(function() {
    sforce.console.getFocusedSubtabId(setCaseId);
    if ($("#caseid").val().trim() == "") {
      sforce.console.getFocusedPrimaryTabId(setCaseId);
    }
  });

  $("#activitytype").change(function() {
    var val = $(this).find("option:selected").val();
    $('#caseid').val('');
    $('#casenumber').val('');
    $('#accountid').val('');
    $('#accountname').val('');
    if (displayAccountLinkFor.toUpperCase().indexOf(val.toUpperCase()) >= 0) {
      $("#searchaccount").show();
      $("#searchcase").hide();
    } else { //Default-case link display
      $("#searchaccount").hide();
      $("#searchcase").show();
    }
  });

  $('#submitBtn').on('click', function(e) {
    e.preventDefault();
    // hide all error messages
    $('#successmessage').addClass('hidden');
    $('#activityerrormessage').addClass('hidden');
    $('#commenterrormessage').addClass('hidden');
    $('#activitydateerrormessage').addClass('hidden');
    $('#durationerrormessage').addClass('hidden');

    var timer = $('#timer').val() || null;
    var hiddentimer = $('#hiddentimer').val() || null;
    var activitydate = $('#activitydate').val() || null;
    var activitytype = $('#activitytype').find("option:selected").val() || null;
    var caseid = $('#caseid').val() || null;
    var casenumber = $('#casenumber').val() || null;
    var accountid = $('#accountid').val() || null;
    var accountname = $('#accountname').val() || null;
    var comment = $('#comment').val() || null;
    var validform = validateFormData(timer, activitytype, activitydate, comment);

    if (!validform) return;
    $('div.container').spin('modal');
    pushTimesheetEntry(timer, hiddentimer, activitydate, activitytype, caseid, casenumber, accountid, accountname, comment);
  });
});

function buildManualLineItems() {
  let manualLineItems = [];
  if (manualEngageTime.length == 0 || manualDisengageTime.length == 0 || manualEngageTime.length != manualDisengageTime.length)
    return manualLineItems;
  for (let i = 0; i < manualEngageTime.length; i++) {
    manualLineItems.push({ "Engage_Time__c": manualEngageTime[i], "Disengage_Time__c": manualDisengageTime[i] });
  }
  console.log(manualLineItems);
  return manualLineItems;
}

function pushManualLineItems() {
  const manualLineItems = buildManualLineItems();
  if(manualLineItems.length == 0) return;
  timetracker.TimeTrackerController.saveManualLineItems(
    JSON.stringify(manualLineItems),
    function(result, e) {
      $('div.container').spin('modal');
      if(!e.status && e.message) {
          $('#successmessage').addClass('hidden');
          $('#errormessage').removeClass('hidden');
          setTimeout(function() {
            $('#errormessage').addClass('hidden');
          }, 8000);
      } else {
        setTimeout(function() {
          $('#successmessage').addClass('hidden');
        }, 8000);
      }
  }, { escape: false });
}

function pushTimesheetEntry(timer, hiddentimer, activitydate, activitytype, caseid, casenumber, accountid, accountname, comment) {
  timetracker.TimeTrackerController.doCreateTimesheetEntry(
    timer, hiddentimer, Date.parse(activitydate), activitytype, caseid, casenumber, accountid, accountname, comment,
    function(result, e) {
      if (e.status) {
        if(result.indexOf('true') >= 0) {
          $('form[id*="tseForm"]').get(0).reset();
          $("#datepicker").datepicker('update', new Date());
          $("#activitytype").select2("val", "");
          $('#errormessage').addClass('hidden');
          $('#successmessage').removeClass('hidden');
          $('#caseid').val('');
          $('#casenumber').val('');
          $('#accountid').val('');
          $('#accountname').val('');
          pushManualLineItems();
        } else if (result.indexOf('Locked') >= 0) {
            $('div.container').spin('modal');
            $('#lockedTimesheet').removeClass('hidden');
            setTimeout(function() {
              $('#lockedTimesheet').addClass('hidden');
            }, 8000);
        }
      } else {
        $('div.container').spin('modal');
        $('#successmessage').addClass('hidden');
        $('#errormessage').removeClass('hidden');
        setTimeout(function() {
          $('#errormessage').addClass('hidden');
        }, 8000);
      }
  }, { escape: false });
}

function validateFormData(timer, activitytype, activitydate, comment) {
  let success = true;

  if (!activitytype || activitytype.length == 0) {
    success = false;
    $('#activityerrormessage').removeClass('hidden');
  } else if (activitytype.indexOf('General - Other') > -1) {
    if (!comment || comment.length == 0) {
      success = false;
      $('#commenterrormessage').removeClass('hidden');
    }
  }

  if (!activitydate && activitydate.length == 0) {
    success = false;
    $('#activitydateerrormessage').removeClass('hidden');
  } else {
    const activityTimestamp = Date.parse(activitydate);

    if (isNaN(activityTimestamp)) {
      success = false;
      $('#activitydateerrormessage').removeClass('hidden');
    }
  }

  if ((timer.indexOf('00:00:00') > -1) || (timer.length != 8)) {
    success = false;
    $('#durationerrormessage').removeClass('hidden');
  }

  return success;
};
