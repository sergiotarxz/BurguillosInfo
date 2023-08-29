"use strict";
import Tablesort from 'tablesort';
window.Tablesort = require('tablesort');
require('tablesort/src/sorts/tablesort.number');

window.onload = () => {
    const menu_expand = document.querySelector('a.menu-expand');
    const mobile_foldable = document.querySelector('nav.mobile-foldable');
    const tables = document.querySelectorAll('table')

    loadAd()
    addEasterEggAnimation()

    if (menu_expand !== null && mobile_foldable !== null) {
        menu_expand.addEventListener('click', () => {
            mobile_foldable.classList.toggle('show');
        });
    }

    for (const table of tables) {
        const header = table.querySelector('tr');
        if (header !== null) {
            header.setAttribute('data-sort-method', 'none')
            for (const th of header.querySelectorAll('th')) {
                if (th.getAttribute('data-sort-method') == null) {
                    th.setAttribute('data-sort-method', 'thead')
                }
            }
        }
        new Tablesort(table)
    }
    if (window !== undefined && window.Android !== undefined) {
        executeAndroidExclusiveCode(Android)
    }
};

function absoluteToHost(imageUrl) {
    if (imageUrl.match(/^\//)) {
        imageUrl = window.location.protocol + "//" + window.location.host + imageUrl 
    }
    return imageUrl.replace(/\?.*$/, '');
}

function executeAndroidExclusiveCode(android) {
    document.querySelectorAll('*.android').forEach((element) => {
        element.classList.remove('android')
    })
    const pinToHomeUrl = document.querySelector('a.pin-to-home')
    if (pinToHomeUrl === null) {
        return;
    }
    pinToHomeUrl.addEventListener('click', () => {
        const url = new URL(window.location.href)
        const pathandQuery = url.pathname + url.search;
        const label = pathandQuery.replace(/^.*\/.?/g, '').
            replace(/(?:^|-)\w/g, function(character) {
                return character.toUpperCase() 
            });
        const firstImg = document.querySelector('div.description img');
        let iconUrl;
        if (firstImg !== null) {
            if (!firstImg.src.match(/\.svg(?:\?|$)/)) {
                iconUrl = absoluteToHost(firstImg.src);
            }
        }
        if (iconUrl === undefined) {
            const imagePreview = document.querySelector('meta[name="image"]');
            iconUrl = absoluteToHost(imagePreview.content);
        }
        console.error(iconUrl);
        android.pinPage(pathandQuery, label, iconUrl)
    })
}

function addEasterEggAnimation() {
    const logoContainer = document.querySelector('div.burguillos-logo-container')
    if (logoContainer === null) {
        return;
    }
    logoContainer.addEventListener('click', () => {
        logoContainer.classList.toggle('active')
    })
}

let current_ad_number = null

function expand_page_contents() {
    const page_contents = document.querySelector('div.page-contents'); 
    if (page_contents === null) {
        return;
    }
    page_contents.classList.add('no-carousel');
}

function no_more_ads() {
    const carousel = document.querySelector('.carousel');
    if (carousel !== null) {
        carousel.remove();
    }
    expand_page_contents();
}

function loadAd() {
    const params = new URLSearchParams();
    if (current_ad_number !== null) {
        params.append('n', ""+current_ad_number);
    }
    fetch('/next-ad.json?' + params).then((res) => {
        return res.json()
    }).then((res) => {
        current_ad_number = res.current_ad_number
        const ad = res.ad
        const must_continue = res.continue
        const carousel = document.querySelector('.carousel');
        if (must_continue === 0
                || carousel === null
                || carousel.offsetWidth === 0) {
            no_more_ads();
            return;
        }
        const a = _retrieveLinkCarousel(carousel)
        a.innerHTML = ""
        const image = document.createElement('img')
        const text_container = document.createElement('div')
        const text = document.createElement('h4')
        const promoted = document.createElement('p')

        promoted.classList.add('promoted-tag')
        promoted.innerText = "Promocionado"
        image.src = ad.img
        image.alt = ""
        text.innerText = ad.text
        a.href = ad.href

        a.append(image)
        text_container.append(promoted)
        text_container.append(text)
        a.append(text_container)

        window.setTimeout(() => {
            loadAd()
        }, ad.seconds * 1000)
    }).catch(() => {
        window.setTimeout(() => {
            loadAd()
        }, 1000)
    });
}

function _retrieveLinkCarousel(carousel) {
    const maybeA = carousel.querySelector('a')
    if (maybeA !== null) {
        return maybeA
    }
    const a = document.createElement('a')
    carousel.innerHTML = ""
    carousel.append(a)
    return a
}
