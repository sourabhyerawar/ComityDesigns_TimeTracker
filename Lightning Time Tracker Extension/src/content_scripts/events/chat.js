$(document).ready(function() {
  const $chatContainer = $(`div[id^='chatInputTextContainer']`);
  if( $chatContainer.length == 0 ) return;
  const $chatTextArea = $chatContainer.find('#chatTextArea');
  if($chatTextArea.length == 0) return;
  const chatKey = getChatKey();
  if(!chatKey) return;
  $chatTextArea.on('focus', function(e){
    chrome.runtime.sendMessage({ type: EventConstants.TRACK_CHAT
      , body: { chatKey: chatKey, type: EventConstants.CHAT_ENTER, activityTime: (new Date()).getTime() }
    });
  });

  $chatTextArea.on('blur', function(e){
    chrome.runtime.sendMessage({ type: EventConstants.TRACK_CHAT
      , body: { chatKey: chatKey, type: EventConstants.CHAT_EXIT, activityTime: (new Date()).getTime() }
    });
  });
});

function getChatKey(){
  let queryParams = location.search;
  if(!queryParams) return null;
  const chatIdLength = ('chatId=').length;
  let chatId = queryParams.indexOf('chatId=');
  return (chatId >= 0 ? queryParams.substring( chatId + chatIdLength, chatId + chatIdLength + 36 ) : null);
}
