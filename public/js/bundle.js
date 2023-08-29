/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./js-src/index.js":
/*!*************************!*\
  !*** ./js-src/index.js ***!
  \*************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony import */ var tablesort__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tablesort */ \"./node_modules/tablesort/src/tablesort.js\");\n/* harmony import */ var tablesort__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(tablesort__WEBPACK_IMPORTED_MODULE_0__);\n\n\nwindow.Tablesort = __webpack_require__(/*! tablesort */ \"./node_modules/tablesort/src/tablesort.js\");\n__webpack_require__(/*! tablesort/src/sorts/tablesort.number */ \"./node_modules/tablesort/src/sorts/tablesort.number.js\");\n\nwindow.onload = () => {\n    const menu_expand = document.querySelector('a.menu-expand');\n    const mobile_foldable = document.querySelector('nav.mobile-foldable');\n    const tables = document.querySelectorAll('table')\n\n    loadAd()\n    addEasterEggAnimation()\n\n    if (menu_expand !== null && mobile_foldable !== null) {\n        menu_expand.addEventListener('click', () => {\n            mobile_foldable.classList.toggle('show');\n        });\n    }\n\n    for (const table of tables) {\n        const header = table.querySelector('tr');\n        if (header !== null) {\n            header.setAttribute('data-sort-method', 'none')\n            for (const th of header.querySelectorAll('th')) {\n                if (th.getAttribute('data-sort-method') == null) {\n                    th.setAttribute('data-sort-method', 'thead')\n                }\n            }\n        }\n        new (tablesort__WEBPACK_IMPORTED_MODULE_0___default())(table)\n    }\n    if (window !== undefined && window.Android !== undefined) {\n        executeAndroidExclusiveCode(Android)\n    }\n};\n\nfunction absoluteToHost(imageUrl) {\n    if (imageUrl.match(/^\\//)) {\n        imageUrl = window.location.protocol + \"//\" + window.location.host + imageUrl \n    }\n    return imageUrl.replace(/\\?.*$/, '');\n}\n\nfunction executeAndroidExclusiveCode(android) {\n    document.querySelectorAll('*.android').forEach((element) => {\n        element.classList.remove('android')\n    })\n    const pinToHomeUrl = document.querySelector('a.pin-to-home')\n    if (pinToHomeUrl === null) {\n        return;\n    }\n    pinToHomeUrl.addEventListener('click', () => {\n        const url = new URL(window.location.href)\n        const pathandQuery = url.pathname + url.search;\n        const label = pathandQuery.replace(/^.*\\//g, '').\n            replace(/(?:^|-)\\w/g, function(character) {\n                return character.toUpperCase() \n            }) + ' - Burguillos.info';\n        console.log(label)\n        const firstImg = document.querySelector('div.description img');\n        let iconUrl;\n        if (firstImg !== null) {\n            if (!firstImg.src.match(/\\.svg(?:\\?|$)/)) {\n                iconUrl = absoluteToHost(firstImg.src);\n            }\n        }\n        if (iconUrl === undefined) {\n            const imagePreview = document.querySelector('meta[name=\"image\"]');\n            console.error(imagePreview.content);\n            console.error(absoluteToHost(imagePreview.content));\n            iconUrl = absoluteToHost(imagePreview.content);\n        }\n        console.error(iconUrl);\n        android.pinPage(pathandQuery, label, iconUrl)\n    })\n}\n\nfunction addEasterEggAnimation() {\n    const logoContainer = document.querySelector('div.burguillos-logo-container')\n    if (logoContainer === null) {\n        return;\n    }\n    logoContainer.addEventListener('click', () => {\n        logoContainer.classList.toggle('active')\n    })\n}\n\nlet current_ad_number = null\n\nfunction expand_page_contents() {\n    const page_contents = document.querySelector('div.page-contents'); \n    if (page_contents === null) {\n        return;\n    }\n    page_contents.classList.add('no-carousel');\n}\n\nfunction no_more_ads() {\n    const carousel = document.querySelector('.carousel');\n    if (carousel !== null) {\n        carousel.remove();\n    }\n    expand_page_contents();\n}\n\nfunction loadAd() {\n    const params = new URLSearchParams();\n    if (current_ad_number !== null) {\n        params.append('n', \"\"+current_ad_number);\n    }\n    fetch('/next-ad.json?' + params).then((res) => {\n        return res.json()\n    }).then((res) => {\n        current_ad_number = res.current_ad_number\n        const ad = res.ad\n        const must_continue = res.continue\n        const carousel = document.querySelector('.carousel');\n        if (must_continue === 0\n                || carousel === null\n                || carousel.offsetWidth === 0) {\n            no_more_ads();\n            return;\n        }\n        const a = _retrieveLinkCarousel(carousel)\n        a.innerHTML = \"\"\n        const image = document.createElement('img')\n        const text_container = document.createElement('div')\n        const text = document.createElement('h4')\n        const promoted = document.createElement('p')\n\n        promoted.classList.add('promoted-tag')\n        promoted.innerText = \"Promocionado\"\n        image.src = ad.img\n        image.alt = \"\"\n        text.innerText = ad.text\n        a.href = ad.href\n\n        a.append(image)\n        text_container.append(promoted)\n        text_container.append(text)\n        a.append(text_container)\n\n        window.setTimeout(() => {\n            loadAd()\n        }, ad.seconds * 1000)\n    }).catch(() => {\n        window.setTimeout(() => {\n            loadAd()\n        }, 1000)\n    });\n}\n\nfunction _retrieveLinkCarousel(carousel) {\n    const maybeA = carousel.querySelector('a')\n    if (maybeA !== null) {\n        return maybeA\n    }\n    const a = document.createElement('a')\n    carousel.innerHTML = \"\"\n    carousel.append(a)\n    return a\n}\n\n\n//# sourceURL=webpack://BurguillosInfo/./js-src/index.js?");

