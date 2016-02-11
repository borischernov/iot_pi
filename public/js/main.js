$(document).ready(function() {
	$('form[data-confirm]').submit(function() {
	    return confirm($(this).data('confirm'));
	});
});