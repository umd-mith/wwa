# # Routers
# This file defines all Backbone routers (hashchange management)

SGASharedCanvas.Router = SGASharedCanvas.Router or {}

( ->

  #
  # For now, the routers assume that there is only one Manifest
  #

  class Main extends Backbone.Router
    routes:
      "" : "page"
      "p:n(/search/f\::filter|q\::query)" : "page"

    page: (n, filter, query) ->
      n = 1 if !n? or n<1

      manifests = SGASharedCanvas.Data.Manifests

      if filter? and query?
        # Trigger an event "search" on the manifests collection to 
        # fetch search data
        manifests.trigger "search", filter, query

      # Trigger an event "page" on the manifests collection to 
      # fetch canvas data      
      manifests.trigger "page", n

  SGASharedCanvas.Router.Main = new Main

)()