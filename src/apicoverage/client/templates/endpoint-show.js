var EDITING_KEY = 'editingList';
Session.setDefault(EDITING_KEY, false);

// Track if this is the first time the list template is rendered
var firstRender = true;
var listRenderHold = LaunchScreen.hold();
listFadeInHold = null;

Template.endpointShow.onRendered(function() {
  if (firstRender) {
    // Released in app-body.js
    listFadeInHold = LaunchScreen.hold();

    // Handle for launch screen defined in app-body.js
    listRenderHold.release();

    firstRender = false;
  }

  this.find('.js-title-nav')._uihooks = {
    insertElement: function(node, next) {
      $(node)
        .hide()
        .insertBefore(next)
        .fadeIn();
    },
    removeElement: function(node) {
      $(node).fadeOut(function() {
        this.remove();
      });
    }
  };
});

Template.endpointShow.helpers({
  rolesReady: function() {
    console.log('in roles ready', Router.current());
    console.log('in roles ready', Router.current().rolesHandle);
    console.log('in roles ready', Router.current().rolesHandle.ready());
    return Router.current().rolesHandle.ready();
  },

  roles: function(endpointId) {
    console.log('endpoint: ', endpointId);
    return Roles.find({endpointId: endpointId});
  }
});

Template.endpointShow.events({
  'click .js-todo-add': function(event, template) {
    template.$('.js-todo-new input').focus();
  },

  'submit .js-todo-new': function(event) {
    event.preventDefault();

    var $input = $(event.target).find('[type=text]');
    if (! $input.val())
      return;
    
    Todos.insert({
      listId: this._id,
      text: $input.val(),
      checked: false,
      createdAt: new Date()
    });
    Lists.update(this._id, {$inc: {incompleteCount: 1}});
    $input.val('');
  }
});
