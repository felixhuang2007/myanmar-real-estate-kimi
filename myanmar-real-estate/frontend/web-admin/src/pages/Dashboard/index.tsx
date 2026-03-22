import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Statistic, DatePicker } from 'antd';
import {
  UserOutlined,
  HomeOutlined,
  CalendarOutlined,
  DollarOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import { Line } from '@ant-design/plots';
import { getDashboardStats, getUserTrend, getHouseTrend, getDealTrend } from '@/services';
import { IDashboardStats, ITrendData } from '@/types';
import styles from './index.less';

const { RangePicker } = DatePicker;

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<IDashboardStats | null>(null);
  const [userTrend, setUserTrend] = useState<ITrendData[]>([]);
  const [houseTrend, setHouseTrend] = useState<ITrendData[]>([]);
  const [dealTrend, setDealTrend] = useState<ITrendData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      const [statsData, userData, houseData, dealData] = await Promise.all([
        getDashboardStats(),
        getUserTrend(7),
        getHouseTrend(7),
        getDealTrend(7),
      ]);
      setStats(statsData);
      setUserTrend(userData);
      setHouseTrend(houseData);
      setDealTrend(dealData);
    } catch (error) {
      console.error('加载数据失败', error);
    } finally {
      setLoading(false);
    }
  };

  const lineConfig = (data: ITrendData[]) => ({
    data,
    xField: 'date',
    yField: 'value',
    smooth: true,
    height: 300,
  });

  return (
    <div className={styles.dashboard}>
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} lg={6}>
          <Card loading={loading}>
            <Statistic
              title="总用户数"
              value={stats?.totalUsers || 0}
              prefix={<UserOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card loading={loading}>
            <Statistic
              title="总房源数"
              value={stats?.totalHouses || 0}
              prefix={<HomeOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card loading={loading}>
            <Statistic
              title="本月成交"
              value={stats?.monthDeals || 0}
              prefix={<CalendarOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card loading={loading}>
            <Statistic
              title="本月GMV"
              value={stats?.monthGMV || 0}
              prefix={<DollarOutlined />}
              suffix="万"
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginTop: 24 }}>
        <Col xs={24} lg={12}>
          <Card title="用户增长趋势" loading={loading}>
            <Line {...lineConfig(userTrend)} />
          </Card>
        </Col>
        <Col xs={24} lg={12}>
          <Card title="房源增长趋势" loading={loading}>
            <Line {...lineConfig(houseTrend)} />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginTop: 24 }}>
        <Col xs={24} lg={12}>
          <Card title="交易趋势" loading={loading}>
            <Line {...lineConfig(dealTrend)} />
          </Card>
        </Col>
        <Col xs={24} lg={12}>
          <Card title="经纪人统计" loading={loading}>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <Statistic
                  title="经纪人总数"
                  value={stats?.totalAgents || 0}
                  prefix={<TeamOutlined />}
                />
              </Col>
              <Col span={12}>
                <Statistic
                  title="活跃经纪人"
                  value={stats?.activeAgents || 0}
                />
              </Col>
            </Row>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default Dashboard;