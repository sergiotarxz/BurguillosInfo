"use strict";
import tablesort from 'tablesort';
require('tablesort/src/sorts/tablesort.number');

window.onload = () => {
    const menu_expand = document.querySelector('a.menu-expand');
    const mobile_foldable = document.querySelector('nav.mobile-foldable');
    const tables = document.querySelectorAll('table')

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
        tablesort(table)
    }
};
