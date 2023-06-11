$(document).ready(function(){
  $('ul.tabs li').click(function(){
    var tab_id = $(this).attr('data-tab');

    $('ul.tabs li').removeClass('current');
    $('.tab-content').removeClass('current');

    $(this).addClass('current');
    $("#"+tab_id).addClass('current');
  });
});
  

$(document).ready(function(){
  if ($("#params_value").attr("params_value") == "attendee"){
    $("#attendee").trigger("click");
  }
});

$(document).ready(function(){
  if ($("#params_value").attr("params_value") == "printBadge"){
    $("#printBadge").trigger("click");
  }
});
$(document).ready(function(){
  if ($("#params_registration_value").attr("params_registration_value") == "onsite_registration"){
    $("#registration_tab").trigger("click");
  }
});
$(document).ready(function(){
  if ($("#invitee_search_tab").attr("invitee_search_tab") == "scanning"){
    $("#qr_scaner").trigger("click");
  }
  if ($("#invitee_search_tab").attr("invitee_search_tab") == "manual_search"){
     $("#qr_scaner").trigger("click");
  }
  if ($("#invitee_search_tab").attr("invitee_search_tab") == "invitee_search_qr"){
    $("#qr_scaner").trigger("click");
  }
  if ($("#invitee_search_tab").attr("invitee_search_tab") == "thank_you"){
    $("#qr_scaner").trigger("click");
  }
  if ($("#invitee_search_tab").attr("invitee_search_tab") == "scanning"){
    $("#tab-5").trigger("click");
  }
  if ($("#invitee_search_tab").attr("invitee_search_tab") == "home_qr_scanner"){
    $("#qr_scaner").trigger("click");
  }
});

// $(document).ready(function(){
//   $('#printBadge').click(function(){
//     $('#get_page').attr( 'for', 'printBadge' )
//   })

//   $('#attendee').click(function(){
//     $('#get_page').attr( 'for', 'attendee' )
//   })  
// });

// $(document).on('click', '#printBadge', function(){
//   var value = $('#get_page').attr('for')
//   alert(value)
// });

// $(document).on('click', '#printBadge', function(){
//   var value = $('#get_page').attr('for')
//   alert(value)
// });

$(document).ready(function(){
  var value = $("#get_page").attr("page")
  if(value == 'attendees'){
    $("#attendee").trigger("click");
  }
  else if (value == 'printbadge')
  {
    $("#printBadge").trigger("click");
  }
});
$(document).ready(function(){

  $(".loadMore_div").click(function(){
    $(this).siblings('.loadLess').show()
    $(this).hide()
    $(this).siblings('#column1_head').find('.row1_display_div11').show();
    $(this).siblings('#column2_data').find('.row1_display_div22').show();
  });
  $(".loadLess").click(function(){
    $(this).siblings('.loadMore_div').show()
    $(this).hide()
    $(this).siblings('#column1_head').find('.row1_display_div11').hide();
    $(this).siblings('#column2_data').find('.row1_display_div22').hide();
  });
});
// $(document).ready(function(){
//   var attr = ($("#params_invitee_page").attr("params_invitee_page") == "invitees_page"){
//     $("#printBadge").trigger("click");
//   }
// });