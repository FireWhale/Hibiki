$(document).ready(function(){
    
    //Fills in empty information with a sorry message.
    if ($('#attributes').length > 0 ) {
        if ($('#attributes > div.panel > div.info-list > b').length == 0) {
            $('#attributes > div.panel > div.info-list').html("Sorry, there is no information available");
        };    
    };
    
    //sortable list for editing watchlists
    $('.sortable-records').sortable({
        connectWith: $(".sortable-records"),
        update: function(event, ui) {
            var hidden = ui.item.children().children("input");
            var grouping = ui.item.parent().parent().parent().parent('.grouping').attr('id');
            hidden.attr('name', "[watchlists][" + grouping + "][records][]");
        }
    });    
    
});

$(window).load(function(){
    if ($('#information > #albums').length > 0 ) {
        var initialPath = location.pathname + location.search;
            
        $(".pagination").delegate("a", "click", function() {
            var state = {statePath: $(this).attr('href')};
            history.pushState( state, '', $(this).attr('href'));
        });
        
        $(window).on('popstate', function(event) {
            var state = event.originalEvent.state;
            var stateURL = initialPath;
            if (state) {
                stateURL = state.statePath;
            }
            
            $.ajax({
                type: "GET",
                url: stateURL,   
                headers: {
                    Accept: "text/javascript, application/javascript"
                }
            });

        });
    };

    if ($('#collection').length > 0 ) {
        var initialPath = location.pathname + location.search;
            
        $("#collection-tabs, .pagination").delegate("a", "click", function() {
            var state = {statePath: $(this).attr('href')};
            history.pushState( state, '', $(this).attr('href'));
        });
        
        $(window).on('popstate', function(event) {
            var state = event.originalEvent.state;
            var stateURL = initialPath;
            if (state) {
                stateURL = state.statePath;
            }
            
            $.ajax({
                type: "GET",
                url: stateURL,   
                headers: {
                    Accept: "text/javascript, application/javascript"
                }
            });

        });
    };

});
