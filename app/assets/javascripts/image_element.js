class LazyImage extends HTMLImageElement {
    constructor() {
        super()

        lazyload([this]);
    }
}

customElements.define('lazy-img', LazyImage, {extends: 'img'});

//Quick Turoblinks fix for resizing
//Should implement as a custom element, but need both anchor (parent) and img (child) to properly perform
//Thus, just using a turbolinks on load

document.addEventListener('turbolinks:load', function() {
    $(".thumbnail-square img").each(function(){
        resizeToSquare($(this));
    });

    $(window).resize(function(){
        $(".thumbnail-square img").each(function(){
            resizeToSquare($(this));
        });
    });
})

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