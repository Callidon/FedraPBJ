
class TriplePattern:
    '''
        A SPARQL triple pattern
        author : Thomas Minier
    '''

    def __init__(self, subject, predicate, obj):
        self.subject = subject
        self.predicate = predicate
        self.object = obj

    def __eq__(self, other):
        if self.subject.placeholder or other.subject.placeholder:
            return (self.predicate == other.predicate) and (self.object == other.object)
        elif self.predicate.placeholder or other.predicate.placeholder:
            return (self.subject == other.subject) and (self.object == other.object)
        elif self.object.placeholder or other.object.placeholder:
            return (self.subject == other.subject) and (self.predicate == other.predicate)
        else:
            return (self.subject == other.subject) and (self.predicate == other.predicate) and (self.object == other.object)

    def __repr__(self):
        return '<Triple pattern : {} {} {}>'.format(self.subject, self.predicate, self.object)
