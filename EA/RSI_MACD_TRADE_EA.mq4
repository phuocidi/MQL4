//+------------------------------------------------------------------+
//|                                            RSI_MACD_TRADE_EA.mq4 |
//|                                                   Huu Phuoc Tran |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
// Issue: Need a filter for range market
// take profit miss huge potential movement due to lag in slowRSI
#property copyright "Huu Phuoc Tran"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

extern double LotSize = 0.1;
extern double StopLoss;
extern double TakeProfit;
extern int MagicNumber = 12344556;
extern double pips;
extern double WhenToMoveToBE;
#include <01_CommonUseFunctions.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   ToPips(pips);   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if( IsNewCandle() ) {
      RSI_MACD();
      MoveToBreakEven(MagicNumber,WhenToMoveToBE,pips,10*pips); 
  }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+

void RSI_MACD(int timeframe = PERIOD_H4,double crossline = 50.0,int MA_period = 132)
{
   double currentSlowRSI  = GetRSI(52,1);
   double prevSlowRSI     = GetRSI(52,2); 
   
   double MACD_value = iMACD(NULL,timeframe,12,26,1,PRICE_CLOSE,MODE_MAIN,1);
   
   double MA_value = iMA(NULL,timeframe,MA_period,0,MODE_SMA,PRICE_CLOSE,1);
   
   static bool RSI_has_crossed_up = false;
   
   if(currentSlowRSI > 50.0 && prevSlowRSI < 50.0)
      RSI_has_crossed_up = true;
   else if(currentSlowRSI < 50.0 && prevSlowRSI > 50.0)
      RSI_has_crossed_up = false;
      

   if(MACD_value > 0.0 && currentSlowRSI > 50.0 && RSI_has_crossed_up)
   {
     StopLoss = NormalizeDouble(iBands(NULL,timeframe,132,1,0,PRICE_CLOSE,MODE_LOWER,1),Digits)-20*pips;
     TakeProfit = 0;
     OrderEntry(OP_BUY,1,LotSize,StopLoss,TakeProfit,MagicNumber,pips);
     WhenToMoveToBE = NormalizeDouble(iBands(NULL,240,132,1,0,PRICE_CLOSE,MODE_UPPER,1) - iBands(NULL,240,132,1,0,PRICE_CLOSE,MODE_MAIN,1) ,Digits);
   }
   
   if(prevSlowRSI > 50.0 && currentSlowRSI <50.0)
   {
      CloseCurrentOrder(OP_BUY,MagicNumber);
   }
   
   if(MACD_value < 0.0 && currentSlowRSI < 50.0 && !RSI_has_crossed_up)
   {
     StopLoss = NormalizeDouble(iBands(NULL,timeframe,132,1,0,PRICE_CLOSE,MODE_UPPER,1),Digits) + 20*pips;
     TakeProfit = 0;
     OrderEntry(OP_SELL,1,LotSize,StopLoss,TakeProfit,MagicNumber,pips);
     WhenToMoveToBE = NormalizeDouble(iBands(NULL,240,132,1,0,PRICE_CLOSE,MODE_UPPER,1) - iBands(NULL,240,132,1,0,PRICE_CLOSE,MODE_MAIN,1) ,Digits);
   }
   
   if(prevSlowRSI < 50.0 && currentSlowRSI > 50.0)
   {
      CloseCurrentOrder(OP_SELL,MagicNumber);   
   }
    
}