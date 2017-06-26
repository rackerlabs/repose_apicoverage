Router.configure({
  // we use the  appBody template to define the layout for the entire app
  layoutTemplate: 'appBody',

  // the appNotFound template is used for unknown routes and missing lists
  notFoundTemplate: 'appNotFound',

  // show the appLoading template whilst the subscriptions below load their data
  loadingTemplate: 'appLoading',

  // wait on the following subscriptions before rendering the page to ensure
  // the data it's expecting is present
  waitOn: function () {
    return [
      Meteor.subscribe('publicLists'),
      Meteor.subscribe('privateLists')
    ];
  }
});

dataReadyHold = null;

if (Meteor.isClient) {
  // Keep showing the launch screen on mobile devices until we have loaded
  // the app's data
  dataReadyHold = LaunchScreen.hold();

  // Show the loading screen on desktop
  Router.onBeforeAction('loading', { except: ['join', 'signin'] });
  Router.onBeforeAction('dataNotFound', { except: ['join', 'signin'] });
}

if (Meteor.isServer) {
  Meteor.methods({
    checkStartupDataValidity: function (data) {
      console.log('on server, check if repose is up for ', data);
      this.unblock();
      return (
        validateJolokiaEndpoint(data.jolokiaEndpoint) &&
        validateReposeEndpoint(data.reposeEndpoint)
        )
    },

    getValidators: function (endpoint) {
      console.log('on server, get validators for: ', endpoint);
      try {
        var response = Meteor.http.call("GET", endpoint);
        console.log(response)
        return response;
      } catch (e) {
        throw new Meteor.Error(404, "No validators have been found");
      }
    }
  });
}

function validateReposeEndpoint(endpoint) {
  try {
    return Meteor.http.call("GET", endpoint);
  } catch (e) {
    if (e.response.statusCode < 500) {
      return true;
    }
    return false;
  }

}

function validateJolokiaEndpoint(endpoint) {
  try {
    return Meteor.http.call("GET", endpoint);
  } catch (e) {
    console.log(e);
    return false;
  }
}

Router.map(function () {
  this.route('join');
  this.route('signin');

  this.route('listsShow', {
    path: '/lists/:_id',
    // subscribe to todos before the page is rendered but don't wait on the
    // subscription, we'll just render the items as they arrive
    onBeforeAction: function () {
      this.todosHandle = Meteor.subscribe('todos', this.params._id);

      if (this.ready()) {
        // Handle for launch screen defined in app-body.js
        dataReadyHold.release();
      }
    },
    data: function () {
      return Lists.findOne(this.params._id);
    },
    action: function () {
      this.render();
    }
  });

  this.route('endpointShow', {
    path: '/endpoints/:_id',
    onBeforeAction: function () {
      var parameter = this.params._id;
      console.log('test2',Endpoints.find().fetch());
      console.log('make a get validators call', Endpoints.findOne({_id: this.params._id}));
      Meteor.call('getValidators', Endpoints.findOne({_id: parameter}).jolokia + '/jolokia/search/%22com.rackspace.com.papi.components.checker%22:type=%22Validator%22,scope=*,name=%22checker%22', function (err, response) {
        console.log('response: ', err, response);
        if (err) {
          return Session.set(ERRORS_KEY, { 'none': 'No validators found.  Check that Repose is started and you put at least 1 request through.' });
        } else {
          var validators = JSON.parse(response.content).value;
          for (var i = 0, max = validators.length; i < max; i++) {
            console.log(validators[i].match(/.*scope=\"([a-zA-Z0-9_]+)\".*/))
            Roles.insert({
              endpointId: parameter,
              name: validators[i],
              role: validators[i].match(/.*scope=\"([a-zA-Z0-9_]+)\".*/)[1]
            });
          }
        }
        console.log('test4')
      });
      console.log('test1',Endpoints.find().fetch());
      this.rolesHandle = Meteor.subscribe('roles', this.params._id);
      if (this.ready()) {
        dataReadyHold.release();
      }
    },
    data: function () {
      //get the available validators
      //http://localhost:8778/jolokia/read/%22com.rackspace.com.papi.components.checker%22:type=%22Validator%22,scope=*,name=%22checker%22
      //for each validator, get the available 
      return Roles.find({ endpointId: this.params._id })
    },
    action: function () {
      this.render();
    }
  })

  this.route('home', {
    path: '/',
    action: function () {
      if (Endpoints.findOne()) {
        console.log(Endpoints.find().fetch());
        Router.go('endpointShow', Endpoints.findOne());
      } else {
        this.render();
      }
      
      //here get the api coverage ui and button for listening to repose feed
      
      //Router.go('listsShow', Lists.findOne());
    }
  });
});
