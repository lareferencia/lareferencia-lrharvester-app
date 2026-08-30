/* 
 *  This is the default license template.
 *  
 *  File: explorer.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
HAL.Views.Explorer = Backbone.View.extend({
  initialize: function(opts) {
    var self = this;
    this.vent = opts.vent;
    this.navigationView = new HAL.Views.Navigation({ vent: this.vent });
    this.resourceView = new HAL.Views.Resource({ vent: this.vent });
  },

  className: 'explorer span6',

  render: function() {
    this.navigationView.render();

    this.$el.html(this.template());

    this.$el.append(this.navigationView.el);
    this.$el.append(this.resourceView.el);
  },

  template: function() {
    return '<h1>Explorer</h1>';
  }
});
