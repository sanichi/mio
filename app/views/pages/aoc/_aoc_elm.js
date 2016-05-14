
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

function eq(rootX, rootY)
{
	var stack = [{ x: rootX, y: rootY }];
	while (stack.length > 0)
	{
		var front = stack.pop();
		var x = front.x;
		var y = front.y;
		if (x === y)
		{
			continue;
		}
		if (typeof x === 'object')
		{
			var c = 0;
			for (var key in x)
			{
				++c;
				if (!(key in y))
				{
					return false;
				}
				if (key === 'ctor')
				{
					continue;
				}
				stack.push({ x: x[key], y: y[key] });
			}
			if ('ctor' in x)
			{
				stack.push({ x: x.ctor, y: y.ctor});
			}
			if (c !== Object.keys(y).length)
			{
				return false;
			}
		}
		else if (typeof x === 'function')
		{
			throw new Error('Equality error: general function equality is ' +
							'undecidable, and therefore, unsupported');
		}
		else
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
	var ord;
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}
	else if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b
			? EQ
			: a < b
				? LT
				: GT;
	}
	else if (x.ctor === '::' || x.ctor === '[]')
	{
		while (true)
		{
			if (x.ctor === '[]' && y.ctor === '[]')
			{
				return EQ;
			}
			if (x.ctor !== y.ctor)
			{
				return x.ctor === '[]' ? LT : GT;
			}
			ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
	}
	else if (x.ctor.slice(0, 6) === '_Tuple')
	{
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
	else
	{
		throw new Error('Comparison error: comparison is only defined on ints, ' +
						'floats, times, chars, strings, lists of comparable values, ' +
						'and tuples of comparable values.');
	}
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
		var value = (key in updatedFields) ? updatedFields[key] : oldRecord[key];
		newRecord[key] = value;
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

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin' || v.ctor === 'Set_elm_builtin')
		{
			var name, list;
			if (v.ctor === 'Set_elm_builtin')
			{
				name = 'Set';
				list = A2(
					_elm_lang$core$List$map,
					function(x) {return x._0; },
					_elm_lang$core$Dict$toList(v._0)
				);
			}
			else
			{
				name = 'Dict';
				list = _elm_lang$core$Dict$toList(v);
			}
			return name + '.fromList ' + toString(list);
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
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p0) {
		var _p1 = _p0;
		return A2(f, _p1._0, _p1._1);
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
var _elm_lang$core$Basics$snd = function (_p2) {
	var _p3 = _p2;
	return _p3._1;
};
var _elm_lang$core$Basics$fst = function (_p4) {
	var _p5 = _p4;
	return _p5._0;
};
var _elm_lang$core$Basics$always = F2(
	function (a, _p6) {
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
var _elm_lang$core$Basics$Never = function (a) {
	return {ctor: 'Never', _0: a};
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
var _elm_lang$core$Maybe$oneOf = function (maybes) {
	oneOf:
	while (true) {
		var _p1 = maybes;
		if (_p1.ctor === '[]') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			var _p3 = _p1._0;
			var _p2 = _p3;
			if (_p2.ctor === 'Nothing') {
				var _v3 = _p1._1;
				maybes = _v3;
				continue oneOf;
			} else {
				return _p3;
			}
		}
	}
};
var _elm_lang$core$Maybe$andThen = F2(
	function (maybeValue, callback) {
		var _p4 = maybeValue;
		if (_p4.ctor === 'Just') {
			return callback(_p4._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p5 = maybe;
		if (_p5.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p5._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p6 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p6.ctor === '_Tuple2') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p6._0._0, _p6._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p7 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p7.ctor === '_Tuple3') && (_p7._0.ctor === 'Just')) && (_p7._1.ctor === 'Just')) && (_p7._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p7._0._0, _p7._1._0, _p7._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p8 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p8.ctor === '_Tuple4') && (_p8._0.ctor === 'Just')) && (_p8._1.ctor === 'Just')) && (_p8._2.ctor === 'Just')) && (_p8._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p8._0._0, _p8._1._0, _p8._2._0, _p8._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p9 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p9.ctor === '_Tuple5') && (_p9._0.ctor === 'Just')) && (_p9._1.ctor === 'Just')) && (_p9._2.ctor === 'Just')) && (_p9._3.ctor === 'Just')) && (_p9._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p9._0._0, _p9._1._0, _p9._2._0, _p9._3._0, _p9._4._0));
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


function range(lo, hi)
{
	var list = Nil;
	if (lo <= hi)
	{
		do
		{
			list = Cons(hi, list);
		}
		while (hi-- > lo);
	}
	return list;
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
	range: range,

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
		return _elm_lang$core$Basics$not(
			A2(
				_elm_lang$core$List$any,
				function (_p2) {
					return _elm_lang$core$Basics$not(
						isOkay(_p2));
				},
				list));
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
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			_elm_lang$core$Native_List.range(
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});
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
					return A2(
						_elm_lang$core$List_ops['::'],
						f(x),
						acc);
				}),
			_elm_lang$core$Native_List.fromArray(
				[]),
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (x, xs$) {
				return pred(x) ? A2(_elm_lang$core$List_ops['::'], x, xs$) : xs$;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			_elm_lang$core$Native_List.fromArray(
				[]),
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return A2(_elm_lang$core$List_ops['::'], _p10._0, xs);
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			_elm_lang$core$Native_List.fromArray(
				[]),
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return A2(_elm_lang$core$List_ops['::'], x, y);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return A2(
						_elm_lang$core$List_ops['::'],
						A2(f, x, _p11._0),
						accAcc);
				} else {
					return _elm_lang$core$Native_List.fromArray(
						[]);
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				_elm_lang$core$Native_List.fromArray(
					[b]),
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
						return A2(_elm_lang$core$List_ops['::'], x, y);
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		_elm_lang$core$Native_List.fromArray(
			[]),
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
					_0: A2(_elm_lang$core$List_ops['::'], x, _p16),
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: A2(_elm_lang$core$List_ops['::'], x, _p15)
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_List.fromArray(
					[]),
				_1: _elm_lang$core$Native_List.fromArray(
					[])
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
				_0: A2(_elm_lang$core$List_ops['::'], _p19._0, _p20._0),
				_1: A2(_elm_lang$core$List_ops['::'], _p19._1, _p20._1)
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_List.fromArray(
				[]),
			_1: _elm_lang$core$Native_List.fromArray(
				[])
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return _elm_lang$core$Native_List.fromArray(
				[]);
		} else {
			var step = F2(
				function (x, rest) {
					return A2(
						_elm_lang$core$List_ops['::'],
						sep,
						A2(_elm_lang$core$List_ops['::'], x, rest));
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				_elm_lang$core$Native_List.fromArray(
					[]),
				_p21._1);
			return A2(_elm_lang$core$List_ops['::'], _p21._0, spersed);
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return _elm_lang$core$Native_List.fromArray(
				[]);
		} else {
			var _p22 = list;
			if (_p22.ctor === '[]') {
				return list;
			} else {
				return A2(
					_elm_lang$core$List_ops['::'],
					_p22._0,
					A2(_elm_lang$core$List$take, n - 1, _p22._1));
			}
		}
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v23 = A2(_elm_lang$core$List_ops['::'], value, result),
					_v24 = n - 1,
					_v25 = value;
				result = _v23;
				n = _v24;
				value = _v25;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			_elm_lang$core$Native_List.fromArray(
				[]),
			n,
			value);
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
		_elm_lang$core$Native_List.range(
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
	shiftLeft: F2(function sll(a, offset) { return a << offset; }),
	shiftRightArithmatic: F2(function sra(a, offset) { return a >> offset; }),
	shiftRightLogical: F2(function srl(a, offset) { return a >>> offset; })
};

}();

