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
  
  set_color_value();
  
  $(".theme_form input").on("change", function () {
    set_color_value();
  });

});

function set_color_value(){
  var textval1 = $('#theme_background_color').val();
  var textval2= $('#theme_content_font_color').val();
  var textval3 = $('#theme_button_color').val();
  var textval4 = $('#theme_button_content_color').val();
  var textval5 = $('#theme_drawer_menu_back_color').val()
  var textval6 = $('#theme_drawer_menu_font_color').val();
  var textval7 = $('#theme_bar_color').val();
  var textval8 = $('#theme_header_color').val();
  var textval9 = $('#theme_footer_color').val();
   $('.hex-pound.input-group-addon').css('opacity', '0');
  if(textval1 != ''){
     $('#theme_background_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval2 != ''){
     $('#theme_content_font_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval3 != ''){
    $('#theme_button_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval4 != ''){
    $('#theme_button_content_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval5 != ''){
    $('#theme_drawer_menu_back_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval6 != ''){
    $('#theme_drawer_menu_font_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval7 != ''){
    $('#theme_bar_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval8 != ''){
    $('#theme_header_color').prev('.input-group-addon').css('opacity', '1');
  }
  if(textval9 != ''){
    $('#theme_footer_color').prev('.input-group-addon').css('opacity', '1');
  }  
  else{
    $(this).parent('.pick-a-color-markup').children('.input-group-addon').hide();
  } 
}