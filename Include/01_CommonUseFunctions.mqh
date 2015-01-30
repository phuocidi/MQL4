//+------------------------------------------------------------------+
//|                                         01_CommonUseFunction.mq4 |
//|                                                   Huu Phuoc Tran |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Huu Phuoc Tran"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//#include <01_USEFUL_DATASTRUTURE_VARIABLES.mqh>
#define SWAP(a,b) ( a^=b;b^=a;a^=b;)

//+------------------------------------------------------------------+
//| ToPips(double pips): Check broker with 4 or 5 digits             |
//+------------------------------------------------------------------+

void ToPips(double &p)
{
   p = Point;
   if (Digits == 3 || Digits==5) p = p *10;
}

//+------------------------------------------------------------------+
//| IsNewCandle(): check the current state of the candle in the chart|
//| return true if new candle is forming and false if the candle is  |
//| the same. It checks in every tick.                               |
//+------------------------------------------------------------------+
bool IsNewCandle()
{
   static int BarsOnChart = 0;
   if(BarsOnChart == Bars) 
      return false;
   BarsOnChart  = Bars;
   return true;
}
//+------------------------------------------------------------------+
//| OpenOrdersThisPair (string pair):return how many open trade on   |
//| particular currency on the chart                                 |
//+------------------------------------------------------------------+
int OpenOrdersThisPair (string pair)
{
   int total = 0;
   for (int i = OrdersTotal()-1; i >=0;i--)
   {
      if(! OrderSelect(i,SELECT_BY_POS,MODE_TRADES) ) 
         MessageBox("SELECT TRADE FAILED: #" + IntegerToString(GetLastError()),"OPEN ORDER"+Symbol(),0);
      if(OrderSymbol() == pair) 
         total++;
   }
   
   return total;
}

//+------------------------------------------------------------------+
//| MoveToBreakEven(): Move the stoploss to BE after price is rallied|
//| in correct direction, given the amounts how far away from open   |
//| position. It then pads the PipsToLockIn + orderOpenPrice as SL   |
//+------------------------------------------------------------------+
void MoveToBreakEven(int &MagicNumber,double &WhenToMoveToBE,double &pips,double &PipsToLockIn=5)
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber() != MagicNumber) continue;
            if(OrderSymbol() == Symbol()){
     // Check for Buy Order and Modify the Order          
               if(OrderType() == OP_BUY){
                  if(Bid-OrderOpenPrice() > WhenToMoveToBE*pips){
                     if(OrderOpenPrice() > OrderStopLoss()){
                        if( ! OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() + (pips*PipsToLockIn),OrderTakeProfit(),0,clrNONE) ) 
                           MessageBox("OrderModify FAILED: #" + IntegerToString(GetLastError()),"MOVE TO BREAK EVEN",0);
                     }
                  }
               }
   
   // Check for Sell order and Modify the Order
               if(OrderType() == OP_SELL){
                  if(OrderOpenPrice()-Ask > WhenToMoveToBE*pips){
                     if( OrderOpenPrice() < OrderStopLoss() ) {
                        if( !OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - (pips*PipsToLockIn),OrderTakeProfit(),0,clrNONE) )
                           MessageBox("OrderModify FAILED: #" + IntegerToString(GetLastError()),"MOVE TO BREAK EVEN",0);
                     }
                  }
               }
            }
   }     
}

//+------------------------------------------------------------------+
//| ExitBuys(): Close all Buy Order that is current opened           |
//+------------------------------------------------------------------+
void ExitBuys(int &MagicNumber)
{
   for(int i =0; i < OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()==OP_BUY&&OrderMagicNumber() == MagicNumber)
         {  
            if( !OrderClose(OrderTicket(),OrderLots(),Bid,5,clrBlue) )
               GetLastError();
            else
               i--;
         }else
            continue;
       }else{
         Print("When selecting a trade, error #",GetLastError()," occurred\n");
       }
   }
}

