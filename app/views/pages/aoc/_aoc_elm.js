var Elm = Elm || { Native: {} };
Elm.Native.Array = {};
Elm.Native.Array.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Array = localRuntime.Native.Array || {};
	if (localRuntime.Native.Array.values)
	{
		return localRuntime.Native.Array.values;
	}
	if ('values' in Elm.Native.Array)
	{
		return localRuntime.Native.Array.values = Elm.Native.Array.values;
	}

	var List = Elm.Native.List.make(localRuntime);

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
		if (list === List.Nil)
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
		return toList_(List.Nil, a);
	}

	function toList_(list, a)
	{
		for (var i = a.table.length - 1; i >= 0; i--)
		{
			list =
				a.height === 0
					? List.Cons(a.table[i], list)
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

	Elm.Native.Array.values = {
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

	return localRuntime.Native.Array.values = Elm.Native.Array.values;
};

Elm.Native.Basics = {};
Elm.Native.Basics.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Basics = localRuntime.Native.Basics || {};
	if (localRuntime.Native.Basics.values)
	{
		return localRuntime.Native.Basics.values;
	}

	var Utils = Elm.Native.Utils.make(localRuntime);

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
		return Utils.cmp(a, b) < 0 ? a : b;
	}
	function max(a, b)
	{
		return Utils.cmp(a, b) > 0 ? a : b;
	}
	function clamp(lo, hi, n)
	{
		return Utils.cmp(n, lo) < 0 ? lo : Utils.cmp(n, hi) > 0 ? hi : n;
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
		return Utils.Tuple2(r * Math.cos(t), r * Math.sin(t));
	}
	function toPolar(point)
	{
		var x = point._0;
		var y = point._1;
		return Utils.Tuple2(Math.sqrt(x * x + y * y), Math.atan2(y, x));
	}

	return localRuntime.Native.Basics.values = {
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
		compare: Utils.compare,

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
};

Elm.Native.Port = {};

Elm.Native.Port.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Port = localRuntime.Native.Port || {};
	if (localRuntime.Native.Port.values)
	{
		return localRuntime.Native.Port.values;
	}

	var NS;

	// INBOUND

	function inbound(name, type, converter)
	{
		if (!localRuntime.argsTracker[name])
		{
			throw new Error(
				'Port Error:\n' +
				'No argument was given for the port named \'' + name + '\' with type:\n\n' +
				'    ' + type.split('\n').join('\n        ') + '\n\n' +
				'You need to provide an initial value!\n\n' +
				'Find out more about ports here <http://elm-lang.org/learn/Ports.elm>'
			);
		}
		var arg = localRuntime.argsTracker[name];
		arg.used = true;

		return jsToElm(name, type, converter, arg.value);
	}


	function inboundSignal(name, type, converter)
	{
		var initialValue = inbound(name, type, converter);

		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		var signal = NS.input('inbound-port-' + name, initialValue);

		function send(jsValue)
		{
			var elmValue = jsToElm(name, type, converter, jsValue);
			setTimeout(function() {
				localRuntime.notify(signal.id, elmValue);
			}, 0);
		}

		localRuntime.ports[name] = { send: send };

		return signal;
	}


	function jsToElm(name, type, converter, value)
	{
		try
		{
			return converter(value);
		}
		catch(e)
		{
			throw new Error(
				'Port Error:\n' +
				'Regarding the port named \'' + name + '\' with type:\n\n' +
				'    ' + type.split('\n').join('\n        ') + '\n\n' +
				'You just sent the value:\n\n' +
				'    ' + JSON.stringify(value) + '\n\n' +
				'but it cannot be converted to the necessary type.\n' +
				e.message
			);
		}
	}


	// OUTBOUND

	function outbound(name, converter, elmValue)
	{
		localRuntime.ports[name] = converter(elmValue);
	}


	function outboundSignal(name, converter, signal)
	{
		var subscribers = [];

		function subscribe(handler)
		{
			subscribers.push(handler);
		}
		function unsubscribe(handler)
		{
			subscribers.pop(subscribers.indexOf(handler));
		}

		function notify(elmValue)
		{
			var jsValue = converter(elmValue);
			var len = subscribers.length;
			for (var i = 0; i < len; ++i)
			{
				subscribers[i](jsValue);
			}
		}

		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		NS.output('outbound-port-' + name, notify, signal);

		localRuntime.ports[name] = {
			subscribe: subscribe,
			unsubscribe: unsubscribe
		};

		return signal;
	}


	return localRuntime.Native.Port.values = {
		inbound: inbound,
		outbound: outbound,
		inboundSignal: inboundSignal,
		outboundSignal: outboundSignal
	};
};

if (!Elm.fullscreen) {
	(function() {
		'use strict';

		var Display = {
			FULLSCREEN: 0,
			COMPONENT: 1,
			NONE: 2
		};

		Elm.fullscreen = function(module, args)
		{
			var container = document.createElement('div');
			document.body.appendChild(container);
			return init(Display.FULLSCREEN, container, module, args || {});
		};

		Elm.embed = function(module, container, args)
		{
			var tag = container.tagName;
			if (tag !== 'DIV')
			{
				throw new Error('Elm.node must be given a DIV, not a ' + tag + '.');
			}
			return init(Display.COMPONENT, container, module, args || {});
		};

		Elm.worker = function(module, args)
		{
			return init(Display.NONE, {}, module, args || {});
		};

		function init(display, container, module, args, moduleToReplace)
		{
			// defining state needed for an instance of the Elm RTS
			var inputs = [];

			/* OFFSET
			 * Elm's time traveling debugger lets you pause time. This means
			 * "now" may be shifted a bit into the past. By wrapping Date.now()
			 * we can manage this.
			 */
			var timer = {
				programStart: Date.now(),
				now: function()
				{
					return Date.now();
				}
			};

			var updateInProgress = false;
			function notify(id, v)
			{
				if (updateInProgress)
				{
					throw new Error(
						'The notify function has been called synchronously!\n' +
						'This can lead to frames being dropped.\n' +
						'Definitely report this to <https://github.com/elm-lang/Elm/issues>\n');
				}
				updateInProgress = true;
				var timestep = timer.now();
				for (var i = inputs.length; i--; )
				{
					inputs[i].notify(timestep, id, v);
				}
				updateInProgress = false;
			}
			function setTimeout(func, delay)
			{
				return window.setTimeout(func, delay);
			}

			var listeners = [];
			function addListener(relevantInputs, domNode, eventName, func)
			{
				domNode.addEventListener(eventName, func);
				var listener = {
					relevantInputs: relevantInputs,
					domNode: domNode,
					eventName: eventName,
					func: func
				};
				listeners.push(listener);
			}

			var argsTracker = {};
			for (var name in args)
			{
				argsTracker[name] = {
					value: args[name],
					used: false
				};
			}

			// create the actual RTS. Any impure modules will attach themselves to this
			// object. This permits many Elm programs to be embedded per document.
			var elm = {
				notify: notify,
				setTimeout: setTimeout,
				node: container,
				addListener: addListener,
				inputs: inputs,
				timer: timer,
				argsTracker: argsTracker,
				ports: {},

				isFullscreen: function() { return display === Display.FULLSCREEN; },
				isEmbed: function() { return display === Display.COMPONENT; },
				isWorker: function() { return display === Display.NONE; }
			};

			function swap(newModule)
			{
				removeListeners(listeners);
				var div = document.createElement('div');
				var newElm = init(display, div, newModule, args, elm);
				inputs = [];

				return newElm;
			}

			function dispose()
			{
				removeListeners(listeners);
				inputs = [];
			}

			var Module = {};
			try
			{
				Module = module.make(elm);
				checkInputs(elm);
			}
			catch (error)
			{
				if (typeof container.appendChild === "function")
				{
					container.appendChild(errorNode(error.message));
				}
				else
				{
					console.error(error.message);
				}
				throw error;
			}

			if (display !== Display.NONE)
			{
				var graphicsNode = initGraphics(elm, Module);
			}

			var rootNode = { kids: inputs };
			trimDeadNodes(rootNode);
			inputs = rootNode.kids;
			filterListeners(inputs, listeners);

			addReceivers(elm.ports);

			if (typeof moduleToReplace !== 'undefined')
			{
				hotSwap(moduleToReplace, elm);

				// rerender scene if graphics are enabled.
				if (typeof graphicsNode !== 'undefined')
				{
					graphicsNode.notify(0, true, 0);
				}
			}

			return {
				swap: swap,
				ports: elm.ports,
				dispose: dispose
			};
		}

		function checkInputs(elm)
		{
			var argsTracker = elm.argsTracker;
			for (var name in argsTracker)
			{
				if (!argsTracker[name].used)
				{
					throw new Error(
						"Port Error:\nYou provided an argument named '" + name +
						"' but there is no corresponding port!\n\n" +
						"Maybe add a port '" + name + "' to your Elm module?\n" +
						"Maybe remove the '" + name + "' argument from your initialization code in JS?"
					);
				}
			}
		}

		function errorNode(message)
		{
			var code = document.createElement('code');

			var lines = message.split('\n');
			code.appendChild(document.createTextNode(lines[0]));
			code.appendChild(document.createElement('br'));
			code.appendChild(document.createElement('br'));
			for (var i = 1; i < lines.length; ++i)
			{
				code.appendChild(document.createTextNode('\u00A0 \u00A0 ' + lines[i].replace(/  /g, '\u00A0 ')));
				code.appendChild(document.createElement('br'));
			}
			code.appendChild(document.createElement('br'));
			code.appendChild(document.createTextNode('Open the developer console for more details.'));
			return code;
		}


		//// FILTER SIGNALS ////

		// TODO: move this code into the signal module and create a function
		// Signal.initializeGraph that actually instantiates everything.

		function filterListeners(inputs, listeners)
		{
			loop:
			for (var i = listeners.length; i--; )
			{
				var listener = listeners[i];
				for (var j = inputs.length; j--; )
				{
					if (listener.relevantInputs.indexOf(inputs[j].id) >= 0)
					{
						continue loop;
					}
				}
				listener.domNode.removeEventListener(listener.eventName, listener.func);
			}
		}

		function removeListeners(listeners)
		{
			for (var i = listeners.length; i--; )
			{
				var listener = listeners[i];
				listener.domNode.removeEventListener(listener.eventName, listener.func);
			}
		}

		// add receivers for built-in ports if they are defined
		function addReceivers(ports)
		{
			if ('title' in ports)
			{
				if (typeof ports.title === 'string')
				{
					document.title = ports.title;
				}
				else
				{
					ports.title.subscribe(function(v) { document.title = v; });
				}
			}
			if ('redirect' in ports)
			{
				ports.redirect.subscribe(function(v) {
					if (v.length > 0)
					{
						window.location = v;
					}
				});
			}
		}


		// returns a boolean representing whether the node is alive or not.
		function trimDeadNodes(node)
		{
			if (node.isOutput)
			{
				return true;
			}

			var liveKids = [];
			for (var i = node.kids.length; i--; )
			{
				var kid = node.kids[i];
				if (trimDeadNodes(kid))
				{
					liveKids.push(kid);
				}
			}
			node.kids = liveKids;

			return liveKids.length > 0;
		}


		////  RENDERING  ////

		function initGraphics(elm, Module)
		{
			if (!('main' in Module))
			{
				throw new Error("'main' is missing! What do I display?!");
			}

			var signalGraph = Module.main;

			// make sure the signal graph is actually a signal & extract the visual model
			if (!('notify' in signalGraph))
			{
				signalGraph = Elm.Signal.make(elm).constant(signalGraph);
			}
			var initialScene = signalGraph.value;

			// Figure out what the render functions should be
			var render;
			var update;
			if (initialScene.ctor === 'Element_elm_builtin')
			{
				var Element = Elm.Native.Graphics.Element.make(elm);
				render = Element.render;
				update = Element.updateAndReplace;
			}
			else
			{
				var VirtualDom = Elm.Native.VirtualDom.make(elm);
				render = VirtualDom.render;
				update = VirtualDom.updateAndReplace;
			}

			// Add the initialScene to the DOM
			var container = elm.node;
			var node = render(initialScene);
			while (container.firstChild)
			{
				container.removeChild(container.firstChild);
			}
			container.appendChild(node);

			var _requestAnimationFrame =
				typeof requestAnimationFrame !== 'undefined'
					? requestAnimationFrame
					: function(cb) { setTimeout(cb, 1000 / 60); }
					;

			// domUpdate is called whenever the main Signal changes.
			//
			// domUpdate and drawCallback implement a small state machine in order
			// to schedule only 1 draw per animation frame. This enforces that
			// once draw has been called, it will not be called again until the
			// next frame.
			//
			// drawCallback is scheduled whenever
			// 1. The state transitions from PENDING_REQUEST to EXTRA_REQUEST, or
			// 2. The state transitions from NO_REQUEST to PENDING_REQUEST
			//
			// Invariants:
			// 1. In the NO_REQUEST state, there is never a scheduled drawCallback.
			// 2. In the PENDING_REQUEST and EXTRA_REQUEST states, there is always exactly 1
			//    scheduled drawCallback.
			var NO_REQUEST = 0;
			var PENDING_REQUEST = 1;
			var EXTRA_REQUEST = 2;
			var state = NO_REQUEST;
			var savedScene = initialScene;
			var scheduledScene = initialScene;

			function domUpdate(newScene)
			{
				scheduledScene = newScene;

				switch (state)
				{
					case NO_REQUEST:
						_requestAnimationFrame(drawCallback);
						state = PENDING_REQUEST;
						return;
					case PENDING_REQUEST:
						state = PENDING_REQUEST;
						return;
					case EXTRA_REQUEST:
						state = PENDING_REQUEST;
						return;
				}
			}

			function drawCallback()
			{
				switch (state)
				{
					case NO_REQUEST:
						// This state should not be possible. How can there be no
						// request, yet somehow we are actively fulfilling a
						// request?
						throw new Error(
							'Unexpected draw callback.\n' +
							'Please report this to <https://github.com/elm-lang/core/issues>.'
						);

					case PENDING_REQUEST:
						// At this point, we do not *know* that another frame is
						// needed, but we make an extra request to rAF just in
						// case. It's possible to drop a frame if rAF is called
						// too late, so we just do it preemptively.
						_requestAnimationFrame(drawCallback);
						state = EXTRA_REQUEST;

						// There's also stuff we definitely need to draw.
						draw();
						return;

					case EXTRA_REQUEST:
						// Turns out the extra request was not needed, so we will
						// stop calling rAF. No reason to call it all the time if
						// no one needs it.
						state = NO_REQUEST;
						return;
				}
			}

			function draw()
			{
				update(elm.node.firstChild, savedScene, scheduledScene);
				if (elm.Native.Window)
				{
					elm.Native.Window.values.resizeIfNeeded();
				}
				savedScene = scheduledScene;
			}

			var renderer = Elm.Native.Signal.make(elm).output('main', domUpdate, signalGraph);

			// must check for resize after 'renderer' is created so
			// that changes show up.
			if (elm.Native.Window)
			{
				elm.Native.Window.values.resizeIfNeeded();
			}

			return renderer;
		}

		//// HOT SWAPPING ////

		// Returns boolean indicating if the swap was successful.
		// Requires that the two signal graphs have exactly the same
		// structure.
		function hotSwap(from, to)
		{
			function similar(nodeOld, nodeNew)
			{
				if (nodeOld.id !== nodeNew.id)
				{
					return false;
				}
				if (nodeOld.isOutput)
				{
					return nodeNew.isOutput;
				}
				return nodeOld.kids.length === nodeNew.kids.length;
			}
			function swap(nodeOld, nodeNew)
			{
				nodeNew.value = nodeOld.value;
				return true;
			}
			var canSwap = depthFirstTraversals(similar, from.inputs, to.inputs);
			if (canSwap)
			{
				depthFirstTraversals(swap, from.inputs, to.inputs);
			}
			from.node.parentNode.replaceChild(to.node, from.node);

			return canSwap;
		}

		// Returns false if the node operation f ever fails.
		function depthFirstTraversals(f, queueOld, queueNew)
		{
			if (queueOld.length !== queueNew.length)
			{
				return false;
			}
			queueOld = queueOld.slice(0);
			queueNew = queueNew.slice(0);

			var seen = [];
			while (queueOld.length > 0 && queueNew.length > 0)
			{
				var nodeOld = queueOld.pop();
				var nodeNew = queueNew.pop();
				if (seen.indexOf(nodeOld.id) < 0)
				{
					if (!f(nodeOld, nodeNew))
					{
						return false;
					}
					queueOld = queueOld.concat(nodeOld.kids || []);
					queueNew = queueNew.concat(nodeNew.kids || []);
					seen.push(nodeOld.id);
				}
			}
			return true;
		}
	}());

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
}

