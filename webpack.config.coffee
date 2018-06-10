webpack = require('webpack')
ExtractTextPlugin = require("extract-text-webpack-plugin")
HtmlWebpackPlugin = require('html-webpack-plugin')
module.exports =
  entry:
    "index": "./src/index.coffee"
    "test": "./src/test.coffee"
    "mocha": "./node_modules/mocha/mocha.js"
    "index.min": "./src/index.coffee"
    "viewer": "./src/viewer.coffee"
    "viewer.min": "./src/viewer.coffee"
    "geometry": "./src/geometry.coffee"
  output:
    path: __dirname,
    filename: "dist/[name].js",
    libraryTarget: "umd",
    library: '[name]'
  module:
    rules: [
      {
        test: /\.coffee$/,
        loaders: [ "coffee-loader" ]
      },
      {
        test: /\.sass$/,
        use: ExtractTextPlugin.extract({
          use: ["css-loader", 'sass-loader']
          fallback: 'style-loader'
        })
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          use: ["css-loader" ]
          fallback: 'style-loader'
        })
      },
      {
        test: /\.pug$/,
        use: ['pug-loader']
      }
    ]
  plugins: [
    new webpack.optimize.UglifyJsPlugin({ include: /\.min\.js$/ }),
    new HtmlWebpackPlugin(
      {
        template: './src/index.pug',
        inject: false,
        cache: false,
        chunks: ['index'],
        filename: 'dist/index.html'
      }
    ),
    new HtmlWebpackPlugin(
      {
        template: './src/test.pug',
        inject: false,
        cache: false,
        chunks: ['test-html'],
        filename: 'dist/test.html'
      }
    ),
    new ExtractTextPlugin("dist/[name].css"),
  ]
  node:
    fs: "empty"
    child_process: "empty"
