"use strict";
import Tablesort from "tablesort";
import CarouselAd from "@burguillosinfo/carousel-ad";
window.Tablesort = require("tablesort");

require("tablesort/src/sorts/tablesort.number");

let fakeSearchInput;
let searchMobile;

const cookies = document.cookie
  .split("; ")
  .map((cookie) => {
    let [key, value] = cookie.split("=");
    return {
      key: key,
      value: value,
    };
  })
  .reduce((acc, cookie) => {
    acc[cookie.key] = cookie.value;
    return acc;
  }, {});

function addEventListernerExpandDescriptionProducts() {
  const searchResults = document.querySelectorAll("div.search-result");
  for (const result of searchResults) {
    const a = result.querySelector("div.row-title-url-image a");
    if (a === null) {
      continue;
    }
    if (!a.href) {
      continue;
    }
    const askUrl = a.href + ".json";
    const content = result.querySelector("div.search-result-content");
    const expand = result.querySelector("div.search-result-content a.expand");
    if (expand === null) {
      continue;
    }
    expand.addEventListener("click", (event) => {
      event.preventDefault();
      fetch(askUrl).then(async (res) => {
        const json = await res.json();
        content.innerHTML = json.description;
      });
    });
  }
}

function startSuggestions() {
  const searchInputs = document.querySelectorAll("div.fake-text-box input");
  const port = _port();
  const url = new URL(
    window.location.protocol +
      "//" +
      window.location.hostname +
      port +
      "/search/suggestions.json",
  );
  fetch(url).then(async (res) => {
    let suggestions = await res.json();
    let selectedSuggestion;
    let currentLength = 0;
    let waitCounter;
    const last3SearchSuggestions = [];
    window.setInterval(() => {
      if (--waitCounter > 0) {
        return;
      }
      if (!selectedSuggestion || currentLength > selectedSuggestion.length) {
        selectedSuggestion =
          suggestions[Math.floor(Math.random() * suggestions.length)];
        currentLength = 0;
        while (last3SearchSuggestions.includes(selectedSuggestion)) {
          selectedSuggestion =
            suggestions[Math.floor(Math.random() * suggestions.length)];
          currentLength = 0;
        }
        last3SearchSuggestions.push(selectedSuggestion);
        if (last3SearchSuggestions.length > 2) {
          last3SearchSuggestions.shift();
        }
        waitCounter = 5;
        return;
      }
      currentLength++;
      for (const input of searchInputs) {
        input.setAttribute(
          "placeholder",
          selectedSuggestion.substring(0, currentLength),
        );
      }
    }, 100);
  });
}

