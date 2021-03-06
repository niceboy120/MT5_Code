//+------------------------------------------------------------------+
//|                                                  ElementBase.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Mouse.mqh"
#include "Objects.mqh"
//+------------------------------------------------------------------+
//| Base class of control                                            |
//+------------------------------------------------------------------+
class CElementBase
  {
protected:
   //--- Class instance for getting the mouse parameters
   CMouse           *m_mouse;
   //--- Class instance for working with color
   CColors           m_clr;
   //--- Instance of the class for working with the chart
   CChart            m_chart;
   //--- (1) Name of class and (2) program, (3) program type
   string            m_class_name;
   string            m_program_name;
   ENUM_PROGRAM_TYPE m_program_type;
   //--- (1) Part of the name (type of the control), (2) name of the control
   string            m_name_part;
   string            m_element_name;
   //--- Identifier and window number of the chart
   long              m_chart_id;
   int               m_subwin;
   //--- Identifier of the last created control
   int               m_last_id;
   //--- Identifier and index of the control
   int               m_id;
   int               m_index;
   //--- Coordinates and boundaries
   int               m_x;
   int               m_y;
   //--- Size
   int               m_x_size;
   int               m_y_size;
   //--- Indents
   int               m_x_gap;
   int               m_y_gap;
   //--- Control states:
   bool              m_is_tooltip;     // tooltip
   bool              m_is_visible;     // visibility
   bool              m_is_dropdown;    // drop-down control
   bool              m_is_locked;      // locking
   bool              m_is_available;   // availability
   bool              m_is_pressed;     // pressed/released
   bool              m_is_highlighted; // highlighting when hovered
   //--- Focus of the mouse cursor
   bool              m_mouse_focus;
   //--- To determine the moment when the mouse cursor crosses the borders of the control
   bool              m_is_mouse_focus;
   //--- Chart corner and anchor point of objects
   ENUM_BASE_CORNER  m_corner;
   ENUM_ANCHOR_POINT m_anchor;
   //--- Mode of automatic control resizing
   bool              m_auto_xresize_mode;
   bool              m_auto_yresize_mode;
   //--- Offset from the right/bottom edge of the form in the mode of automatic control width/height changing
   int               m_auto_xresize_right_offset;
   int               m_auto_yresize_bottom_offset;
   //--- Anchor points of the control in the right and bottom of the window
   bool              m_anchor_right_window_side;
   bool              m_anchor_bottom_window_side;
   //---
public:
                     CElementBase(void);
                    ~CElementBase(void);
   //--- (1) Stores and (2) returns the mouse pointer
   void              MousePointer(CMouse &object)                    { m_mouse=::GetPointer(object);         }
   CMouse           *MousePointer(void)                        const { return(::GetPointer(m_mouse));        }
   //--- (1) Stores and (2) returns the class name
   void              ClassName(const string class_name)              { m_class_name=class_name;              }
   string            ClassName(void)                           const { return(m_class_name);                 }
   //--- (1) Stores and (2) returns the part of the control name
   void              NamePart(const string name_part)                { m_name_part=name_part;                }
   string            NamePart(void)                            const { return(m_name_part);                  }
   //--- (1) Generating the object name, (2) checking if the line contains a significant part of the control name
   string            ElementName(const string name_part="");
   bool              CheckElementName(const string object_name);
   //--- (1) Getting the program name, (2) getting the program type
   string            ProgramName(void)                         const { return(m_program_name);               }
   ENUM_PROGRAM_TYPE ProgramType(void)                         const { return(m_program_type);               }
   //--- (1) Setting/getting the chart window number, (2) getting the chart identifier
   void              SubwindowNumber(const int number)               { m_subwin=number;                      }
   int               SubwindowNumber(void)                     const { return(m_subwin);                     }
   long              ChartId(void)                             const { return(m_chart_id);                   }
   //--- Methods for storing and getting the id of the last created control
   int               LastId(void)                              const { return(m_last_id);                    }
   void              LastId(const int id)                            { m_last_id=id;                         }
   //--- Setting and getting the control identifier
   void              Id(const int id)                                { m_id=id;                              }
   int               Id(void)                                  const { return(m_id);                         }
   //--- Setting and getting the control index
   void              Index(const int index)                          { m_index=index;                        }
   int               Index(void)                               const { return(m_index);                      }
   //--- Coordinates and boundaries
   int               X(void)                                   const { return(m_x);                          }
   void              X(const int x)                                  { m_x=x;                                }
   int               Y(void)                                   const { return(m_y);                          }
   void              Y(const int y)                                  { m_y=y;                                }
   int               X2(void)                                  const { return(m_x+m_x_size);                 }
   int               Y2(void)                                  const { return(m_y+m_y_size);                 }
   //--- Size
   int               XSize(void)                               const { return(m_x_size);                     }
   void              XSize(const int x_size)                         { m_x_size=x_size;                      }
   int               YSize(void)                               const { return(m_y_size);                     }
   void              YSize(const int y_size)                         { m_y_size=y_size;                      }
   //--- Margins from the edge point (xy)
   int               XGap(void)                                const { return(m_x_gap);                      }
   void              XGap(const int x_gap)                           { m_x_gap=x_gap;                        }
   int               YGap(void)                                const { return(m_y_gap);                      }
   void              YGap(const int y_gap)                           { m_y_gap=y_gap;                        }
   //--- Tooltip
   void              IsTooltip(const bool state)                     { m_is_tooltip=state;                   }
   bool              IsTooltip(void)                           const { return(m_is_tooltip);                 }
   //--- Visibility state of control
   void              IsVisible(const bool state)                     { m_is_visible=state;                   }
   bool              IsVisible(void)                           const { return(m_is_visible);                 }
   //--- Indication of a drop-down control
   void              IsDropdown(const bool state)                    { m_is_dropdown=state;                  }
   bool              IsDropdown(void)                          const { return(m_is_dropdown);                }
   //--- Locking/unlocking the control
   virtual void      IsLocked(const bool state)                      { m_is_locked=state;                    }
   bool              IsLocked(void)                            const { return(m_is_locked);                  }
   //--- Sign of available control
   virtual void      IsAvailable(const bool state)                   { m_is_available=state;                 }
   bool              IsAvailable(void)                         const { return(m_is_available);               }
   //--- Sign of pressed control
   virtual void      IsPressed(const bool state)                     { m_is_pressed=state;                   }
   bool              IsPressed(void)                           const { return(m_is_pressed);                 }
   //--- Sign of highlighted control
   void              IsHighlighted(const bool state)                 { m_is_highlighted=state;               }
   bool              IsHighlighted(void)                       const { return(m_is_highlighted);             }
   //--- (1) Focus, (2) the moment of entering/exiting the focus, (3) setting the size of the gradient
   bool              MouseFocus(void)                          const { return(m_mouse_focus);                }
   void              MouseFocus(const bool focus)                    { m_mouse_focus=focus;                  }
   bool              IsMouseFocus(void)                        const { return(m_is_mouse_focus);             }
   void              IsMouseFocus(const bool focus)                  { m_is_mouse_focus=focus;               }
   //--- (1) Mode of auto-changing the control width, (2) get/set the offset from the right edge of the form
   bool              AutoXResizeMode(void)                     const { return(m_auto_xresize_mode);          }
   void              AutoXResizeMode(const bool flag)                { m_auto_xresize_mode=flag;             }
   int               AutoXResizeRightOffset(void)              const { return(m_auto_xresize_right_offset);  }
   void              AutoXResizeRightOffset(const int offset)        { m_auto_xresize_right_offset=offset;   }
   //--- (1) Mode of auto-changing the control height, (2) gets/sets the offset from the bottom edge of the form
   bool              AutoYResizeMode(void)                     const { return(m_auto_yresize_mode);          }
   void              AutoYResizeMode(const bool flag)                { m_auto_yresize_mode=flag;             }
   int               AutoYResizeBottomOffset(void)             const { return(m_auto_yresize_bottom_offset); }
   void              AutoYResizeBottomOffset(const int offset)       { m_auto_yresize_bottom_offset=offset;  }
   //--- Mode (getting/setting) of control anchor point to the (1) right and (2) bottom edge of the window
   bool              AnchorRightWindowSide(void)               const { return(m_anchor_right_window_side);   }
   void              AnchorRightWindowSide(const bool flag)          { m_anchor_right_window_side=flag;      }
   bool              AnchorBottomWindowSide(void)              const { return(m_anchor_bottom_window_side);  }
   void              AnchorBottomWindowSide(const bool flag)         { m_anchor_bottom_window_side=flag;     }
   //---
public:
   //--- Handler of chart events
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Timer
   virtual void      OnEventTimer(void) {}
   //--- Moving the control
   virtual void      Moving(const bool only_visible=true) {}
   //--- (1) Show, (2) hide, (3) move to the top layer, (4) delete
   virtual void      Show(void) {}
   virtual void      Hide(void) {}
   virtual void      Reset(void) {}
   virtual void      Delete(void) {}
   //--- (1) Setting, (2) resetting of priorities for left clicking on mouse
   virtual void      SetZorders(void) {}
   virtual void      ResetZorders(void) {}
   //--- Zeroing the control's color
   virtual void      ResetColors(void) {}
   //--- Updates the control to display the latest changes
   virtual void      Update(const bool redraw=false) {}
   //--- Updates the control to display the latest changes
   virtual void      Draw(void) {}
   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void) {}
   //--- Change the height at the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void) {}

   //--- Checking location of the cursor in the program subwindow
   bool              CheckSubwindowNumber(void);
   //--- Checking location of the cursor over the control
   void              CheckMouseFocus(void);
   //--- Checking the crossing of the control borders
   bool              CheckCrossingBorder(void);
   //---
