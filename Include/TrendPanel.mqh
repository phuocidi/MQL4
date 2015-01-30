//+------------------------------------------------------------------+
//|                                                   TrendPanel.mqh |
//|                                                   Huu Phuoc Tran |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Huu Phuoc Tran"
#property link      "http://www.mql5.com"
#property strict
#include <01_USEFUL_DATASTRUTURE_VARIABLES.mqh> // to use ENUM_TREND currentTrend

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


string CreateButton(string objName)
{
   ObjectCreate(0,objName,OBJ_BUTTON,0,0,0);
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,200);   
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,30);
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,210);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,50);
   return objName;
}

void AddText(string objName,string text)
{
     ObjectSetString(0,objName,OBJPROP_TEXT,text);
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrGreen);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrWhite);  
}
void AddText(string objName,string text,color panelColor)
{
     ObjectSetString(0,objName,OBJPROP_TEXT,text);
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,panelColor);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrWhite);  
}
void AddText(string objName,int direction){
   if (direction==current_trend.UP_WEAK){
     ObjectSetString(0,objName,OBJPROP_TEXT,"UP_WEAK");
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrGreenYellow);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrWhite);    
   }else if(direction==current_trend.UP_STRONG){
     ObjectSetString(0,objName,OBJPROP_TEXT,"UP_STRONG!!!");
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrLime);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrWhite);       
   }else if(direction==current_trend.DOWN_WEAK){
     ObjectSetString(0,objName,OBJPROP_TEXT,"DOWN_WEAK");
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrMagenta);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrWhite);      
   }else if(direction== current_trend.DOWN_STRONG){
     ObjectSetString(0,objName,OBJPROP_TEXT,"DOWN_STRONG!!!");
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrRed);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrWhite);   
   }else if(direction==current_trend.CONSOLIDATION){
     ObjectSetString(0,objName,OBJPROP_TEXT,"CONSOLIDATION");
     ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
     ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBlue);
     ObjectSetInteger(0,objName,OBJPROP_COLOR,clrBlack);
     ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrLinen);      
   }else {
      Print("Cannot predict the trend");
      return;
   }
}