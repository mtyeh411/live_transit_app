Handlebars.registerHelper('math', function(left_value, operator, right_value, options) {
  if(arguments.length < 4) {
    options = right_value;
    right_value = operator;
    operator = "+"; 
  }  

  left_value = parseFloat(left_value);
  right_value = parseFloat(right_value);

  return {
    "+": left_value + right_value,
    "-": left_value - right_value,
    "*": left_value * right_value,
    "/": left_value / right_value,
    "%": left_value % right_value
  }[operator];
});