Elm.Native = Elm.Native || {};
Elm.Native.Utils = {};
Elm.Native.Utils.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Utils = localRuntime.Native.Utils || {};
	if (localRuntime.Native.Utils.values)
	{
		return localRuntime.Native.Utils.values;
	}


	// COMPARISONS

	function eq(l, r)
	{
		var stack = [{'x': l, 'y': r}];
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
				for (var i in x)
				{
					++c;
					if (i in y)
					{
						if (i !== 'ctor')
						{
							stack.push({ 'x': x[i], 'y': y[i] });
						}
					}
					else
					{
						return false;
					}
				}
				if ('ctor' in x)
				{
					stack.push({'x': x.ctor, 'y': y.ctor});
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

	// code in Generate/JavaScript.hs depends on the particular
	// integer values assigned to LT, EQ, and GT
	var LT = -1, EQ = 0, GT = 1, ord = ['LT', 'EQ', 'GT'];

	function compare(x, y)
	{
		return {
			ctor: ord[cmp(x, y) + 1]
		};
	}

	function cmp(x, y) {
		var ord;
		if (typeof x !== 'object')
		{
			return x === y ? EQ : x < y ? LT : GT;
		}
		else if (x.isChar)
		{
			var a = x.toString();
			var b = y.toString();
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


	// TUPLES

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


	// LITERALS

	function chr(c)
	{
		var x = new String(c);
		x.isChar = true;
		return x;
	}

	function txt(str)
	{
		var t = new String(str);
		t.text = true;
		return t;
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


	// MOUSE COORDINATES

	function getXY(e)
	{
		var posx = 0;
		var posy = 0;
		if (e.pageX || e.pageY)
		{
			posx = e.pageX;
			posy = e.pageY;
		}
		else if (e.clientX || e.clientY)
		{
			posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
			posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
		}

		if (localRuntime.isEmbed())
		{
			var rect = localRuntime.node.getBoundingClientRect();
			var relx = rect.left + document.body.scrollLeft + document.documentElement.scrollLeft;
			var rely = rect.top + document.body.scrollTop + document.documentElement.scrollTop;
			// TODO: figure out if there is a way to avoid rounding here
			posx = posx - Math.round(relx) - localRuntime.node.clientLeft;
			posy = posy - Math.round(rely) - localRuntime.node.clientTop;
		}
		return Tuple2(posx, posy);
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

	function list(arr)
	{
		var out = Nil;
		for (var i = arr.length; i--; )
		{
			out = Cons(arr[i], out);
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

	function append(xs, ys)
	{
		// append Strings
		if (typeof xs === 'string')
		{
			return xs + ys;
		}

		// append Text
		if (xs.ctor.slice(0, 5) === 'Text:')
		{
			return {
				ctor: 'Text:Append',
				_0: xs,
				_1: ys
			};
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


	// BAD PORTS

	function badPort(expected, received)
	{
		throw new Error(
			'Runtime error when sending values through a port.\n\n'
			+ 'Expecting ' + expected + ' but was given ' + formatValue(received)
		);
	}

	function formatValue(value)
	{
		// Explicity format undefined values as "undefined"
		// because JSON.stringify(undefined) unhelpfully returns ""
		return (value === undefined) ? "undefined" : JSON.stringify(value);
	}


	// TO STRING

	var _Array;
	var Dict;
	var List;

	var toString = function(v)
	{
		var type = typeof v;
		if (type === 'function')
		{
			var name = v.func ? v.func.name : v.name;
			return '<function' + (name === '' ? '' : ': ') + name + '>';
		}
		else if (type === 'boolean')
		{
			return v ? 'True' : 'False';
		}
		else if (type === 'number')
		{
			return v + '';
		}
		else if ((v instanceof String) && v.isChar)
		{
			return '\'' + addSlashes(v, true) + '\'';
		}
		else if (type === 'string')
		{
			return '"' + addSlashes(v, false) + '"';
		}
		else if (type === 'object' && 'ctor' in v)
		{
			if (v.ctor.substring(0, 6) === '_Tuple')
			{
				var output = [];
				for (var k in v)
				{
					if (k === 'ctor') continue;
					output.push(toString(v[k]));
				}
				return '(' + output.join(',') + ')';
			}
			else if (v.ctor === '_Array')
			{
				if (!_Array)
				{
					_Array = Elm.Array.make(localRuntime);
				}
				var list = _Array.toList(v);
				return 'Array.fromList ' + toString(list);
			}
			else if (v.ctor === '::')
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
			else if (v.ctor === '[]')
			{
				return '[]';
			}
			else if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin' || v.ctor === 'Set_elm_builtin')
			{
				if (!Dict)
				{
					Dict = Elm.Dict.make(localRuntime);
				}
				var list;
				var name;
				if (v.ctor === 'Set_elm_builtin')
				{
					if (!List)
					{
						List = Elm.List.make(localRuntime);
					}
					name = 'Set';
					list = A2(List.map, function(x) {return x._0; }, Dict.toList(v._0));
				}
				else
				{
					name = 'Dict';
					list = Dict.toList(v);
				}
				return name + '.fromList ' + toString(list);
			}
			else if (v.ctor.slice(0, 5) === 'Text:')
			{
				return '<text>';
			}
			else if (v.ctor === 'Element_elm_builtin')
			{
				return '<element>'
			}
			else if (v.ctor === 'Form_elm_builtin')
			{
				return '<form>'
			}
			else
			{
				var output = '';
				for (var i in v)
				{
					if (i === 'ctor') continue;
					var str = toString(v[i]);
					var parenless = str[0] === '{' || str[0] === '<' || str.indexOf(' ') < 0;
					output += ' ' + (parenless ? str : '(' + str + ')');
				}
				return v.ctor + output;
			}
		}
		else if (type === 'object' && 'notify' in v && 'id' in v)
		{
			return '<signal>';
		}
		else if (type === 'object')
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
	};

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


	return localRuntime.Native.Utils.values = {
		eq: eq,
		cmp: cmp,
		compare: F2(compare),
		Tuple0: Tuple0,
		Tuple2: Tuple2,
		chr: chr,
		txt: txt,
		update: update,
		guid: guid,
		getXY: getXY,

		Nil: Nil,
		Cons: Cons,
		list: list,
		range: range,
		append: F2(append),

		crash: crash,
		crashCase: crashCase,
		badPort: badPort,

		toString: toString
	};
};

Elm.Basics = Elm.Basics || {};
Elm.Basics.make = function (_elm) {
   "use strict";
   _elm.Basics = _elm.Basics || {};
   if (_elm.Basics.values) return _elm.Basics.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Native$Basics = Elm.Native.Basics.make(_elm),
   $Native$Utils = Elm.Native.Utils.make(_elm);
   var _op = {};
   var uncurry = F2(function (f,_p0) {
      var _p1 = _p0;
      return A2(f,_p1._0,_p1._1);
   });
   var curry = F3(function (f,a,b) {
      return f({ctor: "_Tuple2",_0: a,_1: b});
   });
   var flip = F3(function (f,b,a) {    return A2(f,a,b);});
   var snd = function (_p2) {    var _p3 = _p2;return _p3._1;};
   var fst = function (_p4) {    var _p5 = _p4;return _p5._0;};
   var always = F2(function (a,_p6) {    return a;});
   var identity = function (x) {    return x;};
   _op["<|"] = F2(function (f,x) {    return f(x);});
   _op["|>"] = F2(function (x,f) {    return f(x);});
   _op[">>"] = F3(function (f,g,x) {    return g(f(x));});
   _op["<<"] = F3(function (g,f,x) {    return g(f(x));});
   _op["++"] = $Native$Utils.append;
   var toString = $Native$Utils.toString;
   var isInfinite = $Native$Basics.isInfinite;
   var isNaN = $Native$Basics.isNaN;
   var toFloat = $Native$Basics.toFloat;
   var ceiling = $Native$Basics.ceiling;
   var floor = $Native$Basics.floor;
   var truncate = $Native$Basics.truncate;
   var round = $Native$Basics.round;
   var not = $Native$Basics.not;
   var xor = $Native$Basics.xor;
   _op["||"] = $Native$Basics.or;
   _op["&&"] = $Native$Basics.and;
   var max = $Native$Basics.max;
   var min = $Native$Basics.min;
   var GT = {ctor: "GT"};
   var EQ = {ctor: "EQ"};
   var LT = {ctor: "LT"};
   var compare = $Native$Basics.compare;
   _op[">="] = $Native$Basics.ge;
   _op["<="] = $Native$Basics.le;
   _op[">"] = $Native$Basics.gt;
   _op["<"] = $Native$Basics.lt;
   _op["/="] = $Native$Basics.neq;
   _op["=="] = $Native$Basics.eq;
   var e = $Native$Basics.e;
   var pi = $Native$Basics.pi;
   var clamp = $Native$Basics.clamp;
   var logBase = $Native$Basics.logBase;
   var abs = $Native$Basics.abs;
   var negate = $Native$Basics.negate;
   var sqrt = $Native$Basics.sqrt;
   var atan2 = $Native$Basics.atan2;
   var atan = $Native$Basics.atan;
   var asin = $Native$Basics.asin;
   var acos = $Native$Basics.acos;
   var tan = $Native$Basics.tan;
   var sin = $Native$Basics.sin;
   var cos = $Native$Basics.cos;
   _op["^"] = $Native$Basics.exp;
   _op["%"] = $Native$Basics.mod;
   var rem = $Native$Basics.rem;
   _op["//"] = $Native$Basics.div;
   _op["/"] = $Native$Basics.floatDiv;
   _op["*"] = $Native$Basics.mul;
   _op["-"] = $Native$Basics.sub;
   _op["+"] = $Native$Basics.add;
   var toPolar = $Native$Basics.toPolar;
   var fromPolar = $Native$Basics.fromPolar;
   var turns = $Native$Basics.turns;
   var degrees = $Native$Basics.degrees;
   var radians = function (t) {    return t;};
   return _elm.Basics.values = {_op: _op
                               ,max: max
                               ,min: min
                               ,compare: compare
                               ,not: not
                               ,xor: xor
                               ,rem: rem
                               ,negate: negate
                               ,abs: abs
                               ,sqrt: sqrt
                               ,clamp: clamp
                               ,logBase: logBase
                               ,e: e
                               ,pi: pi
                               ,cos: cos
                               ,sin: sin
                               ,tan: tan
                               ,acos: acos
                               ,asin: asin
                               ,atan: atan
                               ,atan2: atan2
                               ,round: round
                               ,floor: floor
                               ,ceiling: ceiling
                               ,truncate: truncate
                               ,toFloat: toFloat
                               ,degrees: degrees
                               ,radians: radians
                               ,turns: turns
                               ,toPolar: toPolar
                               ,fromPolar: fromPolar
                               ,isNaN: isNaN
                               ,isInfinite: isInfinite
                               ,toString: toString
                               ,fst: fst
                               ,snd: snd
                               ,identity: identity
                               ,always: always
                               ,flip: flip
                               ,curry: curry
                               ,uncurry: uncurry
                               ,LT: LT
                               ,EQ: EQ
                               ,GT: GT};
};
Elm.Maybe = Elm.Maybe || {};
Elm.Maybe.make = function (_elm) {
   "use strict";
   _elm.Maybe = _elm.Maybe || {};
   if (_elm.Maybe.values) return _elm.Maybe.values;
   var _U = Elm.Native.Utils.make(_elm);
   var _op = {};
   var withDefault = F2(function ($default,maybe) {
      var _p0 = maybe;
      if (_p0.ctor === "Just") {
            return _p0._0;
         } else {
            return $default;
         }
   });
   var Nothing = {ctor: "Nothing"};
   var oneOf = function (maybes) {
      oneOf: while (true) {
         var _p1 = maybes;
         if (_p1.ctor === "[]") {
               return Nothing;
            } else {
               var _p3 = _p1._0;
               var _p2 = _p3;
               if (_p2.ctor === "Nothing") {
                     var _v3 = _p1._1;
                     maybes = _v3;
                     continue oneOf;
                  } else {
                     return _p3;
                  }
            }
      }
   };
   var andThen = F2(function (maybeValue,callback) {
      var _p4 = maybeValue;
      if (_p4.ctor === "Just") {
            return callback(_p4._0);
         } else {
            return Nothing;
         }
   });
   var Just = function (a) {    return {ctor: "Just",_0: a};};
   var map = F2(function (f,maybe) {
      var _p5 = maybe;
      if (_p5.ctor === "Just") {
            return Just(f(_p5._0));
         } else {
            return Nothing;
         }
   });
   var map2 = F3(function (func,ma,mb) {
      var _p6 = {ctor: "_Tuple2",_0: ma,_1: mb};
      if (_p6.ctor === "_Tuple2" && _p6._0.ctor === "Just" && _p6._1.ctor === "Just")
      {
            return Just(A2(func,_p6._0._0,_p6._1._0));
         } else {
            return Nothing;
         }
   });
   var map3 = F4(function (func,ma,mb,mc) {
      var _p7 = {ctor: "_Tuple3",_0: ma,_1: mb,_2: mc};
      if (_p7.ctor === "_Tuple3" && _p7._0.ctor === "Just" && _p7._1.ctor === "Just" && _p7._2.ctor === "Just")
      {
            return Just(A3(func,_p7._0._0,_p7._1._0,_p7._2._0));
         } else {
            return Nothing;
         }
   });
   var map4 = F5(function (func,ma,mb,mc,md) {
      var _p8 = {ctor: "_Tuple4",_0: ma,_1: mb,_2: mc,_3: md};
      if (_p8.ctor === "_Tuple4" && _p8._0.ctor === "Just" && _p8._1.ctor === "Just" && _p8._2.ctor === "Just" && _p8._3.ctor === "Just")
      {
            return Just(A4(func,
            _p8._0._0,
            _p8._1._0,
            _p8._2._0,
            _p8._3._0));
         } else {
            return Nothing;
         }
   });
   var map5 = F6(function (func,ma,mb,mc,md,me) {
      var _p9 = {ctor: "_Tuple5"
                ,_0: ma
                ,_1: mb
                ,_2: mc
                ,_3: md
                ,_4: me};
      if (_p9.ctor === "_Tuple5" && _p9._0.ctor === "Just" && _p9._1.ctor === "Just" && _p9._2.ctor === "Just" && _p9._3.ctor === "Just" && _p9._4.ctor === "Just")
      {
            return Just(A5(func,
            _p9._0._0,
            _p9._1._0,
            _p9._2._0,
            _p9._3._0,
            _p9._4._0));
         } else {
            return Nothing;
         }
   });
   return _elm.Maybe.values = {_op: _op
                              ,andThen: andThen
                              ,map: map
                              ,map2: map2
                              ,map3: map3
                              ,map4: map4
                              ,map5: map5
                              ,withDefault: withDefault
                              ,oneOf: oneOf
                              ,Just: Just
                              ,Nothing: Nothing};
};
Elm.Native.List = {};
Elm.Native.List.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.List = localRuntime.Native.List || {};
	if (localRuntime.Native.List.values)
	{
		return localRuntime.Native.List.values;
	}
	if ('values' in Elm.Native.List)
	{
		return localRuntime.Native.List.values = Elm.Native.List.values;
	}

	var Utils = Elm.Native.Utils.make(localRuntime);

	var Nil = Utils.Nil;
	var Cons = Utils.Cons;

	var fromArray = Utils.list;

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

	// f defined similarly for both foldl and foldr (NB: different from Haskell)
	// ie, foldl : (a -> b -> b) -> b -> [a] -> b
	function foldl(f, b, xs)
	{
		var acc = b;
		while (xs.ctor !== '[]')
		{
			acc = A2(f, xs._0, acc);
			xs = xs._1;
		}
		return acc;
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
			return Utils.cmp(f(a), f(b));
		}));
	}

	function sortWith(f, xs)
	{
		return fromArray(toArray(xs).sort(function(a, b) {
			var ord = f(a)(b).ctor;
			return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
		}));
	}

	function take(n, xs)
	{
		var arr = [];
		while (xs.ctor !== '[]' && n > 0)
		{
			arr.push(xs._0);
			xs = xs._1;
			--n;
		}
		return fromArray(arr);
	}


	Elm.Native.List.values = {
		Nil: Nil,
		Cons: Cons,
		cons: F2(Cons),
		toArray: toArray,
		fromArray: fromArray,

		foldl: F3(foldl),
		foldr: F3(foldr),

		map2: F3(map2),
		map3: F4(map3),
		map4: F5(map4),
		map5: F6(map5),
		sortBy: F2(sortBy),
		sortWith: F2(sortWith),
		take: F2(take)
	};
	return localRuntime.Native.List.values = Elm.Native.List.values;
};

Elm.List = Elm.List || {};
Elm.List.make = function (_elm) {
   "use strict";
   _elm.List = _elm.List || {};
   if (_elm.List.values) return _elm.List.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$List = Elm.Native.List.make(_elm);
   var _op = {};
   var sortWith = $Native$List.sortWith;
   var sortBy = $Native$List.sortBy;
   var sort = function (xs) {
      return A2(sortBy,$Basics.identity,xs);
   };
   var drop = F2(function (n,list) {
      drop: while (true) if (_U.cmp(n,0) < 1) return list; else {
            var _p0 = list;
            if (_p0.ctor === "[]") {
                  return list;
               } else {
                  var _v1 = n - 1,_v2 = _p0._1;
                  n = _v1;
                  list = _v2;
                  continue drop;
               }
         }
   });
   var take = $Native$List.take;
   var map5 = $Native$List.map5;
   var map4 = $Native$List.map4;
   var map3 = $Native$List.map3;
   var map2 = $Native$List.map2;
   var any = F2(function (isOkay,list) {
      any: while (true) {
         var _p1 = list;
         if (_p1.ctor === "[]") {
               return false;
            } else {
               if (isOkay(_p1._0)) return true; else {
                     var _v4 = isOkay,_v5 = _p1._1;
                     isOkay = _v4;
                     list = _v5;
                     continue any;
                  }
            }
      }
   });
   var all = F2(function (isOkay,list) {
      return $Basics.not(A2(any,
      function (_p2) {
         return $Basics.not(isOkay(_p2));
      },
      list));
   });
   var foldr = $Native$List.foldr;
   var foldl = $Native$List.foldl;
   var length = function (xs) {
      return A3(foldl,
      F2(function (_p3,i) {    return i + 1;}),
      0,
      xs);
   };
   var sum = function (numbers) {
      return A3(foldl,
      F2(function (x,y) {    return x + y;}),
      0,
      numbers);
   };
   var product = function (numbers) {
      return A3(foldl,
      F2(function (x,y) {    return x * y;}),
      1,
      numbers);
   };
   var maximum = function (list) {
      var _p4 = list;
      if (_p4.ctor === "::") {
            return $Maybe.Just(A3(foldl,$Basics.max,_p4._0,_p4._1));
         } else {
            return $Maybe.Nothing;
         }
   };
   var minimum = function (list) {
      var _p5 = list;
      if (_p5.ctor === "::") {
            return $Maybe.Just(A3(foldl,$Basics.min,_p5._0,_p5._1));
         } else {
            return $Maybe.Nothing;
         }
   };
   var indexedMap = F2(function (f,xs) {
      return A3(map2,f,_U.range(0,length(xs) - 1),xs);
   });
   var member = F2(function (x,xs) {
      return A2(any,function (a) {    return _U.eq(a,x);},xs);
   });
   var isEmpty = function (xs) {
      var _p6 = xs;
      if (_p6.ctor === "[]") {
            return true;
         } else {
            return false;
         }
   };
   var tail = function (list) {
      var _p7 = list;
      if (_p7.ctor === "::") {
            return $Maybe.Just(_p7._1);
         } else {
            return $Maybe.Nothing;
         }
   };
   var head = function (list) {
      var _p8 = list;
      if (_p8.ctor === "::") {
            return $Maybe.Just(_p8._0);
         } else {
            return $Maybe.Nothing;
         }
   };
   _op["::"] = $Native$List.cons;
   var map = F2(function (f,xs) {
      return A3(foldr,
      F2(function (x,acc) {    return A2(_op["::"],f(x),acc);}),
      _U.list([]),
      xs);
   });
   var filter = F2(function (pred,xs) {
      var conditionalCons = F2(function (x,xs$) {
         return pred(x) ? A2(_op["::"],x,xs$) : xs$;
      });
      return A3(foldr,conditionalCons,_U.list([]),xs);
   });
   var maybeCons = F3(function (f,mx,xs) {
      var _p9 = f(mx);
      if (_p9.ctor === "Just") {
            return A2(_op["::"],_p9._0,xs);
         } else {
            return xs;
         }
   });
   var filterMap = F2(function (f,xs) {
      return A3(foldr,maybeCons(f),_U.list([]),xs);
   });
   var reverse = function (list) {
      return A3(foldl,
      F2(function (x,y) {    return A2(_op["::"],x,y);}),
      _U.list([]),
      list);
   };
   var scanl = F3(function (f,b,xs) {
      var scan1 = F2(function (x,accAcc) {
         var _p10 = accAcc;
         if (_p10.ctor === "::") {
               return A2(_op["::"],A2(f,x,_p10._0),accAcc);
            } else {
               return _U.list([]);
            }
      });
      return reverse(A3(foldl,scan1,_U.list([b]),xs));
   });
   var append = F2(function (xs,ys) {
      var _p11 = ys;
      if (_p11.ctor === "[]") {
            return xs;
         } else {
            return A3(foldr,
            F2(function (x,y) {    return A2(_op["::"],x,y);}),
            ys,
            xs);
         }
   });
   var concat = function (lists) {
      return A3(foldr,append,_U.list([]),lists);
   };
   var concatMap = F2(function (f,list) {
      return concat(A2(map,f,list));
   });
   var partition = F2(function (pred,list) {
      var step = F2(function (x,_p12) {
         var _p13 = _p12;
         var _p15 = _p13._0;
         var _p14 = _p13._1;
         return pred(x) ? {ctor: "_Tuple2"
                          ,_0: A2(_op["::"],x,_p15)
                          ,_1: _p14} : {ctor: "_Tuple2"
                                       ,_0: _p15
                                       ,_1: A2(_op["::"],x,_p14)};
      });
      return A3(foldr,
      step,
      {ctor: "_Tuple2",_0: _U.list([]),_1: _U.list([])},
      list);
   });
   var unzip = function (pairs) {
      var step = F2(function (_p17,_p16) {
         var _p18 = _p17;
         var _p19 = _p16;
         return {ctor: "_Tuple2"
                ,_0: A2(_op["::"],_p18._0,_p19._0)
                ,_1: A2(_op["::"],_p18._1,_p19._1)};
      });
      return A3(foldr,
      step,
      {ctor: "_Tuple2",_0: _U.list([]),_1: _U.list([])},
      pairs);
   };
   var intersperse = F2(function (sep,xs) {
      var _p20 = xs;
      if (_p20.ctor === "[]") {
            return _U.list([]);
         } else {
            var step = F2(function (x,rest) {
               return A2(_op["::"],sep,A2(_op["::"],x,rest));
            });
            var spersed = A3(foldr,step,_U.list([]),_p20._1);
            return A2(_op["::"],_p20._0,spersed);
         }
   });
   var repeatHelp = F3(function (result,n,value) {
      repeatHelp: while (true) if (_U.cmp(n,0) < 1) return result;
      else {
            var _v18 = A2(_op["::"],value,result),
            _v19 = n - 1,
            _v20 = value;
            result = _v18;
            n = _v19;
            value = _v20;
            continue repeatHelp;
         }
   });
   var repeat = F2(function (n,value) {
      return A3(repeatHelp,_U.list([]),n,value);
   });
   return _elm.List.values = {_op: _op
                             ,isEmpty: isEmpty
                             ,length: length
                             ,reverse: reverse
                             ,member: member
                             ,head: head
                             ,tail: tail
                             ,filter: filter
                             ,take: take
                             ,drop: drop
                             ,repeat: repeat
                             ,append: append
                             ,concat: concat
                             ,intersperse: intersperse
                             ,partition: partition
                             ,unzip: unzip
                             ,map: map
                             ,map2: map2
                             ,map3: map3
                             ,map4: map4
                             ,map5: map5
                             ,filterMap: filterMap
                             ,concatMap: concatMap
                             ,indexedMap: indexedMap
                             ,foldr: foldr
                             ,foldl: foldl
                             ,sum: sum
                             ,product: product
                             ,maximum: maximum
                             ,minimum: minimum
                             ,all: all
                             ,any: any
                             ,scanl: scanl
                             ,sort: sort
                             ,sortBy: sortBy
                             ,sortWith: sortWith};
};
Elm.Array = Elm.Array || {};
Elm.Array.make = function (_elm) {
   "use strict";
   _elm.Array = _elm.Array || {};
   if (_elm.Array.values) return _elm.Array.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Array = Elm.Native.Array.make(_elm);
   var _op = {};
   var append = $Native$Array.append;
   var length = $Native$Array.length;
   var isEmpty = function (array) {
      return _U.eq(length(array),0);
   };
   var slice = $Native$Array.slice;
   var set = $Native$Array.set;
   var get = F2(function (i,array) {
      return _U.cmp(0,i) < 1 && _U.cmp(i,
      $Native$Array.length(array)) < 0 ? $Maybe.Just(A2($Native$Array.get,
      i,
      array)) : $Maybe.Nothing;
   });
   var push = $Native$Array.push;
   var empty = $Native$Array.empty;
   var filter = F2(function (isOkay,arr) {
      var update = F2(function (x,xs) {
         return isOkay(x) ? A2($Native$Array.push,x,xs) : xs;
      });
      return A3($Native$Array.foldl,update,$Native$Array.empty,arr);
   });
   var foldr = $Native$Array.foldr;
   var foldl = $Native$Array.foldl;
   var indexedMap = $Native$Array.indexedMap;
   var map = $Native$Array.map;
   var toIndexedList = function (array) {
      return A3($List.map2,
      F2(function (v0,v1) {
         return {ctor: "_Tuple2",_0: v0,_1: v1};
      }),
      _U.range(0,$Native$Array.length(array) - 1),
      $Native$Array.toList(array));
   };
   var toList = $Native$Array.toList;
   var fromList = $Native$Array.fromList;
   var initialize = $Native$Array.initialize;
   var repeat = F2(function (n,e) {
      return A2(initialize,n,$Basics.always(e));
   });
   var Array = {ctor: "Array"};
   return _elm.Array.values = {_op: _op
                              ,empty: empty
                              ,repeat: repeat
                              ,initialize: initialize
                              ,fromList: fromList
                              ,isEmpty: isEmpty
                              ,length: length
                              ,push: push
                              ,append: append
                              ,get: get
                              ,set: set
                              ,slice: slice
                              ,toList: toList
                              ,toIndexedList: toIndexedList
                              ,map: map
                              ,indexedMap: indexedMap
                              ,filter: filter
                              ,foldl: foldl
                              ,foldr: foldr};
};
Elm.Native.Bitwise = {};
Elm.Native.Bitwise.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Bitwise = localRuntime.Native.Bitwise || {};
	if (localRuntime.Native.Bitwise.values)
	{
		return localRuntime.Native.Bitwise.values;
	}

	function and(a, b) { return a & b; }
	function or(a, b) { return a | b; }
	function xor(a, b) { return a ^ b; }
	function not(a) { return ~a; }
	function sll(a, offset) { return a << offset; }
	function sra(a, offset) { return a >> offset; }
	function srl(a, offset) { return a >>> offset; }

	return localRuntime.Native.Bitwise.values = {
		and: F2(and),
		or: F2(or),
		xor: F2(xor),
		complement: not,
		shiftLeft: F2(sll),
		shiftRightArithmatic: F2(sra),
		shiftRightLogical: F2(srl)
	};
};

Elm.Bitwise = Elm.Bitwise || {};
Elm.Bitwise.make = function (_elm) {
   "use strict";
   _elm.Bitwise = _elm.Bitwise || {};
   if (_elm.Bitwise.values) return _elm.Bitwise.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Native$Bitwise = Elm.Native.Bitwise.make(_elm);
   var _op = {};
   var shiftRightLogical = $Native$Bitwise.shiftRightLogical;
   var shiftRight = $Native$Bitwise.shiftRightArithmatic;
   var shiftLeft = $Native$Bitwise.shiftLeft;
   var complement = $Native$Bitwise.complement;
   var xor = $Native$Bitwise.xor;
   var or = $Native$Bitwise.or;
   var and = $Native$Bitwise.and;
   return _elm.Bitwise.values = {_op: _op
                                ,and: and
                                ,or: or
                                ,xor: xor
                                ,complement: complement
                                ,shiftLeft: shiftLeft
                                ,shiftRight: shiftRight
                                ,shiftRightLogical: shiftRightLogical};
};
Elm.Native.Char = {};
Elm.Native.Char.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Char = localRuntime.Native.Char || {};
	if (localRuntime.Native.Char.values)
	{
		return localRuntime.Native.Char.values;
	}

	var Utils = Elm.Native.Utils.make(localRuntime);

	return localRuntime.Native.Char.values = {
		fromCode: function(c) { return Utils.chr(String.fromCharCode(c)); },
		toCode: function(c) { return c.charCodeAt(0); },
		toUpper: function(c) { return Utils.chr(c.toUpperCase()); },
		toLower: function(c) { return Utils.chr(c.toLowerCase()); },
		toLocaleUpper: function(c) { return Utils.chr(c.toLocaleUpperCase()); },
		toLocaleLower: function(c) { return Utils.chr(c.toLocaleLowerCase()); }
	};
};

Elm.Char = Elm.Char || {};
Elm.Char.make = function (_elm) {
   "use strict";
   _elm.Char = _elm.Char || {};
   if (_elm.Char.values) return _elm.Char.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Native$Char = Elm.Native.Char.make(_elm);
   var _op = {};
   var fromCode = $Native$Char.fromCode;
   var toCode = $Native$Char.toCode;
   var toLocaleLower = $Native$Char.toLocaleLower;
   var toLocaleUpper = $Native$Char.toLocaleUpper;
   var toLower = $Native$Char.toLower;
   var toUpper = $Native$Char.toUpper;
   var isBetween = F3(function (low,high,$char) {
      var code = toCode($char);
      return _U.cmp(code,toCode(low)) > -1 && _U.cmp(code,
      toCode(high)) < 1;
   });
   var isUpper = A2(isBetween,_U.chr("A"),_U.chr("Z"));
   var isLower = A2(isBetween,_U.chr("a"),_U.chr("z"));
   var isDigit = A2(isBetween,_U.chr("0"),_U.chr("9"));
   var isOctDigit = A2(isBetween,_U.chr("0"),_U.chr("7"));
   var isHexDigit = function ($char) {
      return isDigit($char) || (A3(isBetween,
      _U.chr("a"),
      _U.chr("f"),
      $char) || A3(isBetween,_U.chr("A"),_U.chr("F"),$char));
   };
   return _elm.Char.values = {_op: _op
                             ,isUpper: isUpper
                             ,isLower: isLower
                             ,isDigit: isDigit
                             ,isOctDigit: isOctDigit
                             ,isHexDigit: isHexDigit
                             ,toUpper: toUpper
                             ,toLower: toLower
                             ,toLocaleUpper: toLocaleUpper
                             ,toLocaleLower: toLocaleLower
                             ,toCode: toCode
                             ,fromCode: fromCode};
};
Elm.Native.Color = {};
Elm.Native.Color.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Color = localRuntime.Native.Color || {};
	if (localRuntime.Native.Color.values)
	{
		return localRuntime.Native.Color.values;
	}

	function toCss(c)
	{
		var format = '';
		var colors = '';
		if (c.ctor === 'RGBA')
		{
			format = 'rgb';
			colors = c._0 + ', ' + c._1 + ', ' + c._2;
		}
		else
		{
			format = 'hsl';
			colors = (c._0 * 180 / Math.PI) + ', ' +
					 (c._1 * 100) + '%, ' +
					 (c._2 * 100) + '%';
		}
		if (c._3 === 1)
		{
			return format + '(' + colors + ')';
		}
		else
		{
			return format + 'a(' + colors + ', ' + c._3 + ')';
		}
	}

	return localRuntime.Native.Color.values = {
		toCss: toCss
	};
};

Elm.Color = Elm.Color || {};
Elm.Color.make = function (_elm) {
   "use strict";
   _elm.Color = _elm.Color || {};
   if (_elm.Color.values) return _elm.Color.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm);
   var _op = {};
   var Radial = F5(function (a,b,c,d,e) {
      return {ctor: "Radial",_0: a,_1: b,_2: c,_3: d,_4: e};
   });
   var radial = Radial;
   var Linear = F3(function (a,b,c) {
      return {ctor: "Linear",_0: a,_1: b,_2: c};
   });
   var linear = Linear;
   var fmod = F2(function (f,n) {
      var integer = $Basics.floor(f);
      return $Basics.toFloat(A2($Basics._op["%"],
      integer,
      n)) + f - $Basics.toFloat(integer);
   });
   var rgbToHsl = F3(function (red,green,blue) {
      var b = $Basics.toFloat(blue) / 255;
      var g = $Basics.toFloat(green) / 255;
      var r = $Basics.toFloat(red) / 255;
      var cMax = A2($Basics.max,A2($Basics.max,r,g),b);
      var cMin = A2($Basics.min,A2($Basics.min,r,g),b);
      var c = cMax - cMin;
      var lightness = (cMax + cMin) / 2;
      var saturation = _U.eq(lightness,
      0) ? 0 : c / (1 - $Basics.abs(2 * lightness - 1));
      var hue = $Basics.degrees(60) * (_U.eq(cMax,r) ? A2(fmod,
      (g - b) / c,
      6) : _U.eq(cMax,g) ? (b - r) / c + 2 : (r - g) / c + 4);
      return {ctor: "_Tuple3",_0: hue,_1: saturation,_2: lightness};
   });
   var hslToRgb = F3(function (hue,saturation,lightness) {
      var hue$ = hue / $Basics.degrees(60);
      var chroma = (1 - $Basics.abs(2 * lightness - 1)) * saturation;
      var x = chroma * (1 - $Basics.abs(A2(fmod,hue$,2) - 1));
      var _p0 = _U.cmp(hue$,0) < 0 ? {ctor: "_Tuple3"
                                     ,_0: 0
                                     ,_1: 0
                                     ,_2: 0} : _U.cmp(hue$,1) < 0 ? {ctor: "_Tuple3"
                                                                    ,_0: chroma
                                                                    ,_1: x
                                                                    ,_2: 0} : _U.cmp(hue$,2) < 0 ? {ctor: "_Tuple3"
                                                                                                   ,_0: x
                                                                                                   ,_1: chroma
                                                                                                   ,_2: 0} : _U.cmp(hue$,3) < 0 ? {ctor: "_Tuple3"
                                                                                                                                  ,_0: 0
                                                                                                                                  ,_1: chroma
                                                                                                                                  ,_2: x} : _U.cmp(hue$,
      4) < 0 ? {ctor: "_Tuple3",_0: 0,_1: x,_2: chroma} : _U.cmp(hue$,
      5) < 0 ? {ctor: "_Tuple3",_0: x,_1: 0,_2: chroma} : _U.cmp(hue$,
      6) < 0 ? {ctor: "_Tuple3"
               ,_0: chroma
               ,_1: 0
               ,_2: x} : {ctor: "_Tuple3",_0: 0,_1: 0,_2: 0};
      var r = _p0._0;
      var g = _p0._1;
      var b = _p0._2;
      var m = lightness - chroma / 2;
      return {ctor: "_Tuple3",_0: r + m,_1: g + m,_2: b + m};
   });
   var toRgb = function (color) {
      var _p1 = color;
      if (_p1.ctor === "RGBA") {
            return {red: _p1._0
                   ,green: _p1._1
                   ,blue: _p1._2
                   ,alpha: _p1._3};
         } else {
            var _p2 = A3(hslToRgb,_p1._0,_p1._1,_p1._2);
            var r = _p2._0;
            var g = _p2._1;
            var b = _p2._2;
            return {red: $Basics.round(255 * r)
                   ,green: $Basics.round(255 * g)
                   ,blue: $Basics.round(255 * b)
                   ,alpha: _p1._3};
         }
   };
   var toHsl = function (color) {
      var _p3 = color;
      if (_p3.ctor === "HSLA") {
            return {hue: _p3._0
                   ,saturation: _p3._1
                   ,lightness: _p3._2
                   ,alpha: _p3._3};
         } else {
            var _p4 = A3(rgbToHsl,_p3._0,_p3._1,_p3._2);
            var h = _p4._0;
            var s = _p4._1;
            var l = _p4._2;
            return {hue: h,saturation: s,lightness: l,alpha: _p3._3};
         }
   };
   var HSLA = F4(function (a,b,c,d) {
      return {ctor: "HSLA",_0: a,_1: b,_2: c,_3: d};
   });
   var hsla = F4(function (hue,saturation,lightness,alpha) {
      return A4(HSLA,
      hue - $Basics.turns($Basics.toFloat($Basics.floor(hue / (2 * $Basics.pi)))),
      saturation,
      lightness,
      alpha);
   });
   var hsl = F3(function (hue,saturation,lightness) {
      return A4(hsla,hue,saturation,lightness,1);
   });
   var complement = function (color) {
      var _p5 = color;
      if (_p5.ctor === "HSLA") {
            return A4(hsla,
            _p5._0 + $Basics.degrees(180),
            _p5._1,
            _p5._2,
            _p5._3);
         } else {
            var _p6 = A3(rgbToHsl,_p5._0,_p5._1,_p5._2);
            var h = _p6._0;
            var s = _p6._1;
            var l = _p6._2;
            return A4(hsla,h + $Basics.degrees(180),s,l,_p5._3);
         }
   };
   var grayscale = function (p) {    return A4(HSLA,0,0,1 - p,1);};
   var greyscale = function (p) {    return A4(HSLA,0,0,1 - p,1);};
   var RGBA = F4(function (a,b,c,d) {
      return {ctor: "RGBA",_0: a,_1: b,_2: c,_3: d};
   });
   var rgba = RGBA;
   var rgb = F3(function (r,g,b) {    return A4(RGBA,r,g,b,1);});
   var lightRed = A4(RGBA,239,41,41,1);
   var red = A4(RGBA,204,0,0,1);
   var darkRed = A4(RGBA,164,0,0,1);
   var lightOrange = A4(RGBA,252,175,62,1);
   var orange = A4(RGBA,245,121,0,1);
   var darkOrange = A4(RGBA,206,92,0,1);
   var lightYellow = A4(RGBA,255,233,79,1);
   var yellow = A4(RGBA,237,212,0,1);
   var darkYellow = A4(RGBA,196,160,0,1);
   var lightGreen = A4(RGBA,138,226,52,1);
   var green = A4(RGBA,115,210,22,1);
   var darkGreen = A4(RGBA,78,154,6,1);
   var lightBlue = A4(RGBA,114,159,207,1);
   var blue = A4(RGBA,52,101,164,1);
   var darkBlue = A4(RGBA,32,74,135,1);
   var lightPurple = A4(RGBA,173,127,168,1);
   var purple = A4(RGBA,117,80,123,1);
   var darkPurple = A4(RGBA,92,53,102,1);
   var lightBrown = A4(RGBA,233,185,110,1);
   var brown = A4(RGBA,193,125,17,1);
   var darkBrown = A4(RGBA,143,89,2,1);
   var black = A4(RGBA,0,0,0,1);
   var white = A4(RGBA,255,255,255,1);
   var lightGrey = A4(RGBA,238,238,236,1);
   var grey = A4(RGBA,211,215,207,1);
   var darkGrey = A4(RGBA,186,189,182,1);
   var lightGray = A4(RGBA,238,238,236,1);
   var gray = A4(RGBA,211,215,207,1);
   var darkGray = A4(RGBA,186,189,182,1);
   var lightCharcoal = A4(RGBA,136,138,133,1);
   var charcoal = A4(RGBA,85,87,83,1);
   var darkCharcoal = A4(RGBA,46,52,54,1);
   return _elm.Color.values = {_op: _op
                              ,rgb: rgb
                              ,rgba: rgba
                              ,hsl: hsl
                              ,hsla: hsla
                              ,greyscale: greyscale
                              ,grayscale: grayscale
                              ,complement: complement
                              ,linear: linear
                              ,radial: radial
                              ,toRgb: toRgb
                              ,toHsl: toHsl
                              ,red: red
                              ,orange: orange
                              ,yellow: yellow
                              ,green: green
                              ,blue: blue
                              ,purple: purple
                              ,brown: brown
                              ,lightRed: lightRed
                              ,lightOrange: lightOrange
                              ,lightYellow: lightYellow
                              ,lightGreen: lightGreen
                              ,lightBlue: lightBlue
                              ,lightPurple: lightPurple
                              ,lightBrown: lightBrown
                              ,darkRed: darkRed
                              ,darkOrange: darkOrange
                              ,darkYellow: darkYellow
                              ,darkGreen: darkGreen
                              ,darkBlue: darkBlue
                              ,darkPurple: darkPurple
                              ,darkBrown: darkBrown
                              ,white: white
                              ,lightGrey: lightGrey
                              ,grey: grey
                              ,darkGrey: darkGrey
                              ,lightCharcoal: lightCharcoal
                              ,charcoal: charcoal
                              ,darkCharcoal: darkCharcoal
                              ,black: black
                              ,lightGray: lightGray
                              ,gray: gray
                              ,darkGray: darkGray};
};
Elm.Native.Signal = {};

Elm.Native.Signal.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Signal = localRuntime.Native.Signal || {};
	if (localRuntime.Native.Signal.values)
	{
		return localRuntime.Native.Signal.values;
	}


	var Task = Elm.Native.Task.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);


	function broadcastToKids(node, timestamp, update)
	{
		var kids = node.kids;
		for (var i = kids.length; i--; )
		{
			kids[i].notify(timestamp, update, node.id);
		}
	}


	// INPUT

	function input(name, base)
	{
		var node = {
			id: Utils.guid(),
			name: 'input-' + name,
			value: base,
			parents: [],
			kids: []
		};

		node.notify = function(timestamp, targetId, value) {
			var update = targetId === node.id;
			if (update)
			{
				node.value = value;
			}
			broadcastToKids(node, timestamp, update);
			return update;
		};

		localRuntime.inputs.push(node);

		return node;
	}

	function constant(value)
	{
		return input('constant', value);
	}


	// MAILBOX

	function mailbox(base)
	{
		var signal = input('mailbox', base);

		function send(value) {
			return Task.asyncFunction(function(callback) {
				localRuntime.setTimeout(function() {
					localRuntime.notify(signal.id, value);
				}, 0);
				callback(Task.succeed(Utils.Tuple0));
			});
		}

		return {
			signal: signal,
			address: {
				ctor: 'Address',
				_0: send
			}
		};
	}

	function sendMessage(message)
	{
		Task.perform(message._0);
	}


	// OUTPUT

	function output(name, handler, parent)
	{
		var node = {
			id: Utils.guid(),
			name: 'output-' + name,
			parents: [parent],
			isOutput: true
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				handler(parent.value);
			}
		};

		parent.kids.push(node);

		return node;
	}


	// MAP

	function mapMany(refreshValue, args)
	{
		var node = {
			id: Utils.guid(),
			name: 'map' + args.length,
			value: refreshValue(),
			parents: args,
			kids: []
		};

		var numberOfParents = args.length;
		var count = 0;
		var update = false;

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			++count;

			update = update || parentUpdate;

			if (count === numberOfParents)
			{
				if (update)
				{
					node.value = refreshValue();
				}
				broadcastToKids(node, timestamp, update);
				update = false;
				count = 0;
			}
		};

		for (var i = numberOfParents; i--; )
		{
			args[i].kids.push(node);
		}

		return node;
	}


	function map(func, a)
	{
		function refreshValue()
		{
			return func(a.value);
		}
		return mapMany(refreshValue, [a]);
	}


	function map2(func, a, b)
	{
		function refreshValue()
		{
			return A2( func, a.value, b.value );
		}
		return mapMany(refreshValue, [a, b]);
	}


	function map3(func, a, b, c)
	{
		function refreshValue()
		{
			return A3( func, a.value, b.value, c.value );
		}
		return mapMany(refreshValue, [a, b, c]);
	}


	function map4(func, a, b, c, d)
	{
		function refreshValue()
		{
			return A4( func, a.value, b.value, c.value, d.value );
		}
		return mapMany(refreshValue, [a, b, c, d]);
	}


	function map5(func, a, b, c, d, e)
	{
		function refreshValue()
		{
			return A5( func, a.value, b.value, c.value, d.value, e.value );
		}
		return mapMany(refreshValue, [a, b, c, d, e]);
	}


	// FOLD

	function foldp(update, state, signal)
	{
		var node = {
			id: Utils.guid(),
			name: 'foldp',
			parents: [signal],
			kids: [],
			value: state
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = A2( update, signal.value, node.value );
			}
			broadcastToKids(node, timestamp, parentUpdate);
		};

		signal.kids.push(node);

		return node;
	}


	// TIME

	function timestamp(signal)
	{
		var node = {
			id: Utils.guid(),
			name: 'timestamp',
			value: Utils.Tuple2(localRuntime.timer.programStart, signal.value),
			parents: [signal],
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = Utils.Tuple2(timestamp, signal.value);
			}
			broadcastToKids(node, timestamp, parentUpdate);
		};

		signal.kids.push(node);

		return node;
	}


	function delay(time, signal)
	{
		var delayed = input('delay-input-' + time, signal.value);

		function handler(value)
		{
			setTimeout(function() {
				localRuntime.notify(delayed.id, value);
			}, time);
		}

		output('delay-output-' + time, handler, signal);

		return delayed;
	}


	// MERGING

	function genericMerge(tieBreaker, leftStream, rightStream)
	{
		var node = {
			id: Utils.guid(),
			name: 'merge',
			value: A2(tieBreaker, leftStream.value, rightStream.value),
			parents: [leftStream, rightStream],
			kids: []
		};

		var left = { touched: false, update: false, value: null };
		var right = { touched: false, update: false, value: null };

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentID === leftStream.id)
			{
				left.touched = true;
				left.update = parentUpdate;
				left.value = leftStream.value;
			}
			if (parentID === rightStream.id)
			{
				right.touched = true;
				right.update = parentUpdate;
				right.value = rightStream.value;
			}

			if (left.touched && right.touched)
			{
				var update = false;
				if (left.update && right.update)
				{
					node.value = A2(tieBreaker, left.value, right.value);
					update = true;
				}
				else if (left.update)
				{
					node.value = left.value;
					update = true;
				}
				else if (right.update)
				{
					node.value = right.value;
					update = true;
				}
				left.touched = false;
				right.touched = false;

				broadcastToKids(node, timestamp, update);
			}
		};

		leftStream.kids.push(node);
		rightStream.kids.push(node);

		return node;
	}


	// FILTERING

	function filterMap(toMaybe, base, signal)
	{
		var maybe = toMaybe(signal.value);
		var node = {
			id: Utils.guid(),
			name: 'filterMap',
			value: maybe.ctor === 'Nothing' ? base : maybe._0,
			parents: [signal],
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			var update = false;
			if (parentUpdate)
			{
				var maybe = toMaybe(signal.value);
				if (maybe.ctor === 'Just')
				{
					update = true;
					node.value = maybe._0;
				}
			}
			broadcastToKids(node, timestamp, update);
		};

		signal.kids.push(node);

		return node;
	}


	// SAMPLING

	function sampleOn(ticker, signal)
	{
		var node = {
			id: Utils.guid(),
			name: 'sampleOn',
			value: signal.value,
			parents: [ticker, signal],
			kids: []
		};

		var signalTouch = false;
		var tickerTouch = false;
		var tickerUpdate = false;

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentID === ticker.id)
			{
				tickerTouch = true;
				tickerUpdate = parentUpdate;
			}
			if (parentID === signal.id)
			{
				signalTouch = true;
			}

			if (tickerTouch && signalTouch)
			{
				if (tickerUpdate)
				{
					node.value = signal.value;
				}
				tickerTouch = false;
				signalTouch = false;

				broadcastToKids(node, timestamp, tickerUpdate);
			}
		};

		ticker.kids.push(node);
		signal.kids.push(node);

		return node;
	}


	// DROP REPEATS

	function dropRepeats(signal)
	{
		var node = {
			id: Utils.guid(),
			name: 'dropRepeats',
			value: signal.value,
			parents: [signal],
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			var update = false;
			if (parentUpdate && !Utils.eq(node.value, signal.value))
			{
				node.value = signal.value;
				update = true;
			}
			broadcastToKids(node, timestamp, update);
		};

		signal.kids.push(node);

		return node;
	}


	return localRuntime.Native.Signal.values = {
		input: input,
		constant: constant,
		mailbox: mailbox,
		sendMessage: sendMessage,
		output: output,
		map: F2(map),
		map2: F3(map2),
		map3: F4(map3),
		map4: F5(map4),
		map5: F6(map5),
		foldp: F3(foldp),
		genericMerge: F3(genericMerge),
		filterMap: F3(filterMap),
		sampleOn: F2(sampleOn),
		dropRepeats: dropRepeats,
		timestamp: timestamp,
		delay: F2(delay)
	};
};

Elm.Native.Transform2D = {};
Elm.Native.Transform2D.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Transform2D = localRuntime.Native.Transform2D || {};
	if (localRuntime.Native.Transform2D.values)
	{
		return localRuntime.Native.Transform2D.values;
	}

	var A;
	if (typeof Float32Array === 'undefined')
	{
		A = function(arr)
		{
			this.length = arr.length;
			this[0] = arr[0];
			this[1] = arr[1];
			this[2] = arr[2];
			this[3] = arr[3];
			this[4] = arr[4];
			this[5] = arr[5];
		};
	}
	else
	{
		A = Float32Array;
	}

	// layout of matrix in an array is
	//
	//   | m11 m12 dx |
	//   | m21 m22 dy |
	//   |  0   0   1 |
	//
	//  new A([ m11, m12, dx, m21, m22, dy ])

	var identity = new A([1, 0, 0, 0, 1, 0]);
	function matrix(m11, m12, m21, m22, dx, dy)
	{
		return new A([m11, m12, dx, m21, m22, dy]);
	}

	function rotation(t)
	{
		var c = Math.cos(t);
		var s = Math.sin(t);
		return new A([c, -s, 0, s, c, 0]);
	}

	function rotate(t, m)
	{
		var c = Math.cos(t);
		var s = Math.sin(t);
		var m11 = m[0], m12 = m[1], m21 = m[3], m22 = m[4];
		return new A([m11 * c + m12 * s, -m11 * s + m12 * c, m[2],
					  m21 * c + m22 * s, -m21 * s + m22 * c, m[5]]);
	}
	/*
	function move(xy,m) {
		var x = xy._0;
		var y = xy._1;
		var m11 = m[0], m12 = m[1], m21 = m[3], m22 = m[4];
		return new A([m11, m12, m11*x + m12*y + m[2],
					  m21, m22, m21*x + m22*y + m[5]]);
	}
	function scale(s,m) { return new A([m[0]*s, m[1]*s, m[2], m[3]*s, m[4]*s, m[5]]); }
	function scaleX(x,m) { return new A([m[0]*x, m[1], m[2], m[3]*x, m[4], m[5]]); }
	function scaleY(y,m) { return new A([m[0], m[1]*y, m[2], m[3], m[4]*y, m[5]]); }
	function reflectX(m) { return new A([-m[0], m[1], m[2], -m[3], m[4], m[5]]); }
	function reflectY(m) { return new A([m[0], -m[1], m[2], m[3], -m[4], m[5]]); }

	function transform(m11, m21, m12, m22, mdx, mdy, n) {
		var n11 = n[0], n12 = n[1], n21 = n[3], n22 = n[4], ndx = n[2], ndy = n[5];
		return new A([m11*n11 + m12*n21,
					  m11*n12 + m12*n22,
					  m11*ndx + m12*ndy + mdx,
					  m21*n11 + m22*n21,
					  m21*n12 + m22*n22,
					  m21*ndx + m22*ndy + mdy]);
	}
	*/
	function multiply(m, n)
	{
		var m11 = m[0], m12 = m[1], m21 = m[3], m22 = m[4], mdx = m[2], mdy = m[5];
		var n11 = n[0], n12 = n[1], n21 = n[3], n22 = n[4], ndx = n[2], ndy = n[5];
		return new A([m11 * n11 + m12 * n21,
					  m11 * n12 + m12 * n22,
					  m11 * ndx + m12 * ndy + mdx,
					  m21 * n11 + m22 * n21,
					  m21 * n12 + m22 * n22,
					  m21 * ndx + m22 * ndy + mdy]);
	}

	return localRuntime.Native.Transform2D.values = {
		identity: identity,
		matrix: F6(matrix),
		rotation: rotation,
		multiply: F2(multiply)
		/*
		transform: F7(transform),
		rotate: F2(rotate),
		move: F2(move),
		scale: F2(scale),
		scaleX: F2(scaleX),
		scaleY: F2(scaleY),
		reflectX: reflectX,
		reflectY: reflectY
		*/
	};
};

Elm.Transform2D = Elm.Transform2D || {};
Elm.Transform2D.make = function (_elm) {
   "use strict";
   _elm.Transform2D = _elm.Transform2D || {};
   if (_elm.Transform2D.values) return _elm.Transform2D.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Native$Transform2D = Elm.Native.Transform2D.make(_elm);
   var _op = {};
   var multiply = $Native$Transform2D.multiply;
   var rotation = $Native$Transform2D.rotation;
   var matrix = $Native$Transform2D.matrix;
   var translation = F2(function (x,y) {
      return A6(matrix,1,0,0,1,x,y);
   });
   var scale = function (s) {    return A6(matrix,s,0,0,s,0,0);};
   var scaleX = function (x) {    return A6(matrix,x,0,0,1,0,0);};
   var scaleY = function (y) {    return A6(matrix,1,0,0,y,0,0);};
   var identity = $Native$Transform2D.identity;
   var Transform2D = {ctor: "Transform2D"};
   return _elm.Transform2D.values = {_op: _op
                                    ,identity: identity
                                    ,matrix: matrix
                                    ,multiply: multiply
                                    ,rotation: rotation
                                    ,translation: translation
                                    ,scale: scale
                                    ,scaleX: scaleX
                                    ,scaleY: scaleY};
};

// setup
Elm.Native = Elm.Native || {};
Elm.Native.Graphics = Elm.Native.Graphics || {};
Elm.Native.Graphics.Collage = Elm.Native.Graphics.Collage || {};

