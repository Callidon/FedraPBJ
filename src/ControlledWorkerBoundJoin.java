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
	private String sourceSelectionStrategy;
    private ParallelFedraPartitioning PBJPartitionning;

	public ControlledWorkerBoundJoin(ControlledWorkerScheduler<BindingSet> scheduler, FederationEvalStrategy strategy,
									 CloseableIteration<BindingSet, QueryEvaluationException> leftIter,
									 TupleExpr rightArg, BindingSet bindings, QueryInfo queryInfo)
			throws QueryEvaluationException {
        super(scheduler, strategy, leftIter, rightArg, bindings, queryInfo);
        sourceSelectionStrategy = Config.getConfig().getProperty("SourceSelectionStrategy", "FedX");
        PBJPartitionning = new ParallelFedraPartitioning();
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
		Map<StatementSource, TaskCreator> parallelTaskCreators = new HashMap<>();
		List<StatementSource> sources = null;
		List<List<StatementSource>> sourcesGroups = null;

		// first item is always sent in a non-bound way
		final boolean useFedraPBJ = sourceSelectionStrategy.toLowerCase().contains("fedra-pbj");
		if (!closed && leftIter.hasNext()) {
			BindingSet b = leftIter.next();
            System.out.println("join#" + joinId + " mysterious b : " + b);
            totalBindings++;
			if (expr instanceof StatementTupleExpr) {

				StatementTupleExpr stmt = (StatementTupleExpr)expr;

				if (stmt.hasFreeVarsFor(b)) {

					if(stmt instanceof StatementSourcePattern) {
						// if we are using the Parallel Bound Join algorithm & this triple has multiples sources selected by Fedra
						if(useFedraPBJ && stmt instanceof FedraStatementSourcePattern) {
                            FedraStatementSourcePattern source_pattern = (FedraStatementSourcePattern) stmt;
                            sourcesGroups = source_pattern.getRelevantSources();

                            // duplicate the tuple without his sources
                            TupleExpr stmt_single = new StatementPattern(source_pattern.getSubjectVar(), source_pattern.getPredicateVar(), source_pattern.getObjectVar());

                            // create a StatmentSourcePattern & his associate Task Creator for each source
                            for(List<StatementSource> endpoints : sourcesGroups) {
                                for(StatementSource source : endpoints) {
                                    StatementSourcePattern new_stmt = new StatementSourcePattern((StatementPattern) stmt_single, source_pattern.getQueryInfo());
                                    new_stmt.addStatementSource(source);
                                    // create the associated task creator
                                    parallelTaskCreators.put(source, new BoundJoinTaskCreator(this, strategy, new_stmt));
                                }
                            }
						} else {
							// classic case in FedX Bound Join algorithm
							taskCreator = new BoundJoinTaskCreator(this, strategy, stmt);
						}
					}
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

		// Collect all the bindings
        int nBindings;
        List<BindingSet> bindings = null;
        List<List<BindingSet>> bindingPages = new ArrayList<>();
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

            if (totalBindings > 10)
                nBindings = nBindingsCfg;
            else
                nBindings = 3;

            bindings = new ArrayList<>(nBindings);

            int count = 0;
            while (count < nBindings && leftIter.hasNext()) {
                BindingSet binding = leftIter.next();
                bindings.add(binding);
                count++;
            }

            totalBindings += count;

            // add the bindings page only if it contains at least one elt
            if(bindings.size() > 0) {
                bindingPages.add(new ArrayList<>(bindings));
            }
        }

        // if we are using the Parallel Bound Join algorithm
        if(useFedraPBJ) {
            // schedule the tasks using the Parallel Bound Join algorithm
            assert sourcesGroups != null;
            System.out.println("join#" + joinId + " parallel bound join");
            for(List<StatementSource> endpoints : sourcesGroups) {
                // if no parallelization is possible
                if(endpoints.size() == 1) {
                    System.out.println("join#" + joinId + " simple case");
                    // classic case for Bound Join
                    for(List<BindingSet> page : bindingPages) {
                        scheduler.schedule(parallelTaskCreators.get(endpoints.get(0)).getTask(page));
                    }
                } else {
                    // if we a parallelization is possible, we apply the parallel bound join algorithm
                    System.out.println("join#" + joinId + " parallel case");
                    PBJPartitionning.setSources(endpoints);
                    PBJPartitionning.setBindingsPage(bindingPages);
                    PBJPartitionning.performPartition(ParallelFedraPartitioning.PARTITION_ALGORITHM.BRUTE_FORCE);
                    List<Pair<StatementSource, List<List<BindingSet>>>> groups = PBJPartitionning.getPartition();

                    for(Pair<StatementSource, List<List<BindingSet>>> pair : groups) {
                        // for each pair assignated to this source, schedule a task
                        System.out.println("join#" + joinId + " source used : " + pair.getFirst());
                        for(List<BindingSet> page : pair.getSecond()) {
                            scheduler.schedule(parallelTaskCreators.get(pair.getFirst()).getTask(page));
                        }
                    }
                }
            }
        } else {
            System.out.println("join#" + joinId + " normal bound join");
            // classic case for Bound Join
            for(List<BindingSet> page : bindingPages) {
                assert taskCreator != null;
                scheduler.schedule(taskCreator.getTask(page));
            }
        }


        // OLD CODE - didn't use the bindings pagination
		/*if(useFedraPBJ) {
			List<BindingSet> allBindings = new ArrayList<>();

			while (!closed && leftIter.hasNext()) {*/
			/*
			 * XXX idea:
			 *
			 * make nBindings dependent on the number of intermediate results of the left argument.
			 *
			 * If many intermediate results, increase the number of bindings. This will result in less
			 * remote SPARQL requests.
			 *
			 */
			/*	allBindings.add(leftIter.next());
			}

			totalBindings = allBindings.size() + 1;

            // FIX ME : possibly remove this test (see FIX ME above)
            if(sourcesGroups != null) {
                // schedule the tasks using the Parallel Bound Join algorithm
                for(List<StatementSource> endpoints : sourcesGroups) {
                    List<Pair<StatementSource, List<BindingSet>>> groups = partition(endpoints, allBindings);

                    for(Pair<StatementSource, List<BindingSet>> pair : groups) {
                        scheduler.schedule(parallelTaskCreator.get(pair.getFirst()).getTask(pair.getSecond()));
                    }
                }
            } else if (sources != null) {
                //process the classic statements
                for(StatementSource source : sources) {
                    scheduler.schedule(parallelTaskCreator.get(source).getTask(allBindings));
                }
            } else {
                log.error("There is values either in sourcesGroups and sources. Something goes wrong :/");
            }

		} else {
			// classic case using FedX native Bound Join algorithm
			int nBindings;
			List<BindingSet> bindings = null;
			while (!closed && leftIter.hasNext()) {*/


			/*
			 * XXX idea:
			 *
			 * make nBindings dependent on the number of intermediate results of the left argument.
			 *
			 * If many intermediate results, increase the number of bindings. This will result in less
			 * remote SPARQL requests.
			 *
			 */

			/*	if (totalBindings>10)
					nBindings = nBindingsCfg;
				else
					nBindings = 3;

				bindings = new ArrayList<>(nBindings);

				int count = 0;
				while (count < nBindings && leftIter.hasNext()) {
					BindingSet binding = leftIter.next();
					bindings.add(binding);
					count++;
				}

				totalBindings += count;
				if(taskCreator != null) {
					scheduler.schedule(taskCreator.getTask(bindings));
				}
			}
		}*/

        System.out.println("join#" + joinId + " number of tasks " + scheduler.getNumberOfTasks());

		scheduler.informFinish(this);

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
