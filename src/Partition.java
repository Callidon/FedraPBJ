package com.alma.partition;

import javafx.util.Pair;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

public class Partition {

    public <T,E> List<Pair<T, List<E>>> partition(List<T> sources, List<E> bindings) {
        List<Pair<T, List<E>>> results = new ArrayList<Pair<T, List<E>>>();
        List<E> subset = new ArrayList<E>();
        int subset_size = (int) Math.ceil((double)bindings.size()/(double)sources.size());
        ListIterator<T> current_source = sources.listIterator();

        for(E binding : bindings) {
            subset.add(binding);
            if(subset.size() == subset_size) {
                Pair<T, List<E>> pair = new Pair<T, List<E>>(current_source.next(), new ArrayList<E>(subset));
                results.add(pair);
                subset.clear();
            }
        }

        if(subset.size() > 0) {
            Pair<T, List<E>> pair = new Pair<T, List<E>>(current_source.next(), new ArrayList<E>(subset));
            results.add(pair);
        }

        return results;
    }

    /*
     * Test avec |sources| > |bindings|
     */
    public static void testSup() {
        Partition p = new Partition();
        List<String> sources = new ArrayList<String>();
        List<String> bindings = new ArrayList<String>();

        sources.add("sA");
        sources.add("sB");
        sources.add("sC");
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

    /*
     * Test avec |sources| < |bindings|
     */
    public static void testInf() {
        Partition p = new Partition();
        List<String> sources = new ArrayList<String>();
        List<String> bindings = new ArrayList<String>();

        sources.add("sA");
        sources.add("sB");
        sources.add("sC");
        bindings.add("e1");
        bindings.add("e2");

        System.out.println(p.partition(sources, bindings));
    }

    /*
     * Test avec |sources| == |bindings|
     */
    public static void testEquals() {
        Partition p = new Partition();
        List<String> sources = new ArrayList<String>();
        List<String> bindings = new ArrayList<String>();

        sources.add("sA");
        sources.add("sB");
        bindings.add("e1");
        bindings.add("e2");

        System.out.println(p.partition(sources, bindings));
    }

    public static void main(String[] args) {
        testSup();
        testInf();
        testEquals();
    }
}
