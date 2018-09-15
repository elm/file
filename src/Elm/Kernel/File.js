/*

import Elm.Kernel.Json exposing (decodePrim, expecting)
import Elm.Kernel.List exposing (Cons, Nil)
import Elm.Kernel.Scheduler exposing (binding, succeed)
import Elm.Kernel.Utils exposing (Tuple0, Tuple2)
import Result exposing (Ok)
import String exposing (join)
import Time exposing (millisToPosix)

*/


// DECODER

var _File_decoder = __Json_decodePrim(function(value) {
	return (value instanceof File)
		? __Result_Ok(_File_toFile(value))
		: __Json_expecting('a FILE', value);
});


// METADATA

function _File_getName(file) { return file.name; }
function _File_getMime(file) { return file.type; }
function _File_getSize(file) { return file.size; }

function _File_getLastModified(file)
{
	return __Time_millisToPosix(file.lastModified);
}


// DOWNLOAD

var _File_downloadNode;

function _File_getDownloadNode()
{
	return _File_downloadNode || (_File_downloadNode = document.createElementNS('http://www.w3.org/1999/xhtml', 'a'));
}

var _File_download = F3(function(mime, name, content)
{
	return __Scheduler_binding(function(callback)
	{
		var blob = new Blob([content], {type: mime});

		// for IE10+
		if (navigator.msSaveOrOpenBlob)
		{
			navigator.msSaveOrOpenBlob(blob, name);
			return;
		}

		// for HTML5
		var node = _File_getDownloadNode();
		var objectUrl = URL.createObjectURL(blob);
		node.setAttribute('href', objectUrl);
		node.setAttribute('download', settings.__$name);
		node.dispatchEvent(new MouseEvent('click'));
		URL.revokeObjectURL(objectUrl);
	});
});

function _File_downloadUrl(href)
{
	return __Scheduler_binding(function(callback)
	{
		var node = _File_getDownloadNode();
		node.setAttribute('href', href);
		node.setAttribute('download', '');
		node.dispatchEvent(new MouseEvent('click'));
	});
}


// UPLOAD

function _File_uploadOne(mimes)
{
	return __Scheduler_binding(function(callback)
	{
		var node = document.createElementNS('http://www.w3.org/1999/xhtml', 'input');
		node.setAttribute('type', 'file');
		node.setAttribute('accept', A2(__String_join, ',', mimes));
		node.addEventListener('change', function(event)
		{
			callback(__Scheduler_succeed(event.target.files[0]));
		});
		node.dispatchEvent(new MouseEvent('click'));
	});
}

function _File_uploadOneOrMore(mimes)
{
	return __Scheduler_binding(function(callback)
	{
		var node = document.createElementNS('http://www.w3.org/1999/xhtml', 'input');
		node.setAttribute('type', 'file');
		node.setAttribute('accept', A2(__String_join, ',', mimes));
		node.setAttribute('multiple', '');
		node.addEventListener('change', function(event)
		{
			var elmFiles = __List_Nil;
			var jsFiles = event.target.files;
			for (var i = jsFiles.length; i--; )
			{
				elmFiles = __List_Cons(_File_toFile(jsFiles[i]), elmFiles);
			}
			callback(__Scheduler_succeed(__Utils_Tuple2(elmFiles.a, elmFiles.b)));
		});
		node.dispatchEvent(new MouseEvent('click'));
	});
}


// CONTENT

function _File_toString(blob)
{
	return __Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
		   callback(__Scheduler_succeed(reader.result));
		});
		reader.readAsText(blob);
	});
}

function _File_toBytes(blob)
{
	return __Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
		   callback(__Scheduler_succeed(new DataView(reader.result)));
		});
		reader.readAsArrayBuffer(blob);
	});
}

function _File_toUrl(blob)
{
	return __Scheduler_binding(function(callback)
	{
		var reader = new FileReader();
		reader.addEventListener('loadend', function() {
		   callback(__Scheduler_succeed(reader.result));
		});
		reader.readAsDataURL(blob);
	});
}

