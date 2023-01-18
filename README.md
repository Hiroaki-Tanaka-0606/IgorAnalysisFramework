# IgorAnalysisFramework

## Notation guide
- **bold phrases** represent important keywords.
- *italic phrases* represent software-specific terms.
- ```code-like phrases``` represent words appearing on Igor Pro windows.

## Description
IgorAnalysisFramework is software running on [Igor Pro](https://www.wavemetrics.com/).
The key concept of the software is that it constructs **analysis diagrams** between raw data, parameters, and analysis results.
It aims for the **complex** and **multi-stage** but **traceable** analysis.

Since the original developer specializes in angle-resolved photoemission spectroscopy (ARPES), examples are mainly for ARPES data analysis.
However, users can develop their functions based on the core part of the software.

## Installation

The software includes **Igor Procedure files** (.ipf) and some READMEs.
Once you put those procedure files in ```User Procedures``` or ```Igor Procedures``` folders, you can start using the software.
You need to add the ```#include "IAF"``` directive in Procedure to load the core and other procedure files if necessary.

## Analysis process
1. Compile Procedure with the ```#include "IAF"``` and other necessary directives. The ```IAF``` menu, including the necessary submenus for the analysis, appears on the menu bar.
1. Set the target folder as the current data folder and select the ```SetUp``` submenu in the ```IAF``` menu. The ```Configurations```, ```Data```, ```Diagrams```, and ```TempData``` folders are created in the current data folder.
1. Add raw data into the folder. We recommend creating another folder for raw data, such as ```raw_data```.
1. Edit diagrams as you want to analyze the data. Be careful that the words in the diagrams are **case-sensitive**. READMEs and examples below will help you.
1. Select the ```ConfigureNames``` and ```ConfigureDependency``` submenus in this order. The former is unnecessary if you are sure there is no mistake in the names of the parts.
1. If you want to visualize the chart, select the ```ConfigureChart``` and ```CallChart``` submenus in this order. A window for the flowchart of the diagrams appears. Each rectangle representing a part can be moved by dragging it.
1. Select the ```CreateData``` submenu and set appropriate values in global variables and strings.
1. Select the ```ExecuteAll``` submenu to perform the analysis.

If the diagrams include *Panel*s, you can call them from the ```CallPanel``` submenu.
The difference between ```CallPanel``` and ```ReCallPanel``` is that the former kills the window and then calls the *Panel* when the window already exists.
The ```ReCallPanel``` submenu is useful when you modify *Variable*s used to draw the *Panel* window.

The ```LoadTemplate``` submenu imports template diagrams in the current ```Diagrams``` folder.

The ```CleanData``` submenu removes waves, global variables, and global strings in the ```Data``` folder, which are not listed in the diagrams.

## How the software works

See [**docs/Structure.md**](docs/Structure.md) to see how the software construct analysis diagrams.

Also, [**docs/GettingStarted.md**](docs/GettingStarted.md) explains how to use the software with examples.

## README for included functions
- **Fundamental *Part*s**: see [**docs/Fundamental.md**](docs/Fundamental.md) for README.
- **ARPES data analysis**: see [**docs/ARPES.md**](docs/ARPES.md) for README, [**docs/ARPES.xlsx**](docs/ARPES.xlsx) for example diagrams.