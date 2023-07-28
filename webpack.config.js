const path = require('path')

module.exports = {
    entry: './js-src/index.ts',
    mode: 'development',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'public/js/')
    },
    resolve: {
        extensions: ['.js', '.ts'],
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
                test: /\.jpe?g|png$/,
                exclude: /node_modules/,
                use: ['url-loader', 'file-loader']
            }
        ]
    }
}
