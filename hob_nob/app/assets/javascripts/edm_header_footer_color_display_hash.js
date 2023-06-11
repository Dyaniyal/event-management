$(window).load(function(){
  $(".pick-a-color").pickAColor({
    showSpectrum            : true,
    showSavedColors         : true,
    saveColorsPerElement    : true,
    fadeMenuToggle          : true,
    showAdvanced            : true,
    showHexInput            : true,
    showBasicColors         : true,
    allowBlank              : true
  });
  
  display_hash();
  
  $("input").on("change", function () {
      display_hash();
  });

});

/*function display_hash(){
  var textval1 = $('#edm_header_color').val();
   $('.hex-pound.input-group-addon').css('opacity', '0');
  if(textval1 != ''){
     $('#edm_header_color').prev('.input-group-addon').css('opacity', '1');
  }  
  else{
    $(this).parent('.pick-a-color-markup').children('.input-group-addon').hide();
  }

  var textval2 = $('#edm_footer_color').val();
   $('.hex-pound.input-group-addon').css('opacity', '0');
  if(textval2 != ''){
     $('#edm_footer_color').prev('.input-group-addon').css('opacity', '1');
  }  
  else{
    $(this).parent('.pick-a-color-markup').children('.input-group-addon').hide();
  }
}*/