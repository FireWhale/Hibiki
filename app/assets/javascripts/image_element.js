class LazyImage extends HTMLImageElement {
    constructor() {
        super()

        lazyload([this]);
    }

}


customElements.define('lazy-img', LazyImage, {extends: 'img'});

