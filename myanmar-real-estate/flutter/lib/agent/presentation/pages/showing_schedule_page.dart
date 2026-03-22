/**
 * B端 - 带看管理页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

class ShowingSchedulePage extends ConsumerStatefulWidget {
  const ShowingSchedulePage({super.key});

  @override
  ConsumerState<ShowingSchedulePage> createState() => _ShowingSchedulePageState();
}

class _ShowingSchedulePageState extends ConsumerState<ShowingSchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).schedule),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_today),
            label: Text(_isCalendarView ? '列表' : '日历'),
          ),
        ],
      ),
      body: _isCalendarView ? _buildCalendarView() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddShowingDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        // 日历
        Container(
          color: AppColors.white,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: AppColors.primary700),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary700,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.orange500,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.gray700),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.gray700),
            ),
            eventLoader: (day) {
              // 模拟事件
              if (day.day % 3 == 0) return [1];
              return [];
            },
          ),
        ),
        
        // 当日带看列表
        Expanded(
          child: _buildDayShowings(),
        ),
      ],
    );
  }

  Widget _buildDayShowings() {
    // 模拟当日带看数据
    final showings = [
      {
        'id': '1',
        'time': '10:00',
        'houseTitle': '仰光Tamwe区精装公寓',
        'houseArea': 'Tamwe区 · 120㎡',
        'clientName': '王先生',
        'clientPhone': '09***1234',
        'status': 'pending',
      },
      {
        'id': '2',
        'time': '14:00',
        'houseTitle': '仰光Bahan区别墅',
        'houseArea': 'Bahan区 · 280㎡',
        'clientName': '李女士',
        'clientPhone': '09***5678',
        'status': 'completed',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: showings.length,
      itemBuilder: (context, index) {
        final showing = showings[index];
        return _buildShowingCard(context, showing);
      },
    );
  }

  Widget _buildListView() {
    // 模拟所有带看数据
    final allShowings = [
      {
        'id': '1',
        'date': '今天',
        'time': '10:00',
        'houseTitle': '仰光Tamwe区精装公寓',
        'houseArea': 'Tamwe区 · 120㎡',
        'clientName': '王先生',
        'clientPhone': '09***1234',
        'status': 'pending',
      },
      {
        'id': '2',
        'date': '今天',
        'time': '14:00',
        'houseTitle': '仰光Bahan区别墅',
        'houseArea': 'Bahan区 · 280㎡',
        'clientName': '李女士',
        'clientPhone': '09***5678',
        'status': 'completed',
      },
      {
        'id': '3',
        'date': '明天',
        'time': '09:30',
        'houseTitle': '仰光Yankin区公寓',
        'houseArea': 'Yankin区 · 95㎡',
        'clientName': '陈先生',
        'clientPhone': '09***9012',
        'status': 'confirmed',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allShowings.length,
      itemBuilder: (context, index) {
        final showing = allShowings[index];
        return _buildShowingCard(context, showing, showDate: true);
      },
    );
  }

  Widget _buildShowingCard(BuildContext context, Map<String, dynamic> showing, 
      {bool showDate = false}) {
    final statusConfig = {
      'pending': {'label': '待完成', 'color': AppColors.orange500},
      'confirmed': {'label': '已确认', 'color': AppColors.blue500},
      'completed': {'label': '已完成', 'color': AppColors.green500},
      'cancelled': {'label': '已取消', 'color': AppColors.gray500},
    };

    final status = statusConfig[showing['status']]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (showDate)
                  Text(
                    showing['date'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.gray600,
                    ),
                  ),
                Text(
                  showing['time'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        showing['houseTitle'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (status['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: status['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  showing['houseArea'],
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: AppColors.gray500),
                    const SizedBox(width: 4),
                    Text(
                      showing['clientName'],
                      style: TextStyle(fontSize: 13, color: AppColors.gray700),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.phone, size: 14, color: AppColors.gray500),
                    const SizedBox(width: 4),
                    Text(
                      showing['clientPhone'],
                      style: TextStyle(fontSize: 13, color: AppColors.gray700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('导航'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showing['status'] == 'pending')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('签到'),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('详情'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddShowingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '新增带看',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: '选择房源',
                prefixIcon: const Icon(Icons.home),
                filled: true,
                fillColor: AppColors.gray50,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '选择客户',
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: AppColors.gray50,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '日期',
                      prefixIcon: const Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: AppColors.gray50,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '时间',
                      prefixIcon: const Icon(Icons.access_time),
                      filled: true,
                      fillColor: AppColors.gray50,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
