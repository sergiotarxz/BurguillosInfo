"use strict";

window.onload = () => {
	let menu_expand = document.querySelector('a.menu-expand');
	let mobile_foldable = document.querySelector('nav.mobile-foldable');

	menu_expand.addEventListener('click', () => {
		mobile_foldable.classList.toggle('show');
	});
};
