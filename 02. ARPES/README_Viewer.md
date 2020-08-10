# Viewer

ソースコードは **IAF_2DViewer.ipf** と **IAF_3DViewer.ipf** と **IAF_Socket3DViewer** の3つ。

## 目次
- [Function **EDC**](#EDC)
- [Function **MDC**](#MDC)
- [Function **ExCut**](#ExCut)
- [Function **EyCut**](#EyCut)
- [Funciton **xyCut**](#xyCut)
- [Function **CutLines2D**](#CutLines2D)
- [Function **CutLines3D**](#CutLines3D)
- [Function **CutLines3D2**](#CutLines3D2)
- [Function **Value2Index**](#Value2Index)
- [Function **DeltaChange**](#DeltaChange)
- [Panel&Template **2DViewer**](#2DViewer)
- [Panel&Template **3DViewer**](#3DViewer)
- [Template **Socket3DViewer**](#Socket3DViewer)

## EDC
Energy distribution curve(EDC)を生成する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/EDC.svg?sanitize=true" width=275>

#### 0th argument(input, Wave2D)
EDCを生成するWave。1st indexがエネルギー、2nd indexが波数または角度。

#### 1st argument(input, Variable)
EDCの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
EDCの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
EDC。```input[][start]```から```input[][end]```までの和となる。

## MDC
Momentum distribution curve (MDC)を生成する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/MDC.svg?sanitize=true" width=275>

#### 0th argument(input, Wave2D)
MDCを生成するWave。1st indexがエネルギー、2nd indexが波数または角度。

#### 1st argument(input, Variable)
MDCの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
MDCの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
MDC。```input[start][]```から```input[end][]```までの和となる。

## ExCut
Energy-x mapを生成する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/ExCut.svg?sanitize=true" width=275>

#### 0th argument(input, Wave3D)
Energy-x mapを生成するWave。1st indexがエネルギー、2nd・3rd indexが波数または角度(x・y)。

#### 1st argument(input, Variable)
Energy-x mapの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
Energy-x mapの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
Energy-x map。```input[][][start]```から```input[][][end]```までの和となる。

## EyCut
Energy-y mapを生成する。

#### Diagram 
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/EyCut.svg?sanitize=true" width=275>

#### 0th argument(input, Wave3D)
Energy-y mapを生成するWave。1st indexがエネルギー、2nd・3rd indexが波数または角度(x・y)。

#### 1st argument(input, Variable)
Energy-y mapの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
Energy-y mapの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
Energy-y map。```input[][start][]```から```input[][end][]```までの和となる。

## xyCut
x-y mapを生成する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/xyCut.svg?sanitize=true" width=275>

#### 0th argument(input, Wave3D)
x-y mapを生成するWave。1st indexがエネルギー、2nd・3rd indexが波数または角度(x・y)。

#### 1st argument(input, Variable)
x-y mapの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
x-y mapの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
x-y map。```input[start][][]```から```input[end][][]```までの和となる。

## CutLines2D
EDC・MDCの範囲を表す線を生成する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/CutLines2D.svg?sanitize=true" width=305>

#### 0th argument(input, Wave2D)
EDC・MDCの範囲を表示するWave。

#### 1st & 2nd arguments(input, Variable)
EDCの波数積算範囲。[Function EDC](#EDC)で用いたものと同じ。

#### 3rd & 4th arguments(input, Variable)
MDCのエネルギー積算範囲。[Function MDC](#MDC)で用いたものと同じ。

#### 5th argument(output, Wave2D)
EDCの波数範囲表示。1st indexがエネルギー(```(-infinity,infinity)```)、2nd indexが波数になっていて、4点を繋げば積算範囲の境界を描く。

#### 6th argument(output, Wave2D)
MDCのエネルギー範囲表示。1st indexがエネルギー、2nd indexが波数(```(-infinity,infinity)```)になっていて、4点を繋げば積算範囲の境界を描く。

## CutLines3D
Energy-x・Energy-y・x-y mapsの範囲を表す線を生成する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/CutLines3D.svg?sanitize=true" width=305>

#### 0th argument(input, Wave3D)
Energy-x・Energy-y・x-y mapsの範囲を表示するWave。

#### 1st & 2nd arguments(input, Variable)
x-y mapにおけるエネルギー積算範囲。[Function xyCut](#xyCut)で用いたものと同じ。

#### 3rd & 4th arguments(input, Variable)
Energy-y mapにおけるx波数の積算範囲。[Function EyCut](#EyCut)で用いたものと同じ。

#### 5th & 6th arguments(input, Variable)
Energy-x mapにおけるy波数の積算範囲。[Function ExCut](#ExCut)で用いたものと同じ。

#### 7th argument(output, Wave2D)
x-y mapのエネルギー範囲表示。1st indexがエネルギー、2nd indexがx波数またはy波数(```(-infinity,infinity)```)になっていて、4点を繋げば積算範囲の境界を描く。Energy-x・Energy-y mapsに現れる。

#### 8th argument(output, Wave2D)
E-y mapのx波数範囲表示。1st indexがx波数、2nd indexがエネルギーまたはy波数```(-infinity,infinity)```になっていて、4点を繋げば積算範囲の境界を描く。Energy-x・x-y mapsに現れる。

#### 9th argument(output, Wave2D)
E-x mapのy波数範囲表示。1st indexがy波数、2nd indexがエネルギーまたはx波数(```(-infinity,infinity)```)になっていて、4点を繋げば積算範囲の境界を描く。Energy-y・x-y mapsに現れる。


## CutLines3D2
Energy-x・Energy-y・x-y mapsの範囲を表す線を生成する。Socket3DViewer用。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/CutLines3D2.svg?sanitize=true" width=305>

#### 0th argument(input, Wave1D)
1st index（エネルギー）に関するWaveの情報。


#### 1st argument(input, Wave1D)
2nd index（x）に関するWaveの情報。

#### 2nd argument(input, Wave1D)
3rd index（y）に関するWaveの情報。

#### 3rd & 4th arguments(input, Variable)
x-y mapにおけるエネルギー積算範囲。[Function xyCut](#xyCut)で用いたものと同じ。

#### 5th & 6th arguments(input, Variable)
Energy-y mapにおけるx波数の積算範囲。[Function EyCut](#EyCut)で用いたものと同じ。

#### 7th & 8th arguments(input, Variable)
Energy-x mapにおけるy波数の積算範囲。[Function ExCut](#ExCut)で用いたものと同じ。

#### 9th argument(output, Wave2D)
x-y mapのエネルギー範囲表示。1st indexがエネルギー、2nd indexがx波数またはy波数(```(-infinity,infinity)```)になっていて、4点を繋げば積算範囲の境界を描く。Energy-x・Energy-y mapsに現れる。

#### 10th argument(output, Wave2D)
E-y mapのx波数範囲表示。1st indexがx波数、2nd indexがエネルギーまたはy波数```(-infinity,infinity)```になっていて、4点を繋げば積算範囲の境界を描く。Energy-x・x-y mapsに現れる。

#### 11th argument(output, Wave2D)
E-x mapのy波数範囲表示。1st indexがy波数、2nd indexがエネルギーまたはx波数(```(-infinity,infinity)```)になっていて、4点を繋げば積算範囲の境界を描く。Energy-y・x-y mapsに現れる。

## Value2Index
軸スケールされた中央値・幅で表された範囲を整数インデックスに変換する。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/Value2Index.svg?sanitize=true" width=310>

#### 0th argument(input, Wave1D)
あるindexに関するWaveの情報。[Function WaveInfo1D](#WaveInfo1D)・[Function WaveInfo2D](#WaveInfo2D)・[Function WaveInfo3D](#WaveInfo3D)から出力されるものを用いればよい。

#### 1st argument(input, Variable)
範囲の中央値。範囲インデックスが整数になるように値は更新される。

#### 2nd argument(input, Variable)
範囲の幅。範囲インデックスが整数になるように値は更新される。

#### 3rd argument(output, Variable)
範囲インデックスの開始値。

#### 4th argument(output, Variable)
範囲インデックスの終了値。

## DeltaChange
インデックスが±1変化することに対応して値を変化させる。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/DeltaChange.svg?sanitize=true" width=310>

#### 0th argument(input, Wave1D)
あるindexに関するWaveの情報。[Function WaveInfo1D](#WaveInfo1D)・[Function WaveInfo2D](#WaveInfo2D)・[Function WaveInfo3D](#WaveInfo3D)から出力されるものを用いればよい。

#### 1st argument(input, Variable)
インデックスの変化。±1だった場合のみ2nd argumentの値が変化する。処理後は値は0になる。

#### 2nd argument(output, Variable)
インデックスの変化に対応して変化する値。

## 2DViewer

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/2DViewer.svg?sanitize=true">

#### View example
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/2DViewer_view2.png" width=455>

(1) \_edc\_start
(2) \_edc\_end
(3) \_mdc\_start
(4) \_mdc\_end
(5) \_edc\_center
(6) \_edc\_width
(7) \_mdc\_center
(8) \_mdc\_width
(9) **+** を押すと\_edcwidthdeltaが1に、**-** を押すと-1になる。
(10) **+** を押すと\_mdcwidthdeltaが1に、**-** を押すと-1になる。
(11) MDC
(12) ***WaveName*** で入力されるWave2D
(13) EDC
(14) 上下のサイズ比を変更できるスライダー
(15) 左右のサイズ比を変更できるスライダー

カーソルキー左右で\_edccenterdeltaが±1に、カーソルキー上下で\_mdccenterdeltaが±1になる。

#### Template 0th argument(String ***PanelName***)
パネルの表示名。接尾辞にも使われる。

#### Template 1st argument(Wave2D ***WaveName***)
表示し、EDC・MDCを生成するWave。

#### Template 2nd argument(String ***xLabel***)
x軸のラベル。

## 3DViewer

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/3DViewer.svg?sanitize=true">

#### View example
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/3DViewer_view2.png" width=455>

(1) \_Ex\_start
(2) \_Ex\_end
(3) \_Ey\_start
(4) \_Ey\_end
(5) \_xy\_start
(6) \_xy\_end
(7) \_ExCenter
(8) \_ExWidth
(9) \_EyCenter
(10) \_EyWidth
(11) \_xyCenter
(12) \_xyWidth
(13) **+** を押すと\_ExWidthDeltaが1に、**-** を押すと-1になる。
(14) **+** を押すと\_EyWidthDeltaが1に、**-** を押すと-1になる。
(15) **+** を押すと\_xyWidthDeltaが1に、**-** を押すと-1になる。
(16) EyCut
(17) xyCut
(18) ExCut
(19) 上下のサイズ比を変更できるスライダー
(20) 左右のサイズ比を変更できるスライダー

カーソルキー上下左右で、選択中のパネルに対応するCenterDeltaが±1になる。


#### Template 0th argument(String ***PanelName***)
パネルの表示名。接尾辞にも使われる。

#### Template 1st argument(Wave3D ***WaveName***)
Energy-x・Energy-y・x-y mapsを生成するWave。

#### Template 2nd argument(String ***xLabel***)
x軸のラベル。

#### Template 3rd argument(String ***yLabel***)
y軸のラベル。



## Socket3DViewer

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/Socket3DViewer.svg?sanitize=true">

Viewは3DViewerを使う。

#### Template 0th argument(String ***PanelName***)
パネルの表示名。接尾辞にも使われる。

#### Template 1st argument(Coordinate3D ***SocketName***)
3D Waveに相当するソケット。

#### Template 2nd argument(Wave1D ***EInfo***)
1st index（エネルギー）に関するWaveの情報。

#### Template 3rd argument(Wave1D ***xInfo***)
2nd index（x）に関するWaveの情報。

#### Template 4th argument(Wave1D ***yInfo***)
3rd index（y）に関するWaveの情報。

#### Template 5th argument(String ***xLabel***)
x軸のラベル。

#### Template 6th argument(String ***yLabel***)
y軸のラベル。
