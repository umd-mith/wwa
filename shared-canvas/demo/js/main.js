(function ($) { 
  'use strict';

  function GetURLParameter(sParam)
  {
      var sPageURL = window.location.search.substring(1);
      var sURLVariables = sPageURL.split('&');
      for (var i = 0; i < sURLVariables.length; i++) 
      {
          var sParameterName = sURLVariables[i].split('=');
          if (sParameterName[0] == sParam) 
          {
              return sParameterName[1];
          }
      }
  }

  var manifest = GetURLParameter('mf');
  var manifestURL = "example-manifest.jsonld";

  if (manifest != undefined) {
    manifestURL = "manifests/"+manifest+"/Manifest.jsonld";
  }

  var sc = new SGASharedCanvas.Application({"manifest":manifestURL});

})(jQuery);