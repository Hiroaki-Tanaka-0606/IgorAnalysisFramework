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
- **LoadTextWave**
- **WaveInfo1D**
- **WaveInfo2D**
- **WaveInfo3D**
- **WaveInfoText**
- **FullRange**
- **StoreWave1D**
- **StoreWave2D**

### Viewer
[Source (2D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_2DViewer.ipf)
[Source (3D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_3DViewer.ipf)
[Source (Socket3D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Socket3DViewer.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_Viewer.md)
#### Functions
- **EDC**
- **MDC**
- **ExCut**
- **EyCut**
- **xyCut**
- **CutLines2D**
- **CutLines3D**
- **CutLines3D2**
- **Value2Index**
- **DeltaChange**

#### Panels and Templates
- **2DViewer**
- **3DViewer**
- **Socket3DViewer**

### Fitting
[Source (FermiEdge)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_FermiEdgeFit.ipf)
[Source (Polynomial)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_PolyFit.ipf
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_FermiEdgeFit.ipf)
#### Functions
- **FermiEdgeFit**
- **PolyFit**
#### Utility Functions
- **EfTrialFunc**
- **GaussianWave**

### Corrections
[Source (1D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Corrections1D.ipf)
[Source (2D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Corrections2D.ipf)
[Source (3D)](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Corrections3D.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_Corrections.ipf)

#### Functions
- **AveragedMDC**
- **MCPHistogram**
- **AveragedInt**
- **ConstantWave1D**
- **CorrectEf1D**
- **Make2D_Index**
- **Make2D_Coord**
- **MakeEx_Index**
- **MakeEy_Index**
- **Makexy_Index**
- **Make3D_Index**
- **MakeEx_Coord**
- **MakeEy_Coord**
- **Makexy_Coord**
- **Make3D_Coord**

#### Modules
- **CorrectInt_sw2D**
- **CorrectInt_fx2D**
- **ConvertIndex2D**
- **CorrectEf2D** (Format: **CorrectEf2D_F**)
- **CorrectInt_fx3D**
- **ConvertIndex3D**
- **CorrectEf3D** (Format: **CorrectEf3D_F**)
- **Smoothing2D** (Format: **Smoothing2D_F**)
- **Smoothing3D** (Format: **Smoothing3D_F**)

#### Panels
- **SmoothingCtrl2D**
- **SmoothingCtrl3D**

### ConvertAngle
[Source](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_ConvertAngle.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_ConvertAngle.ipf)

#### Modules
- **ConvAngle2D** (Format: **ConvAngle2D_F**)

#### Utility Functions
- **E2kConstant**

### Sequence
[Source](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Sequence.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_Sequence.ipf)

#### Functions
- **ExtractVariable**
- **ExtractString**
- **StoreVariable**
- **StoreWave13D**
- **StoreWave12D**
- **Mod**
- **Quotient**

#### Panels
- **Sequence**

### ColorTable
[Source](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_ColorTable.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_ColorTable.ipf)

#### Functions
- **ColorTable**
- **IntRange2D**

#### Panels
- **ColorTableCtrl**

### Others
[Invert](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Invert.ipf)
[DivideWave](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_DivideWave.ipf)
[Integration](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/IAF_Integration.ipf)
[Readme](https://github.com/Hiroaki-Tanaka-0606/IgorAnalysisFramework/blob/master/02.%20ARPES/README_Others.ipf)

#### Functions
- **DivideWave2D**
- **Integrate1D**

#### Modules
- **Invert2D** (Format: **Invert2D_F**)
