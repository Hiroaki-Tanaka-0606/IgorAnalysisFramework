# IgorAnalysisFramework

## Description

IgorAnalysisFramework is a software running on [Igor Pro](https://www.wavemetrics.com/).
The key concept of the software is that it constructs **analysis diagrams** between raw data, parameters, and analysis results.
It aims for the **complex** and **multi-stage** but **traceable** analysis.

Since the original developer specializes in angle-resolved photoemission spectroscopy (ARPES), examples are mainly for ARPES data analysis.
However, users can develop their own functions based on the core part of the software.

## Installation

The software is composed of Igor Procedure files (.ipf) and some READMEs.
Once you put those procedure files in **User procedures** or **Igor Procedures** directories, you can start using the software.
You need to add ```#include "IAF"``` in the Procedure to load the core and other procedure files if necessary.

## How it works

See **docs/Structure.md** to see how the software construct analysis diagrams.

## README for included functions

- **ARPES data analysis**: see **docs/ARPES.md**.