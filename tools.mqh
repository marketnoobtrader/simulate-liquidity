//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID = 0,      // chart's ID
                 const string          name = "TrendLine", // line name
                 const int             sub_window = 0,    // subwindow index
                 datetime              time1 = 0,         // first point time
                 double                price1 = 0,        // first point price
                 datetime              time2 = 0,         // second point time
                 double                price2 = 0,        // second point price
                 const color           clr = clrRed,      // line color
                 const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                 const int             width = 1,         // line width
                 const bool            back = false,      // in the background
                 const bool            ray_right = false, // line's continuation to the right
                 const bool            hidden = false,     // hidden in the object list
                 const long            z_order = 0)       // priority for mouse click
   {
//--- reset the error value
    ResetLastError();
//--- create a trend line by the given coordinates
    if(!ObjectCreate(chart_ID, name, OBJ_TREND, sub_window, time1, price1, time2, price2))
       {
        Print(__FUNCTION__,
              ": failed to create a trend line! Error code = ", GetLastError());
        return(false);
       }
//--- set line color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set line display style
    ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set line width
    ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, false);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
    ObjectSetInteger(chart_ID, name, OBJPROP_RAY_RIGHT, ray_right);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
   }


/*
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
*/

//+------------------------------------------------------------------+