//+------------------------------------------------------------------+
//| ExitSells function: Close Buy Order at Market Price               |
//+------------------------------------------------------------------+
void ExitSells(int &MagicNumber)
{
   for(int i = 0; i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()==OP_SELL && OrderMagicNumber() == MagicNumber)
         {  
            if( !OrderClose(OrderTicket(),OrderLots(),Ask,5,clrYellow) )
               GetLastError();
            else
               i--;
         }else
            continue;
       }else{
         Print("When selecting a trade, error #",GetLastError()," occurred\n");
       }
   }
}
//+------------------------------------------------------------------+
//| Delete Pending Order  function                                   |
//+------------------------------------------------------------------+
void DeletePendingOrder()
{

   for(int i = 0; i< OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() != Symbol()) continue;
         else{
            if(OrderType() > 1)
               if(!OrderDelete(OrderTicket(),clrNONE))Print("OrderDelete Failed: ERROR# " + IntegerToString(GetLastError()));
               else Print("OrderDelete Success!");
               i--;
            }
       }else{
         Print("OrderSeLect Failed: ERROR# " + IntegerToString(GetLastError()));
         break; // can't find the trade, then jump out
       }
      
   }
}

//+------------------------------------------------------------------+
//| Delete Pending Order  function                                   |
//+------------------------------------------------------------------+
void DeletePendingOrder(int direction)
{

   for(int i = 0; i< OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if( OrderType() == OP_BUYSTOP|| OrderType()==OP_BUYLIMIT){
            if(OrderSymbol() != Symbol()) continue;
            else{
               if(OrderType() > 1)
                  if(!OrderDelete(OrderTicket(),clrNONE))Print("OrderDelete Failed: ERROR# " + IntegerToString(GetLastError()));
                  else Print("OrderDelete Success!");
                  i--;
               }
         }else break;
       }else{
         Print("OrderSeLect Failed: ERROR# " + IntegerToString(GetLastError()));
         break; // can't find the trade, then jump out
       }
      
   }
   
   for(int i = 0; i< OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if( OrderType() == OP_SELLSTOP|| OrderType()==OP_SELLLIMIT){
            if(OrderSymbol() != Symbol()) continue;
            else{
               if(OrderType() > 1)
                  if(!OrderDelete(OrderTicket(),clrNONE))Print("OrderDelete Failed: ERROR# " + IntegerToString(GetLastError()));
                  else Print("OrderDelete Success!");
                  i--;
               }
         }else break;
       }else{
         Print("OrderSeLect Failed: ERROR# " + IntegerToString(GetLastError()));
         break; // can't find the trade, then jump out
       }
      
   }
}

//+------------------------------------------------------------------+
//| OrderEntry function:open market order OP_BUY, OP_SELL            |
//|  with limit  number of order allow                               |
//+------------------------------------------------------------------+ 
void OrderEntry(int direction, int maxOrder,double &LotSize,double &StopLoss,double &TakeProfit,int &MagicNumber,double &pips)
{

   if(direction == OP_BUY){
      if((OrdersTotal()< maxOrder)){
         int buyTicket =OrderSend(Symbol(),OP_BUY,LotSize,Ask,10,StopLoss,TakeProfit,NULL,MagicNumber,0,clrGreen);
            if(buyTicket ==-1)
               Print("Buy Order Failed, ERROR #",GetLastError());
            else
               Print("Buy Order Succesfully");
      }
   }
 
   if(direction == OP_SELL){
      if(OrdersTotal() < maxOrder){
         int sellTicket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,10,StopLoss,TakeProfit,NULL,MagicNumber,0,clrRed);
            if(sellTicket ==-1)
               Print("Sell Order Failed, ERROR #",GetLastError());
             else
               Print("Sell Order Succesfully");
      }    
   }
}

