$(function(){
 $('.active').change(function() {
    update_attribute($(this).attr('url'), $(this).is(":checked"), $(this))
  });
})

// function update_attribute(url, status, current) {
//   $.ajax({
//   url: url + status,
//     success: function() {
//       $(current).val(status);
//       alert("successfull")
//     }
//   });
// }
