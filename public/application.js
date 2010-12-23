$(document).ready(function(){
	
	$('.form textarea').keypress(function(e){
		if(e.ctrlKey && e.which == 13){ // Ctrl-Enter
			e.preventDefault();
			alert('submit that shit');
			$(this).parent().submit();
			return false;			
		 }
	});
	
});