//+---------------------------------------------------------------------+
//|                                            BB_STOCH_EA_v3.06.mq4    |
//|                                                   Huu Phuoc Tran    |
//|                                              http://www.mql5.com    |
//| v3.03: using Close[1],Close[2],Close[3] to generate peak and bottom |
//| v3.04: using Fractal to generate peak and bottom.                   |
//| v3.05: Stricter rule for fractal to avoid false peak and bottom     |
//| v3.06: Add condition where peak is above MA and bottome is below MA | 
//+---------------------------------------------------------------------+
// Case 2 and 4 problem:  Trade picks whenever price is below or above MA.
//Case 1 and 3 problem: Buy when down trend is strong and sell when up trend is strong.
// See BB_STOCH_ADX_EA.mq4
#property copyright "Huu Phuoc Tran"
#property link      "http://www.mql5.com"
#property version   "3.06"
#property strict
#include <01_CommonUseFunctions.mqh>
#include <TrendPanel.mqh>

extern int MagicNumber=304;
extern double LotSize = 0.1;
extern double StopLoss = 70;
extern double TakeProfit = 200;
extern double pips;
extern double PipsToLockIn = 5;
extern double PadAmount = 120;
extern double WhenToTrail = 60;
extern double WhenToMoveToBE = 35;
extern int HowHighLowBackCandle = 10;
extern bool UseOptimalPoint = true;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   CreateButton("Trade Warning");
   Comment("BB_STOCH_EA_v3.06");
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
   if(IsNewCandle()) {
      BB_Stoch_Trade(PERIOD_H1);  
      MoveToBreakEven(MagicNumber,WhenToMoveToBE,pips,PipsToLockIn);
      TrailingStop(UseOptimalPoint, PERIOD_H1, HowHighLowBackCandle,PadAmount,WhenToTrail,MagicNumber,pips);
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

void BB_Stoch_Trade(int timeframe, int BBRangePercent = 6,int BBArrayPeriod = 10){
   int arraySize = BBArrayPeriod;
   double slowUpBB  [10];
   double slowLowBB [10];
   double slowMainBB[10];
   
   double fastUpBB  [10];
   double fastLowBB [10];
   double fastMainBB[10];
   
   bool  isLowBB           = false;
   bool  isUpBB            = false;
   
   bool isNotBelowLowFastBB   = false;
   bool isNotAboveUpFastBB    = false;
   
   bool isMainToSell       = false;
   bool isMainToBuy        = false;
   
   bool isBottom2Bars      = false;
   bool isBottom3Bars      = false;
   
   bool isPeak2Bars        = false;
   bool isPeak3Bars        = false;
   
   double rangeAllow = MathRound(((slowUpBB[0] - slowMainBB[0])/BBRangePercent)/Point)*Point;
   
   double slowStoch  = iStochastic(NULL,timeframe,20,10,20,MODE_EMA,0,MODE_MAIN,1);
   double prevSlowStoch  = iStochastic(NULL,timeframe,20,10,20,MODE_EMA,0,MODE_MAIN,2);

   double slowStochSignal        = iStochastic(NULL,timeframe,20,10,20,MODE_EMA,0,MODE_SIGNAL,1);
   double prevSlowStochSignal    = iStochastic(NULL,timeframe,20,10,20,MODE_EMA,0,MODE_SIGNAL,2);
   
   double fastStoch              = iStochastic(NULL,timeframe,8,3,3,MODE_EMA,0,MODE_MAIN,1);   
   double fastStochSignal        = iStochastic(NULL,timeframe,8,3,3,MODE_EMA,0,MODE_SIGNAL,1);  
//RSI filter has to be the most current bar in action:  
   double currentSlowRSI  = GetRSI(52,1);
   double prevSlowRSI     = GetRSI(52,2);   
   
   double currentFastRSI  = GetRSI(7,1);
   double prevFastRSI     = GetRSI(7,2);

   bool isDownRSI = DoubleIs1Smaller2(currentFastRSI,currentSlowRSI,4) && DoubleIs1Smaller2(prevFastRSI,prevSlowRSI,4)&& currentFastRSI<50;
   bool isUpRSI   = DoubleIs1Greater2(currentFastRSI,currentSlowRSI,4) && DoubleIs1Greater2(prevFastRSI,prevSlowRSI,4) && currentFastRSI>50;
   
   double bsl = Ask - StopLoss*pips;
   double btp = Ask + TakeProfit*pips;
   
   double ssl = Bid + StopLoss*pips;
   double stp = Bid - TakeProfit*pips;   
/*---------------------------------------------------------------------------------------------------*/     
// Generate the most 10 lastest BB values:   
   for (int i = 0; i< BBArrayPeriod;i++){
      slowUpBB[i]   = iBands(NULL,timeframe,120,2,0,PRICE_CLOSE,MODE_UPPER,i+1);
      slowLowBB[i]  = iBands(NULL,timeframe,120,2,0,PRICE_CLOSE,MODE_LOWER,i+1);
      slowMainBB[i] = iBands(NULL,timeframe,120,2,0,PRICE_CLOSE,MODE_MAIN,i+1);    
 
      fastUpBB[i]   = iBands(NULL,timeframe,20,1,2,PRICE_CLOSE,MODE_UPPER,i+1);
      fastLowBB[i]  = iBands(NULL,timeframe,20,1,2,PRICE_CLOSE,MODE_LOWER,i+1);
      fastMainBB[i] = iBands(NULL,timeframe,20,1,2,PRICE_CLOSE,MODE_MAIN,i+1); 
   }  
/*---------------------------------------------------------------------------------------------------*/   
// Find bottom, find the lowest of 2 consecutive bars
// Logic: last Bar cannot lower than the bottom
   for(int i = 0; i< BBArrayPeriod - 1;i++){
      if(Close[1]>Close[i+2]&& Close[i+2]<Close[i+1] && Close[i+2]<Close[i+3] && Close[i+2]<Close[i+4] && Close[i+2] < slowMainBB[i+1]){
         isBottom2Bars = true;
      }else if(High[1]<High[i+2]&&High[i+2]<High[i+1] && High[i+2]<High[i+3] && High[i+2]<High[i+4]&& High[i+2] < slowMainBB[i+1]){
         isBottom2Bars = true;
      }
      else{
         isBottom2Bars = false;
      }
      if (isBottom2Bars) break;
   }
// Find bottom, find the lowest of 3 consecutive bars 
   for(int i = 0; i< BBArrayPeriod - 2;i++){
      if(Close[1]>Close[i+3] && Close[i+3]<Close[i+2] && Close[i+3] <Close[i+1] &&Close[i+3]<Close[i+4] && Close[i+3]<Close[i+5] && Close[i+3] < slowMainBB[i+2]){
         isBottom3Bars = true;
      }else if(High[1]>High[i+3] &&High[i+3]<High[i+2] && High[i+3] <High[i+1] &&High[i+3]<High[i+4] && High[i+3]<High[i+5]&& High[i+3] < slowMainBB[i+2]){
         isBottom3Bars = true;
      }else{
         isBottom3Bars = false;
      }
      if (isBottom3Bars) break;
   }
//Find peak, find the highest of 2 consecutive bars
   for(int i=0; i<BBArrayPeriod-1;i++){
      if(Close[1]<Close[i+2] && Close[i+2]>Close[i+1] && Close[i+2]>Close[i+3]&&Close[i+2]>Close[i+4] && Close[i+2]>slowMainBB[i+1]){
         isPeak2Bars = true;
      }else if(Low[1]<Low[i+2]&&Low[i+2]>Low[i+1] && Low[i+2]>Low[i+3]&&Low[i+2]>Low[i+4]&& Low[i+2]>slowMainBB[i+1]){
         isPeak2Bars = true;
      }else{
         isPeak2Bars = false;
      }
      if(isPeak2Bars) break;
   }
//Find peak, find the highest of 3 consecutive bars
   for(int i =0;i<BBArrayPeriod-2;i++){
      if(Close[1]<Close[i+3] &&Close[i+3]>Close[i+2]&&Close[i+3]>Close[i+1]&&Close[i+3]>Close[i+4]&&Close[i+3]>Close[i+5] && Close[i+3] >slowMainBB[i+2] ){
         isPeak3Bars = true;

      }else if(Low[1]<Low[i+3] &&Low[i+3]>Low[i+2]&&Low[i+3]>Low[i+1]&&Low[i+3]>Low[i+4]&&Low[i+3]>Low[i+5]&& Low[i+3] >slowMainBB[i+2]){
         isPeak3Bars = true ;
      }else{
         isPeak3Bars = false;
      }
      if(isPeak3Bars) break;
   }

/*---------------------------------------------------------------------------------------------------*/   
// Check if any 2 consecutive price bar is under lower BB or above upper BB:
// if one of them Close above lower BB or Close below slowUpBB, then enter trade;
// NOTE: Array time series has index lag by 1 in compare to BB array since we start BB at timeSeries[1]
/*---------------------------------------------------------------------------------------------------*/   

  // Case 1: Reverting from lower slowBB && (not 3 consecutive bars closed below lower fast BB || not 2 most recent bars closed below lower fast BB), buy signal   
   for(int i = 0; i < BBArrayPeriod -2; i++){
      isNotBelowLowFastBB = !( (Close[1] < fastLowBB[0] && Close[2] < fastLowBB[1]) || (Close[i+1] < fastLowBB[i] && Close[i+2]<fastLowBB[i+1] && Close[i+3]<fastLowBB[i+2]) ) && Close[1] > fastLowBB[0];
      
      if(isNotBelowLowFastBB) break;
   }
  // for loop: Is there any 2 consecutive bars low below the lower slow BB and the first one of the two bar
  // is closed above the lower slow BB
   for(int i = 0; i < BBArrayPeriod -1; i++){
      isLowBB = ( (Low[i+1] < slowLowBB[i] && Low[i+2] < slowLowBB[i+1] && Close[i+1] > slowLowBB[i]) || 
                  (Low[i+1] < slowLowBB[i]+rangeAllow && Low[i+2] < slowLowBB[i+1]+rangeAllow && Close[i+1] > slowLowBB[i] + rangeAllow ));
      if(isLowBB) break;
   }
  //Case 2: Price Bounds from upper part of BB, hits Moving Average and bounds back in, Buy   
  for(int i = 0; i < BBArrayPeriod;i++){
      if(isBottom3Bars){
         if(Close[i+1] > slowMainBB[i]){
            isMainToBuy = true;
            break;
         }else if(Close[i+1] > slowUpBB[i]+rangeAllow) {
            isMainToBuy = true;
            break;
         }else if(High[i+1] > slowMainBB[i]){
            isMainToBuy = true;
            break;
         }else if(High[i+1] > slowMainBB[i] + rangeAllow){
            isMainToBuy = true;
            break;
         }else{
            isMainToBuy = false;
         }

      }else if(isBottom2Bars){
         if(Close[i+1] > slowMainBB[i]) {
            isMainToBuy = true;
            break;
         }else if(Close[i+1] > slowMainBB[i]+rangeAllow){
            isMainToBuy = true;
            break;
         }else if(High[i+1] > slowMainBB[i]){
            isMainToBuy = true;
            break;
         }else if(High[i+1] > slowMainBB[i] + rangeAllow){
            isMainToBuy = true;
            break;
         }else{
            isMainToBuy = false;
         }
      }
  }
  //Case 3: Reverting from Upper BB && (not 3 consecutive bars closed above fast upper BB|| not most 2 recent bars closed above fast up BB), sell signal
   for(int i = 0; i < BBArrayPeriod -2; i++){
      isNotAboveUpFastBB = !( (Close[1] > fastUpBB[0] && Close[2] > fastUpBB[1]) || (Close[i+1] > fastUpBB[i] && Close[i+2]>fastUpBB[i+1] && Close[i+3]>fastUpBB[i+2]) ) && Close[1] < fastUpBB[0];
      
      if(isNotAboveUpFastBB) break;
   }
  // for loop: Is there any 2 consecutive bars high above the upper slow BB and the first one of the two bar
  // is closed below the upper slow BB
   for(int i = 0; i < BBArrayPeriod -1; i++){
      isUpBB = ( (High[i+1] > slowUpBB[i] && High[i+2] > slowUpBB[i+1] && Close[i+1] < slowUpBB[i]) || 
                 (High[i+1] > slowUpBB[i] -rangeAllow && High[i+2] > slowUpBB[i+1]-rangeAllow && Close[i+1] < slowUpBB[i]-rangeAllow) );
      if(isUpBB) break;
   }
   //Case 4: Price Bound from lower BB, hits MA and bounds back in, SELL   
  for(int i = 0; i < BBArrayPeriod;i++){
      if(isPeak3Bars){
         if(Close[i+1] < slowMainBB[i]){
            isMainToSell = true;
            break;
         }else if(Close[i+1] < slowMainBB[i]-rangeAllow){
            isMainToSell = true;
            break;
         }else if(Low[i+1] < slowMainBB[i]){
            isMainToSell = true;
            break;
         }else if(Low[i+1] < slowMainBB[i] - rangeAllow){
            isMainToSell = true;
            break;
         }else{
            isMainToSell = false;
         }
      
      }else if(isPeak2Bars){
         if(Close[i+1] < slowMainBB[i]) {
            isMainToSell = true;
            break;
         }else if(Close[i+1] < slowMainBB[i]-rangeAllow) {
            isMainToSell = true;
            break;
         }else if(Low[i+1] < slowMainBB[i]){
            isMainToSell = true; 
            break;
         }else if(Low[i+1] < slowMainBB[i]-rangeAllow){
            isMainToSell = true; 
            break;
         }else{
            isMainToSell = false;
         }
      }
  }
/*---------------------------------------------------------------------------------------------------*/   
/*                             TRADE LOGIC& EXCECUTION OF TRADE                                      */
/*---------------------------------------------------------------------------------------------------*/      
 // Case 1: Reverting from lower BB, buy signal                      
   if(fastStoch > slowStoch && fastStoch<80 && slowStoch<70 && isLowBB && isNotBelowLowFastBB)
   {  CloseCurrentOrder(OP_SELL,MagicNumber);
      OrderEntry(OP_BUY,1,LotSize,bsl,btp,MagicNumber,pips);
      AddText("Trade Warning","CASE 1: BUY",clrGreenYellow);
   }
   //Case 2: Price Bounds from upper part of BB, hits Moving Average and bounds back in, Buy
   // can sua logic, 2 cay nen nam duoi MA cung se kich hoat BUY
   if(fastStoch > slowStoch &&  fastStoch >20&& slowStoch>30 && isMainToBuy && isUpRSI)
   {
      //btp = Ask+TakeProfit*pips*0.5;
      CloseCurrentOrder(OP_SELL,MagicNumber);
      OrderEntry(OP_BUY,1,LotSize,bsl,btp,MagicNumber,pips);
      AddText("Trade Warning","CASE 2: BUY MA",clrGreen);
   }
   //Case 3: Reverting from Upper BB, sell signal
   if( fastStoch < slowStoch && fastStoch > 20 && slowStoch>30 && isUpBB && isNotAboveUpFastBB) 
   {
      CloseCurrentOrder(OP_BUY,MagicNumber);
      OrderEntry(OP_SELL,1,LotSize,ssl,stp,MagicNumber,pips); 
      AddText("Trade Warning","Case 3: SELL",clrOrangeRed);      
   }
   //Case 4: Price Bound from lower BB, hits MA and bounds back in, SELL
   // Sua logic o day nhu case 2 lun
   if( fastStoch < slowStoch && fastStoch<80 && slowStoch<70 && isMainToSell && isDownRSI)
   {
      //stp = Bid-TakeProfit*pips*0.5;
      CloseCurrentOrder(OP_BUY,MagicNumber);
      OrderEntry(OP_SELL,1,LotSize,ssl,stp,MagicNumber,pips);
      AddText("Trade Warning","Case 4: SELL MA",clrRed);
   }
   
// Force to close order section here:

   if(prevSlowStoch > prevSlowStochSignal && slowStoch < slowStochSignal){
      CloseCurrentOrder(OP_BUY,MagicNumber);
      AddText("Trade Warning","JUST CLOSE BUY",clrGray);
   }
   if(prevSlowStoch < prevSlowStochSignal && slowStoch > slowStochSignal){
      CloseCurrentOrder(OP_SELL,MagicNumber);
      AddText("Trade Warning","JUST CLOSE SELL",clrGray);
   }
  
  
  Comment("isPeak2Bars = ",isPeak2Bars,
        "\nisPeak3Bars = ", isPeak3Bars,
        "\nisMainToSell =", isMainToSell,
        "\nisDownRSI = ",isDownRSI,
        "\n",
        "\nisBottom2bars = ",isBottom2Bars,
        "\nisBottom2Bars = ",isBottom3Bars,
        "\nisMainToBuy = ",isMainToBuy,
        "\nisUpRSI = ",isUpRSI);
}// END BB_Stoch_Trade
/*---------------------------------------------------------------------------------------------------*/   