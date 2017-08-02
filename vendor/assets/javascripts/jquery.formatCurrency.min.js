//  This file is part of the jQuery formatCurrency Plugin.
//
//    The jQuery formatCurrency Plugin is free software: you can redistribute it
//    and/or modify it under the terms of the GNU Lesser General Public License as published 
//    by the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    The jQuery formatCurrency Plugin is distributed in the hope that it will
//    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
//    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License along with 
//    the jQuery formatCurrency Plugin.  If not, see <http://www.gnu.org/licenses/>.

;(function ($) {
	$.formatCurrency = {};
	$.formatCurrencyLive = {};
	$.toNumber = {};
	$.asNumber = {};

	var fcDefaults = {
		colorize: false,
		region: '',
		roundToDecimalPlace: 2, // roundToDecimalPlace: -2; for not allowing decimals; roundToDecimalPlace: -1; for no rounding; 0 to round to the dollar; 1 for one digit cents; 2 for two digit cents; 3 for three digit cents; ...
		minimumDecimalPlaces: 9,
		eventOnDecimalsEntered: false,
		suppressCurrencySymbol: false,
		removeTrailingZerosOnDecimal: false,
		parseAsFloat: false
	};
	
	var fcLiveDefaults = {
		decPointCharCodes: [], // by index: 0 - key code for key press event; 1 & 2 key codes for keyup event for the decimal point keys on the keyboard and keypad, respectively
		formatOnBlur: true,
		filterKeys: true,
		formatOnType: true
	};

	var toNumberDefaults = {
		region: ''
	};

	var asNumberDefaults = {
		region: '',
		parse: true,
		parseType: 'Float'
	};

	$.formatCurrency.regions = [];

	// default Region is en
	$.formatCurrency.regions[''] = {
		symbol: '$',
		positiveFormat: '%s%n',
		negativeFormat: '(%s%n)',
		decimalSymbol: '.',
		digitGroupSymbol: ',',
		groupDigits: true
	};

	$.formatCurrencyLive.setDefaults = function(settings) {
		$.extend(fcLiveDefaults, settings);
	};

	$.fn.formatCurrencyLive = function (settings) {
		return this.each(function () {
			var $this = $(this);

			settings = buildSettingsObjGraph(
				settings,
				$.extend(
					{},
					fcDefaults,
					fcLiveDefaults,
					($this.data('formatCurrency') ? $this.data('formatCurrency') : {})
				)
			);

			// setup the decimal point charCode setting according to the region
			if (settings.roundToDecimalPlace === -2)
				settings.decPointCharCodes = [-1, -1, -1];
			else {
				if (settings.decimalSymbol == ',')
					settings.decPointCharCodes = [44, 188, 110];
				else
					settings.decPointCharCodes = [46, 190, 110];
			}

			$this.data('formatCurrency', settings);

			if (settings.filterKeys)
				$this.off('keypress.formatCurrency')
					.on('keypress.formatCurrency', function (ev) {
						if (!keyAllowed(ev, settings.decPointCharCodes)) ev.preventDefault();
					});

			if (settings.formatOnType) {
				var settingsFmtOnType = $.extend({}, settings, { roundToDecimalPlace: -1, removeTrailingZerosOnDecimal: false });
				$this.off('keyup.formatCurrency')
					.on('keyup.formatCurrency', function (ev) {
						if (keyAllowed(ev, settings.decPointCharCodes)) $(this).formatCurrency(settingsFmtOnType);
					});
			}

			if (settings.formatOnBlur)
				$this.on('blur.formatCurrency', function (ev) {
					$(this).formatCurrency(settings);
				});

			$(this).formatCurrency(settings);
		});
	};

	$.formatCurrency.setDefaults = function(settings) {
		$.extend(fcDefaults, settings);
	};

	$.formatCurrency.setAllDefaults = function(settings) {
		for (var prop in settings) {
			if(fcDefaults.hasOwnProperty(prop)) fcDefaults[prop] = settings[prop];
			if(fcLiveDefaults.hasOwnProperty(prop)) fcLiveDefaults[prop] = settings[prop];
			if(toNumberDefaults.hasOwnProperty(prop)) toNumberDefaults[prop] = settings[prop];
			if(asNumberDefaults.hasOwnProperty(prop)) asNumberDefaults[prop] = settings[prop];
		}
	};

	$.fn.formatCurrency = function (destination, settings) {

		if (arguments.length == 1 && typeof destination !== "string") {
			settings = destination;
			destination = false;
		}

		// if this element has settings associated with it by the live Formatter and no settings
		// was specified, use the stored settings. Else, build the settings object as normal
		settings = ($(this).data('formatCurrency') && !settings ?
						$(this).data('formatCurrency') : 
						settings
					);

		return this.each(function () {
			var $this = $(this);

			// get number
			var num = '0';
			num = $this[$this.is('input, select, textarea') ? 'val' : 'html']();

			var money = $.getFormattedCurrency(num, settings, true);
			settings = money[4];

			$this.data('fcMetadata', {
				'hasDecimals': money[1],
				'originalDecimals': money[2],
				'isPositive': money[3]
			});

			if(!money) return;

			// setup destination
			var $destination = $([]);
			if (!destination) {
				$destination = $this;
			} else {
				$destination = $(destination);
			}
			// set destination
			$destination[$destination.is('input, select, textarea') ? 'val' : 'html'](money[0]);

			if (money[1] &&
				settings.eventOnDecimalsEntered &&
				money[2].length > 0) {
				$destination.trigger('decimalsEntered', money[2]);
			}

			// colorize
			if (settings.colorize) $destination.css('color', money[3] ? 'black' : 'red');
		});
	};

	$.getFormattedCurrency = function (expr, settings, returnMetadata) {
		settings = buildSettingsObjGraph(settings, fcDefaults);

		if (settings.parseAsFloat) {
			var tryFloat = parseFloat(expr);
			expr = isNaN(tryFloat) ? expr : tryFloat;
		}

		expr = (typeof(expr) !== "string" ? expr.toString().replace('\.', settings.decimalSymbol) : expr);

		//identify '(123)' as a negative number
		if (expr.search('\\(') >= 0)
			expr = '-' + expr;

		if (expr === '' || (expr === '-' && settings.roundToDecimalPlace === -1))
			return (returnMetadata ? [ expr, false, "", true, settings ] : "");

		expr = expr.replace(settings.symbol, ''); // Remove currency symbol for arithmetic
		expr = expr.replace(settings.regexGroupDigit, ''); // Remove group digit for arithmetic

		if (settings.decimalSymbol != '.')
			expr = expr.replace(settings.decimalSymbol, '.');  // reset to US decimal for arithmetic				

		// if the number is valid use it, otherwise clean it
		if (isNaN(expr)) {
			// clean number
			expr = expr.replace(settings.regexArithmetic, '');

			if (expr === '' || (expr === '-' && settings.roundToDecimalPlace === -1))
				expr = '0';

			if (isNaN(expr))
				expr = '0';
		}

		var isPositive = (expr == Math.abs(expr));
		if (!isPositive && settings.disableNegative === true) {
			expr = 0;
			isPositive = true;
		}

		// evalutate number input
		var numParts = String(expr).split('.');
		var hasDecimals = (numParts.length > 1 && settings.roundToDecimalPlace > -2);
		var decimals = (hasDecimals ? numParts[1].toString() : '0');
		var originalDecimals = hasDecimals || decimals != '0' ? decimals : '';

		// format number
		expr = Math.abs(numParts[0]);
		expr = isNaN(expr) ? 0 : expr;
		if (settings.roundToDecimalPlace >= 0) {
			decimals = parseFloat('1.' + decimals); // prepend "0."; (IE does NOT round 0.50.toFixed(0) up, but (1+0.50).toFixed(0)-1
			decimals = decimals.toFixed(settings.roundToDecimalPlace); // round
			if (decimals.substring(0, 1) == '2') {
				expr = Number(expr) + 1;
			}
			decimals = decimals.substring(2); // remove "0."
		}
		expr = String(expr);

		if (settings.groupDigits) {
			for (var i = 0; i < Math.floor((expr.length - (1 + i)) / 3); i++) {
				expr = expr.substring(0, expr.length - (4 * i + 3)) + settings.digitGroupSymbol + expr.substring(expr.length - (4 * i + 3));
			}
		}

		if ((hasDecimals && settings.roundToDecimalPlace == -1) || settings.roundToDecimalPlace > 0) {
			if (settings.removeTrailingZerosOnDecimal) {
				decimals = decimals.replace(/0+$/, '');
				if (decimals.length < settings.minimumDecimalPlaces) decimals = String(decimals + Array(settings.minimumDecimalPlaces+1).join('0')).slice(0,settings.minimumDecimalPlaces);
			}
			expr += (decimals.length > 0 ? settings.decimalSymbol + decimals : "");
		}

		// format symbol/negative
		var format = isPositive ? settings.positiveFormat : settings.negativeFormat;
		var money = format;
		money = money.replace(/%s/g, settings.symbol);
		money = money.replace(/%n/g, expr);

		return (returnMetadata ? [ money, hasDecimals, originalDecimals, isPositive, settings ] : money);
	};

	// Remove all non numbers from text	
	$.toNumber.setDefaults = function(settings) {
		$.extend(toNumberDefaults, settings);
	};

	$.fn.toNumber = function (settings) {
		return this.each(function () {
			var method = $(this).is('input, select, textarea') ? 'val' : 'html';
			$(this)[method]($.toNumber($(this)[method](), settings));
		});
	};

	$.toNumber = function(expr, settings) {
		settings = buildSettingsObjGraph(settings, toNumberDefaults);

		return expr.replace('(', '(-').replace(settings.regex, '');
	};

	// returns the value from the first element as a number
	$.asNumber.setDefaults = function(settings) {
		$.extend(asNumberDefaults, settings);
	};

	$.fn.asNumber = function (settings) {
		var method = $(this).is('input, select, textarea') ? 'val' : 'html';
		var num = $(this)[method]();

		return $.asNumber(num, settings)
	};

	$.asNumber = function(expr, settings) {
		settings = buildSettingsObjGraph(settings, asNumberDefaults);

		expr = expr ? expr : "";
		expr = expr.replace('(', '(-');
		expr = expr.replace(settings.regex, '');
		if (!settings.parse) return expr;

		if (expr.length == 0) expr = '0';

		if (settings.decimalSymbol != '.') expr = expr.replace(settings.decimalSymbol, '.');  // reset to US decimal for arithmetic

		return window['parse' + settings.parseType](expr);
	};

	function buildSettingsObjGraph(settings, defaults) {
		if (!settings) settings = {};
		var bareSettings = settings;

		// build settings graph starting from the defaults and merging region settings if needed
		settings = $.extend(
			{},
			defaults,
			$.formatCurrency.regions[''],
			settings
		);

		if (settings.region !== '') $.extend(settings, getRegionOrCulture(settings.region), bareSettings);

		if (settings.suppressCurrencySymbol) {
			settings.symbol = '';
			settings.positiveFormat = $.trim(settings.positiveFormat.replace('%s', ''));
			settings.negativeFormat = $.trim(settings.negativeFormat.replace('%s', '').replace(' %n', '%n'));
		}

		if (settings.roundToDecimalPlace >= -1) {
			settings.minimumDecimalPlaces = (settings.roundToDecimalPlace == -1 || settings.minimumDecimalPlaces > settings.roundToDecimalPlace ? settings.roundToDecimalPlace : settings.minimumDecimalPlaces);
		} else {
			settings.minimumDecimalPlaces = 0;
		}

		// validate parseType if it exists (for the 'asNumber' settings object graph)
		if (settings.hasOwnProperty('parseType'))
			settings.parseType = validateParseType(settings.parseType);

		// Generate regex for formatting
		settings.regexArithmetic = new RegExp("[^\\d\\.\\-]", "g");
		if (settings.symbol === '')
			settings.regex = new RegExp("[^\\d" + settings.decimalSymbol + "-]", "g");
		else {
			var symbol = settings.symbol.replace('$', '\\$').replace('.', '\\.');
			settings.regex = new RegExp(symbol + "|[^\\d" + settings.decimalSymbol + "-]", "g");
		}

		settings.regexGroupDigit = new RegExp("\\" + settings.digitGroupSymbol, "g");

		return settings;
	}

	function keyAllowed(ev, decPointCodes) {
		if (ev.which >= 48 && ev.which <= 57)
			return true;
		else if (ev.type == 'keypress' && ev.which == decPointCodes[0])
			return (ev.target.value.indexOf(String.fromCharCode(decPointCodes[0])) == -1);
		else if (ev.type == 'keypress') {
			if (ev.ctrlKey && ev.key.toUpperCase() == "A") return true;
			return (ev.which < 32 || (ev.which >= 33 && ev.which <= 40) || (decPointCodes[0] != -1 && ev.which == 46));
		} else if (ev.type == 'keyup') {
			if (ev.ctrlKey && ev.key.toUpperCase() == "A") return false;

			if(ev.which < 32 || (ev.which >= 33 && ev.which <= 40)) return false;

			if(decPointCodes[0] != -1) {
				switch (ev.which) {
					case 78: break; // N (Opera 9.63+ maps the "." from the number key section to the "N" key too!) (See: http://unixpapa.com/js/key.html search for ". Del")
					case decPointCodes[2]: break; // . number block (Opera 9.63+ maps the "." from the number block to the "N" key (78) !!!)
					case decPointCodes[1]: break; // .
					default: return true;
				}
			}

			return false;
		} else
			return true;
	}

	function getRegionOrCulture(region) {
		var regionInfo = $.formatCurrency.regions[region];
		if (regionInfo) {
			return regionInfo;
		}
		else {
			if (/(\w+)-(\w+)/g.test(region)) {
				var culture = region.replace(/(\w+)-(\w+)/g, "$1");
				return $.formatCurrency.regions[culture];
			}
		}
		// fallback to extend(null) (i.e. nothing)
		return null;
	}

	function validateParseType(parseType) {
		switch (parseType.toLowerCase()) {
			case 'int':
				return 'Int';
			case 'float':
				return 'Float';
			default:
				throw 'invalid parseType';
		}
	}

})(jQuery);
