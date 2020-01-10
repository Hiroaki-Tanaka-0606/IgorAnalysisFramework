# IgorAnalysisFramework
Igor上で、生データからグラフまでの処理をフローチャート的に構築する。

## 構成
- カレントフォルダ直下に以下のフォルダを用意する。
  - **Diagrams** フローチャートを記述するWave(Text, 2D, 複数可)を格納する。
  - **Data** データを格納する。

## フローチャート
フローチャートを記述するWaveでは、以下の順で部品の性質を並べる。
- 0行目: 部品の種類(Data, Equation, Function, Module, Socket, Panel)
- 1行目: 部品の型
- 2行目: 部品の名前(他のWaveを含めて、重複不可)
- 3行目以降: 部品のプロパティ(input, output)

### 部品の種類
#### Data(データ)
以下の型を持つ。プロパティはない。
- Variable: 数
- String: 文字列
- Wave1D, Wave2D, Wave3D: 1, 2, 3次元Wave(Double Precision)
- TextWave: 1次元Text Wave

#### Equation(関数)
