# Normal Mode operation manual

[Open PoTATo Document List] (index.md)

<!-- TOC -->

- [Normal Mode operation manual](#normal-mode-operation-manual)
- [Overview](#overview)
    - [Explanation contents](#explanation-contents)
    - [Analysis model and state](#analysis-model-and-state)
    - [Main window overview](#main-window-overview)
    - [](#)
- [Single experimental data analysis](#single-experimental-data-analysis)
    - [Execution procedure](#execution-procedure)
    - [Adding an analysis method (recipe)](#adding-an-analysis-method-recipe)
        - [Adding an analysis method (recipe)](#adding-an-analysis-method-recipe-1)
        - [Creating a Zipped Recipe](#creating-a-zipped-recipe)
- [Multiple experimental data analysis](#multiple-experimental-data-analysis)
    - [Execution procedure](#execution-procedure-1)
    - [Adding an analysis method (recipe)](#adding-an-analysis-method-recipe-2)
        - [Adding an analysis method (recipe)](#adding-an-analysis-method-recipe-3)
        - [Creating a Zipped Recipe](#creating-a-zipped-recipe-1)

<!-- /TOC -->

# Overview

## Explanation contents

This document explains how to operate Open PoTATo in Normal mode. For information regarding how to start Open PoTATo, how to import experimental data into Open PoTATo, or how to select imported data, please see the “Basic operation” manual.

Normal mode is used to perform typically used fNIRS analysis. With Normal mode, you can perform full-fledged analysis through three steps: selecting experimental data, selecting an analysis method, and performing analysis.

You can also add analysis methods (recipes). This makes it possible to introduce the latest analysis methods and to share analysis methods within your team.

[To table of contents ](#Normal Mode operation manual)

## Analysis model and state

This section explains Normal mode’s analysis model and analysis processing. Processing in Normal mode can be divided into two types: analysis of single experimental data and analysis of multiple experimental data. The table below summarizes them.

**Table 1.1 Normal mode states**

| State           | Contents                  |

| ------------- | -------------------- |

| Normal Single  | Single experimental data analysis  |

| Normal Group   | Multiple experimental data analysis  |

The operation methods for both of these states is explained below.

First, let’s look at the analysis model used in the Normal Single state.

![image-20191127170352959](Normal-Mode.assets/image-20191127170352959.png)

**Figure 1.1 Normal mode - Single experimental data analysis model** 

The input is the analysis method and the single experimental data to be analyzed. The experimental data is analyzed using the recipe (analysis procedure) and the results are drawn using the LAYOUT stored in the analysis method.

Next, let’s look at the analysis model used in the Normal Group state.

![image-20191127170443874](Normal-Mode.assets/image-20191127170443874.png)

**Figure 1.2 Normal mode - Multiple experimental data analysis model** 

The input is the analysis method and the multiple experimental data to be analyzed. Analysis is performed by applying the recipe to each of the experimental data. Next, summary statistic information such as average values are calculated using the analysis data that is produced. Lastly, statistical verification is performed on these statistics.

## Main window overview

To start Normal mode, launch Open PoTATo and, on the main window Setting menu, select “Normal Mode” as the “P3 MODE”.

Below is an overview of the Normal mode main window.

![image-20191127170655512](Normal-Mode.assets/image-20191127170655512.png)

**Figure 1.3 Normal mode main window and areas**

Normal mode has two states, depending on whether single or multiple experimental data is analyzed. However, analysis is performed for both using the same three step process, indicated below.

​	I) Select experimental data

​	II) Select analysis method

​	III) Perform analysis

Analysis methods can be imported for either state.

Below is an explanation of the steps and methods for adding analysis methods for each of the states.

Messages will be displayed in the Status indication area if the state changes, etc., but the explanation is not explained herein.

[To table of contents ](#Normal Mode operation manual)

## 

# Single experimental data analysis

## Execution procedure

Normal mode, Single state is the state when one item of analysis data has been selected in Normal mode. In this state, the main window will appear as below.

![image-20191127170827728](Normal-Mode.assets/image-20191127170827728.png)

**Figure 2.1 Normal mode Single state**

First, select the experimental data. Select the data you wish to analyze from the data list box (A).

Next, select the analysis method from the Recipe popup menu (B). The Description list box (C) will show a brief description of the selected analysis method. If there is detailed help information, the Help button (b1) will be enabled.

Last, draw the results. Select the drawing method (layout) from the popup menu (D) and click the “Draw” button (E) to draw the results.

## Adding an analysis method (recipe)

Below is an explanation of how to add an analysis method.

### Adding an analysis method (recipe)

Adding an analysis method requires a zip file containing an Open PoTATo: Normal mode Single data analysis method. This file is called a Zipped Recipe.

To add it, first click the “Install Recipe” button on the main window. You will be asked to select the Zipped Recipe, so select the Zipped Recipe.

If the installation process is successful, the main window will be updated and the analysis method will be added to the Recipe popup menu.

### Creating a Zipped Recipe

A Zipped Recipe is a zip file of a directory containing an analysis method (recipe). The directory contents are as indicated below.

**Table 2.1 Analysis method directory**

| File name      | Required  | Contents                                                          |

| -------------- | ---- | ------------------------------------------------------------ |

| Recipe.mat      | Required  | Filter recipe                                                |

| Descript.txt    | -    | Text file containing the character string to be shown in the Description list box (explanation of the analysis performed). If this does not exist, it will be generated automatically from the recipe.  |

| Descript.pdf    | -    | If there is no detailed help file (PDF), the Help (HTML) will be referenced.       |

| Descript.html   | -    | If there is no detailed help (HTML), the “Detailed help” button will be disabled.  |

| LAYOUT_*.mat  | -    | Layout used for analysis  * If this does not exist, default values will be used  |

Recipe.mat is a file that can be created using the recipe’s “Save” button in Research mode Preprocess state.

The recipe name that is displayed in the Recipe popup menu is decided using one of the following methods. If Recipe.mat contains the variable Name and its value is something other than “P3-Recipe", the value of the Name variable will be used. In all other cases, the directory name will be used as the recipe name.

[To table of contents ](#Normal Mode operation manual)

# Multiple experimental data analysis

## Execution procedure

This section explains the analysis procedure when analyzing multiple experimental data.

In the Normal mode Group state, the main window will appear as below.

![image-20191127171537311](Normal-Mode.assets/image-20191127171537311.png)

**Figure 3.1 Normal mode Group state**

First, select the experimental data. Select multiple data you wish to analyze from the data list box (A).

Next, select the analysis method from the Recipe popup menu (B). The Description list box (C) will show a brief description of the selected analysis method.

Last, click the “Execution” button (D) to perform verification.

## Adding an analysis method (recipe)

Below is an explanation of how to add an analysis method.

### Adding an analysis method (recipe)

Adding an analysis method requires a zip file containing an Open PoTATo: Normal mode Group data analysis method. This file is called a Zipped Recipe.

To add it, first click the “Install Recipe” button on the main window. You will be asked to select the Zipped Recipe, so select the Zipped Recipe you have prepared.

If the installation process is successful, the main window will be updated and the analysis method will be added to the Recipe popup menu.

### Creating a Zipped Recipe

A Zipped Recipe is a zip file of a directory containing an analysis method (recipe).

The directory contains the following contents.

**Table 3.1 Analysis method directory**

| File name       | Required  | Contents                                                          |

| --------------- | ---- | ------------------------------------------------------------ |

| GroupRecipe.mat  | Required  | Data containing the analysis method                                        |

| Summary_Arg.mat  | Required  | Summary Statistics Computation argument data                   |

| Stat_Arg.mat     | Required  | Statistical Test argument data                                 |

| Descript.txt     | -    | Text file containing the character string to be shown in the Description list box (explanation of the analysis performed). If this does not exist, it will be generated automatically from the recipe.  |

| Descript.pdf     | -    | If there is no detailed help file (PDF), the Help (HTML) will be referenced.       |

| Descript.html    | -    | If there is no detailed help (HTML), the “Detailed help” button will be disabled.  |

GroupRecipe.mat contains the following data.

**Table 3.2 Variables within GroupRecipe.mat**

| Variable name           | Required  | Contents                                   |

| --------------- | ---- | ------------------------------------- |

| Name             | -    | Name of analysis method                           |

| Filter_Manager   | Required  | Recipe for analysis of single experimental data              |

| SummaryFunction  | Required  | Name of the Summary Statistics Computation function  |

| StatFunction     | Required  | Name of the Statistical Test function                |

If a Name variable is added to GroupRecipe.mat, it will be used as the name of the recipe displayed in the Recipe popup menu. If there is no Name, the directory name will be used as the recipe name.

The Filter_Manager Recipe is the same as the data stored in the file created when the filter recipe “Save” button is pressed in Research mode Pre state.

The name of the Summary Statistics Computation function indicated in the SummaryFunction defines the name of the summary statistic information calculation function. The function must conform with Open PoTATo rules. The name of the Statistical Test function indicated in the StatFunction defines the name of the statistical verification function. The function must conform with Open PoTATo rules.

[To table of contents ](#Normal Mode operation manual)

