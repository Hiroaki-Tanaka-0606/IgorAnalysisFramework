# LoadWave
ソースコードは **IAF_LoadWave.ipf** のひとつ。
## 目次
### Wave読み込み
- [Function **LoadWave1D**](#LoadWave1D)
- [Function **LoadWave2D**](#LoadWave2D)
- [Function **LoadWave3D**](#LoadWave3D)
### WaveInfo
- [Function **WaveInfo1D**](#WaveInfo1D)
- [Function **WaveInfo2D**](#WaveInfo2D)
- [Function **WaveInfo3D**](#WaveInfo3D)
- [Function **FullRange**](#FullRange)

## LoadWave1D
1D Waveを読み込む。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave1D.svg?sanitize=true" width=300>

#### 0th argument(input, String)
読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
#### 1st argument(output, Wave1D)
読み込んだWave。

## LoadWave2D
2D Waveを読み込む。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave2D.svg?sanitize=true" width=300>

#### 0th argument(input, String)
読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
#### 1st argument(output, Wave2D)
読み込んだWave。

## LoadWave3D
3D Waveを読み込む。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/LoadWave3D.svg?sanitize=true" width=300>

#### 0th argument(input, String)
読み込むWaveの相対パス（起点はカレントフォルダ）。カレントフォルダ直下にあればWaveの名前そのままでよいし、カレントフォルダ内の何らかのフォルダ内にあれば```Folder:WaveName```となる。
#### 1st argument(output, Wave3D)
読み込んだWave。

## WaveInfo1D
1D Waveの軸スケール情報を返す。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/WaveInfo1D.svg?sanitize=true" width=300>

#### 0th argument(input, Wave1D)
参照するWave。

#### 1st argument(output, Wave1D)
Waveの1st indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

## WaveInfo2D
2D Waveの軸スケール情報を返す。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/WaveInfo2D.svg?sanitize=true" width=300>

#### 0th argument(input, Wave2D)
参照するWave。

#### 1st argument(output, Wave1D)
Waveの1st indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

#### 2nd argument(output, Wave1D)
Waveの2nd indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

## WaveInfo3D
3D Waveの軸スケール情報を返す。

#### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/WaveInfo3D.svg?sanitize=true" width=300>

#### 0th argument(input, Wave3D)
参照するWave。

#### 1st argument(output, Wave1D)
Waveの1st indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

#### 2nd argument(output, Wave1D)
Waveの2nd indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

#### 3rd argument(output, Wave1D)
Waveの3rd indexに関する情報を持つWave。データは3個で、```DimOffset```・```DimDelta```・```DimSize```の値が並ぶ。

## FullRange
WaveInfoを基に、幅全体を指定する（両端含む）ためのVariableを作る。

### Diagram
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/raw/master/00.%20Resources/FullRange.svg?sanitize=true" width=300>

#### 0th argument(input, Wave1D)
Waveのあるindexに関する情報を持つWave。**WaveInfo1D**・**WaveInfo2D**・**WaveInfo3D**の出力として得られるものを用いる。

#### 1st argument(output, Variable)
幅全体を指定するときの開始値。常に0。

#### 2nd argument(output, Variable)
幅全体を指定するときの終了値。**input\[2\]-1**の値となる。
