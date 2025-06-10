import 'package:flutter/material.dart';
import 'package:mobile_p3l/services/api_service.dart';
import 'package:mobile_p3l/services/merch_service.dart';

class MerchScreen extends StatefulWidget {
  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  List<Map<String, dynamic>> merchItems = [];
  bool isLoading = true;
  Map<String, dynamic>? user;

  final Color primaryColor = const Color(0xFF51B995);

  @override
  void initState() {
    super.initState();
    fetchMerchandise();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await ApiService.showLoggedInUser();
    final userData = prefs['data'];
    if (userData != null) {
      setState(() {
        user = userData;
        print('user data: $user');
      });
    }
  }

  Future<void> fetchMerchandise() async {
    try {
      final merchData = await MerchService().getAllMerchandise();
      setState(() {
        merchItems = List<Map<String, dynamic>>.from(merchData);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching merch: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : merchItems.isEmpty
              ? const Center(child: Text("No merchandise available."))
              : ListView.builder(
                  itemCount: merchItems.length,
                  itemBuilder: (context, index) {
                    final item = merchItems[index];
                    final itemId = item['id_merchandise'];
                    final itemName = item['nama'] ?? 'Unknown';
                    final itemKategori = item['kategori'] ?? 'Unknown';
                    final stock = item['stock'] ?? 0;
                    final poin = item['poin'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/hunter.jpeg',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(itemName,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text("Kategori : $itemKategori"),
                                    Text("Stok : $stock"),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => _onClaimPressed(itemId, itemName, stock, user?['poin'], poin),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text("Claim"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _onClaimPressed(String itemId, String itemName, int stock, int userPoin, int merchPoin) async {
    final claimedQuantity = await showDialog<int>(
      context: context,
      builder: (context) => ClaimDialog(itemId: itemId, itemName: itemName, stock: stock, userPoin: userPoin, merchPoin: merchPoin,),
    );

    if (claimedQuantity != null) {
      final success = await MerchService().claimMerch(
        itemId: itemId,
        quantity: claimedQuantity,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Claimed $claimedQuantity $itemId successfully!"
              : "Failed to claim item."),
        ),
      );
    }
  }
}

class ClaimDialog extends StatefulWidget {
  final String itemId;
  final String itemName;
  final int stock;
  final int userPoin;
  final int merchPoin;

  const ClaimDialog({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.stock,
    required this.userPoin,
    required this.merchPoin,
  }) : super(key: key);

  @override
  State<ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<ClaimDialog> {
  int quantity = 1;

  final Color primaryColor = const Color(0xFF51B995);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              width: 40,
              color: primaryColor,
              margin: const EdgeInsets.only(bottom: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.itemName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Stok : ${widget.stock}"),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (quantity < widget.stock) {
                          setState(() {
                            quantity++;
                          });
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
  "Your Points: ${widget.userPoin} | Needed: ${quantity * widget.merchPoin}",
  style: const TextStyle(fontSize: 14),
),
const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (quantity * widget.merchPoin) > widget.userPoin
      ? null
      : () {
          Navigator.pop(context, quantity);
        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text("Claim"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
