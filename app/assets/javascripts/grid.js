$(document).ready(function(){


    if ($('#date-slider').length > 0 ) {
        if($('#left-sidebar').length > 0 ) {
            $('#date-slider').slider({
                range: true,
                min: 0,
                max: getUpperLimit(),
                values: [0, getUpperLimit() - 8],
                slide: function( event, ui ) {
                    $('#date-begin').html(Math.floor(ui.values[0] / 12) + 1970);
                    $('#date-end').html(Math.floor(ui.values[1] / 12) + 1970);
                },
                stop: function( event, ui ) {
                    changeHash();
                }
            });
            $('#date-begin').html(Math.floor($('#date-slider').slider('values', 0) / 12) + 1970);
            $('#date-end').html(Math.floor($('#date-slider').slider('values', 1) / 12) + 1970);
        } else {
            $('#date-slider').slider({
                min: 0,
                max: getUpperLimit(),
                value: getUpperLimit() - 12,
                slide: function( event, ui) {
                    $('#date-begin').html(getMonthName(ui.value) + " " + (parseInt(Math.floor(ui.value / 12), 10) + 1970));
                },
                stop: function( event, ui) {
                    changeHash();
                }
            });
            $('#date-begin').html(getMonthName($('#date-slider').slider('value')) + " " + (parseInt(Math.floor($('#date-slider').slider('value')/ 12), 10) + 1970));
        };
    };
});


$(window).load(function(){
    if ($('#grid').length > 0 ) {

        //Sidebar lengths
        if ($(".sidebar").length > 0 ) {
            $(".sidebar").each(function(){
                setHeight($(this));
            });

            $(window).resize(function(){
                $(".sidebar").each(function(){
                    setHeight($(this));
                });
                setHeight($("#grid-content"));
            });
        };
        if ($("#grid-content").length > 0){
            setHeight($("#grid-content"));
        };

        $('#left-sidebar').nanoScroller();
        $('#right-sidebar').nanoScroller();
        $('#grid-content').nanoScroller();

        $('.nano-content').scroll(function() {
            $(window).scroll();
        });

    }


    if ($('#grid-albums').length > 0 ) {

        //Set Special flag to not send requests while another request is processed.
        var requestActive = false,
            newPage = true;

        //function needs to go here for firefox
        function callHashChange() {
            if(requestActive === false) {
                requestActive = true;
                var newHash = window.location.hash.substring(1);
                var splitHash = newHash.split("&");
                var dataArray = {};
                for (var i = 0; i < splitHash.length; i++ ) {
                    var keyvalue = splitHash[i].split("=");
                    dataArray[keyvalue[0]] = keyvalue[1];
                };
                //If there is no left sidebar, Fill in a buncha stuff
                if($('#left-sidebar').length == 0) {
                    dataArray['all_albums'] = 'true';
                    if(newPage == true) {
                        var d = new Date();
                        var current_date = (d.getFullYear() - 1969) * 12 + d.getMonth() - 12;
                        dataArray['date1'] = current_date;
                        dataArray['date2'] = current_date;
                        dataArray['sort'] = "Week";
                    };

                };
                //change the class of the divs in the hash, in case of reload
                if(newPage == true ) {
                    if ("aos" in dataArray) {
                        var aosArray = dataArray['aos'].split(',');
                        jQuery.each(aosArray, function(index, value) {
                            $("a[data-id='" + this + "']").addClass('active');
                            $("a[data-id='" + this + "']").parent().children('span').addClass("glyphicon-ok");
                        });
                        $('.grouping').each(function () {
                            var count = $(this).find('a.active').length;
                            if(count == 0){
                                $(this).find('div.count > span').html('');
                            };
                            if(count > 0) {
                                $(this).find('div.count > span').html(count);
                            }
                        });
                    };
                    if ("col" in dataArray) {
                        var colArray = dataArray['col'].split(',');
                        jQuery.each(colArray, function(index, value) {
                            $("a[data-col='" + this + "']").addClass('active');
                            $("a[data-col='" + this + "']").parent().children('span').addClass("glyphicon-ok");
                        });
                    };
                    if ("rel" in dataArray) {
                        var relArray = dataArray['rel'].split(',');
                        jQuery.each(relArray, function(index, value) {
                            $("a[data-rel='" + this + "']").addClass('active');
                            $("a[data-rel='" + this + "']").parent().children('span').addClass("glyphicon-ok");
                        });
                    };
                    if ("tag" in dataArray) {
                        var tagArray = dataArray['tag'].split(',');
                        jQuery.each(tagArray, function(index, value) {
                            $("a[data-tag='" + this + "']").addClass('active');
                            $("a[data-tag='" + this + "']").parent().children('span').addClass("glyphicon-ok");
                        });
                    };
                    if ("date1" in dataArray && "date2" in dataArray) {
                        var date1 = dataArray['date1'];
                        var date2 = dataArray['date2'];
                        if($('#left-sidebar').length > 0 ) {
                            if(isNaN(date1) === false) {
                                $('#date-slider').slider("values", 0, date1);
                                $('#date-begin').html(Math.floor(dataArray['date1'] / 12) + 1970);
                            }
                            if(isNaN(date2) === false) {
                                $('#date-slider').slider("values", 1, date2);
                                $('#date-end').html(Math.floor(dataArray['date2'] / 12) + 1970);
                            }
                        } else {
                            if(isNaN(date1) === false) {
                                $('#date-slider').slider("value", date1);
                                $('#date-begin').html(Math.floor(dataArray['date1'] / 12) + 1970);
                            };
                        };
                    };
                    if ("sort" in dataArray) {
                        var sort = dataArray['sort'];
                        $("a[data-sort='" + sort + "']").addClass('active');
                        newPage = false;
                    };
                };
                //Call the ajax
                $.ajax({
                    type: "GET",
                    url: '/toggle_albums',
                    data: dataArray
                }).always( function() {
                    var sameHash = window.location.hash.substring(1);
                    if(newHash != sameHash) {
                        var splitHash = sameHash.split("&");
                        var dataArray = {};
                        for (var i = 0; i < splitHash.length; i++ ) {
                            var keyvalue = splitHash[i].split("=");
                            dataArray[keyvalue[0]] = keyvalue[1];
                        }
                        $.ajax({
                            type: "GET",
                            url: '/toggle_albums',
                            data: dataArray
                        });
                    };
                    requestActive = false;
                });
            };
        };

        //Click Detection
        $(".sidebar").delegate("a", "click", function() {
            //Apply class
            if($(this).hasClass('sort-link')) {
                $('.sort-link').removeClass('active');
            };
            $(this).toggleClass("active");
            if($(this).parent().hasClass('filter-item') || $(this).parent().hasClass('item') ) {
                $(this).parent().children('span').toggleClass("glyphicon-ok");
            };
            if($(this).parent().hasClass('item')){
                var count = $(this).parents().eq(2).find('a.active').length;
                if(count == 0){
                    $(this).parents().eq(2).find('div.count > span').html('');
                };
                if(count > 0) {
                    $(this).parents().eq(2).find('div.count > span').html(count);
                }
            };

            changeHash();
            return false;
        });

        //Grouping toggling:
        $("#selection-sidebar").delegate(".group-label", "click", function() {
            $(this).parent().find('.group-items').slideToggle(300, function() {
                $("#left-sidebar").nanoScroller();
            });
            $(this).children('.group-section').children('.chevron').children('span').toggleClass('glyphicon-chevron-down glyphicon-chevron-right');
            return false;
        });
        //Just in case we start clicking, we'll wait .5 secs and check the window hash
        setTimeout(callHashChange, 200);

        //Hash Change
        $(window).bind('hashchange', callHashChange );

    };


});

