import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

// const String baseURL = "http://localhost:5555/api";
const String baseURL =
    "https://google-dogs.bluewater-55be1484.uksouth.azurecontainerapps.io/api";

class ApiService {
  String token = '';
  late Map<String, String> header;

  ApiService() {
    header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<dynamic> request(String endpoint,
      {String method = 'GET',
      required Map<String, String> headers,
      dynamic body}) async {
    var url = Uri.parse(baseURL + endpoint);
    print(url);
    http.Response response;
    try {
      switch (method) {
        case 'GET':
          if (body != null) {
            url = Uri.parse(
                "$baseURL$endpoint?${Uri(queryParameters: body).query}");
            response = await http.get(url, headers: headers);
          } else {
            response = await http.get(url, headers: headers);
          }
          break;
        case 'POST':
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response =
              await http.delete(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          print(url);
          response =
              await http.patch(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          var request = http.Request('DELETE', url);
          request.headers.addAll(headers);
          if (body != null) {
            request.body = jsonEncode(body);
          }
          var streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
          break;
        default:
          throw Exception('HTTP method $method not implemented');
      }
      print(response.body);
      return response;
    } catch (e) {
      debugPrint("Exception occured: $e");
    }
  }

  Future<Response> register(Map<String, dynamic> body) async {
    var result = await request('/users/register',
        headers: header, method: 'POST', body: body);
    return result;
  }

  Future<Response> login(Map<String, dynamic> body) async {
    var result = await request('/users/login',
        headers: header, method: 'POST', body: body);
    return result;
  }

  Future<Response> getAllUserDocuments(Map<String, dynamic> body) async {
    print(body);
    var result = await request(
        '/relations/getAllUserDocuments?userId=${body['userId']}',
        headers: header,
        method: 'GET');
    print(result);
    return result;
  }

  Future<Response> createDocument(Map<String, dynamic> body) async {
    var result = await request('/documents/createDocument',
        headers: header, method: 'POST', body: body);
    return result;
  }

  Future<Response> getDocumentById(Map<String, dynamic> body) async {
    var result = await request('/documents/getDocumentById',
        headers: header, method: 'GET', body: body);
    return result;
  }

  Future<Response> addUserToDocument(Map<String, dynamic> body) async {
    var result = await request('/relations/addUsertoDocument',
        headers: header, method: 'POST', body: body);
    return result;
  }

  Future<Response> getUsersFromDocumentID(Map<String, dynamic> body) async {
    print(body);
    var result = await request('/relations/getUsersFromDocumentId',
        headers: header, method: 'GET', body: body);
    return result;
  }

  Future<Response> updateUserRole(Map<String, dynamic> body) async {
    var result = await request('/relations/updateUserRole',
        headers: header, method: 'PATCH', body: body);
    return result;
  }

  // Future<Response> updateDocumentContent(Map<String, dynamic> body) async {
  //   print(body);
  //   var result = await request('/documents/updateDocumentContent',
  //       headers: header, method: 'PATCH', body: body);
  //   return result;
  // }

  Future<Response> renameDocument(Map<String, dynamic> body) async {
    // print('aaaaaaaa: $body');
    var result = await request('/documents/renameDocument',
        headers: header, method: 'PATCH', body: body);
    // print(result.body);
    // print(result.statusCode);
    return result;
  }

  Future<Response> deleteDocument(Map<String, dynamic> body) async {
    var result = await request('/documents/deleteDocument',
        headers: header, method: 'DELETE', body: body);
    return result;
  }
}
