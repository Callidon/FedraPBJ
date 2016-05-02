package com.fluidops.fedx.evaluation.join;

import com.fluidops.fedx.algebra.StatementSource;
import com.fluidops.fedx.optimizer.Pair;
import org.openrdf.query.BindingSet;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

/**
 * Class to perform the partition for the Parallel Bound Join algorithm using different algorithms
 */
public class ParallelFedraPartitioning {

    public enum PARTITION_ALGORITHM {
        BRUTE_FORCE
    }

    private List<StatementSource> sources;
    private List<List<BindingSet>> bindingsPages;
    private List<Pair<StatementSource, List<List<BindingSet>>>> partition;

    public ParallelFedraPartitioning() {
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
            default:
                this.bruteForcePairs();
                break;
        }
    }

    /**
     * Perform the partition using a brute force algorithm
     * @warning possibly very poorly optimized
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
        int num = 0;
        //ouput infos about the partition
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
    }

    /**
     * Perform the partition using a LPT algorithm
     */
    private void LPTPairs() {
        List<Pair<StatementSource, List<List<BindingSet>>>> results = new ArrayList<>();
    }
}
