"use strict";
import Tablesort from 'tablesort';
window.Tablesort = require('tablesort');
require('tablesort/src/sorts/tablesort.number');

let fakeSearchInput
let searchMobile
window.onload = () => {
    const menu_expand = document.querySelector('a.menu-expand');
    const mobile_foldable = document.querySelector('nav.mobile-foldable');
    const tables = document.querySelectorAll('table')

    fillFarmaciaGuardia();
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
    searchMobile = document.querySelector('nav.mobile-shortcuts div.search')
    fakeSearchInput = searchMobile.querySelector('input')
    addListenersSearch()
};

function fillFarmaciaGuardia() {
    const farmaciaName = document.querySelector('#farmacia-name');
    const farmaciaAddress = document.querySelector('#farmacia-address');
    if (farmaciaName !== null || farmaciaAddress !== null) {
        const port = _port()
        const url = new URL(window.location.protocol
        + "//"
        + window.location.hostname
        + port
        + '/farmacia-guardia.json');
        fetch(url).then(async (res) => {
            const farmacia = await res.json()
            if (farmaciaName !== null) {
                farmaciaName.innerText = farmacia.name;
                farmaciaAddress.innerText = farmacia.address;
            }
        })
    }
}

function addListenersSearch() {
    if (searchMobile !== null) {
        const searchIcon = searchMobile.querySelector('div.search-icon')
        searchIcon.addEventListener('click', onFakeSearchClick);
        fakeSearchInput.addEventListener('keydown', (e) => {
            if (e.code !== 'Enter') {
                return false;
            }
            const searchOverlay = document.querySelector('div.search-overlay');
            const searchInput = searchOverlay.querySelector('div.search input');
            searchInput.value = fakeSearchInput.value;
            onSearchChange(e)
            onFakeSearchClick(e)
            return true;
        });
    }
    const nextResult = searchMobile.querySelector('div.down');
    const prevResult = searchMobile.querySelector('div.up');
    if (nextResult !== null && prevResult !== null) {
        nextResult.addEventListener('click', () => {
            searchInWebsite(fakeSearchInput.value, true);
        });
        prevResult.addEventListener('click', () => {
            console.log('hola')
            searchInWebsite(fakeSearchInput.value, false);
        });
    }
    const exitSearch = document.querySelector('a.exit-search')
    const searchOverlay = document.querySelector('div.search-overlay');
    const searchInput = searchOverlay.querySelector('div.search input');
    fakeSearchInput.value = searchInput.value;
    exitSearch.addEventListener('click', onExitSearch)
    const search = document.querySelector('div.search-overlay div.search input');
    if (search !== null) {
        search.addEventListener('change', onSearchChange);
    }
    const searchIconDesktop = document.querySelector('nav.desktop a.search-icon');
    if (searchIconDesktop !== null) {
        searchIconDesktop.addEventListener('click', (e) => {
            onFakeSearchClick(e)
        })
    }
}

function searchInWebsite(value, isToBottom) {
    window.find(value, false, !isToBottom, true);
}

function _port() {
    let port = window.location.port;
    if (port !== '') {
        port = ':' + port
    }
    return port;
}

function onSearchChange() {
    const search = document.querySelector('div.search-overlay div.search input');
    const searchResults = document.querySelector('div.search-overlay div.search-results');
    if (search === null || searchResults === null) {
        return;
    }
    const query = search.value;
    fakeSearchInput.value = search.value
    const port = _port()
    const url = new URL(window.location.protocol
        + "//"
        + window.location.hostname
        + port
        + '/search.json');
    url.searchParams.set('q', query);
    fetch(url).then(async (res) => {
        const json = await res.json()
        if (!json.ok) {
            noResults(searchResults);
            return
        }
        console.log(json.searchObjects.length)
        if (json.searchObjects.length < 1) {
            noResults(searchResults);
            return;
        }
        showResults(searchResults, json.searchObjects);
    })
    search.focus()
}

