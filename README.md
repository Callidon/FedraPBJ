# Parallel Bound Join - Parallelizing Federated SPARQL query using Replicated Fragments

Implementation of the Parallel Bound Join Algorithm in Fedra + FedX.

# Motivation

Federated query engines allow to consume linked data from SPARQL endpoints. Replication of data fragments allow consumers to re-organize data to better fit their needs. However, current federated SPARQl query engines poorly support replication. Source selection techniques are offered to solve part of these problems, but no use of replication is done to increase the parallelization of queries.

We propose an algorithm to take advantage of the replicated fragments in order to parallelize the execution of the Bound Join operator offered by [FedX](https://www.fluidops.com/downloads/documents/pubeswc2011fedx.pdf), using the source selection technique offered by [Fedra](https://hal.inria.fr/hal-01169601/document).

# Requirements
You must have installed the FedX query engine with [Fedra](https://github.com/gmontoya/fedra). Please follow the [instructions](https://github.com/gmontoya/fedra#requirements) for installing FedX + Fedra before installing this algorithm.

# Installation

* Clone the repository or [download it](https://github.com/Callidon/FedraPBJ)
```bash
git clone https://github.com/Callidon/FedraPBJ.git
```

* Navigate into the project folder and execute the installation script. It takes in parameter the location of FedX's directory
```bash
cd FedraPBJ/
./install.sh <path-to-FedX-directory>
```

* Compile FedX & use it as usual

# References
* Montoya, Gabriela and Skaf-Molli, Hala and Molli, Pascal and Vidal, Maria-Esther, [Federated SPARQL Queries Processing with Replicated Fragments](https://hal.inria.fr/hal-01169601/document). In International Semantic Web Conference Oct. 2015
* Schwarte, Andreas and Haase, Peter and Hose, Katja and Schenkel, Ralf and Schmidt, Michael, [FedX: Optimization Techniques for Federated Query Processing on Linked Data](http://www2.informatik.uni-freiburg.de/~mschmidt/docs/iswc11_fedx.pdf). In International Semantic Web Conference Oct. 2011
* G. Aluç, M. T. Ozsu, K. Daudjee and O. Hartig, [chameleon-db: a Workload-Aware robust rdf data management system](https://cs.uwaterloo.ca/~galuc/papers/chameleon-db-research.pdf). University of Waterloo, Tech. Rep. CS-2013-10. 2013
