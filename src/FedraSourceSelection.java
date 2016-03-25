package com.fluidops.fedx.optimizer;

import java.util.*;
import java.io.*;

//import org.openrdf.query.Query;
import org.openrdf.query.parser.sparql.SPARQLParserFactory;
import org.openrdf.query.parser.QueryParser;
import org.openrdf.query.parser.ParsedQuery;
import org.openrdf.query.algebra.TupleExpr;
import org.openrdf.query.algebra.StatementPattern;
import com.fluidops.fedx.structures.Endpoint;
import com.fluidops.fedx.Config;
import org.openrdf.query.algebra.helpers.StatementPatternCollector;
/*
import com.hp.hpl.jena.graph.Triple;
import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.sparql.core.BasicPattern;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.sparql.algebra.*;
import com.hp.hpl.jena.sparql.algebra.op.*;
import com.hp.hpl.jena.sparql.syntax.*;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.sparql.engine.http.QueryEngineHTTP;
import com.hp.hpl.jena.sparql.expr.ExprList;

import com.hp.hpl.jena.util.FileManager;
import com.hp.hpl.jena.util.Locator;*/

// javac -cp ".:/Users/montoya-g/Downloads/apache-jena-2.11.0/lib/*" fedra.java
// java -cp ".:/Users/montoya-g/Downloads/apache-jena-2.11.0/lib/*" fedra testing/three/query1.sparql testing/three/endpointDescription testing/three/publicEndpoints testing/three/containedIn testing/three/origin /Users/montoya-g/Dropbox/presentations/federatedExecution/testing/three/viewsDefinition/
class FedraSourceSelection {

    private TupleExpr query;
    private List<StatementPattern> stmts;
    private HashMap<String,Endpoint> endpoints;
    private HashMap<StatementPattern, Set<Endpoint>> selectedSources;
    private ArrayList<ArrayList<StatementPattern>> bgps;
    private TreeMap<String, TriplePatternFragment> fragments;
    private boolean random;

    private HashMap<StatementPattern, Set<Set<Endpoint>>> allSelectedSources;

