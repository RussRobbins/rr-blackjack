$(document).ready(function() {

	$(document).on('click', '#hit_form input', function() {
    $.ajax({
      type: 'POST',
      url:  '/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', '#stay_form input', function() {
    $.ajax({
      type: 'POST',
      url:  '/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', '#dealer_hit_form input', function() {
    $.ajax({
      type: 'POST',
      url:  '/dealer_hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

});
