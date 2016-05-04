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
