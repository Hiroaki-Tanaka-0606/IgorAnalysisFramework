
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