document.addEventListener(
  "DOMContentLoaded",
  function () {
    window.addEventListener("popstate", (event) => {
      if (event) {
        console.log("refreshing");
        window.location.reload();
      }
    });
    startSuggestions();
    addEventListernerExpandDescriptionProducts();
    let focusSearch = document.body.querySelector(
      "nav.mobile-shortcuts div.search input",
    );
    if (focusSearch === null) {
      focusSearch = document.body.querySelector("div.search input");
    }
    if (focusSearch !== null) {
      focusSearch.focus();
    }

    const menu_expand = document.querySelector("a.menu-expand");
    const mobile_foldable = document.querySelector("nav.mobile-foldable");
    const transparentFullscreenHide = document.querySelector(
      "div.transparent-fullscreen-hide",
    );
    const contentsWithoutMenu = document.querySelector(
      "div.contents-without-menu",
    );
    const tables = document.querySelectorAll("table");
    const searchTooltips = document.querySelectorAll(
      "div.tooltip-search-promo",
    );
    for (const searchTooltip of searchTooltips) {
      const cookie_name = "seen-tooltip-this-week";
      if (cookies[cookie_name]) {
        searchTooltip.classList.add("hidden");
      }
      searchTooltip.addEventListener("click", () => {
        let time = 86400 * 7;
        document.cookie = `${cookie_name}=1; max-age=${time}; path=/;`;
        for (const searchTooltip of searchTooltips) {
          searchTooltip.classList.add("hidden");
        }
      });
    }
    fillFarmaciaGuardia();
    //    new CarouselAd().run()
    addEasterEggAnimation();

    if (
      menu_expand !== null &&
      mobile_foldable !== null &&
      transparentFullscreenHide !== null &&
      contentsWithoutMenu !== null
    ) {
      mobile_foldable.toggleAttribute("aria-hidden");
      if (mobile_foldable.getAttribute("aria-hidden") !== null) {
        mobile_foldable.setAttribute("aria-hidden", true);
      }
      transparentFullscreenHide.addEventListener("click", () => {
        mobile_foldable.classList.remove("show");
        transparentFullscreenHide.classList.remove("show");
        menu_expand.classList.remove("active");
        contentsWithoutMenu.removeAttribute("aria-hidden");
        mobile_foldable.setAttribute("aria-hidden", true);
      });
      menu_expand.addEventListener("click", () => {
        menu_expand.classList.toggle("active");
        mobile_foldable.classList.toggle("show");
        transparentFullscreenHide.classList.toggle("show");
        contentsWithoutMenu.toggleAttribute("aria-hidden");
        if (contentsWithoutMenu.getAttribute("aria-hidden") !== null) {
          contentsWithoutMenu.setAttribute("aria-hidden", true);
        }
        mobile_foldable.toggleAttribute("aria-hidden");
        if (mobile_foldable.getAttribute("aria-hidden") !== null) {
          mobile_foldable.setAttribute("aria-hidden", true);
        }
      });
    }

    for (const table of tables) {
      const header = table.querySelector("tr");
      if (header !== null) {
        header.setAttribute("data-sort-method", "none");
        for (const th of header.querySelectorAll("th")) {
          if (th.getAttribute("data-sort-method") == null) {
            th.setAttribute("data-sort-method", "thead");
          }
        }
      }
      new Tablesort(table);
    }
    if (window !== undefined && window.Android !== undefined) {
      executeAndroidAppExclusiveCode(Android);
    }
    searchMobile = document.querySelector("nav.mobile-shortcuts div.search");
    if (searchMobile !== null) {
      fakeSearchInput = searchMobile.querySelector("input");
      addListenersSearch();
    }
    addListenersSearchOverlay();

    if (!cookies["search-tutorial-seen"]) {
      startSearchTutorial();
    }
  },
  false,
);

function startSearchTutorial() {
  console.log("Showing how to use search");
  const tutorialOverlay = document.querySelector(".tutorial-overlay-step-1");
  if (tutorialOverlay === null) {
    console.error("tutorialOverlay missing");
    return;
  }
  //    tutorialOverlay.classList.remove('hidden');
}

function markSearchTutorialAsSeen() {
  console.log("Tutorial ended");
  document.cookie = "search-tutorial-seen=1; SameSite=Lax;";
}
function fillFarmaciaGuardia() {
  const farmaciaName = document.querySelector("#farmacia-name");
  const farmaciaAddress = document.querySelector("#farmacia-address");
  if (farmaciaName !== null || farmaciaAddress !== null) {
    const port = _port();
    const url = new URL(
      window.location.protocol +
        "//" +
        window.location.hostname +
        port +
        "/farmacia-guardia.json",
    );
    fetch(url).then(async (res) => {
      const farmacia = await res.json();
      if (farmaciaName !== null) {
        farmaciaName.innerText = farmacia.name;
        farmaciaAddress.innerText = farmacia.address;
      }
    });
  }
}