var _elm_lang$core$Bitwise$shiftRightLogical = _elm_lang$core$Native_Bitwise.shiftRightLogical;
var _elm_lang$core$Bitwise$shiftRight = _elm_lang$core$Native_Bitwise.shiftRightArithmatic;
var _elm_lang$core$Bitwise$shiftLeft = _elm_lang$core$Native_Bitwise.shiftLeft;
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

function andThen(task, callback)
{
	return {
		ctor: '_Task_andThen',
		task: task,
		callback: callback
	};
}

function onError(task, callback)
{
	return {
		ctor: '_Task_onError',
		task: task,
		callback: callback
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
		numSteps = step(numSteps, process);
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

function addPublicModule(object, name, main)
{
	var init = main ? makeEmbed(name, main) : mainIsUndefined(name);

	object['worker'] = function worker(flags)
	{
		return init(undefined, flags, false);
	}

	object['embed'] = function embed(domNode, flags)
	{
		return init(domNode, flags, true);
	}

	object['fullscreen'] = function fullscreen(flags)
	{
		return init(document.body, flags, true);
	};
}


// PROGRAM FAIL

function mainIsUndefined(name)
{
	return function(domNode)
	{
		var message = 'Cannot initialize module `' + name +
			'` because it has no `main` value!\nWhat should I show on screen?';
		domNode.innerHTML = errorHtml(message);
		throw new Error(message);
	};
}

function errorHtml(message)
{
	return '<div style="padding-left:1em;">'
		+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
		+ '<pre style="padding-left:1em;">' + message + '</pre>'
		+ '</div>';
}


// PROGRAM SUCCESS

function makeEmbed(moduleName, main)
{
	return function embed(rootDomNode, flags, withRenderer)
	{
		try
		{
			var program = mainToProgram(moduleName, main);
			if (!withRenderer)
			{
				program.renderer = dummyRenderer;
			}
			return makeEmbedHelp(moduleName, program, rootDomNode, flags);
		}
		catch (e)
		{
			rootDomNode.innerHTML = errorHtml(e.message);
			throw e;
		}
	};
}

function dummyRenderer()
{
	return { update: function() {} };
}


// MAIN TO PROGRAM

function mainToProgram(moduleName, wrappedMain)
{
	var main = wrappedMain.main;

	if (typeof main.init === 'undefined')
	{
		var emptyBag = batch(_elm_lang$core$Native_List.Nil);
		var noChange = _elm_lang$core$Native_Utils.Tuple2(
			_elm_lang$core$Native_Utils.Tuple0,
			emptyBag
		);

		return _elm_lang$virtual_dom$VirtualDom$programWithFlags({
			init: function() { return noChange; },
			view: function() { return main; },
			update: F2(function() { return noChange; }),
			subscriptions: function () { return emptyBag; }
		});
	}

	var flags = wrappedMain.flags;
	var init = flags
		? initWithFlags(moduleName, main.init, flags)
		: initWithoutFlags(moduleName, main.init);

	return _elm_lang$virtual_dom$VirtualDom$programWithFlags({
		init: init,
		view: main.view,
		update: main.update,
		subscriptions: main.subscriptions,
	});
}

function initWithoutFlags(moduleName, realInit)
{
	return function init(flags)
	{
		if (typeof flags !== 'undefined')
		{
			throw new Error(
				'You are giving module `' + moduleName + '` an argument in JavaScript.\n'
				+ 'This module does not take arguments though! You probably need to change the\n'
				+ 'initialization code to something like `Elm.' + moduleName + '.fullscreen()`'
			);
		}
		return realInit();
	};
}

function initWithFlags(moduleName, realInit, flagDecoder)
{
	return function init(flags)
	{
		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Err')
		{
			throw new Error(
				'You are trying to initialize module `' + moduleName + '` with an unexpected argument.\n'
				+ 'When trying to convert it to a usable Elm value, I run into this problem:\n\n'
				+ result._0
			);
		}
		return realInit(result._0);
	};
}


// SETUP RUNTIME SYSTEM

function makeEmbedHelp(moduleName, program, rootDomNode, flags)
{
	var init = program.init;
	var update = program.update;
	var subscriptions = program.subscriptions;
	var view = program.view;
	var makeRenderer = program.renderer;

	// ambient state
	var managers = {};
	var renderer;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var results = init(flags);
		var model = results._0;
		renderer = makeRenderer(rootDomNode, enqueue, view(model));
		var cmds = results._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			renderer.update(view(model));
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
		return A2(andThen, handleMsg, loop);
	}

	var task = A2(andThen, init, loop);

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
		while (taggers)
		{
			x = taggers.tagger(x);
			taggers = taggers.rest;
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
			var value = converter(cmdList._0);
			for (var i = 0; i < subs.length; i++)
			{
				subs[i](value);
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
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function send(value)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, value);
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

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	mainToProgram: mainToProgram,
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,
	addPublicModule: addPublicModule,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
};

}();
var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	_elm_lang$core$Native_List.fromArray(
		[]));
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
	function (result, callback) {
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
var _elm_lang$core$Result$formatError = F2(
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
				return A2(_elm_lang$core$List_ops['::'], key, keyList);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2(_elm_lang$core$List_ops['::'], value, valueList);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					_elm_lang$core$List_ops['::'],
					{ctor: '_Tuple2', _0: key, _1: value},
					list);
			}),
		_elm_lang$core$Native_List.fromArray(
			[]),
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
					return (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) ? {
						ctor: '_Tuple2',
						_0: _p7,
						_1: A3(leftStep, _p5, _p6, _p9)
					} : ((_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) ? {
						ctor: '_Tuple2',
						_0: _p8,
						_1: A3(rightStep, rKey, rValue, _p9)
					} : {
						ctor: '_Tuple2',
						_0: _p7,
						_1: A4(bothStep, _p5, _p6, rValue, _p9)
					});
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
				_elm_lang$core$Native_List.fromArray(
					[
						'Internal red-black tree invariant violated, expected ',
						msg,
						' and got ',
						_elm_lang$core$Basics$toString(c),
						'/',
						lgot,
						'/',
						rgot,
						'\nPlease report this bug to <https://github.com/elm-lang/core/issues>'
					])));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v11_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v11_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v11_2;
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
				var _v13 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v14 = _p14._3;
				n = _v13;
				dict = _v14;
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
						var _v17 = targetKey,
							_v18 = _p15._3;
						targetKey = _v17;
						dict = _v18;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v19 = targetKey,
							_v20 = _p15._4;
						targetKey = _v19;
						dict = _v20;
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
				var _v23 = _p18._1,
					_v24 = _p18._2,
					_v25 = _p18._4;
				k = _v23;
				v = _v24;
				r = _v25;
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
	_v33_6:
	do {
		_v33_5:
		do {
			_v33_4:
			do {
				_v33_3:
				do {
					_v33_2:
					do {
						_v33_1:
						do {
							_v33_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v33_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v33_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v33_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v33_3;
																		} else {
																			break _v33_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v33_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v33_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v33_4;
																	} else {
																		break _v33_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v33_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v33_1;
																} else {
																	break _v33_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v33_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v33_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v33_5;
																	} else {
																		break _v33_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v33_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v33_5;
																	} else {
																		break _v33_6;
																	}
																}
															} else {
																break _v33_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v33_5;
															} else {
																break _v33_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v33_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v33_3;
																} else {
																	break _v33_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v33_4;
															} else {
																break _v33_6;
															}
														default:
															break _v33_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v33_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v33_1;
														} else {
															break _v33_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v33_5;
													} else {
														break _v33_6;
													}
												default:
													break _v33_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v33_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v33_3;
														} else {
															break _v33_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v33_4;
													} else {
														break _v33_6;
													}
												default:
													break _v33_6;
											}
										} else {
											break _v33_6;
										}
									}
								} else {
									break _v33_6;
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
	function (c, l, r) {
		var _p29 = {ctor: '_Tuple2', _0: l, _1: r};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = c;
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
				var _p31 = {ctor: '_Tuple3', _0: c, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						c,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: c, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						c,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var l$ = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, c, k, v, l$, r);
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

var _elm_lang$core$Platform_Sub$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Sub$none = _elm_lang$core$Platform_Sub$batch(
	_elm_lang$core$Native_List.fromArray(
		[]));
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

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
			index: arguments[i - 1],
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
	while (n--)
	{
		if (!(result = re.exec(string))) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
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

/* Help from JS for things that are too difficult or impossible in Elm. */

var make = function make(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Help = elm.Native.Help || {};

  if (elm.Native.Help.values) return elm.Native.Help.values;

  return {
    'no_red': no_red
  };
};

Elm.Native.Help = {};
Elm.Native.Help.make = make;

var no_red = function(json) {
  return JSON.stringify(filter_red(JSON.parse(json)));
}

var filter_red = function(obj, parent, key) {
  if (typeof obj == 'object')
  {
    var red = false;
    if (!Array.isArray(obj) && parent)
    {
      Object.keys(obj).forEach(function(key) {
        if (obj[key] == 'red') red = true;
      });
      if (red) delete parent[key];
    }
    if (!red) {
      Object.keys(obj).forEach(function(key) {
        filter_red(obj[key], obj, key);
      });
    }
  }
  return parent ? undefined : obj;
}

var _user$project$Help$no_red = _user$project$Native_Help.no_red;

//
// Based on https://github.com/NoRedInk/take-home/wiki/Writing-your-first-Elm-Native-module
//

var make = function make(elm) {
  elm.Native = elm.Native || {};
  elm.Native.MD5 = elm.Native.MD5 || {};

  if (elm.Native.MD5.values) return elm.Native.MD5.values;

  return {
    'md5': md5
  };
};

Elm.Native.MD5 = {};
Elm.Native.MD5.make = make;

//
// From https://css-tricks.com/snippets/javascript/javascript-md5/.
//
var md5 = function (string) {

  function RotateLeft(lValue, iShiftBits) {
    return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
  }

  function AddUnsigned(lX,lY) {
    var lX4,lY4,lX8,lY8,lResult;
    lX8 = (lX & 0x80000000);
    lY8 = (lY & 0x80000000);
    lX4 = (lX & 0x40000000);
    lY4 = (lY & 0x40000000);
    lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
    if (lX4 & lY4) {
      return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
    }
    if (lX4 | lY4) {
      if (lResult & 0x40000000) {
             return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
      } else {
             return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
      }
    } else {
      return (lResult ^ lX8 ^ lY8);
    }
  }

  function F(x,y,z) { return (x & y) | ((~x) & z); }
  function G(x,y,z) { return (x & z) | (y & (~z)); }
  function H(x,y,z) { return (x ^ y ^ z); }
  function I(x,y,z) { return (y ^ (x | (~z))); }

  function FF(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  }

  function GG(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  }

  function HH(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  }

  function II(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  }

  function ConvertToWordArray(string) {
    var lWordCount;
    var lMessageLength = string.length;
    var lNumberOfWords_temp1=lMessageLength + 8;
    var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
    var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
    var lWordArray=Array(lNumberOfWords-1);
    var lBytePosition = 0;
    var lByteCount = 0;
    while ( lByteCount < lMessageLength ) {
      lWordCount = (lByteCount-(lByteCount % 4))/4;
      lBytePosition = (lByteCount % 4)*8;
      lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount)<<lBytePosition));
      lByteCount++;
    }
    lWordCount = (lByteCount-(lByteCount % 4))/4;
    lBytePosition = (lByteCount % 4)*8;
    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
    lWordArray[lNumberOfWords-2] = lMessageLength<<3;
    lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
    return lWordArray;
  }

  function WordToHex(lValue) {
    var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;
    for (lCount = 0;lCount<=3;lCount++) {
      lByte = (lValue>>>(lCount*8)) & 255;
      WordToHexValue_temp = "0" + lByte.toString(16);
      WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);
    }
    return WordToHexValue;
  }

  function Utf8Encode(string) {
    string = string.replace(/\r\n/g,"\n");
    var utftext = "";
    for (var n = 0; n < string.length; n++) {
      var c = string.charCodeAt(n);
      if (c < 128) {
        utftext += String.fromCharCode(c);
      }
      else if ((c > 127) && (c < 2048)) {
          utftext += String.fromCharCode((c >> 6) | 192);
          utftext += String.fromCharCode((c & 63) | 128);
        }
        else {
          utftext += String.fromCharCode((c >> 12) | 224);
          utftext += String.fromCharCode(((c >> 6) & 63) | 128);
          utftext += String.fromCharCode((c & 63) | 128);
        }
    }
    return utftext;
  }

  var x=Array();
  var k,AA,BB,CC,DD,a,b,c,d;
  var S11=7, S12=12, S13=17, S14=22;
  var S21=5, S22=9 , S23=14, S24=20;
  var S31=4, S32=11, S33=16, S34=23;
  var S41=6, S42=10, S43=15, S44=21;

  string = Utf8Encode(string);

  x = ConvertToWordArray(string);

  a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476;

  for (k=0;k<x.length;k+=16) {
    AA=a; BB=b; CC=c; DD=d;
    a=FF(a,b,c,d,x[k+0], S11,0xD76AA478);
    d=FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
    c=FF(c,d,a,b,x[k+2], S13,0x242070DB);
    b=FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
    a=FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
    d=FF(d,a,b,c,x[k+5], S12,0x4787C62A);
    c=FF(c,d,a,b,x[k+6], S13,0xA8304613);
    b=FF(b,c,d,a,x[k+7], S14,0xFD469501);
    a=FF(a,b,c,d,x[k+8], S11,0x698098D8);
    d=FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
    c=FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
    b=FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
    a=FF(a,b,c,d,x[k+12],S11,0x6B901122);
    d=FF(d,a,b,c,x[k+13],S12,0xFD987193);
    c=FF(c,d,a,b,x[k+14],S13,0xA679438E);
    b=FF(b,c,d,a,x[k+15],S14,0x49B40821);
    a=GG(a,b,c,d,x[k+1], S21,0xF61E2562);
    d=GG(d,a,b,c,x[k+6], S22,0xC040B340);
    c=GG(c,d,a,b,x[k+11],S23,0x265E5A51);
    b=GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
    a=GG(a,b,c,d,x[k+5], S21,0xD62F105D);
    d=GG(d,a,b,c,x[k+10],S22,0x2441453);
    c=GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
    b=GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
    a=GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
    d=GG(d,a,b,c,x[k+14],S22,0xC33707D6);
    c=GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
    b=GG(b,c,d,a,x[k+8], S24,0x455A14ED);
    a=GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
    d=GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
    c=GG(c,d,a,b,x[k+7], S23,0x676F02D9);
    b=GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
    a=HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
    d=HH(d,a,b,c,x[k+8], S32,0x8771F681);
    c=HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
    b=HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
    a=HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
    d=HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
    c=HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
    b=HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
    a=HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
    d=HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
    c=HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
    b=HH(b,c,d,a,x[k+6], S34,0x4881D05);
    a=HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
    d=HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
    c=HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
    b=HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
    a=II(a,b,c,d,x[k+0], S41,0xF4292244);
    d=II(d,a,b,c,x[k+7], S42,0x432AFF97);
    c=II(c,d,a,b,x[k+14],S43,0xAB9423A7);
    b=II(b,c,d,a,x[k+5], S44,0xFC93A039);
    a=II(a,b,c,d,x[k+12],S41,0x655B59C3);
    d=II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
    c=II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
    b=II(b,c,d,a,x[k+1], S44,0x85845DD1);
    a=II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
    d=II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
    c=II(c,d,a,b,x[k+6], S43,0xA3014314);
    b=II(b,c,d,a,x[k+13],S44,0x4E0811A1);
    a=II(a,b,c,d,x[k+4], S41,0xF7537E82);
    d=II(d,a,b,c,x[k+11],S42,0xBD3AF235);
    c=II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
    b=II(b,c,d,a,x[k+9], S44,0xEB86D391);
    a=AddUnsigned(a,AA);
    b=AddUnsigned(b,BB);
    c=AddUnsigned(c,CC);
    d=AddUnsigned(d,DD);
  }

  var temp = WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);

  return temp.toLowerCase();
}

