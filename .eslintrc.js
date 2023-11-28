module.exports = {
    env: {
        browser: true,
        es2021: true
    },
    overrides: [
    ],
    parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: 'tsconfig.json'
    },
    parser: '@typescript-eslint/parser',
    plugins: ['@typescript-eslint'],
    extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended', 'prettier'],
    root: true,
    rules: {
        indent: ['error', 4, { SwitchCase: 1 }],
    },
    settings: {
        'import/resolver': {
            typescript: {
                project: [
                    'tsconfig.json'
                ]
            }
        }
    }
}
