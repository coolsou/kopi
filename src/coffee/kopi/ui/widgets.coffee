kopi.module("kopi.ui.widgets")
  .require("kopi.utils")
  .require("kopi.utils.klass")
  .require("kopi.utils.text")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .define (exports, utils, klass, text, events, exceptions, settings) ->

    ###
    UI 组件的基类
    ###
    class Widget extends events.EventEmitter

      # {{{ Class configuration
      klass.configure this
        # @type {String}    tag name of element to create
        tagName: "div"
      # }}}

      # {{{ Class methods
      ###
      A helper method to generate CSS class names added to widget element
      ###
      this.cssClass = (action, prefix="") ->
        this._cssClasses or= {}
        cache = "#{action},#{prefix}"
        return this._cssClasses[cache] if cache of this._cssClasses

        this.prefix or= text.underscore(this.name)
        name = this.prefix
        name = prefix + "-" + name if prefix
        name = settings.kopi.ui.prefix + "-" + name if settings.kopi.ui.prefix
        name = name + "-" + action if action
        this._cssClasses[cache] = name

      ###
      A helper method to generate CSS class names regexps for states
      ###
      this.stateRegExp = (prefix="") ->
        this._stateRegExps or= {}
        return this._stateRegExps[prefix] if prefix of this._stateRegExps

        regExp = new RegExp(this.cssClass("[^\s]+\s*", prefix), 'g')
        this._stateRegExps[prefix] = regExp
      # }}}

      # {{{ Lifecycle methods
      constructor: (element, options={}) ->
        if arguments.length < 2
          [element, options] = [null, element]

        self = this
        # @type {String}
        self.constructor.prefix or= text.underscore(self.constructor.name)
        # @type {String}
        self.guid = utils.guid(self.constructor.prefix)
        # @type {jQuery Element}
        self.element = element if element

        # {{{ State properties
        # If skeleton has been built
        self.initialized = false
        # If widget is rendered with data
        self.rendered = false
        # If widget is disabled
        self.locked = false
        # }}}

        # Copy class configurations to instance
        self._options = utils.extend {}, self.constructor._options, options

      ###
      Ensure basic skeleton of widget usually with a loader
      ###
      skeleton: (element) ->
        self = this
        return self if self.state.initialized or self.state.locked
        self.element = self._ensureElement(element or self.element)
        self.element.attr('id', self.guid)
        cssClass = self.constructor.cssClass()
        if not self.element.hasClass(cssClass)
          self.element.addClass(cssClass)
        self._updateOptions()
        self.emit("skeleton")

      ###
      Render widget when data is ready
      ###
      render: () ->
        self = this
        return self if self.state.rendered or self.state.locked
        self.emit("render")

      update: () ->
        self = this
        return self if self.state.locked
        self.emit("update")

      ###
      Disable events
      ###
      lock: ->
        self = this
        return self if self.state.locked
        # TODO 从 Event 层禁止，考虑如果子类也在 element 上绑定时间的情况
        self.state.locked = true
        self.element.addClass(self.constructor.cssClass("lock"))
        self.emit('lock')

      ###
      Enable events
      ###
      unlock: ->
        self = this
        return self unless self.state.locked
        self.state.locked = false
        self.element.removeClass(self.constructor.cssClass("lock"))
        self.emit('unlock')

      ###
      Unregister event listeners, remove elements and so on
      ###
      destroy: ->
        self = this
        return self if self.state.locked
        self.element.remove()
        self.off()
        self.emit('destroy')
      # }}}

      # {{{ Helper methods
      ###
      Human readable widget name
      ###
      toString: ->
        "[#{this.constructor.name} #{this.guid}]"

      ###
      Add or update state class and data attribute to element
      ###
      state: (name, value) ->
        if value == null
          this.element.attr("data-#{name}")
        else
          this.element
            .attr("data-#{name}", value)
            .replaceClass(this.constructor.stateRegExp(name),
              this.constructor.cssClass(value, name))

      ###
      Remove state class and data attribute from element
      ###
      removeState: (name) ->
        this.element
          .removeAttr("data-#{name}")
          .replaceClass(this.constructor.stateRegExp(name), "")
      # }}}

      # {{{ Private methods
      ###
      Get or create element
      ###
      _ensureElement: (element) ->
        self = this
        return $(element) if element
        if self._options.element
          return $(self._options.element)
        if self._options.template
          return $(self._options.template).tmpl(self)
        $(document.createElement(self.options.tagName))

      ###
      Update options from data attributes of element
      ###
      _updateOptions: ->
        return this unless this.element.length > 0
        for name, value of this._options
          value = this.element.data(text.underscore(name))
          this._options[name] = value if value isnt undefined
        this
      # }}}

    exports.Widget = Widget
