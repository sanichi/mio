
(function() {
'use strict';

function F2(fun)
{
  function wrapper(a) { return function(b) { return fun(a,b); }; }
  wrapper.arity = 2;
  wrapper.func = fun;
  return wrapper;
}

function F3(fun)
{
  function wrapper(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  }
  wrapper.arity = 3;
  wrapper.func = fun;
  return wrapper;
}

function F4(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  }
  wrapper.arity = 4;
  wrapper.func = fun;
  return wrapper;
}

function F5(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  }
  wrapper.arity = 5;
  wrapper.func = fun;
  return wrapper;
}

function F6(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  }
  wrapper.arity = 6;
  wrapper.func = fun;
  return wrapper;
}

function F7(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  }
  wrapper.arity = 7;
  wrapper.func = fun;
  return wrapper;
}

function F8(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  }
  wrapper.arity = 8;
  wrapper.func = fun;
  return wrapper;
}

function F9(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  }
  wrapper.arity = 9;
  wrapper.func = fun;
  return wrapper;
}

function A2(fun, a, b)
{
  return fun.arity === 2
    ? fun.func(a, b)
    : fun(a)(b);
}
function A3(fun, a, b, c)
{
  return fun.arity === 3
    ? fun.func(a, b, c)
    : fun(a)(b)(c);
}
function A4(fun, a, b, c, d)
{
  return fun.arity === 4
    ? fun.func(a, b, c, d)
    : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e)
{
  return fun.arity === 5
    ? fun.func(a, b, c, d, e)
    : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f)
{
  return fun.arity === 6
    ? fun.func(a, b, c, d, e, f)
    : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g)
{
  return fun.arity === 7
    ? fun.func(a, b, c, d, e, f, g)
    : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h)
{
  return fun.arity === 8
    ? fun.func(a, b, c, d, e, f, g, h)
    : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i)
{
  return fun.arity === 9
    ? fun.func(a, b, c, d, e, f, g, h, i)
    : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

//import Native.List //

var _elm_lang$core$Native_Array = function() {

// A RRB-Tree has two distinct data types.
// Leaf -> "height"  is always 0
//         "table"   is an array of elements
// Node -> "height"  is always greater than 0
//         "table"   is an array of child nodes
//         "lengths" is an array of accumulated lengths of the child nodes

// M is the maximal table size. 32 seems fast. E is the allowed increase
// of search steps when concatting to find an index. Lower values will
// decrease balancing, but will increase search steps.
var M = 32;
var E = 2;

// An empty array.
var empty = {
	ctor: '_Array',
	height: 0,
	table: []
};


function get(i, array)
{
	if (i < 0 || i >= length(array))
	{
		throw new Error(
			'Index ' + i + ' is out of range. Check the length of ' +
			'your array first or use getMaybe or getWithDefault.');
	}
	return unsafeGet(i, array);
}


function unsafeGet(i, array)
{
	for (var x = array.height; x > 0; x--)
	{
		var slot = i >> (x * 5);
		while (array.lengths[slot] <= i)
		{
			slot++;
		}
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array = array.table[slot];
	}
	return array.table[i];
}


// Sets the value at the index i. Only the nodes leading to i will get
// copied and updated.
function set(i, item, array)
{
	if (i < 0 || length(array) <= i)
	{
		return array;
	}
	return unsafeSet(i, item, array);
}


function unsafeSet(i, item, array)
{
	array = nodeCopy(array);

	if (array.height === 0)
	{
		array.table[i] = item;
	}
	else
	{
		var slot = getSlot(i, array);
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array.table[slot] = unsafeSet(i, item, array.table[slot]);
	}
	return array;
}


function initialize(len, f)
{
	if (len <= 0)
	{
		return empty;
	}
	var h = Math.floor( Math.log(len) / Math.log(M) );
	return initialize_(f, h, 0, len);
}

function initialize_(f, h, from, to)
{
	if (h === 0)
	{
		var table = new Array((to - from) % (M + 1));
		for (var i = 0; i < table.length; i++)
		{
		  table[i] = f(from + i);
		}
		return {
			ctor: '_Array',
			height: 0,
			table: table
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = initialize_(f, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i-1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

function fromList(list)
{
	if (list.ctor === '[]')
	{
		return empty;
	}

	// Allocate M sized blocks (table) and write list elements to it.
	var table = new Array(M);
	var nodes = [];
	var i = 0;

	while (list.ctor !== '[]')
	{
		table[i] = list._0;
		list = list._1;
		i++;

		// table is full, so we can push a leaf containing it into the
		// next node.
		if (i === M)
		{
			var leaf = {
				ctor: '_Array',
				height: 0,
				table: table
			};
			fromListPush(leaf, nodes);
			table = new Array(M);
			i = 0;
		}
	}

	// Maybe there is something left on the table.
	if (i > 0)
	{
		var leaf = {
			ctor: '_Array',
			height: 0,
			table: table.splice(0, i)
		};
		fromListPush(leaf, nodes);
	}

	// Go through all of the nodes and eventually push them into higher nodes.
	for (var h = 0; h < nodes.length - 1; h++)
	{
		if (nodes[h].table.length > 0)
		{
			fromListPush(nodes[h], nodes);
		}
	}

	var head = nodes[nodes.length - 1];
	if (head.height > 0 && head.table.length === 1)
	{
		return head.table[0];
	}
	else
	{
		return head;
	}
}

// Push a node into a higher node as a child.
function fromListPush(toPush, nodes)
{
	var h = toPush.height;

	// Maybe the node on this height does not exist.
	if (nodes.length === h)
	{
		var node = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
		nodes.push(node);
	}

	nodes[h].table.push(toPush);
	var len = length(toPush);
	if (nodes[h].lengths.length > 0)
	{
		len += nodes[h].lengths[nodes[h].lengths.length - 1];
	}
	nodes[h].lengths.push(len);

	if (nodes[h].table.length === M)
	{
		fromListPush(nodes[h], nodes);
		nodes[h] = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
	}
}

// Pushes an item via push_ to the bottom right of a tree.
function push(item, a)
{
	var pushed = push_(item, a);
	if (pushed !== null)
	{
		return pushed;
	}

	var newTree = create(item, a.height);
	return siblise(a, newTree);
}

// Recursively tries to push an item to the bottom-right most
// tree possible. If there is no space left for the item,
// null will be returned.
function push_(item, a)
{
	// Handle resursion stop at leaf level.
	if (a.height === 0)
	{
		if (a.table.length < M)
		{
			var newA = {
				ctor: '_Array',
				height: 0,
				table: a.table.slice()
			};
			newA.table.push(item);
			return newA;
		}
		else
		{
		  return null;
		}
	}

	// Recursively push
	var pushed = push_(item, botRight(a));

	// There was space in the bottom right tree, so the slot will
	// be updated.
	if (pushed !== null)
	{
		var newA = nodeCopy(a);
		newA.table[newA.table.length - 1] = pushed;
		newA.lengths[newA.lengths.length - 1]++;
		return newA;
	}

	// When there was no space left, check if there is space left
	// for a new slot with a tree which contains only the item
	// at the bottom.
	if (a.table.length < M)
	{
		var newSlot = create(item, a.height - 1);
		var newA = nodeCopy(a);
		newA.table.push(newSlot);
		newA.lengths.push(newA.lengths[newA.lengths.length - 1] + length(newSlot));
		return newA;
	}
	else
	{
		return null;
	}
}

// Converts an array into a list of elements.
function toList(a)
{
	return toList_(_elm_lang$core$Native_List.Nil, a);
}

function toList_(list, a)
{
	for (var i = a.table.length - 1; i >= 0; i--)
	{
		list =
			a.height === 0
				? _elm_lang$core$Native_List.Cons(a.table[i], list)
				: toList_(list, a.table[i]);
	}
	return list;
}

// Maps a function over the elements of an array.
function map(f, a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? f(a.table[i])
				: map(f, a.table[i]);
	}
	return newA;
}

// Maps a function over the elements with their index as first argument.
function indexedMap(f, a)
{
	return indexedMap_(f, a, 0);
}

function indexedMap_(f, a, from)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? A2(f, from + i, a.table[i])
				: indexedMap_(f, a.table[i], i == 0 ? from : from + a.lengths[i - 1]);
	}
	return newA;
}

function foldl(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = foldl(f, b, a.table[i]);
		}
	}
	return b;
}

function foldr(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = a.table.length; i--; )
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = a.table.length; i--; )
		{
			b = foldr(f, b, a.table[i]);
		}
	}
	return b;
}

// TODO: currently, it slices the right, then the left. This can be
// optimized.
function slice(from, to, a)
{
	if (from < 0)
	{
		from += length(a);
	}
	if (to < 0)
	{
		to += length(a);
	}
	return sliceLeft(from, sliceRight(to, a));
}

function sliceRight(to, a)
{
	if (to === length(a))
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(0, to);
		return newA;
	}

	// Slice the right recursively.
	var right = getSlot(to, a);
	var sliced = sliceRight(to - (right > 0 ? a.lengths[right - 1] : 0), a.table[right]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (right === 0)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(0, right),
		lengths: a.lengths.slice(0, right)
	};
	if (sliced.table.length > 0)
	{
		newA.table[right] = sliced;
		newA.lengths[right] = length(sliced) + (right > 0 ? newA.lengths[right - 1] : 0);
	}
	return newA;
}

function sliceLeft(from, a)
{
	if (from === 0)
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(from, a.table.length + 1);
		return newA;
	}

	// Slice the left recursively.
	var left = getSlot(from, a);
	var sliced = sliceLeft(from - (left > 0 ? a.lengths[left - 1] : 0), a.table[left]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (left === a.table.length - 1)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(left, a.table.length + 1),
		lengths: new Array(a.table.length - left)
	};
	newA.table[0] = sliced;
	var len = 0;
	for (var i = 0; i < newA.table.length; i++)
	{
		len += length(newA.table[i]);
		newA.lengths[i] = len;
	}

	return newA;
}

// Appends two trees.
function append(a,b)
{
	if (a.table.length === 0)
	{
		return b;
	}
	if (b.table.length === 0)
	{
		return a;
	}

	var c = append_(a, b);

	// Check if both nodes can be crunshed together.
	if (c[0].table.length + c[1].table.length <= M)
	{
		if (c[0].table.length === 0)
		{
			return c[1];
		}
		if (c[1].table.length === 0)
		{
			return c[0];
		}

		// Adjust .table and .lengths
		c[0].table = c[0].table.concat(c[1].table);
		if (c[0].height > 0)
		{
			var len = length(c[0]);
			for (var i = 0; i < c[1].lengths.length; i++)
			{
				c[1].lengths[i] += len;
			}
			c[0].lengths = c[0].lengths.concat(c[1].lengths);
		}

		return c[0];
	}

	if (c[0].height > 0)
	{
		var toRemove = calcToRemove(a, b);
		if (toRemove > E)
		{
			c = shuffle(c[0], c[1], toRemove);
		}
	}

	return siblise(c[0], c[1]);
}

// Returns an array of two nodes; right and left. One node _may_ be empty.
function append_(a, b)
{
	if (a.height === 0 && b.height === 0)
	{
		return [a, b];
	}

	if (a.height !== 1 || b.height !== 1)
	{
		if (a.height === b.height)
		{
			a = nodeCopy(a);
			b = nodeCopy(b);
			var appended = append_(botRight(a), botLeft(b));

			insertRight(a, appended[1]);
			insertLeft(b, appended[0]);
		}
		else if (a.height > b.height)
		{
			a = nodeCopy(a);
			var appended = append_(botRight(a), b);

			insertRight(a, appended[0]);
			b = parentise(appended[1], appended[1].height + 1);
		}
		else
		{
			b = nodeCopy(b);
			var appended = append_(a, botLeft(b));

			var left = appended[0].table.length === 0 ? 0 : 1;
			var right = left === 0 ? 1 : 0;
			insertLeft(b, appended[left]);
			a = parentise(appended[right], appended[right].height + 1);
		}
	}

	// Check if balancing is needed and return based on that.
	if (a.table.length === 0 || b.table.length === 0)
	{
		return [a, b];
	}

	var toRemove = calcToRemove(a, b);
	if (toRemove <= E)
	{
		return [a, b];
	}
	return shuffle(a, b, toRemove);
}

// Helperfunctions for append_. Replaces a child node at the side of the parent.
function insertRight(parent, node)
{
	var index = parent.table.length - 1;
	parent.table[index] = node;
	parent.lengths[index] = length(node);
	parent.lengths[index] += index > 0 ? parent.lengths[index - 1] : 0;
}

function insertLeft(parent, node)
{
	if (node.table.length > 0)
	{
		parent.table[0] = node;
		parent.lengths[0] = length(node);

		var len = length(parent.table[0]);
		for (var i = 1; i < parent.lengths.length; i++)
		{
			len += length(parent.table[i]);
			parent.lengths[i] = len;
		}
	}
	else
	{
		parent.table.shift();
		for (var i = 1; i < parent.lengths.length; i++)
		{
			parent.lengths[i] = parent.lengths[i] - parent.lengths[0];
		}
		parent.lengths.shift();
	}
}

// Returns the extra search steps for E. Refer to the paper.
function calcToRemove(a, b)
{
	var subLengths = 0;
	for (var i = 0; i < a.table.length; i++)
	{
		subLengths += a.table[i].table.length;
	}
	for (var i = 0; i < b.table.length; i++)
	{
		subLengths += b.table[i].table.length;
	}

	var toRemove = a.table.length + b.table.length;
	return toRemove - (Math.floor((subLengths - 1) / M) + 1);
}

// get2, set2 and saveSlot are helpers for accessing elements over two arrays.
function get2(a, b, index)
{
	return index < a.length
		? a[index]
		: b[index - a.length];
}

function set2(a, b, index, value)
{
	if (index < a.length)
	{
		a[index] = value;
	}
	else
	{
		b[index - a.length] = value;
	}
}

function saveSlot(a, b, index, slot)
{
	set2(a.table, b.table, index, slot);

	var l = (index === 0 || index === a.lengths.length)
		? 0
		: get2(a.lengths, a.lengths, index - 1);

	set2(a.lengths, b.lengths, index, l + length(slot));
}

// Creates a node or leaf with a given length at their arrays for perfomance.
// Is only used by shuffle.
function createNode(h, length)
{
	if (length < 0)
	{
		length = 0;
	}
	var a = {
		ctor: '_Array',
		height: h,
		table: new Array(length)
	};
	if (h > 0)
	{
		a.lengths = new Array(length);
	}
	return a;
}

// Returns an array of two balanced nodes.
function shuffle(a, b, toRemove)
{
	var newA = createNode(a.height, Math.min(M, a.table.length + b.table.length - toRemove));
	var newB = createNode(a.height, newA.table.length - (a.table.length + b.table.length - toRemove));

	// Skip the slots with size M. More precise: copy the slot references
	// to the new node
	var read = 0;
	while (get2(a.table, b.table, read).table.length % M === 0)
	{
		set2(newA.table, newB.table, read, get2(a.table, b.table, read));
		set2(newA.lengths, newB.lengths, read, get2(a.lengths, b.lengths, read));
		read++;
	}

	// Pulling items from left to right, caching in a slot before writing
	// it into the new nodes.
	var write = read;
	var slot = new createNode(a.height - 1, 0);
	var from = 0;

	// If the current slot is still containing data, then there will be at
	// least one more write, so we do not break this loop yet.
	while (read - write - (slot.table.length > 0 ? 1 : 0) < toRemove)
	{
		// Find out the max possible items for copying.
		var source = get2(a.table, b.table, read);
		var to = Math.min(M - slot.table.length, source.table.length);

		// Copy and adjust size table.
		slot.table = slot.table.concat(source.table.slice(from, to));
		if (slot.height > 0)
		{
			var len = slot.lengths.length;
			for (var i = len; i < len + to - from; i++)
			{
				slot.lengths[i] = length(slot.table[i]);
				slot.lengths[i] += (i > 0 ? slot.lengths[i - 1] : 0);
			}
		}

		from += to;

		// Only proceed to next slots[i] if the current one was
		// fully copied.
		if (source.table.length <= to)
		{
			read++; from = 0;
		}

		// Only create a new slot if the current one is filled up.
		if (slot.table.length === M)
		{
			saveSlot(newA, newB, write, slot);
			slot = createNode(a.height - 1, 0);
			write++;
		}
	}

	// Cleanup after the loop. Copy the last slot into the new nodes.
	if (slot.table.length > 0)
	{
		saveSlot(newA, newB, write, slot);
		write++;
	}

	// Shift the untouched slots to the left
	while (read < a.table.length + b.table.length )
	{
		saveSlot(newA, newB, write, get2(a.table, b.table, read));
		read++;
		write++;
	}

	return [newA, newB];
}

// Navigation functions
function botRight(a)
{
	return a.table[a.table.length - 1];
}
function botLeft(a)
{
	return a.table[0];
}

// Copies a node for updating. Note that you should not use this if
// only updating only one of "table" or "lengths" for performance reasons.
function nodeCopy(a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice()
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths.slice();
	}
	return newA;
}

// Returns how many items are in the tree.
function length(array)
{
	if (array.height === 0)
	{
		return array.table.length;
	}
	else
	{
		return array.lengths[array.lengths.length - 1];
	}
}

// Calculates in which slot of "table" the item probably is, then
// find the exact slot via forward searching in  "lengths". Returns the index.
function getSlot(i, a)
{
	var slot = i >> (5 * a.height);
	while (a.lengths[slot] <= i)
	{
		slot++;
	}
	return slot;
}

// Recursively creates a tree with a given height containing
// only the given item.
function create(item, h)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: [item]
		};
	}
	return {
		ctor: '_Array',
		height: h,
		table: [create(item, h - 1)],
		lengths: [1]
	};
}

// Recursively creates a tree that contains the given tree.
function parentise(tree, h)
{
	if (h === tree.height)
	{
		return tree;
	}

	return {
		ctor: '_Array',
		height: h,
		table: [parentise(tree, h - 1)],
		lengths: [length(tree)]
	};
}

// Emphasizes blood brotherhood beneath two trees.
function siblise(a, b)
{
	return {
		ctor: '_Array',
		height: a.height + 1,
		table: [a, b],
		lengths: [length(a), length(a) + length(b)]
	};
}

function toJSArray(a)
{
	var jsArray = new Array(length(a));
	toJSArray_(jsArray, 0, a);
	return jsArray;
}

function toJSArray_(jsArray, i, a)
{
	for (var t = 0; t < a.table.length; t++)
	{
		if (a.height === 0)
		{
			jsArray[i + t] = a.table[t];
		}
		else
		{
			var inc = t === 0 ? 0 : a.lengths[t - 1];
			toJSArray_(jsArray, i + inc, a.table[t]);
		}
	}
}

function fromJSArray(jsArray)
{
	if (jsArray.length === 0)
	{
		return empty;
	}
	var h = Math.floor(Math.log(jsArray.length) / Math.log(M));
	return fromJSArray_(jsArray, h, 0, jsArray.length);
}

function fromJSArray_(jsArray, h, from, to)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: jsArray.slice(from, to)
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = fromJSArray_(jsArray, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i - 1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

return {
	empty: empty,
	fromList: fromList,
	toList: toList,
	initialize: F2(initialize),
	append: F2(append),
	push: F2(push),
	slice: F3(slice),
	get: F2(get),
	set: F3(set),
	map: F2(map),
	indexedMap: F2(indexedMap),
	foldl: F3(foldl),
	foldr: F3(foldr),
	length: length,

	toJSArray: toJSArray,
	fromJSArray: fromJSArray
};

}();
//import Native.Utils //

var _elm_lang$core$Native_Basics = function() {

function div(a, b)
{
	return (a / b) | 0;
}
function rem(a, b)
{
	return a % b;
}
function mod(a, b)
{
	if (b === 0)
	{
		throw new Error('Cannot perform mod 0. Division by zero error.');
	}
	var r = a % b;
	var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r + b) : -mod(-a, -b));

	return m === b ? 0 : m;
}
function logBase(base, n)
{
	return Math.log(n) / Math.log(base);
}
function negate(n)
{
	return -n;
}
function abs(n)
{
	return n < 0 ? -n : n;
}

function min(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) < 0 ? a : b;
}
function max(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) > 0 ? a : b;
}
function clamp(lo, hi, n)
{
	return _elm_lang$core$Native_Utils.cmp(n, lo) < 0
		? lo
		: _elm_lang$core$Native_Utils.cmp(n, hi) > 0
			? hi
			: n;
}

var ord = ['LT', 'EQ', 'GT'];

function compare(x, y)
{
	return { ctor: ord[_elm_lang$core$Native_Utils.cmp(x, y) + 1] };
}

function xor(a, b)
{
	return a !== b;
}
function not(b)
{
	return !b;
}
function isInfinite(n)
{
	return n === Infinity || n === -Infinity;
}

function truncate(n)
{
	return n | 0;
}

function degrees(d)
{
	return d * Math.PI / 180;
}
function turns(t)
{
	return 2 * Math.PI * t;
}
function fromPolar(point)
{
	var r = point._0;
	var t = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(r * Math.cos(t), r * Math.sin(t));
}
function toPolar(point)
{
	var x = point._0;
	var y = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(Math.sqrt(x * x + y * y), Math.atan2(y, x));
}

return {
	div: F2(div),
	rem: F2(rem),
	mod: F2(mod),

	pi: Math.PI,
	e: Math.E,
	cos: Math.cos,
	sin: Math.sin,
	tan: Math.tan,
	acos: Math.acos,
	asin: Math.asin,
	atan: Math.atan,
	atan2: F2(Math.atan2),

	degrees: degrees,
	turns: turns,
	fromPolar: fromPolar,
	toPolar: toPolar,

	sqrt: Math.sqrt,
	logBase: F2(logBase),
	negate: negate,
	abs: abs,
	min: F2(min),
	max: F2(max),
	clamp: F3(clamp),
	compare: F2(compare),

	xor: F2(xor),
	not: not,

	truncate: truncate,
	ceiling: Math.ceil,
	floor: Math.floor,
	round: Math.round,
	toFloat: function(x) { return x; },
	isNaN: isNaN,
	isInfinite: isInfinite
};

}();
//import //

var _elm_lang$core$Native_Utils = function() {

// COMPARISONS

function eq(x, y)
{
	var stack = [];
	var isEqual = eqHelp(x, y, 0, stack);
	var pair;
	while (isEqual && (pair = stack.pop()))
	{
		isEqual = eqHelp(pair.x, pair.y, 0, stack);
	}
	return isEqual;
}


function eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push({ x: x, y: y });
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object')
	{
		if (typeof x === 'function')
		{
			throw new Error(
				'Trying to use `(==)` on functions. There is no way to know if functions are "the same" in the Elm sense.'
				+ ' Read more about this at http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#=='
				+ ' which describes why it is this way and what the better version will look like.'
			);
		}
		return false;
	}

	if (x === null || y === null)
	{
		return false
	}

	if (x instanceof Date)
	{
		return x.getTime() === y.getTime();
	}

	if (!('ctor' in x))
	{
		for (var key in x)
		{
			if (!eqHelp(x[key], y[key], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	// convert Dicts and Sets to lists
	if (x.ctor === 'RBNode_elm_builtin' || x.ctor === 'RBEmpty_elm_builtin')
	{
		x = _elm_lang$core$Dict$toList(x);
		y = _elm_lang$core$Dict$toList(y);
	}
	if (x.ctor === 'Set_elm_builtin')
	{
		x = _elm_lang$core$Set$toList(x);
		y = _elm_lang$core$Set$toList(y);
	}

	// check if lists are equal without recursion
	if (x.ctor === '::')
	{
		var a = x;
		var b = y;
		while (a.ctor === '::' && b.ctor === '::')
		{
			if (!eqHelp(a._0, b._0, depth + 1, stack))
			{
				return false;
			}
			a = a._1;
			b = b._1;
		}
		return a.ctor === b.ctor;
	}

	// check if Arrays are equal
	if (x.ctor === '_Array')
	{
		var xs = _elm_lang$core$Native_Array.toJSArray(x);
		var ys = _elm_lang$core$Native_Array.toJSArray(y);
		if (xs.length !== ys.length)
		{
			return false;
		}
		for (var i = 0; i < xs.length; i++)
		{
			if (!eqHelp(xs[i], ys[i], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	if (!eqHelp(x.ctor, y.ctor, depth + 1, stack))
	{
		return false;
	}

	for (var key in x)
	{
		if (!eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

var LT = -1, EQ = 0, GT = 1;

function cmp(x, y)
{
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? EQ : a < b ? LT : GT;
	}

	if (x.ctor === '::' || x.ctor === '[]')
	{
		while (x.ctor === '::' && y.ctor === '::')
		{
			var ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
		return x.ctor === y.ctor ? EQ : x.ctor === '[]' ? LT : GT;
	}

	if (x.ctor.slice(0, 6) === '_Tuple')
	{
		var ord;
		var n = x.ctor.slice(6) - 0;
		var err = 'cannot compare tuples with more than 6 elements.';
		if (n === 0) return EQ;
		if (n >= 1) { ord = cmp(x._0, y._0); if (ord !== EQ) return ord;
		if (n >= 2) { ord = cmp(x._1, y._1); if (ord !== EQ) return ord;
		if (n >= 3) { ord = cmp(x._2, y._2); if (ord !== EQ) return ord;
		if (n >= 4) { ord = cmp(x._3, y._3); if (ord !== EQ) return ord;
		if (n >= 5) { ord = cmp(x._4, y._4); if (ord !== EQ) return ord;
		if (n >= 6) { ord = cmp(x._5, y._5); if (ord !== EQ) return ord;
		if (n >= 7) throw new Error('Comparison error: ' + err); } } } } } }
		return EQ;
	}

	throw new Error(
		'Comparison error: comparison is only defined on ints, '
		+ 'floats, times, chars, strings, lists of comparable values, '
		+ 'and tuples of comparable values.'
	);
}


// COMMON VALUES

var Tuple0 = {
	ctor: '_Tuple0'
};

function Tuple2(x, y)
{
	return {
		ctor: '_Tuple2',
		_0: x,
		_1: y
	};
}

function chr(c)
{
	return new String(c);
}


// GUID

var count = 0;
function guid(_)
{
	return count++;
}


// RECORDS

function update(oldRecord, updatedFields)
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


//// LIST STUFF ////

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return {
		ctor: '::',
		_0: hd,
		_1: tl
	};
}

function append(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (xs.ctor === '[]')
	{
		return ys;
	}
	var root = Cons(xs._0, Nil);
	var curr = root;
	xs = xs._1;
	while (xs.ctor !== '[]')
	{
		curr._1 = Cons(xs._0, Nil);
		xs = xs._1;
		curr = curr._1;
	}
	curr._1 = ys;
	return root;
}


// CRASHES

function crash(moduleName, region)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '` ' + regionToString(region) + '\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function crashCase(moduleName, region, value)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '`\n\n'
			+ 'This was caused by the `case` expression ' + regionToString(region) + '.\n'
			+ 'One of the branches ended with a crash and the following value got through:\n\n    ' + toString(value) + '\n\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function regionToString(region)
{
	if (region.start.line == region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'between lines ' + region.start.line + ' and ' + region.end.line;
}


// TO STRING

function toString(v)
{
	var type = typeof v;
	if (type === 'function')
	{
		var name = v.func ? v.func.name : v.name;
		return '<function' + (name === '' ? '' : ':') + name + '>';
	}

	if (type === 'boolean')
	{
		return v ? 'True' : 'False';
	}

	if (type === 'number')
	{
		return v + '';
	}

	if (v instanceof String)
	{
		return '\'' + addSlashes(v, true) + '\'';
	}

	if (type === 'string')
	{
		return '"' + addSlashes(v, false) + '"';
	}

	if (v === null)
	{
		return 'null';
	}

	if (type === 'object' && 'ctor' in v)
	{
		var ctorStarter = v.ctor.substring(0, 5);

		if (ctorStarter === '_Tupl')
		{
			var output = [];
			for (var k in v)
			{
				if (k === 'ctor') continue;
				output.push(toString(v[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (ctorStarter === '_Task')
		{
			return '<task>'
		}

		if (v.ctor === '_Array')
		{
			var list = _elm_lang$core$Array$toList(v);
			return 'Array.fromList ' + toString(list);
		}

		if (v.ctor === '<decoder>')
		{
			return '<decoder>';
		}

		if (v.ctor === '_Process')
		{
			return '<process:' + v.id + '>';
		}

		if (v.ctor === '::')
		{
			var output = '[' + toString(v._0);
			v = v._1;
			while (v.ctor === '::')
			{
				output += ',' + toString(v._0);
				v = v._1;
			}
			return output + ']';
		}

		if (v.ctor === '[]')
		{
			return '[]';
		}

		if (v.ctor === 'Set_elm_builtin')
		{
			return 'Set.fromList ' + toString(_elm_lang$core$Set$toList(v));
		}

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin')
		{
			return 'Dict.fromList ' + toString(_elm_lang$core$Dict$toList(v));
		}

		var output = '';
		for (var i in v)
		{
			if (i === 'ctor') continue;
			var str = toString(v[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return v.ctor + output;
	}

	if (type === 'object')
	{
		if (v instanceof Date)
		{
			return '<' + v.toString() + '>';
		}

		if (v.elm_web_socket)
		{
			return '<websocket>';
		}

		var output = [];
		for (var k in v)
		{
			output.push(k + ' = ' + toString(v[k]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return '<internal structure>';
}

function addSlashes(str, isChar)
{
	var s = str.replace(/\\/g, '\\\\')
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


return {
	eq: eq,
	cmp: cmp,
	Tuple0: Tuple0,
	Tuple2: Tuple2,
	chr: chr,
	update: update,
	guid: guid,

	append: F2(append),

	crash: crash,
	crashCase: crashCase,

	toString: toString
};

}();
var _elm_lang$core$Basics$never = function (_p0) {
	never:
	while (true) {
		var _p1 = _p0;
		var _v1 = _p1._0;
		_p0 = _v1;
		continue never;
	}
};
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p2) {
		var _p3 = _p2;
		return A2(f, _p3._0, _p3._1);
	});
var _elm_lang$core$Basics$curry = F3(
	function (f, a, b) {
		return f(
			{ctor: '_Tuple2', _0: a, _1: b});
	});
var _elm_lang$core$Basics$flip = F3(
	function (f, b, a) {
		return A2(f, a, b);
	});
var _elm_lang$core$Basics$always = F2(
	function (a, _p4) {
		return a;
	});
var _elm_lang$core$Basics$identity = function (x) {
	return x;
};
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<|'] = F2(
	function (f, x) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['|>'] = F2(
	function (x, f) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>>'] = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<<'] = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['++'] = _elm_lang$core$Native_Utils.append;
var _elm_lang$core$Basics$toString = _elm_lang$core$Native_Utils.toString;
var _elm_lang$core$Basics$isInfinite = _elm_lang$core$Native_Basics.isInfinite;
var _elm_lang$core$Basics$isNaN = _elm_lang$core$Native_Basics.isNaN;
var _elm_lang$core$Basics$toFloat = _elm_lang$core$Native_Basics.toFloat;
var _elm_lang$core$Basics$ceiling = _elm_lang$core$Native_Basics.ceiling;
var _elm_lang$core$Basics$floor = _elm_lang$core$Native_Basics.floor;
var _elm_lang$core$Basics$truncate = _elm_lang$core$Native_Basics.truncate;
var _elm_lang$core$Basics$round = _elm_lang$core$Native_Basics.round;
var _elm_lang$core$Basics$not = _elm_lang$core$Native_Basics.not;
var _elm_lang$core$Basics$xor = _elm_lang$core$Native_Basics.xor;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['||'] = _elm_lang$core$Native_Basics.or;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['&&'] = _elm_lang$core$Native_Basics.and;
var _elm_lang$core$Basics$max = _elm_lang$core$Native_Basics.max;
var _elm_lang$core$Basics$min = _elm_lang$core$Native_Basics.min;
var _elm_lang$core$Basics$compare = _elm_lang$core$Native_Basics.compare;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>='] = _elm_lang$core$Native_Basics.ge;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<='] = _elm_lang$core$Native_Basics.le;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>'] = _elm_lang$core$Native_Basics.gt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<'] = _elm_lang$core$Native_Basics.lt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/='] = _elm_lang$core$Native_Basics.neq;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['=='] = _elm_lang$core$Native_Basics.eq;
var _elm_lang$core$Basics$e = _elm_lang$core$Native_Basics.e;
var _elm_lang$core$Basics$pi = _elm_lang$core$Native_Basics.pi;
var _elm_lang$core$Basics$clamp = _elm_lang$core$Native_Basics.clamp;
var _elm_lang$core$Basics$logBase = _elm_lang$core$Native_Basics.logBase;
var _elm_lang$core$Basics$abs = _elm_lang$core$Native_Basics.abs;
var _elm_lang$core$Basics$negate = _elm_lang$core$Native_Basics.negate;
var _elm_lang$core$Basics$sqrt = _elm_lang$core$Native_Basics.sqrt;
var _elm_lang$core$Basics$atan2 = _elm_lang$core$Native_Basics.atan2;
var _elm_lang$core$Basics$atan = _elm_lang$core$Native_Basics.atan;
var _elm_lang$core$Basics$asin = _elm_lang$core$Native_Basics.asin;
var _elm_lang$core$Basics$acos = _elm_lang$core$Native_Basics.acos;
var _elm_lang$core$Basics$tan = _elm_lang$core$Native_Basics.tan;
var _elm_lang$core$Basics$sin = _elm_lang$core$Native_Basics.sin;
var _elm_lang$core$Basics$cos = _elm_lang$core$Native_Basics.cos;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['^'] = _elm_lang$core$Native_Basics.exp;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['%'] = _elm_lang$core$Native_Basics.mod;
var _elm_lang$core$Basics$rem = _elm_lang$core$Native_Basics.rem;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['//'] = _elm_lang$core$Native_Basics.div;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/'] = _elm_lang$core$Native_Basics.floatDiv;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['*'] = _elm_lang$core$Native_Basics.mul;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['-'] = _elm_lang$core$Native_Basics.sub;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['+'] = _elm_lang$core$Native_Basics.add;
var _elm_lang$core$Basics$toPolar = _elm_lang$core$Native_Basics.toPolar;
var _elm_lang$core$Basics$fromPolar = _elm_lang$core$Native_Basics.fromPolar;
var _elm_lang$core$Basics$turns = _elm_lang$core$Native_Basics.turns;
var _elm_lang$core$Basics$degrees = _elm_lang$core$Native_Basics.degrees;
var _elm_lang$core$Basics$radians = function (t) {
	return t;
};
var _elm_lang$core$Basics$GT = {ctor: 'GT'};
var _elm_lang$core$Basics$EQ = {ctor: 'EQ'};
var _elm_lang$core$Basics$LT = {ctor: 'LT'};
var _elm_lang$core$Basics$JustOneMore = function (a) {
	return {ctor: 'JustOneMore', _0: a};
};

var _elm_lang$core$Maybe$withDefault = F2(
	function ($default, maybe) {
		var _p0 = maybe;
		if (_p0.ctor === 'Just') {
			return _p0._0;
		} else {
			return $default;
		}
	});
var _elm_lang$core$Maybe$Nothing = {ctor: 'Nothing'};
var _elm_lang$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		var _p1 = maybeValue;
		if (_p1.ctor === 'Just') {
			return callback(_p1._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p2 = maybe;
		if (_p2.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p3 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p3.ctor === '_Tuple2') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p3._0._0, _p3._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p4 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p4.ctor === '_Tuple3') && (_p4._0.ctor === 'Just')) && (_p4._1.ctor === 'Just')) && (_p4._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p4._0._0, _p4._1._0, _p4._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p5 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p5.ctor === '_Tuple4') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === 'Just')) && (_p5._2.ctor === 'Just')) && (_p5._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p5._0._0, _p5._1._0, _p5._2._0, _p5._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p6 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p6.ctor === '_Tuple5') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) && (_p6._2.ctor === 'Just')) && (_p6._3.ctor === 'Just')) && (_p6._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0, _p6._4._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});

//import Native.Utils //

var _elm_lang$core$Native_List = function() {

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return { ctor: '::', _0: hd, _1: tl };
}

function fromArray(arr)
{
	var out = Nil;
	for (var i = arr.length; i--; )
	{
		out = Cons(arr[i], out);
	}
	return out;
}

function toArray(xs)
{
	var out = [];
	while (xs.ctor !== '[]')
	{
		out.push(xs._0);
		xs = xs._1;
	}
	return out;
}

function foldr(f, b, xs)
{
	var arr = toArray(xs);
	var acc = b;
	for (var i = arr.length; i--; )
	{
		acc = A2(f, arr[i], acc);
	}
	return acc;
}

function map2(f, xs, ys)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]')
	{
		arr.push(A2(f, xs._0, ys._0));
		xs = xs._1;
		ys = ys._1;
	}
	return fromArray(arr);
}

function map3(f, xs, ys, zs)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]' && zs.ctor !== '[]')
	{
		arr.push(A3(f, xs._0, ys._0, zs._0));
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map4(f, ws, xs, ys, zs)
{
	var arr = [];
	while (   ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A4(f, ws._0, xs._0, ys._0, zs._0));
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map5(f, vs, ws, xs, ys, zs)
{
	var arr = [];
	while (   vs.ctor !== '[]'
		   && ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A5(f, vs._0, ws._0, xs._0, ys._0, zs._0));
		vs = vs._1;
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function sortBy(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		return _elm_lang$core$Native_Utils.cmp(f(a), f(b));
	}));
}

function sortWith(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		var ord = f(a)(b).ctor;
		return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
	}));
}

return {
	Nil: Nil,
	Cons: Cons,
	cons: F2(Cons),
	toArray: toArray,
	fromArray: fromArray,

	foldr: F3(foldr),

	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	sortBy: F2(sortBy),
	sortWith: F2(sortWith)
};

}();
var _elm_lang$core$List$sortWith = _elm_lang$core$Native_List.sortWith;
var _elm_lang$core$List$sortBy = _elm_lang$core$Native_List.sortBy;
var _elm_lang$core$List$sort = function (xs) {
	return A2(_elm_lang$core$List$sortBy, _elm_lang$core$Basics$identity, xs);
};
var _elm_lang$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return list;
			} else {
				var _p0 = list;
				if (_p0.ctor === '[]') {
					return list;
				} else {
					var _v1 = n - 1,
						_v2 = _p0._1;
					n = _v1;
					list = _v2;
					continue drop;
				}
			}
		}
	});
var _elm_lang$core$List$map5 = _elm_lang$core$Native_List.map5;
var _elm_lang$core$List$map4 = _elm_lang$core$Native_List.map4;
var _elm_lang$core$List$map3 = _elm_lang$core$Native_List.map3;
var _elm_lang$core$List$map2 = _elm_lang$core$Native_List.map2;
var _elm_lang$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			var _p1 = list;
			if (_p1.ctor === '[]') {
				return false;
			} else {
				if (isOkay(_p1._0)) {
					return true;
				} else {
					var _v4 = isOkay,
						_v5 = _p1._1;
					isOkay = _v4;
					list = _v5;
					continue any;
				}
			}
		}
	});
var _elm_lang$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			_elm_lang$core$List$any,
			function (_p2) {
				return !isOkay(_p2);
			},
			list);
	});
var _elm_lang$core$List$foldr = _elm_lang$core$Native_List.foldr;
var _elm_lang$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			var _p3 = list;
			if (_p3.ctor === '[]') {
				return acc;
			} else {
				var _v7 = func,
					_v8 = A2(func, _p3._0, acc),
					_v9 = _p3._1;
				func = _v7;
				acc = _v8;
				list = _v9;
				continue foldl;
			}
		}
	});
var _elm_lang$core$List$length = function (xs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p4, i) {
				return i + 1;
			}),
		0,
		xs);
};
var _elm_lang$core$List$sum = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x + y;
			}),
		0,
		numbers);
};
var _elm_lang$core$List$product = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x * y;
			}),
		1,
		numbers);
};
var _elm_lang$core$List$maximum = function (list) {
	var _p5 = list;
	if (_p5.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$max, _p5._0, _p5._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$minimum = function (list) {
	var _p6 = list;
	if (_p6.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$min, _p6._0, _p6._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$member = F2(
	function (x, xs) {
		return A2(
			_elm_lang$core$List$any,
			function (a) {
				return _elm_lang$core$Native_Utils.eq(a, x);
			},
			xs);
	});
var _elm_lang$core$List$isEmpty = function (xs) {
	var _p7 = xs;
	if (_p7.ctor === '[]') {
		return true;
	} else {
		return false;
	}
};
var _elm_lang$core$List$tail = function (list) {
	var _p8 = list;
	if (_p8.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p8._1);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$head = function (list) {
	var _p9 = list;
	if (_p9.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p9._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List_ops = _elm_lang$core$List_ops || {};
_elm_lang$core$List_ops['::'] = _elm_lang$core$Native_List.cons;
var _elm_lang$core$List$map = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, acc) {
					return {
						ctor: '::',
						_0: f(x),
						_1: acc
					};
				}),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (front, back) {
				return pred(front) ? {ctor: '::', _0: front, _1: back} : back;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return {ctor: '::', _0: _p10._0, _1: xs};
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return {ctor: '::', _0: x, _1: y};
			}),
		{ctor: '[]'},
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return {
						ctor: '::',
						_0: A2(f, x, _p11._0),
						_1: accAcc
					};
				} else {
					return {ctor: '[]'};
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				{
					ctor: '::',
					_0: b,
					_1: {ctor: '[]'}
				},
				xs));
	});
var _elm_lang$core$List$append = F2(
	function (xs, ys) {
		var _p12 = ys;
		if (_p12.ctor === '[]') {
			return xs;
		} else {
			return A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		{ctor: '[]'},
		lists);
};
var _elm_lang$core$List$concatMap = F2(
	function (f, list) {
		return _elm_lang$core$List$concat(
			A2(_elm_lang$core$List$map, f, list));
	});
var _elm_lang$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _p13) {
				var _p14 = _p13;
				var _p16 = _p14._0;
				var _p15 = _p14._1;
				return pred(x) ? {
					ctor: '_Tuple2',
					_0: {ctor: '::', _0: x, _1: _p16},
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: {ctor: '::', _0: x, _1: _p15}
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			},
			list);
	});
var _elm_lang$core$List$unzip = function (pairs) {
	var step = F2(
		function (_p18, _p17) {
			var _p19 = _p18;
			var _p20 = _p17;
			return {
				ctor: '_Tuple2',
				_0: {ctor: '::', _0: _p19._0, _1: _p20._0},
				_1: {ctor: '::', _0: _p19._1, _1: _p20._1}
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var step = F2(
				function (x, rest) {
					return {
						ctor: '::',
						_0: sep,
						_1: {ctor: '::', _0: x, _1: rest}
					};
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				{ctor: '[]'},
				_p21._1);
			return {ctor: '::', _0: _p21._0, _1: spersed};
		}
	});
var _elm_lang$core$List$takeReverse = F3(
	function (n, list, taken) {
		takeReverse:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return taken;
			} else {
				var _p22 = list;
				if (_p22.ctor === '[]') {
					return taken;
				} else {
					var _v23 = n - 1,
						_v24 = _p22._1,
						_v25 = {ctor: '::', _0: _p22._0, _1: taken};
					n = _v23;
					list = _v24;
					taken = _v25;
					continue takeReverse;
				}
			}
		}
	});
var _elm_lang$core$List$takeTailRec = F2(
	function (n, list) {
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$takeReverse,
				n,
				list,
				{ctor: '[]'}));
	});
var _elm_lang$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return {ctor: '[]'};
		} else {
			var _p23 = {ctor: '_Tuple2', _0: n, _1: list};
			_v26_5:
			do {
				_v26_1:
				do {
					if (_p23.ctor === '_Tuple2') {
						if (_p23._1.ctor === '[]') {
							return list;
						} else {
							if (_p23._1._1.ctor === '::') {
								switch (_p23._0) {
									case 1:
										break _v26_1;
									case 2:
										return {
											ctor: '::',
											_0: _p23._1._0,
											_1: {
												ctor: '::',
												_0: _p23._1._1._0,
												_1: {ctor: '[]'}
											}
										};
									case 3:
										if (_p23._1._1._1.ctor === '::') {
											return {
												ctor: '::',
												_0: _p23._1._0,
												_1: {
													ctor: '::',
													_0: _p23._1._1._0,
													_1: {
														ctor: '::',
														_0: _p23._1._1._1._0,
														_1: {ctor: '[]'}
													}
												}
											};
										} else {
											break _v26_5;
										}
									default:
										if ((_p23._1._1._1.ctor === '::') && (_p23._1._1._1._1.ctor === '::')) {
											var _p28 = _p23._1._1._1._0;
											var _p27 = _p23._1._1._0;
											var _p26 = _p23._1._0;
											var _p25 = _p23._1._1._1._1._0;
											var _p24 = _p23._1._1._1._1._1;
											return (_elm_lang$core$Native_Utils.cmp(ctr, 1000) > 0) ? {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A2(_elm_lang$core$List$takeTailRec, n - 4, _p24)
														}
													}
												}
											} : {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A3(_elm_lang$core$List$takeFast, ctr + 1, n - 4, _p24)
														}
													}
												}
											};
										} else {
											break _v26_5;
										}
								}
							} else {
								if (_p23._0 === 1) {
									break _v26_1;
								} else {
									break _v26_5;
								}
							}
						}
					} else {
						break _v26_5;
					}
				} while(false);
				return {
					ctor: '::',
					_0: _p23._1._0,
					_1: {ctor: '[]'}
				};
			} while(false);
			return list;
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		return A3(_elm_lang$core$List$takeFast, 0, n, list);
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v27 = {ctor: '::', _0: value, _1: result},
					_v28 = n - 1,
					_v29 = value;
				result = _v27;
				n = _v28;
				value = _v29;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			{ctor: '[]'},
			n,
			value);
	});
var _elm_lang$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(lo, hi) < 1) {
				var _v30 = lo,
					_v31 = hi - 1,
					_v32 = {ctor: '::', _0: hi, _1: list};
				lo = _v30;
				hi = _v31;
				list = _v32;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var _elm_lang$core$List$range = F2(
	function (lo, hi) {
		return A3(
			_elm_lang$core$List$rangeHelp,
			lo,
			hi,
			{ctor: '[]'});
	});
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			A2(
				_elm_lang$core$List$range,
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});

var _elm_lang$core$Array$append = _elm_lang$core$Native_Array.append;
var _elm_lang$core$Array$length = _elm_lang$core$Native_Array.length;
var _elm_lang$core$Array$isEmpty = function (array) {
	return _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Array$length(array),
		0);
};
var _elm_lang$core$Array$slice = _elm_lang$core$Native_Array.slice;
var _elm_lang$core$Array$set = _elm_lang$core$Native_Array.set;
var _elm_lang$core$Array$get = F2(
	function (i, array) {
		return ((_elm_lang$core$Native_Utils.cmp(0, i) < 1) && (_elm_lang$core$Native_Utils.cmp(
			i,
			_elm_lang$core$Native_Array.length(array)) < 0)) ? _elm_lang$core$Maybe$Just(
			A2(_elm_lang$core$Native_Array.get, i, array)) : _elm_lang$core$Maybe$Nothing;
	});
var _elm_lang$core$Array$push = _elm_lang$core$Native_Array.push;
var _elm_lang$core$Array$empty = _elm_lang$core$Native_Array.empty;
var _elm_lang$core$Array$filter = F2(
	function (isOkay, arr) {
		var update = F2(
			function (x, xs) {
				return isOkay(x) ? A2(_elm_lang$core$Native_Array.push, x, xs) : xs;
			});
		return A3(_elm_lang$core$Native_Array.foldl, update, _elm_lang$core$Native_Array.empty, arr);
	});
var _elm_lang$core$Array$foldr = _elm_lang$core$Native_Array.foldr;
var _elm_lang$core$Array$foldl = _elm_lang$core$Native_Array.foldl;
var _elm_lang$core$Array$indexedMap = _elm_lang$core$Native_Array.indexedMap;
var _elm_lang$core$Array$map = _elm_lang$core$Native_Array.map;
var _elm_lang$core$Array$toIndexedList = function (array) {
	return A3(
		_elm_lang$core$List$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(
			_elm_lang$core$List$range,
			0,
			_elm_lang$core$Native_Array.length(array) - 1),
		_elm_lang$core$Native_Array.toList(array));
};
var _elm_lang$core$Array$toList = _elm_lang$core$Native_Array.toList;
var _elm_lang$core$Array$fromList = _elm_lang$core$Native_Array.fromList;
var _elm_lang$core$Array$initialize = _elm_lang$core$Native_Array.initialize;
var _elm_lang$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			_elm_lang$core$Array$initialize,
			n,
			_elm_lang$core$Basics$always(e));
	});
var _elm_lang$core$Array$Array = {ctor: 'Array'};

var _elm_lang$core$Native_Bitwise = function() {

return {
	and: F2(function and(a, b) { return a & b; }),
	or: F2(function or(a, b) { return a | b; }),
	xor: F2(function xor(a, b) { return a ^ b; }),
	complement: function complement(a) { return ~a; },
	shiftLeftBy: F2(function(offset, a) { return a << offset; }),
	shiftRightBy: F2(function(offset, a) { return a >> offset; }),
	shiftRightZfBy: F2(function(offset, a) { return a >>> offset; })
};

}();

var _elm_lang$core$Bitwise$shiftRightZfBy = _elm_lang$core$Native_Bitwise.shiftRightZfBy;
var _elm_lang$core$Bitwise$shiftRightBy = _elm_lang$core$Native_Bitwise.shiftRightBy;
var _elm_lang$core$Bitwise$shiftLeftBy = _elm_lang$core$Native_Bitwise.shiftLeftBy;
var _elm_lang$core$Bitwise$complement = _elm_lang$core$Native_Bitwise.complement;
var _elm_lang$core$Bitwise$xor = _elm_lang$core$Native_Bitwise.xor;
var _elm_lang$core$Bitwise$or = _elm_lang$core$Native_Bitwise.or;
var _elm_lang$core$Bitwise$and = _elm_lang$core$Native_Bitwise.and;

//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

return {
	fromCode: function(c) { return _elm_lang$core$Native_Utils.chr(String.fromCharCode(c)); },
	toCode: function(c) { return c.charCodeAt(0); },
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();
var _elm_lang$core$Char$fromCode = _elm_lang$core$Native_Char.fromCode;
var _elm_lang$core$Char$toCode = _elm_lang$core$Native_Char.toCode;
var _elm_lang$core$Char$toLocaleLower = _elm_lang$core$Native_Char.toLocaleLower;
var _elm_lang$core$Char$toLocaleUpper = _elm_lang$core$Native_Char.toLocaleUpper;
var _elm_lang$core$Char$toLower = _elm_lang$core$Native_Char.toLower;
var _elm_lang$core$Char$toUpper = _elm_lang$core$Native_Char.toUpper;
var _elm_lang$core$Char$isBetween = F3(
	function (low, high, $char) {
		var code = _elm_lang$core$Char$toCode($char);
		return (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(low)) > -1) && (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(high)) < 1);
	});
var _elm_lang$core$Char$isUpper = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('A'),
	_elm_lang$core$Native_Utils.chr('Z'));
var _elm_lang$core$Char$isLower = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('a'),
	_elm_lang$core$Native_Utils.chr('z'));
var _elm_lang$core$Char$isDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('9'));
var _elm_lang$core$Char$isOctDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('7'));
var _elm_lang$core$Char$isHexDigit = function ($char) {
	return _elm_lang$core$Char$isDigit($char) || (A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('a'),
		_elm_lang$core$Native_Utils.chr('f'),
		$char) || A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('A'),
		_elm_lang$core$Native_Utils.chr('F'),
		$char));
};

//import Native.Utils //

var _elm_lang$core$Native_Scheduler = function() {

var MAX_STEPS = 10000;


// TASKS

function succeed(value)
{
	return {
		ctor: '_Task_succeed',
		value: value
	};
}

function fail(error)
{
	return {
		ctor: '_Task_fail',
		value: error
	};
}

function nativeBinding(callback)
{
	return {
		ctor: '_Task_nativeBinding',
		callback: callback,
		cancel: null
	};
}

function andThen(callback, task)
{
	return {
		ctor: '_Task_andThen',
		callback: callback,
		task: task
	};
}

function onError(callback, task)
{
	return {
		ctor: '_Task_onError',
		callback: callback,
		task: task
	};
}

function receive(callback)
{
	return {
		ctor: '_Task_receive',
		callback: callback
	};
}


// PROCESSES

function rawSpawn(task)
{
	var process = {
		ctor: '_Process',
		id: _elm_lang$core$Native_Utils.guid(),
		root: task,
		stack: null,
		mailbox: []
	};

	enqueue(process);

	return process;
}

function spawn(task)
{
	return nativeBinding(function(callback) {
		var process = rawSpawn(task);
		callback(succeed(process));
	});
}

function rawSend(process, msg)
{
	process.mailbox.push(msg);
	enqueue(process);
}

function send(process, msg)
{
	return nativeBinding(function(callback) {
		rawSend(process, msg);
		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function kill(process)
{
	return nativeBinding(function(callback) {
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding' && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sleep(time)
{
	return nativeBinding(function(callback) {
		var id = setTimeout(function() {
			callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}


// STEP PROCESSES

function step(numSteps, process)
{
	while (numSteps < MAX_STEPS)
	{
		var ctor = process.root.ctor;

		if (ctor === '_Task_succeed')
		{
			while (process.stack && process.stack.ctor === '_Task_onError')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_fail')
		{
			while (process.stack && process.stack.ctor === '_Task_andThen')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_andThen')
		{
			process.stack = {
				ctor: '_Task_andThen',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_onError')
		{
			process.stack = {
				ctor: '_Task_onError',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_nativeBinding')
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				enqueue(process);
			});

			break;
		}

		if (ctor === '_Task_receive')
		{
			var mailbox = process.mailbox;
			if (mailbox.length === 0)
			{
				break;
			}

			process.root = process.root.callback(mailbox.shift());
			++numSteps;
			continue;
		}

		throw new Error(ctor);
	}

	if (numSteps < MAX_STEPS)
	{
		return numSteps + 1;
	}
	enqueue(process);

	return numSteps;
}


// WORK QUEUE

var working = false;
var workQueue = [];

function enqueue(process)
{
	workQueue.push(process);

	if (!working)
	{
		setTimeout(work, 0);
		working = true;
	}
}

function work()
{
	var numSteps = 0;
	var process;
	while (numSteps < MAX_STEPS && (process = workQueue.shift()))
	{
		if (process.root)
		{
			numSteps = step(numSteps, process);
		}
	}
	if (!process)
	{
		working = false;
		return;
	}
	setTimeout(work, 0);
}


return {
	succeed: succeed,
	fail: fail,
	nativeBinding: nativeBinding,
	andThen: F2(andThen),
	onError: F2(onError),
	receive: receive,

	spawn: spawn,
	kill: kill,
	sleep: sleep,
	send: F2(send),

	rawSpawn: rawSpawn,
	rawSend: rawSend
};

}();
//import //

var _elm_lang$core$Native_Platform = function() {


// PROGRAMS

function program(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flags !== 'undefined')
				{
					throw new Error(
						'The `' + moduleName + '` module does not need flags.\n'
						+ 'Call ' + moduleName + '.worker() with no arguments and you should be all set!'
					);
				}

				return initialize(
					impl.init,
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function programWithFlags(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flagDecoder === 'undefined')
				{
					throw new Error(
						'Are you trying to sneak a Never value into Elm? Trickster!\n'
						+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
						+ 'Use `program` instead if you do not want flags.'
					);
				}

				var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
				if (result.ctor === 'Err')
				{
					throw new Error(
						moduleName + '.worker(...) was called with an unexpected argument.\n'
						+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
						+ result._0
					);
				}

				return initialize(
					impl.init(result._0),
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function renderer(enqueue, _)
{
	return function(_) {};
}


// HTML TO PROGRAM

function htmlToProgram(vnode)
{
	var emptyBag = batch(_elm_lang$core$Native_List.Nil);
	var noChange = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		emptyBag
	);

	return _elm_lang$virtual_dom$VirtualDom$program({
		init: noChange,
		view: function(model) { return main; },
		update: F2(function(msg, model) { return noChange; }),
		subscriptions: function (model) { return emptyBag; }
	});
}


// INITIALIZE A PROGRAM

function initialize(init, update, subscriptions, renderer)
{
	// ambient state
	var managers = {};
	var updateView;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var model = init._0;
		updateView = renderer(enqueue, model);
		var cmds = init._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			updateView(model);
			var cmds = results._1;
			var subs = subscriptions(model);
			dispatchEffects(managers, cmds, subs);
			callback(_elm_lang$core$Native_Scheduler.succeed(model));
		});
	}

	var mainProcess = spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		_elm_lang$core$Native_Scheduler.rawSend(mainProcess, msg);
	}

	var ports = setupEffects(managers, enqueue);

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var effectManagers = {};

function setupEffects(managers, callback)
{
	var ports;

	// setup all necessary effect managers
	for (var key in effectManagers)
	{
		var manager = effectManagers[key];

		if (manager.isForeign)
		{
			ports = ports || {};
			ports[key] = manager.tag === 'cmd'
				? setupOutgoingPort(key)
				: setupIncomingPort(key, callback);
		}

		managers[key] = makeManager(manager, callback);
	}

	return ports;
}

function makeManager(info, callback)
{
	var router = {
		main: callback,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.ctor === 'self')
		{
			return A3(onSelfMsg, router, msg._0, state);
		}

		var fx = msg._0;
		switch (tag)
		{
			case 'cmd':
				return A3(onEffects, router, fx.cmds, state);

			case 'sub':
				return A3(onEffects, router, fx.subs, state);

			case 'fx':
				return A4(onEffects, router, fx.cmds, fx.subs, state);
		}
	}

	var process = spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

function sendToApp(router, msg)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		router.main(msg);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sendToSelf(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.self, {
		ctor: 'self',
		_0: msg
	});
}


// HELPER for STATEFUL LOOPS

function spawnLoop(init, onMessage)
{
	var andThen = _elm_lang$core$Native_Scheduler.andThen;

	function loop(state)
	{
		var handleMsg = _elm_lang$core$Native_Scheduler.receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(andThen, loop, handleMsg);
	}

	var task = A2(andThen, loop, init);

	return _elm_lang$core$Native_Scheduler.rawSpawn(task);
}


// BAGS

function leaf(home)
{
	return function(value)
	{
		return {
			type: 'leaf',
			home: home,
			value: value
		};
	};
}

function batch(list)
{
	return {
		type: 'node',
		branches: list
	};
}

function map(tagger, bag)
{
	return {
		type: 'map',
		tagger: tagger,
		tree: bag
	}
}


// PIPE BAGS INTO EFFECT MANAGERS

function dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects(true, cmdBag, effectsDict, null);
	gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		var fx = home in effectsDict
			? effectsDict[home]
			: {
				cmds: _elm_lang$core$Native_List.Nil,
				subs: _elm_lang$core$Native_List.Nil
			};

		_elm_lang$core$Native_Scheduler.rawSend(managers[home], { ctor: 'fx', _0: fx });
	}
}

function gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(isCmd, list._0, effectsDict, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		var temp = taggers;
		while (temp)
		{
			x = temp.tagger(x);
			temp = temp.rest;
		}
		return x;
	}

	var map = isCmd
		? effectManagers[home].cmdMap
		: effectManagers[home].subMap;

	return A2(map, applyTaggers, value)
}

function insert(isCmd, newEffect, effects)
{
	effects = effects || {
		cmds: _elm_lang$core$Native_List.Nil,
		subs: _elm_lang$core$Native_List.Nil
	};
	if (isCmd)
	{
		effects.cmds = _elm_lang$core$Native_List.Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = _elm_lang$core$Native_List.Cons(newEffect, effects.subs);
	return effects;
}


// PORTS

function checkPortName(name)
{
	if (name in effectManagers)
	{
		throw new Error('There can only be one port named `' + name + '`, but your program has multiple.');
	}
}


// OUTGOING PORTS

function outgoingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'cmd',
		cmdMap: outgoingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var outgoingPortMap = F2(function cmdMap(tagger, value) {
	return value;
});

function setupOutgoingPort(name)
{
	var subs = [];
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, cmdList, state)
	{
		while (cmdList.ctor !== '[]')
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = converter(cmdList._0);
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
			cmdList = cmdList._1;
		}
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

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

function incomingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'sub',
		subMap: incomingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var incomingPortMap = F2(function subMap(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});

function setupIncomingPort(name, callback)
{
	var sentBeforeInit = [];
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;
	var currentOnEffects = preInitOnEffects;
	var currentSend = preInitSend;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function preInitOnEffects(router, subList, state)
	{
		var postInitResult = postInitOnEffects(router, subList, state);

		for(var i = 0; i < sentBeforeInit.length; i++)
		{
			postInitSend(sentBeforeInit[i]);
		}

		sentBeforeInit = null; // to release objects held in queue
		currentSend = postInitSend;
		currentOnEffects = postInitOnEffects;
		return postInitResult;
	}

	function postInitOnEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	function onEffects(router, subList, state)
	{
		return currentOnEffects(router, subList, state);
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function preInitSend(value)
	{
		sentBeforeInit.push(value);
	}

	function postInitSend(incomingValue)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, incomingValue);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through port `' + name + '`:\n' + result._0);
		}

		var value = result._0;
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			callback(temp._0(value));
			temp = temp._1;
		}
	}

	function send(incomingValue)
	{
		currentSend(incomingValue);
	}

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,

	htmlToProgram: htmlToProgram,
	program: program,
	programWithFlags: programWithFlags,
	initialize: initialize,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
};

}();

var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Cmd_ops = _elm_lang$core$Platform_Cmd_ops || {};
_elm_lang$core$Platform_Cmd_ops['!'] = F2(
	function (model, commands) {
		return {
			ctor: '_Tuple2',
			_0: model,
			_1: _elm_lang$core$Platform_Cmd$batch(commands)
		};
	});
var _elm_lang$core$Platform_Cmd$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Cmd$Cmd = {ctor: 'Cmd'};

var _elm_lang$core$Platform_Sub$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Sub$none = _elm_lang$core$Platform_Sub$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$programWithFlags = _elm_lang$core$Native_Platform.programWithFlags;
var _elm_lang$core$Platform$program = _elm_lang$core$Native_Platform.program;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _elm_lang$core$Result$toMaybe = function (result) {
	var _p0 = result;
	if (_p0.ctor === 'Ok') {
		return _elm_lang$core$Maybe$Just(_p0._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$Result$withDefault = F2(
	function (def, result) {
		var _p1 = result;
		if (_p1.ctor === 'Ok') {
			return _p1._0;
		} else {
			return def;
		}
	});
var _elm_lang$core$Result$Err = function (a) {
	return {ctor: 'Err', _0: a};
};
var _elm_lang$core$Result$andThen = F2(
	function (callback, result) {
		var _p2 = result;
		if (_p2.ctor === 'Ok') {
			return callback(_p2._0);
		} else {
			return _elm_lang$core$Result$Err(_p2._0);
		}
	});
var _elm_lang$core$Result$Ok = function (a) {
	return {ctor: 'Ok', _0: a};
};
var _elm_lang$core$Result$map = F2(
	function (func, ra) {
		var _p3 = ra;
		if (_p3.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(
				func(_p3._0));
		} else {
			return _elm_lang$core$Result$Err(_p3._0);
		}
	});
var _elm_lang$core$Result$map2 = F3(
	function (func, ra, rb) {
		var _p4 = {ctor: '_Tuple2', _0: ra, _1: rb};
		if (_p4._0.ctor === 'Ok') {
			if (_p4._1.ctor === 'Ok') {
				return _elm_lang$core$Result$Ok(
					A2(func, _p4._0._0, _p4._1._0));
			} else {
				return _elm_lang$core$Result$Err(_p4._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p4._0._0);
		}
	});
var _elm_lang$core$Result$map3 = F4(
	function (func, ra, rb, rc) {
		var _p5 = {ctor: '_Tuple3', _0: ra, _1: rb, _2: rc};
		if (_p5._0.ctor === 'Ok') {
			if (_p5._1.ctor === 'Ok') {
				if (_p5._2.ctor === 'Ok') {
					return _elm_lang$core$Result$Ok(
						A3(func, _p5._0._0, _p5._1._0, _p5._2._0));
				} else {
					return _elm_lang$core$Result$Err(_p5._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p5._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p5._0._0);
		}
	});
var _elm_lang$core$Result$map4 = F5(
	function (func, ra, rb, rc, rd) {
		var _p6 = {ctor: '_Tuple4', _0: ra, _1: rb, _2: rc, _3: rd};
		if (_p6._0.ctor === 'Ok') {
			if (_p6._1.ctor === 'Ok') {
				if (_p6._2.ctor === 'Ok') {
					if (_p6._3.ctor === 'Ok') {
						return _elm_lang$core$Result$Ok(
							A4(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0));
					} else {
						return _elm_lang$core$Result$Err(_p6._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p6._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p6._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p6._0._0);
		}
	});
var _elm_lang$core$Result$map5 = F6(
	function (func, ra, rb, rc, rd, re) {
		var _p7 = {ctor: '_Tuple5', _0: ra, _1: rb, _2: rc, _3: rd, _4: re};
		if (_p7._0.ctor === 'Ok') {
			if (_p7._1.ctor === 'Ok') {
				if (_p7._2.ctor === 'Ok') {
					if (_p7._3.ctor === 'Ok') {
						if (_p7._4.ctor === 'Ok') {
							return _elm_lang$core$Result$Ok(
								A5(func, _p7._0._0, _p7._1._0, _p7._2._0, _p7._3._0, _p7._4._0));
						} else {
							return _elm_lang$core$Result$Err(_p7._4._0);
						}
					} else {
						return _elm_lang$core$Result$Err(_p7._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p7._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p7._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p7._0._0);
		}
	});
var _elm_lang$core$Result$mapError = F2(
	function (f, result) {
		var _p8 = result;
		if (_p8.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(_p8._0);
		} else {
			return _elm_lang$core$Result$Err(
				f(_p8._0));
		}
	});
var _elm_lang$core$Result$fromMaybe = F2(
	function (err, maybe) {
		var _p9 = maybe;
		if (_p9.ctor === 'Just') {
			return _elm_lang$core$Result$Ok(_p9._0);
		} else {
			return _elm_lang$core$Result$Err(err);
		}
	});

//import Native.Utils //

var _elm_lang$core$Native_Debug = function() {

function log(tag, value)
{
	var msg = tag + ': ' + _elm_lang$core$Native_Utils.toString(value);
	var process = process || {};
	if (process.stdout)
	{
		process.stdout.write(msg);
	}
	else
	{
		console.log(msg);
	}
	return value;
}

function crash(message)
{
	throw new Error(message);
}

return {
	crash: crash,
	log: F2(log)
};

}();
//import Maybe, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_String = function() {

function isEmpty(str)
{
	return str.length === 0;
}
function cons(chr, str)
{
	return chr + str;
}
function uncons(str)
{
	var hd = str[0];
	if (hd)
	{
		return _elm_lang$core$Maybe$Just(_elm_lang$core$Native_Utils.Tuple2(_elm_lang$core$Native_Utils.chr(hd), str.slice(1)));
	}
	return _elm_lang$core$Maybe$Nothing;
}
function append(a, b)
{
	return a + b;
}
function concat(strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join('');
}
function length(str)
{
	return str.length;
}
function map(f, str)
{
	var out = str.split('');
	for (var i = out.length; i--; )
	{
		out[i] = f(_elm_lang$core$Native_Utils.chr(out[i]));
	}
	return out.join('');
}
function filter(pred, str)
{
	return str.split('').map(_elm_lang$core$Native_Utils.chr).filter(pred).join('');
}
function reverse(str)
{
	return str.split('').reverse().join('');
}
function foldl(f, b, str)
{
	var len = str.length;
	for (var i = 0; i < len; ++i)
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function foldr(f, b, str)
{
	for (var i = str.length; i--; )
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function split(sep, str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(sep));
}
function join(sep, strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join(sep);
}
function repeat(n, str)
{
	var result = '';
	while (n > 0)
	{
		if (n & 1)
		{
			result += str;
		}
		n >>= 1, str += str;
	}
	return result;
}
function slice(start, end, str)
{
	return str.slice(start, end);
}
function left(n, str)
{
	return n < 1 ? '' : str.slice(0, n);
}
function right(n, str)
{
	return n < 1 ? '' : str.slice(-n);
}
function dropLeft(n, str)
{
	return n < 1 ? str : str.slice(n);
}
function dropRight(n, str)
{
	return n < 1 ? str : str.slice(0, -n);
}
function pad(n, chr, str)
{
	var half = (n - str.length) / 2;
	return repeat(Math.ceil(half), chr) + str + repeat(half | 0, chr);
}
function padRight(n, chr, str)
{
	return str + repeat(n - str.length, chr);
}
function padLeft(n, chr, str)
{
	return repeat(n - str.length, chr) + str;
}

function trim(str)
{
	return str.trim();
}
function trimLeft(str)
{
	return str.replace(/^\s+/, '');
}
function trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function words(str)
{
	return _elm_lang$core$Native_List.fromArray(str.trim().split(/\s+/g));
}
function lines(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(/\r\n|\r|\n/g));
}

function toUpper(str)
{
	return str.toUpperCase();
}
function toLower(str)
{
	return str.toLowerCase();
}

function any(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return true;
		}
	}
	return false;
}
function all(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (!pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return false;
		}
	}
	return true;
}

function contains(sub, str)
{
	return str.indexOf(sub) > -1;
}
function startsWith(sub, str)
{
	return str.indexOf(sub) === 0;
}
function endsWith(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
}
function indexes(sub, str)
{
	var subLen = sub.length;
	
	if (subLen < 1)
	{
		return _elm_lang$core$Native_List.Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}	
	
	return _elm_lang$core$Native_List.fromArray(is);
}

function toInt(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
		start = 1;
	}
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if (c < '0' || '9' < c)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
	}
	return _elm_lang$core$Result$Ok(parseInt(s, 10));
}

function toFloat(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
		}
		start = 1;
	}
	var dotCount = 0;
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if ('0' <= c && c <= '9')
		{
			continue;
		}
		if (c === '.')
		{
			dotCount += 1;
			if (dotCount <= 1)
			{
				continue;
			}
		}
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	return _elm_lang$core$Result$Ok(parseFloat(s));
}

function toList(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split('').map(_elm_lang$core$Native_Utils.chr));
}
function fromList(chars)
{
	return _elm_lang$core$Native_List.toArray(chars).join('');
}

return {
	isEmpty: isEmpty,
	cons: F2(cons),
	uncons: uncons,
	append: F2(append),
	concat: concat,
	length: length,
	map: F2(map),
	filter: F2(filter),
	reverse: reverse,
	foldl: F3(foldl),
	foldr: F3(foldr),

	split: F2(split),
	join: F2(join),
	repeat: F2(repeat),

	slice: F3(slice),
	left: F2(left),
	right: F2(right),
	dropLeft: F2(dropLeft),
	dropRight: F2(dropRight),

	pad: F3(pad),
	padLeft: F3(padLeft),
	padRight: F3(padRight),

	trim: trim,
	trimLeft: trimLeft,
	trimRight: trimRight,

	words: words,
	lines: lines,

	toUpper: toUpper,
	toLower: toLower,

	any: F2(any),
	all: F2(all),

	contains: F2(contains),
	startsWith: F2(startsWith),
	endsWith: F2(endsWith),
	indexes: F2(indexes),

	toInt: toInt,
	toFloat: toFloat,
	toList: toList,
	fromList: fromList
};

}();

var _elm_lang$core$String$fromList = _elm_lang$core$Native_String.fromList;
var _elm_lang$core$String$toList = _elm_lang$core$Native_String.toList;
var _elm_lang$core$String$toFloat = _elm_lang$core$Native_String.toFloat;
var _elm_lang$core$String$toInt = _elm_lang$core$Native_String.toInt;
var _elm_lang$core$String$indices = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$indexes = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$endsWith = _elm_lang$core$Native_String.endsWith;
var _elm_lang$core$String$startsWith = _elm_lang$core$Native_String.startsWith;
var _elm_lang$core$String$contains = _elm_lang$core$Native_String.contains;
var _elm_lang$core$String$all = _elm_lang$core$Native_String.all;
var _elm_lang$core$String$any = _elm_lang$core$Native_String.any;
var _elm_lang$core$String$toLower = _elm_lang$core$Native_String.toLower;
var _elm_lang$core$String$toUpper = _elm_lang$core$Native_String.toUpper;
var _elm_lang$core$String$lines = _elm_lang$core$Native_String.lines;
var _elm_lang$core$String$words = _elm_lang$core$Native_String.words;
var _elm_lang$core$String$trimRight = _elm_lang$core$Native_String.trimRight;
var _elm_lang$core$String$trimLeft = _elm_lang$core$Native_String.trimLeft;
var _elm_lang$core$String$trim = _elm_lang$core$Native_String.trim;
var _elm_lang$core$String$padRight = _elm_lang$core$Native_String.padRight;
var _elm_lang$core$String$padLeft = _elm_lang$core$Native_String.padLeft;
var _elm_lang$core$String$pad = _elm_lang$core$Native_String.pad;
var _elm_lang$core$String$dropRight = _elm_lang$core$Native_String.dropRight;
var _elm_lang$core$String$dropLeft = _elm_lang$core$Native_String.dropLeft;
var _elm_lang$core$String$right = _elm_lang$core$Native_String.right;
var _elm_lang$core$String$left = _elm_lang$core$Native_String.left;
var _elm_lang$core$String$slice = _elm_lang$core$Native_String.slice;
var _elm_lang$core$String$repeat = _elm_lang$core$Native_String.repeat;
var _elm_lang$core$String$join = _elm_lang$core$Native_String.join;
var _elm_lang$core$String$split = _elm_lang$core$Native_String.split;
var _elm_lang$core$String$foldr = _elm_lang$core$Native_String.foldr;
var _elm_lang$core$String$foldl = _elm_lang$core$Native_String.foldl;
var _elm_lang$core$String$reverse = _elm_lang$core$Native_String.reverse;
var _elm_lang$core$String$filter = _elm_lang$core$Native_String.filter;
var _elm_lang$core$String$map = _elm_lang$core$Native_String.map;
var _elm_lang$core$String$length = _elm_lang$core$Native_String.length;
var _elm_lang$core$String$concat = _elm_lang$core$Native_String.concat;
var _elm_lang$core$String$append = _elm_lang$core$Native_String.append;
var _elm_lang$core$String$uncons = _elm_lang$core$Native_String.uncons;
var _elm_lang$core$String$cons = _elm_lang$core$Native_String.cons;
var _elm_lang$core$String$fromChar = function ($char) {
	return A2(_elm_lang$core$String$cons, $char, '');
};
var _elm_lang$core$String$isEmpty = _elm_lang$core$Native_String.isEmpty;

var _elm_lang$core$Dict$foldr = F3(
	function (f, acc, t) {
		foldr:
		while (true) {
			var _p0 = t;
			if (_p0.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v1 = f,
					_v2 = A3(
					f,
					_p0._1,
					_p0._2,
					A3(_elm_lang$core$Dict$foldr, f, acc, _p0._4)),
					_v3 = _p0._3;
				f = _v1;
				acc = _v2;
				t = _v3;
				continue foldr;
			}
		}
	});
var _elm_lang$core$Dict$keys = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return {ctor: '::', _0: key, _1: keyList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return {ctor: '::', _0: value, _1: valueList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: key, _1: value},
					_1: list
				};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			var _p1 = dict;
			if (_p1.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v5 = f,
					_v6 = A3(
					f,
					_p1._1,
					_p1._2,
					A3(_elm_lang$core$Dict$foldl, f, acc, _p1._3)),
					_v7 = _p1._4;
				f = _v5;
				acc = _v6;
				dict = _v7;
				continue foldl;
			}
		}
	});
var _elm_lang$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _p2) {
				stepState:
				while (true) {
					var _p3 = _p2;
					var _p9 = _p3._1;
					var _p8 = _p3._0;
					var _p4 = _p8;
					if (_p4.ctor === '[]') {
						return {
							ctor: '_Tuple2',
							_0: _p8,
							_1: A3(rightStep, rKey, rValue, _p9)
						};
					} else {
						var _p7 = _p4._1;
						var _p6 = _p4._0._1;
						var _p5 = _p4._0._0;
						if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) {
							var _v10 = rKey,
								_v11 = rValue,
								_v12 = {
								ctor: '_Tuple2',
								_0: _p7,
								_1: A3(leftStep, _p5, _p6, _p9)
							};
							rKey = _v10;
							rValue = _v11;
							_p2 = _v12;
							continue stepState;
						} else {
							if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) {
								return {
									ctor: '_Tuple2',
									_0: _p8,
									_1: A3(rightStep, rKey, rValue, _p9)
								};
							} else {
								return {
									ctor: '_Tuple2',
									_0: _p7,
									_1: A4(bothStep, _p5, _p6, rValue, _p9)
								};
							}
						}
					}
				}
			});
		var _p10 = A3(
			_elm_lang$core$Dict$foldl,
			stepState,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Dict$toList(leftDict),
				_1: initialResult
			},
			rightDict);
		var leftovers = _p10._0;
		var intermediateResult = _p10._1;
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (_p11, result) {
					var _p12 = _p11;
					return A3(leftStep, _p12._0, _p12._1, result);
				}),
			intermediateResult,
			leftovers);
	});
var _elm_lang$core$Dict$reportRemBug = F4(
	function (msg, c, lgot, rgot) {
		return _elm_lang$core$Native_Debug.crash(
			_elm_lang$core$String$concat(
				{
					ctor: '::',
					_0: 'Internal red-black tree invariant violated, expected ',
					_1: {
						ctor: '::',
						_0: msg,
						_1: {
							ctor: '::',
							_0: ' and got ',
							_1: {
								ctor: '::',
								_0: _elm_lang$core$Basics$toString(c),
								_1: {
									ctor: '::',
									_0: '/',
									_1: {
										ctor: '::',
										_0: lgot,
										_1: {
											ctor: '::',
											_0: '/',
											_1: {
												ctor: '::',
												_0: rgot,
												_1: {
													ctor: '::',
													_0: '\nPlease report this bug to <https://github.com/elm-lang/core/issues>',
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}
				}));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v14_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v14_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v14_2;
			}
		}
	} while(false);
	return false;
};
var _elm_lang$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			var _p14 = dict;
			if (_p14.ctor === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var _v16 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v17 = _p14._3;
				n = _v16;
				dict = _v17;
				continue sizeHelp;
			}
		}
	});
var _elm_lang$core$Dict$size = function (dict) {
	return A2(_elm_lang$core$Dict$sizeHelp, 0, dict);
};
var _elm_lang$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			var _p15 = dict;
			if (_p15.ctor === 'RBEmpty_elm_builtin') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p16 = A2(_elm_lang$core$Basics$compare, targetKey, _p15._1);
				switch (_p16.ctor) {
					case 'LT':
						var _v20 = targetKey,
							_v21 = _p15._3;
						targetKey = _v20;
						dict = _v21;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v22 = targetKey,
							_v23 = _p15._4;
						targetKey = _v22;
						dict = _v23;
						continue get;
				}
			}
		}
	});
var _elm_lang$core$Dict$member = F2(
	function (key, dict) {
		var _p17 = A2(_elm_lang$core$Dict$get, key, dict);
		if (_p17.ctor === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var _elm_lang$core$Dict$maxWithDefault = F3(
	function (k, v, r) {
		maxWithDefault:
		while (true) {
			var _p18 = r;
			if (_p18.ctor === 'RBEmpty_elm_builtin') {
				return {ctor: '_Tuple2', _0: k, _1: v};
			} else {
				var _v26 = _p18._1,
					_v27 = _p18._2,
					_v28 = _p18._4;
				k = _v26;
				v = _v27;
				r = _v28;
				continue maxWithDefault;
			}
		}
	});
var _elm_lang$core$Dict$NBlack = {ctor: 'NBlack'};
var _elm_lang$core$Dict$BBlack = {ctor: 'BBlack'};
var _elm_lang$core$Dict$Black = {ctor: 'Black'};
var _elm_lang$core$Dict$blackish = function (t) {
	var _p19 = t;
	if (_p19.ctor === 'RBNode_elm_builtin') {
		var _p20 = _p19._0;
		return _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$Black) || _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$BBlack);
	} else {
		return true;
	}
};
var _elm_lang$core$Dict$Red = {ctor: 'Red'};
var _elm_lang$core$Dict$moreBlack = function (color) {
	var _p21 = color;
	switch (_p21.ctor) {
		case 'Black':
			return _elm_lang$core$Dict$BBlack;
		case 'Red':
			return _elm_lang$core$Dict$Black;
		case 'NBlack':
			return _elm_lang$core$Dict$Red;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a double black node more black!');
	}
};
var _elm_lang$core$Dict$lessBlack = function (color) {
	var _p22 = color;
	switch (_p22.ctor) {
		case 'BBlack':
			return _elm_lang$core$Dict$Black;
		case 'Black':
			return _elm_lang$core$Dict$Red;
		case 'Red':
			return _elm_lang$core$Dict$NBlack;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a negative black node less black!');
	}
};
var _elm_lang$core$Dict$LBBlack = {ctor: 'LBBlack'};
var _elm_lang$core$Dict$LBlack = {ctor: 'LBlack'};
var _elm_lang$core$Dict$RBEmpty_elm_builtin = function (a) {
	return {ctor: 'RBEmpty_elm_builtin', _0: a};
};
var _elm_lang$core$Dict$empty = _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
var _elm_lang$core$Dict$isEmpty = function (dict) {
	return _elm_lang$core$Native_Utils.eq(dict, _elm_lang$core$Dict$empty);
};
var _elm_lang$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {ctor: 'RBNode_elm_builtin', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _elm_lang$core$Dict$ensureBlackRoot = function (dict) {
	var _p23 = dict;
	if ((_p23.ctor === 'RBNode_elm_builtin') && (_p23._0.ctor === 'Red')) {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p23._1, _p23._2, _p23._3, _p23._4);
	} else {
		return dict;
	}
};
var _elm_lang$core$Dict$lessBlackTree = function (dict) {
	var _p24 = dict;
	if (_p24.ctor === 'RBNode_elm_builtin') {
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$lessBlack(_p24._0),
			_p24._1,
			_p24._2,
			_p24._3,
			_p24._4);
	} else {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	}
};
var _elm_lang$core$Dict$balancedTree = function (col) {
	return function (xk) {
		return function (xv) {
			return function (yk) {
				return function (yv) {
					return function (zk) {
						return function (zv) {
							return function (a) {
								return function (b) {
									return function (c) {
										return function (d) {
											return A5(
												_elm_lang$core$Dict$RBNode_elm_builtin,
												_elm_lang$core$Dict$lessBlack(col),
												yk,
												yv,
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, xk, xv, a, b),
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, zk, zv, c, d));
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$core$Dict$blacken = function (t) {
	var _p25 = t;
	if (_p25.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p25._1, _p25._2, _p25._3, _p25._4);
	}
};
var _elm_lang$core$Dict$redden = function (t) {
	var _p26 = t;
	if (_p26.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Native_Debug.crash('can\'t make a Leaf red');
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, _p26._1, _p26._2, _p26._3, _p26._4);
	}
};
var _elm_lang$core$Dict$balanceHelp = function (tree) {
	var _p27 = tree;
	_v36_6:
	do {
		_v36_5:
		do {
			_v36_4:
			do {
				_v36_3:
				do {
					_v36_2:
					do {
						_v36_1:
						do {
							_v36_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v36_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v36_3;
																		} else {
																			break _v36_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v36_4;
																	} else {
																		break _v36_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	break _v36_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v36_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															} else {
																break _v36_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v36_5;
															} else {
																break _v36_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	break _v36_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v36_4;
															} else {
																break _v36_6;
															}
														default:
															break _v36_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v36_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v36_1;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v36_5;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v36_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v36_3;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v36_4;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										} else {
											break _v36_6;
										}
									}
								} else {
									break _v36_6;
								}
							} while(false);
							return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._3._1)(_p27._3._3._2)(_p27._3._1)(_p27._3._2)(_p27._1)(_p27._2)(_p27._3._3._3)(_p27._3._3._4)(_p27._3._4)(_p27._4);
						} while(false);
						return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._1)(_p27._3._2)(_p27._3._4._1)(_p27._3._4._2)(_p27._1)(_p27._2)(_p27._3._3)(_p27._3._4._3)(_p27._3._4._4)(_p27._4);
					} while(false);
					return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._3._1)(_p27._4._3._2)(_p27._4._1)(_p27._4._2)(_p27._3)(_p27._4._3._3)(_p27._4._3._4)(_p27._4._4);
				} while(false);
				return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._1)(_p27._4._2)(_p27._4._4._1)(_p27._4._4._2)(_p27._3)(_p27._4._3)(_p27._4._4._3)(_p27._4._4._4);
			} while(false);
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_elm_lang$core$Dict$Black,
				_p27._4._3._1,
				_p27._4._3._2,
				A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3, _p27._4._3._3),
				A5(
					_elm_lang$core$Dict$balance,
					_elm_lang$core$Dict$Black,
					_p27._4._1,
					_p27._4._2,
					_p27._4._3._4,
					_elm_lang$core$Dict$redden(_p27._4._4)));
		} while(false);
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$Black,
			_p27._3._4._1,
			_p27._3._4._2,
			A5(
				_elm_lang$core$Dict$balance,
				_elm_lang$core$Dict$Black,
				_p27._3._1,
				_p27._3._2,
				_elm_lang$core$Dict$redden(_p27._3._3),
				_p27._3._4._3),
			A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3._4._4, _p27._4));
	} while(false);
	return tree;
};
var _elm_lang$core$Dict$balance = F5(
	function (c, k, v, l, r) {
		var tree = A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
		return _elm_lang$core$Dict$blackish(tree) ? _elm_lang$core$Dict$balanceHelp(tree) : tree;
	});
var _elm_lang$core$Dict$bubble = F5(
	function (c, k, v, l, r) {
		return (_elm_lang$core$Dict$isBBlack(l) || _elm_lang$core$Dict$isBBlack(r)) ? A5(
			_elm_lang$core$Dict$balance,
			_elm_lang$core$Dict$moreBlack(c),
			k,
			v,
			_elm_lang$core$Dict$lessBlackTree(l),
			_elm_lang$core$Dict$lessBlackTree(r)) : A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
	});
var _elm_lang$core$Dict$removeMax = F5(
	function (c, k, v, l, r) {
		var _p28 = r;
		if (_p28.ctor === 'RBEmpty_elm_builtin') {
			return A3(_elm_lang$core$Dict$rem, c, l, r);
		} else {
			return A5(
				_elm_lang$core$Dict$bubble,
				c,
				k,
				v,
				l,
				A5(_elm_lang$core$Dict$removeMax, _p28._0, _p28._1, _p28._2, _p28._3, _p28._4));
		}
	});
var _elm_lang$core$Dict$rem = F3(
	function (color, left, right) {
		var _p29 = {ctor: '_Tuple2', _0: left, _1: right};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = color;
				switch (_p30.ctor) {
					case 'Red':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
					case 'Black':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBBlack);
					default:
						return _elm_lang$core$Native_Debug.crash('cannot have bblack or nblack nodes at this point');
				}
			} else {
				var _p33 = _p29._1._0;
				var _p32 = _p29._0._0;
				var _p31 = {ctor: '_Tuple3', _0: color, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						color,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: color, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						color,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var newLeft = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, color, k, v, newLeft, right);
			}
		}
	});
var _elm_lang$core$Dict$map = F2(
	function (f, dict) {
		var _p41 = dict;
		if (_p41.ctor === 'RBEmpty_elm_builtin') {
			return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
		} else {
			var _p42 = _p41._1;
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_p41._0,
				_p42,
				A2(f, _p42, _p41._2),
				A2(_elm_lang$core$Dict$map, f, _p41._3),
				A2(_elm_lang$core$Dict$map, f, _p41._4));
		}
	});
var _elm_lang$core$Dict$Same = {ctor: 'Same'};
var _elm_lang$core$Dict$Remove = {ctor: 'Remove'};
var _elm_lang$core$Dict$Insert = {ctor: 'Insert'};
var _elm_lang$core$Dict$update = F3(
	function (k, alter, dict) {
		var up = function (dict) {
			var _p43 = dict;
			if (_p43.ctor === 'RBEmpty_elm_builtin') {
				var _p44 = alter(_elm_lang$core$Maybe$Nothing);
				if (_p44.ctor === 'Nothing') {
					return {ctor: '_Tuple2', _0: _elm_lang$core$Dict$Same, _1: _elm_lang$core$Dict$empty};
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Dict$Insert,
						_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, k, _p44._0, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty)
					};
				}
			} else {
				var _p55 = _p43._2;
				var _p54 = _p43._4;
				var _p53 = _p43._3;
				var _p52 = _p43._1;
				var _p51 = _p43._0;
				var _p45 = A2(_elm_lang$core$Basics$compare, k, _p52);
				switch (_p45.ctor) {
					case 'EQ':
						var _p46 = alter(
							_elm_lang$core$Maybe$Just(_p55));
						if (_p46.ctor === 'Nothing') {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Remove,
								_1: A3(_elm_lang$core$Dict$rem, _p51, _p53, _p54)
							};
						} else {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Same,
								_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p46._0, _p53, _p54)
							};
						}
					case 'LT':
						var _p47 = up(_p53);
						var flag = _p47._0;
						var newLeft = _p47._1;
						var _p48 = flag;
						switch (_p48.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, newLeft, _p54)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, newLeft, _p54)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, newLeft, _p54)
								};
						}
					default:
						var _p49 = up(_p54);
						var flag = _p49._0;
						var newRight = _p49._1;
						var _p50 = flag;
						switch (_p50.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, _p53, newRight)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, _p53, newRight)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, _p53, newRight)
								};
						}
				}
			}
		};
		var _p56 = up(dict);
		var flag = _p56._0;
		var updatedDict = _p56._1;
		var _p57 = flag;
		switch (_p57.ctor) {
			case 'Same':
				return updatedDict;
			case 'Insert':
				return _elm_lang$core$Dict$ensureBlackRoot(updatedDict);
			default:
				return _elm_lang$core$Dict$blacken(updatedDict);
		}
	});
var _elm_lang$core$Dict$insert = F3(
	function (key, value, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(
				_elm_lang$core$Maybe$Just(value)),
			dict);
	});
var _elm_lang$core$Dict$singleton = F2(
	function (key, value) {
		return A3(_elm_lang$core$Dict$insert, key, value, _elm_lang$core$Dict$empty);
	});
var _elm_lang$core$Dict$union = F2(
	function (t1, t2) {
		return A3(_elm_lang$core$Dict$foldl, _elm_lang$core$Dict$insert, t2, t1);
	});
var _elm_lang$core$Dict$filter = F2(
	function (predicate, dictionary) {
		var add = F3(
			function (key, value, dict) {
				return A2(predicate, key, value) ? A3(_elm_lang$core$Dict$insert, key, value, dict) : dict;
			});
		return A3(_elm_lang$core$Dict$foldl, add, _elm_lang$core$Dict$empty, dictionary);
	});
var _elm_lang$core$Dict$intersect = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Dict$filter,
			F2(
				function (k, _p58) {
					return A2(_elm_lang$core$Dict$member, k, t2);
				}),
			t1);
	});
var _elm_lang$core$Dict$partition = F2(
	function (predicate, dict) {
		var add = F3(
			function (key, value, _p59) {
				var _p60 = _p59;
				var _p62 = _p60._1;
				var _p61 = _p60._0;
				return A2(predicate, key, value) ? {
					ctor: '_Tuple2',
					_0: A3(_elm_lang$core$Dict$insert, key, value, _p61),
					_1: _p62
				} : {
					ctor: '_Tuple2',
					_0: _p61,
					_1: A3(_elm_lang$core$Dict$insert, key, value, _p62)
				};
			});
		return A3(
			_elm_lang$core$Dict$foldl,
			add,
			{ctor: '_Tuple2', _0: _elm_lang$core$Dict$empty, _1: _elm_lang$core$Dict$empty},
			dict);
	});
var _elm_lang$core$Dict$fromList = function (assocs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p63, dict) {
				var _p64 = _p63;
				return A3(_elm_lang$core$Dict$insert, _p64._0, _p64._1, dict);
			}),
		_elm_lang$core$Dict$empty,
		assocs);
};
var _elm_lang$core$Dict$remove = F2(
	function (key, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(_elm_lang$core$Maybe$Nothing),
			dict);
	});
var _elm_lang$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2(_elm_lang$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});

var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

//import Maybe, Native.Array, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_Json = function() {


// CORE DECODERS

function succeed(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'succeed',
		msg: msg
	};
}

function fail(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'fail',
		msg: msg
	};
}

function decodePrimitive(tag)
{
	return {
		ctor: '<decoder>',
		tag: tag
	};
}

function decodeContainer(tag, decoder)
{
	return {
		ctor: '<decoder>',
		tag: tag,
		decoder: decoder
	};
}

function decodeNull(value)
{
	return {
		ctor: '<decoder>',
		tag: 'null',
		value: value
	};
}

function decodeField(field, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'field',
		field: field,
		decoder: decoder
	};
}

function decodeIndex(index, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'index',
		index: index,
		decoder: decoder
	};
}

function decodeKeyValuePairs(decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'key-value',
		decoder: decoder
	};
}

function mapMany(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'map-many',
		func: f,
		decoders: decoders
	};
}

function andThen(callback, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'andThen',
		decoder: decoder,
		callback: callback
	};
}

function oneOf(decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'oneOf',
		decoders: decoders
	};
}


// DECODING OBJECTS

function map1(f, d1)
{
	return mapMany(f, [d1]);
}

function map2(f, d1, d2)
{
	return mapMany(f, [d1, d2]);
}

function map3(f, d1, d2, d3)
{
	return mapMany(f, [d1, d2, d3]);
}

function map4(f, d1, d2, d3, d4)
{
	return mapMany(f, [d1, d2, d3, d4]);
}

function map5(f, d1, d2, d3, d4, d5)
{
	return mapMany(f, [d1, d2, d3, d4, d5]);
}

function map6(f, d1, d2, d3, d4, d5, d6)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6]);
}

function map7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function map8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
}


// DECODE HELPERS

function ok(value)
{
	return { tag: 'ok', value: value };
}

function badPrimitive(type, value)
{
	return { tag: 'primitive', type: type, value: value };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badField(field, nestedProblems)
{
	return { tag: 'field', field: field, rest: nestedProblems };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badOneOf(problems)
{
	return { tag: 'oneOf', problems: problems };
}

function bad(msg)
{
	return { tag: 'fail', msg: msg };
}

function badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case 'primitive':
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + jsToString(problem.value);

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'field':
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'oneOf':
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case 'fail':
				return 'I ran into a `fail` decoder'
					+ (context === '_' ? '' : ' at ' + context)
					+ ': ' + problem.msg;
		}
	}
}

function jsToString(value)
{
	return value === undefined
		? 'undefined'
		: JSON.stringify(value);
}


// DECODE

function runOnString(decoder, string)
{
	var json;
	try
	{
		json = JSON.parse(string);
	}
	catch (e)
	{
		return _elm_lang$core$Result$Err('Given an invalid JSON: ' + e.message);
	}
	return run(decoder, json);
}

function run(decoder, value)
{
	var result = runHelp(decoder, value);
	return (result.tag === 'ok')
		? _elm_lang$core$Result$Ok(result.value)
		: _elm_lang$core$Result$Err(badToString(result));
}

function runHelp(decoder, value)
{
	switch (decoder.tag)
	{
		case 'bool':
			return (typeof value === 'boolean')
				? ok(value)
				: badPrimitive('a Bool', value);

		case 'int':
			if (typeof value !== 'number') {
				return badPrimitive('an Int', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return ok(value);
			}

			return badPrimitive('an Int', value);

		case 'float':
			return (typeof value === 'number')
				? ok(value)
				: badPrimitive('a Float', value);

		case 'string':
			return (typeof value === 'string')
				? ok(value)
				: (value instanceof String)
					? ok(value + '')
					: badPrimitive('a String', value);

		case 'null':
			return (value === null)
				? ok(decoder.value)
				: badPrimitive('null', value);

		case 'value':
			return ok(value);

		case 'list':
			if (!(value instanceof Array))
			{
				return badPrimitive('a List', value);
			}

			var list = _elm_lang$core$Native_List.Nil;
			for (var i = value.length; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result)
				}
				list = _elm_lang$core$Native_List.Cons(result.value, list);
			}
			return ok(list);

		case 'array':
			if (!(value instanceof Array))
			{
				return badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result);
				}
				array[i] = result.value;
			}
			return ok(_elm_lang$core$Native_Array.fromJSArray(array));

		case 'maybe':
			var result = runHelp(decoder.decoder, value);
			return (result.tag === 'ok')
				? ok(_elm_lang$core$Maybe$Just(result.value))
				: ok(_elm_lang$core$Maybe$Nothing);

		case 'field':
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = runHelp(decoder.decoder, value[field]);
			return (result.tag === 'ok') ? result : badField(field, result);

		case 'index':
			var index = decoder.index;
			if (!(value instanceof Array))
			{
				return badPrimitive('an array', value);
			}
			if (index >= value.length)
			{
				return badPrimitive('a longer array. Need index ' + index + ' but there are only ' + value.length + ' entries', value);
			}

			var result = runHelp(decoder.decoder, value[index]);
			return (result.tag === 'ok') ? result : badIndex(index, result);

		case 'key-value':
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return badPrimitive('an object', value);
			}

			var keyValuePairs = _elm_lang$core$Native_List.Nil;
			for (var key in value)
			{
				var result = runHelp(decoder.decoder, value[key]);
				if (result.tag !== 'ok')
				{
					return badField(key, result);
				}
				var pair = _elm_lang$core$Native_Utils.Tuple2(key, result.value);
				keyValuePairs = _elm_lang$core$Native_List.Cons(pair, keyValuePairs);
			}
			return ok(keyValuePairs);

		case 'map-many':
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = runHelp(decoders[i], value);
				if (result.tag !== 'ok')
				{
					return result;
				}
				answer = answer(result.value);
			}
			return ok(answer);

		case 'andThen':
			var result = runHelp(decoder.decoder, value);
			return (result.tag !== 'ok')
				? result
				: runHelp(decoder.callback(result.value), value);

		case 'oneOf':
			var errors = [];
			var temp = decoder.decoders;
			while (temp.ctor !== '[]')
			{
				var result = runHelp(temp._0, value);

				if (result.tag === 'ok')
				{
					return result;
				}

				errors.push(result);

				temp = temp._1;
			}
			return badOneOf(errors);

		case 'fail':
			return bad(decoder.msg);

		case 'succeed':
			return ok(decoder.msg);
	}
}


// EQUALITY

function equality(a, b)
{
	if (a === b)
	{
		return true;
	}

	if (a.tag !== b.tag)
	{
		return false;
	}

	switch (a.tag)
	{
		case 'succeed':
		case 'fail':
			return a.msg === b.msg;

		case 'bool':
		case 'int':
		case 'float':
		case 'string':
		case 'value':
			return true;

		case 'null':
			return a.value === b.value;

		case 'list':
		case 'array':
		case 'maybe':
		case 'key-value':
			return equality(a.decoder, b.decoder);

		case 'field':
			return a.field === b.field && equality(a.decoder, b.decoder);

		case 'index':
			return a.index === b.index && equality(a.decoder, b.decoder);

		case 'map-many':
			if (a.func !== b.func)
			{
				return false;
			}
			return listEquality(a.decoders, b.decoders);

		case 'andThen':
			return a.callback === b.callback && equality(a.decoder, b.decoder);

		case 'oneOf':
			return listEquality(a.decoders, b.decoders);
	}
}

function listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

function encode(indentLevel, value)
{
	return JSON.stringify(value, null, indentLevel);
}

function identity(value)
{
	return value;
}

function encodeObject(keyValuePairs)
{
	var obj = {};
	while (keyValuePairs.ctor !== '[]')
	{
		var pair = keyValuePairs._0;
		obj[pair._0] = pair._1;
		keyValuePairs = keyValuePairs._1;
	}
	return obj;
}

return {
	encode: F2(encode),
	runOnString: F2(runOnString),
	run: F2(run),

	decodeNull: decodeNull,
	decodePrimitive: decodePrimitive,
	decodeContainer: F2(decodeContainer),

	decodeField: F2(decodeField),
	decodeIndex: F2(decodeIndex),

	map1: F2(map1),
	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	map6: F7(map6),
	map7: F8(map7),
	map8: F9(map8),
	decodeKeyValuePairs: decodeKeyValuePairs,

	andThen: F2(andThen),
	fail: fail,
	succeed: succeed,
	oneOf: oneOf,

	identity: identity,
	encodeNull: null,
	encodeArray: _elm_lang$core$Native_Array.toJSArray,
	encodeList: _elm_lang$core$Native_List.toArray,
	encodeObject: encodeObject,

	equality: equality
};

}();

var _elm_lang$core$Json_Encode$list = _elm_lang$core$Native_Json.encodeList;
var _elm_lang$core$Json_Encode$array = _elm_lang$core$Native_Json.encodeArray;
var _elm_lang$core$Json_Encode$object = _elm_lang$core$Native_Json.encodeObject;
var _elm_lang$core$Json_Encode$null = _elm_lang$core$Native_Json.encodeNull;
var _elm_lang$core$Json_Encode$bool = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$float = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$int = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$string = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$encode = _elm_lang$core$Native_Json.encode;
var _elm_lang$core$Json_Encode$Value = {ctor: 'Value'};

var _elm_lang$core$Json_Decode$null = _elm_lang$core$Native_Json.decodeNull;
var _elm_lang$core$Json_Decode$value = _elm_lang$core$Native_Json.decodePrimitive('value');
var _elm_lang$core$Json_Decode$andThen = _elm_lang$core$Native_Json.andThen;
var _elm_lang$core$Json_Decode$fail = _elm_lang$core$Native_Json.fail;
var _elm_lang$core$Json_Decode$succeed = _elm_lang$core$Native_Json.succeed;
var _elm_lang$core$Json_Decode$lazy = function (thunk) {
	return A2(
		_elm_lang$core$Json_Decode$andThen,
		thunk,
		_elm_lang$core$Json_Decode$succeed(
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Json_Decode$decodeValue = _elm_lang$core$Native_Json.run;
var _elm_lang$core$Json_Decode$decodeString = _elm_lang$core$Native_Json.runOnString;
var _elm_lang$core$Json_Decode$map8 = _elm_lang$core$Native_Json.map8;
var _elm_lang$core$Json_Decode$map7 = _elm_lang$core$Native_Json.map7;
var _elm_lang$core$Json_Decode$map6 = _elm_lang$core$Native_Json.map6;
var _elm_lang$core$Json_Decode$map5 = _elm_lang$core$Native_Json.map5;
var _elm_lang$core$Json_Decode$map4 = _elm_lang$core$Native_Json.map4;
var _elm_lang$core$Json_Decode$map3 = _elm_lang$core$Native_Json.map3;
var _elm_lang$core$Json_Decode$map2 = _elm_lang$core$Native_Json.map2;
var _elm_lang$core$Json_Decode$map = _elm_lang$core$Native_Json.map1;
var _elm_lang$core$Json_Decode$oneOf = _elm_lang$core$Native_Json.oneOf;
var _elm_lang$core$Json_Decode$maybe = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'maybe', decoder);
};
var _elm_lang$core$Json_Decode$index = _elm_lang$core$Native_Json.decodeIndex;
var _elm_lang$core$Json_Decode$field = _elm_lang$core$Native_Json.decodeField;
var _elm_lang$core$Json_Decode$at = F2(
	function (fields, decoder) {
		return A3(_elm_lang$core$List$foldr, _elm_lang$core$Json_Decode$field, decoder, fields);
	});
var _elm_lang$core$Json_Decode$keyValuePairs = _elm_lang$core$Native_Json.decodeKeyValuePairs;
var _elm_lang$core$Json_Decode$dict = function (decoder) {
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$Dict$fromList,
		_elm_lang$core$Json_Decode$keyValuePairs(decoder));
};
var _elm_lang$core$Json_Decode$array = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'array', decoder);
};
var _elm_lang$core$Json_Decode$list = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'list', decoder);
};
var _elm_lang$core$Json_Decode$nullable = function (decoder) {
	return _elm_lang$core$Json_Decode$oneOf(
		{
			ctor: '::',
			_0: _elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, decoder),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$core$Json_Decode$float = _elm_lang$core$Native_Json.decodePrimitive('float');
var _elm_lang$core$Json_Decode$int = _elm_lang$core$Native_Json.decodePrimitive('int');
var _elm_lang$core$Json_Decode$bool = _elm_lang$core$Native_Json.decodePrimitive('bool');
var _elm_lang$core$Json_Decode$string = _elm_lang$core$Native_Json.decodePrimitive('string');
var _elm_lang$core$Json_Decode$Decoder = {ctor: 'Decoder'};

//import Maybe, Native.List //

var _elm_lang$core$Native_Regex = function() {

function escape(str)
{
	return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
}
function caseInsensitive(re)
{
	return new RegExp(re.source, 'gi');
}
function regex(raw)
{
	return new RegExp(raw, 'g');
}

function contains(re, string)
{
	return string.match(re) !== null;
}

function find(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex === re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		out.push({
			match: result[0],
			submatches: _elm_lang$core$Native_List.fromArray(subs),
			index: result.index,
			number: number
		});
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

function replace(n, re, replacer, string)
{
	n = n.ctor === 'All' ? Infinity : n._0;
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
			submatches[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		return replacer({
			match: match,
			submatches: _elm_lang$core$Native_List.fromArray(submatches),
			index: arguments[arguments.length - 2],
			number: count
		});
	}
	return string.replace(re, jsReplacer);
}

function split(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	if (n === Infinity)
	{
		return _elm_lang$core$Native_List.fromArray(str.split(re));
	}
	var string = str;
	var result;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		if (!(result = re.exec(string))) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

return {
	regex: regex,
	caseInsensitive: caseInsensitive,
	escape: escape,

	contains: F2(contains),
	find: F3(find),
	replace: F4(replace),
	split: F3(split)
};

}();

var _elm_lang$core$Tuple$mapSecond = F2(
	function (func, _p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: _p1._0,
			_1: func(_p1._1)
		};
	});
var _elm_lang$core$Tuple$mapFirst = F2(
	function (func, _p2) {
		var _p3 = _p2;
		return {
			ctor: '_Tuple2',
			_0: func(_p3._0),
			_1: _p3._1
		};
	});
var _elm_lang$core$Tuple$second = function (_p4) {
	var _p5 = _p4;
	return _p5._1;
};
var _elm_lang$core$Tuple$first = function (_p6) {
	var _p7 = _p6;
	return _p7._0;
};

var _elm_lang$core$Regex$split = _elm_lang$core$Native_Regex.split;
var _elm_lang$core$Regex$replace = _elm_lang$core$Native_Regex.replace;
var _elm_lang$core$Regex$find = _elm_lang$core$Native_Regex.find;
var _elm_lang$core$Regex$contains = _elm_lang$core$Native_Regex.contains;
var _elm_lang$core$Regex$caseInsensitive = _elm_lang$core$Native_Regex.caseInsensitive;
var _elm_lang$core$Regex$regex = _elm_lang$core$Native_Regex.regex;
var _elm_lang$core$Regex$escape = _elm_lang$core$Native_Regex.escape;
var _elm_lang$core$Regex$Match = F4(
	function (a, b, c, d) {
		return {match: a, submatches: b, index: c, number: d};
	});
var _elm_lang$core$Regex$Regex = {ctor: 'Regex'};
var _elm_lang$core$Regex$AtMost = function (a) {
	return {ctor: 'AtMost', _0: a};
};
var _elm_lang$core$Regex$All = {ctor: 'All'};

var _elm_lang$core$Set$foldr = F3(
	function (f, b, _p0) {
		var _p1 = _p0;
		return A3(
			_elm_lang$core$Dict$foldr,
			F3(
				function (k, _p2, b) {
					return A2(f, k, b);
				}),
			b,
			_p1._0);
	});
var _elm_lang$core$Set$foldl = F3(
	function (f, b, _p3) {
		var _p4 = _p3;
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, _p5, b) {
					return A2(f, k, b);
				}),
			b,
			_p4._0);
	});
var _elm_lang$core$Set$toList = function (_p6) {
	var _p7 = _p6;
	return _elm_lang$core$Dict$keys(_p7._0);
};
var _elm_lang$core$Set$size = function (_p8) {
	var _p9 = _p8;
	return _elm_lang$core$Dict$size(_p9._0);
};
var _elm_lang$core$Set$member = F2(
	function (k, _p10) {
		var _p11 = _p10;
		return A2(_elm_lang$core$Dict$member, k, _p11._0);
	});
var _elm_lang$core$Set$isEmpty = function (_p12) {
	var _p13 = _p12;
	return _elm_lang$core$Dict$isEmpty(_p13._0);
};
var _elm_lang$core$Set$Set_elm_builtin = function (a) {
	return {ctor: 'Set_elm_builtin', _0: a};
};
var _elm_lang$core$Set$empty = _elm_lang$core$Set$Set_elm_builtin(_elm_lang$core$Dict$empty);
var _elm_lang$core$Set$singleton = function (k) {
	return _elm_lang$core$Set$Set_elm_builtin(
		A2(
			_elm_lang$core$Dict$singleton,
			k,
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Set$insert = F2(
	function (k, _p14) {
		var _p15 = _p14;
		return _elm_lang$core$Set$Set_elm_builtin(
			A3(
				_elm_lang$core$Dict$insert,
				k,
				{ctor: '_Tuple0'},
				_p15._0));
	});
var _elm_lang$core$Set$fromList = function (xs) {
	return A3(_elm_lang$core$List$foldl, _elm_lang$core$Set$insert, _elm_lang$core$Set$empty, xs);
};
var _elm_lang$core$Set$map = F2(
	function (f, s) {
		return _elm_lang$core$Set$fromList(
			A2(
				_elm_lang$core$List$map,
				f,
				_elm_lang$core$Set$toList(s)));
	});
var _elm_lang$core$Set$remove = F2(
	function (k, _p16) {
		var _p17 = _p16;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$remove, k, _p17._0));
	});
var _elm_lang$core$Set$union = F2(
	function (_p19, _p18) {
		var _p20 = _p19;
		var _p21 = _p18;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$union, _p20._0, _p21._0));
	});
var _elm_lang$core$Set$intersect = F2(
	function (_p23, _p22) {
		var _p24 = _p23;
		var _p25 = _p22;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$intersect, _p24._0, _p25._0));
	});
var _elm_lang$core$Set$diff = F2(
	function (_p27, _p26) {
		var _p28 = _p27;
		var _p29 = _p26;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(_elm_lang$core$Dict$diff, _p28._0, _p29._0));
	});
var _elm_lang$core$Set$filter = F2(
	function (p, _p30) {
		var _p31 = _p30;
		return _elm_lang$core$Set$Set_elm_builtin(
			A2(
				_elm_lang$core$Dict$filter,
				F2(
					function (k, _p32) {
						return p(k);
					}),
				_p31._0));
	});
var _elm_lang$core$Set$partition = F2(
	function (p, _p33) {
		var _p34 = _p33;
		var _p35 = A2(
			_elm_lang$core$Dict$partition,
			F2(
				function (k, _p36) {
					return p(k);
				}),
			_p34._0);
		var p1 = _p35._0;
		var p2 = _p35._1;
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Set$Set_elm_builtin(p1),
			_1: _elm_lang$core$Set$Set_elm_builtin(p2)
		};
	});

var _elm_lang$virtual_dom$VirtualDom_Debug$wrap;
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags;

var _elm_lang$virtual_dom$Native_VirtualDom = function() {

var STYLE_KEY = 'STYLE';
var EVENT_KEY = 'EVENT';
var ATTR_KEY = 'ATTR';
var ATTR_NS_KEY = 'ATTR_NS';

var localDoc = typeof document !== 'undefined' ? document : {};


////////////  VIRTUAL DOM NODES  ////////////


function text(string)
{
	return {
		type: 'text',
		text: string
	};
}


function node(tag)
{
	return F2(function(factList, kidList) {
		return nodeHelp(tag, factList, kidList);
	});
}


function nodeHelp(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function keyedNode(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid._1.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'keyed-node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function custom(factList, model, impl)
{
	var facts = organizeFacts(factList).facts;

	return {
		type: 'custom',
		facts: facts,
		model: model,
		impl: impl
	};
}


function map(tagger, node)
{
	return {
		type: 'tagger',
		tagger: tagger,
		node: node,
		descendantsCount: 1 + (node.descendantsCount || 0)
	};
}


function thunk(func, args, thunk)
{
	return {
		type: 'thunk',
		func: func,
		args: args,
		thunk: thunk,
		node: undefined
	};
}

function lazy(fn, a)
{
	return thunk(fn, [a], function() {
		return fn(a);
	});
}

function lazy2(fn, a, b)
{
	return thunk(fn, [a,b], function() {
		return A2(fn, a, b);
	});
}

function lazy3(fn, a, b, c)
{
	return thunk(fn, [a,b,c], function() {
		return A3(fn, a, b, c);
	});
}



// FACTS


function organizeFacts(factList)
{
	var namespace, facts = {};

	while (factList.ctor !== '[]')
	{
		var entry = factList._0;
		var key = entry.key;

		if (key === ATTR_KEY || key === ATTR_NS_KEY || key === EVENT_KEY)
		{
			var subFacts = facts[key] || {};
			subFacts[entry.realKey] = entry.value;
			facts[key] = subFacts;
		}
		else if (key === STYLE_KEY)
		{
			var styles = facts[key] || {};
			var styleList = entry.value;
			while (styleList.ctor !== '[]')
			{
				var style = styleList._0;
				styles[style._0] = style._1;
				styleList = styleList._1;
			}
			facts[key] = styles;
		}
		else if (key === 'namespace')
		{
			namespace = entry.value;
		}
		else if (key === 'className')
		{
			var classes = facts[key];
			facts[key] = typeof classes === 'undefined'
				? entry.value
				: classes + ' ' + entry.value;
		}
 		else
		{
			facts[key] = entry.value;
		}
		factList = factList._1;
	}

	return {
		facts: facts,
		namespace: namespace
	};
}



////////////  PROPERTIES AND ATTRIBUTES  ////////////


function style(value)
{
	return {
		key: STYLE_KEY,
		value: value
	};
}


function property(key, value)
{
	return {
		key: key,
		value: value
	};
}


function attribute(key, value)
{
	return {
		key: ATTR_KEY,
		realKey: key,
		value: value
	};
}


function attributeNS(namespace, key, value)
{
	return {
		key: ATTR_NS_KEY,
		realKey: key,
		value: {
			value: value,
			namespace: namespace
		}
	};
}


function on(name, options, decoder)
{
	return {
		key: EVENT_KEY,
		realKey: name,
		value: {
			options: options,
			decoder: decoder
		}
	};
}


function equalEvents(a, b)
{
	if (!a.options === b.options)
	{
		if (a.stopPropagation !== b.stopPropagation || a.preventDefault !== b.preventDefault)
		{
			return false;
		}
	}
	return _elm_lang$core$Native_Json.equality(a.decoder, b.decoder);
}


function mapProperty(func, property)
{
	if (property.key !== EVENT_KEY)
	{
		return property;
	}
	return on(
		property.realKey,
		property.value.options,
		A2(_elm_lang$core$Json_Decode$map, func, property.value.decoder)
	);
}


////////////  RENDER  ////////////


function render(vNode, eventNode)
{
	switch (vNode.type)
	{
		case 'thunk':
			if (!vNode.node)
			{
				vNode.node = vNode.thunk();
			}
			return render(vNode.node, eventNode);

		case 'tagger':
			var subNode = vNode.node;
			var tagger = vNode.tagger;

			while (subNode.type === 'tagger')
			{
				typeof tagger !== 'object'
					? tagger = [tagger, subNode.tagger]
					: tagger.push(subNode.tagger);

				subNode = subNode.node;
			}

			var subEventRoot = { tagger: tagger, parent: eventNode };
			var domNode = render(subNode, subEventRoot);
			domNode.elm_event_node_ref = subEventRoot;
			return domNode;

		case 'text':
			return localDoc.createTextNode(vNode.text);

		case 'node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i], eventNode));
			}

			return domNode;

		case 'keyed-node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i]._1, eventNode));
			}

			return domNode;

		case 'custom':
			var domNode = vNode.impl.render(vNode.model);
			applyFacts(domNode, eventNode, vNode.facts);
			return domNode;
	}
}



////////////  APPLY FACTS  ////////////


function applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		switch (key)
		{
			case STYLE_KEY:
				applyStyles(domNode, value);
				break;

			case EVENT_KEY:
				applyEvents(domNode, eventNode, value);
				break;

			case ATTR_KEY:
				applyAttrs(domNode, value);
				break;

			case ATTR_NS_KEY:
				applyAttrsNS(domNode, value);
				break;

			case 'value':
				if (domNode[key] !== value)
				{
					domNode[key] = value;
				}
				break;

			default:
				domNode[key] = value;
				break;
		}
	}
}

function applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}

function applyEvents(domNode, eventNode, events)
{
	var allHandlers = domNode.elm_handlers || {};

	for (var key in events)
	{
		var handler = allHandlers[key];
		var value = events[key];

		if (typeof value === 'undefined')
		{
			domNode.removeEventListener(key, handler);
			allHandlers[key] = undefined;
		}
		else if (typeof handler === 'undefined')
		{
			var handler = makeEventHandler(eventNode, value);
			domNode.addEventListener(key, handler);
			allHandlers[key] = handler;
		}
		else
		{
			handler.info = value;
		}
	}

	domNode.elm_handlers = allHandlers;
}

function makeEventHandler(eventNode, info)
{
	function eventHandler(event)
	{
		var info = eventHandler.info;

		var value = A2(_elm_lang$core$Native_Json.run, info.decoder, event);

		if (value.ctor === 'Ok')
		{
			var options = info.options;
			if (options.stopPropagation)
			{
				event.stopPropagation();
			}
			if (options.preventDefault)
			{
				event.preventDefault();
			}

			var message = value._0;

			var currentEventNode = eventNode;
			while (currentEventNode)
			{
				var tagger = currentEventNode.tagger;
				if (typeof tagger === 'function')
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
				currentEventNode = currentEventNode.parent;
			}
		}
	};

	eventHandler.info = info;

	return eventHandler;
}

function applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		if (typeof value === 'undefined')
		{
			domNode.removeAttribute(key);
		}
		else
		{
			domNode.setAttribute(key, value);
		}
	}
}

function applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.namespace;
		var value = pair.value;

		if (typeof value === 'undefined')
		{
			domNode.removeAttributeNS(namespace, key);
		}
		else
		{
			domNode.setAttributeNS(namespace, key, value);
		}
	}
}



////////////  DIFF  ////////////


function diff(a, b)
{
	var patches = [];
	diffHelp(a, b, patches, 0);
	return patches;
}


function makePatch(type, index, data)
{
	return {
		index: index,
		type: type,
		data: data,
		domNode: undefined,
		eventNode: undefined
	};
}


function diffHelp(a, b, patches, index)
{
	if (a === b)
	{
		return;
	}

	var aType = a.type;
	var bType = b.type;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (aType !== bType)
	{
		patches.push(makePatch('p-redraw', index, b));
		return;
	}

	// Now we know that both nodes are the same type.
	switch (bType)
	{
		case 'thunk':
			var aArgs = a.args;
			var bArgs = b.args;
			var i = aArgs.length;
			var same = a.func === b.func && i === bArgs.length;
			while (same && i--)
			{
				same = aArgs[i] === bArgs[i];
			}
			if (same)
			{
				b.node = a.node;
				return;
			}
			b.node = b.thunk();
			var subPatches = [];
			diffHelp(a.node, b.node, subPatches, 0);
			if (subPatches.length > 0)
			{
				patches.push(makePatch('p-thunk', index, subPatches));
			}
			return;

		case 'tagger':
			// gather nested taggers
			var aTaggers = a.tagger;
			var bTaggers = b.tagger;
			var nesting = false;

			var aSubNode = a.node;
			while (aSubNode.type === 'tagger')
			{
				nesting = true;

				typeof aTaggers !== 'object'
					? aTaggers = [aTaggers, aSubNode.tagger]
					: aTaggers.push(aSubNode.tagger);

				aSubNode = aSubNode.node;
			}

			var bSubNode = b.node;
			while (bSubNode.type === 'tagger')
			{
				nesting = true;

				typeof bTaggers !== 'object'
					? bTaggers = [bTaggers, bSubNode.tagger]
					: bTaggers.push(bSubNode.tagger);

				bSubNode = bSubNode.node;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && aTaggers.length !== bTaggers.length)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !pairwiseRefEqual(aTaggers, bTaggers) : aTaggers !== bTaggers)
			{
				patches.push(makePatch('p-tagger', index, bTaggers));
			}

			// diff everything below the taggers
			diffHelp(aSubNode, bSubNode, patches, index + 1);
			return;

		case 'text':
			if (a.text !== b.text)
			{
				patches.push(makePatch('p-text', index, b.text));
				return;
			}

			return;

		case 'node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffChildren(a, b, patches, index);
			return;

		case 'keyed-node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffKeyedChildren(a, b, patches, index);
			return;

		case 'custom':
			if (a.impl !== b.impl)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);
			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			var patch = b.impl.diff(a,b);
			if (patch)
			{
				patches.push(makePatch('p-custom', index, patch));
				return;
			}

			return;
	}
}


// assumes the incoming arrays are the same length
function pairwiseRefEqual(as, bs)
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


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function diffFacts(a, b, category)
{
	var diff;

	// look for changes and removals
	for (var aKey in a)
	{
		if (aKey === STYLE_KEY || aKey === EVENT_KEY || aKey === ATTR_KEY || aKey === ATTR_NS_KEY)
		{
			var subDiff = diffFacts(a[aKey], b[aKey] || {}, aKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[aKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(aKey in b))
		{
			diff = diff || {};
			diff[aKey] =
				(typeof category === 'undefined')
					? (typeof a[aKey] === 'string' ? '' : null)
					:
				(category === STYLE_KEY)
					? ''
					:
				(category === EVENT_KEY || category === ATTR_KEY)
					? undefined
					:
				{ namespace: a[aKey].namespace, value: undefined };

			continue;
		}

		var aValue = a[aKey];
		var bValue = b[aKey];

		// reference equal, so don't worry about it
		if (aValue === bValue && aKey !== 'value'
			|| category === EVENT_KEY && equalEvents(aValue, bValue))
		{
			continue;
		}

		diff = diff || {};
		diff[aKey] = bValue;
	}

	// add new stuff
	for (var bKey in b)
	{
		if (!(bKey in a))
		{
			diff = diff || {};
			diff[bKey] = b[bKey];
		}
	}

	return diff;
}


function diffChildren(aParent, bParent, patches, rootIndex)
{
	var aChildren = aParent.children;
	var bChildren = bParent.children;

	var aLen = aChildren.length;
	var bLen = bChildren.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (aLen > bLen)
	{
		patches.push(makePatch('p-remove-last', rootIndex, aLen - bLen));
	}
	else if (aLen < bLen)
	{
		patches.push(makePatch('p-append', rootIndex, bChildren.slice(aLen)));
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	var index = rootIndex;
	var minLen = aLen < bLen ? aLen : bLen;
	for (var i = 0; i < minLen; i++)
	{
		index++;
		var aChild = aChildren[i];
		diffHelp(aChild, bChildren[i], patches, index);
		index += aChild.descendantsCount || 0;
	}
}



////////////  KEYED DIFF  ////////////


function diffKeyedChildren(aParent, bParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var aChildren = aParent.children;
	var bChildren = bParent.children;
	var aLen = aChildren.length;
	var bLen = bChildren.length;
	var aIndex = 0;
	var bIndex = 0;

	var index = rootIndex;

	while (aIndex < aLen && bIndex < bLen)
	{
		var a = aChildren[aIndex];
		var b = bChildren[bIndex];

		var aKey = a._0;
		var bKey = b._0;
		var aNode = a._1;
		var bNode = b._1;

		// check if keys match

		if (aKey === bKey)
		{
			index++;
			diffHelp(aNode, bNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex++;
			bIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var aLookAhead = aIndex + 1 < aLen;
		var bLookAhead = bIndex + 1 < bLen;

		if (aLookAhead)
		{
			var aNext = aChildren[aIndex + 1];
			var aNextKey = aNext._0;
			var aNextNode = aNext._1;
			var oldMatch = bKey === aNextKey;
		}

		if (bLookAhead)
		{
			var bNext = bChildren[bIndex + 1];
			var bNextKey = bNext._0;
			var bNextNode = bNext._1;
			var newMatch = aKey === bNextKey;
		}


		// swap a and b
		if (aLookAhead && bLookAhead && newMatch && oldMatch)
		{
			index++;
			diffHelp(aNode, bNextNode, localPatches, index);
			insertNode(changes, localPatches, aKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			removeNode(changes, localPatches, aKey, aNextNode, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		// insert b
		if (bLookAhead && newMatch)
		{
			index++;
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			diffHelp(aNode, bNextNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex += 1;
			bIndex += 2;
			continue;
		}

		// remove a
		if (aLookAhead && oldMatch)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 1;
			continue;
		}

		// remove a, insert b
		if (aLookAhead && bLookAhead && aNextKey === bNextKey)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNextNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (aIndex < aLen)
	{
		index++;
		var a = aChildren[aIndex];
		var aNode = a._1;
		removeNode(changes, localPatches, a._0, aNode, index);
		index += aNode.descendantsCount || 0;
		aIndex++;
	}

	var endInserts;
	while (bIndex < bLen)
	{
		endInserts = endInserts || [];
		var b = bChildren[bIndex];
		insertNode(changes, localPatches, b._0, b._1, undefined, endInserts);
		bIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || typeof endInserts !== 'undefined')
	{
		patches.push(makePatch('p-reorder', rootIndex, {
			patches: localPatches,
			inserts: inserts,
			endInserts: endInserts
		}));
	}
}



////////////  CHANGES FROM KEYED DIFF  ////////////


var POSTFIX = '_elmW6BL';


function insertNode(changes, localPatches, key, vnode, bIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		entry = {
			tag: 'insert',
			vnode: vnode,
			index: bIndex,
			data: undefined
		};

		inserts.push({ index: bIndex, entry: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.tag === 'remove')
	{
		inserts.push({ index: bIndex, entry: entry });

		entry.tag = 'move';
		var subPatches = [];
		diffHelp(entry.vnode, vnode, subPatches, entry.index);
		entry.index = bIndex;
		entry.data.data = {
			patches: subPatches,
			entry: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	insertNode(changes, localPatches, key + POSTFIX, vnode, bIndex, inserts);
}


function removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		var patch = makePatch('p-remove', index, undefined);
		localPatches.push(patch);

		changes[key] = {
			tag: 'remove',
			vnode: vnode,
			index: index,
			data: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.tag === 'insert')
	{
		entry.tag = 'move';
		var subPatches = [];
		diffHelp(vnode, entry.vnode, subPatches, index);

		var patch = makePatch('p-remove', index, {
			patches: subPatches,
			entry: entry
		});
		localPatches.push(patch);

		return;
	}

	// this key has already been removed or moved, a duplicate!
	removeNode(changes, localPatches, key + POSTFIX, vnode, index);
}



////////////  ADD DOM NODES  ////////////
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function addDomNodes(domNode, vNode, patches, eventNode)
{
	addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.descendantsCount, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.index;

	while (index === low)
	{
		var patchType = patch.type;

		if (patchType === 'p-thunk')
		{
			addDomNodes(domNode, vNode.node, patch.data, eventNode);
		}
		else if (patchType === 'p-reorder')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var subPatches = patch.data.patches;
			if (subPatches.length > 0)
			{
				addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 'p-remove')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var data = patch.data;
			if (typeof data !== 'undefined')
			{
				data.entry.data = domNode;
				var subPatches = data.patches;
				if (subPatches.length > 0)
				{
					addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.index) > high)
		{
			return i;
		}
	}

	switch (vNode.type)
	{
		case 'tagger':
			var subNode = vNode.node;

			while (subNode.type === "tagger")
			{
				subNode = subNode.node;
			}

			return addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);

		case 'node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j];
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'keyed-node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j]._1;
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'text':
		case 'thunk':
			throw new Error('should never traverse `text` or `thunk` nodes like this');
	}
}



////////////  APPLY PATCHES  ////////////


function applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return applyPatchesHelp(rootDomNode, patches);
}

function applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.domNode
		var newNode = applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function applyPatch(domNode, patch)
{
	switch (patch.type)
	{
		case 'p-redraw':
			return applyPatchRedraw(domNode, patch.data, patch.eventNode);

		case 'p-facts':
			applyFacts(domNode, patch.eventNode, patch.data);
			return domNode;

		case 'p-text':
			domNode.replaceData(0, domNode.length, patch.data);
			return domNode;

		case 'p-thunk':
			return applyPatchesHelp(domNode, patch.data);

		case 'p-tagger':
			if (typeof domNode.elm_event_node_ref !== 'undefined')
			{
				domNode.elm_event_node_ref.tagger = patch.data;
			}
			else
			{
				domNode.elm_event_node_ref = { tagger: patch.data, parent: patch.eventNode };
			}
			return domNode;

		case 'p-remove-last':
			var i = patch.data;
			while (i--)
			{
				domNode.removeChild(domNode.lastChild);
			}
			return domNode;

		case 'p-append':
			var newNodes = patch.data;
			for (var i = 0; i < newNodes.length; i++)
			{
				domNode.appendChild(render(newNodes[i], patch.eventNode));
			}
			return domNode;

		case 'p-remove':
			var data = patch.data;
			if (typeof data === 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.entry;
			if (typeof entry.index !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.data = applyPatchesHelp(domNode, data.patches);
			return domNode;

		case 'p-reorder':
			return applyPatchReorder(domNode, patch);

		case 'p-custom':
			var impl = patch.data;
			return impl.applyPatch(domNode, impl.data);

		default:
			throw new Error('Ran into an unknown patch!');
	}
}


function applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = render(vNode, eventNode);

	if (typeof newNode.elm_event_node_ref === 'undefined')
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function applyPatchReorder(domNode, patch)
{
	var data = patch.data;

	// remove end inserts
	var frag = applyPatchReorderEndInsertsHelp(data.endInserts, patch);

	// removals
	domNode = applyPatchesHelp(domNode, data.patches);

	// inserts
	var inserts = data.inserts;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.entry;
		var node = entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode);
		domNode.insertBefore(node, domNode.childNodes[insert.index]);
	}

	// add end inserts
	if (typeof frag !== 'undefined')
	{
		domNode.appendChild(frag);
	}

	return domNode;
}


function applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (typeof endInserts === 'undefined')
	{
		return;
	}

	var frag = localDoc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.entry;
		frag.appendChild(entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode)
		);
	}
	return frag;
}


// PROGRAMS

var program = makeProgram(checkNoFlags);
var programWithFlags = makeProgram(checkYesFlags);

function makeProgram(flagChecker)
{
	return F2(function(debugWrap, impl)
	{
		return function(flagDecoder)
		{
			return function(object, moduleName, debugMetadata)
			{
				var checker = flagChecker(flagDecoder, moduleName);
				if (typeof debugMetadata === 'undefined')
				{
					normalSetup(impl, object, moduleName, checker);
				}
				else
				{
					debugSetup(A2(debugWrap, debugMetadata, impl), object, moduleName, checker);
				}
			};
		};
	});
}

function staticProgram(vNode)
{
	var nothing = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		_elm_lang$core$Platform_Cmd$none
	);
	return A2(program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, {
		init: nothing,
		view: function() { return vNode; },
		update: F2(function() { return nothing; }),
		subscriptions: function() { return _elm_lang$core$Platform_Sub$none; }
	})();
}


// FLAG CHECKERS

function checkNoFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flags === 'undefined')
		{
			return init;
		}

		var errorMessage =
			'The `' + moduleName + '` module does not need flags.\n'
			+ 'Initialize it with no arguments and you should be all set!';

		crash(errorMessage, domNode);
	};
}

function checkYesFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flagDecoder === 'undefined')
		{
			var errorMessage =
				'Are you trying to sneak a Never value into Elm? Trickster!\n'
				+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
				+ 'Use `program` instead if you do not want flags.'

			crash(errorMessage, domNode);
		}

		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Ok')
		{
			return init(result._0);
		}

		var errorMessage =
			'Trying to initialize the `' + moduleName + '` module with an unexpected flag.\n'
			+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
			+ result._0;

		crash(errorMessage, domNode);
	};
}

function crash(errorMessage, domNode)
{
	if (domNode)
	{
		domNode.innerHTML =
			'<div style="padding-left:1em;">'
			+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
			+ '<pre style="padding-left:1em;">' + errorMessage + '</pre>'
			+ '</div>';
	}

	throw new Error(errorMessage);
}


//  NORMAL SETUP

function normalSetup(impl, object, moduleName, flagChecker)
{
	object['embed'] = function embed(node, flags)
	{
		while (node.lastChild)
		{
			node.removeChild(node.lastChild);
		}

		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update,
			impl.subscriptions,
			normalRenderer(node, impl.view)
		);
	};

	object['fullscreen'] = function fullscreen(flags)
	{
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update,
			impl.subscriptions,
			normalRenderer(document.body, impl.view)
		);
	};
}

function normalRenderer(parentNode, view)
{
	return function(tagger, initialModel)
	{
		var eventNode = { tagger: tagger, parent: undefined };
		var initialVirtualNode = view(initialModel);
		var domNode = render(initialVirtualNode, eventNode);
		parentNode.appendChild(domNode);
		return makeStepper(domNode, view, initialVirtualNode, eventNode);
	};
}


// STEPPER

var rAF =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { callback(); };

function makeStepper(domNode, view, initialVirtualNode, eventNode)
{
	var state = 'NO_REQUEST';
	var currNode = initialVirtualNode;
	var nextModel;

	function updateIfNeeded()
	{
		switch (state)
		{
			case 'NO_REQUEST':
				throw new Error(
					'Unexpected draw callback.\n' +
					'Please report this to <https://github.com/elm-lang/virtual-dom/issues>.'
				);

			case 'PENDING_REQUEST':
				rAF(updateIfNeeded);
				state = 'EXTRA_REQUEST';

				var nextNode = view(nextModel);
				var patches = diff(currNode, nextNode);
				domNode = applyPatches(domNode, currNode, patches, eventNode);
				currNode = nextNode;

				return;

			case 'EXTRA_REQUEST':
				state = 'NO_REQUEST';
				return;
		}
	}

	return function stepper(model)
	{
		if (state === 'NO_REQUEST')
		{
			rAF(updateIfNeeded);
		}
		state = 'PENDING_REQUEST';
		nextModel = model;
	};
}


// DEBUG SETUP

function debugSetup(impl, object, moduleName, flagChecker)
{
	object['fullscreen'] = function fullscreen(flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, document.body, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};

	object['embed'] = function fullscreen(node, flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, node, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};
}

function scrollTask(popoutRef)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var doc = popoutRef.doc;
		if (doc)
		{
			var msgs = doc.getElementsByClassName('debugger-sidebar-messages')[0];
			if (msgs)
			{
				msgs.scrollTop = msgs.scrollHeight;
			}
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


function debugRenderer(moduleName, parentNode, popoutRef, view, viewIn, viewOut)
{
	return function(tagger, initialModel)
	{
		var appEventNode = { tagger: tagger, parent: undefined };
		var eventNode = { tagger: tagger, parent: undefined };

		// make normal stepper
		var appVirtualNode = view(initialModel);
		var appNode = render(appVirtualNode, appEventNode);
		parentNode.appendChild(appNode);
		var appStepper = makeStepper(appNode, view, appVirtualNode, appEventNode);

		// make overlay stepper
		var overVirtualNode = viewIn(initialModel)._1;
		var overNode = render(overVirtualNode, eventNode);
		parentNode.appendChild(overNode);
		var wrappedViewIn = wrapViewIn(appEventNode, overNode, viewIn);
		var overStepper = makeStepper(overNode, wrappedViewIn, overVirtualNode, eventNode);

		// make debugger stepper
		var debugStepper = makeDebugStepper(initialModel, viewOut, eventNode, parentNode, moduleName, popoutRef);

		return function stepper(model)
		{
			appStepper(model);
			overStepper(model);
			debugStepper(model);
		}
	};
}

function makeDebugStepper(initialModel, view, eventNode, parentNode, moduleName, popoutRef)
{
	var curr;
	var domNode;

	return function stepper(model)
	{
		if (!model.isDebuggerOpen)
		{
			return;
		}

		if (!popoutRef.doc)
		{
			curr = view(model);
			domNode = openDebugWindow(moduleName, popoutRef, curr, eventNode);
			return;
		}

		// switch to document of popout
		localDoc = popoutRef.doc;

		var next = view(model);
		var patches = diff(curr, next);
		domNode = applyPatches(domNode, curr, patches, eventNode);
		curr = next;

		// switch back to normal document
		localDoc = document;
	};
}

function openDebugWindow(moduleName, popoutRef, virtualNode, eventNode)
{
	var w = 900;
	var h = 360;
	var x = screen.width - w;
	var y = screen.height - h;
	var debugWindow = window.open('', '', 'width=' + w + ',height=' + h + ',left=' + x + ',top=' + y);

	// switch to window document
	localDoc = debugWindow.document;

	popoutRef.doc = localDoc;
	localDoc.title = 'Debugger - ' + moduleName;
	localDoc.body.style.margin = '0';
	localDoc.body.style.padding = '0';
	var domNode = render(virtualNode, eventNode);
	localDoc.body.appendChild(domNode);

	localDoc.addEventListener('keydown', function(event) {
		if (event.metaKey && event.which === 82)
		{
			window.location.reload();
		}
		if (event.which === 38)
		{
			eventNode.tagger({ ctor: 'Up' });
			event.preventDefault();
		}
		if (event.which === 40)
		{
			eventNode.tagger({ ctor: 'Down' });
			event.preventDefault();
		}
	});

	function close()
	{
		popoutRef.doc = undefined;
		debugWindow.close();
	}
	window.addEventListener('unload', close);
	debugWindow.addEventListener('unload', function() {
		popoutRef.doc = undefined;
		window.removeEventListener('unload', close);
		eventNode.tagger({ ctor: 'Close' });
	});

	// switch back to the normal document
	localDoc = document;

	return domNode;
}


// BLOCK EVENTS

function wrapViewIn(appEventNode, overlayNode, viewIn)
{
	var ignorer = makeIgnorer(overlayNode);
	var blocking = 'Normal';
	var overflow;

	var normalTagger = appEventNode.tagger;
	var blockTagger = function() {};

	return function(model)
	{
		var tuple = viewIn(model);
		var newBlocking = tuple._0.ctor;
		appEventNode.tagger = newBlocking === 'Normal' ? normalTagger : blockTagger;
		if (blocking !== newBlocking)
		{
			traverse('removeEventListener', ignorer, blocking);
			traverse('addEventListener', ignorer, newBlocking);

			if (blocking === 'Normal')
			{
				overflow = document.body.style.overflow;
				document.body.style.overflow = 'hidden';
			}

			if (newBlocking === 'Normal')
			{
				document.body.style.overflow = overflow;
			}

			blocking = newBlocking;
		}
		return tuple._1;
	}
}

function traverse(verbEventListener, ignorer, blocking)
{
	switch(blocking)
	{
		case 'Normal':
			return;

		case 'Pause':
			return traverseHelp(verbEventListener, ignorer, mostEvents);

		case 'Message':
			return traverseHelp(verbEventListener, ignorer, allEvents);
	}
}

function traverseHelp(verbEventListener, handler, eventNames)
{
	for (var i = 0; i < eventNames.length; i++)
	{
		document.body[verbEventListener](eventNames[i], handler, true);
	}
}

function makeIgnorer(overlayNode)
{
	return function(event)
	{
		if (event.type === 'keydown' && event.metaKey && event.which === 82)
		{
			return;
		}

		var isScroll = event.type === 'scroll' || event.type === 'wheel';

		var node = event.target;
		while (node !== null)
		{
			if (node.className === 'elm-overlay-message-details' && isScroll)
			{
				return;
			}

			if (node === overlayNode && !isScroll)
			{
				return;
			}
			node = node.parentNode;
		}

		event.stopPropagation();
		event.preventDefault();
	}
}

var mostEvents = [
	'click', 'dblclick', 'mousemove',
	'mouseup', 'mousedown', 'mouseenter', 'mouseleave',
	'touchstart', 'touchend', 'touchcancel', 'touchmove',
	'pointerdown', 'pointerup', 'pointerover', 'pointerout',
	'pointerenter', 'pointerleave', 'pointermove', 'pointercancel',
	'dragstart', 'drag', 'dragend', 'dragenter', 'dragover', 'dragleave', 'drop',
	'keyup', 'keydown', 'keypress',
	'input', 'change',
	'focus', 'blur'
];

var allEvents = mostEvents.concat('wheel', 'scroll');


return {
	node: node,
	text: text,
	custom: custom,
	map: F2(map),

	on: F3(on),
	style: style,
	property: F2(property),
	attribute: F2(attribute),
	attributeNS: F3(attributeNS),
	mapProperty: F2(mapProperty),

	lazy: F2(lazy),
	lazy2: F3(lazy2),
	lazy3: F4(lazy3),
	keyedNode: F3(keyedNode),

	program: program,
	programWithFlags: programWithFlags,
	staticProgram: staticProgram
};

}();

var _elm_lang$virtual_dom$VirtualDom$programWithFlags = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.programWithFlags, _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags, impl);
};
var _elm_lang$virtual_dom$VirtualDom$program = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, impl);
};
var _elm_lang$virtual_dom$VirtualDom$keyedNode = _elm_lang$virtual_dom$Native_VirtualDom.keyedNode;
var _elm_lang$virtual_dom$VirtualDom$lazy3 = _elm_lang$virtual_dom$Native_VirtualDom.lazy3;
var _elm_lang$virtual_dom$VirtualDom$lazy2 = _elm_lang$virtual_dom$Native_VirtualDom.lazy2;
var _elm_lang$virtual_dom$VirtualDom$lazy = _elm_lang$virtual_dom$Native_VirtualDom.lazy;
var _elm_lang$virtual_dom$VirtualDom$defaultOptions = {stopPropagation: false, preventDefault: false};
var _elm_lang$virtual_dom$VirtualDom$onWithOptions = _elm_lang$virtual_dom$Native_VirtualDom.on;
var _elm_lang$virtual_dom$VirtualDom$on = F2(
	function (eventName, decoder) {
		return A3(_elm_lang$virtual_dom$VirtualDom$onWithOptions, eventName, _elm_lang$virtual_dom$VirtualDom$defaultOptions, decoder);
	});
var _elm_lang$virtual_dom$VirtualDom$style = _elm_lang$virtual_dom$Native_VirtualDom.style;
var _elm_lang$virtual_dom$VirtualDom$mapProperty = _elm_lang$virtual_dom$Native_VirtualDom.mapProperty;
var _elm_lang$virtual_dom$VirtualDom$attributeNS = _elm_lang$virtual_dom$Native_VirtualDom.attributeNS;
var _elm_lang$virtual_dom$VirtualDom$attribute = _elm_lang$virtual_dom$Native_VirtualDom.attribute;
var _elm_lang$virtual_dom$VirtualDom$property = _elm_lang$virtual_dom$Native_VirtualDom.property;
var _elm_lang$virtual_dom$VirtualDom$map = _elm_lang$virtual_dom$Native_VirtualDom.map;
var _elm_lang$virtual_dom$VirtualDom$text = _elm_lang$virtual_dom$Native_VirtualDom.text;
var _elm_lang$virtual_dom$VirtualDom$node = _elm_lang$virtual_dom$Native_VirtualDom.node;
var _elm_lang$virtual_dom$VirtualDom$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});
var _elm_lang$virtual_dom$VirtualDom$Node = {ctor: 'Node'};
var _elm_lang$virtual_dom$VirtualDom$Property = {ctor: 'Property'};

var _elm_lang$html$Html$programWithFlags = _elm_lang$virtual_dom$VirtualDom$programWithFlags;
var _elm_lang$html$Html$program = _elm_lang$virtual_dom$VirtualDom$program;
var _elm_lang$html$Html$beginnerProgram = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$html$Html$program(
		{
			init: A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_p1.model,
				{ctor: '[]'}),
			update: F2(
				function (msg, model) {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						A2(_p1.update, msg, model),
						{ctor: '[]'});
				}),
			view: _p1.view,
			subscriptions: function (_p2) {
				return _elm_lang$core$Platform_Sub$none;
			}
		});
};
var _elm_lang$html$Html$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$html$Html$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$html$Html$node = _elm_lang$virtual_dom$VirtualDom$node;
var _elm_lang$html$Html$body = _elm_lang$html$Html$node('body');
var _elm_lang$html$Html$section = _elm_lang$html$Html$node('section');
var _elm_lang$html$Html$nav = _elm_lang$html$Html$node('nav');
var _elm_lang$html$Html$article = _elm_lang$html$Html$node('article');
var _elm_lang$html$Html$aside = _elm_lang$html$Html$node('aside');
var _elm_lang$html$Html$h1 = _elm_lang$html$Html$node('h1');
var _elm_lang$html$Html$h2 = _elm_lang$html$Html$node('h2');
var _elm_lang$html$Html$h3 = _elm_lang$html$Html$node('h3');
var _elm_lang$html$Html$h4 = _elm_lang$html$Html$node('h4');
var _elm_lang$html$Html$h5 = _elm_lang$html$Html$node('h5');
var _elm_lang$html$Html$h6 = _elm_lang$html$Html$node('h6');
var _elm_lang$html$Html$header = _elm_lang$html$Html$node('header');
var _elm_lang$html$Html$footer = _elm_lang$html$Html$node('footer');
var _elm_lang$html$Html$address = _elm_lang$html$Html$node('address');
var _elm_lang$html$Html$main_ = _elm_lang$html$Html$node('main');
var _elm_lang$html$Html$p = _elm_lang$html$Html$node('p');
var _elm_lang$html$Html$hr = _elm_lang$html$Html$node('hr');
var _elm_lang$html$Html$pre = _elm_lang$html$Html$node('pre');
var _elm_lang$html$Html$blockquote = _elm_lang$html$Html$node('blockquote');
var _elm_lang$html$Html$ol = _elm_lang$html$Html$node('ol');
var _elm_lang$html$Html$ul = _elm_lang$html$Html$node('ul');
var _elm_lang$html$Html$li = _elm_lang$html$Html$node('li');
var _elm_lang$html$Html$dl = _elm_lang$html$Html$node('dl');
var _elm_lang$html$Html$dt = _elm_lang$html$Html$node('dt');
var _elm_lang$html$Html$dd = _elm_lang$html$Html$node('dd');
var _elm_lang$html$Html$figure = _elm_lang$html$Html$node('figure');
var _elm_lang$html$Html$figcaption = _elm_lang$html$Html$node('figcaption');
var _elm_lang$html$Html$div = _elm_lang$html$Html$node('div');
var _elm_lang$html$Html$a = _elm_lang$html$Html$node('a');
var _elm_lang$html$Html$em = _elm_lang$html$Html$node('em');
var _elm_lang$html$Html$strong = _elm_lang$html$Html$node('strong');
var _elm_lang$html$Html$small = _elm_lang$html$Html$node('small');
var _elm_lang$html$Html$s = _elm_lang$html$Html$node('s');
var _elm_lang$html$Html$cite = _elm_lang$html$Html$node('cite');
var _elm_lang$html$Html$q = _elm_lang$html$Html$node('q');
var _elm_lang$html$Html$dfn = _elm_lang$html$Html$node('dfn');
var _elm_lang$html$Html$abbr = _elm_lang$html$Html$node('abbr');
var _elm_lang$html$Html$time = _elm_lang$html$Html$node('time');
var _elm_lang$html$Html$code = _elm_lang$html$Html$node('code');
var _elm_lang$html$Html$var = _elm_lang$html$Html$node('var');
var _elm_lang$html$Html$samp = _elm_lang$html$Html$node('samp');
var _elm_lang$html$Html$kbd = _elm_lang$html$Html$node('kbd');
var _elm_lang$html$Html$sub = _elm_lang$html$Html$node('sub');
var _elm_lang$html$Html$sup = _elm_lang$html$Html$node('sup');
var _elm_lang$html$Html$i = _elm_lang$html$Html$node('i');
var _elm_lang$html$Html$b = _elm_lang$html$Html$node('b');
var _elm_lang$html$Html$u = _elm_lang$html$Html$node('u');
var _elm_lang$html$Html$mark = _elm_lang$html$Html$node('mark');
var _elm_lang$html$Html$ruby = _elm_lang$html$Html$node('ruby');
var _elm_lang$html$Html$rt = _elm_lang$html$Html$node('rt');
var _elm_lang$html$Html$rp = _elm_lang$html$Html$node('rp');
var _elm_lang$html$Html$bdi = _elm_lang$html$Html$node('bdi');
var _elm_lang$html$Html$bdo = _elm_lang$html$Html$node('bdo');
var _elm_lang$html$Html$span = _elm_lang$html$Html$node('span');
var _elm_lang$html$Html$br = _elm_lang$html$Html$node('br');
var _elm_lang$html$Html$wbr = _elm_lang$html$Html$node('wbr');
var _elm_lang$html$Html$ins = _elm_lang$html$Html$node('ins');
var _elm_lang$html$Html$del = _elm_lang$html$Html$node('del');
var _elm_lang$html$Html$img = _elm_lang$html$Html$node('img');
var _elm_lang$html$Html$iframe = _elm_lang$html$Html$node('iframe');
var _elm_lang$html$Html$embed = _elm_lang$html$Html$node('embed');
var _elm_lang$html$Html$object = _elm_lang$html$Html$node('object');
var _elm_lang$html$Html$param = _elm_lang$html$Html$node('param');
var _elm_lang$html$Html$video = _elm_lang$html$Html$node('video');
var _elm_lang$html$Html$audio = _elm_lang$html$Html$node('audio');
var _elm_lang$html$Html$source = _elm_lang$html$Html$node('source');
var _elm_lang$html$Html$track = _elm_lang$html$Html$node('track');
var _elm_lang$html$Html$canvas = _elm_lang$html$Html$node('canvas');
var _elm_lang$html$Html$math = _elm_lang$html$Html$node('math');
var _elm_lang$html$Html$table = _elm_lang$html$Html$node('table');
var _elm_lang$html$Html$caption = _elm_lang$html$Html$node('caption');
var _elm_lang$html$Html$colgroup = _elm_lang$html$Html$node('colgroup');
var _elm_lang$html$Html$col = _elm_lang$html$Html$node('col');
var _elm_lang$html$Html$tbody = _elm_lang$html$Html$node('tbody');
var _elm_lang$html$Html$thead = _elm_lang$html$Html$node('thead');
var _elm_lang$html$Html$tfoot = _elm_lang$html$Html$node('tfoot');
var _elm_lang$html$Html$tr = _elm_lang$html$Html$node('tr');
var _elm_lang$html$Html$td = _elm_lang$html$Html$node('td');
var _elm_lang$html$Html$th = _elm_lang$html$Html$node('th');
var _elm_lang$html$Html$form = _elm_lang$html$Html$node('form');
var _elm_lang$html$Html$fieldset = _elm_lang$html$Html$node('fieldset');
var _elm_lang$html$Html$legend = _elm_lang$html$Html$node('legend');
var _elm_lang$html$Html$label = _elm_lang$html$Html$node('label');
var _elm_lang$html$Html$input = _elm_lang$html$Html$node('input');
var _elm_lang$html$Html$button = _elm_lang$html$Html$node('button');
var _elm_lang$html$Html$select = _elm_lang$html$Html$node('select');
var _elm_lang$html$Html$datalist = _elm_lang$html$Html$node('datalist');
var _elm_lang$html$Html$optgroup = _elm_lang$html$Html$node('optgroup');
var _elm_lang$html$Html$option = _elm_lang$html$Html$node('option');
var _elm_lang$html$Html$textarea = _elm_lang$html$Html$node('textarea');
var _elm_lang$html$Html$keygen = _elm_lang$html$Html$node('keygen');
var _elm_lang$html$Html$output = _elm_lang$html$Html$node('output');
var _elm_lang$html$Html$progress = _elm_lang$html$Html$node('progress');
var _elm_lang$html$Html$meter = _elm_lang$html$Html$node('meter');
var _elm_lang$html$Html$details = _elm_lang$html$Html$node('details');
var _elm_lang$html$Html$summary = _elm_lang$html$Html$node('summary');
var _elm_lang$html$Html$menuitem = _elm_lang$html$Html$node('menuitem');
var _elm_lang$html$Html$menu = _elm_lang$html$Html$node('menu');

var _elm_lang$html$Html_Attributes$map = _elm_lang$virtual_dom$VirtualDom$mapProperty;
var _elm_lang$html$Html_Attributes$attribute = _elm_lang$virtual_dom$VirtualDom$attribute;
var _elm_lang$html$Html_Attributes$contextmenu = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'contextmenu', value);
};
var _elm_lang$html$Html_Attributes$draggable = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'draggable', value);
};
var _elm_lang$html$Html_Attributes$itemprop = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'itemprop', value);
};
var _elm_lang$html$Html_Attributes$tabindex = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'tabIndex',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$charset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'charset', value);
};
var _elm_lang$html$Html_Attributes$height = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'height',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$width = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'width',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$formaction = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'formAction', value);
};
var _elm_lang$html$Html_Attributes$list = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'list', value);
};
var _elm_lang$html$Html_Attributes$minlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'minLength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$maxlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'maxlength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$size = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'size',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$form = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'form', value);
};
var _elm_lang$html$Html_Attributes$cols = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'cols',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rows = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rows',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$challenge = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'challenge', value);
};
var _elm_lang$html$Html_Attributes$media = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'media', value);
};
var _elm_lang$html$Html_Attributes$rel = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'rel', value);
};
var _elm_lang$html$Html_Attributes$datetime = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'datetime', value);
};
var _elm_lang$html$Html_Attributes$pubdate = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'pubdate', value);
};
var _elm_lang$html$Html_Attributes$colspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'colspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rowspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rowspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$manifest = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'manifest', value);
};
var _elm_lang$html$Html_Attributes$property = _elm_lang$virtual_dom$VirtualDom$property;
var _elm_lang$html$Html_Attributes$stringProperty = F2(
	function (name, string) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$string(string));
	});
var _elm_lang$html$Html_Attributes$class = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'className', name);
};
var _elm_lang$html$Html_Attributes$id = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'id', name);
};
var _elm_lang$html$Html_Attributes$title = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'title', name);
};
var _elm_lang$html$Html_Attributes$accesskey = function ($char) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'accessKey',
		_elm_lang$core$String$fromChar($char));
};
var _elm_lang$html$Html_Attributes$dir = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dir', value);
};
var _elm_lang$html$Html_Attributes$dropzone = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dropzone', value);
};
var _elm_lang$html$Html_Attributes$lang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'lang', value);
};
var _elm_lang$html$Html_Attributes$content = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'content', value);
};
var _elm_lang$html$Html_Attributes$httpEquiv = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'httpEquiv', value);
};
var _elm_lang$html$Html_Attributes$language = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'language', value);
};
var _elm_lang$html$Html_Attributes$src = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'src', value);
};
var _elm_lang$html$Html_Attributes$alt = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'alt', value);
};
var _elm_lang$html$Html_Attributes$preload = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'preload', value);
};
var _elm_lang$html$Html_Attributes$poster = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'poster', value);
};
var _elm_lang$html$Html_Attributes$kind = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'kind', value);
};
var _elm_lang$html$Html_Attributes$srclang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srclang', value);
};
var _elm_lang$html$Html_Attributes$sandbox = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'sandbox', value);
};
var _elm_lang$html$Html_Attributes$srcdoc = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srcdoc', value);
};
var _elm_lang$html$Html_Attributes$type_ = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'type', value);
};
var _elm_lang$html$Html_Attributes$value = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'value', value);
};
var _elm_lang$html$Html_Attributes$defaultValue = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'defaultValue', value);
};
var _elm_lang$html$Html_Attributes$placeholder = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'placeholder', value);
};
var _elm_lang$html$Html_Attributes$accept = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'accept', value);
};
var _elm_lang$html$Html_Attributes$acceptCharset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'acceptCharset', value);
};
var _elm_lang$html$Html_Attributes$action = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'action', value);
};
var _elm_lang$html$Html_Attributes$autocomplete = function (bool) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'autocomplete',
		bool ? 'on' : 'off');
};
var _elm_lang$html$Html_Attributes$enctype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'enctype', value);
};
var _elm_lang$html$Html_Attributes$method = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'method', value);
};
var _elm_lang$html$Html_Attributes$name = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'name', value);
};
var _elm_lang$html$Html_Attributes$pattern = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'pattern', value);
};
var _elm_lang$html$Html_Attributes$for = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'htmlFor', value);
};
var _elm_lang$html$Html_Attributes$max = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'max', value);
};
var _elm_lang$html$Html_Attributes$min = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'min', value);
};
var _elm_lang$html$Html_Attributes$step = function (n) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'step', n);
};
var _elm_lang$html$Html_Attributes$wrap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'wrap', value);
};
var _elm_lang$html$Html_Attributes$usemap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'useMap', value);
};
var _elm_lang$html$Html_Attributes$shape = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'shape', value);
};
var _elm_lang$html$Html_Attributes$coords = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'coords', value);
};
var _elm_lang$html$Html_Attributes$keytype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'keytype', value);
};
var _elm_lang$html$Html_Attributes$align = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'align', value);
};
var _elm_lang$html$Html_Attributes$cite = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'cite', value);
};
var _elm_lang$html$Html_Attributes$href = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'href', value);
};
var _elm_lang$html$Html_Attributes$target = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'target', value);
};
var _elm_lang$html$Html_Attributes$downloadAs = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'download', value);
};
var _elm_lang$html$Html_Attributes$hreflang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'hreflang', value);
};
var _elm_lang$html$Html_Attributes$ping = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'ping', value);
};
var _elm_lang$html$Html_Attributes$start = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'start',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$headers = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'headers', value);
};
var _elm_lang$html$Html_Attributes$scope = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'scope', value);
};
var _elm_lang$html$Html_Attributes$boolProperty = F2(
	function (name, bool) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$bool(bool));
	});
var _elm_lang$html$Html_Attributes$hidden = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'hidden', bool);
};
var _elm_lang$html$Html_Attributes$contenteditable = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'contentEditable', bool);
};
var _elm_lang$html$Html_Attributes$spellcheck = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'spellcheck', bool);
};
var _elm_lang$html$Html_Attributes$async = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'async', bool);
};
var _elm_lang$html$Html_Attributes$defer = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'defer', bool);
};
var _elm_lang$html$Html_Attributes$scoped = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'scoped', bool);
};
var _elm_lang$html$Html_Attributes$autoplay = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autoplay', bool);
};
var _elm_lang$html$Html_Attributes$controls = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'controls', bool);
};
var _elm_lang$html$Html_Attributes$loop = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'loop', bool);
};
var _elm_lang$html$Html_Attributes$default = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'default', bool);
};
var _elm_lang$html$Html_Attributes$seamless = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'seamless', bool);
};
var _elm_lang$html$Html_Attributes$checked = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'checked', bool);
};
var _elm_lang$html$Html_Attributes$selected = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'selected', bool);
};
var _elm_lang$html$Html_Attributes$autofocus = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autofocus', bool);
};
var _elm_lang$html$Html_Attributes$disabled = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'disabled', bool);
};
var _elm_lang$html$Html_Attributes$multiple = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'multiple', bool);
};
var _elm_lang$html$Html_Attributes$novalidate = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'noValidate', bool);
};
var _elm_lang$html$Html_Attributes$readonly = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'readOnly', bool);
};
var _elm_lang$html$Html_Attributes$required = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'required', bool);
};
var _elm_lang$html$Html_Attributes$ismap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'isMap', value);
};
var _elm_lang$html$Html_Attributes$download = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'download', bool);
};
var _elm_lang$html$Html_Attributes$reversed = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'reversed', bool);
};
var _elm_lang$html$Html_Attributes$classList = function (list) {
	return _elm_lang$html$Html_Attributes$class(
		A2(
			_elm_lang$core$String$join,
			' ',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Tuple$first,
				A2(_elm_lang$core$List$filter, _elm_lang$core$Tuple$second, list))));
};
var _elm_lang$html$Html_Attributes$style = _elm_lang$virtual_dom$VirtualDom$style;

var _elm_lang$html$Html_Events$keyCode = A2(_elm_lang$core$Json_Decode$field, 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$html$Html_Events$targetChecked = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'checked',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$bool);
var _elm_lang$html$Html_Events$targetValue = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'value',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$string);
var _elm_lang$html$Html_Events$defaultOptions = _elm_lang$virtual_dom$VirtualDom$defaultOptions;
var _elm_lang$html$Html_Events$onWithOptions = _elm_lang$virtual_dom$VirtualDom$onWithOptions;
var _elm_lang$html$Html_Events$on = _elm_lang$virtual_dom$VirtualDom$on;
var _elm_lang$html$Html_Events$onFocus = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'focus',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onBlur = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'blur',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onSubmitOptions = _elm_lang$core$Native_Utils.update(
	_elm_lang$html$Html_Events$defaultOptions,
	{preventDefault: true});
var _elm_lang$html$Html_Events$onSubmit = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'submit',
		_elm_lang$html$Html_Events$onSubmitOptions,
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onCheck = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'change',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetChecked));
};
var _elm_lang$html$Html_Events$onInput = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'input',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetValue));
};
var _elm_lang$html$Html_Events$onMouseOut = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseout',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseOver = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseover',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseLeave = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseleave',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseEnter = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseenter',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseUp = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseup',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseDown = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mousedown',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onDoubleClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'dblclick',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'click',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});

var _sanichi$elm_md5$MD5$g = F3(
	function (x, y, z) {
		return (x & z) | (y & (~z));
	});
var _sanichi$elm_md5$MD5$f = F3(
	function (x, y, z) {
		return (x & y) | ((~x) & z);
	});
var _sanichi$elm_md5$MD5$iget = F2(
	function (index, array) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(_elm_lang$core$Array$get, index, array));
	});
var _sanichi$elm_md5$MD5$ixor = F2(
	function (x, y) {
		return x ^ y;
	});
var _sanichi$elm_md5$MD5$h = F3(
	function (x, y, z) {
		return A2(
			_sanichi$elm_md5$MD5$ixor,
			z,
			A2(_sanichi$elm_md5$MD5$ixor, x, y));
	});
var _sanichi$elm_md5$MD5$i = F3(
	function (x, y, z) {
		return A2(_sanichi$elm_md5$MD5$ixor, y, x | (~z));
	});
var _sanichi$elm_md5$MD5$addUnsigned = F2(
	function (x, y) {
		var result = (x & 1073741823) + (y & 1073741823);
		var y4 = y & 1073741824;
		var x4 = x & 1073741824;
		var y8 = y & 2147483648;
		var x8 = x & 2147483648;
		return (_elm_lang$core$Native_Utils.cmp(x4 & y4, 0) > 0) ? A2(
			_sanichi$elm_md5$MD5$ixor,
			y8,
			A2(
				_sanichi$elm_md5$MD5$ixor,
				x8,
				A2(_sanichi$elm_md5$MD5$ixor, result, 2147483648))) : ((_elm_lang$core$Native_Utils.cmp(x4 | y4, 0) > 0) ? ((_elm_lang$core$Native_Utils.cmp(result & 1073741824, 0) > 0) ? A2(
			_sanichi$elm_md5$MD5$ixor,
			y8,
			A2(
				_sanichi$elm_md5$MD5$ixor,
				x8,
				A2(_sanichi$elm_md5$MD5$ixor, result, 3221225472))) : A2(
			_sanichi$elm_md5$MD5$ixor,
			y8,
			A2(
				_sanichi$elm_md5$MD5$ixor,
				x8,
				A2(_sanichi$elm_md5$MD5$ixor, result, 1073741824)))) : A2(
			_sanichi$elm_md5$MD5$ixor,
			y8,
			A2(_sanichi$elm_md5$MD5$ixor, result, x8)));
	});
var _sanichi$elm_md5$MD5$rotateLeft = F2(
	function (input, bits) {
		return (input << bits) | (input >>> (32 - bits));
	});
var _sanichi$elm_md5$MD5$ff = F7(
	function (a, b, c, d, x, s, ac) {
		var z = A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			a,
			A2(
				_sanichi$elm_md5$MD5$addUnsigned,
				A2(
					_sanichi$elm_md5$MD5$addUnsigned,
					A3(_sanichi$elm_md5$MD5$f, b, c, d),
					x),
				ac));
		return A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			A2(_sanichi$elm_md5$MD5$rotateLeft, z, s),
			b);
	});
var _sanichi$elm_md5$MD5$gg = F7(
	function (a, b, c, d, x, s, ac) {
		var z = A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			a,
			A2(
				_sanichi$elm_md5$MD5$addUnsigned,
				A2(
					_sanichi$elm_md5$MD5$addUnsigned,
					A3(_sanichi$elm_md5$MD5$g, b, c, d),
					x),
				ac));
		return A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			A2(_sanichi$elm_md5$MD5$rotateLeft, z, s),
			b);
	});
var _sanichi$elm_md5$MD5$hh = F7(
	function (a, b, c, d, x, s, ac) {
		var z = A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			a,
			A2(
				_sanichi$elm_md5$MD5$addUnsigned,
				A2(
					_sanichi$elm_md5$MD5$addUnsigned,
					A3(_sanichi$elm_md5$MD5$h, b, c, d),
					x),
				ac));
		return A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			A2(_sanichi$elm_md5$MD5$rotateLeft, z, s),
			b);
	});
var _sanichi$elm_md5$MD5$ii = F7(
	function (a, b, c, d, x, s, ac) {
		var z = A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			a,
			A2(
				_sanichi$elm_md5$MD5$addUnsigned,
				A2(
					_sanichi$elm_md5$MD5$addUnsigned,
					A3(_sanichi$elm_md5$MD5$i, b, c, d),
					x),
				ac));
		return A2(
			_sanichi$elm_md5$MD5$addUnsigned,
			A2(_sanichi$elm_md5$MD5$rotateLeft, z, s),
			b);
	});
var _sanichi$elm_md5$MD5$hexFromInt = function (i) {
	return (_elm_lang$core$Native_Utils.cmp(i, 10) < 0) ? _elm_lang$core$Char$fromCode(
		i + _elm_lang$core$Char$toCode(
			_elm_lang$core$Native_Utils.chr('0'))) : _elm_lang$core$Char$fromCode(
		(i - 10) + _elm_lang$core$Char$toCode(
			_elm_lang$core$Native_Utils.chr('a')));
};
var _sanichi$elm_md5$MD5$toHex = function (i) {
	return (_elm_lang$core$Native_Utils.cmp(i, 16) < 0) ? _elm_lang$core$String$fromChar(
		_sanichi$elm_md5$MD5$hexFromInt(i)) : A2(
		_elm_lang$core$Basics_ops['++'],
		_sanichi$elm_md5$MD5$toHex((i / 16) | 0),
		_elm_lang$core$String$fromChar(
			_sanichi$elm_md5$MD5$hexFromInt(
				A2(_elm_lang$core$Basics_ops['%'], i, 16))));
};
var _sanichi$elm_md5$MD5$wordToHex_ = F3(
	function (input, index, output) {
		wordToHex_:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(index, 3) > 0) {
				return output;
			} else {
				var $byte = (input >>> (index * 8)) & 255;
				var tmp2 = _sanichi$elm_md5$MD5$toHex($byte);
				var tmp1 = _elm_lang$core$Native_Utils.eq(
					_elm_lang$core$String$length(tmp2),
					1) ? '0' : '';
				var _v0 = input,
					_v1 = index + 1,
					_v2 = A2(
					_elm_lang$core$Basics_ops['++'],
					output,
					A2(_elm_lang$core$Basics_ops['++'], tmp1, tmp2));
				input = _v0;
				index = _v1;
				output = _v2;
				continue wordToHex_;
			}
		}
	});
var _sanichi$elm_md5$MD5$wordToHex = function (input) {
	return A3(_sanichi$elm_md5$MD5$wordToHex_, input, 0, '');
};
var _sanichi$elm_md5$MD5$utf8Encode_ = F2(
	function (input, output) {
		utf8Encode_:
		while (true) {
			var split = _elm_lang$core$String$uncons(input);
			var _p0 = split;
			if (_p0.ctor === 'Nothing') {
				return output;
			} else {
				var _p1 = _p0._0._0;
				var c = _elm_lang$core$Char$toCode(_p1);
				var newOutput = (_elm_lang$core$Native_Utils.cmp(c, 128) < 0) ? A2(
					_elm_lang$core$Basics_ops['++'],
					output,
					_elm_lang$core$String$fromChar(_p1)) : ((_elm_lang$core$Native_Utils.cmp(c, 2048) < 0) ? A2(
					_elm_lang$core$Basics_ops['++'],
					output,
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$String$fromChar(
							_elm_lang$core$Char$fromCode((c >> 6) | 192)),
						_elm_lang$core$String$fromChar(
							_elm_lang$core$Char$fromCode((c & 63) | 128)))) : A2(
					_elm_lang$core$Basics_ops['++'],
					output,
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$String$fromChar(
							_elm_lang$core$Char$fromCode((c >> 12) | 224)),
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$String$fromChar(
								_elm_lang$core$Char$fromCode(((c >> 6) & 63) | 128)),
							_elm_lang$core$String$fromChar(
								_elm_lang$core$Char$fromCode((c & 63) | 128))))));
				var _v4 = _p0._0._1,
					_v5 = newOutput;
				input = _v4;
				output = _v5;
				continue utf8Encode_;
			}
		}
	});
var _sanichi$elm_md5$MD5$utf8Encode = function (string) {
	return A2(_sanichi$elm_md5$MD5$utf8Encode_, string, '');
};
var _sanichi$elm_md5$MD5$convertToWordArray_ = F4(
	function (input, byteCount, messageLength, words) {
		convertToWordArray_:
		while (true) {
			var bytePosition = 8 * A2(_elm_lang$core$Basics_ops['%'], byteCount, 4);
			var wordCount = ((byteCount - A2(_elm_lang$core$Basics_ops['%'], byteCount, 4)) / 4) | 0;
			var oldWord = A2(_sanichi$elm_md5$MD5$iget, wordCount, words);
			if (_elm_lang$core$Native_Utils.cmp(byteCount, messageLength) < 0) {
				var str = A3(_elm_lang$core$String$slice, byteCount, byteCount + 1, input);
				var split = _elm_lang$core$String$uncons(str);
				var code = function () {
					var _p2 = split;
					if (_p2.ctor === 'Nothing') {
						return 0;
					} else {
						return _elm_lang$core$Char$toCode(_p2._0._0) << bytePosition;
					}
				}();
				var newWord = oldWord | code;
				var newWords = A3(_elm_lang$core$Array$set, wordCount, newWord, words);
				var _v7 = input,
					_v8 = byteCount + 1,
					_v9 = messageLength,
					_v10 = newWords;
				input = _v7;
				byteCount = _v8;
				messageLength = _v9;
				words = _v10;
				continue convertToWordArray_;
			} else {
				var code = 128 << bytePosition;
				var newWord = oldWord | code;
				var tmp1 = A3(_elm_lang$core$Array$set, wordCount, newWord, words);
				var numberOfWords = _elm_lang$core$Array$length(words);
				var tmp2 = A3(_elm_lang$core$Array$set, numberOfWords - 2, messageLength << 3, tmp1);
				return A3(_elm_lang$core$Array$set, numberOfWords - 1, messageLength >>> 29, tmp2);
			}
		}
	});
var _sanichi$elm_md5$MD5$convertToWordArray = function (input) {
	var messageLength = _elm_lang$core$String$length(input);
	var tmp1 = messageLength + 8;
	var tmp2 = ((tmp1 - A2(_elm_lang$core$Basics_ops['%'], tmp1, 64)) / 64) | 0;
	var numberOfWords = 16 * (tmp2 + 1);
	var words = A2(_elm_lang$core$Array$repeat, numberOfWords, 0);
	return A4(_sanichi$elm_md5$MD5$convertToWordArray_, input, 0, messageLength, words);
};
var _sanichi$elm_md5$MD5$hex_ = F3(
	function (x, k, _p3) {
		hex_:
		while (true) {
			var _p4 = _p3;
			var _p8 = _p4._3;
			var _p7 = _p4._2;
			var _p6 = _p4._1;
			var _p5 = _p4._0;
			if (_elm_lang$core$Native_Utils.cmp(
				k,
				_elm_lang$core$Array$length(x)) > -1) {
				return {ctor: '_Tuple4', _0: _p5, _1: _p6, _2: _p7, _3: _p8};
			} else {
				var d00 = _p8;
				var c00 = _p7;
				var b00 = _p6;
				var a00 = _p5;
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
				var a01 = A7(
					_sanichi$elm_md5$MD5$ff,
					a00,
					b00,
					c00,
					d00,
					A2(_sanichi$elm_md5$MD5$iget, k + 0, x),
					s11,
					3614090360);
				var d01 = A7(
					_sanichi$elm_md5$MD5$ff,
					d00,
					a01,
					b00,
					c00,
					A2(_sanichi$elm_md5$MD5$iget, k + 1, x),
					s12,
					3905402710);
				var c01 = A7(
					_sanichi$elm_md5$MD5$ff,
					c00,
					d01,
					a01,
					b00,
					A2(_sanichi$elm_md5$MD5$iget, k + 2, x),
					s13,
					606105819);
				var b01 = A7(
					_sanichi$elm_md5$MD5$ff,
					b00,
					c01,
					d01,
					a01,
					A2(_sanichi$elm_md5$MD5$iget, k + 3, x),
					s14,
					3250441966);
				var a02 = A7(
					_sanichi$elm_md5$MD5$ff,
					a01,
					b01,
					c01,
					d01,
					A2(_sanichi$elm_md5$MD5$iget, k + 4, x),
					s11,
					4118548399);
				var d02 = A7(
					_sanichi$elm_md5$MD5$ff,
					d01,
					a02,
					b01,
					c01,
					A2(_sanichi$elm_md5$MD5$iget, k + 5, x),
					s12,
					1200080426);
				var c02 = A7(
					_sanichi$elm_md5$MD5$ff,
					c01,
					d02,
					a02,
					b01,
					A2(_sanichi$elm_md5$MD5$iget, k + 6, x),
					s13,
					2821735955);
				var b02 = A7(
					_sanichi$elm_md5$MD5$ff,
					b01,
					c02,
					d02,
					a02,
					A2(_sanichi$elm_md5$MD5$iget, k + 7, x),
					s14,
					4249261313);
				var a03 = A7(
					_sanichi$elm_md5$MD5$ff,
					a02,
					b02,
					c02,
					d02,
					A2(_sanichi$elm_md5$MD5$iget, k + 8, x),
					s11,
					1770035416);
				var d03 = A7(
					_sanichi$elm_md5$MD5$ff,
					d02,
					a03,
					b02,
					c02,
					A2(_sanichi$elm_md5$MD5$iget, k + 9, x),
					s12,
					2336552879);
				var c03 = A7(
					_sanichi$elm_md5$MD5$ff,
					c02,
					d03,
					a03,
					b02,
					A2(_sanichi$elm_md5$MD5$iget, k + 10, x),
					s13,
					4294925233);
				var b03 = A7(
					_sanichi$elm_md5$MD5$ff,
					b02,
					c03,
					d03,
					a03,
					A2(_sanichi$elm_md5$MD5$iget, k + 11, x),
					s14,
					2304563134);
				var a04 = A7(
					_sanichi$elm_md5$MD5$ff,
					a03,
					b03,
					c03,
					d03,
					A2(_sanichi$elm_md5$MD5$iget, k + 12, x),
					s11,
					1804603682);
				var d04 = A7(
					_sanichi$elm_md5$MD5$ff,
					d03,
					a04,
					b03,
					c03,
					A2(_sanichi$elm_md5$MD5$iget, k + 13, x),
					s12,
					4254626195);
				var c04 = A7(
					_sanichi$elm_md5$MD5$ff,
					c03,
					d04,
					a04,
					b03,
					A2(_sanichi$elm_md5$MD5$iget, k + 14, x),
					s13,
					2792965006);
				var b04 = A7(
					_sanichi$elm_md5$MD5$ff,
					b03,
					c04,
					d04,
					a04,
					A2(_sanichi$elm_md5$MD5$iget, k + 15, x),
					s14,
					1236535329);
				var a05 = A7(
					_sanichi$elm_md5$MD5$gg,
					a04,
					b04,
					c04,
					d04,
					A2(_sanichi$elm_md5$MD5$iget, k + 1, x),
					s21,
					4129170786);
				var d05 = A7(
					_sanichi$elm_md5$MD5$gg,
					d04,
					a05,
					b04,
					c04,
					A2(_sanichi$elm_md5$MD5$iget, k + 6, x),
					s22,
					3225465664);
				var c05 = A7(
					_sanichi$elm_md5$MD5$gg,
					c04,
					d05,
					a05,
					b04,
					A2(_sanichi$elm_md5$MD5$iget, k + 11, x),
					s23,
					643717713);
				var b05 = A7(
					_sanichi$elm_md5$MD5$gg,
					b04,
					c05,
					d05,
					a05,
					A2(_sanichi$elm_md5$MD5$iget, k + 0, x),
					s24,
					3921069994);
				var a06 = A7(
					_sanichi$elm_md5$MD5$gg,
					a05,
					b05,
					c05,
					d05,
					A2(_sanichi$elm_md5$MD5$iget, k + 5, x),
					s21,
					3593408605);
				var d06 = A7(
					_sanichi$elm_md5$MD5$gg,
					d05,
					a06,
					b05,
					c05,
					A2(_sanichi$elm_md5$MD5$iget, k + 10, x),
					s22,
					38016083);
				var c06 = A7(
					_sanichi$elm_md5$MD5$gg,
					c05,
					d06,
					a06,
					b05,
					A2(_sanichi$elm_md5$MD5$iget, k + 15, x),
					s23,
					3634488961);
				var b06 = A7(
					_sanichi$elm_md5$MD5$gg,
					b05,
					c06,
					d06,
					a06,
					A2(_sanichi$elm_md5$MD5$iget, k + 4, x),
					s24,
					3889429448);
				var a07 = A7(
					_sanichi$elm_md5$MD5$gg,
					a06,
					b06,
					c06,
					d06,
					A2(_sanichi$elm_md5$MD5$iget, k + 9, x),
					s21,
					568446438);
				var d07 = A7(
					_sanichi$elm_md5$MD5$gg,
					d06,
					a07,
					b06,
					c06,
					A2(_sanichi$elm_md5$MD5$iget, k + 14, x),
					s22,
					3275163606);
				var c07 = A7(
					_sanichi$elm_md5$MD5$gg,
					c06,
					d07,
					a07,
					b06,
					A2(_sanichi$elm_md5$MD5$iget, k + 3, x),
					s23,
					4107603335);
				var b07 = A7(
					_sanichi$elm_md5$MD5$gg,
					b06,
					c07,
					d07,
					a07,
					A2(_sanichi$elm_md5$MD5$iget, k + 8, x),
					s24,
					1163531501);
				var a08 = A7(
					_sanichi$elm_md5$MD5$gg,
					a07,
					b07,
					c07,
					d07,
					A2(_sanichi$elm_md5$MD5$iget, k + 13, x),
					s21,
					2850285829);
				var d08 = A7(
					_sanichi$elm_md5$MD5$gg,
					d07,
					a08,
					b07,
					c07,
					A2(_sanichi$elm_md5$MD5$iget, k + 2, x),
					s22,
					4243563512);
				var c08 = A7(
					_sanichi$elm_md5$MD5$gg,
					c07,
					d08,
					a08,
					b07,
					A2(_sanichi$elm_md5$MD5$iget, k + 7, x),
					s23,
					1735328473);
				var b08 = A7(
					_sanichi$elm_md5$MD5$gg,
					b07,
					c08,
					d08,
					a08,
					A2(_sanichi$elm_md5$MD5$iget, k + 12, x),
					s24,
					2368359562);
				var a09 = A7(
					_sanichi$elm_md5$MD5$hh,
					a08,
					b08,
					c08,
					d08,
					A2(_sanichi$elm_md5$MD5$iget, k + 5, x),
					s31,
					4294588738);
				var d09 = A7(
					_sanichi$elm_md5$MD5$hh,
					d08,
					a09,
					b08,
					c08,
					A2(_sanichi$elm_md5$MD5$iget, k + 8, x),
					s32,
					2272392833);
				var c09 = A7(
					_sanichi$elm_md5$MD5$hh,
					c08,
					d09,
					a09,
					b08,
					A2(_sanichi$elm_md5$MD5$iget, k + 11, x),
					s33,
					1839030562);
				var b09 = A7(
					_sanichi$elm_md5$MD5$hh,
					b08,
					c09,
					d09,
					a09,
					A2(_sanichi$elm_md5$MD5$iget, k + 14, x),
					s34,
					4259657740);
				var a10 = A7(
					_sanichi$elm_md5$MD5$hh,
					a09,
					b09,
					c09,
					d09,
					A2(_sanichi$elm_md5$MD5$iget, k + 1, x),
					s31,
					2763975236);
				var d10 = A7(
					_sanichi$elm_md5$MD5$hh,
					d09,
					a10,
					b09,
					c09,
					A2(_sanichi$elm_md5$MD5$iget, k + 4, x),
					s32,
					1272893353);
				var c10 = A7(
					_sanichi$elm_md5$MD5$hh,
					c09,
					d10,
					a10,
					b09,
					A2(_sanichi$elm_md5$MD5$iget, k + 7, x),
					s33,
					4139469664);
				var b10 = A7(
					_sanichi$elm_md5$MD5$hh,
					b09,
					c10,
					d10,
					a10,
					A2(_sanichi$elm_md5$MD5$iget, k + 10, x),
					s34,
					3200236656);
				var a11 = A7(
					_sanichi$elm_md5$MD5$hh,
					a10,
					b10,
					c10,
					d10,
					A2(_sanichi$elm_md5$MD5$iget, k + 13, x),
					s31,
					681279174);
				var d11 = A7(
					_sanichi$elm_md5$MD5$hh,
					d10,
					a11,
					b10,
					c10,
					A2(_sanichi$elm_md5$MD5$iget, k + 0, x),
					s32,
					3936430074);
				var c11 = A7(
					_sanichi$elm_md5$MD5$hh,
					c10,
					d11,
					a11,
					b10,
					A2(_sanichi$elm_md5$MD5$iget, k + 3, x),
					s33,
					3572445317);
				var b11 = A7(
					_sanichi$elm_md5$MD5$hh,
					b10,
					c11,
					d11,
					a11,
					A2(_sanichi$elm_md5$MD5$iget, k + 6, x),
					s34,
					76029189);
				var a12 = A7(
					_sanichi$elm_md5$MD5$hh,
					a11,
					b11,
					c11,
					d11,
					A2(_sanichi$elm_md5$MD5$iget, k + 9, x),
					s31,
					3654602809);
				var d12 = A7(
					_sanichi$elm_md5$MD5$hh,
					d11,
					a12,
					b11,
					c11,
					A2(_sanichi$elm_md5$MD5$iget, k + 12, x),
					s32,
					3873151461);
				var c12 = A7(
					_sanichi$elm_md5$MD5$hh,
					c11,
					d12,
					a12,
					b11,
					A2(_sanichi$elm_md5$MD5$iget, k + 15, x),
					s33,
					530742520);
				var b12 = A7(
					_sanichi$elm_md5$MD5$hh,
					b11,
					c12,
					d12,
					a12,
					A2(_sanichi$elm_md5$MD5$iget, k + 2, x),
					s34,
					3299628645);
				var a13 = A7(
					_sanichi$elm_md5$MD5$ii,
					a12,
					b12,
					c12,
					d12,
					A2(_sanichi$elm_md5$MD5$iget, k + 0, x),
					s41,
					4096336452);
				var d13 = A7(
					_sanichi$elm_md5$MD5$ii,
					d12,
					a13,
					b12,
					c12,
					A2(_sanichi$elm_md5$MD5$iget, k + 7, x),
					s42,
					1126891415);
				var c13 = A7(
					_sanichi$elm_md5$MD5$ii,
					c12,
					d13,
					a13,
					b12,
					A2(_sanichi$elm_md5$MD5$iget, k + 14, x),
					s43,
					2878612391);
				var b13 = A7(
					_sanichi$elm_md5$MD5$ii,
					b12,
					c13,
					d13,
					a13,
					A2(_sanichi$elm_md5$MD5$iget, k + 5, x),
					s44,
					4237533241);
				var a14 = A7(
					_sanichi$elm_md5$MD5$ii,
					a13,
					b13,
					c13,
					d13,
					A2(_sanichi$elm_md5$MD5$iget, k + 12, x),
					s41,
					1700485571);
				var d14 = A7(
					_sanichi$elm_md5$MD5$ii,
					d13,
					a14,
					b13,
					c13,
					A2(_sanichi$elm_md5$MD5$iget, k + 3, x),
					s42,
					2399980690);
				var c14 = A7(
					_sanichi$elm_md5$MD5$ii,
					c13,
					d14,
					a14,
					b13,
					A2(_sanichi$elm_md5$MD5$iget, k + 10, x),
					s43,
					4293915773);
				var b14 = A7(
					_sanichi$elm_md5$MD5$ii,
					b13,
					c14,
					d14,
					a14,
					A2(_sanichi$elm_md5$MD5$iget, k + 1, x),
					s44,
					2240044497);
				var a15 = A7(
					_sanichi$elm_md5$MD5$ii,
					a14,
					b14,
					c14,
					d14,
					A2(_sanichi$elm_md5$MD5$iget, k + 8, x),
					s41,
					1873313359);
				var d15 = A7(
					_sanichi$elm_md5$MD5$ii,
					d14,
					a15,
					b14,
					c14,
					A2(_sanichi$elm_md5$MD5$iget, k + 15, x),
					s42,
					4264355552);
				var c15 = A7(
					_sanichi$elm_md5$MD5$ii,
					c14,
					d15,
					a15,
					b14,
					A2(_sanichi$elm_md5$MD5$iget, k + 6, x),
					s43,
					2734768916);
				var b15 = A7(
					_sanichi$elm_md5$MD5$ii,
					b14,
					c15,
					d15,
					a15,
					A2(_sanichi$elm_md5$MD5$iget, k + 13, x),
					s44,
					1309151649);
				var a16 = A7(
					_sanichi$elm_md5$MD5$ii,
					a15,
					b15,
					c15,
					d15,
					A2(_sanichi$elm_md5$MD5$iget, k + 4, x),
					s41,
					4149444226);
				var d16 = A7(
					_sanichi$elm_md5$MD5$ii,
					d15,
					a16,
					b15,
					c15,
					A2(_sanichi$elm_md5$MD5$iget, k + 11, x),
					s42,
					3174756917);
				var d17 = A2(_sanichi$elm_md5$MD5$addUnsigned, d00, d16);
				var c16 = A7(
					_sanichi$elm_md5$MD5$ii,
					c15,
					d16,
					a16,
					b15,
					A2(_sanichi$elm_md5$MD5$iget, k + 2, x),
					s43,
					718787259);
				var c17 = A2(_sanichi$elm_md5$MD5$addUnsigned, c00, c16);
				var b16 = A7(
					_sanichi$elm_md5$MD5$ii,
					b15,
					c16,
					d16,
					a16,
					A2(_sanichi$elm_md5$MD5$iget, k + 9, x),
					s44,
					3951481745);
				var b17 = A2(_sanichi$elm_md5$MD5$addUnsigned, b00, b16);
				var a17 = A2(_sanichi$elm_md5$MD5$addUnsigned, a00, a16);
				var _v12 = x,
					_v13 = k + 16,
					_v14 = {ctor: '_Tuple4', _0: a17, _1: b17, _2: c17, _3: d17};
				x = _v12;
				k = _v13;
				_p3 = _v14;
				continue hex_;
			}
		}
	});
var _sanichi$elm_md5$MD5$hex = function (string) {
	var x = _sanichi$elm_md5$MD5$convertToWordArray(
		_sanichi$elm_md5$MD5$utf8Encode(string));
	var _p9 = A3(
		_sanichi$elm_md5$MD5$hex_,
		x,
		0,
		{ctor: '_Tuple4', _0: 1732584193, _1: 4023233417, _2: 2562383102, _3: 271733878});
	var a = _p9._0;
	var b = _p9._1;
	var c = _p9._2;
	var d = _p9._3;
	return A2(
		_elm_lang$core$Basics_ops['++'],
		_sanichi$elm_md5$MD5$wordToHex(a),
		A2(
			_elm_lang$core$Basics_ops['++'],
			_sanichi$elm_md5$MD5$wordToHex(b),
			A2(
				_elm_lang$core$Basics_ops['++'],
				_sanichi$elm_md5$MD5$wordToHex(c),
				_sanichi$elm_md5$MD5$wordToHex(d))));
};

var _user$project$Ports$getData = _elm_lang$core$Native_Platform.outgoingPort(
	'getData',
	function (v) {
		return [v._0, v._1];
	});
var _user$project$Ports$newData = _elm_lang$core$Native_Platform.incomingPort('newData', _elm_lang$core$Json_Decode$string);
var _user$project$Ports$prepareAnswer = _elm_lang$core$Native_Platform.outgoingPort(
	'prepareAnswer',
	function (v) {
		return v;
	});
var _user$project$Ports$startAnswer = _elm_lang$core$Native_Platform.incomingPort('startAnswer', _elm_lang$core$Json_Decode$int);

var _user$project$Y15D01$position = F3(
	function (floor, step, instructions) {
		position:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(floor, 0) < 0) {
				return step;
			} else {
				var next = _elm_lang$core$String$uncons(instructions);
				var _p0 = next;
				_v0_2:
				do {
					if ((_p0.ctor === 'Just') && (_p0._0.ctor === '_Tuple2')) {
						switch (_p0._0._0.valueOf()) {
							case '(':
								var _v1 = floor + 1,
									_v2 = step + 1,
									_v3 = _p0._0._1;
								floor = _v1;
								step = _v2;
								instructions = _v3;
								continue position;
							case ')':
								var _v4 = floor - 1,
									_v5 = step + 1,
									_v6 = _p0._0._1;
								floor = _v4;
								step = _v5;
								instructions = _v6;
								continue position;
							default:
								break _v0_2;
						}
					} else {
						break _v0_2;
					}
				} while(false);
				return step;
			}
		}
	});
var _user$project$Y15D01$count = F2(
	function (floor, instructions) {
		count:
		while (true) {
			var next = _elm_lang$core$String$uncons(instructions);
			var _p1 = next;
			_v7_2:
			do {
				if ((_p1.ctor === 'Just') && (_p1._0.ctor === '_Tuple2')) {
					switch (_p1._0._0.valueOf()) {
						case '(':
							var _v8 = floor + 1,
								_v9 = _p1._0._1;
							floor = _v8;
							instructions = _v9;
							continue count;
						case ')':
							var _v10 = floor - 1,
								_v11 = _p1._0._1;
							floor = _v10;
							instructions = _v11;
							continue count;
						default:
							break _v7_2;
					}
				} else {
					break _v7_2;
				}
			} while(false);
			return floor;
		}
	});
var _user$project$Y15D01$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(_user$project$Y15D01$count, 0, input)) : _elm_lang$core$Basics$toString(
			A3(_user$project$Y15D01$position, 0, 0, input));
	});

var _user$project$Y15D02$ribbon = F3(
	function (l, w, h) {
		var volume = (l * w) * h;
		var perimeters = {
			ctor: '::',
			_0: l + w,
			_1: {
				ctor: '::',
				_0: w + h,
				_1: {
					ctor: '::',
					_0: h + l,
					_1: {ctor: '[]'}
				}
			}
		};
		var perimeter = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$minimum(perimeters));
		return (2 * perimeter) + volume;
	});
var _user$project$Y15D02$wrapping = F3(
	function (l, w, h) {
		var sides = {
			ctor: '::',
			_0: l * w,
			_1: {
				ctor: '::',
				_0: w * h,
				_1: {
					ctor: '::',
					_0: h * l,
					_1: {ctor: '[]'}
				}
			}
		};
		var paper = 2 * _elm_lang$core$List$sum(sides);
		var slack = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$minimum(sides));
		return paper + slack;
	});
var _user$project$Y15D02$sumLine = F3(
	function (counter, line, count) {
		var dimensions = A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Result$withDefault(0),
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$String$toInt,
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.match;
					},
					A3(
						_elm_lang$core$Regex$find,
						_elm_lang$core$Regex$All,
						_elm_lang$core$Regex$regex('[1-9]\\d*'),
						line))));
		var extra = function () {
			var _p0 = dimensions;
			if ((((_p0.ctor === '::') && (_p0._1.ctor === '::')) && (_p0._1._1.ctor === '::')) && (_p0._1._1._1.ctor === '[]')) {
				return A3(counter, _p0._0, _p0._1._0, _p0._1._1._0);
			} else {
				return 0;
			}
		}();
		return count + extra;
	});
var _user$project$Y15D02$sumInput = F2(
	function (counter, input) {
		var lines = A3(
			_elm_lang$core$Regex$split,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('\n'),
			input);
		return A3(
			_elm_lang$core$List$foldl,
			_user$project$Y15D02$sumLine(counter),
			0,
			lines);
	});
var _user$project$Y15D02$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(_user$project$Y15D02$sumInput, _user$project$Y15D02$wrapping, input)) : _elm_lang$core$Basics$toString(
			A2(_user$project$Y15D02$sumInput, _user$project$Y15D02$ribbon, input));
	});

var _user$project$Y15D03$visit = F3(
	function (x, y, visited) {
		var key = A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Basics$toString(x),
			A2(
				_elm_lang$core$Basics_ops['++'],
				'|',
				_elm_lang$core$Basics$toString(y)));
		return A3(_elm_lang$core$Dict$insert, key, true, visited);
	});
var _user$project$Y15D03$errorSanta = function (err) {
	return {
		stop: true,
		x: 0,
		y: 0,
		err: _elm_lang$core$Maybe$Just(err)
	};
};
var _user$project$Y15D03$updateSanta = F2(
	function ($char, santa) {
		var _p0 = $char;
		switch (_p0.valueOf()) {
			case '>':
				return _elm_lang$core$Native_Utils.update(
					santa,
					{x: santa.x + 1});
			case '<':
				return _elm_lang$core$Native_Utils.update(
					santa,
					{x: santa.x - 1});
			case '^':
				return _elm_lang$core$Native_Utils.update(
					santa,
					{y: santa.y + 1});
			case 'v':
				return _elm_lang$core$Native_Utils.update(
					santa,
					{y: santa.y - 1});
			case '\n':
				return _elm_lang$core$Native_Utils.update(
					santa,
					{stop: true});
			default:
				return _user$project$Y15D03$errorSanta(
					A2(
						_elm_lang$core$Basics_ops['++'],
						'illegal instruction [',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString($char),
							']')));
		}
	});
var _user$project$Y15D03$deliver = F2(
	function (model, instructions) {
		deliver:
		while (true) {
			if (_elm_lang$core$String$isEmpty(instructions)) {
				return model;
			} else {
				var index = A2(
					_elm_lang$core$Basics$rem,
					model.turn,
					_elm_lang$core$Array$length(model.santas));
				var santa = A2(
					_elm_lang$core$Maybe$withDefault,
					_user$project$Y15D03$errorSanta(
						A2(
							_elm_lang$core$Basics_ops['++'],
							'illegal index [',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(index),
								']'))),
					A2(_elm_lang$core$Array$get, index, model.santas));
				var next = _elm_lang$core$String$uncons(instructions);
				var _p1 = function () {
					var _p2 = next;
					if ((_p2.ctor === 'Just') && (_p2._0.ctor === '_Tuple2')) {
						return {ctor: '_Tuple2', _0: _p2._0._0, _1: _p2._0._1};
					} else {
						return {
							ctor: '_Tuple2',
							_0: _elm_lang$core$Native_Utils.chr('*'),
							_1: ''
						};
					}
				}();
				var $char = _p1._0;
				var remaining = _p1._1;
				var santa_ = A2(_user$project$Y15D03$updateSanta, $char, santa);
				if (santa_.stop) {
					return _elm_lang$core$Native_Utils.update(
						model,
						{err: santa.err});
				} else {
					var model_ = _elm_lang$core$Native_Utils.update(
						model,
						{
							visited: A3(_user$project$Y15D03$visit, santa_.x, santa_.y, model.visited),
							turn: model.turn + 1,
							santas: A3(_elm_lang$core$Array$set, index, santa_, model.santas)
						});
					var _v2 = model_,
						_v3 = remaining;
					model = _v2;
					instructions = _v3;
					continue deliver;
				}
			}
		}
	});
var _user$project$Y15D03$initSanta = {stop: false, x: 0, y: 0, err: _elm_lang$core$Maybe$Nothing};
var _user$project$Y15D03$initModel = function (n) {
	return {
		visited: A3(_user$project$Y15D03$visit, 0, 0, _elm_lang$core$Dict$empty),
		santas: A2(_elm_lang$core$Array$repeat, n, _user$project$Y15D03$initSanta),
		turn: 0,
		err: _elm_lang$core$Maybe$Nothing
	};
};
var _user$project$Y15D03$christmas = F2(
	function (n, input) {
		var model = A2(
			_user$project$Y15D03$deliver,
			_user$project$Y15D03$initModel(n),
			input);
		var _p3 = model.err;
		if (_p3.ctor === 'Just') {
			return _p3._0;
		} else {
			return _elm_lang$core$Basics$toString(
				_elm_lang$core$List$length(
					_elm_lang$core$Dict$keys(model.visited)));
		}
	});
var _user$project$Y15D03$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A2(_user$project$Y15D03$christmas, 1, input) : A2(_user$project$Y15D03$christmas, 2, input);
	});
var _user$project$Y15D03$Santa = F4(
	function (a, b, c, d) {
		return {stop: a, x: b, y: c, err: d};
	});
var _user$project$Y15D03$Model = F4(
	function (a, b, c, d) {
		return {visited: a, santas: b, turn: c, err: d};
	});

var _user$project$Y15D04$find = F3(
	function (step, start, key) {
		find:
		while (true) {
			var hash = _sanichi$elm_md5$MD5$hex(
				A2(
					_elm_lang$core$Basics_ops['++'],
					key,
					_elm_lang$core$Basics$toString(step)));
			if (A2(_elm_lang$core$String$startsWith, start, hash)) {
				return step;
			} else {
				var _v0 = step + 1,
					_v1 = start,
					_v2 = key;
				step = _v0;
				start = _v1;
				key = _v2;
				continue find;
			}
		}
	});
var _user$project$Y15D04$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'no secret key found',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('[a-z]+'),
					input))));
};
var _user$project$Y15D04$answer = F2(
	function (part, input) {
		var key = _user$project$Y15D04$parse(input);
		var a1 = A3(_user$project$Y15D04$find, 1, '00000', key);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(a1) : _elm_lang$core$Basics$toString(
			A3(_user$project$Y15D04$find, a1, '000000', key));
	});

var _user$project$Y15D05$twipsRgx = _elm_lang$core$Regex$regex('(.).\\1');
var _user$project$Y15D05$pairsRgx = _elm_lang$core$Regex$regex('(..).*\\1');
var _user$project$Y15D05$badieRgx = _elm_lang$core$Regex$regex('(:?ab|cd|pq|xy)');
var _user$project$Y15D05$dubleRgx = _elm_lang$core$Regex$regex('(.)\\1');
var _user$project$Y15D05$vowelRgx = _elm_lang$core$Regex$regex('[aeiou]');
var _user$project$Y15D05$stringRgx = _elm_lang$core$Regex$regex('[a-z]{10,}');
var _user$project$Y15D05$count = F2(
	function (rgx, string) {
		return _elm_lang$core$List$length(
			A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, rgx, string));
	});
var _user$project$Y15D05$nice2 = function (string) {
	var twips = A2(_user$project$Y15D05$count, _user$project$Y15D05$twipsRgx, string);
	var pairs = A2(_user$project$Y15D05$count, _user$project$Y15D05$pairsRgx, string);
	return (_elm_lang$core$Native_Utils.cmp(pairs, 0) > 0) && (_elm_lang$core$Native_Utils.cmp(twips, 0) > 0);
};
var _user$project$Y15D05$nice1 = function (string) {
	var badies = A2(_user$project$Y15D05$count, _user$project$Y15D05$badieRgx, string);
	var dubles = A2(_user$project$Y15D05$count, _user$project$Y15D05$dubleRgx, string);
	var vowels = A2(_user$project$Y15D05$count, _user$project$Y15D05$vowelRgx, string);
	return (_elm_lang$core$Native_Utils.cmp(vowels, 3) > -1) && ((_elm_lang$core$Native_Utils.cmp(dubles, 0) > 0) && _elm_lang$core$Native_Utils.eq(badies, 0));
};
var _user$project$Y15D05$countNice = F2(
	function (nice, strings) {
		return _elm_lang$core$Basics$toString(
			_elm_lang$core$List$length(
				A2(_elm_lang$core$List$filter, nice, strings)));
	});
var _user$project$Y15D05$answer = F2(
	function (part, input) {
		var strings = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.match;
			},
			A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, _user$project$Y15D05$stringRgx, input));
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A2(_user$project$Y15D05$countNice, _user$project$Y15D05$nice1, strings) : A2(_user$project$Y15D05$countNice, _user$project$Y15D05$nice2, strings);
	});

var _user$project$Y15D06$initModel = {
	ctor: '_Tuple2',
	_0: A2(_elm_lang$core$Array$repeat, 1000000, 0),
	_1: A2(_elm_lang$core$Array$repeat, 1000000, 0)
};
var _user$project$Y15D06$index = function (instruction) {
	var y = _elm_lang$core$Tuple$second(instruction.from);
	var x = _elm_lang$core$Tuple$first(instruction.from);
	return x + (1000 * y);
};
var _user$project$Y15D06$updateCell = F2(
	function (instruction, lights) {
		var l2 = _elm_lang$core$Tuple$second(lights);
		var l1 = _elm_lang$core$Tuple$first(lights);
		var k = _user$project$Y15D06$index(instruction);
		var v1 = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(_elm_lang$core$Array$get, k, l1));
		var v1_ = function () {
			var _p0 = instruction.action;
			switch (_p0.ctor) {
				case 'Toggle':
					return _elm_lang$core$Native_Utils.eq(v1, 1) ? 0 : 1;
				case 'On':
					return 1;
				default:
					return 0;
			}
		}();
		var v2 = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(_elm_lang$core$Array$get, k, l2));
		var v2_ = function () {
			var _p1 = instruction.action;
			switch (_p1.ctor) {
				case 'Toggle':
					return v2 + 2;
				case 'On':
					return v2 + 1;
				default:
					return _elm_lang$core$Native_Utils.eq(v2, 0) ? 0 : (v2 - 1);
			}
		}();
		return {
			ctor: '_Tuple2',
			_0: A3(_elm_lang$core$Array$set, k, v1_, l1),
			_1: A3(_elm_lang$core$Array$set, k, v2_, l2)
		};
	});
var _user$project$Y15D06$updateCol = F2(
	function (instruction, lights) {
		updateCol:
		while (true) {
			var ty = _elm_lang$core$Tuple$second(instruction.to);
			var fy = _elm_lang$core$Tuple$second(instruction.from);
			var lights_ = A2(_user$project$Y15D06$updateCell, instruction, lights);
			if (_elm_lang$core$Native_Utils.eq(fy, ty)) {
				return lights_;
			} else {
				var tx = _elm_lang$core$Tuple$first(instruction.to);
				var fx = _elm_lang$core$Tuple$first(instruction.from);
				var instruction_ = _elm_lang$core$Native_Utils.update(
					instruction,
					{
						from: {ctor: '_Tuple2', _0: fx, _1: fy + 1},
						to: {ctor: '_Tuple2', _0: tx, _1: ty}
					});
				var _v2 = instruction_,
					_v3 = lights_;
				instruction = _v2;
				lights = _v3;
				continue updateCol;
			}
		}
	});
var _user$project$Y15D06$updateRow = F2(
	function (instruction, lights) {
		updateRow:
		while (true) {
			var tx = _elm_lang$core$Tuple$first(instruction.to);
			var fx = _elm_lang$core$Tuple$first(instruction.from);
			var lights_ = A2(_user$project$Y15D06$updateCol, instruction, lights);
			if (_elm_lang$core$Native_Utils.eq(fx, tx)) {
				return lights_;
			} else {
				var ty = _elm_lang$core$Tuple$second(instruction.to);
				var fy = _elm_lang$core$Tuple$second(instruction.from);
				var instruction_ = _elm_lang$core$Native_Utils.update(
					instruction,
					{
						from: {ctor: '_Tuple2', _0: fx + 1, _1: fy},
						to: {ctor: '_Tuple2', _0: tx, _1: ty}
					});
				var _v4 = instruction_,
					_v5 = lights_;
				instruction = _v4;
				lights = _v5;
				continue updateRow;
			}
		}
	});
var _user$project$Y15D06$process = F2(
	function (instructions, lights) {
		process:
		while (true) {
			var _p2 = instructions;
			if (_p2.ctor === '[]') {
				return lights;
			} else {
				var lights_ = A2(_user$project$Y15D06$updateRow, _p2._0, lights);
				var _v7 = _p2._1,
					_v8 = lights_;
				instructions = _v7;
				lights = _v8;
				continue process;
			}
		}
	});
var _user$project$Y15D06$Instruction = F3(
	function (a, b, c) {
		return {action: a, from: b, to: c};
	});
var _user$project$Y15D06$Off = {ctor: 'Off'};
var _user$project$Y15D06$On = {ctor: 'On'};
var _user$project$Y15D06$Toggle = {ctor: 'Toggle'};
var _user$project$Y15D06$badInstruction = {
	action: _user$project$Y15D06$Toggle,
	from: {ctor: '_Tuple2', _0: 1, _1: 1},
	to: {ctor: '_Tuple2', _0: 0, _1: 0}
};
var _user$project$Y15D06$parseInstruction = function (submatches) {
	var _p3 = submatches;
	if (((((((((((_p3.ctor === '::') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === '::')) && (_p3._1._0.ctor === 'Just')) && (_p3._1._1.ctor === '::')) && (_p3._1._1._0.ctor === 'Just')) && (_p3._1._1._1.ctor === '::')) && (_p3._1._1._1._0.ctor === 'Just')) && (_p3._1._1._1._1.ctor === '::')) && (_p3._1._1._1._1._0.ctor === 'Just')) && (_p3._1._1._1._1._1.ctor === '[]')) {
		var ty_ = _elm_lang$core$String$toInt(_p3._1._1._1._1._0._0);
		var tx_ = _elm_lang$core$String$toInt(_p3._1._1._1._0._0);
		var fy_ = _elm_lang$core$String$toInt(_p3._1._1._0._0);
		var fx_ = _elm_lang$core$String$toInt(_p3._1._0._0);
		var a_ = function () {
			var _p4 = _p3._0._0;
			switch (_p4) {
				case 'toggle':
					return _elm_lang$core$Maybe$Just(_user$project$Y15D06$Toggle);
				case 'turn on':
					return _elm_lang$core$Maybe$Just(_user$project$Y15D06$On);
				case 'turn off':
					return _elm_lang$core$Maybe$Just(_user$project$Y15D06$Off);
				default:
					return _elm_lang$core$Maybe$Nothing;
			}
		}();
		var _p5 = {ctor: '_Tuple5', _0: a_, _1: fx_, _2: fy_, _3: tx_, _4: ty_};
		if ((((((_p5.ctor === '_Tuple5') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === 'Ok')) && (_p5._2.ctor === 'Ok')) && (_p5._3.ctor === 'Ok')) && (_p5._4.ctor === 'Ok')) {
			var _p9 = _p5._4._0;
			var _p8 = _p5._3._0;
			var _p7 = _p5._2._0;
			var _p6 = _p5._1._0;
			return ((_elm_lang$core$Native_Utils.cmp(_p6, 0) > -1) && ((_elm_lang$core$Native_Utils.cmp(_p7, 0) > -1) && ((_elm_lang$core$Native_Utils.cmp(_p6, _p8) < 1) && ((_elm_lang$core$Native_Utils.cmp(_p7, _p9) < 1) && ((_elm_lang$core$Native_Utils.cmp(_p8, 1000) < 0) && (_elm_lang$core$Native_Utils.cmp(_p9, 1000) < 0)))))) ? {
				action: _p5._0._0,
				from: {ctor: '_Tuple2', _0: _p6, _1: _p7},
				to: {ctor: '_Tuple2', _0: _p8, _1: _p9}
			} : _user$project$Y15D06$badInstruction;
		} else {
			return _user$project$Y15D06$badInstruction;
		}
	} else {
		return _user$project$Y15D06$badInstruction;
	}
};
var _user$project$Y15D06$parse = function (input) {
	var rgx = _elm_lang$core$Regex$regex('(toggle|turn (?:on|off)) (\\d+),(\\d+) through (\\d+),(\\d+)');
	return A2(
		_elm_lang$core$List$filter,
		function (i) {
			return !_elm_lang$core$Native_Utils.eq(i, _user$project$Y15D06$badInstruction);
		},
		A2(
			_elm_lang$core$List$map,
			_user$project$Y15D06$parseInstruction,
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.submatches;
				},
				A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, rgx, input))));
};
var _user$project$Y15D06$answer = F2(
	function (part, input) {
		var instructions = _user$project$Y15D06$parse(input);
		var model = A2(_user$project$Y15D06$process, instructions, _user$project$Y15D06$initModel);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_elm_lang$core$List$length(
				A2(
					_elm_lang$core$List$filter,
					function (l) {
						return _elm_lang$core$Native_Utils.eq(l, 1);
					},
					_elm_lang$core$Array$toList(
						_elm_lang$core$Tuple$first(model))))) : _elm_lang$core$Basics$toString(
			_elm_lang$core$List$sum(
				_elm_lang$core$Array$toList(
					_elm_lang$core$Tuple$second(model))));
	});

var _user$project$Y15D07$maxValue = 65535;
var _user$project$Y15D07$parseInt = function (i) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(i));
};
var _user$project$Y15D07$getVal = F2(
	function (wire, circuit) {
		var val = A2(_elm_lang$core$Dict$get, wire, circuit);
		var _p0 = val;
		if (_p0.ctor === 'Nothing') {
			return 0;
		} else {
			var _p1 = _p0._0;
			if (_p1.ctor === 'NoOp') {
				return _p1._0;
			} else {
				return 0;
			}
		}
	});
var _user$project$Y15D07$Not = function (a) {
	return {ctor: 'Not', _0: a};
};
var _user$project$Y15D07$Rshift = F2(
	function (a, b) {
		return {ctor: 'Rshift', _0: a, _1: b};
	});
var _user$project$Y15D07$Lshift = F2(
	function (a, b) {
		return {ctor: 'Lshift', _0: a, _1: b};
	});
var _user$project$Y15D07$Or = F2(
	function (a, b) {
		return {ctor: 'Or', _0: a, _1: b};
	});
var _user$project$Y15D07$And = F2(
	function (a, b) {
		return {ctor: 'And', _0: a, _1: b};
	});
var _user$project$Y15D07$Pass = function (a) {
	return {ctor: 'Pass', _0: a};
};
var _user$project$Y15D07$NoOp = function (a) {
	return {ctor: 'NoOp', _0: a};
};
var _user$project$Y15D07$reduce = F2(
	function (wire, circuit) {
		var val = A2(_elm_lang$core$Dict$get, wire, circuit);
		var _p2 = val;
		if (_p2.ctor === 'Nothing') {
			return A3(
				_elm_lang$core$Dict$insert,
				wire,
				_user$project$Y15D07$NoOp(0),
				circuit);
		} else {
			var _p3 = function () {
				var _p4 = _p2._0;
				switch (_p4.ctor) {
					case 'NoOp':
						return {ctor: '_Tuple3', _0: _p4._0, _1: circuit, _2: false};
					case 'Pass':
						var _p5 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var i = _p5._0;
						var c = _p5._1;
						return {ctor: '_Tuple3', _0: i, _1: c, _2: true};
					case 'And':
						var _p6 = A3(_user$project$Y15D07$reduce2, _p4._0, _p4._1, circuit);
						var i = _p6._0;
						var j = _p6._1;
						var c = _p6._2;
						return {ctor: '_Tuple3', _0: i & j, _1: c, _2: true};
					case 'Or':
						var _p7 = A3(_user$project$Y15D07$reduce2, _p4._0, _p4._1, circuit);
						var i = _p7._0;
						var j = _p7._1;
						var c = _p7._2;
						return {ctor: '_Tuple3', _0: i | j, _1: c, _2: true};
					case 'Lshift':
						var _p8 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var j = _p8._0;
						var c = _p8._1;
						var k = j << _p4._1;
						return {ctor: '_Tuple3', _0: k, _1: c, _2: true};
					case 'Rshift':
						var _p9 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var j = _p9._0;
						var c = _p9._1;
						return {ctor: '_Tuple3', _0: j >> _p4._1, _1: c, _2: true};
					default:
						var _p10 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var i = _p10._0;
						var c = _p10._1;
						var j = ~i;
						var k = (_elm_lang$core$Native_Utils.cmp(j, 0) < 0) ? ((_user$project$Y15D07$maxValue + j) + 1) : j;
						return {ctor: '_Tuple3', _0: k, _1: c, _2: true};
				}
			}();
			var k = _p3._0;
			var circuit_ = _p3._1;
			var insert = _p3._2;
			return insert ? A3(
				_elm_lang$core$Dict$insert,
				wire,
				_user$project$Y15D07$NoOp(k),
				circuit_) : circuit_;
		}
	});
var _user$project$Y15D07$reduce1 = F2(
	function (w, circuit) {
		var i = _elm_lang$core$String$toInt(w);
		var _p11 = i;
		if (_p11.ctor === 'Ok') {
			return {ctor: '_Tuple2', _0: _p11._0, _1: circuit};
		} else {
			var circuit_ = A2(_user$project$Y15D07$reduce, w, circuit);
			return {
				ctor: '_Tuple2',
				_0: A2(_user$project$Y15D07$getVal, w, circuit_),
				_1: circuit_
			};
		}
	});
var _user$project$Y15D07$reduce2 = F3(
	function (w1, w2, circuit) {
		var i2 = _elm_lang$core$String$toInt(w2);
		var i1 = _elm_lang$core$String$toInt(w1);
		var _p12 = {ctor: '_Tuple2', _0: i1, _1: i2};
		if (_p12._0.ctor === 'Ok') {
			if (_p12._1.ctor === 'Ok') {
				return {ctor: '_Tuple3', _0: _p12._0._0, _1: _p12._1._0, _2: circuit};
			} else {
				var circuit_ = A2(_user$project$Y15D07$reduce, w2, circuit);
				return {
					ctor: '_Tuple3',
					_0: _p12._0._0,
					_1: A2(_user$project$Y15D07$getVal, w2, circuit_),
					_2: circuit_
				};
			}
		} else {
			if (_p12._1.ctor === 'Ok') {
				var circuit_ = A2(_user$project$Y15D07$reduce, w1, circuit);
				return {
					ctor: '_Tuple3',
					_0: A2(_user$project$Y15D07$getVal, w1, circuit_),
					_1: _p12._1._0,
					_2: circuit_
				};
			} else {
				var circuit_ = A2(_user$project$Y15D07$reduce, w1, circuit);
				var circuit__ = A2(_user$project$Y15D07$reduce, w2, circuit_);
				return {
					ctor: '_Tuple3',
					_0: A2(_user$project$Y15D07$getVal, w1, circuit_),
					_1: A2(_user$project$Y15D07$getVal, w2, circuit__),
					_2: circuit__
				};
			}
		}
	});
var _user$project$Y15D07$parseConnection = function (connection) {
	var words = A2(_elm_lang$core$String$split, ' ', connection);
	var _p13 = words;
	_v6_6:
	do {
		if (((_p13.ctor === '::') && (_p13._1.ctor === '::')) && (_p13._1._1.ctor === '::')) {
			if (_p13._1._1._1.ctor === '[]') {
				if (_p13._1._0 === '->') {
					return {
						ctor: '_Tuple2',
						_0: _p13._1._1._0,
						_1: _user$project$Y15D07$Pass(_p13._0)
					};
				} else {
					break _v6_6;
				}
			} else {
				if (_p13._1._1._1._1.ctor === '::') {
					if ((_p13._1._1._1._0 === '->') && (_p13._1._1._1._1._1.ctor === '[]')) {
						switch (_p13._1._0) {
							case 'AND':
								return {
									ctor: '_Tuple2',
									_0: _p13._1._1._1._1._0,
									_1: A2(_user$project$Y15D07$And, _p13._0, _p13._1._1._0)
								};
							case 'OR':
								return {
									ctor: '_Tuple2',
									_0: _p13._1._1._1._1._0,
									_1: A2(_user$project$Y15D07$Or, _p13._0, _p13._1._1._0)
								};
							case 'LSHIFT':
								return {
									ctor: '_Tuple2',
									_0: _p13._1._1._1._1._0,
									_1: A2(
										_user$project$Y15D07$Lshift,
										_p13._0,
										_user$project$Y15D07$parseInt(_p13._1._1._0))
								};
							case 'RSHIFT':
								return {
									ctor: '_Tuple2',
									_0: _p13._1._1._1._1._0,
									_1: A2(
										_user$project$Y15D07$Rshift,
										_p13._0,
										_user$project$Y15D07$parseInt(_p13._1._1._0))
								};
							default:
								break _v6_6;
						}
					} else {
						break _v6_6;
					}
				} else {
					if ((_p13._0 === 'NOT') && (_p13._1._1._0 === '->')) {
						return {
							ctor: '_Tuple2',
							_0: _p13._1._1._1._0,
							_1: _user$project$Y15D07$Not(_p13._1._0)
						};
					} else {
						break _v6_6;
					}
				}
			}
		} else {
			break _v6_6;
		}
	} while(false);
	return {
		ctor: '_Tuple2',
		_0: connection,
		_1: _user$project$Y15D07$NoOp(0)
	};
};
var _user$project$Y15D07$parseLines = F2(
	function (lines, circuit) {
		parseLines:
		while (true) {
			var _p14 = lines;
			if (_p14.ctor === '[]') {
				return circuit;
			} else {
				var _p16 = _p14._1;
				var _p15 = _user$project$Y15D07$parseConnection(_p14._0);
				var wire = _p15._0;
				var action = _p15._1;
				var circuit_ = A3(_elm_lang$core$Dict$insert, wire, action, circuit);
				if (_elm_lang$core$Native_Utils.eq(wire, '') && _elm_lang$core$Native_Utils.eq(
					action,
					_user$project$Y15D07$NoOp(0))) {
					var _v8 = _p16,
						_v9 = circuit;
					lines = _v8;
					circuit = _v9;
					continue parseLines;
				} else {
					var _v10 = _p16,
						_v11 = circuit_;
					lines = _v10;
					circuit = _v11;
					continue parseLines;
				}
			}
		}
	});
var _user$project$Y15D07$parseInput = function (input) {
	return A2(
		_user$project$Y15D07$parseLines,
		A2(_elm_lang$core$String$split, '\n', input),
		_elm_lang$core$Dict$empty);
};
var _user$project$Y15D07$answer = F2(
	function (part, input) {
		var circuit = _user$project$Y15D07$parseInput(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y15D07$getVal,
				'a',
				A2(_user$project$Y15D07$reduce, 'a', circuit))) : _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y15D07$getVal,
				'a',
				A2(
					_user$project$Y15D07$reduce,
					'a',
					A3(
						_elm_lang$core$Dict$insert,
						'b',
						_user$project$Y15D07$NoOp(3176),
						circuit))));
	});

var _user$project$Y15D08$escape = function (line) {
	var r1 = A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\\\\'),
		function (_p0) {
			return '\\\\';
		},
		line);
	var r2 = A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\"'),
		function (_p1) {
			return '\\\"';
		},
		r1);
	var r3 = A2(
		_elm_lang$core$Basics_ops['++'],
		'\"',
		A2(_elm_lang$core$Basics_ops['++'], r2, '\"'));
	return r3;
};
var _user$project$Y15D08$unescape = function (line) {
	var r1 = A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('(^\"|\"$)'),
		function (_p2) {
			return '';
		},
		line);
	var r2 = A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\\\\\"'),
		function (_p3) {
			return '_';
		},
		r1);
	var r3 = A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\\\\\\\\'),
		function (_p4) {
			return '.';
		},
		r2);
	var r4 = A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\\\\x[0-9a-f]{2}'),
		function (_p5) {
			return '-';
		},
		r3);
	return r4;
};
var _user$project$Y15D08$escLength = function (lines) {
	return _elm_lang$core$List$sum(
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$String$length,
			A2(_elm_lang$core$List$map, _user$project$Y15D08$escape, lines)));
};
var _user$project$Y15D08$memLength = function (lines) {
	return _elm_lang$core$List$sum(
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$String$length,
			A2(_elm_lang$core$List$map, _user$project$Y15D08$unescape, lines)));
};
var _user$project$Y15D08$chrLength = function (lines) {
	return _elm_lang$core$List$sum(
		A2(_elm_lang$core$List$map, _elm_lang$core$String$length, lines));
};
var _user$project$Y15D08$parseInput = function (input) {
	return A2(
		_elm_lang$core$List$filter,
		function (l) {
			return !_elm_lang$core$Native_Utils.eq(l, '');
		},
		A2(_elm_lang$core$String$split, '\n', input));
};
var _user$project$Y15D08$answer = F2(
	function (part, input) {
		var strings = _user$project$Y15D08$parseInput(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_user$project$Y15D08$chrLength(strings) - _user$project$Y15D08$memLength(strings)) : _elm_lang$core$Basics$toString(
			_user$project$Y15D08$escLength(strings) - _user$project$Y15D08$chrLength(strings));
	});

var _user$project$Util$select = function (xs) {
	var _p0 = xs;
	if (_p0.ctor === '[]') {
		return {ctor: '[]'};
	} else {
		var _p4 = _p0._1;
		var _p3 = _p0._0;
		return {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _p3, _1: _p4},
			_1: A2(
				_elm_lang$core$List$map,
				function (_p1) {
					var _p2 = _p1;
					return {
						ctor: '_Tuple2',
						_0: _p2._0,
						_1: {ctor: '::', _0: _p3, _1: _p2._1}
					};
				},
				_user$project$Util$select(_p4))
		};
	}
};
var _user$project$Util$permutations = function (xs) {
	var _p5 = xs;
	if (_p5.ctor === '[]') {
		return {
			ctor: '::',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		};
	} else {
		var f = function (_p6) {
			var _p7 = _p6;
			return A2(
				_elm_lang$core$List$map,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					})(_p7._0),
				_user$project$Util$permutations(_p7._1));
		};
		return A2(
			_elm_lang$core$List$concatMap,
			f,
			_user$project$Util$select(_p5));
	}
};
var _user$project$Util$onlyOnePart = 'no part two for this day';
var _user$project$Util$failed = 'failed to solve this part';
var _user$project$Util$combinations = F2(
	function (n, list) {
		return ((_elm_lang$core$Native_Utils.cmp(n, 0) < 0) || (_elm_lang$core$Native_Utils.cmp(
			n,
			_elm_lang$core$List$length(list)) > 0)) ? {ctor: '[]'} : A2(_user$project$Util$combo, n, list);
	});
var _user$project$Util$combo = F2(
	function (n, list) {
		if (_elm_lang$core$Native_Utils.eq(n, 0)) {
			return {
				ctor: '::',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			};
		} else {
			if (_elm_lang$core$Native_Utils.eq(
				n,
				_elm_lang$core$List$length(list))) {
				return {
					ctor: '::',
					_0: list,
					_1: {ctor: '[]'}
				};
			} else {
				var _p8 = list;
				if (_p8.ctor === '[]') {
					return {ctor: '[]'};
				} else {
					var _p9 = _p8._1;
					var c2 = A2(_user$project$Util$combinations, n, _p9);
					var c1 = A2(
						_elm_lang$core$List$map,
						F2(
							function (x, y) {
								return {ctor: '::', _0: x, _1: y};
							})(_p8._0),
						A2(_user$project$Util$combinations, n - 1, _p9));
					return A2(_elm_lang$core$Basics_ops['++'], c1, c2);
				}
			}
		}
	});
var _user$project$Util$join = F2(
	function (p1, p2) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			p1,
			A2(_elm_lang$core$Basics_ops['++'], ' | ', p2));
	});

var _user$project$Y15D09$initModel = {
	distances: _elm_lang$core$Dict$empty,
	cities: {ctor: '[]'}
};
var _user$project$Y15D09$key = F2(
	function (c1, c2) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			c1,
			A2(_elm_lang$core$Basics_ops['++'], '|', c2));
	});
var _user$project$Y15D09$pairs = function (list) {
	var _p0 = list;
	if (_p0.ctor === '[]') {
		return {ctor: '[]'};
	} else {
		if (_p0._1.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var _p1 = _p0._1._0;
			return {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: _p0._0, _1: _p1},
				_1: _user$project$Y15D09$pairs(
					{ctor: '::', _0: _p1, _1: _p0._1._1})
			};
		}
	}
};
var _user$project$Y15D09$parseLine = F2(
	function (line, model) {
		var matches = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex('^(\\w+) to (\\w+) = (\\d+)$'),
				line));
		var _p2 = matches;
		if (((((((((_p2.ctor === '::') && (_p2._0.ctor === '::')) && (_p2._0._0.ctor === 'Just')) && (_p2._0._1.ctor === '::')) && (_p2._0._1._0.ctor === 'Just')) && (_p2._0._1._1.ctor === '::')) && (_p2._0._1._1._0.ctor === 'Just')) && (_p2._0._1._1._1.ctor === '[]')) && (_p2._1.ctor === '[]')) {
			var _p4 = _p2._0._1._0._0;
			var _p3 = _p2._0._0._0;
			var cities_ = A2(_elm_lang$core$List$member, _p3, model.cities) ? model.cities : {ctor: '::', _0: _p3, _1: model.cities};
			var cities = A2(_elm_lang$core$List$member, _p4, cities_) ? cities_ : {ctor: '::', _0: _p4, _1: cities_};
			var di = A2(
				_elm_lang$core$Result$withDefault,
				0,
				_elm_lang$core$String$toInt(_p2._0._1._1._0._0));
			var distances = A3(
				_elm_lang$core$Dict$insert,
				A2(_user$project$Y15D09$key, _p4, _p3),
				di,
				A3(
					_elm_lang$core$Dict$insert,
					A2(_user$project$Y15D09$key, _p3, _p4),
					di,
					model.distances));
			return _elm_lang$core$Native_Utils.update(
				model,
				{distances: distances, cities: cities});
		} else {
			return model;
		}
	});
var _user$project$Y15D09$parseInput = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D09$parseLine,
		_user$project$Y15D09$initModel,
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D09$extreme = function (model) {
	var f = function (_p5) {
		var _p6 = _p5;
		return A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(
				_elm_lang$core$Dict$get,
				A2(_user$project$Y15D09$key, _p6._0, _p6._1),
				model.distances));
	};
	return A2(
		_elm_lang$core$List$map,
		function (p) {
			return _elm_lang$core$List$sum(
				A2(_elm_lang$core$List$map, f, p));
		},
		A2(
			_elm_lang$core$List$map,
			function (perm) {
				return _user$project$Y15D09$pairs(perm);
			},
			_user$project$Util$permutations(model.cities)));
};
var _user$project$Y15D09$answer = F2(
	function (part, input) {
		var model = _user$project$Y15D09$parseInput(input);
		var extremes = _user$project$Y15D09$extreme(model);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$minimum(extremes))) : _elm_lang$core$Basics$toString(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$maximum(extremes)));
	});
var _user$project$Y15D09$Model = F2(
	function (a, b) {
		return {distances: a, cities: b};
	});

var _user$project$Y15D10$mapper = function (match) {
	var $char = A2(_elm_lang$core$String$left, 1, match.match);
	var length = _elm_lang$core$Basics$toString(
		_elm_lang$core$String$length(match.match));
	return A2(_elm_lang$core$Basics_ops['++'], length, $char);
};
var _user$project$Y15D10$conway = F2(
	function (count, digits) {
		conway:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(count, 0) < 1) {
				return digits;
			} else {
				var digits_ = A4(
					_elm_lang$core$Regex$replace,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('(\\d)\\1*'),
					_user$project$Y15D10$mapper,
					digits);
				var _v0 = count - 1,
					_v1 = digits_;
				count = _v0;
				digits = _v1;
				continue conway;
			}
		}
	});
var _user$project$Y15D10$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'no digits found',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('\\d+'),
					input))));
};
var _user$project$Y15D10$answer = F2(
	function (part, input) {
		var digits = A2(
			_user$project$Y15D10$conway,
			40,
			_user$project$Y15D10$parse(input));
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_elm_lang$core$String$length(digits)) : _elm_lang$core$Basics$toString(
			_elm_lang$core$String$length(
				A2(_user$project$Y15D10$conway, 10, digits)));
	});

var _user$project$Y15D11$has_enough_pairs = function (p) {
	return A2(
		_elm_lang$core$Regex$contains,
		_elm_lang$core$Regex$regex('(.)\\1.*(.)(?!\\1)\\2'),
		p);
};
var _user$project$Y15D11$has_a_straight = function (p) {
	return A2(
		_elm_lang$core$Regex$contains,
		_elm_lang$core$Regex$regex('(abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)'),
		p);
};
var _user$project$Y15D11$is_not_confusing = function (p) {
	return !A2(
		_elm_lang$core$Regex$contains,
		_elm_lang$core$Regex$regex('[iol]'),
		p);
};
var _user$project$Y15D11$increment = function (p) {
	var parts = _elm_lang$core$List$head(
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex('^([a-z]*)([a-y])(z*)$'),
				p)));
	var _p0 = parts;
	if ((((((((_p0.ctor === 'Just') && (_p0._0.ctor === '::')) && (_p0._0._0.ctor === 'Just')) && (_p0._0._1.ctor === '::')) && (_p0._0._1._0.ctor === 'Just')) && (_p0._0._1._1.ctor === '::')) && (_p0._0._1._1._0.ctor === 'Just')) && (_p0._0._1._1._1.ctor === '[]')) {
		var c1 = A2(
			_elm_lang$core$String$repeat,
			_elm_lang$core$String$length(_p0._0._1._1._0._0),
			'a');
		var b1 = _elm_lang$core$String$uncons(_p0._0._1._0._0);
		var b2 = function () {
			var _p1 = b1;
			if ((_p1.ctor === 'Just') && (_p1._0.ctor === '_Tuple2')) {
				return _elm_lang$core$String$fromChar(
					_elm_lang$core$Char$fromCode(
						A2(
							F2(
								function (x, y) {
									return x + y;
								}),
							1,
							_elm_lang$core$Char$toCode(_p1._0._0))));
			} else {
				return '';
			}
		}();
		return A2(
			_elm_lang$core$Regex$contains,
			_elm_lang$core$Regex$regex('^[b-z]$'),
			b2) ? A2(
			_elm_lang$core$Basics_ops['++'],
			_p0._0._0._0,
			A2(_elm_lang$core$Basics_ops['++'], b2, c1)) : A2(
			_elm_lang$core$Basics_ops['++'],
			'invalid (',
			A2(_elm_lang$core$Basics_ops['++'], p, ')'));
	} else {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			'invalid (',
			A2(_elm_lang$core$Basics_ops['++'], p, ')'));
	}
};
var _user$project$Y15D11$next = function (q) {
	next:
	while (true) {
		var p = _user$project$Y15D11$increment(q);
		if (A2(_elm_lang$core$String$startsWith, 'invalid', p)) {
			return p;
		} else {
			if (_user$project$Y15D11$is_not_confusing(p) && (_user$project$Y15D11$has_a_straight(p) && _user$project$Y15D11$has_enough_pairs(p))) {
				return p;
			} else {
				var _v2 = p;
				q = _v2;
				continue next;
			}
		}
	}
};
var _user$project$Y15D11$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'no password found',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('[a-z]{8}'),
					input))));
};
var _user$project$Y15D11$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _user$project$Y15D11$next(
			_user$project$Y15D11$parse(input)) : _user$project$Y15D11$next(
			_user$project$Y15D11$next(
				_user$project$Y15D11$parse(input)));
	});

var _user$project$Y15D12$count = function (json) {
	return _elm_lang$core$Basics$toString(
		_elm_lang$core$List$sum(
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Result$withDefault(0),
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$String$toInt,
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.match;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$All,
							_elm_lang$core$Regex$regex('-?[1-9]\\d*'),
							json))))));
};
var _user$project$Y15D12$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _user$project$Y15D12$count(input) : _user$project$Util$failed;
	});

var _user$project$Y15D13$initModel = {happiness: _elm_lang$core$Dict$empty, people: _elm_lang$core$Set$empty};
var _user$project$Y15D13$outer = function (list) {
	var last = _elm_lang$core$List$head(
		_elm_lang$core$List$reverse(list));
	var first = _elm_lang$core$List$head(list);
	var _p0 = {ctor: '_Tuple2', _0: first, _1: last};
	if (((_p0.ctor === '_Tuple2') && (_p0._0.ctor === 'Just')) && (_p0._1.ctor === 'Just')) {
		return _elm_lang$core$Maybe$Just(
			{ctor: '_Tuple2', _0: _p0._1._0, _1: _p0._0._0});
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _user$project$Y15D13$inner = function (list) {
	var _p1 = list;
	if ((_p1.ctor === '::') && (_p1._1.ctor === '::')) {
		var _p2 = _p1._1._0;
		return {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _p1._0, _1: _p2},
			_1: _user$project$Y15D13$inner(
				{ctor: '::', _0: _p2, _1: _p1._1._1})
		};
	} else {
		return {ctor: '[]'};
	}
};
var _user$project$Y15D13$pairup = function (list) {
	var pair = _user$project$Y15D13$outer(list);
	var pairs = _user$project$Y15D13$inner(list);
	var _p3 = pair;
	if ((_p3.ctor === 'Just') && (_p3._0.ctor === '_Tuple2')) {
		return {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _p3._0._0, _1: _p3._0._1},
			_1: pairs
		};
	} else {
		return pairs;
	}
};
var _user$project$Y15D13$key = F2(
	function (p1, p2) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			p1,
			A2(_elm_lang$core$Basics_ops['++'], '|', p2));
	});
var _user$project$Y15D13$parseLine = F2(
	function (line, model) {
		var matches = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex('^(\\w+) would (gain|lose) (\\d+) happiness units by sitting next to (\\w+)\\.$'),
				line));
		var _p4 = matches;
		if (((((((((((_p4.ctor === '::') && (_p4._0.ctor === '::')) && (_p4._0._0.ctor === 'Just')) && (_p4._0._1.ctor === '::')) && (_p4._0._1._0.ctor === 'Just')) && (_p4._0._1._1.ctor === '::')) && (_p4._0._1._1._0.ctor === 'Just')) && (_p4._0._1._1._1.ctor === '::')) && (_p4._0._1._1._1._0.ctor === 'Just')) && (_p4._0._1._1._1._1.ctor === '[]')) && (_p4._1.ctor === '[]')) {
			var _p6 = _p4._0._1._1._1._0._0;
			var _p5 = _p4._0._0._0;
			var p = A2(
				_elm_lang$core$Set$insert,
				_p6,
				A2(_elm_lang$core$Set$insert, _p5, model.people));
			var j = A2(
				_elm_lang$core$Result$withDefault,
				0,
				_elm_lang$core$String$toInt(_p4._0._1._1._0._0));
			var k = _elm_lang$core$Native_Utils.eq(_p4._0._1._0._0, 'gain') ? j : (0 - j);
			var h = A3(
				_elm_lang$core$Dict$insert,
				A2(_user$project$Y15D13$key, _p5, _p6),
				k,
				model.happiness);
			return {happiness: h, people: p};
		} else {
			return model;
		}
	});
var _user$project$Y15D13$parse = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D13$parseLine,
		_user$project$Y15D13$initModel,
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D13$addMe = function (model) {
	var h0 = model.happiness;
	var a = _elm_lang$core$Set$toList(model.people);
	var me = 'Me';
	var p = A2(_elm_lang$core$Set$insert, me, model.people);
	var h1 = A3(
		_elm_lang$core$List$foldl,
		F2(
			function (p, h) {
				return A3(
					_elm_lang$core$Dict$insert,
					A2(_user$project$Y15D13$key, me, p),
					0,
					h);
			}),
		h0,
		a);
	var h2 = A3(
		_elm_lang$core$List$foldl,
		F2(
			function (p, h) {
				return A3(
					_elm_lang$core$Dict$insert,
					A2(_user$project$Y15D13$key, p, me),
					0,
					h);
			}),
		h1,
		a);
	return {happiness: h2, people: p};
};
var _user$project$Y15D13$pairValue = F3(
	function (p1, p2, h) {
		var v2 = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(
				_elm_lang$core$Dict$get,
				A2(_user$project$Y15D13$key, p2, p1),
				h));
		var v1 = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(
				_elm_lang$core$Dict$get,
				A2(_user$project$Y15D13$key, p1, p2),
				h));
		return v1 + v2;
	});
var _user$project$Y15D13$happinesses = function (model) {
	var f = function (_p7) {
		var _p8 = _p7;
		return A3(_user$project$Y15D13$pairValue, _p8._0, _p8._1, model.happiness);
	};
	return A2(
		_elm_lang$core$List$map,
		function (pairs) {
			return _elm_lang$core$List$sum(
				A2(_elm_lang$core$List$map, f, pairs));
		},
		A2(
			_elm_lang$core$List$map,
			function (perm) {
				return _user$project$Y15D13$pairup(perm);
			},
			_user$project$Util$permutations(
				_elm_lang$core$Set$toList(model.people))));
};
var _user$project$Y15D13$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$maximum(
					_user$project$Y15D13$happinesses(
						_user$project$Y15D13$parse(input))))) : _elm_lang$core$Basics$toString(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$maximum(
					_user$project$Y15D13$happinesses(
						_user$project$Y15D13$addMe(
							_user$project$Y15D13$parse(input))))));
	});
var _user$project$Y15D13$Model = F2(
	function (a, b) {
		return {happiness: a, people: b};
	});

var _user$project$Y15D14$parseLine = F2(
	function (line, model) {
		var matches = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex('^(\\w+) can fly (\\d+) km/s for (\\d+) seconds, but then must rest for (\\d+) seconds\\.$'),
				line));
		var _p0 = matches;
		if (((((((((((_p0.ctor === '::') && (_p0._0.ctor === '::')) && (_p0._0._0.ctor === 'Just')) && (_p0._0._1.ctor === '::')) && (_p0._0._1._0.ctor === 'Just')) && (_p0._0._1._1.ctor === '::')) && (_p0._0._1._1._0.ctor === 'Just')) && (_p0._0._1._1._1.ctor === '::')) && (_p0._0._1._1._1._0.ctor === 'Just')) && (_p0._0._1._1._1._1.ctor === '[]')) && (_p0._1.ctor === '[]')) {
			var r2 = A2(
				_elm_lang$core$Result$withDefault,
				0,
				_elm_lang$core$String$toInt(_p0._0._1._1._1._0._0));
			var t2 = A2(
				_elm_lang$core$Result$withDefault,
				0,
				_elm_lang$core$String$toInt(_p0._0._1._1._0._0));
			var s2 = A2(
				_elm_lang$core$Result$withDefault,
				0,
				_elm_lang$core$String$toInt(_p0._0._1._0._0));
			var reindeer = {name: _p0._0._0._0, speed: s2, time: t2, rest: r2, km: 0, score: 0};
			return {ctor: '::', _0: reindeer, _1: model};
		} else {
			return model;
		}
	});
var _user$project$Y15D14$parse = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D14$parseLine,
		{ctor: '[]'},
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D14$distance = F2(
	function (t, r) {
		var cyc = r.time + r.rest;
		var tmp = A2(_elm_lang$core$Basics$rem, t, cyc);
		var rdr = (_elm_lang$core$Native_Utils.cmp(tmp, r.time) > 0) ? r.time : tmp;
		return ((((t / cyc) | 0) * r.time) + rdr) * r.speed;
	});
var _user$project$Y15D14$score = F3(
	function (t, time, model) {
		score:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(t, time) > -1) {
				return model;
			} else {
				var t_ = t + 1;
				var model1 = A2(
					_elm_lang$core$List$map,
					function (r) {
						return _elm_lang$core$Native_Utils.update(
							r,
							{
								km: A2(_user$project$Y15D14$distance, t_, r)
							});
					},
					model);
				var maxDst = A2(
					_elm_lang$core$Maybe$withDefault,
					0,
					_elm_lang$core$List$maximum(
						A2(
							_elm_lang$core$List$map,
							function (_) {
								return _.km;
							},
							model1)));
				var model2 = A2(
					_elm_lang$core$List$map,
					function (r) {
						return _elm_lang$core$Native_Utils.update(
							r,
							{
								score: r.score + (_elm_lang$core$Native_Utils.eq(r.km, maxDst) ? 1 : 0)
							});
					},
					model1);
				var _v1 = t_,
					_v2 = time,
					_v3 = model2;
				t = _v1;
				time = _v2;
				model = _v3;
				continue score;
			}
		}
	});
var _user$project$Y15D14$bestScore = F2(
	function (time, model) {
		return _elm_lang$core$Basics$toString(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$maximum(
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.score;
						},
						A3(_user$project$Y15D14$score, 0, time, model)))));
	});
var _user$project$Y15D14$maxDistance = F2(
	function (time, model) {
		return _elm_lang$core$Basics$toString(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$maximum(
					A2(
						_elm_lang$core$List$map,
						_user$project$Y15D14$distance(time),
						model))));
	});
var _user$project$Y15D14$answer = F2(
	function (part, input) {
		var time = 2503;
		var model = _user$project$Y15D14$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A2(_user$project$Y15D14$maxDistance, time, model) : A2(_user$project$Y15D14$bestScore, time, model);
	});
var _user$project$Y15D14$Reindeer = F6(
	function (a, b, c, d, e, f) {
		return {name: a, speed: b, time: c, rest: d, km: e, score: f};
	});

var _user$project$Y15D15$initCookie = F2(
	function (model, total) {
		var size = _elm_lang$core$List$length(model);
		var first = (total - size) + 1;
		var ones = A2(_elm_lang$core$List$repeat, size - 1, 1);
		return {ctor: '::', _0: first, _1: ones};
	});
var _user$project$Y15D15$parseInt = function (s) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(s));
};
var _user$project$Y15D15$score = F3(
	function (m, calories, cookie) {
		var excluded = function () {
			var _p0 = calories;
			if (_p0.ctor === 'Just') {
				return !_elm_lang$core$Native_Utils.eq(
					_p0._0,
					_elm_lang$core$List$sum(
						A3(
							_elm_lang$core$List$map2,
							F2(
								function (x, y) {
									return x * y;
								}),
							A2(
								_elm_lang$core$List$map,
								function (_) {
									return _.calories;
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
			var tx = _elm_lang$core$List$sum(
				A3(
					_elm_lang$core$List$map2,
					F2(
						function (x, y) {
							return x * y;
						}),
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.texture;
						},
						m),
					cookie));
			var fl = _elm_lang$core$List$sum(
				A3(
					_elm_lang$core$List$map2,
					F2(
						function (x, y) {
							return x * y;
						}),
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.flavor;
						},
						m),
					cookie));
			var du = _elm_lang$core$List$sum(
				A3(
					_elm_lang$core$List$map2,
					F2(
						function (x, y) {
							return x * y;
						}),
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.durability;
						},
						m),
					cookie));
			var cp = _elm_lang$core$List$sum(
				A3(
					_elm_lang$core$List$map2,
					F2(
						function (x, y) {
							return x * y;
						}),
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.capacity;
						},
						m),
					cookie));
			return _elm_lang$core$List$product(
				A2(
					_elm_lang$core$List$map,
					function (s) {
						return (_elm_lang$core$Native_Utils.cmp(s, 0) < 0) ? 0 : s;
					},
					{
						ctor: '::',
						_0: cp,
						_1: {
							ctor: '::',
							_0: du,
							_1: {
								ctor: '::',
								_0: fl,
								_1: {
									ctor: '::',
									_0: tx,
									_1: {ctor: '[]'}
								}
							}
						}
					}));
		}
	});
var _user$project$Y15D15$increment = function (l) {
	var _p1 = l;
	if (_p1.ctor === '[]') {
		return {ctor: '[]'};
	} else {
		return {ctor: '::', _0: _p1._0 + 1, _1: _p1._1};
	}
};
var _user$project$Y15D15$rollover = function (l) {
	rollover:
	while (true) {
		var _p2 = l;
		if (_p2.ctor === '[]') {
			return {
				ctor: '_Tuple2',
				_0: 0,
				_1: {ctor: '[]'}
			};
		} else {
			if (_p2._0 === 1) {
				var _v3 = _p2._1;
				l = _v3;
				continue rollover;
			} else {
				return {
					ctor: '_Tuple2',
					_0: _p2._0 - 1,
					_1: _user$project$Y15D15$increment(_p2._1)
				};
			}
		}
	}
};
var _user$project$Y15D15$next = function (c) {
	var _p3 = c;
	if (_p3.ctor === '[]') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		if (_p3._0 === 1) {
			var _p4 = _user$project$Y15D15$rollover(_p3._1);
			var n = _p4._0;
			var l = _p4._1;
			if (_elm_lang$core$Native_Utils.eq(n, 0)) {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var ones = A2(
					_elm_lang$core$List$repeat,
					(_elm_lang$core$List$length(c) - _elm_lang$core$List$length(l)) - 1,
					1);
				return _elm_lang$core$Maybe$Just(
					{
						ctor: '::',
						_0: n,
						_1: A2(_elm_lang$core$Basics_ops['++'], ones, l)
					});
			}
		} else {
			return _elm_lang$core$Maybe$Just(
				{
					ctor: '::',
					_0: _p3._0 - 1,
					_1: _user$project$Y15D15$increment(_p3._1)
				});
		}
	}
};
var _user$project$Y15D15$highScore = F4(
	function (model, calories, oldHigh, oldCookie) {
		highScore:
		while (true) {
			var newCookie = _user$project$Y15D15$next(oldCookie);
			var newHigh = A2(
				_elm_lang$core$Maybe$withDefault,
				oldHigh,
				_elm_lang$core$List$maximum(
					{
						ctor: '::',
						_0: A3(_user$project$Y15D15$score, model, calories, oldCookie),
						_1: {
							ctor: '::',
							_0: oldHigh,
							_1: {ctor: '[]'}
						}
					}));
			var _p5 = newCookie;
			if (_p5.ctor === 'Just') {
				var _v6 = model,
					_v7 = calories,
					_v8 = newHigh,
					_v9 = _p5._0;
				model = _v6;
				calories = _v7;
				oldHigh = _v8;
				oldCookie = _v9;
				continue highScore;
			} else {
				return newHigh;
			}
		}
	});
var _user$project$Y15D15$Ingredient = F6(
	function (a, b, c, d, e, f) {
		return {name: a, capacity: b, durability: c, flavor: d, texture: e, calories: f};
	});
var _user$project$Y15D15$parseLine = F2(
	function (line, model) {
		var rgx = A2(
			_elm_lang$core$Basics_ops['++'],
			'^(\\w+): ',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'capacity (-?\\d+), ',
				A2(
					_elm_lang$core$Basics_ops['++'],
					'durability (-?\\d+), ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						'flavor (-?\\d+), ',
						A2(_elm_lang$core$Basics_ops['++'], 'texture (-?\\d+), ', 'calories (-?\\d+)$')))));
		var matches = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex(rgx),
				line));
		var _p6 = matches;
		if (((((((((((((((_p6.ctor === '::') && (_p6._0.ctor === '::')) && (_p6._0._0.ctor === 'Just')) && (_p6._0._1.ctor === '::')) && (_p6._0._1._0.ctor === 'Just')) && (_p6._0._1._1.ctor === '::')) && (_p6._0._1._1._0.ctor === 'Just')) && (_p6._0._1._1._1.ctor === '::')) && (_p6._0._1._1._1._0.ctor === 'Just')) && (_p6._0._1._1._1._1.ctor === '::')) && (_p6._0._1._1._1._1._0.ctor === 'Just')) && (_p6._0._1._1._1._1._1.ctor === '::')) && (_p6._0._1._1._1._1._1._0.ctor === 'Just')) && (_p6._0._1._1._1._1._1._1.ctor === '[]')) && (_p6._1.ctor === '[]')) {
			var cl2 = _user$project$Y15D15$parseInt(_p6._0._1._1._1._1._1._0._0);
			var tx2 = _user$project$Y15D15$parseInt(_p6._0._1._1._1._1._0._0);
			var fl2 = _user$project$Y15D15$parseInt(_p6._0._1._1._1._0._0);
			var du2 = _user$project$Y15D15$parseInt(_p6._0._1._1._0._0);
			var cp2 = _user$project$Y15D15$parseInt(_p6._0._1._0._0);
			return {
				ctor: '::',
				_0: A6(_user$project$Y15D15$Ingredient, _p6._0._0._0, cp2, du2, fl2, tx2, cl2),
				_1: model
			};
		} else {
			return model;
		}
	});
var _user$project$Y15D15$parseInput = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D15$parseLine,
		{ctor: '[]'},
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D15$answer = F2(
	function (part, input) {
		var model = _user$project$Y15D15$parseInput(input);
		var cookie = A2(_user$project$Y15D15$initCookie, model, 100);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A4(_user$project$Y15D15$highScore, model, _elm_lang$core$Maybe$Nothing, 0, cookie)) : _elm_lang$core$Basics$toString(
			A4(
				_user$project$Y15D15$highScore,
				model,
				_elm_lang$core$Maybe$Just(500),
				0,
				cookie));
	});

var _user$project$Y15D16$parseInt = function (s) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(s));
};
var _user$project$Y15D16$match2 = F3(
	function (prop, val, prevProp) {
		if (!prevProp) {
			return false;
		} else {
			var _p0 = prop;
			switch (_p0) {
				case 'akitas':
					return _elm_lang$core$Native_Utils.eq(val, 0);
				case 'cars':
					return _elm_lang$core$Native_Utils.eq(val, 2);
				case 'cats':
					return _elm_lang$core$Native_Utils.cmp(val, 7) > 0;
				case 'children':
					return _elm_lang$core$Native_Utils.eq(val, 3);
				case 'goldfish':
					return _elm_lang$core$Native_Utils.cmp(val, 5) < 0;
				case 'perfumes':
					return _elm_lang$core$Native_Utils.eq(val, 1);
				case 'pomeranians':
					return _elm_lang$core$Native_Utils.cmp(val, 3) < 0;
				case 'samoyeds':
					return _elm_lang$core$Native_Utils.eq(val, 2);
				case 'trees':
					return _elm_lang$core$Native_Utils.cmp(val, 3) > 0;
				case 'vizslas':
					return _elm_lang$core$Native_Utils.eq(val, 0);
				default:
					return false;
			}
		}
	});
var _user$project$Y15D16$match1 = F3(
	function (prop, val, prevProp) {
		if (!prevProp) {
			return false;
		} else {
			var _p1 = prop;
			switch (_p1) {
				case 'akitas':
					return _elm_lang$core$Native_Utils.eq(val, 0);
				case 'cars':
					return _elm_lang$core$Native_Utils.eq(val, 2);
				case 'cats':
					return _elm_lang$core$Native_Utils.eq(val, 7);
				case 'children':
					return _elm_lang$core$Native_Utils.eq(val, 3);
				case 'goldfish':
					return _elm_lang$core$Native_Utils.eq(val, 5);
				case 'perfumes':
					return _elm_lang$core$Native_Utils.eq(val, 1);
				case 'pomeranians':
					return _elm_lang$core$Native_Utils.eq(val, 3);
				case 'samoyeds':
					return _elm_lang$core$Native_Utils.eq(val, 2);
				case 'trees':
					return _elm_lang$core$Native_Utils.eq(val, 3);
				case 'vizslas':
					return _elm_lang$core$Native_Utils.eq(val, 0);
				default:
					return false;
			}
		}
	});
var _user$project$Y15D16$sue = F2(
	function (hit, model) {
		var sues = A2(
			_elm_lang$core$List$filter,
			function (s) {
				return A3(_elm_lang$core$Dict$foldl, hit, true, s.props);
			},
			model);
		var _p2 = _elm_lang$core$List$length(sues);
		switch (_p2) {
			case 0:
				return 'none';
			case 1:
				return _elm_lang$core$Basics$toString(
					A2(
						_elm_lang$core$Maybe$withDefault,
						0,
						_elm_lang$core$List$head(
							A2(
								_elm_lang$core$List$map,
								function (_) {
									return _.number;
								},
								sues))));
			default:
				return 'too many';
		}
	});
var _user$project$Y15D16$Sue = F2(
	function (a, b) {
		return {number: a, props: b};
	});
var _user$project$Y15D16$parseLine = F2(
	function (line, model) {
		var cs = '(akitas|cars|cats|children|goldfish|perfumes|pomeranians|samoyeds|trees|vizslas): (\\d+)';
		var rx = A2(
			_elm_lang$core$Basics_ops['++'],
			'Sue ([1-9]\\d*): ',
			A2(
				_elm_lang$core$String$join,
				', ',
				A2(_elm_lang$core$List$repeat, 3, cs)));
		var ms = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex(rx),
				line));
		var _p3 = ms;
		if (((((((((((((((((_p3.ctor === '::') && (_p3._0.ctor === '::')) && (_p3._0._0.ctor === 'Just')) && (_p3._0._1.ctor === '::')) && (_p3._0._1._0.ctor === 'Just')) && (_p3._0._1._1.ctor === '::')) && (_p3._0._1._1._0.ctor === 'Just')) && (_p3._0._1._1._1.ctor === '::')) && (_p3._0._1._1._1._0.ctor === 'Just')) && (_p3._0._1._1._1._1.ctor === '::')) && (_p3._0._1._1._1._1._0.ctor === 'Just')) && (_p3._0._1._1._1._1._1.ctor === '::')) && (_p3._0._1._1._1._1._1._0.ctor === 'Just')) && (_p3._0._1._1._1._1._1._1.ctor === '::')) && (_p3._0._1._1._1._1._1._1._0.ctor === 'Just')) && (_p3._0._1._1._1._1._1._1._1.ctor === '[]')) && (_p3._1.ctor === '[]')) {
			var d = A3(
				_elm_lang$core$Dict$insert,
				_p3._0._1._1._1._1._1._0._0,
				_user$project$Y15D16$parseInt(_p3._0._1._1._1._1._1._1._0._0),
				A3(
					_elm_lang$core$Dict$insert,
					_p3._0._1._1._1._0._0,
					_user$project$Y15D16$parseInt(_p3._0._1._1._1._1._0._0),
					A3(
						_elm_lang$core$Dict$insert,
						_p3._0._1._0._0,
						_user$project$Y15D16$parseInt(_p3._0._1._1._0._0),
						_elm_lang$core$Dict$empty)));
			var i = _user$project$Y15D16$parseInt(_p3._0._0._0);
			return {
				ctor: '::',
				_0: A2(_user$project$Y15D16$Sue, i, d),
				_1: model
			};
		} else {
			return model;
		}
	});
var _user$project$Y15D16$parse = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D16$parseLine,
		{ctor: '[]'},
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D16$answer = F2(
	function (part, input) {
		var match = _elm_lang$core$Native_Utils.eq(part, 1) ? _user$project$Y15D16$match1 : _user$project$Y15D16$match2;
		return A2(
			_user$project$Y15D16$sue,
			match,
			_user$project$Y15D16$parse(input));
	});

var _user$project$Y15D17$parse = function (input) {
	return A2(
		_elm_lang$core$List$filter,
		function (i) {
			return _elm_lang$core$Native_Utils.cmp(i, 0) > 0;
		},
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Result$withDefault(0),
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$String$toInt,
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.match;
					},
					A3(
						_elm_lang$core$Regex$find,
						_elm_lang$core$Regex$All,
						_elm_lang$core$Regex$regex('[1-9]\\d*'),
						input)))));
};
var _user$project$Y15D17$combos = F3(
	function (n, total, model) {
		if (_elm_lang$core$Native_Utils.eq(n, 0)) {
			return {ctor: '_Tuple2', _0: 0, _1: 0};
		} else {
			var _p0 = A3(_user$project$Y15D17$combos, n - 1, total, model);
			var q = _p0._0;
			var r = _p0._1;
			var p = _elm_lang$core$List$length(
				A2(
					_elm_lang$core$List$filter,
					function (c) {
						return _elm_lang$core$Native_Utils.eq(
							_elm_lang$core$List$sum(c),
							total);
					},
					A2(_user$project$Util$combinations, n, model)));
			return {
				ctor: '_Tuple2',
				_0: p + q,
				_1: _elm_lang$core$Native_Utils.eq(r, 0) ? p : r
			};
		}
	});
var _user$project$Y15D17$answer = F2(
	function (part, input) {
		var select = _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Tuple$first : _elm_lang$core$Tuple$second;
		var model = _user$project$Y15D17$parse(input);
		var number = A3(
			_user$project$Y15D17$combos,
			_elm_lang$core$List$length(model),
			150,
			model);
		return _elm_lang$core$Basics$toString(
			select(number));
	});

var _user$project$Y15D18$initModel = {lights: _elm_lang$core$Array$empty, size: 0, maxIndex: 0, stuck: false};
var _user$project$Y15D18$count = function (model) {
	return _elm_lang$core$List$length(
		A2(
			_elm_lang$core$List$filter,
			_elm_lang$core$Basics$identity,
			_elm_lang$core$Array$toList(model.lights)));
};
var _user$project$Y15D18$outside = F2(
	function (model, _p0) {
		var _p1 = _p0;
		var _p3 = _p1._0;
		var _p2 = _p1._1;
		return (_elm_lang$core$Native_Utils.cmp(_p3, model.maxIndex) > 0) || ((_elm_lang$core$Native_Utils.cmp(_p3, 0) < 0) || ((_elm_lang$core$Native_Utils.cmp(_p2, model.maxIndex) > 0) || (_elm_lang$core$Native_Utils.cmp(_p2, 0) < 0)));
	});
var _user$project$Y15D18$next = F2(
	function (model, _p4) {
		var _p5 = _p4;
		var _p7 = _p5._0;
		var _p6 = _p5._1;
		return (_elm_lang$core$Native_Utils.cmp(_p6, model.maxIndex) > -1) ? {ctor: '_Tuple2', _0: _p7 + 1, _1: 0} : {ctor: '_Tuple2', _0: _p7, _1: _p6 + 1};
	});
var _user$project$Y15D18$corner = F2(
	function (model, _p8) {
		var _p9 = _p8;
		var _p11 = _p9._0;
		var _p10 = _p9._1;
		return (_elm_lang$core$Native_Utils.eq(_p11, 0) || _elm_lang$core$Native_Utils.eq(_p11, model.maxIndex)) && (_elm_lang$core$Native_Utils.eq(_p10, 0) || _elm_lang$core$Native_Utils.eq(_p10, model.maxIndex));
	});
var _user$project$Y15D18$index = F2(
	function (model, _p12) {
		var _p13 = _p12;
		return (_p13._0 * model.size) + _p13._1;
	});
var _user$project$Y15D18$stick = function (model) {
	var a = A3(
		_elm_lang$core$Array$set,
		A2(
			_user$project$Y15D18$index,
			model,
			{ctor: '_Tuple2', _0: model.maxIndex, _1: model.maxIndex}),
		true,
		A3(
			_elm_lang$core$Array$set,
			A2(
				_user$project$Y15D18$index,
				model,
				{ctor: '_Tuple2', _0: model.maxIndex, _1: 0}),
			true,
			A3(
				_elm_lang$core$Array$set,
				A2(
					_user$project$Y15D18$index,
					model,
					{ctor: '_Tuple2', _0: 0, _1: model.maxIndex}),
				true,
				A3(
					_elm_lang$core$Array$set,
					A2(
						_user$project$Y15D18$index,
						model,
						{ctor: '_Tuple2', _0: 0, _1: 0}),
					true,
					model.lights))));
	return _elm_lang$core$Native_Utils.update(
		model,
		{lights: a, stuck: true});
};
var _user$project$Y15D18$query = F2(
	function (model, cell) {
		return A2(_user$project$Y15D18$outside, model, cell) ? false : A2(
			_elm_lang$core$Maybe$withDefault,
			false,
			A2(
				_elm_lang$core$Array$get,
				A2(_user$project$Y15D18$index, model, cell),
				model.lights));
	});
var _user$project$Y15D18$neighbours = F2(
	function (model, _p14) {
		var _p15 = _p14;
		var ds = {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: -1, _1: -1},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 0, _1: -1},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 1, _1: -1},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: -1, _1: 0},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 1, _1: 0},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: -1, _1: 1},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 0, _1: 1},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 1, _1: 1},
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}
				}
			}
		};
		return _elm_lang$core$List$length(
			A2(
				_elm_lang$core$List$filter,
				_elm_lang$core$Basics$identity,
				A2(
					_elm_lang$core$List$map,
					_user$project$Y15D18$query(model),
					A2(
						_elm_lang$core$List$map,
						function (_p16) {
							var _p17 = _p16;
							return {ctor: '_Tuple2', _0: _p15._0 + _p17._0, _1: _p15._1 + _p17._1};
						},
						ds))));
	});
var _user$project$Y15D18$newVal = F2(
	function (model, cell) {
		if (model.stuck && A2(_user$project$Y15D18$corner, model, cell)) {
			return true;
		} else {
			var n = A2(_user$project$Y15D18$neighbours, model, cell);
			return A2(_user$project$Y15D18$query, model, cell) ? (_elm_lang$core$Native_Utils.eq(n, 2) || _elm_lang$core$Native_Utils.eq(n, 3)) : _elm_lang$core$Native_Utils.eq(n, 3);
		}
	});
var _user$project$Y15D18$sweep = F3(
	function (oldModel, model, cell) {
		sweep:
		while (true) {
			if (A2(_user$project$Y15D18$outside, model, cell)) {
				return model;
			} else {
				var v = A2(_user$project$Y15D18$newVal, oldModel, cell);
				var model_ = _elm_lang$core$Native_Utils.update(
					model,
					{
						lights: A3(
							_elm_lang$core$Array$set,
							A2(_user$project$Y15D18$index, model, cell),
							v,
							model.lights)
					});
				var nextCell = A2(_user$project$Y15D18$next, model_, cell);
				var _v6 = oldModel,
					_v7 = model_,
					_v8 = nextCell;
				oldModel = _v6;
				model = _v7;
				cell = _v8;
				continue sweep;
			}
		}
	});
var _user$project$Y15D18$step = function (model) {
	var oldModel = model;
	var start = {ctor: '_Tuple2', _0: 0, _1: 0};
	return A3(_user$project$Y15D18$sweep, oldModel, model, start);
};
var _user$project$Y15D18$steps = F2(
	function (n, model) {
		steps:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return model;
			} else {
				var _v9 = n - 1,
					_v10 = _user$project$Y15D18$step(model);
				n = _v9;
				model = _v10;
				continue steps;
			}
		}
	});
var _user$project$Y15D18$Model = F4(
	function (a, b, c, d) {
		return {lights: a, size: b, maxIndex: c, stuck: d};
	});
var _user$project$Y15D18$parse = function (input) {
	var a = A3(
		_elm_lang$core$List$foldl,
		_elm_lang$core$Array$push,
		_elm_lang$core$Array$empty,
		A2(
			_elm_lang$core$List$map,
			function (s) {
				return _elm_lang$core$Native_Utils.eq(s, '#');
			},
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('[#.]'),
					input))));
	var s = _elm_lang$core$Basics$ceiling(
		_elm_lang$core$Basics$sqrt(
			_elm_lang$core$Basics$toFloat(
				_elm_lang$core$Array$length(a))));
	var m = s - 1;
	return A4(_user$project$Y15D18$Model, a, s, m, false);
};
var _user$project$Y15D18$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_user$project$Y15D18$count(
				A2(
					_user$project$Y15D18$steps,
					100,
					_user$project$Y15D18$parse(input)))) : _elm_lang$core$Basics$toString(
			_user$project$Y15D18$count(
				A2(
					_user$project$Y15D18$steps,
					100,
					_user$project$Y15D18$stick(
						_user$project$Y15D18$parse(input)))));
	});

var _user$project$Y15D19$comaRgx = _elm_lang$core$Regex$regex('Y');
var _user$project$Y15D19$bracRgx = _elm_lang$core$Regex$regex('(Ar|Rn)');
var _user$project$Y15D19$atomRgx = _elm_lang$core$Regex$regex('[A-Z][a-z]?');
var _user$project$Y15D19$moleRgx = _elm_lang$core$Regex$regex('((?:[A-Z][a-z]?){10,})');
var _user$project$Y15D19$ruleRgx = _elm_lang$core$Regex$regex('(e|[A-Z][a-z]?) => ((?:[A-Z][a-z]?)+)');
var _user$project$Y15D19$count = F2(
	function (rgx, model) {
		return _elm_lang$core$List$length(
			A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, rgx, model.molecule));
	});
var _user$project$Y15D19$addToReplacements = F5(
	function (matches, from, to, molecule, replacements) {
		addToReplacements:
		while (true) {
			var _p0 = matches;
			if (_p0.ctor === '[]') {
				return replacements;
			} else {
				var _p1 = _p0._0;
				var right = A3(
					_elm_lang$core$String$slice,
					_p1.index + _elm_lang$core$String$length(from),
					-1,
					molecule);
				var left = A3(_elm_lang$core$String$slice, 0, _p1.index, molecule);
				var replacement = A2(
					_elm_lang$core$Basics_ops['++'],
					left,
					A2(_elm_lang$core$Basics_ops['++'], to, right));
				var replacements_ = A2(_elm_lang$core$Set$insert, replacement, replacements);
				var _v1 = _p0._1,
					_v2 = from,
					_v3 = to,
					_v4 = molecule,
					_v5 = replacements_;
				matches = _v1;
				from = _v2;
				to = _v3;
				molecule = _v4;
				replacements = _v5;
				continue addToReplacements;
			}
		}
	});
var _user$project$Y15D19$iterateRules = function (model) {
	iterateRules:
	while (true) {
		var _p2 = model.rules;
		if (_p2.ctor === '[]') {
			return model;
		} else {
			var _p3 = _p2._0;
			var to = _elm_lang$core$Tuple$second(_p3);
			var from = _elm_lang$core$Tuple$first(_p3);
			var matches = A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex(from),
				model.molecule);
			var replacements_ = A5(_user$project$Y15D19$addToReplacements, matches, from, to, model.molecule, model.replacements);
			var model_ = {rules: _p2._1, molecule: model.molecule, replacements: replacements_};
			var _v7 = model_;
			model = _v7;
			continue iterateRules;
		}
	}
};
var _user$project$Y15D19$extractMolecule = function (submatches) {
	var _p4 = submatches;
	if (_p4.ctor === 'Nothing') {
		return '';
	} else {
		var _p5 = _p4._0;
		if (((_p5.ctor === '::') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === '[]')) {
			return _p5._0._0;
		} else {
			return '';
		}
	}
};
var _user$project$Y15D19$extractRule = function (submatches) {
	var _p6 = submatches;
	if (((((_p6.ctor === '::') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === '::')) && (_p6._1._0.ctor === 'Just')) && (_p6._1._1.ctor === '[]')) {
		return {ctor: '_Tuple2', _0: _p6._0._0, _1: _p6._1._0._0};
	} else {
		return {ctor: '_Tuple2', _0: '', _1: ''};
	}
};
var _user$project$Y15D19$parse = function (input) {
	var molecule = _user$project$Y15D19$extractMolecule(
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.submatches;
				},
				A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, _user$project$Y15D19$moleRgx, input))));
	var rules = A2(
		_elm_lang$core$List$map,
		_user$project$Y15D19$extractRule,
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, _user$project$Y15D19$ruleRgx, input)));
	return {rules: rules, molecule: molecule, replacements: _elm_lang$core$Set$empty};
};
var _user$project$Y15D19$askalski = function (model) {
	var comas = A2(_user$project$Y15D19$count, _user$project$Y15D19$comaRgx, model);
	var bracs = A2(_user$project$Y15D19$count, _user$project$Y15D19$bracRgx, model);
	var atoms = A2(_user$project$Y15D19$count, _user$project$Y15D19$atomRgx, model);
	return _elm_lang$core$Basics$toString(((atoms - bracs) - (2 * comas)) - 1);
};
var _user$project$Y15D19$molecules = function (model) {
	var model_ = _user$project$Y15D19$iterateRules(model);
	return _elm_lang$core$Basics$toString(
		_elm_lang$core$Set$size(model_.replacements));
};
var _user$project$Y15D19$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _user$project$Y15D19$molecules(
			_user$project$Y15D19$parse(input)) : _user$project$Y15D19$askalski(
			_user$project$Y15D19$parse(input));
	});
var _user$project$Y15D19$Model = F3(
	function (a, b, c) {
		return {rules: a, molecule: b, replacements: c};
	});

var _user$project$Y15D20$parse = function (input) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(
			A2(
				_elm_lang$core$Maybe$withDefault,
				'0',
				_elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.match;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$AtMost(1),
							_elm_lang$core$Regex$regex('\\d+'),
							input))))));
};
var _user$project$Y15D20$fac = F4(
	function (n, i, l, fs) {
		if (_elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$Basics$toFloat(i),
			l) > 0) {
			return fs;
		} else {
			var fs1 = function () {
				if (!_elm_lang$core$Native_Utils.eq(
					A2(_elm_lang$core$Basics$rem, n, i),
					0)) {
					return fs;
				} else {
					var j = (n / i) | 0;
					var fs2 = {ctor: '::', _0: i, _1: fs};
					return _elm_lang$core$Native_Utils.eq(j, i) ? fs2 : {ctor: '::', _0: j, _1: fs2};
				}
			}();
			return A2(
				_elm_lang$core$Basics_ops['++'],
				fs1,
				A4(_user$project$Y15D20$fac, n, i + 1, l, fs));
		}
	});
var _user$project$Y15D20$factors = function (n) {
	return A4(
		_user$project$Y15D20$fac,
		n,
		1,
		_elm_lang$core$Basics$sqrt(
			_elm_lang$core$Basics$toFloat(n)),
		{ctor: '[]'});
};
var _user$project$Y15D20$house2 = F2(
	function (house, goal) {
		house2:
		while (true) {
			var presents = _elm_lang$core$List$sum(
				A2(
					_elm_lang$core$List$map,
					F2(
						function (x, y) {
							return x * y;
						})(11),
					A2(
						_elm_lang$core$List$filter,
						function (elf) {
							return _elm_lang$core$Native_Utils.cmp((house / elf) | 0, 50) < 1;
						},
						_user$project$Y15D20$factors(house))));
			if (_elm_lang$core$Native_Utils.cmp(presents, goal) > -1) {
				return house;
			} else {
				var _v0 = house + 1,
					_v1 = goal;
				house = _v0;
				goal = _v1;
				continue house2;
			}
		}
	});
var _user$project$Y15D20$house1 = F2(
	function (house, goal) {
		house1:
		while (true) {
			var presents = _elm_lang$core$List$sum(
				A2(
					_elm_lang$core$List$map,
					F2(
						function (x, y) {
							return x * y;
						})(10),
					_user$project$Y15D20$factors(house)));
			if (_elm_lang$core$Native_Utils.cmp(presents, goal) > -1) {
				return house;
			} else {
				var _v2 = house + 1,
					_v3 = goal;
				house = _v2;
				goal = _v3;
				continue house1;
			}
		}
	});
var _user$project$Y15D20$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y15D20$house1,
				1,
				_user$project$Y15D20$parse(input))) : _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y15D20$house2,
				1,
				_user$project$Y15D20$parse(input)));
	});

var _user$project$Y15D21$rings = _elm_lang$core$Array$fromList(
	{
		ctor: '::',
		_0: {
			ctor: '::',
			_0: 0,
			_1: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		_1: {
			ctor: '::',
			_0: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {
						ctor: '::',
						_0: 0,
						_1: {ctor: '[]'}
					}
				}
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '::',
					_0: 25,
					_1: {
						ctor: '::',
						_0: 1,
						_1: {
							ctor: '::',
							_0: 0,
							_1: {ctor: '[]'}
						}
					}
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '::',
						_0: 50,
						_1: {
							ctor: '::',
							_0: 2,
							_1: {
								ctor: '::',
								_0: 0,
								_1: {ctor: '[]'}
							}
						}
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '::',
							_0: 100,
							_1: {
								ctor: '::',
								_0: 3,
								_1: {
									ctor: '::',
									_0: 0,
									_1: {ctor: '[]'}
								}
							}
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '::',
								_0: 20,
								_1: {
									ctor: '::',
									_0: 0,
									_1: {
										ctor: '::',
										_0: 1,
										_1: {ctor: '[]'}
									}
								}
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '::',
									_0: 40,
									_1: {
										ctor: '::',
										_0: 0,
										_1: {
											ctor: '::',
											_0: 2,
											_1: {ctor: '[]'}
										}
									}
								},
								_1: {
									ctor: '::',
									_0: {
										ctor: '::',
										_0: 80,
										_1: {
											ctor: '::',
											_0: 0,
											_1: {
												ctor: '::',
												_0: 3,
												_1: {ctor: '[]'}
											}
										}
									},
									_1: {ctor: '[]'}
								}
							}
						}
					}
				}
			}
		}
	});
var _user$project$Y15D21$armors = _elm_lang$core$Array$fromList(
	{
		ctor: '::',
		_0: {
			ctor: '::',
			_0: 0,
			_1: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		_1: {
			ctor: '::',
			_0: {
				ctor: '::',
				_0: 13,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {
						ctor: '::',
						_0: 1,
						_1: {ctor: '[]'}
					}
				}
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '::',
					_0: 31,
					_1: {
						ctor: '::',
						_0: 0,
						_1: {
							ctor: '::',
							_0: 2,
							_1: {ctor: '[]'}
						}
					}
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '::',
						_0: 53,
						_1: {
							ctor: '::',
							_0: 0,
							_1: {
								ctor: '::',
								_0: 3,
								_1: {ctor: '[]'}
							}
						}
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '::',
							_0: 75,
							_1: {
								ctor: '::',
								_0: 0,
								_1: {
									ctor: '::',
									_0: 4,
									_1: {ctor: '[]'}
								}
							}
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '::',
								_0: 102,
								_1: {
									ctor: '::',
									_0: 0,
									_1: {
										ctor: '::',
										_0: 5,
										_1: {ctor: '[]'}
									}
								}
							},
							_1: {ctor: '[]'}
						}
					}
				}
			}
		}
	});
var _user$project$Y15D21$weapons = _elm_lang$core$Array$fromList(
	{
		ctor: '::',
		_0: {
			ctor: '::',
			_0: 8,
			_1: {
				ctor: '::',
				_0: 4,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		_1: {
			ctor: '::',
			_0: {
				ctor: '::',
				_0: 10,
				_1: {
					ctor: '::',
					_0: 5,
					_1: {
						ctor: '::',
						_0: 0,
						_1: {ctor: '[]'}
					}
				}
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '::',
					_0: 25,
					_1: {
						ctor: '::',
						_0: 6,
						_1: {
							ctor: '::',
							_0: 0,
							_1: {ctor: '[]'}
						}
					}
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '::',
						_0: 40,
						_1: {
							ctor: '::',
							_0: 7,
							_1: {
								ctor: '::',
								_0: 0,
								_1: {ctor: '[]'}
							}
						}
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '::',
							_0: 74,
							_1: {
								ctor: '::',
								_0: 8,
								_1: {
									ctor: '::',
									_0: 0,
									_1: {ctor: '[]'}
								}
							}
						},
						_1: {ctor: '[]'}
					}
				}
			}
		}
	});
var _user$project$Y15D21$winner = F2(
	function (attacker, defender) {
		winner:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(attacker.hitp, 0) < 1) {
				return defender.player;
			} else {
				var damage = attacker.damage - defender.armor;
				var hitp = defender.hitp - ((_elm_lang$core$Native_Utils.cmp(damage, 1) < 0) ? 1 : damage);
				var damaged = _elm_lang$core$Native_Utils.update(
					defender,
					{hitp: hitp});
				var _v0 = damaged,
					_v1 = attacker;
				attacker = _v0;
				defender = _v1;
				continue winner;
			}
		}
	});
var _user$project$Y15D21$nextIndex = function (i) {
	return (_elm_lang$core$Native_Utils.cmp(i.r2, 7) < 0) ? _elm_lang$core$Maybe$Just(
		_elm_lang$core$Native_Utils.update(
			i,
			{r2: i.r2 + 1})) : ((_elm_lang$core$Native_Utils.cmp(i.r1, 6) < 0) ? _elm_lang$core$Maybe$Just(
		_elm_lang$core$Native_Utils.update(
			i,
			{r1: i.r1 + 1, r2: i.r1 + 2})) : ((_elm_lang$core$Native_Utils.cmp(i.a, 5) < 0) ? _elm_lang$core$Maybe$Just(
		_elm_lang$core$Native_Utils.update(
			i,
			{a: i.a + 1, r1: 0, r2: 1})) : ((_elm_lang$core$Native_Utils.cmp(i.w, 4) < 0) ? _elm_lang$core$Maybe$Just(
		_elm_lang$core$Native_Utils.update(
			i,
			{w: i.w + 1, a: 0, r1: 0, r2: 1})) : _elm_lang$core$Maybe$Nothing)));
};
var _user$project$Y15D21$highest = F3(
	function (pwin, pcost, best) {
		return (!pwin) && (_elm_lang$core$Native_Utils.cmp(pcost, best) > 0);
	});
var _user$project$Y15D21$lowest = F3(
	function (pwin, pcost, best) {
		return pwin && (_elm_lang$core$Native_Utils.eq(best, 0) || (_elm_lang$core$Native_Utils.cmp(pcost, best) < 0));
	});
var _user$project$Y15D21$Fighter = F5(
	function (a, b, c, d, e) {
		return {hitp: a, damage: b, armor: c, cost: d, player: e};
	});
var _user$project$Y15D21$fighterFromIndex = function (i) {
	var ring2 = A2(
		_elm_lang$core$Maybe$withDefault,
		{
			ctor: '::',
			_0: 0,
			_1: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		A2(_elm_lang$core$Array$get, i.r2, _user$project$Y15D21$rings));
	var ring1 = A2(
		_elm_lang$core$Maybe$withDefault,
		{
			ctor: '::',
			_0: 0,
			_1: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		A2(_elm_lang$core$Array$get, i.r1, _user$project$Y15D21$rings));
	var armor = A2(
		_elm_lang$core$Maybe$withDefault,
		{
			ctor: '::',
			_0: 0,
			_1: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		A2(_elm_lang$core$Array$get, i.a, _user$project$Y15D21$armors));
	var weapon = A2(
		_elm_lang$core$Maybe$withDefault,
		{
			ctor: '::',
			_0: 0,
			_1: {
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 0,
					_1: {ctor: '[]'}
				}
			}
		},
		A2(_elm_lang$core$Array$get, i.w, _user$project$Y15D21$weapons));
	var totals = A5(
		_elm_lang$core$List$map4,
		F4(
			function (w, a, r1, r2) {
				return ((w + a) + r1) + r2;
			}),
		weapon,
		armor,
		ring1,
		ring2);
	var _p0 = totals;
	if ((((_p0.ctor === '::') && (_p0._1.ctor === '::')) && (_p0._1._1.ctor === '::')) && (_p0._1._1._1.ctor === '[]')) {
		return A5(_user$project$Y15D21$Fighter, 100, _p0._1._0, _p0._1._1._0, _p0._0, true);
	} else {
		return A5(_user$project$Y15D21$Fighter, 0, 0, 0, 0, true);
	}
};
var _user$project$Y15D21$search = F4(
	function (boss, candidate, best, index) {
		search:
		while (true) {
			var _p1 = index;
			if (_p1.ctor === 'Nothing') {
				return best;
			} else {
				var _p2 = _p1._0;
				var player = _user$project$Y15D21$fighterFromIndex(_p2);
				var nextBest = A3(
					candidate,
					A2(_user$project$Y15D21$winner, player, boss),
					player.cost,
					best) ? player.cost : best;
				var _v4 = boss,
					_v5 = candidate,
					_v6 = nextBest,
					_v7 = _user$project$Y15D21$nextIndex(_p2);
				boss = _v4;
				candidate = _v5;
				best = _v6;
				index = _v7;
				continue search;
			}
		}
	});
var _user$project$Y15D21$parse = function (input) {
	var ns = A2(
		_elm_lang$core$List$map,
		_elm_lang$core$String$toInt,
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.match;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('\\d+'),
				input)));
	var _p3 = ns;
	if (((((((_p3.ctor === '::') && (_p3._0.ctor === 'Ok')) && (_p3._1.ctor === '::')) && (_p3._1._0.ctor === 'Ok')) && (_p3._1._1.ctor === '::')) && (_p3._1._1._0.ctor === 'Ok')) && (_p3._1._1._1.ctor === '[]')) {
		return A5(_user$project$Y15D21$Fighter, _p3._0._0, _p3._1._0._0, _p3._1._1._0._0, 0, false);
	} else {
		return A5(_user$project$Y15D21$Fighter, 0, 0, 0, 0, false);
	}
};
var _user$project$Y15D21$Index = F4(
	function (a, b, c, d) {
		return {w: a, a: b, r1: c, r2: d};
	});
var _user$project$Y15D21$initIndex = _elm_lang$core$Maybe$Just(
	A4(_user$project$Y15D21$Index, 0, 0, 0, 1));
var _user$project$Y15D21$answer = F2(
	function (part, input) {
		var boss = _user$project$Y15D21$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A4(_user$project$Y15D21$search, boss, _user$project$Y15D21$lowest, 0, _user$project$Y15D21$initIndex)) : _elm_lang$core$Basics$toString(
			A4(_user$project$Y15D21$search, boss, _user$project$Y15D21$highest, 0, _user$project$Y15D21$initIndex));
	});

var _user$project$Y15D22$answer = F2(
	function (part, input) {
		return _user$project$Util$failed;
	});

var _user$project$Y15D23$initModel = {instructions: _elm_lang$core$Array$empty, registers: _elm_lang$core$Dict$empty, i: 0};
var _user$project$Y15D23$get = F2(
	function (reg, model) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(_elm_lang$core$Dict$get, reg, model.registers));
	});
var _user$project$Y15D23$update = F3(
	function (name, f, model) {
		var value = f(
			A2(_user$project$Y15D23$get, name, model));
		return A3(_elm_lang$core$Dict$insert, name, value, model.registers);
	});
var _user$project$Y15D23$run = function (model) {
	run:
	while (true) {
		var instruction = A2(_elm_lang$core$Array$get, model.i, model.instructions);
		var _p0 = instruction;
		if (_p0.ctor === 'Nothing') {
			return model;
		} else {
			var model_ = function () {
				var _p1 = _p0._0;
				switch (_p1.ctor) {
					case 'Inc':
						return _elm_lang$core$Native_Utils.update(
							model,
							{
								registers: A3(
									_user$project$Y15D23$update,
									_p1._0,
									function (v) {
										return v + 1;
									},
									model),
								i: model.i + 1
							});
					case 'Hlf':
						return _elm_lang$core$Native_Utils.update(
							model,
							{
								registers: A3(
									_user$project$Y15D23$update,
									_p1._0,
									function (v) {
										return (v / 2) | 0;
									},
									model),
								i: model.i + 1
							});
					case 'Tpl':
						return _elm_lang$core$Native_Utils.update(
							model,
							{
								registers: A3(
									_user$project$Y15D23$update,
									_p1._0,
									function (v) {
										return v * 3;
									},
									model),
								i: model.i + 1
							});
					case 'Jmp':
						return _elm_lang$core$Native_Utils.update(
							model,
							{i: model.i + _p1._0});
					case 'Jie':
						return _elm_lang$core$Native_Utils.update(
							model,
							{
								i: model.i + (_elm_lang$core$Native_Utils.eq(
									A2(
										_elm_lang$core$Basics$rem,
										A2(_user$project$Y15D23$get, _p1._0, model),
										2),
									0) ? _p1._1 : 1)
							});
					case 'Jio':
						return _elm_lang$core$Native_Utils.update(
							model,
							{
								i: model.i + (_elm_lang$core$Native_Utils.eq(
									A2(_user$project$Y15D23$get, _p1._0, model),
									1) ? _p1._1 : 1)
							});
					default:
						return _elm_lang$core$Native_Utils.update(
							model,
							{i: model.i + 1});
				}
			}();
			var _v2 = model_;
			model = _v2;
			continue run;
		}
	}
};
var _user$project$Y15D23$Model = F3(
	function (a, b, c) {
		return {instructions: a, registers: b, i: c};
	});
var _user$project$Y15D23$Jio = F2(
	function (a, b) {
		return {ctor: 'Jio', _0: a, _1: b};
	});
var _user$project$Y15D23$Jie = F2(
	function (a, b) {
		return {ctor: 'Jie', _0: a, _1: b};
	});
var _user$project$Y15D23$Jmp = function (a) {
	return {ctor: 'Jmp', _0: a};
};
var _user$project$Y15D23$Tpl = function (a) {
	return {ctor: 'Tpl', _0: a};
};
var _user$project$Y15D23$Hlf = function (a) {
	return {ctor: 'Hlf', _0: a};
};
var _user$project$Y15D23$Inc = function (a) {
	return {ctor: 'Inc', _0: a};
};
var _user$project$Y15D23$NoOp = {ctor: 'NoOp'};
var _user$project$Y15D23$parseLine = F2(
	function (line, model) {
		var rx = '^([a-z]{3})\\s+(a|b)?,?\\s*\\+?(-?\\d*)?';
		var sm = A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex(rx),
				line));
		var _p2 = sm;
		if ((((((_p2.ctor === '::') && (_p2._0.ctor === '::')) && (_p2._0._1.ctor === '::')) && (_p2._0._1._1.ctor === '::')) && (_p2._0._1._1._1.ctor === '[]')) && (_p2._1.ctor === '[]')) {
			var j = A2(
				_elm_lang$core$Result$withDefault,
				0,
				_elm_lang$core$String$toInt(
					A2(_elm_lang$core$Maybe$withDefault, '', _p2._0._1._1._0)));
			var r = A2(_elm_lang$core$Maybe$withDefault, '', _p2._0._1._0);
			var n = A2(_elm_lang$core$Maybe$withDefault, '', _p2._0._0);
			var i = function () {
				var _p3 = n;
				switch (_p3) {
					case 'inc':
						return _user$project$Y15D23$Inc(r);
					case 'hlf':
						return _user$project$Y15D23$Hlf(r);
					case 'tpl':
						return _user$project$Y15D23$Tpl(r);
					case 'jmp':
						return _user$project$Y15D23$Jmp(j);
					case 'jie':
						return A2(_user$project$Y15D23$Jie, r, j);
					case 'jio':
						return A2(_user$project$Y15D23$Jio, r, j);
					default:
						return _user$project$Y15D23$NoOp;
				}
			}();
			return _elm_lang$core$Native_Utils.update(
				model,
				{
					instructions: A2(_elm_lang$core$Array$push, i, model.instructions)
				});
		} else {
			return model;
		}
	});
var _user$project$Y15D23$parse = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D23$parseLine,
		_user$project$Y15D23$initModel,
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D23$answer = F2(
	function (part, input) {
		var init = _user$project$Y15D23$parse(input);
		var model = _elm_lang$core$Native_Utils.eq(part, 1) ? init : _elm_lang$core$Native_Utils.update(
			init,
			{
				registers: A3(_elm_lang$core$Dict$insert, 'a', 1, init.registers)
			});
		return _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y15D23$get,
				'b',
				_user$project$Y15D23$run(model)));
	});

var _user$project$Y15D24$parse = function (input) {
	return A2(
		_elm_lang$core$List$filter,
		function (w) {
			return !_elm_lang$core$Native_Utils.eq(w, 0);
		},
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Result$withDefault(0),
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$String$toInt,
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.match;
					},
					A3(
						_elm_lang$core$Regex$find,
						_elm_lang$core$Regex$All,
						_elm_lang$core$Regex$regex('\\d+'),
						input)))));
};
var _user$project$Y15D24$searchCombo = F3(
	function (qe, weight, combos) {
		searchCombo:
		while (true) {
			var _p0 = combos;
			if (_p0.ctor === '[]') {
				return qe;
			} else {
				var _p1 = _p0._0;
				var qe_ = function () {
					if (!_elm_lang$core$Native_Utils.eq(
						_elm_lang$core$List$sum(_p1),
						weight)) {
						return qe;
					} else {
						var qe__ = _elm_lang$core$List$product(_p1);
						return (_elm_lang$core$Native_Utils.eq(qe, 0) || (_elm_lang$core$Native_Utils.cmp(qe__, qe) < 0)) ? qe__ : qe;
					}
				}();
				var _v1 = qe_,
					_v2 = weight,
					_v3 = _p0._1;
				qe = _v1;
				weight = _v2;
				combos = _v3;
				continue searchCombo;
			}
		}
	});
var _user$project$Y15D24$searchLength = F5(
	function (qe, length, maxLen, weight, weights) {
		searchLength:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(length, maxLen) > 0) {
				return qe;
			} else {
				var combos = A2(_user$project$Util$combinations, length, weights);
				var qe_ = A3(_user$project$Y15D24$searchCombo, qe, weight, combos);
				if (_elm_lang$core$Native_Utils.cmp(qe_, 0) > 0) {
					return qe_;
				} else {
					var _v4 = qe,
						_v5 = length + 1,
						_v6 = maxLen,
						_v7 = weight,
						_v8 = weights;
					qe = _v4;
					length = _v5;
					maxLen = _v6;
					weight = _v7;
					weights = _v8;
					continue searchLength;
				}
			}
		}
	});
var _user$project$Y15D24$bestQe = F2(
	function (groups, weights) {
		var maxLen = (_elm_lang$core$List$length(weights) - groups) + 1;
		var weight = (_elm_lang$core$List$sum(weights) / groups) | 0;
		return A5(_user$project$Y15D24$searchLength, 0, 1, maxLen, weight, weights);
	});
var _user$project$Y15D24$answer = F2(
	function (part, input) {
		var num = _elm_lang$core$Native_Utils.eq(part, 1) ? 3 : 4;
		return _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y15D24$bestQe,
				num,
				_user$project$Y15D24$parse(input)));
	});

var _user$project$Y15D25$start = {code: 20151125, row: 1, col: 1};
var _user$project$Y15D25$search = F2(
	function (_p0, model) {
		search:
		while (true) {
			var _p1 = _p0;
			var _p4 = _p1._0;
			var _p3 = _p1._1;
			if (_elm_lang$core$Native_Utils.eq(_p4, model.row) && _elm_lang$core$Native_Utils.eq(_p3, model.col)) {
				return model;
			} else {
				var code_ = A2(_elm_lang$core$Basics_ops['%'], model.code * 252533, 33554393);
				var _p2 = (_elm_lang$core$Native_Utils.cmp(model.row, 1) > 0) ? {ctor: '_Tuple2', _0: model.row - 1, _1: model.col + 1} : {ctor: '_Tuple2', _0: model.col + 1, _1: 1};
				var row_ = _p2._0;
				var col_ = _p2._1;
				var _v1 = {ctor: '_Tuple2', _0: _p4, _1: _p3},
					_v2 = {code: code_, row: row_, col: col_};
				_p0 = _v1;
				model = _v2;
				continue search;
			}
		}
	});
var _user$project$Y15D25$parse = function (input) {
	var numbers = A2(
		_elm_lang$core$List$map,
		_elm_lang$core$String$toInt,
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Maybe$withDefault('1'),
			A2(
				_elm_lang$core$Maybe$withDefault,
				{
					ctor: '::',
					_0: _elm_lang$core$Maybe$Just('1'),
					_1: {
						ctor: '::',
						_0: _elm_lang$core$Maybe$Just('1'),
						_1: {ctor: '[]'}
					}
				},
				_elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.submatches;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$AtMost(1),
							_elm_lang$core$Regex$regex('code at row (\\d+), column (\\d+)'),
							input))))));
	var _p5 = function () {
		var _p6 = numbers;
		if (((((_p6.ctor === '::') && (_p6._0.ctor === 'Ok')) && (_p6._1.ctor === '::')) && (_p6._1._0.ctor === 'Ok')) && (_p6._1._1.ctor === '[]')) {
			return {ctor: '_Tuple2', _0: _p6._0._0, _1: _p6._1._0._0};
		} else {
			return {ctor: '_Tuple2', _0: 1, _1: 1};
		}
	}();
	var row = _p5._0;
	var col = _p5._1;
	return {ctor: '_Tuple2', _0: row, _1: col};
};
var _user$project$Y15D25$answer = F2(
	function (part, input) {
		if (_elm_lang$core$Native_Utils.eq(part, 1)) {
			var target = _user$project$Y15D25$parse(input);
			var model = A2(_user$project$Y15D25$search, target, _user$project$Y15D25$start);
			return _elm_lang$core$Basics$toString(model.code);
		} else {
			return _user$project$Util$onlyOnePart;
		}
	});
var _user$project$Y15D25$Model = F3(
	function (a, b, c) {
		return {code: a, row: b, col: c};
	});

var _user$project$Y15$answer = F3(
	function (day, part, input) {
		var _p0 = day;
		switch (_p0) {
			case 1:
				return A2(_user$project$Y15D01$answer, part, input);
			case 2:
				return A2(_user$project$Y15D02$answer, part, input);
			case 3:
				return A2(_user$project$Y15D03$answer, part, input);
			case 4:
				return A2(_user$project$Y15D04$answer, part, input);
			case 5:
				return A2(_user$project$Y15D05$answer, part, input);
			case 6:
				return A2(_user$project$Y15D06$answer, part, input);
			case 7:
				return A2(_user$project$Y15D07$answer, part, input);
			case 8:
				return A2(_user$project$Y15D08$answer, part, input);
			case 9:
				return A2(_user$project$Y15D09$answer, part, input);
			case 10:
				return A2(_user$project$Y15D10$answer, part, input);
			case 11:
				return A2(_user$project$Y15D11$answer, part, input);
			case 12:
				return A2(_user$project$Y15D12$answer, part, input);
			case 13:
				return A2(_user$project$Y15D13$answer, part, input);
			case 14:
				return A2(_user$project$Y15D14$answer, part, input);
			case 15:
				return A2(_user$project$Y15D15$answer, part, input);
			case 16:
				return A2(_user$project$Y15D16$answer, part, input);
			case 17:
				return A2(_user$project$Y15D17$answer, part, input);
			case 18:
				return A2(_user$project$Y15D18$answer, part, input);
			case 19:
				return A2(_user$project$Y15D19$answer, part, input);
			case 20:
				return A2(_user$project$Y15D20$answer, part, input);
			case 21:
				return A2(_user$project$Y15D21$answer, part, input);
			case 22:
				return A2(_user$project$Y15D22$answer, part, input);
			case 23:
				return A2(_user$project$Y15D23$answer, part, input);
			case 24:
				return A2(_user$project$Y15D24$answer, part, input);
			case 25:
				return A2(_user$project$Y15D25$answer, part, input);
			default:
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'year 2015, day ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(day),
						': not available'));
		}
	});

var _user$project$Y16D01$blocks = function (model) {
	return _elm_lang$core$Basics$abs(model.p.x) + _elm_lang$core$Basics$abs(model.p.y);
};
var _user$project$Y16D01$Step = F2(
	function (a, b) {
		return {r: a, n: b};
	});
var _user$project$Y16D01$Position = F2(
	function (a, b) {
		return {x: a, y: b};
	});
var _user$project$Y16D01$origin = A2(_user$project$Y16D01$Position, 0, 0);
var _user$project$Y16D01$Model = F2(
	function (a, b) {
		return {d: a, p: b};
	});
var _user$project$Y16D01$None = {ctor: 'None'};
var _user$project$Y16D01$Right = {ctor: 'Right'};
var _user$project$Y16D01$Left = {ctor: 'Left'};
var _user$project$Y16D01$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		function (m) {
			var _p0 = m;
			if (((((_p0.ctor === '::') && (_p0._0.ctor === 'Just')) && (_p0._1.ctor === '::')) && (_p0._1._0.ctor === 'Just')) && (_p0._1._1.ctor === '[]')) {
				var n = A2(
					_elm_lang$core$Result$withDefault,
					1,
					_elm_lang$core$String$toInt(_p0._1._0._0));
				var r = _elm_lang$core$Native_Utils.eq(_p0._0._0, 'R') ? _user$project$Y16D01$Right : _user$project$Y16D01$Left;
				return A2(_user$project$Y16D01$Step, r, n);
			} else {
				return A2(_user$project$Y16D01$Step, _user$project$Y16D01$Right, 1);
			}
		},
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('([RL])([1-9][0-9]*)'),
				input)));
};
var _user$project$Y16D01$West = {ctor: 'West'};
var _user$project$Y16D01$South = {ctor: 'South'};
var _user$project$Y16D01$East = {ctor: 'East'};
var _user$project$Y16D01$North = {ctor: 'North'};
var _user$project$Y16D01$init = A2(_user$project$Y16D01$Model, _user$project$Y16D01$North, _user$project$Y16D01$origin);
var _user$project$Y16D01$update = F2(
	function (step, model) {
		var p = model.p;
		var d = model.d;
		var _p1 = step.r;
		switch (_p1.ctor) {
			case 'Right':
				var _p2 = d;
				switch (_p2.ctor) {
					case 'North':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$East,
							_elm_lang$core$Native_Utils.update(
								p,
								{x: p.x + step.n}));
					case 'East':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$South,
							_elm_lang$core$Native_Utils.update(
								p,
								{y: p.y - step.n}));
					case 'South':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$West,
							_elm_lang$core$Native_Utils.update(
								p,
								{x: p.x - step.n}));
					default:
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$North,
							_elm_lang$core$Native_Utils.update(
								p,
								{y: p.y + step.n}));
				}
			case 'Left':
				var _p3 = model.d;
				switch (_p3.ctor) {
					case 'North':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$West,
							_elm_lang$core$Native_Utils.update(
								p,
								{x: p.x - step.n}));
					case 'East':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$North,
							_elm_lang$core$Native_Utils.update(
								p,
								{y: p.y + step.n}));
					case 'South':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$East,
							_elm_lang$core$Native_Utils.update(
								p,
								{x: p.x + step.n}));
					default:
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$South,
							_elm_lang$core$Native_Utils.update(
								p,
								{y: p.y - step.n}));
				}
			default:
				var _p4 = model.d;
				switch (_p4.ctor) {
					case 'North':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$North,
							_elm_lang$core$Native_Utils.update(
								p,
								{y: p.y + step.n}));
					case 'East':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$East,
							_elm_lang$core$Native_Utils.update(
								p,
								{x: p.x + step.n}));
					case 'South':
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$South,
							_elm_lang$core$Native_Utils.update(
								p,
								{y: p.y - step.n}));
					default:
						return A2(
							_user$project$Y16D01$Model,
							_user$project$Y16D01$West,
							_elm_lang$core$Native_Utils.update(
								p,
								{x: p.x - step.n}));
				}
		}
	});
var _user$project$Y16D01$updates = F2(
	function (steps, model) {
		updates:
		while (true) {
			var _p5 = steps;
			if (_p5.ctor === '::') {
				var _v6 = _p5._1,
					_v7 = A2(_user$project$Y16D01$update, _p5._0, model);
				steps = _v6;
				model = _v7;
				continue updates;
			} else {
				return model;
			}
		}
	});
var _user$project$Y16D01$revisits = F3(
	function (steps, visits, model) {
		revisits:
		while (true) {
			var _p6 = steps;
			if (_p6.ctor === '::') {
				var _p8 = _p6._0;
				var _p7 = _p6._1;
				var newModel = A2(
					_user$project$Y16D01$update,
					_elm_lang$core$Native_Utils.update(
						_p8,
						{n: 1}),
					model);
				if (A2(_elm_lang$core$List$member, newModel.p, visits)) {
					return newModel;
				} else {
					var newVisits = {ctor: '::', _0: newModel.p, _1: visits};
					if (_elm_lang$core$Native_Utils.cmp(_p8.n, 1) < 1) {
						var _v9 = _p7,
							_v10 = newVisits,
							_v11 = newModel;
						steps = _v9;
						visits = _v10;
						model = _v11;
						continue revisits;
					} else {
						var _v12 = {
							ctor: '::',
							_0: A2(_user$project$Y16D01$Step, _user$project$Y16D01$None, _p8.n - 1),
							_1: _p7
						},
							_v13 = newVisits,
							_v14 = newModel;
						steps = _v12;
						visits = _v13;
						model = _v14;
						continue revisits;
					}
				}
			} else {
				return model;
			}
		}
	});
var _user$project$Y16D01$answer = F2(
	function (part, input) {
		var steps = _user$project$Y16D01$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_user$project$Y16D01$blocks(
				A2(_user$project$Y16D01$updates, steps, _user$project$Y16D01$init))) : _elm_lang$core$Basics$toString(
			_user$project$Y16D01$blocks(
				A3(
					_user$project$Y16D01$revisits,
					steps,
					{ctor: '[]'},
					_user$project$Y16D01$init)));
	});

var _user$project$Y16D02$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.match;
		},
		A3(
			_elm_lang$core$Regex$find,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('([RLUD]+)'),
			input));
};
var _user$project$Y16D02$init = _elm_lang$core$Native_Utils.chr('5');
var _user$project$Y16D02$move2 = F2(
	function (current, letter) {
		var _p0 = current;
		switch (_p0.valueOf()) {
			case '1':
				var _p1 = letter;
				if (_p1.valueOf() === 'D') {
					return _elm_lang$core$Native_Utils.chr('3');
				} else {
					return current;
				}
			case '2':
				var _p2 = letter;
				switch (_p2.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('3');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('6');
					default:
						return current;
				}
			case '3':
				var _p3 = letter;
				switch (_p3.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('4');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('2');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('1');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('7');
					default:
						return current;
				}
			case '4':
				var _p4 = letter;
				switch (_p4.valueOf()) {
					case 'L':
						return _elm_lang$core$Native_Utils.chr('3');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('8');
					default:
						return current;
				}
			case '5':
				var _p5 = letter;
				if (_p5.valueOf() === 'R') {
					return _elm_lang$core$Native_Utils.chr('6');
				} else {
					return current;
				}
			case '6':
				var _p6 = letter;
				switch (_p6.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('7');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('5');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('2');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('A');
					default:
						return current;
				}
			case '7':
				var _p7 = letter;
				switch (_p7.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('8');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('6');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('3');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('B');
					default:
						return current;
				}
			case '8':
				var _p8 = letter;
				switch (_p8.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('9');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('7');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('4');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('C');
					default:
						return current;
				}
			case '9':
				var _p9 = letter;
				if (_p9.valueOf() === 'L') {
					return _elm_lang$core$Native_Utils.chr('8');
				} else {
					return current;
				}
			case 'A':
				var _p10 = letter;
				switch (_p10.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('B');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('6');
					default:
						return current;
				}
			case 'B':
				var _p11 = letter;
				switch (_p11.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('C');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('A');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('7');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('D');
					default:
						return current;
				}
			case 'C':
				var _p12 = letter;
				switch (_p12.valueOf()) {
					case 'L':
						return _elm_lang$core$Native_Utils.chr('B');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('8');
					default:
						return current;
				}
			case 'D':
				var _p13 = letter;
				if (_p13.valueOf() === 'U') {
					return _elm_lang$core$Native_Utils.chr('B');
				} else {
					return current;
				}
			default:
				return current;
		}
	});
var _user$project$Y16D02$move1 = F2(
	function (current, letter) {
		var _p14 = current;
		switch (_p14.valueOf()) {
			case '1':
				var _p15 = letter;
				switch (_p15.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('2');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('4');
					default:
						return current;
				}
			case '2':
				var _p16 = letter;
				switch (_p16.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('3');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('1');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('5');
					default:
						return current;
				}
			case '3':
				var _p17 = letter;
				switch (_p17.valueOf()) {
					case 'L':
						return _elm_lang$core$Native_Utils.chr('2');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('6');
					default:
						return current;
				}
			case '4':
				var _p18 = letter;
				switch (_p18.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('5');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('1');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('7');
					default:
						return current;
				}
			case '5':
				var _p19 = letter;
				switch (_p19.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('6');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('4');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('2');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('8');
					default:
						return current;
				}
			case '6':
				var _p20 = letter;
				switch (_p20.valueOf()) {
					case 'L':
						return _elm_lang$core$Native_Utils.chr('5');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('3');
					case 'D':
						return _elm_lang$core$Native_Utils.chr('9');
					default:
						return current;
				}
			case '7':
				var _p21 = letter;
				switch (_p21.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('8');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('4');
					default:
						return current;
				}
			case '8':
				var _p22 = letter;
				switch (_p22.valueOf()) {
					case 'R':
						return _elm_lang$core$Native_Utils.chr('9');
					case 'L':
						return _elm_lang$core$Native_Utils.chr('7');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('5');
					default:
						return current;
				}
			case '9':
				var _p23 = letter;
				switch (_p23.valueOf()) {
					case 'L':
						return _elm_lang$core$Native_Utils.chr('8');
					case 'U':
						return _elm_lang$core$Native_Utils.chr('6');
					default:
						return current;
				}
			default:
				return current;
		}
	});
var _user$project$Y16D02$follow = F3(
	function (current, mover, instruction) {
		follow:
		while (true) {
			var _p24 = _elm_lang$core$String$uncons(instruction);
			if (_p24.ctor === 'Just') {
				var button = A2(mover, current, _p24._0._0);
				var _v25 = button,
					_v26 = mover,
					_v27 = _p24._0._1;
				current = _v25;
				mover = _v26;
				instruction = _v27;
				continue follow;
			} else {
				return current;
			}
		}
	});
var _user$project$Y16D02$translate = F4(
	function (current, buttons, mover, instructions) {
		translate:
		while (true) {
			var _p25 = instructions;
			if (_p25.ctor === '::') {
				var button = A3(_user$project$Y16D02$follow, current, mover, _p25._0);
				var newButtons = {ctor: '::', _0: button, _1: buttons};
				var _v29 = button,
					_v30 = newButtons,
					_v31 = mover,
					_v32 = _p25._1;
				current = _v29;
				buttons = _v30;
				mover = _v31;
				instructions = _v32;
				continue translate;
			} else {
				return _elm_lang$core$List$reverse(buttons);
			}
		}
	});
var _user$project$Y16D02$answer = F2(
	function (part, input) {
		var instructions = _user$project$Y16D02$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$String$fromList(
			A4(
				_user$project$Y16D02$translate,
				_user$project$Y16D02$init,
				{ctor: '[]'},
				_user$project$Y16D02$move1,
				instructions)) : _elm_lang$core$String$fromList(
			A4(
				_user$project$Y16D02$translate,
				_user$project$Y16D02$init,
				{ctor: '[]'},
				_user$project$Y16D02$move2,
				instructions));
	});

var _user$project$Y16D03$convertToInt = function (item) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(
			A2(_elm_lang$core$Maybe$withDefault, '0', item)));
};
var _user$project$Y16D03$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		_elm_lang$core$List$map(_user$project$Y16D03$convertToInt),
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('(\\d+) +(\\d+) +(\\d+)'),
				input)));
};
var _user$project$Y16D03$rearrange = F4(
	function (a1, a2, a3, horizontals) {
		rearrange:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(
				_elm_lang$core$List$length(a1),
				3) > -1) {
				return A2(
					_elm_lang$core$Basics_ops['++'],
					{
						ctor: '::',
						_0: a1,
						_1: {
							ctor: '::',
							_0: a2,
							_1: {
								ctor: '::',
								_0: a3,
								_1: {ctor: '[]'}
							}
						}
					},
					A4(
						_user$project$Y16D03$rearrange,
						{ctor: '[]'},
						{ctor: '[]'},
						{ctor: '[]'},
						horizontals));
			} else {
				var _p0 = horizontals;
				if (_p0.ctor === '[]') {
					return {ctor: '[]'};
				} else {
					if ((((_p0._0.ctor === '::') && (_p0._0._1.ctor === '::')) && (_p0._0._1._1.ctor === '::')) && (_p0._0._1._1._1.ctor === '[]')) {
						var b3 = {ctor: '::', _0: _p0._0._1._1._0, _1: a3};
						var b2 = {ctor: '::', _0: _p0._0._1._0, _1: a2};
						var b1 = {ctor: '::', _0: _p0._0._0, _1: a1};
						var _v1 = b1,
							_v2 = b2,
							_v3 = b3,
							_v4 = _p0._1;
						a1 = _v1;
						a2 = _v2;
						a3 = _v3;
						horizontals = _v4;
						continue rearrange;
					} else {
						var _v5 = a1,
							_v6 = a2,
							_v7 = a3,
							_v8 = _p0._1;
						a1 = _v5;
						a2 = _v6;
						a3 = _v7;
						horizontals = _v8;
						continue rearrange;
					}
				}
			}
		}
	});
var _user$project$Y16D03$ok = function (triangle) {
	var _p1 = triangle;
	if ((((_p1.ctor === '::') && (_p1._1.ctor === '::')) && (_p1._1._1.ctor === '::')) && (_p1._1._1._1.ctor === '[]')) {
		return (_elm_lang$core$Native_Utils.cmp(_p1._0 + _p1._1._0, _p1._1._1._0) > 0) ? 1 : 0;
	} else {
		return 0;
	}
};
var _user$project$Y16D03$count = function (triangles) {
	var _p2 = triangles;
	if (_p2.ctor === '[]') {
		return 0;
	} else {
		return _user$project$Y16D03$ok(_p2._0) + _user$project$Y16D03$count(_p2._1);
	}
};
var _user$project$Y16D03$process = function (triangles) {
	return _elm_lang$core$Basics$toString(
		_user$project$Y16D03$count(
			A2(_elm_lang$core$List$map, _elm_lang$core$List$sort, triangles)));
};
var _user$project$Y16D03$answer = F2(
	function (part, input) {
		var horizontals = _user$project$Y16D03$parse(input);
		if (_elm_lang$core$Native_Utils.eq(part, 1)) {
			return _user$project$Y16D03$process(horizontals);
		} else {
			var verticals = A4(
				_user$project$Y16D03$rearrange,
				{ctor: '[]'},
				{ctor: '[]'},
				{ctor: '[]'},
				horizontals);
			return _user$project$Y16D03$process(verticals);
		}
	});

var _user$project$Y16D04$potentialRoom = function (room) {
	var _p0 = room;
	if (_p0.ctor === 'Just') {
		var _p1 = _p0._0;
		return (_elm_lang$core$Native_Utils.cmp(_p1.sector, 0) > 0) ? _elm_lang$core$Maybe$Just(_p1) : _elm_lang$core$Maybe$Nothing;
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _user$project$Y16D04$decrypt = F3(
	function (shift, accum, string) {
		decrypt:
		while (true) {
			var _p2 = _elm_lang$core$String$uncons(string);
			if (_p2.ctor === 'Just') {
				var _p3 = _p2._0._0;
				var newChar = _elm_lang$core$Native_Utils.eq(
					_p3,
					_elm_lang$core$Native_Utils.chr('-')) ? _elm_lang$core$Native_Utils.chr(' ') : _elm_lang$core$Char$fromCode(
					97 + A2(
						_elm_lang$core$Basics_ops['%'],
						(_elm_lang$core$Char$toCode(_p3) + shift) - 97,
						26));
				var newAccum = A2(_elm_lang$core$String$cons, newChar, accum);
				var _v2 = shift,
					_v3 = newAccum,
					_v4 = _p2._0._1;
				shift = _v2;
				accum = _v3;
				string = _v4;
				continue decrypt;
			} else {
				return _elm_lang$core$String$reverse(accum);
			}
		}
	});
var _user$project$Y16D04$northPole = function (room) {
	var name = A3(_user$project$Y16D04$decrypt, room.sector, '', room.name);
	return A2(
		_elm_lang$core$Regex$contains,
		_elm_lang$core$Regex$regex('northpole object'),
		name);
};
var _user$project$Y16D04$insert = function (count) {
	var _p4 = count;
	if (_p4.ctor === 'Just') {
		return _elm_lang$core$Maybe$Just(_p4._0 + 1);
	} else {
		return _elm_lang$core$Maybe$Just(1);
	}
};
var _user$project$Y16D04$statCompare = F2(
	function (_p6, _p5) {
		var _p7 = _p6;
		var _p10 = _p7._1;
		var _p8 = _p5;
		var _p9 = _p8._1;
		return _elm_lang$core$Native_Utils.eq(_p10, _p9) ? A2(_elm_lang$core$Basics$compare, _p7._0, _p8._0) : A2(_elm_lang$core$Basics$compare, _p9, _p10);
	});
var _user$project$Y16D04$stats = F2(
	function (name, dict) {
		stats:
		while (true) {
			var _p11 = _elm_lang$core$String$uncons(name);
			if (_p11.ctor === 'Just') {
				var _p12 = _p11._0._0;
				var newDict = _elm_lang$core$Native_Utils.eq(
					_p12,
					_elm_lang$core$Native_Utils.chr('-')) ? dict : A3(_elm_lang$core$Dict$update, _p12, _user$project$Y16D04$insert, dict);
				var _v9 = _p11._0._1,
					_v10 = newDict;
				name = _v9;
				dict = _v10;
				continue stats;
			} else {
				return dict;
			}
		}
	});
var _user$project$Y16D04$checksum = function (room) {
	var dict = A2(_user$project$Y16D04$stats, room.name, _elm_lang$core$Dict$empty);
	var list = A2(
		_elm_lang$core$List$take,
		5,
		A2(
			_elm_lang$core$List$sortWith,
			_user$project$Y16D04$statCompare,
			_elm_lang$core$Dict$toList(dict)));
	return _elm_lang$core$String$fromList(
		A2(_elm_lang$core$List$map, _elm_lang$core$Tuple$first, list));
};
var _user$project$Y16D04$realRoom = function (room) {
	return _elm_lang$core$Native_Utils.eq(
		room.checksum,
		_user$project$Y16D04$checksum(room));
};
var _user$project$Y16D04$Room = F3(
	function (a, b, c) {
		return {name: a, sector: b, checksum: c};
	});
var _user$project$Y16D04$convertToMaybeRoom = function (matches) {
	var _p13 = matches;
	if (((((((_p13.ctor === '::') && (_p13._0.ctor === 'Just')) && (_p13._1.ctor === '::')) && (_p13._1._0.ctor === 'Just')) && (_p13._1._1.ctor === '::')) && (_p13._1._1._0.ctor === 'Just')) && (_p13._1._1._1.ctor === '[]')) {
		return _elm_lang$core$Maybe$Just(
			A3(
				_user$project$Y16D04$Room,
				_p13._0._0,
				A2(
					_elm_lang$core$Result$withDefault,
					0,
					_elm_lang$core$String$toInt(_p13._1._0._0)),
				_p13._1._1._0._0));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _user$project$Y16D04$parse = function (input) {
	return A2(
		_elm_lang$core$List$filterMap,
		_user$project$Y16D04$potentialRoom,
		A2(
			_elm_lang$core$List$map,
			_user$project$Y16D04$convertToMaybeRoom,
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.submatches;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('([-a-z]+)-([1-9]\\d*)\\[([a-z]{5})\\]'),
					input))));
};
var _user$project$Y16D04$answer = F2(
	function (part, input) {
		var rooms = _user$project$Y16D04$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_elm_lang$core$List$sum(
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.sector;
					},
					A2(_elm_lang$core$List$filter, _user$project$Y16D04$realRoom, rooms)))) : _elm_lang$core$Basics$toString(
			_elm_lang$core$List$sum(
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.sector;
					},
					A2(_elm_lang$core$List$filter, _user$project$Y16D04$northPole, rooms))));
	});

var _user$project$Y16D05$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'error',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('[a-z]+'),
					input))));
};
var _user$project$Y16D05$zeros = '00000';
var _user$project$Y16D05$zLen = _elm_lang$core$String$length(_user$project$Y16D05$zeros);
var _user$project$Y16D05$password2 = F3(
	function (doorId, index, accum) {
		password2:
		while (true) {
			if (!A2(
				_elm_lang$core$List$member,
				_elm_lang$core$Maybe$Nothing,
				_elm_lang$core$Array$toList(accum))) {
				return A2(
					_elm_lang$core$String$join,
					'',
					A2(
						_elm_lang$core$List$map,
						_elm_lang$core$Maybe$withDefault('-'),
						_elm_lang$core$Array$toList(accum)));
			} else {
				var newIndex = index + 1;
				var digest = _sanichi$elm_md5$MD5$hex(
					A2(
						_elm_lang$core$Basics_ops['++'],
						doorId,
						_elm_lang$core$Basics$toString(index)));
				var newAccum = function () {
					if (A2(_elm_lang$core$String$startsWith, _user$project$Y16D05$zeros, digest)) {
						var rest = A2(_elm_lang$core$String$dropLeft, _user$project$Y16D05$zLen, digest);
						var $char = function () {
							var _p0 = _elm_lang$core$String$uncons(rest);
							if (_p0.ctor === 'Just') {
								return _p0._0._0;
							} else {
								return _elm_lang$core$Native_Utils.chr('-');
							}
						}();
						var index = A2(
							_elm_lang$core$Result$withDefault,
							-1,
							_elm_lang$core$String$toInt(
								_elm_lang$core$String$fromChar($char)));
						if ((_elm_lang$core$Native_Utils.cmp(index, 0) > -1) && (_elm_lang$core$Native_Utils.cmp(index, 8) < 0)) {
							var _p1 = A2(_elm_lang$core$Array$get, index, accum);
							if ((_p1.ctor === 'Just') && (_p1._0.ctor === 'Nothing')) {
								var item = function () {
									var _p2 = _elm_lang$core$String$uncons(
										A2(_elm_lang$core$String$dropLeft, 1, rest));
									if (_p2.ctor === 'Just') {
										return _elm_lang$core$Maybe$Just(
											_elm_lang$core$String$fromChar(_p2._0._0));
									} else {
										return _elm_lang$core$Maybe$Just('-');
									}
								}();
								return A3(_elm_lang$core$Array$set, index, item, accum);
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
				var _v3 = doorId,
					_v4 = newIndex,
					_v5 = newAccum;
				doorId = _v3;
				index = _v4;
				accum = _v5;
				continue password2;
			}
		}
	});
var _user$project$Y16D05$password1 = F3(
	function (doorId, index, accum) {
		password1:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(
				_elm_lang$core$String$length(accum),
				8) > -1) {
				return _elm_lang$core$String$reverse(accum);
			} else {
				var newIndex = index + 1;
				var digest = _sanichi$elm_md5$MD5$hex(
					A2(
						_elm_lang$core$Basics_ops['++'],
						doorId,
						_elm_lang$core$Basics$toString(index)));
				var newAccum = function () {
					if (A2(_elm_lang$core$String$startsWith, _user$project$Y16D05$zeros, digest)) {
						var _p3 = _elm_lang$core$String$uncons(
							A2(_elm_lang$core$String$dropLeft, _user$project$Y16D05$zLen, digest));
						if (_p3.ctor === 'Just') {
							return A2(_elm_lang$core$String$cons, _p3._0._0, accum);
						} else {
							return A2(
								_elm_lang$core$String$cons,
								_elm_lang$core$Native_Utils.chr('-'),
								accum);
						}
					} else {
						return accum;
					}
				}();
				var _v7 = doorId,
					_v8 = newIndex,
					_v9 = newAccum;
				doorId = _v7;
				index = _v8;
				accum = _v9;
				continue password1;
			}
		}
	});
var _user$project$Y16D05$answer = F2(
	function (part, input) {
		var doorId = _user$project$Y16D05$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A3(_user$project$Y16D05$password1, doorId, 0, '') : A3(
			_user$project$Y16D05$password2,
			doorId,
			0,
			A2(_elm_lang$core$Array$repeat, 8, _elm_lang$core$Maybe$Nothing));
	});

var _user$project$Y16D06$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.match;
		},
		A3(
			_elm_lang$core$Regex$find,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('[a-z]+'),
			input));
};
var _user$project$Y16D06$addToDicts = F3(
	function (message, index, dicts) {
		addToDicts:
		while (true) {
			if (_elm_lang$core$Native_Utils.eq(message, '')) {
				return dicts;
			} else {
				var maybeDict = A2(_elm_lang$core$Array$get, index, dicts);
				var _p0 = A2(
					_elm_lang$core$Maybe$withDefault,
					{
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.chr('-'),
						_1: ''
					},
					_elm_lang$core$String$uncons(message));
				var $char = _p0._0;
				var rest = _p0._1;
				var newDicts = function () {
					var _p1 = maybeDict;
					if (_p1.ctor === 'Nothing') {
						return dicts;
					} else {
						var _p3 = _p1._0;
						var newDict = function () {
							var _p2 = A2(_elm_lang$core$Dict$get, $char, _p3);
							if (_p2.ctor === 'Nothing') {
								return A3(_elm_lang$core$Dict$insert, $char, 1, _p3);
							} else {
								return A3(_elm_lang$core$Dict$insert, $char, _p2._0 + 1, _p3);
							}
						}();
						return A3(_elm_lang$core$Array$set, index, newDict, dicts);
					}
				}();
				var _v2 = rest,
					_v3 = index + 1,
					_v4 = newDicts;
				message = _v2;
				index = _v3;
				dicts = _v4;
				continue addToDicts;
			}
		}
	});
var _user$project$Y16D06$choose = F2(
	function (frequency, sortedList) {
		var _p4 = frequency;
		if (_p4.ctor === 'Most') {
			return _elm_lang$core$List$reverse(sortedList);
		} else {
			return sortedList;
		}
	});
var _user$project$Y16D06$pick = F2(
	function (frequency, dict) {
		return _elm_lang$core$String$fromChar(
			_elm_lang$core$Tuple$first(
				A2(
					_elm_lang$core$Maybe$withDefault,
					{
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.chr('-'),
						_1: 0
					},
					_elm_lang$core$List$head(
						A2(
							_user$project$Y16D06$choose,
							frequency,
							A2(
								_elm_lang$core$List$sortBy,
								_elm_lang$core$Tuple$second,
								_elm_lang$core$Dict$toList(dict)))))));
	});
var _user$project$Y16D06$decrypt_ = F3(
	function (messages, frequency, dicts) {
		decrypt_:
		while (true) {
			var _p5 = messages;
			if (_p5.ctor === '[]') {
				return A2(
					_elm_lang$core$String$join,
					'',
					A2(
						_elm_lang$core$List$map,
						_user$project$Y16D06$pick(frequency),
						_elm_lang$core$Array$toList(dicts)));
			} else {
				var newDicts = A3(_user$project$Y16D06$addToDicts, _p5._0, 0, dicts);
				var _v7 = _p5._1,
					_v8 = frequency,
					_v9 = newDicts;
				messages = _v7;
				frequency = _v8;
				dicts = _v9;
				continue decrypt_;
			}
		}
	});
var _user$project$Y16D06$decrypt = F2(
	function (messages, frequency) {
		var width = _elm_lang$core$String$length(
			A2(
				_elm_lang$core$Maybe$withDefault,
				'',
				_elm_lang$core$List$head(messages)));
		var dicts = A2(_elm_lang$core$Array$repeat, width, _elm_lang$core$Dict$empty);
		return A3(_user$project$Y16D06$decrypt_, messages, frequency, dicts);
	});
var _user$project$Y16D06$Least = {ctor: 'Least'};
var _user$project$Y16D06$Most = {ctor: 'Most'};
var _user$project$Y16D06$answer = F2(
	function (part, input) {
		var messages = _user$project$Y16D06$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A2(_user$project$Y16D06$decrypt, messages, _user$project$Y16D06$Most) : A2(_user$project$Y16D06$decrypt, messages, _user$project$Y16D06$Least);
	});

var _user$project$Y16D07$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.match;
		},
		A3(
			_elm_lang$core$Regex$find,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex('[a-z\\[\\]]+'),
			input));
};
var _user$project$Y16D07$matchInterior = _elm_lang$core$Regex$regex('\\[([a-z]+)\\]');
var _user$project$Y16D07$matchExterior = _elm_lang$core$Regex$regex('(?:^|\\])([a-z]+)(?:\\[|$)');
var _user$project$Y16D07$fragments = F2(
	function (matcher, address) {
		return A2(
			_elm_lang$core$List$map,
			_elm_lang$core$Maybe$withDefault(''),
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Maybe$withDefault(_elm_lang$core$Maybe$Nothing),
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$List$head,
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.submatches;
						},
						A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, matcher, address)))));
	});
var _user$project$Y16D07$ssl = function (address) {
	var abaList = function (fragment) {
		return A2(
			_elm_lang$core$List$filter,
			function (a) {
				return !A2(
					_elm_lang$core$Regex$contains,
					_elm_lang$core$Regex$regex('^(.)\\1\\1$'),
					a);
			},
			A2(
				_elm_lang$core$List$filter,
				function (a) {
					return A2(
						_elm_lang$core$Regex$contains,
						_elm_lang$core$Regex$regex('^(.).\\1$'),
						a);
				},
				A2(
					_elm_lang$core$List$filter,
					function (a) {
						return _elm_lang$core$Native_Utils.eq(
							_elm_lang$core$String$length(a),
							3);
					},
					A2(
						_elm_lang$core$List$map,
						_elm_lang$core$String$fromList,
						A3(
							_elm_lang$core$List$scanl,
							F2(
								function (a, b) {
									return {
										ctor: '::',
										_0: a,
										_1: A2(_elm_lang$core$List$take, 2, b)
									};
								}),
							{ctor: '[]'},
							_elm_lang$core$String$toList(fragment))))));
	};
	var abas = _elm_lang$core$List$concat(
		A2(
			_elm_lang$core$List$map,
			abaList,
			A2(_user$project$Y16D07$fragments, _user$project$Y16D07$matchExterior, address)));
	if (_elm_lang$core$List$isEmpty(abas)) {
		return false;
	} else {
		var abaToBab = function (aba) {
			var _p0 = _elm_lang$core$String$toList(aba);
			if ((((_p0.ctor === '::') && (_p0._1.ctor === '::')) && (_p0._1._1.ctor === '::')) && (_p0._1._1._1.ctor === '[]')) {
				var _p1 = _p0._1._0;
				return _elm_lang$core$String$fromList(
					{
						ctor: '::',
						_0: _p1,
						_1: {
							ctor: '::',
							_0: _p0._0,
							_1: {
								ctor: '::',
								_0: _p1,
								_1: {ctor: '[]'}
							}
						}
					});
			} else {
				return '---';
			}
		};
		var babs = A2(_elm_lang$core$List$map, abaToBab, abas);
		var hasBab = function (fragment) {
			return A2(
				_elm_lang$core$List$any,
				function (b) {
					return A2(_elm_lang$core$String$contains, b, fragment);
				},
				babs);
		};
		return A2(
			_elm_lang$core$List$any,
			hasBab,
			A2(_user$project$Y16D07$fragments, _user$project$Y16D07$matchInterior, address));
	}
};
var _user$project$Y16D07$tls = function (address) {
	var hasAbba = function (fragment) {
		var abbas = A2(
			_elm_lang$core$List$filter,
			function (s) {
				return !A2(
					_elm_lang$core$Regex$contains,
					_elm_lang$core$Regex$regex('^(.)\\1\\1\\1$'),
					s);
			},
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('(.)(.)\\2\\1'),
					fragment)));
		return _elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$List$length(abbas),
			0) > 0;
	};
	var exteriors = A2(
		_elm_lang$core$List$any,
		hasAbba,
		A2(_user$project$Y16D07$fragments, _user$project$Y16D07$matchExterior, address));
	var interiors = A2(
		_elm_lang$core$List$any,
		hasAbba,
		A2(_user$project$Y16D07$fragments, _user$project$Y16D07$matchInterior, address));
	return exteriors && (!interiors);
};
var _user$project$Y16D07$answer = F2(
	function (part, input) {
		var addresses = _user$project$Y16D07$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_elm_lang$core$List$length(
				A2(_elm_lang$core$List$filter, _user$project$Y16D07$tls, addresses))) : _elm_lang$core$Basics$toString(
			_elm_lang$core$List$length(
				A2(_elm_lang$core$List$filter, _user$project$Y16D07$ssl, addresses)));
	});

var _user$project$Y16D08$initialScreen = A2(
	_elm_lang$core$Array$repeat,
	6,
	A2(_elm_lang$core$Array$repeat, 50, false));
var _user$project$Y16D08$display = function (screen) {
	var boolToString = function (bool) {
		return bool ? '#' : '.';
	};
	var rowToString = function (row) {
		return _elm_lang$core$String$concat(
			_elm_lang$core$Array$toList(
				A2(_elm_lang$core$Array$map, boolToString, row)));
	};
	return A2(
		_elm_lang$core$String$join,
		'\n',
		A2(
			_elm_lang$core$List$map,
			rowToString,
			_elm_lang$core$Array$toList(screen)));
};
var _user$project$Y16D08$count = function (screen) {
	var count = function (row) {
		return _elm_lang$core$List$length(
			A2(
				_elm_lang$core$List$filter,
				_elm_lang$core$Basics$identity,
				_elm_lang$core$Array$toList(row)));
	};
	return _elm_lang$core$Basics$toString(
		_elm_lang$core$List$sum(
			A2(
				_elm_lang$core$List$map,
				count,
				_elm_lang$core$Array$toList(screen))));
};
var _user$project$Y16D08$flipRow = F2(
	function (screen, y) {
		return A2(
			_elm_lang$core$Array$map,
			_elm_lang$core$Maybe$withDefault(false),
			A2(
				_elm_lang$core$Array$map,
				_elm_lang$core$Array$get(y),
				screen));
	});
var _user$project$Y16D08$flipScreen = function (screen) {
	var newRowLen = _elm_lang$core$Array$length(
		A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Array$empty,
			A2(_elm_lang$core$Array$get, 0, screen)));
	return _elm_lang$core$Array$fromList(
		A2(
			_elm_lang$core$List$map,
			_user$project$Y16D08$flipRow(screen),
			A2(_elm_lang$core$List$range, 0, newRowLen - 1)));
};
var _user$project$Y16D08$rotateRow = F3(
	function (y, r, screen) {
		var oldRow = _elm_lang$core$Array$toList(
			A2(
				_elm_lang$core$Maybe$withDefault,
				_elm_lang$core$Array$empty,
				A2(_elm_lang$core$Array$get, y, screen)));
		var len = _elm_lang$core$List$length(oldRow);
		var x = A2(_elm_lang$core$Basics_ops['%'], r, len);
		var newRight = A2(_elm_lang$core$List$take, len - x, oldRow);
		var newLeft = A2(_elm_lang$core$List$drop, len - x, oldRow);
		var newRow = _elm_lang$core$Array$fromList(
			A2(_elm_lang$core$Basics_ops['++'], newLeft, newRight));
		return A3(_elm_lang$core$Array$set, y, newRow, screen);
	});
var _user$project$Y16D08$rotateCol = F3(
	function (x, r, screen) {
		return _user$project$Y16D08$flipScreen(
			A3(
				_user$project$Y16D08$rotateRow,
				x,
				r,
				_user$project$Y16D08$flipScreen(screen)));
	});
var _user$project$Y16D08$rect = F3(
	function (x, y, screen) {
		rect:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(y, 0) < 1) {
				return screen;
			} else {
				var newRow = _elm_lang$core$Array$fromList(
					A2(
						F2(
							function (x, y) {
								return A2(_elm_lang$core$Basics_ops['++'], x, y);
							}),
						A2(_elm_lang$core$List$repeat, x, true),
						A2(
							_elm_lang$core$List$drop,
							x,
							_elm_lang$core$Array$toList(
								A2(
									_elm_lang$core$Maybe$withDefault,
									_elm_lang$core$Array$empty,
									A2(_elm_lang$core$Array$get, y - 1, screen))))));
				var newScreen = A3(_elm_lang$core$Array$set, y - 1, newRow, screen);
				var _v0 = x,
					_v1 = y - 1,
					_v2 = newScreen;
				x = _v0;
				y = _v1;
				screen = _v2;
				continue rect;
			}
		}
	});
var _user$project$Y16D08$step = F2(
	function (instruction, screen) {
		var _p0 = instruction;
		switch (_p0.ctor) {
			case 'Rect':
				return A3(_user$project$Y16D08$rect, _p0._0, _p0._1, screen);
			case 'Row':
				return A3(_user$project$Y16D08$rotateRow, _p0._0, _p0._1, screen);
			case 'Col':
				return A3(_user$project$Y16D08$rotateCol, _p0._0, _p0._1, screen);
			default:
				return screen;
		}
	});
var _user$project$Y16D08$decode = F2(
	function (instructions, screen) {
		decode:
		while (true) {
			var _p1 = instructions;
			if (_p1.ctor === '[]') {
				return screen;
			} else {
				var _v5 = _p1._1,
					_v6 = A2(_user$project$Y16D08$step, _p1._0, screen);
				instructions = _v5;
				screen = _v6;
				continue decode;
			}
		}
	});
var _user$project$Y16D08$Invalid = {ctor: 'Invalid'};
var _user$project$Y16D08$Col = F2(
	function (a, b) {
		return {ctor: 'Col', _0: a, _1: b};
	});
var _user$project$Y16D08$Row = F2(
	function (a, b) {
		return {ctor: 'Row', _0: a, _1: b};
	});
var _user$project$Y16D08$Rect = F2(
	function (a, b) {
		return {ctor: 'Rect', _0: a, _1: b};
	});
var _user$project$Y16D08$parseInstruction = function (submatches) {
	var _p2 = function () {
		var _p3 = submatches;
		if (((((((_p3.ctor === '::') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === '::')) && (_p3._1._0.ctor === 'Just')) && (_p3._1._1.ctor === '::')) && (_p3._1._1._0.ctor === 'Just')) && (_p3._1._1._1.ctor === '[]')) {
			return {
				ctor: '_Tuple3',
				_0: _p3._0._0,
				_1: A2(
					_elm_lang$core$Result$withDefault,
					0,
					_elm_lang$core$String$toInt(_p3._1._0._0)),
				_2: A2(
					_elm_lang$core$Result$withDefault,
					0,
					_elm_lang$core$String$toInt(_p3._1._1._0._0))
			};
		} else {
			return {ctor: '_Tuple3', _0: '', _1: 0, _2: 0};
		}
	}();
	var string = _p2._0;
	var i = _p2._1;
	var j = _p2._2;
	var _p4 = string;
	switch (_p4) {
		case 'rect ':
			return A2(_user$project$Y16D08$Rect, i, j);
		case 'rotate row y=':
			return A2(_user$project$Y16D08$Row, i, j);
		case 'rotate column x=':
			return A2(_user$project$Y16D08$Col, i, j);
		default:
			return _user$project$Y16D08$Invalid;
	}
};
var _user$project$Y16D08$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		_user$project$Y16D08$parseInstruction,
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('(rect |rotate (?:row y|column x)=)(\\d+)(?:x| by )(\\d+)'),
				input)));
};
var _user$project$Y16D08$answer = F2(
	function (part, input) {
		var instructions = _user$project$Y16D08$parse(input);
		var screen = A2(_user$project$Y16D08$decode, instructions, _user$project$Y16D08$initialScreen);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _user$project$Y16D08$count(screen) : _user$project$Y16D08$display(screen);
	});

var _user$project$Y16D09$parse = function (input) {
	return A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex('\\s'),
		function (_p0) {
			return '';
		},
		input);
};
var _user$project$Y16D09$toInt = function (string) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(string));
};
var _user$project$Y16D09$matches = function (string) {
	var m = _elm_lang$core$List$head(
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.submatches;
			},
			A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$AtMost(1),
				_elm_lang$core$Regex$regex('^([A-Z]*)\\((\\d+)x(\\d+)\\)(.+)$'),
				string)));
	var _p1 = m;
	if ((((((((((_p1.ctor === 'Just') && (_p1._0.ctor === '::')) && (_p1._0._0.ctor === 'Just')) && (_p1._0._1.ctor === '::')) && (_p1._0._1._0.ctor === 'Just')) && (_p1._0._1._1.ctor === '::')) && (_p1._0._1._1._0.ctor === 'Just')) && (_p1._0._1._1._1.ctor === '::')) && (_p1._0._1._1._1._0.ctor === 'Just')) && (_p1._0._1._1._1._1.ctor === '[]')) {
		return {
			ctor: '_Tuple4',
			_0: _p1._0._0._0,
			_1: _user$project$Y16D09$toInt(_p1._0._1._0._0),
			_2: _user$project$Y16D09$toInt(_p1._0._1._1._0._0),
			_3: _p1._0._1._1._1._0._0
		};
	} else {
		return {ctor: '_Tuple4', _0: '', _1: 0, _2: 0, _3: ''};
	}
};
var _user$project$Y16D09$decompressedLength = function (string) {
	var _p2 = _user$project$Y16D09$matches(string);
	var caps = _p2._0;
	var len = _p2._1;
	var num = _p2._2;
	var rest = _p2._3;
	if (_elm_lang$core$Native_Utils.eq(rest, '')) {
		return _elm_lang$core$String$length(string);
	} else {
		var p3 = _user$project$Y16D09$decompressedLength(
			A2(_elm_lang$core$String$dropLeft, len, rest));
		var p2 = _user$project$Y16D09$decompressedLength(
			A2(
				_elm_lang$core$String$repeat,
				num,
				A2(_elm_lang$core$String$left, len, rest)));
		var p1 = _elm_lang$core$String$length(caps);
		return (p1 + p2) + p3;
	}
};
var _user$project$Y16D09$decompress = function (string) {
	var _p3 = _user$project$Y16D09$matches(string);
	var caps = _p3._0;
	var len = _p3._1;
	var num = _p3._2;
	var rest = _p3._3;
	if (_elm_lang$core$Native_Utils.eq(rest, '')) {
		return string;
	} else {
		var p3 = _user$project$Y16D09$decompress(
			A2(_elm_lang$core$String$dropLeft, len, rest));
		var p2 = A2(
			_elm_lang$core$String$repeat,
			num,
			A2(_elm_lang$core$String$left, len, rest));
		var p1 = caps;
		return A2(
			_elm_lang$core$Basics_ops['++'],
			p1,
			A2(_elm_lang$core$Basics_ops['++'], p2, p3));
	}
};
var _user$project$Y16D09$answer = F2(
	function (part, input) {
		var file = _user$project$Y16D09$parse(input);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_elm_lang$core$String$length(
				_user$project$Y16D09$decompress(file))) : _elm_lang$core$Basics$toString(
			_user$project$Y16D09$decompressedLength(file));
	});

var _user$project$Y16D10$parse = function (input) {
	var specific = 'value (\\d+) goes to ((?:bot|output) \\d+)';
	var highLow = '(bot \\d+) gives low to ((?:bot|output) \\d+) and high to ((?:bot|output) \\d+)';
	var pattern = A2(
		_elm_lang$core$Basics_ops['++'],
		highLow,
		A2(_elm_lang$core$Basics_ops['++'], '|', specific));
	return A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.submatches;
		},
		A3(
			_elm_lang$core$Regex$find,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex(pattern),
			input));
};
var _user$project$Y16D10$process = F2(
	function (matches, state) {
		process:
		while (true) {
			var _p0 = matches;
			if (_p0.ctor === '[]') {
				return state;
			} else {
				var _p8 = _p0._1;
				var _p7 = _p0._0;
				var _p1 = _p7;
				_v1_2:
				do {
					if (_p1.ctor === '::') {
						if (_p1._0.ctor === 'Just') {
							if (((((((((_p1._1.ctor === '::') && (_p1._1._0.ctor === 'Just')) && (_p1._1._1.ctor === '::')) && (_p1._1._1._0.ctor === 'Just')) && (_p1._1._1._1.ctor === '::')) && (_p1._1._1._1._0.ctor === 'Nothing')) && (_p1._1._1._1._1.ctor === '::')) && (_p1._1._1._1._1._0.ctor === 'Nothing')) && (_p1._1._1._1._1._1.ctor === '[]')) {
								var _p5 = _p1._1._0._0;
								var _p4 = _p1._1._1._0._0;
								var chips = A2(
									_elm_lang$core$Maybe$withDefault,
									{ctor: '[]'},
									A2(_elm_lang$core$Dict$get, _p1._0._0, state));
								var newState = function () {
									var _p2 = chips;
									if (((_p2.ctor === '::') && (_p2._1.ctor === '::')) && (_p2._1._1.ctor === '[]')) {
										var highChips = A2(
											_elm_lang$core$Maybe$withDefault,
											{ctor: '[]'},
											A2(_elm_lang$core$Dict$get, _p4, state));
										var lowChips = A2(
											_elm_lang$core$Maybe$withDefault,
											{ctor: '[]'},
											A2(_elm_lang$core$Dict$get, _p5, state));
										return A3(
											_elm_lang$core$Dict$insert,
											_p4,
											_elm_lang$core$List$sort(
												{ctor: '::', _0: _p2._1._0, _1: highChips}),
											A3(
												_elm_lang$core$Dict$insert,
												_p5,
												_elm_lang$core$List$sort(
													{ctor: '::', _0: _p2._0, _1: lowChips}),
												state));
									} else {
										return state;
									}
								}();
								var newMatches = function () {
									var _p3 = chips;
									if (((_p3.ctor === '::') && (_p3._1.ctor === '::')) && (_p3._1._1.ctor === '[]')) {
										return _p8;
									} else {
										return _elm_lang$core$List$reverse(
											A2(
												F2(
													function (x, y) {
														return {ctor: '::', _0: x, _1: y};
													}),
												_p7,
												_elm_lang$core$List$reverse(_p8)));
									}
								}();
								var _v4 = newMatches,
									_v5 = newState;
								matches = _v4;
								state = _v5;
								continue process;
							} else {
								break _v1_2;
							}
						} else {
							if (((((((((_p1._1.ctor === '::') && (_p1._1._0.ctor === 'Nothing')) && (_p1._1._1.ctor === '::')) && (_p1._1._1._0.ctor === 'Nothing')) && (_p1._1._1._1.ctor === '::')) && (_p1._1._1._1._0.ctor === 'Just')) && (_p1._1._1._1._1.ctor === '::')) && (_p1._1._1._1._1._0.ctor === 'Just')) && (_p1._1._1._1._1._1.ctor === '[]')) {
								var _p6 = _p1._1._1._1._1._0._0;
								var chips = A2(
									_elm_lang$core$Maybe$withDefault,
									{ctor: '[]'},
									A2(_elm_lang$core$Dict$get, _p6, state));
								var newChips = _elm_lang$core$List$sort(
									function (i) {
										return {ctor: '::', _0: i, _1: chips};
									}(
										A2(
											_elm_lang$core$Result$withDefault,
											0,
											_elm_lang$core$String$toInt(_p1._1._1._1._0._0))));
								var newState = A3(_elm_lang$core$Dict$insert, _p6, newChips, state);
								var _v6 = _p8,
									_v7 = newState;
								matches = _v6;
								state = _v7;
								continue process;
							} else {
								break _v1_2;
							}
						}
					} else {
						break _v1_2;
					}
				} while(false);
				var _v8 = _p8,
					_v9 = state;
				matches = _v8;
				state = _v9;
				continue process;
			}
		}
	});
var _user$project$Y16D10$init = _elm_lang$core$Dict$empty;
var _user$project$Y16D10$multiply = F3(
	function (num, state, ids) {
		multiply:
		while (true) {
			var _p9 = ids;
			if (_p9.ctor === '[]') {
				return num;
			} else {
				var output = A2(
					F2(
						function (x, y) {
							return A2(_elm_lang$core$Basics_ops['++'], x, y);
						}),
					'output ',
					_elm_lang$core$Basics$toString(_p9._0));
				var chips = A2(
					_elm_lang$core$Maybe$withDefault,
					{ctor: '[]'},
					A2(_elm_lang$core$Dict$get, output, state));
				var newNum = A2(
					F2(
						function (x, y) {
							return x * y;
						}),
					num,
					_elm_lang$core$List$product(chips));
				var _v11 = newNum,
					_v12 = state,
					_v13 = _p9._1;
				num = _v11;
				state = _v12;
				ids = _v13;
				continue multiply;
			}
		}
	});
var _user$project$Y16D10$lookfor = F2(
	function (match, idLists) {
		lookfor:
		while (true) {
			var _p10 = idLists;
			if (_p10.ctor === '[]') {
				return 'none';
			} else {
				var _p11 = _p10._0._0;
				if (_elm_lang$core$Native_Utils.eq(
					A2(
						_elm_lang$core$String$join,
						'-',
						A2(_elm_lang$core$List$map, _elm_lang$core$Basics$toString, _p10._0._1)),
					match) && A2(_elm_lang$core$String$startsWith, 'bot ', _p11)) {
					return _p11;
				} else {
					var _v15 = match,
						_v16 = _p10._1;
					match = _v15;
					idLists = _v16;
					continue lookfor;
				}
			}
		}
	});
var _user$project$Y16D10$answer = F2(
	function (part, input) {
		var matches = _user$project$Y16D10$parse(input);
		var state = A2(_user$project$Y16D10$process, matches, _user$project$Y16D10$init);
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A2(
			_user$project$Y16D10$lookfor,
			'17-61',
			_elm_lang$core$Dict$toList(state)) : _elm_lang$core$Basics$toString(
			A3(
				_user$project$Y16D10$multiply,
				1,
				state,
				{
					ctor: '::',
					_0: 0,
					_1: {
						ctor: '::',
						_0: 1,
						_1: {
							ctor: '::',
							_0: 2,
							_1: {ctor: '[]'}
						}
					}
				}));
	});

var _user$project$Y16D11$answer = F2(
	function (part, input) {
		return _user$project$Util$failed;
	});

var _user$project$Y16D12$initState = function (instructions) {
	return {
		index: 0,
		instructions: instructions,
		registers: _elm_lang$core$Dict$fromList(
			{
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'a', _1: 0},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'b', _1: 0},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'c', _1: 0},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'd', _1: 0},
							_1: {ctor: '[]'}
						}
					}
				}
			})
	};
};
var _user$project$Y16D12$set = F3(
	function (reg, state, val) {
		return A3(_elm_lang$core$Dict$insert, reg, val, state.registers);
	});
var _user$project$Y16D12$get = F2(
	function (reg, state) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(_elm_lang$core$Dict$get, reg, state.registers));
	});
var _user$project$Y16D12$State = F3(
	function (a, b, c) {
		return {index: a, instructions: b, registers: c};
	});
var _user$project$Y16D12$Invalid = {ctor: 'Invalid'};
var _user$project$Y16D12$process = function (state) {
	process:
	while (true) {
		var maybeInstruction = A2(_elm_lang$core$Array$get, state.index, state.instructions);
		var _p0 = maybeInstruction;
		if (_p0.ctor === 'Nothing') {
			return state;
		} else {
			var _p7 = _p0._0;
			if (_elm_lang$core$Native_Utils.eq(_p7, _user$project$Y16D12$Invalid)) {
				return state;
			} else {
				var index = function () {
					var $default = state.index + 1;
					var _p1 = _p7;
					switch (_p1.ctor) {
						case 'Jnz':
							var _p2 = _p1._1;
							return (_elm_lang$core$Native_Utils.eq(
								A2(_user$project$Y16D12$get, _p1._0, state),
								0) || _elm_lang$core$Native_Utils.eq(_p2, 0)) ? $default : (state.index + _p2);
						case 'Jiz':
							var _p3 = _p1._1;
							return (_elm_lang$core$Native_Utils.eq(_p1._0, 0) || _elm_lang$core$Native_Utils.eq(_p3, 0)) ? $default : (state.index + _p3);
						default:
							return $default;
					}
				}();
				var registers = function () {
					var _p4 = _p7;
					switch (_p4.ctor) {
						case 'Cpn':
							return A3(_user$project$Y16D12$set, _p4._1, state, _p4._0);
						case 'Cpr':
							return A3(
								_user$project$Y16D12$set,
								_p4._1,
								state,
								A2(_user$project$Y16D12$get, _p4._0, state));
						case 'Inc':
							var _p5 = _p4._0;
							return A3(
								_user$project$Y16D12$set,
								_p5,
								state,
								A2(
									F2(
										function (x, y) {
											return x + y;
										}),
									1,
									A2(_user$project$Y16D12$get, _p5, state)));
						case 'Dec':
							var _p6 = _p4._0;
							return A3(
								_user$project$Y16D12$set,
								_p6,
								state,
								A2(
									F2(
										function (x, y) {
											return x + y;
										}),
									-1,
									A2(_user$project$Y16D12$get, _p6, state)));
						default:
							return state.registers;
					}
				}();
				var _v3 = _elm_lang$core$Native_Utils.update(
					state,
					{registers: registers, index: index});
				state = _v3;
				continue process;
			}
		}
	}
};
var _user$project$Y16D12$Jiz = F2(
	function (a, b) {
		return {ctor: 'Jiz', _0: a, _1: b};
	});
var _user$project$Y16D12$Jnz = F2(
	function (a, b) {
		return {ctor: 'Jnz', _0: a, _1: b};
	});
var _user$project$Y16D12$Dec = function (a) {
	return {ctor: 'Dec', _0: a};
};
var _user$project$Y16D12$Inc = function (a) {
	return {ctor: 'Inc', _0: a};
};
var _user$project$Y16D12$Cpr = F2(
	function (a, b) {
		return {ctor: 'Cpr', _0: a, _1: b};
	});
var _user$project$Y16D12$Cpn = F2(
	function (a, b) {
		return {ctor: 'Cpn', _0: a, _1: b};
	});
var _user$project$Y16D12$parseMatches = function (matches) {
	var _p8 = matches;
	_v4_4:
	do {
		if (_p8.ctor === '::') {
			if (_p8._0.ctor === 'Just') {
				if (((((((((((_p8._1.ctor === '::') && (_p8._1._0.ctor === 'Just')) && (_p8._1._1.ctor === '::')) && (_p8._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1.ctor === '::')) && (_p8._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1.ctor === '::')) && (_p8._1._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1._1.ctor === '::')) && (_p8._1._1._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1._1._1.ctor === '[]')) {
					var _p11 = _p8._1._0._0;
					var _p10 = _p8._0._0;
					var _p9 = _elm_lang$core$String$toInt(_p10);
					if (_p9.ctor === 'Ok') {
						return A2(_user$project$Y16D12$Cpn, _p9._0, _p11);
					} else {
						return A2(_user$project$Y16D12$Cpr, _p10, _p11);
					}
				} else {
					break _v4_4;
				}
			} else {
				if (((_p8._1.ctor === '::') && (_p8._1._0.ctor === 'Nothing')) && (_p8._1._1.ctor === '::')) {
					if (_p8._1._1._0.ctor === 'Just') {
						if (((((((_p8._1._1._1.ctor === '::') && (_p8._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1.ctor === '::')) && (_p8._1._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1._1.ctor === '::')) && (_p8._1._1._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1._1._1.ctor === '[]')) {
							return _user$project$Y16D12$Inc(_p8._1._1._0._0);
						} else {
							break _v4_4;
						}
					} else {
						if (_p8._1._1._1.ctor === '::') {
							if (_p8._1._1._1._0.ctor === 'Just') {
								if (((((_p8._1._1._1._1.ctor === '::') && (_p8._1._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1._1.ctor === '::')) && (_p8._1._1._1._1._1._0.ctor === 'Nothing')) && (_p8._1._1._1._1._1._1.ctor === '[]')) {
									return _user$project$Y16D12$Dec(_p8._1._1._1._0._0);
								} else {
									break _v4_4;
								}
							} else {
								if (((((_p8._1._1._1._1.ctor === '::') && (_p8._1._1._1._1._0.ctor === 'Just')) && (_p8._1._1._1._1._1.ctor === '::')) && (_p8._1._1._1._1._1._0.ctor === 'Just')) && (_p8._1._1._1._1._1._1.ctor === '[]')) {
									var _p13 = _p8._1._1._1._1._0._0;
									var jmp = A2(
										_elm_lang$core$Result$withDefault,
										0,
										_elm_lang$core$String$toInt(_p8._1._1._1._1._1._0._0));
									var _p12 = _elm_lang$core$String$toInt(_p13);
									if (_p12.ctor === 'Ok') {
										return A2(_user$project$Y16D12$Jiz, _p12._0, jmp);
									} else {
										return A2(_user$project$Y16D12$Jnz, _p13, jmp);
									}
								} else {
									break _v4_4;
								}
							}
						} else {
							break _v4_4;
						}
					}
				} else {
					break _v4_4;
				}
			}
		} else {
			break _v4_4;
		}
	} while(false);
	return _user$project$Y16D12$Invalid;
};
var _user$project$Y16D12$parse = function (input) {
	return _elm_lang$core$Array$fromList(
		A2(
			_elm_lang$core$List$map,
			_user$project$Y16D12$parseMatches,
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.submatches;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('cpy ([abcd]|-?\\d+) ([abcd])|inc ([abcd])|dec ([abcd])|jnz ([abcd]|-?\\d+) (-?\\d+)'),
					input))));
};
var _user$project$Y16D12$answer = F2(
	function (part, input) {
		var state = _user$project$Y16D12$initState(
			_user$project$Y16D12$parse(input));
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y16D12$get,
				'a',
				_user$project$Y16D12$process(state))) : _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y16D12$get,
				'a',
				_user$project$Y16D12$process(
					_elm_lang$core$Native_Utils.update(
						state,
						{
							registers: A3(_user$project$Y16D12$set, 'c', state, 1)
						}))));
	});

var _user$project$Y16D13$parse = function (input) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(
			A2(_elm_lang$core$String$dropRight, 1, input)));
};
var _user$project$Y16D13$same = F2(
	function (c1, c2) {
		return _elm_lang$core$Native_Utils.eq(c1.x, c2.x) && _elm_lang$core$Native_Utils.eq(c1.y, c2.y);
	});
var _user$project$Y16D13$toBinary = function (num) {
	var _p0 = num;
	switch (_p0) {
		case 0:
			return '0';
		case 1:
			return '1';
		default:
			var r = A2(_elm_lang$core$Basics_ops['%'], num, 2);
			var q = (num / 2) | 0;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				_user$project$Y16D13$toBinary(q),
				_user$project$Y16D13$toBinary(r));
	}
};
var _user$project$Y16D13$open = F2(
	function (fav, cell) {
		var y = cell.y;
		var x = cell.x;
		var num = (((((x * x) + (3 * x)) + ((2 * x) * y)) + y) + (y * y)) + fav;
		var ones = _elm_lang$core$List$length(
			A2(
				_elm_lang$core$List$filter,
				function (c) {
					return _elm_lang$core$Native_Utils.eq(
						c,
						_elm_lang$core$Native_Utils.chr('1'));
				},
				_elm_lang$core$String$toList(
					_user$project$Y16D13$toBinary(num))));
		return _elm_lang$core$Native_Utils.eq(
			A2(_elm_lang$core$Basics_ops['%'], ones, 2),
			0);
	});
var _user$project$Y16D13$start = {x: 1, y: 1, d: 0};
var _user$project$Y16D13$Cell = F3(
	function (a, b, c) {
		return {x: a, y: b, d: c};
	});
var _user$project$Y16D13$getNeighbours = F3(
	function (fav, visited, cell) {
		var notSeenBefore = function (neighbour) {
			return !A2(
				_elm_lang$core$List$any,
				_user$project$Y16D13$same(neighbour),
				visited);
		};
		var inBounds = function (neighbour) {
			return (_elm_lang$core$Native_Utils.cmp(neighbour.x, 0) > -1) && (_elm_lang$core$Native_Utils.cmp(neighbour.y, 0) > -1);
		};
		var $new = F2(
			function (old, move) {
				return A3(
					_user$project$Y16D13$Cell,
					old.x + _elm_lang$core$Tuple$first(move),
					old.y + _elm_lang$core$Tuple$second(move),
					old.d + 1);
			});
		var moves = {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 1, _1: 0},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 0, _1: 1},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: -1, _1: 0},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 0, _1: -1},
						_1: {ctor: '[]'}
					}
				}
			}
		};
		return A2(
			_elm_lang$core$List$filter,
			notSeenBefore,
			A2(
				_elm_lang$core$List$filter,
				_user$project$Y16D13$open(fav),
				A2(
					_elm_lang$core$List$filter,
					inBounds,
					A2(
						_elm_lang$core$List$map,
						$new(cell),
						moves))));
	});
var _user$project$Y16D13$search = F5(
	function (part, fav, finish, visited, queue) {
		search:
		while (true) {
			var _p1 = queue;
			if (_p1.ctor === '[]') {
				return 0;
			} else {
				var _p2 = _p1._0;
				if (_elm_lang$core$Native_Utils.eq(part, 2) && _elm_lang$core$Native_Utils.eq(_p2.d, 50)) {
					return _elm_lang$core$List$length(visited);
				} else {
					var neighbours = A3(_user$project$Y16D13$getNeighbours, fav, visited, _p2);
					var goal = A2(
						_elm_lang$core$Maybe$withDefault,
						_user$project$Y16D13$start,
						_elm_lang$core$List$head(
							A2(
								_elm_lang$core$List$filter,
								_user$project$Y16D13$same(finish),
								neighbours)));
					if (_elm_lang$core$Native_Utils.eq(part, 1) && (_elm_lang$core$Native_Utils.cmp(goal.d, 0) > 0)) {
						return goal.d;
					} else {
						var _v2 = part,
							_v3 = fav,
							_v4 = finish,
							_v5 = A2(_elm_lang$core$Basics_ops['++'], visited, neighbours),
							_v6 = A2(_elm_lang$core$Basics_ops['++'], _p1._1, neighbours);
						part = _v2;
						fav = _v3;
						finish = _v4;
						visited = _v5;
						queue = _v6;
						continue search;
					}
				}
			}
		}
	});
var _user$project$Y16D13$answer = F2(
	function (part, input) {
		var finish = A3(_user$project$Y16D13$Cell, 31, 39, 0);
		var fav = _user$project$Y16D13$parse(input);
		return _elm_lang$core$Basics$toString(
			A5(
				_user$project$Y16D13$search,
				part,
				fav,
				finish,
				{
					ctor: '::',
					_0: _user$project$Y16D13$start,
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _user$project$Y16D13$start,
					_1: {ctor: '[]'}
				}));
	});

var _user$project$Y16D14$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('[a-z]+'),
					input))));
};
var _user$project$Y16D14$repeatHash = F2(
	function (iterations, hash) {
		repeatHash:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(iterations, 0) < 1) {
				return hash;
			} else {
				var _v0 = iterations - 1,
					_v1 = _sanichi$elm_md5$MD5$hex(hash);
				iterations = _v0;
				hash = _v1;
				continue repeatHash;
			}
		}
	});
var _user$project$Y16D14$getHash = F4(
	function (part, salt, index, cache) {
		var iterations = _elm_lang$core$Native_Utils.eq(part, 1) ? 0 : 2016;
		var maybeHash = A2(_elm_lang$core$Dict$get, index, cache);
		var hash = function () {
			var _p0 = maybeHash;
			if (_p0.ctor === 'Just') {
				return _p0._0;
			} else {
				return _sanichi$elm_md5$MD5$hex(
					A2(
						_elm_lang$core$Basics_ops['++'],
						salt,
						_elm_lang$core$Basics$toString(index)));
			}
		}();
		return A2(_user$project$Y16D14$repeatHash, iterations, hash);
	});
var _user$project$Y16D14$buildCache = F6(
	function (part, salt, upto, index, oldCache, cache) {
		buildCache:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(index, upto) > 0) {
				return cache;
			} else {
				var newIndex = index + 1;
				var hash = A4(_user$project$Y16D14$getHash, part, salt, index, oldCache);
				var newCache = A3(_elm_lang$core$Dict$insert, index, hash, cache);
				var _v3 = part,
					_v4 = salt,
					_v5 = upto,
					_v6 = newIndex,
					_v7 = oldCache,
					_v8 = newCache;
				part = _v3;
				salt = _v4;
				upto = _v5;
				index = _v6;
				oldCache = _v7;
				cache = _v8;
				continue buildCache;
			}
		}
	});
var _user$project$Y16D14$search = F5(
	function (part, salt, keys, index, cache) {
		search:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(keys, 64) > -1) {
				return _elm_lang$core$Basics$toString(index - 1);
			} else {
				var newIndex = index + 1;
				var hash = A4(_user$project$Y16D14$getHash, part, salt, index, cache);
				var maybeMatch3 = _elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.match;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$AtMost(1),
							_elm_lang$core$Regex$regex('(.)\\1\\1'),
							hash)));
				var _p1 = maybeMatch3;
				if (_p1.ctor === 'Nothing') {
					var _v10 = part,
						_v11 = salt,
						_v12 = keys,
						_v13 = newIndex,
						_v14 = cache;
					part = _v10;
					salt = _v11;
					keys = _v12;
					index = _v13;
					cache = _v14;
					continue search;
				} else {
					var newCache = A6(_user$project$Y16D14$buildCache, part, salt, index + 1000, newIndex, cache, _elm_lang$core$Dict$empty);
					var match5 = A2(
						_elm_lang$core$String$left,
						5,
						A2(_elm_lang$core$String$repeat, 2, _p1._0));
					var foundSome = A2(
						_elm_lang$core$List$any,
						_elm_lang$core$String$contains(match5),
						_elm_lang$core$Dict$values(newCache));
					var newKeys = foundSome ? (keys + 1) : keys;
					var _v15 = part,
						_v16 = salt,
						_v17 = newKeys,
						_v18 = newIndex,
						_v19 = newCache;
					part = _v15;
					salt = _v16;
					keys = _v17;
					index = _v18;
					cache = _v19;
					continue search;
				}
			}
		}
	});
var _user$project$Y16D14$answer = F2(
	function (part, input) {
		var salt = _user$project$Y16D14$parse(input);
		return A5(_user$project$Y16D14$search, part, salt, 0, 0, _elm_lang$core$Dict$empty);
	});

var _user$project$Y16D15$push = F2(
	function (item, list) {
		return _elm_lang$core$List$reverse(
			function (l) {
				return {ctor: '::', _0: item, _1: l};
			}(
				_elm_lang$core$List$reverse(list)));
	});
var _user$project$Y16D15$invalid = {number: 0, positions: 1, position: 0};
var _user$project$Y16D15$rotate = F2(
	function (time, disc) {
		return _elm_lang$core$Native_Utils.update(
			disc,
			{
				position: A2(_elm_lang$core$Basics_ops['%'], disc.position + time, disc.positions)
			});
	});
var _user$project$Y16D15$initShift = F3(
	function (time, maze, initMaze) {
		initShift:
		while (true) {
			var _p0 = initMaze;
			if (_p0.ctor === '[]') {
				return maze;
			} else {
				var newTime = time + 1;
				var newDisc = A2(_user$project$Y16D15$rotate, time, _p0._0);
				var newMaze = A2(_user$project$Y16D15$push, newDisc, maze);
				var _v1 = newTime,
					_v2 = newMaze,
					_v3 = _p0._1;
				time = _v1;
				maze = _v2;
				initMaze = _v3;
				continue initShift;
			}
		}
	});
var _user$project$Y16D15$advance = function (maze) {
	return A2(
		_elm_lang$core$List$map,
		_user$project$Y16D15$rotate(1),
		maze);
};
var _user$project$Y16D15$open = function (maze) {
	return A2(
		_elm_lang$core$List$all,
		function (d) {
			return _elm_lang$core$Native_Utils.eq(d.position, 0);
		},
		maze);
};
var _user$project$Y16D15$search_ = F2(
	function (time, maze) {
		search_:
		while (true) {
			if (_user$project$Y16D15$open(maze)) {
				return time;
			} else {
				var _v4 = time + 1,
					_v5 = _user$project$Y16D15$advance(maze);
				time = _v4;
				maze = _v5;
				continue search_;
			}
		}
	});
var _user$project$Y16D15$search = function (maze) {
	var shiftedMaze = A3(
		_user$project$Y16D15$initShift,
		1,
		{ctor: '[]'},
		maze);
	return A2(_user$project$Y16D15$search_, 0, shiftedMaze);
};
var _user$project$Y16D15$Disc = F3(
	function (a, b, c) {
		return {number: a, positions: b, position: c};
	});
var _user$project$Y16D15$toDisc = function (numbers) {
	var _p1 = numbers;
	if ((((_p1.ctor === '::') && (_p1._1.ctor === '::')) && (_p1._1._1.ctor === '::')) && (_p1._1._1._1.ctor === '[]')) {
		return A3(_user$project$Y16D15$Disc, _p1._0, _p1._1._0, _p1._1._1._0);
	} else {
		return _user$project$Y16D15$invalid;
	}
};
var _user$project$Y16D15$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		_user$project$Y16D15$toDisc,
		A2(
			_elm_lang$core$List$map,
			_elm_lang$core$List$map(
				_elm_lang$core$Result$withDefault(0)),
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$List$map(_elm_lang$core$String$toInt),
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$List$map(
						_elm_lang$core$Maybe$withDefault('')),
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.submatches;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$All,
							_elm_lang$core$Regex$regex('Disc #(\\d+) has (\\d+) positions; at time=0, it is at position (\\d+).'),
							input))))));
};
var _user$project$Y16D15$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_user$project$Y16D15$search(
				_user$project$Y16D15$parse(input))) : _elm_lang$core$Basics$toString(
			_user$project$Y16D15$search(
				A2(
					_user$project$Y16D15$push,
					A3(_user$project$Y16D15$Disc, 7, 11, 0),
					_user$project$Y16D15$parse(input))));
	});

var _user$project$Y16D16$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('[01]+'),
					input))));
};
var _user$project$Y16D16$twoToOne = function (pair) {
	var _p0 = pair;
	switch (_p0) {
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
var _user$project$Y16D16$swap = function (c) {
	return _elm_lang$core$Native_Utils.eq(
		c,
		_elm_lang$core$Native_Utils.chr('0')) ? _elm_lang$core$Native_Utils.chr('1') : _elm_lang$core$Native_Utils.chr('0');
};
var _user$project$Y16D16$checksum_ = function (data) {
	checksum_:
	while (true) {
		if (_elm_lang$core$Native_Utils.eq(
			A2(
				_elm_lang$core$Basics_ops['%'],
				_elm_lang$core$String$length(data),
				2),
			1)) {
			return data;
		} else {
			var _v1 = _elm_lang$core$String$concat(
				A2(
					_elm_lang$core$List$map,
					_user$project$Y16D16$twoToOne,
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.match;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$All,
							_elm_lang$core$Regex$regex('..'),
							data))));
			data = _v1;
			continue checksum_;
		}
	}
};
var _user$project$Y16D16$checksum = F2(
	function (len, data) {
		return _user$project$Y16D16$checksum_(
			A2(_elm_lang$core$String$left, len, data));
	});
var _user$project$Y16D16$generate = F2(
	function (len, data) {
		generate:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(
				_elm_lang$core$String$length(data),
				len) > -1) {
				return data;
			} else {
				var copy = _elm_lang$core$String$fromList(
					A2(
						_elm_lang$core$List$map,
						_user$project$Y16D16$swap,
						_elm_lang$core$String$toList(
							_elm_lang$core$String$reverse(data))));
				var newData = A2(
					_elm_lang$core$Basics_ops['++'],
					data,
					A2(_elm_lang$core$Basics_ops['++'], '0', copy));
				var _v2 = len,
					_v3 = newData;
				len = _v2;
				data = _v3;
				continue generate;
			}
		}
	});
var _user$project$Y16D16$generateAndChecksum = F2(
	function (len, init) {
		return A2(
			_user$project$Y16D16$checksum,
			len,
			A2(_user$project$Y16D16$generate, len, init));
	});
var _user$project$Y16D16$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? A2(
			_user$project$Y16D16$generateAndChecksum,
			272,
			_user$project$Y16D16$parse(input)) : A2(
			_user$project$Y16D16$generateAndChecksum,
			35651584,
			_user$project$Y16D16$parse(input));
	});

var _user$project$Y16D17$parse = function (input) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'',
		_elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$map,
				function (_) {
					return _.match;
				},
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_elm_lang$core$Regex$regex('\\S+'),
					input))));
};
var _user$project$Y16D17$fCode = _elm_lang$core$Char$toCode(
	_elm_lang$core$Native_Utils.chr('f'));
var _user$project$Y16D17$bCode = _elm_lang$core$Char$toCode(
	_elm_lang$core$Native_Utils.chr('b'));
var _user$project$Y16D17$found = function (location) {
	return _elm_lang$core$Native_Utils.eq(location.x, 3) && _elm_lang$core$Native_Utils.eq(location.y, 3);
};
var _user$project$Y16D17$Location = F3(
	function (a, b, c) {
		return {x: a, y: b, path: c};
	});
var _user$project$Y16D17$newLocation = F2(
	function (location, _p0) {
		var _p1 = _p0;
		var _p4 = _p1._1;
		if ((_elm_lang$core$Native_Utils.cmp(_p4, _user$project$Y16D17$bCode) < 0) || (_elm_lang$core$Native_Utils.cmp(_p4, _user$project$Y16D17$fCode) > 0)) {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			var _p2 = function () {
				var _p3 = _p1._0;
				switch (_p3) {
					case 0:
						return {ctor: '_Tuple3', _0: location.x, _1: location.y - 1, _2: 'U'};
					case 1:
						return {ctor: '_Tuple3', _0: location.x, _1: location.y + 1, _2: 'D'};
					case 2:
						return {ctor: '_Tuple3', _0: location.x - 1, _1: location.y, _2: 'L'};
					default:
						return {ctor: '_Tuple3', _0: location.x + 1, _1: location.y, _2: 'R'};
				}
			}();
			var x = _p2._0;
			var y = _p2._1;
			var step = _p2._2;
			return ((_elm_lang$core$Native_Utils.cmp(x, 0) < 0) || ((_elm_lang$core$Native_Utils.cmp(y, 0) < 0) || ((_elm_lang$core$Native_Utils.cmp(x, 3) > 0) || (_elm_lang$core$Native_Utils.cmp(y, 3) > 0)))) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(
				A3(
					_user$project$Y16D17$Location,
					x,
					y,
					A2(_elm_lang$core$Basics_ops['++'], location.path, step)));
		}
	});
var _user$project$Y16D17$newLocations = F2(
	function (passcode, location) {
		return A2(
			_elm_lang$core$List$filterMap,
			_user$project$Y16D17$newLocation(location),
			A2(
				_elm_lang$core$List$indexedMap,
				F2(
					function (i, c) {
						return {ctor: '_Tuple2', _0: i, _1: c};
					}),
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$Char$toCode,
					_elm_lang$core$String$toList(
						A2(
							_elm_lang$core$String$left,
							4,
							_sanichi$elm_md5$MD5$hex(
								A2(_elm_lang$core$Basics_ops['++'], passcode, location.path)))))));
	});
var _user$project$Y16D17$search = F4(
	function (part, len, queue, passcode) {
		search:
		while (true) {
			var _p5 = queue;
			if (_p5.ctor === '[]') {
				return _elm_lang$core$Native_Utils.eq(part, 1) ? 'none' : _elm_lang$core$Basics$toString(len);
			} else {
				var _p9 = _p5._1;
				var locations = A2(_user$project$Y16D17$newLocations, passcode, _p5._0);
				var maybeGoal = _elm_lang$core$List$head(
					A2(_elm_lang$core$List$filter, _user$project$Y16D17$found, locations));
				var _p6 = maybeGoal;
				if (_p6.ctor === 'Nothing') {
					var _v4 = part,
						_v5 = len,
						_v6 = A2(_elm_lang$core$Basics_ops['++'], _p9, locations),
						_v7 = passcode;
					part = _v4;
					len = _v5;
					queue = _v6;
					passcode = _v7;
					continue search;
				} else {
					var _p8 = _p6._0;
					if (_elm_lang$core$Native_Utils.eq(part, 1)) {
						return _p8.path;
					} else {
						var notGoals = A2(
							_elm_lang$core$List$filter,
							function (_p7) {
								return !_user$project$Y16D17$found(_p7);
							},
							locations);
						var newLen = _elm_lang$core$String$length(_p8.path);
						var _v8 = part,
							_v9 = newLen,
							_v10 = A2(_elm_lang$core$Basics_ops['++'], _p9, notGoals),
							_v11 = passcode;
						part = _v8;
						len = _v9;
						queue = _v10;
						passcode = _v11;
						continue search;
					}
				}
			}
		}
	});
var _user$project$Y16D17$start = A3(_user$project$Y16D17$Location, 0, 0, '');
var _user$project$Y16D17$answer = F2(
	function (part, input) {
		return A4(
			_user$project$Y16D17$search,
			part,
			0,
			{
				ctor: '::',
				_0: _user$project$Y16D17$start,
				_1: {ctor: '[]'}
			},
			_user$project$Y16D17$parse(input));
	});

var _user$project$Y16D18$parse = function (input) {
	return A2(
		_elm_lang$core$List$map,
		function (c) {
			return _elm_lang$core$Native_Utils.eq(
				c,
				_elm_lang$core$Native_Utils.chr('^')) ? true : false;
		},
		_elm_lang$core$String$toList(
			A2(
				_elm_lang$core$Maybe$withDefault,
				'',
				_elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$map,
						function (_) {
							return _.match;
						},
						A3(
							_elm_lang$core$Regex$find,
							_elm_lang$core$Regex$AtMost(1),
							_elm_lang$core$Regex$regex('\\S+'),
							input))))));
};
var _user$project$Y16D18$isTrap = F3(
	function (t1, t2, t3) {
		var _p0 = {ctor: '_Tuple3', _0: t1, _1: t2, _2: t3};
		_v0_4:
		do {
			if (_p0.ctor === '_Tuple3') {
				if (_p0._0 === true) {
					if (_p0._1 === true) {
						if (_p0._2 === false) {
							return true;
						} else {
							break _v0_4;
						}
					} else {
						if (_p0._2 === false) {
							return true;
						} else {
							break _v0_4;
						}
					}
				} else {
					if (_p0._1 === true) {
						if (_p0._2 === true) {
							return true;
						} else {
							break _v0_4;
						}
					} else {
						if (_p0._2 === true) {
							return true;
						} else {
							break _v0_4;
						}
					}
				}
			} else {
				break _v0_4;
			}
		} while(false);
		return false;
	});
var _user$project$Y16D18$nextRow = F2(
	function (start, row) {
		var _p1 = row;
		if (_p1.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			if (_p1._1.ctor === '[]') {
				var t = A3(_user$project$Y16D18$isTrap, false, _p1._0, false);
				return {
					ctor: '::',
					_0: t,
					_1: {ctor: '[]'}
				};
			} else {
				if (_p1._1._1.ctor === '[]') {
					var _p3 = _p1._1._0;
					var _p2 = _p1._0;
					if (start) {
						var t = A3(_user$project$Y16D18$isTrap, false, _p2, _p3);
						return {
							ctor: '::',
							_0: t,
							_1: A2(_user$project$Y16D18$nextRow, false, row)
						};
					} else {
						var t = A3(_user$project$Y16D18$isTrap, _p2, _p3, false);
						return {
							ctor: '::',
							_0: t,
							_1: {ctor: '[]'}
						};
					}
				} else {
					var _p6 = _p1._1._1._0;
					var _p5 = _p1._1._0;
					var _p4 = _p1._0;
					if (start) {
						var t = A3(_user$project$Y16D18$isTrap, false, _p4, _p5);
						return {
							ctor: '::',
							_0: t,
							_1: A2(_user$project$Y16D18$nextRow, false, row)
						};
					} else {
						var t = A3(_user$project$Y16D18$isTrap, _p4, _p5, _p6);
						return {
							ctor: '::',
							_0: t,
							_1: A2(
								_user$project$Y16D18$nextRow,
								start,
								{
									ctor: '::',
									_0: _p5,
									_1: {ctor: '::', _0: _p6, _1: _p1._1._1._1}
								})
						};
					}
				}
			}
		}
	});
var _user$project$Y16D18$count = F3(
	function (num, total, row) {
		count:
		while (true) {
			var rowCount = _elm_lang$core$List$length(
				A2(_elm_lang$core$List$filter, _elm_lang$core$Basics$not, row));
			var newTotal = total + rowCount;
			if (_elm_lang$core$Native_Utils.cmp(num, 1) < 1) {
				return newTotal;
			} else {
				var newNum = num - 1;
				var newRow = A2(_user$project$Y16D18$nextRow, true, row);
				var _v2 = newNum,
					_v3 = newTotal,
					_v4 = newRow;
				num = _v2;
				total = _v3;
				row = _v4;
				continue count;
			}
		}
	});
var _user$project$Y16D18$answer = F2(
	function (part, input) {
		var num = _elm_lang$core$Native_Utils.eq(part, 1) ? 40 : 400000;
		return _elm_lang$core$Basics$toString(
			A3(
				_user$project$Y16D18$count,
				num,
				0,
				_user$project$Y16D18$parse(input)));
	});

var _user$project$Y16D19$parse = function (input) {
	return A2(
		_elm_lang$core$Result$withDefault,
		1,
		_elm_lang$core$String$toInt(
			A2(_elm_lang$core$String$dropRight, 1, input)));
};
var _user$project$Y16D19$stealAcross = function (num) {
	var thresh = A2(
		F2(
			function (x, y) {
				return Math.pow(x, y);
			}),
		3,
		_elm_lang$core$Basics$floor(
			A2(
				_elm_lang$core$Basics$logBase,
				3,
				_elm_lang$core$Basics$toFloat(num))));
	return _elm_lang$core$Native_Utils.eq(num, thresh) ? num : ((_elm_lang$core$Native_Utils.cmp(num, 2 * thresh) < 1) ? (num - thresh) : ((2 * num) - (3 * thresh)));
};
var _user$project$Y16D19$stealLeft = function (num) {
	var thresh = A2(
		F2(
			function (x, y) {
				return Math.pow(x, y);
			}),
		2,
		_elm_lang$core$Basics$floor(
			A2(
				_elm_lang$core$Basics$logBase,
				2,
				_elm_lang$core$Basics$toFloat(num))));
	return (2 * (num - thresh)) + 1;
};
var _user$project$Y16D19$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			_user$project$Y16D19$stealLeft(
				_user$project$Y16D19$parse(input))) : _elm_lang$core$Basics$toString(
			_user$project$Y16D19$stealAcross(
				_user$project$Y16D19$parse(input)));
	});

var _user$project$Y16D20$size = function (block) {
	return (block.upper - block.lower) + 1;
};
var _user$project$Y16D20$mergeable = F2(
	function (b1, b2) {
		return _elm_lang$core$Native_Utils.cmp(b2.lower, b1.upper + 1) < 1;
	});
var _user$project$Y16D20$allowed = F2(
	function (remaining, blocks) {
		allowed:
		while (true) {
			var _p0 = blocks;
			if (_p0.ctor === '[]') {
				return remaining;
			} else {
				var newRemaining = remaining - _user$project$Y16D20$size(_p0._0);
				var _v1 = newRemaining,
					_v2 = _p0._1;
				remaining = _v1;
				blocks = _v2;
				continue allowed;
			}
		}
	});
var _user$project$Y16D20$lowest = F2(
	function (num, blocks) {
		lowest:
		while (true) {
			var _p1 = blocks;
			if (_p1.ctor === '[]') {
				return num;
			} else {
				var _p2 = _p1._0;
				if (_elm_lang$core$Native_Utils.cmp(num, _p2.lower) < 0) {
					return num;
				} else {
					var _v4 = _p2.upper + 1,
						_v5 = _p1._1;
					num = _v4;
					blocks = _v5;
					continue lowest;
				}
			}
		}
	});
var _user$project$Y16D20$Block = F2(
	function (a, b) {
		return {lower: a, upper: b};
	});
var _user$project$Y16D20$invalid = A2(_user$project$Y16D20$Block, 0, 0);
var _user$project$Y16D20$notInvalid = function (block) {
	return !_elm_lang$core$Native_Utils.eq(block, _user$project$Y16D20$invalid);
};
var _user$project$Y16D20$toBlock = function (list) {
	var _p3 = list;
	if (((_p3.ctor === '::') && (_p3._1.ctor === '::')) && (_p3._1._1.ctor === '[]')) {
		var _p5 = _p3._1._0;
		var _p4 = _p3._0;
		return (_elm_lang$core$Native_Utils.cmp(_p4, _p5) < 1) ? A2(_user$project$Y16D20$Block, _p4, _p5) : _user$project$Y16D20$invalid;
	} else {
		return _user$project$Y16D20$invalid;
	}
};
var _user$project$Y16D20$merge = F2(
	function (b1, b2) {
		return (_elm_lang$core$Native_Utils.cmp(b2.upper, b1.upper) < 1) ? b1 : A2(_user$project$Y16D20$Block, b1.lower, b2.upper);
	});
var _user$project$Y16D20$compact = function (blocks) {
	compact:
	while (true) {
		var _p6 = blocks;
		if (_p6.ctor === '[]') {
			return blocks;
		} else {
			if (_p6._1.ctor === '[]') {
				return blocks;
			} else {
				var _p9 = _p6._1._1;
				var _p8 = _p6._1._0;
				var _p7 = _p6._0;
				if (A2(_user$project$Y16D20$mergeable, _p7, _p8)) {
					var b = A2(_user$project$Y16D20$merge, _p7, _p8);
					var _v8 = {ctor: '::', _0: b, _1: _p9};
					blocks = _v8;
					continue compact;
				} else {
					return {
						ctor: '::',
						_0: _p7,
						_1: _user$project$Y16D20$compact(
							{ctor: '::', _0: _p8, _1: _p9})
					};
				}
			}
		}
	}
};
var _user$project$Y16D20$parse = function (input) {
	return _user$project$Y16D20$compact(
		A2(
			_elm_lang$core$List$sortBy,
			function (_) {
				return _.lower;
			},
			A2(
				_elm_lang$core$List$filter,
				_user$project$Y16D20$notInvalid,
				A2(
					_elm_lang$core$List$map,
					_user$project$Y16D20$toBlock,
					A2(
						_elm_lang$core$List$map,
						_elm_lang$core$List$map(
							_elm_lang$core$Result$withDefault(0)),
						A2(
							_elm_lang$core$List$map,
							_elm_lang$core$List$map(_elm_lang$core$String$toInt),
							A2(
								_elm_lang$core$List$map,
								_elm_lang$core$List$map(
									_elm_lang$core$Maybe$withDefault('')),
								A2(
									_elm_lang$core$List$map,
									function (_) {
										return _.submatches;
									},
									A3(
										_elm_lang$core$Regex$find,
										_elm_lang$core$Regex$All,
										_elm_lang$core$Regex$regex('(\\d+)-(\\d+)'),
										input)))))))));
};
var _user$project$Y16D20$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y16D20$lowest,
				0,
				_user$project$Y16D20$parse(input))) : _elm_lang$core$Basics$toString(
			A2(
				_user$project$Y16D20$allowed,
				4294967296,
				_user$project$Y16D20$parse(input)));
	});

var _user$project$Y16D21$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? 'TODO' : 'TODO';
	});

var _user$project$Y16D22$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? 'TODO' : 'TODO';
	});

var _user$project$Y16D23$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? 'TODO' : 'TODO';
	});

var _user$project$Y16D24$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? 'TODO' : 'TODO';
	});

var _user$project$Y16D25$answer = F2(
	function (part, input) {
		return _elm_lang$core$Native_Utils.eq(part, 1) ? 'TODO' : _user$project$Util$onlyOnePart;
	});

var _user$project$Y16$answer = F3(
	function (day, part, input) {
		var _p0 = day;
		switch (_p0) {
			case 1:
				return A2(_user$project$Y16D01$answer, part, input);
			case 2:
				return A2(_user$project$Y16D02$answer, part, input);
			case 3:
				return A2(_user$project$Y16D03$answer, part, input);
			case 4:
				return A2(_user$project$Y16D04$answer, part, input);
			case 5:
				return A2(_user$project$Y16D05$answer, part, input);
			case 6:
				return A2(_user$project$Y16D06$answer, part, input);
			case 7:
				return A2(_user$project$Y16D07$answer, part, input);
			case 8:
				return A2(_user$project$Y16D08$answer, part, input);
			case 9:
				return A2(_user$project$Y16D09$answer, part, input);
			case 10:
				return A2(_user$project$Y16D10$answer, part, input);
			case 11:
				return A2(_user$project$Y16D11$answer, part, input);
			case 12:
				return A2(_user$project$Y16D12$answer, part, input);
			case 13:
				return A2(_user$project$Y16D13$answer, part, input);
			case 14:
				return A2(_user$project$Y16D14$answer, part, input);
			case 15:
				return A2(_user$project$Y16D15$answer, part, input);
			case 16:
				return A2(_user$project$Y16D16$answer, part, input);
			case 17:
				return A2(_user$project$Y16D17$answer, part, input);
			case 18:
				return A2(_user$project$Y16D18$answer, part, input);
			case 19:
				return A2(_user$project$Y16D19$answer, part, input);
			case 20:
				return A2(_user$project$Y16D20$answer, part, input);
			case 21:
				return A2(_user$project$Y16D21$answer, part, input);
			case 22:
				return A2(_user$project$Y16D22$answer, part, input);
			case 23:
				return A2(_user$project$Y16D23$answer, part, input);
			case 24:
				return A2(_user$project$Y16D24$answer, part, input);
			case 25:
				return A2(_user$project$Y16D25$answer, part, input);
			default:
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'year 2016, day ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(day),
						': not available'));
		}
	});

var _user$project$Main$getNote = F2(
	function (year, day) {
		var key = A2(
			_elm_lang$core$String$join,
			'-',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Basics$toString,
				{
					ctor: '::',
					_0: year,
					_1: {
						ctor: '::',
						_0: day,
						_1: {ctor: '[]'}
					}
				}));
		var _p0 = key;
		switch (_p0) {
			case '2015-12':
				return _elm_lang$core$Maybe$Just('For part 2 I couldn\'t see any way to filter out the \"red\" parts of the object in Elm so did it in Perl instead.');
			case '2015-22':
				return _elm_lang$core$Maybe$Just('I found this problem highly annoying as there were so many fiddly details to take care of. After many iteratons of a Perl 5 program eventually produced the right answers, I couldn\'t face trying to redo it all in Elm.');
			case '2016-11':
				return _elm_lang$core$Maybe$Just('I didn\'t have much of a clue about this one so quickly admitted defeat and spent my time on other things that day.');
			case '2016-14':
				return _elm_lang$core$Maybe$Just('I left part 2 running for nearly 24 hours and it still hadn\'t finished. So, giving up on that, I wrote a Perl 5 program based on the same algorithm and it only took 20 seconds! I estimate MD5 digests are roughly 100 times faster in Perl 5 than in Elm, so that\'s not the whole story since 100 times 20 seconds is only about half an hour.');
			case '2016-16':
				return _elm_lang$core$Maybe$Just('The Elm program for part 2 crashed my browser window after a few minutes (presumably out of memory) so instead I wrote a Perl 5 program which got the answer in less than a minute while using almost 3GB of memory.');
			default:
				return _elm_lang$core$Maybe$Nothing;
		}
	});
var _user$project$Main$failed = F3(
	function (year, day, part) {
		var key = A2(
			_elm_lang$core$String$join,
			'-',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Basics$toString,
				{
					ctor: '::',
					_0: year,
					_1: {
						ctor: '::',
						_0: day,
						_1: {
							ctor: '::',
							_0: part,
							_1: {ctor: '[]'}
						}
					}
				}));
		var _p1 = key;
		switch (_p1) {
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
var _user$project$Main$speed = F3(
	function (year, day, part) {
		var key = A2(
			_elm_lang$core$String$join,
			'-',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Basics$toString,
				{
					ctor: '::',
					_0: year,
					_1: {
						ctor: '::',
						_0: day,
						_1: {
							ctor: '::',
							_0: part,
							_1: {ctor: '[]'}
						}
					}
				}));
		var _p2 = key;
		switch (_p2) {
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
			default:
				return 0;
		}
	});
var _user$project$Main$toInt = function (str) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(str));
};
var _user$project$Main$viewNote = function (model) {
	var note = A2(
		_elm_lang$core$Maybe$withDefault,
		'',
		A2(_user$project$Main$getNote, model.year, model.day));
	var display = _elm_lang$core$Native_Utils.eq(note, '') ? 'none' : 'table-row';
	return A2(
		_elm_lang$html$Html$tr,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$style(
				{
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'display', _1: display},
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(note),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		});
};
var _user$project$Main$codeLink = function (model) {
	var domain = 'bitbucket.org/';
	var scheme = 'https://';
	var day = _elm_lang$core$Basics$toString(model.day);
	var paddedDay = (_elm_lang$core$Native_Utils.cmp(model.day, 9) > 0) ? day : A2(_elm_lang$core$Basics_ops['++'], '0', day);
	var year = _elm_lang$core$Basics$toString(model.year);
	var shortYear = A2(_elm_lang$core$String$right, 2, year);
	var file = A2(
		_elm_lang$core$Basics_ops['++'],
		'Y',
		A2(
			_elm_lang$core$Basics_ops['++'],
			shortYear,
			A2(
				_elm_lang$core$Basics_ops['++'],
				'D',
				A2(_elm_lang$core$Basics_ops['++'], paddedDay, '.elm'))));
	var path = A2(
		_elm_lang$core$Basics_ops['++'],
		'sanichi/sni_mio_app/src/master/app/views/pages/aoc/',
		A2(_elm_lang$core$Basics_ops['++'], year, '/'));
	var link = A2(
		_elm_lang$core$Basics_ops['++'],
		scheme,
		A2(
			_elm_lang$core$Basics_ops['++'],
			domain,
			A2(_elm_lang$core$Basics_ops['++'], path, file)));
	return A2(
		_elm_lang$html$Html$a,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$href(link),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$target('external2'),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('Code'),
			_1: {ctor: '[]'}
		});
};
var _user$project$Main$probLink = function (model) {
	var domain = 'adventofcode.com/';
	var scheme = 'https://';
	var day = _elm_lang$core$Basics$toString(model.day);
	var file = day;
	var year = _elm_lang$core$Basics$toString(model.year);
	var path = A2(_elm_lang$core$Basics_ops['++'], year, '/day/');
	var link = A2(
		_elm_lang$core$Basics_ops['++'],
		scheme,
		A2(
			_elm_lang$core$Basics_ops['++'],
			domain,
			A2(_elm_lang$core$Basics_ops['++'], path, file)));
	return A2(
		_elm_lang$html$Html$a,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$href(link),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$target('external'),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('Problem'),
			_1: {ctor: '[]'}
		});
};
var _user$project$Main$viewLinks = function (model) {
	return A2(
		_elm_lang$html$Html$tr,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('text-center'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _user$project$Main$probLink(model),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html$text(' • '),
						_1: {
							ctor: '::',
							_0: _user$project$Main$codeLink(model),
							_1: {ctor: '[]'}
						}
					}
				}),
			_1: {ctor: '[]'}
		});
};
var _user$project$Main$failedIndicator = function (failed) {
	return failed ? '✘' : '✔︎';
};
var _user$project$Main$speedDescription = function (time) {
	var _p3 = time;
	switch (_p3) {
		case 0:
			return 'Answer should be returned instantly';
		case 1:
			return 'Won\'t take more than a few seconds';
		case 2:
			return 'May take as much as a minute';
		case 3:
			return 'You should have time to get a coffee';
		default:
			return 'Will take many hours or run out of memory';
	}
};
var _user$project$Main$speedColour = function (time) {
	var _p4 = time;
	switch (_p4) {
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
var _user$project$Main$speedIndicator = function (time) {
	var _p5 = time;
	switch (_p5) {
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
var _user$project$Main$viewIcon = function (time) {
	var description = _user$project$Main$speedDescription(time);
	var symbol = _user$project$Main$speedIndicator(time);
	var colour = _user$project$Main$speedColour(time);
	var klass = A2(_elm_lang$core$Basics_ops['++'], 'btn btn-xs btn-', colour);
	return A2(
		_elm_lang$html$Html$tr,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('col-xs-1 text-center'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class(klass),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(symbol),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('col-xs-11'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(description),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Main$viewHeader = A2(
	_elm_lang$html$Html$tr,
	{ctor: '[]'},
	{
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$td,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('col-xs-2 text-center'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text('Part'),
				_1: {ctor: '[]'}
			}),
		_1: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$td,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('col-xs-10 text-center'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Answer'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		}
	});
var _user$project$Main$viewDayOption = F3(
	function (year, chosen, day) {
		var failedSymbol = _user$project$Main$failedIndicator(
			A3(
				_elm_lang$core$List$foldl,
				F2(
					function (x, y) {
						return x || y;
					}),
				false,
				A2(
					_elm_lang$core$List$map,
					A2(_user$project$Main$failed, year, day),
					{
						ctor: '::',
						_0: 1,
						_1: {
							ctor: '::',
							_0: 2,
							_1: {ctor: '[]'}
						}
					})));
		var speedSymbol = _user$project$Main$speedIndicator(
			A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$List$maximum(
					A2(
						_elm_lang$core$List$map,
						A2(_user$project$Main$speed, year, day),
						{
							ctor: '::',
							_0: 1,
							_1: {
								ctor: '::',
								_0: 2,
								_1: {ctor: '[]'}
							}
						}))));
		var str = _elm_lang$core$Basics$toString(day);
		var pad = _elm_lang$core$Native_Utils.eq(
			_elm_lang$core$String$length(str),
			1) ? A2(_elm_lang$core$Basics_ops['++'], '0', str) : str;
		var txt = A2(
			_elm_lang$core$Basics_ops['++'],
			'Day ',
			A2(
				_elm_lang$core$Basics_ops['++'],
				pad,
				A2(
					_elm_lang$core$Basics_ops['++'],
					' ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						failedSymbol,
						A2(_elm_lang$core$Basics_ops['++'], ' ', speedSymbol)))));
		return A2(
			_elm_lang$html$Html$option,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$value(str),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$selected(
						_elm_lang$core$Native_Utils.eq(chosen, day)),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(txt),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Main$viewYearOption = F2(
	function (chosen, year) {
		var str = _elm_lang$core$Basics$toString(year);
		var txt = A2(_elm_lang$core$Basics_ops['++'], 'Year ', str);
		return A2(
			_elm_lang$html$Html$option,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$value(str),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$selected(
						_elm_lang$core$Native_Utils.eq(chosen, year)),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(txt),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Main$prepareAnswer = function (part) {
	return _user$project$Ports$prepareAnswer(part);
};
var _user$project$Main$getData = function (model) {
	return _user$project$Ports$getData(
		{ctor: '_Tuple2', _0: model.year, _1: model.day});
};
var _user$project$Main$getAnswer = F3(
	function (model, part, data) {
		var _p6 = model.year;
		switch (_p6) {
			case 2015:
				return A3(_user$project$Y15$answer, model.day, part, data);
			case 2016:
				return A3(_user$project$Y16$answer, model.day, part, data);
			default:
				return '';
		}
	});
var _user$project$Main$thinking = function (part) {
	return _elm_lang$core$Native_Utils.eq(part, 1) ? {ctor: '_Tuple2', _0: true, _1: false} : {ctor: '_Tuple2', _0: false, _1: true};
};
var _user$project$Main$initThinks = {ctor: '_Tuple2', _0: false, _1: false};
var _user$project$Main$initAnswers = {ctor: '_Tuple2', _0: _elm_lang$core$Maybe$Nothing, _1: _elm_lang$core$Maybe$Nothing};
var _user$project$Main$defaultDay = 20;
var _user$project$Main$defaultYear = 2016;
var _user$project$Main$initModel = {
	years: {
		ctor: '::',
		_0: {
			year: 2015,
			days: A2(_elm_lang$core$List$range, 1, 25)
		},
		_1: {
			ctor: '::',
			_0: {
				year: 2016,
				days: A2(_elm_lang$core$List$range, 1, 20)
			},
			_1: {ctor: '[]'}
		}
	},
	year: _user$project$Main$defaultYear,
	day: _user$project$Main$defaultDay,
	data: _elm_lang$core$Maybe$Nothing,
	answers: _user$project$Main$initAnswers,
	thinks: _user$project$Main$initThinks,
	help: false
};
var _user$project$Main$newProblem = F2(
	function (year, day) {
		var year1 = _elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$filter,
				function (y) {
					return _elm_lang$core$Native_Utils.eq(y.year, year);
				},
				_user$project$Main$initModel.years));
		var newYear = function () {
			var _p7 = year1;
			if (_p7.ctor === 'Just') {
				return _p7._0.year;
			} else {
				return _user$project$Main$defaultYear;
			}
		}();
		var year2 = _elm_lang$core$List$head(
			A2(
				_elm_lang$core$List$filter,
				function (y) {
					return _elm_lang$core$Native_Utils.eq(y.year, newYear);
				},
				_user$project$Main$initModel.years));
		var newDay = function () {
			var _p8 = year2;
			if (_p8.ctor === 'Just') {
				var _p9 = _p8._0;
				return A2(_elm_lang$core$List$member, day, _p9.days) ? day : A2(
					_elm_lang$core$Maybe$withDefault,
					_user$project$Main$defaultDay,
					_elm_lang$core$List$head(_p9.days));
			} else {
				return _user$project$Main$defaultDay;
			}
		}();
		return _elm_lang$core$Native_Utils.update(
			_user$project$Main$initModel,
			{year: newYear, day: newDay});
	});
var _user$project$Main$init = function (flags) {
	var day = A2(
		_elm_lang$core$Result$withDefault,
		_user$project$Main$defaultDay,
		_elm_lang$core$String$toInt(flags.day));
	var year = A2(
		_elm_lang$core$Result$withDefault,
		_user$project$Main$defaultYear,
		_elm_lang$core$String$toInt(flags.year));
	var model = A2(_user$project$Main$newProblem, year, day);
	return {
		ctor: '_Tuple2',
		_0: model,
		_1: _user$project$Main$getData(model)
	};
};
var _user$project$Main$update = F2(
	function (msg, model) {
		var _p10 = msg;
		switch (_p10.ctor) {
			case 'SelectYear':
				var newModel = A2(_user$project$Main$newProblem, _p10._0, model.day);
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					newModel,
					{
						ctor: '::',
						_0: _user$project$Main$getData(newModel),
						_1: {ctor: '[]'}
					});
			case 'SelectDay':
				var newModel = A2(_user$project$Main$newProblem, model.year, _p10._0);
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					newModel,
					{
						ctor: '::',
						_0: _user$project$Main$getData(newModel),
						_1: {ctor: '[]'}
					});
			case 'NewData':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							data: _elm_lang$core$Maybe$Just(_p10._0)
						}),
					{ctor: '[]'});
			case 'Prepare':
				var _p11 = _p10._0;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							thinks: _user$project$Main$thinking(_p11)
						}),
					{
						ctor: '::',
						_0: _user$project$Main$prepareAnswer(_p11),
						_1: {ctor: '[]'}
					});
			case 'Answer':
				var _p12 = _p10._0;
				var data = A2(_elm_lang$core$Maybe$withDefault, '', model.data);
				var answer = A3(_user$project$Main$getAnswer, model, _p12, data);
				var answers = _elm_lang$core$Native_Utils.eq(_p12, 1) ? {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Maybe$Just(answer),
					_1: _elm_lang$core$Tuple$second(model.answers)
				} : {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Tuple$first(model.answers),
					_1: _elm_lang$core$Maybe$Just(answer)
				};
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{answers: answers, thinks: _user$project$Main$initThinks}),
					{ctor: '[]'});
			case 'ShowHelp':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{help: true}),
					{ctor: '[]'});
			default:
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{help: false}),
					{ctor: '[]'});
		}
	});
var _user$project$Main$Year = F2(
	function (a, b) {
		return {year: a, days: b};
	});
var _user$project$Main$Model = F7(
	function (a, b, c, d, e, f, g) {
		return {years: a, year: b, day: c, data: d, answers: e, thinks: f, help: g};
	});
var _user$project$Main$Flags = F2(
	function (a, b) {
		return {year: a, day: b};
	});
var _user$project$Main$HideHelp = {ctor: 'HideHelp'};
var _user$project$Main$ShowHelp = {ctor: 'ShowHelp'};
var _user$project$Main$viewHelp = function (show) {
	var btnText = function (txt) {
		return _elm_lang$html$Html$text(
			A2(_elm_lang$core$Basics_ops['++'], txt, ' Button Decriptions'));
	};
	if (show) {
		var help = ' Icon Descriptions';
		var trows = A2(
			_elm_lang$core$List$map,
			_user$project$Main$viewIcon,
			{
				ctor: '::',
				_0: 0,
				_1: {
					ctor: '::',
					_0: 1,
					_1: {
						ctor: '::',
						_0: 2,
						_1: {
							ctor: '::',
							_0: 3,
							_1: {
								ctor: '::',
								_0: 4,
								_1: {ctor: '[]'}
							}
						}
					}
				}
			});
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('row'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('col-xs-offset-1 col-xs-10 col-sm-offset-2 col-sm-8 col-md-offset-3 col-md-6 col-lg-offset-4 col-lg-4'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$p,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('text-center'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$button,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$type_('button'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('btn btn-xs btn-default'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Events$onClick(_user$project$Main$HideHelp),
												_1: {ctor: '[]'}
											}
										}
									},
									{
										ctor: '::',
										_0: btnText('Hide'),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$table,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('table table-bordered'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$tbody,
										{ctor: '[]'},
										trows),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			});
	} else {
		return A2(
			_elm_lang$html$Html$p,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('text-center'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$button,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$type_('button'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('btn btn-xs btn-default'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(_user$project$Main$ShowHelp),
								_1: {ctor: '[]'}
							}
						}
					},
					{
						ctor: '::',
						_0: btnText('Show'),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	}
};
var _user$project$Main$Prepare = function (a) {
	return {ctor: 'Prepare', _0: a};
};
var _user$project$Main$viewAnswer = F2(
	function (model, part) {
		var noSolution = A3(_user$project$Main$failed, model.year, model.day, part);
		var thinking = _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Tuple$first(model.thinks) : _elm_lang$core$Tuple$second(model.thinks);
		var answer = _elm_lang$core$Native_Utils.eq(part, 1) ? _elm_lang$core$Tuple$first(model.answers) : _elm_lang$core$Tuple$second(model.answers);
		var display = function () {
			if (noSolution) {
				var data = A2(_elm_lang$core$Maybe$withDefault, '', model.data);
				return _elm_lang$html$Html$text(
					A3(_user$project$Main$getAnswer, model, part, data));
			} else {
				if (thinking) {
					return A2(
						_elm_lang$html$Html$img,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$src('/images/loader.gif'),
							_1: {ctor: '[]'}
						},
						{ctor: '[]'});
				} else {
					var _p13 = answer;
					if (_p13.ctor === 'Nothing') {
						var time = A3(_user$project$Main$speed, model.year, model.day, part);
						var colour = _user$project$Main$speedColour(time);
						var symbol = _user$project$Main$speedIndicator(time);
						return A2(
							_elm_lang$html$Html$span,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class(
									A2(
										_elm_lang$core$Basics_ops['++'],
										'btn btn-',
										A2(_elm_lang$core$Basics_ops['++'], colour, ' btn-xs'))),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onClick(
										_user$project$Main$Prepare(part)),
									_1: {ctor: '[]'}
								}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(symbol),
								_1: {ctor: '[]'}
							});
					} else {
						var _p14 = _p13._0;
						return (_elm_lang$core$Native_Utils.cmp(
							_elm_lang$core$String$length(_p14),
							32) > 0) ? A2(
							_elm_lang$html$Html$pre,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(_p14),
								_1: {ctor: '[]'}
							}) : _elm_lang$html$Html$text(_p14);
					}
				}
			}
		}();
		return A2(
			_elm_lang$html$Html$tr,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$td,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('col-xs-2 text-center'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(
							_elm_lang$core$Basics$toString(part)),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$td,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('col-xs-10 text-center'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: display,
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Main$Answer = function (a) {
	return {ctor: 'Answer', _0: a};
};
var _user$project$Main$NewData = function (a) {
	return {ctor: 'NewData', _0: a};
};
var _user$project$Main$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$batch(
		{
			ctor: '::',
			_0: _user$project$Ports$newData(_user$project$Main$NewData),
			_1: {
				ctor: '::',
				_0: _user$project$Ports$startAnswer(_user$project$Main$Answer),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Main$SelectDay = function (a) {
	return {ctor: 'SelectDay', _0: a};
};
var _user$project$Main$SelectYear = function (a) {
	return {ctor: 'SelectYear', _0: a};
};
var _user$project$Main$view = function (model) {
	var data = A2(_elm_lang$core$Maybe$withDefault, '', model.data);
	var onDayChange = _elm_lang$html$Html_Events$onInput(
		function (_p15) {
			return _user$project$Main$SelectDay(
				_user$project$Main$toInt(_p15));
		});
	var onYearChange = _elm_lang$html$Html_Events$onInput(
		function (_p16) {
			return _user$project$Main$SelectYear(
				_user$project$Main$toInt(_p16));
		});
	var dayOptions = A2(
		_elm_lang$core$List$map,
		A2(_user$project$Main$viewDayOption, model.year, model.day),
		A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '[]'},
			_elm_lang$core$List$head(
				A2(
					_elm_lang$core$List$map,
					function (_) {
						return _.days;
					},
					A2(
						_elm_lang$core$List$filter,
						function (y) {
							return _elm_lang$core$Native_Utils.eq(y.year, model.year);
						},
						model.years)))));
	var yearOptions = A2(
		_elm_lang$core$List$map,
		_user$project$Main$viewYearOption(model.year),
		A2(
			_elm_lang$core$List$map,
			function (_) {
				return _.year;
			},
			model.years));
	return A2(
		_elm_lang$html$Html$div,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('row'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('col-xs-12'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$form,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('form-horizontal'),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$html$Html_Attributes$attribute, 'role', 'form'),
										_1: {ctor: '[]'}
									}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$div,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('form-group'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$div,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('col-xs-1 col-sm-2 col-md-3'),
													_1: {ctor: '[]'}
												},
												{ctor: '[]'}),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$div,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('col-xs-4 col-sm-3 col-md-2'),
														_1: {ctor: '[]'}
													},
													{
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$select,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('form-control input-sm'),
																_1: {
																	ctor: '::',
																	_0: A2(_elm_lang$html$Html_Attributes$attribute, 'size', '1'),
																	_1: {
																		ctor: '::',
																		_0: onYearChange,
																		_1: {ctor: '[]'}
																	}
																}
															},
															yearOptions),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$div,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('col-xs-2 col-sm-2 col-md-2'),
															_1: {ctor: '[]'}
														},
														{ctor: '[]'}),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$div,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('col-xs-4 col-sm-3 col-md-2'),
																_1: {ctor: '[]'}
															},
															{
																ctor: '::',
																_0: A2(
																	_elm_lang$html$Html$select,
																	{
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$class('form-control input-sm'),
																		_1: {
																			ctor: '::',
																			_0: A2(_elm_lang$html$Html_Attributes$attribute, 'size', '1'),
																			_1: {
																				ctor: '::',
																				_0: onDayChange,
																				_1: {ctor: '[]'}
																			}
																		}
																	},
																	dayOptions),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}
												}
											}
										}),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$hr,
					{ctor: '[]'},
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('row'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-2 col-md-8 col-lg-offset-3 col-lg-6'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$table,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('table table-bordered'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$tbody,
												{ctor: '[]'},
												{
													ctor: '::',
													_0: _user$project$Main$viewHeader,
													_1: {
														ctor: '::',
														_0: A2(_user$project$Main$viewAnswer, model, 1),
														_1: {
															ctor: '::',
															_0: A2(_user$project$Main$viewAnswer, model, 2),
															_1: {ctor: '[]'}
														}
													}
												}),
											_1: {ctor: '[]'}
										}),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('row'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$div,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-2 col-md-8 col-lg-offset-3 col-lg-6'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$table,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('table table-bordered'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$tbody,
													{ctor: '[]'},
													{
														ctor: '::',
														_0: _user$project$Main$viewLinks(model),
														_1: {
															ctor: '::',
															_0: _user$project$Main$viewNote(model),
															_1: {ctor: '[]'}
														}
													}),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$hr,
								{ctor: '[]'},
								{ctor: '[]'}),
							_1: {
								ctor: '::',
								_0: _user$project$Main$viewHelp(model.help),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$hr,
										{ctor: '[]'},
										{ctor: '[]'}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$div,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('row'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$div,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('col-xs-12'),
														_1: {ctor: '[]'}
													},
													{
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$pre,
															{ctor: '[]'},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text(data),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}
				}
			}
		});
};
var _user$project$Main$main = _elm_lang$html$Html$programWithFlags(
	{init: _user$project$Main$init, update: _user$project$Main$update, view: _user$project$Main$view, subscriptions: _user$project$Main$subscriptions})(
	A2(
		_elm_lang$core$Json_Decode$andThen,
		function (day) {
			return A2(
				_elm_lang$core$Json_Decode$andThen,
				function (year) {
					return _elm_lang$core$Json_Decode$succeed(
						{day: day, year: year});
				},
				A2(_elm_lang$core$Json_Decode$field, 'year', _elm_lang$core$Json_Decode$string));
		},
		A2(_elm_lang$core$Json_Decode$field, 'day', _elm_lang$core$Json_Decode$string)));

var Elm = {};
Elm['Main'] = Elm['Main'] || {};
if (typeof _user$project$Main$main !== 'undefined') {
    _user$project$Main$main(Elm['Main'], 'Main', undefined);
}

if (typeof define === "function" && define['amd'])
{
  define([], function() { return Elm; });
  return;
}

if (typeof module === "object")
{
  module['exports'] = Elm;
  return;
}

var globalElm = this['Elm'];
if (typeof globalElm === "undefined")
{
  this['Elm'] = Elm;
  return;
}

for (var publicModule in Elm)
{
  if (publicModule in globalElm)
  {
    throw new Error('There are two Elm modules called `' + publicModule + '` on this page! Rename one of them.');
  }
  globalElm[publicModule] = Elm[publicModule];
}

}).call(this);

