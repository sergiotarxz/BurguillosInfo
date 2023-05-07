"use strict";
import tablesort from 'tablesort';

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
        const header = document.querySelector('tr');
        if (header !== null) {
            header.setAttribute('data-sort-method', 'none')
            for (const th of header.querySelectorAll('th')) {
                th.setAttribute('data-sort-method', 'thead')
            }
        }
        tablesort(table)
    }
};
