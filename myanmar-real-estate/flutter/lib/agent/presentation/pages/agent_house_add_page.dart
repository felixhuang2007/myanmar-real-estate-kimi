/**
 * B端 - 极速录房页面
 */
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../providers/house_provider.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

// ===========================================================================
// LocationPickerPage
// ===========================================================================

class LocationPickerPage extends StatefulWidget {
  /// Pre-selected position (optional). Defaults to Yangon center.
  final LatLng? initialPosition;

  const LocationPickerPage({super.key, this.initialPosition});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const LatLng _yangonCenter = LatLng(16.8661, 96.1951);

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _confirm() {
    final center = _mapController.camera.center;
    Navigator.of(context).pop(center);
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initialPosition ?? _yangonCenter;

    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.location),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: Stack(
        children: [
          // ---- Map ----
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.myanmarhome.agent',
              ),
            ],
          ),

          // ---- Fixed center pin (tip aligns with center via bottom offset) ----
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_pin,
                  size: 48,
                  color: AppColors.primary700,
                ),
                // Shift up by half icon height so pin tip hits the center point
                SizedBox(height: 24),
              ],
            ),
          ),

          // ---- Instruction banner ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: const Text(
                '拖动地图将图钉移至房源位置',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          // ---- Confirm button ----
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check),
                  label: Text(AppLocalizations.of(context).confirm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AgentHouseAddPage extends ConsumerStatefulWidget {
  const AgentHouseAddPage({super.key});

  @override
  ConsumerState<AgentHouseAddPage> createState() => _AgentHouseAddPageState();
}

class _AgentHouseAddPageState extends ConsumerState<AgentHouseAddPage> {
  final _formKey = GlobalKey<FormState>();
  
  // 表单数据
  String _transactionType = 'sale';
  String _houseType = 'apartment';
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _roomsController = TextEditingController();
  final _floorController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();

  final List<String> _images = [];
  final List<XFile> _pendingImages = [];
  bool _isLoading = false;

  // Location picker state
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _roomsController.dispose();
    _floorController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    ToastUtil.showSuccess(AppLocalizations.of(context).save);
    context.pop();
  }

  /// 上传本地待传图片，返回所有图片URL（已上传 + 新上传）
  Future<List<String>> _uploadImages() async {
    final token = ref.read(authProvider).user?.token ?? '';
    final dio = Dio();
    if (token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    final urls = <String>[];
    for (final xfile in _pendingImages) {
      final bytes = await xfile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: xfile.name),
      });
      try {
        final resp = await dio.post(
          '${ApiConstants.baseUrl}/v1/upload/image',
          data: formData,
        );
        if (resp.data['code'] == 200) {
          urls.add(resp.data['data']['url'] as String);
        }
      } catch (_) {
        // 单张失败时跳过，继续上传其余图片
      }
    }
    return [..._images, ...urls];
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialPosition: (_latitude != null && _longitude != null)
              ? LatLng(_latitude!, _longitude!)
              : null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        // Auto-fill address with coordinates when address is still empty
        if (_addressController.text.isEmpty) {
          _addressController.text =
              '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // 先上传待传图片
      final allImages = await _uploadImages();

      final body = <String, dynamic>{
        'title': _titleController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'area': double.tryParse(_areaController.text.trim()) ?? 0,
        'rooms': _roomsController.text.trim(),
        'floor': _floorController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'owner_name': _ownerNameController.text.trim(),
        'owner_phone': _ownerPhoneController.text.trim(),
        'transaction_type': _transactionType,
        'house_type': _houseType,
        'price_unit': 'MMK',
        'city_code': CityCodes.yangon,
        'district_code': DistrictCodes.tamwe,
        'images': allImages,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      };

      await ref.read(createHouseProvider.notifier).createHouse(body);

      if (mounted) {
        ToastUtil.showSuccess('房源提交成功，等待审核');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失败: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.addHouse),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: Text(l.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 房源图片
            _buildImageUpload(),
            const SizedBox(height: 24),
            
            // 交易类型
            _buildSectionTitle('交易类型'),
            const SizedBox(height: 12),
            _buildTransactionTypeSelector(),
            const SizedBox(height: 24),
            
            // 房源类型
            _buildSectionTitle('房源类型'),
            const SizedBox(height: 12),
            _buildHouseTypeSelector(),
            const SizedBox(height: 24),
            
            // 基本信息
            _buildSectionTitle('基本信息'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              label: '房源标题',
              hint: '请输入房源标题',
              required: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: '价格',
                    hint: '请输入价格',
                    keyboardType: TextInputType.number,
                    required: true,
                    suffix: '万缅币',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _areaController,
                    label: '面积',
                    hint: '请输入面积',
                    keyboardType: TextInputType.number,
                    required: true,
                    suffix: '㎡',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _roomsController,
                    label: '户型',
                    hint: '如：3室2厅',
                    required: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _floorController,
                    label: '楼层',
                    hint: '如：8/15',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 位置信息
            _buildSectionTitle('位置信息'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressController,
              label: '详细地址',
              hint: '请输入详细地址',
              required: true,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // 地图选点按钮
            OutlinedButton.icon(
              onPressed: _openLocationPicker,
              icon: const Icon(Icons.map),
              label: Text(
                (_latitude != null && _longitude != null)
                    ? '已选择: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                    : '在地图上选择位置',
              ),
            ),
            if (_latitude != null && _longitude != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.primary700),
                  const SizedBox(width: 4),
                  Text(
                    '纬度: ${_latitude!.toStringAsFixed(5)}  经度: ${_longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gray600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _latitude = null;
                      _longitude = null;
                    }),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.gray500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            
            // 房源描述
            _buildSectionTitle('房源描述'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: '房源描述',
              hint: '请输入房源描述信息...',
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            
            // 业主信息
            _buildSectionTitle('业主信息'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _ownerNameController,
              label: '业主姓名',
              hint: '请输入业主姓名',
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ownerPhoneController,
              label: '业主电话',
              hint: '请输入业主电话',
              keyboardType: TextInputType.phone,
              required: true,
            ),
            const SizedBox(height: 32),
            
            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('提交审核'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    int maxLines = 1,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        suffixText: suffix,
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '请输入$label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('房源图片'),
        const SizedBox(height: 8),
        Text(
          '建议上传6-12张图片，包含客厅、卧室、厨房、卫生间等',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 已上传图片（网络图片）
            ..._images.map((url) => _buildNetworkImageItem(url)),
            // 本地待上传图片（本地文件）
            ..._pendingImages.map((xfile) => _buildLocalImageItem(xfile)),
            // 添加按钮（总数不超过9张时显示）
            if (_images.length + _pendingImages.length < 9)
              _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkImageItem(String url) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLocalImageItem(XFile xfile) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(xfile.path),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final images = await picker.pickMultiImage(imageQuality: 80);
        if (images.isEmpty) return;
        setState(() {
          _pendingImages.addAll(
            images.take(9 - _images.length - _pendingImages.length),
          );
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.gray400,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              color: AppColors.gray500,
            ),
            SizedBox(height: 4),
            Text(
              '添加图片',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Row(
      children: [
        _buildTypeChip(
          label: '出售',
          isSelected: _transactionType == 'sale',
          onTap: () => setState(() => _transactionType = 'sale'),
        ),
        const SizedBox(width: 12),
        _buildTypeChip(
          label: '出租',
          isSelected: _transactionType == 'rent',
          onTap: () => setState(() => _transactionType = 'rent'),
        ),
      ],
    );
  }

  Widget _buildHouseTypeSelector() {
    final types = [
      {'code': 'apartment', 'label': '公寓', 'icon': Icons.apartment},
      {'code': 'house', 'label': '别墅', 'icon': Icons.home},
      {'code': 'townhouse', 'label': '联排', 'icon': Icons.holiday_village},
      {'code': 'land', 'label': '土地', 'icon': Icons.landscape},
      {'code': 'commercial', 'label': '商铺', 'icon': Icons.store},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _houseType == type['code'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type['icon'] as IconData,
                size: 16,
                color: isSelected ? AppColors.white : AppColors.gray600,
              ),
              const SizedBox(width: 4),
              Text(type['label'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => setState(() => _houseType = type['code'] as String),
          selectedColor: AppColors.primary700,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.white : AppColors.gray700,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary700 : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.gray700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
