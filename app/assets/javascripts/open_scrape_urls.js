document.addEventListener('click', function() {
    //Post Expanding -used to expand posts with the read more button
    if (!event.target.matches('#GenerateScrapes')) return;

    var x = document.getElementById('list').value.split('\n');
    console.log(x);
    for (var i = 0; i < x.length; i++) {
        if (x[i].indexOf('.') > 0)
        if (x[i].indexOf('://') < 0)
            window.open('http://'+x[i]);
        else
            console.log(x[i]);
            window.open(x[i], x[i]);
    };
    var upperBound = document.getElementById('number').value;
    var lowerBound = upperBound - 49;
    $('#scrape-alert').text("generated " + lowerBound + " to " + upperBound);
});