//+------------------------------------------------------------------+
//| OrderEntry function:parameter OP_BUY, OP_SELL                    |
//| OP_BUYLIMIT, OP_BUYSTOP, OP_SELLSTOP, OP_SELLLIMIT               |
//+------------------------------------------------------------------+ 
void OrderEntry(int direction,double &LotSize,double &StopLoss,double &TakeProfit,int &MagicNumber,int &pips)
{

   if(direction == OP_BUY){
      if((OrdersTotal()<0)){
         int buyTicket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,10,StopLoss,TakeProfit,NULL,MagicNumber,0,clrGreen);
            if(buyTicket ==-1)
               Print("Buy Order Failed, ERROR #",GetLastError());
            else
               Print("Buy Order Succesfully");
      }
   }
 
   if(direction == OP_SELL){
      if(OrdersTotal() < 0){
         int sellTicket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,10,StopLoss,TakeProfit,NULL,MagicNumber,0,clrRed);
         if(sellTicket ==-1)
            Print("Sell Order Failed, ERROR #",GetLastError());
         else
            Print("Sell Order Succesfully");
         }   
   }  
}

//+------------------------------------------------------------------+
//| PendingOrderEntry function                  |
//| OP_BUYLIMIT, OP_BUYSTOP, OP_SELLSTOP, OP_SELLLIMIT, with limit   |
//|  number of order allow                                           |
//+------------------------------------------------------------------+ 
void PendingOrderEntry(int direction,int maxOrder,double &LotSize, double &EntryPrice,double &StopLoss,double &TakeProfit,int &MagicNumber,double &pips)
{
   if(direction==OP_BUYSTOP){
      if(OrdersTotal() < maxOrder){
         int sellTicket = OrderSend(Symbol(),OP_BUYSTOP,LotSize,EntryPrice,3,StopLoss,TakeProfit,NULL,MagicNumber,0,clrRed);
            if(sellTicket ==-1)
               Print("BUY STOP ORDER Failed, ERROR #",GetLastError());
             else
               Print("BUY STOP ORDER Succesfully");
      }    
   }
   
    if(direction==OP_BUYLIMIT){
      if(OrdersTotal() < maxOrder){
         int sellTicket = OrderSend(Symbol(),OP_BUYLIMIT,LotSize,EntryPrice,3,StopLoss,TakeProfit,NULL,MagicNumber,0,clrRed);
            if(sellTicket ==-1)
               Print("BUY LIMIT ORDER Failed, ERROR #",GetLastError());
             else
               Print("BUY LIMIT ORDER Succesfully");
      }    
   }
   
   if(direction==OP_SELLSTOP){
      if(OrdersTotal() < maxOrder){
         int sellTicket = OrderSend(Symbol(),OP_SELLSTOP,LotSize,EntryPrice,3,StopLoss,TakeProfit,NULL,MagicNumber,0,clrRed);
            if(sellTicket ==-1)
               Print("SELL STOP ORDER Failed, ERROR #",GetLastError());
             else
               Print("SELL STOP ORDER Succesfully");
      }    
   }
   
   if(direction==OP_SELLLIMIT){
      if(OrdersTotal() < maxOrder){
         int sellTicket = OrderSend(Symbol(),OP_SELLLIMIT,LotSize,EntryPrice,3,StopLoss,TakeProfit,NULL,MagicNumber,0,clrRed);
            if(sellTicket ==-1)
               Print("SELL LIMIT ORDER Failed, ERROR #",GetLastError());
             else
               Print("SELL LIMIT ORDER Succesfully");
      }    
   }
}

