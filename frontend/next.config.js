module.exports = {
    webpack: config => {
        return {
            ...config,
            node: {
                ...config.node,
                fs: "empty"
            },
            module: {
                ...config.module,
                rules: [
                    ...config.module.rules,
                    {
                        test: /\.elm$/,
                        exclude: [/elm-stuff/, /node_modules/],
                        use: [
                            { loader: "elm-hot-webpack-loader" },
                            {
                                loader: "elm-webpack-loader",
                                options: {
                                    forceWatch: true,
                                    debug: true
                                }
                            }
                        ]
                    }
                ]
            }
        };
    }
};