var _user$project$MD5$md5 = _user$project$Native_MD5.md5;

var _user$project$Util$select = function (xs) {
	var _p0 = xs;
	if (_p0.ctor === '[]') {
		return _elm_lang$core$Native_List.fromArray(
			[]);
	} else {
		var _p4 = _p0._1;
		var _p3 = _p0._0;
		return A2(
			_elm_lang$core$List_ops['::'],
			{ctor: '_Tuple2', _0: _p3, _1: _p4},
			A2(
				_elm_lang$core$List$map,
				function (_p1) {
					var _p2 = _p1;
					return {
						ctor: '_Tuple2',
						_0: _p2._0,
						_1: A2(_elm_lang$core$List_ops['::'], _p3, _p2._1)
					};
				},
				_user$project$Util$select(_p4)));
	}
};
var _user$project$Util$permutations = function (xs$) {
	var _p5 = xs$;
	if (_p5.ctor === '[]') {
		return _elm_lang$core$Native_List.fromArray(
			[
				_elm_lang$core$Native_List.fromArray(
				[])
			]);
	} else {
		var f = function (_p6) {
			var _p7 = _p6;
			return A2(
				_elm_lang$core$List$map,
				F2(
					function (x, y) {
						return A2(_elm_lang$core$List_ops['::'], x, y);
					})(_p7._0),
				_user$project$Util$permutations(_p7._1));
		};
		return A2(
			_elm_lang$core$List$concatMap,
			f,
			_user$project$Util$select(_p5));
	}
};
var _user$project$Util$combinations = F2(
	function (n, list) {
		return ((_elm_lang$core$Native_Utils.cmp(n, 0) < 0) || (_elm_lang$core$Native_Utils.cmp(
			n,
			_elm_lang$core$List$length(list)) > 0)) ? _elm_lang$core$Native_List.fromArray(
			[]) : A2(_user$project$Util$combo, n, list);
	});
