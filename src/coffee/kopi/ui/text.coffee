kopi.module("kopi.ui.text")
  .require("kopi.ui.widgets")
  .define (exports, widgets) ->

    class Text extends widgets.Widget

      this.configure
        tagName: 'p'


    ###
    A text view support truncate multi-line text
    ###
    class EllipsisText extends Text

      # 文本垂直对齐的方式
      this.VALIGN_NONE   = 0  # 不对齐
      this.VALIGN_TOP    = 1  # 向上对齐
      this.VALIGN_BOTTOM = 2  # 向下对齐
      this.VALIGN_MIDDLE = 3  # 居中对齐

      this.configure
        ###
        单行高度
        ###
        lineHeight: 18
        ###
        最多显示的行数
        ###
        lines: 3
        ###
        @type {String}  对齐方式
        ###
        valign: this.ALIGN_NONE
        ###
        Truncate text 时最多尝试的次数
        ###
        maxTries: 30

      constructor: (element, options, text="") ->
        super(element, options)

        options = this._options
        this._text = text
        this._maxHeight = options.lineHeight * options.lines
        this._fullHeight = null

      onskeleton: (element) ->
        super

        self = this
        options = self._options
        self._maxHeight = options.lineHeight * options.lines
        css =
          overflow: 'hidden'
          lineHeight: options.lineHeight
          maxHeight: self._.maxHeight
        self.element.css(css)

      onrender: ->
        super

        self = this
        self._fill()
        self._truncate()

      onupdate: ->
        super
        this.render(arguments...)

      text: (text, render=false) ->
        this._text = text
        this.render() if render

      _fill: ->
        this.element.text(this.data.text)

      _truncate: ->
        cls = this.constructor
        self = this
        element = this.element
        min = 0
        max = self.text.length - 1
        # 用二分法加速计算过程
        for i in [0..self._options.maxTries]
          break if max < min
          middle = Math.floor((min + max) / 2)
          subtext = text.substr(0, middle)
          element.text(subtext + '...')
          height = element.height()
          # 确定行数
          if height > self._maxHeight
            max = middle
          else if height < self._maxHeight
            min = middle
          else
            # 确定具体列数
            subtext2 = text.substr(0, middle + 1)
            element.text(subtext2 + '...')
            if element.height() > self._maxHeight
              element.text(subtext + '...')
              break
            else
              break if min is middle
              min = middle

        # 填补 margin
        margin = self._maxHeight - element.height()
        if margin > 0
          marginBottom = element.marginBottom()
          switch self._options.valign
            when cls.VALIGN_TOP
              element.css("marginTop", margin + element.css("marginTop"))
            when cls.VALIGN_BOTTOM
              element.css("marginBottom", margin + element.css("marginBottom"))
            when cls.VALIGN_MIDDLE
              margin /= 2
              element.css
                marginTop: margin + element.css("marginTop")
                marginBottom: margin + element.css("marginBottom")
        self

      # Get height when display full text
      _height: (force=false) ->
        self = this
        element = self.element
        if force or not self._fullHeight
          text = element.text()
          element.text(self.text)
          self._fullHeight = element.height()
          element.text(text)
        self._fullHeight

    exports.Text = Text
    exports.EllipsisText = EllipsisText