/*! Author : Thomas Minier */
/** Source selection module able to identifiy replicates in a fragment selection */
'use strict';
var _ = require('lodash');

// Perform a source selection using a greedy set covering heuristic
// Heuristic reference : https://en.wikipedia.org/wiki/Set_cover_problem#Greedy_algorithm
function SourceSelection(fragments, config) {
    var uncoveredElements = [];
    var selection = [];
    var allFragments = _.uniq(fragments);
    // get the elements we need to cover
    _.forEach(config.replicates, function(value, key) {
        if(allFragments.indexOf(key) > -1) {
            uncoveredElements = _.union(uncoveredElements, value);
        }
    });

    // At each stage, choose the set that contains the largest number of uncovered elements
    while(uncoveredElements.length > 0) {
        var maxKey = null,
            maxValue = -1;
        // count the number of uncovered elements by set and find the maximum
        _.forEach(allFragments, function(f) {
            var value = _.filter(config.replicates[f], function(elt) {
                return uncoveredElements.indexOf(elt) > -1;
            }).length;
            if(value > maxValue) {
                maxValue = value;
                maxKey = f;
            }
        });
        // add the selected set to the selection
        selection.push(maxKey);
        // update the collections by pulling out the values found
        _.pull(allFragments, maxKey);
        _.forEach(config.replicates[maxKey], function(elt) {
            _.pull(uncoveredElements, elt);
        });
    }
    return selection;
}

module.exports = SourceSelection;
