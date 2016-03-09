package com.fluidops.fedx.algebra;

import com.fluidops.fedx.structures.QueryInfo;
import org.openrdf.query.algebra.StatementPattern;

import java.util.ArrayList;
import java.util.List;

/**
 * Statement source pattern implementing a set of set of sources
 */
public class FedraStatementSourcePattern extends StatementSourcePattern {

    private List<List<StatementSource>> relevantSources;

    public FedraStatementSourcePattern(StatementPattern node, QueryInfo queryInfo) {
        super(node, queryInfo);
        relevantSources = new ArrayList<>();
    }

    public List<List<StatementSource>> getRelevantSources() {
        return relevantSources;
    }

    public void addRelevantSources(List<StatementSource> sources) {
        relevantSources.add(sources);
    }

}
