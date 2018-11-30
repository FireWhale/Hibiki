document.addEventListener("turbolinks:load", function(){

    //Fills in empty information with a sorry message.
    if ($('#attributes').length > 0 ) {
        if ($('#attributes > div.panel > div.info-list > b').length == 0) {
            $('#attributes > div.panel > div.info-list').html("Sorry, there is no information available");
        };    
    };
    
    //sortable list for editing watchlists
    if ($('.sortable-records').length > 0 ) {
        $('.sortable-records').sortable({
            connectWith: $(".sortable-records"),
            update: function (event, ui) {
                var hidden = ui.item.children().children("input");
                var grouping = ui.item.parent().parent().parent().parent('.grouping').attr('id');
                hidden.attr('name', "[watchlists][" + grouping + "][records][]");
            }
        });
    };

    if ($('.sortable-records').length > 0 ) {
        $('.secondary-languages').sortable();
    };

});

document.addEventListener('click', function() {
    //Post Expanding -used to expand posts with the read more button
    if (!event.target.matches('.add-form')) return;
    event.preventDefault();

    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + event.target.dataset.association, "g")

    var new_fields = document.createElement('div');
    new_fields.innerHTML = event.target.dataset.content.replace(regexp, new_id);

    event.target.parentNode.prepend(new_fields);

});
