import 'dart:developer';
import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:vlc_india/General/app_details.dart';
import 'package:vlc_india/Screen/play_video_screen.dart';

import '../General/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileManagerController controller = FileManagerController(

  );
  @override
  void initState() {
  // how to add mb4 get all video folder
    
   
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ControlBackButton(
      controller: controller,
      child: Scaffold(
      
        appBar: AppBar(
          elevation: 3,
          scrolledUnderElevation: 3,
          title: const Text(
            AppDetails.appName,
            style: TextStyle(
              fontFamily: "pop",
              color: Colors.white,
              fontWeight: FontWeight.w800
            ),
    
          ),
          backgroundColor: AppColor.appColor,
        ),
        // floatingActionButton: FloatingActionButton(onPressed: ()async{
        //    await controller.;
        // }),
        body: FileManager(
          controller: controller,
        
          builder: (context, snapshot) {
             final List<FileSystemEntity> entities = snapshot;
              
            return ListView.builder(
                itemCount: entities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading:  Icon(IconlyBold.folder,size: 40,color: Colors.grey.shade400,),
                    title: Text(FileManager.basename(entities[index]),style:const TextStyle(
                      fontFamily: "pop",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 15,
                    ),),
                    subtitle: const Text(' videos'),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                     if (FileManager.isDirectory(entities[index])) {
                    controller.openDirectory(entities[index]);   // open directory
                  } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return VideoScreen(video: entities[index].path);
                      }));
                  }
                    },
                  );
                });
          }
        ),
      ),
    );
  }




}

