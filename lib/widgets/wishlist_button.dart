import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:j_app/data/wishlist_data.dart';

class WishlistButton extends StatefulWidget {
  final Map<String, dynamic> coffee;
  final int refresh;
  final VoidCallback? onChanged;

  const WishlistButton({
    super.key,
    required this.coffee,
    required this.refresh,
    this.onChanged,
  });

  @override
  State<WishlistButton> createState() =>
      _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {

  bool isFavorite = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkWishlist();
  }

  @override
  void didUpdateWidget(
      covariant WishlistButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refresh != widget.refresh) {
      checkWishlist();
    }
  }

  Future<void> checkWishlist() async {

    final productId = widget.coffee["id"];

    final result =
    await isWishlisted(productId);

    if (!mounted) return;

    setState(() {
      isFavorite = result;
      loading = false;
    });
  }

  Future<void> toggleWishlist() async {

    final productId = widget.coffee["id"];

    if (isFavorite) {

      await removeFromWishlist(productId);

      if (!mounted) return;

      setState(() {
        isFavorite = false;
      });

      Fluttertoast.showToast(
        msg: "Removed from Wishlist",
      );

      // Tell parent that wishlist changed
      widget.onChanged?.call();

    } else {

      await addToWishlist(
        widget.coffee,
        productId,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = true;
      });

      Fluttertoast.showToast(
        msg: "Added to Wishlist",
      );

      // Tell parent that wishlist changed
      widget.onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),

      child: loading

          ? const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFC67C4E),
          ),
        ),
      )

          : IconButton(
        onPressed: toggleWishlist,

        icon: Icon(
          isFavorite
              ? Icons.favorite
              : Icons.favorite_border,

          color: isFavorite
              ? const Color(0xFFC67C4E)
              : Colors.grey,
        ),
      ),
    );
  }
}