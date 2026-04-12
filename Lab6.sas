/* ============================================================
   ASSIGNMENT 6: TIME SERIES ANALYSIS & INFLATION FORECASTING
   Course: Forecasting | SAS Studio
   ============================================================ */


/* ------------------------------------------------------------
   SECTION 1: MANUAL DATA INPUT — GOOGLE PLAY STORE DATES
   ------------------------------------------------------------ */

TITLE "SECTION 1: Manual Data Input";
TITLE2 "Google Play Store Release Dates — January 2012 to March 2018";
FOOTNOTE "Data entered manually using SAS DATALINES statement";

Data Playstore;
    Format Date Date.;
    Input Date : Date. @@;
Datalines;
21JAN12 20FEB12 22MAR12 21APR12 21APR12 13MAY12 21JUN12 20JUL12 21AUG12 22SEP12
15OCT12 16NOV12 21DEC12 21DEC12 20JAN13 19FEB13 19MAR13 18MAY13 17JUN13 18JUL13
17OCT13 18NOV13 17DEC13 01JAN14 02FEB14 03MAR14 04APR14 05MAY14 06JUN14 07AUG14
11SEP14 31OCT14 01NOV14 01DEC14 25FEB15 01MAR15 01APR15 01MAY15 01JUN15 01JUL15
01AUG15 01SEP15 01OCT15 01NOV15 01DEC15 05JAN16 01FEB16 01MAR16 01APR16 01MAY16
01JUN16 01JUL16 01AUG16 01SEP16 01OCT16 01NOV16 01DEC16 05JAN17 01FEB17 01FEB17
01APR17 01MAY17 01JUN17 01JUL17 01AUG17 01SEP17 01NOV17 01DEC17 01FEB18 01MAR18
;
Run;


/* ------------------------------------------------------------
   SECTION 2: TIME SERIES DIAGNOSTICS — PROC TIMEID
   ------------------------------------------------------------ */

TITLE "SECTION 2: Time Series Diagnostics";
TITLE2 "PROC TIMEID — Interval Detection, Duplicates, and Missing Periods";
TITLE3 "Dataset: Playstore | Interval: MONTH";
FOOTNOTE "Output shows time ID summary, duplicate dates, and gaps in the monthly sequence";

ODS GRAPHICS ON;

PROC TIMEID Data=Playstore PRINT=All PLOT=All;
    Id Date Interval=MONTH;
Run;


/* ------------------------------------------------------------
   SECTION 3: IMPORT INFLATION DATA — EXCEL FILE
   ------------------------------------------------------------ */

TITLE "SECTION 3: Excel Data Import";
TITLE2 "PROC IMPORT — Inflation Dataset from inflation.xlsx";
FOOTNOTE "Source file: /home/u64366633/sasuser.v94/inflation.xlsx | Output: WORK.inflation";

%web_drop_table(WORK.inflation);

FILENAME REFFILE '/home/u64366633/sasuser.v94/inflation.xlsx';

PROC IMPORT DATAFILE=REFFILE
    DBMS=XLSX
    OUT=WORK.inflation;
    GETNAMES=YES;
RUN;


/* ------------------------------------------------------------
   SECTION 4: DATASET INSPECTION — PROC CONTENTS
   ------------------------------------------------------------ */

TITLE "SECTION 4: Dataset Inspection";
TITLE2 "PROC CONTENTS — Variable Names, Types, and Structure";
TITLE3 "Dataset: WORK.inflation";
FOOTNOTE "Confirms all variables were imported correctly from the Excel source file";

PROC CONTENTS DATA=WORK.inflation;
RUN;


/* ------------------------------------------------------------
   SECTION 5: MODEL PREPARATION — HOLD-OUT SAMPLE CREATION
   ------------------------------------------------------------ */

TITLE "SECTION 5: Model Dataset Preparation";
TITLE2 "Hold-Out Sample — CPI Nulled for October 2017 to March 2018";
TITLE3 "Training Window: January 2012 – September 2017 | Forecast Window: October 2017 – March 2018";
FOOTNOTE "CPI set to missing for hold-out period to validate regression forecasts";

Data Model;
    Set Inflation;
    If Month gt "30Sep2017"d then do;
        CPI=.;
    End;
Run;

/* Optional: print last 10 rows to confirm CPI goes missing after Sep 2017 */
TITLE "SECTION 5 (VERIFICATION): Last 10 Rows of Model Dataset";
TITLE2 "Confirms CPI Is Missing for the Hold-Out Period";
FOOTNOTE "Rows after 30SEP2017 should show CPI = .";

PROC PRINT Data=Model (FIRSTOBS=60 OBS=70);
    Var Month CPI;
Run;


/* ------------------------------------------------------------
   SECTION 6A: FORWARD SELECTION REGRESSION
   ------------------------------------------------------------ */

TITLE "SECTION 6A: Multivariate Regression — Forward Selection";
TITLE2 "Starts with no variables, adds the best predictor at each step";
TITLE3 "Response: CPI | Predictors: 9 Consumer Spending Categories";
FOOTNOTE "Selection criteria: SBC | Details=All shows step-by-step entry log";

Proc Reg Data=Model Plots=(Criteria SBC);
    Id Month;
    Model CPI = Furniture_Home_Improvement Travel_including_Leisure
                Eating_out Entertainment Grocery Education
                Communication Clothing_and_shopping
                Spend_save_quaterly_ratio
                / Selection=Forward Details=All;
Run;


/* ------------------------------------------------------------
   SECTION 6B: BACKWARD SELECTION REGRESSION
   ------------------------------------------------------------ */

TITLE "SECTION 6B: Multivariate Regression — Backward Selection";
TITLE2 "Starts with all 9 variables, removes the weakest predictor at each step";
TITLE3 "Response: CPI | Predictors: 9 Consumer Spending Categories";
FOOTNOTE "Selection criteria: SBC | Details=All shows step-by-step removal log";

Proc Reg Data=Model Plots=(Criteria SBC);
    Id Month;
    Model CPI = Furniture_Home_Improvement Travel_including_Leisure
                Eating_out Entertainment Grocery Education
                Communication Clothing_and_shopping
                Spend_save_quaterly_ratio
                / Selection=Backward Details=All;
Run;


/* ------------------------------------------------------------
   SECTION 6C: MAXR SELECTION REGRESSION
   ------------------------------------------------------------ */

TITLE "SECTION 6C: Multivariate Regression — MaxR Selection";
TITLE2 "Maximizes R-squared by evaluating the best variable swap at each step";
TITLE3 "Response: CPI | Predictors: 9 Consumer Spending Categories";
FOOTNOTE "MaxR differs from Stepwise: substitutions evaluated before removals";

Proc Reg Data=Model Plots=(Criteria SBC);
    Id Month;
    Model CPI = Furniture_Home_Improvement Travel_including_Leisure
                Eating_out Entertainment Grocery Education
                Communication Clothing_and_shopping
                Spend_save_quaterly_ratio
                / Selection=Maxr Details=All;
Run;


/* ============================================================
   CLEAR TITLES AND FOOTNOTES — END OF ASSIGNMENT 6
   ============================================================ */

TITLE;
FOOTNOTE;