//+------------------------------------------------------------------+
//| Close market order when called                                   |
//+------------------------------------------------------------------+
void CloseCurrentOrder(int direction,int &MagicNumber){
   if( OrdersTotal()== 0 ) 
      MessageBox("There is no order to close","CLOSE ORDER",0);
   else{
         if(direction==OP_BUY || direction==OP_BUYSTOP || direction == OP_BUYLIMIT){
            for(int i = 0; i < OrdersTotal(); i++){
               if( !OrderSelect(i,SELECT_BY_POS,MODE_TRADES) ){
                  MessageBox("SELECT BUY ORDER FAILED","CLOSE ORDER",0);
               }else{
                  if( ( OrderType()==OP_BUY || OrderType() == OP_BUYSTOP || OrderType()== OP_BUYLIMIT )&& MagicNumber==OrderMagicNumber() ){
                     if(!OrderClose(OrderTicket(),OrderLots(),Bid,10,clrRed)) 
                        MessageBox("CLOSE BUY ORDER FAILED: #"+ IntegerToString(GetLastError()),"CLOSE ORDER",0);
                     else{
                        i--;
                        MessageBox("CLOSE BUY ORDER SUCCESSFULLY","CLOSE ORDER",0);
                     }
                  }
               }
            }// end for loop to close buy order
         }
         if(direction==OP_SELL || direction == OP_SELLSTOP || direction == OP_SELLLIMIT){
            for(int i = 0; i < OrdersTotal(); i++){
               if( !OrderSelect(i,SELECT_BY_POS,MODE_TRADES) ){
                  MessageBox("SELECT SELL ORDER FAILED","CLOSE ORDER",0);
               }else{
                  if( (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT )&& MagicNumber==OrderMagicNumber() ){
                     if(!OrderClose(OrderTicket(),OrderLots(),Ask,10,clrGreen)) 
                        MessageBox("CLOSE SELL ORDER FAILED: #"+ IntegerToString(GetLastError()),"CLOSE ORDER",0);
                     else{
                        i--;
                        MessageBox("CLOSE SELL ORDER SUCCESSFULLY","CLOSE ORDER",0);
                     }
                  }
               }
            }// end for loop to close sell order
         }// end OP_SELL
   }
}

//+------------------------------------------------------------------+
//|TrailingStop():                                                   |
//|Case 1: Price has not yet rallied in right direction but lowest   |
//|  price is greater than stoploss                                  |
//|Case 2: Price is the gap between current Price is greater than    |
//| the amount allow to start trailing                               |
//|Case 3: No stop loss at order, trailing stop still work           |
//|Trailing stop is locked at the lowest bar                         |
//+------------------------------------------------------------------+
void TrailingStop(int timeframe,int &HowHighLowBackCandle,double &WhenToTrail,double &PadAmount,int &MagicNumber,double &pips)
{

   // Buy section:
   if(OrdersTotal()>0){
      for(int i = 0; i< OrdersTotal(); i++){
         if(! OrderSelect(i, SELECT_BY_POS) ){
            MessageBox("SELECT ORDER FAILED: #" + IntegerToString(GetLastError()),"TRALING STOP",0);
         }else{
            if(OrderType()== OP_BUY || OrderType()==OP_BUYLIMIT || OrderType() == OP_BUYSTOP){
               if(OrderSymbol() ==Symbol()){
                  if(Bid - OrderOpenPrice() > WhenToTrail*pips|| OrderStopLoss()==0 || Low[iLowest(NULL,timeframe,MODE_LOW,HowHighLowBackCandle,0)] - PadAmount*pips > OrderStopLoss()){
                     if( OrderModify(OrderTicket(),OrderOpenPrice(),Low[iLowest(NULL,timeframe,MODE_LOW,HowHighLowBackCandle,0)] - PadAmount*pips,OrderTakeProfit(),0,clrNONE) ){
                        Print("TRAILING STOP SUCCESS");
                     }else{
                        Print("TRAILING STOP FAIL!");
                     }
                  }
               }
            }
         }
      }
      
   // sell sECTION:
      for(int i = 0; i< OrdersTotal(); i++){
         if(! OrderSelect(i, SELECT_BY_POS) ){
            MessageBox("SELECT ORDER FAILED: #" + IntegerToString(GetLastError()),"TRALING STOP",0);
         }else{
            if(OrderType()== OP_SELL || OrderType()==OP_SELLLIMIT || OrderType() == OP_SELLSTOP){
               if(OrderSymbol() ==Symbol()){
                  if(OrderOpenPrice() - Ask > WhenToTrail*pips|| OrderStopLoss()==0 || High[iHighest(NULL,timeframe,MODE_HIGH,HowHighLowBackCandle,0)] + PadAmount*pips > OrderStopLoss()){
                     if( OrderModify(OrderTicket(),OrderOpenPrice(),High[iHighest(NULL,timeframe,MODE_HIGH,HowHighLowBackCandle,0)] + PadAmount*pips,OrderTakeProfit(),0,clrNONE) ){
                        Print("TRAILING STOP SUCCESS");
                     }else{
                        Print("TRAILING STOP FAIL!");
                     }
                  }
               }
            }
         }
      }
        
   }
   
}


