import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_text_scale.dart';
import '../../data/models/product.dart';
import '../../widgets/app_skeleton.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_model.dart';
import 'shop_repository.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Product> _future;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _future = context.read<ShopRepository>().fetchProduct(widget.productId);
    _future.then((p) {
      if (!mounted) return;
      final cap = p.maxSelectableQty;
      if (cap < 1) return;
      if (_qty > cap) setState(() => _qty = cap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: FutureBuilder<Product>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) return Text(l10n.productTitle);
            return Text(
              snap.data!.localizedName(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ),
      body: FutureBuilder<Product>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  snap.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const DetailPageSkeleton();
          }
          final p = snap.data!;
          final titleSize = AppTextScale.fontSize(context, 26);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final image = p.images.isNotEmpty ? p.images.first : null;
                  final isAssetImage = image != null && image.startsWith('asset:');
                  if (image == null) {
                    return AspectRatio(
                      aspectRatio: 1.2,
                      child: Container(
                        color: AppTheme.cream,
                        alignment: Alignment.center,
                        child: const Icon(Icons.set_meal, size: 64),
                      ),
                    );
                  }
                  return AspectRatio(
                    aspectRatio: 1.2,
                    child: isAssetImage
                        ? Image.asset(
                            'assets/images/${image.substring('asset:'.length)}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: AppTheme.cream),
                          )
                        : Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: AppTheme.cream),
                          ),
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.localizedName(lang),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.productMetaLine(
                          p.unitPrice.toStringAsFixed(2),
                          p.weightLabel,
                          '${p.stock}',
                          '${p.maxOrderQty}',
                        ),
                        style: GoogleFonts.montserrat(
                          color: AppTheme.goldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        p.localizedDescription(lang, l10n.premiumPoultryDescription),
                        style: GoogleFonts.montserrat(height: 1.5),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          Text(
                            l10n.quantity,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _qty > 1
                                    ? () => setState(() => _qty--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('$_qty'),
                              IconButton(
                                onPressed: _qty < p.maxSelectableQty
                                    ? () => setState(() => _qty++)
                                    : null,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: FilledButton(
                    onPressed: p.stock < 1
                        ? null
                        : () {
                            context.read<CartController>().add(
                                  CartLine.fromProduct(p, quantity: _qty),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.addedToCartSnack)),
                            );
                            Navigator.of(context).pop();
                          },
                    child: Text(l10n.addToCart),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
