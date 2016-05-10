
class Node:
    '''
        A node in a SPARQL query
        author : Thomas Minier
    '''
    def __init__(self, uri, placeholder):
        self.uri = uri
        self.placeholder = placeholder

    def __eq__(self, other):
        if self.placeholder and other.placeholder:
            return true
        else:
            return self.uri == other.uri

    def __repr__(self):
        return self.uri
