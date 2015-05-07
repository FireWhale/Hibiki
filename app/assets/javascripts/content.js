$(document).ready(function(){
    
    //Fills in empty information with a sorry message.
    if ($('#attributes').length > 0 ) {
        if ($('#attributes > div.panel > div.info-list > b').length == 0) {
            $('#attributes > div.panel > div.info-list').html("Sorry, there is no information available");
        };    
    };
    
    
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
