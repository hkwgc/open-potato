# LAYOUTマニュアル

[Open PoTAToドキュメントリストへ](index.md)

<!-- TOC -->

- [LAYOUTマニュアル](#layoutマニュアル)
- [概要](#概要)
    - [説明内容](#説明内容)
    - [表示機能とLAYOUT](#表示機能とlayout)
    - [データ構造](#データ構造)
        - [Open PoTAToデータ](#open-potatoデータ)
        - [ObjectData](#objectdata)
        - [AO: Draw処理と関連データ](#ao-draw処理と関連データ)
        - [CO: Callback処理と関連データ](#co-callback処理と関連データ)
    - [補助関数](#補助関数)
        - [Open PoTAToデータの取得](#open-potatoデータの取得)
        - [AO関連データのI/O](#ao関連データのio)
    - [AO:Axis-Objectの作成](#aoaxis-objectの作成)
        - [AO関数インタフェィス](#ao関数インタフェィス)
        - [createBasicInfo](#createbasicinfo)
        - [getArgument](#getargument)
        - [drawstr,draw](#drawstrdraw)
    - [CO:Control-Objectの作成](#cocontrol-objectの作成)
        - [createBasicInfo](#createbasicinfo-1)
        - [getArgument](#getargument-1)
        - [drawstr,make](#drawstrmake)
        - [mycallback](#mycallback)
- [付録：ScriptAOの使用方法](#付録scriptaoの使用方法)
    - [概要](#概要-1)
    - [設定](#設定)
    - [Axis用スクリプト](#axis用スクリプト)
    - [描画用スクリプト](#描画用スクリプト)

<!-- /TOC -->

# 概要


本書はOpen PoTAToにおけるデータの描画機能の拡張について説明します。
事前に[描画機能マニュアル-基本編](LayoutEditor.md)を読んでから、進んでください。

LAYOUTの構成要素であるAO, COを新たに作成することにより、Open PoTAToの表示機能を拡張できます。
ここではプログラムコードの作成を前提としていますので、プログラムサイドからの説明になります。
作成のための予備知識として、Open PoTAToにおける表示処理について説明します。ここで、LAYOUTの構造とデータの引継ぎに関しては再度説明しません。
ここでは典型的なAO,COについて説明します。一部のAO,COの動作と異なる場合があります。


## 説明内容



## 表示機能とLAYOUT

表示処理において、LAYOUTのオブジェクトのCO, AOの相互作用に注目して説明します。

ここで相互作用の説明にはUMLにおけるシーケンス図を用います。まず、簡単に今回の表記で用いているシーケンス図について説明します。下図はシーケンス図の例です。図の縦軸は時間で、上から下に流れます。

また考慮するオブジェクト(A)を四角と点線で示しています。点線は存在する期間を示しており、削除される時点を×で示します。ここで言うオブジェクトは各種ウィンドウやCOやAOです。CO、AOはMATLAB上では単なる特定の構造を持つデータで、そのひとつひとつをオブジェクトと言います。

オブジェクトは、特定の関数（およびそのサブ関数）を用いて操作します。図ではこれら操作をメッセージ(B)として記載します。特に注目している引数がある場合のみ括弧内に引数を記載しています。

メッセージを受け、オブジェクト内部に正しく初期化されたデータを持つようになった時、状態不変式(C)にそのデータを示しています。

![image-20200326121228714](LayoutEditor.assets/image-20200326121228714.png)



描画時のCO,AOの主要なシーケンスを示します。

![image-20200326121251679](LayoutEditor.assets/image-20200326121251679.png)



描画する際、Open PoTAToからみると3つの状態があります。1つはLayout EditorでLayoutを作成している状態、もうひとつはP3_view関数で描画を実行している状態、そして最後は描画後、コントロールにより図の再描画等を行っている状態です。

最初に、Open PoTAToにより1.LayoutEditorが起動され、Layoutの作成状態になります。

LayoutEditorからCOの2.getArgumentサブ関数が呼び出されCOが生成されます。このときCOはObjectDataとして作成されLayoutに保存されます。

同様にLayoutEditorからAOの3.getArgumentサブ関数が呼び出されAOが生成されます。ここで実際の編集作業ではCO,AOの生成順序、生成数に制限はありません。また、削除や変更などのメッセージは省略しています。

Layoutが作成されると、Open PoTAToにより4描画処理が実行されます。この時、P3_Viewにより処理が行われます。描画処理中、LAYOUT構成要素であるArea,Axis-Areaはそれぞれ自分のcurdataを保持し、curdataを利用・変更し、親から子へcurdataを引き継いでいきます。

CO描画時、描画処理(P3_View)はCOに対してCOの属するAreaのcurdataを引数とし5.makeを実施します。この時COはボタン等のGUIを作成し、curdataを内部に保持します。また、上位Areaのcurdataを更新します。
AO描画時、描画処理(P3_View)はAＯに対してAOの属するAxis-Areaのcurdataを引数とし6.drawを実施します。この時、AOはグラフを描画などによりGUIを作成し、curdataを保持します。また、先祖にCallbackを受けたいCOが居る場合、そのCOに7.Callbackしてもらうようデータを登録します。登録されたデータはCO内にUserDataとして保存されます。
最後にCOが作成したGUIがユーザ等により8操作された際、COは登録されているAOの持つcurdataを書き換え9.draw関数を実行します。
なお、ここでの説明はCO,AOの相互作用を主眼にしたため、Open PoTATo内部で行う描画管理処理に関しては大幅に省略しています。省略しているものはArea,Axis-Areaに関する処理や、CO,AOの基本情報の参照メソッドcreateBasicInfoや、描画処理を行うための処理をdrawstrメソッドです。また、ObjectDataやcurdata引継ぎ、保存方法に関しても省略しています。



## データ構造

CO,AOを拡張する上で必要なデータ構造を説明します。LAYOUTの構造とcurdataに関しては[LAYOUTの構造とデータの引継ぎ](LAYOUTの構造とデータの引継ぎ)も参照ください。

なおデータ構造は、LAYOUT編集中、描画中、GUIによるCallback中の３つの状態の影響を受けます。



### Open PoTAToデータ

描画中のOpen PoTAToの解析結果として渡された、連続データや区間データおよび要約統計量は、
FigureのApplicationDataとして保存されます。なお、存在しないデータは空([])になります。

| データ名 | 内容               | 関連curdata                                    |
| -------- | ------------------ | ---------------------------------------------- |
| CHDATA   | 連続データ(ヘッダ) | curdata.region=’Cntinuous’                     |
| CDATA    | 連続データ         | curdata.cid0                                   |
| BHDATA   | 区間データ(ヘッダ) | curdata.region=’Block’                         |
| BDATA    | 区間データ         | curdata.stimkind<br>curdata.flag.MarkAveraging |
| SSHDATA  | 要約統計量(ヘッダ) | curdata.region=’Summary’                       |
| SSDATA   | 統計量(ヘッダ)     | -                                              |


現在、注目している描画対象のデータはcurdataにより記載されます。データの種類はcurdataの.regionで指定されます。
また、連続データが複数ある場合、cid0に連続データの通し番号が、区間データの場合は
stimkindに注目中の刺激の種類が指定されます。
データの取得にはp3_LayoutViewToolの’getCurrentData’が利用できます。



### ObjectData

ObjectDataはAO, COが持つサブ関数getArgumentにより作成されるデータで、利用関数名や引数などが格納されます。
AOのObjectDataはLAYOUT編集中にgetArgumentにより作成されLAYOUT内のAxisAreaの構成要素(Object)に保存されます。
描画中、AxisArea内ではobj{idx}として参照可能です。通常、AOのサブ関数drawstrを通して参照され、AOのサブ関数drawの引数objdataとして渡ってきます。また、draw中に描画中のAOに対応するApplicationDataとして保存されます。
GUIによるCallback中、ObjectDataはCO内でApplicationDataから呼び出され、AOのサブ関数drawに渡されます。
なお、ApplicationDataとのI/Oはp3_ViewCommonCallback関数が利用できます。AO:描画処理終了時に、”checkin”で保存し、COは”getData”で呼び出します。また、AO再描画時は”update”を用いてデータを更新します。詳細は補助関数を参考ください。
ObjectDataの例を示します。なおAOのサブ関数getArgument関数に依存します。



| フィールド名 | 内容               | 例                      |
| ------------ | ------------------ | ----------------------- |
| str          | 表示名             | ‘3D_BrainSurf’          |
| fnc          | AO 関数名          | ‘LAYOUT_AO_3DBrainSurf' |
| ver          | Version:内部管理用 | 1                       |
| (Arg1)       | 引数など           | 4                       |



COのObjectDataはLAYOUT編集中にgetArgumentにより作成され、LAYOUT内のAreaの構成要素(CObject)として保存されます。

描画中、Area内でcbobj{idx}として参照可能です。通常、COのサブ関数drawstrを通して参照され、AOのサブ関数makeの引数objとして渡ってきます。objデータは通常make後に破棄されますが、COによっては作成uicontrol内の’UserData’に保存されることがあります。

GUIによるCallback中、ObjectDataは通常利用しません。

ObjectDataの例を示します。なおCOのサブ関数getArgument関数に依存します。



### AO: Draw処理と関連データ

AOのサブ関数drawを実施する上で必要なその他のデータについて説明します。関連するハンドルとして、AOを描画するAxesハンドルが入力として渡ってきます。また、Drawにより作成されたハンドル群を出力します。ハンドル群は再描画前に削除するために利用されます。また、AOはObjectIDを持ちます。AOのDraw処理に必要な情報の多くはApplicationDataとして保存しますが、このデータを取得する際に利用します。なお、ObjectIDは通常p3_ViewCommonCallback関数を用いて発行します。

### CO: Callback処理と関連データ

一般的なCOがGUIよりコールバックされた時に必要なデータについて説明します。
GUIからコールされた時の引数は対象GUIのハンドルです。実行に必要なデータはそのハンドル内のUserDataプロパティに格納されています。
UserDataはセル配列で定義されており、Callback登録されているAOの一覧が入っています。ただし、描画時にObjectDataを保存している場合、UserDataが1番目のセルに格納されている場合があります。
COのUserData内にCallback登録されているデータの変数名は多くの場合udと表現されています。udは以下のデータを持ちます。

| フィールド名 | 内容                      | 例                                           |
| ------------ | ------------------------- | -------------------------------------------- |
| axes         | 対象 Axes のハンドル      | 347.0016                                     |
| ObjectID     | AO の ObjectID            | 1                                            |
| name         | AO の名称                 | ‘Layout_AO_TimeLine_ObjectData’              |
| str          | Callback するための文字列 | ‘Layout_AO_TimeLine_ObjectData(‘’draw’’, ... |



このudを用いるとApplicationDataに保存しているAOのDraw処理に関する情報（AO関連データ）が取得できます。取得は以下の様に補助関数p3_ViewCommonCallbackを利用します。

data=p3_ViewCommonCallback(‘getData’,ud.axes,ud.name,ud.ObjectID);
関数を実行するとud.axesをカレントAxesに変更し、Application-Dataからname,ObjectIDに対応したdataを取り出します。ここでdataの構造は以下のようになっています。

| フィールド名 | 内容                  | 主な用途         |
| ------------ | --------------------- | ---------------- |
| handles      | AO が作成したハンドル | 描画前に削除する |
| axes         | AO の属する Axes      | 描画(ud.str)     |
| curdata      | AO 内部の curdata     | 更新および描画   |
| obj          | AO の ObjectData      | 描画             |



handles AOが作成したハンドル 描画前に削除するaxes AOの属するAxes 描画（ud.str）curdata AO内部のcurdata 更新および描画obj AOのObjectData 描画

## 補助関数

AO, COを作成中に利用する補助関数を説明します。

| 関数名              | サブ関数名                   | 内容                                                         |
| ------------------- | ---------------------------- | ------------------------------------------------------------ |
| p3_LayoutViewerTool | getCurrentData               | 描画対象の POTATo データを取得する                           |
| p3_ViewCommonCallck | checkin<br>update<br>getdata | AO 関連データを保存し、Common CO に登録する<br>AO 関連データを更新する<br>AO 関連データを取得する |



### Open PoTAToデータの取得

curdataに対応するOpen PoTAToデータの取得のためには以下の関数を利用します。

| 項目         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| シンタックス | [hdata, data] = p3_LayoutViewerTool(‘getCurrentData’, fh, curdata); |
| 機能         | 描画中の curdata に対応する POTATo データを取得する。        |
| 入力         | **fh** Figure ハンドル(描画中のもの)                         |
|              | **curdata** curdata                                          |
| 出力         | **hdata** POTATo データ(ヘッダ)                              |
|              | **data** POTATo データ                                       |

関数はcurdata.regionをみて、対象となるOpen PoTAToデータを取得します。regionが”Block”の場合は通常、curdata.flag.MarkAveraging=falseの時を除きdataはグランドアベレージ後のdataになり3次元になります。また、対象データが無いときは空行列が帰ってきます。

ApplicationDataから直接Open PoTAToデータを取得する場合やその他の関連するcurdataに関してはOpen PoTAToデータ](Open PoTAToデータ)をご参照ください。



### AO関連データのI/O

AO関連データを保存し、Common-COにCallback登録するには以下の関数を使います。



| 項目         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| シンタックス | ID= p3_ ViewCommonCallck (‘checkin’,h,name, ah, curdata, obj); |
| 機能         | AO 関連データを保存し、Common-CO に Callback 登録する        |
| 入力         | **h** AO が作成したハンドルの配列(再描画時に書き換えるもののみ) |
|              | **name** Application Data に登録する名前(AO 固有の名前であること) |
|              | **ah** AO の親となる axes                                    |
|              | **curdata** curdata                                          |
|              | **obj** AO の ObjectData                                     |
| 出力         | **ID** AO の ObjectID                                        |



checkinされたデータはAO関連データ(表4.5 CO:AO関連データ（data）)に変更されます。このAO関連データはAO固有の名前”name”のApplicationデータ内にあるセル配列の末尾に追加されます。

このとき、セル配列を参照するための番号がObjectIDとして返されます。

checkinされたAO関連データを更新します。

| 項目         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| シンタックス | p3_ViewCommonCallck(‘update’,h,name, ah, curdata, obj,ID);   |
| 機能         | 指定した name, ID に対応する AO 関連データを更新する         |
| 入力         | **h** AO が作成したハンドルの配列(再描画時に書き換えるもののみ) |
|              | **name** Application Data に登録する名前(AO 固有の名前であること) |
|              | **ah** AO の親となる axes                                    |
|              | **curdata** curdata                                          |
|              | **obj** AO の ObjectData                                     |
|              | **ID** AO の ObjectID                                        |





保存したAO関連データを呼び出すには以下の関数を使います。

| 項目         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| シンタックス | p3_ViewCommonCallck(‘update’,h,name, ah, curdata, obj,ID);   |
| 機能         | AO 関連データを保存し、Common-CO に Callback 登録する        |
| 入力         | **ah** AO の親となる axes                                    |
|              | **name** Application Data に登録する名前(AO 固有の名前であること) |
|              | **ID** AO の ObjectID                                        |
| 出力         | **data** AO 関連データ                                       |

通常COから呼び出されますが、実行に必要なデータはUserData(表4.4 CO:Callback登録データ（UserData内）)に保存されています。



## AO:Axis-Objectの作成

### AO関数インタフェィス

AOの処理はOpen PoTATo内のLAYOUT/AxisObjecｔフォルダ内に作成されたLAYOUT_AO_*.mに記述します。この関数は以下のようなインタフェィスを持ちます。
LAYOUT_AO_*(‘subfncname’,[arg1,arg2,・・・])
ここでsubfncnameにサブ関数名が入り、arg1,arg2・・・はサブ関数の引数です。用意すべきサブ関数は以下になります。

| サブ関数名      | 内容                       |
| --------------- | -------------------------- |
| createBasicInfo | 基本情報設定               |
| getArgument     | ObjectDataを設定する       |
| drawstr         | 描画時の実行方法を提供する |
| (draw)          | 描画処理                   |

それぞれのサブ関数の引数や用途は決まっており、ここでは各サブ関数について説明します。なお、これらの関数の骨格となるコードは、他のAOをコピーするか、”P3_wizard_plugin“のViewerAxis-Objectにて作成できます。

### createBasicInfo

編集時や描画中の基本情報を設定します。

| 項目         | 説明                                            |
| ------------ | ----------------------------------------------- |
| シンタックス | info=createBasicInfo                            |
| 機能         | 指定したname,IDに対応するAO関連データを更新する |
| 出力         | **info** 基本情報（構造体）                     |



ccbはp3_ViewCommonCallck/checkinでCommon-COに対してCallback登録を実施するかどうかの判定をするさいに使います。ccbが‘all’の場合は全てCallback登録します。

‘all’設定は容易ですが、描画に時間のかかるAOは不必要なタイミングで再描画されないよう、COを限定すべきです。

| フィールド名 | 内容                              | 例                              |
| ------------ | --------------------------------- | ------------------------------- |
| MODENAME     | AOの名前                          | '2DImage(2.0)';                 |
| fnc          | AOの関数名                        | mfilename                       |
| ver          | バージョン                        | 2.0                             |
| ccb          | Callback登録するCommon-COのリスト | {'Data','DataKind','stimkind'}; |



### getArgument

描画処理を実施するための引数設定を行います。

| 項目         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| シンタックス | obj=getArgument(obj)                                         |
| 機能         | AO: 描画のための引数を設定する                               |
| 入出力       | **obj** AOのObjectData ([ObjectData](ObjectData)の表AO:ObjectDataを参照) |

Layout Editorから呼び出されます。
新規作成時、objは空白になり、更新時、objは以前のobjが設定されます。キャンセルする場合はreturn前にobj=[]；と設定します。



### drawstr,draw

描画処理を実施するための文字列を渡します。文字列はAxis-Area内のAO描画処理で実行されますので、変数のスコープには注意が必要です。

| 項目         | 説明                                              |
| ------------ | ------------------------------------------------- |
| シンタックス | str=drawstr(varargin)                             |
| 機能         | AO：描画処理のための文字列作成                    |
| 入力         | **varargin**  varargin{1}にはObjectDataが入ります |
| 出力         | **str** Axis-Area内のAO描画処理で実行する文字列   |



通常、以下のように記載します。

```matlab
function str = drawstr(varargin) %#ok
str=[mfilename, ' (''draw'', h.axes, curdata, obj{idx})'];
```

上記の記載を前提にdraw処理を説明します。

| 項目         | 説明                                                |
| ------------ | --------------------------------------------------- |
| シンタックス | hout=draw(gca0,curdata,objdata,ObjectID)            |
| 機能         | AO：描画処理                                        |
| 入力         | **gca0** AOの親となるaxes                           |
|              | **curdata** curdata                                 |
|              | **objdata** AOのObjectData                          |
|              | **ObjectID** AOのObjectID(ただし、再描画の時のみ)   |
| 出力         | **hout** AOが作成したハンドルとタグを記載した構造体 |

ここでhoutはhout.hにハンドルの配列、hout.tagにタグのセル配列を作成します。

ここでdraw処理の一般的な内容について説明します。
Open PoTAToデータを利用する場合は以下の一文を追加しOpen PoTAToデータを取得します。

```matlab
[hdata,data]=osp_LayoutViewerTool(... 'getCurrentData',curdata.gcf,curdata);
```

次に、グラフを描画します。例えば以下の様なコードになります。

```matlab
h.h = surf(peaks(10)); % ハンドルを設定します(必須)
h.tag = {‘test’}; % タグを設定します
```

実際にはこのグラフ描画がAOのコア部分です。

また、ApplicationDataI/OおよびCommonCOにCallbackを呼び出すよう登録します。



```matlab
%=====================================
%= Common-CO への Callback 登録 =
%=====================================
myName='LAYOUT_AO_hoge'; % Application Data に登録する名前
if exist('ObjectID','var'),
	% 再描画時
	p3_ViewCommCallback('Update', ...
      h.h, myName, ...
			gca0, curdata, obj, ObjectID);
	return; % Update して終了
else
% Application Data の登録、Callbak 登録
	ObjectID = p3_ViewCommCallback('CheckIn', ...
      h.h, myName, ...
			gca0, curdata, obj); % ObjectID 取得
end
```



最後に、CommonCO以外のCOにCallback登録します。以下はCallbackの必要がある場合のみ行います。なお、Callbackの登録の方法はCOにより異なりますが、典型的なCOは同じです。
最初に登録用データとしてUserData(表4.4CO:Callback登録データ（UserData内）)を作成しまう。
次に、curdata内にある対象のCOにUserDataを追記します。



```matlab
% ================================================================
% = Callbackの登録 =
% ================================================================
% Callback 登録用データの作成
udadd.axes = gca0;
udadd.ObjectID = ObjectID; % Common CO の登録で発行された ID
udadd.name = myName;       % Common CO の登録時と同じ
udadd.str = [objdata.fnc,...
    '(''draw'',data.axes, data.curdata, data.obj, ud.ObjectID);'];
%------------------------
% Callback 登録 ( XX)
%------------------------
% CO_XX が存在するかどうかのチェック
if isfield(curdata,'Callback_XX') && ...
        isfield(curdata.Callback_XX,'handles') && ...
        ishandle(curdata.Callback_XX.handles)
    % See also LAYOUT_CO_XX
    % ハンドル取得
    h = curdata.Callback_XX.handles;
    % UD の追加
    ud=get(h,'UserData'); % 現状の ud 取得
    if isempty(ud)
        ud = {udadd};
    else
        ud{end+1}=udadd;
    end
    set(h,'UserData',ud); % UD 更新
end

```









## CO:Control-Objectの作成

COの処理はOpen PoTATo内のLAYOUT/ControlObjectフォルダ内に作成されたLAYOUT_CO_*.m
もしくはLAYOUT_CCO_*.mに記述します。
ここで、COは通常のCO,CCOはCommon–COです。

この関数は以下のようなインタフェィスを持ちます。
LAYOUT_[C]CO_*(‘subfncname’,[arg1,arg2,・・・])

ここでsubfncnameにサブ関数名が入り、arg1,arg2・・・はサブ関数の引数です。用意すべきサブ関数は以下になります。

| サブ関数名      | 内容                   |
| --------------- | ---------------------- |
| createBasicInfo | 基本情報設定           |
| getArgument     | ObjectDataを設定する   |
| drawstr         | COの作成方法を提供する |
| (make)          | CO作成                 |
| (mycallback)    | Callback実行           |

サブ関数getDefaultCObjectはLayoutEditorのArea内Variable設定をする一部のCOには必須ですが、今回は説明しません。

以下、それぞれのサブ関数の引数や用途は決まっており、ここでは各サブ関数について説明します。
なお、これらの関数の骨格となるコードは、他のCOをコピーするか、以下のコードを利用ください。



```matlab
function varargout=LAYOUT_CO_XX (fcn,varargin)
% ヘルプを記載します
if nargin==0, fcn='help';end
%====================
% Switch by Function
%====================
switch fcn
    case {'help','Help','HELP'}
        POTATo_Help(mfilename);
    case {'createBasicInfo','drawstr','getArgument'}
        % Basic Information
        varargout{1} = feval(fcn, varargin{:});
    case 'make'
        varargout{1} = make(varargin{:});
    otherwise
        % Default
        if nargout
            [varargout{1:nargout}] = feval(fcn, varargin{:});
        else
            feval(fcn, varargin{:});
        end
end %===============================
return;
```



### createBasicInfo

編集時や描画中の基本情報を設定します。



| 項目         | 説明                                            |
| ------------ | ----------------------------------------------- |
| シンタックス | info=createBasicInfo                            |
| 機能         | 指定したname,IDに対応するCO関連データを更新する |
| 出力         | **info** 基本情報（構造体）                     |

ここで、基本情報構造体は以下のフォーマットです。



| フィールド名 | 内容       | 例                 |
| ------------ | ---------- | ------------------ |
| name         | COの名前   | 'XX';              |
| fnc          | COの関数名 | mfilename          |
| rver         | バージョン | ‘ Revision: 1.1’   |
| date         | 最終更新日 | ‘Date: 2012/09/01’ |

rver,dateは使用していませんが記載を推奨します。
uicontrolフィールドはLayoutEditorのArea内Variable設定をする一部のCOには必須ですが今回は説明しません。

### getArgument

描画処理を実施するための引数設定を行います。

| 項目         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| シンタックス | obj=getArgument(obj)                                         |
| 機能         | CO：描画のための引数を設定する                               |
| 入出力       | **obj** COのObjectData([ObjectData](ObjectData)の表 COのObjectDataを参照) |

LayoutEditorから呼び出されます。

新規作成時、objは空白になり、更新時、objは以前のobjが設定されます。

キャンセルする場合はreturn前にobj=[]；と設定します。

### drawstr,make

CO描画処理を実施するための文字列を渡します。文字列はAxis-Area内のCO描画処理で実行されますので、変数のスコープには注意が必要です。

| 項目         | 説明                                              |
| ------------ | ------------------------------------------------- |
| シンタックス | str=drawstr(varargin)                             |
| 機能         | CO：描画処理のための文字列作成                    |
| 入力         | **varargin**  varargin{1}にはObjectDataが入ります |
| 出力         | **str** Axis-Area内のCO描画処理で実行する文字列   |



通常、以下のように記載します。

```matlab
function str = drawstr(varargin)
% Execute on ViewGroupCallback 'exe' Function
str=['curdata=’ mfilename ‘(''make'',handles, abspos,' ...
      'curdata, cbobj{idx});'];
return;
```



上記の記載を前提にmake処理を説明します。



| 項目         | 説明                                              |
| ------------ | ------------------------------------------------- |
| シンタックス | curdata=make(hs,apos,curdata,obj)                 |
| 機能         | CO：描画処理                                      |
| 入力         | **hs** 上位ハンドル                               |
|              | **abspos** 上位Areaの絶対位置（Normalized Units） |
|              | **curdata** curdata                               |
|              | **objdata** COのObjectData                        |
| 出力         | **curdata** curdata                               |

ここでmake処理の一般的な内容について説明します。

CommonCOの場合はCommonCO用の構造体の基本設定を行います。



```matlab
%=====================
% Common-Callback-Data
%=====================
CCD.Name         = 'XX';        % CO の名前
CCD.CurDataValue = {'XX','xx'}; % AO 基本情報 ccb の指定名
CCD.handle       = [];          % Callback 登録するハンドル
```

この例では、AOの基本情報(表4.8 AO:基本情報)内のccbに、’XX’もしくは‘ｘｘ’をもつAOに限りCallback登録するよう設定しています。（ただしcbbがallの場合はCallback登録します。



次にGUIを作成します。

```matlab
h0       = uicontrol;
```

実際にh0とハンドルを作る必要はないですが、これ以降便宜上h0として話しをします。

GUIの位置は相対位置で着ていますので以下のように変更が必要です。

```matlab
pos=getPosabs(obj.pos,apos);

function lpos=getPosabs(lpos,pos)
% Get Absolute position from local-Position 
lpos([1,3]) = lpos([1,3])*pos(3);
lpos([2,4]) = lpos([2,4])*pos(4);
lpos(1:2)   = lpos(1:2)+pos(1:2);
```



なお、単位はNormalizedですので位置設定を行う前にuicontrolなどのプロパティ’Units’を’Normalized’に設定する必要があります。

Callback設定は次のようにします。

```matlab
set(h0, 'Callback',....
    [mfilename ' (''mycallback'',gcbo)']);
```



ここではCallback関数をサブ関数のmycallbackと設定しています。サブ関数名は自由ですが、以降mycallbackと設定したものとします。

最後に、makeで作成したdataをcurdataに反映させます。デフォルト値などで値を変えた場合、

```matlab
curdata.foovar = obj.defaultfoovar; % この CO が foovar を変更
```

また、COの場合はハンドルを引き継ぎます。

```matlab
curdata.Callback_XX.handles =h0;
```

CommonCOの場合は次のようにハンドルを引き継ぎます。

```matlab
CCD.handle =h0;
if isfield(curdata,'CommonCallbackData')
curdata.CommonCallbackData{end+1}=CCD; else
curdata.CommonCallbackData={CCD}; end
```



### mycallback

上記のmake処理を前提にmycallback関数を説明します。

| 項目         | 説明                 |
| ------------ | -------------------- |
| シンタックス | mycallback(h)        |
| 機能         | COのコールバック処理 |
| 入力         | **h** COハンドル     |

ここでmycallback処理の一般的な内容について説明します。最初に再描画する際に変更す値を用意します。

```matlab
foovar = get(h,’Value’);
```



この例では、COはcurdata.foovarを変更するものとし、foovarはhの’Value’で指定されているものとします。

次にCallback登録されているAOについてループ処理を行い終了します。

```matlab
ud=get(h,'UserData');

for idx=1:length(ud), % for のループ変数名は必ず idx とします。 
    % <<< 以降はこの内部処理の説明になります>>
end
return;
```



ここで、udの内部は表4.4 CO:Callback登録データ（UserData内）に記載しています。

ループ内では最初にAO関連データ(表4.5 CO:AO関連データ（data）)を取得します。

```matlab
% Get Data
data = osp_ViewCommCallback('getData', ...
    ud{idx}.axes, ...
    ud{idx}.name, ud{idx}.ObjectID);
```

次に対象AOのcurdataを更新します。

```matlab
% curdata の更新
data.curdata.foovar =foovar;
```



なお、この場合foovarを更新しています。再描画の前に以前のAOが書いた図を削除します。

```matlab
% Delete handle
for idxh = 1:length(data.handle),
    try
        if ishandle(data.handle(idxh))
            delete(data.handle(idxh));
        end
    catch
        warning(lasterr);
    end % Try - Catch
end

```



最後に再描画を実行します。

```matlab
% Evaluate (Draw)
try
    eval(ud{idx}.str);
catch
    warning(lasterr);
end % Try - Catch
```





# 付録：ScriptAOの使用方法

## 概要

ここで、AOのひとつScriptAOの使用例を説明します。
ScriptAOはスクリプトにより比較的自由に描画を行うためのAOです。

AOは入力に２つのスクリプトを持ちます。
ひとつはAxisおよび同一Axis内にある後続のAOに影響を与えるcurdataを編集するためのスクリプトです。これをAxis用スクリプトと呼びます。このスクリプトは描画時に１度のみ実行されます。
もうひとつはdraw実施のスクリプトです。これを描画用スクリプトと呼びます。このスクリプトは描画時および再描画時に実行されます。

## 設定

ScriptAOをLayoutに追加するには他のAOと同じくLayoutEditor上で行います。
Layoutを作成し、Scriptを設定したいAxisAreaに移動し、AOポップアップメニューから”Script”を選択します。
そうするとScript設定画面が開かれます。

![image-20200326134727180](LayoutEditor.assets/image-20200326134727180.png)

Script設定時、右図のようなダイアログが表示されます。ここで上のエディットボックス(A)にAxis用スクリプトを、下のエディットボックス(B)に描画用スクリプトを記述します。
内容がよければOK(C)ボタンを押して確定します。

以下、Axis用スクリプト、描画用スクリプトの詳細を説明します。



## Axis用スクリプト

Axis用スクリプトは、Axisおよび同一Axis内にある後続のAOに影響を与えるcurdataを編集するためのスクリプトです。このスクリプトは描画時に１度のみ実行されます。
また、AOは全てのCommon-COからCallbackされるため、１度きりで良い処理かつ時間の掛かる処理もAxis用スクリプトに入れます。
Axis用スクリプトはAxis-Areaの描画処理内で実行されます。
そのため変更は親Axisと後続するAOに影響を及ぼします。Axis内で利用できる主なデータは以下になります。

| フィールド名 | 内容                 |
| ------------ | -------------------- |
| h.axes       | Axesハンドル         |
| curdata      | Axis-Area内のcurdata |
| obj{idx}     | ScriptAOのObjectData |



たとえば、対象Axisではデータの種類(kind)として全ヘモグロビンデータのみ表示する場合、Axisに以下の様な設定を付加します。

```matlab
% curdata を設定
% (以降の Axis 全体に影響)
curdata.kind=3;

% 一度だけ行われるべき処理
title('Kind =3');
xlabel('time [sec]');
ylabel('Total HB data');

```



ある情報(foovar)を取得する関数(foo)に時間がかかるとし、この値がCallbackに影響を受けない場合、以下のように事前に計算します。

```matlab
[hdata,data]=p3_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);
curdata.foovar=foo(hdata,data);
```





## 描画用スクリプト

描画用スクリプトはdraw実施のスクリプトです。このスクリプトは描画時および再描画時に実行されます。
ScriptAOのdrawサブ関数処理内で実行されます。
そのため変更はcurdataの変更は再描画時にのみ引き継がれます。AO：drawサブ関数内で利用できる主なデータは以下になります。

| フィールド名 | 内容                             |
| ------------ | -------------------------------- |
| gca0         | 親Axesハンドル                   |
| curdata      | AO内のcurdata                    |
| objdata      | ScriptAOのObjectData             |
| ObjectID     | 再描画時のみ存在する。ObjectID。 |
| hout         | 出力ハンドル                     |



たとえば、Line-Propertyを無視し,HBデータを線で表示します。

```matlab
% POTATo データ取得
[hdata,data]=p3_LayoutViewerTool('getCurrentData',curdata.gcf,curdata);


% 時間軸計算
unit = 1000/hdata.samplingperiod;
t0=1:size(data,1);
t=(t0 -1)/unit;

kind=curdata.kind;

% 表示, 出力ハンドルの設定
hout.h(end+1)=line(t,data(:,1,kind));
hout.tag{end+1}=['XX' hdata.TAGs.DataTag{kind}];
```



ここで、hout.hが設定されていない場合、Redraw時に削除されませんので注意ください。