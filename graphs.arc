; The goal here is to provide a library of data visualization macros.
; BYOData, the macros do the rest.

; So what are the macros doing?
; The macros expand into html wrapped in an iframe.
; 

;(mac graph ((graphtype :line) (width 300) (height 100) (data sample-data*)))
(mac graph (width height data)
  `(let v (tostring (graphpage ,width ,height ,data))
    (tag (div class "graph1") (pr v))))
    ;(tag (iframe srcdoc v))))

(mac graphpage (width height data)
  `(string
    (doctype "html")
    (charset "utf-8")
    (tag style
      (pr graphcss*))
    (tag body
      (include-d3)
      (tag script 
        (pr (graphscript ,width ,height ,data))))))

; build-out to be more controlled -- take variables for specific types
(mac doctype (x)
  `(gentag (!DOCTYPE " " ,x)))

(mac charset (x)
  `(tag (meta charset ,x)))

(mac include-d3 ()
  `(tag (script src "http://d3js.org/d3.v3.js")))

(= graphcss* 
  "
  body {
    font: 10px sans-serif;
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
  ")

(mac graphscript (width height data)
  `(string "
          var margin = {top: 20, right: 20, bottom: 30, left: 50},
              width = " ,width " - margin.left - margin.right,
              height = " ,height " - margin.top - margin.bottom;

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

          d3.csv('" ,data "', function(d) {
            return {
                  day: +d.day,
                  avg: +d.avg
              };
          }, function(error, rows) {
           
            console.log(rows);
           
            x.domain(d3.extent(rows, function(d) { return d.day; }));
            y.domain(d3.extent(rows, function(d) { return d.avg; })); 
            
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
           
          });"))

; (mac barchart ((data "sample.csv") (width 300) (height 100)) ___)
; http://bl.ocks.org/mbostock/3885304
; (mac smoothlinegraph
;
; (mac heatgrid
; http://mbostock.github.io/d3/talk/20111018/calendar.html
