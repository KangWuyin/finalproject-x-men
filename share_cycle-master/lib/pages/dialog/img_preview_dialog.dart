import 'package:flutter/material.dart';
import 'package:share_cycle/pages/common/img_preview_page.dart';

showImagePreview(BuildContext context, {required List<String> imageData,int position= 0}) {
  if(imageData.isEmpty){
    return;
  }
  showDialog(
      context: context,
      builder: (context) {
        return ImgPreviewPage(urlImageData: imageData,position: position,);
      });
}
