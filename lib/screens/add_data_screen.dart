import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:fitsugar/services/open_food_facts_service.dart';
import 'package:fitsugar/services/FirestoreService.dart';
import 'package:fitsugar/widgets/appbar.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({Key? key}) : super(key: key);

  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final OpenFoodFactsService _foodFactsService = OpenFoodFactsService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _productInfo = "No product information available.";
  bool _isLoading = false;

  // Store the found product for saving
  String? _currentProductName;
  double? _currentSugarAmount;

  // Function to search for product by name
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
        // Extract product name and sugar amount
        final productName = products[0]['product_name'] ?? 'Unknown Product';
        final sugarValue = products[0]['nutriments']?['sugars'];

        // Parse sugar amount, handle different data types
        double? sugarAmount;
        if (sugarValue is int) {
          sugarAmount = sugarValue.toDouble();
        } else if (sugarValue is double) {
          sugarAmount = sugarValue;
        } else if (sugarValue is String) {
          sugarAmount = double.tryParse(sugarValue);
        }

        setState(() {
          _currentProductName = productName;
          _currentSugarAmount = sugarAmount ?? 0.0;
          _productInfo = 'Product: $productName\nSugar: ${sugarAmount?.toStringAsFixed(1) ?? 'unknown'}g';
        });
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

  // Function to scan barcode and get product details
  void _scanBarcode() async {
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
          // Extract product name and sugar amount
          final productName = productData['product_name'] ?? 'Unknown Product';
          final sugarValue = productData['nutriments']?['sugars'];

          // Parse sugar amount, handle different data types
          double? sugarAmount;
          if (sugarValue is int) {
            sugarAmount = sugarValue.toDouble();
          } else if (sugarValue is double) {
            sugarAmount = sugarValue;
          } else if (sugarValue is String) {
            sugarAmount = double.tryParse(sugarValue);
          }

          setState(() {
            _currentProductName = productName;
            _currentSugarAmount = sugarAmount ?? 0.0;
            _productInfo = 'Product: $productName\nSugar: ${sugarAmount?.toStringAsFixed(1) ?? 'unknown'}g';
          });
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

  // Save the current product to history
  void _saveToHistory() async {
    if (_currentProductName == null || _currentSugarAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No product data to save')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _firestoreService.addFoodEntry(_currentProductName!, _currentSugarAmount!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food entry saved to history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
    // Brand color to match your splash screen
    final brandColor = const Color(0xFFE83A5F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Food', style: TextStyle(color: Colors.white)),
        backgroundColor: brandColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          // Light gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              brandColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search section with rounded borders
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
                              prefixIcon: Icon(Icons.search, color: brandColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _searchProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
                              : const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Barcode'),
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

              // Results section
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _productInfo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      if (_currentProductName != null && _currentSugarAmount != null)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveToHistory,
                            icon: const Icon(Icons.save),
                            label: const Text('Save to History'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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