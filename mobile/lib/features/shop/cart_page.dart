import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../auth/auth_controller.dart';
import '../auth/customer_profile_local_service.dart';
import '../auth/sign_up_page.dart';
import '../cart/cart_controller.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _goToCheckout(BuildContext context) async {
    final auth = context.read<AuthController>();
    final profile = await CustomerProfileLocalService().load();
    final hasAuthProfileBasics = auth.guestName.trim().isNotEmpty &&
        auth.guestPhone.trim().isNotEmpty &&
        auth.guestDistrict.trim().isNotEmpty &&
        auth.guestAddressDetail.trim().isNotEmpty;
    if (profile == null && !hasAuthProfileBasics) {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const SignUpPage(returnToPreviousOnSave: true),
        ),
      );
      if (saved != true || !context.mounted) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CheckoutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final pad = AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width);
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
        title: Text(l10n.cartTitle),
      ),
      body: cart.lines.isEmpty
          ? Center(child: Text(l10n.cartEmpty))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: pad,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, i) {
                      final line = cart.lines[i];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _lineImage(line.image),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.localizedName(lang),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      '${line.price.toStringAsFixed(2)} × ${line.quantity}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        IconButton(
                                          constraints: const BoxConstraints(
                                            minWidth: 40,
                                            minHeight: 40,
                                          ),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () => cart.setQuantity(
                                            line.productId,
                                            line.quantity - 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                          ),
                                          child: Text(
                                            '${line.quantity}',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          constraints: const BoxConstraints(
                                            minWidth: 40,
                                            minHeight: 40,
                                          ),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () => cart.setQuantity(
                                            line.productId,
                                            line.quantity + 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Material(
                  elevation: 6,
                  shadowColor: Colors.black26,
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        pad,
                        AppSpacing.md,
                        pad,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.subtotal,
                                  style: GoogleFonts.montserrat(fontSize: 16),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  cart.subtotal.toStringAsFixed(2),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.goldDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                          FilledButton(
                            onPressed: () => _goToCheckout(context),
                            child: Text(l10n.checkout),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  static Widget _placeholderThumb() {
    return Container(
      width: 56,
      height: 56,
      color: AppTheme.cream,
      alignment: Alignment.center,
      child: const Icon(Icons.set_meal),
    );
  }

  static Widget _lineImage(String? image) {
    if (image == null || image.isEmpty) return _placeholderThumb();
    if (image.startsWith('asset:')) {
      return Image.asset(
        'assets/images/${image.substring('asset:'.length)}',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderThumb(),
      );
    }
    return Image.network(
      image,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholderThumb(),
    );
  }
}
