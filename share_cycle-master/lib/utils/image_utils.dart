import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:share_cycle/base/config.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImageUtils {
  static Future<List<File>> showOpenPhoto(BuildContext context, {int maxAssets = 5, int gridCount = 5}) async {
    List<File> files = [];
    List<AssetEntity>? images = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
          maxAssets: maxAssets,
          gridCount: gridCount,
          textDelegate: AssetPickerTextDelegate(),
        ));
    for (var i = 0; i < images!.length; i++) {
      File? tempFile = await images[i].file;
      // 判断文件是否已经存在
      // 移除字符
      var path = tempFile!.absolute.path;
      var replaceAll = path.replaceAll("compressed.jpg", "");
      File comFile = File("${replaceAll}compressed.jpg");
      if (await comFile.exists()) {
        // 自身就是压缩的文件则进行处理
        // 直接选中
        files.add(comFile);
      } else {
        var pathTemp = tempFile!.absolute.path;
        String targetPath = "${tempFile!.absolute.path}compressed.jpg";
        try{
          XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
            pathTemp,
            targetPath,
            quality: 60,
            rotate: 0,
          );
          files.add(File(compressedFile!.path));

        }catch(error){
          files.add(File(tempFile!.path));
        }
      }
    }
    return files;
  }

  static firebaseUploadFile({required List<File> selectFile, required Function(String) goodsImage}) async {
    final storage = FirebaseStorage.instanceFor(bucket: baseBucket);
// 从我们的应用程序创建存储引用
    final storageRef = storage.ref();
    List<String> uploadFile= [];
    for (var value in selectFile) {
      List<String> pathComponents = value.path.split('/');
      String fileName = pathComponents.last;
      final mountainsRef = storageRef.child("${fileName}");
      try {
        mountainsRef.putFile(value,SettableMetadata(contentType: "image/jpeg",));
        uploadFile.add(fileName);
      } on FirebaseException catch (e) {
        //
      }
    }
    goodsImage(json.encode(uploadFile));
  }

  static firebaseImageUrl({required String fileName}) {
    String imgUrl = "https://firebasestorage.googleapis.com/v0/b/sharecycle-6b853.appspot.com/o/$fileName?alt=media";
    return imgUrl;
  }
}
