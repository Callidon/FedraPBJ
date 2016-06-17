/*! Author : Thomas Minier */
/** Source selection module able to identifiy replicvates in a fragment selection */
'use strict';
var _ = require('lodash');

// Perform a source selection
function SourceSelection(fragments, config) {
    var selection = fragments;

    // find the replicates of each fragment & remove them from the selection
    _.forEach(fragments, function(fragment) {
        var replicates = _.flatten(_.filter(config.replicates, function(r) {
            return r.indexOf(fragment) != -1;
        }));
        selection = _.difference(selection, replicates);
        selection.push(fragment);
    });
    return selection;
}

module.exports = SourceSelection;
