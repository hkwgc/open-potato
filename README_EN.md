# Open PoTATo for fNIRS
#### Open Platform of Tranparent Analysis Tools for functional near infrared spectroscopy



[Japanease](/README.md)

Sorry. English page is now under construction. 





## Feature

* Easy to test variou analysis tools

* Plug-in

* Recipe



## Dependency

PoTATo works with MATLAB and follwing toolboxes. MATLAB and Toolboxes are commercial software of Mathworks. Inc.

```
Signal Processing Toolbox (recommended)
Statistics and Machine Learning Toolbox (recommended)
Wavelet toolbox (only used in several fuctions)
```
PoTATo does not include MATLAB and toolboxes.



## Attention

bra bra bra



## Setup

1. MATLABをインストールしてください。

2. ダウンロードサイトから以下のファイルを取得します。
```
P3_files.zip
```
ダウンロード時点で[ライセンス](/LICENCE.txt)に同意したものとします。
ダウンロードしたzipファイルを適当なところに解凍してください。

3. ダウンロードしたP3_files.zipを適当なフォルダに解凍してください。[^1] 
解凍後のフォルダ構成は以下のようになります。
```
P3_files
-\P38
-\manual(English)
-\簡易マニュアル
- インストールマニュアル
```

4. カレントディレクトリ(現在のフォルダー)を変更してください。
MATLABを起動し，カレントディレクトリを展開したフォルダの
```
P3_files\P38\
```
に設定します。設定は MATLAB メイン画面中の MATLAB ツールバー:「現在のフォルダー」からできます。

5. PoTAToを起動します。MATLABコマンドラインに
``` Matlab Command Line
>> P3
```
のように入力し、Enterキーを押すとPoTAToのGUIが起動します。[^2]


## Usage

PoTAToはGUIで動作します。
詳細は「簡易マニュアル」フォルダの下記pdfファイルをご覧ください。
```
* 1 ステップガイド入門編.pdf
* 2 ステップガイド応用編その１.pdf
* 3 解析ツール作成のためのステップガイド.pdf
* 4 LayoutEditorステップガイド.pdf
```



## Contiribution

1. Fork (https://github.com/hkwgc/open-potato)

2. Create a feature branch

3. Commit your changes

4. Rebase your local changes against the master branch

5. Create a new Pull Request

   

## License

MITライセンス




## Maintainer

[Hiroshi KAWAGUCHI](https://github.com/hkwgc)



##### Footnotes

[^1]: ただし，MATLABの特殊ディレクトリ(toolboxなど)にインストールすることは出来ません。
[^2]:  起動が上手くいかない場合，ファイルの解凍場所に問題がある場合もあります。


