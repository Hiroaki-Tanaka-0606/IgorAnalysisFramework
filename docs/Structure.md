# Structure of the software
# Role of the folders
The folders created in the **SetUp** process have the following roles.
- The **Diagrams** folder includes **diagram wave**s (Text, 2D). All two-dimensional text waves are used as diagram waves.
- The **Data** folder includes data (waves) and parameters (global variables and strings). To avoid a mess, we recommend not to put raw data in the **Data** folder. Instead, we put a *String* specifying the path to the raw data and use *Function*s such as **LoadWave1D** to load the raw data in the **Data** folder.
- The **Configurations** includes the dependency relationships between the parts and configurations for the flowchart.
- The **TempData** includes temporary data passed via a *Socket*.

# *Part*s
Each row in the **diagram wave**s represent a *Part*.

## Description of *Part*s in the diagram waves
A *Part* is descibed by the following rules.
- The 0th column describes the *Kind* of the *Part*: **Data**, **Function**, **Module**, or **Panel**.
- The 1st column describes the *Type* of the *Part*. Allowd values for the *Type* depends on the *Kind* and are described below in more detail.
- The 2nd column describes the *Name* of the *Part*. The *Name* must be unique. If *Name*s are duplicated or the *Name* cell is left blank, the **ConfigureNames** process (```IAFc_ConfigureNames()```) modify the *Name*s appropriately.
- The following columns descibe the *Name*s of *Part*s used as the input or the output.

There is another *Kind* not listed above: **Socket**.
However, **Socket**s don't appear in the **diagram wave**s because they are automatically described between modules and functions.

## *Kind*s of *Part*s
### Data
A **Data** *Part* is literally a parameter or a set of data.
**Data** can have the following *Type*s.
- **Variable** is a number, used as a parameter.
- **String** is a string, mainly used to specify the wave path.
- **Wave1D**, **Wave2D**, **Wave3D**, and **Wave4D** are number waves.
- **TextWave** is a text wave, used as a list of strings. It is useful to perform sequential analysis.

Some **Wave1D** parts have a special purpose; they contain only three elements describing the offset, delta, and size of a wave.
Such waves are generated from information functions such as **WaveInfo1D** and used as inputs of various functions.

**Data** *Part*s are global variables (**Variable**), global strings (**String**) and waves (**Wave*X*D** and **TextWave**) in the **Data** folder.

### Function
A **Function** *Part* connects **Data** *Part*s.
The *Type* of the **Function** specifies a pair of functions **Function/S IAFf\_*Type*\_Defintion()** and **Function IAFf\_*Type*(argumentList)**.

**IAFf\_*Type*\_Defintion()** returns a string list according to the following rule.
- The 0th element specifies the number of related *Part*s **n** (both inputs and outputs are included).
- The successive **n** elements specify whether the *Part* is the input ("0") or the output ("1").
- The successive **n** elements specify the *Type* of the *Part*. 
  - When the *Part* is **Data**, the corresponding element simply represents the *Type*.
  - When the *Part* is **Module**, the elements represents the *Type* of the **Socket** which the **Module** *Part* has as the waiting socket.

For example, ```"2;0;1;Wave2D;Wave1D"``` represents that the **Function** has one input of **Wave2D** and one output of **Wave1D**.

**IAFf\_*Type*(argumentList)** is the main executable of the **Function**.
**argumentList** is the list of argument names.
The function does not return any value, because it can directly modify the output **Data** *Part*s based on the names in the list.

The **ConfigureDependency** process (```IAFf_ConfigureDependency()```) checkes whether the *Part*s listed in the 3rd and successive columns of a **Function** *Part* row have correct *Type*s.
If not, the function raises an error.

#### Module(モジュール)
- いくつかのデータを入力に持つ。
- 入力を受け付けるソケットを持つ。別のモジュールに入力を行うソケットを持つ場合もある。
- ソケットがインデックスまたは座標のリスト（Wave2D）を受け取ると処理が実行され、対応する値のリスト（Wave1D）を返す。データを出力することはない。
- 処理の過程で、別のモジュールに入力を行い返された値を用いる場合もある。
- 型がモジュールの種類に対応する。
- 3列目以降は、引数となるデータ・ソケット接続するモジュールの名前を必要な個数だけ順番に並べる。入力を受け付けるソケットの欄は空でよい。

#### Socket(ソケット)
- 2つのモジュール・関数をつなげ、一方からもう一方にインデックスまたは座標のリストを渡し処理を行わせる。
- 引数として渡すリスト（Wave2D）の種類によって以下の型に分類される。すべてのソケットで、返す値は数のリスト（Wave1D）になる。
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
- Function/S **IAFf\_** ***FuncType*** **\_Definition()**: 引数データ（またはソケット接続するモジュール）の情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: 引数が入力であれば"0"、出力であれば"1"。入力受け付けソケット("2")はない。出力引数データが他の関数の出力にもなることはできない(他の関数の入力になることはある)。
  - \[n+1-2n\]: 引数の型
- Function **IAFf\_** ***FuncType*** **(argumentList)** : 実行される関数。**IAF\_** ***FuncType*** **\_Definition()** のリストに従ったデータ・モジュールの名前が文字列リストで入力されるので、処理を行う。データを更新することで出力とするので、```return```で値を返すことはない。

#### Module
以下のProcedure Functionとして存在する。***ModuleType***は各モジュールの型に対応する。
- Function/S **IAFm\_** ***ModuleType*** **\_Definition()** : 引数データ（またはソケット接続するモジュール）の情報を文字列リストで返す。
  - \[0\]: 引数の数**n**
  - \[1-n\]: 引数が入力であれば"0"、入力受け付けソケットであれば"2"(リスト内に1つ)。出力("1")はない。
  - \[n+1-2n\]: 引数の型
- Function/S **IAFm\_** ***ModuleType*** **(argumentList)** : 実行される関数。入力受付ソケットの部分はインデックスまたは座標のリスト（Wave2D）の名前、それ以外は**IAF\_** ***FuncType*** **\_Definition()** のリストに従ったデータの名前が文字列リストで入力される。値のリスト（Wave1D）の名前を```return```で返す。
- Function **IAFm\_** ***ModuleType*** **\_F(argumentList)** (任意): 入力引数から想定される、出力Waveのスケール(size, offset, delta)を返す関数。ソケットからWaveを生成する際に有用となる。 ***FuncType*** = ***ModuleType*** \_FormatのFunctionなので **\_Format_Definition()** も必要であることに注意（出力は必ずWave1D×次元の個数になる）。

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
  
#### Variables for Flowchart and Panels
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
- **CleanData** Dataディレクトリ内の不必要なWave・Variable・Stringを削除する。

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
