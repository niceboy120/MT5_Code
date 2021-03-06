//+------------------------------------------------------------------+
//|                                                   ElBmpImage.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "ElChart.mqh"
//+------------------------------------------------------------------+
//| Image class                                                      |
//+------------------------------------------------------------------+
class CElBmpImage : public CElChart
{
private:
   string m_path_img;         // The path to the image
public:
   CElBmpImage(void);
   void AddImage(string path);
   virtual void OnShow(void);
};

CElBmpImage::CElBmpImage(void) : CElChart(OBJ_BITMAP_LABEL)
{ 
}
//+------------------------------------------------------------------+
//| Displays an image                                                |
//+------------------------------------------------------------------+
void CElBmpImage::OnShow(void)
{
   if(IsShowed() && m_path_img != "")
      ObjectSetString(ChartID(), Name(), OBJPROP_BMPFILE, 0, m_path_img);
   int err = GetLastError();
   CNode::OnShow();
}
//+------------------------------------------------------------------+
//| Loads an image                                                   |
//+------------------------------------------------------------------+
void CElBmpImage::AddImage(string path)
{
   m_path_img = path;
}