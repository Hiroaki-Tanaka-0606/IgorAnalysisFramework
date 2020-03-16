# IgorAnalysisFramework
Igor上で、生データからグラフまでの処理をフローチャート的に構築する。

## 構成
- カレントフォルダ直下に以下のフォルダを用意する。
  - **Diagrams** フローチャートを記述するWave(Text, 2D, 複数可)を格納する。
  - **Data** データを格納する。
  - **Configurations** 依存関係、フローチャートの見た目などの設定情報を格納する。
  - **TempData** 一時的なデータを格納する。

## フローチャート
フローチャートを記述するWaveでは、以下の順で部品の性質を並べる。
- 0列目: 部品の種類(Data, Function, Module, Panel)
- 1列目: 部品の型(\[A-Za-z0-9\]のみで構成される。混乱を招かないためには他の種類も含めて重複しないようにした方がよいが、重複してもプログラム上は不具合がない)
- 2列目: 部品の名前(他のWaveにある部品を含めて、重複不可。空欄、または重複であれば初期化時に**部品の型**+**数字**で命名される。1文字目が_（アンダースコア）であれば、フローチャートに表示されないことがある(条件は後述)。)
- 3列目以降: 部品のプロパティ(入出力)

ソケットは関数・モジュール間の接続関係として定まるので、部品として記述する必要はない。

### 部品の種類
#### Data(データ)
以下の型を持つ。プロパティはない。
- **Variable**: 数
- **String**: 文字列
- **Wave1D**, **Wave2D**, **Wave3D**: 1, 2, 3次元Wave(Double Precision)
- **TextWave**: 1次元Text Wave

#### Function(関数)
- いくつかのデータを入力しいくつかのデータを出力する。
- 型が関数の種類に対応する。
- 3列目以降は、引数となるデータ名を必要な個数だけ順番に並べる。

#### Module(モジュール)
- いくつかのデータを入力に持つ。
- 入力を受け付けるソケットを持つ。別のモジュールに入力を行うソケットを持つ場合もある。
- ソケットが値を受け取ると処理が実行され1つの値を返す。データを出力することはない。
- 処理の過程で、別のモジュールに入力を行い返された値を用いる場合もある。
- 型がモジュールの種類に対応する。
- 3列目以降は、引数となるデータ・ソケット接続するモジュールの名前を必要な個数だけ順番に並べる。入力を受け付けるソケットの欄は空でよい。

#### Socket(ソケット)
- 2つのモジュール・関数をつなげ、一方からもう一方に値を渡し処理を行わせる。
- 引数として渡す値の種類によって以下の型に分類される。すべてのソケットで、返す値は数になる。
  - **Coordinate1D**, **Coordinate2D**, **Coordinate3D**: 1, 2, 3次元座標(x, y, z)入力
  - **Index1D**, **Index2D**, **Index3D**: 1, 2, 3次元インデックス(p, q, r)入力

#### Panel(パネル)
- いくつかのデータを入力し、グラフなどを出力する。
- VariableやStringの型をもつデータを入力欄に表示し、値を変化させることもできる。
- 3列目以降は、引数となるデータの名前を並べる。

### Igorファイル上での実体
#### Data
**Data**フォルダ内に存在する。Variable, StringはNVAR, SVARとして取得することになる。

#### Function
以下のProcedure Functionとして存在する。***FuncType***は各関数の型に対応する。
- **IAFf\_** ***FuncType*** **\_Definition()**: 引数データ（またはソケット接続するモジュール）の情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: 引数が入力であれば"0"、出力であれば"1"。入力受け付けソケット("2")はない。出力引数データが他の関数の出力にもなることはできない(他の関数の入力になることはある)。
  - \[n+1-2n\]: 引数の型
- **IAFf\_** ***FuncType*** **(argumentList)** : 実行される関数。**IAF\_** ***FuncType*** **\_Definition()** のリストに従ったデータ・モジュールの名前が文字列リストで入力されるので、処理を行う。データを更新することで出力とするので、```return```で値を返すことはない。

#### Module
以下のProcedure Functionとして存在する。***ModuleType***は各モジュールの型に対応する。
- **IAFm\_** ***ModuleType*** **\_Definition()** : 引数データ（またはソケット接続するモジュール）の情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: 引数が入力であれば"0"、入力受け付けソケットであれば"2"(リスト内に1つ)。出力("1")はない。
  - \[n+1-2n\]: 引数の型
- **IAFm\_** ***ModuleType*** **(argumentList)** : 実行される関数。入力受付ソケットの部分は実際の値、それ以外は**IAF\_** ***FuncType*** **\_Definition()** のリストに従ったデータの名前が文字列リストで入力される。値を```return```で返す。
- **IAFm\_** ***ModuleType*** **\_Format(argumentList)** (任意): 入力引数から想定される、出力Waveのスケール(size, offset, delta)を返す関数。ソケットからWaveを生成する際に有用となる。 ***FuncType*** = ***ModuleType*** \_FormatのFunctionなので **\_Format_Definition()** も必要であることに注意(出力は必ずWave2Dになる)。

#### Panel
以下のProcedure Functionとして存在する。***PanelType***は各パネルの型に対応する。
- **IAFp\_** ***PanelType*** **\_Definition()** : 引数データの情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: すべての引数が入力なので"0"が並ぶ。出力("1")、入力受け付けソケット("2")はない。
  - \[n+1-2n\]: 引数の型
- **IAFp\_** ***PanelType*** **(argumentList)** : 描画時に実行される関数。パネル（またはグラフ）のウィンドウを作り、グラフや入力欄を設置していく。
- **IAFt\_** ***TemplateType*** **(argumentList)** : Panelに関係するDataやFunctionをDiagram Waveとして生成する。内的に使われるだけのDataは適当に名前を付けるが、外から読み込むDataについてはその名前をargumentListに列挙する。

