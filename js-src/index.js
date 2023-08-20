"use strict";
import Tablesort from 'tablesort';
window.Tablesort = require('tablesort');
require('tablesort/src/sorts/tablesort.number');

window.onload = () => {
    const menu_expand = document.querySelector('a.menu-expand');
    const mobile_foldable = document.querySelector('nav.mobile-foldable');
    const tables = document.querySelectorAll('table')

    loadAd()

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
};

let current_ad_number = null

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
        if (must_continue === 0) {
            return;
        }
        carousel.innerHTML = ""
        const a = document.createElement('a')
        const image = document.createElement('img')
        const text_container = document.createElement('div')
        const text = document.createElement('h3')
        const promoted = document.createElement('p')

        promoted.classList.add('promoted-tag')
        promoted.innerText = "Promocionado"
        image.src = ad.img
        text.innerText = ad.text
        a.href = ad.href

        a.append(image)
        text_container.append(promoted)
        text_container.append(text)
        a.append(text_container)
        carousel.append(a);

        window.setTimeout(() => {
            loadAd()
        }, ad.seconds * 1000)
    })
}
