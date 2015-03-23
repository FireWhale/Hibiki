$(window).load(function(){
    //Post Expanding -used to expand posts with the read more button 
    if ($(".expand-post").length > 0) {
        $(".expand-post").on('click', function() {
            var id = $(this).data('id');
            var sentence = document.getElementById("sentence-" + id),
                body = document.getElementById("body-" + id),
                link = document.getElementById("link-" + id);
            var lastSentence = $("#" + id + " > div.post-body > p:last");
            var lastLink = $("#" + id + " > div.post-body > p:last > a:last");
            //if the extra things aren't a child of the body, move them there
            if ($("#" + id + " > span.post-sentence").length > 0) {
                lastSentence.append(sentence);                 
            };
            if ($("#" + id + " > div.post-expand").length > 0) {
                $("#" + id + " > div.post-body").append(body);                 
            };
            if ($("#" + id + " > span.post-link").length > 0) {
                lastLink.append(link);        
            };
            //toggle visibility
            //We need to account for if it ends with an image.
            if (lastSentence.children("span").length == 2) {
                lastSentence.children("span:last-child").fadeToggle().promise().done(function() {
                    if (lastSentence.children("span:last-child").is(":hidden")) {
                        lastSentence.children("span:first-child").show();
                    };
                });
                if (lastSentence.children("span:first-child").is(":visible")) {
                    lastSentence.children("span:first-child").hide();
                };   
            } else {
                lastSentence.children("span").fadeToggle().promise().done(function() {
                    if (lastSentence.children("span").is(":hidden")) {
                        $("#" + id + "> div.post-body > span:last").show();
                    }
                });
                if (lastSentence.children("span").is(":visible")) {
                    $("#" + id + "> div.post-body > span:last").hide();
                }
            }
            $("#" + id + " > div.post-body > div.post-expand").fadeToggle();
            lastLink.children("span:last-child").fadeToggle().promise().done(function() {
                if (lastLink.children("span:last-child").is(":hidden")) {
                    lastLink.children("span:first-child").show();
                };
            });
            if (lastLink.children("span:first-child").is(":visible")) {
                lastLink.children("span:first-child").hide();
            };
            //Change the element's text
            ($(this).text() === "Read More") ? $(this).text("Collapse") : $(this).text("Read More");
        });
    };

    //Used to open vgmdb links for scrape review
    if ($("#GenerateScrapes").length > 0) {
        $("#vgmdbID").on('click', function() {
            var y = parseInt(document.getElementById('number').value),
            url = "http://vgmdb.net/album/",
            full = "";
            for (var i = 0 ; i < 50; i++) {
                y++;
                full = full + url + y + "\n";
            };
            document.getElementById('number').value = y;
            document.getElementById('list').value = full;
        });
        $("#GenerateScrapes").on('click', function() {
            var x = document.getElementById('list').value.split('\n');
            for (var i = 0; i < x.length; i++) {
                if (x[i].indexOf('.') > 0)
                if (x[i].indexOf('://') < 0)
                    window.open('http://'+x[i]);
                else
                    window.open(x[i]);                    
            };
        });
    };
    
});
