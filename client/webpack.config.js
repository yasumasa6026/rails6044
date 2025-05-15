const path = require('path');

module.exports = {
  // ... その他の設定 (entry, output など)

  // ★ mode の警告をなくすために設定を追加 ★
  // development または production を指定します
  mode: 'development', // または 'production'

  module: {
    rules: [
      {
        // .js または .jsx  .ts, .tsx 拡張子のファイルを対象にする
        test: /\.(js|jsx|ts|tsx)$/,
        // node_modules ディレクトリは除外する
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            // Babel の設定をここに記述するか、別途 .babelrc ファイルを作成する
            presets: ['@babel/preset-env', 
                      '@babel/preset-react',
                      '@babel/preset-typescript'],
          }
        }
      },
      // ★ 必要に応じて他のローダーも追加 ★
      // 例: CSSファイルを処理するためのローダー
       {
         test: /\.css$/,
         use: ['style-loader', 'css-loader']
       },
      // 例: 画像ファイルを処理するためのローダー (Webpack 5 の場合)
      // {
      //   test: /\.(png|svg|jpg|jpeg|gif)$/i,
      //   type: 'asset/resource',
      // },
    ],
  },

  // ★ モジュールの解決設定 (resolve) ★
  // .js や .jsx ファイルをインポート時に拡張子を省略できるようにする
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx'],
  },

  // ... その他の設定
};