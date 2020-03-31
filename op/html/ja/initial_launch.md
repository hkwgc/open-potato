# はじめての起動

## Project Directoryの作成

初回の起動のときにはProject Directoryを設定するウィンドウが開きます。また、操作ガイドも開きます。ウィンドウの **[Select Projrct-Directory]** と書かれたボタンをクリックして、コンピュータの任意のフォルダをひとつ選択してください。Open PoTAToではこのフォルダを「Project Directory」として利用します。「Project Directory」は、解析するためのRAWデータや解析結果などの解析関連データを保存する「Project」が保管される場所です。「Project」の作成方法は次の節で説明します。

![image-20200331125432669](install-potato.assets/image-20200331125432669.png)

``` shell
### 補足説明 ###
複数の利用者が同一の環境で作業をする場合は、この「Project Directory」を利用者ごとに設定すれば、ほかの人のデータを壊してしまう心配はありません。
「Project Directory」は、Platformの起動後、メインウィンドウのメニュー「Setting」→「Project Directory」から変更できます。
「Project Directory」に、すでに解析データが含まれる場合は、自動的に認識され、読み出しが可能になります。
```



<!-- ここからさきは[ステップガイド](Step-Guide.md)と重複 -->



## Projectの作成

Project Directoryの作成が完了すると、ウィンドウには **[Make Project]** ボタンが表示されます。

![image-20200331130926220](install-potato.assets/image-20200331130926220.png)

 **[Make Project]** ボタンをクリックすると、**Project Manager** ダイアログが起動します。このダイアログでは、Projectを作成することができます。Projectは実験テーマなどデータを管理しやすいまとまりごとに作成するとよいでしょう。Project NameにはProjectの名称、Operatorには作成者など、Commentにはコメントを **半角文字** で記入してください。ここで使える文字はフォルダの作成に使える文字と同じです。ダイアログ右下の **[New]** ボタンをクリックするとProjectが作成されます。

![image-20200331131555296](install-potato.assets/image-20200331131555296.png)


## データの読み込みと表示

Projectの作成が完了すると、メインウィンドウの表示が変わり、左上にプロジェクトの情報が表示されるようになります。 **[Import Data]** ボタンを押すと **Data Import** ダイアログが起動し、データの読み込みができるようになります。

![image-20200331132303620](install-potato.assets/image-20200331132303620.png)

 **Data Import** ダイアログでは **Add file(s)**ボタンをクリックするとファイルが選択できるようになります。




![image-20200331133842355](install-potato.assets/image-20200331133842355.png)

Open PoTAToをインストールしたフォルダの **man/sample/フォルダ** にサンプルデータがあります。すべて選択して右下の **Open** ボタンを押してみましょう。


![image-20200331134211862](install-potato.assets/image-20200331134211862.png)

すると、 **Data Import** ダイアログにファイルのリストが表示されます。ファイルの内容を確認することができます。右下の **Execute** ボタンを押すと、ファイルが読み込まれ、ダイアログが閉じます。


![image-20200331134243910](install-potato.assets/image-20200331134243910.png)

データが読み込まれるとメインウィンドウが更新されます。左側中段に読み込んだデータのリストがあります。

Open PoTAToではこのような状態のメインウィンドウをつかって、データのフィルタリングをしたり、データを表示したりできます。詳細な操作は他のマニュアルを参照してください。

ここでは試しに、グラフを表示してみましょう。データを一つ選択してメインウィンドウ右下にある **[Draw]** ボタンを押してみましょう。

![image-20200331134321977](install-potato.assets/image-20200331134321977.png)

このグラフは選択したデータ「sample LT1」のCh1の波形を示しています。このようなグラフの他にも様々なパターンでデータを表示することができます。

![image-20200331140001320](install-potato.assets/image-20200331140001320.png)

