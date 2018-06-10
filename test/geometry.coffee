import Geometry from '../src/geometry.coffee'

export default ->
  describe 'Geometry', ->
    describe 'translation ', ->
      it 'returns 0 if there is no touches', ->
        expect(Geometry.translation([], []).length).to.equal(2)
        expect(Geometry.translation([], [])[0]).to.equal(0)
        expect(Geometry.translation([], [])[1]).to.equal(0)
      describe 'returns a translation', ->
        it 'with there one touches', ->
          t = Geometry.translation([[0, 0]], [[11, 12]])
          expect(t.length).to.equal(2)
          expect(t[0]).to.equal(11)
          expect(t[1]).to.equal(12)
        it 'with there two touches', ->
          t = Geometry.translation([[0, 0], [10, 10]], [[10, 10], [0, 0]])
          expect(t.length).to.equal(2)
          expect(t[0]).to.equal(0)
          expect(t[1]).to.equal(0)
        it 'with there two touches', ->
          t = Geometry.translation([[0, 0], [10, 10]], [[10, 10], [22, 24]])
          expect(t.length).to.equal(2)
          expect(t[0]).to.equal(11)
          expect(t[1]).to.equal(12)
    describe 'barycentre ', ->
      it 'return the point for a point', ->
        b = Geometry.barycentre([[5, 6]])
        expect(b.length).to.equal(2)
        expect(b[0]).to.equal(5)
        expect(b[1]).to.equal(6)
      it 'return the barycentre for two point', ->
        b = Geometry.barycentre([[0, 10], [5, 30]])
        expect(b.length).to.equal(2)
        expect(b[0]).to.equal(2.5)
        expect(b[1]).to.equal(20)
