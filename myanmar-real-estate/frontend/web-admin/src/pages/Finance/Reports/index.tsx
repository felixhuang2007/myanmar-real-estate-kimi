import React, { useEffect, useState } from 'react';
import { Card, Row, Col, Statistic, Table, DatePicker, Space, Typography } from 'antd';
import { ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons';
import { getDashboardStats, getDealTrend } from '@/services/dashboard';
import { IDashboardStats, ITrendData } from '@/types';

const { RangePicker } = DatePicker;
const { Title } = Typography;

const Reports: React.FC = () => {
  const [stats, setStats] = useState<IDashboardStats | null>(null);
  const [trendData, setTrendData] = useState<ITrendData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [statsRes, trendRes] = await Promise.all([
          getDashboardStats(),
          getDealTrend(30),
        ]);
        setStats(statsRes);
        setTrendData(trendRes);
      } catch (e) {
        // silently fail — page still renders with empty data
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const trendColumns = [
    { title: '日期', dataIndex: 'date', key: 'date' },
    {
      title: '成交额 (MMK)',
      dataIndex: 'value',
      key: 'value',
      render: (val: number) => val.toLocaleString(),
    },
  ];

  return (
    <div style={{ padding: '0 0 24px' }}>
      <Title level={4} style={{ marginBottom: 24 }}>财务报表</Title>

      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="本月成交额 (MMK)"
              value={stats?.monthGMV ?? 0}
              formatter={(val) => Number(val).toLocaleString()}
              prefix={<ArrowUpOutlined style={{ color: '#3f8600' }} />}
              valueStyle={{ color: '#3f8600' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="本月成交笔数"
              value={stats?.monthDeals ?? 0}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="本月预约数"
              value={stats?.monthAppointments ?? 0}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="活跃经纪人"
              value={stats?.activeAgents ?? 0}
            />
          </Card>
        </Col>
      </Row>

      <Card
        title="近30日成交趋势"
        extra={
          <Space>
            <RangePicker />
          </Space>
        }
      >
        <Table
          columns={trendColumns}
          dataSource={trendData}
          rowKey="date"
          pagination={{ pageSize: 10 }}
          loading={loading}
          size="small"
        />
      </Card>
    </div>
  );
};

export default Reports;
