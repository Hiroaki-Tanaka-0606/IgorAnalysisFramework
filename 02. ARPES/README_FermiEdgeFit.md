# FermiEdgeFit
ソースコードはIAF_FermiEdgeFit.ipfのひとつ。

## 目次
### Functions
- [Function **FermiEdgeFit**](#FermiEdgeFit)

### Utility Functions
- [Utility Function **EfTrialFunc**](#EfTrialFunc)
- [Utility Function **GaussianWave**](#GaussianWave)

## FermiEdgeFit
Gaussianによるノイズが重層されたFermi分布関数でフィッティングを行う。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/FermiEdgeFit.svg?sanitize=true" width=300>

### 0th argument(input, Wave1D)
フィッティングの対象となるWave。

### 1st argument(input, Variable)
Fermiエネルギーの推定値\[eV\]。フィッティングの初期値に使用される。

### 2nd and 3rd arguments(input, Variable)
フィッティングに使う範囲。インデックス値で指定し、両端含む。

### 4th argument(input, Variable)
温度\[K\]。

### 5th argument(input, String)
6つのフィッティングパラメーターのうち固定する（フィッティングの過程で変化させない）ものを指定する。
固定する場合は **"1"** 、変化させる場合は **"0"** を順に並べた文字列を入力する。

### 6th argument(output, Wave1D)
フィッティングパラメーターが並んだWave。各パラメーターの役割は次節。

### 7th argument(output, Wave1D)
フィッティングの最終結果のWave。入力と同じ範囲で出力している。

## EfTrialFunc
パラメーターに対応し試行関数を出力する。
試行関数 **f(E)** は、**F(x)** （スロープのついたFermi分布関数） と **G(x)** （Gaussian）の畳み込みで求められる。
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;x=E-p_4" title="x=E-p_4" /></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;F(x)=\frac{1&plus;p_1&space;x}{e^{\beta&space;x}&plus;1}"></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;G(x)=\frac{1}{\sqrt{2\pi}\sigma}\exp\left(-\frac{x^2}{2\sigma^2}&space;\right&space;)"></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;f(E)=p_0\times&space;F(x)\otimes&space;G(x)&plus;p_2&plus;p_3&space;x"></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\beta=\frac{1}{k_B&space;T},\&space;\sigma=\frac{p_5}{2\sqrt{2\log&space;2}}"></p>

**p<sub>0</sub>** ～ **p<sub>5</sub>** がフィッティングパラメーターであり、それぞれの意味は以下の通りである。
- **p<sub>0</sub>**: スペクトル強度
- **p<sub>1</sub>**: スロープの傾き
- **p<sub>2</sub>**: バックグラウンド強度
- **p<sub>3</sub>**: バックグラウンドのスロープの傾き
- **p<sub>4</sub>**: Fermiエネルギー
- **p<sub>5</sub>**: Gaussianの幅（半値全幅）

温度は入力で与えられる定数であり、**TempData**ディレクトリ内のGlobal Variableを介して**EfTrialFunc**に渡される。

## GaussianWave
分散 **sigma** が与えられたときに、Gauss分布関数を表すWaveを作る。
