/* 
 *  This is the default license template.
 *  
 *  File: documentation.js
 *  Author: lmatas
 *  Copyright (c) 2022 lmatas
 *  
 *  To edit this license information: Press Ctrl+Shift+P and press 'Create new License Template...'.
 */
HAL.Views.Documenation = Backbone.View.extend({
  className: 'documentation',

  render: function(url) {
    this.$el.html('<iframe src="' + url + '"></iframe>');
  }
});
