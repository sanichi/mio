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
