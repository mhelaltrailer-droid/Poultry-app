import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../auth/auth_controller.dart';
import '../../data/models/flash_offer.dart';
import '../../data/models/product.dart';
import '../../widgets/responsive_sliver_grid.dart';
import 'flash_offers_page.dart';
import 'product_detail_page.dart';
import 'shop_repository.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  late Future<List<Product>> _future;
  late Future<List<FlashOffer>> _offersFuture;
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  Timer? _offersAutoSlide;
  final PageController _offersPager = PageController(viewportFraction: 0.9);
  int _offerPage = 0;
  String _appliedQuery = '';

  @override
  void initState() {
    super.initState();
    _future = context.read<ShopRepository>().fetchProducts();
    _offersFuture = context.read<ShopRepository>().fetchFlashOffers();
    _offersAutoSlide = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_offersPager.hasClients) return;
      final next = _offerPage + 1;
      _offersPager.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _offersAutoSlide?.cancel();
    _offersPager.dispose();
    _search.dispose();
    super.dispose();
  }

  void _scheduleFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), _runFetch);
  }

  void _runFetch() {
    if (!mounted) return;
    final t = _search.text.trim();
    setState(() {
      _appliedQuery = t;
      _future = context.read<ShopRepository>().fetchProducts(
            q: t.isEmpty ? null : t,
          );
    });
  }

  Future<void> _reload() async {
    final t = _search.text.trim();
    setState(() {
      _future = context.read<ShopRepository>().fetchProducts(
            q: t.isEmpty ? null : t,
          );
      _offersFuture = context.read<ShopRepository>().fetchFlashOffers();
    });
    await Future.wait([_future, _offersFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final padX = AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width);
    final greetingName = auth.guestName.trim().isEmpty ? null : auth.guestName.trim();
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
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padX, AppSpacing.sm, padX, 0),
            child: greetingName == null
                ? const SizedBox.shrink()
                : Text(
                    l10n.welcomeUserName(greetingName),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
          ),
          if (greetingName != null)
            SizedBox(height: AppSpacing.xs),
          Padding(
            padding: EdgeInsets.fromLTRB(padX, 0, padX, 0),
            child: ListenableBuilder(
              listenable: _search,
              builder: (context, _) {
                return TextField(
                  controller: _search,
                  onChanged: (_) => _scheduleFetch(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.shopSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              _scheduleFetch();
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    isDense: true,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(padX, AppSpacing.sm, padX, 0),
            child: FutureBuilder<List<FlashOffer>>(
              future: _offersFuture,
              builder: (context, snap) {
                final offers = snap.data ?? const <FlashOffer>[];
                if (offers.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FlashOffersPage(),
                    ),
                  ),
                  child: Container(
                    height: 132,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF171717), Color(0xFF2A2417)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 6),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on, color: Color(0xFFC5A059), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Flash Offers',
                                  style: GoogleFonts.playfairDisplay(
                                    color: const Color(0xFFF6ECD4),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFFF6ECD4)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: _offersPager,
                            onPageChanged: (i) => setState(() => _offerPage = i % offers.length),
                            itemBuilder: (context, i) {
                              final offer = offers[i % offers.length];
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(start: 10, end: 10, bottom: 10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const FlashOffersPage(),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white.withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: const Color(0xFFC5A059).withValues(alpha: 0.45),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  offer.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  '${offer.originalPrice.toStringAsFixed(2)}  ->  ${offer.discountedPrice.toStringAsFixed(2)}',
                                                  style: GoogleFonts.montserrat(
                                                    color: const Color(0xFFF6ECD4),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.local_offer, color: Color(0xFFC5A059)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        l10n.couldNotLoadProducts('${snap.error}'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final list = snap.data ?? [];
                final displayedList = list.reversed.toList();
                if (displayedList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        _appliedQuery.isNotEmpty
                            ? l10n.shopSearchNoResults
                            : l10n.noProductsYet,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final suggestions = _appliedQuery.isNotEmpty
                    ? displayedList.take(5).toList()
                    : <Product>[];

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (suggestions.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              padX,
                              AppSpacing.sm,
                              padX,
                              AppSpacing.xxs,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.shopSuggestionsTitle,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: suggestions.map((p) {
                                    return ActionChip(
                                      label: Text(
                                        p.localizedName(lang),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ProductDetailPage(
                                            productId: p.id,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ResponsiveProductSliverGrid(
                        padding: EdgeInsets.all(padX),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final p = displayedList[i];
                            return _ProductTile(
                              lang: lang,
                              product: p,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProductDetailPage(
                                    productId: p.id,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: displayedList.length,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.lang,
    required this.product,
    required this.onTap,
  });

  final String lang;
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = product.images.isNotEmpty ? product.images.first : null;
    final isAssetImage = image != null && image.startsWith('asset:');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: image == null
                  ? Container(
                      color: AppTheme.cream,
                      alignment: Alignment.center,
                      child: const Icon(Icons.set_meal, size: 40),
                    )
                  : (isAssetImage
                      ? Image.asset(
                          'assets/images/${image.substring('asset:'.length)}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.cream,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.cream,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.localizedName(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    product.salePrice != null
                        ? '${product.unitPrice.toStringAsFixed(2)} · ${product.weightLabel}'
                        : '${product.price.toStringAsFixed(2)} · ${product.weightLabel}',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppTheme.goldDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
