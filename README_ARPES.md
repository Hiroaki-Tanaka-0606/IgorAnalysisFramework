# Readme for ARPES Analysis
## 注意事項
- Function・Moduleの説明の場合、図では部品の型のみをフローチャートに表示している。実際のフローチャートでは2行目に部品の名前も表示される。
- \[x\]はDiagram Waveの3列目以降に記述するデータの順番を表す。\[x\]は3+x列目に現れる。Templateの説明では、\[x\]は対応するPanelへの入力順序である。
- 矢印は見やすくなるよう折れ線にしていることがある。実際のフローチャートではすべて部品の間を直線でつないでいる。
- Panelに入力される矢印は省略することがある。
- Templateの説明の場合、部品の名前はサフィックスを無視したような感じになっている。**argumentList**で名前を指定するものについてはイタリックになっている。

## 目次
### LoadWave
[Source](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_LoadWave.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_LoadWave.md)
#### Functions
- **LoadWave1D**
- **LoadWave2D**
- **LoadWave3D**
- **WaveInfo1D**
- **WaveInfo2D**
- **WaveInfo3D**

### Viewer
[Source (2D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_2DViewer.ipf)
[Source (3D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_3DViewer.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_Viewer.md)
#### Functions
- **EDC**
- **MDC**
- **ExCut**
- **EyCut**
- **xyCut**
- **CutLines2D**
- **CutLines3D**
- **Value2Index**
- **DeltaChange**

#### Panels and Templates
- **2DViewer**
- **3DViewer**

### FermiEdgeFit
[Source](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_FermiEdgeFit.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_FermiEdgeFit.ipf)
#### Functions
- **FermiEdgeFit**
#### Utility Functions
- **EfTrialFunc**
- **GaussianWave**
