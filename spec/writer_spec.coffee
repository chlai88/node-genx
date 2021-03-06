genx = require '../build/default/genx'

describe 'genx', ->

  beforeEach ->
    this.addMatchers
      toBeInstanceOf: (expected) ->
        this.actual instanceof expected

  describe 'Writer', ->
    w = null

    beforeEach ->
      w = new genx.Writer()

    describe 'declareNamespace', ->
      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.declareNamespace()).toThrow('Wrong number of arguments to declareNamespace')
        expect(-> w.declareNamespace(true, true, true)).toThrow('Wrong number of arguments to declareNamespace')

      describe 'with a prefix', ->

        it 'raises an exception if the uri is not a string', ->
          expect(-> w.declareNamespace(1, 2)).toThrow('First argument to declareNamespace must be a string')

        it 'raises an exception if the prefix is not a string', ->
          expect(-> w.declareNamespace('http://example.com/', 1)).toThrow('Second argument to declareNamespace must be a string')

        it 'raises an exception if the prefix is not valid', ->
          expect(-> w.declareNamespace('http://example.com/', 'invalid/prefix')).toThrow('Bad NAME')

        it "returns a Namespace object", ->
          expect(w.declareNamespace 'http://example.com/', 'test').toBeDefined()

      describe 'without a prefix', ->

        it "returns a Namespace object", ->
          expect(w.declareNamespace 'http://example.com/').toBeDefined()

    describe 'declareElement', ->
      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.declareElement()).toThrow('Wrong number of arguments to declareElement')
        expect(-> w.declareElement(true, true, true)).toThrow('Wrong number of arguments to declareElement')

      it 'raises an exception if the element name is invalid', ->
        w.startDocument()
        expect(-> w.declareElement('test>')).toThrow('Bad NAME')

      describe 'without a namespace', ->

        it 'raises an exception if it isn\'t a string', ->
          expect(-> w.declareElement(1)).toThrow('First argument must be a string')

        # FIXME: this doesn't really test as per the description
        it 'returns an Element object', ->
          expect(w.declareElement 'test').toBeDefined()

      describe 'with a namespace', ->
        ns = null

        beforeEach ->
          ns = w.declareNamespace('test')

        it 'returns an Element object', ->
          expect(w.declareElement ns, 'test').toBeDefined()

    describe 'declareAttribute', ->
      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.declareAttribute()).toThrow('Wrong number of arguments to declareAttribute')
        expect(-> w.declareAttribute(true, true, true)).toThrow('Wrong number of arguments to declareAttribute')

      it 'raises an exception if the attribute name is invalid', ->
        expect(-> w.declareElement('test=')).toThrow('Bad NAME')

      describe 'without a namespace', ->

        it 'raises an exception if it isn\'t a string', ->
          expect(-> w.declareAttribute(1)).toThrow('First argument must be a string')

        # FIXME: this doesn't really test as per the description
        it 'returns an Attribute object', ->
          expect(w.declareAttribute 'test').toBeDefined()

      describe 'with a namespace', ->
        ns = null

        beforeEach ->
          ns = w.declareNamespace('test')

        it 'returns an Attribute object', ->
          expect(w.declareAttribute ns, 'attr').toBeDefined()

    describe 'startElementLiteral', ->

      beforeEach -> w.startDocument()

      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.startElementLiteral()).toThrow('Wrong number of arguments to startElementLiteral')
        expect(-> w.startElementLiteral(true, true, true)).toThrow('Wrong number of arguments to startElementLiteral')

      it 'raises an exception if the element name is invalid', ->
        expect(-> w.startElementLiteral('test>')).toThrow('Bad NAME')

    describe 'addAttributeLiteral', ->

      beforeEach -> w.startDocument().startElementLiteral('test')

      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.addAttributeLiteral()).toThrow('Two string arguments must be supplied to addAttributeLiteral')
        expect(-> w.addAttributeLiteral(true, true, true)).toThrow('Two string arguments must be supplied to addAttributeLiteral')

      it 'raises an exception if the attribute name is invalid', ->
        expect(-> w.addAttributeLiteral('test=', 'value')).toThrow('Bad NAME')

    describe 'startElement', ->
      elem = null

      beforeEach ->
        elem = w.declareElement 'test'

      it 'raises an exception if there is the wrong number of arguments', ->
        w.startDocument()
        expect(-> w.startElement()).toThrow('Not enough arguments to startElement')

      it 'raises an exception if the first argument is not an Element', ->
        w.startDocument()
        expect(-> w.startElement('elem')).toThrow('Argument to startElement must be an Element')

      it 'handles errors (by raising them) from genx', ->
        expect(-> w.startElement(elem)).toThrow('Call out of sequence')

    describe 'addAttribute', ->
      attr = null

      beforeEach ->
        attr = w.declareAttribute 'attr'
        w.startDocument()

      it 'raises an exception if there is the wrong number of arguments', ->
        w.startElementLiteral 'test'
        expect(-> w.addAttribute()).toThrow('Wrong number of arguments to addAttribute')
        expect(-> w.addAttribute(attr)).toThrow('Wrong number of arguments to addAttribute')

      it 'raises an exception if the first argument is not an Attribute', ->
        expect(-> w.addAttribute(true, 'value')).toThrow('First argument to addAttribute must be an Attribute')

      it 'raises an exception if the second argument is not a string', ->
        expect(-> w.addAttribute(attr, true)).toThrow('Second argument to addAttribute must be a string')

      it 'raises a sequence error if called in the wrong sequence', ->
        w.startElementLiteral('test').addText('text')
        expect(-> w.addAttribute(attr, 'value')).toThrow('Call out of sequence')

    describe 'addText', ->

      beforeEach -> w.startDocument().startElementLiteral('test')

      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.addText()).toThrow('Not enough arguments to addText')

      it 'raises an exception if the argument is not a string', ->
        expect(-> w.addText(true)).toThrow('Argument to addText must be a string')

    describe 'addComment', ->

      beforeEach -> w.startDocument()

      it 'raises an exception if there is the wrong number of arguments', ->
        expect(-> w.addComment()).toThrow('Not enough arguments to addComment')

      it 'raises an exception if the argument is not a string', ->
        expect(-> w.addComment(true)).toThrow('Argument to addComment must be a string')

    describe 'generating a document', ->

      describe 'using literal nodes', ->

        it 'generates the correct XML', ->
          result = ''
          w.on 'data', (data) -> result += data

          w.startDocument()
            .addComment(' Testing ')
            .startElementLiteral('http://www.w3.org/2005/Atom', 'feed')
              .startElementLiteral('title')
                .addAttributeLiteral('type', 'text')
                .addText('Testing')
              .endElement()
            .endElement()
          .endDocument()

          expect(result).toEqual(
            """<!-- Testing -->
               <g1:feed xmlns:g1="http://www.w3.org/2005/Atom"><title type="text">Testing</title></g1:feed>"""
          )

      describe 'using pre-declared nodes', ->

        it 'generates the correct XML', ->
          result = ''
          w.on 'data', (data) -> result += data

          ns = w.declareNamespace('http://www.w3.org/2005/Atom', '')
          feed = w.declareElement(ns, 'feed')
          title = w.declareElement(ns, 'title')
          type = w.declareAttribute('type')

          w.startDocument()
            .startElement(feed)
              .startElement(title)
                .addAttribute(type, 'text')
                .addText('Testing')
              .endElement()
            .endElement()
          .endDocument()

          expect(result).toEqual(
            """<feed xmlns="http://www.w3.org/2005/Atom"><title type="text">Testing</title></feed>"""
          )


      describe 'using a mix of literal and declared nodes', ->

        it 'generates the correct XML', ->
          result = ''
          w.on 'data', (data) -> result += data

          uri = 'http://www.w3.org/2005/Atom'
          ns = w.declareNamespace(uri, '')
          feed = w.declareElement(ns, 'feed')
          type = w.declareAttribute('type')

          w.startDocument()
            .startElement(feed)
              .startElementLiteral(uri, 'title')
                .addAttribute(type, 'text')
                .addText('Testing')
              .endElement()
            .endElement()
          .endDocument()

          expect(result).toEqual(
            """<feed xmlns="http://www.w3.org/2005/Atom"><title type="text">Testing</title></feed>"""
          )

    it 'can generate multiple documents', ->
      result = ''
      w.on 'data', (data) -> result += data

      w.startDocument()
        .startElementLiteral('doc1')
        .endElement()
      .endDocument()

      result += "\n"

      w.startDocument()
        .startElementLiteral('doc2')
        .endElement()
      .endDocument()

      expect(result).toEqual(
        "<doc1></doc1>\n<doc2></doc2>"
      )
