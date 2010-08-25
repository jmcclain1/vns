// Array Extensions  v1.0.6
// documentation: http://www.dithered.com/javascript/array/index.html
// license: http://creativecommons.org/licenses/by/1.0/
// code by Chris Nott (chris[at]dithered[dot]com)


var undefined;
function isUndefined(property) {
  return (typeof property == 'undefined');
}


// Array.concat() - Join two arrays
if (isUndefined(Array.prototype.concat) == true) {
  Array.prototype.concat = function (secondArray) {
  	var firstArray = this.copy();
  	for (var i = 0; i < secondArray.length; i++) {
  		firstArray[firstArray.length] = secondArray[i];
  	}
  	return firstArray;
  };
}

// Array.copy() - Copy an array
if (isUndefined(Array.prototype.copy) == true) {
  Array.prototype.copy = function() {
  	var copy = new Array();
  	for (var i = 0; i < this.length; i++) {
  		copy[i] = this[i];
  	}
  	return copy;
  };
}

// Array.pop() - Remove the last element of an array and return it
if (isUndefined(Array.prototype.pop) == true) {
  Array.prototype.pop = function() {
  	var lastItem = undefined;
    if ( this.length > 0 ) {
        lastItem = this[this.length - 1];
        this.length--;
    }
    return lastItem;
  };
}

// Array.push() - Add an element to the end of an array
if (isUndefined(Array.prototype.push) == true) {
  Array.prototype.push = function() {
  	var currentLength = this.length;
  	for (var i = 0; i < arguments.length; i++) {
  		this[currentLength + i] = arguments[i];
  	}
  	return this.length;
  };
}

// Array.shift() - Remove the first element of an array and return it
if (isUndefined(Array.prototype.shift) == true) {
  Array.prototype.shift = function() {
  	var firstItem = this[0];
  	for (var i = 0; i < this.length - 1; i++) {
  		this[i] = this[i + 1];
  	}
  	this.length--;
  	return firstItem;
  };
}

// Array.slice() - Copy several elements of an array and return them
if (isUndefined(Array.prototype.slice) == true) {
  Array.prototype.slice = function(start, end) {
  	var temp;
  	
  	if (end == null || end == '') end = this.length;
  	
  	// negative arguments measure from the end of the array
  	else if (end < 0) end = this.length + end;
  	if (start < 0) start = this.length + start;
  	
  	// swap limits if they are backwards
  	if (end < start) {
  		temp  = end;
  		end   = start;
  		start = temp;
  	}
  	
  	// copy elements from array to a new array and return the new array
  	var newArray = new Array();
  	for (var i = 0; i < end - start; i++) {
  		newArray[i] = this[start + i];
  	}
  	return newArray;
  };
}

// Array.splice() - Splice out and / or replace several elements of an array and return any deleted elements
if (isUndefined(Array.prototype.splice) == true) {
  Array.prototype.splice = function(start, deleteCount) {
  	if (deleteCount == null || deleteCount == '') deleteCount = this.length - start;
  	
  	// create a temporary copy of the array
  	var tempArray = this.copy();
  	
  	// Copy new elements into array (over-writing old entries)
  	for (var i = start; i < start + arguments.length - 2; i++) {
  		this[i] = arguments[i - start + 2];
  	}
  	
  	// Copy old entries after the end of the splice back into array and return
  	for (var i = start + arguments.length - 2; i < this.length - deleteCount + arguments.length - 2; i++) {
  		this[i] = tempArray[i + deleteCount - arguments.length + 2];
  	}
  	this.length = this.length - deleteCount + (arguments.length - 2);
  	return tempArray.slice(start, start + deleteCount);
  };
}

// Array.unshift - Add an element to the beginning of an array
if (isUndefined(Array.prototype.unshift) == true) {
  Array.prototype.unshift = function(the_item) {
  	for (loop = this.length-1 ; loop >= 0; loop--) {
  		this[loop+1] = this[loop];
  	}
  	this[0] = the_item;
  	return this.length;
  };
}