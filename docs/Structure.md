# Structure of the software
# Role of the folders
The folders created by the ```SetUp``` command have the following roles.
- The ```Diagrams``` folder includes **diagram wave**s (text, 2D). All two-dimensional text waves are used as diagram waves.
- The ```Data``` folder includes data (waves) and parameters (global variables and strings). We recommend not putting raw data in the ```Data``` folder to avoid a mess. Instead, we put a *String* specifying the path to the raw data and use *Function*s such as *LoadWave1D* to load the raw data in the ```Data``` folder.
- The ```Configurations``` folder includes the dependency relationships between the parts and configurations for the flowchart.
- The ```TempData``` folder includes temporary data passed via a *Socket*.

# *Part*s
Each row in the **diagram wave**s represents a *Part*.

## Description of *Part*s in the diagram waves
A *Part* is described by the following rules.
- The 0th column describes the *Kind* of the *Part*: *Data*, *Function*, *Module*, or *Panel*.
- The 1st column describes the *Type* of the *Part*. Allowed values for the *Type* depends on the *Kind* and are described below in more detail.
- The 2nd column describes the *Name* of the *Part*. The *Name* must be unique. If *Name*s are duplicated, or the *Name* cell is left blank, the ```ConfigureNames``` command (```IAFc_ConfigureNames()```) modifies the *Name*s appropriately.
- The other columns descibe the *Name*s of *Part*s used as the input or the output.

There is another *Kind* not listed above: *Socket*.
However, *Socket*s don't appear in the **diagram wave**s because they are automatically described between modules and functions.

## *Kind*s of *Part*s
### *Data*
A *Data Part* is literally a parameter or a set of data.
*Data Part*s can have the following *Type*s.
- *Variable* is a number used as a parameter.
- *String* is a string mainly used to specify the wave path.
- *Wave1D*, *Wave2D*, *Wave3D*, and *Wave4D* are number waves.
- *TextWave* is a text wave used as a list of strings. It is useful to perform sequential analysis.

Some *Wave1D* parts have a special purpose; they contain only three elements describing  a wave's offset, delta, and size.
These values corresponds to the ```DimOffset```, ```DimDelta```, and ```DimSize``` function in Igor Pro.
Hereafter we call them *InfoWave*s.
Such waves are generated from information functions such as *WaveInfo1D* and used as inputs for various functions.

*Data Part*s are global variables (*Variable*), global strings (*String*) and waves (*WaveXD* and *TextWave*) in the ```Data``` folder.

### *Function*
A *Function Part* connects *Data Part*s.
The *Type* of the *Function* specifies a pair of functions ```Function/S IAFf_[Type]_Defintion()``` and ```Function IAFf_[Type](argumentList)```.

```IAFf_Type_Defintion()``` returns a string list according to the following rule.
- The 0th element specifies the number of related *Part*s **n** (both inputs and outputs are included).
- The successive **n** elements specify whether the *Part* is the input (```"0"```) or the output (```"1"```).
- The successive **n** elements specify the *Type* of the *Part*. 
  - When the *Part* is *Data*, the corresponding element simply represents the *Type*.
  - When the *Part* is *Module*, the element represents the *Type* of the *Socket* which the *Module* *Part* has as the *Waiting Socket*.

For example, ```"2;0;1;Wave2D;Wave1D"``` represents that the *Function* has one input of *Wave2D* and one output of *Wave1D*.

```IAFf_[Type](argumentList)``` is the main executable of the *Function*.
```argumentList``` is the list of argument names.
The function does not return any value because it can directly modify the output *Data Part*s based on the names in the list.

The ```ConfigureDependency``` command (```IAFf_ConfigureDependency()```) checks whether the *Part*s listed in the 3rd and successive columns of a *Function Part* row have correct *Type*s.
If not, the function raises an error.

### Module
As a *Function* does, a *Module Part* also connects *Data Part*s.
The biggest difference is that a *Module* has a *Waiting Socket* and is executed when the socket receives data.
A *Module* is a conversion rule, not a conversion function.

