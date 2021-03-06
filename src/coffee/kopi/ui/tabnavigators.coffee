define "kopi/ui/tabnavigators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  Widget = require("kopi/ui/widgets").Widget
  tabs = require("kopi/ui/tabs")
  Animator = require("kopi/ui/animators").Animator

  class TabPanel extends Widget

    this.widgetName "TabPanel"

    klass.accessor this.prototype, "key"

    constructor: (options) ->
      super(options)
      this._key or= this.guid

  class TabPanelAnimator extends Animator

    this.widgetName "TabPanelAnimator"

    this.configure
      childClass: TabPanel

  ###
  A navigation tabview with a tabbar and a flipper for content
  ###
  class TabNavigator extends Widget

    kls = this
    kls.TAB_BAR_POS_TOP = "top"
    kls.TAB_BAR_POS_RIGHT = "right"
    kls.TAB_BAR_POS_BOTTOM = "bottom"
    kls.TAB_BAR_POS_LEFT = "left"

    kls.widgetName "TabNavigator"

    kls.configure
      tabBarPos: kls.TAB_BAR_POS_TOP
      tabBarClass: tabs.TabBar
      tabPanelClass: TabPanelAnimator

    constructor: ->
      super
      self = this
      cls = this.constructor
      options = this._options
      if options.tabBarPos
        options.extraClass += " #{cls.cssClass(options.tabBarPos)}"
      if options.tabBarPos == cls.TAB_BAR_POS_TOP or options.tabBarPos == cls.TAB_BAR_POS_LEFT
        this
          .register("tabBar", options.tabBarClass)
          .register("tabPanel", options.tabPanelClass)
      else
        this
          .register("tabPanel", options.tabPanelClass)
          .register("tabBar", options.tabBarClass)
      this._tabBar.on tabs.TabBar.SELECT_EVENT, (e, tab) ->
        self._tabPanel.show(tab)


    addTab: (tab, options) ->
      this._tabBar.add(tab, options)
      this

    addPanel: (panel, options) ->
      this._tabPanel.add(panel, options)
      this

  TabPanel: TabPanel
  TabPanelAnimator: TabPanelAnimator
  TabNavigator: TabNavigator