void TrailingStop(bool &UseOptimalPoint, int timeframe,int &HowHighLowBackCandle,double &PadAmount, double &WhenToTrail,int &MagicNumber, double &pips)
{
   if(!UseOptimalPoint) return;
   // buy section
   for(int b = OrdersTotal()-1; b>=0;b--)
   {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderMagicNumber() == MagicNumber){
            if(OrderSymbol() == Symbol()){
               if(OrderType() == OP_BUY){
               
                  if(OrderStopLoss()< Low[iLowest(NULL,timeframe,MODE_LOW,HowHighLowBackCandle,1)]-PadAmount*pips && Bid-OrderStopLoss()-PadAmount*pips > WhenToTrail*pips ){
                     if(! OrderModify(OrderTicket(),OrderOpenPrice(),Low[iLowest(NULL,timeframe,MODE_LOW,HowHighLowBackCandle,1)]-PadAmount*pips,OrderTakeProfit(),0,clrNONE) ){
                        Print("TRAILING STOP ERROR. #",IntegerToString(GetLastError())); 
                     } 
                  }
                  
                  if(Bid - OrderOpenPrice() > WhenToTrail*pips)
                  {       
                     if(OrderStopLoss() < Low[iLowest(NULL,timeframe,MODE_LOW,HowHighLowBackCandle,1)]-PadAmount*pips|| OrderStopLoss() == 0){
                        if(! OrderModify(OrderTicket(),OrderOpenPrice(),Low[iLowest(NULL,timeframe,MODE_LOW,HowHighLowBackCandle,1)]-PadAmount*pips,OrderTakeProfit(),0,clrNONE) ){
                          Print("TRAILING STOP ERROR. #",IntegerToString(GetLastError())); 
                        }
                     }
                  }
               }
            }  
         }  
      }                 
   }
   // sell section
   for(int s = OrdersTotal() -1; s>=0;s--)
   {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderMagicNumber() == MagicNumber){
            if(OrderSymbol() == Symbol()){
               if(OrderType() == OP_SELL){
                 if(OrderStopLoss() > High[iHighest(NULL,timeframe,MODE_HIGH,HowHighLowBackCandle,1)]+ PadAmount*pips && OrderStopLoss()-Ask-PadAmount*pips > WhenToTrail*pips){
                     if( !OrderModify(OrderTicket(),OrderOpenPrice(),High[iHighest(NULL,timeframe,MODE_HIGH,HowHighLowBackCandle,1)]+PadAmount*pips,OrderTakeProfit(),0,clrNONE) ){
                        Print("TRAILING STOP ERROR. #",IntegerToString(GetLastError())); 
                     }
                  }
                 
                 if(OrderOpenPrice() - Ask > WhenToTrail*pips)
                 {  
                     if(OrderStopLoss() > High[iHighest(NULL,timeframe,MODE_HIGH,HowHighLowBackCandle,1)] + pips*PadAmount || OrderStopLoss()==0){
                        if(! OrderModify(OrderTicket(),OrderOpenPrice(), High[iHighest(NULL,timeframe,MODE_HIGH,HowHighLowBackCandle,1)] + (pips*PadAmount),OrderTakeProfit(),0,clrNONE) ){
                           Print("TRAILING STOP ERROR. #",IntegerToString(GetLastError())); 
                        }
                     }
                 }
              }
           }
        }
     }             
   }
}

