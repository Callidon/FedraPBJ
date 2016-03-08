/*
 * Copyright (C) 2008-2013, fluid Operations AG
 *
 * FedX is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.fluidops.fedx.evaluation.join;

import com.fluidops.fedx.algebra.*;
import com.fluidops.fedx.optimizer.Pair;
import info.aduna.iteration.CloseableIteration;

import java.util.*;

import info.aduna.iteration.CloseableIteratorIteration;
import org.apache.log4j.Logger;
import org.openrdf.query.BindingSet;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.algebra.StatementPattern;
import org.openrdf.query.algebra.TupleExpr;

import com.fluidops.fedx.Config;
import com.fluidops.fedx.evaluation.FederationEvalStrategy;
import com.fluidops.fedx.evaluation.concurrent.ControlledWorkerScheduler;
import com.fluidops.fedx.evaluation.concurrent.ParallelTask;
import com.fluidops.fedx.structures.QueryInfo;



/**
 * Execute the nested loop join in an asynchronous fashion, using grouped requests,
 * i.e. group bindings into one SPARQL request using the UNION operator.
 *
 * The number of concurrent threads is controlled by a {@link ControlledWorkerScheduler} which
 * works according to the FIFO principle and uses worker threads.
 *
 * This join cursor blocks until all scheduled tasks are finished, however the result iteration
 * can be accessed from different threads to allow for pipelining.
 *
 * @author Andreas Schwarte
 *
 */
public class ControlledWorkerBoundJoin extends ControlledWorkerJoin {

	public static Logger log = Logger.getLogger(ControlledWorkerBoundJoin.class);

	public ControlledWorkerBoundJoin(ControlledWorkerScheduler<BindingSet> scheduler, FederationEvalStrategy strategy,
			CloseableIteration<BindingSet, QueryEvaluationException> leftIter,
			TupleExpr rightArg, BindingSet bindings, QueryInfo queryInfo)
			throws QueryEvaluationException {
		super(scheduler, strategy, leftIter, rightArg, bindings, queryInfo);
	}

