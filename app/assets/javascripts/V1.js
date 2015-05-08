$(document).ready(function(){

  // scroll function on show pages
  
  //Sortable list for languages
  $('#languages').sortable();
  $('#artistlanguages').sortable();  
  
  //For Released Review's drill down
  if ($("#ReleasedTable").length > 0) {
      $('.drill').on('click', function() {
          $('.activeDrill').removeClass("activeDrill").addClass("drilled");
          parent = $(this).parent().parent();
          if ((parent).hasClass('drilled')) {
              //Need to unmark it and remove div
              parent.removeClass('drilled');
              parent.next().remove();
          } 
          else {
            parent.addClass("activeDrill");    
            params = {id: parent.attr("class")};
            $.get('/maintenance/released_review_drill', params);
          }  
      });
  };

});

