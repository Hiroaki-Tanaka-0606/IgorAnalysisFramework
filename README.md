# IgorAnalysisFramework
Igor上で、生データからグラフまでの処理をフローチャート的に構築する。

## 構成
- カレントフォルダ直下に以下のフォルダを用意する。
  - **Diagrams** フローチャートを記述するWave(Text, 2D, 複数可)を格納する。
  - **Data** データを格納する。
  - **Constants** 数または文字列の定数を格納する。フローチャートの初期化時に**Data**フォルダ内に同名コピーが作成される。
  - **Configurations** 依存関係、フローチャートの見た目などの設定情報を格納する。
  - **TempData** 一時的なデータを格納する。ユーティリティ関数を実行する際は引数をすべてここに格納する必要がある。

## フローチャート
フローチャートを記述するWaveでは、以下の順で部品の性質を並べる。
- 0行目: 部品の種類(Data, Function, Module, Socket, Panel)
- 1行目: 部品の型(\[A-Za-z0-9\]のみで構成される。他の種類も含めて重複不可)
- 2行目: 部品の名前(他のWaveにある部品を含めて、重複不可。空欄であれば初期化時に**部品の型**+**数字**で命名される)
- 3行目以降: 部品のプロパティ(入出力)

### 部品の種類
#### Data(データ)
以下の型を持つ。プロパティはない。
- Variable: 数
- String: 文字列
- Wave1D, Wave2D, Wave3D: 1, 2, 3次元Wave(Double Precision)
- TextWave: 1次元Text Wave

#### Function(関数)
- いくつかのデータを入力しいくつかのデータを出力する。
- 型が関数の種類に対応する。
- 3行目以降は、引数となるデータ名を必要な個数だけ順番に並べる。

#### Module(モジュール)
- いくつかのデータを入力に持つ。
- 入力を受け付けるソケットを持つ。別のモジュールに入力を行うソケットを持つ場合もある。
- ソケットが値を受け取ると処理が実行され1つの値を返す。データを出力することはない。
- 処理の過程で、別のモジュールに入力を行い返された値を用いる場合もある。
- 型がモジュールの種類に対応する。
- 3行目以降は、引数となるデータ・ソケットの名前を必要な個数だけ順番に並べる。入力を受け付けるソケットの欄は空でよい。

#### Socket(ソケット)
- 2つのモジュールをつなげ、一方のモジュールからもう一方に値を渡し処理を行わせる。
- 引数として渡す値の種類によって以下の型に分類される。すべてのソケットで、返す値は数になる。
  - Coordinate1D, Coordinate2D, Coordinate3D: 1, 2, 3次元座標(x, y, z)入力
  - Index1D, Index2D, Index3D: 1, 2, 3次元インデックス(p, q, r)入力
- 3行目は入力を渡すモジュール名を記述する。
- 4行目は値を受け渡すモジュール名となるが、初期化時に入力されるのであらかじめ入力しておく必要はない。

#### Panel(パネル)
- いくつかのデータを入力し、グラフなどを出力する。
- VariableやStringの型をもつデータを入力欄に表示し、値を変化させることもできる。

### Igorファイル上での実体
#### Data
**Data**フォルダ内に存在する。Variable, StringはNVAR, SVARとして取得することになる。

#### Function
以下のProcedure Functionとして存在する。***FuncName***は各関数の型に対応する。
- **IAFf\_** ***FuncName*** **\_Definition()**: 引数データの情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: 引数が入力であれば"0"、出力であれば"1"。入力受け付けソケット("1")はない。出力引数データが他の関数の出力にもなることはできない(他の関数の入力になることはある)。
  - \[n+1-2n\]: 引数の型
- **IAFf\_** ***FuncName*** **(arguments)** : 実行される関数。**IAF\_** ***FuncName*** **\_Definition()** のリストに従ったデータの名前がStringで入力されるので、処理を行う。データを更新することで出力とするので、```return```で値を返すことはない。

