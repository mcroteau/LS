package apex;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvException;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import qio.annotate.HttpHandler;
import qio.annotate.JsonOutput;
import qio.annotate.verbs.Get;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

@HttpHandler
public class HelloHandler {

    Gson gson = new Gson();

    static final String THREAT_URL = "https://pkgstore.datahub.io/core/covid-19/countries-aggregated_json/data/0470557b51a98ab9c4a30ed24cd0eb2c/countries-aggregated_json.json";

    @Get("/")
    public String index(){
        return "/pages/index.jsp";
    }

    @JsonOutput
    @Get("/data")
    public String data() throws IOException, CsvException{

        List<Menace> menaces = new ArrayList<Menace>();

        OkHttpClient client = new OkHttpClient();
        Request requestThreat = new Request.Builder()
                .url(THREAT_URL)
                .build();

        Response threatResponse = client.newCall(requestThreat).execute();
        String json = threatResponse.body().string();

        Type listType = new TypeToken<ArrayList<Menace>>(){}.getType();
        List<Menace> threats = new Gson().fromJson(json, listType);


        CSVReader reader = new CSVReader(new FileReader(new File("pop_data.csv")));
        List<String[]> populations = reader.readAll();

        Map<String, Menace> consolidatedMap = new HashMap<String, Menace>();

        for(String[] populationData : populations){
            String country = populationData[0];
            BigDecimal population = new BigDecimal(populationData[1].trim()).multiply(new BigDecimal(1000));
            for(Menace threat: threats){
                if(country.toLowerCase().equals(threat.getCountry().toLowerCase())){

                    BigDecimal confirmedPercent = new BigDecimal(0);
                    if(!threat.getConfirmed().equals(0)){
                        confirmedPercent = new BigDecimal(threat.getConfirmed()).divide(population, 7, RoundingMode.HALF_UP).multiply(new BigDecimal(100));
                    }
                    BigDecimal recoveredPercent = new BigDecimal(0);
                    if(!threat.getRecovered().equals(0)){
                        recoveredPercent = new BigDecimal(threat.getRecovered()).divide(population, 7, RoundingMode.HALF_UP).multiply(new BigDecimal(100));
                    }
                    BigDecimal deathsPercent = new BigDecimal(0);
                    if(!threat.getDeaths().equals(0)){
                        deathsPercent = new BigDecimal(threat.getDeaths()).divide(population, 7, RoundingMode.HALF_UP).multiply(new BigDecimal(100));
                    }

                    threat.setConfirmedPercent(confirmedPercent);
                    threat.setRecoveredPercent(recoveredPercent);
                    threat.setDeathsPercent(deathsPercent);

                    Integer deathTotal = (threat.getDeathTotal() != null ? threat.getDeathTotal() : 0);
                    threat.setDeathTotal( deathTotal + threat.getDeaths());

                    menaces.add(threat);

                    consolidatedMap.put(threat.getCountry(), threat);

                }
            }
        }

        List<Menace> consolidated = new ArrayList<Menace>();
        for(Map.Entry<String, Menace> entry: consolidatedMap.entrySet()){
            consolidated.add(entry.getValue());
        }
        Comparator<Menace> comparator = new Comparator<Menace>() {
            @Override
            public int compare(Menace a1, Menace a2) {
                return a2.getDeathsPercent().compareTo(a1.getDeathsPercent());
            }
        };
        Collections.sort(consolidated, comparator);

        MenaceTally menaceTally = new MenaceTally(menaces, consolidated);
        return gson.toJson(menaceTally);
    }


}
