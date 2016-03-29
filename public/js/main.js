$(document).ready(function() {
	$('form[data-confirm]').submit(function() {
	    return confirm($(this).data('confirm'));
	});
	
	$('.if-mode-select').change(function() {
		sect = $(this).parent().next('.static-cfg');
		$(this).val() == 'static' ? sect.show() : sect.hide();
	});
	
	$('.if-mode-select').change();

	$('.if-encryption-select').change(function() {
		sect = $(this).parent().next('.encryption-cfg');
		$(this).val() != 'none' ? sect.show() : sect.hide();
	});
	
	$('.if-encryption-select').change();
	
	$('#firmware_name').change(function() {
		$(".fw-param").prop('disabled', true);
		$(".fw-params").hide();
		sid = "fw-params-" + $(this).val(); 
		$("#" + sid + " .fw-param").prop('disabled', false);
		$("#" + sid).show();
	});
	
	$('#firmware_name').change();
	
});