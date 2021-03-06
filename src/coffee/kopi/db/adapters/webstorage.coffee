define "kopi/db/adapters/webstorage", (require, exports, module) ->

  logging = require "kopi/logging"
  klass = require "kopi/utils/support"
  support = require "kopi/utils/support"
  kv = require "kopi/db/adapters/kv"
  models = require "kopi/db/models"

  logger = logging.logger(module.id)
  storage = localStorage

  class StorageAdapater extends kv.KeyValueAdapter

    this.support = -> !!support.storage

    _get: (key, defautValue, fn) ->
      value = storage.getItem(key)
      value = if value? then value else defautValue
      fn(null, value) if fn
      value

    _set: (key, value, fn) ->
      try
        storage.setItem(key, value)
        fn(null) if fn
      catch e
        # TODO Any better handler for quota exceeded error
        if e == QUOTA_EXCEEDED_ERR
          logger.error(e)
          fn(e) if fn
        else
          throw e
      value

    _remove: (key, fn) ->
      value = storage.removeItem(key)
      fn(null, value) if fn
      value

    _adapterValue: (value, field) ->
      self = this
      switch field.type
        when models.DATETIME
          return value.getTime()
        when models.JSON
          return self._adapterObject(value)
        else
          super

    _modelValue: (value, field) ->
      self = this
      switch field.type
        when models.DATETIME
          new Date(value)
        when models.JSON
          self._modelObject(value)
        else
          super

    ###
    Save as string in local storage
    ###
    _adapterObject: (obj, fields) ->
      JSON.stringify(super(obj, fields))

    _modelObject: (string, fields) ->
      super(JSON.parse(string), fields)

  StorageAdapater: StorageAdapater
