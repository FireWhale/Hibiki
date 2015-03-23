$(window).load(function(){
    $("img.lazyload").lazyload({
        effect : "fadeIn", 
        effectspeed : 250,
        skip_invisible : false,
    }).removeClass("lazyload");    
    
    $(".thumbnail-square img").each(function(){
        resizeToSquare($(this));
    });    
    
    $(window).resize(function(){
         $(".thumbnail-square img").each(function(){
            resizeToSquare($(this));
         });
    });   
});


function resizeToSquare(img){
    //Used to resize an image to a square if height > width
    var outerWidth = img.parent().outerWidth();
    var innerWidth = img.parent().width();
    if (img.data('ratio') > 1) {
        img.parent().css({'height':outerWidth+'px'});
        img.css({'height':(Math.round(innerWidth / img.data('ratio'))) +'px'});
    } else {
        img.css({'height':innerWidth+'px'});
    };   
    
};