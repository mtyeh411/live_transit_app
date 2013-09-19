Handlebars.registerHelper('display_time', function(timestamp) {
  return moment.unix(timestamp).format('h:mm A');
});
