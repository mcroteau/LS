package apex;

import java.util.List;

public class MenaceTally {
    public MenaceTally(List<Menace> tally, List<Menace> consolidated){
        this.tally = tally;
        this.consolidated = consolidated;
    }

    List<Menace> tally;
    List<Menace> consolidated;

    public List<Menace> getTally() {
        return tally;
    }

    public void setTally(List<Menace> tally) {
        this.tally = tally;
    }

    public List<Menace> getConsolidated() {
        return consolidated;
    }

    public void setConsolidated(List<Menace> consolidated) {
        this.consolidated = consolidated;
    }
}
