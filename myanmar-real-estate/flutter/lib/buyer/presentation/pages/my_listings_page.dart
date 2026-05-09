/**
 * C端 - 我的发布页面
 */
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/dio_client.dart';
import '../../../l10n/gen/app_localizations.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  List<dynamic> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final response = await DioClient.instance.get('/houses/my');
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final list = data['list'] as List<dynamic>? ?? [];
        setState(() {
          _listings = list;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // 买家端通常没有发布权限，遇到错误时显示空列表
      setState(() {
        _isLoading = false;
        _listings = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.myListings),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(context)
              : _listings.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _listings.length,
                      itemBuilder: (context, index) {
                        final item = _listings[index];
                        return _buildListingItem(context, item);
                      },
                    ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: AppColors.gray600)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadListings,
            child: Text(l.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can publish properties from the Agent app',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListingItem(BuildContext context, dynamic item) {
    final houseId = item['house_id'] as int? ?? item['id'] as int?;
    final title = item['title'] as String? ?? 'Unknown';
    final image = item['images'] != null && (item['images'] as List).isNotEmpty
        ? (item['images'] as List)[0]['image_url'] as String?
        : null;
    final status = item['status'] as String? ?? 'online';
    final price = item['price'] as int? ?? 0;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'sold':
        statusColor = AppColors.red500;
        statusLabel = 'Sold';
        break;
      case 'offline':
        statusColor = AppColors.gray500;
        statusLabel = 'Offline';
        break;
      case 'pending':
        statusColor = AppColors.orange500;
        statusLabel = 'Pending';
        break;
      default:
        statusColor = AppColors.green500;
        statusLabel = 'Online';
    }

    return GestureDetector(
      onTap: () {
        if (houseId != null) {
          context.push('/buyer/house/$houseId');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: AppColors.gray200,
                child: image != null
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: AppColors.gray400),
                      )
                    : Icon(Icons.image, color: AppColors.gray400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(price / 10000).toStringAsFixed(0)}万',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}