// definition
Elm.Native.Graphics.Collage.make = function(localRuntime) {
	'use strict';

	// attempt to short-circuit
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Graphics = localRuntime.Native.Graphics || {};
	localRuntime.Native.Graphics.Collage = localRuntime.Native.Graphics.Collage || {};
	if ('values' in localRuntime.Native.Graphics.Collage)
	{
		return localRuntime.Native.Graphics.Collage.values;
	}

	// okay, we cannot short-ciruit, so now we define everything
	var Color = Elm.Native.Color.make(localRuntime);
	var List = Elm.Native.List.make(localRuntime);
	var NativeElement = Elm.Native.Graphics.Element.make(localRuntime);
	var Transform = Elm.Transform2D.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);

	function setStrokeStyle(ctx, style)
	{
		ctx.lineWidth = style.width;

		var cap = style.cap.ctor;
		ctx.lineCap = cap === 'Flat'
			? 'butt'
			: cap === 'Round'
				? 'round'
				: 'square';

		var join = style.join.ctor;
		ctx.lineJoin = join === 'Smooth'
			? 'round'
			: join === 'Sharp'
				? 'miter'
				: 'bevel';

		ctx.miterLimit = style.join._0 || 10;
		ctx.strokeStyle = Color.toCss(style.color);
	}

	function setFillStyle(redo, ctx, style)
	{
		var sty = style.ctor;
		ctx.fillStyle = sty === 'Solid'
			? Color.toCss(style._0)
			: sty === 'Texture'
				? texture(redo, ctx, style._0)
				: gradient(ctx, style._0);
	}

	function trace(ctx, path)
	{
		var points = List.toArray(path);
		var i = points.length - 1;
		if (i <= 0)
		{
			return;
		}
		ctx.moveTo(points[i]._0, points[i]._1);
		while (i--)
		{
			ctx.lineTo(points[i]._0, points[i]._1);
		}
		if (path.closed)
		{
			i = points.length - 1;
			ctx.lineTo(points[i]._0, points[i]._1);
		}
	}

	function line(ctx, style, path)
	{
		if (style.dashing.ctor === '[]')
		{
			trace(ctx, path);
		}
		else
		{
			customLineHelp(ctx, style, path);
		}
		ctx.scale(1, -1);
		ctx.stroke();
	}

	function customLineHelp(ctx, style, path)
	{
		var points = List.toArray(path);
		if (path.closed)
		{
			points.push(points[0]);
		}
		var pattern = List.toArray(style.dashing);
		var i = points.length - 1;
		if (i <= 0)
		{
			return;
		}
		var x0 = points[i]._0, y0 = points[i]._1;
		var x1 = 0, y1 = 0, dx = 0, dy = 0, remaining = 0;
		var pindex = 0, plen = pattern.length;
		var draw = true, segmentLength = pattern[0];
		ctx.moveTo(x0, y0);
		while (i--)
		{
			x1 = points[i]._0;
			y1 = points[i]._1;
			dx = x1 - x0;
			dy = y1 - y0;
			remaining = Math.sqrt(dx * dx + dy * dy);
			while (segmentLength <= remaining)
			{
				x0 += dx * segmentLength / remaining;
				y0 += dy * segmentLength / remaining;
				ctx[draw ? 'lineTo' : 'moveTo'](x0, y0);
				// update starting position
				dx = x1 - x0;
				dy = y1 - y0;
				remaining = Math.sqrt(dx * dx + dy * dy);
				// update pattern
				draw = !draw;
				pindex = (pindex + 1) % plen;
				segmentLength = pattern[pindex];
			}
			if (remaining > 0)
			{
				ctx[draw ? 'lineTo' : 'moveTo'](x1, y1);
				segmentLength -= remaining;
			}
			x0 = x1;
			y0 = y1;
		}
	}

	function drawLine(ctx, style, path)
	{
		setStrokeStyle(ctx, style);
		return line(ctx, style, path);
	}

	function texture(redo, ctx, src)
	{
		var img = new Image();
		img.src = src;
		img.onload = redo;
		return ctx.createPattern(img, 'repeat');
	}

	function gradient(ctx, grad)
	{
		var g;
		var stops = [];
		if (grad.ctor === 'Linear')
		{
			var p0 = grad._0, p1 = grad._1;
			g = ctx.createLinearGradient(p0._0, -p0._1, p1._0, -p1._1);
			stops = List.toArray(grad._2);
		}
		else
		{
			var p0 = grad._0, p2 = grad._2;
			g = ctx.createRadialGradient(p0._0, -p0._1, grad._1, p2._0, -p2._1, grad._3);
			stops = List.toArray(grad._4);
		}
		var len = stops.length;
		for (var i = 0; i < len; ++i)
		{
			var stop = stops[i];
			g.addColorStop(stop._0, Color.toCss(stop._1));
		}
		return g;
	}

	function drawShape(redo, ctx, style, path)
	{
		trace(ctx, path);
		setFillStyle(redo, ctx, style);
		ctx.scale(1, -1);
		ctx.fill();
	}


	// TEXT RENDERING

	function fillText(redo, ctx, text)
	{
		drawText(ctx, text, ctx.fillText);
	}

	function strokeText(redo, ctx, style, text)
	{
		setStrokeStyle(ctx, style);
		// Use native canvas API for dashes only for text for now
		// Degrades to non-dashed on IE 9 + 10
		if (style.dashing.ctor !== '[]' && ctx.setLineDash)
		{
			var pattern = List.toArray(style.dashing);
			ctx.setLineDash(pattern);
		}
		drawText(ctx, text, ctx.strokeText);
	}

	function drawText(ctx, text, canvasDrawFn)
	{
		var textChunks = chunkText(defaultContext, text);

		var totalWidth = 0;
		var maxHeight = 0;
		var numChunks = textChunks.length;

		ctx.scale(1,-1);

		for (var i = numChunks; i--; )
		{
			var chunk = textChunks[i];
			ctx.font = chunk.font;
			var metrics = ctx.measureText(chunk.text);
			chunk.width = metrics.width;
			totalWidth += chunk.width;
			if (chunk.height > maxHeight)
			{
				maxHeight = chunk.height;
			}
		}

		var x = -totalWidth / 2.0;
		for (var i = 0; i < numChunks; ++i)
		{
			var chunk = textChunks[i];
			ctx.font = chunk.font;
			ctx.fillStyle = chunk.color;
			canvasDrawFn.call(ctx, chunk.text, x, maxHeight / 2);
			x += chunk.width;
		}
	}

	function toFont(props)
	{
		return [
			props['font-style'],
			props['font-variant'],
			props['font-weight'],
			props['font-size'],
			props['font-family']
		].join(' ');
	}


	// Convert the object returned by the text module
	// into something we can use for styling canvas text
	function chunkText(context, text)
	{
		var tag = text.ctor;
		if (tag === 'Text:Append')
		{
			var leftChunks = chunkText(context, text._0);
			var rightChunks = chunkText(context, text._1);
			return leftChunks.concat(rightChunks);
		}
		if (tag === 'Text:Text')
		{
			return [{
				text: text._0,
				color: context.color,
				height: context['font-size'].slice(0, -2) | 0,
				font: toFont(context)
			}];
		}
		if (tag === 'Text:Meta')
		{
			var newContext = freshContext(text._0, context);
			return chunkText(newContext, text._1);
		}
	}

	function freshContext(props, ctx)
	{
		return {
			'font-style': props['font-style'] || ctx['font-style'],
			'font-variant': props['font-variant'] || ctx['font-variant'],
			'font-weight': props['font-weight'] || ctx['font-weight'],
			'font-size': props['font-size'] || ctx['font-size'],
			'font-family': props['font-family'] || ctx['font-family'],
			'color': props['color'] || ctx['color']
		};
	}

	var defaultContext = {
		'font-style': 'normal',
		'font-variant': 'normal',
		'font-weight': 'normal',
		'font-size': '12px',
		'font-family': 'sans-serif',
		'color': 'black'
	};


	// IMAGES

	function drawImage(redo, ctx, form)
	{
		var img = new Image();
		img.onload = redo;
		img.src = form._3;
		var w = form._0,
			h = form._1,
			pos = form._2,
			srcX = pos._0,
			srcY = pos._1,
			srcW = w,
			srcH = h,
			destX = -w / 2,
			destY = -h / 2,
			destW = w,
			destH = h;

		ctx.scale(1, -1);
		ctx.drawImage(img, srcX, srcY, srcW, srcH, destX, destY, destW, destH);
	}

	function renderForm(redo, ctx, form)
	{
		ctx.save();

		var x = form.x,
			y = form.y,
			theta = form.theta,
			scale = form.scale;

		if (x !== 0 || y !== 0)
		{
			ctx.translate(x, y);
		}
		if (theta !== 0)
		{
			ctx.rotate(theta % (Math.PI * 2));
		}
		if (scale !== 1)
		{
			ctx.scale(scale, scale);
		}
		if (form.alpha !== 1)
		{
			ctx.globalAlpha = ctx.globalAlpha * form.alpha;
		}

		ctx.beginPath();
		var f = form.form;
		switch (f.ctor)
		{
			case 'FPath':
				drawLine(ctx, f._0, f._1);
				break;

			case 'FImage':
				drawImage(redo, ctx, f);
				break;

			case 'FShape':
				if (f._0.ctor === 'Line')
				{
					f._1.closed = true;
					drawLine(ctx, f._0._0, f._1);
				}
				else
				{
					drawShape(redo, ctx, f._0._0, f._1);
				}
				break;

			case 'FText':
				fillText(redo, ctx, f._0);
				break;

			case 'FOutlinedText':
				strokeText(redo, ctx, f._0, f._1);
				break;
		}
		ctx.restore();
	}

	function formToMatrix(form)
	{
	   var scale = form.scale;
	   var matrix = A6( Transform.matrix, scale, 0, 0, scale, form.x, form.y );

	   var theta = form.theta;
	   if (theta !== 0)
	   {
		   matrix = A2( Transform.multiply, matrix, Transform.rotation(theta) );
	   }

	   return matrix;
	}

	function str(n)
	{
		if (n < 0.00001 && n > -0.00001)
		{
			return 0;
		}
		return n;
	}

	function makeTransform(w, h, form, matrices)
	{
		var props = form.form._0._0.props;
		var m = A6( Transform.matrix, 1, 0, 0, -1,
					(w - props.width ) / 2,
					(h - props.height) / 2 );
		var len = matrices.length;
		for (var i = 0; i < len; ++i)
		{
			m = A2( Transform.multiply, m, matrices[i] );
		}
		m = A2( Transform.multiply, m, formToMatrix(form) );

		return 'matrix(' +
			str( m[0]) + ', ' + str( m[3]) + ', ' +
			str(-m[1]) + ', ' + str(-m[4]) + ', ' +
			str( m[2]) + ', ' + str( m[5]) + ')';
	}

	function stepperHelp(list)
	{
		var arr = List.toArray(list);
		var i = 0;
		function peekNext()
		{
			return i < arr.length ? arr[i]._0.form.ctor : '';
		}
		// assumes that there is a next element
		function next()
		{
			var out = arr[i]._0;
			++i;
			return out;
		}
		return {
			peekNext: peekNext,
			next: next
		};
	}

	function formStepper(forms)
	{
		var ps = [stepperHelp(forms)];
		var matrices = [];
		var alphas = [];
		function peekNext()
		{
			var len = ps.length;
			var formType = '';
			for (var i = 0; i < len; ++i )
			{
				if (formType = ps[i].peekNext()) return formType;
			}
			return '';
		}
		// assumes that there is a next element
		function next(ctx)
		{
			while (!ps[0].peekNext())
			{
				ps.shift();
				matrices.pop();
				alphas.shift();
				if (ctx)
				{
					ctx.restore();
				}
			}
			var out = ps[0].next();
			var f = out.form;
			if (f.ctor === 'FGroup')
			{
				ps.unshift(stepperHelp(f._1));
				var m = A2(Transform.multiply, f._0, formToMatrix(out));
				ctx.save();
				ctx.transform(m[0], m[3], m[1], m[4], m[2], m[5]);
				matrices.push(m);

				var alpha = (alphas[0] || 1) * out.alpha;
				alphas.unshift(alpha);
				ctx.globalAlpha = alpha;
			}
			return out;
		}
		function transforms()
		{
			return matrices;
		}
		function alpha()
		{
			return alphas[0] || 1;
		}
		return {
			peekNext: peekNext,
			next: next,
			transforms: transforms,
			alpha: alpha
		};
	}

	function makeCanvas(w, h)
	{
		var canvas = NativeElement.createNode('canvas');
		canvas.style.width  = w + 'px';
		canvas.style.height = h + 'px';
		canvas.style.display = 'block';
		canvas.style.position = 'absolute';
		var ratio = window.devicePixelRatio || 1;
		canvas.width  = w * ratio;
		canvas.height = h * ratio;
		return canvas;
	}

	function render(model)
	{
		var div = NativeElement.createNode('div');
		div.style.overflow = 'hidden';
		div.style.position = 'relative';
		update(div, model, model);
		return div;
	}

	function nodeStepper(w, h, div)
	{
		var kids = div.childNodes;
		var i = 0;
		var ratio = window.devicePixelRatio || 1;

		function transform(transforms, ctx)
		{
			ctx.translate( w / 2 * ratio, h / 2 * ratio );
			ctx.scale( ratio, -ratio );
			var len = transforms.length;
			for (var i = 0; i < len; ++i)
			{
				var m = transforms[i];
				ctx.save();
				ctx.transform(m[0], m[3], m[1], m[4], m[2], m[5]);
			}
			return ctx;
		}
		function nextContext(transforms)
		{
			while (i < kids.length)
			{
				var node = kids[i];
				if (node.getContext)
				{
					node.width = w * ratio;
					node.height = h * ratio;
					node.style.width = w + 'px';
					node.style.height = h + 'px';
					++i;
					return transform(transforms, node.getContext('2d'));
				}
				div.removeChild(node);
			}
			var canvas = makeCanvas(w, h);
			div.appendChild(canvas);
			// we have added a new node, so we must step our position
			++i;
			return transform(transforms, canvas.getContext('2d'));
		}
		function addElement(matrices, alpha, form)
		{
			var kid = kids[i];
			var elem = form.form._0;

			var node = (!kid || kid.getContext)
				? NativeElement.render(elem)
				: NativeElement.update(kid, kid.oldElement, elem);

			node.style.position = 'absolute';
			node.style.opacity = alpha * form.alpha * elem._0.props.opacity;
			NativeElement.addTransform(node.style, makeTransform(w, h, form, matrices));
			node.oldElement = elem;
			++i;
			if (!kid)
			{
				div.appendChild(node);
			}
			else
			{
				div.insertBefore(node, kid);
			}
		}
		function clearRest()
		{
			while (i < kids.length)
			{
				div.removeChild(kids[i]);
			}
		}
		return {
			nextContext: nextContext,
			addElement: addElement,
			clearRest: clearRest
		};
	}


	function update(div, _, model)
	{
		var w = model.w;
		var h = model.h;

		var forms = formStepper(model.forms);
		var nodes = nodeStepper(w, h, div);
		var ctx = null;
		var formType = '';

		while (formType = forms.peekNext())
		{
			// make sure we have context if we need it
			if (ctx === null && formType !== 'FElement')
			{
				ctx = nodes.nextContext(forms.transforms());
				ctx.globalAlpha = forms.alpha();
			}

			var form = forms.next(ctx);
			// if it is FGroup, all updates are made within formStepper when next is called.
			if (formType === 'FElement')
			{
				// update or insert an element, get a new context
				nodes.addElement(forms.transforms(), forms.alpha(), form);
				ctx = null;
			}
			else if (formType !== 'FGroup')
			{
				renderForm(function() { update(div, model, model); }, ctx, form);
			}
		}
		nodes.clearRest();
		return div;
	}


	function collage(w, h, forms)
	{
		return A3(NativeElement.newElement, w, h, {
			ctor: 'Custom',
			type: 'Collage',
			render: render,
			update: update,
			model: {w: w, h: h, forms: forms}
		});
	}

	return localRuntime.Native.Graphics.Collage.values = {
		collage: F3(collage)
	};
};


// setup
Elm.Native = Elm.Native || {};
Elm.Native.Graphics = Elm.Native.Graphics || {};
Elm.Native.Graphics.Element = Elm.Native.Graphics.Element || {};

// definition
Elm.Native.Graphics.Element.make = function(localRuntime) {
	'use strict';

	// attempt to short-circuit
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Graphics = localRuntime.Native.Graphics || {};
	localRuntime.Native.Graphics.Element = localRuntime.Native.Graphics.Element || {};
	if ('values' in localRuntime.Native.Graphics.Element)
	{
		return localRuntime.Native.Graphics.Element.values;
	}

	var Color = Elm.Native.Color.make(localRuntime);
	var List = Elm.Native.List.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);
	var Text = Elm.Native.Text.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);


	// CREATION

	var createNode =
		typeof document === 'undefined'
			?
				function(_)
				{
					return {
						style: {},
						appendChild: function() {}
					};
				}
			:
				function(elementType)
				{
					var node = document.createElement(elementType);
					node.style.padding = '0';
					node.style.margin = '0';
					return node;
				}
			;


	function newElement(width, height, elementPrim)
	{
		return {
			ctor: 'Element_elm_builtin',
			_0: {
				element: elementPrim,
				props: {
					id: Utils.guid(),
					width: width,
					height: height,
					opacity: 1,
					color: Maybe.Nothing,
					href: '',
					tag: '',
					hover: Utils.Tuple0,
					click: Utils.Tuple0
				}
			}
		};
	}


	// PROPERTIES

	function setProps(elem, node)
	{
		var props = elem.props;

		var element = elem.element;
		var width = props.width - (element.adjustWidth || 0);
		var height = props.height - (element.adjustHeight || 0);
		node.style.width  = (width | 0) + 'px';
		node.style.height = (height | 0) + 'px';

		if (props.opacity !== 1)
		{
			node.style.opacity = props.opacity;
		}

		if (props.color.ctor === 'Just')
		{
			node.style.backgroundColor = Color.toCss(props.color._0);
		}

		if (props.tag !== '')
		{
			node.id = props.tag;
		}

		if (props.hover.ctor !== '_Tuple0')
		{
			addHover(node, props.hover);
		}

		if (props.click.ctor !== '_Tuple0')
		{
			addClick(node, props.click);
		}

		if (props.href !== '')
		{
			var anchor = createNode('a');
			anchor.href = props.href;
			anchor.style.display = 'block';
			anchor.style.pointerEvents = 'auto';
			anchor.appendChild(node);
			node = anchor;
		}

		return node;
	}

	function addClick(e, handler)
	{
		e.style.pointerEvents = 'auto';
		e.elm_click_handler = handler;
		function trigger(ev)
		{
			e.elm_click_handler(Utils.Tuple0);
			ev.stopPropagation();
		}
		e.elm_click_trigger = trigger;
		e.addEventListener('click', trigger);
	}

	function removeClick(e, handler)
	{
		if (e.elm_click_trigger)
		{
			e.removeEventListener('click', e.elm_click_trigger);
			e.elm_click_trigger = null;
			e.elm_click_handler = null;
		}
	}

	function addHover(e, handler)
	{
		e.style.pointerEvents = 'auto';
		e.elm_hover_handler = handler;
		e.elm_hover_count = 0;

		function over(evt)
		{
			if (e.elm_hover_count++ > 0) return;
			e.elm_hover_handler(true);
			evt.stopPropagation();
		}
		function out(evt)
		{
			if (e.contains(evt.toElement || evt.relatedTarget)) return;
			e.elm_hover_count = 0;
			e.elm_hover_handler(false);
			evt.stopPropagation();
		}
		e.elm_hover_over = over;
		e.elm_hover_out = out;
		e.addEventListener('mouseover', over);
		e.addEventListener('mouseout', out);
	}

	function removeHover(e)
	{
		e.elm_hover_handler = null;
		if (e.elm_hover_over)
		{
			e.removeEventListener('mouseover', e.elm_hover_over);
			e.elm_hover_over = null;
		}
		if (e.elm_hover_out)
		{
			e.removeEventListener('mouseout', e.elm_hover_out);
			e.elm_hover_out = null;
		}
	}


	// IMAGES

	function image(props, img)
	{
		switch (img._0.ctor)
		{
			case 'Plain':
				return plainImage(img._3);

			case 'Fitted':
				return fittedImage(props.width, props.height, img._3);

			case 'Cropped':
				return croppedImage(img, props.width, props.height, img._3);

			case 'Tiled':
				return tiledImage(img._3);
		}
	}

	function plainImage(src)
	{
		var img = createNode('img');
		img.src = src;
		img.name = src;
		img.style.display = 'block';
		return img;
	}

	function tiledImage(src)
	{
		var div = createNode('div');
		div.style.backgroundImage = 'url(' + src + ')';
		return div;
	}

	function fittedImage(w, h, src)
	{
		var div = createNode('div');
		div.style.background = 'url(' + src + ') no-repeat center';
		div.style.webkitBackgroundSize = 'cover';
		div.style.MozBackgroundSize = 'cover';
		div.style.OBackgroundSize = 'cover';
		div.style.backgroundSize = 'cover';
		return div;
	}

	function croppedImage(elem, w, h, src)
	{
		var pos = elem._0._0;
		var e = createNode('div');
		e.style.overflow = 'hidden';

		var img = createNode('img');
		img.onload = function() {
			var sw = w / elem._1, sh = h / elem._2;
			img.style.width = ((this.width * sw) | 0) + 'px';
			img.style.height = ((this.height * sh) | 0) + 'px';
			img.style.marginLeft = ((- pos._0 * sw) | 0) + 'px';
			img.style.marginTop = ((- pos._1 * sh) | 0) + 'px';
		};
		img.src = src;
		img.name = src;
		e.appendChild(img);
		return e;
	}


	// FLOW

	function goOut(node)
	{
		node.style.position = 'absolute';
		return node;
	}
	function goDown(node)
	{
		return node;
	}
	function goRight(node)
	{
		node.style.styleFloat = 'left';
		node.style.cssFloat = 'left';
		return node;
	}

	var directionTable = {
		DUp: goDown,
		DDown: goDown,
		DLeft: goRight,
		DRight: goRight,
		DIn: goOut,
		DOut: goOut
	};
	function needsReversal(dir)
	{
		return dir === 'DUp' || dir === 'DLeft' || dir === 'DIn';
	}

	function flow(dir, elist)
	{
		var array = List.toArray(elist);
		var container = createNode('div');
		var goDir = directionTable[dir];
		if (goDir === goOut)
		{
			container.style.pointerEvents = 'none';
		}
		if (needsReversal(dir))
		{
			array.reverse();
		}
		var len = array.length;
		for (var i = 0; i < len; ++i)
		{
			container.appendChild(goDir(render(array[i])));
		}
		return container;
	}


	// CONTAINER

	function toPos(pos)
	{
		return pos.ctor === 'Absolute'
			? pos._0 + 'px'
			: (pos._0 * 100) + '%';
	}

	// must clear right, left, top, bottom, and transform
	// before calling this function
	function setPos(pos, wrappedElement, e)
	{
		var elem = wrappedElement._0;
		var element = elem.element;
		var props = elem.props;
		var w = props.width + (element.adjustWidth ? element.adjustWidth : 0);
		var h = props.height + (element.adjustHeight ? element.adjustHeight : 0);

		e.style.position = 'absolute';
		e.style.margin = 'auto';
		var transform = '';

		switch (pos.horizontal.ctor)
		{
			case 'P':
				e.style.right = toPos(pos.x);
				e.style.removeProperty('left');
				break;

			case 'Z':
				transform = 'translateX(' + ((-w / 2) | 0) + 'px) ';

			case 'N':
				e.style.left = toPos(pos.x);
				e.style.removeProperty('right');
				break;
		}
		switch (pos.vertical.ctor)
		{
			case 'N':
				e.style.bottom = toPos(pos.y);
				e.style.removeProperty('top');
				break;

			case 'Z':
				transform += 'translateY(' + ((-h / 2) | 0) + 'px)';

			case 'P':
				e.style.top = toPos(pos.y);
				e.style.removeProperty('bottom');
				break;
		}
		if (transform !== '')
		{
			addTransform(e.style, transform);
		}
		return e;
	}

	function addTransform(style, transform)
	{
		style.transform       = transform;
		style.msTransform     = transform;
		style.MozTransform    = transform;
		style.webkitTransform = transform;
		style.OTransform      = transform;
	}

	function container(pos, elem)
	{
		var e = render(elem);
		setPos(pos, elem, e);
		var div = createNode('div');
		div.style.position = 'relative';
		div.style.overflow = 'hidden';
		div.appendChild(e);
		return div;
	}


	function rawHtml(elem)
	{
		var html = elem.html;
		var align = elem.align;

		var div = createNode('div');
		div.innerHTML = html;
		div.style.visibility = 'hidden';
		if (align)
		{
			div.style.textAlign = align;
		}
		div.style.visibility = 'visible';
		div.style.pointerEvents = 'auto';
		return div;
	}


	// RENDER

	function render(wrappedElement)
	{
		var elem = wrappedElement._0;
		return setProps(elem, makeElement(elem));
	}

	function makeElement(e)
	{
		var elem = e.element;
		switch (elem.ctor)
		{
			case 'Image':
				return image(e.props, elem);

			case 'Flow':
				return flow(elem._0.ctor, elem._1);

			case 'Container':
				return container(elem._0, elem._1);

			case 'Spacer':
				return createNode('div');

			case 'RawHtml':
				return rawHtml(elem);

			case 'Custom':
				return elem.render(elem.model);
		}
	}

	function updateAndReplace(node, curr, next)
	{
		var newNode = update(node, curr, next);
		if (newNode !== node)
		{
			node.parentNode.replaceChild(newNode, node);
		}
		return newNode;
	}


	// UPDATE

	function update(node, wrappedCurrent, wrappedNext)
	{
		var curr = wrappedCurrent._0;
		var next = wrappedNext._0;
		var rootNode = node;
		if (node.tagName === 'A')
		{
			node = node.firstChild;
		}
		if (curr.props.id === next.props.id)
		{
			updateProps(node, curr, next);
			return rootNode;
		}
		if (curr.element.ctor !== next.element.ctor)
		{
			return render(wrappedNext);
		}
		var nextE = next.element;
		var currE = curr.element;
		switch (nextE.ctor)
		{
			case 'Spacer':
				updateProps(node, curr, next);
				return rootNode;

			case 'RawHtml':
				if(currE.html.valueOf() !== nextE.html.valueOf())
				{
					node.innerHTML = nextE.html;
				}
				updateProps(node, curr, next);
				return rootNode;

			case 'Image':
				if (nextE._0.ctor === 'Plain')
				{
					if (nextE._3 !== currE._3)
					{
						node.src = nextE._3;
					}
				}
				else if (!Utils.eq(nextE, currE)
					|| next.props.width !== curr.props.width
					|| next.props.height !== curr.props.height)
				{
					return render(wrappedNext);
				}
				updateProps(node, curr, next);
				return rootNode;

			case 'Flow':
				var arr = List.toArray(nextE._1);
				for (var i = arr.length; i--; )
				{
					arr[i] = arr[i]._0.element.ctor;
				}
				if (nextE._0.ctor !== currE._0.ctor)
				{
					return render(wrappedNext);
				}
				var nexts = List.toArray(nextE._1);
				var kids = node.childNodes;
				if (nexts.length !== kids.length)
				{
					return render(wrappedNext);
				}
				var currs = List.toArray(currE._1);
				var dir = nextE._0.ctor;
				var goDir = directionTable[dir];
				var toReverse = needsReversal(dir);
				var len = kids.length;
				for (var i = len; i--; )
				{
					var subNode = kids[toReverse ? len - i - 1 : i];
					goDir(updateAndReplace(subNode, currs[i], nexts[i]));
				}
				updateProps(node, curr, next);
				return rootNode;

			case 'Container':
				var subNode = node.firstChild;
				var newSubNode = updateAndReplace(subNode, currE._1, nextE._1);
				setPos(nextE._0, nextE._1, newSubNode);
				updateProps(node, curr, next);
				return rootNode;

			case 'Custom':
				if (currE.type === nextE.type)
				{
					var updatedNode = nextE.update(node, currE.model, nextE.model);
					updateProps(updatedNode, curr, next);
					return updatedNode;
				}
				return render(wrappedNext);
		}
	}

	function updateProps(node, curr, next)
	{
		var nextProps = next.props;
		var currProps = curr.props;

		var element = next.element;
		var width = nextProps.width - (element.adjustWidth || 0);
		var height = nextProps.height - (element.adjustHeight || 0);
		if (width !== currProps.width)
		{
			node.style.width = (width | 0) + 'px';
		}
		if (height !== currProps.height)
		{
			node.style.height = (height | 0) + 'px';
		}

		if (nextProps.opacity !== currProps.opacity)
		{
			node.style.opacity = nextProps.opacity;
		}

		var nextColor = nextProps.color.ctor === 'Just'
			? Color.toCss(nextProps.color._0)
			: '';
		if (node.style.backgroundColor !== nextColor)
		{
			node.style.backgroundColor = nextColor;
		}

		if (nextProps.tag !== currProps.tag)
		{
			node.id = nextProps.tag;
		}

		if (nextProps.href !== currProps.href)
		{
			if (currProps.href === '')
			{
				// add a surrounding href
				var anchor = createNode('a');
				anchor.href = nextProps.href;
				anchor.style.display = 'block';
				anchor.style.pointerEvents = 'auto';

				node.parentNode.replaceChild(anchor, node);
				anchor.appendChild(node);
			}
			else if (nextProps.href === '')
			{
				// remove the surrounding href
				var anchor = node.parentNode;
				anchor.parentNode.replaceChild(node, anchor);
			}
			else
			{
				// just update the link
				node.parentNode.href = nextProps.href;
			}
		}

		// update click and hover handlers
		var removed = false;

		// update hover handlers
		if (currProps.hover.ctor === '_Tuple0')
		{
			if (nextProps.hover.ctor !== '_Tuple0')
			{
				addHover(node, nextProps.hover);
			}
		}
		else
		{
			if (nextProps.hover.ctor === '_Tuple0')
			{
				removed = true;
				removeHover(node);
			}
			else
			{
				node.elm_hover_handler = nextProps.hover;
			}
		}

		// update click handlers
		if (currProps.click.ctor === '_Tuple0')
		{
			if (nextProps.click.ctor !== '_Tuple0')
			{
				addClick(node, nextProps.click);
			}
		}
		else
		{
			if (nextProps.click.ctor === '_Tuple0')
			{
				removed = true;
				removeClick(node);
			}
			else
			{
				node.elm_click_handler = nextProps.click;
			}
		}

		// stop capturing clicks if
		if (removed
			&& nextProps.hover.ctor === '_Tuple0'
			&& nextProps.click.ctor === '_Tuple0')
		{
			node.style.pointerEvents = 'none';
		}
	}


	// TEXT

	function block(align)
	{
		return function(text)
		{
			var raw = {
				ctor: 'RawHtml',
				html: Text.renderHtml(text),
				align: align
			};
			var pos = htmlHeight(0, raw);
			return newElement(pos._0, pos._1, raw);
		};
	}

	function markdown(text)
	{
		var raw = {
			ctor: 'RawHtml',
			html: text,
			align: null
		};
		var pos = htmlHeight(0, raw);
		return newElement(pos._0, pos._1, raw);
	}

	var htmlHeight =
		typeof document !== 'undefined'
			? realHtmlHeight
			: function(a, b) { return Utils.Tuple2(0, 0); };

	function realHtmlHeight(width, rawHtml)
	{
		// create dummy node
		var temp = document.createElement('div');
		temp.innerHTML = rawHtml.html;
		if (width > 0)
		{
			temp.style.width = width + 'px';
		}
		temp.style.visibility = 'hidden';
		temp.style.styleFloat = 'left';
		temp.style.cssFloat = 'left';

		document.body.appendChild(temp);

		// get dimensions
		var style = window.getComputedStyle(temp, null);
		var w = Math.ceil(style.getPropertyValue('width').slice(0, -2) - 0);
		var h = Math.ceil(style.getPropertyValue('height').slice(0, -2) - 0);
		document.body.removeChild(temp);
		return Utils.Tuple2(w, h);
	}


	return localRuntime.Native.Graphics.Element.values = {
		render: render,
		update: update,
		updateAndReplace: updateAndReplace,

		createNode: createNode,
		newElement: F3(newElement),
		addTransform: addTransform,
		htmlHeight: F2(htmlHeight),
		guid: Utils.guid,

		block: block,
		markdown: markdown
	};
};

