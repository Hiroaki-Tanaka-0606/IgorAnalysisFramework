# Readme for ARPES Analysis
## 注意事項
- 図では部品の型のみをフローチャートに表示している。実際のフローチャートでは2行目に部品の名前も表示される。
- \[x\]はDiagram Waveの3行目以降に記述するデータの順番を表す。\[x\]は3+x列目に現れる。
- 矢印は見やすくなるよう折れ線にしていることがある。実際のフローチャートではすべて部品の間を直線でつないでいる。

## 目次
### Wave読み込み
- [LoadWave1D](#LoadWave1D)
- [LoadWave2D](#LoadWave2D)
- [LoadWave3D](#LoadWave3D)
### WaveInfo
- [WaveInfo1D](#WaveInfo1D)
- [WaveInfo2D](#WaveInfo2D)
- [WaveInfo3D](#WaveInfo3D)

## LoadWave1D
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave1D.svg?sanitize=true" width=300>

- 0th argument(input, String): 読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
- 1st argument(output, Wave1D): 読み込んだWave。

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
