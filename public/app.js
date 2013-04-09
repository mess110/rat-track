function getPoolImageUrl(canvas) {
  var id = canvas.data('movie-id');
  var url = "/videos/" + id + "/frame000001.png";
  return url;
}

var loadCanvasImage = function(src, data) {
  // for some reason it doesn't like $('#pool')
  var canvas = document.getElementById("pool");
  var context = canvas.getContext("2d");
  var img = new Image();
  img.src = src;

  $(img).load(function(){
    canvas.width = img.width;
    canvas.height = img.height
    context.drawImage(this, 0, 0);

    if (data != null) {
      var x = data.offsetX;
      var y = data.offsetY;
      var radius = data.radius;

      context.beginPath();
      context.arc(x, y, radius, 0, 2 * Math.PI, false);
      context.lineWidth = 1;
      context.strokeStyle = '#003300';
      context.stroke();
    }
  });
}

var drawImage = function(canvas, data) {
  var url = getPoolImageUrl(canvas);
  loadCanvasImage(url, data);
}

$(document).ready(function() {
  var canvas = $('#pool');
  var id = canvas.data('movie-id');
  if (canvas.data('frame-count') > 0) {
    $.get('/coordinates/' + id, function (data) {
      if (data != "") {
        json = JSON.parse(data);
        $('#centerX').val(json['centerX']);
        $('#centerY').val(json['centerY']);
        $('#radius').val(json['radius']);
      }

      var circ = {};
      circ.offsetX = parseInt($('#centerX').val());
      circ.offsetY = parseInt($('#centerY').val());
      circ.radius = parseInt($('#radius').val());
      drawImage(canvas, circ);
    });

    $('#analyze').on('click', function (data) {
      $.post('/analyze/' + id);
    });

    canvas.on('mousedown', function (data) {
      data.radius = $('#radius').val();
      $('#centerX').val(data.offsetX);
      $('#centerY').val(data.offsetY);
      drawImage(canvas, data);
    });
  }
});
