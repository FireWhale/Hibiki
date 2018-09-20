
document.addEventListener('click', function() {
    //Post Expanding -used to expand posts with the read more button
    console.log(event)
    if (!event.target.matches('.expand-post')) return;


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
            var upperBound = document.getElementById('number').value;
            var lowerBound = upperBound - 49;
            $('#scrape-alert').text("generated " + lowerBound + " to " + upperBound);
        });
    };

});