protected:
   //--- Getting the identifier from the button name
   int               IdFromObjectName(const string object_name);
   //--- Getting the index from the menu item name
   int               IndexFromObjectName(const string object_name);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CElementBase::CElementBase(void) : m_program_name(PROGRAM_NAME),
                                   m_program_type(PROGRAM_TYPE),
                                   m_class_name(""),
                                   m_name_part(""),
                                   m_last_id(0),
                                   m_x(0),
                                   m_y(0),
                                   m_x_size(0),
                                   m_y_size(0),
                                   m_x_gap(0),
                                   m_y_gap(0),
                                   m_is_tooltip(false),
                                   m_is_visible(true),
                                   m_is_dropdown(false),
                                   m_is_locked(false),
                                   m_is_pressed(false),
                                   m_is_available(true),
                                   m_is_highlighted(true),
                                   m_mouse_focus(false),
                                   m_is_mouse_focus(false),
                                   m_id(WRONG_VALUE),
                                   m_index(WRONG_VALUE),
                                   m_corner(CORNER_LEFT_UPPER),
                                   m_anchor(ANCHOR_LEFT_UPPER),
                                   m_auto_xresize_mode(false),
                                   m_auto_yresize_mode(false),
                                   m_auto_xresize_right_offset(0),
                                   m_auto_yresize_bottom_offset(0),
                                   m_anchor_right_window_side(false),
                                   m_anchor_bottom_window_side(false)
  {
//--- Get the ID of the current chart
   m_chart.Attach();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CElementBase::~CElementBase(void)
  {
//--- Detach from the chart
   m_chart.Detach();
  }
//+------------------------------------------------------------------+
//| Returns the generated control name                               |
//+------------------------------------------------------------------+
string CElementBase::ElementName(const string name_part="")
  {
   m_name_part=(m_name_part!="")? m_name_part : name_part;
//--- Forming the object name
   string name="";
   if(m_index==WRONG_VALUE)
      name=m_program_name+"_"+m_name_part+"_"+(string)CElementBase::Id();
   else
      name=m_program_name+"_"+m_name_part+"_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//---
   return(name);
  }
//+------------------------------------------------------------------+
//| Returns the generated control name                               |
//+------------------------------------------------------------------+
bool CElementBase::CheckElementName(const string object_name)
  {
//--- If the pressing was on this control
   if(::StringFind(object_name,m_program_name+"_"+m_name_part+"_")<0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking location of the cursor in the program subwindow         |
//+------------------------------------------------------------------+
bool CElementBase::CheckSubwindowNumber(void)
  {
   return(m_subwin==m_mouse.SubWindowNumber());
  }
//+------------------------------------------------------------------+
//| Checking location of the cursor over the control                 |
//+------------------------------------------------------------------+
void CElementBase::CheckMouseFocus(void)
  {
   m_mouse_focus=m_mouse.X()>X() && m_mouse.X()<=X2() && m_mouse.Y()>Y() && m_mouse.Y()<=Y2();
  }
//+------------------------------------------------------------------+
//| Checking the crossing of the control borders                     |
//+------------------------------------------------------------------+
bool CElementBase::CheckCrossingBorder(void)
  {
//--- If this is the moment of crossing the borders of the control
   if((MouseFocus() && !IsMouseFocus()) || (!MouseFocus() && IsMouseFocus()))
     {
      IsMouseFocus(MouseFocus());
      //--- Message about the crossing into the control
      if(MouseFocus())
         ::EventChartCustom(m_chart_id,ON_MOUSE_FOCUS,m_id,m_index,m_class_name);
      //--- Message about the crossing out of the control
      else
         ::EventChartCustom(m_chart_id,ON_MOUSE_BLUR,m_id,m_index,m_class_name);
      //---
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Extract the identifier from the object name                      |
//+------------------------------------------------------------------+
int CElementBase::IdFromObjectName(const string object_name)
  {
//--- Get the id from the object name
   int    length =::StringLen(object_name);
   int    pos    =::StringFind(object_name,"__",0);
   string id     =::StringSubstr(object_name,pos+2,length-1);
//--- Return the item id
   return((int)id);
  }
//+------------------------------------------------------------------+
//| Extracts the index from the object name                          |
//+------------------------------------------------------------------+
int CElementBase::IndexFromObjectName(const string object_name)
  {
   ushort u_sep=0;
   string result[];
   int    array_size=0;
//--- Get the code of the separator
   u_sep=::StringGetCharacter("_",0);
//--- Split the string
   ::StringSplit(object_name,u_sep,result);
   array_size=::ArraySize(result)-1;
//--- Checking for exceeding the array range
   if(array_size-2<0)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//--- Return the item index
   return((int)result[array_size-2]);
  }
//+------------------------------------------------------------------+