	protected <T,E> List<Pair<T, List<E>>> partition(List<T> sources, List<E> bindings) {
		List<Pair<T, List<E>>> results = new ArrayList<>();
		List<E> subset = new ArrayList<>();
		int subset_size = (int) Math.ceil((double) bindings.size() / (double) sources.size());
		ListIterator<T> current_source = sources.listIterator();

		for(E binding : bindings) {
			subset.add(binding);

			if( subset.size() == subset_size) {
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


	@Override
	protected void handleBindings() throws Exception {
		if (! (canApplyVectoredEvaluation(rightArg))) {
			log.debug("Right argument is not an applicable BoundJoinTupleExpr. Fallback on ControlledWorkerJoin implementation: " + rightArg.getClass().getCanonicalName());
			super.handleBindings();	// fallback
			return;
		}

		int nBindingsCfg = Config.getConfig().getBoundJoinBlockSize();
		int totalBindings = 0;		// the total number of bindings
		TupleExpr expr = rightArg;

		TaskCreator taskCreator = null;
        Map<StatementSource, TaskCreator> parralellTaskCreators = new HashMap<>();
        List<StatementSource> sources = null;

		// first item is always sent in a non-bound way
		if (!closed && leftIter.hasNext()) {
			BindingSet b = leftIter.next();
			totalBindings++;
			if (expr instanceof StatementTupleExpr) {

				StatementTupleExpr stmt = (StatementTupleExpr)expr;

				if (stmt.hasFreeVarsFor(b)) {
                    log.debug("Inside stmt.hasFreeVars(b)");
                    log.debug("stmt.toString : \n" + stmt.toString());
                    if(stmt instanceof StatementSourcePattern) {
                        StatementSourcePattern source_pattern = (StatementSourcePattern) stmt;
                        sources = source_pattern.getStatementSources();
                        // duplicate the tuple without his sources
                        TupleExpr stmt_single = new StatementPattern(source_pattern.getSubjectVar(), source_pattern.getPredicateVar(), source_pattern.getObjectVar());

                        for(StatementSource source : sources) {
                            // create a new tuple associate with the current source
                            StatementSourcePattern new_stmt = new StatementSourcePattern((StatementPattern) stmt_single, source_pattern.getQueryInfo());
                            new_stmt.addStatementSource(source);
                            log.debug("new stmt : \n" + new_stmt);
                            // create the associated task creator
                            parralellTaskCreators.put(source, new BoundJoinTaskCreator(this, strategy, new_stmt));
                        }
                    }

                    // Previous code
                    //taskCreator = new BoundJoinTaskCreator(this, strategy, stmt);
				} else {
					expr = new CheckStatementPattern(stmt);
					taskCreator = new CheckJoinTaskCreator(this, strategy, (CheckStatementPattern)expr);
				}
			} else if (expr instanceof FedXService) {
				taskCreator = new FedXServiceJoinTaskCreator(this, strategy, (FedXService)expr);
			} else if (expr instanceof IndependentJoinGroup) {
				taskCreator = new IndependentJoinGroupTaskCreator(this, strategy, (IndependentJoinGroup)expr);
			} else {
				throw new RuntimeException("Expr is of unexpected type: " + expr.getClass().getCanonicalName() + ". Please report this problem.");
			}
			scheduler.schedule( new ParallelJoinTask(this, strategy, expr, b) );
		}

		int nBindings;
		List<BindingSet> bindings = null;
        List<BindingSet> allBindings = new ArrayList<>();
		while (!closed && leftIter.hasNext()) {


			/*
			 * XXX idea:
			 *
			 * make nBindings dependent on the number of intermediate results of the left argument.
			 *
			 * If many intermediate results, increase the number of bindings. This will result in less
			 * remote SPARQL requests.
			 *
			 */
			// Previous code
			/*if (totalBindings>10)
				nBindings = nBindingsCfg;
			else
				nBindings = 3;

			bindings = new ArrayList<BindingSet>(nBindings);

			int count = 0;
			while (count < nBindings && leftIter.hasNext()) {
                BindingSet binding = leftIter.next();
				bindings.add(binding);
				count++;
			}

            log.debug("current number of bindings : " + allBindings.size());

			totalBindings += count;*/
            totalBindings++;
            allBindings.add(leftIter.next());

            // Previous code
            if(taskCreator != null) {
                scheduler.schedule( taskCreator.getTask(bindings) );
            }
		}
        log.debug("size of allBindings : " + allBindings.size() + " vs total bindings " + totalBindings);

        // create the partitions
        if(taskCreator == null) {
            List<Pair<StatementSource, List<BindingSet>>> partitions = partition(sources, allBindings);
            log.debug("Les partitions : \n" + partitions);

            for(Pair<StatementSource, List<BindingSet>> pair : partitions) {
                scheduler.schedule( parralellTaskCreators.get(pair.getFirst()).getTask(pair.getSecond()) );
            }
        }

		scheduler.informFinish(this);


		log.debug("JoinStats: left iter of join #" + this.joinId + " had " + totalBindings + " results.");

		// wait until all tasks are executed
		synchronized (this) {
			try {
				// check to avoid deadlock
				if (scheduler.isRunning(this))
					this.wait();
			} catch (InterruptedException e) {
				;	// no-op
			}
		}
	}

	/**
	 * Returns true if the vectored evaluation can be applied for the join argument, i.e.
	 * there is no fallback to {@link ControlledWorkerJoin#handleBindings()}. This is
	 *
	 * a) if the expr is a {@link BoundJoinTupleExpr} (Mind the special handling for
	 *    {@link FedXService} as defined in b)
	 * b) if the expr is a {@link FedXService} and {@link Config#getEnableServiceAsBoundJoin()}
	 *
	 * @return
	 */
	private boolean canApplyVectoredEvaluation(TupleExpr expr) {
		if (expr instanceof BoundJoinTupleExpr) {
			if (expr instanceof FedXService)
				return Config.getConfig().getEnableServiceAsBoundJoin();
			return true;
		}
		return false;
	}


	protected interface TaskCreator {
		public ParallelTask<BindingSet> getTask(List<BindingSet> bindings);
	}

	protected class BoundJoinTaskCreator implements TaskCreator {
		protected final ControlledWorkerBoundJoin _control;
		protected final FederationEvalStrategy _strategy;
		protected final StatementTupleExpr _expr;
		public BoundJoinTaskCreator(ControlledWorkerBoundJoin control,
				FederationEvalStrategy strategy, StatementTupleExpr expr) {
			super();
			_control = control;
			_strategy = strategy;
			_expr = expr;
		}
		@Override
		public ParallelTask<BindingSet> getTask(List<BindingSet> bindings) {
			return new ParallelBoundJoinTask(_control, _strategy, _expr, bindings);
		}
	}

	protected class CheckJoinTaskCreator implements TaskCreator {
		protected final ControlledWorkerBoundJoin _control;
		protected final FederationEvalStrategy _strategy;
		protected final CheckStatementPattern _expr;
		public CheckJoinTaskCreator(ControlledWorkerBoundJoin control,
				FederationEvalStrategy strategy, CheckStatementPattern expr) {
			super();
			_control = control;
			_strategy = strategy;
			_expr = expr;
		}
		@Override
		public ParallelTask<BindingSet> getTask(List<BindingSet> bindings) {
			return new ParallelCheckJoinTask(_control, _strategy, _expr, bindings);
		}
	}

	protected class FedXServiceJoinTaskCreator implements TaskCreator {
		protected final ControlledWorkerBoundJoin _control;
		protected final FederationEvalStrategy _strategy;
		protected final FedXService _expr;
		public FedXServiceJoinTaskCreator(ControlledWorkerBoundJoin control,
				FederationEvalStrategy strategy, FedXService expr) {
			super();
			_control = control;
			_strategy = strategy;
			_expr = expr;
		}
		@Override
		public ParallelTask<BindingSet> getTask(List<BindingSet> bindings) {
			return new ParallelServiceJoinTask(_control, _strategy, _expr, bindings);
		}
	}

	protected class IndependentJoinGroupTaskCreator implements TaskCreator {
		protected final ControlledWorkerBoundJoin _control;
		protected final FederationEvalStrategy _strategy;
		protected final IndependentJoinGroup _expr;
		public IndependentJoinGroupTaskCreator(ControlledWorkerBoundJoin control,
				FederationEvalStrategy strategy, IndependentJoinGroup expr) {
			super();
			_control = control;
			_strategy = strategy;
			_expr = expr;
		}
		@Override
		public ParallelTask<BindingSet> getTask(List<BindingSet> bindings) {
			return new ParallelIndependentGroupJoinTask(_control, _strategy, _expr, bindings);
		}
	}

}
