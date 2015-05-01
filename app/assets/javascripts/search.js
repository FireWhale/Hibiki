$(window).load(function(){
    if ($('#search').length > 0 ) {
        var initialSearch = location.pathname + location.search;
        
        $("#search-tabs, .pagination").delegate("a", "click", function() {
            var state = {statePath: $(this).attr('href')};
            history.pushState( state, '', $(this).attr('href'));
        });
        $(window).on('popstate', function(event) {
            var state = event.originalEvent.state;
            var stateURL = initialSearch;
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
