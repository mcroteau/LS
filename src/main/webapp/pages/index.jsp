<html>
<head>
    <script
            src="https://code.jquery.com/jquery-3.6.0.min.js"
            integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
            crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mustache.js/0.1/mustache.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/d3@7.0.1/dist/d3.min.js"></script>
</head>
<body>

<svg width="890" height="560"></svg>

<table>
    <tr>
        <th>Date</th>
        <th>Country</th>
        <th>Confirmed</th>
        <th>Confirmed Percent</th>
        <th>Recovered</th>
        <th>Recovered Percent</th>
        <th>Deaths</th>
        <th>Deaths Percent</th>
    </tr>
    <tbody id="data"></tbody>
</table>

<script type="text/template" id="template">
    {{#consolidated}}
        <tr>
            <td>{{Date}}</td>
            <td>{{Country}}</td>
            <td>{{Confirmed}}</td>
            <td>{{confirmedPercent}}</td>
            <td>{{Recovered}}</td>
            <td>{{recoveredPercent}}</td>
            <td>{{deathTotal}}</td>
            <td>{{deathsPercent}}</td>
        </tr>
    {{/consolidated}}
</script>

<script>

    $('#data').html('loading...');

    $(document).ready(function(){
        let seriesDataPre = {}
        let seriesData = [];
        let tableData = {};

        $.ajax({
           url : "/q/data",
           success : function(resp, data){
               const output = Mustache.render($('#template').text(), resp);
               $('#data').html(output);

               const consolidateData = (resp) =>{
                   $(resp.tally).each(function(idx, obj){
                       if(obj.Date in seriesDataPre){
                           seriesDataPre[obj.Date].push(obj);
                       }else{
                           seriesDataPre[obj.Date] = []
                           seriesDataPre[obj.Date].push(obj);
                       }
                       seriesData.push(seriesDataPre[obj.Date]);
                   })
               }

               Promise.all([consolidateData(resp)])
                   .then(function() {
                       console.info('loaded')
                       startSeries();
                   });
           }
        })


        height = 560
        width = 890
        margin = ({top: 20, right: 20, bottom: 35, left: 40})

        x = d3.scaleLog([1577836800000, 1625097600000], [margin.left, width - margin.right])
        y = d3.scaleLinear([0, 3], [height - margin.bottom, margin.top])
        radius = d3.scaleSqrt([0, 5e8], [0, width / 24])

        xAxis = g => g
            .attr("transform", 'translate(0, 525)')
            .call(d3.axisBottom(x).ticks(width / 80, ","))
            .call(g => g.select(".domain").remove())
            .call(g => g.append("text")
                .attr("x", width)
                .attr("y", margin.bottom - 4)
                .attr("fill", "currentColor")
                .attr("text-anchor", "end")
                .text("~ Date ~"))


        yAxis = g => g
            .attr("transform", 'translate(40,0)')
            .call(d3.axisLeft(y))
            .call(g => g.select(".domain").remove())
            .call(g => g.append("text")
                .attr("x", -margin.left)
                .attr("y", 10)
                .attr("fill", "currentColor")
                .attr("text-anchor", "start")
                .text("Death Percent"))


        grid = g => g
            .attr("stroke", "currentColor")
            .attr("stroke-opacity", 0.1)
            .call(g => g.append("g")
                .selectAll("line")
                .data(x.ticks())
                .join("line")
                .attr("x1", d => 0.5 + x(d))
                .attr("x2", d => 0.5 + x(d))
                .attr("y1", margin.top)
                .attr("y2", height - margin.bottom))
            .call(g => g.append("g")
                .selectAll("line")
                .data(y.ticks())
                .join("line")
                .attr("y1", d => 0.5 + y(d))
                .attr("y2", d => 0.5 + y(d))
                .attr("x1", margin.left)
                .attr("x2", width - margin.right));

        const svg = d3.select("svg")
            .attr("viewBox", [0, 0, width, height]);

        function Chart(){

            svg.append("g")
                .call(xAxis);

            svg.append("g")
                .call(yAxis);

            svg.append("g")
                .call(grid);

        };


        Chart.prototype.update = function(data){
            svg.selectAll("g").select("circle").exit().remove();
            svg.selectAll("g").select("circle").data(data, d => d.Country)
                .join("circle")
                .sort((a, b) => d3.descending(a.deathsPercent, b.deathsPercent))
                .attr("cx", d => {
                    console.log(x(Date.parse(d.Date)), y(d.deathsPercent), radius(d.deathsPercent * 1000000000000));
                    return x(Date.parse(d.Date))
                })
                .attr("cy", d => {
                    return y(d.deathsPercent)
                })
                .attr("r", d => {
                    return radius(d.deathsPercent * 1000000000000)
                });

        }

        Chart.prototype.h = function(){
            console.info('hx');
            alert('x');
        }

        Chart.prototype.circle = svg.append("g")
                .attr("stroke", "black")
                .selectAll("circle")
                .data([], d => d.Country)
                .join("circle")
                .sort((a, b) => d3.descending(a.deathsPercent, b.deathsPercent))
                .attr("cx", d => {
                    return x(Date.parse(d.Date))})
                .attr("cy", d => {
                    return y(d.deathsPercent)
                })
                .attr("r", d => {
                    return d.deathsPercent * 10000
                })
                .attr("fill", "black")
                .call(circle => circle.append("title")
                    .text(d => d.Country));


        const startSeries = function(){

            chart = new Chart();

            let idx = -1;
            let currentData = seriesData[0];
            let interval = setInterval(() => {
                idx++;
                if (idx >= seriesData.length) {
                    clearInterval(interval);
                    interval = 0;
                }
                currentData = seriesData[idx];
                chart.update(currentData)
            }, 1000);
        }
    });
</script>

</body>
</html>