/***/ }),

/***/ "./node_modules/tablesort/src/sorts/tablesort.number.js":
/*!**************************************************************!*\
  !*** ./node_modules/tablesort/src/sorts/tablesort.number.js ***!
  \**************************************************************/
/***/ (() => {

eval("(function(){\n  var cleanNumber = function(i) {\n    return i.replace(/[^\\-?0-9.]/g, '');\n  },\n\n  compareNumber = function(a, b) {\n    a = parseFloat(a);\n    b = parseFloat(b);\n\n    a = isNaN(a) ? 0 : a;\n    b = isNaN(b) ? 0 : b;\n\n    return a - b;\n  };\n\n  Tablesort.extend('number', function(item) {\n    return item.match(/^[-+]?[£\\x24Û¢´€]?\\d+\\s*([,\\.]\\d{0,2})/) || // Prefixed currency\n      item.match(/^[-+]?\\d+\\s*([,\\.]\\d{0,2})?[£\\x24Û¢´€]/) || // Suffixed currency\n      item.match(/^[-+]?(\\d)*-?([,\\.]){0,1}-?(\\d)+([E,e][\\-+][\\d]+)?%?$/); // Number\n  }, function(a, b) {\n    a = cleanNumber(a);\n    b = cleanNumber(b);\n\n    return compareNumber(b, a);\n  });\n}());\n\n\n//# sourceURL=webpack://BurguillosInfo/./node_modules/tablesort/src/sorts/tablesort.number.js?");

/***/ }),

/***/ "./node_modules/tablesort/src/tablesort.js":
/*!*************************************************!*\
  !*** ./node_modules/tablesort/src/tablesort.js ***!
  \*************************************************/