var _user$project$Util$combo = F2(
	function (n, list) {
		if (_elm_lang$core$Native_Utils.eq(n, 0)) {
			return _elm_lang$core$Native_List.fromArray(
				[
					_elm_lang$core$Native_List.fromArray(
					[])
				]);
		} else {
			if (_elm_lang$core$Native_Utils.eq(
				n,
				_elm_lang$core$List$length(list))) {
				return _elm_lang$core$Native_List.fromArray(
					[list]);
			} else {
				var _p8 = list;
				if (_p8.ctor === '[]') {
					return _elm_lang$core$Native_List.fromArray(
						[]);
				} else {
					var _p9 = _p8._1;
					var c2 = A2(_user$project$Util$combinations, n, _p9);
					var c1 = A2(
						_elm_lang$core$List$map,
						F2(
							function (x, y) {
								return A2(_elm_lang$core$List_ops['::'], x, y);
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
var _user$project$Y15D01$answers = function (input) {
	var p2 = _elm_lang$core$Basics$toString(
		A3(_user$project$Y15D01$position, 0, 0, input));
	var p1 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D01$count, 0, input));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D02$ribbon = F3(
	function (l, w, h) {
		var volume = (l * w) * h;
		var perimeters = _elm_lang$core$Native_List.fromArray(
			[l + w, w + h, h + l]);
		var perimeter = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$minimum(perimeters));
		return (2 * perimeter) + volume;
	});
var _user$project$Y15D02$wrapping = F3(
	function (l, w, h) {
		var sides = _elm_lang$core$Native_List.fromArray(
			[l * w, w * h, h * l]);
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
var _user$project$Y15D02$answers = function (input) {
	var p2 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D02$sumInput, _user$project$Y15D02$ribbon, input));
	var p1 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D02$sumInput, _user$project$Y15D02$wrapping, input));
	return A2(_user$project$Util$join, p1, p2);
};

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
				var santa$ = A2(_user$project$Y15D03$updateSanta, $char, santa);
				if (santa$.stop) {
					return _elm_lang$core$Native_Utils.update(
						model,
						{err: santa.err});
				} else {
					var model$ = _elm_lang$core$Native_Utils.update(
						model,
						{
							visited: A3(_user$project$Y15D03$visit, santa$.x, santa$.y, model.visited),
							turn: model.turn + 1,
							santas: A3(_elm_lang$core$Array$set, index, santa$, model.santas)
						});
					var _v2 = model$,
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
var _user$project$Y15D03$answers = function (input) {
	var p2 = A2(_user$project$Y15D03$christmas, 2, input);
	var p1 = A2(_user$project$Y15D03$christmas, 1, input);
	return A2(_user$project$Util$join, p1, p2);
};
var _user$project$Y15D03$Santa = F4(
	function (a, b, c, d) {
		return {stop: a, x: b, y: c, err: d};
	});
var _user$project$Y15D03$Model = F4(
	function (a, b, c, d) {
		return {visited: a, santas: b, turn: c, err: d};
	});

var _user$project$Y15D04$recurse = F3(
	function (step, start, key) {
		recurse:
		while (true) {
			var hash = _user$project$MD5$md5(
				A2(
					_elm_lang$core$Basics_ops['++'],
					key,
					_elm_lang$core$Basics$toString(step)));
			if (A2(_elm_lang$core$String$startsWith, start, hash)) {
				return _elm_lang$core$Basics$toString(step);
			} else {
				var _v0 = step + 1,
					_v1 = start,
					_v2 = key;
				step = _v0;
				start = _v1;
				key = _v2;
				continue recurse;
			}
		}
	});
var _user$project$Y15D04$find = F2(
	function (start, key) {
		return A3(_user$project$Y15D04$recurse, 1, start, key);
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
var _user$project$Y15D04$answers = function (input) {
	var key = _user$project$Y15D04$parse(input);
	var p1 = A2(_user$project$Y15D04$find, '00000', key);
	var p2 = A2(_user$project$Y15D04$find, '000000', key);
	return A2(_user$project$Util$join, p1, p2);
};

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
var _user$project$Y15D05$answers = function (input) {
	var strings = A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.match;
		},
		A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, _user$project$Y15D05$stringRgx, input));
	var p1 = A2(_user$project$Y15D05$countNice, _user$project$Y15D05$nice1, strings);
	var p2 = A2(_user$project$Y15D05$countNice, _user$project$Y15D05$nice2, strings);
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D06$initModel = {
	ctor: '_Tuple2',
	_0: A2(_elm_lang$core$Array$repeat, 1000000, 0),
	_1: A2(_elm_lang$core$Array$repeat, 1000000, 0)
};
var _user$project$Y15D06$index = function (instruction) {
	var y = _elm_lang$core$Basics$snd(instruction.from);
	var x = _elm_lang$core$Basics$fst(instruction.from);
	return x + (1000 * y);
};
var _user$project$Y15D06$updateCell = F2(
	function (instruction, lights) {
		var l2 = _elm_lang$core$Basics$snd(lights);
		var l1 = _elm_lang$core$Basics$fst(lights);
		var k = _user$project$Y15D06$index(instruction);
		var v1 = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(_elm_lang$core$Array$get, k, l1));
		var v1$ = function () {
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
		var v2$ = function () {
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
			_0: A3(_elm_lang$core$Array$set, k, v1$, l1),
			_1: A3(_elm_lang$core$Array$set, k, v2$, l2)
		};
	});
var _user$project$Y15D06$updateCol = F2(
	function (instruction, lights) {
		updateCol:
		while (true) {
			var ty = _elm_lang$core$Basics$snd(instruction.to);
			var fy = _elm_lang$core$Basics$snd(instruction.from);
			var lights$ = A2(_user$project$Y15D06$updateCell, instruction, lights);
			if (_elm_lang$core$Native_Utils.eq(fy, ty)) {
				return lights$;
			} else {
				var tx = _elm_lang$core$Basics$fst(instruction.to);
				var fx = _elm_lang$core$Basics$fst(instruction.from);
				var instruction$ = _elm_lang$core$Native_Utils.update(
					instruction,
					{
						from: {ctor: '_Tuple2', _0: fx, _1: fy + 1},
						to: {ctor: '_Tuple2', _0: tx, _1: ty}
					});
				var _v2 = instruction$,
					_v3 = lights$;
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
			var tx = _elm_lang$core$Basics$fst(instruction.to);
			var fx = _elm_lang$core$Basics$fst(instruction.from);
			var lights$ = A2(_user$project$Y15D06$updateCol, instruction, lights);
			if (_elm_lang$core$Native_Utils.eq(fx, tx)) {
				return lights$;
			} else {
				var ty = _elm_lang$core$Basics$snd(instruction.to);
				var fy = _elm_lang$core$Basics$snd(instruction.from);
				var instruction$ = _elm_lang$core$Native_Utils.update(
					instruction,
					{
						from: {ctor: '_Tuple2', _0: fx + 1, _1: fy},
						to: {ctor: '_Tuple2', _0: tx, _1: ty}
					});
				var _v4 = instruction$,
					_v5 = lights$;
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
				var lights$ = A2(_user$project$Y15D06$updateRow, _p2._0, lights);
				var _v7 = _p2._1,
					_v8 = lights$;
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
		var ty$ = _elm_lang$core$String$toInt(_p3._1._1._1._1._0._0);
		var tx$ = _elm_lang$core$String$toInt(_p3._1._1._1._0._0);
		var fy$ = _elm_lang$core$String$toInt(_p3._1._1._0._0);
		var fx$ = _elm_lang$core$String$toInt(_p3._1._0._0);
		var a$ = function () {
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
		var _p5 = {ctor: '_Tuple5', _0: a$, _1: fx$, _2: fy$, _3: tx$, _4: ty$};
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
var _user$project$Y15D06$answers = function (input) {
	var instructions = _user$project$Y15D06$parse(input);
	var model = A2(_user$project$Y15D06$process, instructions, _user$project$Y15D06$initModel);
	var p1 = _elm_lang$core$Basics$toString(
		_elm_lang$core$List$length(
			A2(
				_elm_lang$core$List$filter,
				function (l) {
					return _elm_lang$core$Native_Utils.eq(l, 1);
				},
				_elm_lang$core$Array$toList(
					_elm_lang$core$Basics$fst(model)))));
	var p2 = _elm_lang$core$Basics$toString(
		_elm_lang$core$List$sum(
			_elm_lang$core$Array$toList(
				_elm_lang$core$Basics$snd(model))));
	return A2(_user$project$Util$join, p1, p2);
};

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
						return {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Bitwise$and, i, j),
							_1: c,
							_2: true
						};
					case 'Or':
						var _p7 = A3(_user$project$Y15D07$reduce2, _p4._0, _p4._1, circuit);
						var i = _p7._0;
						var j = _p7._1;
						var c = _p7._2;
						return {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Bitwise$or, i, j),
							_1: c,
							_2: true
						};
					case 'Lshift':
						var _p8 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var j = _p8._0;
						var c = _p8._1;
						var k = A2(_elm_lang$core$Bitwise$shiftLeft, j, _p4._1);
						return {ctor: '_Tuple3', _0: k, _1: c, _2: true};
					case 'Rshift':
						var _p9 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var j = _p9._0;
						var c = _p9._1;
						return {
							ctor: '_Tuple3',
							_0: A2(_elm_lang$core$Bitwise$shiftRight, j, _p4._1),
							_1: c,
							_2: true
						};
					default:
						var _p10 = A2(_user$project$Y15D07$reduce1, _p4._0, circuit);
						var i = _p10._0;
						var c = _p10._1;
						var j = _elm_lang$core$Bitwise$complement(i);
						var k = (_elm_lang$core$Native_Utils.cmp(j, 0) < 0) ? ((_user$project$Y15D07$maxValue + j) + 1) : j;
						return {ctor: '_Tuple3', _0: k, _1: c, _2: true};
				}
			}();
			var k = _p3._0;
			var circuit$ = _p3._1;
			var insert = _p3._2;
			return insert ? A3(
				_elm_lang$core$Dict$insert,
				wire,
				_user$project$Y15D07$NoOp(k),
				circuit$) : circuit$;
		}
	});
var _user$project$Y15D07$reduce1 = F2(
	function (w, circuit) {
		var i = _elm_lang$core$String$toInt(w);
		var _p11 = i;
		if (_p11.ctor === 'Ok') {
			return {ctor: '_Tuple2', _0: _p11._0, _1: circuit};
		} else {
			var circuit$ = A2(_user$project$Y15D07$reduce, w, circuit);
			return {
				ctor: '_Tuple2',
				_0: A2(_user$project$Y15D07$getVal, w, circuit$),
				_1: circuit$
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
				var circuit$ = A2(_user$project$Y15D07$reduce, w2, circuit);
				return {
					ctor: '_Tuple3',
					_0: _p12._0._0,
					_1: A2(_user$project$Y15D07$getVal, w2, circuit$),
					_2: circuit$
				};
			}
		} else {
			if (_p12._1.ctor === 'Ok') {
				var circuit$ = A2(_user$project$Y15D07$reduce, w1, circuit);
				return {
					ctor: '_Tuple3',
					_0: A2(_user$project$Y15D07$getVal, w1, circuit$),
					_1: _p12._1._0,
					_2: circuit$
				};
			} else {
				var circuit$ = A2(_user$project$Y15D07$reduce, w1, circuit);
				var circuit$$ = A2(_user$project$Y15D07$reduce, w2, circuit$);
				return {
					ctor: '_Tuple3',
					_0: A2(_user$project$Y15D07$getVal, w1, circuit$),
					_1: A2(_user$project$Y15D07$getVal, w2, circuit$$),
					_2: circuit$$
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
				var circuit$ = A3(_elm_lang$core$Dict$insert, wire, action, circuit);
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
						_v11 = circuit$;
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
var _user$project$Y15D07$answers = function (input) {
	var circuit = _user$project$Y15D07$parseInput(input);
	var circuit1 = A2(_user$project$Y15D07$reduce, 'a', circuit);
	var p1 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D07$getVal, 'a', circuit1));
	var circuit2 = A2(
		_user$project$Y15D07$reduce,
		'a',
		A3(
			_elm_lang$core$Dict$insert,
			'b',
			_user$project$Y15D07$NoOp(3176),
			circuit));
	var p2 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D07$getVal, 'a', circuit2));
	return A2(_user$project$Util$join, p1, p2);
};

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
var _user$project$Y15D08$answers = function (input) {
	var strings = _user$project$Y15D08$parseInput(input);
	var p1 = _elm_lang$core$Basics$toString(
		_user$project$Y15D08$chrLength(strings) - _user$project$Y15D08$memLength(strings));
	var p2 = _elm_lang$core$Basics$toString(
		_user$project$Y15D08$escLength(strings) - _user$project$Y15D08$chrLength(strings));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D09$initModel = {
	distances: _elm_lang$core$Dict$empty,
	cities: _elm_lang$core$Native_List.fromArray(
		[])
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
		return _elm_lang$core$Native_List.fromArray(
			[]);
	} else {
		if (_p0._1.ctor === '[]') {
			return _elm_lang$core$Native_List.fromArray(
				[]);
		} else {
			var _p1 = _p0._1._0;
			return A2(
				_elm_lang$core$List_ops['::'],
				{ctor: '_Tuple2', _0: _p0._0, _1: _p1},
				_user$project$Y15D09$pairs(
					A2(_elm_lang$core$List_ops['::'], _p1, _p0._1._1)));
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
			var cities$ = A2(_elm_lang$core$List$member, _p3, model.cities) ? model.cities : A2(_elm_lang$core$List_ops['::'], _p3, model.cities);
			var cities = A2(_elm_lang$core$List$member, _p4, cities$) ? cities$ : A2(_elm_lang$core$List_ops['::'], _p4, cities$);
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
var _user$project$Y15D09$answers = function (input) {
	var model = _user$project$Y15D09$parseInput(input);
	var extremes = _user$project$Y15D09$extreme(model);
	var p1 = _elm_lang$core$Basics$toString(
		A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$minimum(extremes)));
	var p2 = _elm_lang$core$Basics$toString(
		A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$maximum(extremes)));
	return A2(_user$project$Util$join, p1, p2);
};
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
				var digits$ = A4(
					_elm_lang$core$Regex$replace,
					_elm_lang$core$Regex$All,
					_elm_lang$core$Regex$regex('(\\d)\\1*'),
					_user$project$Y15D10$mapper,
					digits);
				var _v0 = count - 1,
					_v1 = digits$;
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
var _user$project$Y15D10$answers = function (input) {
	var digits = _user$project$Y15D10$parse(input);
	var digits$ = A2(_user$project$Y15D10$conway, 40, digits);
	var p1 = _elm_lang$core$Basics$toString(
		_elm_lang$core$String$length(digits$));
	var digits$$ = A2(_user$project$Y15D10$conway, 10, digits$);
	var p2 = _elm_lang$core$Basics$toString(
		_elm_lang$core$String$length(digits$$));
	return A2(_user$project$Util$join, p1, p2);
};

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
	return _elm_lang$core$Basics$not(
		A2(
			_elm_lang$core$Regex$contains,
			_elm_lang$core$Regex$regex('[iol]'),
			p));
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
var _user$project$Y15D11$answers = function (input) {
	var p0 = _user$project$Y15D11$parse(input);
	var p1 = _user$project$Y15D11$next(p0);
	var p2 = _user$project$Y15D11$next(p1);
	return A2(_user$project$Util$join, p1, p2);
};

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
var _user$project$Y15D12$answers = function (input) {
	var p2 = _user$project$Y15D12$count(
		_user$project$Help$no_red(input));
	var p1 = _user$project$Y15D12$count(input);
	return A2(_user$project$Util$join, p1, p2);
};

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
		return A2(
			_elm_lang$core$List_ops['::'],
			{ctor: '_Tuple2', _0: _p1._0, _1: _p2},
			_user$project$Y15D13$inner(
				A2(_elm_lang$core$List_ops['::'], _p2, _p1._1._1)));
	} else {
		return _elm_lang$core$Native_List.fromArray(
			[]);
	}
};
var _user$project$Y15D13$pairup = function (list) {
	var pair = _user$project$Y15D13$outer(list);
	var pairs = _user$project$Y15D13$inner(list);
	var _p3 = pair;
	if ((_p3.ctor === 'Just') && (_p3._0.ctor === '_Tuple2')) {
		return A2(
			_elm_lang$core$List_ops['::'],
			{ctor: '_Tuple2', _0: _p3._0._0, _1: _p3._0._1},
			pairs);
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
var _user$project$Y15D13$parseInput = function (input) {
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
var _user$project$Y15D13$answers = function (input) {
	var m1 = _user$project$Y15D13$parseInput(input);
	var a1 = _user$project$Y15D13$happinesses(m1);
	var p1 = _elm_lang$core$Basics$toString(
		A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$maximum(a1)));
	var m2 = _user$project$Y15D13$addMe(m1);
	var a2 = _user$project$Y15D13$happinesses(m2);
	var p2 = _elm_lang$core$Basics$toString(
		A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			_elm_lang$core$List$maximum(a2)));
	return A2(_user$project$Util$join, p1, p2);
};
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
			return A2(_elm_lang$core$List_ops['::'], reindeer, model);
		} else {
			return model;
		}
	});
var _user$project$Y15D14$parseInput = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D14$parseLine,
		_elm_lang$core$Native_List.fromArray(
			[]),
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
				var t$ = t + 1;
				var model1 = A2(
					_elm_lang$core$List$map,
					function (r) {
						return _elm_lang$core$Native_Utils.update(
							r,
							{
								km: A2(_user$project$Y15D14$distance, t$, r)
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
				var _v1 = t$,
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
var _user$project$Y15D14$answers = function (input) {
	var time = 2503;
	var model = _user$project$Y15D14$parseInput(input);
	var p1 = A2(_user$project$Y15D14$maxDistance, time, model);
	var p2 = A2(_user$project$Y15D14$bestScore, time, model);
	return A2(_user$project$Util$join, p1, p2);
};
var _user$project$Y15D14$Reindeer = F6(
	function (a, b, c, d, e, f) {
		return {name: a, speed: b, time: c, rest: d, km: e, score: f};
	});

var _user$project$Y15D15$initCookie = F2(
	function (model, total) {
		var size = _elm_lang$core$List$length(model);
		var first = (total - size) + 1;
		var ones = A2(_elm_lang$core$List$repeat, size - 1, 1);
		return A2(_elm_lang$core$List_ops['::'], first, ones);
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
					_elm_lang$core$Native_List.fromArray(
						[cp, du, fl, tx])));
		}
	});
var _user$project$Y15D15$increment = function (l) {
	var _p1 = l;
	if (_p1.ctor === '[]') {
		return _elm_lang$core$Native_List.fromArray(
			[]);
	} else {
		return A2(_elm_lang$core$List_ops['::'], _p1._0 + 1, _p1._1);
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
				_1: _elm_lang$core$Native_List.fromArray(
					[])
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
					A2(
						_elm_lang$core$List_ops['::'],
						n,
						A2(_elm_lang$core$Basics_ops['++'], ones, l)));
			}
		} else {
			return _elm_lang$core$Maybe$Just(
				A2(
					_elm_lang$core$List_ops['::'],
					_p3._0 - 1,
					_user$project$Y15D15$increment(_p3._1)));
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
					_elm_lang$core$Native_List.fromArray(
						[
							A3(_user$project$Y15D15$score, model, calories, oldCookie),
							oldHigh
						])));
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
			return A2(
				_elm_lang$core$List_ops['::'],
				A6(_user$project$Y15D15$Ingredient, _p6._0._0._0, cp2, du2, fl2, tx2, cl2),
				model);
		} else {
			return model;
		}
	});