function showResults(searchResults, searchObjects) {
    searchResults.innerHTML = "";
    for (let searchObject of searchObjects) {
        const searchResultContainer = document.createElement('div')
        searchResultContainer.classList.add('search-result')
        const rowTitleUrlImageDiv = document.createElement('div');
        rowTitleUrlImageDiv.classList.add('row-title-url-image');
        const columnTitleUrl = document.createElement('div');
        columnTitleUrl.classList.add('column-title-url');
        const img = document.createElement('img')
        const title = document.createElement('b')
        const url = document.createElement('a')
        const content = document.createElement('p')

        title.innerText = searchObject.title
        let port = window.location.port;
        if (port !== '') {
            port = ':' + port
        }
        if (searchObject.url.match(/^\//)) {
            searchObject.url = window.location.protocol 
                + "//" + window.location.hostname 
                + port
                + searchObject.url
        }
        let urlImage = searchObject.urlImage;
        if (urlImage !== null && urlImage.match(/^\//)) {
            urlImage = window.location.protocol 
                + "//" + window.location.hostname 
                + port
                + urlImage
        }
        if (urlImage !== null) {
            img.alt = ""
            img.src = urlImage
        }

        url.href = searchObject.url
        url.innerText = searchObject.url
        content.innerText = searchObject.content

        if (urlImage !== null) {
            rowTitleUrlImageDiv.appendChild(img)
        }

        columnTitleUrl.appendChild(title);
        columnTitleUrl.appendChild(document.createElement('br'))
        columnTitleUrl.appendChild(url)

        rowTitleUrlImageDiv.appendChild(columnTitleUrl)

        searchResultContainer.appendChild(rowTitleUrlImageDiv)
        searchResultContainer.appendChild(content)
        searchResults.appendChild(searchResultContainer)
    }
}

function noResults(searchResults) {
    searchResults.innerHTML = ""
    const p = document.createElement('p')
    p.innerText = 'No se han encontrado resultados.'
    searchResults.appendChild(p)
}

function onExitSearch() {
    const searchOverlay = document.querySelector('div.search-overlay');
    if (searchOverlay !== null) {
        searchOverlay.classList.toggle('active');
    }
}

function onFakeSearchClick(e) {
    e.preventDefault();
    const searchOverlay = document.querySelector('div.search-overlay');
    if (searchOverlay === null) {
        return
    }
    searchOverlay.classList.toggle('active');
    const search = searchOverlay.querySelector('div.search input');
    if (search !== null) {
        search.focus()
    }
    return false;
}

function absoluteToHost(imageUrl) {
    if (imageUrl.match(/^\//)) {
        imageUrl = window.location.protocol + "//" + window.location.host + imageUrl 
    }
    return imageUrl.replace(/\?.*$/, '');
}

function addListenerOpenInBrowserButton(android) {
    const openInBrowserLink = document.querySelector('a.open-in-browser')
    if (openInBrowserLink === null) {
        return
    }
    openInBrowserLink.addEventListener('click', () => {
        android.openInBrowser(window.location.href)
    })
}
function executeAndroidExclusiveCode(android) {
    document.querySelectorAll('*.android').forEach((element) => {
        element.classList.remove('android')
    })
    document.querySelectorAll('*.no-android-app').forEach((element) => {
        element.style.display = 'none';
    })
    addListenerOpenInBrowserButton(android)
    const pinToHomeUrl = document.querySelector('a.pin-to-home')
    if (pinToHomeUrl === null) {
        return;
    }
    pinToHomeUrl.addEventListener('click', () => {
        const url = new URL(window.location.href)
        const pathandQuery = url.pathname + url.search;
        const label = (url.pathname.replace(/^.*\//g, '')
            .replace(/(?:^|-)\w/g, function(character) {
                return character.toUpperCase() 
            })
            .replace(/-/g, ' ')) + ' - Burguillos.info';
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
