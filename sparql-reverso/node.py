
class Node:
    """A node in a SPARQL query
    author : Thomas Minier
    """
    def __init__(self, uri, isBlank):
        self.uri = uri
        self.isBlank = isBlank

    def __eq__(self, other):
        if type(self) != type(other):
            return False
        else:
            return (self.isBlank or other.isBlank) or (self.uri == other.uri)

    def __repr__(self):
        return self.uri
