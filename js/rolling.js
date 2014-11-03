(function() {
  var RollingGraph, _max,
    __modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

  _max = function(arr) {
    var el, i, top, _i, _len;
    top = -Infinity;
    for (i = _i = 0, _len = arr.length; _i < _len; i = ++_i) {
      el = arr[i];
      top = Math.max(top, el);
    }
    return top;
  };

  window.RollingGraph = RollingGraph = (function() {
    function RollingGraph(canvas, len, channels) {
      this.canvas = canvas;
      this.len = len;
      this.channels = channels != null ? channels : 2;
      this.ctx = this.canvas.getContext('2d');
      this.buffers = (function() {
        var _i, _ref, _results;
        _results = [];
        for (_i = 0, _ref = this.channels; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--) {
          _results.push(new Float64Array(this.len));
        }
        return _results;
      }).call(this);
      this.indices = (function() {
        var _i, _ref, _results;
        _results = [];
        for (_i = 0, _ref = this.channels; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--) {
          _results.push(0);
        }
        return _results;
      }).call(this);
      this.maximums = (function() {
        var _i, _ref, _results;
        _results = [];
        for (_i = 0, _ref = this.channels; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--) {
          _results.push(0);
        }
        return _results;
      }).call(this);
      this.colors = ['#00F', '#0FF', '#F0F', '#F00', '#FF0', '#0F0'];
      this.convexHullData = [];
      this.listening = true;
    }

    RollingGraph.prototype.index = function() {
      return _max(this.indices);
    };

    RollingGraph.prototype.convexHull = function(data) {
      var ci, cj, convexHull, i, j;
      if (data.length === 0) {
        return [];
      }
      convexHull = new Float64Array(data.length);
      i = 0;
      j = data.length - 1;
      ci = data[0];
      cj = data[j];
      while (!(i >= j)) {
        if (cj > ci) {
          while (!(data[i] > ci || i >= j)) {
            convexHull[i] = ci;
            i++;
          }
        } else {
          while (!(data[j] > cj || j <= i)) {
            convexHull[j] = cj;
            j--;
          }
        }
        ci = data[i];
        cj = data[j];
      }
      return convexHull;
    };

    RollingGraph.prototype.feed = function(data, channel) {
      var el, _i, _len, _ref;
      if (channel == null) {
        channel = 0;
      }
      this.buffers[channel][__modulo(this.indices[channel], this.len)] = data;
      this.maximums[channel] = Math.max(data, this.maximums[channel]);
      this.indices[channel]++;
      this.render();
      if (data > 0.01 && channel === 0) {
        this.listening = true;
        return this.convexHullData.push(data);
      } else if (channel === 0) {
        if (this.listening) {
          _ref = this.convexHull(this.convexHullData);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            el = _ref[_i];
            this.feed(el, 1);
          }
          this.convexHullData = [];
        }
        this.feed(0, 1);
        return this.listening = false;
      }
    };

    RollingGraph.prototype.render = function() {
      var buffer, channel, el, i, index, _i, _j, _len, _len1, _ref, _results;
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      index = this.index();
      _ref = this.buffers;
      _results = [];
      for (channel = _i = 0, _len = _ref.length; _i < _len; channel = ++_i) {
        buffer = _ref[channel];
        this.ctx.strokeStyle = this.colors[channel];
        this.ctx.beginPath();
        this.ctx.moveTo(0, this.canvas.height);
        for (i = _j = 0, _len1 = buffer.length; _j < _len1; i = ++_j) {
          el = buffer[i];
          if (!(i + index < this.indices[channel] + this.len)) {
            continue;
          }
          el = buffer[__modulo(i + index, this.len)];
          this.ctx.lineTo(this.canvas.width * i / this.len, this.canvas.height * (1 - el / this.maximums[channel]));
        }
        _results.push(this.ctx.stroke());
      }
      return _results;
    };

    return RollingGraph;

  })();

}).call(this);

//# sourceMappingURL=rolling.js.map
