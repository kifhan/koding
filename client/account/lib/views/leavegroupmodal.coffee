kd              = require 'kd'
nick            = require 'app/util/nick'
kookies         = require 'kookies'
DeleteModalView = require '../deletemodalview'
Tracker         = require 'app/util/tracker'


module.exports = class LeaveGroupModal extends DeleteModalView


  constructor: (options = {}, data) ->

    data = nick()

    options.title       = 'Please confirm'
    options.buttonTitle = 'Leave Team'
    options.content     = """
      <div class='modalformline'>
        <p>
          <strong>CAUTION! </strong>You are going to leave your team and you will not be able to login again. This action <strong>CANNOT</strong> be undone.
        </p>
        <br>
        <p>Please enter <strong>#{data}</strong> into the field below to continue: </p>
      </div>
    """

    super options, data


  doAction: ->

    kd.singletons.groupsController.getCurrentGroup().leave (err) =>
      if err
        new kd.NotificationView { title : 'You need to transfer ownership of team before leaving team' }
        return @modalTabs.forms.dangerForm.buttons.confirmButton.hideLoader()

      Tracker.track Tracker.USER_LEFT_TEAM
      kookies.expire 'clientId'
      global.location.replace '/'
