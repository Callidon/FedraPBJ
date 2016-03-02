package com.alma.partition;

import javafx.util.Pair;

import java.util.ArrayList;
import java.util.List;

public class Partition {

    public <T,E> List<Pair<T, List<E>>> partition(List<T> sources, List<E> bindings) {
        List<Pair<T, List<E>>> results = new ArrayList<Pair<T, List<E>>>();
        List<E> subset = new ArrayList<E>();
        int subset_size = bindings.size() / sources.size();
        int current_source = 0;
        int cpt = 0;

        for(E binding : bindings) {
            if(cpt % subset_size == 0) {
                Pair<T, List<E>> pair = new Pair<T, List<E>>(sources.get(current_source), subset);
                results.add(pair);
                current_source++;
                subset.clear();
            }
            subset.add(binding);
            cpt++;
        }

        return results;
    }

    public static void main(String[] args) {
        Partition p = new Partition();
        List<String> sources = new ArrayList<String>();
        List<String> bindings = new ArrayList<String>();

        sources.add("sA");
        sources.add("sB");
        bindings.add("e1");
        bindings.add("e2");
        bindings.add("e3");
        bindings.add("e4");
        bindings.add("e5");
        bindings.add("e6");
        bindings.add("e7");
        bindings.add("e8");

        System.out.println(p.partition(sources, bindings));

    }
}
