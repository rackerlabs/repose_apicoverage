var ERRORS_KEY = 'reposeErrors';

Template.home.onCreated(function () {
  Session.set(ERRORS_KEY, {});
});

Template.home.helpers({
  errorMessages: function () {
    return _.values(Session.get(ERRORS_KEY));
  },
  errorClass: function (key) {
    return Session.get(ERRORS_KEY)[key] && 'error';
  }
});

Template.home.events({
  'submit': function (event, template) {
    //find a running repose 
    event.preventDefault();

    var reposeEndpoint = template.$('[name=endpoint]').val();
    var jolokiaEndpoint = template.$('[name=jolokia]').val();

    var errors = {};

    if (!reposeEndpoint) {
      errors.endpoint = 'Repose endpoint is required';
    }

    if (!jolokiaEndpoint) {
      errors.jolokia = 'Jolokia endpoint is required';
    }

    Session.set(ERRORS_KEY, errors);
    if (_.keys(errors).length) {
      return;
    }

    Meteor.call('checkStartupDataValidity',
      {
        'reposeEndpoint': reposeEndpoint,
        'jolokiaEndpoint': jolokiaEndpoint + '/jolokia/list'
      }, function (err, response) {
        console.log('test', err, response)
        if (err || !response) {
          return Session.set(ERRORS_KEY, { 'none': 'This repose instance is not up' });
        } else {
          console.log('add endpoints');
          Endpoints.insert({
            endpointId: reposeEndpoint,
            jolokia: jolokiaEndpoint
          });
          Router.go('home');

        }
      });

  }
});
