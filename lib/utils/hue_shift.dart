import 'package:flutter/material.dart';

//this is a short thing so I don't lose my mind over bad colour schemes

Color hueShift(Color color, double shiftDegree) {
  HSVColor temp = HSVColor.fromColor(color);
  HSVColor temp2 = temp.withHue(temp.hue+shiftDegree);
  return temp2.toColor();
}
Color valueShift(Color color, double shiftDegree) {
  HSVColor temp = HSVColor.fromColor(color);
  HSVColor temp2;

  if(temp.value-shiftDegree<=0){
    temp2 = temp.withValue(1.0-temp.value-shiftDegree);
  }
    temp2 = temp.withValue(temp.value+shiftDegree);
   return temp2.toColor();
}