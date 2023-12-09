
// Parses data after url?
Map<String,dynamic> urlAnalyze(String path){
  Map<String, dynamic> paramMap = {};
  path.split('&').forEach((element) {
    var kv = element.split('=');
    paramMap[kv[0]] = kv[1];
  });
  return paramMap;
}
