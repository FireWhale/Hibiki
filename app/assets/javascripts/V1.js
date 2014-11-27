$(document).ready(function(){

  // scroll function on show pages
  $('.scrolllink').on('click', function() {
    scrollToElement($(this).data('href'), 500, -40);
  });
  
  //Sortable list for languages
  $('#languages').sortable();
  $('#artistlanguages').sortable();  
 
  //Date picker for calendar  
  $('#datepicker').datepicker();

  //Expandable list for seasons/watchlist
  $('.expand-link').on('click', function() {
        $(this).children().toggleClass('ui-icon-triangle-1-s ui-icon-triangle-1-e');
        $(this).next().toggle();
  });
  
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

$(window).load(function(){

      
  //Stops images that are not visible from loading until visible.

  $("img.lazyload").lazyload({
      effect : "fadeIn", 
      effectspeed : 250,
      skip_invisible : false,
      load : function() {
          if($(this).parent().hasClass("thumbnail-square")) {
              resizeToSquare($(this));
          }
      }
  }).removeClass("lazyload");  

  //thumbnails resize on window resize as well.
  $(window).resize(function(){
      $(".thumbnail-square img").each(function(){
          if ($(this).width() < $(this).height()){
              //only need to auto adjust for height > width images.
              //it automatically adjusts for width > height
              var width=$(this).parent().width();
              var height=$(this).parent().height();
              if (height > width) {
                  $(this).css({'height':width+'px'});
                  var resizeactive = "yes";
              } else if (width > height) {
                  $(this).css({'height':width+'px'});
              };                 
          }
      });          
  });   
    
  //For seasons and watchlist show views. 
  if ($("#sidebar-nav").length > 0 ) {
      
      //We need to resize the sidebar scroller 
      //first, we get the height at which the scrollbar is at. 
      var sidebarTop = $("#sidebar-nav").offset().top;
      
      //next, we find the bottom of the window
      var windowBottom = $(window).height();
      
      //now we set the height of the div
      var sidebarHeight = windowBottom - sidebarTop;      
      
      $('#sidebar-nav').css({ height: sidebarHeight });
      if ($('#album-list').length > 0 ){
        $('#album-list').css({ height: sidebarHeight });
      }

      $(window).resize(function(){
        var windowBottom = $(window).height();
        var sidebarHeight = windowBottom - sidebarTop;      
        
        $('#sidebar-nav').css({ height: sidebarHeight });   
        if ($('#album-list').length > 0 ){
          $('#album-list').css({ height: sidebarHeight });
        }
               
      });
        
        //We also need to alert scroll events since we have overflow-y: auto property
        $('#album-list').scroll(function() {
            $(window).scroll();
        });

  }    
    
  // side nav-bar sticky function
  if ($(".sticky").length > 0) {
      var fired = 0;
      var stickyTop = $('.sticky').offset().top; 
      var stickyWidth = $('.sticky').width();
      
      $(window).scroll(function(){ // scroll event 
        if (fired == 0) {
            //Redfines stickyTop in case there's a lazyload image
            stickyTop = $('.sticky').offset().top; 
            stickyWidth = $('.sticky').width();
            fired = 1;   
        };
        
        var windowTop = $(window).scrollTop(); // returns number
        if (+stickyTop < 40 + +windowTop) {
          $('.sticky').css({ position: 'fixed', top: 40});
          $('.sticky').css({ width: stickyWidth });
        }
        else {
          $('.sticky').css('position','static');
        }
      });
  } 
  
  
  // search default page to first one with result
  if ($('#SearchResults').length > 0 ) {
      if ($('#Albums list h5:first-child').length === 0) {
          searchtab('#Albums');
      } else if ($('#Artists div h5:first-child').length === 0) {
          searchtab('#Artists');          
      } else if ($('#Organizations div h5:first-child').length === 0) {
          searchtab('#Organizations');     
      } else if ($('#Sources div h5:first-child').length === 0) {
          searchtab('#Sources');     
      } else if ($('#Songs div h5:first-child').length === 0) {
          searchtab('#Songs');     
      };
      
  };
  
  // search tab function
  $('.searchtab').on('click', function() {
      searchtab($(this).data('href')); 
  });        
});

function searchtab(model) {
   //Clear all the main divs, then highlight the one clicked.
   $('.tabcontents').css("display", "none");
   $(model).css("display", "inline");
    
   //clear all the nav-tabs, then change the one clicked
   $('.searchtab').css('background-color', '');
   $('.searchtab').css('text-decoration', '');
   $(".searchtab[data-href='" + model + "']").css('background-color', '#eeeeee');
   $(".searchtab[data-href='" + model + "']").css('text-decoration', 'none');
     
   var imagediv = $(model + ' img');
   if (imagediv.attr('src') != imagediv.data('original')) {
     imagediv.trigger("reveal");
   };
  
   //Finally, trigger a scroll to lazyload any images. 
   $(window).scroll();

};

function resizeToSquare(img){
    //Used to resize an image to a square if height > width
    //I don't feel comfortable resizing to a square if width > height
    //Because lots of my elements work when the width is flexible. 
    var width=img.parent().width();
    var height=img.parent().height();
    if (height > width) {
        img.css({'height':width+'px'});
        var resizeactive = "yes";
    };   
    
};

function scrollToElement(selector, time, verticalOffset) {
    //Barely Used, but scrolls to the element defined in the selector
    time = typeof(time) != 'undefined' ? time : 1000;
    verticalOffset = typeof(verticalOffset) != 'undefined' ? verticalOffset : 0;
    element = $(selector);
    offset = element.offset();
    offsetTop = offset.top + verticalOffset;
    $('html, body').animate({
        scrollTop: offsetTop
    }, time);
};