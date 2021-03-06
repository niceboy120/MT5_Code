//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
//--- Add the window pointer to the window array
   CWndContainer::AddWindow(m_window);
//--- Coordinates
   int x=(m_window.X()>0) ? m_window.X() : 1;
   int y=(m_window.Y()>0) ? m_window.Y() : 1;
//--- Properties
   m_window.XSize(640);
   m_window.YSize(450);
   m_window.Alpha(200);
   m_window.IconXGap(3);
   m_window.IconYGap(2);
   m_window.IsMovable(true);
   m_window.ResizeMode(true);
   m_window.CloseButtonIsUsed(true);
   m_window.FullscreenButtonIsUsed(true);
   m_window.CollapseButtonIsUsed(true);
   m_window.TooltipsButtonIsUsed(true);
   m_window.RollUpSubwindowMode(true,true);
   m_window.TransparentOnlyCaption(true);
//--- Set the tooltips
   m_window.GetCloseButtonPointer().Tooltip("Close");
   m_window.GetFullscreenButtonPointer().Tooltip("Fullscreen/Minimize");
   m_window.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
   m_window.GetTooltipButtonPointer().Tooltip("Tooltips");
//--- Creating a form
   if(!m_window.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
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
   m_status_bar.MainPointer(m_window);
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
//| Create the "Delay" edit box                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateSpinEditDelay(const int x_gap,const int y_gap,string text)
  {
//--- Store the pointer to the main control
   m_delay_ms.MainPointer(m_window);
//--- Properties
   m_delay_ms.XSize(144);
   m_delay_ms.MaxValue(1000);
   m_delay_ms.MinValue(1);
   m_delay_ms.StepValue(1);
   m_delay_ms.SetDigits(0);
   m_delay_ms.SpinEditMode(true);
   m_delay_ms.SetValue((string)16);
   m_delay_ms.GetTextBoxPointer().XSize(50);
   m_delay_ms.GetTextBoxPointer().AutoSelectionMode(true);
   m_delay_ms.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_delay_ms.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_delay_ms);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Series Total" combo box                              |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxSeriesTotal(const int x_gap,const int y_gap,const string text)
  {
#define ROWS1_TOTAL 20
//--- Store the pointer to the main control
   m_series_total.MainPointer(m_window);
//--- Properties
   m_series_total.XSize(144);
   m_series_total.ItemsTotal(ROWS1_TOTAL);
   m_series_total.GetButtonPointer().XSize(50);
   m_series_total.GetButtonPointer().AnchorRightWindowSide(true);
//--- Populate the combo box list
   for(int i=0; i<ROWS1_TOTAL; i++)
      m_series_total.SetValue(i,string(i+1));
//--- List properties
   CListView *lv=m_series_total.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 5 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_series_total.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_series_total);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Increment Ratio" checkbox with edit control          |
//+------------------------------------------------------------------+
bool CProgram::CreateCheckBoxEditIncrementRatio(const int x_gap,const int y_gap,string text)
  {
//--- Store the pointer to the main control
   m_increment_ratio.MainPointer(m_window);
//--- Properties
   m_increment_ratio.XSize(160);
   m_increment_ratio.MaxValue(100);
   m_increment_ratio.MinValue(1);
   m_increment_ratio.StepValue(1);
   m_increment_ratio.SetDigits(0);
   m_increment_ratio.CheckBoxMode(true);
   m_increment_ratio.SpinEditMode(true);
   m_increment_ratio.SetValue((string)35);
   m_increment_ratio.GetTextBoxPointer().XSize(50);
   m_increment_ratio.GetTextBoxPointer().AutoSelectionMode(true);
   m_increment_ratio.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_increment_ratio.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_increment_ratio);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Offset Series" edit box                              |
//+------------------------------------------------------------------+
bool CProgram::CreateSpinEditOffsetSeries(const int x_gap,const int y_gap,string text)
  {
//--- Store the pointer to the main control
   m_offset_series.MainPointer(m_window);
//--- Properties
   m_offset_series.XSize(160);
   m_offset_series.MaxValue(1);
   m_offset_series.MinValue(0.01);
   m_offset_series.StepValue(0.01);
   m_offset_series.SetDigits(2);
   m_offset_series.SpinEditMode(true);
   m_offset_series.SetValue((string)1.00);
   m_offset_series.GetTextBoxPointer().XSize(50);
   m_offset_series.GetTextBoxPointer().AutoSelectionMode(true);
   m_offset_series.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_offset_series.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_offset_series);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Min. Limit Size" control                             |
//+------------------------------------------------------------------+
bool CProgram::CreateSpinEditMinLimitSize(const int x_gap,const int y_gap,string text)
  {
//--- Store the window pointer
   m_min_limit_size.MainPointer(m_window);
//--- Properties
   m_min_limit_size.XSize(162);
   m_min_limit_size.MaxValue(100);
   m_min_limit_size.MinValue(2);
   m_min_limit_size.StepValue(1);
   m_min_limit_size.SetDigits(0);
   m_min_limit_size.SetValue((string)2);
   m_min_limit_size.SpinEditMode(true);
   m_min_limit_size.GetTextBoxPointer().XSize(50);
   m_min_limit_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_min_limit_size.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_min_limit_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_min_limit_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Max. Limit Size" checkbox with edit control        |
//+------------------------------------------------------------------+
bool CProgram::CreateCheckBoxEditMaxLimitSize(const int x_gap,const int y_gap,string text)
  {
//--- Store the pointer to the main control
   m_max_limit_size.MainPointer(m_window);
//--- Properties
   m_max_limit_size.XSize(162);
   m_max_limit_size.MaxValue(10000);
   m_max_limit_size.MinValue(50);
   m_max_limit_size.StepValue(1);
   m_max_limit_size.SetDigits(0);
   m_max_limit_size.CheckBoxMode(true);
   m_max_limit_size.SpinEditMode(true);
   m_max_limit_size.SetValue((string)50);
   m_max_limit_size.GetTextBoxPointer().XSize(50);
   m_max_limit_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_max_limit_size.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_max_limit_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_max_limit_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Run Speed" checkbox with edit control                |
//+------------------------------------------------------------------+
bool CProgram::CreateCheckBoxEditRunSpeed(const int x_gap,const int y_gap,string text)
  {
//--- Store the pointer to the main control
   m_run_speed.MainPointer(m_window);
//--- Properties
   m_run_speed.XSize(134);
   m_run_speed.MaxValue(1);
   m_run_speed.MinValue(0.01);
   m_run_speed.StepValue(0.01);
   m_run_speed.SetDigits(2);
   m_run_speed.CheckBoxMode(true);
   m_run_speed.SpinEditMode(true);
   m_run_speed.SetValue((string)0.05);
   m_run_speed.GetTextBoxPointer().XSize(50);
   m_run_speed.GetTextBoxPointer().AutoSelectionMode(true);
   m_run_speed.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_run_speed.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_run_speed);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Series Size" edit box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateSpinEditSeriesSize(const int x_gap,const int y_gap,string text)
  {
//--- Store the pointer to the main control
   m_series_size.MainPointer(m_window);
//--- Properties
   m_series_size.XSize(134);
   m_series_size.MaxValue(m_max_limit_size.MaxValue());
   m_series_size.MinValue(m_min_limit_size.MinValue());
   m_series_size.StepValue(1);
   m_series_size.SetDigits(0);
   m_series_size.SpinEditMode(true);
   m_series_size.SetValue((string)18);
   m_series_size.GetTextBoxPointer().XSize(50);
   m_series_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_series_size.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_series_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_series_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Function" combo box                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxFunction(const int x_gap,const int y_gap,const string text)
  {
#define ROWS2_TOTAL 3
//--- Store the pointer to the main control
   m_function.MainPointer(m_window);
//--- Properties
   m_function.XSize(144);
   m_function.ItemsTotal(ROWS2_TOTAL);
   m_function.GetButtonPointer().XSize(50);
   m_function.GetButtonPointer().AnchorRightWindowSide(true);
//--- Populate the combo box list
   for(int i=0; i<ROWS2_TOTAL; i++)
      m_function.SetValue(i,string(i+1));
//--- List properties
   CListView *lv=m_function.GetListViewPointer();
   lv.YSize(57);
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 0 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_function.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_function);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Curve type" combo box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxCurveType(const int x_gap,const int y_gap,const string text)
  {
#define ROWS3_TOTAL 5
//--- Store the pointer to the main control
   m_curve_type.MainPointer(m_window);
//--- Properties
   m_curve_type.XSize(225);
   m_curve_type.ItemsTotal(ROWS3_TOTAL);
   m_curve_type.GetButtonPointer().XSize(160);
   m_curve_type.GetButtonPointer().AnchorRightWindowSide(true);
//--- Array of the chart line types
   string array[]={"CURVE_POINTS","CURVE_LINES","CURVE_POINTS_AND_LINES","CURVE_STEPS","CURVE_HISTOGRAM"};
//--- Populate the combo box list
   for(int i=0; i<ROWS3_TOTAL; i++)
      m_curve_type.SetValue(i,array[i]);
//--- List properties
   CListView *lv=m_curve_type.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 1 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_curve_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_curve_type);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Point type" combo box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxPointType(const int x_gap,const int y_gap,const string text)
  {
#define ROWS4_TOTAL 10
//--- Store the pointer to the main control
   m_point_type.MainPointer(m_window);
//--- Properties
   m_point_type.XSize(235);
   m_point_type.ItemsTotal(ROWS4_TOTAL);
   m_point_type.GetButtonPointer().XSize(170);
   m_point_type.GetButtonPointer().AnchorRightWindowSide(true);
//--- Array of the chart point types
   string array[]={"POINT_CIRCLE","POINT_SQUARE","POINT_DIAMOND","POINT_TRIANGLE","POINT_TRIANGLE_DOWN",
                   "POINT_X_CROSS","POINT_PLUS","POINT_STAR","POINT_HORIZONTAL_DASH","POINT_VERTICAL_DASH"};
//--- Populate the combo box list
   for(int i=0; i<ROWS4_TOTAL; i++)
      m_point_type.SetValue(i,array[i]);
//--- List properties
   CListView *lv=m_point_type.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 0 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_point_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_point_type);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create chart 1                                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateGraph1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_graph1.MainPointer(m_window);
//--- Properties
   m_graph1.XSize(500);
   m_graph1.YSize(300);
   m_graph1.AutoXResizeMode(true);
   m_graph1.AutoYResizeMode(true);
   m_graph1.AutoXResizeRightOffset(2);
   m_graph1.AutoYResizeBottomOffset(23);
//--- Create control
   if(!m_graph1.CreateGraph(x_gap,y_gap))
      return(false);
//--- Calculate the series
   RecalculatingSeries();
//--- Apply to chart
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.CalculateMaxMinValues();
   graph.CurvePlotAll();
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_graph1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create progress bar                                              |
//+------------------------------------------------------------------+
bool CProgram::CreateProgressBar(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_progress_bar.MainPointer(m_status_bar);
//--- Properties
   m_progress_bar.XSize(220);
   m_progress_bar.YSize(15);
   m_progress_bar.BarYSize(11);
   m_progress_bar.BarXGap(75);
   m_progress_bar.BarYGap(2);
   m_progress_bar.LabelYGap(1);
   m_progress_bar.PercentYGap(1);
   m_progress_bar.IndicatorBackColor(clrWhiteSmoke);
   m_progress_bar.AutoXResizeMode(true);
   m_progress_bar.AutoXResizeRightOffset(135);
   m_progress_bar.IsDropdown(true);
//--- Create control
   if(!m_progress_bar.CreateProgressBar(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_progress_bar);
   return(true);
  }
//+------------------------------------------------------------------+
//| Update the chart by timer                                        |
//+------------------------------------------------------------------+
void CProgram::UpdateGraphByTimer(void)
  {
//--- Leave, if the form is minimized or is in the process of moving
   if(m_window.IsMinimized())
      return;
//--- Leave, if the animation is disabled
   if(!m_max_limit_size.IsPressed() && !m_run_speed.IsPressed())
      return;
//--- If the "Running series" option is enabled, shift the first value of the series
   ShiftGraphSeries();
//--- If the management of series array size by timer is enabled
   AutoResizeGraphSeries();
//--- Initialize the arrays
   InitArrays();
//--- (1) Calculate and (2) update the series
   CalculateSeries();
   UpdateSeries();
  }
//+------------------------------------------------------------------+
//| Initializing the chart                                           |
//+------------------------------------------------------------------+
void CProgram::InitGraph(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
//--- Area color
   graph.BackgroundColor(::ColorToARGB(clrWhiteSmoke));
//--- Indents
   graph.GapSize(6);
   graph.IndentLeft(-20);
   graph.IndentRight(0);
//--- The number of values and grid step on the X axis
   double data_total   =(double)int(m_series_size.GetValue())-1;
   double default_step =(data_total<10)? 1 : ::MathFloor(data_total/10.0);
//--- Properties of the X axis
   CAxis *x_axis=graph.XAxis();
   x_axis.AutoScale(false);
   x_axis.MaxGrace(0);
   x_axis.MinGrace(0);
   x_axis.DefaultStep(default_step);
   x_axis.Max(data_total);
   x_axis.Min(0);
//--- Properties of the Y axis
   CAxis *y_axis=graph.YAxis();
   y_axis.AutoScale(false);
   y_axis.MaxGrace(0);
   y_axis.MinGrace(0);
   y_axis.DefaultStep(0.4);
   y_axis.Max(2);
   y_axis.Min(-2);
  }
//+------------------------------------------------------------------+
//| Resize the series array                                          |
//+------------------------------------------------------------------+
void CProgram::ResizeCurveArrays(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
//--- If there are series, delete them
   int total=graph.CurvesTotal();
   if(total>0)
     {
      for(int i=total-1; i>=0; i--)
         graph.CurveRemoveByIndex(i);
      //--- Reset the chart parameters
      graph.SetDefaultParameters();
     }
//--- Set the new size
   int new_total=(int)m_series_total.GetValue();
   ::ArrayResize(m_series,new_total);
  }
//+------------------------------------------------------------------+
//| Resize the data arrays                                           |
//+------------------------------------------------------------------+
void CProgram::ResizeDataArrays(void)
  {
//--- Set the number of series on the chart
   ResizeCurveArrays();
//--- Resize the data arrays
   int total          =(int)m_series_total.GetValue();
   int size_of_series =(int)m_series_size.GetValue();
   for(int s=0; s<total; s++)
     {
      //--- Resize the arrays
      ::ArrayResize(m_series[s].data,size_of_series);
      ::ArrayResize(m_series[s].data_temp,size_of_series);
     }
  }
//+------------------------------------------------------------------+
//| Initialization of the auxiliary arrays for calculations          |
//+------------------------------------------------------------------+
void CProgram::InitArrays(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
//---
   int curves_total =graph.CurvesTotal();
   int series_total =(int)m_series_total.GetValue();
//---
   int total=(curves_total>0)? curves_total : series_total;
//---
   for(int s=0; s<total; s++)
     {
      int size_of_series=::ArraySize(m_series[s].data_temp);
      //---
      for(int i=0; i<size_of_series; i++)
        {
         if(i==0)
           {
            if(s>0)
               m_series[s].data_temp[i]=m_series[s-1].data_temp[i]+(double)m_offset_series.GetValue();
            else
               m_series[s].data_temp[i]=m_run_speed_counter;
           }
         else
            m_series[s].data_temp[i]=m_series[s].data_temp[i-1]+(int)m_increment_ratio.GetValue();
        }
     }
  }
//+------------------------------------------------------------------+
//| Calculate the series                                             |
//+------------------------------------------------------------------+
void CProgram::CalculateSeries(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
//---
   int curves_total =graph.CurvesTotal();
   int series_total =(int)m_series_total.GetValue();
//---
   int total=(curves_total>0)? curves_total : series_total;
//---
   for(int s=0; s<total; s++)
     {
      int size_of_series=::ArraySize(m_series[s].data_temp);
      //---
      for(int i=0; i<size_of_series; i++)
        {
         m_series[s].data_temp[i]+=(double)m_offset_series.GetValue();
         //---
         m_series[s].data[i]=::sin(m_series[s].data_temp[i])-::cos(m_series[s].data_temp[i]);
         //---
         int index=m_function.GetListViewPointer().SelectedItemIndex();
         switch(index)
           {
            case 0 :
               m_series[s].data[i]=::sin(m_series[s].data_temp[i])-::cos(m_series[s].data_temp[i]);
               break;
            case 1 :
               m_series[s].data[i]=::sin(m_series[s].data_temp[i]-::cos(m_series[s].data_temp[i]));
               break;
            case 2 :
               m_series[s].data[i]=::sin(m_series[s].data_temp[i]*10)-::cos(m_series[s].data_temp[i]);
               break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Calculate and place the series on the chart                      |
//+------------------------------------------------------------------+
void CProgram::AddSeries(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
//--- Color generator
   CColorGenerator generator;
//--- Add the specified number of series on the chart
   int total=(int)m_series_total.GetValue();
   for(int s=0; s<total; s++)
     {
      uint            clr        =generator.Next();
      ENUM_CURVE_TYPE curve_type =(ENUM_CURVE_TYPE)m_curve_type.GetListViewPointer().SelectedItemIndex();
      //--- Add the series with the specified color and type
      graph.CurveAdd(m_series[s].data,clr,curve_type);
      //---
      ENUM_POINT_TYPE point_type =(ENUM_POINT_TYPE)m_point_type.GetListViewPointer().SelectedItemIndex();
      graph.CurveGetByIndex(s).PointsType(point_type);
     }
  }
//+------------------------------------------------------------------+
//| Calculate and update series on the chart                         |
//+------------------------------------------------------------------+
void CProgram::UpdateSeries(void)
  {
   CGraphic *graph=m_graph1.GetGraphicPointer();
//--- Update all series of the chart
   int total=graph.CurvesTotal();
   for(int s=0; s<total; s++)
      {
       graph.CurveGetByIndex(s).Update(m_series[s].data);
       graph.CurveGetByIndex(s).LinesSmooth(false);
      }
//--- Initialize the chart properties
   InitGraph();
//--- Apply 
   graph.CalculateMaxMinValues();
   graph.CurvePlotAll();
   graph.Update();
  }
//+------------------------------------------------------------------+
//| Recalculate the series on the chart                              |
//+------------------------------------------------------------------+
void CProgram::RecalculatingSeries(void)
  {
//--- (1) Set the sizes of arrays and (2) initialize them
   ResizeDataArrays();
   InitArrays();
//--- (1) Calculate, (2) add to the chart and (3) update the series
   CalculateSeries();
   AddSeries();
   UpdateSeries();
  }
//+------------------------------------------------------------------+
//| Shift the chart series                                           |
//+------------------------------------------------------------------+
void CProgram::ShiftGraphSeries(void)
  {
   if(m_run_speed.IsPressed())
      m_run_speed_counter+=(double)m_run_speed.GetValue();
  }
//+------------------------------------------------------------------+
//| Auto-resize the chart series                                     |
//+------------------------------------------------------------------+
void CProgram::AutoResizeGraphSeries(void)
  {
//--- Leave, if increasing the series array by timer is disabled
   if(!m_max_limit_size.IsPressed())
      return;
//--- To specify the direction to resize the arrays
   static bool resize_direction=false;
//--- If the minimum array size is reached
   if((int)m_series_size.GetValue()<=(int)m_min_limit_size.GetValue())
     {
      //--- Switch the direction to increasing the array
      resize_direction=false;
      //--- If it is necessary to change the value of X
      if(m_increment_ratio.IsPressed())
        {
         //--- To specify the direction of the increment ratio counter
         static bool increment_ratio_direction=true;
         //--- If the counter is directed at increasing
         if(increment_ratio_direction)
           {
            //--- If the maximum limit is reached, change the counter direction to the opposite
            if((int)m_increment_ratio.GetValue()>=(int)m_increment_ratio.MaxValue()-1)
               increment_ratio_direction=false;
           }
         //--- If the counter is directed at decreasing
         else
           {
            //--- If the minimum limit is reached, change the counter direction to the opposite
            if((int)m_increment_ratio.GetValue()<=(int)m_increment_ratio.MinValue()+1)
               increment_ratio_direction=true;
           }
         //--- Get the current value of the "Increment ratio" parameter and change it in the specified direction
         int increase_value=(int)m_increment_ratio.GetValue();
         m_increment_ratio.SetValue((increment_ratio_direction)? string(++increase_value) : string(--increase_value),false);
         m_increment_ratio.GetTextBoxPointer().Update(true);
        }
     }
//--- Switch the direction to decreasing the array if the maximum has been reached
   if((int)m_series_size.GetValue()>=(int)m_max_limit_size.GetValue())
      resize_direction=true;

//--- If the progress bar is enabled, display the process
   if(m_progress_bar.IsVisible())
     {
      if(!resize_direction)
         m_progress_bar.Update((int)m_series_size.GetValue(),(int)m_max_limit_size.GetValue());
      else
         m_progress_bar.Update((int)m_max_limit_size.GetValue()-(int)m_series_size.GetValue(),(int)m_max_limit_size.GetValue());
     }
//--- Resize the array in the specified direction
   int size_of_series=(int)m_series_size.GetValue();
   m_series_size.SetValue((!resize_direction)?(string)++size_of_series :(string)--size_of_series,false);
   m_series_size.GetTextBoxPointer().Update(true);
//--- Resize the arrays
   ResizeDataArrays();
//--- Add the series to the chart
   AddSeries();
  }
//+------------------------------------------------------------------+
