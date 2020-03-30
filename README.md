# Open PoTATo for fNIRS
#### Open Platform of Tranparent Analysis Tools for functional near infrared spectroscopy



[English](/README_EN.md)

PoTAToは**fNIRSデータ解析の多彩なツールを統合的に活用**できるソフトウェア(=プラットフォーム)です。多様な機種からのデータ読み込み、信号前処理、統計解析、可視化など様々な機能を備えています。解析初心者からエキスパートまで活用できます。



## 特徴

* 豊富な解析ツールを簡単に試用できます

* 解析ツールを追加できます(プラグイン機能)

* 解析ツールを組み合わせた手順を保存・共有できます(レシピ機能)



## 必要条件

PoTAToを利用するには The Mathwork 社の製品MATLABが必要です。
また、一部の機能では同社のMATLAB Toolboxのうち下記のものを使用しています。

```
Signal Processing Toolbox (推奨)
Statistics and Machine Learning Toolbox (推奨)
Wavelet toolbox (特定の解析関数でのみ使用)
```
これらの利用に当たってはThe Mathwork 社の利用規約，制限事項を遵守ください。MATLABおよびToolboxは本ソフトウェアには含まれていません。



## ご注意

Open PoTAToはプラグインを利用して機能を拡張できます。プラグインをインストールする場合，配布元が信頼できることを十分ご確認ください。悪意のあるプラグイン関数はシステム破壊等の重大な問題につながります。



## インストールから起動まで

1. MATLABをインストールしてください。

2. ダウンロードサイトから以下のファイルを取得します。
```
open-potato-master.zip
```
ダウンロード時点で[ライセンス](LICENCE)に同意したものとします。
ダウンロードしたzipファイルを適当なところに解凍してください。

3. ダウンロードしたopen-potato-master.zipを適当なフォルダに解凍してください。[^1] ここでは、
解凍後のフォルダ構成は以下のようになります。
```
-\op
-\man
-LISENCE.txt
-README.md
-README_EN.md
```

4. カレントディレクトリ(現在のフォルダー)を変更してください。
MATLABを起動し，カレントディレクトリを展開したフォルダの
```
op\
```
に設定します。設定は MATLAB メイン画面中の MATLAB ツールバー:「現在のフォルダー」からできます。

5. PoTAToを起動します。MATLABコマンドラインに
``` Matlab Command Line
>> P3
```
のように入力し、Enterキーを押すとPoTAToのGUIが起動します。[^2]


## 使用方法

PoTAToはGUIで動作します。
詳細は「簡易マニュアル」フォルダの下記pdfファイルをご覧ください。
```
* 1 ステップガイド入門編.pdf
* 2 ステップガイド応用編その１.pdf
* 3 解析ツール作成のためのステップガイド.pdf
* 4 LayoutEditorステップガイド.pdf
```

[マニュアル](/op/html/ja/index.md)はオンラインでも読めます。

## 開発への貢献

1. Fork (https://github.com/hkwgc/open-potato)

2. Create a feature branch

3. Commit your changes

4. Rebase your local changes against the master branch

5. Create a new Pull Request

   

## ライセンス

MITライセンス




## メンテナ

[Hiroshi KAWAGUCHI](https://github.com/hkwgc)



##### 脚注

[^1]: ただし，MATLABの特殊ディレクトリ(toolboxなど)にインストールすることは出来ません。
[^2]:  起動が上手くいかない場合，ファイルの解凍場所に問題がある場合もあります。