/***/ ((module) => {

eval(";(function() {\n  function Tablesort(el, options) {\n    if (!(this instanceof Tablesort)) return new Tablesort(el, options);\n\n    if (!el || el.tagName !== 'TABLE') {\n      throw new Error('Element must be a table');\n    }\n    this.init(el, options || {});\n  }\n\n  var sortOptions = [];\n\n  var createEvent = function(name) {\n    var evt;\n\n    if (!window.CustomEvent || typeof window.CustomEvent !== 'function') {\n      evt = document.createEvent('CustomEvent');\n      evt.initCustomEvent(name, false, false, undefined);\n    } else {\n      evt = new CustomEvent(name);\n    }\n\n    return evt;\n  };\n\n  var getInnerText = function(el,options) {\n    return el.getAttribute(options.sortAttribute || 'data-sort') || el.textContent || el.innerText || '';\n  };\n\n  // Default sort method if no better sort method is found\n  var caseInsensitiveSort = function(a, b) {\n    a = a.trim().toLowerCase();\n    b = b.trim().toLowerCase();\n\n    if (a === b) return 0;\n    if (a < b) return 1;\n\n    return -1;\n  };\n\n  var getCellByKey = function(cells, key) {\n    return [].slice.call(cells).find(function(cell) {\n      return cell.getAttribute('data-sort-column-key') === key;\n    });\n  };\n\n  // Stable sort function\n  // If two elements are equal under the original sort function,\n  // then there relative order is reversed\n  var stabilize = function(sort, antiStabilize) {\n    return function(a, b) {\n      var unstableResult = sort(a.td, b.td);\n\n      if (unstableResult === 0) {\n        if (antiStabilize) return b.index - a.index;\n        return a.index - b.index;\n      }\n\n      return unstableResult;\n    };\n  };\n\n  Tablesort.extend = function(name, pattern, sort) {\n    if (typeof pattern !== 'function' || typeof sort !== 'function') {\n      throw new Error('Pattern and sort must be a function');\n    }\n\n    sortOptions.push({\n      name: name,\n      pattern: pattern,\n      sort: sort\n    });\n  };\n\n  Tablesort.prototype = {\n\n    init: function(el, options) {\n      var that = this,\n          firstRow,\n          defaultSort,\n          i,\n          cell;\n\n      that.table = el;\n      that.thead = false;\n      that.options = options;\n\n      if (el.rows && el.rows.length > 0) {\n        if (el.tHead && el.tHead.rows.length > 0) {\n          for (i = 0; i < el.tHead.rows.length; i++) {\n            if (el.tHead.rows[i].getAttribute('data-sort-method') === 'thead') {\n              firstRow = el.tHead.rows[i];\n              break;\n            }\n          }\n          if (!firstRow) {\n            firstRow = el.tHead.rows[el.tHead.rows.length - 1];\n          }\n          that.thead = true;\n        } else {\n          firstRow = el.rows[0];\n        }\n      }\n\n      if (!firstRow) return;\n\n      var onClick = function() {\n        if (that.current && that.current !== this) {\n          that.current.removeAttribute('aria-sort');\n        }\n\n        that.current = this;\n        that.sortTable(this);\n      };\n\n      // Assume first row is the header and attach a click handler to each.\n      for (i = 0; i < firstRow.cells.length; i++) {\n        cell = firstRow.cells[i];\n        cell.setAttribute('role','columnheader');\n        if (cell.getAttribute('data-sort-method') !== 'none') {\n          cell.tabindex = 0;\n          cell.addEventListener('click', onClick, false);\n\n          if (cell.getAttribute('data-sort-default') !== null) {\n            defaultSort = cell;\n          }\n        }\n      }\n\n      if (defaultSort) {\n        that.current = defaultSort;\n        that.sortTable(defaultSort);\n      }\n    },\n\n    sortTable: function(header, update) {\n      var that = this,\n          columnKey = header.getAttribute('data-sort-column-key'),\n          column = header.cellIndex,\n          sortFunction = caseInsensitiveSort,\n          item = '',\n          items = [],\n          i = that.thead ? 0 : 1,\n          sortMethod = header.getAttribute('data-sort-method'),\n          sortOrder = header.getAttribute('aria-sort');\n\n      that.table.dispatchEvent(createEvent('beforeSort'));\n\n      // If updating an existing sort, direction should remain unchanged.\n      if (!update) {\n        if (sortOrder === 'ascending') {\n          sortOrder = 'descending';\n        } else if (sortOrder === 'descending') {\n          sortOrder = 'ascending';\n        } else {\n          sortOrder = that.options.descending ? 'descending' : 'ascending';\n        }\n\n        header.setAttribute('aria-sort', sortOrder);\n      }\n\n      if (that.table.rows.length < 2) return;\n\n      // If we force a sort method, it is not necessary to check rows\n      if (!sortMethod) {\n        var cell;\n        while (items.length < 3 && i < that.table.tBodies[0].rows.length) {\n          if(columnKey) {\n            cell = getCellByKey(that.table.tBodies[0].rows[i].cells, columnKey);\n          } else {\n            cell = that.table.tBodies[0].rows[i].cells[column];\n          }\n\n          // Treat missing cells as empty cells\n          item = cell ? getInnerText(cell,that.options) : \"\";\n\n          item = item.trim();\n\n          if (item.length > 0) {\n            items.push(item);\n          }\n\n          i++;\n        }\n\n        if (!items) return;\n      }\n\n      for (i = 0; i < sortOptions.length; i++) {\n        item = sortOptions[i];\n\n        if (sortMethod) {\n          if (item.name === sortMethod) {\n            sortFunction = item.sort;\n            break;\n          }\n        } else if (items.every(item.pattern)) {\n          sortFunction = item.sort;\n          break;\n        }\n      }\n\n      that.col = column;\n\n      for (i = 0; i < that.table.tBodies.length; i++) {\n        var newRows = [],\n            noSorts = {},\n            j,\n            totalRows = 0,\n            noSortsSoFar = 0;\n\n        if (that.table.tBodies[i].rows.length < 2) continue;\n\n        for (j = 0; j < that.table.tBodies[i].rows.length; j++) {\n          var cell;\n\n          item = that.table.tBodies[i].rows[j];\n          if (item.getAttribute('data-sort-method') === 'none') {\n            // keep no-sorts in separate list to be able to insert\n            // them back at their original position later\n            noSorts[totalRows] = item;\n          } else {\n            if (columnKey) {\n              cell = getCellByKey(item.cells, columnKey);\n            } else {\n              cell = item.cells[that.col];\n            }\n            // Save the index for stable sorting\n            newRows.push({\n              tr: item,\n              td: cell ? getInnerText(cell,that.options) : '',\n              index: totalRows\n            });\n          }\n          totalRows++;\n        }\n        // Before we append should we reverse the new array or not?\n        // If we reverse, the sort needs to be `anti-stable` so that\n        // the double negatives cancel out\n        if (sortOrder === 'descending') {\n          newRows.sort(stabilize(sortFunction, true));\n        } else {\n          newRows.sort(stabilize(sortFunction, false));\n          newRows.reverse();\n        }\n\n        // append rows that already exist rather than creating new ones\n        for (j = 0; j < totalRows; j++) {\n          if (noSorts[j]) {\n            // We have a no-sort row for this position, insert it here.\n            item = noSorts[j];\n            noSortsSoFar++;\n          } else {\n            item = newRows[j - noSortsSoFar].tr;\n          }\n\n          // appendChild(x) moves x if already present somewhere else in the DOM\n          that.table.tBodies[i].appendChild(item);\n        }\n      }\n\n      that.table.dispatchEvent(createEvent('afterSort'));\n    },\n\n    refresh: function() {\n      if (this.current !== undefined) {\n        this.sortTable(this.current, true);\n      }\n    }\n  };\n\n  if ( true && module.exports) {\n    module.exports = Tablesort;\n  } else {\n    window.Tablesort = Tablesort;\n  }\n})();\n\n\n//# sourceURL=webpack://BurguillosInfo/./node_modules/tablesort/src/tablesort.js?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = __webpack_require__("./js-src/index.js");
/******/ 	
/******/ })()
;