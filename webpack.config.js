const path = require('path')

module.exports = {
    entry: './js-src/index.js',
    mode: 'development',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'public/js/')
    },
    resolve: {
        extensions: ['.js', '.jsx', '.ts', '.tsx'],
        roots: [
            path.resolve(__dirname, 'js-src/')
        ],
        alias: {
            '@burguillosinfo': path.resolve(__dirname, 'js-src')
        }
    },
    module: {
        rules: [
            {
                test: /\.(?:tsx|ts)?$/,
                use: 'ts-loader',
                exclude: /node_modules/
            },
            {
                test: /\.jpe?g|png$/,
                exclude: /node_modules/,
                use: ['url-loader', 'file-loader']
            },
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            }
        ]
    }
}