var _user$project$Y15D15$parseInput = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D15$parseLine,
		_elm_lang$core$Native_List.fromArray(
			[]),
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D15$answers = function (input) {
	var model = _user$project$Y15D15$parseInput(input);
	var cookie = A2(_user$project$Y15D15$initCookie, model, 100);
	var p1 = _elm_lang$core$Basics$toString(
		A4(_user$project$Y15D15$highScore, model, _elm_lang$core$Maybe$Nothing, 0, cookie));
	var p2 = _elm_lang$core$Basics$toString(
		A4(
			_user$project$Y15D15$highScore,
			model,
			_elm_lang$core$Maybe$Just(500),
			0,
			cookie));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D16$parseInt = function (s) {
	return A2(
		_elm_lang$core$Result$withDefault,
		0,
		_elm_lang$core$String$toInt(s));
};
var _user$project$Y15D16$match2 = F3(
	function (prop, val, prevProp) {
		if (_elm_lang$core$Basics$not(prevProp)) {
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
		if (_elm_lang$core$Basics$not(prevProp)) {
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
			return A2(
				_elm_lang$core$List_ops['::'],
				A2(_user$project$Y15D16$Sue, i, d),
				model);
		} else {
			return model;
		}
	});
var _user$project$Y15D16$parseInput = function (input) {
	return A3(
		_elm_lang$core$List$foldl,
		_user$project$Y15D16$parseLine,
		_elm_lang$core$Native_List.fromArray(
			[]),
		A2(
			_elm_lang$core$List$filter,
			function (l) {
				return !_elm_lang$core$Native_Utils.eq(l, '');
			},
			A2(_elm_lang$core$String$split, '\n', input)));
};
var _user$project$Y15D16$answers = function (input) {
	var model = _user$project$Y15D16$parseInput(input);
	var p1 = A2(_user$project$Y15D16$sue, _user$project$Y15D16$match1, model);
	var p2 = A2(_user$project$Y15D16$sue, _user$project$Y15D16$match2, model);
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D17$parseInput = function (input) {
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
var _user$project$Y15D17$answers = function (input) {
	var model = _user$project$Y15D17$parseInput(input);
	var number = A3(
		_user$project$Y15D17$combos,
		_elm_lang$core$List$length(model),
		150,
		model);
	var p1 = _elm_lang$core$Basics$toString(
		_elm_lang$core$Basics$fst(number));
	var p2 = _elm_lang$core$Basics$toString(
		_elm_lang$core$Basics$snd(number));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D18$initModel = {lights: _elm_lang$core$Array$empty, size: 0, maxIndex: 0, stuck: false};
var _user$project$Y15D18$debug = function (model) {
	var chars = A2(
		_elm_lang$core$String$join,
		'',
		A2(
			_elm_lang$core$List$map,
			function (b) {
				return b ? '#' : '.';
			},
			_elm_lang$core$Array$toList(model.lights)));
	var lines = A2(
		_elm_lang$core$List$map,
		function (_) {
			return _.match;
		},
		A3(
			_elm_lang$core$Regex$find,
			_elm_lang$core$Regex$All,
			_elm_lang$core$Regex$regex(
				A2(
					_elm_lang$core$Basics_ops['++'],
					'.{',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(model.size),
						'}'))),
			chars));
	return A2(
		_elm_lang$core$Basics_ops['++'],
		A2(_elm_lang$core$String$join, '\n', lines),
		'\n');
};
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
		var ds = _elm_lang$core$Native_List.fromArray(
			[
				{ctor: '_Tuple2', _0: -1, _1: -1},
				{ctor: '_Tuple2', _0: 0, _1: -1},
				{ctor: '_Tuple2', _0: 1, _1: -1},
				{ctor: '_Tuple2', _0: -1, _1: 0},
				{ctor: '_Tuple2', _0: 1, _1: 0},
				{ctor: '_Tuple2', _0: -1, _1: 1},
				{ctor: '_Tuple2', _0: 0, _1: 1},
				{ctor: '_Tuple2', _0: 1, _1: 1}
			]);
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
				var model = _elm_lang$core$Native_Utils.update(
					model,
					{
						lights: A3(
							_elm_lang$core$Array$set,
							A2(_user$project$Y15D18$index, model, cell),
							v,
							model.lights)
					});
				var nextCell = A2(_user$project$Y15D18$next, model, cell);
				var _v6 = oldModel,
					_v7 = model,
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
var _user$project$Y15D18$parseInput = function (input) {
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
var _user$project$Y15D18$answers = function (input) {
	var nm = 100;
	var model = _user$project$Y15D18$parseInput(input);
	var m1 = A2(_user$project$Y15D18$steps, nm, model);
	var p1 = _elm_lang$core$Basics$toString(
		_user$project$Y15D18$count(m1));
	var m2 = A2(
		_user$project$Y15D18$steps,
		nm,
		_user$project$Y15D18$stick(model));
	var p2 = _elm_lang$core$Basics$toString(
		_user$project$Y15D18$count(m2));
	return A2(_user$project$Util$join, p1, p2);
};

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
				var replacements$ = A2(_elm_lang$core$Set$insert, replacement, replacements);
				var _v1 = _p0._1,
					_v2 = from,
					_v3 = to,
					_v4 = molecule,
					_v5 = replacements$;
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
			var to = _elm_lang$core$Basics$snd(_p3);
			var from = _elm_lang$core$Basics$fst(_p3);
			var matches = A3(
				_elm_lang$core$Regex$find,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex(from),
				model.molecule);
			var replacements$ = A5(_user$project$Y15D19$addToReplacements, matches, from, to, model.molecule, model.replacements);
			var model$ = {rules: _p2._1, molecule: model.molecule, replacements: replacements$};
			var _v7 = model$;
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
	var model$ = _user$project$Y15D19$iterateRules(model);
	return _elm_lang$core$Basics$toString(
		_elm_lang$core$Set$size(model$.replacements));
};
var _user$project$Y15D19$answers = function (input) {
	var model = _user$project$Y15D19$parse(input);
	var p1 = _user$project$Y15D19$molecules(model);
	var p2 = _user$project$Y15D19$askalski(model);
	return A2(_user$project$Util$join, p1, p2);
};
var _user$project$Y15D19$Model = F3(
	function (a, b, c) {
		return {rules: a, molecule: b, replacements: c};
	});

var _user$project$Y15D20$parseInput = function (input) {
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
					var fs2 = A2(_elm_lang$core$List_ops['::'], i, fs);
					return _elm_lang$core$Native_Utils.eq(j, i) ? fs2 : A2(_elm_lang$core$List_ops['::'], j, fs2);
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
		_elm_lang$core$Native_List.fromArray(
			[]));
};
var _user$project$Y15D20$house2 = F2(
	function (goal, house) {
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
				var _v0 = goal,
					_v1 = house + 1;
				goal = _v0;
				house = _v1;
				continue house2;
			}
		}
	});
var _user$project$Y15D20$house1 = F2(
	function (goal, house) {
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
				var _v2 = goal,
					_v3 = house + 1;
				goal = _v2;
				house = _v3;
				continue house1;
			}
		}
	});
