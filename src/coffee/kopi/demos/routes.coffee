define "kopi/demos/routes", (require, exports, module) ->

  router = require "kopi/app/router"
  views = require "kopi/demos/views"
  ui = require "kopi/demos/views/ui"
  uibuttons = require "kopi/demos/views/uibuttons"
  uinotification = require "kopi/demos/views/uinotification"

  router
    .view(views.IndexView).route("/", name: "index").end()

    .view(ui.UIView).route("/ui/", name: "ui").end()
    .view(uibuttons.UIButtonView).route("/ui/buttons/", name: "ui-buttons").end()
    .view(uinotification.UINotificationView).route("/ui/notification/", name: "ui-notification").end()

  return
