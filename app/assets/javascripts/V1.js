$(document).ready(function(){

  // scroll function on show pages
  
  //Sortable list for languages
  $('#languages').sortable();
  $('#artistlanguages').sortable();  
 
  //Date picker for calendar  
  $('#datepicker').datepicker();

  
  //sortable list for editing watchlists
  $('.sortableGroup').sortable({
      connectWith: $(".sortableGroup"),
      update: function(event, ui) {
          var hidden = ui.item.children().children("input");
          var grouping = ui.item.parent().parent().attr('id');
          hidden.attr('name', "[watchlist_edit][" + grouping + "][records][]");
      }
  });
  $('#groupings').sortable();
  
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