function addListenersSearch() {
  const searchInPage = document.querySelector("div.search-in-page");
  if (searchMobile !== null) {
    const searchIcon = searchMobile.querySelector("a.search-icon");
    searchIcon.addEventListener("click", (e) => {
      const searchOverlay = document.querySelector("div.search-overlay");
      const searchInput = searchOverlay.querySelector("div.search input");
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({
        event: "fakesearch_term",
        term: fakeSearchInput.value,
      });
      searchInput.value = fakeSearchInput.value;
      onSearchChange(e);
      onFakeSearchClick(e);
      return true;
    });
    fakeSearchInput.addEventListener("keyup", (e) => {
      if (searchInPage === null) {
        return;
      }
      if (fakeSearchInput.value === "") {
        searchInPage.classList.remove("active");
      } else {
        searchInPage.classList.add("active");
      }
      if (e.keyCode !== 13) {
        return false;
      }
      const searchOverlay = document.querySelector("div.search-overlay");
      const searchInput = searchOverlay.querySelector("div.search input");
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({
        event: "fakesearch_term_keyup",
        term: fakeSearchInput.value,
      });
      searchInput.value = fakeSearchInput.value;
      onSearchChange(e);
      onFakeSearchClick(e);
      return true;
    });
  }
  const nextResult = searchInPage.querySelector("a.down");
  const prevResult = searchInPage.querySelector("a.up");
  window.addEventListener("keydown", (e) => {
    if (e.key.toLowerCase() === "f" && e.ctrlKey) {
      openAllDetails();
    }
  });
  window.addEventListener("blur", (e) => {
    openAllDetails();
  });
  if (nextResult !== null && prevResult !== null) {
    nextResult.addEventListener("click", () => {
      searchInWebsite(fakeSearchInput.value, true);
    });
    prevResult.addEventListener("click", () => {
      searchInWebsite(fakeSearchInput.value, false);
    });
  }
  const exitSearch = document.querySelector("a.exit-search");
  const searchOverlay = document.querySelector("div.search-overlay");
  const searchInput = searchOverlay.querySelector("div.search input");
  fakeSearchInput.value = searchInput.value;
  const firstUrl = window.location.href;
  if (exitSearch !== null) {
    exitSearch.addEventListener("click", (event) => {
      onExitSearch(event, firstUrl);
    });
  }
  const searchIconDesktop = document.querySelector("nav.desktop a.search-icon");
  if (searchIconDesktop !== null) {
    searchIconDesktop.addEventListener("click", (e) => {
      onFakeSearchClick(e);
    });
  }
}

function addListenersSearchOverlay() {
  const search = document.querySelector("div.search-overlay div.search input");
  if (search !== null) {
    search.addEventListener("change", onSearchChange);
  }
}

function searchInWebsite(value, isToBottom) {
  window.find(value, false, !isToBottom, true);
  const selection = window.getSelection();
  openAllDetails();
  if (selection.anchorNode === null) {
    const pageContents = document.querySelector("div.page-contents");
    pageContents.focus();
    searchInWebsite(value, isToBottom);
  }
  const anchorNode = selection.anchorNode.parentNode;
  if (anchorNode.tagName !== null && anchorNode.tagName === "INPUT") {
    const pageContents = document.querySelector("div.page-contents");
    pageContents.focus();
    searchInWebsite(value, isToBottom);
  }
  if (anchorNode !== null) {
    const pageContents = document.querySelector("div.page-contents");
    const offsetTop = _getOffsetTopWithNParent(anchorNode, pageContents);
    pageContents.scroll(0, offsetTop - 150);
  }
}

function openAllDetails() {
  for (const detail of document.querySelectorAll("details")) {
    detail.open = true;
  }
}

function _getOffsetTopWithNParent(element, nParent, _carry = 0) {
  if (element === null) {
    return null;
  }
  if (element === nParent) {
    return _carry;
  }
  _carry += element.offsetTop;
  return _getOffsetTopWithNParent(element.offsetParent, nParent, _carry);
}

function _port() {
  let port = window.location.port;
  if (port !== "") {
    port = ":" + port;
  }
  return port;
}

