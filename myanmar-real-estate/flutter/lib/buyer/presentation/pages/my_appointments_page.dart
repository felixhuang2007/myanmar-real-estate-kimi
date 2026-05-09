/**
 * C端 - 我的预约页面
 */
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/dio_client.dart';
import '../../../l10n/gen/app_localizations.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final response = await DioClient.instance.get('/appointments');
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final list = data['list'] as List<dynamic>? ?? [];
        setState(() {
          _appointments = list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _cancelAppointment(int id) async {
    final l = AppLocalizations.of(context);
    try {
      await DioClient.instance.post('/appointments/$id/cancel', data: {});
      _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.myAppointments),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(context)
              : _appointments.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final item = _appointments[index];
                        return _buildAppointmentItem(context, item);
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
            onPressed: _loadAppointments,
            child: Text(l.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule a viewing from any property detail page',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildAppointmentItem(BuildContext context, dynamic item) {
    final status = item['status'] as String? ?? 'pending';
    final date = item['appointment_date'] as String? ?? '';
    final timeStart = item['appointment_time_start'] as String? ?? '';
    final timeEnd = item['appointment_time_end'] as String? ?? '';
    final houseId = item['house_id'] as int?;
    final note = item['client_note'] as String?;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'confirmed':
        statusColor = AppColors.green500;
        statusLabel = 'Confirmed';
        break;
      case 'completed':
        statusColor = AppColors.blue500;
        statusLabel = 'Completed';
        break;
      case 'cancelled':
        statusColor = AppColors.gray500;
        statusLabel = 'Cancelled';
        break;
      default:
        statusColor = AppColors.orange500;
        statusLabel = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (status == 'pending' || status == 'confirmed')
                TextButton(
                  onPressed: () => _cancelAppointment(item['appointment_id'] as int),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.red600,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Cancel'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.gray600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatDate(date)}  $timeStart - $timeEnd',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.notes, size: 16, color: AppColors.gray600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (houseId != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.push('/buyer/house/$houseId');
                },
                child: const Text('View Property'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
