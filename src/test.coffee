import '../node_modules/mocha/mocha.js'
import '../node_modules/mocha/mocha.css'
import test from '../test/viewer.coffee'

# import Geometry from './src/geometry.coffee'
# window.Geometry = Geometry

mocha.setup('bdd')

# import geometry from '../test/geometry.coffee'
test()

mocha.globals([])
mocha.checkLeaks()
mocha.run()
