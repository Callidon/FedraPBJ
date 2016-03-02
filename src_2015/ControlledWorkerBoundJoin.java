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

import info.aduna.iteration.CloseableIteration;

import java.util.*;

import com.fluidops.fedx.structures.Endpoint;
import org.openrdf.query.algebra.StatementPattern;

import org.apache.log4j.Logger;
import org.openrdf.query.BindingSet;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.algebra.TupleExpr;

import com.fluidops.fedx.Config;
import com.fluidops.fedx.algebra.StatementSource;
import com.fluidops.fedx.algebra.BoundJoinTupleExpr;
import com.fluidops.fedx.algebra.CheckStatementPattern;
import com.fluidops.fedx.algebra.FedXService;
import com.fluidops.fedx.algebra.IndependentJoinGroup;
import com.fluidops.fedx.algebra.StatementTupleExpr;
import com.fluidops.fedx.algebra.FedraStatementSourcePattern;
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

	
	@Override
	protected void handleBindings() throws Exception {
		if (! (canApplyVectoredEvaluation(rightArg))) {
			log.debug("Right argument is not an applicable BoundJoinTupleExpr. Fallback on ControlledWorkerJoin implementation: " + rightArg.getClass().getCanonicalName());
			super.handleBindings();// fallback
			return;
		}
		
		int nBindingsCfg = Config.getConfig().getBoundJoinBlockSize();	
		int totalBindings = 0;		// the total number of bindings
		TupleExpr expr = rightArg;
		
		// new StatementSource(e.getId(), StatementSourceType.REMOTE)
		//TaskCreator taskCreator = null;
		ArrayList<TaskCreator> taskCreators = new ArrayList<TaskCreator>();			
		//ArrayList<ArrayList<TaskCreator>> taskCreators = new ArrayList<ArrayList<TaskCreator>();
		ArrayList<FedraStatementSourcePattern> lfedrasrc= new ArrayList<FedraStatementSourcePattern>();
		ArrayList<ArrayList<StatementSource>> ssTmpL = new ArrayList<ArrayList<StatementSource>>();
		// first item is always sent in a non-bound way
		if (!closed && leftIter.hasNext()) {
			BindingSet b = leftIter.next();
			totalBindings++;
			if (expr instanceof StatementTupleExpr) {
				StatementTupleExpr stmt = (StatementTupleExpr)expr;
				if (stmt.hasFreeVarsFor(b)) {
					if(stmt instanceof FedraStatementSourcePattern){
						// we  take all the candidate sources 
						HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidateSources =((FedraStatementSourcePattern)stmt).getCandidateSources(); 
						
						 for (StatementPattern sp : candidateSources.keySet()) {
							
							//System.out.println(sp.equals(stmt));
							if(sp.equals(stmt)){
					                	
								HashSet<TreeSet<Endpoint>> fs = candidateSources.get(sp);
                        													                     			
								for (TreeSet<Endpoint> f : fs) {
								 	ArrayList<StatementSource> stmp = new ArrayList<StatementSource>();

									for(Endpoint endpoint : f){
										 
										stmp.add(new StatementSource(endpoint.getId(),StatementSource.StatementSourceType.REMOTE));	
									}	
								ssTmpL.add(stmp);
								}
							}
					
							
						}
						
						// récupérer chaque premier élément de chaque sous emsemble  et si taille inférieur prendre toujours le derniers
						//ArrayList<StatementSource> sttsTmp= new ArrayList<StatementSource>();
						ArrayList<ArrayList<StatementSource>> lsttsTmp = new ArrayList<ArrayList<StatementSource>>();
						// we discover the maximum size of set
						int max=0;
						for(int i =0 ; i < ssTmpL.size(); i++){
						 							
						  for(int j = 0; j< ssTmpL.get(i).size(); j++){
							if(max < ssTmpL.get(i).size()){
								max= ssTmpL.get(i).size();
							}		
						  }

					        }
						//System.out.println("max : "+max);
						// we using loops to create set with one of each previous sets
						 for (int i = 0; i< max ; i++){
								ArrayList<StatementSource> sttsTmp= new ArrayList<StatementSource>();
		
								for (int j =0; j<ssTmpL.size(); j++){
									
									if(ssTmpL.get(j).size()>=i){
										sttsTmp.add(ssTmpL.get(j).get(i));	
								 	}else{
									
										sttsTmp.add(ssTmpL.get(j).get(0));
									}
								}	
						  
                                                      lsttsTmp.add(sttsTmp);      	
                                                  }

                                               // we create statement pattern for each set
						for(ArrayList<StatementSource> stmtsA : lsttsTmp){
							FedraStatementSourcePattern fdtmp = new FedraStatementSourcePattern(((FedraStatementSourcePattern)stmt).getNode(),
                                                                                                                        ((FedraStatementSourcePattern)stmt).getQueryInfo(),
                                                                                                                         ((FedraStatementSourcePattern)stmt).getCandidateSources());
							for(StatementSource ss: stmtsA){
							 
							fdtmp.addStatementSource(ss);	
							
							}
							 lfedrasrc.add(fdtmp);	

						}
						

						for(FedraStatementSourcePattern fdst: lfedrasrc){
						//	System.out.println(fdst.toString());
							taskCreators.add(new BoundJoinTaskCreator(this, strategy, fdst));
						}
					// NE PAS OUBLIER LES AUTRES
					}else{ 
				//	System.out.println(stmt.getStatementSources());
					taskCreators.add(new BoundJoinTaskCreator(this, strategy, stmt));

					}	
				
				} else {
					//System.out.println("no free vars for bindings");
					expr = new CheckStatementPattern(stmt);
					taskCreators.add(new CheckJoinTaskCreator(this, strategy, (CheckStatementPattern)expr));
				}
			} else if (expr instanceof FedXService) { 
				taskCreators.add(new FedXServiceJoinTaskCreator(this, strategy, (FedXService)expr));
			} else if (expr instanceof IndependentJoinGroup) {
				taskCreators.add(new IndependentJoinGroupTaskCreator(this, strategy, (IndependentJoinGroup)expr));
			} else {
				throw new RuntimeException("Expr is of unexpected type: " + expr.getClass().getCanonicalName() + ". Please report this problem.");
			}
			//System.out.println(b.size());
			//System.out.println(expr.getStatementSources());
		
                        scheduler.schedule( new ParallelJoinTask(this, strategy,expr, b));
			                                                                              

			
		}
		
		int nBindings;	
		int indexTask =0;

		List<BindingSet> bindings = null;
		while (!closed && leftIter.hasNext()) {
			
			
			/*
			 * XXX idea:
			 * 
			 * make nBindings dependent on the number of intermediate results of the left argument.
			 * 
			 * If many intermediate results, increase the number of: bindings. This will result in less
			 * remote SPARQL requests.
			 * 
			 */
			
			if (totalBindings>10)
				nBindings = nBindingsCfg;
			else
				nBindings = 3;

			bindings = new ArrayList<BindingSet>(nBindings);
			
			int count=0;
			while (count < nBindings && leftIter.hasNext()) {
				bindings.add(leftIter.next());
				count++;
			}
			
			totalBindings += count;
		//	System.out.println("total bindings"+ totalBindings);

		//for(BindingSet bs:bindings){
		//		if(bs.getBindingNames().contains("gType"))
		//		System.out.println("bindings name :"+bs.getBindingNames());
		//}	
			
			//System.out.println("binding size :  "+bindings.size());		
			//System.out.println(" binding set size: "+bindings.get(0).size());
			
			// bouclier sur la liste de liste de taskCreators 	
			scheduler.schedule(taskCreators.get(indexTask).getTask(bindings));
			indexTask=(indexTask+1)%taskCreators.size();
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
