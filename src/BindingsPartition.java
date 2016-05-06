package com.fluidops.fedx.evaluation.join;

import com.fluidops.fedx.algebra.StatementSource;
import com.fluidops.fedx.optimizer.Pair;
import org.openrdf.query.BindingSet;

import java.util.*;

/**
 * Class to manage the partition for the Parallel Bound Join algorithm using different algorithms
 * @author Thomas Minier <tminier01@gmail.com>
 */
public class BindingsPartition {

    private List<StatementSource> sources;
    private List<List<BindingSet>> bindingsPages;
    private List<Pair<StatementSource, List<List<BindingSet>>>> partition;

    public BindingsPartition() {
        sources = new ArrayList<>();
        bindingsPages = new ArrayList<>();
    }

    public void setSources(List<StatementSource> sources) {
        this.sources.addAll(sources);
    }

    public void setBindingsPage(List<List<BindingSet>> bindings) {
        this.bindingsPages.addAll(bindings);
    }

    public List<Pair<StatementSource, List<List<BindingSet>>>> getPartition() {
        return partition;
    }

    /**
     * Peform the partition for a given algorithm
     * @param algorithm
     */
    public void performPartition(PARTITION_ALGORITHM algorithm) {
        //System.out.println("bindings : " + bindingsPages);
        switch (algorithm) {
            case BRUTE_FORCE:
                this.bruteForcePairs();
                break;
            case LPT:
                this.LPTPairs();
                break;
            default:
                this.bruteForcePairs();
                break;
        }
        this.printPartition();
    }

    /**
     * Print informations about the current stored partition
     */
    public void printPartition() {
        if( (sources.size() >0 ) && (bindingsPages.size() > 0)) {
            int num = 0;
            for(Pair<StatementSource, List<List<BindingSet>>> pair : partition) {
                System.out.println("Pair n " + num);
                System.out.println("-> source : " + pair.getFirst().getEndpointID());
                System.out.println("-> #bindings : ");
                int nbBindings = 0;
                for(List<BindingSet> page : pair.getSecond()) {
                    System.out.println("--> page of : " + page.size() + " bindings");
                    nbBindings += page.size();
                }
                System.out.println("-> total bindings : " + nbBindings);
                num++;
            }
        } else {
            System.out.println("Empty partition");
        }
    }

    /**
     * Perform the partition using a brute force algorithm
     * WARNING : this algorithm does not ensure the load balancing between the endpoints
     */
    private void bruteForcePairs() {
        List<Pair<StatementSource, List<List<BindingSet>>>> results = new ArrayList<>();
        List<List<BindingSet>> subset = new ArrayList<>();
        int subset_size = (int) Math.ceil((double) bindingsPages.size() / (double) sources.size());
        ListIterator<StatementSource> current_source = sources.listIterator();

        for(List<BindingSet> binding : bindingsPages) {
            subset.add(binding);

            if(subset.size() == subset_size) {
                Pair<StatementSource, List<List<BindingSet>>> pair = new Pair<StatementSource, List<List<BindingSet>>>(current_source.next(), new ArrayList<>(subset));
                results.add(pair);
                subset.clear();
            }
        }

        if(subset.size() > 0) {
            Pair<StatementSource, List<List<BindingSet>>> pair = new Pair<StatementSource, List<List<BindingSet>>>(current_source.next(), new ArrayList<>(subset));
            results.add(pair);
        }
        partition = results;
    }

    /**
     * Perform the partition using a Longest Processing Time (LPT) heuristic
     * @see <a href="http://www.serc.iisc.ernet.in/~simmhan/SE252-JAN2014/lectures/SE252.Jan2014.Lecture-17.pdf">reference lecture (p.12)</a>
     */
    private void LPTPairs() {
        List<Pair<StatementSource, List<List<BindingSet>>>> results = new ArrayList<>();
        ListIterator<StatementSource> current_source = sources.listIterator();
        List<List<List<BindingSet>>> bins = new ArrayList<>(sources.size());

        // sort binding pages by decreasing order
        Collections.sort(bindingsPages, new BindingPageSizeComparator(true));

        // initialize the bins
        for(int i = 0; i < sources.size(); i++) {
            bins.add(new ArrayList<List<BindingSet>>());
        }

        // fill the bins with LPT algorithm
        for(List<BindingSet> page : bindingsPages) {
            // find the bin with the smallest weight & assign the current page to it
            List<List<BindingSet>> min_bin = Collections.min(bins, new BinWeightComparator(false));
            min_bin.add(page);
        }

        // assign the bins to source in order to make pairs
        for(List<List<BindingSet>> bin : bins) {
            Pair<StatementSource, List<List<BindingSet>>> pair = new Pair<StatementSource, List<List<BindingSet>>>(current_source.next(), new ArrayList<>(bin));
            results.add(pair);
        }
        partition = results;
    }

    /**
     * Comparator for the pages of bindings, used in the LTP algorithm, for sorting them by their size
     */
    private class BindingPageSizeComparator implements Comparator<List<BindingSet>> {
        private boolean reverse;

        public BindingPageSizeComparator(boolean r) {
            reverse = r;
        }

        @Override
        public int compare(List<BindingSet> o1, List<BindingSet> o2) {
            if(reverse) {
                return o2.size() - o1.size();
            } else {
                return o1.size() - o2.size();
            }
        }
    }

    /**
     * Comparator for the bins, used in the LTP algorithm, for sorting them by their weight
     */
    private class BinWeightComparator implements Comparator<List<List<BindingSet>>> {
        private boolean reverse;

        public BinWeightComparator(boolean r) {
            reverse = r;
        }

        @Override
        public int compare(List<List<BindingSet>> b1, List<List<BindingSet>> b2) {
            // compute the weight of each bin
            int weight_b1 = 0, weight_b2 = 0;

            for(List<BindingSet> page : b1){
                weight_b1 += page.size();
            }
            for(List<BindingSet> page : b2){
                weight_b2 += page.size();
            }

            if(reverse) {
                return weight_b2 - weight_b1;
            } else {
                return weight_b1 - weight_b2;
            }
        }
    }

    /**
     * Enum representing available algorithm for the partition
     */
    public enum PARTITION_ALGORITHM {
        BRUTE_FORCE,
        LPT
    }
}
