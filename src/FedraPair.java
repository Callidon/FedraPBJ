package com.alma.partition;

import java.util.List;

/**
 * Classe représentant une paire (source, list of bindings)
 */
public class FedraPair<T,E> {

    private T source;
    private List<E> bindings;


    public FedraPair(T source, List<E> bindings) {
        this.source = source;
        this.bindings = bindings;
    }

    public T getSource() {
        return source;
    }

    public void setSource(T source) {
        this.source = source;
    }

    public List<E> getBindings() {
        return bindings;
    }

    public void setBindings(List<E> bindings) {
        this.bindings = bindings;
    }
}