function setHeight(element){
    var windowBottom = $(window).height();
    var elementTop = element.offset().top;
    var elementHeight = windowBottom - elementTop;
    element.css({ height: elementHeight });
};

function getUpperLimit() {
    var d = new Date();
    return (d.getFullYear() - 1969) * 12 + d.getMonth();
}

function getMonthName(number) {
    var monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ];
    return (monthNames[number % 12]);
}

function changeHash() {
    //Collect the classes
    var aos = $(".group-items > .item > .active").map(function(){
        return $(this).data('id');
    }).get().join();
    var col = $("#collections >.filter-items >.filter-item >.active").map(function() {
        return $(this).data('col');
    }).get().join();
    var rel = $("#releases >.filter-items >.filter-item >.active").map(function() {
        return $(this).data('rel');
    }).get().join();
    var tag = $("#tags >.filter-items >.filter-item >.active").map(function() {
        return $(this).data('tag');
    }).get().join();
    var sort = $("#sorting >.sort-items >.sort-item >.active").first().data('sort');
        //If we have "use slider selected"
        if($('#left-sidebar').length > 0 ) {
            var date1 = (Math.floor($("#date-slider").slider('values', 0) / 12) * 12);
            var date2 = (Math.floor($("#date-slider").slider('values', 1) / 12) * 12) + 11;
        } else {
            var date1 = $("#date-slider").slider('value');
            var date2 = $("#date-slider").slider('value');
        }
    //Change window hash
    window.location.hash = 'aos=' + aos + '&col=' + col + '&rel=' + rel + '&tag=' + tag + '&sort=' + sort + '&date1=' + date1 + '&date2=' + date2;
}


