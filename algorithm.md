Algorithme Parallel Bound Join
=========
```go
function parallelBoundJoin(left : set of bindings, right_t : triple pattern, sources : set of set of endpoints ) : set of bindings {
  results := empty set of bindings

  for endpoints in sources // for each group of relevants endpoints
    groups := partition(endpoints, left_t) // create equal group of bindings + endpoint
    for endpoint, subset in groups do
      launch a process in parallel {
        datas := fetch datas in endpoint with join condition
        results := results U datas
      }
    end for
  end for
  
  wait for all process to finish
  
  return results
}
```

```go
function partition(sources : set of endpoints, bindings : set of bindings) : set of pair (endpoint, set of bindings) {
  results := empty set of pair (endpoint, set of bindings)
  subset := empty set of bindings
  subset_size := count(bindings) / count(sources) // rounded up
  current_source := 0
  
  // create the pairs (endpoint, set of binding)
  for i:= 0; i < count(bindings); i++ {
    put(subset, bindings[i])
    if count(subset) == subset_size {
      pair := pair of (sources[current_source], subset)
      put(results, pair)
      current_source++
      subset := empty set of bindings
    }
  }
  
  // add the last pair to the result set
  if count(subset) > 0 {
    pair := pair of (sources[current_source], subset)
    put(results, pair)
  }
  
  return results
}
```
