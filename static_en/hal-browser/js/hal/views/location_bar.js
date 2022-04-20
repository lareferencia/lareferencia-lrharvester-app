/* 
 *  This is the default license template.
 *  
 *  File: location_bar.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
HAL.Views.LocationBar = Backbone.View.extend({
  initialize: function(opts) {
    this.vent = opts.vent;
    _.bindAll(this, 'render');
    _.bindAll(this, 'onButtonClick');
    this.vent.bind('location-change', this.render);
    this.vent.bind('location-change', _.bind(this.showSpinner, this));
    this.vent.bind('response', _.bind(this.hideSpinner, this));
  },

  events: {
    'submit form': 'onButtonClick'
  },

  className: 'address',

  render: function(e) {
    e = e || { url: '' };
    this.$el.html(this.template(e));
  },

  onButtonClick: function(e) {
    e.preventDefault();
    this.vent.trigger('location-go', this.getLocation());
  },

  getLocation: function() {
    return this.$el.find('input').val();
  },

  showSpinner: function() {
    this.$el.find('.ajax-loader').addClass('visible');
  },

  hideSpinner: function() {
    this.$el.find('.ajax-loader').removeClass('visible');
  },

  template: _.template($('#location-bar-template').html())
});
