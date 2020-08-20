# ColorTable
ソースコードは **IAF_ColorTable.ipf** のひとつ。

## 目次
- [Function **ColorTable**](#ColorTable)
- [Function **IntRange2D**](#IntRange2D)
- [Panel **ColorTableCtrl**](#ColorTableCtrl)

## ColorTable
Image plotに使えるカラーテーブルを作る。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ColorTable.svg?sanitize=true" width=300>

### 0th argument(input, Wave2D)
グラデーションを指定するWave。
1st indexは分岐点のインデックスに対応する。
2nd indexは、以下の規則に従う。
- **\[i\]\[0\]** : 分岐点の相対座標。\[i\]の座標は\[i+1\]より小さくなければならない。
- **\[i\]\[1\]** : 赤(R)の値。値の範囲は0から65535まで（以下同様）。
- **\[i\]\[2\]** : 緑(G)の値。
- **\[i\]\[3\]** : 青(B)の値。

### 1st argument(input, Variable)
カラーテーブルの下端に対応する強度。

### 2nd argument(input, Variable)
カラーテーブルの上端に対応する強度。

### 3rd argument(input, Variable)
&gamma;値。役割は後述。

### 4th argument(input, Variable)
カラーテーブルの分割数。出力されるカラーテーブルはこの値+1のデータ点を持つ。

### 5th argument(output, Wave2D)
生成されたカラーテーブル。

### カラーテーブルの計算式
1.  0th argumentで入力されたグラデーションを、始点が0、終点が1の相対座標 **Y** にリスケールする。
1.  2nd & 3rd argumentsに従い、強度も始点（カラーテーブルの下端）が0、終点(上端)が1の相対座標 **X** にリスケールする。
1.  **Y=X<sup>&gamma;</sup>** の関係により、**X**をグラデーション上の色に変換する。

&gamma;は1であれば線形に変化するグラデーション、1より大きいと上端側で早く変化するグラデーション、1より小さいと下端側で早く変化するグラデーションになる。

### カラーテーブルの例
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ColorTable_example.png" width=300>

## IntRange2D
2D Waveの値の最大値と最小値を出力する。
カラーテーブルの範囲決めの参考にできる。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/IntRange2D.svg?sanitize=true" width=300>

### 0th argument(input, Wave2D)
入力。

### 1st argument(output, Variable)
強度の最小値。

### 2nd argument(output, Variable)
強度の最大値。

## ColorTableCtrl
カラーテーブルのパラメーターを調節する。
グラデーションの分岐点や色は調節できないので、Tableを開いて手入力→**IAFc_Update(***GradationWaveName***)** で更新ができる。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ColorTableCtrl.svg?sanitize=true" width=200>

### 0th & 1st arguments(input, Variable)
カラーテーブルの範囲決めの参考となるべき下端と上端の値。
**IntRange2D** の出力を使うことが想定されている。

### 2nd & 3rd arguments(input, Variable)
カラーテーブルの範囲を入力する欄。**ColorTable**の入力に使うことが想定されている。

### 4th argument(input, Variable)
&gamma;値を入力する欄。**ColorTable**の入力に使うことが想定されている。

### 5th argument(input, Variable)
カラーテーブルの分割数を入力する欄。**ColorTable**の入力に使うことが想定されている。

### Panel Image
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ColorTableCtrl_view.png" width=300>

(1) 0th argument（入力不可） (2) 1st argument（入力不可） (3) 2nd argument （入力可） (4) 3rd argument（入力可） (5) 4th argument（入力可） (6) 5th argument（入力可）
