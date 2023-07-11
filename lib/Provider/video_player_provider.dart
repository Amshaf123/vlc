

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerProvider extends ChangeNotifier{

 double sliderValue = 0.0;

 bool isControls=true;
 void setSliderValue(double value){
   sliderValue = value;
   notifyListeners();
 }



  hideControls() {
   
   if (isControls==true) {
      isControls=false;
   }else{
       isControls=true;
   }
    

}


}




