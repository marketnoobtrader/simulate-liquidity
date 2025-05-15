//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "neo"
#property link      "https://t.me/pip_to_pip"
#property description "[FREE]@pip_to_pip"
#property version   "3.0"
#property indicator_chart_window

#include "tools.mqh"

input color InpColor = clrRed;
input ENUM_LINE_STYLE InpStyle = STYLE_DASHDOTDOT;
input int InpWidth = 1;

const string PREFIX = "LiqLine";

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
   {
    return INIT_SUCCEEDED;
   }

//+------------------------------------------------------------------+
//| Main calculation loop                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
   {
    return rates_total;
   }

//+------------------------------------------------------------------+
//| Event handler for chart clicks                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
   {
    if(id != CHARTEVENT_OBJECT_CLICK)
        return;

    string objName = sparam;
    if(ObjectType(objName) != OBJ_RECTANGLE || ObjectGetInteger(0, objName, OBJPROP_SELECTED))
        return;

    string highLiqName = PREFIX + "_H_" + objName;
    string lowLiqName  = PREFIX + "_L_" + objName;

    DeleteObject(highLiqName);
    DeleteObject(lowLiqName);

    datetime time1 = (datetime)ObjectGetInteger(0, objName, OBJPROP_TIME1);
    datetime time2 = (datetime)ObjectGetInteger(0, objName, OBJPROP_TIME2);

    int index1 = iBarShift(NULL, 0, time1);
    int index2 = iBarShift(NULL, 0, time2);

    double highest, lowest;
    GetHighLowBetweenCandles(index1, index2, highest, lowest);

    double highDist[], lowDist[];
    calculatePriceDistance(highDist, index1, index2);
    ArrayCopy(lowDist, highDist);

    CalculateAdjustedPrices(highDist, High, true, index1, index2, highest);
    CalculateAdjustedPrices(lowDist, Low, false, index1, index2, lowest);

    double threshold = calculateThreshold(MathMax(index1, index2));

    double clusteredHigh[], clusteredLow[];
    ClusterNumbers(highDist, threshold, clusteredHigh);
    ClusterNumbers(lowDist, threshold, clusteredLow);

    drawLiquidityLines(clusteredHigh, highLiqName, time1, time2);
    drawLiquidityLines(clusteredLow,  lowLiqName,  time1, time2);
   }

//+------------------------------------------------------------------+
//| Cluster numbers into groups based on threshold                   |
//+------------------------------------------------------------------+
void ClusterNumbers(double &numbers[], double threshold, double &result[])
   {
    ArraySort(numbers);

    double clusters[100][100];
    int clusterSizes[100];
    int clusterCount = 0;
    int startIdx = 0;
    double prev = numbers[0];

    for(int i = 1; i < ArraySize(numbers); i++)
       {
        if(MathAbs(numbers[i] - prev) <= threshold)
           {
            prev = numbers[i];
            continue;
           }

        int size = 0;
        for(int j = startIdx; j < i; j++)
           {
            clusters[clusterCount][size] = numbers[j];
            size++;
           }

        clusterSizes[clusterCount] = size;
        clusterCount++;
        startIdx = i;
        prev = numbers[i];
       }

// Save the final cluster
    int Size = 0;
    for(int k = startIdx; k < ArraySize(numbers); k++)
       {
        clusters[clusterCount][Size] = numbers[k];
        Size++;
       }

    clusterSizes[clusterCount] = Size;
    clusterCount++;

// Find the largest cluster
    int maxClusterIdx = 0, maxSize = clusterSizes[0];
    for(int t = 1; t < clusterCount; t++)
       {
        if(clusterSizes[t] > maxSize)
           {
            maxSize = clusterSizes[t];
            maxClusterIdx = t;
           }
       }

    ArrayResize(result, maxSize);
    for(int p = 0; p < maxSize; p++)
        result[p] = clusters[maxClusterIdx][p];
   }

//+------------------------------------------------------------------+
//| Draw lines on chart based on adjusted prices                     |
//+------------------------------------------------------------------+
void drawLiquidityLines(double &levels[], const string &baseName, datetime time1, datetime time2)
   {
    for(int i = ArraySize(levels) - 1; i >= 0; i--)
       {
        string name = baseName + IntegerToString(i);
        TrendCreate(0, name, 0, time1, levels[i], time2, levels[i], InpColor, InpStyle, InpWidth);
       }
   }

//+------------------------------------------------------------------+
//| Calculate price distances for candle bodies                      |
//+------------------------------------------------------------------+
void calculatePriceDistance(double &distances[], int index1, int index2)
   {
    int start = MathMax(index1, index2);
    int end   = MathMin(index1, index2);
    int count = start - end + 1;

    ArrayResize(distances, count);
    for(int i = start, pos = count - 1; i >= end; i--, pos--)
        distances[pos] = MathAbs(High[i] - Low[i]);
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double multiplyUntilValid(double lValue, double rValue, double limit, bool isHigh)
   {
    while(true)
       {
        lValue += rValue;
        if((isHigh && lValue >= limit) || (!isHigh && lValue <= limit))
           {
            return lValue;
           }

       }

   }

//+------------------------------------------------------------------+
//| Adjust raw price distances to projected price levels             |
//+------------------------------------------------------------------+
void CalculateAdjustedPrices(double &distances[], const double &source[], bool isHigh,
                             int indexStart, int indexEnd, double limit)
   {
    int start = MathMax(indexStart, indexEnd);
    int end   = MathMin(indexStart, indexEnd);
    int direction = isHigh ? 1 : -1;
    int idx = ArraySize(distances) - 1;

    double adj;
    for(int i = start; i >= end; i--, idx--)
       {
        adj = multiplyUntilValid(source[i], distances[idx] * direction, limit, isHigh);
        distances[idx] = adj;
       }
   }

//+------------------------------------------------------------------+
//| Get high and low price within a candle range                     |
//+------------------------------------------------------------------+
void GetHighLowBetweenCandles(int index1, int index2, double &high, double &low)
   {
    int start = MathMin(index1, index2);
    int end   = MathMax(index1, index2);

    high = High[start];
    low  = Low[start];

    for(int i = start + 1; i <= end; i++)
       {
        if(High[i] > high)
            high = High[i];
        if(Low[i] < low)
            low  = Low[i];
       }
   }

//+------------------------------------------------------------------+
//| Get ATR-based threshold                                          |
//+------------------------------------------------------------------+
double calculateThreshold(int index)
   {
    return iATR(NULL, 0, 120, index) / 2;
   }

//+------------------------------------------------------------------+
//| Delete all objects with matching prefix                          |
//+------------------------------------------------------------------+
void DeleteObject(string prefix)
   {
    for(int i = ObjectsTotal() - 1; i >= 0; i--)
       {
        string name = ObjectName(i);
        if(StringFind(name, prefix) != -1)
            ObjectDelete(0, name);
       }
   }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
    DeleteObject(PREFIX);
   }


//+------------------------------------------------------------------+
