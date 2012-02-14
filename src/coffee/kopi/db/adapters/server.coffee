kopi.module("kopi.db.adapters.server")
  .require("kopi.db.adapters.base")
  .require("kopi.exceptions")
  .define (exports, base, exceptions) ->

    class ServerAdapter extends base.BaseAdapter

      kls = this
      kls.configure
        # createURL: "/api/users/create/"
        # retrieveURL: "/api/users/retrieve/"
        # updateURL: "/api/users/update/"
        # destroyURL: "/api/users/destroy/"

        createMethod: "POST"
        retrieveMethod: "GET"
        updateMethod: "PUT"
        destroyMethod: "DELETE"

        onlyParam: "only"
        whereParam: "where"
        sortParam: "sort"
        skipParam: "skip"
        limitParam: "limit"
        attrsParam: "attrs"
        countParam: "count"

        format: "JSON"
        # 30 seconds
        timeout: 30000

      requestFn = -> this._request(arguments...)
      proto = kls.prototype
      proto[action] = requestFn for action in kls.ACTIONS

      # Build URL for query
      _url: (query, url) ->
        url or= this._options["#{query.action()}URL"]
        for name, value of query.criteria().where
          url = url.replace(":#{name}", value.eq) if value.eq
        url

      _method: (query) ->
        method = this._options["#{query.action()}Method"]
        method

      # Build request params
      # {
      #   where: "{sid: 1}"
      #   sort: "{createdAt: true}"
      # }
      _params: (query) ->
        query.params()

      # Send request to server
      _request: (query, fn) ->
        self = this
        options = self._options
        method = self._method(query)
        url = self._url(query)
        params = self._params(query)
        doneFn = (response) ->
          message = self._parse(response)
          fn(null, message)
        failFn = (xhr, text, error) ->
          error = self._parseError(xhr, text, error)
          fn(error)
        # TODO Use some wrapper of $.ajax to queue delayed requests or retry failed requests
        $.ajax
          url: url
          type: method
          data: params
          dataType: options.format
          timeout: options.timeout
          success: doneFn
          error: failFn

      _parse: (response) ->
        this["_parse#{this._options.format}"](response)

      _parseError: (response) ->
        this["_parseError#{this._options.format}"](response)

      _parseJSON: (json) ->
        # TODO Verify if response JSON is formatted correctly
        json

      _parseErrorJSON: (xhr, text, error) ->
        {error: error or true, message: text}

    exports.ServerAdapter = ServerAdapter
