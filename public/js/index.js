"use strict";

window.onload = () => {
	let menu_expand = document.querySelector('a.menu-expand');
	let mobile_foldable = document.querySelector('nav.mobile-foldable');

	menu_expand.addEventListener('click', () => {
		mobile_foldable.classList.toggle('show');
	});
    loadAd() 
};

let current_ad_number = null;
function loadAd() {
    fetch('/next_ad.json?' + new URLSearchParams({
        n: current_ad_number
    }).then((res) => {
        return res.json()
    }).then((res) => {
        console.log(res)
    })
}
