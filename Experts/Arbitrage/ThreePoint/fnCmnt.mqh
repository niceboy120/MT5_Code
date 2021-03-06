//просто вывод комментариев на экран

#include "head.mqh"

void fnCmnt(stThree &MxSmb[], ushort lcOpenThree)
   {     
      int total=ArraySize(MxSmb);
      
      string line="=============================\n";
      string txt=line+MQLInfoString(MQL_PROGRAM_NAME)+": ON\n";
      txt=txt+"Total triangles: "+(string)total+"\n";
      txt=txt+"Open triangles: "+(string)lcOpenThree+"\n"+line;
      
      // столько максимум треугольников выводиться на экран
      short max=5;
      max=(short)MathMin(total,max);
      
      //вывод 5 ближайших к открытию
      short index[];// массивов индексов
      ArrayResize(index,max);
      ArrayInitialize(index,-1);// -1 значит что не сипользуется
      short cnt=0,num=0;
      while(cnt<max && num<total)   //взяли для старта первые max не открытых индексов треугольников
      {
         if(MxSmb[num].status!=0)  {num++;continue;}
         index[cnt]=num;
         num++;cnt++;         
      }
      
      // сортировать и искать есть смысл только если элементов больше чем можно вывести на экран
      if (total>max) 
      for(short i=max;i<total;i++)
      {
         // открытые треугольники выводяться ниже
         if(MxSmb[i].status!=0) continue;
         
         for(short j=0;j<max;j++)
         {
            if (MxSmb[i].PLBuy>MxSmb[index[j]].PLBuy)  {index[j]=i;break;}
            if (MxSmb[i].PLSell>MxSmb[index[j]].PLSell)  {index[j]=i;break;}
         }   
      }
      
      // выводим ближайшие к отрытию треугольники
      bool flag=true;
      for(short i=0;i<max;i++)
      {
         cnt=index[i];
         if (cnt<0) continue;
         if (flag)
         {
            txt=txt+"Smb1           Smb2           Smb3         P/L Buy        P/L Sell        Spread\n";
            flag=false;
         }         
         txt=txt+MxSmb[cnt].smb1.name+" + "+MxSmb[cnt].smb2.name+" + "+MxSmb[cnt].smb3.name+":";
         txt=txt+"      "+DoubleToString(MxSmb[cnt].PLBuy,2)+"          "+DoubleToString(MxSmb[cnt].PLSell,2)+"            "+DoubleToString(MxSmb[cnt].spread,2)+"\n";      
      }            
      
      // выводим открытые треугольники
      txt=txt+line+"\n";
      for(int i=total-1;i>=0;i--)
      if (MxSmb[i].status==2)
      {
         txt=txt+MxSmb[i].smb1.name+"+"+MxSmb[i].smb2.name+"+"+MxSmb[i].smb3.name+" P/L: "+DoubleToString(MxSmb[i].pl,2);
         txt=txt+"  Time open: "+TimeToString(MxSmb[i].timeopen,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
         txt=txt+"\n";
      }   
      Comment(txt);
   }