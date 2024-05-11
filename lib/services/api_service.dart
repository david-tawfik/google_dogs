import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

const String baseURL = "http://localhost:5555/api";
//const String baseURL = "https://e895ac26-6dc5-4b44-8937-20b3ad854396.mock.pstmn.io/api";

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

  Future<dynamic> createCommunity(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/subreddit/createCommunity'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create community');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<dynamic> checkSubredditAvailability(String communityName) async {
    var result = await request(
        '/subreddit/subredditNameAvailability?name=$communityName',
        headers: header,
        method: 'GET');
    return result;
  }

  Future<dynamic> getUserAccountSettings() async {
    var result =
        await request('/user/accountSettings', headers: header, method: 'GET');
    return result;
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
    var result = await request('/relations/getAllUserDocuments?userId=${body['userId']}',
        headers: header, method: 'GET');
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
}
