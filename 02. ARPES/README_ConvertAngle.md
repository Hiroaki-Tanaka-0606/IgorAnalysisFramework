# ConvertAngle
ソースコードは **IAF_ConvertAngle.ipf** のひとつ。

## 目次
- [Module **ConvAngle2D**](#ConvAngle2D)
- [Function **ConvAngle2D_F**](#ConvANgle2D_F)

### Utility Functions
- [Utility Function **E2kConstant**](#E2kConstant)


## ConvAngle2D
角度を波数に変換するモジュール。
実際は、ソケット入力された波数に対応する角度を逆算する。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ConvAngle2D.svg?sanitize=true" width=300>

### 0th argument(input, Variable)
Fermi準位にある光電子が励起されたときのエネルギー。
フォトンエネルギー(**<i>h</i>&nu;**)-仕事関数(**W**)の値に対応する。

### 1st argument(input, Variable)
垂直放射に対応する角度。

### 2nd argument(input socket, Coordinate2D)
(エネルギー, 角度) の座標を受け取り、その座標に対応する強度を返すソケット。
エネルギーはFermiエネルギーが0になるよう較正されていると想定している。

### 3rd argument(output socket, Coordinate2D)
(エネルギー, 波数)の座標を渡してくるソケット。

### 角度と波数の変換
0th argumentの値を <img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;E_\text{ph}">、1st argumentの値を <img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\theta_0"> で表す。

結合エネルギー <img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;E_B<0">の準位から放出された光電子はエネルギー<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;E_\text{ph}&plus;E_B">を持つ。

真空中では、光電子は平面波の分散関係<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;E_\text{ph}+E_B=\frac{\hbar^2k^2}{2m}">に従う。

放出角度<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\theta">のとき、波数の面内成分は<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;k\sin(\theta-\theta_0)">で計算できる。

## ConvAngle2D_F
**ConvAngle2D** で変換されたマッピングの標準的なフォーマットを返す。
フォーマットはあくまで標準であり、より細かく/粗く/狭く/広くしても問題ない。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ConvAngle2D_F.svg?sanitize=true" width=300>

### 0th argument(input, Variable)
Fermi準位にある光電子が励起されたときのエネルギー。
フォトンエネルギー(**<i>h</i>&nu;**)-仕事関数(**W**)の値に対応する。

### 1st argument(input, Variable)
垂直放射に対応する角度。

### 2nd argument(input, Wave1D)
1st index（エネルギー）に対応する **変換前** のWaveInfo。

### 3rd argument(input, Wave1D)
2nd index（角度）に対応する **変換前** のWaveInfo。

### 4th argument(output, Wave1D)
1st index（エネルギー）に対応する **変換後**のWaveInfo。2nd argumentの入力を複製したものになる。

### 5th argument(output, Wave1D)
2nd index（波数）に対応する**変換後**のWaveInfo。
角度範囲をすべてカバーするし、同じデータ数になるよう設定される。

## E2kConstant
光電子エネルギーを波数に変換する式<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;k=\frac{\sqrt{2m}}{\hbar}\sqrt{E}">において、定数<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\frac{\sqrt{2m}}{\hbar}">を計算する。
<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;E">はeV単位、<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;k">は<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\textrm{\AA}^{-1}">単位となるようにすると、<img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\frac{\sqrt{2m}}{\hbar}\fallingdotseq&space;0.512">である。
