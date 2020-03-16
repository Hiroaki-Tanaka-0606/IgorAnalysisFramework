# Readme for ARPES Analysis
## 注意事項
- 図では部品の型のみをフローチャートに表示している。実際のフローチャートでは2行目に部品の名前も表示される。
- \[x\]はDiagram Waveの3行目以降に記述するデータの順番を表す。\[x\]は3+x列目に現れる。
- 矢印は見やすくなるよう折れ線にしていることがある。実際のフローチャートではすべて部品の間を直線でつないでいる。

## 目次
### Wave読み込み
- [Function **LoadWave1D**](#LoadWave1D)
- [Function **LoadWave2D**](#LoadWave2D)
- [Function **LoadWave3D**](#LoadWave3D)
### WaveInfo
- [Function **WaveInfo1D**](#WaveInfo1D)
- [Function **WaveInfo2D**](#WaveInfo2D)
- [Function **WaveInfo3D**](#WaveInfo3D)
### Viewer関連
- [Function **EDC**](#EDC)
- [Function **MDC**](#MDC)
- [Function **ExCut**](#ExCut)
- [Function **EyCut**](#EyCut)
- [Funciton **xyCut**](#xyCut)
- [Function **CutLines2D**](#CutLines2D)
- [Function **CutLines3D**](#CutLines3D)
- [Function **Value2Index**](#Value2Index)
- [Function **DeltaChange**](#DeltaChange)
- [Panel&Template **2DViewer**](#2DViewer)
- [Panel&Template **3DViewer**](#3DViewer)

## LoadWave1D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave1D.svg?sanitize=true" width=300>

#### 0th argument(input, String)
読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
#### 1st argument(output, Wave1D)
読み込んだWave。

## LoadWave2D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave2D.svg?sanitize=true" width=300>

#### 0th argument(input, String)
読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
#### 1st argument(output, Wave2D)
読み込んだWave。

## LoadWave3D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave3D.svg?sanitize=true" width=300>

#### 0th argument(input, String)
読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
#### 1st argument(output, Wave3D)
読み込んだWave。

## WaveInfo1D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/WaveInfo1D.svg?sanitize=true" width=300>

#### 0th argument(input, Wave1D)
参照するWave。

#### 1st argument(output, Wave1D)
Waveの1st indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

## WaveInfo2D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/WaveInfo2D.svg?sanitize=true" width=300>

#### 0th argument(input, Wave2D)
参照するWave。

#### 1st argument(output, Wave1D)
Waveの1st indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

#### 2nd argument(output, Wave1D)
Waveの2nd indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

## WaveInfo3D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/WaveInfo3D.svg?sanitize=true" width=300>

#### 0th argument(input, Wave3D)
参照するWave。

#### 1st argument(output, Wave1D)
Waveの1st indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

#### 2nd argument(output, Wave1D)
Waveの2nd indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

#### 3rd argument(output, Wave1D)
Waveの3rd indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

## EDC
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/EDC.svg?sanitize=true" width=275>

#### 0th argument(input, Wave2D)
Energy distribution curve (EDC)を生成するWave。1st indexがエネルギー、2nd indexが波数または角度。

#### 1st argument(input, Variable)
EDCの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
EDCの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
EDC。```input[][start]```から```input[][end]```までの和となる。

## MDC
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/MDC.svg?sanitize=true" width=275>

#### 0th argument(input, Wave2D)
Momentum distribution curve (MDC)を生成するWave。1st indexがエネルギー、2nd indexが波数または角度。

#### 1st argument(input, Variable)
MDCの積算範囲の開始インデックス。

#### 2nd argument(input, Variable)
MDCの積算範囲の終了インデックス。

#### 3rd argument(output, Wave1D)
MDC。```input[start][]```から```input[end][]```までの和となる。

## ExCut
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

## Value2Index
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

## 2DViewer

## 3DViewer

