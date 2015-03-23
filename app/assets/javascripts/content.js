$(document).ready(function(){
    
    //Fills in empty information with a sorry message.
    if ($('#attributes').length > 0 ) {
        if ($('#attributes > div.panel > div.info-list > b').length == 0) {
            $('#attributes > div.panel > div.info-list').html("Sorry, there is no information available");
        };    
    };
    
    
});