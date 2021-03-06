//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow1(const string caption_text)
  {
//--- Add the window pointer to the window array
   CWndContainer::AddWindow(m_window1);
//--- Coordinates
   int x=(m_window1.X()>0) ? m_window1.X() : 1;
   int y=(m_window1.Y()>0) ? m_window1.Y() : 1;
//--- Properties
   m_window1.XSize(518);
   m_window1.YSize(600);
   m_window1.Alpha(200);
   m_window1.IconXGap(3);
   m_window1.IconYGap(2);
   m_window1.IsMovable(true);
   m_window1.ResizeMode(true);
   m_window1.CloseButtonIsUsed(true);
   m_window1.FullscreenButtonIsUsed(true);
   m_window1.CollapseButtonIsUsed(true);
   m_window1.TooltipsButtonIsUsed(true);
   m_window1.RollUpSubwindowMode(true,true);
   m_window1.TransparentOnlyCaption(true);
//--- Set the tooltips
   m_window1.GetCloseButtonPointer().Tooltip("Close");
   m_window1.GetFullscreenButtonPointer().Tooltip("Fullscreen/Minimize");
   m_window1.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
   m_window1.GetTooltipButtonPointer().Tooltip("Tooltips");
//--- Creating a form
   if(!m_window1.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the status bar                                           |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp"
//---
bool CProgram::CreateStatusBar(const int x_gap,const int y_gap)
  {
#define STATUS_LABELS_TOTAL 2
//--- Store the pointer to the main control
   m_status_bar.MainPointer(m_window1);
//--- Width
   int width[]={0,130};
//--- Properties
   m_status_bar.YSize(22);
   m_status_bar.AutoXResizeMode(true);
   m_status_bar.AutoXResizeRightOffset(1);
   m_status_bar.AnchorBottomWindowSide(true);
//--- Add items
   for(int i=0; i<STATUS_LABELS_TOTAL; i++)
      m_status_bar.AddItem(width[i]);
//--- Setting the text
   m_status_bar.SetValue(0,"For Help, press F1");
   m_status_bar.SetValue(1,"Disconnected...");
//--- Setting the icons
   m_status_bar.GetItemPointer(1).LabelXGap(25);
   m_status_bar.GetItemPointer(1).AddImagesGroup(5,3);
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp");
//--- Create a control
   if(!m_status_bar.CreateStatusBar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create icon 1                                                    |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\resize_window.bmp"
//---
bool CProgram::CreatePicture1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_picture1.MainPointer(m_status_bar);
//--- Properties
   m_picture1.XSize(8);
   m_picture1.YSize(8);
   m_picture1.IconFile("Images\\EasyAndFastGUI\\Controls\\resize_window.bmp");
   m_picture1.AnchorRightWindowSide(true);
   m_picture1.AnchorBottomWindowSide(true);
//--- Creating the button
   if(!m_picture1.CreatePicture(x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_picture1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create area with tabs                                            |
//+------------------------------------------------------------------+
bool CProgram::CreateTabs1(const int x_gap,const int y_gap)
  {
#define TABS1_TOTAL 4
//--- Store the pointer to the main control
   m_tabs1.MainPointer(m_window1);
//--- Array with width for tabs
   int tabs_width[TABS1_TOTAL];
   ::ArrayInitialize(tabs_width,45);
   tabs_width[0]=80;
   tabs_width[1]=105;
   tabs_width[2]=45;
//---
   string tabs_names[TABS1_TOTAL]={"Background","Indents & history","Grid","Axes"};
//--- Properties
   m_tabs1.XSize(400);
   m_tabs1.YSize(140);
   m_tabs1.TabsYSize(22);
   m_tabs1.IsCenterText(true);
   m_tabs1.PositionMode(TABS_TOP);
   m_tabs1.AutoXResizeMode(true);
   m_tabs1.AutoXResizeRightOffset(7);
   m_tabs1.SelectedTab((m_tabs1.SelectedTab()==WRONG_VALUE) ? 3 : m_tabs1.SelectedTab());
//--- Add tabs with the specified properties
   for(int i=0; i<TABS1_TOTAL; i++)
      m_tabs1.AddTab((tabs_names[i]!="")? tabs_names[i] : "Tab "+string(i+1),tabs_width[i]);
//--- Create a control
   if(!m_tabs1.CreateTabs(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_tabs1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create chart 1                                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateGraph1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_graph1.MainPointer(m_window1);
//--- Properties
   m_graph1.AutoXResizeMode(true);
   m_graph1.AutoYResizeMode(true);
   m_graph1.AutoXResizeRightOffset(2);
   m_graph1.AutoYResizeBottomOffset(24);
//--- Create control
   if(!m_graph1.CreateGraph(x_gap,y_gap))
      return(false);
//--- Chart properties
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.BackgroundColor(::ColorToARGB(clrWhiteSmoke));
//--- Initialize the arrays
   InitGraph1Arrays();
//--- Create the curves
   CCurve *curve1=graph.CurveAdd(data1,::ColorToARGB(clrCornflowerBlue),CURVE_LINES);
   CCurve *curve2=graph.CurveAdd(data2,::ColorToARGB(clrRed),CURVE_LINES);
//--- Plot the data on the chart
   graph.CurvePlotAll();
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_graph1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create form 2 for the color picker                               |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\color_picker.bmp"
//---
bool CProgram::CreateWindow2(const string caption_text)
  {
//--- Store the window pointer
   CWndContainer::AddWindow(m_window2);
//--- Coordinates
   int x =(m_window2.X()>0) ? m_window2.X() : 100;
   int y =(m_window2.Y()>0) ? m_window2.Y() : 100;
//--- Properties
   m_window2.Alpha(200);
   m_window2.XSize(350);
   m_window2.YSize(287);
   m_window2.IconXGap(3);
   m_window2.IconYGap(2);
   m_window2.IsMovable(true);
   m_window2.WindowType(W_DIALOG);
   m_window2.CloseButtonIsUsed(true);
   m_window2.IconFile("Images\\EasyAndFastGUI\\Icons\\bmp16\\color_picker.bmp");
//--- Creating a form
   if(!m_window2.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create color picker to select a color                            |
//+------------------------------------------------------------------+
bool CProgram::CreateColorPicker(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_color_picker.MainPointer(m_window2);
//--- Create control
   if(!m_color_picker.CreateColorPicker(x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(1,m_color_picker);
   return(true);
  }
//+------------------------------------------------------------------+
//| Resize the arrays 1                                              |
//+------------------------------------------------------------------+
void CProgram::ResizeGraph1Arrays(void)
  {
   int array_size =::ArraySize(data1);
   int new_size   =1000;
//--- Leave, if the size has not changed
   if(array_size==new_size)
      return;
//--- Set the new size
   ResizeGraph1Arrays(new_size);
//--- Initialization
   ZeroGraph1Arrays();
  }
//+------------------------------------------------------------------+
//| Resize the arrays 1                                              |
//+------------------------------------------------------------------+
void CProgram::ResizeGraph1Arrays(const int new_size)
  {
   ::ArrayResize(data1,new_size);
   ::ArrayResize(data2,new_size);
  }
//+------------------------------------------------------------------+
//| Initialization of arrays                                         |
//+------------------------------------------------------------------+
void CProgram::InitGraph1Arrays(void)
  {
//--- Resize the arrays
   ResizeGraph1Arrays();
//--- Fill the arrays with random data
   int total=::ArraySize(data1);
   for(int i=0; i<total; i++)
      SetGraph1Value(i);
  }
//+------------------------------------------------------------------+
//| Zero the arrays 1                                                |
//+------------------------------------------------------------------+
void CProgram::ZeroGraph1Arrays(void)
  {
   ::ArrayInitialize(data1,NULL);
   ::ArrayInitialize(data2,NULL);
  }
//+------------------------------------------------------------------+
//| Set random value at the specified index                          |
//+------------------------------------------------------------------+
void CProgram::SetGraph1Value(const int index)
  {
   if(index==0)
     {
      int start_value=0;
      data1[index]=start_value;
      data2[index]=start_value;
      return;
     }
//---
   int rand_value =::rand()%10*::rand()%10;
   int direction  =(bool(::rand()%2))? rand_value : -rand_value;
   data1[index]   =data1[index-1]+direction;
//---
   rand_value   =::rand()%10*::rand()%10;
   direction    =(bool(::rand()%2))? rand_value : -rand_value;
   data2[index] =data2[index-1]+direction;
  }
//+------------------------------------------------------------------+
