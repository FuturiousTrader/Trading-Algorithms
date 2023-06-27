//+------------------------------------------------------------------+
//|                                         ExpertAdvisor_BB_RSI.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <RecurrentFonctions.mqh>
#include <stderror.mqh>
#include <stdlib.mqh>

int bbPeriod = 50;
int band1Std = 1;
int band2Std = 2;
int band6Std = 6;
int RSIPeriod = 14;
int magicNumber = 2;
int orderID;
double lotSize = 0.50;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      Alert("Expert Advisor has started");
      Alert("");
      IsTradingAllowed();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      Alert("Expert Advisor has been closed"); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      double bbLower1 = NormalizeDouble(iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,MODE_LOWER,0),_Digits);
      double bbUpper1 = NormalizeDouble(iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,MODE_UPPER,0), _Digits);
      double bbMid = NormalizeDouble(iBands(NULL,0,bbPeriod,band1Std,0,PRICE_CLOSE,0,0),_Digits);
      
      double bbLower2 = NormalizeDouble(iBands(NULL,0,bbPeriod,band2Std,0,PRICE_CLOSE,MODE_LOWER,0),_Digits);
      double bbUpper2 = NormalizeDouble(iBands(NULL,0,bbPeriod,band2Std,0,PRICE_CLOSE,MODE_UPPER,0),_Digits);
      
      double bbLower6 = NormalizeDouble(iBands(NULL,0,bbPeriod,band6Std,0,PRICE_CLOSE,MODE_LOWER,0),_Digits);
      double bbUpper6 = NormalizeDouble(iBands(NULL,0,bbPeriod,band6Std,0,PRICE_CLOSE,MODE_UPPER,0),_Digits);
      
      double RSI = NormalizeDouble(iRSI(NULL,0, 14, PRICE_CLOSE, 0),Digits);
      
      if (orderOpenbyThisExpertAdvisor(magicNumber))
      {
        if (OrderSelect(orderID,SELECT_BY_TICKET) == true)
         {
             int orderType = OrderType();
             double TP = OrderTakeProfit();
             double actualizedTakeProfit = 0;
             if (orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP)
             {
               actualizedTakeProfit = NormalizeDouble(bbUpper1,Digits);
             } 
             else 
             {
               actualizedTakeProfit = NormalizeDouble(bbLower1,Digits);
             }
             
             if (TP != actualizedTakeProfit)
             {
                 bool answer = OrderModify(orderID, OrderOpenPrice(),OrderStopLoss(), actualizedTakeProfit,0);
                 if(answer)
                 {
                  Alert ("Order Modified : " + orderID);
                 }
             }
         }         
      }
      else
      {
         if(NormalizeDouble(Ask, Digits) < bbLower2 && RSI < 40) // buying
         {
            Alert("Price is bellow bbLower2 and RSI is below 40. Sending buy order");
            double stopLossPrice = NormalizeDouble(bbLower6,Digits);
            double takeProfitPrice = NormalizeDouble(bbUpper1,Digits);
            Alert("Entry Price = " + NormalizeDouble(Ask,Digits));
            Alert("Stop Loss Price = " + stopLossPrice);
            Alert("Take Profit Price = " + takeProfitPrice);
            orderID = OrderSend(NULL,OP_BUYLIMIT,lotSize,Ask,20,stopLossPrice,takeProfitPrice,NULL, magicNumber);
            int check=GetLastError();
            if(check!=ERR_NO_ERROR) Alert("Message not sent. Error: ",ErrorDescription(check));
         }
         else if(NormalizeDouble(Bid, Digits) > bbUpper2 && RSI > 60 )//shorting
         {   
            Alert("Price is above bbUpper2 and RSI is upper 60. Sending short order");
            double stopLossPrice = NormalizeDouble(bbUpper6,Digits);
            double takeProfitPrice = NormalizeDouble(bbLower1,Digits);
            Alert("Entry Price = " + NormalizeDouble(Bid,Digits));
            Alert("Stop Loss Price = " + stopLossPrice);
            Alert("Take Profit Price = " + takeProfitPrice);
      	   orderID = OrderSend(NULL,OP_SELLLIMIT,lotSize,Bid,20,stopLossPrice,takeProfitPrice,NULL, magicNumber);
      	   int check=GetLastError();
            if(check!=ERR_NO_ERROR) Alert("Message not sent. Error: ",ErrorDescription(check));           
         }       
      }
  }
//+------------------------------------------------------------------+
