function now(){
  return new Date().getTime();
}

var startTime = 0;
var wordCount = 0;
function updateWPM(){
  wordCount += 1;
  if(startTime == 0){ startTime = now(); }
  var time = (now() - startTime)/1000;
  if(time >= 1){
    var wpm = wordCount / time * 60;
    $('#wpm .number').text(Math.round(wpm));    
  }
  else {
    $('#wpm .number').text('...');
  }
}

$(document).ready(function(){
  $('.form textarea').keypress(function(e){

    // Spacebar increments WPM
    if(e.which == 32) {
      updateWPM();
    }

    // Ctrl-Enter submits the form
    if(e.ctrlKey && e.which == 13){
      e.preventDefault();
      $(this).parent().submit();
      return false;
    }
  });
});