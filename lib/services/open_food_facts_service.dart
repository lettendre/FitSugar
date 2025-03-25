import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:http/io_client.dart';

class OpenFoodFactsService {
  final String apiUrl = 'https://world.openfoodfacts.org/api/v0/product/';
  final http.Client _client;

  //constructor to initialise the appropriate client based on platform
  OpenFoodFactsService() : _client = _createClient();

  //create a client appropriately for platform
  static http.Client _createClient() {
    if (kIsWeb) {
      //use standard client for web
      return http.Client();
    } else {
      //use IOClient with certificate bypass for Android/iOS
      try {
        final httpClient = HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        return IOClient(httpClient);
      } catch (e) {
        //error to standard client if IOClient fails
        print('Error creating IOClient: $e');
        return http.Client();
      }
    }
  }

  //function to fetch product details by barcode
  Future<Map<String, dynamic>?> getProductDataByBarcode(String barcode) async {
    try {
      print('Fetching product with barcode: $barcode');
      final response = await _client.get(Uri.parse('$apiUrl$barcode.json'));

      print('Barcode API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return data['product'];
        } else {
          print('Product not found. API response: ${response.body}');
          throw 'Product not found!';
        }
      } else {
        print('Failed to load product. Status: ${response.statusCode}, Body: ${response.body}');
        throw 'Failed to load product data (${response.statusCode}). Please try again later.';
      }
    } catch (e) {
      print('Exception during barcode lookup: $e');
      throw 'Failed to load product data: $e';
    }
  }

  //function to search for product by name
  Future<List<Map<String, dynamic>>> searchProductsByName(String name) async {
    try {
      // Properly encode the search term for URLs
      final encodedName = Uri.encodeComponent(name);
      final searchUrl = 'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$encodedName&search_simple=1&json=1';

      print('Searching for products with name: $name');
      print('Search URL: $searchUrl');

      final response = await _client.get(Uri.parse(searchUrl));

      print('Search API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('products') && data['products'] is List) {
          return List<Map<String, dynamic>>.from(data['products']);
        } else {
          print('Unexpected response structure: ${response.body.substring(0, min(response.body.length, 500))}...');
          return [];
        }
      } else {
        print('Failed to search. Status: ${response.statusCode}, Body: ${response.body}');
        throw 'Failed to search products (${response.statusCode}). Please try again later.';
      }
    } catch (e) {
      print('Exception during product search: $e');
      throw 'Failed to search products: $e';
    }
  }

  //get the min of two values
  int min(int a, int b) => a < b ? a : b;
}