    public FedraSourceSelection(String queryStr, List<StatementPattern> stmts, List<Endpoint> endpoints) {
        QueryParser qp = (new SPARQLParserFactory()).getParser();
        String baseURI = null;
        try {
            ParsedQuery pq = qp.parseQuery(queryStr, baseURI);
            this.query = pq.getTupleExpr();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
        this.stmts = stmts;
        this.endpoints = new HashMap<String,Endpoint>();
        for (Endpoint e : endpoints) {
            this.endpoints.put(e.getEndpoint(), e);
        }
        //System.out.println("endpoints: "+endpoints);
        this.selectedSources = new HashMap<StatementPattern, Set<Endpoint>>();
        this.allSelectedSources = new HashMap<>(); // modified
        this.bgps = getBGPs(query);
        loadFragments(Config.getConfig().getProperty("FragmentsDefinitionFolder"), Config.getConfig().getProperty("FragmentsSources"));
        loadEndpoints(Config.getConfig().getProperty("EndpointsFile"));
        this.random = Boolean.parseBoolean(Config.getConfig().getProperty("Random"));
        //System.out.println("endpoints: "+endpoints);
        //System.out.println("fragments: "+fragments);
        //System.out.println("endpoints: "+endpoints);
    }

    private static ArrayList<ArrayList<StatementPattern>> getBGPs(TupleExpr query) {

        ArrayList<ArrayList<StatementPattern>> bgps = null;
        try {
            BGPVisitor bgpv = new BGPVisitor();
            query.visit(bgpv);
            bgps =  bgpv.getBGPs();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
        return bgps;
    }

    public HashMap<StatementPattern, Set<Endpoint>> getSelectedSources() {

        return this.selectedSources;
    }

    public HashMap<StatementPattern, Set<Set<Endpoint>>> getAllSelectedSources() {
        return allSelectedSources;
    }

    private HashSet<TreeSet<Endpoint>> getEndpoints(HashSet<List<TriplePatternFragment>> selectedFragments) {

        //System.out.println("selected fragments: "+selectedFragments);
        //System.out.println("endpoints: "+this.endpoints);
        HashSet<TreeSet<Endpoint>> fs = new HashSet<TreeSet<Endpoint>>();
        for (List<TriplePatternFragment> fragmentList : selectedFragments) {
                TreeSet<Endpoint> f = new TreeSet<Endpoint>(new EndpointComparator());
                for (TriplePatternFragment fragment : fragmentList) {
                    List<String> l = fragment.getAllSources();
                    for (String en : l) {
                        if (this.endpoints.containsKey(en)) {
                            f.add(this.endpoints.get(en));
                        }
                    }
                }
                fs.add(f);
        }
        //System.out.println("selected endpoints: "+fs);
	return fs;
    }

    public HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> sourceSelectionPerTriple() {

        HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidates = new HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>>();
        for (StatementPattern sp : this.stmts) {
            HashSet<List<TriplePatternFragment>> selectedFragments = new HashSet<List<TriplePatternFragment>>();
            //System.out.println("considering sp: "+sp);
            for (String fn : this.fragments.keySet()) {
                TriplePatternFragment f = this.fragments.get(fn);
                if (f.canAnswer(sp)) {
                    HashSet<List<TriplePatternFragment>> redundantFragments = new HashSet<List<TriplePatternFragment>>();
                    boolean toAdd = true;
                    List<List<TriplePatternFragment>> includeWith = new ArrayList<List<TriplePatternFragment>>();
                    //System.out.println("trying to add: "+fn+" from dataset: "+f.getDataset());
                    //System.out.println("is f an exact match of sp? "+f.exactMatch(sp));
                    //System.out.println("so far there are "+selectedFragments.size()+ " fragments");
                    for (List<TriplePatternFragment> l :  selectedFragments) {
                        TriplePatternFragment f2 = l.get(0);
                        //System.out.println("checking already added fragment: "+f2.triple+" from dataset: "+f2.getDataset()+" in fragment list: "+l);
                        //System.out.println("is f2 an exact match of sp? "+f2.exactMatch(sp));
                        //System.out.println("f.getDataset().equals(f2.getDataset()): "+f.getDataset().equals(f2.getDataset()));
                        //System.out.println("f.containedBy(f2): "+f.containedBy(f2));
                        //System.out.println("f.contains(f2): "+f.contains(f2));
                        //System.out.println("f.contains(sp): "+f.contains(sp));
                        //System.out.println("f2.contains(sp): "+f2.contains(sp));
                        if (f.contains(sp) && f2.contains(sp) && (f.contains(f2) || f.containedBy(f2))) {
                            includeWith.add(l);
                            toAdd = false;
                        } else if (f.containedBy(f2)) {
                            toAdd = false;
                            break;
                        } else if (f.contains(f2)) {
                            redundantFragments.add(l);
                        }
                    }
                    //System.out.println("removing "+redundantFragments.size()+" fragments");
                    for (List<TriplePatternFragment> l : redundantFragments) {
                        selectedFragments.remove(l);
                    }
                    for (List<TriplePatternFragment> fl : includeWith) {
                        if (!fl.contains(f)) {
                            selectedFragments.remove(fl);
                            fl.add(f);
                            selectedFragments.add(fl);
                        }
                    }
                    if (toAdd) {
                        ArrayList<TriplePatternFragment> l = new ArrayList<TriplePatternFragment>();
                        l.add(f);
                        selectedFragments.add(l);
                    }
                }
            }
            //System.out.println("selected fragments: "+selectedFragments);
            HashSet<TreeSet<Endpoint>> endpoints = getEndpoints(selectedFragments);
            candidates.put(sp, endpoints);
        }
        return candidates;
    }

    private static void obtainInstance(HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidateSources,
                                       TreeSet<Pair<StatementPattern, Integer>> elements,
                                       TreeMap<Endpoint, TreeSet<Pair<StatementPattern, Integer>>> collections) {
        // Obtaining the instance of the minimal set covering problem
        for (StatementPattern sp : candidateSources.keySet()) {
            HashSet<TreeSet<Endpoint>> fs = candidateSources.get(sp);
            int i = 0;
            for (TreeSet<Endpoint> f : fs) {
                Pair<StatementPattern, Integer> p = new Pair<StatementPattern, Integer>(sp, i);
                elements.add(p);
                for (Endpoint e : f) {
                    TreeSet<Pair<StatementPattern, Integer>> sps = collections.get(e);
                    if (sps == null) {
                        sps = new TreeSet<Pair<StatementPattern, Integer>>(new PairComparator());
                    }
                    sps.add(p);
                    collections.put(e, sps);
                }
                i++;
            }
        }
    }

    private static TreeSet<Endpoint> getMinimalSetCovering(TreeSet<Pair<StatementPattern, Integer>> elements,
                                       TreeMap<Endpoint, TreeSet<Pair<StatementPattern, Integer>>> collections, boolean random) {
        TreeSet<Pair<StatementPattern, Integer>> elementsToCover = new TreeSet<Pair<StatementPattern, Integer>> (new PairComparator());
        elementsToCover.addAll(elements);
        TreeSet<Endpoint> selected = new TreeSet<Endpoint>(new EndpointComparator());
        //System.out.println("elements: "+elements);
        while(elementsToCover.size() > 0) {
            TreeSet<Endpoint> c = new TreeSet<Endpoint>(new EndpointComparator());
            //System.out.println("collections: "+collections);
            for (Endpoint k : collections.keySet()) {
                if (c.size() == 0) {
                    c.add(k);
                } else {
                    TreeSet<Pair<StatementPattern, Integer>> tmp1 = new TreeSet<Pair<StatementPattern, Integer>>(elementsToCover);
                    tmp1.retainAll(collections.get(c.first()));
                    TreeSet<Pair<StatementPattern, Integer>> tmp2 = new TreeSet<Pair<StatementPattern, Integer>>(elementsToCover);
                    tmp2.retainAll(collections.get(k));
                    if (tmp1.size() < tmp2.size()) {
                        c.clear();
                        c.add(k);
                    } else if (tmp1.size() == tmp2.size()) {
                        c.add(k);
                    }
                }
            }
            Iterator<Endpoint> it = c.iterator();
            Endpoint e = it.next();
            if (random) {
                int elm = (int) (Math.random()*c.size());
                for (int i = 0; i < elm && it.hasNext(); i++) {
                    e = it.next();
                }
            }
            elementsToCover.removeAll(collections.get(e));
            selected.add(e);
            collections.remove(e);
        }
        return selected;
    }

    private static HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> select(HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidateSources, TreeSet<Endpoint> selected) {

        HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> ss = new HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>>();
        for (StatementPattern sp : candidateSources.keySet()) {
            HashSet<TreeSet<Endpoint>> fs = candidateSources.get(sp);
            //System.out.println("selected sources for "+sp+" are: "+fs);
            HashSet<TreeSet<Endpoint>> es = new HashSet<TreeSet<Endpoint>>();
            for (TreeSet<Endpoint> f : fs) {
                f.retainAll(selected);
                es.add(f);
            }
            ss.put(sp, es);
        }
        return ss;
    }

    private static HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> filter(HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidateSources, ArrayList<StatementPattern> bgp) {
        HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> result = new HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> ();
        for (StatementPattern sp : candidateSources.keySet()) {
            if (bgp.contains(sp)) {
                 result.put(sp, candidateSources.get(sp));
            }
        }
        return result;
    }

    private static void update(HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidateSources, HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> selected) {

        for (StatementPattern sp : candidateSources.keySet()) {
            // end modified
            if (selected.containsKey(sp)) {
                candidateSources.put(sp, selected.get(sp));
            }
        }
    }

    public void performSourceSelection() {

        HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> candidateSources = sourceSelectionPerTriple();
        //System.out.println("candidate sources: "+candidateSources);

		// Fedra-PBJ : Approach without the cover set
		// Take all the candidate sources before the cover set
		for(Map.Entry<StatementPattern, HashSet<TreeSet<Endpoint>>> key : candidateSources.entrySet()) {
			Set<Set<Endpoint>> new_sources = new HashSet<>();
			for(Set<Endpoint> set : key.getValue()) {
				Set<Endpoint> cloned_set = new TreeSet<Endpoint>(new EndpointComparator());
				cloned_set.addAll(set);
				new_sources.add(cloned_set);
			}
			allSelectedSources.put(key.getKey(), new_sources);
		}

        // Priority is given to evaluate triple patterns that belong to the same basic graph pattern in as less endpoints as possible
        for (ArrayList<StatementPattern> bgp : bgps) {
            ArrayList<StatementPattern> bgp2 = new ArrayList<StatementPattern>();
            for (StatementPattern sp : bgp) {
                if (candidateSources.get(sp).size()>1) {
                    HashSet<TreeSet<Endpoint>> fragments = candidateSources.get(sp);
                    Iterator<TreeSet<Endpoint>> it = fragments.iterator();
                    TreeSet<Endpoint> intersection = new TreeSet<Endpoint>(it.next());
                    while (it.hasNext()) {
                        TreeSet<Endpoint> f = it.next();
                        intersection.retainAll(f);
                    }
                    if (intersection.size() > 0) {
                        fragments.clear();
                        fragments.add(intersection);
                        candidateSources.put(sp, fragments);
                    }
                }
            }
            for (StatementPattern sp : bgp) {
                if (candidateSources.get(sp).size()==1) {
                    bgp2.add(sp);
                }
            }
            HashMap<StatementPattern, HashSet<TreeSet<Endpoint>>> bgpCandidateSources = filter(candidateSources, bgp2);
            TreeSet<Pair<StatementPattern, Integer>> elements = new TreeSet<Pair<StatementPattern, Integer>>(new PairComparator());
            TreeMap<Endpoint, TreeSet<Pair<StatementPattern, Integer>>> collections = new TreeMap<Endpoint, TreeSet<Pair<StatementPattern, Integer>>>(new EndpointComparator());
            obtainInstance(bgpCandidateSources, elements, collections);
            TreeSet<Endpoint> selectedSubsets = getMinimalSetCovering(elements, collections, this.random);
            bgpCandidateSources = select(bgpCandidateSources, selectedSubsets);
            update(candidateSources, bgpCandidateSources);
        }
        //System.out.println("candidate sourcesB: "+candidateSources);

        // Then a global choice is done for all the triple patterns, selecting as few endpoints as possible.
//        TreeSet<Pair<StatementPattern, Integer>> elements = new TreeSet<Pair<StatementPattern, Integer>>(new PairComparator());
//        TreeMap<Endpoint, TreeSet<Pair<StatementPattern, Integer>>> collections = new TreeMap<Endpoint, TreeSet<Pair<StatementPattern, Integer>>>(new EndpointComparator());
//        obtainInstance(candidateSources, elements, collections);
//        TreeSet<Endpoint> selectedSubsets = getMinimalSetCovering(elements, collections, this.random);
//        candidateSources = select(candidateSources, selectedSubsets);
        //System.out.println("candidate sourcesC: "+candidateSources);

        // The remaining choices are done randomly to select one source for each different data fragment
        selectedSources.clear();
        for (StatementPattern sp : candidateSources.keySet()) {
            HashSet<TreeSet<Endpoint>> fs = candidateSources.get(sp);

			// Take the set here for the approach without the cover set

            //System.out.println("selected sources for "+sp+" are: "+fs);
            TreeSet<Endpoint> es = new TreeSet<Endpoint>(new EndpointComparator());
            for (TreeSet<Endpoint> f : fs) {
                Iterator<Endpoint> it = f.iterator();
                Endpoint e = it.next();
                if (this.random) {
                    int elm = (int) (Math.random()*f.size());
                    for (int i = 0; i < elm && it.hasNext(); i++) {
                        e = it.next();
                    }
                }
                es.add(e);
            }
            selectedSources.put(sp, es);
        }
        //System.out.println("selected sources: "+selectedSources);
    }

    public void loadEndpoints (String file) {

        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String l = br.readLine();
            while (l!=null) {
                StringTokenizer st = new StringTokenizer(l);
                if (st.hasMoreTokens()) {
                    String fragment = st.nextToken();
                    //endpoints.add(endpoint);
                    TriplePatternFragment f = this.fragments.get(fragment);
                    while (st.hasMoreTokens()) {
                        String endpoint = st.nextToken();
                        f.addSource(endpoint);
                    }
                    // this.fragments.put(fragment, f);
                }
                l = br.readLine();
            }
            br.close();

        } catch (IOException e) {
            System.err.println("Problems reading file: "+file);
            System.exit(1);
        }
    }

    public static HashMap<String, String> loadSources (String file) {
        HashMap map = new HashMap<String, String>();
        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String l = br.readLine();
            while (l!=null) {
                StringTokenizer st = new StringTokenizer(l);
                if (st.hasMoreTokens()) {
                    String fragment = st.nextToken();
                    String source =  st.nextToken();
                    map.put(fragment, source);
                }
                l = br.readLine();
            }
            br.close();

        } catch (IOException e) {
            System.err.println("Problems reading file: "+file);
            System.exit(1);
        }
        return map;
    }


