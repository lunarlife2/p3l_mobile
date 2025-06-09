import 'package:flutter/material.dart';
import 'package:mobile_p3l/services/merch_service.dart';

class MerchScreen extends StatelessWidget {
  final List<Map<String, dynamic>> merchItems = [
    {'name': 'Baju ReuseMart', 'stock': 5},
    {'name': 'Baju ReuseMart', 'stock': 5},
    {'name': 'Baju ReuseMart', 'stock': 5},
  ];

  int _selectedTab = 0;
  String? role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: merchItems.length,
        itemBuilder: (context, index) {
          final item = merchItems[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF51B995)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Stok : ${item['stock']}"),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final claimedQuantity = await showDialog(
                      context: context,
                      builder: (context) => ClaimDialog(
                        itemName: item['name'],
                        stock: item['stock'],
                      ),
                    );
                    if (claimedQuantity != null) {
                      final success = await MerchService().claimMerch(
                        itemName: item['name'],
                        quantity: claimedQuantity,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? "Claimed $claimedQuantity ${item['name']} successfully!"
                              : "Failed to claim item."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF51B995),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text("Claim"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ClaimDialog extends StatefulWidget {
  final String itemName;
  final int stock;

  const ClaimDialog({
    Key? key,
    required this.itemName,
    required this.stock,
  }) : super(key: key);

  @override
  State<ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<ClaimDialog> {
  int quantity = 1;

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
              color: Color(0xFF51B995),
              margin: EdgeInsets.only(bottom: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.itemName,
                        style: TextStyle(
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
                      icon: Icon(Icons.remove),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF51B995)),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        quantity.toString(),
                        style: TextStyle(fontSize: 16),
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
                      icon: Icon(Icons.add),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Do claim API call here with quantity
                  Navigator.pop(context, quantity); // or trigger your logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF51B995),
                ),
                child: Text("Claim"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
