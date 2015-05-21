function monkeyPatchAutocomplete() {
		
    $.ui.autocomplete.prototype._renderItem = function( ul, item) {
        var re = new RegExp(this.term,"i");
        var term = re.exec(item.label) || [this.term];
        var t = item.label.replace(re,"<span style='font-weight:bold;color:Blue;'>" + 
                term[0] + 
                "</span>");
        var model = item.model || "";
        var record_id = item.id;
        if(item.id) {
        	record_id = " #" + item.id;
        }
        
        return $( "<li></li>" )
            .data( "item.autocomplete", item )
            .append("<span class='model-info'>" + model + record_id + "</span>" + "<a>" + t + "</a>")
            .appendTo( ul );
    };

}

$(document).ready(function() {
	//Since autocomplete is on the header, just assuming it needs to load all the time.
	monkeyPatchAutocomplete();
});