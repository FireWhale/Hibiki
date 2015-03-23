$(window).load(function(){
    if ($('#search').length > 0 ) {
        var initialSearch = "/search" + location.search;
            
        $("#search-tabs, .pagination").delegate("a", "click", function() {
            var state = {searchTerm: $(this).attr('href')};
            history.pushState( state, '', $(this).attr('href'));
        });
        $(window).on('popstate', function(event) {
            var state = event.originalEvent.state;
            var stateURL = initialSearch;
            console.log("popped");
            if (state) {
                stateURL = state.searchTerm;
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
