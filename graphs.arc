; The goal here is to provide a library of data visualization macros.
; BYOData, the macros do the rest.

; So what are the macros doing?
; The macros expand into html wrapped in an iframe.
; 
;(mac linegraph ((data sample-data*) (width 300) (height 100) ())
;  `(iframe srcdoc (graphpage ,data ,width ,height)))

;(mac graphpage ((graphtype :line) data width height)
;  `(pr (graphcss :line))
;   (pr (graphscript :line)))

(= linegraph* "
<iframe srcdoc = \"
  <!DOCTYPE html>
  <meta charset='utf-8'>
  <style>
  body {
    font: 10px sand-serif;
  }

  .axis path,
  .axis line {
    fill: none;
    stroke: #000
    shape-rendering: crispedges;
  }

  .x.axis path {
    display: none;
  }

  .line {
    fill: none;
    stroke: steelblue;
    stroke-width: 1.5px;
  }
  </style>
  <body>
  <script src='http://d3js.org/d3.v3.js'></script>
  <script>
  var margin = {top: 20, right: 20, bottom: 30, left: 50},
      width = 300 - margin.left - margin.right,
      height = 100 - margin.top - margin.bottom;
   
  var x = d3.scale.linear()
      .range([0, width]);
   
  var y = d3.scale.linear()
      .range([height,0]);
   
  var xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom');
   
  var yAxis = d3.svg.axis()
      .scale(y)
      .orient('left');
   
  var line = d3.svg.line()
      .x(function(d) { return x(d.day); })
      .y(function(d) { return y(d.avg); });
   
  var svg = d3.select('body').append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
   
  d3.csv('https://dl.dropboxusercontent.com/u/641880/spending.csv', function(d) {
    return {
          day: +d.day,
          avg: +d.avg
      };
  }, function(error, rows) {
   
    console.log(rows);
   
    x.domain([0, 30]);
    y.domain([0.0, 300.0]);
   
    svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + height + ')')
        .call(xAxis);
   
    svg.append('g')
        .attr('class', 'y axis')
        .call(yAxis)
      .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', 6)
        .attr('Dy', '.71em')
        .style('text-anchor', 'end')
        .text('Avg spending ($)');
   
    svg.append('path')
        .datum(rows)
        .attr('class', 'line')
        .attr('d', line);
   
  });
  </script>
\"></iframe>
" )
; (mac barchart ((data "sample.csv") (width 300) (height 100)) ___)
; (mac smoothlinegraph
; (mac heatgrid
; (mac css __)