Elm.Native.Text = {};
Elm.Native.Text.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Text = localRuntime.Native.Text || {};
	if (localRuntime.Native.Text.values)
	{
		return localRuntime.Native.Text.values;
	}

	var toCss = Elm.Native.Color.make(localRuntime).toCss;
	var List = Elm.Native.List.make(localRuntime);


	// CONSTRUCTORS

	function fromString(str)
	{
		return {
			ctor: 'Text:Text',
			_0: str
		};
	}

	function append(a, b)
	{
		return {
			ctor: 'Text:Append',
			_0: a,
			_1: b
		};
	}

	function addMeta(field, value, text)
	{
		var newProps = {};
		var newText = {
			ctor: 'Text:Meta',
			_0: newProps,
			_1: text
		};

		if (text.ctor === 'Text:Meta')
		{
			newText._1 = text._1;
			var props = text._0;
			for (var i = metaKeys.length; i--; )
			{
				var key = metaKeys[i];
				var val = props[key];
				if (val)
				{
					newProps[key] = val;
				}
			}
		}
		newProps[field] = value;
		return newText;
	}

	var metaKeys = [
		'font-size',
		'font-family',
		'font-style',
		'font-weight',
		'href',
		'text-decoration',
		'color'
	];


	// conversions from Elm values to CSS

	function toTypefaces(list)
	{
		var typefaces = List.toArray(list);
		for (var i = typefaces.length; i--; )
		{
			var typeface = typefaces[i];
			if (typeface.indexOf(' ') > -1)
			{
				typefaces[i] = "'" + typeface + "'";
			}
		}
		return typefaces.join(',');
	}

	function toLine(line)
	{
		var ctor = line.ctor;
		return ctor === 'Under'
			? 'underline'
			: ctor === 'Over'
				? 'overline'
				: 'line-through';
	}

	// setting styles of Text

	function style(style, text)
	{
		var newText = addMeta('color', toCss(style.color), text);
		var props = newText._0;

		if (style.typeface.ctor !== '[]')
		{
			props['font-family'] = toTypefaces(style.typeface);
		}
		if (style.height.ctor !== 'Nothing')
		{
			props['font-size'] = style.height._0 + 'px';
		}
		if (style.bold)
		{
			props['font-weight'] = 'bold';
		}
		if (style.italic)
		{
			props['font-style'] = 'italic';
		}
		if (style.line.ctor !== 'Nothing')
		{
			props['text-decoration'] = toLine(style.line._0);
		}
		return newText;
	}

	function height(px, text)
	{
		return addMeta('font-size', px + 'px', text);
	}

	function typeface(names, text)
	{
		return addMeta('font-family', toTypefaces(names), text);
	}

	function monospace(text)
	{
		return addMeta('font-family', 'monospace', text);
	}

	function italic(text)
	{
		return addMeta('font-style', 'italic', text);
	}

	function bold(text)
	{
		return addMeta('font-weight', 'bold', text);
	}

	function link(href, text)
	{
		return addMeta('href', href, text);
	}

	function line(line, text)
	{
		return addMeta('text-decoration', toLine(line), text);
	}

	function color(color, text)
	{
		return addMeta('color', toCss(color), text);
	}


	// RENDER

	function renderHtml(text)
	{
		var tag = text.ctor;
		if (tag === 'Text:Append')
		{
			return renderHtml(text._0) + renderHtml(text._1);
		}
		if (tag === 'Text:Text')
		{
			return properEscape(text._0);
		}
		if (tag === 'Text:Meta')
		{
			return renderMeta(text._0, renderHtml(text._1));
		}
	}

	function renderMeta(metas, string)
	{
		var href = metas.href;
		if (href)
		{
			string = '<a href="' + href + '">' + string + '</a>';
		}
		var styles = '';
		for (var key in metas)
		{
			if (key === 'href')
			{
				continue;
			}
			styles += key + ':' + metas[key] + ';';
		}
		if (styles)
		{
			string = '<span style="' + styles + '">' + string + '</span>';
		}
		return string;
	}

	function properEscape(str)
	{
		if (str.length === 0)
		{
			return str;
		}
		str = str //.replace(/&/g,  '&#38;')
			.replace(/"/g,  '&#34;')
			.replace(/'/g,  '&#39;')
			.replace(/</g,  '&#60;')
			.replace(/>/g,  '&#62;');
		var arr = str.split('\n');
		for (var i = arr.length; i--; )
		{
			arr[i] = makeSpaces(arr[i]);
		}
		return arr.join('<br/>');
	}

	function makeSpaces(s)
	{
		if (s.length === 0)
		{
			return s;
		}
		var arr = s.split('');
		if (arr[0] === ' ')
		{
			arr[0] = '&nbsp;';
		}
		for (var i = arr.length; --i; )
		{
			if (arr[i][0] === ' ' && arr[i - 1] === ' ')
			{
				arr[i - 1] = arr[i - 1] + arr[i];
				arr[i] = '';
			}
		}
		for (var i = arr.length; i--; )
		{
			if (arr[i].length > 1 && arr[i][0] === ' ')
			{
				var spaces = arr[i].split('');
				for (var j = spaces.length - 2; j >= 0; j -= 2)
				{
					spaces[j] = '&nbsp;';
				}
				arr[i] = spaces.join('');
			}
		}
		arr = arr.join('');
		if (arr[arr.length - 1] === ' ')
		{
			return arr.slice(0, -1) + '&nbsp;';
		}
		return arr;
	}


	return localRuntime.Native.Text.values = {
		fromString: fromString,
		append: F2(append),

		height: F2(height),
		italic: italic,
		bold: bold,
		line: F2(line),
		monospace: monospace,
		typeface: F2(typeface),
		color: F2(color),
		link: F2(link),
		style: F2(style),

		toTypefaces: toTypefaces,
		toLine: toLine,
		renderHtml: renderHtml
	};
};

Elm.Text = Elm.Text || {};
Elm.Text.make = function (_elm) {
   "use strict";
   _elm.Text = _elm.Text || {};
   if (_elm.Text.values) return _elm.Text.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Color = Elm.Color.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Text = Elm.Native.Text.make(_elm);
   var _op = {};
   var line = $Native$Text.line;
   var italic = $Native$Text.italic;
   var bold = $Native$Text.bold;
   var color = $Native$Text.color;
   var height = $Native$Text.height;
   var link = $Native$Text.link;
   var monospace = $Native$Text.monospace;
   var typeface = $Native$Text.typeface;
   var style = $Native$Text.style;
   var append = $Native$Text.append;
   var fromString = $Native$Text.fromString;
   var empty = fromString("");
   var concat = function (texts) {
      return A3($List.foldr,append,empty,texts);
   };
   var join = F2(function (seperator,texts) {
      return concat(A2($List.intersperse,seperator,texts));
   });
   var defaultStyle = {typeface: _U.list([])
                      ,height: $Maybe.Nothing
                      ,color: $Color.black
                      ,bold: false
                      ,italic: false
                      ,line: $Maybe.Nothing};
   var Style = F6(function (a,b,c,d,e,f) {
      return {typeface: a
             ,height: b
             ,color: c
             ,bold: d
             ,italic: e
             ,line: f};
   });
   var Through = {ctor: "Through"};
   var Over = {ctor: "Over"};
   var Under = {ctor: "Under"};
   var Text = {ctor: "Text"};
   return _elm.Text.values = {_op: _op
                             ,fromString: fromString
                             ,empty: empty
                             ,append: append
                             ,concat: concat
                             ,join: join
                             ,link: link
                             ,style: style
                             ,defaultStyle: defaultStyle
                             ,typeface: typeface
                             ,monospace: monospace
                             ,height: height
                             ,color: color
                             ,bold: bold
                             ,italic: italic
                             ,line: line
                             ,Style: Style
                             ,Under: Under
                             ,Over: Over
                             ,Through: Through};
};
Elm.Graphics = Elm.Graphics || {};
Elm.Graphics.Element = Elm.Graphics.Element || {};
Elm.Graphics.Element.make = function (_elm) {
   "use strict";
   _elm.Graphics = _elm.Graphics || {};
   _elm.Graphics.Element = _elm.Graphics.Element || {};
   if (_elm.Graphics.Element.values)
   return _elm.Graphics.Element.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Color = Elm.Color.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Graphics$Element = Elm.Native.Graphics.Element.make(_elm),
   $Text = Elm.Text.make(_elm);
   var _op = {};
   var DOut = {ctor: "DOut"};
   var outward = DOut;
   var DIn = {ctor: "DIn"};
   var inward = DIn;
   var DRight = {ctor: "DRight"};
   var right = DRight;
   var DLeft = {ctor: "DLeft"};
   var left = DLeft;
   var DDown = {ctor: "DDown"};
   var down = DDown;
   var DUp = {ctor: "DUp"};
   var up = DUp;
   var RawPosition = F4(function (a,b,c,d) {
      return {horizontal: a,vertical: b,x: c,y: d};
   });
   var Position = function (a) {
      return {ctor: "Position",_0: a};
   };
   var Relative = function (a) {
      return {ctor: "Relative",_0: a};
   };
   var relative = Relative;
   var Absolute = function (a) {
      return {ctor: "Absolute",_0: a};
   };
   var absolute = Absolute;
   var N = {ctor: "N"};
   var bottomLeft = Position({horizontal: N
                             ,vertical: N
                             ,x: Absolute(0)
                             ,y: Absolute(0)});
   var bottomLeftAt = F2(function (x,y) {
      return Position({horizontal: N,vertical: N,x: x,y: y});
   });
   var Z = {ctor: "Z"};
   var middle = Position({horizontal: Z
                         ,vertical: Z
                         ,x: Relative(0.5)
                         ,y: Relative(0.5)});
   var midLeft = Position({horizontal: N
                          ,vertical: Z
                          ,x: Absolute(0)
                          ,y: Relative(0.5)});
   var midBottom = Position({horizontal: Z
                            ,vertical: N
                            ,x: Relative(0.5)
                            ,y: Absolute(0)});
   var middleAt = F2(function (x,y) {
      return Position({horizontal: Z,vertical: Z,x: x,y: y});
   });
   var midLeftAt = F2(function (x,y) {
      return Position({horizontal: N,vertical: Z,x: x,y: y});
   });
   var midBottomAt = F2(function (x,y) {
      return Position({horizontal: Z,vertical: N,x: x,y: y});
   });
   var P = {ctor: "P"};
   var topLeft = Position({horizontal: N
                          ,vertical: P
                          ,x: Absolute(0)
                          ,y: Absolute(0)});
   var topRight = Position({horizontal: P
                           ,vertical: P
                           ,x: Absolute(0)
                           ,y: Absolute(0)});
   var bottomRight = Position({horizontal: P
                              ,vertical: N
                              ,x: Absolute(0)
                              ,y: Absolute(0)});
   var midRight = Position({horizontal: P
                           ,vertical: Z
                           ,x: Absolute(0)
                           ,y: Relative(0.5)});
   var midTop = Position({horizontal: Z
                         ,vertical: P
                         ,x: Relative(0.5)
                         ,y: Absolute(0)});
   var topLeftAt = F2(function (x,y) {
      return Position({horizontal: N,vertical: P,x: x,y: y});
   });
   var topRightAt = F2(function (x,y) {
      return Position({horizontal: P,vertical: P,x: x,y: y});
   });
   var bottomRightAt = F2(function (x,y) {
      return Position({horizontal: P,vertical: N,x: x,y: y});
   });
   var midRightAt = F2(function (x,y) {
      return Position({horizontal: P,vertical: Z,x: x,y: y});
   });
   var midTopAt = F2(function (x,y) {
      return Position({horizontal: Z,vertical: P,x: x,y: y});
   });
   var justified = $Native$Graphics$Element.block("justify");
   var centered = $Native$Graphics$Element.block("center");
   var rightAligned = $Native$Graphics$Element.block("right");
   var leftAligned = $Native$Graphics$Element.block("left");
   var show = function (value) {
      return leftAligned($Text.monospace($Text.fromString($Basics.toString(value))));
   };
   var Tiled = {ctor: "Tiled"};
   var Cropped = function (a) {
      return {ctor: "Cropped",_0: a};
   };
   var Fitted = {ctor: "Fitted"};
   var Plain = {ctor: "Plain"};
   var Custom = {ctor: "Custom"};
   var RawHtml = {ctor: "RawHtml"};
   var Spacer = {ctor: "Spacer"};
   var Flow = F2(function (a,b) {
      return {ctor: "Flow",_0: a,_1: b};
   });
   var Container = F2(function (a,b) {
      return {ctor: "Container",_0: a,_1: b};
   });
   var Image = F4(function (a,b,c,d) {
      return {ctor: "Image",_0: a,_1: b,_2: c,_3: d};
   });
   var newElement = $Native$Graphics$Element.newElement;
   var image = F3(function (w,h,src) {
      return A3(newElement,w,h,A4(Image,Plain,w,h,src));
   });
   var fittedImage = F3(function (w,h,src) {
      return A3(newElement,w,h,A4(Image,Fitted,w,h,src));
   });
   var croppedImage = F4(function (pos,w,h,src) {
      return A3(newElement,w,h,A4(Image,Cropped(pos),w,h,src));
   });
   var tiledImage = F3(function (w,h,src) {
      return A3(newElement,w,h,A4(Image,Tiled,w,h,src));
   });
   var container = F4(function (w,h,_p0,e) {
      var _p1 = _p0;
      return A3(newElement,w,h,A2(Container,_p1._0,e));
   });
   var spacer = F2(function (w,h) {
      return A3(newElement,w,h,Spacer);
   });
   var sizeOf = function (_p2) {
      var _p3 = _p2;
      var _p4 = _p3._0;
      return {ctor: "_Tuple2"
             ,_0: _p4.props.width
             ,_1: _p4.props.height};
   };
   var heightOf = function (_p5) {
      var _p6 = _p5;
      return _p6._0.props.height;
   };
   var widthOf = function (_p7) {
      var _p8 = _p7;
      return _p8._0.props.width;
   };
   var above = F2(function (hi,lo) {
      return A3(newElement,
      A2($Basics.max,widthOf(hi),widthOf(lo)),
      heightOf(hi) + heightOf(lo),
      A2(Flow,DDown,_U.list([hi,lo])));
   });
   var below = F2(function (lo,hi) {
      return A3(newElement,
      A2($Basics.max,widthOf(hi),widthOf(lo)),
      heightOf(hi) + heightOf(lo),
      A2(Flow,DDown,_U.list([hi,lo])));
   });
   var beside = F2(function (lft,rht) {
      return A3(newElement,
      widthOf(lft) + widthOf(rht),
      A2($Basics.max,heightOf(lft),heightOf(rht)),
      A2(Flow,right,_U.list([lft,rht])));
   });
   var layers = function (es) {
      var hs = A2($List.map,heightOf,es);
      var ws = A2($List.map,widthOf,es);
      return A3(newElement,
      A2($Maybe.withDefault,0,$List.maximum(ws)),
      A2($Maybe.withDefault,0,$List.maximum(hs)),
      A2(Flow,DOut,es));
   };
   var empty = A2(spacer,0,0);
   var flow = F2(function (dir,es) {
      var newFlow = F2(function (w,h) {
         return A3(newElement,w,h,A2(Flow,dir,es));
      });
      var maxOrZero = function (list) {
         return A2($Maybe.withDefault,0,$List.maximum(list));
      };
      var hs = A2($List.map,heightOf,es);
      var ws = A2($List.map,widthOf,es);
      if (_U.eq(es,_U.list([]))) return empty; else {
            var _p9 = dir;
            switch (_p9.ctor)
            {case "DUp": return A2(newFlow,maxOrZero(ws),$List.sum(hs));
               case "DDown": return A2(newFlow,maxOrZero(ws),$List.sum(hs));
               case "DLeft": return A2(newFlow,$List.sum(ws),maxOrZero(hs));
               case "DRight": return A2(newFlow,$List.sum(ws),maxOrZero(hs));
               case "DIn": return A2(newFlow,maxOrZero(ws),maxOrZero(hs));
               default: return A2(newFlow,maxOrZero(ws),maxOrZero(hs));}
         }
   });
   var Properties = F9(function (a,b,c,d,e,f,g,h,i) {
      return {id: a
             ,width: b
             ,height: c
             ,opacity: d
             ,color: e
             ,href: f
             ,tag: g
             ,hover: h
             ,click: i};
   });
   var Element_elm_builtin = function (a) {
      return {ctor: "Element_elm_builtin",_0: a};
   };
   var width = F2(function (newWidth,_p10) {
      var _p11 = _p10;
      var _p14 = _p11._0.props;
      var _p13 = _p11._0.element;
      var newHeight = function () {
         var _p12 = _p13;
         switch (_p12.ctor)
         {case "Image":
            return $Basics.round($Basics.toFloat(_p12._2) / $Basics.toFloat(_p12._1) * $Basics.toFloat(newWidth));
            case "RawHtml":
            return $Basics.snd(A2($Native$Graphics$Element.htmlHeight,
              newWidth,
              _p13));
            default: return _p14.height;}
      }();
      return Element_elm_builtin({element: _p13
                                 ,props: _U.update(_p14,{width: newWidth,height: newHeight})});
   });
   var height = F2(function (newHeight,_p15) {
      var _p16 = _p15;
      return Element_elm_builtin({element: _p16._0.element
                                 ,props: _U.update(_p16._0.props,{height: newHeight})});
   });
   var size = F3(function (w,h,e) {
      return A2(height,h,A2(width,w,e));
   });
   var opacity = F2(function (givenOpacity,_p17) {
      var _p18 = _p17;
      return Element_elm_builtin({element: _p18._0.element
                                 ,props: _U.update(_p18._0.props,{opacity: givenOpacity})});
   });
   var color = F2(function (clr,_p19) {
      var _p20 = _p19;
      return Element_elm_builtin({element: _p20._0.element
                                 ,props: _U.update(_p20._0.props,{color: $Maybe.Just(clr)})});
   });
   var tag = F2(function (name,_p21) {
      var _p22 = _p21;
      return Element_elm_builtin({element: _p22._0.element
                                 ,props: _U.update(_p22._0.props,{tag: name})});
   });
   var link = F2(function (href,_p23) {
      var _p24 = _p23;
      return Element_elm_builtin({element: _p24._0.element
                                 ,props: _U.update(_p24._0.props,{href: href})});
   });
   return _elm.Graphics.Element.values = {_op: _op
                                         ,image: image
                                         ,fittedImage: fittedImage
                                         ,croppedImage: croppedImage
                                         ,tiledImage: tiledImage
                                         ,leftAligned: leftAligned
                                         ,rightAligned: rightAligned
                                         ,centered: centered
                                         ,justified: justified
                                         ,show: show
                                         ,width: width
                                         ,height: height
                                         ,size: size
                                         ,color: color
                                         ,opacity: opacity
                                         ,link: link
                                         ,tag: tag
                                         ,widthOf: widthOf
                                         ,heightOf: heightOf
                                         ,sizeOf: sizeOf
                                         ,flow: flow
                                         ,up: up
                                         ,down: down
                                         ,left: left
                                         ,right: right
                                         ,inward: inward
                                         ,outward: outward
                                         ,layers: layers
                                         ,above: above
                                         ,below: below
                                         ,beside: beside
                                         ,empty: empty
                                         ,spacer: spacer
                                         ,container: container
                                         ,middle: middle
                                         ,midTop: midTop
                                         ,midBottom: midBottom
                                         ,midLeft: midLeft
                                         ,midRight: midRight
                                         ,topLeft: topLeft
                                         ,topRight: topRight
                                         ,bottomLeft: bottomLeft
                                         ,bottomRight: bottomRight
                                         ,absolute: absolute
                                         ,relative: relative
                                         ,middleAt: middleAt
                                         ,midTopAt: midTopAt
                                         ,midBottomAt: midBottomAt
                                         ,midLeftAt: midLeftAt
                                         ,midRightAt: midRightAt
                                         ,topLeftAt: topLeftAt
                                         ,topRightAt: topRightAt
                                         ,bottomLeftAt: bottomLeftAt
                                         ,bottomRightAt: bottomRightAt};
};
Elm.Graphics = Elm.Graphics || {};
Elm.Graphics.Collage = Elm.Graphics.Collage || {};
Elm.Graphics.Collage.make = function (_elm) {
   "use strict";
   _elm.Graphics = _elm.Graphics || {};
   _elm.Graphics.Collage = _elm.Graphics.Collage || {};
   if (_elm.Graphics.Collage.values)
   return _elm.Graphics.Collage.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Color = Elm.Color.make(_elm),
   $Graphics$Element = Elm.Graphics.Element.make(_elm),
   $List = Elm.List.make(_elm),
   $Native$Graphics$Collage = Elm.Native.Graphics.Collage.make(_elm),
   $Text = Elm.Text.make(_elm),
   $Transform2D = Elm.Transform2D.make(_elm);
   var _op = {};
   var Shape = function (a) {    return {ctor: "Shape",_0: a};};
   var polygon = function (points) {    return Shape(points);};
   var rect = F2(function (w,h) {
      var hh = h / 2;
      var hw = w / 2;
      return Shape(_U.list([{ctor: "_Tuple2",_0: 0 - hw,_1: 0 - hh}
                           ,{ctor: "_Tuple2",_0: 0 - hw,_1: hh}
                           ,{ctor: "_Tuple2",_0: hw,_1: hh}
                           ,{ctor: "_Tuple2",_0: hw,_1: 0 - hh}]));
   });
   var square = function (n) {    return A2(rect,n,n);};
   var oval = F2(function (w,h) {
      var hh = h / 2;
      var hw = w / 2;
      var n = 50;
      var t = 2 * $Basics.pi / n;
      var f = function (i) {
         return {ctor: "_Tuple2"
                ,_0: hw * $Basics.cos(t * i)
                ,_1: hh * $Basics.sin(t * i)};
      };
      return Shape(A2($List.map,f,_U.range(0,n - 1)));
   });
   var circle = function (r) {    return A2(oval,2 * r,2 * r);};
   var ngon = F2(function (n,r) {
      var m = $Basics.toFloat(n);
      var t = 2 * $Basics.pi / m;
      var f = function (i) {
         return {ctor: "_Tuple2"
                ,_0: r * $Basics.cos(t * i)
                ,_1: r * $Basics.sin(t * i)};
      };
      return Shape(A2($List.map,f,_U.range(0,m - 1)));
   });
   var Path = function (a) {    return {ctor: "Path",_0: a};};
   var path = function (ps) {    return Path(ps);};
   var segment = F2(function (p1,p2) {
      return Path(_U.list([p1,p2]));
   });
   var collage = $Native$Graphics$Collage.collage;
   var Fill = function (a) {    return {ctor: "Fill",_0: a};};
   var Line = function (a) {    return {ctor: "Line",_0: a};};
   var FGroup = F2(function (a,b) {
      return {ctor: "FGroup",_0: a,_1: b};
   });
   var FElement = function (a) {
      return {ctor: "FElement",_0: a};
   };
   var FImage = F4(function (a,b,c,d) {
      return {ctor: "FImage",_0: a,_1: b,_2: c,_3: d};
   });
   var FText = function (a) {    return {ctor: "FText",_0: a};};
   var FOutlinedText = F2(function (a,b) {
      return {ctor: "FOutlinedText",_0: a,_1: b};
   });
   var FShape = F2(function (a,b) {
      return {ctor: "FShape",_0: a,_1: b};
   });
   var FPath = F2(function (a,b) {
      return {ctor: "FPath",_0: a,_1: b};
   });
   var LineStyle = F6(function (a,b,c,d,e,f) {
      return {color: a
             ,width: b
             ,cap: c
             ,join: d
             ,dashing: e
             ,dashOffset: f};
   });
   var Clipped = {ctor: "Clipped"};
   var Sharp = function (a) {    return {ctor: "Sharp",_0: a};};
   var Smooth = {ctor: "Smooth"};
   var Padded = {ctor: "Padded"};
   var Round = {ctor: "Round"};
   var Flat = {ctor: "Flat"};
   var defaultLine = {color: $Color.black
                     ,width: 1
                     ,cap: Flat
                     ,join: Sharp(10)
                     ,dashing: _U.list([])
                     ,dashOffset: 0};
   var solid = function (clr) {
      return _U.update(defaultLine,{color: clr});
   };
   var dashed = function (clr) {
      return _U.update(defaultLine,
      {color: clr,dashing: _U.list([8,4])});
   };
   var dotted = function (clr) {
      return _U.update(defaultLine,
      {color: clr,dashing: _U.list([3,3])});
   };
   var Grad = function (a) {    return {ctor: "Grad",_0: a};};
   var Texture = function (a) {
      return {ctor: "Texture",_0: a};
   };
   var Solid = function (a) {    return {ctor: "Solid",_0: a};};
   var Form_elm_builtin = function (a) {
      return {ctor: "Form_elm_builtin",_0: a};
   };
   var form = function (f) {
      return Form_elm_builtin({theta: 0
                              ,scale: 1
                              ,x: 0
                              ,y: 0
                              ,alpha: 1
                              ,form: f});
   };
   var fill = F2(function (style,_p0) {
      var _p1 = _p0;
      return form(A2(FShape,Fill(style),_p1._0));
   });
   var filled = F2(function (color,shape) {
      return A2(fill,Solid(color),shape);
   });
   var textured = F2(function (src,shape) {
      return A2(fill,Texture(src),shape);
   });
   var gradient = F2(function (grad,shape) {
      return A2(fill,Grad(grad),shape);
   });
   var outlined = F2(function (style,_p2) {
      var _p3 = _p2;
      return form(A2(FShape,Line(style),_p3._0));
   });
   var traced = F2(function (style,_p4) {
      var _p5 = _p4;
      return form(A2(FPath,style,_p5._0));
   });
   var sprite = F4(function (w,h,pos,src) {
      return form(A4(FImage,w,h,pos,src));
   });
   var toForm = function (e) {    return form(FElement(e));};
   var group = function (fs) {
      return form(A2(FGroup,$Transform2D.identity,fs));
   };
   var groupTransform = F2(function (matrix,fs) {
      return form(A2(FGroup,matrix,fs));
   });
   var text = function (t) {    return form(FText(t));};
   var outlinedText = F2(function (ls,t) {
      return form(A2(FOutlinedText,ls,t));
   });
   var move = F2(function (_p7,_p6) {
      var _p8 = _p7;
      var _p9 = _p6;
      var _p10 = _p9._0;
      return Form_elm_builtin(_U.update(_p10,
      {x: _p10.x + _p8._0,y: _p10.y + _p8._1}));
   });
   var moveX = F2(function (x,_p11) {
      var _p12 = _p11;
      var _p13 = _p12._0;
      return Form_elm_builtin(_U.update(_p13,{x: _p13.x + x}));
   });
   var moveY = F2(function (y,_p14) {
      var _p15 = _p14;
      var _p16 = _p15._0;
      return Form_elm_builtin(_U.update(_p16,{y: _p16.y + y}));
   });
   var scale = F2(function (s,_p17) {
      var _p18 = _p17;
      var _p19 = _p18._0;
      return Form_elm_builtin(_U.update(_p19,
      {scale: _p19.scale * s}));
   });
   var rotate = F2(function (t,_p20) {
      var _p21 = _p20;
      var _p22 = _p21._0;
      return Form_elm_builtin(_U.update(_p22,
      {theta: _p22.theta + t}));
   });
   var alpha = F2(function (a,_p23) {
      var _p24 = _p23;
      return Form_elm_builtin(_U.update(_p24._0,{alpha: a}));
   });
   return _elm.Graphics.Collage.values = {_op: _op
                                         ,collage: collage
                                         ,toForm: toForm
                                         ,filled: filled
                                         ,textured: textured
                                         ,gradient: gradient
                                         ,outlined: outlined
                                         ,traced: traced
                                         ,text: text
                                         ,outlinedText: outlinedText
                                         ,move: move
                                         ,moveX: moveX
                                         ,moveY: moveY
                                         ,scale: scale
                                         ,rotate: rotate
                                         ,alpha: alpha
                                         ,group: group
                                         ,groupTransform: groupTransform
                                         ,rect: rect
                                         ,oval: oval
                                         ,square: square
                                         ,circle: circle
                                         ,ngon: ngon
                                         ,polygon: polygon
                                         ,segment: segment
                                         ,path: path
                                         ,solid: solid
                                         ,dashed: dashed
                                         ,dotted: dotted
                                         ,defaultLine: defaultLine
                                         ,LineStyle: LineStyle
                                         ,Flat: Flat
                                         ,Round: Round
                                         ,Padded: Padded
                                         ,Smooth: Smooth
                                         ,Sharp: Sharp
                                         ,Clipped: Clipped};
};
Elm.Native.Debug = {};
Elm.Native.Debug.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Debug = localRuntime.Native.Debug || {};
	if (localRuntime.Native.Debug.values)
	{
		return localRuntime.Native.Debug.values;
	}

	var toString = Elm.Native.Utils.make(localRuntime).toString;

	function log(tag, value)
	{
		var msg = tag + ': ' + toString(value);
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

	function tracePath(tag, form)
	{
		if (localRuntime.debug)
		{
			return localRuntime.debug.trace(tag, form);
		}
		return form;
	}

	function watch(tag, value)
	{
		if (localRuntime.debug)
		{
			localRuntime.debug.watch(tag, value);
		}
		return value;
	}

	function watchSummary(tag, summarize, value)
	{
		if (localRuntime.debug)
		{
			localRuntime.debug.watch(tag, summarize(value));
		}
		return value;
	}

	return localRuntime.Native.Debug.values = {
		crash: crash,
		tracePath: F2(tracePath),
		log: F2(log),
		watch: F2(watch),
		watchSummary: F3(watchSummary)
	};
};

Elm.Debug = Elm.Debug || {};
Elm.Debug.make = function (_elm) {
   "use strict";
   _elm.Debug = _elm.Debug || {};
   if (_elm.Debug.values) return _elm.Debug.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Graphics$Collage = Elm.Graphics.Collage.make(_elm),
   $Native$Debug = Elm.Native.Debug.make(_elm);
   var _op = {};
   var trace = $Native$Debug.tracePath;
   var watchSummary = $Native$Debug.watchSummary;
   var watch = $Native$Debug.watch;
   var crash = $Native$Debug.crash;
   var log = $Native$Debug.log;
   return _elm.Debug.values = {_op: _op
                              ,log: log
                              ,crash: crash
                              ,watch: watch
                              ,watchSummary: watchSummary
                              ,trace: trace};
};
Elm.Native.Task = {};

Elm.Native.Task.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Task = localRuntime.Native.Task || {};
	if (localRuntime.Native.Task.values)
	{
		return localRuntime.Native.Task.values;
	}

	var Result = Elm.Result.make(localRuntime);
	var Signal;
	var Utils = Elm.Native.Utils.make(localRuntime);


	// CONSTRUCTORS

	function succeed(value)
	{
		return {
			tag: 'Succeed',
			value: value
		};
	}

	function fail(error)
	{
		return {
			tag: 'Fail',
			value: error
		};
	}

	function asyncFunction(func)
	{
		return {
			tag: 'Async',
			asyncFunction: func
		};
	}

	function andThen(task, callback)
	{
		return {
			tag: 'AndThen',
			task: task,
			callback: callback
		};
	}

	function catch_(task, callback)
	{
		return {
			tag: 'Catch',
			task: task,
			callback: callback
		};
	}


	// RUNNER

	function perform(task) {
		runTask({ task: task }, function() {});
	}

	function performSignal(name, signal)
	{
		var workQueue = [];

		function onComplete()
		{
			workQueue.shift();

			if (workQueue.length > 0)
			{
				var task = workQueue[0];

				setTimeout(function() {
					runTask(task, onComplete);
				}, 0);
			}
		}

		function register(task)
		{
			var root = { task: task };
			workQueue.push(root);
			if (workQueue.length === 1)
			{
				runTask(root, onComplete);
			}
		}

		if (!Signal)
		{
			Signal = Elm.Native.Signal.make(localRuntime);
		}
		Signal.output('perform-tasks-' + name, register, signal);

		register(signal.value);

		return signal;
	}

	function mark(status, task)
	{
		return { status: status, task: task };
	}

	function runTask(root, onComplete)
	{
		var result = mark('runnable', root.task);
		while (result.status === 'runnable')
		{
			result = stepTask(onComplete, root, result.task);
		}

		if (result.status === 'done')
		{
			root.task = result.task;
			onComplete();
		}

		if (result.status === 'blocked')
		{
			root.task = result.task;
		}
	}

	function stepTask(onComplete, root, task)
	{
		var tag = task.tag;

		if (tag === 'Succeed' || tag === 'Fail')
		{
			return mark('done', task);
		}

		if (tag === 'Async')
		{
			var placeHolder = {};
			var couldBeSync = true;
			var wasSync = false;

			task.asyncFunction(function(result) {
				placeHolder.tag = result.tag;
				placeHolder.value = result.value;
				if (couldBeSync)
				{
					wasSync = true;
				}
				else
				{
					runTask(root, onComplete);
				}
			});
			couldBeSync = false;
			return mark(wasSync ? 'done' : 'blocked', placeHolder);
		}

		if (tag === 'AndThen' || tag === 'Catch')
		{
			var result = mark('runnable', task.task);
			while (result.status === 'runnable')
			{
				result = stepTask(onComplete, root, result.task);
			}

			if (result.status === 'done')
			{
				var activeTask = result.task;
				var activeTag = activeTask.tag;

				var succeedChain = activeTag === 'Succeed' && tag === 'AndThen';
				var failChain = activeTag === 'Fail' && tag === 'Catch';

				return (succeedChain || failChain)
					? mark('runnable', task.callback(activeTask.value))
					: mark('runnable', activeTask);
			}
			if (result.status === 'blocked')
			{
				return mark('blocked', {
					tag: tag,
					task: result.task,
					callback: task.callback
				});
			}
		}
	}


	// THREADS

	function sleep(time) {
		return asyncFunction(function(callback) {
			setTimeout(function() {
				callback(succeed(Utils.Tuple0));
			}, time);
		});
	}

	function spawn(task) {
		return asyncFunction(function(callback) {
			var id = setTimeout(function() {
				perform(task);
			}, 0);
			callback(succeed(id));
		});
	}


	return localRuntime.Native.Task.values = {
		succeed: succeed,
		fail: fail,
		asyncFunction: asyncFunction,
		andThen: F2(andThen),
		catch_: F2(catch_),
		perform: perform,
		performSignal: performSignal,
		spawn: spawn,
		sleep: sleep
	};
};

