import 'package:flutter/material.dart';
import 'package:grocery_app/models/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/providers/cart_provider.dart';

class CartTile extends StatelessWidget {
  final CartItem cartItem;
  const CartTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return ListTile(
      leading: Image.network(cartItem.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(cartItem.name),
      subtitle: Text('\$${cartItem.price} x ${cartItem.quantity}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => cartProvider.removeItem(cartItem.id),
      ),
    );
  }
}