#### Temporary Data
処理の途中でWaveを生成する場合はそのデータを**TempData**フォルダに入れる。

#### Utility Functions
複数の関数やモジュールで頻繁に使われる処理を行うもの。Procedure Functionとして存在する(名称は**IFAu\_** ***UtilityFuncName*** **(arguments)**)。
Waveを参照する場合は**TempData**に用意する。

#### Configurations
以下のような設定情報が保存される。
- **DataOrigin(Text2D)** : データの生成元を表す
  - \[i\]\[0\]: データの型
  - \[i\]\[1\]: データの名前
  - \[i\]\[2\]: そのデータを出力する関数
- **Ascend(Text2D)** : 関数の実行に必要なデータすべて(フローチャートで間接的につながっているものも含む)
  - \[i\]\[0\]: 関数の名前
  - \[i\]\[1\]: 関数の実行に必要なデータの文字列リスト
- **Descend(Text2D)** : データの更新によって再実行する必要がある関数すべて(フローチャートで間接的につながっているものも含む)
  - \[i\]\[0\]: データの名前
  - \[i\]\[1\]: データの更新によって再実行する必要がある関数の文字列リスト
- **ChartIndex(Text2D)** : フローチャートを図示する際のインデックス
  - \[i\]\[0\]: i番目の部品の名前
  - \[i\]\[1\]: i番目の部品が入っていたDiagram Waveの名前
- **ChartPosition(Variable2D)** : フローチャート上での座標と図形の大きさ。**ChartIndex**と対応する。
  - \[i\]\[0\]: 中心のx座標
  - \[i\]\[1\]: 中心のy座標
  - \[i\]\[2\]: 横幅
  - \[i\]\[3\]: 縦幅
  
#### Variables for　Flowchart and Panels
パネル操作時の情報がカレントフォルダ直下にGlobal Variables / Strings として保存されている。
- **IAF_Flowchart_ChartLeft**, **IAF_Flowchart_ChartTop**: クリックされている部品の初期位置
- **IAF_Flowchart_Clicked**: 部品がクリックされていれば1、そうでなければ0
- **IAF_Flowchart_MouseLeft**, **IAF_Flowchart_MouseTop**: 部品をクリックしたときのカーソルの初期位置
- **IAF_Flowchart_Name**: フローチャートのパネル名（表示されているタイトルではない）。
- **IAF_Flowchart_Selected**: クリックした部品の、**ChartIndex**上でのインデックス。
- **IAF_Flowchart_Zoom**: フローチャートの拡大率。
- **IAF\_** ***PanelName*** **\_Name**: パネルの名前。
  
#### Core Functions
フローを管理するための関数群。関数名は**IAFc\_** ***CoreFuntionName*** **(arguments)** となる。Core Functionで使われるユーティリティ関数は**IAFcu\_** ***CoreUtilityFunctionName*** **(arguments)** とする。
- **SetUp()**: 必要なフォルダ・Waveを作成する。
- **ConfigureNames()**: 部品の名前に重複がないか確認し、名前がなければ生成する。
- **ConfigureDependency()**: 引数の型をチェックする。**Configurations**フォルダ内の**DataOrigin**, **Ascend**, **Descend**を生成する。
- **ConfigureChart()**: **Configurations**フォルダ内の**ChartIndex**, **ChartPosition**を生成する。すでに生成されている部分を保ちつつ更新する。
- **CallChart()**: フローチャートパネルを呼び出す。なければ新規作成する。
- **Function_Definition(FunctionType)**: 関数の定義を返す。
- **Module_Definition(ModuleType)**: モジュールの定義を返す。
- **Execute(FunctionName)**: 関数を実行する。
- **ExecuteList(FunctionList)**: リストに挙げられた関数を実行する。順序は依存関係に基づく。
- **ExecuteAll()**: すべての関数を実行する。順序は依存関係に基づく。
- **Update(DataList)**: DataListの更新に伴う関数を実行する。実行される関数およびその順序は依存関係に基づく。
- **CallSocket(SocketName, ValueList)** ソケットを呼び出す。値は文字列リストとして入力。
- **CallPanel(PanelName)**: パネルを呼び出す。なければ新規作成する。
- **ReCallPanel(PanelName)**: パネルを呼び出す。すでにあったとしても作り直す。
- **CreateData()**: VariableまたはStringの型を持つデータのうち、Global Variable / Stringとして存在しないものを生成する。初期値は**0** / **""**。
- **LoadTemplate(TemplateType,argumentList)** パネル関係のデータをDiagram Waveに整備する。**argumentList**の指定は**IAFt\_** ***TemplateType*** **(argumentList)** に従う。

#### フローチャート
パネル上に生成される。パネルの名前は```IAF_FlowchartPanel```に保存される。パネルのタイトル（表示名）は**Flowchart for** ***folderpath***になる。

- **Show all parts**にチェックを入れないと、アンダースコアで始まる部品は表示されない。
- 各部品が長方形で表示され、依存関係が矢印で表される。色の対応は以下の通り。行番号は**IAFc_DrawChart.ipf**のもの。
  - **Data**: 黒(397行目)
  - **Function**: 青(400行目)
  - **Module**: 赤(403行目)
  - **Panel**: 緑(406行目)
  - **入力・出力の矢印**: 黒(473, 494行目)
  - **ソケットの矢印**: 紫(477行目)
  - **フレーム**: 灰色(515行目)
- 各部品はクリック&ドラッグで動かせる。
- Diagram Waveごとにフレームが描かれる。部品の外かつフレームの中をクリック&ドラッグすると、フレーム内の部品をまとめて動かせる。
