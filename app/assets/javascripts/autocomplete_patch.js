function monkeyPatchAutocomplete() {
		
    $.ui.autocomplete.prototype._renderItem = function( ul, item) {
        var re = new RegExp(this.term.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"),"i");
        var term = re.exec(item.label) || [this.term];
        var t = item.label.replace(re,"<span style='font-weight:bold;color:Blue;'>" + 
                term[0] + 
                "</span>");
        var model = item.model || "";
        var record_id = item.id;
        if(item.id) {
        	record_id = " #" + item.id;
        }
        
        return $( "<li data-model='" + model + "' data-id='" + item.id  + "'></li>" )
            .data( "item.autocomplete", item )
            .append("<span class='model-info'>" + model + record_id + "</span>" + "<a>" + t + "</a>")
            .appendTo( ul );
    };
}

$(document).ready(function() {
	//Since autocomplete is on the header, just assuming it needs to load all the time.
	monkeyPatchAutocomplete();
	
	$('#search-box').bind('railsAutocomplete.select', function(event, data){
		if (!window.location.origin) {
		  window.location.origin = window.location.protocol + "//" 
		    + window.location.hostname 
		    + (window.location.port ? ':' + window.location.port: '');
		}
		var url = window.location.origin + "/" + data.item.model.toLowerCase() + "s/" + data.item.id;
		window.location.href = url;
	});
});