Elm.Result = Elm.Result || {};
Elm.Result.make = function (_elm) {
   "use strict";
   _elm.Result = _elm.Result || {};
   if (_elm.Result.values) return _elm.Result.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Maybe = Elm.Maybe.make(_elm);
   var _op = {};
   var toMaybe = function (result) {
      var _p0 = result;
      if (_p0.ctor === "Ok") {
            return $Maybe.Just(_p0._0);
         } else {
            return $Maybe.Nothing;
         }
   };
   var withDefault = F2(function (def,result) {
      var _p1 = result;
      if (_p1.ctor === "Ok") {
            return _p1._0;
         } else {
            return def;
         }
   });
   var Err = function (a) {    return {ctor: "Err",_0: a};};
   var andThen = F2(function (result,callback) {
      var _p2 = result;
      if (_p2.ctor === "Ok") {
            return callback(_p2._0);
         } else {
            return Err(_p2._0);
         }
   });
   var Ok = function (a) {    return {ctor: "Ok",_0: a};};
   var map = F2(function (func,ra) {
      var _p3 = ra;
      if (_p3.ctor === "Ok") {
            return Ok(func(_p3._0));
         } else {
            return Err(_p3._0);
         }
   });
   var map2 = F3(function (func,ra,rb) {
      var _p4 = {ctor: "_Tuple2",_0: ra,_1: rb};
      if (_p4._0.ctor === "Ok") {
            if (_p4._1.ctor === "Ok") {
                  return Ok(A2(func,_p4._0._0,_p4._1._0));
               } else {
                  return Err(_p4._1._0);
               }
         } else {
            return Err(_p4._0._0);
         }
   });
   var map3 = F4(function (func,ra,rb,rc) {
      var _p5 = {ctor: "_Tuple3",_0: ra,_1: rb,_2: rc};
      if (_p5._0.ctor === "Ok") {
            if (_p5._1.ctor === "Ok") {
                  if (_p5._2.ctor === "Ok") {
                        return Ok(A3(func,_p5._0._0,_p5._1._0,_p5._2._0));
                     } else {
                        return Err(_p5._2._0);
                     }
               } else {
                  return Err(_p5._1._0);
               }
         } else {
            return Err(_p5._0._0);
         }
   });
   var map4 = F5(function (func,ra,rb,rc,rd) {
      var _p6 = {ctor: "_Tuple4",_0: ra,_1: rb,_2: rc,_3: rd};
      if (_p6._0.ctor === "Ok") {
            if (_p6._1.ctor === "Ok") {
                  if (_p6._2.ctor === "Ok") {
                        if (_p6._3.ctor === "Ok") {
                              return Ok(A4(func,_p6._0._0,_p6._1._0,_p6._2._0,_p6._3._0));
                           } else {
                              return Err(_p6._3._0);
                           }
                     } else {
                        return Err(_p6._2._0);
                     }
               } else {
                  return Err(_p6._1._0);
               }
         } else {
            return Err(_p6._0._0);
         }
   });
   var map5 = F6(function (func,ra,rb,rc,rd,re) {
      var _p7 = {ctor: "_Tuple5"
                ,_0: ra
                ,_1: rb
                ,_2: rc
                ,_3: rd
                ,_4: re};
      if (_p7._0.ctor === "Ok") {
            if (_p7._1.ctor === "Ok") {
                  if (_p7._2.ctor === "Ok") {
                        if (_p7._3.ctor === "Ok") {
                              if (_p7._4.ctor === "Ok") {
                                    return Ok(A5(func,
                                    _p7._0._0,
                                    _p7._1._0,
                                    _p7._2._0,
                                    _p7._3._0,
                                    _p7._4._0));
                                 } else {
                                    return Err(_p7._4._0);
                                 }
                           } else {
                              return Err(_p7._3._0);
                           }
                     } else {
                        return Err(_p7._2._0);
                     }
               } else {
                  return Err(_p7._1._0);
               }
         } else {
            return Err(_p7._0._0);
         }
   });
   var formatError = F2(function (f,result) {
      var _p8 = result;
      if (_p8.ctor === "Ok") {
            return Ok(_p8._0);
         } else {
            return Err(f(_p8._0));
         }
   });
   var fromMaybe = F2(function (err,maybe) {
      var _p9 = maybe;
      if (_p9.ctor === "Just") {
            return Ok(_p9._0);
         } else {
            return Err(err);
         }
   });
   return _elm.Result.values = {_op: _op
                               ,withDefault: withDefault
                               ,map: map
                               ,map2: map2
                               ,map3: map3
                               ,map4: map4
                               ,map5: map5
                               ,andThen: andThen
                               ,toMaybe: toMaybe
                               ,fromMaybe: fromMaybe
                               ,formatError: formatError
                               ,Ok: Ok
                               ,Err: Err};
};
Elm.Task = Elm.Task || {};
Elm.Task.make = function (_elm) {
   "use strict";
   _elm.Task = _elm.Task || {};
   if (_elm.Task.values) return _elm.Task.values;
   var _U = Elm.Native.Utils.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Task = Elm.Native.Task.make(_elm),
   $Result = Elm.Result.make(_elm);
   var _op = {};
   var sleep = $Native$Task.sleep;
   var spawn = $Native$Task.spawn;
   var ThreadID = function (a) {
      return {ctor: "ThreadID",_0: a};
   };
   var onError = $Native$Task.catch_;
   var andThen = $Native$Task.andThen;
   var fail = $Native$Task.fail;
   var mapError = F2(function (f,task) {
      return A2(onError,
      task,
      function (err) {
         return fail(f(err));
      });
   });
   var succeed = $Native$Task.succeed;
   var map = F2(function (func,taskA) {
      return A2(andThen,
      taskA,
      function (a) {
         return succeed(func(a));
      });
   });
   var map2 = F3(function (func,taskA,taskB) {
      return A2(andThen,
      taskA,
      function (a) {
         return A2(andThen,
         taskB,
         function (b) {
            return succeed(A2(func,a,b));
         });
      });
   });
   var map3 = F4(function (func,taskA,taskB,taskC) {
      return A2(andThen,
      taskA,
      function (a) {
         return A2(andThen,
         taskB,
         function (b) {
            return A2(andThen,
            taskC,
            function (c) {
               return succeed(A3(func,a,b,c));
            });
         });
      });
   });
   var map4 = F5(function (func,taskA,taskB,taskC,taskD) {
      return A2(andThen,
      taskA,
      function (a) {
         return A2(andThen,
         taskB,
         function (b) {
            return A2(andThen,
            taskC,
            function (c) {
               return A2(andThen,
               taskD,
               function (d) {
                  return succeed(A4(func,a,b,c,d));
               });
            });
         });
      });
   });
   var map5 = F6(function (func,taskA,taskB,taskC,taskD,taskE) {
      return A2(andThen,
      taskA,
      function (a) {
         return A2(andThen,
         taskB,
         function (b) {
            return A2(andThen,
            taskC,
            function (c) {
               return A2(andThen,
               taskD,
               function (d) {
                  return A2(andThen,
                  taskE,
                  function (e) {
                     return succeed(A5(func,a,b,c,d,e));
                  });
               });
            });
         });
      });
   });
   var andMap = F2(function (taskFunc,taskValue) {
      return A2(andThen,
      taskFunc,
      function (func) {
         return A2(andThen,
         taskValue,
         function (value) {
            return succeed(func(value));
         });
      });
   });
   var sequence = function (tasks) {
      var _p0 = tasks;
      if (_p0.ctor === "[]") {
            return succeed(_U.list([]));
         } else {
            return A3(map2,
            F2(function (x,y) {    return A2($List._op["::"],x,y);}),
            _p0._0,
            sequence(_p0._1));
         }
   };
   var toMaybe = function (task) {
      return A2(onError,
      A2(map,$Maybe.Just,task),
      function (_p1) {
         return succeed($Maybe.Nothing);
      });
   };
   var fromMaybe = F2(function ($default,maybe) {
      var _p2 = maybe;
      if (_p2.ctor === "Just") {
            return succeed(_p2._0);
         } else {
            return fail($default);
         }
   });
   var toResult = function (task) {
      return A2(onError,
      A2(map,$Result.Ok,task),
      function (msg) {
         return succeed($Result.Err(msg));
      });
   };
   var fromResult = function (result) {
      var _p3 = result;
      if (_p3.ctor === "Ok") {
            return succeed(_p3._0);
         } else {
            return fail(_p3._0);
         }
   };
   var Task = {ctor: "Task"};
   return _elm.Task.values = {_op: _op
                             ,succeed: succeed
                             ,fail: fail
                             ,map: map
                             ,map2: map2
                             ,map3: map3
                             ,map4: map4
                             ,map5: map5
                             ,andMap: andMap
                             ,sequence: sequence
                             ,andThen: andThen
                             ,onError: onError
                             ,mapError: mapError
                             ,toMaybe: toMaybe
                             ,fromMaybe: fromMaybe
                             ,toResult: toResult
                             ,fromResult: fromResult
                             ,spawn: spawn
                             ,sleep: sleep};
};
Elm.Signal = Elm.Signal || {};
Elm.Signal.make = function (_elm) {
   "use strict";
   _elm.Signal = _elm.Signal || {};
   if (_elm.Signal.values) return _elm.Signal.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Signal = Elm.Native.Signal.make(_elm),
   $Task = Elm.Task.make(_elm);
   var _op = {};
   var send = F2(function (_p0,value) {
      var _p1 = _p0;
      return A2($Task.onError,
      _p1._0(value),
      function (_p2) {
         return $Task.succeed({ctor: "_Tuple0"});
      });
   });
   var Message = function (a) {
      return {ctor: "Message",_0: a};
   };
   var message = F2(function (_p3,value) {
      var _p4 = _p3;
      return Message(_p4._0(value));
   });
   var mailbox = $Native$Signal.mailbox;
   var Address = function (a) {
      return {ctor: "Address",_0: a};
   };
   var forwardTo = F2(function (_p5,f) {
      var _p6 = _p5;
      return Address(function (x) {    return _p6._0(f(x));});
   });
   var Mailbox = F2(function (a,b) {
      return {address: a,signal: b};
   });
   var sampleOn = $Native$Signal.sampleOn;
   var dropRepeats = $Native$Signal.dropRepeats;
   var filterMap = $Native$Signal.filterMap;
   var filter = F3(function (isOk,base,signal) {
      return A3(filterMap,
      function (value) {
         return isOk(value) ? $Maybe.Just(value) : $Maybe.Nothing;
      },
      base,
      signal);
   });
   var merge = F2(function (left,right) {
      return A3($Native$Signal.genericMerge,
      $Basics.always,
      left,
      right);
   });
   var mergeMany = function (signalList) {
      var _p7 = $List.reverse(signalList);
      if (_p7.ctor === "[]") {
            return _U.crashCase("Signal",
            {start: {line: 184,column: 3},end: {line: 189,column: 40}},
            _p7)("mergeMany was given an empty list!");
         } else {
            return A3($List.foldl,merge,_p7._0,_p7._1);
         }
   };
   var foldp = $Native$Signal.foldp;
   var map5 = $Native$Signal.map5;
   var map4 = $Native$Signal.map4;
   var map3 = $Native$Signal.map3;
   var map2 = $Native$Signal.map2;
   var map = $Native$Signal.map;
   var constant = $Native$Signal.constant;
   var Signal = {ctor: "Signal"};
   return _elm.Signal.values = {_op: _op
                               ,merge: merge
                               ,mergeMany: mergeMany
                               ,map: map
                               ,map2: map2
                               ,map3: map3
                               ,map4: map4
                               ,map5: map5
                               ,constant: constant
                               ,dropRepeats: dropRepeats
                               ,filter: filter
                               ,filterMap: filterMap
                               ,sampleOn: sampleOn
                               ,foldp: foldp
                               ,mailbox: mailbox
                               ,send: send
                               ,message: message
                               ,forwardTo: forwardTo
                               ,Mailbox: Mailbox};
};
Elm.Native.String = {};

Elm.Native.String.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.String = localRuntime.Native.String || {};
	if (localRuntime.Native.String.values)
	{
		return localRuntime.Native.String.values;
	}
	if ('values' in Elm.Native.String)
	{
		return localRuntime.Native.String.values = Elm.Native.String.values;
	}


	var Char = Elm.Char.make(localRuntime);
	var List = Elm.Native.List.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);
	var Result = Elm.Result.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);

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
			return Maybe.Just(Utils.Tuple2(Utils.chr(hd), str.slice(1)));
		}
		return Maybe.Nothing;
	}
	function append(a, b)
	{
		return a + b;
	}
	function concat(strs)
	{
		return List.toArray(strs).join('');
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
			out[i] = f(Utils.chr(out[i]));
		}
		return out.join('');
	}
	function filter(pred, str)
	{
		return str.split('').map(Utils.chr).filter(pred).join('');
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
			b = A2(f, Utils.chr(str[i]), b);
		}
		return b;
	}
	function foldr(f, b, str)
	{
		for (var i = str.length; i--; )
		{
			b = A2(f, Utils.chr(str[i]), b);
		}
		return b;
	}
	function split(sep, str)
	{
		return List.fromArray(str.split(sep));
	}
	function join(sep, strs)
	{
		return List.toArray(strs).join(sep);
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
		return List.fromArray(str.trim().split(/\s+/g));
	}
	function lines(str)
	{
		return List.fromArray(str.split(/\r\n|\r|\n/g));
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
			if (pred(Utils.chr(str[i])))
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
			if (!pred(Utils.chr(str[i])))
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
		return List.fromArray(is);
	}

	function toInt(s)
	{
		var len = s.length;
		if (len === 0)
		{
			return Result.Err("could not convert string '" + s + "' to an Int" );
		}
		var start = 0;
		if (s[0] === '-')
		{
			if (len === 1)
			{
				return Result.Err("could not convert string '" + s + "' to an Int" );
			}
			start = 1;
		}
		for (var i = start; i < len; ++i)
		{
			if (!Char.isDigit(s[i]))
			{
				return Result.Err("could not convert string '" + s + "' to an Int" );
			}
		}
		return Result.Ok(parseInt(s, 10));
	}

	function toFloat(s)
	{
		var len = s.length;
		if (len === 0)
		{
			return Result.Err("could not convert string '" + s + "' to a Float" );
		}
		var start = 0;
		if (s[0] === '-')
		{
			if (len === 1)
			{
				return Result.Err("could not convert string '" + s + "' to a Float" );
			}
			start = 1;
		}
		var dotCount = 0;
		for (var i = start; i < len; ++i)
		{
			if (Char.isDigit(s[i]))
			{
				continue;
			}
			if (s[i] === '.')
			{
				dotCount += 1;
				if (dotCount <= 1)
				{
					continue;
				}
			}
			return Result.Err("could not convert string '" + s + "' to a Float" );
		}
		return Result.Ok(parseFloat(s));
	}

	function toList(str)
	{
		return List.fromArray(str.split('').map(Utils.chr));
	}
	function fromList(chars)
	{
		return List.toArray(chars).join('');
	}

	return Elm.Native.String.values = {
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
};