//+------------------------------------------------------------------+
//| correct  comparison of 2 doubles                                  |
//+------------------------------------------------------------------+
bool DoubleIs1Greater2(double number1,double number2, int digits = 8)
  {
   if(NormalizeDouble(number1-number2,digits)>0) return(true);
   else return(false);
  }

bool DoubleIs1Smaller2(double number1,double number2, int digits = 8)
  {
   if(NormalizeDouble(number1-number2,digits)>=0) return(false);
   else return(true);
  }

bool DoubleIs1Equal2(double number1,double number2, int digits = 8)
  {
   if(NormalizeDouble(number1-number2,digits )==0) return(true);
   else return(false);
  } 
/*
Don't use
if(OrdersTotal()<1) // check if there are any postions open
for checking if there are any positions open.....

it will fail if there are manually opened trades on your account or trades from other EA's

Check number of trades with something like
//--------------------------------------------------------------------
    if(TotalTrades > 0)    //if(OrdersTotal()<1) no need to check all trades if from EA no opened
      {
       TotalTrades = 0;    //int
       SELLTRADES = 0;     //int
       BUYTRADES = 0;      //int
       for(i = OrdersTotal()-1; i >= 0 ; i--)  //count down checking trades
          {
           if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) //Orderselect and check symbol + EAnr
             {
              if (OrderSymbol()==Symbol() &&  OrderMagicNumber() == MagicNumber)
                 {
                  TotalTrades++;
                  if(OrderType() == OP_BUY)BUYTRADES++;
                  if(OrderType() == OP_SELL)SELLTRADES++;
                 }
              }
           }
       }
*/

//+------------------------------------------------------------------+
//| RSI function. The iRSI is not performed correctly as expected    |
//+------------------------------------------------------------------+
// Reason: iRSI doesn't adjust to the period in the first bar, instead, it start over
// every new period. Let say 14 period, it will get the value of the last 14th bar to 
// caculate the value.
double GetRSI(int RSIperiod, int shift)
{
   double vSumUp = 0, vSumDown = 0, vDiff = 0;
   // Must get the RSI value on the very first bar
   int iStartBar = Bars - RSIperiod -1;
   for(int iFirstCalc = iStartBar; iFirstCalc < iStartBar+ RSIperiod; iFirstCalc++){
      vDiff = Close[iFirstCalc] - Close[iFirstCalc+1];
      if(vDiff > 0){
         vSumUp += vDiff;
      }else{
         vSumDown += MathAbs(vDiff);
      }
   }
   double vAvgUp = vSumUp/RSIperiod;
   double vAvgDown = vSumDown/RSIperiod;
   
   // And now, we have to calculate the smoothed RSI value for 
   // each subsequent bar until we get to the one requested
   for(int iRepeat = iStartBar -1; iRepeat >=shift; iRepeat--){
      vDiff = Close[iRepeat]-Close[iRepeat+1];
      if(vDiff>0){
         vAvgUp = ( (vAvgUp*(RSIperiod -1) ) + vDiff ) /RSIperiod;
         vAvgDown = ( (vAvgDown*(RSIperiod-1)) ) / RSIperiod;
      }else{
         vAvgUp = ( (vAvgUp * (RSIperiod-1)) ) / RSIperiod;
         vAvgDown = ( (vAvgDown*(RSIperiod -1) ) + MathAbs(vDiff) ) / RSIperiod;
      }
   }
   
   if(vAvgDown==0)
      return 0;
   else
      return(100.0-100.0/(1+(vAvgUp/vAvgDown) ) );
}


//+------------------------------------------------------------------------+
//|   StochRSI function.                                                   |
//|StochRSI = (RSI - Lowest Low RSI) / (Highest High RSI - Lowest Low RSI) |
//+------------------------------------------------------------------------+
//double StochRSI(int period)