The definition function for a *Module* is ```Function/S IAFm_[Type]_Definition()```, and the main function is ```Function/S IAFm_[Type](argumentList)```.
The definition function returns a string list according to the following rule, slightly different from that of *Function*.
- The 0th element specifies the number of related *Part*s **n** (both inputs and socket are included).
- The successive **n** elements specify whether the *Part* is the input (```"0"```) or the waiting socket (```"2"```). A *Module* cannot have an output.
- The successive **n** elements specify the *Type* of the *Part*. 
  - When the *Part* is *Data*, the corresponding element simply represents the *Type*.
  - When the *Part* is an input *Module*, the element represents the *Type* of the *Socket* which the *Module Part* has as the *Waiting Socket*.
  - When the *Part* is *Socket*, the element represents the *Type* of the *Socket* which this *Module* has as the *Waiting Socket*.

The main function ```Function/S IAFm_[Type](argumentList)``` receives the list of argument names.
The argument name at the position of the waiting socket represents the list of coordinates or indices (2D wave) for which the *Module* needs to perform the calculation.
The function returns a name of the list representing the calculated values for given positions.

Since a *Module* does not have a concrete data output, we recommend creating the **format function** named *\[Type\]\_F*.
The **format function** receives *InfoWave*s (and some parameters) and exports standard *InfoWave*s which the conversion affects.
'Standard' means users do not always need to use the output *InfoWave*s.

The ```ConfigureDependency``` process (```IAFf_ConfigureDependency()```) checks whether the *Part*s listed in the 3rd and successive columns of a *Module Part* row have correct *Type*s.
If not, the function raises an error.
The position of the waiting socket should be left blank because the socket does not have the *Name*.

### *Socket*
As mentioned above, a *Socket* connects a *Module* and another *Module* or a *Function*.
A *Socket* has the following *Type*s.
- *Coordinate1D*, *Coordinate2D*, *Coordinate3D* pass a list of coordinates (x, y, z) to a *Module*.
- *Index1D*, *Index2D*, *Index3D* pass a list of indices (p, q, r) to a *Module*.

### *Panel*
A *Panel Part* calls window(s) with variables or graphs.
A *Panel* is not only for visualization; a *Panel* can have input boxes in which users can enter values.
Entering values can immediately change the analysis result, as we describe later.

The defintion function for a *Panel* is ```Function/S IAFp_[Type]_Definition()```, and the execution function is ```Function IAFp_[Type](argumentList, PanelName, PanelTitle)```.
```PanelName``` is the *Name* of the *Panel Part*, and ```PanelTitle``` is ```"[PanelName] in [FolderPath]"```, displayed on the window.
Since a *Panel* does not return a value or have a socket, all connected *Data* or *Socket* *Part*s are input.

## Templates
Since the number of *Function* and *Data* *Part*s related to a *Panel* becomes sometimes large, users can use *Template*s to make a **diagram wave** containing them.
When you select the ```LoadTemplate``` submenu and enter an appropriate *TemplateType* and a list of arguments, ```IAFt_[TemplateType](argumentList)``` is executed.
The function makes a **diagram wave** containing necessary *Part*s for a *Panel*.
Some *Part*s use the *Part*s listed in the ```argumentList``` as inputs.
After the construction of the diagram, the function automatically executes necessary commands such as ```ConfigureDependency``` and ```ExecuteAll```.

# Name rules for functions
Here, functions literally mean those defined in the Igor Procedure files, not *Function Part*s.

The functions defined in the software start with ```IAF```.
Other objects, such as Procedure file names, also start with ```IAF``` to avoid name collision with other macros.
The next alphabet determines the occasion where the function is used.

- ```IAFc_~~``` is the name of the core function, such as ```IAFc_ExecuteAll()```.
- ```IAFf_~~``` is the name of the functions representing a *Function* part.
- ```IAFm_~~``` is the name of the functions representing a *Module* part.
- ```IAFp_~~``` is the name of the functions representing a *Panel* part.
- ```IAFt_~~``` is the name of the functions for *Template*s.
- ```IAFu_~~``` is the name of other utility functions, such as keyboard and button event handlers.