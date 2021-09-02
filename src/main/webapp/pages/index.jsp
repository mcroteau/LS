<html>
<head>
    <script
            src="https://code.jquery.com/jquery-3.6.0.min.js"
            integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
            crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mustache.js/0.1/mustache.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/d3@7.0.1/dist/d3.min.js"></script>
    <style>
        body{
            width:690px;
        }
        table{
            border-collapse: collapse;
        }
        table td,
        table th{
            border:solid 1px #ddd;
            padding:3px 7px;
        }
    </style>

</head>

<body>

<h1>Germany + Laos + Vietnamese + Tanzania</h1>
<p>Germany plus the above and some others from East Africa originated Covid19.
In the hierarchy table Laos never had any reported covid deaths and is a known
    area of interest.</p>
<p>The details table displays Germany and Venezuala with similar 'oh shit' moments and
introduce covid to their countries around the same time. Germany "worked" Laos with the idea
that they would later use Laos + Vietnam as an American rally to conflict,
airing on Fox News China as the origin of Covid.</p>

<p style="color:red">Data may take a few minutes to load</p>

<h2>Hierarchy</h2>
<p>When either the first reported death occurred or last date of record</p>
<table id="entries"></table>

<h2>Consolidated</h2>
<table>
    <tr>
        <th>Date</th>
        <th>Country</th>
        <th>Confirmed</th>
<%--        <th>Confirmed Percent</th>--%>
        <th>Recovered</th>
<%--        <th>Recovered Percent</th>--%>
        <th>Deaths</th>
        <th>Deaths Percent</th>
        <th>Recovery Ratio</th>
    </tr>
    <tbody id="totals"></tbody>
</table>

<h2>Detailed</h2>
<table>
    <tr>
        <th>Date</th>
        <th>Country</th>
        <th>Confirmed</th>
<%--        <th>Confirmed Percent</th>--%>
<%--        <th>Recovered</th>--%>
<%--        <th>Recovered Percent</th>--%>
        <th>Deaths</th>
        <th>Deaths Percent</th>
<%--        <th>Ratio</th>--%>
    </tr>
    <tbody id="details"></tbody>
</table>

<script type="text/template" id="entriesTemplate">
<%--    {{#entries}}--%>
        <tr>
            <td>{{Date}}</td>
            <td>{{Country}}</td>
        </tr>
<%--    {{/entries}}--%>
</script>

<script type="text/template" id="consolidatedTemplate">
<%--    {{#consolidated}}--%>
    <tr>
        <td>{{Date}}</td>
        <td>{{Country}}</td>
        <td>{{Confirmed}}</td>
<%--        <td>{{confirmedPercent}}</td>--%>
<%--        <td>{{Recovered}}</td>--%>
<%--        <td>{{recoveredPercent}}</td>--%>
        <td>{{deathTotal}}</td>
        <td>{{deathsPercent}}</td>
        <td>{{curedRatio}}</td>
    </tr>
<%--    {{/consolidated}}--%>
</script>

<script type="text/template" id="template">
<%--    {{#tally}}--%>
        <tr>
            <td>{{Date}}</td>
            <td>{{Country}}</td>
            <td>{{Confirmed}}</td>
<%--            <td>{{confirmedPercent}}</td>--%>
            <td>{{Recovered}}</td>
<%--            <td>{{recoveredPercent}}</td>--%>
            <td>{{deathTotal}}</td>
            <td>{{deathsPercent}}</td>
<%--            <td>{{curedRatio}}</td>--%>
        </tr>
<%--    {{/tally}}--%>
</script>

<script>

    $('#entries').html('loading...');
    $('#totals').html('loading...');
    $('#details').html('loading...');

    $(document).ready(function(){
        let c = { entries: [] };
        let countries = {};
        let tableData = {};

        let lastManStanding = {};

        $.ajax({
           url : "/q/data",
           success : function(resp, data){


               const consolidateData = (resp) =>{
                   $('#totals').html('')
                   $(resp.consolidated).each(function(idx, obj){
                       const totals = Mustache.render($('#consolidatedTemplate').text(), obj);
                       $('#totals').append(totals);
                   })

                   $('#details').html('');
                   $(resp.tally).each(function(idx, obj){
                       const details = Mustache.render($('#template').text(), obj);
                       $('#details').append(details);

                       if(!countries.hasOwnProperty(obj.Country)){
                           if(obj.Deaths != 0){
                               countries[obj.Country] = obj.Date + " - " + obj.Country
                               c.entries.push(obj);
                           }
                       }
                       if($.isEmptyObject(lastManStanding)){
                           lastManStanding = obj
                       }
                       if(Date.parse(lastManStanding.Date) >= Date.parse(obj.Date) &&
                           obj.Deaths == '0'){
                           lastManStanding = obj;
                       }
                   })
               }

               Promise.all([consolidateData(resp)])
                   .then(function() {
                       console.info('loaded')
                       console.log(lastManStanding);
                       c.entries.sort(function (a, b) {
                           return Date.parse(b.Date) - Date.parse(a.Date);
                       });

                       $('#entries').html('');
                       $(c.entries).each(function(idx, obj){
                           const output = Mustache.render($('#entriesTemplate').text(), obj);
                           $('#entries').append(output);
                       })
                   });
           }
        })

    });
</script>

</body>
</html>
