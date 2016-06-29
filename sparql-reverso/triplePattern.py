from node import Node


class TriplePattern:
    """A SPARQL triple pattern
    author : Thomas Minier
    """

    def __init__(self, subject, predicate, obj):
        self.subject = subject
        self.predicate = predicate
        self.object = obj

    def __eq__(self, other):
        if type(self) != type(other):
            return False
        elif self.subject.isBlank or other.subject.isBlank:
            return (self.predicate == other.predicate) and (self.object == other.object)
        elif self.predicate.isBlank or other.predicate.isBlank:
            return (self.subject == other.subject) and (self.object == other.object)
        elif self.object.isBlank or other.object.isBlank:
            return (self.subject == other.subject) and (self.predicate == other.predicate)
        else:
            return (self.subject == other.subject) and (self.predicate == other.predicate) and (self.object == other.object)

    def __repr__(self):
        return '<Triple pattern : {} {} {}>'.format(self.subject, self.predicate, self.object)

    def __str__(self):
        return self.subject.uri + ' ' + self.predicate.uri + ' ' + self.object.uri

    def from_str(triple):
        """Create a triple pattern from its str representation
        """
        def nodeIsBlank(element):
            return (element == '%p') or (element.startswith('?'))

        elements = triple.strip().split(' ')
        # check if current triple pattern is well formed
        if (len(elements) < 3) or (len(elements) > 3):
            raise SyntaxError('The pattern {} is not well formed : '
                              'it must contains exactly three nodes.'
                              .format(triple.strip()))

        # seralize it
        subject = Node(elements[0], nodeIsBlank(elements[0]))
        predicate = Node(elements[1], nodeIsBlank(elements[1]))
        obj = Node(elements[2], nodeIsBlank(elements[2]))
        return TriplePattern(subject, predicate, obj)
