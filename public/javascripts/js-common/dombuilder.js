DomBuilder = Class.create();
DomBuilder.document = document;
DomBuilder.createElement = function(tagName, attributes) {
  var element = DomBuilder.document.createElement(tagName);

  var attHash = $H(attributes);
  attHash.each(function(args) {
    var key = args[0].toString();
    var value = args[1].toString();
    try {
      if(key=="class") {
        element.className = value;
      }
      else if(key=="style") {
        var styles = value.split(";");
        styles.each(function(styleString) {
          var strippedStyleString = styleString.strip();
          if(strippedStyleString.length == 0) return;

          var keyValue = strippedStyleString.split(':', 2);
          var styleKey = keyValue[0].strip();
          var styleValue= keyValue[1].strip();
          if (styleKey.length > 0 && styleValue.length > 0) {
            if(styleKey.toLowerCase() == "float") {
              element.style["cssFloat"] = element.style["styleFloat"] = styleValue;
            }
            else {
              element.style[styleKey] = styleValue;
            }
          }
        });
      }
      else {
        element.setAttribute(key, value);
      }
    }
    catch(e) {
      throw("Error while trying to create an element with the attribute " + key + " and value " + value + ": " + e);
    }
  });

  return element;
}
DomBuilder.createTextNode = function(text) {
  return DomBuilder.document.createTextNode(text);
}

DomBuilder.prototype = {
  initialize: function(params) {
    var objectParams = {
      parent: null,
      binding: this
    };

    objectParams = Object.extend(objectParams, params);
    this.parent = objectParams.parent;

    this.binding = objectParams.binding;

    if(this.parent != null) this._currentElement = this.parent;
    this._elements = [this.parent];

    this.createElement = DomBuilder.createElement;
    this.createTextNode = DomBuilder.createTextNode;
  },

  tag: function(tagName) {
    var arity = arguments.length;
    var element = null;

    if(arity == 1) {
      element = this._tagWithOneArgument(tagName);
    }
    else if(arity == 2) {
      element = this._tagWithTwoArguments(tagName, arguments[1]);
    }
    else if(arity == 3) {
      element = this._tagWithThreeArguments(tagName, arguments[1], arguments[2]);
    }
    else {
      throw "Invalid number of arguments";
    }
    return element;
  },

  _tagWithOneArgument: function(tagName) {
    var element = this.createElement(tagName);
    this._appendChild(element);
    return element;
  },


  _tagWithTwoArguments: function(tagName, secondArgument) {
    var element = null;
    if(typeof secondArgument == 'function') {
      element = this._renderAttributesAndFunction(tagName, null, secondArgument);
    }
    else if(typeof secondArgument == 'string') {
      element = this._renderAttributesAndText(tagName, null, secondArgument);
    }
    else {
      element = this.createElement(tagName, secondArgument);
      this._appendChild(element);
    }
    return element;
  },

  _tagWithThreeArguments: function(tagName, attributes, thirdArgument) {
    var element = null;
    if(typeof thirdArgument == 'function') {
      element = this._renderAttributesAndFunction(tagName, attributes, thirdArgument);
    }
    else {
      element = this._renderAttributesAndText(tagName, attributes, thirdArgument);
    }

    return element;
  },

  _renderAttributesAndFunction: function(tagName, attributes, theFunction) {
    var element = this.createElement(tagName, attributes);
    this._pushElement(element);
    theFunction.call(this.binding, this);

    this._popElement();
    return element;
  },

  _renderAttributesAndText: function(tagName, attributes, text) {
    var element = this.createElement(tagName, attributes);
    this._pushElement(element);
    this.appendText((text) ? text.toString() : "");
    this._popElement();
    return element;
  },

  _appendTextToElement: function(element, text) {
    var node = this.createTextNode(text);
    element.appendChild(node);
  },

  appendText: function(text) {
    this._appendTextToElement(this._currentElement, text);
  },

  appendXml: function(xml) {
    this._currentElement.innerHTML += xml;
  },

  _pushElement: function(element) {
    this._appendChild(element);

    this._elements.push(element);
    this._currentElement = element;
  },

  _appendChild: function(element) {
    if(this._currentElement != null) {
      try {
        this._currentElement.appendChild(element);
      }
      catch(e) {
        throw "Current element does not support appendChild";
      }
    }
  },

  _popElement: function(element) {
    element = this._elements.pop();
    var length = this._elements.length;
    if(length == 0) {
      this._currentElement = null;
    }
    else {
      this._currentElement = this._elements[this._elements.length - 1];
    }
    return element;
  },

  _tagWithArrayArgs: function(tag, args) {
    if(args == null) return this.tag(tag);

    var newArguments = [tag];
    for(var i=0; i < args.length; i++) {
      var arg = args[i];
      newArguments.push(arg);
    }
    return this.tag.apply(this, newArguments);
  },

  end: null
}

DomBuilder._supportedTags = [
  'a',
  'acronym',
  'address',
  'area',
  'b',
  'base',
  'bdo',
  'big',
  'blockquote',
  'body',
  'br',
  'button',
  'caption',
  'cite',
  'code',
  'dd',
  'del',
  'div',
  'dl',
  'dt',
  'em',
  'fieldset',
  'form',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'head',
  'hr',
  'html',
  'i',
  'img',
  'iframe',
  'input',
  'ins',
  'kbd',
  'label',
  'legend',
  'li',
  'link',
  'map',
  'meta',
  'noframes',
  'noscript',
  'ol',
  'optgroup',
  'option',
  'p',
  'param',
  'pre',
  'samp',
  'script',
  'select',
  'small',
  'span',
  'strong',
  'style',
  'sub',
  'sup',
  'table',
  'tbody',
  'td',
  'textarea',
  'th',
  'thead',
  'title',
  'tr',
  'tt',
  'ul',
  'var'
]

DomBuilder.registerTag = function(tagName) {
  DomBuilder.prototype[tagName] = function() {
    return this._tagWithArrayArgs(tagName, arguments);
  };
}

for(var i=0; i < DomBuilder._supportedTags.length; i++) {
  var tag = DomBuilder._supportedTags[i];
  DomBuilder.registerTag(tag);
}

if(Object.extend == null) {
  Object.extend = function(destination, source) {
    for (var property in source) {
      destination[property] = source[property];
    }
    return destination;
  }
}