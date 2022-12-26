# IgorAnalysisFramework

## Description

IgorAnalysisFramework is a software running on [Igor Pro](https://www.wavemetrics.com/).
The key concept of the software is that it constructs **analysis diagrams** between raw data, parameters, and analysis results.
It aims for the **complex** and **multi-stage** but **traceable** analysis.

Since the original developer specializes in angle-resolved photoemission spectroscopy (ARPES), examples are mainly for ARPES data analysis.
However, users can develop their own functions based on the core part of the software.

## Installation

The software is composed of Igor Procedure files (.ipf) and some READMEs.
Once you put those procedure files in **User procedures** or **Igor Procedures** folders, you can start using the software.
You need to add the ```#include "IAF"``` directive in Procedure to load the core and other procedure files if necessary.

## Analysis process
1. Compile Procedure with the ```#include "IAF"``` and other necessary directives. **IAF** appears on the menu bar.
1. Set the target folder as the current data folder and select **SetUp** in the **IAF** menu. The **Configurations**, **Data**, **Diagrams**, and **TempData** folders are created in the current data folder.
1. Add raw data in the folder. We recommend to create another folder for raw data such as **raw_data**.
1. Edit diagrams as you want to analyze the data. Be careful that the diagrams are **case-sensitive**. READMEs and examples below will help you.
1. Select **ConfigureNames** and **ConfigureDependency** in this order. The former is unnecessary if you are sure that there is no mistake in the names of the parts.
1. If you want to visualize the chart, select **ConfigureChart** and **CallChart** in this order. A window for the flowchart of the diagrams appears. Each rectangle representing a part can be moved by dragging it.
1. Select **CreateData** and set appropriate values in global variables and strings.
1. Select **ExecuteAll** to perform the analysis.

If the diagrams include **Panel**s, you can call them from **CallPanel**.
The difference between **CallPanel** and **ReCallPanel** is that the former kills the window and then call the **Panel** when the window already exists.
**ReCallPanel** is useful when you modify **Variable**s used to draw the **Panel** window.

**LoadTemplate** command imports a template diagrams in the current **Diagrams** folder.

**CleanData** command remove waves, global variables, and global strings in the **Data** folder which are not listed in the diagrams.

## How it works

See **docs/Structure.md** to see how the software construct analysis diagrams.

Also, **docs/GettingStarted.md** explains how to use the software with examples.

## README for included functions

- **ARPES data analysis**: see **docs/ARPES.md** for README, **docs/ARPES.xlsx** for example diagrams.