import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:fitsugar/services/open_food_facts_service.dart';
import 'package:fitsugar/services/FirestoreService.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final OpenFoodFactsService _foodFactsService = OpenFoodFactsService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _productInfo = "Search for a product to track sugar.";
  bool _isLoading = false;
  bool _isSaving = false;

  //store the found product for saving
  String? _currentProductName;
  double? _currentSugarAmount;

  //function to search for product by name and auto save
  void _searchProduct() async {
    final name = _searchController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentProductName = null;
      _currentSugarAmount = null;
    });

    try {
      final products = await _foodFactsService.searchProductsByName(name);
      if (products.isNotEmpty) {
        //extract product name and sugar amount
        final productName = products[0]['product_name'] ?? 'Unknown Product';
        final sugarValue = products[0]['nutriments']?['sugars'];

        //parse sugar amount, handle different data types
        double? sugarAmount;
        if (sugarValue is int) {
          sugarAmount = sugarValue.toDouble();
        } else if (sugarValue is double) {
          sugarAmount = sugarValue;
        } else if (sugarValue is String) {
          sugarAmount = double.tryParse(sugarValue);
        }

        final parsedSugarAmount = sugarAmount ?? 0.0;

        setState(() {
          _currentProductName = productName;
          _currentSugarAmount = parsedSugarAmount;
          _productInfo = 'Product: $productName\nSugar: ${parsedSugarAmount.toStringAsFixed(1)}g';
        });

        //auto save the product information
        await _saveToHistory(productName, parsedSugarAmount);
      } else {
        setState(() {
          _productInfo = 'No products found.';
        });
      }
    } catch (e) {
      setState(() {
        _productInfo = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //function to scan barcode and get product details
  void _scanBarcode() async {

    if (kIsWeb) {
      setState(() {
        _productInfo = 'Barcode scanning is not available on web platform.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentProductName = null;
      _currentSugarAmount = null;
    });

    try {
      final scanResult = await BarcodeScanner.scan();
      if (scanResult.rawContent.isNotEmpty) {
        final productData = await _foodFactsService.getProductDataByBarcode(scanResult.rawContent);

        if (productData != null) {
          //extract product name and sugar amount
          final productName = productData['product_name'] ?? 'Unknown Product';
          final sugarValue = productData['nutriments']?['sugars'];

          //parse sugar amount and handle different data types
          double? sugarAmount;
          if (sugarValue is int) {
            sugarAmount = sugarValue.toDouble();
          } else if (sugarValue is double) {
            sugarAmount = sugarValue;
          } else if (sugarValue is String) {
            sugarAmount = double.tryParse(sugarValue);
          }

          final parsedSugarAmount = sugarAmount ?? 0.0;

          setState(() {
            _currentProductName = productName;
            _currentSugarAmount = parsedSugarAmount;
            _productInfo = 'Product: $productName\nSugar: ${parsedSugarAmount.toStringAsFixed(1)}g';
          });

          //auto save the product info
          await _saveToHistory(productName, parsedSugarAmount);
        } else {
          setState(() {
            _productInfo = 'Product not found.';
          });
        }
      } else {
        setState(() {
          _productInfo = 'No barcode scanned.';
        });
      }
    } catch (e) {
      setState(() {
        _productInfo = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //automatically save the product to history
  Future<void> _saveToHistory(String productName, double sugarAmount) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.addFoodEntry(productName, sugarAmount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry Saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = Colors.pink;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFEF7FF),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //search section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search for food',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: brandColor, width: 2),
                              ),
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _searchProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            minimumSize: const Size(57, 57),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Icon(Icons.search, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Barcode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //results card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isSaving ? Center() : Text(
                        _productInfo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}