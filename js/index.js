(function() {
  var AudioContext, canvas, canvas2, ctx, ctx2, lastSpectrum, rollingGraph, _absoluteDifference, _copy, _cosineSimilarity, _dot, _mag, _ref, _ref1, _ref2, _ref3;

  navigator.getUserMedia = (_ref = (_ref1 = (_ref2 = navigator.getUserMedia) != null ? _ref2 : navigator.webkitGetUserMedia) != null ? _ref1 : navigator.mozGetUserMedia) != null ? _ref : navigator.msGetUserMedia;

  AudioContext = (_ref3 = window.AudioContext) != null ? _ref3 : window.webkitAudioContext;

  canvas = document.querySelector('#rolling');

  canvas2 = document.querySelector('#fft');

  ctx = canvas.getContext('2d');

  ctx2 = canvas2.getContext('2d');

  _dot = function(a, b) {
    var el, i, p, _i, _len;
    p = 0;
    for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
      el = a[i];
      p += el * b[i];
    }
    return p;
  };

  _mag = function(a) {
    var el, mag, _i, _len;
    mag = 0;
    for (_i = 0, _len = a.length; _i < _len; _i++) {
      el = a[_i];
      mag += el * el;
    }
    return Math.sqrt(mag);
  };

  _cosineSimilarity = function(a, b) {
    return _dot(a, b) / (_mag(a) * _mag(b));
  };

  _absoluteDifference = function(a, b) {
    var el, i, sum, _i, _len;
    sum = 0;
    for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
      el = a[i];
      sum += Math.pow(el - b[i], 2);
    }
    return sum;
  };

  _copy = function(f32) {
    var i, k, n, _i, _len;
    n = new Float32Array(f32.length);
    for (i = _i = 0, _len = f32.length; _i < _len; i = ++_i) {
      k = f32[i];
      n[i] = k;
    }
    return n;
  };

  rollingGraph = new RollingGraph(canvas, 500, 4);

  lastSpectrum = null;

  navigator.getUserMedia({
    audio: true
  }, (function(stream) {
    var audioInput, context, fft, processor, voider;
    context = new AudioContext();
    processor = context.createScriptProcessor(1024, 1, 1);
    audioInput = context.createMediaStreamSource(stream);
    audioInput.connect(processor);
    voider = context.createGain();
    voider.gain.value = 0;
    processor.connect(voider);
    voider.connect(context.destination);
    fft = new FFT(1024, 44100);
    return processor.onaudioprocess = function(event) {
      var buffer, i, power, signal, similarity, _i, _j, _len, _len1, _ref4, _ref5;
      buffer = event.inputBuffer;
      fft.forward(buffer.getChannelData(0));
      power = 0;
      _ref4 = buffer.getChannelData(0);
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        signal = _ref4[_i];
        power += Math.pow(signal, 2);
      }
      ctx2.clearRect(0, 0, canvas2.width, canvas2.height);
      ctx2.beginPath();
      ctx2.moveTo(0, canvas2.height);
      _ref5 = fft.spectrum;
      for (i = _j = 0, _len1 = _ref5.length; _j < _len1; i = ++_j) {
        signal = _ref5[i];
        ctx2.lineTo(canvas2.width * (i / fft.spectrum.length), canvas2.height - signal * 10000);
      }
      ctx2.strokeStyle = '#F00';
      ctx2.stroke();
      if (lastSpectrum != null) {
        similarity = _cosineSimilarity(fft.spectrum, lastSpectrum);
        if (similarity === similarity) {
          rollingGraph.feed(similarity + 1, 2);
        }
        rollingGraph.feed(_absoluteDifference(fft.spectrum, lastSpectrum) / power, 3);
      }
      lastSpectrum = _copy(fft.spectrum);
      return rollingGraph.feed(power, 0);
    };
  }), (function() {}));

}).call(this);

//# sourceMappingURL=index.js.map
