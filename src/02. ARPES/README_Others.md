# Others

## 目次
- [Module **Invert2D**](#Invert2D) in **IAF_Invert.ipf** 
- [Function **Invert2D_F**](#Invert2D_F) in **IAF_Invert.ipf** 
- [Function **DivideWave2D**](#DivideWave2D) in **IAF_DivideWave.ipf** 
- [Function **Integrate1D**](#Integrate1D) in **IAF_Integration.ipf** 

## Invert2D
2D Waveの軸を反転する。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/Invert2D.svg?sanitize=true" width=300>

### 0th argument(input, Variable)
1st indexの軸を反転するかを指定するパラメーター。1ならば反転し、0ならば反転しない。

処理上は1以外だと反転しないが、0/1で指定することを想定している（1st argumentも同じ）。

### 1st argument(input, Variable)
2nd indexの軸を反転するかを指定するパラメーター。1ならば反転し、0ならば反転しない。

### 2nd argument(input, Coordinate2D)
処理対象のWaveに相当する座標ソケット。

### 3rd argument(output, Coordinate2D)
反転後の座標を渡してくるソケット。

## Invert2D_F
**Invert2D** で変換されたマッピングのWaveInfoを返す。


### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/Invert2D_F.svg?sanitize=true" width=300>

### 0th argument(input, Variable)
1st indexの軸を反転するかを指定するパラメーター。1ならば反転し、0ならば反転しない。

### 1st argument(input, Variable)
2nd indexの軸を反転するかを指定するパラメーター。1ならば反転し、0ならば反転しない。

### 2nd argument(input, Wave1D)
1st indexに対応する**変換前** のWaveInfo。

### 3rd argument(input, Wave1D)
2nd indexに対応する**変換前** のWaveInfo。

### 4th argument(input, Wave1D)
1st indexに対応する**変換後** のWaveInfo。

### 5th argument(input, Wave1D)
2nd indexに対応する**変換後** のWaveInfo。


## DivideWave2D
2つの2D Wave間で割り算をする。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/DivideWave2D.svg?sanitize=true" width=300>

### 0th argument(input, Wave2D)
割られる側のWave。

### 1st argument(input, Wave2D)
割る側のWave。

0th argumentと1st argumentは同じサイズである必要がある。

### 2nd argument(input, Variable)
割る側の値の最小値。小さすぎる値で割って商が発散するのを防ぐ。

### 3rd argument(input, Wave2D)
割った商の値を出力するWave。

## Integrate1D
1D Waveのピクセル統合を行う。2Dや3Dではデータサイズ削減のためbox smoothing(no overlap)で行うことが望ましい。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/Integrate1D.svg?sanitize=true" width=300>

### 0th argument(input, Wave1D)
処理対象のWave。

### 1st argument(input, Variable)
統合するピクセルの個数。

### 2nd argument(input, Variable)
統合処理におけるオフセット。入力された個数だけデータを切り捨ててから、1st argumentで指定された個数ずつ足し合わせていく。

### 3rd argument(output, Wave1D)
処理後のWave。
