package com.fluidops.fedx.algebra;

import com.fluidops.fedx.structures.QueryInfo;
import org.openrdf.query.algebra.StatementPattern;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Statement source pattern implementing a set of set of sources
 */
public class FedraStatementSourcePattern extends StatementSourcePattern {

    private List<List<StatementSource>> relevantSources;
    private Map<StatementSource, StatementSourcePattern> relevantSourcePatterns;

    public FedraStatementSourcePattern(StatementPattern node, QueryInfo queryInfo) {
        super(node, queryInfo);
        relevantSources = new ArrayList<>();
        relevantSourcePatterns = new HashMap<>();
    }

    public List<List<StatementSource>> getRelevantSources() {
        return relevantSources;
    }

    public Map<StatementSource, StatementSourcePattern> getRelevantSourcePatterns() {
        return relevantSourcePatterns;
    }

    public void setRelevantSources(StatementPattern stmt, List<List<StatementSource>> relevantSources, QueryInfo queryInfo) {
        for(List<StatementSource> endpoints : relevantSources) {
            this.relevantSources.add(new ArrayList<>(endpoints));
            for(StatementSource source : endpoints) {
                StatementSourcePattern stmtSource = new StatementSourcePattern(stmt, queryInfo);
                stmtSource.addStatementSource(source);
                this.relevantSourcePatterns.put(source, stmtSource);
            }
        }
    }
}