function onSearchChange() {
  const search = document.querySelector("div.search-overlay div.search input");
  const searchResults = document.querySelector(
    "div.search-overlay div.search-results",
  );
  if (search === null || searchResults === null) {
    return;
  }
  const query = search.value;
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({
    event: "realsearch_term_keyup",
    term: search.value,
  });
  if (fakeSearchInput !== undefined && fakeSearchInput !== null) {
    fakeSearchInput.value = search.value;
  }
  let found = search.value.match(/^#(\S+?)(?:\:(\S+?))?$/);
  const port = _port();
  if (found) {
    let attributeUrlPart = found[2];
    console.log(attributeUrlPart);
    if (attributeUrlPart === undefined) {
      attributeUrlPart = "";
    }
    console.log(attributeUrlPart);
    if (attributeUrlPart !== "") {
      attributeUrlPart = "/atributo/" + attributeUrlPart;
    }
    console.log(attributeUrlPart);
    const checkHashstagUrl = new URL(
      window.location.protocol +
        "//" +
        window.location.hostname +
        port +
        "/" +
        found[1] +
        attributeUrlPart,
    );
    fetch(checkHashstagUrl).then((res) => {
      if (res.status === 200) {
        window.location = checkHashstagUrl;
      }
    });
    return;
  }
  const url = new URL(
    window.location.protocol +
      "//" +
      window.location.hostname +
      port +
      "/search.html",
  );
  url.searchParams.set("q", query);
  url.searchParams.set("e", 1);
  fetch(url).then(async (res) => {
    const url = new URL(
      window.location.protocol +
        "//" +
        window.location.hostname +
        port +
        "/search.html",
    );
    url.searchParams.set("q", query);
    document.title = `'${query}' en Burguillos Info`;
    if (!query) {
      document.title = `Buscador de Burguillos Info`;
    }
    history.pushState({}, "", url);
    searchResults.innerHTML = await res.text();
    addEventListernerExpandDescriptionProducts();
    searchResults.scrollTo(0, 0);
  });
  search.focus();
}

function onExitSearch(event, firstUrl) {
  event.preventDefault();
  const searchOverlay = document.querySelector("div.search-overlay");
  if (searchOverlay !== null) {
    searchOverlay.classList.toggle("active");
  }
  if (!searchOverlay.classList.contains("active")) {
    history.pushState({}, "", firstUrl);
  }
}

function onFakeSearchClick(e) {
  e.preventDefault();
  const searchOverlay = document.querySelector("div.search-overlay");
  if (searchOverlay === null) {
    return;
  }
  searchOverlay.classList.toggle("active");
  const search = searchOverlay.querySelector("div.search input");
  if (search !== null) {
    search.focus();
  }
  return false;
}

function absoluteToHost(imageUrl) {
  if (imageUrl.match(/^\//)) {
    imageUrl =
      window.location.protocol + "//" + window.location.host + imageUrl;
  }
  return imageUrl.replace(/\?.*$/, "");
}

function addListenerOpenInBrowserButton(android) {
  const openInBrowserLink = document.querySelector("a.open-in-browser");
  if (openInBrowserLink === null) {
    return;
  }
  openInBrowserLink.addEventListener("click", () => {
    android.openInBrowser(window.location.href);
  });
}
function executeAndroidAppExclusiveCode(android) {
  const url = new URL(
    window.location.protocol +
      "//" +
      window.location.hostname +
      port +
      "/ping/i-am-android-app",
  );
  fetch(url).then((res) => {
    console.log("Reported I am the Android App");
  });
  document.querySelectorAll("*.android").forEach((element) => {
    element.classList.remove("android");
  });
  document.querySelectorAll("*.no-android-app").forEach((element) => {
    element.style.display = "none";
  });
  addListenerOpenInBrowserButton(android);
  const pinToHomeUrl = document.querySelector("a.pin-to-home");
  if (pinToHomeUrl === null) {
    return;
  }
  pinToHomeUrl.addEventListener("click", () => {
    const url = new URL(window.location.href);
    const pathandQuery = url.pathname + url.search;
    const label =
      url.pathname
        .replace(/^.*\//g, "")
        .replace(/(?:^|-)\w/g, function (character) {
          return character.toUpperCase();
        })
        .replace(/-/g, " ") + " - Burguillos.info";
    const firstImg = document.querySelector("div.description img");
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
    android.pinPage(pathandQuery, label, iconUrl);
  });
}

function addEasterEggAnimation() {
  const logoContainer = document.querySelector("div.burguillos-logo-container");
  if (logoContainer === null) {
    return;
  }
  logoContainer.addEventListener("click", () => {
    logoContainer.classList.toggle("active");
  });
}
