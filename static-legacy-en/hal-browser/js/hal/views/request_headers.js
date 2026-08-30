/* 
 *  This is the default license template.
 *  
 *  File: request_headers.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
HAL.Views.RequestHeaders = Backbone.View.extend({
  initialize: function(opts) {
    var self = this;
    this.vent = opts.vent;

    _.bindAll(this, 'updateRequestHeaders');

    this.vent.bind('app:loaded', function() {
      self.updateRequestHeaders();
    });
  },

  className: 'request-headers',

  events: {
    'blur textarea': 'updateRequestHeaders'
  },

  updateRequestHeaders: function(e) {
    var inputText = this.$('textarea').val() || '';
        headers = HAL.parseHeaders(inputText);
    HAL.client.updateHeaders(_.defaults(headers, HAL.client.defaultHeaders))
  },

  render: function() {
    this.$el.html(this.template());
  },

  template: _.template($('#request-headers-template').html())
});
