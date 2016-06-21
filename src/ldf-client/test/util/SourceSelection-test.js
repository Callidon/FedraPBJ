/*! Author : Thomas Minier */
var SourceSelection = require('../../lib/util/SourceSelection');
var config = {
    'replicates' : {
        'http://localhost:3030/watDiv' : [
            'f1'
        ],
        'http://localhost:3031/watDiv' : [
            'f2'
        ]
    }
};

describe('SourceSelection', function() {

    it('should not alter a selection with one fragment', function() {
        var fragments = [
            'http://localhost:3030/watDiv'
        ];
        SourceSelection(fragments, config).should.be.eql(fragments);
    });

    it('should remove duplicates in a selection', function() {
        var fragments = [
            'http://localhost:3030/watDiv',
            'http://localhost:3030/watDiv',
            'http://localhost:3031/watDiv'
        ];
        SourceSelection(fragments, config).should.be.eql(['http://localhost:3030/watDiv', 'http://localhost:3031/watDiv']);
    });

    it('should produce the minimal result when facing a simple set covering problem', function() {
        var other_config = {
            'replicates' : {
                'http://localhost:3030/watDiv' : [
                    'f1',
                    'f2'
                ],
                'http://localhost:3031/watDiv' : [
                    'f1'
                ]
            }
        };
        var fragments = [
            'http://localhost:3030/watDiv',
            'http://localhost:3030/watDiv',
            'http://localhost:3031/watDiv'
        ];
        SourceSelection(fragments, other_config).should.be.eql(['http://localhost:3030/watDiv']);
    });

    it('should produce the minimal result when facing a more complex set covering problem', function() {
        var other_config = {
            'replicates' : {
                'http://localhost:3030/watDiv' : [
                    'f1',
                    'f2'
                ],
                'http://localhost:3031/watDiv' : [
                    'f3',
                    'f4'
                ],
                'http://localhost:3032/watDiv' : [
                    'f4',
                    'f5'
                ],
                'http://localhost:3033/watDiv' : [
                    'f1',
                    'f2',
                    'f3'
                ]
            }
        };
        var fragments = [
            'http://localhost:3030/watDiv',
            'http://localhost:3031/watDiv',
            'http://localhost:3032/watDiv',
            'http://localhost:3033/watDiv'
        ];
        SourceSelection(fragments, other_config).should.be.eql(['http://localhost:3033/watDiv', 'http://localhost:3032/watDiv']);
    });
});