var _user$project$Y15D20$answers = function (input) {
	var goal = _user$project$Y15D20$parseInput(input);
	var p1 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D20$house1, goal, 1));
	var p2 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D20$house2, goal, 1));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D21$rings = _elm_lang$core$Array$fromList(
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
			_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
			_elm_lang$core$Native_List.fromArray(
			[25, 1, 0]),
			_elm_lang$core$Native_List.fromArray(
			[50, 2, 0]),
			_elm_lang$core$Native_List.fromArray(
			[100, 3, 0]),
			_elm_lang$core$Native_List.fromArray(
			[20, 0, 1]),
			_elm_lang$core$Native_List.fromArray(
			[40, 0, 2]),
			_elm_lang$core$Native_List.fromArray(
			[80, 0, 3])
		]));
var _user$project$Y15D21$armors = _elm_lang$core$Array$fromList(
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
			_elm_lang$core$Native_List.fromArray(
			[13, 0, 1]),
			_elm_lang$core$Native_List.fromArray(
			[31, 0, 2]),
			_elm_lang$core$Native_List.fromArray(
			[53, 0, 3]),
			_elm_lang$core$Native_List.fromArray(
			[75, 0, 4]),
			_elm_lang$core$Native_List.fromArray(
			[102, 0, 5])
		]));
