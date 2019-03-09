import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import '../event/error_event.dart';
import '../model/base_data.dart';
import '../utils/cookie_util.dart';
import 'dart:convert';

import '../utils/eventbus.dart';

class DioManager{

  Dio _dio;

  DioManager.internal(){
    _dio = new Dio(Options(
      baseUrl:"http://www.wanandroid.com/",
      connectTimeout: 10000,
      receiveTimeout:3000,
    ));
    CookieUtil.getCookiePath().then((path){
      _dio.cookieJar = PersistCookieJar(path);
    });

    _dio.interceptor.response.onError = (DioError e){
      // 当请求失败时做一些预处理
      EventUtil.eventBus.fire(e);
      return e;
    };

  }

  static DioManager singleton = DioManager.internal();

  factory DioManager() => singleton;

  get dio{
    return _dio;
  }

  Future<ResultData> get(url,{data,options,cancelToken}) async{
    print('get initiate ! url : $url , body : $data');
    Response response;
    ResultData result;

    try{
      response = await dio.get(
        url,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );

    print('get请求成功!response.data：${response.data}');

    result = ResultData.fromJson(response.data is String ? json.decode(response.data) : response.data);
    if(result.errorCode < 0){
      EventUtil.eventBus.fire(ErrorEvent(result.errorCode,result.errorMsg));
      result = null;
    }

    }on DioError catch(e){
      if(cancelToken.isCancel(e)){
        print("get cancel !" + e.message);
    }
    
    print("a error occur from get");
    }
    return result;

  }

  Future<Response> getNormal(url,{data,options,cancelToken}) async{
    print('get notmal ! url : $url , body : $data');

    Response response;
    try{
      response = await dio.get(
        url,
        data:data,
        options : options,
        cancelToken : cancelToken,
      );
      print('请求成功 ! response.data : ${response.data}');
    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print("请求取消 " + e.message);
      }
      print('请求发生错误 : $e');
    }

    return response;
  }

  Future<ResultData> post(url,{data,options,cancelToken}) async{
    print('post 请求 url : $url , body : $data');
    Response response;
    ResultData result;

    try{
      response = await dio.get(
        url,
        data: data,
        options : options,
        cancelToken : cancelToken
      );

      result = ResultData.fromJson(response.data is String ?
                json.decode(response.data) : response.data);
      if(result.errorCode < 0){
        EventUtil.eventBus.fire(ErrorEvent(result.errorCode,result.errorMsg));
        result = null;
      }

    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('请求取消 :' + e.message);
      }
      
      print('请求发生错误 : $e');
    }

    return result;

  }

  Future<Response> postNormal(url,{data,options,cancelToken}) async{
    print('post normal : $url , body : $data');

    Response response;
    try{
      response = await dio.get(
        url,
        data : data,
        options : options,
        cancelToken : cancelToken
      );
      print('请求成功 ! response.data : ${response.data}');
    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('请求取消了 : ${e.message}');
      }
      print("请求发生错误 $e");
    }

    return response;
  }

}









