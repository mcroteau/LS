package apex;

import java.math.BigDecimal;

public class Menace {
    String Date;
    String Country;
    Integer Confirmed;
    Integer Recovered;
    Integer Deaths;
    BigDecimal confirmedPercent;
    BigDecimal recoveredPercent;
    BigDecimal deathsPercent;

    Integer deathTotal;

    public String getDate() {
        return Date;
    }

    public void setDate(String date) {
        Date = date;
    }

    public String getCountry() {
        return Country;
    }

    public void setCountry(String country) {
        Country = country;
    }

    public Integer getConfirmed() {
        return Confirmed;
    }

    public void setConfirmed(Integer confirmed) {
        Confirmed = confirmed;
    }

    public Integer getRecovered() {
        return Recovered;
    }

    public void setRecovered(Integer recovered) {
        Recovered = recovered;
    }

    public Integer getDeaths() {
        return Deaths;
    }

    public void setDeaths(Integer deaths) {
        Deaths = deaths;
    }

    public BigDecimal getConfirmedPercent() {
        return confirmedPercent;
    }

    public void setConfirmedPercent(BigDecimal confirmedPercent) {
        this.confirmedPercent = confirmedPercent;
    }

    public BigDecimal getRecoveredPercent() {
        return recoveredPercent;
    }

    public void setRecoveredPercent(BigDecimal recoveredPercent) {
        this.recoveredPercent = recoveredPercent;
    }

    public BigDecimal getDeathsPercent() {
        return deathsPercent;
    }

    public void setDeathsPercent(BigDecimal deathsPercent) {
        this.deathsPercent = deathsPercent;
    }

    public Integer getDeathTotal() {
        return deathTotal;
    }

    public void setDeathTotal(Integer deathTotal) {
        this.deathTotal = deathTotal;
    }
}

