import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../../data/models/flash_offer.dart';
import 'shop_repository.dart';

class FlashOffersPage extends StatefulWidget {
  const FlashOffersPage({super.key});

  @override
  State<FlashOffersPage> createState() => _FlashOffersPageState();
}

class _FlashOffersPageState extends State<FlashOffersPage> {
  late Future<List<FlashOffer>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ShopRepository>().fetchFlashOffers();
  }

  Future<void> _reload() async {
    setState(() {
      _future = context.read<ShopRepository>().fetchFlashOffers();
    });
    await _future;
  }

  String _fmt(DateTime d) {
    final v = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${v.year}-${two(v.month)}-${two(v.day)} ${two(v.hour)}:${two(v.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final pad = AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width);
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Flash Offers'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<FlashOffer>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      l10n.couldNotLoadProducts('${snap.error}'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            final list = snap.data ?? const <FlashOffer>[];
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No active flash offers now.')),
                ],
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(pad),
              itemCount: list.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final offer = list[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 2.4,
                        child: offer.imageUrl.isEmpty
                            ? Container(
                                color: AppTheme.cream,
                                alignment: Alignment.center,
                                child: const Icon(Icons.flash_on, size: 42),
                              )
                            : Image.network(
                                offer.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppTheme.cream,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Before ${offer.originalPrice.toStringAsFixed(2)}  •  Now ${offer.discountedPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.goldDark,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Max/order: ${offer.maxQtyPerOrder}   Remaining: ${offer.remainingCount}',
                              style: GoogleFonts.montserrat(fontSize: 12),
                            ),
                            SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Start: ${_fmt(offer.startsAt)}\nEnd: ${_fmt(offer.endsAt)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            if (offer.products.isNotEmpty) ...[
                              SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xxs,
                                children: offer.products
                                    .map((p) => Chip(
                                          label: Text(
                                            p.localizedName(lang),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
