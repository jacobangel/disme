App = Ember.Application.create();

App.Router.map(function() {
  // put your routes here
  this.route('resume', {
    path: '/resume'
  });

  this.route('contact', {
  	path: '/contact'
  });

  this.route('success', {
    path: '/contact/success'
  });
    
});

App.IndexRoute = Ember.Route.extend({

});

App.ResumeRoute = Ember.Route.extend({
  model : function () {
    return resume;
  }
});

App.Resume = Ember.Object.extend({});

var resume = App.Resume.create();

jQuery.getJSON('/resume.json', function(data) {
    resume.setProperties(data);
});