    private static String getQuery(String file) {

        String query = "";
        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String l = br.readLine();
            while (l!=null) {
                query = query + l + "\n";
                l = br.readLine();
            }
            br.close();
        } catch (IOException e) {
            System.err.println("Problems reading file: "+file);
            System.exit(1);
        }
        return query;
    }

    private StatementPattern getStatementPattern(TupleExpr te) {

        List<StatementPattern> stmts = StatementPatternCollector.process(te);
        StatementPattern sp = stmts.get(0);
        return sp;
    }

    public void loadFragments(String folder, String file) {

        HashMap<String, String> sources = loadSources(file);
        File f = new File(folder);
        File[] content = f.listFiles();
        this.fragments = new TreeMap<String, TriplePatternFragment>();
        //System.out.println("folder: "+folder);
        QueryParser qp = (new SPARQLParserFactory()).getParser();
        if (content != null) {
            for (File g : content) {
                try {
                    String path = g.getAbsolutePath();
                    //System.out.println("path: "+path);
                    String query = getQuery(path);
                    String baseURI = null;
                    ParsedQuery pq = qp.parseQuery(query, baseURI);
                    TupleExpr te = pq.getTupleExpr();
                    StatementPattern sp = getStatementPattern(te);
                    int i = path.lastIndexOf("/") + 1;
                    int j = path.lastIndexOf(".");
                    j = j < 0 ? path.length() : j;
                    String name = path.substring(i, j);
                    this.fragments.put(name, new TriplePatternFragment(sp, sources.get(name)));
                }  catch (Exception e) {
                    e.printStackTrace();
                    System.exit(1);
                }
            }
        }
    }
}