Elm.String = Elm.String || {};
Elm.String.make = function (_elm) {
   "use strict";
   _elm.String = _elm.String || {};
   if (_elm.String.values) return _elm.String.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$String = Elm.Native.String.make(_elm),
   $Result = Elm.Result.make(_elm);
   var _op = {};
   var fromList = $Native$String.fromList;
   var toList = $Native$String.toList;
   var toFloat = $Native$String.toFloat;
   var toInt = $Native$String.toInt;
   var indices = $Native$String.indexes;
   var indexes = $Native$String.indexes;
   var endsWith = $Native$String.endsWith;
   var startsWith = $Native$String.startsWith;
   var contains = $Native$String.contains;
   var all = $Native$String.all;
   var any = $Native$String.any;
   var toLower = $Native$String.toLower;
   var toUpper = $Native$String.toUpper;
   var lines = $Native$String.lines;
   var words = $Native$String.words;
   var trimRight = $Native$String.trimRight;
   var trimLeft = $Native$String.trimLeft;
   var trim = $Native$String.trim;
   var padRight = $Native$String.padRight;
   var padLeft = $Native$String.padLeft;
   var pad = $Native$String.pad;
   var dropRight = $Native$String.dropRight;
   var dropLeft = $Native$String.dropLeft;
   var right = $Native$String.right;
   var left = $Native$String.left;
   var slice = $Native$String.slice;
   var repeat = $Native$String.repeat;
   var join = $Native$String.join;
   var split = $Native$String.split;
   var foldr = $Native$String.foldr;
   var foldl = $Native$String.foldl;
   var reverse = $Native$String.reverse;
   var filter = $Native$String.filter;
   var map = $Native$String.map;
   var length = $Native$String.length;
   var concat = $Native$String.concat;
   var append = $Native$String.append;
   var uncons = $Native$String.uncons;
   var cons = $Native$String.cons;
   var fromChar = function ($char) {    return A2(cons,$char,"");};
   var isEmpty = $Native$String.isEmpty;
   return _elm.String.values = {_op: _op
                               ,isEmpty: isEmpty
                               ,length: length
                               ,reverse: reverse
                               ,repeat: repeat
                               ,cons: cons
                               ,uncons: uncons
                               ,fromChar: fromChar
                               ,append: append
                               ,concat: concat
                               ,split: split
                               ,join: join
                               ,words: words
                               ,lines: lines
                               ,slice: slice
                               ,left: left
                               ,right: right
                               ,dropLeft: dropLeft
                               ,dropRight: dropRight
                               ,contains: contains
                               ,startsWith: startsWith
                               ,endsWith: endsWith
                               ,indexes: indexes
                               ,indices: indices
                               ,toInt: toInt
                               ,toFloat: toFloat
                               ,toList: toList
                               ,fromList: fromList
                               ,toUpper: toUpper
                               ,toLower: toLower
                               ,pad: pad
                               ,padLeft: padLeft
                               ,padRight: padRight
                               ,trim: trim
                               ,trimLeft: trimLeft
                               ,trimRight: trimRight
                               ,map: map
                               ,filter: filter
                               ,foldl: foldl
                               ,foldr: foldr
                               ,any: any
                               ,all: all};
};
Elm.Dict = Elm.Dict || {};
Elm.Dict.make = function (_elm) {
   "use strict";
   _elm.Dict = _elm.Dict || {};
   if (_elm.Dict.values) return _elm.Dict.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Debug = Elm.Native.Debug.make(_elm),
   $String = Elm.String.make(_elm);
   var _op = {};
   var foldr = F3(function (f,acc,t) {
      foldr: while (true) {
         var _p0 = t;
         if (_p0.ctor === "RBEmpty_elm_builtin") {
               return acc;
            } else {
               var _v1 = f,
               _v2 = A3(f,_p0._1,_p0._2,A3(foldr,f,acc,_p0._4)),
               _v3 = _p0._3;
               f = _v1;
               acc = _v2;
               t = _v3;
               continue foldr;
            }
      }
   });
   var keys = function (dict) {
      return A3(foldr,
      F3(function (key,value,keyList) {
         return A2($List._op["::"],key,keyList);
      }),
      _U.list([]),
      dict);
   };
   var values = function (dict) {
      return A3(foldr,
      F3(function (key,value,valueList) {
         return A2($List._op["::"],value,valueList);
      }),
      _U.list([]),
      dict);
   };
   var toList = function (dict) {
      return A3(foldr,
      F3(function (key,value,list) {
         return A2($List._op["::"],
         {ctor: "_Tuple2",_0: key,_1: value},
         list);
      }),
      _U.list([]),
      dict);
   };
   var foldl = F3(function (f,acc,dict) {
      foldl: while (true) {
         var _p1 = dict;
         if (_p1.ctor === "RBEmpty_elm_builtin") {
               return acc;
            } else {
               var _v5 = f,
               _v6 = A3(f,_p1._1,_p1._2,A3(foldl,f,acc,_p1._3)),
               _v7 = _p1._4;
               f = _v5;
               acc = _v6;
               dict = _v7;
               continue foldl;
            }
      }
   });
   var reportRemBug = F4(function (msg,c,lgot,rgot) {
      return $Native$Debug.crash($String.concat(_U.list(["Internal red-black tree invariant violated, expected "
                                                        ,msg
                                                        ," and got "
                                                        ,$Basics.toString(c)
                                                        ,"/"
                                                        ,lgot
                                                        ,"/"
                                                        ,rgot
                                                        ,"\nPlease report this bug to <https://github.com/elm-lang/core/issues>"])));
   });
   var isBBlack = function (dict) {
      var _p2 = dict;
      _v8_2: do {
         if (_p2.ctor === "RBNode_elm_builtin") {
               if (_p2._0.ctor === "BBlack") {
                     return true;
                  } else {
                     break _v8_2;
                  }
            } else {
               if (_p2._0.ctor === "LBBlack") {
                     return true;
                  } else {
                     break _v8_2;
                  }
            }
      } while (false);
      return false;
   };
   var Same = {ctor: "Same"};
   var Remove = {ctor: "Remove"};
   var Insert = {ctor: "Insert"};
   var sizeHelp = F2(function (n,dict) {
      sizeHelp: while (true) {
         var _p3 = dict;
         if (_p3.ctor === "RBEmpty_elm_builtin") {
               return n;
            } else {
               var _v10 = A2(sizeHelp,n + 1,_p3._4),_v11 = _p3._3;
               n = _v10;
               dict = _v11;
               continue sizeHelp;
            }
      }
   });
   var size = function (dict) {    return A2(sizeHelp,0,dict);};
   var get = F2(function (targetKey,dict) {
      get: while (true) {
         var _p4 = dict;
         if (_p4.ctor === "RBEmpty_elm_builtin") {
               return $Maybe.Nothing;
            } else {
               var _p5 = A2($Basics.compare,targetKey,_p4._1);
               switch (_p5.ctor)
               {case "LT": var _v14 = targetKey,_v15 = _p4._3;
                    targetKey = _v14;
                    dict = _v15;
                    continue get;
                  case "EQ": return $Maybe.Just(_p4._2);
                  default: var _v16 = targetKey,_v17 = _p4._4;
                    targetKey = _v16;
                    dict = _v17;
                    continue get;}
            }
      }
   });
   var member = F2(function (key,dict) {
      var _p6 = A2(get,key,dict);
      if (_p6.ctor === "Just") {
            return true;
         } else {
            return false;
         }
   });
   var maxWithDefault = F3(function (k,v,r) {
      maxWithDefault: while (true) {
         var _p7 = r;
         if (_p7.ctor === "RBEmpty_elm_builtin") {
               return {ctor: "_Tuple2",_0: k,_1: v};
            } else {
               var _v20 = _p7._1,_v21 = _p7._2,_v22 = _p7._4;
               k = _v20;
               v = _v21;
               r = _v22;
               continue maxWithDefault;
            }
      }
   });
   var RBEmpty_elm_builtin = function (a) {
      return {ctor: "RBEmpty_elm_builtin",_0: a};
   };
   var RBNode_elm_builtin = F5(function (a,b,c,d,e) {
      return {ctor: "RBNode_elm_builtin"
             ,_0: a
             ,_1: b
             ,_2: c
             ,_3: d
             ,_4: e};
   });
   var LBBlack = {ctor: "LBBlack"};
   var LBlack = {ctor: "LBlack"};
   var empty = RBEmpty_elm_builtin(LBlack);
   var isEmpty = function (dict) {    return _U.eq(dict,empty);};
   var map = F2(function (f,dict) {
      var _p8 = dict;
      if (_p8.ctor === "RBEmpty_elm_builtin") {
            return RBEmpty_elm_builtin(LBlack);
         } else {
            var _p9 = _p8._1;
            return A5(RBNode_elm_builtin,
            _p8._0,
            _p9,
            A2(f,_p9,_p8._2),
            A2(map,f,_p8._3),
            A2(map,f,_p8._4));
         }
   });
   var NBlack = {ctor: "NBlack"};
   var BBlack = {ctor: "BBlack"};
   var Black = {ctor: "Black"};
   var ensureBlackRoot = function (dict) {
      var _p10 = dict;
      if (_p10.ctor === "RBNode_elm_builtin" && _p10._0.ctor === "Red")
      {
            return A5(RBNode_elm_builtin,
            Black,
            _p10._1,
            _p10._2,
            _p10._3,
            _p10._4);
         } else {
            return dict;
         }
   };
   var blackish = function (t) {
      var _p11 = t;
      if (_p11.ctor === "RBNode_elm_builtin") {
            var _p12 = _p11._0;
            return _U.eq(_p12,Black) || _U.eq(_p12,BBlack);
         } else {
            return true;
         }
   };
   var blacken = function (t) {
      var _p13 = t;
      if (_p13.ctor === "RBEmpty_elm_builtin") {
            return RBEmpty_elm_builtin(LBlack);
         } else {
            return A5(RBNode_elm_builtin,
            Black,
            _p13._1,
            _p13._2,
            _p13._3,
            _p13._4);
         }
   };
   var Red = {ctor: "Red"};
   var moreBlack = function (color) {
      var _p14 = color;
      switch (_p14.ctor)
      {case "Black": return BBlack;
         case "Red": return Black;
         case "NBlack": return Red;
         default:
         return $Native$Debug.crash("Can\'t make a double black node more black!");}
   };
   var lessBlack = function (color) {
      var _p15 = color;
      switch (_p15.ctor)
      {case "BBlack": return Black;
         case "Black": return Red;
         case "Red": return NBlack;
         default:
         return $Native$Debug.crash("Can\'t make a negative black node less black!");}
   };
   var lessBlackTree = function (dict) {
      var _p16 = dict;
      if (_p16.ctor === "RBNode_elm_builtin") {
            return A5(RBNode_elm_builtin,
            lessBlack(_p16._0),
            _p16._1,
            _p16._2,
            _p16._3,
            _p16._4);
         } else {
            return RBEmpty_elm_builtin(LBlack);
         }
   };
   var balancedTree = function (col) {
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
                                    return A5(RBNode_elm_builtin,
                                    lessBlack(col),
                                    yk,
                                    yv,
                                    A5(RBNode_elm_builtin,Black,xk,xv,a,b),
                                    A5(RBNode_elm_builtin,Black,zk,zv,c,d));
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
   var redden = function (t) {
      var _p17 = t;
      if (_p17.ctor === "RBEmpty_elm_builtin") {
            return $Native$Debug.crash("can\'t make a Leaf red");
         } else {
            return A5(RBNode_elm_builtin,
            Red,
            _p17._1,
            _p17._2,
            _p17._3,
            _p17._4);
         }
   };
   var balanceHelp = function (tree) {
      var _p18 = tree;
      _v31_6: do {
         _v31_5: do {
            _v31_4: do {
               _v31_3: do {
                  _v31_2: do {
                     _v31_1: do {
                        _v31_0: do {
                           if (_p18.ctor === "RBNode_elm_builtin") {
                                 if (_p18._3.ctor === "RBNode_elm_builtin") {
                                       if (_p18._4.ctor === "RBNode_elm_builtin") {
                                             switch (_p18._3._0.ctor)
                                             {case "Red": switch (_p18._4._0.ctor)
                                                  {case "Red":
                                                     if (_p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Red")
                                                       {
                                                             break _v31_0;
                                                          } else {
                                                             if (_p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Red")
                                                             {
                                                                   break _v31_1;
                                                                } else {
                                                                   if (_p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Red")
                                                                   {
                                                                         break _v31_2;
                                                                      } else {
                                                                         if (_p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Red")
                                                                         {
                                                                               break _v31_3;
                                                                            } else {
                                                                               break _v31_6;
                                                                            }
                                                                      }
                                                                }
                                                          }
                                                     case "NBlack":
                                                     if (_p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Red")
                                                       {
                                                             break _v31_0;
                                                          } else {
                                                             if (_p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Red")
                                                             {
                                                                   break _v31_1;
                                                                } else {
                                                                   if (_p18._0.ctor === "BBlack" && _p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Black" && _p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Black")
                                                                   {
                                                                         break _v31_4;
                                                                      } else {
                                                                         break _v31_6;
                                                                      }
                                                                }
                                                          }
                                                     default:
                                                     if (_p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Red")
                                                       {
                                                             break _v31_0;
                                                          } else {
                                                             if (_p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Red")
                                                             {
                                                                   break _v31_1;
                                                                } else {
                                                                   break _v31_6;
                                                                }
                                                          }}
                                                case "NBlack": switch (_p18._4._0.ctor)
                                                  {case "Red":
                                                     if (_p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Red")
                                                       {
                                                             break _v31_2;
                                                          } else {
                                                             if (_p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Red")
                                                             {
                                                                   break _v31_3;
                                                                } else {
                                                                   if (_p18._0.ctor === "BBlack" && _p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Black" && _p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Black")
                                                                   {
                                                                         break _v31_5;
                                                                      } else {
                                                                         break _v31_6;
                                                                      }
                                                                }
                                                          }
                                                     case "NBlack": if (_p18._0.ctor === "BBlack") {
                                                             if (_p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Black" && _p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Black")
                                                             {
                                                                   break _v31_4;
                                                                } else {
                                                                   if (_p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Black" && _p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Black")
                                                                   {
                                                                         break _v31_5;
                                                                      } else {
                                                                         break _v31_6;
                                                                      }
                                                                }
                                                          } else {
                                                             break _v31_6;
                                                          }
                                                     default:
                                                     if (_p18._0.ctor === "BBlack" && _p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Black" && _p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Black")
                                                       {
                                                             break _v31_5;
                                                          } else {
                                                             break _v31_6;
                                                          }}
                                                default: switch (_p18._4._0.ctor)
                                                  {case "Red":
                                                     if (_p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Red")
                                                       {
                                                             break _v31_2;
                                                          } else {
                                                             if (_p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Red")
                                                             {
                                                                   break _v31_3;
                                                                } else {
                                                                   break _v31_6;
                                                                }
                                                          }
                                                     case "NBlack":
                                                     if (_p18._0.ctor === "BBlack" && _p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Black" && _p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Black")
                                                       {
                                                             break _v31_4;
                                                          } else {
                                                             break _v31_6;
                                                          }
                                                     default: break _v31_6;}}
                                          } else {
                                             switch (_p18._3._0.ctor)
                                             {case "Red":
                                                if (_p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Red")
                                                  {
                                                        break _v31_0;
                                                     } else {
                                                        if (_p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Red")
                                                        {
                                                              break _v31_1;
                                                           } else {
                                                              break _v31_6;
                                                           }
                                                     }
                                                case "NBlack":
                                                if (_p18._0.ctor === "BBlack" && _p18._3._3.ctor === "RBNode_elm_builtin" && _p18._3._3._0.ctor === "Black" && _p18._3._4.ctor === "RBNode_elm_builtin" && _p18._3._4._0.ctor === "Black")
                                                  {
                                                        break _v31_5;
                                                     } else {
                                                        break _v31_6;
                                                     }
                                                default: break _v31_6;}
                                          }
                                    } else {
                                       if (_p18._4.ctor === "RBNode_elm_builtin") {
                                             switch (_p18._4._0.ctor)
                                             {case "Red":
                                                if (_p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Red")
                                                  {
                                                        break _v31_2;
                                                     } else {
                                                        if (_p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Red")
                                                        {
                                                              break _v31_3;
                                                           } else {
                                                              break _v31_6;
                                                           }
                                                     }
                                                case "NBlack":
                                                if (_p18._0.ctor === "BBlack" && _p18._4._3.ctor === "RBNode_elm_builtin" && _p18._4._3._0.ctor === "Black" && _p18._4._4.ctor === "RBNode_elm_builtin" && _p18._4._4._0.ctor === "Black")
                                                  {
                                                        break _v31_4;
                                                     } else {
                                                        break _v31_6;
                                                     }
                                                default: break _v31_6;}
                                          } else {
                                             break _v31_6;
                                          }
                                    }
                              } else {
                                 break _v31_6;
                              }
                        } while (false);
                        return balancedTree(_p18._0)(_p18._3._3._1)(_p18._3._3._2)(_p18._3._1)(_p18._3._2)(_p18._1)(_p18._2)(_p18._3._3._3)(_p18._3._3._4)(_p18._3._4)(_p18._4);
                     } while (false);
                     return balancedTree(_p18._0)(_p18._3._1)(_p18._3._2)(_p18._3._4._1)(_p18._3._4._2)(_p18._1)(_p18._2)(_p18._3._3)(_p18._3._4._3)(_p18._3._4._4)(_p18._4);
                  } while (false);
                  return balancedTree(_p18._0)(_p18._1)(_p18._2)(_p18._4._3._1)(_p18._4._3._2)(_p18._4._1)(_p18._4._2)(_p18._3)(_p18._4._3._3)(_p18._4._3._4)(_p18._4._4);
               } while (false);
               return balancedTree(_p18._0)(_p18._1)(_p18._2)(_p18._4._1)(_p18._4._2)(_p18._4._4._1)(_p18._4._4._2)(_p18._3)(_p18._4._3)(_p18._4._4._3)(_p18._4._4._4);
            } while (false);
            return A5(RBNode_elm_builtin,
            Black,
            _p18._4._3._1,
            _p18._4._3._2,
            A5(RBNode_elm_builtin,
            Black,
            _p18._1,
            _p18._2,
            _p18._3,
            _p18._4._3._3),
            A5(balance,
            Black,
            _p18._4._1,
            _p18._4._2,
            _p18._4._3._4,
            redden(_p18._4._4)));
         } while (false);
         return A5(RBNode_elm_builtin,
         Black,
         _p18._3._4._1,
         _p18._3._4._2,
         A5(balance,
         Black,
         _p18._3._1,
         _p18._3._2,
         redden(_p18._3._3),
         _p18._3._4._3),
         A5(RBNode_elm_builtin,
         Black,
         _p18._1,
         _p18._2,
         _p18._3._4._4,
         _p18._4));
      } while (false);
      return tree;
   };
   var balance = F5(function (c,k,v,l,r) {
      var tree = A5(RBNode_elm_builtin,c,k,v,l,r);
      return blackish(tree) ? balanceHelp(tree) : tree;
   });
   var bubble = F5(function (c,k,v,l,r) {
      return isBBlack(l) || isBBlack(r) ? A5(balance,
      moreBlack(c),
      k,
      v,
      lessBlackTree(l),
      lessBlackTree(r)) : A5(RBNode_elm_builtin,c,k,v,l,r);
   });
   var removeMax = F5(function (c,k,v,l,r) {
      var _p19 = r;
      if (_p19.ctor === "RBEmpty_elm_builtin") {
            return A3(rem,c,l,r);
         } else {
            return A5(bubble,
            c,
            k,
            v,
            l,
            A5(removeMax,_p19._0,_p19._1,_p19._2,_p19._3,_p19._4));
         }
   });
   var rem = F3(function (c,l,r) {
      var _p20 = {ctor: "_Tuple2",_0: l,_1: r};
      if (_p20._0.ctor === "RBEmpty_elm_builtin") {
            if (_p20._1.ctor === "RBEmpty_elm_builtin") {
                  var _p21 = c;
                  switch (_p21.ctor)
                  {case "Red": return RBEmpty_elm_builtin(LBlack);
                     case "Black": return RBEmpty_elm_builtin(LBBlack);
                     default:
                     return $Native$Debug.crash("cannot have bblack or nblack nodes at this point");}
               } else {
                  var _p24 = _p20._1._0;
                  var _p23 = _p20._0._0;
                  var _p22 = {ctor: "_Tuple3",_0: c,_1: _p23,_2: _p24};
                  if (_p22.ctor === "_Tuple3" && _p22._0.ctor === "Black" && _p22._1.ctor === "LBlack" && _p22._2.ctor === "Red")
                  {
                        return A5(RBNode_elm_builtin,
                        Black,
                        _p20._1._1,
                        _p20._1._2,
                        _p20._1._3,
                        _p20._1._4);
                     } else {
                        return A4(reportRemBug,
                        "Black/LBlack/Red",
                        c,
                        $Basics.toString(_p23),
                        $Basics.toString(_p24));
                     }
               }
         } else {
            if (_p20._1.ctor === "RBEmpty_elm_builtin") {
                  var _p27 = _p20._1._0;
                  var _p26 = _p20._0._0;
                  var _p25 = {ctor: "_Tuple3",_0: c,_1: _p26,_2: _p27};
                  if (_p25.ctor === "_Tuple3" && _p25._0.ctor === "Black" && _p25._1.ctor === "Red" && _p25._2.ctor === "LBlack")
                  {
                        return A5(RBNode_elm_builtin,
                        Black,
                        _p20._0._1,
                        _p20._0._2,
                        _p20._0._3,
                        _p20._0._4);
                     } else {
                        return A4(reportRemBug,
                        "Black/Red/LBlack",
                        c,
                        $Basics.toString(_p26),
                        $Basics.toString(_p27));
                     }
               } else {
                  var _p31 = _p20._0._2;
                  var _p30 = _p20._0._4;
                  var _p29 = _p20._0._1;
                  var l$ = A5(removeMax,_p20._0._0,_p29,_p31,_p20._0._3,_p30);
                  var _p28 = A3(maxWithDefault,_p29,_p31,_p30);
                  var k = _p28._0;
                  var v = _p28._1;
                  return A5(bubble,c,k,v,l$,r);
               }
         }
   });
   var update = F3(function (k,alter,dict) {
      var up = function (dict) {
         var _p32 = dict;
         if (_p32.ctor === "RBEmpty_elm_builtin") {
               var _p33 = alter($Maybe.Nothing);
               if (_p33.ctor === "Nothing") {
                     return {ctor: "_Tuple2",_0: Same,_1: empty};
                  } else {
                     return {ctor: "_Tuple2"
                            ,_0: Insert
                            ,_1: A5(RBNode_elm_builtin,Red,k,_p33._0,empty,empty)};
                  }
            } else {
               var _p44 = _p32._2;
               var _p43 = _p32._4;
               var _p42 = _p32._3;
               var _p41 = _p32._1;
               var _p40 = _p32._0;
               var _p34 = A2($Basics.compare,k,_p41);
               switch (_p34.ctor)
               {case "EQ": var _p35 = alter($Maybe.Just(_p44));
                    if (_p35.ctor === "Nothing") {
                          return {ctor: "_Tuple2"
                                 ,_0: Remove
                                 ,_1: A3(rem,_p40,_p42,_p43)};
                       } else {
                          return {ctor: "_Tuple2"
                                 ,_0: Same
                                 ,_1: A5(RBNode_elm_builtin,_p40,_p41,_p35._0,_p42,_p43)};
                       }
                  case "LT": var _p36 = up(_p42);
                    var flag = _p36._0;
                    var newLeft = _p36._1;
                    var _p37 = flag;
                    switch (_p37.ctor)
                    {case "Same": return {ctor: "_Tuple2"
                                         ,_0: Same
                                         ,_1: A5(RBNode_elm_builtin,_p40,_p41,_p44,newLeft,_p43)};
                       case "Insert": return {ctor: "_Tuple2"
                                             ,_0: Insert
                                             ,_1: A5(balance,_p40,_p41,_p44,newLeft,_p43)};
                       default: return {ctor: "_Tuple2"
                                       ,_0: Remove
                                       ,_1: A5(bubble,_p40,_p41,_p44,newLeft,_p43)};}
                  default: var _p38 = up(_p43);
                    var flag = _p38._0;
                    var newRight = _p38._1;
                    var _p39 = flag;
                    switch (_p39.ctor)
                    {case "Same": return {ctor: "_Tuple2"
                                         ,_0: Same
                                         ,_1: A5(RBNode_elm_builtin,_p40,_p41,_p44,_p42,newRight)};
                       case "Insert": return {ctor: "_Tuple2"
                                             ,_0: Insert
                                             ,_1: A5(balance,_p40,_p41,_p44,_p42,newRight)};
                       default: return {ctor: "_Tuple2"
                                       ,_0: Remove
                                       ,_1: A5(bubble,_p40,_p41,_p44,_p42,newRight)};}}
            }
      };
      var _p45 = up(dict);
      var flag = _p45._0;
      var updatedDict = _p45._1;
      var _p46 = flag;
      switch (_p46.ctor)
      {case "Same": return updatedDict;
         case "Insert": return ensureBlackRoot(updatedDict);
         default: return blacken(updatedDict);}
   });
   var insert = F3(function (key,value,dict) {
      return A3(update,
      key,
      $Basics.always($Maybe.Just(value)),
      dict);
   });
   var singleton = F2(function (key,value) {
      return A3(insert,key,value,empty);
   });
   var union = F2(function (t1,t2) {
      return A3(foldl,insert,t2,t1);
   });
   var fromList = function (assocs) {
      return A3($List.foldl,
      F2(function (_p47,dict) {
         var _p48 = _p47;
         return A3(insert,_p48._0,_p48._1,dict);
      }),
      empty,
      assocs);
   };
   var filter = F2(function (predicate,dictionary) {
      var add = F3(function (key,value,dict) {
         return A2(predicate,key,value) ? A3(insert,
         key,
         value,
         dict) : dict;
      });
      return A3(foldl,add,empty,dictionary);
   });
   var intersect = F2(function (t1,t2) {
      return A2(filter,
      F2(function (k,_p49) {    return A2(member,k,t2);}),
      t1);
   });
   var partition = F2(function (predicate,dict) {
      var add = F3(function (key,value,_p50) {
         var _p51 = _p50;
         var _p53 = _p51._1;
         var _p52 = _p51._0;
         return A2(predicate,key,value) ? {ctor: "_Tuple2"
                                          ,_0: A3(insert,key,value,_p52)
                                          ,_1: _p53} : {ctor: "_Tuple2"
                                                       ,_0: _p52
                                                       ,_1: A3(insert,key,value,_p53)};
      });
      return A3(foldl,add,{ctor: "_Tuple2",_0: empty,_1: empty},dict);
   });
   var remove = F2(function (key,dict) {
      return A3(update,key,$Basics.always($Maybe.Nothing),dict);
   });
   var diff = F2(function (t1,t2) {
      return A3(foldl,
      F3(function (k,v,t) {    return A2(remove,k,t);}),
      t1,
      t2);
   });
   return _elm.Dict.values = {_op: _op
                             ,empty: empty
                             ,singleton: singleton
                             ,insert: insert
                             ,update: update
                             ,isEmpty: isEmpty
                             ,get: get
                             ,remove: remove
                             ,member: member
                             ,size: size
                             ,filter: filter
                             ,partition: partition
                             ,foldl: foldl
                             ,foldr: foldr
                             ,map: map
                             ,union: union
                             ,intersect: intersect
                             ,diff: diff
                             ,keys: keys
                             ,values: values
                             ,toList: toList
                             ,fromList: fromList};
};
Elm.Set = Elm.Set || {};
Elm.Set.make = function (_elm) {
   "use strict";
   _elm.Set = _elm.Set || {};
   if (_elm.Set.values) return _elm.Set.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm);
   var _op = {};
   var foldr = F3(function (f,b,_p0) {
      var _p1 = _p0;
      return A3($Dict.foldr,
      F3(function (k,_p2,b) {    return A2(f,k,b);}),
      b,
      _p1._0);
   });
   var foldl = F3(function (f,b,_p3) {
      var _p4 = _p3;
      return A3($Dict.foldl,
      F3(function (k,_p5,b) {    return A2(f,k,b);}),
      b,
      _p4._0);
   });
   var toList = function (_p6) {
      var _p7 = _p6;
      return $Dict.keys(_p7._0);
   };
   var size = function (_p8) {
      var _p9 = _p8;
      return $Dict.size(_p9._0);
   };
   var member = F2(function (k,_p10) {
      var _p11 = _p10;
      return A2($Dict.member,k,_p11._0);
   });
   var isEmpty = function (_p12) {
      var _p13 = _p12;
      return $Dict.isEmpty(_p13._0);
   };
   var Set_elm_builtin = function (a) {
      return {ctor: "Set_elm_builtin",_0: a};
   };
   var empty = Set_elm_builtin($Dict.empty);
   var singleton = function (k) {
      return Set_elm_builtin(A2($Dict.singleton,
      k,
      {ctor: "_Tuple0"}));
   };
   var insert = F2(function (k,_p14) {
      var _p15 = _p14;
      return Set_elm_builtin(A3($Dict.insert,
      k,
      {ctor: "_Tuple0"},
      _p15._0));
   });
   var fromList = function (xs) {
      return A3($List.foldl,insert,empty,xs);
   };
   var map = F2(function (f,s) {
      return fromList(A2($List.map,f,toList(s)));
   });
   var remove = F2(function (k,_p16) {
      var _p17 = _p16;
      return Set_elm_builtin(A2($Dict.remove,k,_p17._0));
   });
   var union = F2(function (_p19,_p18) {
      var _p20 = _p19;
      var _p21 = _p18;
      return Set_elm_builtin(A2($Dict.union,_p20._0,_p21._0));
   });
   var intersect = F2(function (_p23,_p22) {
      var _p24 = _p23;
      var _p25 = _p22;
      return Set_elm_builtin(A2($Dict.intersect,_p24._0,_p25._0));
   });
   var diff = F2(function (_p27,_p26) {
      var _p28 = _p27;
      var _p29 = _p26;
      return Set_elm_builtin(A2($Dict.diff,_p28._0,_p29._0));
   });
   var filter = F2(function (p,_p30) {
      var _p31 = _p30;
      return Set_elm_builtin(A2($Dict.filter,
      F2(function (k,_p32) {    return p(k);}),
      _p31._0));
   });
   var partition = F2(function (p,_p33) {
      var _p34 = _p33;
      var _p35 = A2($Dict.partition,
      F2(function (k,_p36) {    return p(k);}),
      _p34._0);
      var p1 = _p35._0;
      var p2 = _p35._1;
      return {ctor: "_Tuple2"
             ,_0: Set_elm_builtin(p1)
             ,_1: Set_elm_builtin(p2)};
   });
   return _elm.Set.values = {_op: _op
                            ,empty: empty
                            ,singleton: singleton
                            ,insert: insert
                            ,remove: remove
                            ,isEmpty: isEmpty
                            ,member: member
                            ,size: size
                            ,foldl: foldl
                            ,foldr: foldr
                            ,map: map
                            ,filter: filter
                            ,partition: partition
                            ,union: union
                            ,intersect: intersect
                            ,diff: diff
                            ,toList: toList
                            ,fromList: fromList};
};
Elm.Native.Regex = {};
Elm.Native.Regex.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Regex = localRuntime.Native.Regex || {};
	if (localRuntime.Native.Regex.values)
	{
		return localRuntime.Native.Regex.values;
	}
	if ('values' in Elm.Native.Regex)
	{
		return localRuntime.Native.Regex.values = Elm.Native.Regex.values;
	}

	var List = Elm.Native.List.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);

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
					? Maybe.Nothing
					: Maybe.Just(submatch);
			}
			out.push({
				match: result[0],
				submatches: List.fromArray(subs),
				index: result.index,
				number: number
			});
			prevLastIndex = re.lastIndex;
		}
		re.lastIndex = lastIndex;
		return List.fromArray(out);
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
					? Maybe.Nothing
					: Maybe.Just(submatch);
			}
			return replacer({
				match: match,
				submatches: List.fromArray(submatches),
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
			return List.fromArray(str.split(re));
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
		return List.fromArray(out);
	}

	return Elm.Native.Regex.values = {
		regex: regex,
		caseInsensitive: caseInsensitive,
		escape: escape,

		contains: F2(contains),
		find: F3(find),
		replace: F4(replace),
		split: F3(split)
	};
};

Elm.Regex = Elm.Regex || {};
Elm.Regex.make = function (_elm) {
   "use strict";
   _elm.Regex = _elm.Regex || {};
   if (_elm.Regex.values) return _elm.Regex.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Regex = Elm.Native.Regex.make(_elm);
   var _op = {};
   var split = $Native$Regex.split;
   var replace = $Native$Regex.replace;
   var find = $Native$Regex.find;
   var AtMost = function (a) {    return {ctor: "AtMost",_0: a};};
   var All = {ctor: "All"};
   var Match = F4(function (a,b,c,d) {
      return {match: a,submatches: b,index: c,number: d};
   });
   var contains = $Native$Regex.contains;
   var caseInsensitive = $Native$Regex.caseInsensitive;
   var regex = $Native$Regex.regex;
   var escape = $Native$Regex.escape;
   var Regex = {ctor: "Regex"};
   return _elm.Regex.values = {_op: _op
                              ,regex: regex
                              ,escape: escape
                              ,caseInsensitive: caseInsensitive
                              ,contains: contains
                              ,find: find
                              ,replace: replace
                              ,split: split
                              ,Match: Match
                              ,All: All
                              ,AtMost: AtMost};
};
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

Elm.Help = Elm.Help || {};
Elm.Help.make = function (_elm) {
   "use strict";
   _elm.Help = _elm.Help || {};
   if (_elm.Help.values) return _elm.Help.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$Help = Elm.Native.Help.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm);
   var _op = {};
   var no_red = $Native$Help.no_red;
   return _elm.Help.values = {_op: _op,no_red: no_red};
};
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

Elm.MD5 = Elm.MD5 || {};
Elm.MD5.make = function (_elm) {
   "use strict";
   _elm.MD5 = _elm.MD5 || {};
   if (_elm.MD5.values) return _elm.MD5.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Native$MD5 = Elm.Native.MD5.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm);
   var _op = {};
   var md5 = $Native$MD5.md5;
   return _elm.MD5.values = {_op: _op,md5: md5};
};
Elm.Util = Elm.Util || {};
Elm.Util.make = function (_elm) {
   "use strict";
   _elm.Util = _elm.Util || {};
   if (_elm.Util.values) return _elm.Util.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm);
   var _op = {};
   var select = function (xs) {
      var _p0 = xs;
      if (_p0.ctor === "[]") {
            return _U.list([]);
         } else {
            var _p4 = _p0._1;
            var _p3 = _p0._0;
            return A2($List._op["::"],
            {ctor: "_Tuple2",_0: _p3,_1: _p4},
            A2($List.map,
            function (_p1) {
               var _p2 = _p1;
               return {ctor: "_Tuple2"
                      ,_0: _p2._0
                      ,_1: A2($List._op["::"],_p3,_p2._1)};
            },
            select(_p4)));
         }
   };
   var permutations = function (xs$) {
      var _p5 = xs$;
      if (_p5.ctor === "[]") {
            return _U.list([_U.list([])]);
         } else {
            var f = function (_p6) {
               var _p7 = _p6;
               return A2($List.map,
               F2(function (x,y) {
                  return A2($List._op["::"],x,y);
               })(_p7._0),
               permutations(_p7._1));
            };
            return A2($List.concatMap,f,select(_p5));
         }
   };
   var combinations = F2(function (n,list) {
      return _U.cmp(n,0) < 0 || _U.cmp(n,
      $List.length(list)) > 0 ? _U.list([]) : A2(combo,n,list);
   });
   var combo = F2(function (n,list) {
      if (_U.eq(n,0)) return _U.list([_U.list([])]);
      else if (_U.eq(n,$List.length(list))) return _U.list([list]);
         else {
               var _p8 = list;
               if (_p8.ctor === "[]") {
                     return _U.list([]);
                  } else {
                     var _p9 = _p8._1;
                     var c2 = A2(combinations,n,_p9);
                     var c1 = A2($List.map,
                     F2(function (x,y) {
                        return A2($List._op["::"],x,y);
                     })(_p8._0),
                     A2(combinations,n - 1,_p9));
                     return A2($Basics._op["++"],c1,c2);
                  }
            }
   });
   var join = F2(function (p1,p2) {
      return A2($Basics._op["++"],
      p1,
      A2($Basics._op["++"]," | ",p2));
   });
   return _elm.Util.values = {_op: _op
                             ,combinations: combinations
                             ,join: join
                             ,permutations: permutations};
};
Elm.Y15D01 = Elm.Y15D01 || {};
Elm.Y15D01.make = function (_elm) {
   "use strict";
   _elm.Y15D01 = _elm.Y15D01 || {};
   if (_elm.Y15D01.values) return _elm.Y15D01.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var position = F3(function (floor,step,instructions) {
      position: while (true) if (_U.cmp(floor,0) < 0) return step;
      else {
            var next = $String.uncons(instructions);
            var _p0 = next;
            _v0_2: do {
               if (_p0.ctor === "Just" && _p0._0.ctor === "_Tuple2") {
                     switch (_p0._0._0.valueOf())
                     {case "(": var _v1 = floor + 1,_v2 = step + 1,_v3 = _p0._0._1;
                          floor = _v1;
                          step = _v2;
                          instructions = _v3;
                          continue position;
                        case ")": var _v4 = floor - 1,_v5 = step + 1,_v6 = _p0._0._1;
                          floor = _v4;
                          step = _v5;
                          instructions = _v6;
                          continue position;
                        default: break _v0_2;}
                  } else {
                     break _v0_2;
                  }
            } while (false);
            return step;
         }
   });
   var count = F2(function (floor,instructions) {
      count: while (true) {
         var next = $String.uncons(instructions);
         var _p1 = next;
         _v7_2: do {
            if (_p1.ctor === "Just" && _p1._0.ctor === "_Tuple2") {
                  switch (_p1._0._0.valueOf())
                  {case "(": var _v8 = floor + 1,_v9 = _p1._0._1;
                       floor = _v8;
                       instructions = _v9;
                       continue count;
                     case ")": var _v10 = floor - 1,_v11 = _p1._0._1;
                       floor = _v10;
                       instructions = _v11;
                       continue count;
                     default: break _v7_2;}
               } else {
                  break _v7_2;
               }
         } while (false);
         return floor;
      }
   });
   var answers = function (input) {
      var p2 = $Basics.toString(A3(position,0,0,input));
      var p1 = $Basics.toString(A2(count,0,input));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D01.values = {_op: _op
                               ,answers: answers
                               ,count: count
                               ,position: position};
};
Elm.Y15D02 = Elm.Y15D02 || {};
Elm.Y15D02.make = function (_elm) {
   "use strict";
   _elm.Y15D02 = _elm.Y15D02 || {};
   if (_elm.Y15D02.values) return _elm.Y15D02.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var ribbon = F3(function (l,w,h) {
      var volume = l * w * h;
      var perimeters = _U.list([l + w,w + h,h + l]);
      var perimeter = A2($Maybe.withDefault,
      0,
      $List.minimum(perimeters));
      return 2 * perimeter + volume;
   });
   var wrapping = F3(function (l,w,h) {
      var sides = _U.list([l * w,w * h,h * l]);
      var paper = 2 * $List.sum(sides);
      var slack = A2($Maybe.withDefault,0,$List.minimum(sides));
      return paper + slack;
   });
   var sumLine = F3(function (counter,line,count) {
      var dimensions = A2($List.map,
      $Result.withDefault(0),
      A2($List.map,
      $String.toInt,
      A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.All,$Regex.regex("[1-9]\\d*"),line))));
      var extra = function () {
         var _p0 = dimensions;
         if (_p0.ctor === "::" && _p0._1.ctor === "::" && _p0._1._1.ctor === "::" && _p0._1._1._1.ctor === "[]")
         {
               return A3(counter,_p0._0,_p0._1._0,_p0._1._1._0);
            } else {
               return 0;
            }
      }();
      return count + extra;
   });
   var sumInput = F2(function (counter,input) {
      var lines = A3($Regex.split,
      $Regex.All,
      $Regex.regex("\n"),
      input);
      return A3($List.foldl,sumLine(counter),0,lines);
   });
   var answers = function (input) {
      var p2 = $Basics.toString(A2(sumInput,ribbon,input));
      var p1 = $Basics.toString(A2(sumInput,wrapping,input));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D02.values = {_op: _op
                               ,answers: answers
                               ,sumInput: sumInput
                               ,sumLine: sumLine
                               ,wrapping: wrapping
                               ,ribbon: ribbon};
};
Elm.Y15D03 = Elm.Y15D03 || {};
Elm.Y15D03.make = function (_elm) {
   "use strict";
   _elm.Y15D03 = _elm.Y15D03 || {};
   if (_elm.Y15D03.values) return _elm.Y15D03.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Array = Elm.Array.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var visit = F3(function (x,y,visited) {
      var key = A2($Basics._op["++"],
      $Basics.toString(x),
      A2($Basics._op["++"],"|",$Basics.toString(y)));
      return A3($Dict.insert,key,true,visited);
   });
   var Model = F4(function (a,b,c,d) {
      return {visited: a,santas: b,turn: c,err: d};
   });
   var errorSanta = function (err) {
      return {stop: true,x: 0,y: 0,err: $Maybe.Just(err)};
   };
   var updateSanta = F2(function ($char,santa) {
      var _p0 = $char;
      switch (_p0.valueOf())
      {case ">": return _U.update(santa,{x: santa.x + 1});
         case "<": return _U.update(santa,{x: santa.x - 1});
         case "^": return _U.update(santa,{y: santa.y + 1});
         case "v": return _U.update(santa,{y: santa.y - 1});
         case "\n": return _U.update(santa,{stop: true});
         default: return errorSanta(A2($Basics._op["++"],
           "illegal instruction [",
           A2($Basics._op["++"],$Basics.toString($char),"]")));}
   });
   var deliver = F2(function (model,instructions) {
      deliver: while (true) if ($String.isEmpty(instructions))
      return model; else {
            var index = A2($Basics.rem,
            model.turn,
            $Array.length(model.santas));
            var santa = A2($Maybe.withDefault,
            errorSanta(A2($Basics._op["++"],
            "illegal index [",
            A2($Basics._op["++"],$Basics.toString(index),"]"))),
            A2($Array.get,index,model.santas));
            var next = $String.uncons(instructions);
            var _p1 = function () {
               var _p2 = next;
               if (_p2.ctor === "Just" && _p2._0.ctor === "_Tuple2") {
                     return {ctor: "_Tuple2",_0: _p2._0._0,_1: _p2._0._1};
                  } else {
                     return {ctor: "_Tuple2",_0: _U.chr("*"),_1: ""};
                  }
            }();
            var $char = _p1._0;
            var remaining = _p1._1;
            var santa$ = A2(updateSanta,$char,santa);
            if (santa$.stop) return _U.update(model,{err: santa.err});
            else {
                  var model$ = _U.update(model,
                  {visited: A3(visit,santa$.x,santa$.y,model.visited)
                  ,turn: model.turn + 1
                  ,santas: A3($Array.set,index,santa$,model.santas)});
                  var _v2 = model$,_v3 = remaining;
                  model = _v2;
                  instructions = _v3;
                  continue deliver;
               }
         }
   });
   var initSanta = {stop: false,x: 0,y: 0,err: $Maybe.Nothing};
   var initModel = function (n) {
      return {visited: A3(visit,0,0,$Dict.empty)
             ,santas: A2($Array.repeat,n,initSanta)
             ,turn: 0
             ,err: $Maybe.Nothing};
   };
   var Santa = F4(function (a,b,c,d) {
      return {stop: a,x: b,y: c,err: d};
   });
   var christmas = F2(function (n,input) {
      var model = A2(deliver,initModel(n),input);
      var _p3 = model.err;
      if (_p3.ctor === "Just") {
            return _p3._0;
         } else {
            return $Basics.toString($List.length($Dict.keys(model.visited)));
         }
   });
   var answers = function (input) {
      var p2 = A2(christmas,2,input);
      var p1 = A2(christmas,1,input);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D03.values = {_op: _op
                               ,answers: answers
                               ,christmas: christmas
                               ,Santa: Santa
                               ,initSanta: initSanta
                               ,errorSanta: errorSanta
                               ,Model: Model
                               ,initModel: initModel
                               ,deliver: deliver
                               ,updateSanta: updateSanta
                               ,visit: visit};
};
Elm.Y15D04 = Elm.Y15D04 || {};
Elm.Y15D04.make = function (_elm) {
   "use strict";
   _elm.Y15D04 = _elm.Y15D04 || {};
   if (_elm.Y15D04.values) return _elm.Y15D04.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $MD5 = Elm.MD5.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var recurse = F3(function (step,start,key) {
      recurse: while (true) {
         var hash = $MD5.md5(A2($Basics._op["++"],
         key,
         $Basics.toString(step)));
         if (A2($String.startsWith,start,hash))
         return $Basics.toString(step); else {
               var _v0 = step + 1,_v1 = start,_v2 = key;
               step = _v0;
               start = _v1;
               key = _v2;
               continue recurse;
            }
      }
   });
   var find = F2(function (start,key) {
      return A3(recurse,1,start,key);
   });
   var parse = function (input) {
      return A2($Maybe.withDefault,
      "no secret key found",
      $List.head(A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("[a-z]+"),
      input))));
   };
   var answers = function (input) {
      var key = parse(input);
      var p1 = A2(find,"00000",key);
      var p2 = A2(find,"000000",key);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D04.values = {_op: _op
                               ,answers: answers
                               ,parse: parse
                               ,find: find
                               ,recurse: recurse};
};
Elm.Y15D05 = Elm.Y15D05 || {};
Elm.Y15D05.make = function (_elm) {
   "use strict";
   _elm.Y15D05 = _elm.Y15D05 || {};
   if (_elm.Y15D05.values) return _elm.Y15D05.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var twipsRgx = $Regex.regex("(.).\\1");
   var pairsRgx = $Regex.regex("(..).*\\1");
   var badieRgx = $Regex.regex("(:?ab|cd|pq|xy)");
   var dubleRgx = $Regex.regex("(.)\\1");
   var vowelRgx = $Regex.regex("[aeiou]");
   var stringRgx = $Regex.regex("[a-z]{10,}");
   var count = F2(function (rgx,string) {
      return $List.length(A3($Regex.find,$Regex.All,rgx,string));
   });
   var nice2 = function (string) {
      var twips = A2(count,twipsRgx,string);
      var pairs = A2(count,pairsRgx,string);
      return _U.cmp(pairs,0) > 0 && _U.cmp(twips,0) > 0;
   };
   var nice1 = function (string) {
      var badies = A2(count,badieRgx,string);
      var dubles = A2(count,dubleRgx,string);
      var vowels = A2(count,vowelRgx,string);
      return _U.cmp(vowels,3) > -1 && (_U.cmp(dubles,
      0) > 0 && _U.eq(badies,0));
   };
   var countNice = F2(function (nice,strings) {
      return $Basics.toString($List.length(A2($List.filter,
      nice,
      strings)));
   });
   var answers = function (input) {
      var strings = A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.All,stringRgx,input));
      var p1 = A2(countNice,nice1,strings);
      var p2 = A2(countNice,nice2,strings);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D05.values = {_op: _op
                               ,answers: answers
                               ,countNice: countNice
                               ,nice1: nice1
                               ,nice2: nice2
                               ,count: count
                               ,stringRgx: stringRgx
                               ,vowelRgx: vowelRgx
                               ,dubleRgx: dubleRgx
                               ,badieRgx: badieRgx
                               ,pairsRgx: pairsRgx
                               ,twipsRgx: twipsRgx};
};
Elm.Y15D06 = Elm.Y15D06 || {};
Elm.Y15D06.make = function (_elm) {
   "use strict";
   _elm.Y15D06 = _elm.Y15D06 || {};
   if (_elm.Y15D06.values) return _elm.Y15D06.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Array = Elm.Array.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var initModel = {ctor: "_Tuple2"
                   ,_0: A2($Array.repeat,1000000,0)
                   ,_1: A2($Array.repeat,1000000,0)};
   var Instruction = F3(function (a,b,c) {
      return {action: a,from: b,to: c};
   });
   var Off = {ctor: "Off"};
   var On = {ctor: "On"};
   var Toggle = {ctor: "Toggle"};
   var badInstruction = {action: Toggle
                        ,from: {ctor: "_Tuple2",_0: 1,_1: 1}
                        ,to: {ctor: "_Tuple2",_0: 0,_1: 0}};
   var parseInstruction = function (submatches) {
      var _p0 = submatches;
      if (_p0.ctor === "::" && _p0._0.ctor === "Just" && _p0._1.ctor === "::" && _p0._1._0.ctor === "Just" && _p0._1._1.ctor === "::" && _p0._1._1._0.ctor === "Just" && _p0._1._1._1.ctor === "::" && _p0._1._1._1._0.ctor === "Just" && _p0._1._1._1._1.ctor === "::" && _p0._1._1._1._1._0.ctor === "Just" && _p0._1._1._1._1._1.ctor === "[]")
      {
            var ty$ = $String.toInt(_p0._1._1._1._1._0._0);
            var tx$ = $String.toInt(_p0._1._1._1._0._0);
            var fy$ = $String.toInt(_p0._1._1._0._0);
            var fx$ = $String.toInt(_p0._1._0._0);
            var a$ = function () {
               var _p1 = _p0._0._0;
               switch (_p1)
               {case "toggle": return $Maybe.Just(Toggle);
                  case "turn on": return $Maybe.Just(On);
                  case "turn off": return $Maybe.Just(Off);
                  default: return $Maybe.Nothing;}
            }();
            var _p2 = {ctor: "_Tuple5"
                      ,_0: a$
                      ,_1: fx$
                      ,_2: fy$
                      ,_3: tx$
                      ,_4: ty$};
            if (_p2.ctor === "_Tuple5" && _p2._0.ctor === "Just" && _p2._1.ctor === "Ok" && _p2._2.ctor === "Ok" && _p2._3.ctor === "Ok" && _p2._4.ctor === "Ok")
            {
                  var _p6 = _p2._4._0;
                  var _p5 = _p2._3._0;
                  var _p4 = _p2._2._0;
                  var _p3 = _p2._1._0;
                  return _U.cmp(_p3,0) > -1 && (_U.cmp(_p4,0) > -1 && (_U.cmp(_p3,
                  _p5) < 1 && (_U.cmp(_p4,_p6) < 1 && (_U.cmp(_p5,
                  1000) < 0 && _U.cmp(_p6,1000) < 0)))) ? {action: _p2._0._0
                                                          ,from: {ctor: "_Tuple2",_0: _p3,_1: _p4}
                                                          ,to: {ctor: "_Tuple2",_0: _p5,_1: _p6}} : badInstruction;
               } else {
                  return badInstruction;
               }
         } else {
            return badInstruction;
         }
   };
   var index = function (instruction) {
      var y = $Basics.snd(instruction.from);
      var x = $Basics.fst(instruction.from);
      return x + 1000 * y;
   };
   var updateCell = F2(function (instruction,lights) {
      var l2 = $Basics.snd(lights);
      var l1 = $Basics.fst(lights);
      var k = index(instruction);
      var v1 = A2($Maybe.withDefault,0,A2($Array.get,k,l1));
      var v1$ = function () {
         var _p7 = instruction.action;
         switch (_p7.ctor)
         {case "Toggle": return _U.eq(v1,1) ? 0 : 1;
            case "On": return 1;
            default: return 0;}
      }();
      var v2 = A2($Maybe.withDefault,0,A2($Array.get,k,l2));
      var v2$ = function () {
         var _p8 = instruction.action;
         switch (_p8.ctor)
         {case "Toggle": return v2 + 2;
            case "On": return v2 + 1;
            default: return _U.eq(v2,0) ? 0 : v2 - 1;}
      }();
      return {ctor: "_Tuple2"
             ,_0: A3($Array.set,k,v1$,l1)
             ,_1: A3($Array.set,k,v2$,l2)};
   });
   var updateCol = F2(function (instruction,lights) {
      updateCol: while (true) {
         var ty = $Basics.snd(instruction.to);
         var fy = $Basics.snd(instruction.from);
         var lights$ = A2(updateCell,instruction,lights);
         if (_U.eq(fy,ty)) return lights$; else {
               var tx = $Basics.fst(instruction.to);
               var fx = $Basics.fst(instruction.from);
               var instruction$ = _U.update(instruction,
               {from: {ctor: "_Tuple2",_0: fx,_1: fy + 1}
               ,to: {ctor: "_Tuple2",_0: tx,_1: ty}});
               var _v5 = instruction$,_v6 = lights$;
               instruction = _v5;
               lights = _v6;
               continue updateCol;
            }
      }
   });
   var updateRow = F2(function (instruction,lights) {
      updateRow: while (true) {
         var tx = $Basics.fst(instruction.to);
         var fx = $Basics.fst(instruction.from);
         var lights$ = A2(updateCol,instruction,lights);
         if (_U.eq(fx,tx)) return lights$; else {
               var ty = $Basics.snd(instruction.to);
               var fy = $Basics.snd(instruction.from);
               var instruction$ = _U.update(instruction,
               {from: {ctor: "_Tuple2",_0: fx + 1,_1: fy}
               ,to: {ctor: "_Tuple2",_0: tx,_1: ty}});
               var _v7 = instruction$,_v8 = lights$;
               instruction = _v7;
               lights = _v8;
               continue updateRow;
            }
      }
   });
   var process = F2(function (instructions,lights) {
      process: while (true) {
         var _p9 = instructions;
         if (_p9.ctor === "[]") {
               return lights;
            } else {
               var lights$ = A2(updateRow,_p9._0,lights);
               var _v10 = _p9._1,_v11 = lights$;
               instructions = _v10;
               lights = _v11;
               continue process;
            }
      }
   });
   var parse = function (input) {
      var rgx = $Regex.regex("(toggle|turn (?:on|off)) (\\d+),(\\d+) through (\\d+),(\\d+)");
      return A2($List.filter,
      function (i) {
         return !_U.eq(i,badInstruction);
      },
      A2($List.map,
      parseInstruction,
      A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,$Regex.All,rgx,input))));
   };
   var answers = function (input) {
      var instructions = parse(input);
      var model = A2(process,instructions,initModel);
      var p1 = $Basics.toString($List.length(A2($List.filter,
      function (l) {
         return _U.eq(l,1);
      },
      $Array.toList($Basics.fst(model)))));
      var p2 = $Basics.toString($List.sum($Array.toList($Basics.snd(model))));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D06.values = {_op: _op
                               ,answers: answers
                               ,parse: parse
                               ,process: process
                               ,updateRow: updateRow
                               ,updateCol: updateCol
                               ,updateCell: updateCell
                               ,index: index
                               ,parseInstruction: parseInstruction
                               ,Toggle: Toggle
                               ,On: On
                               ,Off: Off
                               ,Instruction: Instruction
                               ,badInstruction: badInstruction
                               ,initModel: initModel};
};
Elm.Y15D07 = Elm.Y15D07 || {};
Elm.Y15D07.make = function (_elm) {
   "use strict";
   _elm.Y15D07 = _elm.Y15D07 || {};
   if (_elm.Y15D07.values) return _elm.Y15D07.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Bitwise = Elm.Bitwise.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var Not = function (a) {    return {ctor: "Not",_0: a};};
   var Rshift = F2(function (a,b) {
      return {ctor: "Rshift",_0: a,_1: b};
   });
   var Lshift = F2(function (a,b) {
      return {ctor: "Lshift",_0: a,_1: b};
   });
   var Or = F2(function (a,b) {
      return {ctor: "Or",_0: a,_1: b};
   });
   var And = F2(function (a,b) {
      return {ctor: "And",_0: a,_1: b};
   });
   var Pass = function (a) {    return {ctor: "Pass",_0: a};};
   var NoOp = function (a) {    return {ctor: "NoOp",_0: a};};
   var maxValue = 65535;
   var parseInt = function (i) {
      return A2($Result.withDefault,0,$String.toInt(i));
   };
   var parseConnection = function (connection) {
      var words = A2($String.split," ",connection);
      var _p0 = words;
      _v0_6: do {
         if (_p0.ctor === "::" && _p0._1.ctor === "::" && _p0._1._1.ctor === "::")
         {
               if (_p0._1._1._1.ctor === "[]") {
                     if (_p0._1._0 === "->") {
                           return {ctor: "_Tuple2",_0: _p0._1._1._0,_1: Pass(_p0._0)};
                        } else {
                           break _v0_6;
                        }
                  } else {
                     if (_p0._1._1._1._1.ctor === "::") {
                           if (_p0._1._1._1._0 === "->" && _p0._1._1._1._1._1.ctor === "[]")
                           {
                                 switch (_p0._1._0)
                                 {case "AND": return {ctor: "_Tuple2"
                                                     ,_0: _p0._1._1._1._1._0
                                                     ,_1: A2(And,_p0._0,_p0._1._1._0)};
                                    case "OR": return {ctor: "_Tuple2"
                                                      ,_0: _p0._1._1._1._1._0
                                                      ,_1: A2(Or,_p0._0,_p0._1._1._0)};
                                    case "LSHIFT": return {ctor: "_Tuple2"
                                                          ,_0: _p0._1._1._1._1._0
                                                          ,_1: A2(Lshift,_p0._0,parseInt(_p0._1._1._0))};
                                    case "RSHIFT": return {ctor: "_Tuple2"
                                                          ,_0: _p0._1._1._1._1._0
                                                          ,_1: A2(Rshift,_p0._0,parseInt(_p0._1._1._0))};
                                    default: break _v0_6;}
                              } else {
                                 break _v0_6;
                              }
                        } else {
                           if (_p0._0 === "NOT" && _p0._1._1._0 === "->") {
                                 return {ctor: "_Tuple2"
                                        ,_0: _p0._1._1._1._0
                                        ,_1: Not(_p0._1._0)};
                              } else {
                                 break _v0_6;
                              }
                        }
                  }
            } else {
               break _v0_6;
            }
      } while (false);
      return {ctor: "_Tuple2",_0: connection,_1: NoOp(0)};
   };
   var parseLines = F2(function (lines,circuit) {
      parseLines: while (true) {
         var _p1 = lines;
         if (_p1.ctor === "[]") {
               return circuit;
            } else {
               var _p3 = _p1._1;
               var _p2 = parseConnection(_p1._0);
               var wire = _p2._0;
               var action = _p2._1;
               var circuit$ = A3($Dict.insert,wire,action,circuit);
               if (_U.eq(wire,"") && _U.eq(action,NoOp(0))) {
                     var _v2 = _p3,_v3 = circuit;
                     lines = _v2;
                     circuit = _v3;
                     continue parseLines;
                  } else {
                     var _v4 = _p3,_v5 = circuit$;
                     lines = _v4;
                     circuit = _v5;
                     continue parseLines;
                  }
            }
      }
   });
   var parseInput = function (input) {
      return A2(parseLines,
      A2($String.split,"\n",input),
      $Dict.empty);
   };
   var getVal = F2(function (wire,circuit) {
      var val = A2($Dict.get,wire,circuit);
      var _p4 = val;
      if (_p4.ctor === "Nothing") {
            return 0;
         } else {
            var _p5 = _p4._0;
            if (_p5.ctor === "NoOp") {
                  return _p5._0;
               } else {
                  return 0;
               }
         }
   });
   var reduce = F2(function (wire,circuit) {
      var val = A2($Dict.get,wire,circuit);
      var _p6 = val;
      if (_p6.ctor === "Nothing") {
            return A3($Dict.insert,wire,NoOp(0),circuit);
         } else {
            var _p7 = function () {
               var _p8 = _p6._0;
               switch (_p8.ctor)
               {case "NoOp": return {ctor: "_Tuple3"
                                    ,_0: _p8._0
                                    ,_1: circuit
                                    ,_2: false};
                  case "Pass": var _p9 = A2(reduce1,_p8._0,circuit);
                    var i = _p9._0;
                    var c = _p9._1;
                    return {ctor: "_Tuple3",_0: i,_1: c,_2: true};
                  case "And": var _p10 = A3(reduce2,_p8._0,_p8._1,circuit);
                    var i = _p10._0;
                    var j = _p10._1;
                    var c = _p10._2;
                    return {ctor: "_Tuple3"
                           ,_0: A2($Bitwise.and,i,j)
                           ,_1: c
                           ,_2: true};
                  case "Or": var _p11 = A3(reduce2,_p8._0,_p8._1,circuit);
                    var i = _p11._0;
                    var j = _p11._1;
                    var c = _p11._2;
                    return {ctor: "_Tuple3",_0: A2($Bitwise.or,i,j),_1: c,_2: true};
                  case "Lshift": var _p12 = A2(reduce1,_p8._0,circuit);
                    var j = _p12._0;
                    var c = _p12._1;
                    var k = A2($Bitwise.shiftLeft,j,_p8._1);
                    return {ctor: "_Tuple3",_0: k,_1: c,_2: true};
                  case "Rshift": var _p13 = A2(reduce1,_p8._0,circuit);
                    var j = _p13._0;
                    var c = _p13._1;
                    return {ctor: "_Tuple3"
                           ,_0: A2($Bitwise.shiftRight,j,_p8._1)
                           ,_1: c
                           ,_2: true};
                  default: var _p14 = A2(reduce1,_p8._0,circuit);
                    var i = _p14._0;
                    var c = _p14._1;
                    var j = $Bitwise.complement(i);
                    var k = _U.cmp(j,0) < 0 ? maxValue + j + 1 : j;
                    return {ctor: "_Tuple3",_0: k,_1: c,_2: true};}
            }();
            var k = _p7._0;
            var circuit$ = _p7._1;
            var insert = _p7._2;
            return insert ? A3($Dict.insert,
            wire,
            NoOp(k),
            circuit$) : circuit$;
         }
   });
   var reduce1 = F2(function (w,circuit) {
      var i = $String.toInt(w);
      var _p15 = i;
      if (_p15.ctor === "Ok") {
            return {ctor: "_Tuple2",_0: _p15._0,_1: circuit};
         } else {
            var circuit$ = A2(reduce,w,circuit);
            return {ctor: "_Tuple2",_0: A2(getVal,w,circuit$),_1: circuit$};
         }
   });
   var reduce2 = F3(function (w1,w2,circuit) {
      var i2 = $String.toInt(w2);
      var i1 = $String.toInt(w1);
      var _p16 = {ctor: "_Tuple2",_0: i1,_1: i2};
      if (_p16._0.ctor === "Ok") {
            if (_p16._1.ctor === "Ok") {
                  return {ctor: "_Tuple3"
                         ,_0: _p16._0._0
                         ,_1: _p16._1._0
                         ,_2: circuit};
               } else {
                  var circuit$ = A2(reduce,w2,circuit);
                  return {ctor: "_Tuple3"
                         ,_0: _p16._0._0
                         ,_1: A2(getVal,w2,circuit$)
                         ,_2: circuit$};
               }
         } else {
            if (_p16._1.ctor === "Ok") {
                  var circuit$ = A2(reduce,w1,circuit);
                  return {ctor: "_Tuple3"
                         ,_0: A2(getVal,w1,circuit$)
                         ,_1: _p16._1._0
                         ,_2: circuit$};
               } else {
                  var circuit$ = A2(reduce,w1,circuit);
                  var circuit$$ = A2(reduce,w2,circuit$);
                  return {ctor: "_Tuple3"
                         ,_0: A2(getVal,w1,circuit$)
                         ,_1: A2(getVal,w2,circuit$$)
                         ,_2: circuit$$};
               }
         }
   });
   var answers = function (input) {
      var circuit = parseInput(input);
      var circuit1 = A2(reduce,"a",circuit);
      var p1 = $Basics.toString(A2(getVal,"a",circuit1));
      var circuit2 = A2(reduce,
      "a",
      A3($Dict.insert,"b",NoOp(3176),circuit));
      var p2 = $Basics.toString(A2(getVal,"a",circuit2));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D07.values = {_op: _op
                               ,answers: answers
                               ,reduce: reduce
                               ,reduce1: reduce1
                               ,reduce2: reduce2
                               ,getVal: getVal
                               ,parseInput: parseInput
                               ,parseLines: parseLines
                               ,parseConnection: parseConnection
                               ,parseInt: parseInt
                               ,maxValue: maxValue
                               ,NoOp: NoOp
                               ,Pass: Pass
                               ,And: And
                               ,Or: Or
                               ,Lshift: Lshift
                               ,Rshift: Rshift
                               ,Not: Not};
};
Elm.Y15D08 = Elm.Y15D08 || {};
Elm.Y15D08.make = function (_elm) {
   "use strict";
   _elm.Y15D08 = _elm.Y15D08 || {};
   if (_elm.Y15D08.values) return _elm.Y15D08.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var escape = function (line) {
      var r1 = A4($Regex.replace,
      $Regex.All,
      $Regex.regex("\\\\"),
      function (_p0) {
         return "\\\\";
      },
      line);
      var r2 = A4($Regex.replace,
      $Regex.All,
      $Regex.regex("\""),
      function (_p1) {
         return "\\\"";
      },
      r1);
      var r3 = A2($Basics._op["++"],
      "\"",
      A2($Basics._op["++"],r2,"\""));
      return r3;
   };
   var unescape = function (line) {
      var r1 = A4($Regex.replace,
      $Regex.All,
      $Regex.regex("(^\"|\"$)"),
      function (_p2) {
         return "";
      },
      line);
      var r2 = A4($Regex.replace,
      $Regex.All,
      $Regex.regex("\\\\\""),
      function (_p3) {
         return "_";
      },
      r1);
      var r3 = A4($Regex.replace,
      $Regex.All,
      $Regex.regex("\\\\\\\\"),
      function (_p4) {
         return ".";
      },
      r2);
      var r4 = A4($Regex.replace,
      $Regex.All,
      $Regex.regex("\\\\x[0-9a-f]{2}"),
      function (_p5) {
         return "-";
      },
      r3);
      return r4;
   };
   var escLength = function (lines) {
      return $List.sum(A2($List.map,
      $String.length,
      A2($List.map,escape,lines)));
   };
   var memLength = function (lines) {
      return $List.sum(A2($List.map,
      $String.length,
      A2($List.map,unescape,lines)));
   };
   var chrLength = function (lines) {
      return $List.sum(A2($List.map,$String.length,lines));
   };
   var parseInput = function (input) {
      return A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input));
   };
   var answers = function (input) {
      var strings = parseInput(input);
      var p1 = $Basics.toString(chrLength(strings) - memLength(strings));
      var p2 = $Basics.toString(escLength(strings) - chrLength(strings));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D08.values = {_op: _op
                               ,answers: answers
                               ,parseInput: parseInput
                               ,chrLength: chrLength
                               ,memLength: memLength
                               ,escLength: escLength
                               ,unescape: unescape
                               ,escape: escape};
};
Elm.Y15D09 = Elm.Y15D09 || {};
Elm.Y15D09.make = function (_elm) {
   "use strict";
   _elm.Y15D09 = _elm.Y15D09 || {};
   if (_elm.Y15D09.values) return _elm.Y15D09.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var initModel = {distances: $Dict.empty,cities: _U.list([])};
   var Model = F2(function (a,b) {
      return {distances: a,cities: b};
   });
   var key = F2(function (c1,c2) {
      return A2($Basics._op["++"],c1,A2($Basics._op["++"],"|",c2));
   });
   var pairs = function (list) {
      var _p0 = list;
      if (_p0.ctor === "[]") {
            return _U.list([]);
         } else {
            if (_p0._1.ctor === "[]") {
                  return _U.list([]);
               } else {
                  var _p1 = _p0._1._0;
                  return A2($List._op["::"],
                  {ctor: "_Tuple2",_0: _p0._0,_1: _p1},
                  pairs(A2($List._op["::"],_p1,_p0._1._1)));
               }
         }
   };
   var parseLine = F2(function (line,model) {
      var matches = A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("^(\\w+) to (\\w+) = (\\d+)$"),
      line));
      var _p2 = matches;
      if (_p2.ctor === "::" && _p2._0.ctor === "::" && _p2._0._0.ctor === "Just" && _p2._0._1.ctor === "::" && _p2._0._1._0.ctor === "Just" && _p2._0._1._1.ctor === "::" && _p2._0._1._1._0.ctor === "Just" && _p2._0._1._1._1.ctor === "[]" && _p2._1.ctor === "[]")
      {
            var _p4 = _p2._0._1._0._0;
            var _p3 = _p2._0._0._0;
            var cities$ = A2($List.member,
            _p3,
            model.cities) ? model.cities : A2($List._op["::"],
            _p3,
            model.cities);
            var cities = A2($List.member,
            _p4,
            cities$) ? cities$ : A2($List._op["::"],_p4,cities$);
            var di = A2($Result.withDefault,
            0,
            $String.toInt(_p2._0._1._1._0._0));
            var distances = A3($Dict.insert,
            A2(key,_p4,_p3),
            di,
            A3($Dict.insert,A2(key,_p3,_p4),di,model.distances));
            return _U.update(model,{distances: distances,cities: cities});
         } else {
            return model;
         }
   });
   var parseInput = function (input) {
      return A3($List.foldl,
      parseLine,
      initModel,
      A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input)));
   };
   var extreme = function (model) {
      var f = function (_p5) {
         var _p6 = _p5;
         return A2($Maybe.withDefault,
         0,
         A2($Dict.get,A2(key,_p6._0,_p6._1),model.distances));
      };
      return A2($List.map,
      function (p) {
         return $List.sum(A2($List.map,f,p));
      },
      A2($List.map,
      function (perm) {
         return pairs(perm);
      },
      $Util.permutations(model.cities)));
   };
   var answers = function (input) {
      var model = parseInput(input);
      var extremes = extreme(model);
      var p1 = $Basics.toString(A2($Maybe.withDefault,
      0,
      $List.minimum(extremes)));
      var p2 = $Basics.toString(A2($Maybe.withDefault,
      0,
      $List.maximum(extremes)));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D09.values = {_op: _op
                               ,answers: answers
                               ,extreme: extreme
                               ,parseInput: parseInput
                               ,parseLine: parseLine
                               ,pairs: pairs
                               ,key: key
                               ,Model: Model
                               ,initModel: initModel};
};
Elm.Y15D10 = Elm.Y15D10 || {};
Elm.Y15D10.make = function (_elm) {
   "use strict";
   _elm.Y15D10 = _elm.Y15D10 || {};
   if (_elm.Y15D10.values) return _elm.Y15D10.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var mapper = function (match) {
      var $char = A2($String.left,1,match.match);
      var length = $Basics.toString($String.length(match.match));
      return A2($Basics._op["++"],length,$char);
   };
   var conway = F2(function (count,digits) {
      conway: while (true) if (_U.cmp(count,0) < 1) return digits;
      else {
            var digits$ = A4($Regex.replace,
            $Regex.All,
            $Regex.regex("(\\d)\\1*"),
            mapper,
            digits);
            var _v0 = count - 1,_v1 = digits$;
            count = _v0;
            digits = _v1;
            continue conway;
         }
   });
   var parse = function (input) {
      return A2($Maybe.withDefault,
      "no digits found",
      $List.head(A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.AtMost(1),$Regex.regex("\\d+"),input))));
   };
   var answers = function (input) {
      var digits = parse(input);
      var digits$ = A2(conway,40,digits);
      var p1 = $Basics.toString($String.length(digits$));
      var digits$$ = A2(conway,10,digits$);
      var p2 = $Basics.toString($String.length(digits$$));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D10.values = {_op: _op
                               ,answers: answers
                               ,parse: parse
                               ,conway: conway
                               ,mapper: mapper};
};
Elm.Y15D11 = Elm.Y15D11 || {};
Elm.Y15D11.make = function (_elm) {
   "use strict";
   _elm.Y15D11 = _elm.Y15D11 || {};
   if (_elm.Y15D11.values) return _elm.Y15D11.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Char = Elm.Char.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var has_enough_pairs = function (p) {
      return A2($Regex.contains,
      $Regex.regex("(.)\\1.*(.)(?!\\1)\\2"),
      p);
   };
   var has_a_straight = function (p) {
      return A2($Regex.contains,
      $Regex.regex("(abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)"),
      p);
   };
   var is_not_confusing = function (p) {
      return $Basics.not(A2($Regex.contains,
      $Regex.regex("[iol]"),
      p));
   };
   var increment = function (p) {
      var parts = $List.head(A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("^([a-z]*)([a-y])(z*)$"),
      p)));
      var _p0 = parts;
      if (_p0.ctor === "Just" && _p0._0.ctor === "::" && _p0._0._0.ctor === "Just" && _p0._0._1.ctor === "::" && _p0._0._1._0.ctor === "Just" && _p0._0._1._1.ctor === "::" && _p0._0._1._1._0.ctor === "Just" && _p0._0._1._1._1.ctor === "[]")
      {
            var c1 = A2($String.repeat,
            $String.length(_p0._0._1._1._0._0),
            "a");
            var b1 = $String.uncons(_p0._0._1._0._0);
            var b2 = function () {
               var _p1 = b1;
               if (_p1.ctor === "Just" && _p1._0.ctor === "_Tuple2") {
                     return $String.fromChar($Char.fromCode(A2(F2(function (x,y) {
                        return x + y;
                     }),
                     1,
                     $Char.toCode(_p1._0._0))));
                  } else {
                     return "";
                  }
            }();
            return A2($Regex.contains,
            $Regex.regex("^[b-z]$"),
            b2) ? A2($Basics._op["++"],
            _p0._0._0._0,
            A2($Basics._op["++"],b2,c1)) : A2($Basics._op["++"],
            "invalid (",
            A2($Basics._op["++"],p,")"));
         } else {
            return A2($Basics._op["++"],
            "invalid (",
            A2($Basics._op["++"],p,")"));
         }
   };
   var next = function (q) {
      next: while (true) {
         var p = increment(q);
         if (A2($String.startsWith,"invalid",p)) return p;
         else if (is_not_confusing(p) && (has_a_straight(p) && has_enough_pairs(p)))
            return p; else {
                  var _v2 = p;
                  q = _v2;
                  continue next;
               }
      }
   };
   var parse = function (input) {
      return A2($Maybe.withDefault,
      "no password found",
      $List.head(A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("[a-z]{8}"),
      input))));
   };
   var answers = function (input) {
      var p0 = parse(input);
      var p1 = next(p0);
      var p2 = next(p1);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D11.values = {_op: _op
                               ,answers: answers
                               ,parse: parse
                               ,next: next
                               ,increment: increment
                               ,is_not_confusing: is_not_confusing
                               ,has_a_straight: has_a_straight
                               ,has_enough_pairs: has_enough_pairs};
};
Elm.Y15D12 = Elm.Y15D12 || {};
Elm.Y15D12.make = function (_elm) {
   "use strict";
   _elm.Y15D12 = _elm.Y15D12 || {};
   if (_elm.Y15D12.values) return _elm.Y15D12.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Help = Elm.Help.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var count = function (json) {
      return $Basics.toString($List.sum(A2($List.map,
      $Result.withDefault(0),
      A2($List.map,
      $String.toInt,
      A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,
      $Regex.All,
      $Regex.regex("-?[1-9]\\d*"),
      json))))));
   };
   var answers = function (input) {
      var p2 = count($Help.no_red(input));
      var p1 = count(input);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D12.values = {_op: _op
                               ,answers: answers
                               ,count: count};
};
Elm.Y15D13 = Elm.Y15D13 || {};
Elm.Y15D13.make = function (_elm) {
   "use strict";
   _elm.Y15D13 = _elm.Y15D13 || {};
   if (_elm.Y15D13.values) return _elm.Y15D13.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Set = Elm.Set.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var initModel = {happiness: $Dict.empty,people: $Set.empty};
   var Model = F2(function (a,b) {
      return {happiness: a,people: b};
   });
   var outer = function (list) {
      var last = $List.head($List.reverse(list));
      var first = $List.head(list);
      var _p0 = {ctor: "_Tuple2",_0: first,_1: last};
      if (_p0.ctor === "_Tuple2" && _p0._0.ctor === "Just" && _p0._1.ctor === "Just")
      {
            return $Maybe.Just({ctor: "_Tuple2"
                               ,_0: _p0._1._0
                               ,_1: _p0._0._0});
         } else {
            return $Maybe.Nothing;
         }
   };
   var inner = function (list) {
      var _p1 = list;
      if (_p1.ctor === "::" && _p1._1.ctor === "::") {
            var _p2 = _p1._1._0;
            return A2($List._op["::"],
            {ctor: "_Tuple2",_0: _p1._0,_1: _p2},
            inner(A2($List._op["::"],_p2,_p1._1._1)));
         } else {
            return _U.list([]);
         }
   };
   var pairup = function (list) {
      var pair = outer(list);
      var pairs = inner(list);
      var _p3 = pair;
      if (_p3.ctor === "Just" && _p3._0.ctor === "_Tuple2") {
            return A2($List._op["::"],
            {ctor: "_Tuple2",_0: _p3._0._0,_1: _p3._0._1},
            pairs);
         } else {
            return pairs;
         }
   };
   var key = F2(function (p1,p2) {
      return A2($Basics._op["++"],p1,A2($Basics._op["++"],"|",p2));
   });
   var parseLine = F2(function (line,model) {
      var matches = A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("^(\\w+) would (gain|lose) (\\d+) happiness units by sitting next to (\\w+)\\.$"),
      line));
      var _p4 = matches;
      if (_p4.ctor === "::" && _p4._0.ctor === "::" && _p4._0._0.ctor === "Just" && _p4._0._1.ctor === "::" && _p4._0._1._0.ctor === "Just" && _p4._0._1._1.ctor === "::" && _p4._0._1._1._0.ctor === "Just" && _p4._0._1._1._1.ctor === "::" && _p4._0._1._1._1._0.ctor === "Just" && _p4._0._1._1._1._1.ctor === "[]" && _p4._1.ctor === "[]")
      {
            var _p6 = _p4._0._1._1._1._0._0;
            var _p5 = _p4._0._0._0;
            var p = A2($Set.insert,_p6,A2($Set.insert,_p5,model.people));
            var j = A2($Result.withDefault,
            0,
            $String.toInt(_p4._0._1._1._0._0));
            var k = _U.eq(_p4._0._1._0._0,"gain") ? j : 0 - j;
            var h = A3($Dict.insert,A2(key,_p5,_p6),k,model.happiness);
            return {happiness: h,people: p};
         } else {
            return model;
         }
   });
   var parseInput = function (input) {
      return A3($List.foldl,
      parseLine,
      initModel,
      A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input)));
   };
   var addMe = function (model) {
      var h0 = model.happiness;
      var a = $Set.toList(model.people);
      var me = "Me";
      var p = A2($Set.insert,me,model.people);
      var h1 = A3($List.foldl,
      F2(function (p,h) {
         return A3($Dict.insert,A2(key,me,p),0,h);
      }),
      h0,
      a);
      var h2 = A3($List.foldl,
      F2(function (p,h) {
         return A3($Dict.insert,A2(key,p,me),0,h);
      }),
      h1,
      a);
      return {happiness: h2,people: p};
   };
   var pairValue = F3(function (p1,p2,h) {
      var v2 = A2($Maybe.withDefault,
      0,
      A2($Dict.get,A2(key,p2,p1),h));
      var v1 = A2($Maybe.withDefault,0,A2($Dict.get,A2(key,p1,p2),h));
      return v1 + v2;
   });
   var happinesses = function (model) {
      var f = function (_p7) {
         var _p8 = _p7;
         return A3(pairValue,_p8._0,_p8._1,model.happiness);
      };
      return A2($List.map,
      function (pairs) {
         return $List.sum(A2($List.map,f,pairs));
      },
      A2($List.map,
      function (perm) {
         return pairup(perm);
      },
      $Util.permutations($Set.toList(model.people))));
   };
   var answers = function (input) {
      var m1 = parseInput(input);
      var a1 = happinesses(m1);
      var p1 = $Basics.toString(A2($Maybe.withDefault,
      0,
      $List.maximum(a1)));
      var m2 = addMe(m1);
      var a2 = happinesses(m2);
      var p2 = $Basics.toString(A2($Maybe.withDefault,
      0,
      $List.maximum(a2)));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D13.values = {_op: _op
                               ,answers: answers
                               ,happinesses: happinesses
                               ,pairValue: pairValue
                               ,addMe: addMe
                               ,parseInput: parseInput
                               ,parseLine: parseLine
                               ,key: key
                               ,pairup: pairup
                               ,inner: inner
                               ,outer: outer
                               ,Model: Model
                               ,initModel: initModel};
};
Elm.Y15D14 = Elm.Y15D14 || {};
Elm.Y15D14.make = function (_elm) {
   "use strict";
   _elm.Y15D14 = _elm.Y15D14 || {};
   if (_elm.Y15D14.values) return _elm.Y15D14.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var Reindeer = F6(function (a,b,c,d,e,f) {
      return {name: a,speed: b,time: c,rest: d,km: e,score: f};
   });
   var parseLine = F2(function (line,model) {
      var matches = A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("^(\\w+) can fly (\\d+) km/s for (\\d+) seconds, but then must rest for (\\d+) seconds\\.$"),
      line));
      var _p0 = matches;
      if (_p0.ctor === "::" && _p0._0.ctor === "::" && _p0._0._0.ctor === "Just" && _p0._0._1.ctor === "::" && _p0._0._1._0.ctor === "Just" && _p0._0._1._1.ctor === "::" && _p0._0._1._1._0.ctor === "Just" && _p0._0._1._1._1.ctor === "::" && _p0._0._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1.ctor === "[]" && _p0._1.ctor === "[]")
      {
            var r2 = A2($Result.withDefault,
            0,
            $String.toInt(_p0._0._1._1._1._0._0));
            var t2 = A2($Result.withDefault,
            0,
            $String.toInt(_p0._0._1._1._0._0));
            var s2 = A2($Result.withDefault,
            0,
            $String.toInt(_p0._0._1._0._0));
            var reindeer = {name: _p0._0._0._0
                           ,speed: s2
                           ,time: t2
                           ,rest: r2
                           ,km: 0
                           ,score: 0};
            return A2($List._op["::"],reindeer,model);
         } else {
            return model;
         }
   });
   var parseInput = function (input) {
      return A3($List.foldl,
      parseLine,
      _U.list([]),
      A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input)));
   };
   var distance = F2(function (t,r) {
      var cyc = r.time + r.rest;
      var tmp = A2($Basics.rem,t,cyc);
      var rdr = _U.cmp(tmp,r.time) > 0 ? r.time : tmp;
      return ((t / cyc | 0) * r.time + rdr) * r.speed;
   });
   var score = F3(function (t,time,model) {
      score: while (true) if (_U.cmp(t,time) > -1) return model;
      else {
            var t$ = t + 1;
            var model1 = A2($List.map,
            function (r) {
               return _U.update(r,{km: A2(distance,t$,r)});
            },
            model);
            var maxDst = A2($Maybe.withDefault,
            0,
            $List.maximum(A2($List.map,
            function (_) {
               return _.km;
            },
            model1)));
            var model2 = A2($List.map,
            function (r) {
               return _U.update(r,
               {score: r.score + (_U.eq(r.km,maxDst) ? 1 : 0)});
            },
            model1);
            var _v1 = t$,_v2 = time,_v3 = model2;
            t = _v1;
            time = _v2;
            model = _v3;
            continue score;
         }
   });
   var bestScore = F2(function (time,model) {
      return $Basics.toString(A2($Maybe.withDefault,
      0,
      $List.maximum(A2($List.map,
      function (_) {
         return _.score;
      },
      A3(score,0,time,model)))));
   });
   var maxDistance = F2(function (time,model) {
      return $Basics.toString(A2($Maybe.withDefault,
      0,
      $List.maximum(A2($List.map,distance(time),model))));
   });
   var answers = function (input) {
      var time = 2503;
      var model = parseInput(input);
      var p1 = A2(maxDistance,time,model);
      var p2 = A2(bestScore,time,model);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D14.values = {_op: _op
                               ,answers: answers
                               ,maxDistance: maxDistance
                               ,bestScore: bestScore
                               ,distance: distance
                               ,score: score
                               ,parseInput: parseInput
                               ,parseLine: parseLine
                               ,Reindeer: Reindeer};
};
Elm.Y15D15 = Elm.Y15D15 || {};
Elm.Y15D15.make = function (_elm) {
   "use strict";
   _elm.Y15D15 = _elm.Y15D15 || {};
   if (_elm.Y15D15.values) return _elm.Y15D15.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var initCookie = F2(function (model,total) {
      var size = $List.length(model);
      var first = total - size + 1;
      var ones = A2($List.repeat,size - 1,1);
      return A2($List._op["::"],first,ones);
   });
   var Ingredient = F6(function (a,b,c,d,e,f) {
      return {name: a
             ,capacity: b
             ,durability: c
             ,flavor: d
             ,texture: e
             ,calories: f};
   });
   var parseInt = function (s) {
      return A2($Result.withDefault,0,$String.toInt(s));
   };
   var parseLine = F2(function (line,model) {
      var rgx = A2($Basics._op["++"],
      "^(\\w+): ",
      A2($Basics._op["++"],
      "capacity (-?\\d+), ",
      A2($Basics._op["++"],
      "durability (-?\\d+), ",
      A2($Basics._op["++"],
      "flavor (-?\\d+), ",
      A2($Basics._op["++"],
      "texture (-?\\d+), ",
      "calories (-?\\d+)$")))));
      var matches = A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,$Regex.AtMost(1),$Regex.regex(rgx),line));
      var _p0 = matches;
      if (_p0.ctor === "::" && _p0._0.ctor === "::" && _p0._0._0.ctor === "Just" && _p0._0._1.ctor === "::" && _p0._0._1._0.ctor === "Just" && _p0._0._1._1.ctor === "::" && _p0._0._1._1._0.ctor === "Just" && _p0._0._1._1._1.ctor === "::" && _p0._0._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1.ctor === "::" && _p0._0._1._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1._1.ctor === "::" && _p0._0._1._1._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1._1._1.ctor === "[]" && _p0._1.ctor === "[]")
      {
            var cl2 = parseInt(_p0._0._1._1._1._1._1._0._0);
            var tx2 = parseInt(_p0._0._1._1._1._1._0._0);
            var fl2 = parseInt(_p0._0._1._1._1._0._0);
            var du2 = parseInt(_p0._0._1._1._0._0);
            var cp2 = parseInt(_p0._0._1._0._0);
            return A2($List._op["::"],
            A6(Ingredient,_p0._0._0._0,cp2,du2,fl2,tx2,cl2),
            model);
         } else {
            return model;
         }
   });
   var parseInput = function (input) {
      return A3($List.foldl,
      parseLine,
      _U.list([]),
      A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input)));
   };
   var score = F3(function (m,calories,cookie) {
      var excluded = function () {
         var _p1 = calories;
         if (_p1.ctor === "Just") {
               return !_U.eq(_p1._0,
               $List.sum(A3($List.map2,
               F2(function (x,y) {    return x * y;}),
               A2($List.map,function (_) {    return _.calories;},m),
               cookie)));
            } else {
               return false;
            }
      }();
      if (excluded) return 0; else {
            var tx = $List.sum(A3($List.map2,
            F2(function (x,y) {    return x * y;}),
            A2($List.map,function (_) {    return _.texture;},m),
            cookie));
            var fl = $List.sum(A3($List.map2,
            F2(function (x,y) {    return x * y;}),
            A2($List.map,function (_) {    return _.flavor;},m),
            cookie));
            var du = $List.sum(A3($List.map2,
            F2(function (x,y) {    return x * y;}),
            A2($List.map,function (_) {    return _.durability;},m),
            cookie));
            var cp = $List.sum(A3($List.map2,
            F2(function (x,y) {    return x * y;}),
            A2($List.map,function (_) {    return _.capacity;},m),
            cookie));
            return $List.product(A2($List.map,
            function (s) {
               return _U.cmp(s,0) < 0 ? 0 : s;
            },
            _U.list([cp,du,fl,tx])));
         }
   });
   var increment = function (l) {
      var _p2 = l;
      if (_p2.ctor === "[]") {
            return _U.list([]);
         } else {
            return A2($List._op["::"],_p2._0 + 1,_p2._1);
         }
   };
   var rollover = function (l) {
      rollover: while (true) {
         var _p3 = l;
         if (_p3.ctor === "[]") {
               return {ctor: "_Tuple2",_0: 0,_1: _U.list([])};
            } else {
               if (_p3._0 === 1) {
                     var _v4 = _p3._1;
                     l = _v4;
                     continue rollover;
                  } else {
                     return {ctor: "_Tuple2"
                            ,_0: _p3._0 - 1
                            ,_1: increment(_p3._1)};
                  }
            }
      }
   };
   var next = function (c) {
      var _p4 = c;
      if (_p4.ctor === "[]") {
            return $Maybe.Nothing;
         } else {
            if (_p4._0 === 1) {
                  var _p5 = rollover(_p4._1);
                  var n = _p5._0;
                  var l = _p5._1;
                  if (_U.eq(n,0)) return $Maybe.Nothing; else {
                        var ones = A2($List.repeat,
                        $List.length(c) - $List.length(l) - 1,
                        1);
                        return $Maybe.Just(A2($List._op["::"],
                        n,
                        A2($Basics._op["++"],ones,l)));
                     }
               } else {
                  return $Maybe.Just(A2($List._op["::"],
                  _p4._0 - 1,
                  increment(_p4._1)));
               }
         }
   };
   var highScore = F4(function (model,calories,oldHigh,oldCookie) {
      highScore: while (true) {
         var newCookie = next(oldCookie);
         var newHigh = A2($Maybe.withDefault,
         oldHigh,
         $List.maximum(_U.list([A3(score,model,calories,oldCookie)
                               ,oldHigh])));
         var _p6 = newCookie;
         if (_p6.ctor === "Just") {
               var _v7 = model,_v8 = calories,_v9 = newHigh,_v10 = _p6._0;
               model = _v7;
               calories = _v8;
               oldHigh = _v9;
               oldCookie = _v10;
               continue highScore;
            } else {
               return newHigh;
            }
      }
   });
   var answers = function (input) {
      var model = parseInput(input);
      var cookie = A2(initCookie,model,100);
      var p1 = $Basics.toString(A4(highScore,
      model,
      $Maybe.Nothing,
      0,
      cookie));
      var p2 = $Basics.toString(A4(highScore,
      model,
      $Maybe.Just(500),
      0,
      cookie));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D15.values = {_op: _op
                               ,answers: answers
                               ,highScore: highScore
                               ,next: next
                               ,rollover: rollover
                               ,increment: increment
                               ,score: score
                               ,parseInput: parseInput
                               ,parseLine: parseLine
                               ,parseInt: parseInt
                               ,Ingredient: Ingredient
                               ,initCookie: initCookie};
};
Elm.Y15D16 = Elm.Y15D16 || {};
Elm.Y15D16.make = function (_elm) {
   "use strict";
   _elm.Y15D16 = _elm.Y15D16 || {};
   if (_elm.Y15D16.values) return _elm.Y15D16.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var Sue = F2(function (a,b) {    return {number: a,props: b};});
   var parseInt = function (s) {
      return A2($Result.withDefault,0,$String.toInt(s));
   };
   var parseLine = F2(function (line,model) {
      var cs = "(akitas|cars|cats|children|goldfish|perfumes|pomeranians|samoyeds|trees|vizslas): (\\d+)";
      var rx = A2($Basics._op["++"],
      "Sue ([1-9]\\d*): ",
      A2($String.join,", ",A2($List.repeat,3,cs)));
      var ms = A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,$Regex.AtMost(1),$Regex.regex(rx),line));
      var _p0 = ms;
      if (_p0.ctor === "::" && _p0._0.ctor === "::" && _p0._0._0.ctor === "Just" && _p0._0._1.ctor === "::" && _p0._0._1._0.ctor === "Just" && _p0._0._1._1.ctor === "::" && _p0._0._1._1._0.ctor === "Just" && _p0._0._1._1._1.ctor === "::" && _p0._0._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1.ctor === "::" && _p0._0._1._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1._1.ctor === "::" && _p0._0._1._1._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1._1._1.ctor === "::" && _p0._0._1._1._1._1._1._1._0.ctor === "Just" && _p0._0._1._1._1._1._1._1._1.ctor === "[]" && _p0._1.ctor === "[]")
      {
            var d = A3($Dict.insert,
            _p0._0._1._1._1._1._1._0._0,
            parseInt(_p0._0._1._1._1._1._1._1._0._0),
            A3($Dict.insert,
            _p0._0._1._1._1._0._0,
            parseInt(_p0._0._1._1._1._1._0._0),
            A3($Dict.insert,
            _p0._0._1._0._0,
            parseInt(_p0._0._1._1._0._0),
            $Dict.empty)));
            var i = parseInt(_p0._0._0._0);
            return A2($List._op["::"],A2(Sue,i,d),model);
         } else {
            return model;
         }
   });
   var parseInput = function (input) {
      return A3($List.foldl,
      parseLine,
      _U.list([]),
      A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input)));
   };
   var match2 = F3(function (prop,val,prevProp) {
      if ($Basics.not(prevProp)) return false; else {
            var _p1 = prop;
            switch (_p1)
            {case "akitas": return _U.eq(val,0);
               case "cars": return _U.eq(val,2);
               case "cats": return _U.cmp(val,7) > 0;
               case "children": return _U.eq(val,3);
               case "goldfish": return _U.cmp(val,5) < 0;
               case "perfumes": return _U.eq(val,1);
               case "pomeranians": return _U.cmp(val,3) < 0;
               case "samoyeds": return _U.eq(val,2);
               case "trees": return _U.cmp(val,3) > 0;
               case "vizslas": return _U.eq(val,0);
               default: return false;}
         }
   });
   var match1 = F3(function (prop,val,prevProp) {
      if ($Basics.not(prevProp)) return false; else {
            var _p2 = prop;
            switch (_p2)
            {case "akitas": return _U.eq(val,0);
               case "cars": return _U.eq(val,2);
               case "cats": return _U.eq(val,7);
               case "children": return _U.eq(val,3);
               case "goldfish": return _U.eq(val,5);
               case "perfumes": return _U.eq(val,1);
               case "pomeranians": return _U.eq(val,3);
               case "samoyeds": return _U.eq(val,2);
               case "trees": return _U.eq(val,3);
               case "vizslas": return _U.eq(val,0);
               default: return false;}
         }
   });
   var sue = F2(function (hit,model) {
      var sues = A2($List.filter,
      function (s) {
         return A3($Dict.foldl,hit,true,s.props);
      },
      model);
      var _p3 = $List.length(sues);
      switch (_p3)
      {case 0: return "none";
         case 1: return $Basics.toString(A2($Maybe.withDefault,
           0,
           $List.head(A2($List.map,
           function (_) {
              return _.number;
           },
           sues))));
         default: return "too many";}
   });
   var answers = function (input) {
      var model = parseInput(input);
      var p1 = A2(sue,match1,model);
      var p2 = A2(sue,match2,model);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D16.values = {_op: _op
                               ,answers: answers
                               ,sue: sue
                               ,match1: match1
                               ,match2: match2
                               ,parseInput: parseInput
                               ,parseLine: parseLine
                               ,parseInt: parseInt
                               ,Sue: Sue};
};
Elm.Y15D17 = Elm.Y15D17 || {};
Elm.Y15D17.make = function (_elm) {
   "use strict";
   _elm.Y15D17 = _elm.Y15D17 || {};
   if (_elm.Y15D17.values) return _elm.Y15D17.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var parseInput = function (input) {
      return A2($List.filter,
      function (i) {
         return _U.cmp(i,0) > 0;
      },
      A2($List.map,
      $Result.withDefault(0),
      A2($List.map,
      $String.toInt,
      A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.All,$Regex.regex("[1-9]\\d*"),input)))));
   };
   var combos = F3(function (n,total,model) {
      if (_U.eq(n,0)) return {ctor: "_Tuple2",_0: 0,_1: 0}; else {
            var _p0 = A3(combos,n - 1,total,model);
            var q = _p0._0;
            var r = _p0._1;
            var p = $List.length(A2($List.filter,
            function (c) {
               return _U.eq($List.sum(c),total);
            },
            A2($Util.combinations,n,model)));
            return {ctor: "_Tuple2",_0: p + q,_1: _U.eq(r,0) ? p : r};
         }
   });
   var answers = function (input) {
      var model = parseInput(input);
      var number = A3(combos,$List.length(model),150,model);
      var p1 = $Basics.toString($Basics.fst(number));
      var p2 = $Basics.toString($Basics.snd(number));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D17.values = {_op: _op
                               ,answers: answers
                               ,combos: combos
                               ,parseInput: parseInput};
};
Elm.Y15D18 = Elm.Y15D18 || {};
Elm.Y15D18.make = function (_elm) {
   "use strict";
   _elm.Y15D18 = _elm.Y15D18 || {};
   if (_elm.Y15D18.values) return _elm.Y15D18.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Array = Elm.Array.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var initModel = {lights: $Array.empty
                   ,size: 0
                   ,maxIndex: 0
                   ,stuck: false};
   var Model = F4(function (a,b,c,d) {
      return {lights: a,size: b,maxIndex: c,stuck: d};
   });
   var debug = function (model) {
      var chars = A2($String.join,
      "",
      A2($List.map,
      function (b) {
         return b ? "#" : ".";
      },
      $Array.toList(model.lights)));
      var lines = A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,
      $Regex.All,
      $Regex.regex(A2($Basics._op["++"],
      ".{",
      A2($Basics._op["++"],$Basics.toString(model.size),"}"))),
      chars));
      return A2($Basics._op["++"],A2($String.join,"\n",lines),"\n");
   };
   var parseInput = function (input) {
      var a = A3($List.foldl,
      $Array.push,
      $Array.empty,
      A2($List.map,
      function (s) {
         return _U.eq(s,"#");
      },
      A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.All,$Regex.regex("[#.]"),input))));
      var s = $Basics.ceiling($Basics.sqrt($Basics.toFloat($Array.length(a))));
      var m = s - 1;
      return A4(Model,a,s,m,false);
   };
   var count = function (model) {
      return $List.length(A2($List.filter,
      $Basics.identity,
      $Array.toList(model.lights)));
   };
   var outside = F2(function (model,_p0) {
      var _p1 = _p0;
      var _p3 = _p1._0;
      var _p2 = _p1._1;
      return _U.cmp(_p3,model.maxIndex) > 0 || (_U.cmp(_p3,
      0) < 0 || (_U.cmp(_p2,model.maxIndex) > 0 || _U.cmp(_p2,
      0) < 0));
   });
   var next = F2(function (model,_p4) {
      var _p5 = _p4;
      var _p7 = _p5._0;
      var _p6 = _p5._1;
      return _U.cmp(_p6,model.maxIndex) > -1 ? {ctor: "_Tuple2"
                                               ,_0: _p7 + 1
                                               ,_1: 0} : {ctor: "_Tuple2",_0: _p7,_1: _p6 + 1};
   });
   var corner = F2(function (model,_p8) {
      var _p9 = _p8;
      var _p11 = _p9._0;
      var _p10 = _p9._1;
      return (_U.eq(_p11,0) || _U.eq(_p11,
      model.maxIndex)) && (_U.eq(_p10,0) || _U.eq(_p10,
      model.maxIndex));
   });
   var index = F2(function (model,_p12) {
      var _p13 = _p12;
      return _p13._0 * model.size + _p13._1;
   });
   var stick = function (model) {
      var a = A3($Array.set,
      A2(index,
      model,
      {ctor: "_Tuple2",_0: model.maxIndex,_1: model.maxIndex}),
      true,
      A3($Array.set,
      A2(index,model,{ctor: "_Tuple2",_0: model.maxIndex,_1: 0}),
      true,
      A3($Array.set,
      A2(index,model,{ctor: "_Tuple2",_0: 0,_1: model.maxIndex}),
      true,
      A3($Array.set,
      A2(index,model,{ctor: "_Tuple2",_0: 0,_1: 0}),
      true,
      model.lights))));
      return _U.update(model,{lights: a,stuck: true});
   };
   var query = F2(function (model,cell) {
      return A2(outside,
      model,
      cell) ? false : A2($Maybe.withDefault,
      false,
      A2($Array.get,A2(index,model,cell),model.lights));
   });
   var neighbours = F2(function (model,_p14) {
      var _p15 = _p14;
      var ds = _U.list([{ctor: "_Tuple2",_0: -1,_1: -1}
                       ,{ctor: "_Tuple2",_0: 0,_1: -1}
                       ,{ctor: "_Tuple2",_0: 1,_1: -1}
                       ,{ctor: "_Tuple2",_0: -1,_1: 0}
                       ,{ctor: "_Tuple2",_0: 1,_1: 0}
                       ,{ctor: "_Tuple2",_0: -1,_1: 1}
                       ,{ctor: "_Tuple2",_0: 0,_1: 1}
                       ,{ctor: "_Tuple2",_0: 1,_1: 1}]);
      return $List.length(A2($List.filter,
      $Basics.identity,
      A2($List.map,
      query(model),
      A2($List.map,
      function (_p16) {
         var _p17 = _p16;
         return {ctor: "_Tuple2"
                ,_0: _p15._0 + _p17._0
                ,_1: _p15._1 + _p17._1};
      },
      ds))));
   });
   var newVal = F2(function (model,cell) {
      if (model.stuck && A2(corner,model,cell)) return true; else {
            var n = A2(neighbours,model,cell);
            return A2(query,model,cell) ? _U.eq(n,2) || _U.eq(n,
            3) : _U.eq(n,3);
         }
   });
   var sweep = F3(function (oldModel,model,cell) {
      sweep: while (true) if (A2(outside,model,cell)) return model;
      else {
            var v = A2(newVal,oldModel,cell);
            var model = _U.update(model,
            {lights: A3($Array.set,A2(index,model,cell),v,model.lights)});
            var nextCell = A2(next,model,cell);
            var _v6 = oldModel,_v7 = model,_v8 = nextCell;
            oldModel = _v6;
            model = _v7;
            cell = _v8;
            continue sweep;
         }
   });
   var step = function (model) {
      var oldModel = model;
      var start = {ctor: "_Tuple2",_0: 0,_1: 0};
      return A3(sweep,oldModel,model,start);
   };
   var steps = F2(function (n,model) {
      steps: while (true) if (_U.cmp(n,0) < 1) return model; else {
            var _v9 = n - 1,_v10 = step(model);
            n = _v9;
            model = _v10;
            continue steps;
         }
   });
   var answers = function (input) {
      var nm = 100;
      var model = parseInput(input);
      var m1 = A2(steps,nm,model);
      var p1 = $Basics.toString(count(m1));
      var m2 = A2(steps,nm,stick(model));
      var p2 = $Basics.toString(count(m2));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D18.values = {_op: _op
                               ,answers: answers
                               ,steps: steps
                               ,step: step
                               ,sweep: sweep
                               ,newVal: newVal
                               ,neighbours: neighbours
                               ,query: query
                               ,index: index
                               ,corner: corner
                               ,next: next
                               ,outside: outside
                               ,count: count
                               ,stick: stick
                               ,parseInput: parseInput
                               ,debug: debug
                               ,Model: Model
                               ,initModel: initModel};
};
Elm.Y15D19 = Elm.Y15D19 || {};
Elm.Y15D19.make = function (_elm) {
   "use strict";
   _elm.Y15D19 = _elm.Y15D19 || {};
   if (_elm.Y15D19.values) return _elm.Y15D19.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Set = Elm.Set.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var comaRgx = $Regex.regex("Y");
   var bracRgx = $Regex.regex("(Ar|Rn)");
   var atomRgx = $Regex.regex("[A-Z][a-z]?");
   var moleRgx = $Regex.regex("((?:[A-Z][a-z]?){10,})");
   var ruleRgx = $Regex.regex("(e|[A-Z][a-z]?) => ((?:[A-Z][a-z]?)+)");
   var count = F2(function (rgx,model) {
      return $List.length(A3($Regex.find,
      $Regex.All,
      rgx,
      model.molecule));
   });
   var addToReplacements = F5(function (matches,
   from,
   to,
   molecule,
   replacements) {
      addToReplacements: while (true) {
         var _p0 = matches;
         if (_p0.ctor === "[]") {
               return replacements;
            } else {
               var _p1 = _p0._0;
               var right = A3($String.slice,
               _p1.index + $String.length(from),
               -1,
               molecule);
               var left = A3($String.slice,0,_p1.index,molecule);
               var replacement = A2($Basics._op["++"],
               left,
               A2($Basics._op["++"],to,right));
               var replacements$ = A2($Set.insert,replacement,replacements);
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
   var iterateRules = function (model) {
      iterateRules: while (true) {
         var _p2 = model.rules;
         if (_p2.ctor === "[]") {
               return model;
            } else {
               var _p3 = _p2._0;
               var to = $Basics.snd(_p3);
               var from = $Basics.fst(_p3);
               var matches = A3($Regex.find,
               $Regex.All,
               $Regex.regex(from),
               model.molecule);
               var replacements$ = A5(addToReplacements,
               matches,
               from,
               to,
               model.molecule,
               model.replacements);
               var model$ = {rules: _p2._1
                            ,molecule: model.molecule
                            ,replacements: replacements$};
               var _v7 = model$;
               model = _v7;
               continue iterateRules;
            }
      }
   };
   var extractMolecule = function (submatches) {
      var _p4 = submatches;
      if (_p4.ctor === "Nothing") {
            return "";
         } else {
            var _p5 = _p4._0;
            if (_p5.ctor === "::" && _p5._0.ctor === "Just" && _p5._1.ctor === "[]")
            {
                  return _p5._0._0;
               } else {
                  return "";
               }
         }
   };
   var extractRule = function (submatches) {
      var _p6 = submatches;
      if (_p6.ctor === "::" && _p6._0.ctor === "Just" && _p6._1.ctor === "::" && _p6._1._0.ctor === "Just" && _p6._1._1.ctor === "[]")
      {
            return {ctor: "_Tuple2",_0: _p6._0._0,_1: _p6._1._0._0};
         } else {
            return {ctor: "_Tuple2",_0: "",_1: ""};
         }
   };
   var parse = function (input) {
      var molecule = extractMolecule($List.head(A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,$Regex.All,moleRgx,input))));
      var rules = A2($List.map,
      extractRule,
      A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,$Regex.All,ruleRgx,input)));
      return {rules: rules
             ,molecule: molecule
             ,replacements: $Set.empty};
   };
   var askalski = function (model) {
      var comas = A2(count,comaRgx,model);
      var bracs = A2(count,bracRgx,model);
      var atoms = A2(count,atomRgx,model);
      return $Basics.toString(atoms - bracs - 2 * comas - 1);
   };
   var molecules = function (model) {
      var model$ = iterateRules(model);
      return $Basics.toString($Set.size(model$.replacements));
   };
   var Model = F3(function (a,b,c) {
      return {rules: a,molecule: b,replacements: c};
   });
   var answers = function (input) {
      var model = parse(input);
      var p1 = molecules(model);
      var p2 = askalski(model);
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D19.values = {_op: _op
                               ,answers: answers
                               ,Model: Model
                               ,molecules: molecules
                               ,askalski: askalski
                               ,parse: parse
                               ,extractRule: extractRule
                               ,extractMolecule: extractMolecule
                               ,iterateRules: iterateRules
                               ,addToReplacements: addToReplacements
                               ,count: count
                               ,ruleRgx: ruleRgx
                               ,moleRgx: moleRgx
                               ,atomRgx: atomRgx
                               ,bracRgx: bracRgx
                               ,comaRgx: comaRgx};
};
Elm.Y15D20 = Elm.Y15D20 || {};
Elm.Y15D20.make = function (_elm) {
   "use strict";
   _elm.Y15D20 = _elm.Y15D20 || {};
   if (_elm.Y15D20.values) return _elm.Y15D20.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var parseInput = function (input) {
      return A2($Result.withDefault,
      0,
      $String.toInt(A2($Maybe.withDefault,
      "0",
      $List.head(A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("\\d+"),
      input))))));
   };
   var fac = F4(function (n,i,l,fs) {
      if (_U.cmp($Basics.toFloat(i),l) > 0) return fs; else {
            var fs1 = function () {
               if (!_U.eq(A2($Basics.rem,n,i),0)) return fs; else {
                     var j = n / i | 0;
                     var fs2 = A2($List._op["::"],i,fs);
                     return _U.eq(j,i) ? fs2 : A2($List._op["::"],j,fs2);
                  }
            }();
            return A2($Basics._op["++"],fs1,A4(fac,n,i + 1,l,fs));
         }
   });
   var factors = function (n) {
      return A4(fac,
      n,
      1,
      $Basics.sqrt($Basics.toFloat(n)),
      _U.list([]));
   };
   var house2 = F2(function (goal,house) {
      house2: while (true) {
         var presents = $List.sum(A2($List.map,
         F2(function (x,y) {    return x * y;})(11),
         A2($List.filter,
         function (elf) {
            return _U.cmp(house / elf | 0,50) < 1;
         },
         factors(house))));
         if (_U.cmp(presents,goal) > -1) return house; else {
               var _v0 = goal,_v1 = house + 1;
               goal = _v0;
               house = _v1;
               continue house2;
            }
      }
   });
   var house1 = F2(function (goal,house) {
      house1: while (true) {
         var presents = $List.sum(A2($List.map,
         F2(function (x,y) {    return x * y;})(10),
         factors(house)));
         if (_U.cmp(presents,goal) > -1) return house; else {
               var _v2 = goal,_v3 = house + 1;
               goal = _v2;
               house = _v3;
               continue house1;
            }
      }
   });
   var answers = function (input) {
      var goal = parseInput(input);
      var p1 = $Basics.toString(A2(house1,goal,1));
      var p2 = $Basics.toString(A2(house2,goal,1));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D20.values = {_op: _op
                               ,answers: answers
                               ,house1: house1
                               ,house2: house2
                               ,factors: factors
                               ,fac: fac
                               ,parseInput: parseInput};
};
Elm.Y15D21 = Elm.Y15D21 || {};
Elm.Y15D21.make = function (_elm) {
   "use strict";
   _elm.Y15D21 = _elm.Y15D21 || {};
   if (_elm.Y15D21.values) return _elm.Y15D21.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Array = Elm.Array.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var Index = F4(function (a,b,c,d) {
      return {w: a,a: b,r1: c,r2: d};
   });
   var initIndex = $Maybe.Just(A4(Index,0,0,0,1));
   var Fighter = F5(function (a,b,c,d,e) {
      return {hitp: a,damage: b,armor: c,cost: d,player: e};
   });
   var parseInput = function (input) {
      var ns = A2($List.map,
      $String.toInt,
      A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.All,$Regex.regex("\\d+"),input)));
      var _p0 = ns;
      if (_p0.ctor === "::" && _p0._0.ctor === "Ok" && _p0._1.ctor === "::" && _p0._1._0.ctor === "Ok" && _p0._1._1.ctor === "::" && _p0._1._1._0.ctor === "Ok" && _p0._1._1._1.ctor === "[]")
      {
            return A5(Fighter,
            _p0._0._0,
            _p0._1._0._0,
            _p0._1._1._0._0,
            0,
            false);
         } else {
            return A5(Fighter,0,0,0,0,false);
         }
   };
   var rings = $Array.fromList(_U.list([_U.list([0,0,0])
                                       ,_U.list([0,0,0])
                                       ,_U.list([25,1,0])
                                       ,_U.list([50,2,0])
                                       ,_U.list([100,3,0])
                                       ,_U.list([20,0,1])
                                       ,_U.list([40,0,2])
                                       ,_U.list([80,0,3])]));
   var armors = $Array.fromList(_U.list([_U.list([0,0,0])
                                        ,_U.list([13,0,1])
                                        ,_U.list([31,0,2])
                                        ,_U.list([53,0,3])
                                        ,_U.list([75,0,4])
                                        ,_U.list([102,0,5])]));
   var weapons = $Array.fromList(_U.list([_U.list([8,4,0])
                                         ,_U.list([10,5,0])
                                         ,_U.list([25,6,0])
                                         ,_U.list([40,7,0])
                                         ,_U.list([74,8,0])]));
   var winner = F2(function (attacker,defender) {
      winner: while (true) if (_U.cmp(attacker.hitp,0) < 1)
      return defender.player; else {
            var damage = attacker.damage - defender.armor;
            var hitp = defender.hitp - (_U.cmp(damage,1) < 0 ? 1 : damage);
            var damaged = _U.update(defender,{hitp: hitp});
            var _v1 = damaged,_v2 = attacker;
            attacker = _v1;
            defender = _v2;
            continue winner;
         }
   });
   var nextIndex = function (i) {
      return _U.cmp(i.r2,7) < 0 ? $Maybe.Just(_U.update(i,
      {r2: i.r2 + 1})) : _U.cmp(i.r1,6) < 0 ? $Maybe.Just(_U.update(i,
      {r1: i.r1 + 1,r2: i.r1 + 2})) : _U.cmp(i.a,
      5) < 0 ? $Maybe.Just(_U.update(i,
      {a: i.a + 1,r1: 0,r2: 1})) : _U.cmp(i.w,
      4) < 0 ? $Maybe.Just(_U.update(i,
      {w: i.w + 1,a: 0,r1: 0,r2: 1})) : $Maybe.Nothing;
   };
   var fighterFromIndex = function (i) {
      var ring2 = A2($Maybe.withDefault,
      _U.list([0,0,0]),
      A2($Array.get,i.r2,rings));
      var ring1 = A2($Maybe.withDefault,
      _U.list([0,0,0]),
      A2($Array.get,i.r1,rings));
      var armor = A2($Maybe.withDefault,
      _U.list([0,0,0]),
      A2($Array.get,i.a,armors));
      var weapon = A2($Maybe.withDefault,
      _U.list([0,0,0]),
      A2($Array.get,i.w,weapons));
      var totals = A5($List.map4,
      F4(function (w,a,r1,r2) {    return w + a + r1 + r2;}),
      weapon,
      armor,
      ring1,
      ring2);
      var _p1 = totals;
      if (_p1.ctor === "::" && _p1._1.ctor === "::" && _p1._1._1.ctor === "::" && _p1._1._1._1.ctor === "[]")
      {
            return A5(Fighter,100,_p1._1._0,_p1._1._1._0,_p1._0,true);
         } else {
            return A5(Fighter,0,0,0,0,true);
         }
   };
   var highest = F3(function (pwin,pcost,best) {
      return $Basics.not(pwin) && _U.cmp(pcost,best) > 0;
   });
   var lowest = F3(function (pwin,pcost,best) {
      return pwin && (_U.eq(best,0) || _U.cmp(pcost,best) < 0);
   });
   var search = F4(function (boss,candidate,best,index) {
      search: while (true) {
         var _p2 = index;
         if (_p2.ctor === "Nothing") {
               return best;
            } else {
               var _p3 = _p2._0;
               var player = fighterFromIndex(_p3);
               var nextBest = A3(candidate,
               A2(winner,player,boss),
               player.cost,
               best) ? player.cost : best;
               var _v5 = boss,
               _v6 = candidate,
               _v7 = nextBest,
               _v8 = nextIndex(_p3);
               boss = _v5;
               candidate = _v6;
               best = _v7;
               index = _v8;
               continue search;
            }
      }
   });
   var answers = function (input) {
      var boss = parseInput(input);
      var p1 = $Basics.toString(A4(search,boss,lowest,0,initIndex));
      var p2 = $Basics.toString(A4(search,boss,highest,0,initIndex));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D21.values = {_op: _op
                               ,answers: answers
                               ,search: search
                               ,lowest: lowest
                               ,highest: highest
                               ,fighterFromIndex: fighterFromIndex
                               ,nextIndex: nextIndex
                               ,winner: winner
                               ,weapons: weapons
                               ,armors: armors
                               ,rings: rings
                               ,parseInput: parseInput
                               ,Fighter: Fighter
                               ,Index: Index
                               ,initIndex: initIndex};
};
Elm.Y15D22 = Elm.Y15D22 || {};
Elm.Y15D22.make = function (_elm) {
   "use strict";
   _elm.Y15D22 = _elm.Y15D22 || {};
   if (_elm.Y15D22.values) return _elm.Y15D22.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm);
   var _op = {};
   var answers = function (input) {    return "not implemented";};
   return _elm.Y15D22.values = {_op: _op,answers: answers};
};
Elm.Y15D23 = Elm.Y15D23 || {};
Elm.Y15D23.make = function (_elm) {
   "use strict";
   _elm.Y15D23 = _elm.Y15D23 || {};
   if (_elm.Y15D23.values) return _elm.Y15D23.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Array = Elm.Array.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $Dict = Elm.Dict.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var Jio = F2(function (a,b) {
      return {ctor: "Jio",_0: a,_1: b};
   });
   var Jie = F2(function (a,b) {
      return {ctor: "Jie",_0: a,_1: b};
   });
   var Jmp = function (a) {    return {ctor: "Jmp",_0: a};};
   var Tpl = function (a) {    return {ctor: "Tpl",_0: a};};
   var Hlf = function (a) {    return {ctor: "Hlf",_0: a};};
   var Inc = function (a) {    return {ctor: "Inc",_0: a};};
   var NoOp = {ctor: "NoOp"};
   var Model = F3(function (a,b,c) {
      return {instructions: a,registers: b,i: c};
   });
   var initModel = {instructions: $Array.empty
                   ,registers: $Dict.empty
                   ,i: 0};
   var parseLine = F2(function (line,model) {
      var rx = "^([a-z]{3})\\s+(a|b)?,?\\s*\\+?(-?\\d*)?";
      var sm = A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,$Regex.AtMost(1),$Regex.regex(rx),line));
      var _p0 = sm;
      if (_p0.ctor === "::" && _p0._0.ctor === "::" && _p0._0._1.ctor === "::" && _p0._0._1._1.ctor === "::" && _p0._0._1._1._1.ctor === "[]" && _p0._1.ctor === "[]")
      {
            var j = A2($Result.withDefault,
            0,
            $String.toInt(A2($Maybe.withDefault,"",_p0._0._1._1._0)));
            var r = A2($Maybe.withDefault,"",_p0._0._1._0);
            var n = A2($Maybe.withDefault,"",_p0._0._0);
            var i = function () {
               var _p1 = n;
               switch (_p1)
               {case "inc": return Inc(r);
                  case "hlf": return Hlf(r);
                  case "tpl": return Tpl(r);
                  case "jmp": return Jmp(j);
                  case "jie": return A2(Jie,r,j);
                  case "jio": return A2(Jio,r,j);
                  default: return NoOp;}
            }();
            return _U.update(model,
            {instructions: A2($Array.push,i,model.instructions)});
         } else {
            return model;
         }
   });
   var parseInput = function (input) {
      return A3($List.foldl,
      parseLine,
      initModel,
      A2($List.filter,
      function (l) {
         return !_U.eq(l,"");
      },
      A2($String.split,"\n",input)));
   };
   var get = F2(function (reg,model) {
      return A2($Maybe.withDefault,
      0,
      A2($Dict.get,reg,model.registers));
   });
   var update = F3(function (name,f,model) {
      var value = f(A2(get,name,model));
      return A3($Dict.insert,name,value,model.registers);
   });
   var run = function (model) {
      run: while (true) {
         var instruction = A2($Array.get,model.i,model.instructions);
         var _p2 = instruction;
         if (_p2.ctor === "Nothing") {
               return model;
            } else {
               var model$ = function () {
                  var _p3 = _p2._0;
                  switch (_p3.ctor)
                  {case "Inc": return _U.update(model,
                       {registers: A3(update,
                       _p3._0,
                       function (v) {
                          return v + 1;
                       },
                       model)
                       ,i: model.i + 1});
                     case "Hlf": return _U.update(model,
                       {registers: A3(update,
                       _p3._0,
                       function (v) {
                          return v / 2 | 0;
                       },
                       model)
                       ,i: model.i + 1});
                     case "Tpl": return _U.update(model,
                       {registers: A3(update,
                       _p3._0,
                       function (v) {
                          return v * 3;
                       },
                       model)
                       ,i: model.i + 1});
                     case "Jmp": return _U.update(model,{i: model.i + _p3._0});
                     case "Jie": return _U.update(model,
                       {i: model.i + (_U.eq(A2($Basics.rem,A2(get,_p3._0,model),2),
                       0) ? _p3._1 : 1)});
                     case "Jio": return _U.update(model,
                       {i: model.i + (_U.eq(A2(get,_p3._0,model),1) ? _p3._1 : 1)});
                     default: return _U.update(model,{i: model.i + 1});}
               }();
               var _v4 = model$;
               model = _v4;
               continue run;
            }
      }
   };
   var answers = function (input) {
      var model1 = parseInput(input);
      var model2 = _U.update(model1,
      {registers: A3($Dict.insert,"a",1,model1.registers)});
      var p2 = $Basics.toString(A2(get,"b",run(model2)));
      var p1 = $Basics.toString(A2(get,"b",run(model1)));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D23.values = {_op: _op
                               ,answers: answers
                               ,run: run
                               ,update: update
                               ,get: get
                               ,parseInput: parseInput
                               ,parseLine: parseLine
                               ,initModel: initModel
                               ,Model: Model
                               ,NoOp: NoOp
                               ,Inc: Inc
                               ,Hlf: Hlf
                               ,Tpl: Tpl
                               ,Jmp: Jmp
                               ,Jie: Jie
                               ,Jio: Jio};
};
Elm.Y15D24 = Elm.Y15D24 || {};
Elm.Y15D24.make = function (_elm) {
   "use strict";
   _elm.Y15D24 = _elm.Y15D24 || {};
   if (_elm.Y15D24.values) return _elm.Y15D24.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm),
   $Util = Elm.Util.make(_elm);
   var _op = {};
   var parseInput = function (input) {
      return A2($List.filter,
      function (w) {
         return !_U.eq(w,0);
      },
      A2($List.map,
      $Result.withDefault(0),
      A2($List.map,
      $String.toInt,
      A2($List.map,
      function (_) {
         return _.match;
      },
      A3($Regex.find,$Regex.All,$Regex.regex("\\d+"),input)))));
   };
   var searchCombo = F3(function (qe,weight,combos) {
      searchCombo: while (true) {
         var _p0 = combos;
         if (_p0.ctor === "[]") {
               return qe;
            } else {
               var _p1 = _p0._0;
               var qe$ = function () {
                  if (!_U.eq($List.sum(_p1),weight)) return qe; else {
                        var qe$$ = $List.product(_p1);
                        return _U.eq(qe,0) || _U.cmp(qe$$,qe) < 0 ? qe$$ : qe;
                     }
               }();
               var _v1 = qe$,_v2 = weight,_v3 = _p0._1;
               qe = _v1;
               weight = _v2;
               combos = _v3;
               continue searchCombo;
            }
      }
   });
   var searchLength = F5(function (qe,
   length,
   maxLen,
   weight,
   weights) {
      searchLength: while (true) if (_U.cmp(length,maxLen) > 0)
      return qe; else {
            var combos = A2($Util.combinations,length,weights);
            var qe$ = A3(searchCombo,qe,weight,combos);
            if (_U.cmp(qe$,0) > 0) return qe$; else {
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
   });
   var bestQe = F2(function (groups,weights) {
      var maxLen = $List.length(weights) - groups + 1;
      var weight = $List.sum(weights) / groups | 0;
      return A5(searchLength,0,1,maxLen,weight,weights);
   });
   var answers = function (input) {
      var weights = parseInput(input);
      var p1 = $Basics.toString(A2(bestQe,3,weights));
      var p2 = $Basics.toString(A2(bestQe,4,weights));
      return A2($Util.join,p1,p2);
   };
   return _elm.Y15D24.values = {_op: _op
                               ,answers: answers
                               ,bestQe: bestQe
                               ,searchLength: searchLength
                               ,searchCombo: searchCombo
                               ,parseInput: parseInput};
};
Elm.Y15D25 = Elm.Y15D25 || {};
Elm.Y15D25.make = function (_elm) {
   "use strict";
   _elm.Y15D25 = _elm.Y15D25 || {};
   if (_elm.Y15D25.values) return _elm.Y15D25.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Regex = Elm.Regex.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $String = Elm.String.make(_elm);
   var _op = {};
   var start = {code: 20151125,row: 1,col: 1};
   var Model = F3(function (a,b,c) {
      return {code: a,row: b,col: c};
   });
   var search = F2(function (_p0,model) {
      search: while (true) {
         var _p1 = _p0;
         var _p4 = _p1._0;
         var _p3 = _p1._1;
         if (_U.eq(_p4,model.row) && _U.eq(_p3,model.col)) return model;
         else {
               var code$ = A2($Basics._op["%"],
               model.code * 252533,
               33554393);
               var _p2 = _U.cmp(model.row,1) > 0 ? {ctor: "_Tuple2"
                                                   ,_0: model.row - 1
                                                   ,_1: model.col + 1} : {ctor: "_Tuple2",_0: model.col + 1,_1: 1};
               var row$ = _p2._0;
               var col$ = _p2._1;
               var _v1 = {ctor: "_Tuple2",_0: _p4,_1: _p3},
               _v2 = {code: code$,row: row$,col: col$};
               _p0 = _v1;
               model = _v2;
               continue search;
            }
      }
   });
   var parse = function (input) {
      var numbers = A2($List.map,
      $String.toInt,
      A2($List.map,
      $Maybe.withDefault("1"),
      A2($Maybe.withDefault,
      _U.list([$Maybe.Just("1"),$Maybe.Just("1")]),
      $List.head(A2($List.map,
      function (_) {
         return _.submatches;
      },
      A3($Regex.find,
      $Regex.AtMost(1),
      $Regex.regex("code at row (\\d+), column (\\d+)"),
      input))))));
      var _p5 = function () {
         var _p6 = numbers;
         if (_p6.ctor === "::" && _p6._0.ctor === "Ok" && _p6._1.ctor === "::" && _p6._1._0.ctor === "Ok" && _p6._1._1.ctor === "[]")
         {
               return {ctor: "_Tuple2",_0: _p6._0._0,_1: _p6._1._0._0};
            } else {
               return {ctor: "_Tuple2",_0: 1,_1: 1};
            }
      }();
      var row = _p5._0;
      var col = _p5._1;
      return {ctor: "_Tuple2",_0: row,_1: col};
   };
   var answer = function (input) {
      var target = parse(input);
      var model = A2(search,target,start);
      return $Basics.toString(model.code);
   };
   return _elm.Y15D25.values = {_op: _op
                               ,answer: answer
                               ,parse: parse
                               ,search: search
                               ,Model: Model
                               ,start: start};
};
Elm.Y15 = Elm.Y15 || {};
Elm.Y15.make = function (_elm) {
   "use strict";
   _elm.Y15 = _elm.Y15 || {};
   if (_elm.Y15.values) return _elm.Y15.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $Y15D01 = Elm.Y15D01.make(_elm),
   $Y15D02 = Elm.Y15D02.make(_elm),
   $Y15D03 = Elm.Y15D03.make(_elm),
   $Y15D04 = Elm.Y15D04.make(_elm),
   $Y15D05 = Elm.Y15D05.make(_elm),
   $Y15D06 = Elm.Y15D06.make(_elm),
   $Y15D07 = Elm.Y15D07.make(_elm),
   $Y15D08 = Elm.Y15D08.make(_elm),
   $Y15D09 = Elm.Y15D09.make(_elm),
   $Y15D10 = Elm.Y15D10.make(_elm),
   $Y15D11 = Elm.Y15D11.make(_elm),
   $Y15D12 = Elm.Y15D12.make(_elm),
   $Y15D13 = Elm.Y15D13.make(_elm),
   $Y15D14 = Elm.Y15D14.make(_elm),
   $Y15D15 = Elm.Y15D15.make(_elm),
   $Y15D16 = Elm.Y15D16.make(_elm),
   $Y15D17 = Elm.Y15D17.make(_elm),
   $Y15D18 = Elm.Y15D18.make(_elm),
   $Y15D19 = Elm.Y15D19.make(_elm),
   $Y15D20 = Elm.Y15D20.make(_elm),
   $Y15D21 = Elm.Y15D21.make(_elm),
   $Y15D22 = Elm.Y15D22.make(_elm),
   $Y15D23 = Elm.Y15D23.make(_elm),
   $Y15D24 = Elm.Y15D24.make(_elm),
   $Y15D25 = Elm.Y15D25.make(_elm);
   var _op = {};
   var answers = F2(function (day,input) {
      var _p0 = day;
      switch (_p0)
      {case 1: return $Y15D01.answers(input);
         case 2: return $Y15D02.answers(input);
         case 3: return $Y15D03.answers(input);
         case 4: return $Y15D04.answers(input);
         case 5: return $Y15D05.answers(input);
         case 6: return $Y15D06.answers(input);
         case 7: return $Y15D07.answers(input);
         case 8: return $Y15D08.answers(input);
         case 9: return $Y15D09.answers(input);
         case 10: return $Y15D10.answers(input);
         case 11: return $Y15D11.answers(input);
         case 12: return $Y15D12.answers(input);
         case 13: return $Y15D13.answers(input);
         case 14: return $Y15D14.answers(input);
         case 15: return $Y15D15.answers(input);
         case 16: return $Y15D16.answers(input);
         case 17: return $Y15D17.answers(input);
         case 18: return $Y15D18.answers(input);
         case 19: return $Y15D19.answers(input);
         case 20: return $Y15D20.answers(input);
         case 21: return $Y15D21.answers(input);
         case 22: return $Y15D22.answers(input);
         case 23: return $Y15D23.answers(input);
         case 24: return $Y15D24.answers(input);
         case 25: return $Y15D25.answer(input);
         default: return A2($Basics._op["++"],
           "year 2015, day ",
           A2($Basics._op["++"],
           $Basics.toString(day),
           ": not implemented yet"));}
   });
   return _elm.Y15.values = {_op: _op,answers: answers};
};
Elm.Main = Elm.Main || {};
Elm.Main.make = function (_elm) {
   "use strict";
   _elm.Main = _elm.Main || {};
   if (_elm.Main.values) return _elm.Main.values;
   var _U = Elm.Native.Utils.make(_elm),
   $Basics = Elm.Basics.make(_elm),
   $Debug = Elm.Debug.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm),
   $Result = Elm.Result.make(_elm),
   $Signal = Elm.Signal.make(_elm),
   $Y15 = Elm.Y15.make(_elm);
   var _op = {};
   var problem = Elm.Native.Port.make(_elm).inboundSignal("problem",
   "( Int, Int, String )",
   function (v) {
      return typeof v === "object" && v instanceof Array ? {ctor: "_Tuple3"
                                                           ,_0: typeof v[0] === "number" && isFinite(v[0]) && Math.floor(v[0]) === v[0] ? v[0] : _U.badPort("an integer",
                                                           v[0])
                                                           ,_1: typeof v[1] === "number" && isFinite(v[1]) && Math.floor(v[1]) === v[1] ? v[1] : _U.badPort("an integer",
                                                           v[1])
                                                           ,_2: typeof v[2] === "string" || typeof v[2] === "object" && v[2] instanceof String ? v[2] : _U.badPort("a string",
                                                           v[2])} : _U.badPort("an array",v);
   });
   var update = F2(function (action,model) {
      var _p0 = action;
      if (_p0.ctor === "NoOp") {
            return model;
         } else {
            var _p2 = _p0._0._0;
            var _p1 = _p2;
            if (_p1 === 2015) {
                  return A2($Y15.answers,_p0._0._1,_p0._0._2);
               } else {
                  return A2($Basics._op["++"],
                  "year ",
                  A2($Basics._op["++"],
                  $Basics.toString(_p2),
                  ": not available yet"));
               }
         }
   });
   var Problem = function (a) {
      return {ctor: "Problem",_0: a};
   };
   var actions = A2($Signal.map,Problem,problem);
   var NoOp = {ctor: "NoOp"};
   var init = "no problem";
   var model = A3($Signal.foldp,update,init,actions);
   var answer = Elm.Native.Port.make(_elm).outboundSignal("answer",
   function (v) {
      return v;
   },
   model);
   return _elm.Main.values = {_op: _op
                             ,init: init
                             ,NoOp: NoOp
                             ,Problem: Problem
                             ,update: update
                             ,model: model
                             ,actions: actions};
};
