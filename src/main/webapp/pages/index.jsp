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

<h1>Pesky Kids</h1>
<table id="entries"></table>

<h1>Totals</h1>
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
        <th>Ratio</th>
    </tr>
    <tbody id="data"></tbody>
</table>

<script type="text/template" id="entriesTemplate">
    {{#entries}}
        <tr>
            <td>{{Date}}</td>
            <td>{{Country}}</td>
        </tr>
    {{/entries}}
</script>

<script type="text/template" id="template">
    {{#tally}}
        <tr>
            <td>{{Date}}</td>
            <td>{{Country}}</td>
            <td>{{Confirmed}}</td>
            <td>{{confirmedPercent}}</td>
            <td>{{Recovered}}</td>
            <td>{{recoveredPercent}}</td>
            <td>{{deathTotal}}</td>
            <td>{{deathsPercent}}</td>
<%--            <td>{{curedRatio}}</td>--%>
        </tr>
    {{/tally}}
</script>

<script>

    $('#data').html('loading...');

    $(document).ready(function(){
        let c = { entries: [] };
        let countries = {};
        let tableData = {};

        let lastManStanding = {};

        $.ajax({
           url : "/q/data",
           success : function(resp, data){
               const output = Mustache.render($('#template').text(), resp);
               $('#data').html(output);

               const consolidateData = (resp) =>{
                   $(resp.tally).each(function(idx, obj){
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

                       const output = Mustache.render($('#entriesTemplate').text(), c);
                       $('#entries').html(output);
                   });
           }
        })

    });
</script>

</body>
</html>