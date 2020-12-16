(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.bJ.as === region.bl.as)
	{
		return 'on line ' + region.bJ.as;
	}
	return 'on lines ' + region.bJ.as + ' through ' + region.bl.as;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bX,
		impl.b5,
		impl.b3,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_enqueueEffects(managers, result.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		B: func(record.B),
		bb: record.bb,
		a6: record.a6
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.B;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.bb;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.a6) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bX,
		impl.b5,
		impl.b3,
		function(sendToApp, initialModel) {
			var view = impl.b6;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bX,
		impl.b5,
		impl.b3,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.a8 && impl.a8(sendToApp)
			var view = impl.b6;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.bP);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.b4) && (_VirtualDom_doc.title = title = doc.b4);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.b_;
	var onUrlRequest = impl.b$;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		a8: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.bC === next.bC
							&& curr.bp === next.bp
							&& curr.by.a === next.by.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		bX: function(flags)
		{
			return A3(impl.bX, flags, _Browser_getUrl(), key);
		},
		b6: impl.b6,
		b5: impl.b5,
		b3: impl.b3
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { bV: 'hidden', bR: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { bV: 'mozHidden', bR: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { bV: 'msHidden', bR: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { bV: 'webkitHidden', bR: 'webkitvisibilitychange' }
		: { bV: 'hidden', bR: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		bI: _Browser_getScene(),
		bN: {
			H: _Browser_window.pageXOffset,
			I: _Browser_window.pageYOffset,
			U: _Browser_doc.documentElement.clientWidth,
			Z: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		U: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		Z: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			bI: {
				U: node.scrollWidth,
				Z: node.scrollHeight
			},
			bN: {
				H: node.scrollLeft,
				I: node.scrollTop,
				U: node.clientWidth,
				Z: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			bI: _Browser_getScene(),
			bN: {
				H: x,
				I: y,
				U: _Browser_doc.documentElement.clientWidth,
				Z: _Browser_doc.documentElement.clientHeight
			},
			bT: {
				H: x + rect.left,
				I: y + rect.top,
				U: rect.width,
				Z: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}


// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.bZ) { flags += 'm'; }
	if (options.bQ) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$LT = 0;
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.b) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.e),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.e);
		} else {
			var treeLen = builder.b * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.g) : builder.g;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.b);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.e) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.e);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{g: nodeList, b: (len / $elm$core$Array$branchFactor) | 0, e: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = $elm$core$Basics$identity;
var $elm$url$Url$Http = 0;
var $elm$url$Url$Https = 1;
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {bo: fragment, bp: host, av: path, by: port_, bC: protocol, bD: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 1) {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		0,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		1,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = $elm$core$Basics$identity;
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return 0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0;
		return A2($elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			A2($elm$core$Task$map, toMessage, task));
	});
var $elm$browser$Browser$element = _Browser_element;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $author$project$Main$defaultDay = 16;
var $author$project$Main$defaultYear = 2020;
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $author$project$Ports$getData = _Platform_outgoingPort(
	'getData',
	function ($) {
		var a = $.a;
		var b = $.b;
		return A2(
			$elm$json$Json$Encode$list,
			$elm$core$Basics$identity,
			_List_fromArray(
				[
					$elm$json$Json$Encode$int(a),
					$elm$json$Json$Encode$int(b)
				]));
	});
var $author$project$Main$getData = function (model) {
	return $author$project$Ports$getData(
		_Utils_Tuple2(model.a, model.d));
};
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Main$initAnswers = _Utils_Tuple2($elm$core$Maybe$Nothing, $elm$core$Maybe$Nothing);
var $author$project$Main$initThinks = _Utils_Tuple2(false, false);
var $author$project$Main$initModel = {
	J: $author$project$Main$initAnswers,
	X: $elm$core$Maybe$Nothing,
	d: $author$project$Main$defaultDay,
	ao: false,
	ae: $author$project$Main$initThinks,
	a: $author$project$Main$defaultYear,
	ai: _List_fromArray(
		[
			{
			M: A2($elm$core$List$range, 1, 25),
			a: 2015
		},
			{
			M: A2($elm$core$List$range, 1, 25),
			a: 2016
		},
			{
			M: A2($elm$core$List$range, 1, $author$project$Main$defaultDay),
			a: $author$project$Main$defaultYear
		}
		])
};
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Main$newProblem = F2(
	function (year, day) {
		var year1 = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (y) {
					return _Utils_eq(y.a, year);
				},
				$author$project$Main$initModel.ai));
		var newYear = function () {
			if (!year1.$) {
				var y = year1.a;
				return y.a;
			} else {
				return $author$project$Main$defaultYear;
			}
		}();
		var year2 = $elm$core$List$head(
			A2(
				$elm$core$List$filter,
				function (y) {
					return _Utils_eq(y.a, newYear);
				},
				$author$project$Main$initModel.ai));
		var newDay = function () {
			if (!year2.$) {
				var y = year2.a;
				return A2($elm$core$List$member, day, y.M) ? day : A2(
					$elm$core$Maybe$withDefault,
					$author$project$Main$defaultDay,
					$elm$core$List$head(y.M));
			} else {
				return $author$project$Main$defaultDay;
			}
		}();
		return _Utils_update(
			$author$project$Main$initModel,
			{d: newDay, a: newYear});
	});
var $author$project$Main$init = function (flags) {
	var year = A2(
		$elm$core$Maybe$withDefault,
		$author$project$Main$defaultYear,
		$elm$core$String$toInt(flags.a));
	var day = A2(
		$elm$core$Maybe$withDefault,
		$author$project$Main$defaultDay,
		$elm$core$String$toInt(flags.d));
	var model = A2($author$project$Main$newProblem, year, day);
	return _Utils_Tuple2(
		model,
		$author$project$Main$getData(model));
};
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Main$Answer = function (a) {
	return {$: 3, a: a};
};
var $author$project$Main$NewData = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $author$project$Ports$newData = _Platform_incomingPort('newData', $elm$json$Json$Decode$string);
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $author$project$Ports$startAnswer = _Platform_incomingPort('startAnswer', $elm$json$Json$Decode$int);
var $author$project$Main$subscriptions = function (model) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				$author$project$Ports$newData($author$project$Main$NewData),
				$author$project$Ports$startAnswer($author$project$Main$Answer)
			]));
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $author$project$Y15D01$count = F2(
	function (floor, instructions) {
		count:
		while (true) {
			var next = $elm$core$String$uncons(instructions);
			_v0$2:
			while (true) {
				if (!next.$) {
					switch (next.a.a) {
						case '(':
							var _v1 = next.a;
							var remaining = _v1.b;
							var $temp$floor = floor + 1,
								$temp$instructions = remaining;
							floor = $temp$floor;
							instructions = $temp$instructions;
							continue count;
						case ')':
							var _v2 = next.a;
							var remaining = _v2.b;
							var $temp$floor = floor - 1,
								$temp$instructions = remaining;
							floor = $temp$floor;
							instructions = $temp$instructions;
							continue count;
						default:
							break _v0$2;
					}
				} else {
					break _v0$2;
				}
			}
			return floor;
		}
	});
var $author$project$Y15D01$position = F3(
	function (floor, step, instructions) {
		position:
		while (true) {
			if (floor < 0) {
				return step;
			} else {
				var next = $elm$core$String$uncons(instructions);
				_v0$2:
				while (true) {
					if (!next.$) {
						switch (next.a.a) {
							case '(':
								var _v1 = next.a;
								var remaining = _v1.b;
								var $temp$floor = floor + 1,
									$temp$step = step + 1,
									$temp$instructions = remaining;
								floor = $temp$floor;
								step = $temp$step;
								instructions = $temp$instructions;
								continue position;
							case ')':
								var _v2 = next.a;
								var remaining = _v2.b;
								var $temp$floor = floor - 1,
									$temp$step = step + 1,
									$temp$instructions = remaining;
								floor = $temp$floor;
								step = $temp$step;
								instructions = $temp$instructions;
								continue position;
							default:
								break _v0$2;
						}
					} else {
						break _v0$2;
					}
				}
				return step;
			}
		}
	});
var $author$project$Y15D01$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			A2($author$project$Y15D01$count, 0, input)) : $elm$core$String$fromInt(
			A3($author$project$Y15D01$position, 0, 0, input));
	});
var $elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var $elm$core$List$minimum = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(
			A3($elm$core$List$foldl, $elm$core$Basics$min, x, xs));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Y15D02$ribbon = F3(
	function (l, w, h) {
		var volume = (l * w) * h;
		var perimeters = _List_fromArray(
			[l + w, w + h, h + l]);
		var perimeter = A2(
			$elm$core$Maybe$withDefault,
			0,
			$elm$core$List$minimum(perimeters));
		return (2 * perimeter) + volume;
	});
var $elm$regex$Regex$Match = F4(
	function (match, index, number, submatches) {
		return {bq: index, bY: match, bu: number, b2: submatches};
	});
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{bQ: false, bZ: false},
		string);
};
var $elm$regex$Regex$never = _Regex_never;
var $author$project$Util$regex = function (str) {
	return A2(
		$elm$core$Maybe$withDefault,
		$elm$regex$Regex$never,
		$elm$regex$Regex$fromString(str));
};
var $elm$regex$Regex$split = _Regex_splitAtMost(_Regex_infinity);
var $elm$regex$Regex$find = _Regex_findAtMost(_Regex_infinity);
var $author$project$Y15D02$sumLine = F3(
	function (counter, line, count) {
		var number = $author$project$Util$regex('[1-9]\\d*');
		var dimensions = A2(
			$elm$core$List$map,
			$elm$core$Maybe$withDefault(0),
			A2(
				$elm$core$List$map,
				$elm$core$String$toInt,
				A2(
					$elm$core$List$map,
					function ($) {
						return $.bY;
					},
					A2($elm$regex$Regex$find, number, line))));
		var extra = function () {
			if (((dimensions.b && dimensions.b.b) && dimensions.b.b.b) && (!dimensions.b.b.b.b)) {
				var l = dimensions.a;
				var _v1 = dimensions.b;
				var w = _v1.a;
				var _v2 = _v1.b;
				var h = _v2.a;
				return A3(counter, l, w, h);
			} else {
				return 0;
			}
		}();
		return count + extra;
	});
var $author$project$Y15D02$sumInput = F2(
	function (counter, input) {
		var lines = A2(
			$elm$regex$Regex$split,
			$author$project$Util$regex('\n'),
			input);
		return A3(
			$elm$core$List$foldl,
			$author$project$Y15D02$sumLine(counter),
			0,
			lines);
	});
var $elm$core$List$sum = function (numbers) {
	return A3($elm$core$List$foldl, $elm$core$Basics$add, 0, numbers);
};
var $author$project$Y15D02$wrapping = F3(
	function (l, w, h) {
		var sides = _List_fromArray(
			[l * w, w * h, h * l]);
		var slack = A2(
			$elm$core$Maybe$withDefault,
			0,
			$elm$core$List$minimum(sides));
		var paper = 2 * $elm$core$List$sum(sides);
		return paper + slack;
	});
var $author$project$Y15D02$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			A2($author$project$Y15D02$sumInput, $author$project$Y15D02$wrapping, input)) : $elm$core$String$fromInt(
			A2($author$project$Y15D02$sumInput, $author$project$Y15D02$ribbon, input));
	});
var $author$project$Y15D03$errorSanta = function (err) {
	return {
		z: $elm$core$Maybe$Just(err),
		aA: true,
		H: 0,
		I: 0
	};
};
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = $elm$core$Array$bitMask & (index >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!_v0.$) {
				var subTree = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _v0.a;
				return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
			}
		}
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$get = F2(
	function (index, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
			A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
			A3($elm$core$Array$getHelp, startShift, index, tree)));
	});
var $elm$core$Array$length = function (_v0) {
	var len = _v0.a;
	return len;
};
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$setHelp = F4(
	function (shift, index, value, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (!_v0.$) {
			var subTree = _v0.a;
			var newSub = A4($elm$core$Array$setHelp, shift - $elm$core$Array$shiftStep, index, value, subTree);
			return A3(
				$elm$core$Elm$JsArray$unsafeSet,
				pos,
				$elm$core$Array$SubTree(newSub),
				tree);
		} else {
			var values = _v0.a;
			var newLeaf = A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, values);
			return A3(
				$elm$core$Elm$JsArray$unsafeSet,
				pos,
				$elm$core$Array$Leaf(newLeaf),
				tree);
		}
	});
var $elm$core$Array$set = F3(
	function (index, value, array) {
		var len = array.a;
		var startShift = array.b;
		var tree = array.c;
		var tail = array.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? array : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			tree,
			A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, tail)) : A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A4($elm$core$Array$setHelp, startShift, index, value, tree),
			tail));
	});
var $elm$core$String$cons = _String_cons;
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $author$project$Y15D03$updateSanta = F2(
	function (_char, santa) {
		switch (_char) {
			case '>':
				return _Utils_update(
					santa,
					{H: santa.H + 1});
			case '<':
				return _Utils_update(
					santa,
					{H: santa.H - 1});
			case '^':
				return _Utils_update(
					santa,
					{I: santa.I + 1});
			case 'v':
				return _Utils_update(
					santa,
					{I: santa.I - 1});
			case '\n':
				return _Utils_update(
					santa,
					{aA: true});
			default:
				return $author$project$Y15D03$errorSanta(
					'illegal instruction [' + ($elm$core$String$fromChar(_char) + ']'));
		}
	});
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $author$project$Y15D03$visit = F3(
	function (x, y, visited) {
		var key = $elm$core$String$fromInt(x) + ('|' + $elm$core$String$fromInt(y));
		return A3($elm$core$Dict$insert, key, true, visited);
	});
var $author$project$Y15D03$deliver = F2(
	function (model, instructions) {
		deliver:
		while (true) {
			if ($elm$core$String$isEmpty(instructions)) {
				return model;
			} else {
				var next = $elm$core$String$uncons(instructions);
				var index = model.aD % $elm$core$Array$length(model.ac);
				var santa = A2(
					$elm$core$Maybe$withDefault,
					$author$project$Y15D03$errorSanta(
						'illegal index [' + ($elm$core$String$fromInt(index) + ']')),
					A2($elm$core$Array$get, index, model.ac));
				var _v0 = function () {
					if (!next.$) {
						var _v2 = next.a;
						var c = _v2.a;
						var r = _v2.b;
						return _Utils_Tuple2(c, r);
					} else {
						return _Utils_Tuple2('*', '');
					}
				}();
				var _char = _v0.a;
				var remaining = _v0.b;
				var santa_ = A2($author$project$Y15D03$updateSanta, _char, santa);
				if (santa_.aA) {
					return _Utils_update(
						model,
						{z: santa.z});
				} else {
					var model_ = _Utils_update(
						model,
						{
							ac: A3($elm$core$Array$set, index, santa_, model.ac),
							aD: model.aD + 1,
							aH: A3($author$project$Y15D03$visit, santa_.H, santa_.I, model.aH)
						});
					var $temp$model = model_,
						$temp$instructions = remaining;
					model = $temp$model;
					instructions = $temp$instructions;
					continue deliver;
				}
			}
		}
	});
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $author$project$Y15D03$initSanta = {z: $elm$core$Maybe$Nothing, aA: false, H: 0, I: 0};
var $elm$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			$elm$core$Array$initialize,
			n,
			function (_v0) {
				return e;
			});
	});
var $author$project$Y15D03$initModel = function (n) {
	return {
		z: $elm$core$Maybe$Nothing,
		ac: A2($elm$core$Array$repeat, n, $author$project$Y15D03$initSanta),
		aD: 0,
		aH: A3($author$project$Y15D03$visit, 0, 0, $elm$core$Dict$empty)
	};
};
var $author$project$Y15D03$christmas = F2(
	function (n, input) {
		var model = A2(
			$author$project$Y15D03$deliver,
			$author$project$Y15D03$initModel(n),
			input);
		var _v0 = model.z;
		if (!_v0.$) {
			var err = _v0.a;
			return err;
		} else {
			return $elm$core$String$fromInt(
				$elm$core$List$length(
					$elm$core$Dict$keys(model.aH)));
		}
	});
var $author$project$Y15D03$answer = F2(
	function (part, input) {
		return (part === 1) ? A2($author$project$Y15D03$christmas, 1, input) : A2($author$project$Y15D03$christmas, 2, input);
	});
var $truqu$elm_md5$MD5$emptyWords = A2($elm$core$Array$repeat, 16, 0);
var $truqu$elm_md5$MD5$addUnsigned = F2(
	function (x, y) {
		return 4294967295 & (x + y);
	});
var $elm$core$Bitwise$or = _Bitwise_or;
var $truqu$elm_md5$MD5$rotateLeft = F2(
	function (bits, input) {
		return (input << bits) | (input >>> (32 - bits));
	});
var $truqu$elm_md5$MD5$cmn = F8(
	function (fun, a, b, c, d, x, s, ac) {
		return A2(
			$truqu$elm_md5$MD5$addUnsigned,
			b,
			A2(
				$truqu$elm_md5$MD5$rotateLeft,
				s,
				A2(
					$truqu$elm_md5$MD5$addUnsigned,
					a,
					A2(
						$truqu$elm_md5$MD5$addUnsigned,
						ac,
						A2(
							$truqu$elm_md5$MD5$addUnsigned,
							A3(fun, b, c, d),
							x)))));
	});
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $truqu$elm_md5$MD5$f = F3(
	function (x, y, z) {
		return z ^ (x & (y ^ z));
	});
var $truqu$elm_md5$MD5$ff = F7(
	function (a, b, c, d, x, s, ac) {
		return A8($truqu$elm_md5$MD5$cmn, $truqu$elm_md5$MD5$f, a, b, c, d, x, s, ac);
	});
var $truqu$elm_md5$MD5$g = F3(
	function (x, y, z) {
		return y ^ (z & (x ^ y));
	});
var $truqu$elm_md5$MD5$gg = F7(
	function (a, b, c, d, x, s, ac) {
		return A8($truqu$elm_md5$MD5$cmn, $truqu$elm_md5$MD5$g, a, b, c, d, x, s, ac);
	});
var $truqu$elm_md5$MD5$h = F3(
	function (x, y, z) {
		return z ^ (x ^ y);
	});
var $truqu$elm_md5$MD5$hh = F7(
	function (a, b, c, d, x, s, ac) {
		return A8($truqu$elm_md5$MD5$cmn, $truqu$elm_md5$MD5$h, a, b, c, d, x, s, ac);
	});
var $elm$core$Bitwise$complement = _Bitwise_complement;
var $truqu$elm_md5$MD5$i = F3(
	function (x, y, z) {
		return y ^ (x | (~z));
	});
var $truqu$elm_md5$MD5$ii = F7(
	function (a, b, c, d, x, s, ac) {
		return A8($truqu$elm_md5$MD5$cmn, $truqu$elm_md5$MD5$i, a, b, c, d, x, s, ac);
	});
var $truqu$elm_md5$MD5$hex_ = F2(
	function (xs, acc) {
		var a = acc.V;
		var b = acc.aJ;
		var c = acc.aK;
		var d = acc.aM;
		if ((((((((((((((((xs.b && xs.b.b) && xs.b.b.b) && xs.b.b.b.b) && xs.b.b.b.b.b) && xs.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b) && xs.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b) && (!xs.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b)) {
			var x0 = xs.a;
			var _v1 = xs.b;
			var x1 = _v1.a;
			var _v2 = _v1.b;
			var x2 = _v2.a;
			var _v3 = _v2.b;
			var x3 = _v3.a;
			var _v4 = _v3.b;
			var x4 = _v4.a;
			var _v5 = _v4.b;
			var x5 = _v5.a;
			var _v6 = _v5.b;
			var x6 = _v6.a;
			var _v7 = _v6.b;
			var x7 = _v7.a;
			var _v8 = _v7.b;
			var x8 = _v8.a;
			var _v9 = _v8.b;
			var x9 = _v9.a;
			var _v10 = _v9.b;
			var x10 = _v10.a;
			var _v11 = _v10.b;
			var x11 = _v11.a;
			var _v12 = _v11.b;
			var x12 = _v12.a;
			var _v13 = _v12.b;
			var x13 = _v13.a;
			var _v14 = _v13.b;
			var x14 = _v14.a;
			var _v15 = _v14.b;
			var x15 = _v15.a;
			var s44 = 21;
			var s43 = 15;
			var s42 = 10;
			var s41 = 6;
			var s34 = 23;
			var s33 = 16;
			var s32 = 11;
			var s31 = 4;
			var s24 = 20;
			var s23 = 14;
			var s22 = 9;
			var s21 = 5;
			var s14 = 22;
			var s13 = 17;
			var s12 = 12;
			var s11 = 7;
			var d00 = d;
			var c00 = c;
			var b00 = b;
			var a00 = a;
			var a01 = A7($truqu$elm_md5$MD5$ff, a00, b00, c00, d00, x0, s11, 3614090360);
			var d01 = A7($truqu$elm_md5$MD5$ff, d00, a01, b00, c00, x1, s12, 3905402710);
			var c01 = A7($truqu$elm_md5$MD5$ff, c00, d01, a01, b00, x2, s13, 606105819);
			var b01 = A7($truqu$elm_md5$MD5$ff, b00, c01, d01, a01, x3, s14, 3250441966);
			var a02 = A7($truqu$elm_md5$MD5$ff, a01, b01, c01, d01, x4, s11, 4118548399);
			var d02 = A7($truqu$elm_md5$MD5$ff, d01, a02, b01, c01, x5, s12, 1200080426);
			var c02 = A7($truqu$elm_md5$MD5$ff, c01, d02, a02, b01, x6, s13, 2821735955);
			var b02 = A7($truqu$elm_md5$MD5$ff, b01, c02, d02, a02, x7, s14, 4249261313);
			var a03 = A7($truqu$elm_md5$MD5$ff, a02, b02, c02, d02, x8, s11, 1770035416);
			var d03 = A7($truqu$elm_md5$MD5$ff, d02, a03, b02, c02, x9, s12, 2336552879);
			var c03 = A7($truqu$elm_md5$MD5$ff, c02, d03, a03, b02, x10, s13, 4294925233);
			var b03 = A7($truqu$elm_md5$MD5$ff, b02, c03, d03, a03, x11, s14, 2304563134);
			var a04 = A7($truqu$elm_md5$MD5$ff, a03, b03, c03, d03, x12, s11, 1804603682);
			var d04 = A7($truqu$elm_md5$MD5$ff, d03, a04, b03, c03, x13, s12, 4254626195);
			var c04 = A7($truqu$elm_md5$MD5$ff, c03, d04, a04, b03, x14, s13, 2792965006);
			var b04 = A7($truqu$elm_md5$MD5$ff, b03, c04, d04, a04, x15, s14, 1236535329);
			var a05 = A7($truqu$elm_md5$MD5$gg, a04, b04, c04, d04, x1, s21, 4129170786);
			var d05 = A7($truqu$elm_md5$MD5$gg, d04, a05, b04, c04, x6, s22, 3225465664);
			var c05 = A7($truqu$elm_md5$MD5$gg, c04, d05, a05, b04, x11, s23, 643717713);
			var b05 = A7($truqu$elm_md5$MD5$gg, b04, c05, d05, a05, x0, s24, 3921069994);
			var a06 = A7($truqu$elm_md5$MD5$gg, a05, b05, c05, d05, x5, s21, 3593408605);
			var d06 = A7($truqu$elm_md5$MD5$gg, d05, a06, b05, c05, x10, s22, 38016083);
			var c06 = A7($truqu$elm_md5$MD5$gg, c05, d06, a06, b05, x15, s23, 3634488961);
			var b06 = A7($truqu$elm_md5$MD5$gg, b05, c06, d06, a06, x4, s24, 3889429448);
			var a07 = A7($truqu$elm_md5$MD5$gg, a06, b06, c06, d06, x9, s21, 568446438);
			var d07 = A7($truqu$elm_md5$MD5$gg, d06, a07, b06, c06, x14, s22, 3275163606);
			var c07 = A7($truqu$elm_md5$MD5$gg, c06, d07, a07, b06, x3, s23, 4107603335);
			var b07 = A7($truqu$elm_md5$MD5$gg, b06, c07, d07, a07, x8, s24, 1163531501);
			var a08 = A7($truqu$elm_md5$MD5$gg, a07, b07, c07, d07, x13, s21, 2850285829);
			var d08 = A7($truqu$elm_md5$MD5$gg, d07, a08, b07, c07, x2, s22, 4243563512);
			var c08 = A7($truqu$elm_md5$MD5$gg, c07, d08, a08, b07, x7, s23, 1735328473);
			var b08 = A7($truqu$elm_md5$MD5$gg, b07, c08, d08, a08, x12, s24, 2368359562);
			var a09 = A7($truqu$elm_md5$MD5$hh, a08, b08, c08, d08, x5, s31, 4294588738);
			var d09 = A7($truqu$elm_md5$MD5$hh, d08, a09, b08, c08, x8, s32, 2272392833);
			var c09 = A7($truqu$elm_md5$MD5$hh, c08, d09, a09, b08, x11, s33, 1839030562);
			var b09 = A7($truqu$elm_md5$MD5$hh, b08, c09, d09, a09, x14, s34, 4259657740);
			var a10 = A7($truqu$elm_md5$MD5$hh, a09, b09, c09, d09, x1, s31, 2763975236);
			var d10 = A7($truqu$elm_md5$MD5$hh, d09, a10, b09, c09, x4, s32, 1272893353);
			var c10 = A7($truqu$elm_md5$MD5$hh, c09, d10, a10, b09, x7, s33, 4139469664);
			var b10 = A7($truqu$elm_md5$MD5$hh, b09, c10, d10, a10, x10, s34, 3200236656);
			var a11 = A7($truqu$elm_md5$MD5$hh, a10, b10, c10, d10, x13, s31, 681279174);
			var d11 = A7($truqu$elm_md5$MD5$hh, d10, a11, b10, c10, x0, s32, 3936430074);
			var c11 = A7($truqu$elm_md5$MD5$hh, c10, d11, a11, b10, x3, s33, 3572445317);
			var b11 = A7($truqu$elm_md5$MD5$hh, b10, c11, d11, a11, x6, s34, 76029189);
			var a12 = A7($truqu$elm_md5$MD5$hh, a11, b11, c11, d11, x9, s31, 3654602809);
			var d12 = A7($truqu$elm_md5$MD5$hh, d11, a12, b11, c11, x12, s32, 3873151461);
			var c12 = A7($truqu$elm_md5$MD5$hh, c11, d12, a12, b11, x15, s33, 530742520);
			var b12 = A7($truqu$elm_md5$MD5$hh, b11, c12, d12, a12, x2, s34, 3299628645);
			var a13 = A7($truqu$elm_md5$MD5$ii, a12, b12, c12, d12, x0, s41, 4096336452);
			var d13 = A7($truqu$elm_md5$MD5$ii, d12, a13, b12, c12, x7, s42, 1126891415);
			var c13 = A7($truqu$elm_md5$MD5$ii, c12, d13, a13, b12, x14, s43, 2878612391);
			var b13 = A7($truqu$elm_md5$MD5$ii, b12, c13, d13, a13, x5, s44, 4237533241);
			var a14 = A7($truqu$elm_md5$MD5$ii, a13, b13, c13, d13, x12, s41, 1700485571);
			var d14 = A7($truqu$elm_md5$MD5$ii, d13, a14, b13, c13, x3, s42, 2399980690);
			var c14 = A7($truqu$elm_md5$MD5$ii, c13, d14, a14, b13, x10, s43, 4293915773);
			var b14 = A7($truqu$elm_md5$MD5$ii, b13, c14, d14, a14, x1, s44, 2240044497);
			var a15 = A7($truqu$elm_md5$MD5$ii, a14, b14, c14, d14, x8, s41, 1873313359);
			var d15 = A7($truqu$elm_md5$MD5$ii, d14, a15, b14, c14, x15, s42, 4264355552);
			var c15 = A7($truqu$elm_md5$MD5$ii, c14, d15, a15, b14, x6, s43, 2734768916);
			var b15 = A7($truqu$elm_md5$MD5$ii, b14, c15, d15, a15, x13, s44, 1309151649);
			var a16 = A7($truqu$elm_md5$MD5$ii, a15, b15, c15, d15, x4, s41, 4149444226);
			var d16 = A7($truqu$elm_md5$MD5$ii, d15, a16, b15, c15, x11, s42, 3174756917);
			var c16 = A7($truqu$elm_md5$MD5$ii, c15, d16, a16, b15, x2, s43, 718787259);
			var b16 = A7($truqu$elm_md5$MD5$ii, b15, c16, d16, a16, x9, s44, 3951481745);
			var b17 = A2($truqu$elm_md5$MD5$addUnsigned, b00, b16);
			var c17 = A2($truqu$elm_md5$MD5$addUnsigned, c00, c16);
			var d17 = A2($truqu$elm_md5$MD5$addUnsigned, d00, d16);
			var a17 = A2($truqu$elm_md5$MD5$addUnsigned, a00, a16);
			return {V: a17, aJ: b17, aK: c17, aM: d17};
		} else {
			return acc;
		}
	});
var $truqu$elm_md5$MD5$iget = F2(
	function (index, array) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Array$get, index, array));
	});
var $truqu$elm_md5$MD5$consume = F2(
	function (_char, _v0) {
		var hashState = _v0.a;
		var _v1 = _v0.b;
		var byteCount = _v1.a;
		var words = _v1.b;
		var totalByteCount = _v0.c;
		var wordCount = (byteCount / 4) | 0;
		var oldWord = A2($truqu$elm_md5$MD5$iget, wordCount, words);
		var bytePosition = 8 * (byteCount % 4);
		var code = _char << bytePosition;
		var newWord = oldWord | code;
		var newWords = A3($elm$core$Array$set, wordCount, newWord, words);
		return (byteCount === 63) ? _Utils_Tuple3(
			A2(
				$truqu$elm_md5$MD5$hex_,
				$elm$core$Array$toList(newWords),
				hashState),
			_Utils_Tuple2(0, $truqu$elm_md5$MD5$emptyWords),
			totalByteCount + 1) : _Utils_Tuple3(
			hashState,
			_Utils_Tuple2(byteCount + 1, newWords),
			totalByteCount + 1);
	});
var $truqu$elm_md5$MD5$finishUp = function (_v0) {
	var hashState = _v0.a;
	var _v1 = _v0.b;
	var byteCount = _v1.a;
	var words = _v1.b;
	var totalByteCount = _v0.c;
	var wordCount = (byteCount / 4) | 0;
	var oldWord = A2($truqu$elm_md5$MD5$iget, wordCount, words);
	var bytePosition = 8 * (byteCount % 4);
	var code = 128 << bytePosition;
	var newWord = oldWord | code;
	var newWords = A3($elm$core$Array$set, wordCount, newWord, words);
	return (wordCount < 14) ? function (x) {
		return A2($truqu$elm_md5$MD5$hex_, x, hashState);
	}(
		$elm$core$Array$toList(
			A3(
				$elm$core$Array$set,
				15,
				totalByteCount >>> 29,
				A3($elm$core$Array$set, 14, totalByteCount << 3, newWords)))) : function (x) {
		return A2(
			$truqu$elm_md5$MD5$hex_,
			x,
			A2(
				$truqu$elm_md5$MD5$hex_,
				$elm$core$Array$toList(newWords),
				hashState));
	}(
		$elm$core$Array$toList(
			A3(
				$elm$core$Array$set,
				15,
				totalByteCount >>> 29,
				A3($elm$core$Array$set, 14, totalByteCount << 3, $truqu$elm_md5$MD5$emptyWords))));
};
var $elm$core$String$foldl = _String_foldl;
var $zwilias$elm_utf_tools$String$UTF8$utf32ToUtf8 = F3(
	function (add, _char, acc) {
		return (_char < 128) ? A2(add, _char, acc) : ((_char < 2048) ? A2(
			add,
			128 | (63 & _char),
			A2(add, 192 | (_char >>> 6), acc)) : ((_char < 65536) ? A2(
			add,
			128 | (63 & _char),
			A2(
				add,
				128 | (63 & (_char >>> 6)),
				A2(add, 224 | (_char >>> 12), acc))) : A2(
			add,
			128 | (63 & _char),
			A2(
				add,
				128 | (63 & (_char >>> 6)),
				A2(
					add,
					128 | (63 & (_char >>> 12)),
					A2(add, 240 | (_char >>> 18), acc))))));
	});
var $zwilias$elm_utf_tools$String$UTF8$foldl = F3(
	function (op, initialAcc, input) {
		return A3(
			$elm$core$String$foldl,
			F2(
				function (_char, acc) {
					return A3(
						$zwilias$elm_utf_tools$String$UTF8$utf32ToUtf8,
						op,
						$elm$core$Char$toCode(_char),
						acc);
				}),
			initialAcc,
			input);
	});
var $truqu$elm_md5$MD5$State = F4(
	function (a, b, c, d) {
		return {V: a, aJ: b, aK: c, aM: d};
	});
var $truqu$elm_md5$MD5$initialHashState = A4($truqu$elm_md5$MD5$State, 1732584193, 4023233417, 2562383102, 271733878);
var $truqu$elm_md5$MD5$hash = function (input) {
	return $truqu$elm_md5$MD5$finishUp(
		A3(
			$zwilias$elm_utf_tools$String$UTF8$foldl,
			$truqu$elm_md5$MD5$consume,
			_Utils_Tuple3(
				$truqu$elm_md5$MD5$initialHashState,
				_Utils_Tuple2(0, $truqu$elm_md5$MD5$emptyWords),
				0),
			input));
};
var $truqu$elm_md5$MD5$bytes = function (string) {
	var _v0 = $truqu$elm_md5$MD5$hash(string);
	var a = _v0.V;
	var b = _v0.aJ;
	var c = _v0.aK;
	var d = _v0.aM;
	return _List_fromArray(
		[a & 255, (a >>> 8) & 255, (a >>> 16) & 255, (a >>> 24) & 255, b & 255, (b >>> 8) & 255, (b >>> 16) & 255, (b >>> 24) & 255, c & 255, (c >>> 8) & 255, (c >>> 16) & 255, (c >>> 24) & 255, d & 255, (d >>> 8) & 255, (d >>> 16) & 255, (d >>> 24) & 255]);
};
var $elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var $elm$core$String$repeatHelp = F3(
	function (n, chunk, result) {
		return (n <= 0) ? result : A3(
			$elm$core$String$repeatHelp,
			n >> 1,
			_Utils_ap(chunk, chunk),
			(!(n & 1)) ? result : _Utils_ap(result, chunk));
	});
var $elm$core$String$repeat = F2(
	function (n, chunk) {
		return A3($elm$core$String$repeatHelp, n, chunk, '');
	});
var $elm$core$String$padLeft = F3(
	function (n, _char, string) {
		return _Utils_ap(
			A2(
				$elm$core$String$repeat,
				n - $elm$core$String$length(string),
				$elm$core$String$fromChar(_char)),
			string);
	});
var $truqu$elm_md5$MD5$toHex = function (_byte) {
	switch (_byte) {
		case 0:
			return '0';
		case 1:
			return '1';
		case 2:
			return '2';
		case 3:
			return '3';
		case 4:
			return '4';
		case 5:
			return '5';
		case 6:
			return '6';
		case 7:
			return '7';
		case 8:
			return '8';
		case 9:
			return '9';
		case 10:
			return 'a';
		case 11:
			return 'b';
		case 12:
			return 'c';
		case 13:
			return 'd';
		case 14:
			return 'e';
		case 15:
			return 'f';
		default:
			return _Utils_ap(
				$truqu$elm_md5$MD5$toHex((_byte / 16) | 0),
				$truqu$elm_md5$MD5$toHex(_byte % 16));
	}
};
var $truqu$elm_md5$MD5$hex = function (s) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (b, acc) {
				return _Utils_ap(
					acc,
					A3(
						$elm$core$String$padLeft,
						2,
						'0',
						$truqu$elm_md5$MD5$toHex(b)));
			}),
		'',
		$truqu$elm_md5$MD5$bytes(s));
};
var $author$project$Y15D04$find = F3(
	function (step, start, key) {
		find:
		while (true) {
			var hash = $truqu$elm_md5$MD5$hex(
				_Utils_ap(
					key,
					$elm$core$String$fromInt(step)));
			if (A2($elm$core$String$startsWith, start, hash)) {
				return step;
			} else {
				var $temp$step = step + 1,
					$temp$start = start,
					$temp$key = key;
				step = $temp$step;
				start = $temp$start;
				key = $temp$key;
				continue find;
			}
		}
	});
var $elm$regex$Regex$findAtMost = _Regex_findAtMost;
var $author$project$Y15D04$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'no secret key found',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('[a-z]+'),
					input))));
};
var $author$project$Y15D04$answer = F2(
	function (part, input) {
		var key = $author$project$Y15D04$parse(input);
		var a1 = A3($author$project$Y15D04$find, 1, '00000', key);
		return (part === 1) ? $elm$core$String$fromInt(a1) : $elm$core$String$fromInt(
			A3($author$project$Y15D04$find, a1, '000000', key));
	});
var $author$project$Y15D05$countNice = F2(
	function (nice, strings) {
		return $elm$core$String$fromInt(
			$elm$core$List$length(
				A2($elm$core$List$filter, nice, strings)));
	});
var $author$project$Y15D05$badieRgx = $author$project$Util$regex('(:?ab|cd|pq|xy)');
var $author$project$Y15D05$count = F2(
	function (rgx, string) {
		return $elm$core$List$length(
			A2($elm$regex$Regex$find, rgx, string));
	});
var $author$project$Y15D05$dubleRgx = $author$project$Util$regex('(.)\\1');
var $author$project$Y15D05$vowelRgx = $author$project$Util$regex('[aeiou]');
var $author$project$Y15D05$nice1 = function (string) {
	var vowels = A2($author$project$Y15D05$count, $author$project$Y15D05$vowelRgx, string);
	var dubles = A2($author$project$Y15D05$count, $author$project$Y15D05$dubleRgx, string);
	var badies = A2($author$project$Y15D05$count, $author$project$Y15D05$badieRgx, string);
	return (vowels >= 3) && ((dubles > 0) && (!badies));
};
var $author$project$Y15D05$pairsRgx = $author$project$Util$regex('(..).*\\1');
var $author$project$Y15D05$twipsRgx = $author$project$Util$regex('(.).\\1');
var $author$project$Y15D05$nice2 = function (string) {
	var twips = A2($author$project$Y15D05$count, $author$project$Y15D05$twipsRgx, string);
	var pairs = A2($author$project$Y15D05$count, $author$project$Y15D05$pairsRgx, string);
	return (pairs > 0) && (twips > 0);
};
var $author$project$Y15D05$stringRgx = $author$project$Util$regex('[a-z]{10,}');
var $author$project$Y15D05$answer = F2(
	function (part, input) {
		var strings = A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2($elm$regex$Regex$find, $author$project$Y15D05$stringRgx, input));
		return (part === 1) ? A2($author$project$Y15D05$countNice, $author$project$Y15D05$nice1, strings) : A2($author$project$Y15D05$countNice, $author$project$Y15D05$nice2, strings);
	});
var $author$project$Y15D06$initModel = _Utils_Tuple2(
	A2($elm$core$Array$repeat, 1000000, 0),
	A2($elm$core$Array$repeat, 1000000, 0));
var $author$project$Y15D06$Toggle = 0;
var $author$project$Y15D06$badInstruction = {
	aj: 0,
	m: _Utils_Tuple2(1, 1),
	w: _Utils_Tuple2(0, 0)
};
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Y15D06$Off = 2;
var $author$project$Y15D06$On = 1;
var $author$project$Y15D06$parseInstruction = function (submatches) {
	if ((((((((((submatches.b && (!submatches.a.$)) && submatches.b.b) && (!submatches.b.a.$)) && submatches.b.b.b) && (!submatches.b.b.a.$)) && submatches.b.b.b.b) && (!submatches.b.b.b.a.$)) && submatches.b.b.b.b.b) && (!submatches.b.b.b.b.a.$)) && (!submatches.b.b.b.b.b.b)) {
		var a__ = submatches.a.a;
		var _v1 = submatches.b;
		var fx__ = _v1.a.a;
		var _v2 = _v1.b;
		var fy__ = _v2.a.a;
		var _v3 = _v2.b;
		var tx__ = _v3.a.a;
		var _v4 = _v3.b;
		var ty__ = _v4.a.a;
		var ty_ = $elm$core$String$toInt(ty__);
		var tx_ = $elm$core$String$toInt(tx__);
		var fy_ = $elm$core$String$toInt(fy__);
		var fx_ = $elm$core$String$toInt(fx__);
		var a_ = function () {
			switch (a__) {
				case 'toggle':
					return $elm$core$Maybe$Just(0);
				case 'turn on':
					return $elm$core$Maybe$Just(1);
				case 'turn off':
					return $elm$core$Maybe$Just(2);
				default:
					return $elm$core$Maybe$Nothing;
			}
		}();
		if (!a_.$) {
			var a = a_.a;
			var _v6 = _List_fromArray(
				[fx_, fy_, tx_, ty_]);
			if ((((((((_v6.b && (!_v6.a.$)) && _v6.b.b) && (!_v6.b.a.$)) && _v6.b.b.b) && (!_v6.b.b.a.$)) && _v6.b.b.b.b) && (!_v6.b.b.b.a.$)) && (!_v6.b.b.b.b.b)) {
				var fx = _v6.a.a;
				var _v7 = _v6.b;
				var fy = _v7.a.a;
				var _v8 = _v7.b;
				var tx = _v8.a.a;
				var _v9 = _v8.b;
				var ty = _v9.a.a;
				return ((fx >= 0) && ((fy >= 0) && ((_Utils_cmp(fx, tx) < 1) && ((_Utils_cmp(fy, ty) < 1) && ((tx < 1000) && (ty < 1000)))))) ? {
					aj: a,
					m: _Utils_Tuple2(fx, fy),
					w: _Utils_Tuple2(tx, ty)
				} : $author$project$Y15D06$badInstruction;
			} else {
				return $author$project$Y15D06$badInstruction;
			}
		} else {
			return $author$project$Y15D06$badInstruction;
		}
	} else {
		return $author$project$Y15D06$badInstruction;
	}
};
var $author$project$Y15D06$parse = function (input) {
	var rgx = $author$project$Util$regex('(toggle|turn (?:on|off)) (\\d+),(\\d+) through (\\d+),(\\d+)');
	return A2(
		$elm$core$List$filter,
		function (i) {
			return !_Utils_eq(i, $author$project$Y15D06$badInstruction);
		},
		A2(
			$elm$core$List$map,
			$author$project$Y15D06$parseInstruction,
			A2(
				$elm$core$List$map,
				function ($) {
					return $.b2;
				},
				A2($elm$regex$Regex$find, rgx, input))));
};
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $author$project$Y15D06$index = function (instruction) {
	var y = instruction.m.b;
	var x = instruction.m.a;
	return x + (1000 * y);
};
var $author$project$Y15D06$updateCell = F2(
	function (instruction, lights) {
		var l2 = lights.b;
		var l1 = lights.a;
		var k = $author$project$Y15D06$index(instruction);
		var v1 = A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Array$get, k, l1));
		var v1_ = function () {
			var _v1 = instruction.aj;
			switch (_v1) {
				case 0:
					return (v1 === 1) ? 0 : 1;
				case 1:
					return 1;
				default:
					return 0;
			}
		}();
		var v2 = A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Array$get, k, l2));
		var v2_ = function () {
			var _v0 = instruction.aj;
			switch (_v0) {
				case 0:
					return v2 + 2;
				case 1:
					return v2 + 1;
				default:
					return (!v2) ? 0 : (v2 - 1);
			}
		}();
		return _Utils_Tuple2(
			A3($elm$core$Array$set, k, v1_, l1),
			A3($elm$core$Array$set, k, v2_, l2));
	});
var $author$project$Y15D06$updateCol = F2(
	function (instruction, lights) {
		updateCol:
		while (true) {
			var ty = instruction.w.b;
			var lights_ = A2($author$project$Y15D06$updateCell, instruction, lights);
			var fy = instruction.m.b;
			if (_Utils_eq(fy, ty)) {
				return lights_;
			} else {
				var tx = instruction.w.a;
				var fx = instruction.m.a;
				var instruction_ = _Utils_update(
					instruction,
					{
						m: _Utils_Tuple2(fx, fy + 1),
						w: _Utils_Tuple2(tx, ty)
					});
				var $temp$instruction = instruction_,
					$temp$lights = lights_;
				instruction = $temp$instruction;
				lights = $temp$lights;
				continue updateCol;
			}
		}
	});
var $author$project$Y15D06$updateRow = F2(
	function (instruction, lights) {
		updateRow:
		while (true) {
			var tx = instruction.w.a;
			var lights_ = A2($author$project$Y15D06$updateCol, instruction, lights);
			var fx = instruction.m.a;
			if (_Utils_eq(fx, tx)) {
				return lights_;
			} else {
				var ty = instruction.w.b;
				var fy = instruction.m.b;
				var instruction_ = _Utils_update(
					instruction,
					{
						m: _Utils_Tuple2(fx + 1, fy),
						w: _Utils_Tuple2(tx, ty)
					});
				var $temp$instruction = instruction_,
					$temp$lights = lights_;
				instruction = $temp$instruction;
				lights = $temp$lights;
				continue updateRow;
			}
		}
	});
var $author$project$Y15D06$process = F2(
	function (instructions, lights) {
		process:
		while (true) {
			if (!instructions.b) {
				return lights;
			} else {
				var instruction = instructions.a;
				var rest = instructions.b;
				var lights_ = A2($author$project$Y15D06$updateRow, instruction, lights);
				var $temp$instructions = rest,
					$temp$lights = lights_;
				instructions = $temp$instructions;
				lights = $temp$lights;
				continue process;
			}
		}
	});
var $author$project$Y15D06$answer = F2(
	function (part, input) {
		var instructions = $author$project$Y15D06$parse(input);
		var model = A2($author$project$Y15D06$process, instructions, $author$project$Y15D06$initModel);
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$List$length(
				A2(
					$elm$core$List$filter,
					function (l) {
						return l === 1;
					},
					$elm$core$Array$toList(model.a)))) : $elm$core$String$fromInt(
			$elm$core$List$sum(
				$elm$core$Array$toList(model.b)));
	});
var $author$project$Y15D07$NoOp = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $author$project$Y15D07$getVal = F2(
	function (wire, circuit) {
		var val = A2($elm$core$Dict$get, wire, circuit);
		if (val.$ === 1) {
			return 0;
		} else {
			var action = val.a;
			if (!action.$) {
				var i = action.a;
				return i;
			} else {
				return 0;
			}
		}
	});
var $author$project$Y15D07$And = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$Y15D07$Lshift = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $author$project$Y15D07$Not = function (a) {
	return {$: 6, a: a};
};
var $author$project$Y15D07$Or = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $author$project$Y15D07$Pass = function (a) {
	return {$: 1, a: a};
};
var $author$project$Y15D07$Rshift = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var $author$project$Y15D07$parseInt = function (i) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(i));
};
var $author$project$Y15D07$parseConnection = function (connection) {
	var words = A2($elm$core$String$split, ' ', connection);
	_v0$6:
	while (true) {
		if ((words.b && words.b.b) && words.b.b.b) {
			if (!words.b.b.b.b) {
				if (words.b.a === '->') {
					var from = words.a;
					var _v1 = words.b;
					var _v2 = _v1.b;
					var to = _v2.a;
					return _Utils_Tuple2(
						to,
						$author$project$Y15D07$Pass(from));
				} else {
					break _v0$6;
				}
			} else {
				if (words.b.b.b.b.b) {
					if ((words.b.b.b.a === '->') && (!words.b.b.b.b.b.b)) {
						switch (words.b.a) {
							case 'AND':
								var w1 = words.a;
								var _v3 = words.b;
								var _v4 = _v3.b;
								var w2 = _v4.a;
								var _v5 = _v4.b;
								var _v6 = _v5.b;
								var to = _v6.a;
								return _Utils_Tuple2(
									to,
									A2($author$project$Y15D07$And, w1, w2));
							case 'OR':
								var w1 = words.a;
								var _v7 = words.b;
								var _v8 = _v7.b;
								var w2 = _v8.a;
								var _v9 = _v8.b;
								var _v10 = _v9.b;
								var to = _v10.a;
								return _Utils_Tuple2(
									to,
									A2($author$project$Y15D07$Or, w1, w2));
							case 'LSHIFT':
								var w = words.a;
								var _v11 = words.b;
								var _v12 = _v11.b;
								var i = _v12.a;
								var _v13 = _v12.b;
								var _v14 = _v13.b;
								var to = _v14.a;
								return _Utils_Tuple2(
									to,
									A2(
										$author$project$Y15D07$Lshift,
										w,
										$author$project$Y15D07$parseInt(i)));
							case 'RSHIFT':
								var w = words.a;
								var _v15 = words.b;
								var _v16 = _v15.b;
								var i = _v16.a;
								var _v17 = _v16.b;
								var _v18 = _v17.b;
								var to = _v18.a;
								return _Utils_Tuple2(
									to,
									A2(
										$author$project$Y15D07$Rshift,
										w,
										$author$project$Y15D07$parseInt(i)));
							default:
								break _v0$6;
						}
					} else {
						break _v0$6;
					}
				} else {
					if ((words.a === 'NOT') && (words.b.b.a === '->')) {
						var _v19 = words.b;
						var w = _v19.a;
						var _v20 = _v19.b;
						var _v21 = _v20.b;
						var to = _v21.a;
						return _Utils_Tuple2(
							to,
							$author$project$Y15D07$Not(w));
					} else {
						break _v0$6;
					}
				}
			}
		} else {
			break _v0$6;
		}
	}
	return _Utils_Tuple2(
		connection,
		$author$project$Y15D07$NoOp(0));
};
var $author$project$Y15D07$parseLines = F2(
	function (lines, circuit) {
		parseLines:
		while (true) {
			if (!lines.b) {
				return circuit;
			} else {
				var connection = lines.a;
				var rest = lines.b;
				var _v1 = $author$project$Y15D07$parseConnection(connection);
				var wire = _v1.a;
				var action = _v1.b;
				var circuit_ = A3($elm$core$Dict$insert, wire, action, circuit);
				if ((wire === '') && _Utils_eq(
					action,
					$author$project$Y15D07$NoOp(0))) {
					var $temp$lines = rest,
						$temp$circuit = circuit;
					lines = $temp$lines;
					circuit = $temp$circuit;
					continue parseLines;
				} else {
					var $temp$lines = rest,
						$temp$circuit = circuit_;
					lines = $temp$lines;
					circuit = $temp$circuit;
					continue parseLines;
				}
			}
		}
	});
var $author$project$Y15D07$parseInput = function (input) {
	return A2(
		$author$project$Y15D07$parseLines,
		A2($elm$core$String$split, '\n', input),
		$elm$core$Dict$empty);
};
var $author$project$Y15D07$maxValue = 65535;
var $author$project$Y15D07$reduce = F2(
	function (wire, circuit) {
		var val = A2($elm$core$Dict$get, wire, circuit);
		if (val.$ === 1) {
			return A3(
				$elm$core$Dict$insert,
				wire,
				$author$project$Y15D07$NoOp(0),
				circuit);
		} else {
			var action = val.a;
			var _v7 = function () {
				switch (action.$) {
					case 0:
						var i = action.a;
						return _Utils_Tuple3(i, circuit, false);
					case 1:
						var w = action.a;
						var _v9 = A2($author$project$Y15D07$reduce1, w, circuit);
						var i = _v9.a;
						var c = _v9.b;
						return _Utils_Tuple3(i, c, true);
					case 2:
						var w1 = action.a;
						var w2 = action.b;
						var _v10 = A3($author$project$Y15D07$reduce2, w1, w2, circuit);
						var i = _v10.a;
						var j = _v10.b;
						var c = _v10.c;
						return _Utils_Tuple3(i & j, c, true);
					case 3:
						var w1 = action.a;
						var w2 = action.b;
						var _v11 = A3($author$project$Y15D07$reduce2, w1, w2, circuit);
						var i = _v11.a;
						var j = _v11.b;
						var c = _v11.c;
						return _Utils_Tuple3(i | j, c, true);
					case 4:
						var w = action.a;
						var i = action.b;
						var _v12 = A2($author$project$Y15D07$reduce1, w, circuit);
						var j = _v12.a;
						var c = _v12.b;
						var l = j << i;
						return _Utils_Tuple3(l, c, true);
					case 5:
						var w = action.a;
						var i = action.b;
						var _v13 = A2($author$project$Y15D07$reduce1, w, circuit);
						var j = _v13.a;
						var c = _v13.b;
						return _Utils_Tuple3(j >> i, c, true);
					default:
						var w = action.a;
						var _v14 = A2($author$project$Y15D07$reduce1, w, circuit);
						var i = _v14.a;
						var c = _v14.b;
						var j = ~i;
						var l = (j < 0) ? (($author$project$Y15D07$maxValue + j) + 1) : j;
						return _Utils_Tuple3(l, c, true);
				}
			}();
			var k = _v7.a;
			var circuit_ = _v7.b;
			var insert = _v7.c;
			return insert ? A3(
				$elm$core$Dict$insert,
				wire,
				$author$project$Y15D07$NoOp(k),
				circuit_) : circuit_;
		}
	});
var $author$project$Y15D07$reduce1 = F2(
	function (w, circuit) {
		var i = $elm$core$String$toInt(w);
		if (!i.$) {
			var j = i.a;
			return _Utils_Tuple2(j, circuit);
		} else {
			var circuit_ = A2($author$project$Y15D07$reduce, w, circuit);
			return _Utils_Tuple2(
				A2($author$project$Y15D07$getVal, w, circuit_),
				circuit_);
		}
	});
var $author$project$Y15D07$reduce2 = F3(
	function (w1, w2, circuit) {
		var i2 = $elm$core$String$toInt(w2);
		var i1 = $elm$core$String$toInt(w1);
		var _v0 = _Utils_Tuple2(i1, i2);
		if (!_v0.a.$) {
			if (!_v0.b.$) {
				var j1 = _v0.a.a;
				var j2 = _v0.b.a;
				return _Utils_Tuple3(j1, j2, circuit);
			} else {
				var j1 = _v0.a.a;
				var _v1 = _v0.b;
				var circuit_ = A2($author$project$Y15D07$reduce, w2, circuit);
				return _Utils_Tuple3(
					j1,
					A2($author$project$Y15D07$getVal, w2, circuit_),
					circuit_);
			}
		} else {
			if (!_v0.b.$) {
				var _v2 = _v0.a;
				var j2 = _v0.b.a;
				var circuit_ = A2($author$project$Y15D07$reduce, w1, circuit);
				return _Utils_Tuple3(
					A2($author$project$Y15D07$getVal, w1, circuit_),
					j2,
					circuit_);
			} else {
				var _v3 = _v0.a;
				var _v4 = _v0.b;
				var circuit_ = A2($author$project$Y15D07$reduce, w1, circuit);
				var circuit__ = A2($author$project$Y15D07$reduce, w2, circuit_);
				return _Utils_Tuple3(
					A2($author$project$Y15D07$getVal, w1, circuit_),
					A2($author$project$Y15D07$getVal, w2, circuit__),
					circuit__);
			}
		}
	});
var $author$project$Y15D07$answer = F2(
	function (part, input) {
		var circuit = $author$project$Y15D07$parseInput(input);
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$author$project$Y15D07$getVal,
				'a',
				A2($author$project$Y15D07$reduce, 'a', circuit))) : $elm$core$String$fromInt(
			A2(
				$author$project$Y15D07$getVal,
				'a',
				A2(
					$author$project$Y15D07$reduce,
					'a',
					A3(
						$elm$core$Dict$insert,
						'b',
						$author$project$Y15D07$NoOp(3176),
						circuit))));
	});
var $author$project$Y15D08$chrLength = function (lines) {
	return $elm$core$List$sum(
		A2($elm$core$List$map, $elm$core$String$length, lines));
};
var $elm$regex$Regex$replace = _Regex_replaceAtMost(_Regex_infinity);
var $author$project$Y15D08$escape = function (line) {
	var r1 = A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('\\\\'),
		function (_v1) {
			return '\\\\';
		},
		line);
	var r2 = A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('\"'),
		function (_v0) {
			return '\\\"';
		},
		r1);
	var r3 = '\"' + (r2 + '\"');
	return r3;
};
var $author$project$Y15D08$escLength = function (lines) {
	return $elm$core$List$sum(
		A2(
			$elm$core$List$map,
			$elm$core$String$length,
			A2($elm$core$List$map, $author$project$Y15D08$escape, lines)));
};
var $author$project$Y15D08$unescape = function (line) {
	var r1 = A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('(^\"|\"$)'),
		function (_v3) {
			return '';
		},
		line);
	var r2 = A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('\\\\\"'),
		function (_v2) {
			return '_';
		},
		r1);
	var r3 = A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('\\\\\\\\'),
		function (_v1) {
			return '.';
		},
		r2);
	var r4 = A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('\\\\x[0-9a-f]{2}'),
		function (_v0) {
			return '-';
		},
		r3);
	return r4;
};
var $author$project$Y15D08$memLength = function (lines) {
	return $elm$core$List$sum(
		A2(
			$elm$core$List$map,
			$elm$core$String$length,
			A2($elm$core$List$map, $author$project$Y15D08$unescape, lines)));
};
var $author$project$Y15D08$parseInput = function (input) {
	return A2(
		$elm$core$List$filter,
		function (l) {
			return l !== '';
		},
		A2($elm$core$String$split, '\n', input));
};
var $author$project$Y15D08$answer = F2(
	function (part, input) {
		var strings = $author$project$Y15D08$parseInput(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y15D08$chrLength(strings) - $author$project$Y15D08$memLength(strings)) : $elm$core$String$fromInt(
			$author$project$Y15D08$escLength(strings) - $author$project$Y15D08$chrLength(strings));
	});
var $author$project$Y15D09$key = F2(
	function (c1, c2) {
		return c1 + ('|' + c2);
	});
var $author$project$Y15D09$pairs = function (list) {
	if (!list.b) {
		return _List_Nil;
	} else {
		if (!list.b.b) {
			var x = list.a;
			return _List_Nil;
		} else {
			var x = list.a;
			var _v1 = list.b;
			var y = _v1.a;
			var rest = _v1.b;
			return A2(
				$elm$core$List$cons,
				_Utils_Tuple2(x, y),
				$author$project$Y15D09$pairs(
					A2($elm$core$List$cons, y, rest)));
		}
	}
};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $author$project$Util$select = function (s) {
	if (!s.b) {
		return _List_Nil;
	} else {
		var x = s.a;
		var xs = s.b;
		return A2(
			$elm$core$List$cons,
			_Utils_Tuple2(x, xs),
			A2(
				$elm$core$List$map,
				function (_v1) {
					var y = _v1.a;
					var ys = _v1.b;
					return _Utils_Tuple2(
						y,
						A2($elm$core$List$cons, x, ys));
				},
				$author$project$Util$select(xs)));
	}
};
var $author$project$Util$permutations = function (xs) {
	if (!xs.b) {
		return _List_fromArray(
			[_List_Nil]);
	} else {
		var xss = xs;
		var f = function (_v1) {
			var y = _v1.a;
			var ys = _v1.b;
			return A2(
				$elm$core$List$map,
				$elm$core$List$cons(y),
				$author$project$Util$permutations(ys));
		};
		return A2(
			$elm$core$List$concatMap,
			f,
			$author$project$Util$select(xss));
	}
};
var $author$project$Y15D09$extreme = function (model) {
	var f = function (_v0) {
		var c1 = _v0.a;
		var c2 = _v0.b;
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2(
				$elm$core$Dict$get,
				A2($author$project$Y15D09$key, c1, c2),
				model.an));
	};
	return A2(
		$elm$core$List$map,
		function (p) {
			return $elm$core$List$sum(
				A2($elm$core$List$map, f, p));
		},
		A2(
			$elm$core$List$map,
			function (perm) {
				return $author$project$Y15D09$pairs(perm);
			},
			$author$project$Util$permutations(model.L)));
};
var $elm$core$List$maximum = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(
			A3($elm$core$List$foldl, $elm$core$Basics$max, x, xs));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Y15D09$initModel = {L: _List_Nil, an: $elm$core$Dict$empty};
var $author$project$Y15D09$parseLine = F2(
	function (line, model) {
		var matches = A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex('^(\\w+) to (\\w+) = (\\d+)$'),
				line));
		if ((((((((matches.b && matches.a.b) && (!matches.a.a.$)) && matches.a.b.b) && (!matches.a.b.a.$)) && matches.a.b.b.b) && (!matches.a.b.b.a.$)) && (!matches.a.b.b.b.b)) && (!matches.b.b)) {
			var _v1 = matches.a;
			var c1 = _v1.a.a;
			var _v2 = _v1.b;
			var c2 = _v2.a.a;
			var _v3 = _v2.b;
			var d = _v3.a.a;
			var di = A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(d));
			var distances = A3(
				$elm$core$Dict$insert,
				A2($author$project$Y15D09$key, c2, c1),
				di,
				A3(
					$elm$core$Dict$insert,
					A2($author$project$Y15D09$key, c1, c2),
					di,
					model.an));
			var cities_ = A2($elm$core$List$member, c1, model.L) ? model.L : A2($elm$core$List$cons, c1, model.L);
			var cities = A2($elm$core$List$member, c2, cities_) ? cities_ : A2($elm$core$List$cons, c2, cities_);
			return _Utils_update(
				model,
				{L: cities, an: distances});
		} else {
			return model;
		}
	});
var $author$project$Y15D09$parseInput = function (input) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Y15D09$parseLine,
		$author$project$Y15D09$initModel,
		A2(
			$elm$core$List$filter,
			function (l) {
				return l !== '';
			},
			A2($elm$core$String$split, '\n', input)));
};
var $author$project$Y15D09$answer = F2(
	function (part, input) {
		var model = $author$project$Y15D09$parseInput(input);
		var extremes = $author$project$Y15D09$extreme(model);
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$minimum(extremes))) : $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(extremes)));
	});
var $author$project$Y15D10$mapper = function (match) {
	var length = $elm$core$String$fromInt(
		$elm$core$String$length(match.bY));
	var _char = A2($elm$core$String$left, 1, match.bY);
	return _Utils_ap(length, _char);
};
var $author$project$Y15D10$conway = F2(
	function (count, digits) {
		conway:
		while (true) {
			if (count <= 0) {
				return digits;
			} else {
				var digits_ = A3(
					$elm$regex$Regex$replace,
					$author$project$Util$regex('(\\d)\\1*'),
					$author$project$Y15D10$mapper,
					digits);
				var $temp$count = count - 1,
					$temp$digits = digits_;
				count = $temp$count;
				digits = $temp$digits;
				continue conway;
			}
		}
	});
var $author$project$Y15D10$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'no digits found',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('\\d+'),
					input))));
};
var $author$project$Y15D10$answer = F2(
	function (part, input) {
		var digits = A2(
			$author$project$Y15D10$conway,
			40,
			$author$project$Y15D10$parse(input));
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$String$length(digits)) : $elm$core$String$fromInt(
			$elm$core$String$length(
				A2($author$project$Y15D10$conway, 10, digits)));
	});
var $elm$regex$Regex$contains = _Regex_contains;
var $author$project$Y15D11$has_a_straight = function (p) {
	return A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('(abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)'),
		p);
};
var $author$project$Y15D11$has_enough_pairs = function (p) {
	return A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('(.)\\1.*(.)(?!\\1)\\2'),
		p);
};
var $elm$core$Char$fromCode = _Char_fromCode;
var $author$project$Y15D11$increment = function (p) {
	var parts = $elm$core$List$head(
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex('^([a-z]*)([a-y])(z*)$'),
				p)));
	_v0$2:
	while (true) {
		if ((((((!parts.$) && parts.a.b) && (!parts.a.a.$)) && parts.a.b.b) && (!parts.a.b.a.$)) && parts.a.b.b.b) {
			if (!parts.a.b.b.a.$) {
				if (!parts.a.b.b.b.b) {
					var _v1 = parts.a;
					var a = _v1.a.a;
					var _v2 = _v1.b;
					var b = _v2.a.a;
					var _v3 = _v2.b;
					var c = _v3.a.a;
					var c1 = A2(
						$elm$core$String$repeat,
						$elm$core$String$length(c),
						'a');
					var b1 = $elm$core$String$uncons(b);
					var b2 = function () {
						if (!b1.$) {
							var _v5 = b1.a;
							var _char = _v5.a;
							var string = _v5.b;
							return $elm$core$String$fromChar(
								$elm$core$Char$fromCode(
									1 + $elm$core$Char$toCode(_char)));
						} else {
							return '';
						}
					}();
					return A2(
						$elm$regex$Regex$contains,
						$author$project$Util$regex('^[b-z]$'),
						b2) ? _Utils_ap(
						a,
						_Utils_ap(b2, c1)) : ('invalid (' + (p + ')'));
				} else {
					break _v0$2;
				}
			} else {
				if (!parts.a.b.b.b.b) {
					var _v6 = parts.a;
					var a = _v6.a.a;
					var _v7 = _v6.b;
					var b = _v7.a.a;
					var _v8 = _v7.b;
					var _v9 = _v8.a;
					var c1 = '';
					var b1 = $elm$core$String$uncons(b);
					var b2 = function () {
						if (!b1.$) {
							var _v11 = b1.a;
							var _char = _v11.a;
							var string = _v11.b;
							return $elm$core$String$fromChar(
								$elm$core$Char$fromCode(
									1 + $elm$core$Char$toCode(_char)));
						} else {
							return '';
						}
					}();
					return A2(
						$elm$regex$Regex$contains,
						$author$project$Util$regex('^[b-z]$'),
						b2) ? _Utils_ap(
						a,
						_Utils_ap(b2, c1)) : ('invalid (' + (p + ')'));
				} else {
					break _v0$2;
				}
			}
		} else {
			break _v0$2;
		}
	}
	return 'invalid (' + (p + ')');
};
var $elm$core$Basics$not = _Basics_not;
var $author$project$Y15D11$is_not_confusing = function (p) {
	return !A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('[iol]'),
		p);
};
var $author$project$Y15D11$next = function (q) {
	next:
	while (true) {
		var p = $author$project$Y15D11$increment(q);
		if (A2($elm$core$String$startsWith, 'invalid', p)) {
			return p;
		} else {
			if ($author$project$Y15D11$is_not_confusing(p) && ($author$project$Y15D11$has_a_straight(p) && $author$project$Y15D11$has_enough_pairs(p))) {
				return p;
			} else {
				var $temp$q = p;
				q = $temp$q;
				continue next;
			}
		}
	}
};
var $author$project$Y15D11$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'no password found',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('[a-z]{8}'),
					input))));
};
var $author$project$Y15D11$answer = F2(
	function (part, input) {
		return (part === 1) ? $author$project$Y15D11$next(
			$author$project$Y15D11$parse(input)) : $author$project$Y15D11$next(
			$author$project$Y15D11$next(
				$author$project$Y15D11$parse(input)));
	});
var $author$project$Y15D12$count = function (json) {
	return $elm$core$String$fromInt(
		$elm$core$List$sum(
			A2(
				$elm$core$List$map,
				$elm$core$Maybe$withDefault(0),
				A2(
					$elm$core$List$map,
					$elm$core$String$toInt,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bY;
						},
						A2(
							$elm$regex$Regex$find,
							$author$project$Util$regex('-?[1-9]\\d*'),
							json))))));
};
var $author$project$Util$failed = 'failed to solve this part';
var $author$project$Y15D12$answer = F2(
	function (part, input) {
		return (part === 1) ? $author$project$Y15D12$count(input) : $author$project$Util$failed;
	});
var $elm$core$Set$Set_elm_builtin = $elm$core$Basics$identity;
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0;
		return A3($elm$core$Dict$insert, key, 0, dict);
	});
var $author$project$Y15D13$key = F2(
	function (p1, p2) {
		return p1 + ('|' + p2);
	});
var $author$project$Y15D13$addMe = function (model) {
	var me = 'Me';
	var p = A2($elm$core$Set$insert, me, model.C);
	var h0 = model.O;
	var a = $elm$core$Set$toList(model.C);
	var h1 = A3(
		$elm$core$List$foldl,
		F2(
			function (q, h) {
				return A3(
					$elm$core$Dict$insert,
					A2($author$project$Y15D13$key, me, q),
					0,
					h);
			}),
		h0,
		a);
	var h2 = A3(
		$elm$core$List$foldl,
		F2(
			function (q, h) {
				return A3(
					$elm$core$Dict$insert,
					A2($author$project$Y15D13$key, q, me),
					0,
					h);
			}),
		h1,
		a);
	return {O: h2, C: p};
};
var $author$project$Y15D13$pairValue = F3(
	function (p1, p2, h) {
		var v2 = A2(
			$elm$core$Maybe$withDefault,
			0,
			A2(
				$elm$core$Dict$get,
				A2($author$project$Y15D13$key, p2, p1),
				h));
		var v1 = A2(
			$elm$core$Maybe$withDefault,
			0,
			A2(
				$elm$core$Dict$get,
				A2($author$project$Y15D13$key, p1, p2),
				h));
		return v1 + v2;
	});
var $author$project$Y15D13$inner = function (list) {
	if (list.b && list.b.b) {
		var x = list.a;
		var _v1 = list.b;
		var y = _v1.a;
		var rest = _v1.b;
		return A2(
			$elm$core$List$cons,
			_Utils_Tuple2(x, y),
			$author$project$Y15D13$inner(
				A2($elm$core$List$cons, y, rest)));
	} else {
		return _List_Nil;
	}
};
var $author$project$Y15D13$outer = function (list) {
	var last = $elm$core$List$head(
		$elm$core$List$reverse(list));
	var first = $elm$core$List$head(list);
	var _v0 = _Utils_Tuple2(first, last);
	if ((!_v0.a.$) && (!_v0.b.$)) {
		var f = _v0.a.a;
		var l = _v0.b.a;
		return $elm$core$Maybe$Just(
			_Utils_Tuple2(l, f));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Y15D13$pairup = function (list) {
	var pairs = $author$project$Y15D13$inner(list);
	var pair = $author$project$Y15D13$outer(list);
	if (!pair.$) {
		var _v1 = pair.a;
		var l = _v1.a;
		var f = _v1.b;
		return A2(
			$elm$core$List$cons,
			_Utils_Tuple2(l, f),
			pairs);
	} else {
		return pairs;
	}
};
var $author$project$Y15D13$happinesses = function (model) {
	var f = function (_v0) {
		var p1 = _v0.a;
		var p2 = _v0.b;
		return A3($author$project$Y15D13$pairValue, p1, p2, model.O);
	};
	return A2(
		$elm$core$List$map,
		function (pairs) {
			return $elm$core$List$sum(
				A2($elm$core$List$map, f, pairs));
		},
		A2(
			$elm$core$List$map,
			function (perm) {
				return $author$project$Y15D13$pairup(perm);
			},
			$author$project$Util$permutations(
				$elm$core$Set$toList(model.C))));
};
var $elm$core$Set$empty = $elm$core$Dict$empty;
var $author$project$Y15D13$initModel = {O: $elm$core$Dict$empty, C: $elm$core$Set$empty};
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $author$project$Y15D13$parseLine = F2(
	function (line, model) {
		var matches = A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex('^(\\w+) would (gain|lose) (\\d+) happiness units by sitting next to (\\w+)\\.$'),
				line));
		if ((((((((((matches.b && matches.a.b) && (!matches.a.a.$)) && matches.a.b.b) && (!matches.a.b.a.$)) && matches.a.b.b.b) && (!matches.a.b.b.a.$)) && matches.a.b.b.b.b) && (!matches.a.b.b.b.a.$)) && (!matches.a.b.b.b.b.b)) && (!matches.b.b)) {
			var _v1 = matches.a;
			var p1 = _v1.a.a;
			var _v2 = _v1.b;
			var gl = _v2.a.a;
			var _v3 = _v2.b;
			var i = _v3.a.a;
			var _v4 = _v3.b;
			var p2 = _v4.a.a;
			var p = A2(
				$elm$core$Set$insert,
				p2,
				A2($elm$core$Set$insert, p1, model.C));
			var j = A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(i));
			var k = (gl === 'gain') ? j : (-j);
			var h = A3(
				$elm$core$Dict$insert,
				A2($author$project$Y15D13$key, p1, p2),
				k,
				model.O);
			return {O: h, C: p};
		} else {
			return model;
		}
	});
var $author$project$Y15D13$parse = function (input) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Y15D13$parseLine,
		$author$project$Y15D13$initModel,
		A2(
			$elm$core$List$filter,
			function (l) {
				return l !== '';
			},
			A2($elm$core$String$split, '\n', input)));
};
var $author$project$Y15D13$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(
					$author$project$Y15D13$happinesses(
						$author$project$Y15D13$parse(input))))) : $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(
					$author$project$Y15D13$happinesses(
						$author$project$Y15D13$addMe(
							$author$project$Y15D13$parse(input))))));
	});
var $author$project$Y15D14$distance = F2(
	function (t, r) {
		var cyc = r.af + r.a7;
		var tmp = t % cyc;
		var rdr = (_Utils_cmp(tmp, r.af) > 0) ? r.af : tmp;
		return ((((t / cyc) | 0) * r.af) + rdr) * r.ba;
	});
var $author$project$Y15D14$score = F3(
	function (t, time, model) {
		score:
		while (true) {
			if (_Utils_cmp(t, time) > -1) {
				return model;
			} else {
				var t_ = t + 1;
				var model1 = A2(
					$elm$core$List$map,
					function (r) {
						return _Utils_update(
							r,
							{
								ar: A2($author$project$Y15D14$distance, t_, r)
							});
					},
					model);
				var maxDst = A2(
					$elm$core$Maybe$withDefault,
					0,
					$elm$core$List$maximum(
						A2(
							$elm$core$List$map,
							function ($) {
								return $.ar;
							},
							model1)));
				var model2 = A2(
					$elm$core$List$map,
					function (r) {
						return _Utils_update(
							r,
							{
								ay: r.ay + (_Utils_eq(r.ar, maxDst) ? 1 : 0)
							});
					},
					model1);
				var $temp$t = t_,
					$temp$time = time,
					$temp$model = model2;
				t = $temp$t;
				time = $temp$time;
				model = $temp$model;
				continue score;
			}
		}
	});
var $author$project$Y15D14$bestScore = F2(
	function (time, model) {
		return $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(
					A2(
						$elm$core$List$map,
						function ($) {
							return $.ay;
						},
						A3($author$project$Y15D14$score, 0, time, model)))));
	});
var $author$project$Y15D14$maxDistance = F2(
	function (time, model) {
		return $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(
					A2(
						$elm$core$List$map,
						$author$project$Y15D14$distance(time),
						model))));
	});
var $author$project$Y15D14$parseLine = F2(
	function (line, model) {
		var matches = A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex('^(\\w+) can fly (\\d+) km/s for (\\d+) seconds, but then must rest for (\\d+) seconds\\.$'),
				line));
		if ((((((((((matches.b && matches.a.b) && (!matches.a.a.$)) && matches.a.b.b) && (!matches.a.b.a.$)) && matches.a.b.b.b) && (!matches.a.b.b.a.$)) && matches.a.b.b.b.b) && (!matches.a.b.b.b.a.$)) && (!matches.a.b.b.b.b.b)) && (!matches.b.b)) {
			var _v1 = matches.a;
			var n1 = _v1.a.a;
			var _v2 = _v1.b;
			var s1 = _v2.a.a;
			var _v3 = _v2.b;
			var t1 = _v3.a.a;
			var _v4 = _v3.b;
			var r1 = _v4.a.a;
			var t2 = A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(t1));
			var s2 = A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(s1));
			var r2 = A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(r1));
			var reindeer = {ar: 0, bt: n1, a7: r2, ay: 0, ba: s2, af: t2};
			return A2($elm$core$List$cons, reindeer, model);
		} else {
			return model;
		}
	});
var $author$project$Y15D14$parse = function (input) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Y15D14$parseLine,
		_List_Nil,
		A2(
			$elm$core$List$filter,
			function (l) {
				return l !== '';
			},
			A2($elm$core$String$split, '\n', input)));
};
var $author$project$Y15D14$answer = F2(
	function (part, input) {
		var time = 2503;
		var model = $author$project$Y15D14$parse(input);
		return (part === 1) ? A2($author$project$Y15D14$maxDistance, time, model) : A2($author$project$Y15D14$bestScore, time, model);
	});
var $author$project$Y15D15$increment = function (l) {
	if (!l.b) {
		return _List_Nil;
	} else {
		var n = l.a;
		var rest = l.b;
		return A2($elm$core$List$cons, n + 1, rest);
	}
};
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $author$project$Y15D15$rollover = function (l) {
	rollover:
	while (true) {
		if (!l.b) {
			return _Utils_Tuple2(0, _List_Nil);
		} else {
			if (l.a === 1) {
				var rest = l.b;
				var $temp$l = rest;
				l = $temp$l;
				continue rollover;
			} else {
				var n = l.a;
				var rest = l.b;
				return _Utils_Tuple2(
					n - 1,
					$author$project$Y15D15$increment(rest));
			}
		}
	}
};
var $author$project$Y15D15$next = function (c) {
	if (!c.b) {
		return $elm$core$Maybe$Nothing;
	} else {
		if (c.a === 1) {
			var rest = c.b;
			var _v1 = $author$project$Y15D15$rollover(rest);
			var n = _v1.a;
			var l = _v1.b;
			if (!n) {
				return $elm$core$Maybe$Nothing;
			} else {
				var ones = A2(
					$elm$core$List$repeat,
					($elm$core$List$length(c) - $elm$core$List$length(l)) - 1,
					1);
				return $elm$core$Maybe$Just(
					A2(
						$elm$core$List$cons,
						n,
						_Utils_ap(ones, l)));
			}
		} else {
			var n = c.a;
			var rest = c.b;
			return $elm$core$Maybe$Just(
				A2(
					$elm$core$List$cons,
					n - 1,
					$author$project$Y15D15$increment(rest)));
		}
	}
};
var $elm$core$List$product = function (numbers) {
	return A3($elm$core$List$foldl, $elm$core$Basics$mul, 1, numbers);
};
var $author$project$Y15D15$score = F3(
	function (m, calories, cookie) {
		var excluded = function () {
			if (!calories.$) {
				var c = calories.a;
				return !_Utils_eq(
					c,
					$elm$core$List$sum(
						A3(
							$elm$core$List$map2,
							$elm$core$Basics$mul,
							A2(
								$elm$core$List$map,
								function ($) {
									return $.bf;
								},
								m),
							cookie)));
			} else {
				return false;
			}
		}();
		if (excluded) {
			return 0;
		} else {
			var tx = $elm$core$List$sum(
				A3(
					$elm$core$List$map2,
					$elm$core$Basics$mul,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bM;
						},
						m),
					cookie));
			var fl = $elm$core$List$sum(
				A3(
					$elm$core$List$map2,
					$elm$core$Basics$mul,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bn;
						},
						m),
					cookie));
			var du = $elm$core$List$sum(
				A3(
					$elm$core$List$map2,
					$elm$core$Basics$mul,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bk;
						},
						m),
					cookie));
			var cp = $elm$core$List$sum(
				A3(
					$elm$core$List$map2,
					$elm$core$Basics$mul,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bg;
						},
						m),
					cookie));
			return $elm$core$List$product(
				A2(
					$elm$core$List$map,
					function (s) {
						return (s < 0) ? 0 : s;
					},
					_List_fromArray(
						[cp, du, fl, tx])));
		}
	});
var $author$project$Y15D15$highScore = F4(
	function (model, calories, oldHigh, oldCookie) {
		highScore:
		while (true) {
			var newHigh = A2(
				$elm$core$Maybe$withDefault,
				oldHigh,
				$elm$core$List$maximum(
					_List_fromArray(
						[
							A3($author$project$Y15D15$score, model, calories, oldCookie),
							oldHigh
						])));
			var newCookie = $author$project$Y15D15$next(oldCookie);
			if (!newCookie.$) {
				var cookie = newCookie.a;
				var $temp$model = model,
					$temp$calories = calories,
					$temp$oldHigh = newHigh,
					$temp$oldCookie = cookie;
				model = $temp$model;
				calories = $temp$calories;
				oldHigh = $temp$oldHigh;
				oldCookie = $temp$oldCookie;
				continue highScore;
			} else {
				return newHigh;
			}
		}
	});
var $author$project$Y15D15$initCookie = F2(
	function (model, total) {
		var size = $elm$core$List$length(model);
		var ones = A2($elm$core$List$repeat, size - 1, 1);
		var first = (total - size) + 1;
		return A2($elm$core$List$cons, first, ones);
	});
var $author$project$Y15D15$Ingredient = F6(
	function (name, capacity, durability, flavor, texture, calories) {
		return {bf: calories, bg: capacity, bk: durability, bn: flavor, bt: name, bM: texture};
	});
var $author$project$Y15D15$parseInt = function (s) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(s));
};
var $author$project$Y15D15$parseLine = F2(
	function (line, model) {
		var rgx = '^(\\w+): ' + ('capacity (-?\\d+), ' + ('durability (-?\\d+), ' + ('flavor (-?\\d+), ' + ('texture (-?\\d+), ' + 'calories (-?\\d+)$'))));
		var matches = A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex(rgx),
				line));
		if ((((((((((((((matches.b && matches.a.b) && (!matches.a.a.$)) && matches.a.b.b) && (!matches.a.b.a.$)) && matches.a.b.b.b) && (!matches.a.b.b.a.$)) && matches.a.b.b.b.b) && (!matches.a.b.b.b.a.$)) && matches.a.b.b.b.b.b) && (!matches.a.b.b.b.b.a.$)) && matches.a.b.b.b.b.b.b) && (!matches.a.b.b.b.b.b.a.$)) && (!matches.a.b.b.b.b.b.b.b)) && (!matches.b.b)) {
			var _v1 = matches.a;
			var nm = _v1.a.a;
			var _v2 = _v1.b;
			var cp1 = _v2.a.a;
			var _v3 = _v2.b;
			var du1 = _v3.a.a;
			var _v4 = _v3.b;
			var fl1 = _v4.a.a;
			var _v5 = _v4.b;
			var tx1 = _v5.a.a;
			var _v6 = _v5.b;
			var cl1 = _v6.a.a;
			var tx2 = $author$project$Y15D15$parseInt(tx1);
			var fl2 = $author$project$Y15D15$parseInt(fl1);
			var du2 = $author$project$Y15D15$parseInt(du1);
			var cp2 = $author$project$Y15D15$parseInt(cp1);
			var cl2 = $author$project$Y15D15$parseInt(cl1);
			return A2(
				$elm$core$List$cons,
				A6($author$project$Y15D15$Ingredient, nm, cp2, du2, fl2, tx2, cl2),
				model);
		} else {
			return model;
		}
	});
var $author$project$Y15D15$parseInput = function (input) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Y15D15$parseLine,
		_List_Nil,
		A2(
			$elm$core$List$filter,
			function (l) {
				return l !== '';
			},
			A2($elm$core$String$split, '\n', input)));
};
var $author$project$Y15D15$answer = F2(
	function (part, input) {
		var model = $author$project$Y15D15$parseInput(input);
		var cookie = A2($author$project$Y15D15$initCookie, model, 100);
		return (part === 1) ? $elm$core$String$fromInt(
			A4($author$project$Y15D15$highScore, model, $elm$core$Maybe$Nothing, 0, cookie)) : $elm$core$String$fromInt(
			A4(
				$author$project$Y15D15$highScore,
				model,
				$elm$core$Maybe$Just(500),
				0,
				cookie));
	});
var $author$project$Y15D16$match1 = F3(
	function (prop, val, prevProp) {
		if (!prevProp) {
			return false;
		} else {
			switch (prop) {
				case 'akitas':
					return !val;
				case 'cars':
					return val === 2;
				case 'cats':
					return val === 7;
				case 'children':
					return val === 3;
				case 'goldfish':
					return val === 5;
				case 'perfumes':
					return val === 1;
				case 'pomeranians':
					return val === 3;
				case 'samoyeds':
					return val === 2;
				case 'trees':
					return val === 3;
				case 'vizslas':
					return !val;
				default:
					return false;
			}
		}
	});
var $author$project$Y15D16$match2 = F3(
	function (prop, val, prevProp) {
		if (!prevProp) {
			return false;
		} else {
			switch (prop) {
				case 'akitas':
					return !val;
				case 'cars':
					return val === 2;
				case 'cats':
					return val > 7;
				case 'children':
					return val === 3;
				case 'goldfish':
					return val < 5;
				case 'perfumes':
					return val === 1;
				case 'pomeranians':
					return val < 3;
				case 'samoyeds':
					return val === 2;
				case 'trees':
					return val > 3;
				case 'vizslas':
					return !val;
				default:
					return false;
			}
		}
	});
var $author$project$Y15D16$Sue = F2(
	function (number, props) {
		return {bu: number, bB: props};
	});
var $author$project$Y15D16$parseInt = function (s) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(s));
};
var $author$project$Y15D16$parseLine = F2(
	function (line, model) {
		var cs = '(akitas|cars|cats|children|goldfish|perfumes|pomeranians|samoyeds|trees|vizslas): (\\d+)';
		var rx = 'Sue ([1-9]\\d*): ' + A2(
			$elm$core$String$join,
			', ',
			A2($elm$core$List$repeat, 3, cs));
		var ms = A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex(rx),
				line));
		if ((((((((((((((((ms.b && ms.a.b) && (!ms.a.a.$)) && ms.a.b.b) && (!ms.a.b.a.$)) && ms.a.b.b.b) && (!ms.a.b.b.a.$)) && ms.a.b.b.b.b) && (!ms.a.b.b.b.a.$)) && ms.a.b.b.b.b.b) && (!ms.a.b.b.b.b.a.$)) && ms.a.b.b.b.b.b.b) && (!ms.a.b.b.b.b.b.a.$)) && ms.a.b.b.b.b.b.b.b) && (!ms.a.b.b.b.b.b.b.a.$)) && (!ms.a.b.b.b.b.b.b.b.b)) && (!ms.b.b)) {
			var _v1 = ms.a;
			var n = _v1.a.a;
			var _v2 = _v1.b;
			var p1 = _v2.a.a;
			var _v3 = _v2.b;
			var n1 = _v3.a.a;
			var _v4 = _v3.b;
			var p2 = _v4.a.a;
			var _v5 = _v4.b;
			var n2 = _v5.a.a;
			var _v6 = _v5.b;
			var p3 = _v6.a.a;
			var _v7 = _v6.b;
			var n3 = _v7.a.a;
			var i = $author$project$Y15D16$parseInt(n);
			var d = A3(
				$elm$core$Dict$insert,
				p3,
				$author$project$Y15D16$parseInt(n3),
				A3(
					$elm$core$Dict$insert,
					p2,
					$author$project$Y15D16$parseInt(n2),
					A3(
						$elm$core$Dict$insert,
						p1,
						$author$project$Y15D16$parseInt(n1),
						$elm$core$Dict$empty)));
			return A2(
				$elm$core$List$cons,
				A2($author$project$Y15D16$Sue, i, d),
				model);
		} else {
			return model;
		}
	});
var $author$project$Y15D16$parse = function (input) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Y15D16$parseLine,
		_List_Nil,
		A2(
			$elm$core$List$filter,
			function (l) {
				return l !== '';
			},
			A2($elm$core$String$split, '\n', input)));
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $author$project$Y15D16$sue = F2(
	function (hit, model) {
		var sues = A2(
			$elm$core$List$filter,
			function (s) {
				return A3($elm$core$Dict$foldl, hit, true, s.bB);
			},
			model);
		var _v0 = $elm$core$List$length(sues);
		switch (_v0) {
			case 0:
				return 'none';
			case 1:
				return $elm$core$String$fromInt(
					A2(
						$elm$core$Maybe$withDefault,
						0,
						$elm$core$List$head(
							A2(
								$elm$core$List$map,
								function ($) {
									return $.bu;
								},
								sues))));
			default:
				return 'too many';
		}
	});
var $author$project$Y15D16$answer = F2(
	function (part, input) {
		var match = (part === 1) ? $author$project$Y15D16$match1 : $author$project$Y15D16$match2;
		return A2(
			$author$project$Y15D16$sue,
			match,
			$author$project$Y15D16$parse(input));
	});
var $author$project$Util$combinations = F2(
	function (n, list) {
		return ((n < 0) || (_Utils_cmp(
			n,
			$elm$core$List$length(list)) > 0)) ? _List_Nil : A2($author$project$Util$combo, n, list);
	});
var $author$project$Util$combo = F2(
	function (n, list) {
		if (!n) {
			return _List_fromArray(
				[_List_Nil]);
		} else {
			if (_Utils_eq(
				n,
				$elm$core$List$length(list))) {
				return _List_fromArray(
					[list]);
			} else {
				if (!list.b) {
					return _List_Nil;
				} else {
					var x = list.a;
					var xs = list.b;
					var c2 = A2($author$project$Util$combinations, n, xs);
					var c1 = A2(
						$elm$core$List$map,
						$elm$core$List$cons(x),
						A2($author$project$Util$combinations, n - 1, xs));
					return _Utils_ap(c1, c2);
				}
			}
		}
	});
var $author$project$Y15D17$combos = F3(
	function (n, total, model) {
		if (!n) {
			return _Utils_Tuple2(0, 0);
		} else {
			var p = $elm$core$List$length(
				A2(
					$elm$core$List$filter,
					function (c) {
						return _Utils_eq(
							$elm$core$List$sum(c),
							total);
					},
					A2($author$project$Util$combinations, n, model)));
			var _v0 = A3($author$project$Y15D17$combos, n - 1, total, model);
			var q = _v0.a;
			var r = _v0.b;
			return _Utils_Tuple2(
				p + q,
				(!r) ? p : r);
		}
	});
var $author$project$Y15D17$parse = function (input) {
	return A2(
		$elm$core$List$filter,
		function (i) {
			return i > 0;
		},
		A2(
			$elm$core$List$map,
			$elm$core$Maybe$withDefault(0),
			A2(
				$elm$core$List$map,
				$elm$core$String$toInt,
				A2(
					$elm$core$List$map,
					function ($) {
						return $.bY;
					},
					A2(
						$elm$regex$Regex$find,
						$author$project$Util$regex('[1-9]\\d*'),
						input)))));
};
var $author$project$Y15D17$answer = F2(
	function (part, input) {
		var select = (part === 1) ? $elm$core$Tuple$first : $elm$core$Tuple$second;
		var model = $author$project$Y15D17$parse(input);
		var number = A3(
			$author$project$Y15D17$combos,
			$elm$core$List$length(model),
			150,
			model);
		return $elm$core$String$fromInt(
			select(number));
	});
var $author$project$Y15D18$count = function (model) {
	return $elm$core$List$length(
		A2(
			$elm$core$List$filter,
			$elm$core$Basics$identity,
			$elm$core$Array$toList(model.A)));
};
var $author$project$Y15D18$Model = F4(
	function (lights, size, maxIndex, stuck) {
		return {A: lights, o: maxIndex, a9: size, aU: stuck};
	});
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var $elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			$elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					$elm$core$Elm$JsArray$push,
					$elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, $elm$core$Elm$JsArray$empty));
				return A2($elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!value.$) {
				var subTree = value.a;
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, subTree));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4(
						$elm$core$Array$insertTailInTree,
						shift - $elm$core$Array$shiftStep,
						index,
						tail,
						$elm$core$Elm$JsArray$singleton(value)));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var $elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var originalTailLen = $elm$core$Elm$JsArray$length(tail);
		var newTailLen = $elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, $elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> $elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + $elm$core$Array$shiftStep;
				var newTree = A4(
					$elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					$elm$core$Elm$JsArray$singleton(
						$elm$core$Array$SubTree(tree)));
				return A4($elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, $elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4($elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					$elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4($elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var $elm$core$Array$push = F2(
	function (a, array) {
		var tail = array.d;
		return A2(
			$elm$core$Array$unsafeReplaceTail,
			A2($elm$core$Elm$JsArray$push, a, tail),
			array);
	});
var $elm$core$Basics$sqrt = _Basics_sqrt;
var $author$project$Y15D18$parse = function (input) {
	var a = A3(
		$elm$core$List$foldl,
		$elm$core$Array$push,
		$elm$core$Array$empty,
		A2(
			$elm$core$List$map,
			function (t) {
				return t === '#';
			},
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('[#.]'),
					input))));
	var s = $elm$core$Basics$ceiling(
		$elm$core$Basics$sqrt(
			$elm$core$Array$length(a)));
	var m = s - 1;
	return A4($author$project$Y15D18$Model, a, s, m, false);
};
var $author$project$Y15D18$index = F2(
	function (model, _v0) {
		var r = _v0.a;
		var c = _v0.b;
		return (r * model.a9) + c;
	});
var $author$project$Y15D18$corner = F2(
	function (model, _v0) {
		var r = _v0.a;
		var c = _v0.b;
		return ((!r) || _Utils_eq(r, model.o)) && ((!c) || _Utils_eq(c, model.o));
	});
var $author$project$Y15D18$outside = F2(
	function (model, _v0) {
		var r = _v0.a;
		var c = _v0.b;
		return (_Utils_cmp(r, model.o) > 0) || ((r < 0) || ((_Utils_cmp(c, model.o) > 0) || (c < 0)));
	});
var $author$project$Y15D18$query = F2(
	function (model, cell) {
		return A2($author$project$Y15D18$outside, model, cell) ? false : A2(
			$elm$core$Maybe$withDefault,
			false,
			A2(
				$elm$core$Array$get,
				A2($author$project$Y15D18$index, model, cell),
				model.A));
	});
var $author$project$Y15D18$neighbours = F2(
	function (model, _v0) {
		var r = _v0.a;
		var c = _v0.b;
		var ds = _List_fromArray(
			[
				_Utils_Tuple2(-1, -1),
				_Utils_Tuple2(0, -1),
				_Utils_Tuple2(1, -1),
				_Utils_Tuple2(-1, 0),
				_Utils_Tuple2(1, 0),
				_Utils_Tuple2(-1, 1),
				_Utils_Tuple2(0, 1),
				_Utils_Tuple2(1, 1)
			]);
		return $elm$core$List$length(
			A2(
				$elm$core$List$filter,
				$elm$core$Basics$identity,
				A2(
					$elm$core$List$map,
					$author$project$Y15D18$query(model),
					A2(
						$elm$core$List$map,
						function (_v1) {
							var dr = _v1.a;
							var dc = _v1.b;
							return _Utils_Tuple2(r + dr, c + dc);
						},
						ds))));
	});
var $author$project$Y15D18$newVal = F2(
	function (model, cell) {
		if (model.aU && A2($author$project$Y15D18$corner, model, cell)) {
			return true;
		} else {
			var n = A2($author$project$Y15D18$neighbours, model, cell);
			return A2($author$project$Y15D18$query, model, cell) ? ((n === 2) || (n === 3)) : (n === 3);
		}
	});
var $author$project$Y15D18$next = F2(
	function (model, _v0) {
		var r = _v0.a;
		var c = _v0.b;
		return (_Utils_cmp(c, model.o) > -1) ? _Utils_Tuple2(r + 1, 0) : _Utils_Tuple2(r, c + 1);
	});
var $author$project$Y15D18$sweep = F3(
	function (oldModel, model, cell) {
		sweep:
		while (true) {
			if (A2($author$project$Y15D18$outside, model, cell)) {
				return model;
			} else {
				var v = A2($author$project$Y15D18$newVal, oldModel, cell);
				var model_ = _Utils_update(
					model,
					{
						A: A3(
							$elm$core$Array$set,
							A2($author$project$Y15D18$index, model, cell),
							v,
							model.A)
					});
				var nextCell = A2($author$project$Y15D18$next, model_, cell);
				var $temp$oldModel = oldModel,
					$temp$model = model_,
					$temp$cell = nextCell;
				oldModel = $temp$oldModel;
				model = $temp$model;
				cell = $temp$cell;
				continue sweep;
			}
		}
	});
var $author$project$Y15D18$step = function (model) {
	var start = _Utils_Tuple2(0, 0);
	var oldModel = model;
	return A3($author$project$Y15D18$sweep, oldModel, model, start);
};
var $author$project$Y15D18$steps = F2(
	function (n, model) {
		return (n <= 0) ? model : A2(
			$author$project$Y15D18$steps,
			n - 1,
			$author$project$Y15D18$step(model));
	});
var $author$project$Y15D18$stick = function (model) {
	var a = A3(
		$elm$core$Array$set,
		A2(
			$author$project$Y15D18$index,
			model,
			_Utils_Tuple2(model.o, model.o)),
		true,
		A3(
			$elm$core$Array$set,
			A2(
				$author$project$Y15D18$index,
				model,
				_Utils_Tuple2(model.o, 0)),
			true,
			A3(
				$elm$core$Array$set,
				A2(
					$author$project$Y15D18$index,
					model,
					_Utils_Tuple2(0, model.o)),
				true,
				A3(
					$elm$core$Array$set,
					A2(
						$author$project$Y15D18$index,
						model,
						_Utils_Tuple2(0, 0)),
					true,
					model.A))));
	return _Utils_update(
		model,
		{A: a, aU: true});
};
var $author$project$Y15D18$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y15D18$count(
				A2(
					$author$project$Y15D18$steps,
					100,
					$author$project$Y15D18$parse(input)))) : $elm$core$String$fromInt(
			$author$project$Y15D18$count(
				A2(
					$author$project$Y15D18$steps,
					100,
					$author$project$Y15D18$stick(
						$author$project$Y15D18$parse(input)))));
	});
var $author$project$Y15D19$atomRgx = $author$project$Util$regex('[A-Z][a-z]?');
var $author$project$Y15D19$bracRgx = $author$project$Util$regex('(Ar|Rn)');
var $author$project$Y15D19$comaRgx = $author$project$Util$regex('Y');
var $author$project$Y15D19$count = F2(
	function (rgx, model) {
		return $elm$core$List$length(
			A2($elm$regex$Regex$find, rgx, model.P));
	});
var $author$project$Y15D19$askalski = function (model) {
	var comas = A2($author$project$Y15D19$count, $author$project$Y15D19$comaRgx, model);
	var bracs = A2($author$project$Y15D19$count, $author$project$Y15D19$bracRgx, model);
	var atoms = A2($author$project$Y15D19$count, $author$project$Y15D19$atomRgx, model);
	return $elm$core$String$fromInt(((atoms - bracs) - (2 * comas)) - 1);
};
var $author$project$Y15D19$addToReplacements = F5(
	function (matches, from, to, molecule, replacements) {
		addToReplacements:
		while (true) {
			if (!matches.b) {
				return replacements;
			} else {
				var match = matches.a;
				var rest = matches.b;
				var right = A3(
					$elm$core$String$slice,
					match.bq + $elm$core$String$length(from),
					-1,
					molecule);
				var left = A3($elm$core$String$slice, 0, match.bq, molecule);
				var replacement = _Utils_ap(
					left,
					_Utils_ap(to, right));
				var replacements_ = A2($elm$core$Set$insert, replacement, replacements);
				var $temp$matches = rest,
					$temp$from = from,
					$temp$to = to,
					$temp$molecule = molecule,
					$temp$replacements = replacements_;
				matches = $temp$matches;
				from = $temp$from;
				to = $temp$to;
				molecule = $temp$molecule;
				replacements = $temp$replacements;
				continue addToReplacements;
			}
		}
	});
var $author$project$Y15D19$iterateRules = function (model) {
	iterateRules:
	while (true) {
		var _v0 = model.aT;
		if (!_v0.b) {
			return model;
		} else {
			var rule = _v0.a;
			var rules = _v0.b;
			var to = rule.b;
			var from = rule.a;
			var matches = A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex(from),
				model.P);
			var replacements_ = A5($author$project$Y15D19$addToReplacements, matches, from, to, model.P, model.ax);
			var model_ = {P: model.P, ax: replacements_, aT: rules};
			var $temp$model = model_;
			model = $temp$model;
			continue iterateRules;
		}
	}
};
var $elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === -2) {
				return n;
			} else {
				var left = dict.d;
				var right = dict.e;
				var $temp$n = A2($elm$core$Dict$sizeHelp, n + 1, right),
					$temp$dict = left;
				n = $temp$n;
				dict = $temp$dict;
				continue sizeHelp;
			}
		}
	});
var $elm$core$Dict$size = function (dict) {
	return A2($elm$core$Dict$sizeHelp, 0, dict);
};
var $elm$core$Set$size = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$size(dict);
};
var $author$project$Y15D19$molecules = function (model) {
	var model_ = $author$project$Y15D19$iterateRules(model);
	return $elm$core$String$fromInt(
		$elm$core$Set$size(model_.ax));
};
var $author$project$Y15D19$extractMolecule = function (submatches) {
	if (submatches.$ === 1) {
		return '';
	} else {
		var list = submatches.a;
		if ((list.b && (!list.a.$)) && (!list.b.b)) {
			var m = list.a.a;
			return m;
		} else {
			return '';
		}
	}
};
var $author$project$Y15D19$extractRule = function (submatches) {
	if ((((submatches.b && (!submatches.a.$)) && submatches.b.b) && (!submatches.b.a.$)) && (!submatches.b.b.b)) {
		var from = submatches.a.a;
		var _v1 = submatches.b;
		var to = _v1.a.a;
		return _Utils_Tuple2(from, to);
	} else {
		return _Utils_Tuple2('', '');
	}
};
var $author$project$Y15D19$moleRgx = $author$project$Util$regex('((?:[A-Z][a-z]?){10,})');
var $author$project$Y15D19$ruleRgx = $author$project$Util$regex('(e|[A-Z][a-z]?) => ((?:[A-Z][a-z]?)+)');
var $author$project$Y15D19$parse = function (input) {
	var rules = A2(
		$elm$core$List$map,
		$author$project$Y15D19$extractRule,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2($elm$regex$Regex$find, $author$project$Y15D19$ruleRgx, input)));
	var molecule = $author$project$Y15D19$extractMolecule(
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.b2;
				},
				A2($elm$regex$Regex$find, $author$project$Y15D19$moleRgx, input))));
	return {P: molecule, ax: $elm$core$Set$empty, aT: rules};
};
var $author$project$Y15D19$answer = F2(
	function (part, input) {
		return (part === 1) ? $author$project$Y15D19$molecules(
			$author$project$Y15D19$parse(input)) : $author$project$Y15D19$askalski(
			$author$project$Y15D19$parse(input));
	});
var $author$project$Y15D20$fac = F4(
	function (n, i, l, fs) {
		if (_Utils_cmp(i, l) > 0) {
			return fs;
		} else {
			var fs1 = function () {
				if (!(!(n % i))) {
					return fs;
				} else {
					var j = (n / i) | 0;
					var fs2 = A2($elm$core$List$cons, i, fs);
					return _Utils_eq(j, i) ? fs2 : A2($elm$core$List$cons, j, fs2);
				}
			}();
			return _Utils_ap(
				fs1,
				A4($author$project$Y15D20$fac, n, i + 1, l, fs));
		}
	});
var $author$project$Y15D20$factors = function (n) {
	return A4(
		$author$project$Y15D20$fac,
		n,
		1,
		$elm$core$Basics$sqrt(n),
		_List_Nil);
};
var $author$project$Y15D20$house1 = F2(
	function (house, goal) {
		house1:
		while (true) {
			var presents = $elm$core$List$sum(
				A2(
					$elm$core$List$map,
					$elm$core$Basics$mul(10),
					$author$project$Y15D20$factors(house)));
			if (_Utils_cmp(presents, goal) > -1) {
				return house;
			} else {
				var $temp$house = house + 1,
					$temp$goal = goal;
				house = $temp$house;
				goal = $temp$goal;
				continue house1;
			}
		}
	});
var $author$project$Y15D20$house2 = F2(
	function (house, goal) {
		house2:
		while (true) {
			var presents = $elm$core$List$sum(
				A2(
					$elm$core$List$map,
					$elm$core$Basics$mul(11),
					A2(
						$elm$core$List$filter,
						function (elf) {
							return ((house / elf) | 0) <= 50;
						},
						$author$project$Y15D20$factors(house))));
			if (_Utils_cmp(presents, goal) > -1) {
				return house;
			} else {
				var $temp$house = house + 1,
					$temp$goal = goal;
				house = $temp$house;
				goal = $temp$goal;
				continue house2;
			}
		}
	});
var $author$project$Y15D20$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(
			A2(
				$elm$core$Maybe$withDefault,
				'0',
				$elm$core$List$head(
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bY;
						},
						A3(
							$elm$regex$Regex$findAtMost,
							1,
							$author$project$Util$regex('\\d+'),
							input))))));
};
var $author$project$Y15D20$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$author$project$Y15D20$house1,
				1,
				$author$project$Y15D20$parse(input))) : $elm$core$String$fromInt(
			A2(
				$author$project$Y15D20$house2,
				1,
				$author$project$Y15D20$parse(input)));
	});
var $author$project$Y15D21$highest = F3(
	function (pwin, pcost, best) {
		return (!pwin) && (_Utils_cmp(pcost, best) > 0);
	});
var $author$project$Y15D21$Index = F4(
	function (w, a, r1, r2) {
		return {V: a, E: r1, F: r2, aI: w};
	});
var $author$project$Y15D21$initIndex = $elm$core$Maybe$Just(
	A4($author$project$Y15D21$Index, 0, 0, 0, 1));
var $author$project$Y15D21$lowest = F3(
	function (pwin, pcost, best) {
		return pwin && ((!best) || (_Utils_cmp(pcost, best) < 0));
	});
var $author$project$Y15D21$Fighter = F5(
	function (hitp, damage, armor, cost, player) {
		return {be: armor, aZ: cost, bj: damage, aN: hitp, bx: player};
	});
var $author$project$Y15D21$parse = function (input) {
	var ns = A2(
		$elm$core$List$map,
		$elm$core$String$toInt,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('\\d+'),
				input)));
	if ((((((ns.b && (!ns.a.$)) && ns.b.b) && (!ns.b.a.$)) && ns.b.b.b) && (!ns.b.b.a.$)) && (!ns.b.b.b.b)) {
		var h = ns.a.a;
		var _v1 = ns.b;
		var d = _v1.a.a;
		var _v2 = _v1.b;
		var a = _v2.a.a;
		return A5($author$project$Y15D21$Fighter, h, d, a, 0, false);
	} else {
		return A5($author$project$Y15D21$Fighter, 0, 0, 0, 0, false);
	}
};
var $elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
			var jsArray = _v0.a;
			var remainingItems = _v0.b;
			if (_Utils_cmp(
				$elm$core$Elm$JsArray$length(jsArray),
				$elm$core$Array$branchFactor) < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					true,
					{g: nodeList, b: nodeListSize, e: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					$elm$core$List$cons,
					$elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return A3($elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var $author$project$Y15D21$armors = $elm$core$Array$fromList(
	_List_fromArray(
		[
			_List_fromArray(
			[0, 0, 0]),
			_List_fromArray(
			[13, 0, 1]),
			_List_fromArray(
			[31, 0, 2]),
			_List_fromArray(
			[53, 0, 3]),
			_List_fromArray(
			[75, 0, 4]),
			_List_fromArray(
			[102, 0, 5])
		]));
var $elm$core$List$map4 = _List_map4;
var $author$project$Y15D21$rings = $elm$core$Array$fromList(
	_List_fromArray(
		[
			_List_fromArray(
			[0, 0, 0]),
			_List_fromArray(
			[0, 0, 0]),
			_List_fromArray(
			[25, 1, 0]),
			_List_fromArray(
			[50, 2, 0]),
			_List_fromArray(
			[100, 3, 0]),
			_List_fromArray(
			[20, 0, 1]),
			_List_fromArray(
			[40, 0, 2]),
			_List_fromArray(
			[80, 0, 3])
		]));
var $author$project$Y15D21$weapons = $elm$core$Array$fromList(
	_List_fromArray(
		[
			_List_fromArray(
			[8, 4, 0]),
			_List_fromArray(
			[10, 5, 0]),
			_List_fromArray(
			[25, 6, 0]),
			_List_fromArray(
			[40, 7, 0]),
			_List_fromArray(
			[74, 8, 0])
		]));
var $author$project$Y15D21$fighterFromIndex = function (i) {
	var weapon = A2(
		$elm$core$Maybe$withDefault,
		_List_fromArray(
			[0, 0, 0]),
		A2($elm$core$Array$get, i.aI, $author$project$Y15D21$weapons));
	var ring2 = A2(
		$elm$core$Maybe$withDefault,
		_List_fromArray(
			[0, 0, 0]),
		A2($elm$core$Array$get, i.F, $author$project$Y15D21$rings));
	var ring1 = A2(
		$elm$core$Maybe$withDefault,
		_List_fromArray(
			[0, 0, 0]),
		A2($elm$core$Array$get, i.E, $author$project$Y15D21$rings));
	var armor = A2(
		$elm$core$Maybe$withDefault,
		_List_fromArray(
			[0, 0, 0]),
		A2($elm$core$Array$get, i.V, $author$project$Y15D21$armors));
	var totals = A5(
		$elm$core$List$map4,
		F4(
			function (w, a, r1, r2) {
				return ((w + a) + r1) + r2;
			}),
		weapon,
		armor,
		ring1,
		ring2);
	if (((totals.b && totals.b.b) && totals.b.b.b) && (!totals.b.b.b.b)) {
		var c = totals.a;
		var _v1 = totals.b;
		var d = _v1.a;
		var _v2 = _v1.b;
		var a = _v2.a;
		return A5($author$project$Y15D21$Fighter, 100, d, a, c, true);
	} else {
		return A5($author$project$Y15D21$Fighter, 0, 0, 0, 0, true);
	}
};
var $author$project$Y15D21$nextIndex = function (i) {
	return (i.F < 7) ? $elm$core$Maybe$Just(
		_Utils_update(
			i,
			{F: i.F + 1})) : ((i.E < 6) ? $elm$core$Maybe$Just(
		_Utils_update(
			i,
			{E: i.E + 1, F: i.E + 2})) : ((i.V < 5) ? $elm$core$Maybe$Just(
		_Utils_update(
			i,
			{V: i.V + 1, E: 0, F: 1})) : ((i.aI < 4) ? $elm$core$Maybe$Just(
		_Utils_update(
			i,
			{V: 0, E: 0, F: 1, aI: i.aI + 1})) : $elm$core$Maybe$Nothing)));
};
var $author$project$Y15D21$winner = F2(
	function (attacker, defender) {
		winner:
		while (true) {
			if (attacker.aN <= 0) {
				return defender.bx;
			} else {
				var damage = attacker.bj - defender.be;
				var hitp = defender.aN - ((damage < 1) ? 1 : damage);
				var damaged = _Utils_update(
					defender,
					{aN: hitp});
				var $temp$attacker = damaged,
					$temp$defender = attacker;
				attacker = $temp$attacker;
				defender = $temp$defender;
				continue winner;
			}
		}
	});
var $author$project$Y15D21$search = F4(
	function (boss, candidate, best, index) {
		search:
		while (true) {
			if (index.$ === 1) {
				return best;
			} else {
				var i = index.a;
				var player = $author$project$Y15D21$fighterFromIndex(i);
				var nextBest = A3(
					candidate,
					A2($author$project$Y15D21$winner, player, boss),
					player.aZ,
					best) ? player.aZ : best;
				var $temp$boss = boss,
					$temp$candidate = candidate,
					$temp$best = nextBest,
					$temp$index = $author$project$Y15D21$nextIndex(i);
				boss = $temp$boss;
				candidate = $temp$candidate;
				best = $temp$best;
				index = $temp$index;
				continue search;
			}
		}
	});
var $author$project$Y15D21$answer = F2(
	function (part, input) {
		var boss = $author$project$Y15D21$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			A4($author$project$Y15D21$search, boss, $author$project$Y15D21$lowest, 0, $author$project$Y15D21$initIndex)) : $elm$core$String$fromInt(
			A4($author$project$Y15D21$search, boss, $author$project$Y15D21$highest, 0, $author$project$Y15D21$initIndex));
	});
var $author$project$Y15D22$answer = F2(
	function (part, input) {
		return $author$project$Util$failed;
	});
var $author$project$Y15D23$get = F2(
	function (reg, model) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Dict$get, reg, model.v));
	});
var $author$project$Y15D23$initModel = {f: 0, aq: $elm$core$Array$empty, v: $elm$core$Dict$empty};
var $author$project$Y15D23$Hlf = function (a) {
	return {$: 2, a: a};
};
var $author$project$Y15D23$Inc = function (a) {
	return {$: 1, a: a};
};
var $author$project$Y15D23$Jie = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var $author$project$Y15D23$Jio = F2(
	function (a, b) {
		return {$: 6, a: a, b: b};
	});
var $author$project$Y15D23$Jmp = function (a) {
	return {$: 4, a: a};
};
var $author$project$Y15D23$NoOp = {$: 0};
var $author$project$Y15D23$Tpl = function (a) {
	return {$: 3, a: a};
};
var $author$project$Y15D23$parseLine = F2(
	function (line, model) {
		var rx = $author$project$Util$regex('^([a-z]{3})\\s+(a|b)?,?\\s*\\+?(-?\\d*)?');
		var sm = A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3($elm$regex$Regex$findAtMost, 1, rx, line));
		if (((((sm.b && sm.a.b) && sm.a.b.b) && sm.a.b.b.b) && (!sm.a.b.b.b.b)) && (!sm.b.b)) {
			var _v1 = sm.a;
			var name = _v1.a;
			var _v2 = _v1.b;
			var reg = _v2.a;
			var _v3 = _v2.b;
			var jmp = _v3.a;
			var r = A2($elm$core$Maybe$withDefault, '', reg);
			var n = A2($elm$core$Maybe$withDefault, '', name);
			var j = A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$String$toInt(
					A2($elm$core$Maybe$withDefault, '', jmp)));
			var i = function () {
				switch (n) {
					case 'inc':
						return $author$project$Y15D23$Inc(r);
					case 'hlf':
						return $author$project$Y15D23$Hlf(r);
					case 'tpl':
						return $author$project$Y15D23$Tpl(r);
					case 'jmp':
						return $author$project$Y15D23$Jmp(j);
					case 'jie':
						return A2($author$project$Y15D23$Jie, r, j);
					case 'jio':
						return A2($author$project$Y15D23$Jio, r, j);
					default:
						return $author$project$Y15D23$NoOp;
				}
			}();
			return _Utils_update(
				model,
				{
					aq: A2($elm$core$Array$push, i, model.aq)
				});
		} else {
			return model;
		}
	});
var $author$project$Y15D23$parse = function (input) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Y15D23$parseLine,
		$author$project$Y15D23$initModel,
		A2(
			$elm$core$List$filter,
			function (l) {
				return l !== '';
			},
			A2($elm$core$String$split, '\n', input)));
};
var $author$project$Y15D23$update = F3(
	function (name, f, model) {
		var value = f(
			A2($author$project$Y15D23$get, name, model));
		return A3($elm$core$Dict$insert, name, value, model.v);
	});
var $author$project$Y15D23$run = function (model) {
	run:
	while (true) {
		var instruction = A2($elm$core$Array$get, model.f, model.aq);
		if (instruction.$ === 1) {
			return model;
		} else {
			var inst = instruction.a;
			var model_ = function () {
				switch (inst.$) {
					case 1:
						var r = inst.a;
						return _Utils_update(
							model,
							{
								f: model.f + 1,
								v: A3(
									$author$project$Y15D23$update,
									r,
									function (v) {
										return v + 1;
									},
									model)
							});
					case 2:
						var r = inst.a;
						return _Utils_update(
							model,
							{
								f: model.f + 1,
								v: A3(
									$author$project$Y15D23$update,
									r,
									function (v) {
										return (v / 2) | 0;
									},
									model)
							});
					case 3:
						var r = inst.a;
						return _Utils_update(
							model,
							{
								f: model.f + 1,
								v: A3(
									$author$project$Y15D23$update,
									r,
									function (v) {
										return v * 3;
									},
									model)
							});
					case 4:
						var j = inst.a;
						return _Utils_update(
							model,
							{f: model.f + j});
					case 5:
						var r = inst.a;
						var j = inst.b;
						return _Utils_update(
							model,
							{
								f: model.f + ((!(A2($author$project$Y15D23$get, r, model) % 2)) ? j : 1)
							});
					case 6:
						var r = inst.a;
						var j = inst.b;
						return _Utils_update(
							model,
							{
								f: model.f + ((A2($author$project$Y15D23$get, r, model) === 1) ? j : 1)
							});
					default:
						return _Utils_update(
							model,
							{f: model.f + 1});
				}
			}();
			var $temp$model = model_;
			model = $temp$model;
			continue run;
		}
	}
};
var $author$project$Y15D23$answer = F2(
	function (part, input) {
		var init = $author$project$Y15D23$parse(input);
		var model = (part === 1) ? init : _Utils_update(
			init,
			{
				v: A3($elm$core$Dict$insert, 'a', 1, init.v)
			});
		return $elm$core$String$fromInt(
			A2(
				$author$project$Y15D23$get,
				'b',
				$author$project$Y15D23$run(model)));
	});
var $author$project$Y15D24$searchCombo = F3(
	function (qe, weight, combos) {
		searchCombo:
		while (true) {
			if (!combos.b) {
				return qe;
			} else {
				var weights = combos.a;
				var rest = combos.b;
				var qe_ = function () {
					if (!_Utils_eq(
						$elm$core$List$sum(weights),
						weight)) {
						return qe;
					} else {
						var qe__ = $elm$core$List$product(weights);
						return ((!qe) || (_Utils_cmp(qe__, qe) < 0)) ? qe__ : qe;
					}
				}();
				var $temp$qe = qe_,
					$temp$weight = weight,
					$temp$combos = rest;
				qe = $temp$qe;
				weight = $temp$weight;
				combos = $temp$combos;
				continue searchCombo;
			}
		}
	});
var $author$project$Y15D24$searchLength = F5(
	function (qe, length, maxLen, weight, weights) {
		searchLength:
		while (true) {
			if (_Utils_cmp(length, maxLen) > 0) {
				return qe;
			} else {
				var combos = A2($author$project$Util$combinations, length, weights);
				var qe_ = A3($author$project$Y15D24$searchCombo, qe, weight, combos);
				if (qe_ > 0) {
					return qe_;
				} else {
					var $temp$qe = qe,
						$temp$length = length + 1,
						$temp$maxLen = maxLen,
						$temp$weight = weight,
						$temp$weights = weights;
					qe = $temp$qe;
					length = $temp$length;
					maxLen = $temp$maxLen;
					weight = $temp$weight;
					weights = $temp$weights;
					continue searchLength;
				}
			}
		}
	});
var $author$project$Y15D24$bestQe = F2(
	function (groups, weights) {
		var weight = ($elm$core$List$sum(weights) / groups) | 0;
		var maxLen = ($elm$core$List$length(weights) - groups) + 1;
		return A5($author$project$Y15D24$searchLength, 0, 1, maxLen, weight, weights);
	});
var $author$project$Y15D24$parse = function (input) {
	return A2(
		$elm$core$List$filter,
		function (w) {
			return !(!w);
		},
		A2(
			$elm$core$List$map,
			$elm$core$Maybe$withDefault(0),
			A2(
				$elm$core$List$map,
				$elm$core$String$toInt,
				A2(
					$elm$core$List$map,
					function ($) {
						return $.bY;
					},
					A2(
						$elm$regex$Regex$find,
						$author$project$Util$regex('\\d+'),
						input)))));
};
var $author$project$Y15D24$answer = F2(
	function (part, input) {
		var num = (part === 1) ? 3 : 4;
		return $elm$core$String$fromInt(
			A2(
				$author$project$Y15D24$bestQe,
				num,
				$author$project$Y15D24$parse(input)));
	});
var $author$project$Util$onlyOnePart = 'no part two for this day';
var $author$project$Y15D25$parse = function (input) {
	var numbers = A2(
		$elm$core$List$map,
		$elm$core$String$toInt,
		A2(
			$elm$core$List$map,
			$elm$core$Maybe$withDefault('1'),
			A2(
				$elm$core$Maybe$withDefault,
				_List_fromArray(
					[
						$elm$core$Maybe$Just('1'),
						$elm$core$Maybe$Just('1')
					]),
				$elm$core$List$head(
					A2(
						$elm$core$List$map,
						function ($) {
							return $.b2;
						},
						A3(
							$elm$regex$Regex$findAtMost,
							1,
							$author$project$Util$regex('code at row (\\d+), column (\\d+)'),
							input))))));
	var _v0 = function () {
		if ((((numbers.b && (!numbers.a.$)) && numbers.b.b) && (!numbers.b.a.$)) && (!numbers.b.b.b)) {
			var r = numbers.a.a;
			var _v2 = numbers.b;
			var c = _v2.a.a;
			return _Utils_Tuple2(r, c);
		} else {
			return _Utils_Tuple2(1, 1);
		}
	}();
	var row = _v0.a;
	var col = _v0.b;
	return _Utils_Tuple2(row, col);
};
var $elm$core$Basics$modBy = _Basics_modBy;
var $author$project$Y15D25$search = F2(
	function (_v0, model) {
		search:
		while (true) {
			var row = _v0.a;
			var col = _v0.b;
			if (_Utils_eq(row, model.ab) && _Utils_eq(col, model.W)) {
				return model;
			} else {
				var code_ = A2($elm$core$Basics$modBy, 33554393, model.am * 252533);
				var _v1 = (model.ab > 1) ? _Utils_Tuple2(model.ab - 1, model.W + 1) : _Utils_Tuple2(model.W + 1, 1);
				var row_ = _v1.a;
				var col_ = _v1.b;
				var $temp$_v0 = _Utils_Tuple2(row, col),
					$temp$model = {am: code_, W: col_, ab: row_};
				_v0 = $temp$_v0;
				model = $temp$model;
				continue search;
			}
		}
	});
var $author$project$Y15D25$start = {am: 20151125, W: 1, ab: 1};
var $author$project$Y15D25$answer = F2(
	function (part, input) {
		if (part === 1) {
			var target = $author$project$Y15D25$parse(input);
			var model = A2($author$project$Y15D25$search, target, $author$project$Y15D25$start);
			return $elm$core$String$fromInt(model.am);
		} else {
			return $author$project$Util$onlyOnePart;
		}
	});
var $author$project$Y15$answer = F3(
	function (day, part, input) {
		switch (day) {
			case 1:
				return A2($author$project$Y15D01$answer, part, input);
			case 2:
				return A2($author$project$Y15D02$answer, part, input);
			case 3:
				return A2($author$project$Y15D03$answer, part, input);
			case 4:
				return A2($author$project$Y15D04$answer, part, input);
			case 5:
				return A2($author$project$Y15D05$answer, part, input);
			case 6:
				return A2($author$project$Y15D06$answer, part, input);
			case 7:
				return A2($author$project$Y15D07$answer, part, input);
			case 8:
				return A2($author$project$Y15D08$answer, part, input);
			case 9:
				return A2($author$project$Y15D09$answer, part, input);
			case 10:
				return A2($author$project$Y15D10$answer, part, input);
			case 11:
				return A2($author$project$Y15D11$answer, part, input);
			case 12:
				return A2($author$project$Y15D12$answer, part, input);
			case 13:
				return A2($author$project$Y15D13$answer, part, input);
			case 14:
				return A2($author$project$Y15D14$answer, part, input);
			case 15:
				return A2($author$project$Y15D15$answer, part, input);
			case 16:
				return A2($author$project$Y15D16$answer, part, input);
			case 17:
				return A2($author$project$Y15D17$answer, part, input);
			case 18:
				return A2($author$project$Y15D18$answer, part, input);
			case 19:
				return A2($author$project$Y15D19$answer, part, input);
			case 20:
				return A2($author$project$Y15D20$answer, part, input);
			case 21:
				return A2($author$project$Y15D21$answer, part, input);
			case 22:
				return A2($author$project$Y15D22$answer, part, input);
			case 23:
				return A2($author$project$Y15D23$answer, part, input);
			case 24:
				return A2($author$project$Y15D24$answer, part, input);
			case 25:
				return A2($author$project$Y15D25$answer, part, input);
			default:
				return 'year 2015, day ' + ($elm$core$String$fromInt(day) + ': not available');
		}
	});
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $author$project$Y16D01$blocks = function (model) {
	return $elm$core$Basics$abs(model.aa.H) + $elm$core$Basics$abs(model.aa.I);
};
var $author$project$Y16D01$Model = F2(
	function (d, p) {
		return {aM: d, aa: p};
	});
var $author$project$Y16D01$North = 0;
var $author$project$Y16D01$Position = F2(
	function (x, y) {
		return {H: x, I: y};
	});
var $author$project$Y16D01$origin = A2($author$project$Y16D01$Position, 0, 0);
var $author$project$Y16D01$init = A2($author$project$Y16D01$Model, 0, $author$project$Y16D01$origin);
var $author$project$Y16D01$Left = 0;
var $author$project$Y16D01$Right = 1;
var $author$project$Y16D01$Step = F2(
	function (r, n) {
		return {h: n, bE: r};
	});
var $author$project$Y16D01$parse = function (input) {
	var step = A2(
		$elm$core$Maybe$withDefault,
		$elm$regex$Regex$never,
		$elm$regex$Regex$fromString('([RL])([1-9][0-9]*)'));
	return A2(
		$elm$core$List$map,
		function (m) {
			if ((((m.b && (!m.a.$)) && m.b.b) && (!m.b.a.$)) && (!m.b.b.b)) {
				var r_ = m.a.a;
				var _v1 = m.b;
				var n_ = _v1.a.a;
				var r = (r_ === 'R') ? 1 : 0;
				var n = A2(
					$elm$core$Maybe$withDefault,
					1,
					$elm$core$String$toInt(n_));
				return A2($author$project$Y16D01$Step, r, n);
			} else {
				return A2($author$project$Y16D01$Step, 1, 1);
			}
		},
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2($elm$regex$Regex$find, step, input)));
};
var $author$project$Y16D01$None = 2;
var $author$project$Y16D01$East = 1;
var $author$project$Y16D01$South = 2;
var $author$project$Y16D01$West = 3;
var $author$project$Y16D01$update = F2(
	function (step, model) {
		var p = model.aa;
		var d = model.aM;
		var _v0 = step.bE;
		switch (_v0) {
			case 1:
				switch (d) {
					case 0:
						return A2(
							$author$project$Y16D01$Model,
							1,
							_Utils_update(
								p,
								{H: p.H + step.h}));
					case 1:
						return A2(
							$author$project$Y16D01$Model,
							2,
							_Utils_update(
								p,
								{I: p.I - step.h}));
					case 2:
						return A2(
							$author$project$Y16D01$Model,
							3,
							_Utils_update(
								p,
								{H: p.H - step.h}));
					default:
						return A2(
							$author$project$Y16D01$Model,
							0,
							_Utils_update(
								p,
								{I: p.I + step.h}));
				}
			case 0:
				var _v2 = model.aM;
				switch (_v2) {
					case 0:
						return A2(
							$author$project$Y16D01$Model,
							3,
							_Utils_update(
								p,
								{H: p.H - step.h}));
					case 1:
						return A2(
							$author$project$Y16D01$Model,
							0,
							_Utils_update(
								p,
								{I: p.I + step.h}));
					case 2:
						return A2(
							$author$project$Y16D01$Model,
							1,
							_Utils_update(
								p,
								{H: p.H + step.h}));
					default:
						return A2(
							$author$project$Y16D01$Model,
							2,
							_Utils_update(
								p,
								{I: p.I - step.h}));
				}
			default:
				var _v3 = model.aM;
				switch (_v3) {
					case 0:
						return A2(
							$author$project$Y16D01$Model,
							0,
							_Utils_update(
								p,
								{I: p.I + step.h}));
					case 1:
						return A2(
							$author$project$Y16D01$Model,
							1,
							_Utils_update(
								p,
								{H: p.H + step.h}));
					case 2:
						return A2(
							$author$project$Y16D01$Model,
							2,
							_Utils_update(
								p,
								{I: p.I - step.h}));
					default:
						return A2(
							$author$project$Y16D01$Model,
							3,
							_Utils_update(
								p,
								{H: p.H - step.h}));
				}
		}
	});
var $author$project$Y16D01$revisits = F3(
	function (steps, visits, model) {
		revisits:
		while (true) {
			if (steps.b) {
				var step = steps.a;
				var rest = steps.b;
				var newModel = A2(
					$author$project$Y16D01$update,
					_Utils_update(
						step,
						{h: 1}),
					model);
				if (A2($elm$core$List$member, newModel.aa, visits)) {
					return newModel;
				} else {
					var newVisits = A2($elm$core$List$cons, newModel.aa, visits);
					if (step.h <= 1) {
						var $temp$steps = rest,
							$temp$visits = newVisits,
							$temp$model = newModel;
						steps = $temp$steps;
						visits = $temp$visits;
						model = $temp$model;
						continue revisits;
					} else {
						var $temp$steps = A2(
							$elm$core$List$cons,
							A2($author$project$Y16D01$Step, 2, step.h - 1),
							rest),
							$temp$visits = newVisits,
							$temp$model = newModel;
						steps = $temp$steps;
						visits = $temp$visits;
						model = $temp$model;
						continue revisits;
					}
				}
			} else {
				return model;
			}
		}
	});
var $author$project$Y16D01$updates = F2(
	function (steps, model) {
		if (steps.b) {
			var step = steps.a;
			var rest = steps.b;
			return A2(
				$author$project$Y16D01$updates,
				rest,
				A2($author$project$Y16D01$update, step, model));
		} else {
			return model;
		}
	});
var $author$project$Y16D01$answer = F2(
	function (part, input) {
		var steps = $author$project$Y16D01$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y16D01$blocks(
				A2($author$project$Y16D01$updates, steps, $author$project$Y16D01$init))) : $elm$core$String$fromInt(
			$author$project$Y16D01$blocks(
				A3($author$project$Y16D01$revisits, steps, _List_Nil, $author$project$Y16D01$init)));
	});
var $elm$core$String$fromList = _String_fromList;
var $author$project$Y16D02$init = '5';
var $author$project$Y16D02$move1 = F2(
	function (current, letter) {
		switch (current) {
			case '1':
				switch (letter) {
					case 'R':
						return '2';
					case 'D':
						return '4';
					default:
						return current;
				}
			case '2':
				switch (letter) {
					case 'R':
						return '3';
					case 'L':
						return '1';
					case 'D':
						return '5';
					default:
						return current;
				}
			case '3':
				switch (letter) {
					case 'L':
						return '2';
					case 'D':
						return '6';
					default:
						return current;
				}
			case '4':
				switch (letter) {
					case 'R':
						return '5';
					case 'U':
						return '1';
					case 'D':
						return '7';
					default:
						return current;
				}
			case '5':
				switch (letter) {
					case 'R':
						return '6';
					case 'L':
						return '4';
					case 'U':
						return '2';
					case 'D':
						return '8';
					default:
						return current;
				}
			case '6':
				switch (letter) {
					case 'L':
						return '5';
					case 'U':
						return '3';
					case 'D':
						return '9';
					default:
						return current;
				}
			case '7':
				switch (letter) {
					case 'R':
						return '8';
					case 'U':
						return '4';
					default:
						return current;
				}
			case '8':
				switch (letter) {
					case 'R':
						return '9';
					case 'L':
						return '7';
					case 'U':
						return '5';
					default:
						return current;
				}
			case '9':
				switch (letter) {
					case 'L':
						return '8';
					case 'U':
						return '6';
					default:
						return current;
				}
			default:
				return current;
		}
	});
var $author$project$Y16D02$move2 = F2(
	function (current, letter) {
		switch (current) {
			case '1':
				if ('D' === letter) {
					return '3';
				} else {
					return current;
				}
			case '2':
				switch (letter) {
					case 'R':
						return '3';
					case 'D':
						return '6';
					default:
						return current;
				}
			case '3':
				switch (letter) {
					case 'R':
						return '4';
					case 'L':
						return '2';
					case 'U':
						return '1';
					case 'D':
						return '7';
					default:
						return current;
				}
			case '4':
				switch (letter) {
					case 'L':
						return '3';
					case 'D':
						return '8';
					default:
						return current;
				}
			case '5':
				if ('R' === letter) {
					return '6';
				} else {
					return current;
				}
			case '6':
				switch (letter) {
					case 'R':
						return '7';
					case 'L':
						return '5';
					case 'U':
						return '2';
					case 'D':
						return 'A';
					default:
						return current;
				}
			case '7':
				switch (letter) {
					case 'R':
						return '8';
					case 'L':
						return '6';
					case 'U':
						return '3';
					case 'D':
						return 'B';
					default:
						return current;
				}
			case '8':
				switch (letter) {
					case 'R':
						return '9';
					case 'L':
						return '7';
					case 'U':
						return '4';
					case 'D':
						return 'C';
					default:
						return current;
				}
			case '9':
				if ('L' === letter) {
					return '8';
				} else {
					return current;
				}
			case 'A':
				switch (letter) {
					case 'R':
						return 'B';
					case 'U':
						return '6';
					default:
						return current;
				}
			case 'B':
				switch (letter) {
					case 'R':
						return 'C';
					case 'L':
						return 'A';
					case 'U':
						return '7';
					case 'D':
						return 'D';
					default:
						return current;
				}
			case 'C':
				switch (letter) {
					case 'L':
						return 'B';
					case 'U':
						return '8';
					default:
						return current;
				}
			case 'D':
				if ('U' === letter) {
					return 'B';
				} else {
					return current;
				}
			default:
				return current;
		}
	});
var $author$project$Y16D02$parse = function (input) {
	return A2(
		$elm$core$List$map,
		function ($) {
			return $.bY;
		},
		A2(
			$elm$regex$Regex$find,
			$author$project$Util$regex('([RLUD]+)'),
			input));
};
var $author$project$Y16D02$follow = F3(
	function (current, mover, instruction) {
		follow:
		while (true) {
			var _v0 = $elm$core$String$uncons(instruction);
			if (!_v0.$) {
				var _v1 = _v0.a;
				var letter = _v1.a;
				var rest = _v1.b;
				var button = A2(mover, current, letter);
				var $temp$current = button,
					$temp$mover = mover,
					$temp$instruction = rest;
				current = $temp$current;
				mover = $temp$mover;
				instruction = $temp$instruction;
				continue follow;
			} else {
				return current;
			}
		}
	});
var $author$project$Y16D02$translate = F4(
	function (current, buttons, mover, instructions) {
		translate:
		while (true) {
			if (instructions.b) {
				var instruction = instructions.a;
				var remainingInstructions = instructions.b;
				var button = A3($author$project$Y16D02$follow, current, mover, instruction);
				var newButtons = A2($elm$core$List$cons, button, buttons);
				var $temp$current = button,
					$temp$buttons = newButtons,
					$temp$mover = mover,
					$temp$instructions = remainingInstructions;
				current = $temp$current;
				buttons = $temp$buttons;
				mover = $temp$mover;
				instructions = $temp$instructions;
				continue translate;
			} else {
				return $elm$core$List$reverse(buttons);
			}
		}
	});
var $author$project$Y16D02$answer = F2(
	function (part, input) {
		var instructions = $author$project$Y16D02$parse(input);
		return (part === 1) ? $elm$core$String$fromList(
			A4($author$project$Y16D02$translate, $author$project$Y16D02$init, _List_Nil, $author$project$Y16D02$move1, instructions)) : $elm$core$String$fromList(
			A4($author$project$Y16D02$translate, $author$project$Y16D02$init, _List_Nil, $author$project$Y16D02$move2, instructions));
	});
var $author$project$Y16D03$convertToInt = function (item) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(
			A2($elm$core$Maybe$withDefault, '0', item)));
};
var $author$project$Y16D03$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$elm$core$List$map($author$project$Y16D03$convertToInt),
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('(\\d+) +(\\d+) +(\\d+)'),
				input)));
};
var $author$project$Y16D03$ok = function (triangle) {
	if (((triangle.b && triangle.b.b) && triangle.b.b.b) && (!triangle.b.b.b.b)) {
		var s1 = triangle.a;
		var _v1 = triangle.b;
		var s2 = _v1.a;
		var _v2 = _v1.b;
		var s3 = _v2.a;
		return (_Utils_cmp(s1 + s2, s3) > 0) ? 1 : 0;
	} else {
		return 0;
	}
};
var $author$project$Y16D03$count = function (triangles) {
	if (!triangles.b) {
		return 0;
	} else {
		var triangle = triangles.a;
		var rest = triangles.b;
		return $author$project$Y16D03$ok(triangle) + $author$project$Y16D03$count(rest);
	}
};
var $elm$core$List$sortBy = _List_sortBy;
var $elm$core$List$sort = function (xs) {
	return A2($elm$core$List$sortBy, $elm$core$Basics$identity, xs);
};
var $author$project$Y16D03$process = function (triangles) {
	return $elm$core$String$fromInt(
		$author$project$Y16D03$count(
			A2($elm$core$List$map, $elm$core$List$sort, triangles)));
};
var $author$project$Y16D03$rearrange = F4(
	function (a1, a2, a3, horizontals) {
		rearrange:
		while (true) {
			if ($elm$core$List$length(a1) >= 3) {
				return _Utils_ap(
					_List_fromArray(
						[a1, a2, a3]),
					A4($author$project$Y16D03$rearrange, _List_Nil, _List_Nil, _List_Nil, horizontals));
			} else {
				if (!horizontals.b) {
					return _List_Nil;
				} else {
					if (((horizontals.a.b && horizontals.a.b.b) && horizontals.a.b.b.b) && (!horizontals.a.b.b.b.b)) {
						var _v1 = horizontals.a;
						var s1 = _v1.a;
						var _v2 = _v1.b;
						var s2 = _v2.a;
						var _v3 = _v2.b;
						var s3 = _v3.a;
						var rest = horizontals.b;
						var b3 = A2($elm$core$List$cons, s3, a3);
						var b2 = A2($elm$core$List$cons, s2, a2);
						var b1 = A2($elm$core$List$cons, s1, a1);
						var $temp$a1 = b1,
							$temp$a2 = b2,
							$temp$a3 = b3,
							$temp$horizontals = rest;
						a1 = $temp$a1;
						a2 = $temp$a2;
						a3 = $temp$a3;
						horizontals = $temp$horizontals;
						continue rearrange;
					} else {
						var rest = horizontals.b;
						var $temp$a1 = a1,
							$temp$a2 = a2,
							$temp$a3 = a3,
							$temp$horizontals = rest;
						a1 = $temp$a1;
						a2 = $temp$a2;
						a3 = $temp$a3;
						horizontals = $temp$horizontals;
						continue rearrange;
					}
				}
			}
		}
	});
var $author$project$Y16D03$answer = F2(
	function (part, input) {
		var horizontals = $author$project$Y16D03$parse(input);
		if (part === 1) {
			return $author$project$Y16D03$process(horizontals);
		} else {
			var verticals = A4($author$project$Y16D03$rearrange, _List_Nil, _List_Nil, _List_Nil, horizontals);
			return $author$project$Y16D03$process(verticals);
		}
	});
var $elm$core$String$reverse = _String_reverse;
var $author$project$Y16D04$decrypt = F3(
	function (shift, accum, string) {
		decrypt:
		while (true) {
			var _v0 = $elm$core$String$uncons(string);
			if (!_v0.$) {
				var _v1 = _v0.a;
				var _char = _v1.a;
				var rest = _v1.b;
				var newChar = (_char === '-') ? ' ' : $elm$core$Char$fromCode(
					97 + A2(
						$elm$core$Basics$modBy,
						26,
						($elm$core$Char$toCode(_char) + shift) - 97));
				var newAccum = A2($elm$core$String$cons, newChar, accum);
				var $temp$shift = shift,
					$temp$accum = newAccum,
					$temp$string = rest;
				shift = $temp$shift;
				accum = $temp$accum;
				string = $temp$string;
				continue decrypt;
			} else {
				return $elm$core$String$reverse(accum);
			}
		}
	});
var $author$project$Y16D04$northPole = function (room) {
	var name = A3($author$project$Y16D04$decrypt, room.az, '', room.bt);
	return A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('northpole object'),
		name);
};
var $author$project$Y16D04$Room = F3(
	function (name, sector, checksum) {
		return {bi: checksum, bt: name, az: sector};
	});
var $author$project$Y16D04$convertToMaybeRoom = function (matches) {
	if ((((((matches.b && (!matches.a.$)) && matches.b.b) && (!matches.b.a.$)) && matches.b.b.b) && (!matches.b.b.a.$)) && (!matches.b.b.b.b)) {
		var name = matches.a.a;
		var _v1 = matches.b;
		var sector = _v1.a.a;
		var _v2 = _v1.b;
		var check = _v2.a.a;
		return $elm$core$Maybe$Just(
			A3(
				$author$project$Y16D04$Room,
				name,
				A2(
					$elm$core$Maybe$withDefault,
					0,
					$elm$core$String$toInt(sector)),
				check));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (!_v0.$) {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $author$project$Y16D04$potentialRoom = function (room) {
	if (!room.$) {
		var r = room.a;
		return (r.az > 0) ? $elm$core$Maybe$Just(r) : $elm$core$Maybe$Nothing;
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Y16D04$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		$author$project$Y16D04$potentialRoom,
		A2(
			$elm$core$List$map,
			$author$project$Y16D04$convertToMaybeRoom,
			A2(
				$elm$core$List$map,
				function ($) {
					return $.b2;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('([-a-z]+)-([1-9]\\d*)\\[([a-z]{5})\\]'),
					input))));
};
var $elm$core$List$sortWith = _List_sortWith;
var $author$project$Y16D04$statCompare = F2(
	function (_v0, _v1) {
		var char1 = _v0.a;
		var int1 = _v0.b;
		var char2 = _v1.a;
		var int2 = _v1.b;
		return _Utils_eq(int1, int2) ? A2($elm$core$Basics$compare, char1, char2) : A2($elm$core$Basics$compare, int2, int1);
	});
var $author$project$Y16D04$insert = function (count) {
	if (!count.$) {
		var c = count.a;
		return $elm$core$Maybe$Just(c + 1);
	} else {
		return $elm$core$Maybe$Just(1);
	}
};
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === -1) {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === -1) {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (!_v0.$) {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $author$project$Y16D04$stats = F2(
	function (name, dict) {
		stats:
		while (true) {
			var _v0 = $elm$core$String$uncons(name);
			if (!_v0.$) {
				var _v1 = _v0.a;
				var _char = _v1.a;
				var rest = _v1.b;
				var newDict = (_char === '-') ? dict : A3($elm$core$Dict$update, _char, $author$project$Y16D04$insert, dict);
				var $temp$name = rest,
					$temp$dict = newDict;
				name = $temp$name;
				dict = $temp$dict;
				continue stats;
			} else {
				return dict;
			}
		}
	});
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $author$project$Y16D04$checksum = function (room) {
	var dict = A2($author$project$Y16D04$stats, room.bt, $elm$core$Dict$empty);
	var list = A2(
		$elm$core$List$take,
		5,
		A2(
			$elm$core$List$sortWith,
			$author$project$Y16D04$statCompare,
			$elm$core$Dict$toList(dict)));
	return $elm$core$String$fromList(
		A2($elm$core$List$map, $elm$core$Tuple$first, list));
};
var $author$project$Y16D04$realRoom = function (room) {
	return _Utils_eq(
		room.bi,
		$author$project$Y16D04$checksum(room));
};
var $author$project$Y16D04$answer = F2(
	function (part, input) {
		var rooms = $author$project$Y16D04$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$List$sum(
				A2(
					$elm$core$List$map,
					function ($) {
						return $.az;
					},
					A2($elm$core$List$filter, $author$project$Y16D04$realRoom, rooms)))) : $elm$core$String$fromInt(
			$elm$core$List$sum(
				A2(
					$elm$core$List$map,
					function ($) {
						return $.az;
					},
					A2($elm$core$List$filter, $author$project$Y16D04$northPole, rooms))));
	});
var $author$project$Y16D05$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'error',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('[a-z]+'),
					input))));
};
var $author$project$Y16D05$zeros = '00000';
var $author$project$Y16D05$zLen = $elm$core$String$length($author$project$Y16D05$zeros);
var $author$project$Y16D05$password1 = F3(
	function (doorId, index, accum) {
		password1:
		while (true) {
			if ($elm$core$String$length(accum) >= 8) {
				return $elm$core$String$reverse(accum);
			} else {
				var newIndex = index + 1;
				var digest = $truqu$elm_md5$MD5$hex(
					_Utils_ap(
						doorId,
						$elm$core$String$fromInt(index)));
				var newAccum = function () {
					if (A2($elm$core$String$startsWith, $author$project$Y16D05$zeros, digest)) {
						var _v0 = $elm$core$String$uncons(
							A2($elm$core$String$dropLeft, $author$project$Y16D05$zLen, digest));
						if (!_v0.$) {
							var _v1 = _v0.a;
							var c = _v1.a;
							return A2($elm$core$String$cons, c, accum);
						} else {
							return A2($elm$core$String$cons, '-', accum);
						}
					} else {
						return accum;
					}
				}();
				var $temp$doorId = doorId,
					$temp$index = newIndex,
					$temp$accum = newAccum;
				doorId = $temp$doorId;
				index = $temp$index;
				accum = $temp$accum;
				continue password1;
			}
		}
	});
var $author$project$Y16D05$password2 = F3(
	function (doorId, index, accum) {
		password2:
		while (true) {
			if (!A2(
				$elm$core$List$member,
				$elm$core$Maybe$Nothing,
				$elm$core$Array$toList(accum))) {
				return A2(
					$elm$core$String$join,
					'',
					A2(
						$elm$core$List$map,
						$elm$core$Maybe$withDefault('-'),
						$elm$core$Array$toList(accum)));
			} else {
				var newIndex = index + 1;
				var digest = $truqu$elm_md5$MD5$hex(
					_Utils_ap(
						doorId,
						$elm$core$String$fromInt(index)));
				var newAccum = function () {
					if (A2($elm$core$String$startsWith, $author$project$Y16D05$zeros, digest)) {
						var rest = A2($elm$core$String$dropLeft, $author$project$Y16D05$zLen, digest);
						var _char = function () {
							var _v4 = $elm$core$String$uncons(rest);
							if (!_v4.$) {
								var _v5 = _v4.a;
								var c = _v5.a;
								return c;
							} else {
								return '-';
							}
						}();
						var ind = A2(
							$elm$core$Maybe$withDefault,
							-1,
							$elm$core$String$toInt(
								$elm$core$String$fromChar(_char)));
						if ((ind >= 0) && (ind < 8)) {
							var _v0 = A2($elm$core$Array$get, ind, accum);
							if ((!_v0.$) && (_v0.a.$ === 1)) {
								var _v1 = _v0.a;
								var item = function () {
									var _v2 = $elm$core$String$uncons(
										A2($elm$core$String$dropLeft, 1, rest));
									if (!_v2.$) {
										var _v3 = _v2.a;
										var c = _v3.a;
										return $elm$core$Maybe$Just(
											$elm$core$String$fromChar(c));
									} else {
										return $elm$core$Maybe$Just('-');
									}
								}();
								return A3($elm$core$Array$set, ind, item, accum);
							} else {
								return accum;
							}
						} else {
							return accum;
						}
					} else {
						return accum;
					}
				}();
				var $temp$doorId = doorId,
					$temp$index = newIndex,
					$temp$accum = newAccum;
				doorId = $temp$doorId;
				index = $temp$index;
				accum = $temp$accum;
				continue password2;
			}
		}
	});
var $author$project$Y16D05$answer = F2(
	function (part, input) {
		var doorId = $author$project$Y16D05$parse(input);
		return (part === 1) ? A3($author$project$Y16D05$password1, doorId, 0, '') : A3(
			$author$project$Y16D05$password2,
			doorId,
			0,
			A2($elm$core$Array$repeat, 8, $elm$core$Maybe$Nothing));
	});
var $author$project$Y16D06$Least = 1;
var $author$project$Y16D06$Most = 0;
var $author$project$Y16D06$addToDicts = F3(
	function (message, index, dicts) {
		addToDicts:
		while (true) {
			if (message === '') {
				return dicts;
			} else {
				var maybeDict = A2($elm$core$Array$get, index, dicts);
				var _v0 = A2(
					$elm$core$Maybe$withDefault,
					_Utils_Tuple2('-', ''),
					$elm$core$String$uncons(message));
				var _char = _v0.a;
				var rest = _v0.b;
				var newDicts = function () {
					if (maybeDict.$ === 1) {
						return dicts;
					} else {
						var dict = maybeDict.a;
						var newDict = function () {
							var _v2 = A2($elm$core$Dict$get, _char, dict);
							if (_v2.$ === 1) {
								return A3($elm$core$Dict$insert, _char, 1, dict);
							} else {
								var n = _v2.a;
								return A3($elm$core$Dict$insert, _char, n + 1, dict);
							}
						}();
						return A3($elm$core$Array$set, index, newDict, dicts);
					}
				}();
				var $temp$message = rest,
					$temp$index = index + 1,
					$temp$dicts = newDicts;
				message = $temp$message;
				index = $temp$index;
				dicts = $temp$dicts;
				continue addToDicts;
			}
		}
	});
var $author$project$Y16D06$choose = F2(
	function (frequency, sortedList) {
		if (!frequency) {
			return $elm$core$List$reverse(sortedList);
		} else {
			return sortedList;
		}
	});
var $author$project$Y16D06$pick = F2(
	function (frequency, dict) {
		return $elm$core$String$fromChar(
			A2(
				$elm$core$Maybe$withDefault,
				_Utils_Tuple2('-', 0),
				$elm$core$List$head(
					A2(
						$author$project$Y16D06$choose,
						frequency,
						A2(
							$elm$core$List$sortBy,
							$elm$core$Tuple$second,
							$elm$core$Dict$toList(dict))))).a);
	});
var $author$project$Y16D06$decrypt_ = F3(
	function (messages, frequency, dicts) {
		decrypt_:
		while (true) {
			if (!messages.b) {
				return A2(
					$elm$core$String$join,
					'',
					A2(
						$elm$core$List$map,
						$author$project$Y16D06$pick(frequency),
						$elm$core$Array$toList(dicts)));
			} else {
				var message = messages.a;
				var rest = messages.b;
				var newDicts = A3($author$project$Y16D06$addToDicts, message, 0, dicts);
				var $temp$messages = rest,
					$temp$frequency = frequency,
					$temp$dicts = newDicts;
				messages = $temp$messages;
				frequency = $temp$frequency;
				dicts = $temp$dicts;
				continue decrypt_;
			}
		}
	});
var $author$project$Y16D06$decrypt = F2(
	function (messages, frequency) {
		var width = $elm$core$String$length(
			A2(
				$elm$core$Maybe$withDefault,
				'',
				$elm$core$List$head(messages)));
		var dicts = A2($elm$core$Array$repeat, width, $elm$core$Dict$empty);
		return A3($author$project$Y16D06$decrypt_, messages, frequency, dicts);
	});
var $author$project$Y16D06$parse = function (input) {
	return A2(
		$elm$core$List$map,
		function ($) {
			return $.bY;
		},
		A2(
			$elm$regex$Regex$find,
			$author$project$Util$regex('[a-z]+'),
			input));
};
var $author$project$Y16D06$answer = F2(
	function (part, input) {
		var messages = $author$project$Y16D06$parse(input);
		return (part === 1) ? A2($author$project$Y16D06$decrypt, messages, 0) : A2($author$project$Y16D06$decrypt, messages, 1);
	});
var $author$project$Y16D07$parse = function (input) {
	return A2(
		$elm$core$List$map,
		function ($) {
			return $.bY;
		},
		A2(
			$elm$regex$Regex$find,
			$author$project$Util$regex('[a-z\\[\\]]+'),
			input));
};
var $author$project$Y16D07$fragments = F2(
	function (matcher, address) {
		return A2(
			$elm$core$List$map,
			$elm$core$Maybe$withDefault(''),
			A2(
				$elm$core$List$map,
				$elm$core$Maybe$withDefault($elm$core$Maybe$Nothing),
				A2(
					$elm$core$List$map,
					$elm$core$List$head,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.b2;
						},
						A2($elm$regex$Regex$find, matcher, address)))));
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Y16D07$matchExterior = $author$project$Util$regex('(?:^|\\])([a-z]+)(?:\\[|$)');
var $author$project$Y16D07$matchInterior = $author$project$Util$regex('\\[([a-z]+)\\]');
var $elm_community$list_extra$List$Extra$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				if (accAcc.b) {
					var acc = accAcc.a;
					return A2(
						$elm$core$List$cons,
						A2(f, x, acc),
						accAcc);
				} else {
					return _List_Nil;
				}
			});
		return $elm$core$List$reverse(
			A3(
				$elm$core$List$foldl,
				scan1,
				_List_fromArray(
					[b]),
				xs));
	});
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $author$project$Y16D07$ssl = function (address) {
	var abaList = function (fragment) {
		return A2(
			$elm$core$List$filter,
			function (a) {
				return !A2(
					$elm$regex$Regex$contains,
					$author$project$Util$regex('^(.)\\1\\1$'),
					a);
			},
			A2(
				$elm$core$List$filter,
				function (a) {
					return A2(
						$elm$regex$Regex$contains,
						$author$project$Util$regex('^(.).\\1$'),
						a);
				},
				A2(
					$elm$core$List$filter,
					function (a) {
						return $elm$core$String$length(a) === 3;
					},
					A2(
						$elm$core$List$map,
						$elm$core$String$fromList,
						A3(
							$elm_community$list_extra$List$Extra$scanl,
							F2(
								function (a, b) {
									return A2(
										$elm$core$List$cons,
										a,
										A2($elm$core$List$take, 2, b));
								}),
							_List_Nil,
							$elm$core$String$toList(fragment))))));
	};
	var abas = $elm$core$List$concat(
		A2(
			$elm$core$List$map,
			abaList,
			A2($author$project$Y16D07$fragments, $author$project$Y16D07$matchExterior, address)));
	if ($elm$core$List$isEmpty(abas)) {
		return false;
	} else {
		var abaToBab = function (aba) {
			var _v0 = $elm$core$String$toList(aba);
			if (((_v0.b && _v0.b.b) && _v0.b.b.b) && (!_v0.b.b.b.b)) {
				var a = _v0.a;
				var _v1 = _v0.b;
				var b = _v1.a;
				var _v2 = _v1.b;
				return $elm$core$String$fromList(
					_List_fromArray(
						[b, a, b]));
			} else {
				return '---';
			}
		};
		var babs = A2($elm$core$List$map, abaToBab, abas);
		var hasBab = function (fragment) {
			return A2(
				$elm$core$List$any,
				function (b) {
					return A2($elm$core$String$contains, b, fragment);
				},
				babs);
		};
		return A2(
			$elm$core$List$any,
			hasBab,
			A2($author$project$Y16D07$fragments, $author$project$Y16D07$matchInterior, address));
	}
};
var $author$project$Y16D07$tls = function (address) {
	var hasAbba = function (fragment) {
		var abbas = A2(
			$elm$core$List$filter,
			function (s) {
				return !A2(
					$elm$regex$Regex$contains,
					$author$project$Util$regex('^(.)\\1\\1\\1$'),
					s);
			},
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('(.)(.)\\2\\1'),
					fragment)));
		return $elm$core$List$length(abbas) > 0;
	};
	var interiors = A2(
		$elm$core$List$any,
		hasAbba,
		A2($author$project$Y16D07$fragments, $author$project$Y16D07$matchInterior, address));
	var exteriors = A2(
		$elm$core$List$any,
		hasAbba,
		A2($author$project$Y16D07$fragments, $author$project$Y16D07$matchExterior, address));
	return exteriors && (!interiors);
};
var $author$project$Y16D07$answer = F2(
	function (part, input) {
		var addresses = $author$project$Y16D07$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$List$length(
				A2($elm$core$List$filter, $author$project$Y16D07$tls, addresses))) : $elm$core$String$fromInt(
			$elm$core$List$length(
				A2($elm$core$List$filter, $author$project$Y16D07$ssl, addresses)));
	});
var $author$project$Y16D08$count = function (screen) {
	var cnt = function (row) {
		return $elm$core$List$length(
			A2(
				$elm$core$List$filter,
				$elm$core$Basics$identity,
				$elm$core$Array$toList(row)));
	};
	return $elm$core$String$fromInt(
		$elm$core$List$sum(
			A2(
				$elm$core$List$map,
				cnt,
				$elm$core$Array$toList(screen))));
};
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $author$project$Y16D08$rect = F3(
	function (x, y, screen) {
		rect:
		while (true) {
			if (y <= 0) {
				return screen;
			} else {
				var newRow = $elm$core$Array$fromList(
					_Utils_ap(
						A2($elm$core$List$repeat, x, true),
						A2(
							$elm$core$List$drop,
							x,
							$elm$core$Array$toList(
								A2(
									$elm$core$Maybe$withDefault,
									$elm$core$Array$empty,
									A2($elm$core$Array$get, y - 1, screen))))));
				var newScreen = A3($elm$core$Array$set, y - 1, newRow, screen);
				var $temp$x = x,
					$temp$y = y - 1,
					$temp$screen = newScreen;
				x = $temp$x;
				y = $temp$y;
				screen = $temp$screen;
				continue rect;
			}
		}
	});
var $elm$core$Elm$JsArray$map = _JsArray_map;
var $elm$core$Array$map = F2(
	function (func, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = function (node) {
			if (!node.$) {
				var subTree = node.a;
				return $elm$core$Array$SubTree(
					A2($elm$core$Elm$JsArray$map, helper, subTree));
			} else {
				var values = node.a;
				return $elm$core$Array$Leaf(
					A2($elm$core$Elm$JsArray$map, func, values));
			}
		};
		return A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A2($elm$core$Elm$JsArray$map, helper, tree),
			A2($elm$core$Elm$JsArray$map, func, tail));
	});
var $author$project$Y16D08$flipRow = F2(
	function (screen, y) {
		return A2(
			$elm$core$Array$map,
			$elm$core$Maybe$withDefault(false),
			A2(
				$elm$core$Array$map,
				$elm$core$Array$get(y),
				screen));
	});
var $author$project$Y16D08$flipScreen = function (screen) {
	var newRowLen = $elm$core$Array$length(
		A2(
			$elm$core$Maybe$withDefault,
			$elm$core$Array$empty,
			A2($elm$core$Array$get, 0, screen)));
	return $elm$core$Array$fromList(
		A2(
			$elm$core$List$map,
			$author$project$Y16D08$flipRow(screen),
			A2($elm$core$List$range, 0, newRowLen - 1)));
};
var $author$project$Y16D08$rotateRow = F3(
	function (y, r, screen) {
		var oldRow = $elm$core$Array$toList(
			A2(
				$elm$core$Maybe$withDefault,
				$elm$core$Array$empty,
				A2($elm$core$Array$get, y, screen)));
		var len = $elm$core$List$length(oldRow);
		var x = A2($elm$core$Basics$modBy, len, r);
		var newLeft = A2($elm$core$List$drop, len - x, oldRow);
		var newRight = A2($elm$core$List$take, len - x, oldRow);
		var newRow = $elm$core$Array$fromList(
			_Utils_ap(newLeft, newRight));
		return A3($elm$core$Array$set, y, newRow, screen);
	});
var $author$project$Y16D08$rotateCol = F3(
	function (x, r, screen) {
		return $author$project$Y16D08$flipScreen(
			A3(
				$author$project$Y16D08$rotateRow,
				x,
				r,
				$author$project$Y16D08$flipScreen(screen)));
	});
var $author$project$Y16D08$step = F2(
	function (instruction, screen) {
		switch (instruction.$) {
			case 0:
				var x = instruction.a;
				var y = instruction.b;
				return A3($author$project$Y16D08$rect, x, y, screen);
			case 1:
				var x = instruction.a;
				var y = instruction.b;
				return A3($author$project$Y16D08$rotateRow, x, y, screen);
			case 2:
				var x = instruction.a;
				var y = instruction.b;
				return A3($author$project$Y16D08$rotateCol, x, y, screen);
			default:
				return screen;
		}
	});
var $author$project$Y16D08$decode = F2(
	function (instructions, screen) {
		if (!instructions.b) {
			return screen;
		} else {
			var instruction = instructions.a;
			var rest = instructions.b;
			return A2(
				$author$project$Y16D08$decode,
				rest,
				A2($author$project$Y16D08$step, instruction, screen));
		}
	});
var $elm$core$String$concat = function (strings) {
	return A2($elm$core$String$join, '', strings);
};
var $author$project$Y16D08$display = function (screen) {
	var boolToString = function (bool) {
		return bool ? '#' : '.';
	};
	var rowToString = function (row) {
		return $elm$core$String$concat(
			$elm$core$Array$toList(
				A2($elm$core$Array$map, boolToString, row)));
	};
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			rowToString,
			$elm$core$Array$toList(screen)));
};
var $author$project$Y16D08$initialScreen = A2(
	$elm$core$Array$repeat,
	6,
	A2($elm$core$Array$repeat, 50, false));
var $author$project$Y16D08$Col = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$Y16D08$Invalid = {$: 3};
var $author$project$Y16D08$Rect = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Y16D08$Row = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$Y16D08$parseInstruction = function (submatches) {
	var _v0 = function () {
		if ((((((submatches.b && (!submatches.a.$)) && submatches.b.b) && (!submatches.b.a.$)) && submatches.b.b.b) && (!submatches.b.b.a.$)) && (!submatches.b.b.b.b)) {
			var s = submatches.a.a;
			var _v2 = submatches.b;
			var p = _v2.a.a;
			var _v3 = _v2.b;
			var q = _v3.a.a;
			return _Utils_Tuple3(
				s,
				A2(
					$elm$core$Maybe$withDefault,
					0,
					$elm$core$String$toInt(p)),
				A2(
					$elm$core$Maybe$withDefault,
					0,
					$elm$core$String$toInt(q)));
		} else {
			return _Utils_Tuple3('', 0, 0);
		}
	}();
	var string = _v0.a;
	var i = _v0.b;
	var j = _v0.c;
	switch (string) {
		case 'rect ':
			return A2($author$project$Y16D08$Rect, i, j);
		case 'rotate row y=':
			return A2($author$project$Y16D08$Row, i, j);
		case 'rotate column x=':
			return A2($author$project$Y16D08$Col, i, j);
		default:
			return $author$project$Y16D08$Invalid;
	}
};
var $author$project$Y16D08$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y16D08$parseInstruction,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('(rect |rotate (?:row y|column x)=)(\\d+)(?:x| by )(\\d+)'),
				input)));
};
var $author$project$Y16D08$answer = F2(
	function (part, input) {
		var instructions = $author$project$Y16D08$parse(input);
		var screen = A2($author$project$Y16D08$decode, instructions, $author$project$Y16D08$initialScreen);
		return (part === 1) ? $author$project$Y16D08$count(screen) : $author$project$Y16D08$display(screen);
	});
var $author$project$Y16D09$toInt = function (string) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(string));
};
var $author$project$Y16D09$matches = function (string) {
	var m = $elm$core$List$head(
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A3(
				$elm$regex$Regex$findAtMost,
				1,
				$author$project$Util$regex('^([A-Z]*)\\((\\d+)x(\\d+)\\)(.+)$'),
				string)));
	if ((((((((((!m.$) && m.a.b) && (!m.a.a.$)) && m.a.b.b) && (!m.a.b.a.$)) && m.a.b.b.b) && (!m.a.b.b.a.$)) && m.a.b.b.b.b) && (!m.a.b.b.b.a.$)) && (!m.a.b.b.b.b.b)) {
		var _v1 = m.a;
		var c = _v1.a.a;
		var _v2 = _v1.b;
		var l = _v2.a.a;
		var _v3 = _v2.b;
		var n = _v3.a.a;
		var _v4 = _v3.b;
		var r = _v4.a.a;
		return _Utils_Tuple2(
			_Utils_Tuple2(c, r),
			_Utils_Tuple2(
				$author$project$Y16D09$toInt(l),
				$author$project$Y16D09$toInt(n)));
	} else {
		return _Utils_Tuple2(
			_Utils_Tuple2('', ''),
			_Utils_Tuple2(0, 0));
	}
};
var $author$project$Y16D09$decompress = function (string) {
	var _v0 = $author$project$Y16D09$matches(string);
	var _v1 = _v0.a;
	var caps = _v1.a;
	var rest = _v1.b;
	var _v2 = _v0.b;
	var len = _v2.a;
	var num = _v2.b;
	if (rest === '') {
		return string;
	} else {
		var p3 = $author$project$Y16D09$decompress(
			A2($elm$core$String$dropLeft, len, rest));
		var p2 = A2(
			$elm$core$String$repeat,
			num,
			A2($elm$core$String$left, len, rest));
		var p1 = caps;
		return _Utils_ap(
			p1,
			_Utils_ap(p2, p3));
	}
};
var $author$project$Y16D09$decompressedLength = function (string) {
	var _v0 = $author$project$Y16D09$matches(string);
	var _v1 = _v0.a;
	var caps = _v1.a;
	var rest = _v1.b;
	var _v2 = _v0.b;
	var len = _v2.a;
	var num = _v2.b;
	if (rest === '') {
		return $elm$core$String$length(string);
	} else {
		var p3 = $author$project$Y16D09$decompressedLength(
			A2($elm$core$String$dropLeft, len, rest));
		var p2 = $author$project$Y16D09$decompressedLength(
			A2(
				$elm$core$String$repeat,
				num,
				A2($elm$core$String$left, len, rest)));
		var p1 = $elm$core$String$length(caps);
		return (p1 + p2) + p3;
	}
};
var $author$project$Y16D09$parse = function (input) {
	return A3(
		$elm$regex$Regex$replace,
		$author$project$Util$regex('\\s'),
		function (_v0) {
			return '';
		},
		input);
};
var $author$project$Y16D09$answer = F2(
	function (part, input) {
		var file = $author$project$Y16D09$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$String$length(
				$author$project$Y16D09$decompress(file))) : $elm$core$String$fromInt(
			$author$project$Y16D09$decompressedLength(file));
	});
var $author$project$Y16D10$init = $elm$core$Dict$empty;
var $author$project$Y16D10$lookfor = F2(
	function (match, idLists) {
		lookfor:
		while (true) {
			if (!idLists.b) {
				return 'none';
			} else {
				var _v1 = idLists.a;
				var id = _v1.a;
				var list = _v1.b;
				var rest = idLists.b;
				if (_Utils_eq(
					A2(
						$elm$core$String$join,
						'-',
						A2($elm$core$List$map, $elm$core$String$fromInt, list)),
					match) && A2($elm$core$String$startsWith, 'bot ', id)) {
					return id;
				} else {
					var $temp$match = match,
						$temp$idLists = rest;
					match = $temp$match;
					idLists = $temp$idLists;
					continue lookfor;
				}
			}
		}
	});
var $author$project$Y16D10$multiply = F3(
	function (num, state, ids) {
		multiply:
		while (true) {
			if (!ids.b) {
				return num;
			} else {
				var id = ids.a;
				var rest = ids.b;
				var output = 'output ' + $elm$core$String$fromInt(id);
				var chips = A2(
					$elm$core$Maybe$withDefault,
					_List_Nil,
					A2($elm$core$Dict$get, output, state));
				var newNum = num * $elm$core$List$product(chips);
				var $temp$num = newNum,
					$temp$state = state,
					$temp$ids = rest;
				num = $temp$num;
				state = $temp$state;
				ids = $temp$ids;
				continue multiply;
			}
		}
	});
var $author$project$Y16D10$parse = function (input) {
	var specific = 'value (\\d+) goes to ((?:bot|output) \\d+)';
	var highLow = '(bot \\d+) gives low to ((?:bot|output) \\d+) and high to ((?:bot|output) \\d+)';
	var pattern = highLow + ('|' + specific);
	return A2(
		$elm$core$List$map,
		function ($) {
			return $.b2;
		},
		A2(
			$elm$regex$Regex$find,
			$author$project$Util$regex(pattern),
			input));
};
var $author$project$Y16D10$process = F2(
	function (matches, state) {
		process:
		while (true) {
			if (!matches.b) {
				return state;
			} else {
				var match = matches.a;
				var rest = matches.b;
				_v1$2:
				while (true) {
					if (match.b) {
						if (!match.a.$) {
							if ((((((((match.b.b && (!match.b.a.$)) && match.b.b.b) && (!match.b.b.a.$)) && match.b.b.b.b) && (match.b.b.b.a.$ === 1)) && match.b.b.b.b.b) && (match.b.b.b.b.a.$ === 1)) && (!match.b.b.b.b.b.b)) {
								var bot = match.a.a;
								var _v2 = match.b;
								var lowTarget = _v2.a.a;
								var _v3 = _v2.b;
								var highTarget = _v3.a.a;
								var _v4 = _v3.b;
								var _v5 = _v4.a;
								var _v6 = _v4.b;
								var _v7 = _v6.a;
								var chips = A2(
									$elm$core$Maybe$withDefault,
									_List_Nil,
									A2($elm$core$Dict$get, bot, state));
								var newMatches = function () {
									if ((chips.b && chips.b.b) && (!chips.b.b.b)) {
										var low = chips.a;
										var _v11 = chips.b;
										var high = _v11.a;
										return rest;
									} else {
										return $elm$core$List$reverse(
											A2(
												$elm$core$List$cons,
												match,
												$elm$core$List$reverse(rest)));
									}
								}();
								var newState = function () {
									if ((chips.b && chips.b.b) && (!chips.b.b.b)) {
										var low = chips.a;
										var _v9 = chips.b;
										var high = _v9.a;
										var lowChips = A2(
											$elm$core$Maybe$withDefault,
											_List_Nil,
											A2($elm$core$Dict$get, lowTarget, state));
										var highChips = A2(
											$elm$core$Maybe$withDefault,
											_List_Nil,
											A2($elm$core$Dict$get, highTarget, state));
										return A3(
											$elm$core$Dict$insert,
											highTarget,
											$elm$core$List$sort(
												A2($elm$core$List$cons, high, highChips)),
											A3(
												$elm$core$Dict$insert,
												lowTarget,
												$elm$core$List$sort(
													A2($elm$core$List$cons, low, lowChips)),
												state));
									} else {
										return state;
									}
								}();
								var $temp$matches = newMatches,
									$temp$state = newState;
								matches = $temp$matches;
								state = $temp$state;
								continue process;
							} else {
								break _v1$2;
							}
						} else {
							if ((((((((match.b.b && (match.b.a.$ === 1)) && match.b.b.b) && (match.b.b.a.$ === 1)) && match.b.b.b.b) && (!match.b.b.b.a.$)) && match.b.b.b.b.b) && (!match.b.b.b.b.a.$)) && (!match.b.b.b.b.b.b)) {
								var _v12 = match.a;
								var _v13 = match.b;
								var _v14 = _v13.a;
								var _v15 = _v13.b;
								var _v16 = _v15.a;
								var _v17 = _v15.b;
								var value = _v17.a.a;
								var _v18 = _v17.b;
								var target = _v18.a.a;
								var chips = A2(
									$elm$core$Maybe$withDefault,
									_List_Nil,
									A2($elm$core$Dict$get, target, state));
								var newChips = $elm$core$List$sort(
									function (i) {
										return A2($elm$core$List$cons, i, chips);
									}(
										A2(
											$elm$core$Maybe$withDefault,
											0,
											$elm$core$String$toInt(value))));
								var newState = A3($elm$core$Dict$insert, target, newChips, state);
								var $temp$matches = rest,
									$temp$state = newState;
								matches = $temp$matches;
								state = $temp$state;
								continue process;
							} else {
								break _v1$2;
							}
						}
					} else {
						break _v1$2;
					}
				}
				var $temp$matches = rest,
					$temp$state = state;
				matches = $temp$matches;
				state = $temp$state;
				continue process;
			}
		}
	});
var $author$project$Y16D10$answer = F2(
	function (part, input) {
		var matches = $author$project$Y16D10$parse(input);
		var state = A2($author$project$Y16D10$process, matches, $author$project$Y16D10$init);
		return (part === 1) ? A2(
			$author$project$Y16D10$lookfor,
			'17-61',
			$elm$core$Dict$toList(state)) : $elm$core$String$fromInt(
			A3(
				$author$project$Y16D10$multiply,
				1,
				state,
				_List_fromArray(
					[0, 1, 2])));
	});
var $author$project$Y16D11$answer = F2(
	function (part, input) {
		return $author$project$Util$failed;
	});
var $author$project$Y16D12$get = F2(
	function (reg, state) {
		return A2(
			$elm$core$Maybe$withDefault,
			0,
			A2($elm$core$Dict$get, reg, state.v));
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $author$project$Y16D12$initState = F2(
	function (c, instructions) {
		return {
			bq: 0,
			aq: instructions,
			v: $elm$core$Dict$fromList(
				_List_fromArray(
					[
						_Utils_Tuple2('a', 0),
						_Utils_Tuple2('b', 0),
						_Utils_Tuple2('c', c),
						_Utils_Tuple2('d', 0)
					]))
		};
	});
var $author$project$Y16D12$CpyI = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Y16D12$CpyR = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$Y16D12$Dec = function (a) {
	return {$: 2, a: a};
};
var $author$project$Y16D12$Inc = function (a) {
	return {$: 3, a: a};
};
var $author$project$Y16D12$Invalid = {$: 6};
var $author$project$Y16D12$JnzI = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $author$project$Y16D12$JnzR = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var $author$project$Y16D12$parseMatches = function (matches) {
	_v0$4:
	while (true) {
		if (matches.b) {
			if (!matches.a.$) {
				if ((((((((((matches.b.b && (!matches.b.a.$)) && matches.b.b.b) && (matches.b.b.a.$ === 1)) && matches.b.b.b.b) && (matches.b.b.b.a.$ === 1)) && matches.b.b.b.b.b) && (matches.b.b.b.b.a.$ === 1)) && matches.b.b.b.b.b.b) && (matches.b.b.b.b.b.a.$ === 1)) && (!matches.b.b.b.b.b.b.b)) {
					var numOrReg = matches.a.a;
					var _v1 = matches.b;
					var reg = _v1.a.a;
					var _v2 = _v1.b;
					var _v3 = _v2.a;
					var _v4 = _v2.b;
					var _v5 = _v4.a;
					var _v6 = _v4.b;
					var _v7 = _v6.a;
					var _v8 = _v6.b;
					var _v9 = _v8.a;
					var _v10 = $elm$core$String$toInt(numOrReg);
					if (!_v10.$) {
						var num = _v10.a;
						return A2($author$project$Y16D12$CpyI, num, reg);
					} else {
						return A2($author$project$Y16D12$CpyR, numOrReg, reg);
					}
				} else {
					break _v0$4;
				}
			} else {
				if ((matches.b.b && (matches.b.a.$ === 1)) && matches.b.b.b) {
					if (!matches.b.b.a.$) {
						if ((((((matches.b.b.b.b && (matches.b.b.b.a.$ === 1)) && matches.b.b.b.b.b) && (matches.b.b.b.b.a.$ === 1)) && matches.b.b.b.b.b.b) && (matches.b.b.b.b.b.a.$ === 1)) && (!matches.b.b.b.b.b.b.b)) {
							var _v11 = matches.a;
							var _v12 = matches.b;
							var _v13 = _v12.a;
							var _v14 = _v12.b;
							var reg = _v14.a.a;
							var _v15 = _v14.b;
							var _v16 = _v15.a;
							var _v17 = _v15.b;
							var _v18 = _v17.a;
							var _v19 = _v17.b;
							var _v20 = _v19.a;
							return $author$project$Y16D12$Inc(reg);
						} else {
							break _v0$4;
						}
					} else {
						if (matches.b.b.b.b) {
							if (!matches.b.b.b.a.$) {
								if ((((matches.b.b.b.b.b && (matches.b.b.b.b.a.$ === 1)) && matches.b.b.b.b.b.b) && (matches.b.b.b.b.b.a.$ === 1)) && (!matches.b.b.b.b.b.b.b)) {
									var _v21 = matches.a;
									var _v22 = matches.b;
									var _v23 = _v22.a;
									var _v24 = _v22.b;
									var _v25 = _v24.a;
									var _v26 = _v24.b;
									var reg = _v26.a.a;
									var _v27 = _v26.b;
									var _v28 = _v27.a;
									var _v29 = _v27.b;
									var _v30 = _v29.a;
									return $author$project$Y16D12$Dec(reg);
								} else {
									break _v0$4;
								}
							} else {
								if ((((matches.b.b.b.b.b && (!matches.b.b.b.b.a.$)) && matches.b.b.b.b.b.b) && (!matches.b.b.b.b.b.a.$)) && (!matches.b.b.b.b.b.b.b)) {
									var _v31 = matches.a;
									var _v32 = matches.b;
									var _v33 = _v32.a;
									var _v34 = _v32.b;
									var _v35 = _v34.a;
									var _v36 = _v34.b;
									var _v37 = _v36.a;
									var _v38 = _v36.b;
									var numOrReg = _v38.a.a;
									var _v39 = _v38.b;
									var num = _v39.a.a;
									var jmp = A2(
										$elm$core$Maybe$withDefault,
										0,
										$elm$core$String$toInt(num));
									var _v40 = $elm$core$String$toInt(numOrReg);
									if (!_v40.$) {
										var nm = _v40.a;
										return A2($author$project$Y16D12$JnzI, nm, jmp);
									} else {
										return A2($author$project$Y16D12$JnzR, numOrReg, jmp);
									}
								} else {
									break _v0$4;
								}
							}
						} else {
							break _v0$4;
						}
					}
				} else {
					break _v0$4;
				}
			}
		} else {
			break _v0$4;
		}
	}
	return $author$project$Y16D12$Invalid;
};
var $author$project$Y16D12$parse = function (input) {
	return $elm$core$Array$fromList(
		A2(
			$elm$core$List$map,
			$author$project$Y16D12$parseMatches,
			A2(
				$elm$core$List$map,
				function ($) {
					return $.b2;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('cpy ([abcd]|-?\\d+) ([abcd])|inc ([abcd])|dec ([abcd])|jnz ([abcd]|-?\\d+) (-?\\d+)'),
					input))));
};
var $author$project$Y16D12$set = F3(
	function (reg, state, val) {
		return A3($elm$core$Dict$insert, reg, val, state.v);
	});
var $author$project$Y16D12$process = function (state) {
	process:
	while (true) {
		var instruction = A2(
			$elm$core$Maybe$withDefault,
			$author$project$Y16D12$Invalid,
			A2($elm$core$Array$get, state.bq, state.aq));
		if (_Utils_eq(instruction, $author$project$Y16D12$Invalid)) {
			return state;
		} else {
			var registers = function () {
				switch (instruction.$) {
					case 0:
						var _int = instruction.a;
						var reg = instruction.b;
						return A3($author$project$Y16D12$set, reg, state, _int);
					case 1:
						var reg1 = instruction.a;
						var reg2 = instruction.b;
						return A3(
							$author$project$Y16D12$set,
							reg2,
							state,
							A2($author$project$Y16D12$get, reg1, state));
					case 3:
						var reg = instruction.a;
						return A3(
							$author$project$Y16D12$set,
							reg,
							state,
							1 + A2($author$project$Y16D12$get, reg, state));
					case 2:
						var reg = instruction.a;
						return A3(
							$author$project$Y16D12$set,
							reg,
							state,
							(-1) + A2($author$project$Y16D12$get, reg, state));
					default:
						return state.v;
				}
			}();
			var index = function () {
				var _default = state.bq + 1;
				switch (instruction.$) {
					case 5:
						var reg = instruction.a;
						var jmp = instruction.b;
						return ((!A2($author$project$Y16D12$get, reg, state)) || (!jmp)) ? _default : (state.bq + jmp);
					case 4:
						var _int = instruction.a;
						var jmp = instruction.b;
						return ((!_int) || (!jmp)) ? _default : (state.bq + jmp);
					default:
						return _default;
				}
			}();
			var $temp$state = _Utils_update(
				state,
				{bq: index, v: registers});
			state = $temp$state;
			continue process;
		}
	}
};
var $author$project$Y16D12$answer = F2(
	function (part, input) {
		var c = (part === 1) ? 0 : 1;
		return $elm$core$String$fromInt(
			A2(
				$author$project$Y16D12$get,
				'a',
				$author$project$Y16D12$process(
					A2(
						$author$project$Y16D12$initState,
						c,
						$author$project$Y16D12$parse(input)))));
	});
var $author$project$Y16D13$Cell = F3(
	function (x, y, d) {
		return {aM: d, H: x, I: y};
	});
var $elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3($elm$core$String$slice, 0, -n, string);
	});
var $author$project$Y16D13$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(
			A2($elm$core$String$dropRight, 1, input)));
};
var $author$project$Y16D13$toBinary = function (num) {
	switch (num) {
		case 0:
			return '0';
		case 1:
			return '1';
		default:
			var r = A2($elm$core$Basics$modBy, 2, num);
			var q = (num / 2) | 0;
			return _Utils_ap(
				$author$project$Y16D13$toBinary(q),
				$author$project$Y16D13$toBinary(r));
	}
};
var $author$project$Y16D13$open = F2(
	function (fav, cell) {
		var y = cell.I;
		var x = cell.H;
		var num = (((((x * x) + (3 * x)) + ((2 * x) * y)) + y) + (y * y)) + fav;
		var ones = $elm$core$List$length(
			A2(
				$elm$core$List$filter,
				function (c) {
					return c === '1';
				},
				$elm$core$String$toList(
					$author$project$Y16D13$toBinary(num))));
		return !A2($elm$core$Basics$modBy, 2, ones);
	});
var $author$project$Y16D13$same = F2(
	function (c1, c2) {
		return _Utils_eq(c1.H, c2.H) && _Utils_eq(c1.I, c2.I);
	});
var $author$project$Y16D13$getNeighbours = F3(
	function (fav, visited, cell) {
		var notSeenBefore = function (neighbour) {
			return !A2(
				$elm$core$List$any,
				$author$project$Y16D13$same(neighbour),
				visited);
		};
		var _new = F2(
			function (old, move) {
				return A3($author$project$Y16D13$Cell, old.H + move.a, old.I + move.b, old.aM + 1);
			});
		var moves = _List_fromArray(
			[
				_Utils_Tuple2(1, 0),
				_Utils_Tuple2(0, 1),
				_Utils_Tuple2(-1, 0),
				_Utils_Tuple2(0, -1)
			]);
		var inBounds = function (neighbour) {
			return (neighbour.H >= 0) && (neighbour.I >= 0);
		};
		return A2(
			$elm$core$List$filter,
			notSeenBefore,
			A2(
				$elm$core$List$filter,
				$author$project$Y16D13$open(fav),
				A2(
					$elm$core$List$filter,
					inBounds,
					A2(
						$elm$core$List$map,
						_new(cell),
						moves))));
	});
var $author$project$Y16D13$start = {aM: 0, H: 1, I: 1};
var $author$project$Y16D13$search = F5(
	function (part, fav, finish, visited, queue) {
		search:
		while (true) {
			if (!queue.b) {
				return 0;
			} else {
				var cell = queue.a;
				var rest = queue.b;
				if ((part === 2) && (cell.aM === 50)) {
					return $elm$core$List$length(visited);
				} else {
					var neighbours = A3($author$project$Y16D13$getNeighbours, fav, visited, cell);
					var goal = A2(
						$elm$core$Maybe$withDefault,
						$author$project$Y16D13$start,
						$elm$core$List$head(
							A2(
								$elm$core$List$filter,
								$author$project$Y16D13$same(finish),
								neighbours)));
					if ((part === 1) && (goal.aM > 0)) {
						return goal.aM;
					} else {
						var $temp$part = part,
							$temp$fav = fav,
							$temp$finish = finish,
							$temp$visited = _Utils_ap(visited, neighbours),
							$temp$queue = _Utils_ap(rest, neighbours);
						part = $temp$part;
						fav = $temp$fav;
						finish = $temp$finish;
						visited = $temp$visited;
						queue = $temp$queue;
						continue search;
					}
				}
			}
		}
	});
var $author$project$Y16D13$answer = F2(
	function (part, input) {
		var finish = A3($author$project$Y16D13$Cell, 31, 39, 0);
		var fav = $author$project$Y16D13$parse(input);
		return $elm$core$String$fromInt(
			A5(
				$author$project$Y16D13$search,
				part,
				fav,
				finish,
				_List_fromArray(
					[$author$project$Y16D13$start]),
				_List_fromArray(
					[$author$project$Y16D13$start])));
	});
var $author$project$Y16D14$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('[a-z]+'),
					input))));
};
var $author$project$Y16D14$repeatHash = F2(
	function (iterations, hash) {
		return (iterations <= 0) ? hash : A2(
			$author$project$Y16D14$repeatHash,
			iterations - 1,
			$truqu$elm_md5$MD5$hex(hash));
	});
var $author$project$Y16D14$getHash = F4(
	function (part, salt, index, cache) {
		var maybeHash = A2($elm$core$Dict$get, index, cache);
		var iterations = (part === 1) ? 0 : 2016;
		var hash = function () {
			if (!maybeHash.$) {
				var h = maybeHash.a;
				return h;
			} else {
				return $truqu$elm_md5$MD5$hex(
					_Utils_ap(
						salt,
						$elm$core$String$fromInt(index)));
			}
		}();
		return A2($author$project$Y16D14$repeatHash, iterations, hash);
	});
var $author$project$Y16D14$buildCache = F6(
	function (part, salt, upto, index, oldCache, cache) {
		buildCache:
		while (true) {
			if (_Utils_cmp(index, upto) > 0) {
				return cache;
			} else {
				var newIndex = index + 1;
				var hash = A4($author$project$Y16D14$getHash, part, salt, index, oldCache);
				var newCache = A3($elm$core$Dict$insert, index, hash, cache);
				var $temp$part = part,
					$temp$salt = salt,
					$temp$upto = upto,
					$temp$index = newIndex,
					$temp$oldCache = oldCache,
					$temp$cache = newCache;
				part = $temp$part;
				salt = $temp$salt;
				upto = $temp$upto;
				index = $temp$index;
				oldCache = $temp$oldCache;
				cache = $temp$cache;
				continue buildCache;
			}
		}
	});
var $elm$core$Dict$values = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Y16D14$search = F5(
	function (part, salt, keys, index, cache) {
		search:
		while (true) {
			if (keys >= 64) {
				return $elm$core$String$fromInt(index - 1);
			} else {
				var newIndex = index + 1;
				var hash = A4($author$project$Y16D14$getHash, part, salt, index, cache);
				var maybeMatch3 = $elm$core$List$head(
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bY;
						},
						A3(
							$elm$regex$Regex$findAtMost,
							1,
							$author$project$Util$regex('(.)\\1\\1'),
							hash)));
				if (maybeMatch3.$ === 1) {
					var $temp$part = part,
						$temp$salt = salt,
						$temp$keys = keys,
						$temp$index = newIndex,
						$temp$cache = cache;
					part = $temp$part;
					salt = $temp$salt;
					keys = $temp$keys;
					index = $temp$index;
					cache = $temp$cache;
					continue search;
				} else {
					var match3 = maybeMatch3.a;
					var newCache = A6($author$project$Y16D14$buildCache, part, salt, index + 1000, newIndex, cache, $elm$core$Dict$empty);
					var match5 = A2(
						$elm$core$String$left,
						5,
						A2($elm$core$String$repeat, 2, match3));
					var foundSome = A2(
						$elm$core$List$any,
						$elm$core$String$contains(match5),
						$elm$core$Dict$values(newCache));
					var newKeys = foundSome ? (keys + 1) : keys;
					var $temp$part = part,
						$temp$salt = salt,
						$temp$keys = newKeys,
						$temp$index = newIndex,
						$temp$cache = newCache;
					part = $temp$part;
					salt = $temp$salt;
					keys = $temp$keys;
					index = $temp$index;
					cache = $temp$cache;
					continue search;
				}
			}
		}
	});
var $author$project$Y16D14$answer = F2(
	function (part, input) {
		var salt = $author$project$Y16D14$parse(input);
		return A5($author$project$Y16D14$search, part, salt, 0, 0, $elm$core$Dict$empty);
	});
var $author$project$Y16D15$Disc = F3(
	function (number, positions, position) {
		return {bu: number, aw: position, a5: positions};
	});
var $author$project$Y16D15$invalid = {bu: 0, aw: 0, a5: 1};
var $author$project$Y16D15$toDisc = function (numbers) {
	if (((numbers.b && numbers.b.b) && numbers.b.b.b) && (!numbers.b.b.b.b)) {
		var a = numbers.a;
		var _v1 = numbers.b;
		var b = _v1.a;
		var _v2 = _v1.b;
		var c = _v2.a;
		return A3($author$project$Y16D15$Disc, a, b, c);
	} else {
		return $author$project$Y16D15$invalid;
	}
};
var $author$project$Y16D15$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y16D15$toDisc,
		A2(
			$elm$core$List$map,
			$elm$core$List$map(
				$elm$core$Maybe$withDefault(0)),
			A2(
				$elm$core$List$map,
				$elm$core$List$map($elm$core$String$toInt),
				A2(
					$elm$core$List$map,
					$elm$core$List$map(
						$elm$core$Maybe$withDefault('')),
					A2(
						$elm$core$List$map,
						function ($) {
							return $.b2;
						},
						A2(
							$elm$regex$Regex$find,
							$author$project$Util$regex('Disc #(\\d+) has (\\d+) positions; at time=0, it is at position (\\d+).'),
							input))))));
};
var $author$project$Y16D15$push = F2(
	function (item, list) {
		return $elm$core$List$reverse(
			function (l) {
				return A2($elm$core$List$cons, item, l);
			}(
				$elm$core$List$reverse(list)));
	});
var $author$project$Y16D15$rotate = F2(
	function (time, disc) {
		return _Utils_update(
			disc,
			{
				aw: A2($elm$core$Basics$modBy, disc.a5, disc.aw + time)
			});
	});
var $author$project$Y16D15$initShift = F3(
	function (time, maze, initMaze) {
		initShift:
		while (true) {
			if (!initMaze.b) {
				return maze;
			} else {
				var disc = initMaze.a;
				var rest = initMaze.b;
				var newTime = time + 1;
				var newDisc = A2($author$project$Y16D15$rotate, time, disc);
				var newMaze = A2($author$project$Y16D15$push, newDisc, maze);
				var $temp$time = newTime,
					$temp$maze = newMaze,
					$temp$initMaze = rest;
				time = $temp$time;
				maze = $temp$maze;
				initMaze = $temp$initMaze;
				continue initShift;
			}
		}
	});
var $author$project$Y16D15$advance = function (maze) {
	return A2(
		$elm$core$List$map,
		$author$project$Y16D15$rotate(1),
		maze);
};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			$elm$core$List$any,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
			list);
	});
var $author$project$Y16D15$open = function (maze) {
	return A2(
		$elm$core$List$all,
		function (d) {
			return !d.aw;
		},
		maze);
};
var $author$project$Y16D15$search_ = F2(
	function (time, maze) {
		return $author$project$Y16D15$open(maze) ? time : A2(
			$author$project$Y16D15$search_,
			time + 1,
			$author$project$Y16D15$advance(maze));
	});
var $author$project$Y16D15$search = function (maze) {
	var shiftedMaze = A3($author$project$Y16D15$initShift, 1, _List_Nil, maze);
	return A2($author$project$Y16D15$search_, 0, shiftedMaze);
};
var $author$project$Y16D15$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y16D15$search(
				$author$project$Y16D15$parse(input))) : $elm$core$String$fromInt(
			$author$project$Y16D15$search(
				A2(
					$author$project$Y16D15$push,
					A3($author$project$Y16D15$Disc, 7, 11, 0),
					$author$project$Y16D15$parse(input))));
	});
var $author$project$Y16D16$twoToOne = function (pair) {
	switch (pair) {
		case '11':
			return '1';
		case '00':
			return '1';
		case '10':
			return '0';
		default:
			return '0';
	}
};
var $author$project$Y16D16$checksum_ = function (data) {
	return (A2(
		$elm$core$Basics$modBy,
		2,
		$elm$core$String$length(data)) === 1) ? data : $author$project$Y16D16$checksum_(
		$elm$core$String$concat(
			A2(
				$elm$core$List$map,
				$author$project$Y16D16$twoToOne,
				A2(
					$elm$core$List$map,
					function ($) {
						return $.bY;
					},
					A2(
						$elm$regex$Regex$find,
						$author$project$Util$regex('..'),
						data)))));
};
var $author$project$Y16D16$checksum = F2(
	function (len, data) {
		return $author$project$Y16D16$checksum_(
			A2($elm$core$String$left, len, data));
	});
var $author$project$Y16D16$swap = function (c) {
	return (c === '0') ? '1' : '0';
};
var $author$project$Y16D16$generate = F2(
	function (len, data) {
		generate:
		while (true) {
			if (_Utils_cmp(
				$elm$core$String$length(data),
				len) > -1) {
				return data;
			} else {
				var copy = $elm$core$String$fromList(
					A2(
						$elm$core$List$map,
						$author$project$Y16D16$swap,
						$elm$core$String$toList(
							$elm$core$String$reverse(data))));
				var newData = data + ('0' + copy);
				var $temp$len = len,
					$temp$data = newData;
				len = $temp$len;
				data = $temp$data;
				continue generate;
			}
		}
	});
var $author$project$Y16D16$generateAndChecksum = F2(
	function (len, init) {
		return A2(
			$author$project$Y16D16$checksum,
			len,
			A2($author$project$Y16D16$generate, len, init));
	});
var $author$project$Y16D16$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('[01]+'),
					input))));
};
var $author$project$Y16D16$answer = F2(
	function (part, input) {
		return (part === 1) ? A2(
			$author$project$Y16D16$generateAndChecksum,
			272,
			$author$project$Y16D16$parse(input)) : A2(
			$author$project$Y16D16$generateAndChecksum,
			35651584,
			$author$project$Y16D16$parse(input));
	});
var $author$project$Y16D17$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		'',
		$elm$core$List$head(
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A3(
					$elm$regex$Regex$findAtMost,
					1,
					$author$project$Util$regex('\\S+'),
					input))));
};
var $author$project$Y16D17$found = function (location) {
	return (location.H === 3) && (location.I === 3);
};
var $author$project$Y16D17$Location = F3(
	function (x, y, path) {
		return {av: path, H: x, I: y};
	});
var $author$project$Y16D17$bCode = $elm$core$Char$toCode('b');
var $author$project$Y16D17$fCode = $elm$core$Char$toCode('f');
var $author$project$Y16D17$newLocation = F2(
	function (location, _v0) {
		var index = _v0.a;
		var code = _v0.b;
		if ((_Utils_cmp(code, $author$project$Y16D17$bCode) < 0) || (_Utils_cmp(code, $author$project$Y16D17$fCode) > 0)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v1 = function () {
				switch (index) {
					case 0:
						return _Utils_Tuple3(location.H, location.I - 1, 'U');
					case 1:
						return _Utils_Tuple3(location.H, location.I + 1, 'D');
					case 2:
						return _Utils_Tuple3(location.H - 1, location.I, 'L');
					default:
						return _Utils_Tuple3(location.H + 1, location.I, 'R');
				}
			}();
			var x = _v1.a;
			var y = _v1.b;
			var step = _v1.c;
			return ((x < 0) || ((y < 0) || ((x > 3) || (y > 3)))) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
				A3(
					$author$project$Y16D17$Location,
					x,
					y,
					_Utils_ap(location.av, step)));
		}
	});
var $author$project$Y16D17$newLocations = F2(
	function (passcode, location) {
		return A2(
			$elm$core$List$filterMap,
			$author$project$Y16D17$newLocation(location),
			A2(
				$elm$core$List$indexedMap,
				F2(
					function (i, c) {
						return _Utils_Tuple2(i, c);
					}),
				A2(
					$elm$core$List$map,
					$elm$core$Char$toCode,
					$elm$core$String$toList(
						A2(
							$elm$core$String$left,
							4,
							$truqu$elm_md5$MD5$hex(
								_Utils_ap(passcode, location.av)))))));
	});
var $author$project$Y16D17$search = F4(
	function (part, len, queue, passcode) {
		search:
		while (true) {
			if (!queue.b) {
				return (part === 1) ? 'none' : $elm$core$String$fromInt(len);
			} else {
				var location = queue.a;
				var rest = queue.b;
				var locations = A2($author$project$Y16D17$newLocations, passcode, location);
				var maybeGoal = $elm$core$List$head(
					A2($elm$core$List$filter, $author$project$Y16D17$found, locations));
				if (maybeGoal.$ === 1) {
					var $temp$part = part,
						$temp$len = len,
						$temp$queue = _Utils_ap(rest, locations),
						$temp$passcode = passcode;
					part = $temp$part;
					len = $temp$len;
					queue = $temp$queue;
					passcode = $temp$passcode;
					continue search;
				} else {
					var goal = maybeGoal.a;
					if (part === 1) {
						return goal.av;
					} else {
						var notGoals = A2(
							$elm$core$List$filter,
							A2($elm$core$Basics$composeL, $elm$core$Basics$not, $author$project$Y16D17$found),
							locations);
						var newLen = $elm$core$String$length(goal.av);
						var $temp$part = part,
							$temp$len = newLen,
							$temp$queue = _Utils_ap(rest, notGoals),
							$temp$passcode = passcode;
						part = $temp$part;
						len = $temp$len;
						queue = $temp$queue;
						passcode = $temp$passcode;
						continue search;
					}
				}
			}
		}
	});
var $author$project$Y16D17$start = A3($author$project$Y16D17$Location, 0, 0, '');
var $author$project$Y16D17$answer = F2(
	function (part, input) {
		return A4(
			$author$project$Y16D17$search,
			part,
			0,
			_List_fromArray(
				[$author$project$Y16D17$start]),
			$author$project$Y16D17$parse(input));
	});
var $author$project$Y16D18$isTrap = F3(
	function (t1, t2, t3) {
		var _v0 = _Utils_Tuple3(t1, t2, t3);
		_v0$4:
		while (true) {
			if (_v0.a) {
				if (_v0.b) {
					if (!_v0.c) {
						return true;
					} else {
						break _v0$4;
					}
				} else {
					if (!_v0.c) {
						return true;
					} else {
						break _v0$4;
					}
				}
			} else {
				if (_v0.b) {
					if (_v0.c) {
						return true;
					} else {
						break _v0$4;
					}
				} else {
					if (_v0.c) {
						return true;
					} else {
						break _v0$4;
					}
				}
			}
		}
		return false;
	});
var $author$project$Y16D18$nextRow = F2(
	function (start, row) {
		if (!row.b) {
			return _List_Nil;
		} else {
			if (!row.b.b) {
				var t1 = row.a;
				var t = A3($author$project$Y16D18$isTrap, false, t1, false);
				return _List_fromArray(
					[t]);
			} else {
				if (!row.b.b.b) {
					var t1 = row.a;
					var _v1 = row.b;
					var t2 = _v1.a;
					if (start) {
						var t = A3($author$project$Y16D18$isTrap, false, t1, t2);
						return A2(
							$elm$core$List$cons,
							t,
							A2($author$project$Y16D18$nextRow, false, row));
					} else {
						var t = A3($author$project$Y16D18$isTrap, t1, t2, false);
						return _List_fromArray(
							[t]);
					}
				} else {
					var t1 = row.a;
					var _v2 = row.b;
					var t2 = _v2.a;
					var _v3 = _v2.b;
					var t3 = _v3.a;
					var rest = _v3.b;
					if (start) {
						var t = A3($author$project$Y16D18$isTrap, false, t1, t2);
						return A2(
							$elm$core$List$cons,
							t,
							A2($author$project$Y16D18$nextRow, false, row));
					} else {
						var t = A3($author$project$Y16D18$isTrap, t1, t2, t3);
						return A2(
							$elm$core$List$cons,
							t,
							A2(
								$author$project$Y16D18$nextRow,
								start,
								A2(
									$elm$core$List$cons,
									t2,
									A2($elm$core$List$cons, t3, rest))));
					}
				}
			}
		}
	});
var $author$project$Y16D18$count = F3(
	function (num, total, row) {
		count:
		while (true) {
			var rowCount = $elm$core$List$length(
				A2($elm$core$List$filter, $elm$core$Basics$not, row));
			var newTotal = total + rowCount;
			if (num <= 1) {
				return newTotal;
			} else {
				var newRow = A2($author$project$Y16D18$nextRow, true, row);
				var newNum = num - 1;
				var $temp$num = newNum,
					$temp$total = newTotal,
					$temp$row = newRow;
				num = $temp$num;
				total = $temp$total;
				row = $temp$row;
				continue count;
			}
		}
	});
var $author$project$Y16D18$parse = function (input) {
	return A2(
		$elm$core$List$map,
		function (c) {
			return (c === '^') ? true : false;
		},
		$elm$core$String$toList(
			A2(
				$elm$core$Maybe$withDefault,
				'',
				$elm$core$List$head(
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bY;
						},
						A3(
							$elm$regex$Regex$findAtMost,
							1,
							$author$project$Util$regex('\\S+'),
							input))))));
};
var $author$project$Y16D18$answer = F2(
	function (part, input) {
		var num = (part === 1) ? 40 : 400000;
		return $elm$core$String$fromInt(
			A3(
				$author$project$Y16D18$count,
				num,
				0,
				$author$project$Y16D18$parse(input)));
	});
var $author$project$Y16D19$parse = function (input) {
	return A2(
		$elm$core$Maybe$withDefault,
		1,
		$elm$core$String$toInt(
			A2($elm$core$String$dropRight, 1, input)));
};
var $elm$core$Basics$pow = _Basics_pow;
var $author$project$Y16D19$stealAcross = function (num) {
	var thresh = A2(
		$elm$core$Basics$pow,
		3,
		$elm$core$Basics$floor(
			A2($elm$core$Basics$logBase, 3, num)));
	return _Utils_eq(num, thresh) ? num : ((_Utils_cmp(num, 2 * thresh) < 1) ? (num - thresh) : ((2 * num) - (3 * thresh)));
};
var $author$project$Y16D19$stealLeft = function (num) {
	var thresh = A2(
		$elm$core$Basics$pow,
		2,
		$elm$core$Basics$floor(
			A2($elm$core$Basics$logBase, 2, num)));
	return (2 * (num - thresh)) + 1;
};
var $author$project$Y16D19$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y16D19$stealLeft(
				$author$project$Y16D19$parse(input))) : $elm$core$String$fromInt(
			$author$project$Y16D19$stealAcross(
				$author$project$Y16D19$parse(input)));
	});
var $author$project$Y16D20$size = function (block) {
	return (block.T - block._) + 1;
};
var $author$project$Y16D20$allowed = F2(
	function (remaining, blocks) {
		allowed:
		while (true) {
			if (!blocks.b) {
				return remaining;
			} else {
				var block = blocks.a;
				var rest = blocks.b;
				var newRemaining = remaining - $author$project$Y16D20$size(block);
				var $temp$remaining = newRemaining,
					$temp$blocks = rest;
				remaining = $temp$remaining;
				blocks = $temp$blocks;
				continue allowed;
			}
		}
	});
var $author$project$Y16D20$lowest = F2(
	function (num, blocks) {
		lowest:
		while (true) {
			if (!blocks.b) {
				return num;
			} else {
				var block = blocks.a;
				var rest = blocks.b;
				if (_Utils_cmp(num, block._) < 0) {
					return num;
				} else {
					var $temp$num = block.T + 1,
						$temp$blocks = rest;
					num = $temp$num;
					blocks = $temp$blocks;
					continue lowest;
				}
			}
		}
	});
var $author$project$Y16D20$Block = F2(
	function (lower, upper) {
		return {_: lower, T: upper};
	});
var $author$project$Y16D20$merge = F2(
	function (b1, b2) {
		return (_Utils_cmp(b2.T, b1.T) < 1) ? b1 : A2($author$project$Y16D20$Block, b1._, b2.T);
	});
var $author$project$Y16D20$mergeable = F2(
	function (b1, b2) {
		return _Utils_cmp(b2._, b1.T + 1) < 1;
	});
var $author$project$Y16D20$compact = function (blocks) {
	compact:
	while (true) {
		if (!blocks.b) {
			return blocks;
		} else {
			if (!blocks.b.b) {
				return blocks;
			} else {
				var b1 = blocks.a;
				var _v1 = blocks.b;
				var b2 = _v1.a;
				var rest = _v1.b;
				if (A2($author$project$Y16D20$mergeable, b1, b2)) {
					var b = A2($author$project$Y16D20$merge, b1, b2);
					var $temp$blocks = A2($elm$core$List$cons, b, rest);
					blocks = $temp$blocks;
					continue compact;
				} else {
					return A2(
						$elm$core$List$cons,
						b1,
						$author$project$Y16D20$compact(
							A2($elm$core$List$cons, b2, rest)));
				}
			}
		}
	}
};
var $author$project$Y16D20$invalid = A2($author$project$Y16D20$Block, 0, 0);
var $author$project$Y16D20$notInvalid = function (block) {
	return !_Utils_eq(block, $author$project$Y16D20$invalid);
};
var $author$project$Y16D20$toBlock = function (list) {
	if ((list.b && list.b.b) && (!list.b.b.b)) {
		var l = list.a;
		var _v1 = list.b;
		var u = _v1.a;
		return (_Utils_cmp(l, u) < 1) ? A2($author$project$Y16D20$Block, l, u) : $author$project$Y16D20$invalid;
	} else {
		return $author$project$Y16D20$invalid;
	}
};
var $author$project$Y16D20$parse = function (input) {
	return $author$project$Y16D20$compact(
		A2(
			$elm$core$List$sortBy,
			function ($) {
				return $._;
			},
			A2(
				$elm$core$List$filter,
				$author$project$Y16D20$notInvalid,
				A2(
					$elm$core$List$map,
					$author$project$Y16D20$toBlock,
					A2(
						$elm$core$List$map,
						$elm$core$List$map(
							$elm$core$Maybe$withDefault(0)),
						A2(
							$elm$core$List$map,
							$elm$core$List$map($elm$core$String$toInt),
							A2(
								$elm$core$List$map,
								$elm$core$List$map(
									$elm$core$Maybe$withDefault('')),
								A2(
									$elm$core$List$map,
									function ($) {
										return $.b2;
									},
									A2(
										$elm$regex$Regex$find,
										$author$project$Util$regex('(\\d+)-(\\d+)'),
										input)))))))));
};
var $author$project$Y16D20$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$author$project$Y16D20$lowest,
				0,
				$author$project$Y16D20$parse(input))) : $elm$core$String$fromInt(
			A2(
				$author$project$Y16D20$allowed,
				4294967296,
				$author$project$Y16D20$parse(input)));
	});
var $author$project$Y16D21$instructionPattern = function () {
	var list = _List_fromArray(
		['(swap position) ([0-9]) with position ([0-9])', '(swap letter) ([a-z]) with letter ([a-z])', '(rotate left) ([0-9]) steps?', '(rotate right) ([0-9]) steps?', '(rotate based) on position of letter ([a-z])', '(reverse positions) ([0-9]) through ([1-9])', '(move position) ([0-9]) to position ([0-9])']);
	return $author$project$Util$regex(
		A2($elm$core$String$join, '|', list));
}();
var $author$project$Y16D21$MovePosition = F2(
	function (a, b) {
		return {$: 8, a: a, b: b};
	});
var $author$project$Y16D21$NoOp = {$: 0};
var $author$project$Y16D21$ReversePosition = F2(
	function (a, b) {
		return {$: 7, a: a, b: b};
	});
var $author$project$Y16D21$RotateBased = function (a) {
	return {$: 5, a: a};
};
var $author$project$Y16D21$RotateLeft = function (a) {
	return {$: 3, a: a};
};
var $author$project$Y16D21$RotateRight = function (a) {
	return {$: 4, a: a};
};
var $author$project$Y16D21$SwapLetter = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$Y16D21$SwapPosition = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$Y16D21$toChar = function (str) {
	var _v0 = $elm$core$String$uncons(str);
	if (!_v0.$) {
		var _v1 = _v0.a;
		var c = _v1.a;
		var s = _v1.b;
		return c;
	} else {
		return '_';
	}
};
var $author$project$Y16D21$toInt = function (str) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(str));
};
var $author$project$Y16D21$toInstruction = function (words) {
	_v0$7:
	while (true) {
		if (words.b && words.b.b) {
			if (!words.b.b.b) {
				switch (words.a) {
					case 'rotate left':
						var _v5 = words.b;
						var a = _v5.a;
						var n = $author$project$Y16D21$toInt(a);
						return (n > 0) ? $author$project$Y16D21$RotateLeft(n) : $author$project$Y16D21$NoOp;
					case 'rotate right':
						var _v6 = words.b;
						var a = _v6.a;
						var n = $author$project$Y16D21$toInt(a);
						return (n > 0) ? $author$project$Y16D21$RotateRight(n) : $author$project$Y16D21$NoOp;
					case 'rotate based':
						var _v7 = words.b;
						var a = _v7.a;
						var c = $author$project$Y16D21$toChar(a);
						return $author$project$Y16D21$RotateBased(c);
					default:
						break _v0$7;
				}
			} else {
				if (!words.b.b.b.b) {
					switch (words.a) {
						case 'swap position':
							var _v1 = words.b;
							var a = _v1.a;
							var _v2 = _v1.b;
							var b = _v2.a;
							var i2 = $author$project$Y16D21$toInt(b);
							var i1 = $author$project$Y16D21$toInt(a);
							return (!_Utils_eq(i1, i2)) ? A2($author$project$Y16D21$SwapPosition, i1, i2) : $author$project$Y16D21$NoOp;
						case 'swap letter':
							var _v3 = words.b;
							var a = _v3.a;
							var _v4 = _v3.b;
							var b = _v4.a;
							var c2 = $author$project$Y16D21$toChar(b);
							var c1 = $author$project$Y16D21$toChar(a);
							return (!_Utils_eq(c1, c2)) ? A2($author$project$Y16D21$SwapLetter, c1, c2) : $author$project$Y16D21$NoOp;
						case 'reverse positions':
							var _v8 = words.b;
							var a = _v8.a;
							var _v9 = _v8.b;
							var b = _v9.a;
							var i2 = $author$project$Y16D21$toInt(b);
							var i1 = $author$project$Y16D21$toInt(a);
							return (_Utils_cmp(i1, i2) < 0) ? A2($author$project$Y16D21$ReversePosition, i1, i2) : $author$project$Y16D21$NoOp;
						case 'move position':
							var _v10 = words.b;
							var a = _v10.a;
							var _v11 = _v10.b;
							var b = _v11.a;
							var i2 = $author$project$Y16D21$toInt(b);
							var i1 = $author$project$Y16D21$toInt(a);
							return (!_Utils_eq(i1, i2)) ? A2($author$project$Y16D21$MovePosition, i1, i2) : $author$project$Y16D21$NoOp;
						default:
							break _v0$7;
					}
				} else {
					break _v0$7;
				}
			}
		} else {
			break _v0$7;
		}
	}
	return $author$project$Y16D21$NoOp;
};
var $author$project$Y16D21$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y16D21$toInstruction,
		A2(
			$elm$core$List$map,
			$elm$core$List$filter(
				A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$String$isEmpty)),
			A2(
				$elm$core$List$map,
				$elm$core$List$map(
					$elm$core$Maybe$withDefault('')),
				A2(
					$elm$core$List$map,
					function ($) {
						return $.b2;
					},
					A2($elm$regex$Regex$find, $author$project$Y16D21$instructionPattern, input)))));
};
var $elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var $elm$core$Elm$JsArray$slice = _JsArray_slice;
var $elm$core$Array$appendHelpBuilder = F2(
	function (tail, builder) {
		var tailLen = $elm$core$Elm$JsArray$length(tail);
		var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(builder.e)) - tailLen;
		var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, builder.e, tail);
		return (notAppended < 0) ? {
			g: A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(appended),
				builder.g),
			b: builder.b + 1,
			e: A3($elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
		} : ((!notAppended) ? {
			g: A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(appended),
				builder.g),
			b: builder.b + 1,
			e: $elm$core$Elm$JsArray$empty
		} : {g: builder.g, b: builder.b, e: appended});
	});
var $elm$core$Array$appendHelpTree = F2(
	function (toAppend, array) {
		var len = array.a;
		var tree = array.c;
		var tail = array.d;
		var itemsToAppend = $elm$core$Elm$JsArray$length(toAppend);
		var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(tail)) - itemsToAppend;
		var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, tail, toAppend);
		var newArray = A2($elm$core$Array$unsafeReplaceTail, appended, array);
		if (notAppended < 0) {
			var nextTail = A3($elm$core$Elm$JsArray$slice, notAppended, itemsToAppend, toAppend);
			return A2($elm$core$Array$unsafeReplaceTail, nextTail, newArray);
		} else {
			return newArray;
		}
	});
var $elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var $elm$core$Array$builderFromArray = function (_v0) {
	var len = _v0.a;
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = F2(
		function (node, acc) {
			if (!node.$) {
				var subTree = node.a;
				return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
			} else {
				return A2($elm$core$List$cons, node, acc);
			}
		});
	return {
		g: A3($elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		b: (len / $elm$core$Array$branchFactor) | 0,
		e: tail
	};
};
var $elm$core$Array$append = F2(
	function (a, _v0) {
		var aTail = a.d;
		var bLen = _v0.a;
		var bTree = _v0.c;
		var bTail = _v0.d;
		if (_Utils_cmp(bLen, $elm$core$Array$branchFactor * 4) < 1) {
			var foldHelper = F2(
				function (node, array) {
					if (!node.$) {
						var tree = node.a;
						return A3($elm$core$Elm$JsArray$foldl, foldHelper, array, tree);
					} else {
						var leaf = node.a;
						return A2($elm$core$Array$appendHelpTree, leaf, array);
					}
				});
			return A2(
				$elm$core$Array$appendHelpTree,
				bTail,
				A3($elm$core$Elm$JsArray$foldl, foldHelper, a, bTree));
		} else {
			var foldHelper = F2(
				function (node, builder) {
					if (!node.$) {
						var tree = node.a;
						return A3($elm$core$Elm$JsArray$foldl, foldHelper, builder, tree);
					} else {
						var leaf = node.a;
						return A2($elm$core$Array$appendHelpBuilder, leaf, builder);
					}
				});
			return A2(
				$elm$core$Array$builderToArray,
				true,
				A2(
					$elm$core$Array$appendHelpBuilder,
					bTail,
					A3(
						$elm$core$Elm$JsArray$foldl,
						foldHelper,
						$elm$core$Array$builderFromArray(a),
						bTree)));
		}
	});
var $elm$core$Array$sliceLeft = F2(
	function (from, array) {
		var len = array.a;
		var tree = array.c;
		var tail = array.d;
		if (!from) {
			return array;
		} else {
			if (_Utils_cmp(
				from,
				$elm$core$Array$tailIndex(len)) > -1) {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					len - from,
					$elm$core$Array$shiftStep,
					$elm$core$Elm$JsArray$empty,
					A3(
						$elm$core$Elm$JsArray$slice,
						from - $elm$core$Array$tailIndex(len),
						$elm$core$Elm$JsArray$length(tail),
						tail));
			} else {
				var skipNodes = (from / $elm$core$Array$branchFactor) | 0;
				var helper = F2(
					function (node, acc) {
						if (!node.$) {
							var subTree = node.a;
							return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
						} else {
							var leaf = node.a;
							return A2($elm$core$List$cons, leaf, acc);
						}
					});
				var leafNodes = A3(
					$elm$core$Elm$JsArray$foldr,
					helper,
					_List_fromArray(
						[tail]),
					tree);
				var nodesToInsert = A2($elm$core$List$drop, skipNodes, leafNodes);
				if (!nodesToInsert.b) {
					return $elm$core$Array$empty;
				} else {
					var head = nodesToInsert.a;
					var rest = nodesToInsert.b;
					var firstSlice = from - (skipNodes * $elm$core$Array$branchFactor);
					var initialBuilder = {
						g: _List_Nil,
						b: 0,
						e: A3(
							$elm$core$Elm$JsArray$slice,
							firstSlice,
							$elm$core$Elm$JsArray$length(head),
							head)
					};
					return A2(
						$elm$core$Array$builderToArray,
						true,
						A3($elm$core$List$foldl, $elm$core$Array$appendHelpBuilder, initialBuilder, rest));
				}
			}
		}
	});
var $elm$core$Array$fetchNewTail = F4(
	function (shift, end, treeEnd, tree) {
		fetchNewTail:
		while (true) {
			var pos = $elm$core$Array$bitMask & (treeEnd >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!_v0.$) {
				var sub = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$end = end,
					$temp$treeEnd = treeEnd,
					$temp$tree = sub;
				shift = $temp$shift;
				end = $temp$end;
				treeEnd = $temp$treeEnd;
				tree = $temp$tree;
				continue fetchNewTail;
			} else {
				var values = _v0.a;
				return A3($elm$core$Elm$JsArray$slice, 0, $elm$core$Array$bitMask & end, values);
			}
		}
	});
var $elm$core$Array$hoistTree = F3(
	function (oldShift, newShift, tree) {
		hoistTree:
		while (true) {
			if ((_Utils_cmp(oldShift, newShift) < 1) || (!$elm$core$Elm$JsArray$length(tree))) {
				return tree;
			} else {
				var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, 0, tree);
				if (!_v0.$) {
					var sub = _v0.a;
					var $temp$oldShift = oldShift - $elm$core$Array$shiftStep,
						$temp$newShift = newShift,
						$temp$tree = sub;
					oldShift = $temp$oldShift;
					newShift = $temp$newShift;
					tree = $temp$tree;
					continue hoistTree;
				} else {
					return tree;
				}
			}
		}
	});
var $elm$core$Array$sliceTree = F3(
	function (shift, endIdx, tree) {
		var lastPos = $elm$core$Array$bitMask & (endIdx >>> shift);
		var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, lastPos, tree);
		if (!_v0.$) {
			var sub = _v0.a;
			var newSub = A3($elm$core$Array$sliceTree, shift - $elm$core$Array$shiftStep, endIdx, sub);
			return (!$elm$core$Elm$JsArray$length(newSub)) ? A3($elm$core$Elm$JsArray$slice, 0, lastPos, tree) : A3(
				$elm$core$Elm$JsArray$unsafeSet,
				lastPos,
				$elm$core$Array$SubTree(newSub),
				A3($elm$core$Elm$JsArray$slice, 0, lastPos + 1, tree));
		} else {
			return A3($elm$core$Elm$JsArray$slice, 0, lastPos, tree);
		}
	});
var $elm$core$Array$sliceRight = F2(
	function (end, array) {
		var len = array.a;
		var startShift = array.b;
		var tree = array.c;
		var tail = array.d;
		if (_Utils_eq(end, len)) {
			return array;
		} else {
			if (_Utils_cmp(
				end,
				$elm$core$Array$tailIndex(len)) > -1) {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					end,
					startShift,
					tree,
					A3($elm$core$Elm$JsArray$slice, 0, $elm$core$Array$bitMask & end, tail));
			} else {
				var endIdx = $elm$core$Array$tailIndex(end);
				var depth = $elm$core$Basics$floor(
					A2(
						$elm$core$Basics$logBase,
						$elm$core$Array$branchFactor,
						A2($elm$core$Basics$max, 1, endIdx - 1)));
				var newShift = A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep);
				return A4(
					$elm$core$Array$Array_elm_builtin,
					end,
					newShift,
					A3(
						$elm$core$Array$hoistTree,
						startShift,
						newShift,
						A3($elm$core$Array$sliceTree, startShift, endIdx, tree)),
					A4($elm$core$Array$fetchNewTail, startShift, end, endIdx, tree));
			}
		}
	});
var $elm$core$Array$translateIndex = F2(
	function (index, _v0) {
		var len = _v0.a;
		var posIndex = (index < 0) ? (len + index) : index;
		return (posIndex < 0) ? 0 : ((_Utils_cmp(posIndex, len) > 0) ? len : posIndex);
	});
var $elm$core$Array$slice = F3(
	function (from, to, array) {
		var correctTo = A2($elm$core$Array$translateIndex, to, array);
		var correctFrom = A2($elm$core$Array$translateIndex, from, array);
		return (_Utils_cmp(correctFrom, correctTo) > 0) ? $elm$core$Array$empty : A2(
			$elm$core$Array$sliceLeft,
			correctFrom,
			A2($elm$core$Array$sliceRight, correctTo, array));
	});
var $author$project$Y16D21$movePosition = F3(
	function (i1, i2, chars) {
		var len = $elm$core$Array$length(chars);
		if ((_Utils_cmp(i1, len) < 0) && (_Utils_cmp(i2, len) < 0)) {
			var a3 = A3($elm$core$Array$slice, i1 + 1, len, chars);
			var a2 = A3($elm$core$Array$slice, i1, i1 + 1, chars);
			var a1 = A3($elm$core$Array$slice, 0, i1, chars);
			var a4 = A2($elm$core$Array$append, a1, a3);
			var a5 = A3($elm$core$Array$slice, 0, i2, a4);
			var a6 = A3($elm$core$Array$slice, i2, len - 1, a4);
			return A2(
				$elm$core$Array$append,
				a5,
				A2($elm$core$Array$append, a2, a6));
		} else {
			return chars;
		}
	});
var $author$project$Y16D21$reversePosition = F3(
	function (i1, i2, chars) {
		var len = $elm$core$Array$length(chars);
		if ((_Utils_cmp(i1, len) < 0) && (_Utils_cmp(i2, len) < 0)) {
			var a3 = A3($elm$core$Array$slice, i2 + 1, len, chars);
			var a2 = $elm$core$Array$fromList(
				$elm$core$List$reverse(
					$elm$core$Array$toList(
						A3($elm$core$Array$slice, i1, i2 + 1, chars))));
			var a1 = A3($elm$core$Array$slice, 0, i1, chars);
			return A2(
				$elm$core$Array$append,
				a1,
				A2($elm$core$Array$append, a2, a3));
		} else {
			return chars;
		}
	});
var $elm$core$Array$toIndexedList = function (array) {
	var len = array.a;
	var helper = F2(
		function (entry, _v0) {
			var index = _v0.a;
			var list = _v0.b;
			return _Utils_Tuple2(
				index - 1,
				A2(
					$elm$core$List$cons,
					_Utils_Tuple2(index, entry),
					list));
		});
	return A3(
		$elm$core$Array$foldr,
		helper,
		_Utils_Tuple2(len - 1, _List_Nil),
		array).b;
};
var $author$project$Y16D21$indexOf = F2(
	function (_char, chars) {
		return $elm$core$List$head(
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$first,
				A2(
					$elm$core$List$filter,
					function (t) {
						return _Utils_eq(t.b, _char);
					},
					$elm$core$Array$toIndexedList(chars))));
	});
var $author$project$Y16D21$rotateLeft = F2(
	function (n, chars) {
		if (!n) {
			return chars;
		} else {
			var len = $elm$core$Array$length(chars);
			var n_ = A2($elm$core$Basics$modBy, len, n);
			var a2 = A3($elm$core$Array$slice, n_, len, chars);
			var a1 = A3($elm$core$Array$slice, 0, n_, chars);
			return A2($elm$core$Array$append, a2, a1);
		}
	});
var $author$project$Y16D21$rotateRight = F2(
	function (n, chars) {
		if (!n) {
			return chars;
		} else {
			var len = $elm$core$Array$length(chars);
			var n_ = A2($elm$core$Basics$modBy, len, n);
			return A2($author$project$Y16D21$rotateLeft, len - n_, chars);
		}
	});
var $author$project$Y16D21$rotateBased = F2(
	function (c, chars) {
		var mi = A2($author$project$Y16D21$indexOf, c, chars);
		if (!mi.$) {
			var i = mi.a;
			var x = (i >= 4) ? 1 : 0;
			var n = (1 + i) + x;
			return A2($author$project$Y16D21$rotateRight, n, chars);
		} else {
			return chars;
		}
	});
var $author$project$Y16D21$rotateBasedInverse = F2(
	function (c, chars) {
		var mi = A2($author$project$Y16D21$indexOf, c, chars);
		var n = function () {
			_v0$8:
			while (true) {
				if (!mi.$) {
					switch (mi.a) {
						case 0:
							return 1;
						case 1:
							return 1;
						case 2:
							return 6;
						case 3:
							return 2;
						case 4:
							return 7;
						case 5:
							return 3;
						case 6:
							return 0;
						case 7:
							return 4;
						default:
							break _v0$8;
					}
				} else {
					break _v0$8;
				}
			}
			return 0;
		}();
		return A2($author$project$Y16D21$rotateLeft, n, chars);
	});
var $author$project$Y16D21$swapPosition = F3(
	function (i1, i2, chars) {
		var mc2 = A2($elm$core$Array$get, i2, chars);
		var mc1 = A2($elm$core$Array$get, i1, chars);
		var _v0 = _Utils_Tuple2(mc1, mc2);
		if ((!_v0.a.$) && (!_v0.b.$)) {
			var c1 = _v0.a.a;
			var c2 = _v0.b.a;
			return A3(
				$elm$core$Array$set,
				i2,
				c1,
				A3($elm$core$Array$set, i1, c2, chars));
		} else {
			return chars;
		}
	});
var $author$project$Y16D21$swapLetter = F3(
	function (c1, c2, chars) {
		var mi2 = A2($author$project$Y16D21$indexOf, c2, chars);
		var mi1 = A2($author$project$Y16D21$indexOf, c1, chars);
		var _v0 = _Utils_Tuple2(mi1, mi2);
		if ((!_v0.a.$) && (!_v0.b.$)) {
			var i1 = _v0.a.a;
			var i2 = _v0.b.a;
			return A3($author$project$Y16D21$swapPosition, i1, i2, chars);
		} else {
			return chars;
		}
	});
var $author$project$Y16D21$transform = F2(
	function (instruction, chars) {
		switch (instruction.$) {
			case 0:
				return chars;
			case 1:
				var i1 = instruction.a;
				var i2 = instruction.b;
				return A3($author$project$Y16D21$swapPosition, i1, i2, chars);
			case 2:
				var c1 = instruction.a;
				var c2 = instruction.b;
				return A3($author$project$Y16D21$swapLetter, c1, c2, chars);
			case 3:
				var n = instruction.a;
				return A2($author$project$Y16D21$rotateLeft, n, chars);
			case 4:
				var n = instruction.a;
				return A2($author$project$Y16D21$rotateRight, n, chars);
			case 5:
				var c = instruction.a;
				return A2($author$project$Y16D21$rotateBased, c, chars);
			case 6:
				var c = instruction.a;
				return A2($author$project$Y16D21$rotateBasedInverse, c, chars);
			case 7:
				var i1 = instruction.a;
				var i2 = instruction.b;
				return A3($author$project$Y16D21$reversePosition, i1, i2, chars);
			default:
				var i1 = instruction.a;
				var i2 = instruction.b;
				return A3($author$project$Y16D21$movePosition, i1, i2, chars);
		}
	});
var $author$project$Y16D21$process = F2(
	function (instructions, chars) {
		process:
		while (true) {
			if (!instructions.b) {
				return chars;
			} else {
				var instruction = instructions.a;
				var rest = instructions.b;
				var newChars = A2($author$project$Y16D21$transform, instruction, chars);
				var $temp$instructions = rest,
					$temp$chars = newChars;
				instructions = $temp$instructions;
				chars = $temp$chars;
				continue process;
			}
		}
	});
var $author$project$Y16D21$scramble = F2(
	function (instructions, password) {
		var chars = $elm$core$Array$fromList(
			$elm$core$String$toList(password));
		var scrambledChars = A2($author$project$Y16D21$process, instructions, chars);
		return $elm$core$String$fromList(
			$elm$core$Array$toList(scrambledChars));
	});
var $author$project$Y16D21$RotateBasedInverse = function (a) {
	return {$: 6, a: a};
};
var $author$project$Y16D21$reverse = function (instruction) {
	switch (instruction.$) {
		case 0:
			return $author$project$Y16D21$NoOp;
		case 1:
			var i1 = instruction.a;
			var i2 = instruction.b;
			return A2($author$project$Y16D21$SwapPosition, i2, i1);
		case 2:
			var c1 = instruction.a;
			var c2 = instruction.b;
			return A2($author$project$Y16D21$SwapLetter, c2, c1);
		case 3:
			var n = instruction.a;
			return $author$project$Y16D21$RotateRight(n);
		case 4:
			var n = instruction.a;
			return $author$project$Y16D21$RotateLeft(n);
		case 5:
			var c = instruction.a;
			return $author$project$Y16D21$RotateBasedInverse(c);
		case 6:
			var c = instruction.a;
			return $author$project$Y16D21$NoOp;
		case 7:
			var i1 = instruction.a;
			var i2 = instruction.b;
			return A2($author$project$Y16D21$ReversePosition, i1, i2);
		default:
			var i1 = instruction.a;
			var i2 = instruction.b;
			return A2($author$project$Y16D21$MovePosition, i2, i1);
	}
};
var $author$project$Y16D21$unscramble = F2(
	function (instructions, scrambled) {
		var scrambledChars = $elm$core$Array$fromList(
			$elm$core$String$toList(scrambled));
		var newInstructions = A2(
			$elm$core$List$map,
			$author$project$Y16D21$reverse,
			$elm$core$List$reverse(instructions));
		var chars = A2($author$project$Y16D21$process, newInstructions, scrambledChars);
		return $elm$core$String$fromList(
			$elm$core$Array$toList(chars));
	});
var $author$project$Y16D21$answer = F2(
	function (part, input) {
		var instructions = $author$project$Y16D21$parse(input);
		return (part === 1) ? A2($author$project$Y16D21$scramble, instructions, 'abcdefgh') : A2($author$project$Y16D21$unscramble, instructions, 'fbgdceah');
	});
var $author$project$Y16D22$Cluster = F3(
	function (width, height, nodes) {
		return {Z: height, au: nodes, U: width};
	});
var $author$project$Y16D22$emptyCluster = A3($author$project$Y16D22$Cluster, 0, 0, $elm$core$Dict$empty);
var $author$project$Y16D22$toCluster = F2(
	function (cluster, nodes) {
		toCluster:
		while (true) {
			if (!nodes.b) {
				return cluster;
			} else {
				var node = nodes.a;
				var remainingNodes = nodes.b;
				var newWidth = (_Utils_cmp(node.H + 1, cluster.U) > 0) ? (node.H + 1) : cluster.U;
				var newNodes = A3(
					$elm$core$Dict$insert,
					_Utils_Tuple2(node.H, node.I),
					node,
					cluster.au);
				var newHeight = (_Utils_cmp(node.I + 1, cluster.Z) > 0) ? (node.I + 1) : cluster.Z;
				var newCluster = A3($author$project$Y16D22$Cluster, newWidth, newHeight, newNodes);
				var $temp$cluster = newCluster,
					$temp$nodes = remainingNodes;
				cluster = $temp$cluster;
				nodes = $temp$nodes;
				continue toCluster;
			}
		}
	});
var $author$project$Y16D22$Node = F5(
	function (x, y, size, used, avail) {
		return {aW: avail, a9: size, ag: used, H: x, I: y};
	});
var $author$project$Y16D22$invalidNode = A5($author$project$Y16D22$Node, 0, 0, 0, 0, 0);
var $author$project$Y16D22$toNode = function (numbers) {
	if (((((numbers.b && numbers.b.b) && numbers.b.b.b) && numbers.b.b.b.b) && numbers.b.b.b.b.b) && (!numbers.b.b.b.b.b.b)) {
		var x = numbers.a;
		var _v1 = numbers.b;
		var y = _v1.a;
		var _v2 = _v1.b;
		var size = _v2.a;
		var _v3 = _v2.b;
		var used = _v3.a;
		var _v4 = _v3.b;
		var avail = _v4.a;
		return A5($author$project$Y16D22$Node, x, y, size, used, avail);
	} else {
		return $author$project$Y16D22$invalidNode;
	}
};
var $author$project$Y16D22$parse = function (input) {
	return A2(
		$author$project$Y16D22$toCluster,
		$author$project$Y16D22$emptyCluster,
		A2(
			$elm$core$List$map,
			$author$project$Y16D22$toNode,
			A2(
				$elm$core$List$map,
				$elm$core$List$map(
					$elm$core$Maybe$withDefault(0)),
				A2(
					$elm$core$List$map,
					$elm$core$List$map($elm$core$String$toInt),
					A2(
						$elm$core$List$map,
						$elm$core$List$map(
							$elm$core$Maybe$withDefault('')),
						A2(
							$elm$core$List$map,
							function ($) {
								return $.b2;
							},
							A2(
								$elm$regex$Regex$find,
								$author$project$Util$regex('/dev/grid/node-x(\\d+)-y(\\d+)\\s+(\\d+)T\\s+(\\d+)T\\s+(\\d+)T\\s+\\d+%'),
								input)))))));
};
var $author$project$Y16D22$printNode = F3(
	function (cluster, y, x) {
		if ((!y) && (!x)) {
			return '0';
		} else {
			if ((!y) && _Utils_eq(x, cluster.U - 1)) {
				return 'G';
			} else {
				var node = A2(
					$elm$core$Maybe$withDefault,
					$author$project$Y16D22$invalidNode,
					A2(
						$elm$core$Dict$get,
						_Utils_Tuple2(x, y),
						cluster.au));
				return _Utils_eq(node, $author$project$Y16D22$invalidNode) ? ' ' : ((!node.ag) ? '_' : ((node.a9 >= 500) ? '#' : '.'));
			}
		}
	});
var $author$project$Y16D22$printRow = F2(
	function (cluster, y) {
		return $elm$core$String$fromList(
			A2(
				$elm$core$List$map,
				A2($author$project$Y16D22$printNode, cluster, y),
				A2($elm$core$List$range, 0, (-1) + cluster.U)));
	});
var $author$project$Y16D22$print = function (cluster) {
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			$author$project$Y16D22$printRow(cluster),
			A2($elm$core$List$range, 0, (-1) + cluster.Z)));
};
var $author$project$Y16D22$viable1 = F4(
	function (x, y, total, cluster) {
		viable1:
		while (true) {
			if (_Utils_cmp(x, cluster.U) > -1) {
				return total;
			} else {
				if (_Utils_cmp(y, cluster.Z) > -1) {
					var $temp$x = x + 1,
						$temp$y = 0,
						$temp$total = total,
						$temp$cluster = cluster;
					x = $temp$x;
					y = $temp$y;
					total = $temp$total;
					cluster = $temp$cluster;
					continue viable1;
				} else {
					return A6($author$project$Y16D22$viable2, x, y, x, y + 1, total, cluster);
				}
			}
		}
	});
var $author$project$Y16D22$viable2 = F6(
	function (x1, y1, x2, y2, total, cluster) {
		viable2:
		while (true) {
			if (_Utils_cmp(x2, cluster.U) > -1) {
				return A4($author$project$Y16D22$viable1, x1, y1 + 1, total, cluster);
			} else {
				if (_Utils_cmp(y2, cluster.Z) > -1) {
					var $temp$x1 = x1,
						$temp$y1 = y1,
						$temp$x2 = x2 + 1,
						$temp$y2 = 0,
						$temp$total = total,
						$temp$cluster = cluster;
					x1 = $temp$x1;
					y1 = $temp$y1;
					x2 = $temp$x2;
					y2 = $temp$y2;
					total = $temp$total;
					cluster = $temp$cluster;
					continue viable2;
				} else {
					var node2 = A2(
						$elm$core$Maybe$withDefault,
						$author$project$Y16D22$invalidNode,
						A2(
							$elm$core$Dict$get,
							_Utils_Tuple2(x2, y2),
							cluster.au));
					var node1 = A2(
						$elm$core$Maybe$withDefault,
						$author$project$Y16D22$invalidNode,
						A2(
							$elm$core$Dict$get,
							_Utils_Tuple2(x1, y1),
							cluster.au));
					var add21 = ((node2.ag > 0) && (_Utils_cmp(node2.ag, node1.aW) < 1)) ? 1 : 0;
					var add12 = ((node1.ag > 0) && (_Utils_cmp(node1.ag, node2.aW) < 1)) ? 1 : 0;
					var newTotal = (total + add12) + add21;
					var $temp$x1 = x1,
						$temp$y1 = y1,
						$temp$x2 = x2,
						$temp$y2 = y2 + 1,
						$temp$total = newTotal,
						$temp$cluster = cluster;
					x1 = $temp$x1;
					y1 = $temp$y1;
					x2 = $temp$x2;
					y2 = $temp$y2;
					total = $temp$total;
					cluster = $temp$cluster;
					continue viable2;
				}
			}
		}
	});
var $author$project$Y16D22$viable = function (cluster) {
	return A4($author$project$Y16D22$viable1, 0, 0, 0, cluster);
};
var $author$project$Y16D22$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y16D22$viable(
				$author$project$Y16D22$parse(input))) : $author$project$Y16D22$print(
			$author$project$Y16D22$parse(input));
	});
var $author$project$Y16D23$answer = F2(
	function (part, input) {
		return $author$project$Util$failed;
	});
var $author$project$Y16D24$neighbours = F3(
	function (x, y, nodes) {
		var u = _Utils_Tuple2(x, y - 1);
		var r = _Utils_Tuple2(x + 1, y);
		var l = _Utils_Tuple2(x - 1, y);
		var d = _Utils_Tuple2(x, y + 1);
		return A2(
			$elm$core$List$filterMap,
			$elm$core$Basics$identity,
			A2(
				$elm$core$List$map,
				function (loc) {
					return A2($elm$core$Dict$get, loc, nodes);
				},
				_List_fromArray(
					[r, d, l, u])));
	});
var $author$project$Y16D24$toEntry = function (node) {
	return _Utils_Tuple2(
		_Utils_Tuple2(node.H, node.I),
		node);
};
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $author$project$Y16D24$cost_ = F2(
	function (target, state) {
		cost_:
		while (true) {
			var _v0 = state.aL;
			if (_v0.$ === 1) {
				return 0;
			} else {
				var current = _v0.a;
				var update = function (node) {
					return ((!node.t) || (_Utils_cmp(node.t, current.t + 1) > 0)) ? _Utils_update(
						node,
						{t: current.t + 1}) : node;
				};
				var updatedNeighboursList = A2(
					$elm$core$List$map,
					update,
					A3($author$project$Y16D24$neighbours, current.H, current.I, state.au));
				var maybeTarget = $elm$core$List$head(
					A2(
						$elm$core$List$filter,
						function (n) {
							return _Utils_eq(n.aG, target);
						},
						updatedNeighboursList));
				if (!maybeTarget.$) {
					var node = maybeTarget.a;
					return node.t;
				} else {
					var newUpdatedNodes = $elm$core$Dict$fromList(
						A2($elm$core$List$map, $author$project$Y16D24$toEntry, updatedNeighboursList));
					var tmpNodes = A2($elm$core$Dict$union, newUpdatedNodes, state.au);
					var newCurrent = $elm$core$List$head(
						A2(
							$elm$core$List$map,
							$elm$core$Tuple$second,
							A2(
								$elm$core$List$sortBy,
								$elm$core$Tuple$first,
								A2(
									$elm$core$List$map,
									function (n) {
										return _Utils_Tuple2(n.t, n);
									},
									A2(
										$elm$core$List$filter,
										function (n) {
											return n.t > 0;
										},
										$elm$core$Dict$values(tmpNodes))))));
					var newNodes = function () {
						if (newCurrent.$ === 1) {
							return tmpNodes;
						} else {
							var node = newCurrent.a;
							return A2(
								$elm$core$Dict$remove,
								_Utils_Tuple2(node.H, node.I),
								tmpNodes);
						}
					}();
					var newState = _Utils_update(
						state,
						{aL: newCurrent, au: newNodes});
					var $temp$target = target,
						$temp$state = newState;
					target = $temp$target;
					state = $temp$state;
					continue cost_;
				}
			}
		}
	});
var $author$project$Y16D24$cost = F2(
	function (_v0, state) {
		var source = _v0.a;
		var target = _v0.b;
		if (_Utils_eq(source, target)) {
			return 0;
		} else {
			var newCurrent = $elm$core$List$head(
				A2(
					$elm$core$List$filter,
					function (n) {
						return _Utils_eq(n.aG, source);
					},
					$elm$core$Dict$values(state.au)));
			var newNodes = function () {
				if (!newCurrent.$) {
					var node = newCurrent.a;
					return A2(
						$elm$core$Dict$remove,
						_Utils_Tuple2(node.H, node.I),
						state.au);
				} else {
					return state.au;
				}
			}();
			var newState = _Utils_update(
				state,
				{aL: newCurrent, au: newNodes});
			return A2($author$project$Y16D24$cost_, target, newState);
		}
	});
var $author$project$Y16D24$swap = function (_v0) {
	var v1 = _v0.a;
	var v2 = _v0.b;
	return _Utils_Tuple2(v2, v1);
};
var $author$project$Y16D24$getDistances_ = F3(
	function (pairs, state, distances) {
		getDistances_:
		while (true) {
			if (!pairs.b) {
				return distances;
			} else {
				var pair = pairs.a;
				var rest = pairs.b;
				var newCost = A2($author$project$Y16D24$cost, pair, state);
				var newDistances = A3(
					$elm$core$Dict$insert,
					$author$project$Y16D24$swap(pair),
					newCost,
					A3($elm$core$Dict$insert, pair, newCost, distances));
				var $temp$pairs = rest,
					$temp$state = state,
					$temp$distances = newDistances;
				pairs = $temp$pairs;
				state = $temp$state;
				distances = $temp$distances;
				continue getDistances_;
			}
		}
	});
var $author$project$Y16D24$getDistances = function (state) {
	var toPair = function (list) {
		if ((list.b && list.b.b) && (!list.b.b.b)) {
			var v1 = list.a;
			var _v1 = list.b;
			var v2 = _v1.a;
			return _Utils_Tuple2(v1, v2);
		} else {
			return _Utils_Tuple2('_', '_');
		}
	};
	var pairs = A2(
		$elm$core$List$map,
		toPair,
		A2(
			$author$project$Util$combinations,
			2,
			A2($elm$core$List$cons, '0', state.bc)));
	return A3($author$project$Y16D24$getDistances_, pairs, state, $elm$core$Dict$empty);
};
var $author$project$Y16D24$Node = F4(
	function (x, y, v, distance) {
		return {t: distance, aG: v, H: x, I: y};
	});
var $author$project$Y16D24$State = F3(
	function (current, nodes, targets) {
		return {aL: current, au: nodes, bc: targets};
	});
var $author$project$Y16D24$parse = function (input) {
	var parseYthRow = F2(
		function (y, row) {
			return A2(
				$elm$core$List$indexedMap,
				F2(
					function (x, v) {
						return A4($author$project$Y16D24$Node, x, y, v, 0);
					}),
				row);
		});
	var nodeList = A2(
		$elm$core$List$filter,
		function (n) {
			return n.aG !== '#';
		},
		$elm$core$List$concat(
			A2(
				$elm$core$List$indexedMap,
				parseYthRow,
				A2(
					$elm$core$List$map,
					$elm$core$String$toList,
					A2(
						$elm$core$List$map,
						function ($) {
							return $.bY;
						},
						A2(
							$elm$regex$Regex$find,
							$author$project$Util$regex('[#.0-9]+'),
							input))))));
	var nodes = $elm$core$Dict$fromList(
		A2($elm$core$List$map, $author$project$Y16D24$toEntry, nodeList));
	var targets = $elm$core$List$sort(
		A2(
			$elm$core$List$filter,
			function (v) {
				return (v > '0') && (v <= '9');
			},
			A2(
				$elm$core$List$map,
				function ($) {
					return $.aG;
				},
				nodeList)));
	var current = $elm$core$Maybe$Nothing;
	return A3($author$project$Y16D24$State, current, nodes, targets);
};
var $author$project$Y16D24$pathCost = F3(
	function (costs, cst, path) {
		pathCost:
		while (true) {
			if (!path.b) {
				return cst;
			} else {
				if (!path.b.b) {
					return cst;
				} else {
					var v1 = path.a;
					var _v1 = path.b;
					var v2 = _v1.a;
					var rest = _v1.b;
					var newCost = cst + A2(
						$elm$core$Maybe$withDefault,
						0,
						A2(
							$elm$core$Dict$get,
							_Utils_Tuple2(v1, v2),
							costs));
					var $temp$costs = costs,
						$temp$cst = newCost,
						$temp$path = A2($elm$core$List$cons, v2, rest);
					costs = $temp$costs;
					cst = $temp$cst;
					path = $temp$path;
					continue pathCost;
				}
			}
		}
	});
var $author$project$Y16D24$answer = F2(
	function (part, input) {
		var state = $author$project$Y16D24$parse(input);
		var paths = A2(
			$elm$core$List$map,
			$elm$core$List$cons('0'),
			$author$project$Util$permutations(state.bc));
		var costs = $author$project$Y16D24$getDistances(state);
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$minimum(
					A2(
						$elm$core$List$map,
						A2($author$project$Y16D24$pathCost, costs, 0),
						paths)))) : $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$minimum(
					A2(
						$elm$core$List$map,
						A2($author$project$Y16D24$pathCost, costs, 0),
						A2(
							$elm$core$List$map,
							function (path) {
								return _Utils_ap(
									path,
									_List_fromArray(
										['0']));
							},
							paths)))));
	});
var $author$project$Y16D25$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$elm$core$Maybe$withDefault(0),
		A2(
			$elm$core$List$map,
			$elm$core$String$toInt,
			A2(
				$elm$core$List$map,
				$elm$core$Maybe$withDefault(''),
				A2(
					$elm$core$List$map,
					$elm$core$List$head,
					A2(
						$elm$core$List$map,
						$elm$core$List$map(
							$elm$core$Maybe$withDefault('')),
						A2(
							$elm$core$List$map,
							function ($) {
								return $.b2;
							},
							A3(
								$elm$regex$Regex$findAtMost,
								2,
								$author$project$Util$regex('cpy (\\d+) [abcd]'),
								input)))))));
};
var $author$project$Y16D25$answer = F2(
	function (part, input) {
		return (part === 1) ? $elm$core$String$fromInt(
			2730 - $elm$core$List$product(
				$author$project$Y16D25$parse(input))) : $author$project$Util$onlyOnePart;
	});
var $author$project$Y16$answer = F3(
	function (day, part, input) {
		switch (day) {
			case 1:
				return A2($author$project$Y16D01$answer, part, input);
			case 2:
				return A2($author$project$Y16D02$answer, part, input);
			case 3:
				return A2($author$project$Y16D03$answer, part, input);
			case 4:
				return A2($author$project$Y16D04$answer, part, input);
			case 5:
				return A2($author$project$Y16D05$answer, part, input);
			case 6:
				return A2($author$project$Y16D06$answer, part, input);
			case 7:
				return A2($author$project$Y16D07$answer, part, input);
			case 8:
				return A2($author$project$Y16D08$answer, part, input);
			case 9:
				return A2($author$project$Y16D09$answer, part, input);
			case 10:
				return A2($author$project$Y16D10$answer, part, input);
			case 11:
				return A2($author$project$Y16D11$answer, part, input);
			case 12:
				return A2($author$project$Y16D12$answer, part, input);
			case 13:
				return A2($author$project$Y16D13$answer, part, input);
			case 14:
				return A2($author$project$Y16D14$answer, part, input);
			case 15:
				return A2($author$project$Y16D15$answer, part, input);
			case 16:
				return A2($author$project$Y16D16$answer, part, input);
			case 17:
				return A2($author$project$Y16D17$answer, part, input);
			case 18:
				return A2($author$project$Y16D18$answer, part, input);
			case 19:
				return A2($author$project$Y16D19$answer, part, input);
			case 20:
				return A2($author$project$Y16D20$answer, part, input);
			case 21:
				return A2($author$project$Y16D21$answer, part, input);
			case 22:
				return A2($author$project$Y16D22$answer, part, input);
			case 23:
				return A2($author$project$Y16D23$answer, part, input);
			case 24:
				return A2($author$project$Y16D24$answer, part, input);
			case 25:
				return A2($author$project$Y16D25$answer, part, input);
			default:
				return 'year 2016, day ' + ($elm$core$String$fromInt(day) + ': not available');
		}
	});
var $author$project$Y20D01$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		$elm$core$String$toInt,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('\\d+'),
				input)));
};
var $author$project$Y20D01$search = function (combos) {
	search:
	while (true) {
		if (combos.b) {
			var numbers = combos.a;
			var rest = combos.b;
			if ($elm$core$List$sum(numbers) === 2020) {
				return $elm$core$String$fromInt(
					$elm$core$List$product(numbers));
			} else {
				var $temp$combos = rest;
				combos = $temp$combos;
				continue search;
			}
		} else {
			return 'none found';
		}
	}
};
var $author$project$Y20D01$answer = F2(
	function (part, input) {
		var expenses = $author$project$Y20D01$parse(input);
		return (part === 1) ? $author$project$Y20D01$search(
			A2($author$project$Util$combinations, 2, expenses)) : $author$project$Y20D01$search(
			A2($author$project$Util$combinations, 3, expenses));
	});
var $author$project$Y20D02$Password = F4(
	function (n1, n2, letter, password) {
		return {aP: letter, aQ: n1, aR: n2, aS: password};
	});
var $author$project$Y20D02$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		function (m) {
			if ((((((((m.b && (!m.a.$)) && m.b.b) && (!m.b.a.$)) && m.b.b.b) && (!m.b.b.a.$)) && m.b.b.b.b) && (!m.b.b.b.a.$)) && (!m.b.b.b.b.b)) {
				var n1_ = m.a.a;
				var _v1 = m.b;
				var n2_ = _v1.a.a;
				var _v2 = _v1.b;
				var letter = _v2.a.a;
				var _v3 = _v2.b;
				var password = _v3.a.a;
				var _v4 = _Utils_Tuple2(
					$elm$core$String$toInt(n1_),
					$elm$core$String$toInt(n2_));
				if ((!_v4.a.$) && (!_v4.b.$)) {
					var n1 = _v4.a.a;
					var n2 = _v4.b.a;
					return $elm$core$Maybe$Just(
						A4($author$project$Y20D02$Password, n1, n2, letter, password));
				} else {
					return $elm$core$Maybe$Nothing;
				}
			} else {
				return $elm$core$Maybe$Nothing;
			}
		},
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('([1-9]\\d*)-([1-9]\\d*) ([a-z]): ([a-z]+)'),
				input)));
};
var $elm$core$String$indices = _String_indexes;
var $author$project$Y20D02$valid1 = function (p) {
	var count = $elm$core$List$length(
		A2($elm$core$String$indices, p.aP, p.aS));
	return (_Utils_cmp(p.aQ, count) < 1) && (_Utils_cmp(p.aR, count) > -1);
};
var $elm$core$Basics$xor = _Basics_xor;
var $author$project$Y20D02$valid2 = function (p) {
	var l2 = A3($elm$core$String$slice, p.aR - 1, p.aR, p.aS);
	var l1 = A3($elm$core$String$slice, p.aQ - 1, p.aQ, p.aS);
	return _Utils_eq(l1, p.aP) !== _Utils_eq(l2, p.aP);
};
var $author$project$Y20D02$answer = F2(
	function (part, input) {
		var passwords = $author$project$Y20D02$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$List$length(
				A2($elm$core$List$filter, $author$project$Y20D02$valid1, passwords))) : $elm$core$String$fromInt(
			$elm$core$List$length(
				A2($elm$core$List$filter, $author$project$Y20D02$valid2, passwords)));
	});
var $author$project$Y20D03$count_ = F4(
	function (forrest, _v0, _v1, t) {
		count_:
		while (true) {
			var dx = _v0.a;
			var dy = _v0.b;
			var x = _v1.a;
			var y = _v1.b;
			if (_Utils_cmp(y, forrest.Z) > -1) {
				return t;
			} else {
				var dt = function () {
					var _v2 = A2($elm$core$Array$get, y, forrest.bH);
					if (!_v2.$) {
						var row = _v2.a;
						var _v3 = A2(
							$elm$core$Array$get,
							A2($elm$core$Basics$modBy, forrest.U, x),
							row);
						if (!_v3.$) {
							var tree = _v3.a;
							return tree;
						} else {
							return 0;
						}
					} else {
						return 0;
					}
				}();
				var $temp$forrest = forrest,
					$temp$_v0 = _Utils_Tuple2(dx, dy),
					$temp$_v1 = _Utils_Tuple2(x + dx, y + dy),
					$temp$t = t + dt;
				forrest = $temp$forrest;
				_v0 = $temp$_v0;
				_v1 = $temp$_v1;
				t = $temp$t;
				continue count_;
			}
		}
	});
var $author$project$Y20D03$count = F2(
	function (forrest, _v0) {
		var dx = _v0.a;
		var dy = _v0.b;
		return A4(
			$author$project$Y20D03$count_,
			forrest,
			_Utils_Tuple2(dx, dy),
			_Utils_Tuple2(0, 0),
			0);
	});
var $author$project$Y20D03$Forrest = F3(
	function (rows, width, height) {
		return {Z: height, bH: rows, U: width};
	});
var $author$project$Y20D03$parseRow = function (row) {
	return $elm$core$Array$fromList(
		A2(
			$elm$core$List$map,
			function (c) {
				return (c === '#') ? 1 : 0;
			},
			A2($elm$core$String$split, '', row)));
};
var $author$project$Y20D03$parse = function (input) {
	var list = A2(
		$elm$core$List$map,
		$author$project$Y20D03$parseRow,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('[.#]+'),
				input)));
	var rows = $elm$core$Array$fromList(list);
	var width = function () {
		if (list.b) {
			var first = list.a;
			var rest = list.b;
			return $elm$core$Array$length(first);
		} else {
			return 0;
		}
	}();
	var height = $elm$core$List$length(list);
	return A3($author$project$Y20D03$Forrest, rows, width, height);
};
var $author$project$Y20D03$answer = F2(
	function (part, input) {
		var forrest = $author$project$Y20D03$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$author$project$Y20D03$count,
				forrest,
				_Utils_Tuple2(3, 1))) : $elm$core$String$fromInt(
			$elm$core$List$product(
				A2(
					$elm$core$List$map,
					$author$project$Y20D03$count(forrest),
					_List_fromArray(
						[
							_Utils_Tuple2(1, 1),
							_Utils_Tuple2(3, 1),
							_Utils_Tuple2(5, 1),
							_Utils_Tuple2(7, 1),
							_Utils_Tuple2(1, 2)
						]))));
	});
var $author$project$Y20D04$checkYear = F4(
	function (p, f, min, max) {
		var number = $elm$core$String$toInt(
			A2(
				$elm$core$Maybe$withDefault,
				'',
				A2($elm$core$Dict$get, f, p)));
		if (!number.$) {
			var year = number.a;
			return (_Utils_cmp(min, year) < 1) && (_Utils_cmp(year, max) < 1);
		} else {
			return false;
		}
	});
var $author$project$Y20D04$byrValid = function (p) {
	return A4($author$project$Y20D04$checkYear, p, 'byr', 1920, 2002);
};
var $author$project$Y20D04$eclValid = function (p) {
	return A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('^(amb|blu|brn|gry|grn|hzl|oth)$'),
		A2(
			$elm$core$Maybe$withDefault,
			'',
			A2($elm$core$Dict$get, 'ecl', p)));
};
var $author$project$Y20D04$eyrValid = function (p) {
	return A4($author$project$Y20D04$checkYear, p, 'eyr', 2020, 2030);
};
var $author$project$Y20D04$hclValid = function (p) {
	return A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('^#[0-9a-f]{6}$'),
		A2(
			$elm$core$Maybe$withDefault,
			'',
			A2($elm$core$Dict$get, 'hcl', p)));
};
var $author$project$Y20D04$getLength = function (input) {
	var data = A2(
		$elm$core$List$map,
		$elm$core$Maybe$withDefault(''),
		A2(
			$elm$core$Maybe$withDefault,
			_List_fromArray(
				[
					$elm$core$Maybe$Just(''),
					$elm$core$Maybe$Just('')
				]),
			$elm$core$List$head(
				A2(
					$elm$core$List$map,
					function ($) {
						return $.b2;
					},
					A2(
						$elm$regex$Regex$find,
						$author$project$Util$regex('^(\\d+)(cm|in)$'),
						input)))));
	var number = A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(
			A2(
				$elm$core$Maybe$withDefault,
				'',
				$elm$core$List$head(data))));
	_v0$2:
	while (true) {
		if ((data.b && data.b.b) && (!data.b.b.b)) {
			switch (data.b.a) {
				case 'cm':
					var _v1 = data.b;
					return $elm$core$Maybe$Just(
						_Utils_Tuple2(number, 'cm'));
				case 'in':
					var _v2 = data.b;
					return $elm$core$Maybe$Just(
						_Utils_Tuple2(number, 'in'));
				default:
					break _v0$2;
			}
		} else {
			break _v0$2;
		}
	}
	return $elm$core$Maybe$Nothing;
};
var $author$project$Y20D04$hgtValid = function (p) {
	var length = $author$project$Y20D04$getLength(
		A2(
			$elm$core$Maybe$withDefault,
			'',
			A2($elm$core$Dict$get, 'hgt', p)));
	_v0$2:
	while (true) {
		if (!length.$) {
			switch (length.a.b) {
				case 'cm':
					var _v1 = length.a;
					var v = _v1.a;
					return (150 <= v) && (v <= 193);
				case 'in':
					var _v2 = length.a;
					var v = _v2.a;
					return (59 <= v) && (v <= 76);
				default:
					break _v0$2;
			}
		} else {
			break _v0$2;
		}
	}
	return false;
};
var $author$project$Y20D04$iyrValid = function (p) {
	return A4($author$project$Y20D04$checkYear, p, 'iyr', 2010, 2020);
};
var $author$project$Y20D04$parsePassport = function (input) {
	return $elm$core$Dict$fromList(
		A2(
			$elm$core$List$filterMap,
			function (m) {
				if ((((m.b && (!m.a.$)) && m.b.b) && (!m.b.a.$)) && (!m.b.b.b)) {
					var field = m.a.a;
					var _v1 = m.b;
					var value = _v1.a.a;
					return $elm$core$Maybe$Just(
						_Utils_Tuple2(field, value));
				} else {
					return $elm$core$Maybe$Nothing;
				}
			},
			A2(
				$elm$core$List$map,
				function ($) {
					return $.b2;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('(byr|cid|ecl|eyr|hcl|hgt|iyr|pid):([^\\s]+)'),
					input))));
};
var $author$project$Y20D04$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y20D04$parsePassport,
		A2(
			$elm$regex$Regex$split,
			$author$project$Util$regex('\\n\\n'),
			input));
};
var $author$project$Y20D04$pidValid = function (p) {
	return A2(
		$elm$regex$Regex$contains,
		$author$project$Util$regex('^\\d{9}$'),
		A2(
			$elm$core$Maybe$withDefault,
			'',
			A2($elm$core$Dict$get, 'pid', p)));
};
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (!_v0.$) {
			return true;
		} else {
			return false;
		}
	});
var $author$project$Y20D04$valid = function (p) {
	return A2(
		$elm$core$List$all,
		function (f) {
			return A2($elm$core$Dict$member, f, p);
		},
		_List_fromArray(
			['byr', 'ecl', 'eyr', 'hcl', 'hgt', 'iyr', 'pid']));
};
var $author$project$Y20D04$answer = F2(
	function (part, input) {
		var passports = $author$project$Y20D04$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$elm$core$List$length(
				A2($elm$core$List$filter, $author$project$Y20D04$valid, passports))) : $elm$core$String$fromInt(
			$elm$core$List$length(
				A2(
					$elm$core$List$filter,
					$author$project$Y20D04$pidValid,
					A2(
						$elm$core$List$filter,
						$author$project$Y20D04$eclValid,
						A2(
							$elm$core$List$filter,
							$author$project$Y20D04$hclValid,
							A2(
								$elm$core$List$filter,
								$author$project$Y20D04$hgtValid,
								A2(
									$elm$core$List$filter,
									$author$project$Y20D04$eyrValid,
									A2(
										$elm$core$List$filter,
										$author$project$Y20D04$iyrValid,
										A2($elm$core$List$filter, $author$project$Y20D04$byrValid, passports)))))))));
	});
var $author$project$Y20D05$convert_ = F3(
	function (n, f, chars) {
		convert_:
		while (true) {
			if (chars.b) {
				var c = chars.a;
				var rest = chars.b;
				var d = ((c === 'B') || (c === 'R')) ? f : 0;
				var $temp$n = n + d,
					$temp$f = 2 * f,
					$temp$chars = rest;
				n = $temp$n;
				f = $temp$f;
				chars = $temp$chars;
				continue convert_;
			} else {
				return n;
			}
		}
	});
var $author$project$Y20D05$convert = function (code) {
	return A3(
		$author$project$Y20D05$convert_,
		0,
		1,
		$elm$core$List$reverse(
			$elm$core$String$toList(code)));
};
var $author$project$Y20D05$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y20D05$convert,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('[FB]{7}[LR]{3}'),
				input)));
};
var $author$project$Y20D05$search = function (ids) {
	search:
	while (true) {
		if (ids.b && ids.b.b) {
			var c1 = ids.a;
			var _v1 = ids.b;
			var c2 = _v1.a;
			var rest = _v1.b;
			if (_Utils_eq(c2, c1 + 2)) {
				return c1 + 1;
			} else {
				var $temp$ids = A2($elm$core$List$cons, c2, rest);
				ids = $temp$ids;
				continue search;
			}
		} else {
			return 0;
		}
	}
};
var $author$project$Y20D05$answer = F2(
	function (part, input) {
		var ids = $author$project$Y20D05$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(ids))) : $elm$core$String$fromInt(
			$author$project$Y20D05$search(
				$elm$core$List$sort(ids)));
	});
var $elm$core$Dict$filter = F2(
	function (isGood, dict) {
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (k, v, d) {
					return A2(isGood, k, v) ? A3($elm$core$Dict$insert, k, v, d) : d;
				}),
			$elm$core$Dict$empty,
			dict);
	});
var $elm$core$Dict$intersect = F2(
	function (t1, t2) {
		return A2(
			$elm$core$Dict$filter,
			F2(
				function (k, _v0) {
					return A2($elm$core$Dict$member, k, t2);
				}),
			t1);
	});
var $author$project$Y20D06$mergePeople = F3(
	function (mergePerson, people, soFar) {
		if (people.b) {
			var person = people.a;
			var rest = people.b;
			return A3(
				$author$project$Y20D06$mergePeople,
				mergePerson,
				rest,
				A2(mergePerson, person, soFar));
		} else {
			return soFar;
		}
	});
var $author$project$Y20D06$count = F2(
	function (part, people) {
		var start = (part === 1) ? $elm$core$Dict$empty : $elm$core$Dict$fromList(
			A2(
				$elm$core$List$map,
				function (c) {
					return _Utils_Tuple2(c, true);
				},
				$elm$core$String$toList('abcdefghijklmnopqrstuvwxyz')));
		var mergePerson = (part === 1) ? $elm$core$Dict$union : $elm$core$Dict$intersect;
		var merged = A3($author$project$Y20D06$mergePeople, mergePerson, people, start);
		return $elm$core$Dict$size(merged);
	});
var $author$project$Y20D06$parsePerson = function (input) {
	return $elm$core$Dict$fromList(
		A2(
			$elm$core$List$map,
			function (c) {
				return _Utils_Tuple2(c, true);
			},
			$elm$core$String$toList(input)));
};
var $author$project$Y20D06$parsePeople = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y20D06$parsePerson,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('[a-z]+'),
				input)));
};
var $author$project$Y20D06$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$author$project$Y20D06$parsePeople,
		A2(
			$elm$regex$Regex$split,
			$author$project$Util$regex('\\n\\n'),
			input));
};
var $author$project$Y20D06$answer = F2(
	function (part, input) {
		return $elm$core$String$fromInt(
			$elm$core$List$sum(
				A2(
					$elm$core$List$map,
					$author$project$Y20D06$count(part),
					$author$project$Y20D06$parse(input))));
	});
var $author$project$Y20D07$ancestors__ = F3(
	function (children, parent, soFar) {
		if (children.b) {
			var _v1 = children.a;
			var child = _v1.a;
			var number = _v1.b;
			var rest = children.b;
			var parents = A3(
				$elm$core$Dict$insert,
				parent,
				number,
				A2(
					$elm$core$Maybe$withDefault,
					$elm$core$Dict$empty,
					A2($elm$core$Dict$get, child, soFar)));
			return A3(
				$author$project$Y20D07$ancestors__,
				rest,
				parent,
				A3($elm$core$Dict$insert, child, parents, soFar));
		} else {
			return soFar;
		}
	});
var $author$project$Y20D07$ancestors_ = F2(
	function (lines, soFar) {
		if (lines.b) {
			var line = lines.a;
			var rest = lines.b;
			return A2(
				$author$project$Y20D07$ancestors_,
				rest,
				A3($author$project$Y20D07$ancestors__, line.aY, line.a4, soFar));
		} else {
			return soFar;
		}
	});
var $author$project$Y20D07$ancestors = function (lines) {
	return A2($author$project$Y20D07$ancestors_, lines, $elm$core$Dict$empty);
};
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$member, key, dict);
	});
var $author$project$Y20D07$count1__ = F3(
	function (parents, data, soFar) {
		count1__:
		while (true) {
			if (parents.b) {
				var parent = parents.a;
				var rest = parents.b;
				var nextFar = function () {
					if (A2($elm$core$Set$member, parent, soFar)) {
						return soFar;
					} else {
						var grandparents = $elm$core$Dict$keys(
							A2(
								$elm$core$Maybe$withDefault,
								$elm$core$Dict$empty,
								A2($elm$core$Dict$get, parent, data)));
						return A3(
							$author$project$Y20D07$count1__,
							grandparents,
							data,
							A2($elm$core$Set$insert, parent, soFar));
					}
				}();
				var $temp$parents = rest,
					$temp$data = data,
					$temp$soFar = nextFar;
				parents = $temp$parents;
				data = $temp$data;
				soFar = $temp$soFar;
				continue count1__;
			} else {
				return soFar;
			}
		}
	});
var $author$project$Y20D07$count1_ = F3(
	function (child, data, soFar) {
		var parents = $elm$core$Dict$keys(
			A2(
				$elm$core$Maybe$withDefault,
				$elm$core$Dict$empty,
				A2($elm$core$Dict$get, child, data)));
		return A3($author$project$Y20D07$count1__, parents, data, soFar);
	});
var $author$project$Y20D07$count1 = F2(
	function (child, data) {
		return $elm$core$Set$size(
			A3($author$project$Y20D07$count1_, child, data, $elm$core$Set$empty));
	});
var $author$project$Y20D07$count2_ = F3(
	function (parent, number, data) {
		return number + (number * $elm$core$List$sum(
			A2(
				$elm$core$List$map,
				function (_v0) {
					var child = _v0.a;
					var num = _v0.b;
					return A3($author$project$Y20D07$count2_, child, num, data);
				},
				$elm$core$Dict$toList(
					A2(
						$elm$core$Maybe$withDefault,
						$elm$core$Dict$empty,
						A2($elm$core$Dict$get, parent, data))))));
	});
var $author$project$Y20D07$count2 = F2(
	function (parent, data) {
		return A3($author$project$Y20D07$count2_, parent, 1, data) - 1;
	});
var $author$project$Y20D07$descendants_ = F2(
	function (lines, soFar) {
		if (lines.b) {
			var line = lines.a;
			var rest = lines.b;
			return A2(
				$author$project$Y20D07$descendants_,
				rest,
				A3(
					$elm$core$Dict$insert,
					line.a4,
					$elm$core$Dict$fromList(line.aY),
					soFar));
		} else {
			return soFar;
		}
	});
var $author$project$Y20D07$descendants = function (lines) {
	return A2($author$project$Y20D07$descendants_, lines, $elm$core$Dict$empty);
};
var $author$project$Y20D07$Line = F2(
	function (parent, children) {
		return {aY: children, a4: parent};
	});
var $author$project$Y20D07$parseChildren = function (list) {
	return A2(
		$elm$core$List$filterMap,
		function (m) {
			if ((((m.b && (!m.a.$)) && m.b.b) && (!m.b.a.$)) && (!m.b.b.b)) {
				var numberStr = m.a.a;
				var _v1 = m.b;
				var child = _v1.a.a;
				var number = A2(
					$elm$core$Maybe$withDefault,
					0,
					$elm$core$String$toInt(numberStr));
				return $elm$core$Maybe$Just(
					_Utils_Tuple2(child, number));
			} else {
				return $elm$core$Maybe$Nothing;
			}
		},
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('([1-9]\\d*) (\\w+ \\w+) bag'),
				list)));
};
var $author$project$Y20D07$parseLine = function (match) {
	var _v0 = match.b2;
	if ((((_v0.b && (!_v0.a.$)) && _v0.b.b) && (!_v0.b.a.$)) && (!_v0.b.b.b)) {
		var parent = _v0.a.a;
		var _v1 = _v0.b;
		var list = _v1.a.a;
		var children = $author$project$Y20D07$parseChildren(list);
		return $elm$core$Maybe$Just(
			A2($author$project$Y20D07$Line, parent, children));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Y20D07$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		$author$project$Y20D07$parseLine,
		A2(
			$elm$regex$Regex$find,
			$author$project$Util$regex('(\\w+ \\w+) bags contain ([^.]+)\\.'),
			input));
};
var $author$project$Y20D07$answer = F2(
	function (part, input) {
		var lines = $author$project$Y20D07$parse(input);
		var bag = 'shiny gold';
		return (part === 1) ? $elm$core$String$fromInt(
			A2(
				$author$project$Y20D07$count1,
				bag,
				$author$project$Y20D07$ancestors(lines))) : $elm$core$String$fromInt(
			A2(
				$author$project$Y20D07$count2,
				bag,
				$author$project$Y20D07$descendants(lines)));
	});
var $author$project$Y20D08$Console = F4(
	function (i, acc, mem, ops) {
		return {s: acc, f: i, a_: mem, q: ops};
	});
var $author$project$Y20D08$Result = F2(
	function (ok, acc) {
		return {s: acc, a1: ok};
	});
var $author$project$Y20D08$execute = function (c) {
	execute:
	while (true) {
		if (_Utils_eq(
			c.f,
			$elm$core$Array$length(c.q))) {
			return A2($author$project$Y20D08$Result, true, c.s);
		} else {
			if (A2($elm$core$Dict$member, c.f, c.a_)) {
				return A2($author$project$Y20D08$Result, false, c.s);
			} else {
				var mem = A3($elm$core$Dict$insert, c.f, true, c.a_);
				var _v0 = function () {
					var _v1 = A2($elm$core$Array$get, c.f, c.q);
					if (!_v1.$) {
						var inst = _v1.a;
						return _Utils_Tuple2(inst.a3, inst.aV);
					} else {
						return _Utils_Tuple2('err', 0);
					}
				}();
				var op = _v0.a;
				var arg = _v0.b;
				var acc = function () {
					if (op === 'acc') {
						return c.s + arg;
					} else {
						return c.s;
					}
				}();
				var i = function () {
					if (op === 'jmp') {
						return c.f + arg;
					} else {
						return c.f + 1;
					}
				}();
				if (op === 'err') {
					return A2($author$project$Y20D08$Result, false, 0);
				} else {
					var $temp$c = A4($author$project$Y20D08$Console, i, acc, mem, c.q);
					c = $temp$c;
					continue execute;
				}
			}
		}
	}
};
var $author$project$Y20D08$Instruction = F2(
	function (op, arg) {
		return {aV: arg, a3: op};
	});
var $author$project$Y20D08$parse = function (input) {
	return A4(
		$author$project$Y20D08$Console,
		0,
		0,
		$elm$core$Dict$empty,
		$elm$core$Array$fromList(
			A2(
				$elm$core$List$filterMap,
				function (m) {
					if ((((m.b && (!m.a.$)) && m.b.b) && (!m.b.a.$)) && (!m.b.b.b)) {
						var op = m.a.a;
						var _v1 = m.b;
						var str = _v1.a.a;
						var arg = function () {
							var _v2 = $elm$core$String$toInt(str);
							if (!_v2.$) {
								var num = _v2.a;
								return num;
							} else {
								return 0;
							}
						}();
						return $elm$core$Maybe$Just(
							A2($author$project$Y20D08$Instruction, op, arg));
					} else {
						return $elm$core$Maybe$Nothing;
					}
				},
				A2(
					$elm$core$List$map,
					function ($) {
						return $.b2;
					},
					A2(
						$elm$regex$Regex$find,
						$author$project$Util$regex('(nop|acc|jmp) ([-+]\\d+)'),
						input)))));
};
var $author$project$Y20D08$repair = F2(
	function (i, c) {
		repair:
		while (true) {
			if (_Utils_cmp(
				i,
				$elm$core$Array$length(c.q)) > -1) {
				return 0;
			} else {
				var _v0 = function () {
					var _v1 = A2($elm$core$Array$get, i, c.q);
					if (!_v1.$) {
						var inst = _v1.a;
						return _Utils_Tuple2(inst.a3, inst.aV);
					} else {
						return _Utils_Tuple2('err', 0);
					}
				}();
				var op = _v0.a;
				var arg = _v0.b;
				switch (op) {
					case 'jmp':
						var _try = $author$project$Y20D08$execute(
							_Utils_update(
								c,
								{
									q: A3(
										$elm$core$Array$set,
										i,
										A2($author$project$Y20D08$Instruction, 'nop', arg),
										c.q)
								}));
						if (_try.a1) {
							return _try.s;
						} else {
							var $temp$i = i + 1,
								$temp$c = c;
							i = $temp$i;
							c = $temp$c;
							continue repair;
						}
					case 'nop':
						var _try = $author$project$Y20D08$execute(
							_Utils_update(
								c,
								{
									q: A3(
										$elm$core$Array$set,
										i,
										A2($author$project$Y20D08$Instruction, 'jmp', arg),
										c.q)
								}));
						if (_try.a1) {
							return _try.s;
						} else {
							var $temp$i = i + 1,
								$temp$c = c;
							i = $temp$i;
							c = $temp$c;
							continue repair;
						}
					default:
						var $temp$i = i + 1,
							$temp$c = c;
						i = $temp$i;
						c = $temp$c;
						continue repair;
				}
			}
		}
	});
var $author$project$Y20D08$answer = F2(
	function (part, input) {
		var console = $author$project$Y20D08$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y20D08$execute(console).s) : $elm$core$String$fromInt(
			A2($author$project$Y20D08$repair, 0, console));
	});
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $author$project$Y20D09$valid = F2(
	function (num, preamble) {
		return A2(
			$elm$core$List$member,
			num,
			A2(
				$elm$core$List$map,
				$elm$core$List$sum,
				A2(
					$elm$core$List$map,
					$elm$core$Set$toList,
					A2(
						$elm$core$List$filter,
						function (s) {
							return $elm$core$Set$size(s) === 2;
						},
						A2(
							$elm$core$List$map,
							$elm$core$Set$fromList,
							A2($author$project$Util$combinations, 2, preamble))))));
	});
var $author$project$Y20D09$findFirst = F3(
	function (len, preamble, numbers) {
		findFirst:
		while (true) {
			if (numbers.b) {
				var num = numbers.a;
				var rest = numbers.b;
				if (_Utils_cmp(
					$elm$core$List$length(preamble),
					len) < 0) {
					var $temp$len = len,
						$temp$preamble = A2($elm$core$List$cons, num, preamble),
						$temp$numbers = rest;
					len = $temp$len;
					preamble = $temp$preamble;
					numbers = $temp$numbers;
					continue findFirst;
				} else {
					if (A2($author$project$Y20D09$valid, num, preamble)) {
						var preamble_ = $elm$core$List$reverse(
							A2(
								$elm$core$List$drop,
								1,
								$elm$core$List$reverse(preamble)));
						var $temp$len = len,
							$temp$preamble = A2($elm$core$List$cons, num, preamble_),
							$temp$numbers = rest;
						len = $temp$len;
						preamble = $temp$preamble;
						numbers = $temp$numbers;
						continue findFirst;
					} else {
						return $elm$core$Maybe$Just(num);
					}
				}
			} else {
				return $elm$core$Maybe$Nothing;
			}
		}
	});
var $author$project$Y20D09$findSum = F3(
	function (target, len, numbers) {
		findSum:
		while (true) {
			if (_Utils_cmp(
				$elm$core$List$length(numbers),
				len) < 0) {
				return $elm$core$Maybe$Nothing;
			} else {
				if (numbers.b) {
					var num = numbers.a;
					var rest = numbers.b;
					var chunk = A2($elm$core$List$take, len, numbers);
					var total = $elm$core$List$sum(chunk);
					if (_Utils_cmp(total, target) < 0) {
						var $temp$target = target,
							$temp$len = len + 1,
							$temp$numbers = numbers;
						target = $temp$target;
						len = $temp$len;
						numbers = $temp$numbers;
						continue findSum;
					} else {
						if (_Utils_cmp(total, target) > 0) {
							if (len > 2) {
								var $temp$target = target,
									$temp$len = len - 1,
									$temp$numbers = rest;
								target = $temp$target;
								len = $temp$len;
								numbers = $temp$numbers;
								continue findSum;
							} else {
								var $temp$target = target,
									$temp$len = 2,
									$temp$numbers = rest;
								target = $temp$target;
								len = $temp$len;
								numbers = $temp$numbers;
								continue findSum;
							}
						} else {
							var min = A2(
								$elm$core$Maybe$withDefault,
								0,
								$elm$core$List$minimum(chunk));
							var max = A2(
								$elm$core$Maybe$withDefault,
								0,
								$elm$core$List$maximum(chunk));
							return $elm$core$Maybe$Just(min + max);
						}
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $author$project$Y20D09$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		$elm$core$String$toInt,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('[1-9]\\d*'),
				input)));
};
var $author$project$Y20D09$answer = F2(
	function (part, input) {
		var numbers = $author$project$Y20D09$parse(input);
		var first = A2(
			$elm$core$Maybe$withDefault,
			0,
			A3($author$project$Y20D09$findFirst, 25, _List_Nil, numbers));
		return (part === 1) ? $elm$core$String$fromInt(first) : $elm$core$String$fromInt(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				A3($author$project$Y20D09$findSum, first, 2, numbers)));
	});
var $author$project$Y20D10$extendAndSort = function (numbers) {
	var target = 3 + A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$List$maximum(numbers));
	return $elm$core$List$sort(
		A2($elm$core$List$cons, target, numbers));
};
var $author$project$Y20D10$arrangements = F3(
	function (start, finish, numbers) {
		if (numbers.b) {
			var num = numbers.a;
			var rest = numbers.b;
			if ((num - start) > 3) {
				return 0;
			} else {
				var without = (_Utils_cmp(
					finish - start,
					3 + $elm$core$List$length(rest)) > 0) ? 0 : A3($author$project$Y20D10$arrangements, start, finish, rest);
				var _with = A3($author$project$Y20D10$arrangements, num, finish, rest);
				return _with + without;
			}
		} else {
			return ((finish - start) > 3) ? 0 : 1;
		}
	});
var $author$project$Y20D10$runArrangements = function (run) {
	return A3(
		$author$project$Y20D10$arrangements,
		0,
		run + 1,
		A2(
			$elm$core$List$indexedMap,
			F2(
				function (i, _v0) {
					return i + 1;
				}),
			A2($elm$core$List$repeat, run, $elm$core$Maybe$Nothing)));
};
var $author$project$Y20D10$runsOfOnes = F4(
	function (prev, run, ones, numbers) {
		runsOfOnes:
		while (true) {
			if (numbers.b) {
				var num = numbers.a;
				var rest = numbers.b;
				if ((num - prev) === 1) {
					var $temp$prev = num,
						$temp$run = run + 1,
						$temp$ones = ones,
						$temp$numbers = rest;
					prev = $temp$prev;
					run = $temp$run;
					ones = $temp$ones;
					numbers = $temp$numbers;
					continue runsOfOnes;
				} else {
					if (run > 1) {
						var $temp$prev = num,
							$temp$run = 0,
							$temp$ones = A2($elm$core$List$cons, run - 1, ones),
							$temp$numbers = rest;
						prev = $temp$prev;
						run = $temp$run;
						ones = $temp$ones;
						numbers = $temp$numbers;
						continue runsOfOnes;
					} else {
						var $temp$prev = num,
							$temp$run = 0,
							$temp$ones = ones,
							$temp$numbers = rest;
						prev = $temp$prev;
						run = $temp$run;
						ones = $temp$ones;
						numbers = $temp$numbers;
						continue runsOfOnes;
					}
				}
			} else {
				return (run > 0) ? A2($elm$core$List$cons, run, ones) : ones;
			}
		}
	});
var $author$project$Y20D10$numberOfArrangements = function (numbers) {
	return $elm$core$List$product(
		A2(
			$elm$core$List$map,
			$author$project$Y20D10$runArrangements,
			A4(
				$author$project$Y20D10$runsOfOnes,
				0,
				0,
				_List_Nil,
				$author$project$Y20D10$extendAndSort(numbers))));
};
var $author$project$Y20D10$getDiffs = F3(
	function (prev, diffs, numbers) {
		getDiffs:
		while (true) {
			if (numbers.b) {
				var num = numbers.a;
				var rest = numbers.b;
				var diff = num - prev;
				var times = A2(
					$elm$core$Maybe$withDefault,
					0,
					A2($elm$core$Dict$get, diff, diffs));
				var newDiffs = A3($elm$core$Dict$insert, diff, times + 1, diffs);
				var $temp$prev = num,
					$temp$diffs = newDiffs,
					$temp$numbers = rest;
				prev = $temp$prev;
				diffs = $temp$diffs;
				numbers = $temp$numbers;
				continue getDiffs;
			} else {
				return diffs;
			}
		}
	});
var $author$project$Y20D10$onesAndThrees = function (numbers) {
	var diffs = A3(
		$author$project$Y20D10$getDiffs,
		0,
		$elm$core$Dict$empty,
		$author$project$Y20D10$extendAndSort(numbers));
	var ones = A2(
		$elm$core$Maybe$withDefault,
		0,
		A2($elm$core$Dict$get, 1, diffs));
	var threes = A2(
		$elm$core$Maybe$withDefault,
		0,
		A2($elm$core$Dict$get, 3, diffs));
	return ones * threes;
};
var $author$project$Y20D10$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		$elm$core$String$toInt,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('[1-9]\\d*'),
				input)));
};
var $author$project$Y20D10$answer = F2(
	function (part, input) {
		var numbers = $author$project$Y20D10$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y20D10$onesAndThrees(numbers)) : $elm$core$String$fromInt(
			$author$project$Y20D10$numberOfArrangements(numbers));
	});
var $author$project$Y20D11$Data = F2(
	function (seats, changes) {
		return {K: changes, S: seats};
	});
var $author$project$Y20D11$Occupied = 2;
var $elm$core$Array$filter = F2(
	function (isGood, array) {
		return $elm$core$Array$fromList(
			A3(
				$elm$core$Array$foldr,
				F2(
					function (x, xs) {
						return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
					}),
				_List_Nil,
				array));
	});
var $author$project$Y20D11$occupied_ = function (row) {
	return $elm$core$Array$length(
		A2(
			$elm$core$Array$filter,
			function (seat) {
				return seat === 2;
			},
			row));
};
var $author$project$Y20D11$occupied = function (seats) {
	return $elm$core$List$sum(
		$elm$core$Array$toList(
			A2($elm$core$Array$map, $author$project$Y20D11$occupied_, seats)));
};
var $author$project$Y20D11$Empty = 1;
var $author$project$Y20D11$Floor = 0;
var $author$project$Y20D11$get = F3(
	function (r, c, seats) {
		var _v0 = A2($elm$core$Array$get, r, seats);
		if (!_v0.$) {
			var row = _v0.a;
			return A2($elm$core$Array$get, c, row);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Y20D11$spoke = F6(
	function (r, c, dr, dc, n, seats) {
		spoke:
		while (true) {
			var _v0 = A3($author$project$Y20D11$get, r + (n * dr), c + (n * dc), seats);
			if (_v0.$ === 1) {
				return $elm$core$Maybe$Nothing;
			} else {
				if (!_v0.a) {
					var _v1 = _v0.a;
					var $temp$r = r,
						$temp$c = c,
						$temp$dr = dr,
						$temp$dc = dc,
						$temp$n = n + 1,
						$temp$seats = seats;
					r = $temp$r;
					c = $temp$c;
					dr = $temp$dr;
					dc = $temp$dc;
					n = $temp$n;
					seats = $temp$seats;
					continue spoke;
				} else {
					var seat = _v0.a;
					return $elm$core$Maybe$Just(seat);
				}
			}
		}
	});
var $author$project$Y20D11$near = F4(
	function (part, r, c, seats) {
		return $elm$core$List$sum(
			A2(
				$elm$core$List$map,
				function (_v0) {
					var dr = _v0.a;
					var dc = _v0.b;
					var seat = (part === 1) ? A3($author$project$Y20D11$get, r + dr, c + dc, seats) : A6($author$project$Y20D11$spoke, r, c, dr, dc, 1, seats);
					return _Utils_eq(
						seat,
						$elm$core$Maybe$Just(2)) ? 1 : 0;
				},
				_List_fromArray(
					[
						_Utils_Tuple2(1, 1),
						_Utils_Tuple2(1, 0),
						_Utils_Tuple2(1, -1),
						_Utils_Tuple2(0, 1),
						_Utils_Tuple2(0, -1),
						_Utils_Tuple2(-1, 1),
						_Utils_Tuple2(-1, 0),
						_Utils_Tuple2(-1, -1)
					])));
	});
var $author$project$Y20D11$put = F4(
	function (r, c, seat, seats) {
		var _v0 = A2($elm$core$Array$get, r, seats);
		if (!_v0.$) {
			var row = _v0.a;
			return A3(
				$elm$core$Array$set,
				r,
				A3($elm$core$Array$set, c, seat, row),
				seats);
		} else {
			return seats;
		}
	});
var $author$project$Y20D11$update = F6(
	function (part, r, c, seat, seats, data) {
		if (!seat) {
			return data;
		} else {
			var number = A4($author$project$Y20D11$near, part, r, c, seats);
			switch (seat) {
				case 1:
					return (!number) ? _Utils_update(
						data,
						{
							K: data.K + 1,
							S: A4($author$project$Y20D11$put, r, c, 2, data.S)
						}) : data;
				case 2:
					var threshold = (part === 1) ? 4 : 5;
					return (_Utils_cmp(number, threshold) > -1) ? _Utils_update(
						data,
						{
							K: data.K + 1,
							S: A4($author$project$Y20D11$put, r, c, 1, data.S)
						}) : data;
				default:
					return data;
			}
		}
	});
var $author$project$Y20D11$shuffle = F5(
	function (part, r, c, seats, data) {
		shuffle:
		while (true) {
			var _v0 = A2($elm$core$Array$get, r, seats);
			if (!_v0.$) {
				var row = _v0.a;
				var _v1 = A2($elm$core$Array$get, c, row);
				if (!_v1.$) {
					var seat = _v1.a;
					return A5(
						$author$project$Y20D11$shuffle,
						part,
						r,
						c + 1,
						seats,
						A6($author$project$Y20D11$update, part, r, c, seat, seats, data));
				} else {
					var $temp$part = part,
						$temp$r = r + 1,
						$temp$c = 0,
						$temp$seats = seats,
						$temp$data = data;
					part = $temp$part;
					r = $temp$r;
					c = $temp$c;
					seats = $temp$seats;
					data = $temp$data;
					continue shuffle;
				}
			} else {
				if (!data.K) {
					return data;
				} else {
					var $temp$part = part,
						$temp$r = 0,
						$temp$c = 0,
						$temp$seats = data.S,
						$temp$data = _Utils_update(
						data,
						{K: 0});
					part = $temp$part;
					r = $temp$r;
					c = $temp$c;
					seats = $temp$seats;
					data = $temp$data;
					continue shuffle;
				}
			}
		}
	});
var $author$project$Y20D11$choose = F2(
	function (part, seats) {
		return $author$project$Y20D11$occupied(
			A5(
				$author$project$Y20D11$shuffle,
				part,
				0,
				0,
				seats,
				A2($author$project$Y20D11$Data, seats, 0)).S);
	});
var $author$project$Y20D11$toRow = function (input) {
	return $elm$core$Array$fromList(
		A2(
			$elm$core$List$map,
			function (c) {
				switch (c) {
					case '.':
						return 0;
					case 'L':
						return 1;
					default:
						return 2;
				}
			},
			$elm$core$String$toList(input)));
};
var $author$project$Y20D11$parse = function (input) {
	return $elm$core$Array$fromList(
		A2(
			$elm$core$List$map,
			$author$project$Y20D11$toRow,
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('[.#L]+'),
					input))));
};
var $author$project$Y20D11$answer = F2(
	function (part, input) {
		return $elm$core$String$fromInt(
			A2(
				$author$project$Y20D11$choose,
				part,
				$author$project$Y20D11$parse(input)));
	});
var $author$project$Y20D12$distance = function (ferry) {
	return $elm$core$Basics$abs(ferry.H) + $elm$core$Basics$abs(ferry.I);
};
var $author$project$Y20D12$East = 2;
var $author$project$Y20D12$Ferry = F3(
	function (x, y, d) {
		return {aM: d, H: x, I: y};
	});
var $author$project$Y20D12$initFerry = A3($author$project$Y20D12$Ferry, 0, 0, 2);
var $author$project$Y20D12$Waypoint = F2(
	function (x, y) {
		return {H: x, I: y};
	});
var $author$project$Y20D12$initWaypoint = A2($author$project$Y20D12$Waypoint, 10, 1);
var $author$project$Y20D12$initCombo = _Utils_Tuple2($author$project$Y20D12$initFerry, $author$project$Y20D12$initWaypoint);
var $author$project$Y20D12$L = 5;
var $author$project$Y20D12$R = 4;
var $author$project$Y20D12$North = 0;
var $author$project$Y20D12$South = 1;
var $author$project$Y20D12$West = 3;
var $author$project$Y20D12$rotateFerry = F3(
	function (ferry, a, n) {
		var direction = function () {
			if (n === 180) {
				var _v0 = ferry.aM;
				switch (_v0) {
					case 0:
						return 1;
					case 1:
						return 0;
					case 2:
						return 3;
					default:
						return 2;
				}
			} else {
				if (((a === 5) && (n === 90)) || ((a === 4) && (n === 270))) {
					var _v1 = ferry.aM;
					switch (_v1) {
						case 0:
							return 3;
						case 1:
							return 2;
						case 2:
							return 0;
						default:
							return 1;
					}
				} else {
					if (((a === 4) && (n === 90)) || ((a === 5) && (n === 270))) {
						var _v2 = ferry.aM;
						switch (_v2) {
							case 0:
								return 2;
							case 1:
								return 3;
							case 2:
								return 1;
							default:
								return 0;
						}
					} else {
						return ferry.aM;
					}
				}
			}
		}();
		return _Utils_update(
			ferry,
			{aM: direction});
	});
var $author$project$Y20D12$navigate1 = F2(
	function (ferry, instructions) {
		navigate1:
		while (true) {
			if (instructions.b) {
				var instruction = instructions.a;
				var rest = instructions.b;
				var update = function () {
					switch (instruction.a) {
						case 0:
							var _v2 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								ferry,
								{I: ferry.I + n});
						case 1:
							var _v3 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								ferry,
								{I: ferry.I - n});
						case 2:
							var _v4 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								ferry,
								{H: ferry.H + n});
						case 3:
							var _v5 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								ferry,
								{H: ferry.H - n});
						case 5:
							var _v6 = instruction.a;
							var n = instruction.b;
							return A3($author$project$Y20D12$rotateFerry, ferry, 5, n);
						case 4:
							var _v7 = instruction.a;
							var n = instruction.b;
							return A3($author$project$Y20D12$rotateFerry, ferry, 4, n);
						default:
							var _v8 = instruction.a;
							var n = instruction.b;
							var _v9 = ferry.aM;
							switch (_v9) {
								case 0:
									return _Utils_update(
										ferry,
										{I: ferry.I + n});
								case 1:
									return _Utils_update(
										ferry,
										{I: ferry.I - n});
								case 2:
									return _Utils_update(
										ferry,
										{H: ferry.H + n});
								default:
									return _Utils_update(
										ferry,
										{H: ferry.H - n});
							}
					}
				}();
				var $temp$ferry = update,
					$temp$instructions = rest;
				ferry = $temp$ferry;
				instructions = $temp$instructions;
				continue navigate1;
			} else {
				return ferry;
			}
		}
	});
var $author$project$Y20D12$rotateWaypoint = F3(
	function (w, a, n) {
		return (n === 180) ? A2($author$project$Y20D12$Waypoint, -w.H, -w.I) : ((((a === 5) && (n === 90)) || ((a === 4) && (n === 270))) ? A2($author$project$Y20D12$Waypoint, -w.I, w.H) : ((((a === 4) && (n === 90)) || ((a === 5) && (n === 270))) ? A2($author$project$Y20D12$Waypoint, w.I, -w.H) : w));
	});
var $author$project$Y20D12$navigate2 = F2(
	function (combo, instructions) {
		navigate2:
		while (true) {
			if (instructions.b) {
				var instruction = instructions.a;
				var rest = instructions.b;
				var _v1 = combo;
				var f = _v1.a;
				var w = _v1.b;
				var ferry = function () {
					if (instruction.a === 6) {
						var _v10 = instruction.a;
						var n = instruction.b;
						return _Utils_update(
							f,
							{H: f.H + (n * w.H), I: f.I + (n * w.I)});
					} else {
						return f;
					}
				}();
				var waypoint = function () {
					switch (instruction.a) {
						case 0:
							var _v3 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								w,
								{I: w.I + n});
						case 1:
							var _v4 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								w,
								{I: w.I - n});
						case 2:
							var _v5 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								w,
								{H: w.H + n});
						case 3:
							var _v6 = instruction.a;
							var n = instruction.b;
							return _Utils_update(
								w,
								{H: w.H - n});
						case 5:
							var _v7 = instruction.a;
							var n = instruction.b;
							return A3($author$project$Y20D12$rotateWaypoint, w, 5, n);
						case 4:
							var _v8 = instruction.a;
							var n = instruction.b;
							return A3($author$project$Y20D12$rotateWaypoint, w, 4, n);
						default:
							return w;
					}
				}();
				var $temp$combo = _Utils_Tuple2(ferry, waypoint),
					$temp$instructions = rest;
				combo = $temp$combo;
				instructions = $temp$instructions;
				continue navigate2;
			} else {
				return combo;
			}
		}
	});
var $author$project$Y20D12$E = 2;
var $author$project$Y20D12$F = 6;
var $author$project$Y20D12$N = 0;
var $author$project$Y20D12$S = 1;
var $author$project$Y20D12$W = 3;
var $author$project$Y20D12$parse = function (input) {
	return A2(
		$elm$core$List$filterMap,
		function (m) {
			if ((((m.b && (!m.a.$)) && m.b.b) && (!m.b.a.$)) && (!m.b.b.b)) {
				var act = m.a.a;
				var _v1 = m.b;
				var num = _v1.a.a;
				var n = A2(
					$elm$core$Maybe$withDefault,
					0,
					$elm$core$String$toInt(num));
				var a = function () {
					switch (act) {
						case 'N':
							return 0;
						case 'S':
							return 1;
						case 'E':
							return 2;
						case 'W':
							return 3;
						case 'L':
							return 5;
						case 'R':
							return 4;
						default:
							return 6;
					}
				}();
				return $elm$core$Maybe$Just(
					_Utils_Tuple2(a, n));
			} else {
				return $elm$core$Maybe$Nothing;
			}
		},
		A2(
			$elm$core$List$map,
			function ($) {
				return $.b2;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('([NSEWLRF])([1-9]\\d*)'),
				input)));
};
var $author$project$Y20D12$answer = F2(
	function (part, input) {
		var instructions = $author$project$Y20D12$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y20D12$distance(
				A2($author$project$Y20D12$navigate1, $author$project$Y20D12$initFerry, instructions))) : $elm$core$String$fromInt(
			$author$project$Y20D12$distance(
				A2($author$project$Y20D12$navigate2, $author$project$Y20D12$initCombo, instructions).a));
	});
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $lynn$elm_arithmetic$Arithmetic$extendedGcd = F2(
	function (a, b) {
		var egcd = F6(
			function (n1, o1, n2, o2, r, s) {
				egcd:
				while (true) {
					if (!s) {
						return _Utils_Tuple3(r, o1, o2);
					} else {
						var q = (r / s) | 0;
						var $temp$n1 = o1 - (q * n1),
							$temp$o1 = n1,
							$temp$n2 = o2 - (q * n2),
							$temp$o2 = n2,
							$temp$r = s,
							$temp$s = r % s;
						n1 = $temp$n1;
						o1 = $temp$o1;
						n2 = $temp$n2;
						o2 = $temp$o2;
						r = $temp$r;
						s = $temp$s;
						continue egcd;
					}
				}
			});
		var _v0 = A6(
			egcd,
			0,
			1,
			1,
			0,
			$elm$core$Basics$abs(a),
			$elm$core$Basics$abs(b));
		var d = _v0.a;
		var x = _v0.b;
		var y = _v0.c;
		var u = (a < 0) ? (-x) : x;
		var v = (b < 0) ? (-y) : y;
		return _Utils_Tuple3(d, u, v);
	});
var $lynn$elm_arithmetic$Arithmetic$modularInverse = F2(
	function (a, modulus) {
		var _v0 = A2($lynn$elm_arithmetic$Arithmetic$extendedGcd, a, modulus);
		var d = _v0.a;
		var x = _v0.b;
		return (d === 1) ? $elm$core$Maybe$Just(
			A2($elm$core$Basics$modBy, modulus, x)) : $elm$core$Maybe$Nothing;
	});
var $elm$core$List$unzip = function (pairs) {
	var step = F2(
		function (_v0, _v1) {
			var x = _v0.a;
			var y = _v0.b;
			var xs = _v1.a;
			var ys = _v1.b;
			return _Utils_Tuple2(
				A2($elm$core$List$cons, x, xs),
				A2($elm$core$List$cons, y, ys));
		});
	return A3(
		$elm$core$List$foldr,
		step,
		_Utils_Tuple2(_List_Nil, _List_Nil),
		pairs);
};
var $lynn$elm_arithmetic$Arithmetic$chineseRemainder = function (equations) {
	var fromJustCons = F2(
		function (x, acc) {
			if (!x.$) {
				var y = x.a;
				return A2(
					$elm$core$Maybe$map,
					$elm$core$List$cons(y),
					acc);
			} else {
				return $elm$core$Maybe$Nothing;
			}
		});
	var fromJustList = A2(
		$elm$core$List$foldr,
		fromJustCons,
		$elm$core$Maybe$Just(_List_Nil));
	var _v0 = $elm$core$List$unzip(equations);
	var residues = _v0.a;
	var moduli = _v0.b;
	var m = $elm$core$List$product(moduli);
	var v = A2(
		$elm$core$List$map,
		function (x) {
			return (m / x) | 0;
		},
		moduli);
	return A2(
		$elm$core$Maybe$map,
		A2(
			$elm$core$Basics$composeR,
			A2($elm$core$List$map2, $elm$core$Basics$mul, residues),
			A2(
				$elm$core$Basics$composeR,
				A2($elm$core$List$map2, $elm$core$Basics$mul, v),
				A2(
					$elm$core$Basics$composeR,
					$elm$core$List$sum,
					function (a) {
						return A2(
							F2(
								function (dividend, modulus) {
									return A2($elm$core$Basics$modBy, modulus, dividend);
								}),
							a,
							m);
					}))),
		fromJustList(
			A3($elm$core$List$map2, $lynn$elm_arithmetic$Arithmetic$modularInverse, v, moduli)));
};
var $author$project$Y20D13$contest = function (schedule) {
	var pairs = A2(
		$elm$core$List$map,
		function (b) {
			return _Utils_Tuple2(
				A2($elm$core$Basics$modBy, b.ap, b.ap - b.bv),
				b.ap);
		},
		schedule.aX);
	var solution = $lynn$elm_arithmetic$Arithmetic$chineseRemainder(pairs);
	if (!solution.$) {
		var t = solution.a;
		return '526090562196173';
	} else {
		return 'problem';
	}
};
var $author$project$Y20D13$minimum = function (schedule) {
	var s = schedule.bJ;
	var t = s;
	var best = $elm$core$List$head(
		A2(
			$elm$core$List$sortBy,
			$elm$core$Tuple$second,
			A2(
				$elm$core$List$map,
				function (id) {
					return _Utils_Tuple2(
						id,
						(id * $elm$core$Basics$ceiling(t / id)) - s);
				},
				A2(
					$elm$core$List$map,
					function ($) {
						return $.ap;
					},
					schedule.aX))));
	if (!best.$) {
		var _v1 = best.a;
		var id = _v1.a;
		var wait = _v1.b;
		return $elm$core$String$fromInt(id * wait);
	} else {
		return 'problem';
	}
};
var $author$project$Y20D13$Bus = F2(
	function (id, offset) {
		return {ap: id, bv: offset};
	});
var $author$project$Y20D13$Schedule = F2(
	function (start, buses) {
		return {aX: buses, bJ: start};
	});
var $author$project$Y20D13$parse = function (input) {
	var raw = A2(
		$elm$core$List$map,
		$elm$core$String$toInt,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('([1-9]\\d*|x)'),
				input)));
	if (raw.b && (!raw.a.$)) {
		var start = raw.a.a;
		var ids = raw.b;
		var buses = A2(
			$elm$core$List$filterMap,
			$elm$core$Basics$identity,
			A2(
				$elm$core$List$indexedMap,
				F2(
					function (i, m) {
						if (!m.$) {
							var id = m.a;
							return $elm$core$Maybe$Just(
								A2($author$project$Y20D13$Bus, id, i));
						} else {
							return $elm$core$Maybe$Nothing;
						}
					}),
				ids));
		return A2($author$project$Y20D13$Schedule, start, buses);
	} else {
		return A2($author$project$Y20D13$Schedule, 0, _List_Nil);
	}
};
var $author$project$Y20D13$answer = F2(
	function (part, input) {
		var schedule = $author$project$Y20D13$parse(input);
		return (part === 1) ? $author$project$Y20D13$minimum(schedule) : $author$project$Y20D13$contest(schedule);
	});
var $author$project$Y20D14$answer = F2(
	function (part, input) {
		return (part === 1) ? '10050490168421' : '2173858456958';
	});
var $author$project$Y20D15$Game = F3(
	function (turn, last, before) {
		return {al: before, aO: last, aD: turn};
	});
var $author$project$Y20D15$init_ = F2(
	function (numbers, game) {
		init_:
		while (true) {
			if (numbers.b) {
				var num = numbers.a;
				var rest = numbers.b;
				var turn = game.aD + 1;
				var before = $elm$core$List$isEmpty(rest) ? game.al : A3($elm$core$Dict$insert, num, turn, game.al);
				var $temp$numbers = rest,
					$temp$game = A3($author$project$Y20D15$Game, turn, num, before);
				numbers = $temp$numbers;
				game = $temp$game;
				continue init_;
			} else {
				return game;
			}
		}
	});
var $author$project$Y20D15$init = function (numbers) {
	return A2(
		$author$project$Y20D15$init_,
		numbers,
		A3($author$project$Y20D15$Game, 0, 0, $elm$core$Dict$empty));
};
var $author$project$Y20D15$parse = function (input) {
	return A2(
		$elm$core$List$map,
		$elm$core$Maybe$withDefault(0),
		A2(
			$elm$core$List$map,
			$elm$core$String$toInt,
			A2(
				$elm$core$List$map,
				function ($) {
					return $.bY;
				},
				A2(
					$elm$regex$Regex$find,
					$author$project$Util$regex('\\d+'),
					input))));
};
var $author$project$Y20D15$play = F2(
	function (upto, game) {
		play:
		while (true) {
			if (_Utils_eq(game.aD, upto)) {
				return game.aO;
			} else {
				var turn = game.aD + 1;
				var last = function () {
					var _v0 = A2($elm$core$Dict$get, game.aO, game.al);
					if (_v0.$ === 1) {
						return 0;
					} else {
						var previous = _v0.a;
						return game.aD - previous;
					}
				}();
				var before = A3($elm$core$Dict$insert, game.aO, game.aD, game.al);
				var $temp$upto = upto,
					$temp$game = A3($author$project$Y20D15$Game, turn, last, before);
				upto = $temp$upto;
				game = $temp$game;
				continue play;
			}
		}
	});
var $author$project$Y20D15$answer = F2(
	function (part, input) {
		var upto = (part === 1) ? 2020 : 30000000;
		var start = $author$project$Y20D15$parse(input);
		return $elm$core$String$fromInt(
			A2(
				$author$project$Y20D15$play,
				upto,
				$author$project$Y20D15$init(start)));
	});
var $author$project$Y20D16$ok = F2(
	function (num, _v0) {
		var min = _v0.a;
		var max = _v0.b;
		return (_Utils_cmp(num, max) < 1) && (_Utils_cmp(num, min) > -1);
	});
var $author$project$Y20D16$valid = F2(
	function (rule, num) {
		return A2($author$project$Y20D16$ok, num, rule.E) || A2($author$project$Y20D16$ok, num, rule.F);
	});
var $author$project$Y20D16$noValidRules = F2(
	function (rules, num) {
		noValidRules:
		while (true) {
			if (rules.b) {
				var rule = rules.a;
				var rest = rules.b;
				if (A2($author$project$Y20D16$valid, rule, num)) {
					return $elm$core$Maybe$Nothing;
				} else {
					var $temp$rules = rest,
						$temp$num = num;
					rules = $temp$rules;
					num = $temp$num;
					continue noValidRules;
				}
			} else {
				return $elm$core$Maybe$Just(num);
			}
		}
	});
var $author$project$Y20D16$findInvalid = F2(
	function (rules, ticket) {
		return A2(
			$elm$core$List$filterMap,
			$author$project$Y20D16$noValidRules(rules),
			ticket);
	});
var $author$project$Y20D16$possiblesFromIndexNames = F3(
	function (names, index, possibles) {
		possiblesFromIndexNames:
		while (true) {
			if (names.b) {
				var name = names.a;
				var rest = names.b;
				var counts = A2(
					$elm$core$Maybe$withDefault,
					$elm$core$Dict$empty,
					A2($elm$core$Dict$get, index, possibles));
				var current = A2(
					$elm$core$Maybe$withDefault,
					0,
					A2($elm$core$Dict$get, name, counts));
				var update = A3($elm$core$Dict$insert, name, current + 1, counts);
				var possibles_ = A3($elm$core$Dict$insert, index, update, possibles);
				var $temp$names = rest,
					$temp$index = index,
					$temp$possibles = possibles_;
				names = $temp$names;
				index = $temp$index;
				possibles = $temp$possibles;
				continue possiblesFromIndexNames;
			} else {
				return possibles;
			}
		}
	});
var $author$project$Y20D16$possiblesFromIndexNums = F3(
	function (indexNums, rules, possibles) {
		possiblesFromIndexNums:
		while (true) {
			if (indexNums.b) {
				var _v1 = indexNums.a;
				var index = _v1.a;
				var num = _v1.b;
				var rest = indexNums.b;
				var names = A2(
					$elm$core$List$map,
					function ($) {
						return $.bt;
					},
					A2(
						$elm$core$List$filter,
						function (rule) {
							return A2($author$project$Y20D16$valid, rule, num);
						},
						rules));
				var possibles_ = A3($author$project$Y20D16$possiblesFromIndexNames, names, index, possibles);
				var $temp$indexNums = rest,
					$temp$rules = rules,
					$temp$possibles = possibles_;
				indexNums = $temp$indexNums;
				rules = $temp$rules;
				possibles = $temp$possibles;
				continue possiblesFromIndexNums;
			} else {
				return possibles;
			}
		}
	});
var $author$project$Y20D16$getPossibles = F3(
	function (tickets, rules, possibles) {
		getPossibles:
		while (true) {
			if (tickets.b) {
				var ticket = tickets.a;
				var rest = tickets.b;
				var indexNums = A2(
					$elm$core$List$indexedMap,
					F2(
						function (index, num) {
							return _Utils_Tuple2(index, num);
						}),
					ticket);
				var possibles_ = A3($author$project$Y20D16$possiblesFromIndexNums, indexNums, rules, possibles);
				var $temp$tickets = rest,
					$temp$rules = rules,
					$temp$possibles = possibles_;
				tickets = $temp$tickets;
				rules = $temp$rules;
				possibles = $temp$possibles;
				continue getPossibles;
			} else {
				return possibles;
			}
		}
	});
var $elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2($elm$core$Dict$map, func, left),
				A2($elm$core$Dict$map, func, right));
		}
	});
var $author$project$Y20D16$pruneInexes = F2(
	function (indexes, dict) {
		if (indexes.b) {
			var index = indexes.a;
			var rest = indexes.b;
			return A2(
				$author$project$Y20D16$pruneInexes,
				rest,
				A2($elm$core$Dict$remove, index, dict));
		} else {
			return dict;
		}
	});
var $author$project$Y20D16$pruneNames = F2(
	function (names, dict) {
		if (names.b) {
			var name = names.a;
			var rest = names.b;
			return A2(
				$author$project$Y20D16$pruneNames,
				rest,
				A2($elm$core$Dict$remove, name, dict));
		} else {
			return dict;
		}
	});
var $author$project$Y20D16$possiblesToNames = F3(
	function (len, possible, positions) {
		var certain = $elm$core$Dict$fromList(
			A2(
				$elm$core$List$filterMap,
				function (_v1) {
					var index = _v1.a;
					var maybeName = _v1.b;
					if (!maybeName.$) {
						var name = maybeName.a;
						return $elm$core$Maybe$Just(
							_Utils_Tuple2(index, name));
					} else {
						return $elm$core$Maybe$Nothing;
					}
				},
				$elm$core$Dict$toList(
					A2(
						$elm$core$Dict$map,
						F2(
							function (index, candidates) {
								return ($elm$core$List$length(candidates) === 1) ? $elm$core$List$head(candidates) : $elm$core$Maybe$Nothing;
							}),
						A2(
							$elm$core$Dict$map,
							F2(
								function (index, dict) {
									return A2(
										$elm$core$List$map,
										$elm$core$Tuple$first,
										A2(
											$elm$core$List$filter,
											function (_v0) {
												var name = _v0.a;
												var count = _v0.b;
												return _Utils_eq(count, len);
											},
											$elm$core$Dict$toList(dict)));
								}),
							possible)))));
		var reduced = A2(
			$elm$core$Dict$map,
			F2(
				function (index, dict) {
					return A2(
						$author$project$Y20D16$pruneNames,
						$elm$core$Dict$values(certain),
						dict);
				}),
			A2(
				$author$project$Y20D16$pruneInexes,
				$elm$core$Dict$keys(certain),
				possible));
		return ($elm$core$Dict$size(certain) > 0) ? A3(
			$author$project$Y20D16$possiblesToNames,
			len,
			reduced,
			A2($elm$core$Dict$union, certain, positions)) : positions;
	});
var $author$project$Y20D16$getIndexToName = function (data) {
	var validTickets = A2(
		$elm$core$List$filter,
		function (ticket) {
			return _Utils_eq(
				A2($author$project$Y20D16$findInvalid, data.aT, ticket),
				_List_Nil);
		},
		data.at);
	var possibles = A3($author$project$Y20D16$getPossibles, validTickets, data.aT, $elm$core$Dict$empty);
	var len = $elm$core$List$length(validTickets);
	return A3($author$project$Y20D16$possiblesToNames, len, possibles, $elm$core$Dict$empty);
};
var $author$project$Y20D16$multiplySelected = F2(
	function (start, data) {
		var indexToName = $author$project$Y20D16$getIndexToName(data);
		return $elm$core$List$product(
			A2(
				$elm$core$List$indexedMap,
				F2(
					function (index, num) {
						var _v0 = A2($elm$core$Dict$get, index, indexToName);
						if (!_v0.$) {
							var name = _v0.a;
							return A2($elm$core$String$startsWith, start, name) ? num : 1;
						} else {
							return 1;
						}
					}),
				data.a0));
	});
var $author$project$Y20D16$Data = F3(
	function (rules, mine, near) {
		return {a0: mine, at: near, aT: rules};
	});
var $author$project$Y20D16$Rule = F3(
	function (name, r1, r2) {
		return {bt: name, E: r1, F: r2};
	});
var $author$project$Y20D16$toInt = function (str) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(str));
};
var $author$project$Y20D16$toInts = function (str) {
	return A2(
		$elm$core$List$map,
		$author$project$Y20D16$toInt,
		A2(
			$elm$core$List$map,
			function ($) {
				return $.bY;
			},
			A2(
				$elm$regex$Regex$find,
				$author$project$Util$regex('\\d+'),
				str)));
};
var $author$project$Y20D16$parse_ = F3(
	function (state, data, lines) {
		parse_:
		while (true) {
			if (lines.b) {
				var line = lines.a;
				var rest = lines.b;
				switch (state) {
					case 0:
						if (A2($elm$core$String$contains, 'your ticket', line)) {
							var $temp$state = 1,
								$temp$data = data,
								$temp$lines = rest;
							state = $temp$state;
							data = $temp$data;
							lines = $temp$lines;
							continue parse_;
						} else {
							var matches = A2(
								$elm$core$List$map,
								function ($) {
									return $.b2;
								},
								A2(
									$elm$regex$Regex$find,
									$author$project$Util$regex('([a-z].*): (\\d+)-(\\d+) or (\\d+)-(\\d+)'),
									line));
							if ((((((((((((matches.b && matches.a.b) && (!matches.a.a.$)) && matches.a.b.b) && (!matches.a.b.a.$)) && matches.a.b.b.b) && (!matches.a.b.b.a.$)) && matches.a.b.b.b.b) && (!matches.a.b.b.b.a.$)) && matches.a.b.b.b.b.b) && (!matches.a.b.b.b.b.a.$)) && (!matches.a.b.b.b.b.b.b)) && (!matches.b.b)) {
								var _v3 = matches.a;
								var name = _v3.a.a;
								var _v4 = _v3.b;
								var r11 = _v4.a.a;
								var _v5 = _v4.b;
								var r12 = _v5.a.a;
								var _v6 = _v5.b;
								var r21 = _v6.a.a;
								var _v7 = _v6.b;
								var r22 = _v7.a.a;
								var rule = A3(
									$author$project$Y20D16$Rule,
									name,
									_Utils_Tuple2(
										$author$project$Y20D16$toInt(r11),
										$author$project$Y20D16$toInt(r12)),
									_Utils_Tuple2(
										$author$project$Y20D16$toInt(r21),
										$author$project$Y20D16$toInt(r22)));
								var data_ = _Utils_update(
									data,
									{
										aT: A2($elm$core$List$cons, rule, data.aT)
									});
								var $temp$state = state,
									$temp$data = data_,
									$temp$lines = rest;
								state = $temp$state;
								data = $temp$data;
								lines = $temp$lines;
								continue parse_;
							} else {
								var $temp$state = state,
									$temp$data = data,
									$temp$lines = rest;
								state = $temp$state;
								data = $temp$data;
								lines = $temp$lines;
								continue parse_;
							}
						}
					case 1:
						if (A2($elm$core$String$contains, 'nearby tickets', line)) {
							var $temp$state = 2,
								$temp$data = data,
								$temp$lines = rest;
							state = $temp$state;
							data = $temp$data;
							lines = $temp$lines;
							continue parse_;
						} else {
							var mine = $author$project$Y20D16$toInts(line);
							var data_ = ($elm$core$List$length(mine) > 0) ? _Utils_update(
								data,
								{a0: mine}) : data;
							var $temp$state = state,
								$temp$data = data_,
								$temp$lines = rest;
							state = $temp$state;
							data = $temp$data;
							lines = $temp$lines;
							continue parse_;
						}
					case 2:
						var near = $author$project$Y20D16$toInts(line);
						var data_ = ($elm$core$List$length(near) > 0) ? _Utils_update(
							data,
							{
								at: A2($elm$core$List$cons, near, data.at)
							}) : data;
						var $temp$state = state,
							$temp$data = data_,
							$temp$lines = rest;
						state = $temp$state;
						data = $temp$data;
						lines = $temp$lines;
						continue parse_;
					default:
						var $temp$state = state,
							$temp$data = data,
							$temp$lines = rest;
						state = $temp$state;
						data = $temp$data;
						lines = $temp$lines;
						continue parse_;
				}
			} else {
				return data;
			}
		}
	});
var $author$project$Y20D16$parse = function (input) {
	return A3(
		$author$project$Y20D16$parse_,
		0,
		A3($author$project$Y20D16$Data, _List_Nil, _List_Nil, _List_Nil),
		A2(
			$elm$regex$Regex$split,
			$author$project$Util$regex('\\n'),
			input));
};
var $author$project$Y20D16$sumInvalid = function (data) {
	return $elm$core$List$sum(
		$elm$core$List$concat(
			A2(
				$elm$core$List$map,
				$author$project$Y20D16$findInvalid(data.aT),
				data.at)));
};
var $author$project$Y20D16$answer = F2(
	function (part, input) {
		var data = $author$project$Y20D16$parse(input);
		return (part === 1) ? $elm$core$String$fromInt(
			$author$project$Y20D16$sumInvalid(data)) : $elm$core$String$fromInt(
			A2($author$project$Y20D16$multiplySelected, 'departure', data));
	});
var $author$project$Y20$answer = F3(
	function (day, part, input) {
		switch (day) {
			case 1:
				return A2($author$project$Y20D01$answer, part, input);
			case 2:
				return A2($author$project$Y20D02$answer, part, input);
			case 3:
				return A2($author$project$Y20D03$answer, part, input);
			case 4:
				return A2($author$project$Y20D04$answer, part, input);
			case 5:
				return A2($author$project$Y20D05$answer, part, input);
			case 6:
				return A2($author$project$Y20D06$answer, part, input);
			case 7:
				return A2($author$project$Y20D07$answer, part, input);
			case 8:
				return A2($author$project$Y20D08$answer, part, input);
			case 9:
				return A2($author$project$Y20D09$answer, part, input);
			case 10:
				return A2($author$project$Y20D10$answer, part, input);
			case 11:
				return A2($author$project$Y20D11$answer, part, input);
			case 12:
				return A2($author$project$Y20D12$answer, part, input);
			case 13:
				return A2($author$project$Y20D13$answer, part, input);
			case 14:
				return A2($author$project$Y20D14$answer, part, input);
			case 15:
				return A2($author$project$Y20D15$answer, part, input);
			case 16:
				return A2($author$project$Y20D16$answer, part, input);
			default:
				return 'year 2020, day ' + ($elm$core$String$fromInt(day) + ': not available');
		}
	});
var $author$project$Main$getAnswer = F3(
	function (model, part, data) {
		var _v0 = model.a;
		switch (_v0) {
			case 2015:
				return A3($author$project$Y15$answer, model.d, part, data);
			case 2016:
				return A3($author$project$Y16$answer, model.d, part, data);
			case 2020:
				return A3($author$project$Y20$answer, model.d, part, data);
			default:
				return '';
		}
	});
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Ports$prepareAnswer = _Platform_outgoingPort('prepareAnswer', $elm$json$Json$Encode$int);
var $author$project$Main$prepareAnswer = function (part) {
	return $author$project$Ports$prepareAnswer(part);
};
var $author$project$Main$thinking = function (part) {
	return (part === 1) ? _Utils_Tuple2(true, false) : _Utils_Tuple2(false, true);
};
var $author$project$Main$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 0:
				var year = msg.a;
				var newModel = A2($author$project$Main$newProblem, year, model.d);
				return _Utils_Tuple2(
					newModel,
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								$author$project$Main$getData(newModel)
							])));
			case 1:
				var day = msg.a;
				var newModel = A2($author$project$Main$newProblem, model.a, day);
				return _Utils_Tuple2(
					newModel,
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								$author$project$Main$getData(newModel)
							])));
			case 2:
				var data = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							X: $elm$core$Maybe$Just(data)
						}),
					$elm$core$Platform$Cmd$none);
			case 4:
				var part = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							ae: $author$project$Main$thinking(part)
						}),
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								$author$project$Main$prepareAnswer(part)
							])));
			case 3:
				var part = msg.a;
				var data = A2($elm$core$Maybe$withDefault, '', model.X);
				var answer = A3($author$project$Main$getAnswer, model, part, data);
				var answers = (part === 1) ? _Utils_Tuple2(
					$elm$core$Maybe$Just(answer),
					model.J.b) : _Utils_Tuple2(
					model.J.a,
					$elm$core$Maybe$Just(answer));
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{J: answers, ae: $author$project$Main$initThinks}),
					$elm$core$Platform$Cmd$none);
			case 5:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{ao: true}),
					$elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{ao: false}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Main$SelectDay = function (a) {
	return {$: 1, a: a};
};
var $author$project$Main$SelectYear = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$html$Html$form = _VirtualDom_node('form');
var $elm$html$Html$hr = _VirtualDom_node('hr');
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 1, a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$pre = _VirtualDom_node('pre');
var $elm$html$Html$select = _VirtualDom_node('select');
var $elm$html$Html$table = _VirtualDom_node('table');
var $elm$html$Html$tbody = _VirtualDom_node('tbody');
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $elm$html$Html$thead = _VirtualDom_node('thead');
var $author$project$Main$toInt = function (str) {
	return A2(
		$elm$core$Maybe$withDefault,
		0,
		$elm$core$String$toInt(str));
};
var $author$project$Main$Prepare = function (a) {
	return {$: 4, a: a};
};
var $author$project$Main$failed = F3(
	function (year, day, part) {
		var key = A2(
			$elm$core$String$join,
			'-',
			A2(
				$elm$core$List$map,
				$elm$core$String$fromInt,
				_List_fromArray(
					[year, day, part])));
		switch (key) {
			case '2015-12-2':
				return true;
			case '2015-22-1':
				return true;
			case '2015-22-2':
				return true;
			case '2016-11-1':
				return true;
			case '2016-11-2':
				return true;
			default:
				return false;
		}
	});
var $elm$html$Html$img = _VirtualDom_node('img');
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$span = _VirtualDom_node('span');
var $author$project$Main$speed = F3(
	function (year, day, part) {
		var key = A2(
			$elm$core$String$join,
			'-',
			A2(
				$elm$core$List$map,
				$elm$core$String$fromInt,
				_List_fromArray(
					[year, day, part])));
		switch (key) {
			case '2015-4-1':
				return 2;
			case '2015-4-2':
				return 3;
			case '2015-6-1':
				return 2;
			case '2015-6-2':
				return 3;
			case '2015-10-1':
				return 1;
			case '2015-10-2':
				return 2;
			case '2015-11-1':
				return 1;
			case '2015-11-2':
				return 2;
			case '2015-13-1':
				return 1;
			case '2015-13-2':
				return 2;
			case '2015-15-1':
				return 2;
			case '2015-15-2':
				return 2;
			case '2015-17-1':
				return 2;
			case '2015-17-2':
				return 2;
			case '2015-18-1':
				return 2;
			case '2015-18-2':
				return 2;
			case '2015-20-1':
				return 2;
			case '2015-20-2':
				return 2;
			case '2015-24-1':
				return 2;
			case '2015-24-2':
				return 1;
			case '2015-25-1':
				return 1;
			case '2016-5-1':
				return 3;
			case '2016-5-2':
				return 3;
			case '2016-9-2':
				return 3;
			case '2016-12-1':
				return 1;
			case '2016-12-2':
				return 2;
			case '2016-14-1':
				return 2;
			case '2016-14-2':
				return 4;
			case '2016-15-1':
				return 1;
			case '2016-15-2':
				return 2;
			case '2016-16-2':
				return 4;
			case '2016-17-2':
				return 2;
			case '2016-18-2':
				return 1;
			case '2016-22-1':
				return 1;
			case '2016-24-1':
				return 2;
			case '2016-24-2':
				return 2;
			case '2020-1-2':
				return 1;
			case '2020-11-1':
				return 1;
			case '2020-11-2':
				return 1;
			case '2020-15-2':
				return 2;
			default:
				return 0;
		}
	});
var $author$project$Main$speedColour = function (time) {
	switch (time) {
		case 0:
			return 'success';
		case 1:
			return 'info';
		case 2:
			return 'primary';
		case 3:
			return 'warning';
		default:
			return 'danger';
	}
};
var $author$project$Main$speedIndicator = function (time) {
	switch (time) {
		case 0:
			return '⚡️';
		case 1:
			return '⏳';
		case 2:
			return '🐌';
		case 3:
			return '☕️';
		default:
			return '☠️';
	}
};
var $elm$html$Html$Attributes$src = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'src',
		_VirtualDom_noJavaScriptOrHtmlUri(url));
};
var $elm$html$Html$td = _VirtualDom_node('td');
var $elm$html$Html$tr = _VirtualDom_node('tr');
var $author$project$Main$viewAnswer = F2(
	function (model, part) {
		var noSolution = A3($author$project$Main$failed, model.a, model.d, part);
		var busy = (part === 1) ? model.ae.a : model.ae.b;
		var answer = (part === 1) ? model.J.a : model.J.b;
		var display = function () {
			if (noSolution) {
				var data = A2($elm$core$Maybe$withDefault, '', model.X);
				return $elm$html$Html$text(
					A3($author$project$Main$getAnswer, model, part, data));
			} else {
				if (busy) {
					return A2(
						$elm$html$Html$img,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$src('/images/loader.gif')
							]),
						_List_Nil);
				} else {
					if (answer.$ === 1) {
						var time = A3($author$project$Main$speed, model.a, model.d, part);
						var symbol = $author$project$Main$speedIndicator(time);
						var colour = $author$project$Main$speedColour(time);
						return A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('btn btn-' + (colour + ' btn-sm')),
									$elm$html$Html$Events$onClick(
									$author$project$Main$Prepare(part))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(symbol)
								]));
					} else {
						var ans = answer.a;
						return ($elm$core$String$length(ans) > 32) ? A2(
							$elm$html$Html$pre,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(ans)
								])) : $elm$html$Html$text(ans);
					}
				}
			}
		}();
		return A2(
			$elm$html$Html$tr,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('d-flex')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$td,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('col-2 text-center')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							$elm$core$String$fromInt(part))
						])),
					A2(
					$elm$html$Html$td,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('col-10 text-center')
						]),
					_List_fromArray(
						[display]))
				]));
	});
var $author$project$Main$failedIndicator = function (failedFlag) {
	return failedFlag ? '✘' : '✔︎';
};
var $elm$html$Html$option = _VirtualDom_node('option');
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$selected = $elm$html$Html$Attributes$boolProperty('selected');
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Main$viewDayOption = F3(
	function (year, chosen, day) {
		var str = $elm$core$String$fromInt(day);
		var speedSymbol = $author$project$Main$speedIndicator(
			A2(
				$elm$core$Maybe$withDefault,
				0,
				$elm$core$List$maximum(
					A2(
						$elm$core$List$map,
						A2($author$project$Main$speed, year, day),
						_List_fromArray(
							[1, 2])))));
		var pad = ($elm$core$String$length(str) === 1) ? ('0' + str) : str;
		var failedSymbol = $author$project$Main$failedIndicator(
			A3(
				$elm$core$List$foldl,
				$elm$core$Basics$or,
				false,
				A2(
					$elm$core$List$map,
					A2($author$project$Main$failed, year, day),
					_List_fromArray(
						[1, 2]))));
		var txt = 'Day ' + (pad + (' ' + (failedSymbol + (' ' + speedSymbol))));
		return A2(
			$elm$html$Html$option,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$value(str),
					$elm$html$Html$Attributes$selected(
					_Utils_eq(chosen, day))
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(txt)
				]));
	});
var $author$project$Main$viewHeader = A2(
	$elm$html$Html$tr,
	_List_fromArray(
		[
			$elm$html$Html$Attributes$class('d-flex')
		]),
	_List_fromArray(
		[
			A2(
			$elm$html$Html$td,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('col-2 text-center')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Part')
				])),
			A2(
			$elm$html$Html$td,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('col-10 text-center')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Answer')
				]))
		]));
var $author$project$Main$HideHelp = {$: 6};
var $author$project$Main$ShowHelp = {$: 5};
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$html$Html$p = _VirtualDom_node('p');
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $author$project$Main$speedDescription = function (time) {
	switch (time) {
		case 0:
			return 'Answer should be returned instantly';
		case 1:
			return 'Won\'t take more than a few seconds';
		case 2:
			return 'Will take more like a minute';
		case 3:
			return 'You should have time to get a coffee';
		default:
			return 'May take many hours or run out of memory';
	}
};
var $author$project$Main$viewIcon = function (time) {
	var symbol = $author$project$Main$speedIndicator(time);
	var description = $author$project$Main$speedDescription(time);
	var colour = $author$project$Main$speedColour(time);
	var klass = 'btn btn-sm btn-' + colour;
	return A2(
		$elm$html$Html$tr,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('d-flex')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$td,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('col-2 text-center')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class(klass)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(symbol)
							]))
					])),
				A2(
				$elm$html$Html$td,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('col-10')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(description)
					]))
			]));
};
var $author$project$Main$viewHelp = function (show) {
	var btnText = function (txt) {
		return $elm$html$Html$text(txt + ' Button Decriptions');
	};
	if (show) {
		var trows = A2(
			$elm$core$List$map,
			$author$project$Main$viewIcon,
			_List_fromArray(
				[0, 1, 2, 3, 4]));
		var help = ' Icon Descriptions';
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('row')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('offset-1 col-10 offset-lg-2 col-lg-8')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$p,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('text-center')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$button,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$type_('button'),
											$elm$html$Html$Attributes$class('btn btn-sm btn-secondary'),
											$elm$html$Html$Events$onClick($author$project$Main$HideHelp)
										]),
									_List_fromArray(
										[
											btnText('Hide')
										]))
								])),
							A2(
							$elm$html$Html$table,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('table table-bordered')
								]),
							_List_fromArray(
								[
									A2($elm$html$Html$tbody, _List_Nil, trows)
								]))
						]))
				]));
	} else {
		return A2(
			$elm$html$Html$p,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('text-center')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('button'),
							$elm$html$Html$Attributes$class('btn btn-sm btn-secondary'),
							$elm$html$Html$Events$onClick($author$project$Main$ShowHelp)
						]),
					_List_fromArray(
						[
							btnText('Show')
						]))
				]));
	}
};
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $elm$core$String$right = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(
			$elm$core$String$slice,
			-n,
			$elm$core$String$length(string),
			string);
	});
var $elm$html$Html$Attributes$target = $elm$html$Html$Attributes$stringProperty('target');
var $author$project$Main$codeLink = function (model) {
	var year = $elm$core$String$fromInt(model.a);
	var shortYear = A2($elm$core$String$right, 2, year);
	var scheme = 'https://';
	var path = 'sanichi/mio/src/master/app/views/pages/aoc/' + (year + '/');
	var domain = 'bitbucket.org/';
	var day = $elm$core$String$fromInt(model.d);
	var paddedDay = (model.d > 9) ? day : ('0' + day);
	var file = 'Y' + (shortYear + ('D' + (paddedDay + '.elm')));
	var link = _Utils_ap(
		scheme,
		_Utils_ap(
			domain,
			_Utils_ap(path, file)));
	return A2(
		$elm$html$Html$a,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$href(link),
				$elm$html$Html$Attributes$target('external2')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('Code')
			]));
};
var $author$project$Main$probLink = function (model) {
	var year = $elm$core$String$fromInt(model.a);
	var scheme = 'https://';
	var path = year + '/day/';
	var domain = 'adventofcode.com/';
	var day = $elm$core$String$fromInt(model.d);
	var file = day;
	var link = _Utils_ap(
		scheme,
		_Utils_ap(
			domain,
			_Utils_ap(path, file)));
	return A2(
		$elm$html$Html$a,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$href(link),
				$elm$html$Html$Attributes$target('external')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('Problem')
			]));
};
var $author$project$Main$viewLinks = function (model) {
	return A2(
		$elm$html$Html$tr,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$td,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('text-center')
					]),
				_List_fromArray(
					[
						$author$project$Main$probLink(model),
						$elm$html$Html$text(' • '),
						$author$project$Main$codeLink(model)
					]))
			]));
};
var $author$project$Main$getNote = F2(
	function (year, day) {
		var key = A2(
			$elm$core$String$join,
			'-',
			A2(
				$elm$core$List$map,
				$elm$core$String$fromInt,
				_List_fromArray(
					[year, day])));
		switch (key) {
			case '2015-12':
				return $elm$core$Maybe$Just('For part 2 I couldn\'t see any way to filter out the \"red\" parts of the object in Elm so did it in Perl instead.');
			case '2015-22':
				return $elm$core$Maybe$Just('I found this problem highly annoying as there were so many fiddly details to take care of. After many iteratons of a Perl 5 program eventually produced the right answers, I couldn\'t face trying to redo it all in Elm.');
			case '2016-11':
				return $elm$core$Maybe$Just('I didn\'t have much of a clue about this one so quickly admitted defeat and spent my time on other things that day.');
			case '2016-14':
				return $elm$core$Maybe$Just('I left part 2 running for nearly 24 hours and it still hadn\'t finished. So, giving up on that, I wrote a Perl 5 program based on the same algorithm and it only took 20 seconds! I estimate MD5 digests are roughly 100 times faster in Perl 5 than in Elm, so that\'s not the whole story since 100 times 20 seconds is only about half an hour.');
			case '2016-16':
				return $elm$core$Maybe$Just('The Elm program for part 2 crashed my browser window after a few minutes (presumably out of memory) so instead I wrote a Perl 5 program which got the answer in less than a minute while using almost 3GB of memory.');
			case '2016-23':
				return $elm$core$Maybe$Just('There was a strange error after converting from 0.18 to 0.19 which I couldn\'t figure out so I abandoned this one even though it had been working.');
			case '2020-13':
				return $elm$core$Maybe$Just('Elm can\'t handle 64-bit integers and could only solve the toy examples. For the proper part 2 problem, a Chinese Remainder algorithm from another language (I picked Ruby) had to be used.');
			case '2020-14':
				return $elm$core$Maybe$Just('Had to avoid Elm for this one because it involves 64-bit integers. A quick Ruby script did the job.');
			default:
				return $elm$core$Maybe$Nothing;
		}
	});
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$Main$viewNote = function (model) {
	var note = A2(
		$elm$core$Maybe$withDefault,
		'',
		A2($author$project$Main$getNote, model.a, model.d));
	var display = (note === '') ? 'none' : 'table-row';
	return A2(
		$elm$html$Html$tr,
		_List_fromArray(
			[
				A2($elm$html$Html$Attributes$style, 'display', display)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$td,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text(note)
					]))
			]));
};
var $author$project$Main$viewYearOption = F2(
	function (chosen, year) {
		var str = $elm$core$String$fromInt(year);
		var txt = 'Year ' + str;
		return A2(
			$elm$html$Html$option,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$value(str),
					$elm$html$Html$Attributes$selected(
					_Utils_eq(chosen, year))
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(txt)
				]));
	});
var $author$project$Main$view = function (model) {
	var yearOptions = A2(
		$elm$core$List$map,
		$author$project$Main$viewYearOption(model.a),
		A2(
			$elm$core$List$map,
			function ($) {
				return $.a;
			},
			model.ai));
	var onYearChange = $elm$html$Html$Events$onInput(
		A2($elm$core$Basics$composeR, $author$project$Main$toInt, $author$project$Main$SelectYear));
	var onDayChange = $elm$html$Html$Events$onInput(
		A2($elm$core$Basics$composeR, $author$project$Main$toInt, $author$project$Main$SelectDay));
	var dayOptions = A2(
		$elm$core$List$map,
		A2($author$project$Main$viewDayOption, model.a, model.d),
		A2(
			$elm$core$Maybe$withDefault,
			_List_Nil,
			$elm$core$List$head(
				A2(
					$elm$core$List$map,
					function ($) {
						return $.M;
					},
					A2(
						$elm$core$List$filter,
						function (y) {
							return _Utils_eq(y.a, model.a);
						},
						model.ai)))));
	var data = A2($elm$core$Maybe$withDefault, '', model.X);
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('col')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$form,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('form-inline justify-content-around')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$select,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('form-control'),
												onYearChange
											]),
										yearOptions),
										A2(
										$elm$html$Html$select,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('form-control'),
												onDayChange
											]),
										dayOptions)
									]))
							]))
					])),
				A2($elm$html$Html$hr, _List_Nil, _List_Nil),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('offset-sm-1 col-sm-10 offset-md-2 col-md-8 offset-lg-3 col-lg-6')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$table,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('table table-bordered')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$thead,
										_List_Nil,
										_List_fromArray(
											[$author$project$Main$viewHeader])),
										A2(
										$elm$html$Html$tbody,
										_List_Nil,
										_List_fromArray(
											[
												A2($author$project$Main$viewAnswer, model, 1),
												A2($author$project$Main$viewAnswer, model, 2)
											]))
									]))
							]))
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('offset-sm-1 col-sm-10 offset-md-2 col-md-8 offset-lg-3 col-lg-6')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$table,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('table table-bordered')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$tbody,
										_List_Nil,
										_List_fromArray(
											[
												$author$project$Main$viewLinks(model),
												$author$project$Main$viewNote(model)
											]))
									]))
							]))
					])),
				A2($elm$html$Html$hr, _List_Nil, _List_Nil),
				$author$project$Main$viewHelp(model.ao),
				A2($elm$html$Html$hr, _List_Nil, _List_Nil),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('col')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$pre,
								_List_Nil,
								_List_fromArray(
									[
										$elm$html$Html$text(data)
									]))
							]))
					]))
			]));
};
var $author$project$Main$main = $elm$browser$Browser$element(
	{bX: $author$project$Main$init, b3: $author$project$Main$subscriptions, b5: $author$project$Main$update, b6: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	A2(
		$elm$json$Json$Decode$andThen,
		function (year) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (day) {
					return $elm$json$Json$Decode$succeed(
						{d: day, a: year});
				},
				A2($elm$json$Json$Decode$field, 'day', $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$field, 'year', $elm$json$Json$Decode$string)))(0)}});}(this));