var _user$project$Y15D21$weapons = _elm_lang$core$Array$fromList(
	_elm_lang$core$Native_List.fromArray(
		[
			_elm_lang$core$Native_List.fromArray(
			[8, 4, 0]),
			_elm_lang$core$Native_List.fromArray(
			[10, 5, 0]),
			_elm_lang$core$Native_List.fromArray(
			[25, 6, 0]),
			_elm_lang$core$Native_List.fromArray(
			[40, 7, 0]),
			_elm_lang$core$Native_List.fromArray(
			[74, 8, 0])
		]));
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
		return _elm_lang$core$Basics$not(pwin) && (_elm_lang$core$Native_Utils.cmp(pcost, best) > 0);
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
		_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
		A2(_elm_lang$core$Array$get, i.r2, _user$project$Y15D21$rings));
	var ring1 = A2(
		_elm_lang$core$Maybe$withDefault,
		_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
		A2(_elm_lang$core$Array$get, i.r1, _user$project$Y15D21$rings));
	var armor = A2(
		_elm_lang$core$Maybe$withDefault,
		_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
		A2(_elm_lang$core$Array$get, i.a, _user$project$Y15D21$armors));
	var weapon = A2(
		_elm_lang$core$Maybe$withDefault,
		_elm_lang$core$Native_List.fromArray(
			[0, 0, 0]),
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
var _user$project$Y15D21$parseInput = function (input) {
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
var _user$project$Y15D21$answers = function (input) {
	var boss = _user$project$Y15D21$parseInput(input);
	var p1 = _elm_lang$core$Basics$toString(
		A4(_user$project$Y15D21$search, boss, _user$project$Y15D21$lowest, 0, _user$project$Y15D21$initIndex));
	var p2 = _elm_lang$core$Basics$toString(
		A4(_user$project$Y15D21$search, boss, _user$project$Y15D21$highest, 0, _user$project$Y15D21$initIndex));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D22$answers = function (input) {
	return 'not implemented';
};

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
			var model$ = function () {
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
			var _v2 = model$;
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
var _user$project$Y15D23$parseInput = function (input) {
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
var _user$project$Y15D23$answers = function (input) {
	var model1 = _user$project$Y15D23$parseInput(input);
	var model2 = _elm_lang$core$Native_Utils.update(
		model1,
		{
			registers: A3(_elm_lang$core$Dict$insert, 'a', 1, model1.registers)
		});
	var p2 = _elm_lang$core$Basics$toString(
		A2(
			_user$project$Y15D23$get,
			'b',
			_user$project$Y15D23$run(model2)));
	var p1 = _elm_lang$core$Basics$toString(
		A2(
			_user$project$Y15D23$get,
			'b',
			_user$project$Y15D23$run(model1)));
	return A2(_user$project$Util$join, p1, p2);
};

var _user$project$Y15D24$parseInput = function (input) {
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
				var qe$ = function () {
					if (!_elm_lang$core$Native_Utils.eq(
						_elm_lang$core$List$sum(_p1),
						weight)) {
						return qe;
					} else {
						var qe$$ = _elm_lang$core$List$product(_p1);
						return (_elm_lang$core$Native_Utils.eq(qe, 0) || (_elm_lang$core$Native_Utils.cmp(qe$$, qe) < 0)) ? qe$$ : qe;
					}
				}();
				var _v1 = qe$,
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
				var qe$ = A3(_user$project$Y15D24$searchCombo, qe, weight, combos);
				if (_elm_lang$core$Native_Utils.cmp(qe$, 0) > 0) {
					return qe$;
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
var _user$project$Y15D24$answers = function (input) {
	var weights = _user$project$Y15D24$parseInput(input);
	var p1 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D24$bestQe, 3, weights));
	var p2 = _elm_lang$core$Basics$toString(
		A2(_user$project$Y15D24$bestQe, 4, weights));
	return A2(_user$project$Util$join, p1, p2);
};

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
				var code$ = A2(_elm_lang$core$Basics_ops['%'], model.code * 252533, 33554393);
				var _p2 = (_elm_lang$core$Native_Utils.cmp(model.row, 1) > 0) ? {ctor: '_Tuple2', _0: model.row - 1, _1: model.col + 1} : {ctor: '_Tuple2', _0: model.col + 1, _1: 1};
				var row$ = _p2._0;
				var col$ = _p2._1;
				var _v1 = {ctor: '_Tuple2', _0: _p4, _1: _p3},
					_v2 = {code: code$, row: row$, col: col$};
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
				_elm_lang$core$Native_List.fromArray(
					[
						_elm_lang$core$Maybe$Just('1'),
						_elm_lang$core$Maybe$Just('1')
					]),
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
var _user$project$Y15D25$answer = function (input) {
	var target = _user$project$Y15D25$parse(input);
	var model = A2(_user$project$Y15D25$search, target, _user$project$Y15D25$start);
	return _elm_lang$core$Basics$toString(model.code);
};
var _user$project$Y15D25$Model = F3(
	function (a, b, c) {
		return {code: a, row: b, col: c};
	});

var _user$project$Y15$answers = F2(
	function (day, input) {
		var _p0 = day;
		switch (_p0) {
			case 1:
				return _user$project$Y15D01$answers(input);
			case 2:
				return _user$project$Y15D02$answers(input);
			case 3:
				return _user$project$Y15D03$answers(input);
			case 4:
				return _user$project$Y15D04$answers(input);
			case 5:
				return _user$project$Y15D05$answers(input);
			case 6:
				return _user$project$Y15D06$answers(input);
			case 7:
				return _user$project$Y15D07$answers(input);
			case 8:
				return _user$project$Y15D08$answers(input);
			case 9:
				return _user$project$Y15D09$answers(input);
			case 10:
				return _user$project$Y15D10$answers(input);
			case 11:
				return _user$project$Y15D11$answers(input);
			case 12:
				return _user$project$Y15D12$answers(input);
			case 13:
				return _user$project$Y15D13$answers(input);
			case 14:
				return _user$project$Y15D14$answers(input);
			case 15:
				return _user$project$Y15D15$answers(input);
			case 16:
				return _user$project$Y15D16$answers(input);
			case 17:
				return _user$project$Y15D17$answers(input);
			case 18:
				return _user$project$Y15D18$answers(input);
			case 19:
				return _user$project$Y15D19$answers(input);
			case 20:
				return _user$project$Y15D20$answers(input);
			case 21:
				return _user$project$Y15D21$answers(input);
			case 22:
				return _user$project$Y15D22$answers(input);
			case 23:
				return _user$project$Y15D23$answers(input);
			case 24:
				return _user$project$Y15D24$answers(input);
			case 25:
				return _user$project$Y15D25$answer(input);
			default:
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'year 2015, day ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(day),
						': not implemented yet'));
		}
	});

var _user$project$Ports$problem = _elm_lang$core$Native_Platform.incomingPort(
	'problem',
	A4(
		_elm_lang$core$Json_Decode$tuple3,
		F3(
			function (x1, x2, x3) {
				return {ctor: '_Tuple3', _0: x1, _1: x2, _2: x3};
			}),
		_elm_lang$core$Json_Decode$int,
		_elm_lang$core$Json_Decode$int,
		_elm_lang$core$Json_Decode$string));
var _user$project$Ports$answer = _elm_lang$core$Native_Platform.outgoingPort(
	'answer',
	function (v) {
		return v;
	});

var _user$project$Main$update = F2(
	function (msg, model) {
		var _p0 = msg;
		var _p2 = _p0._0._0;
		var newModel = function () {
			var _p1 = _p2;
			if (_p1 === 2015) {
				return A2(_user$project$Y15$answers, _p0._0._1, _p0._0._2);
			} else {
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'year ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p2),
						': not available yet'));
			}
		}();
		return {
			ctor: '_Tuple2',
			_0: newModel,
			_1: _user$project$Ports$answer(newModel)
		};
	});
var _user$project$Main$init = {ctor: '_Tuple2', _0: 'no problem', _1: _elm_lang$core$Platform_Cmd$none};
var _user$project$Main$Problem = function (a) {
	return {ctor: 'Problem', _0: a};
};
var _user$project$Main$subscriptions = function (model) {
	return _user$project$Ports$problem(_user$project$Main$Problem);
};

var Elm = {};
Elm['Main'] = Elm['Main'] || {};
_elm_lang$core$Native_Platform.addPublicModule(Elm['Main'], 'Main', typeof _user$project$Main$main === 'undefined' ? null : _user$project$Main$main);

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