#### Module
以下のProcedure Functionとして存在する。***ModuleName***は各モジュールの型に対応する。
- **IAFm\_** ***ModuleName*** **\_Definition()** : 引数データの情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: 引数が入力であれば"0"、入力受け付けソケットであれば"2"(リスト内に1つ)。出力("1")はない。
  - \[n+1-2n\]: 引数の型
- **IAFm\_** ***ModuleName*** **(arguments)** : 実行される関数。入力受付ソケットの部分は実際の値、それ以外は**IAF\_** ***FuncName*** **\_Definition()** のリストに従ったデータの名前(String)が入力される。値を```return```で返す。
- **IAFm\_** ***ModuleName*** **\_Format(arguments)** (任意): 入力引数から想定される、出力Waveのスケール(size, offset, delta)を返す関数。ソケットからWaveを生成する際に有用となる。 ***FuncName*** = ***ModuleName*** \_FormatのFunctionなので **\_Format_Definition()** も必要であることに注意(出力は必ずWave2Dになる)。

#### Panel
(under construction)

#### Temporary Data
処理の途中でWaveを生成する場合、ユーティリティ関数に値を渡す場合はそのデータを**TempData**フォルダに入れる。

#### Utility Functions
複数の関数やモジュールで頻繁に使われる処理を行うもの。引数なしのProcedure Functionとして存在する(名称は**IFAu\_** ***UtilityFuncName*** **()**)。
**TempData**から必要な値を引いて処理を行い**TempData**に反映する。**TempData**の整備は関数やモジュール内で適切に行う。

#### Configurations
以下のような設定情報が保存される。
- **DataOrigin(Text2D)** : データの生成元を表す
  - \[i\]\[0\]: データの名前
  - \[i\]\[1\]: そのデータを出力する関数
- **Ascend(Text2D)** : 関数の実行に必要なデータすべて(フローチャートで間接的につながっているものも含む)
  - \[i\]\[0\]: 関数の名前
  - \[i\]\[1\]: 関数の実行に必要なデータの文字列リスト
- **Descend(Text2D)** : データの更新によって再実行する必要がある関数すべて(フローチャートで間接的につながっているものも含む)
  - \[i\]\[0\]: データの名前
  - \[i\]\[1\]: データの更新によって再実行する必要がある関数の文字列リスト
- **ChartIndex(Text1D)** : フローチャートを図示する際のインデックス
  - \[i\]: i番目の部品の名前
- **ChartPosition(Variable2D)** : フローチャート上での座標。**ChartIndex**と対応する。
  - \[i\]\[0\]: x座標
  - \[i\]\[1\]: y座標
  
#### Core Functions
フローを管理するための関数群。関数名は**IAFc\_** ***CoreFuntionName*** **(arguments)** となる。Core Functionで使われるユーティリティ関数は**IAFcu\_** ***CoreUtilityFunctionName*** **(arguments)** とする。
- **SetUp()**: 必要なフォルダ・Waveを作成する。
- **CopyConstants()**: **Constants**から**Data**に値を移動する。
- **ConfigureDependency()**: 部品の名前に重複がないか確認し、名前がなければ生成する。引数の型をチェックし、ソケットが値を受け渡すモジュール名を**Diagrams**フォルダ内のWave(4行目)に記述する。**Configurations**フォルダ内の**DataOrigin**, **Ascend**, **Descend**を生成する。
- **ConfigureChart()**: **Configurations**フォルダ内の**ChartIndex**, **ChartPosition**を生成する。
- **Execute(FunctionName)**: 関数を実行する。
- **ExecuteAll()**: すべての関数を実行する。順序は依存関係に基づく。
- **Update(DataList)**: DataListの更新に伴う関数を実行する。実行される関数およびその順序は依存関係に基づく。
- **CallSocket(SocketName, ValueList)** ソケットを呼び出す。値は文字列リストとして入力。
- **CallUtility(UtilityName)** Utility Functionを実行する。実行前に**TempData**に引数を整備しておくこと。
- **Initialize()**: **CopyConstants**, **ConfigureDependency**, **ConfigureChart**, **ExecuteAll()** を実行する。
