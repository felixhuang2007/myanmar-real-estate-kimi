import React, { useEffect, useState } from 'react';
import { Card, Table, Statistic, Row, Col, Tag } from 'antd';
import { TrophyOutlined, HomeOutlined, RiseOutlined } from '@ant-design/icons';
import http from '@/services/request';

interface PerfRow {
  agent_id: number;
  agent_name: string;
  total_deals: number;
  total_gmv: number;
}

const Performance: React.FC = () => {
  const [data, setData] = useState<PerfRow[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    http
      .get<PerfRow[]>('/admin/agents/performance')
      .then((res: any) => {
        const rows: PerfRow[] = res?.data ?? res ?? [];
        setData(Array.isArray(rows) ? rows : []);
      })
      .finally(() => setLoading(false));
  }, []);

  const totalDeals = data.reduce((s, r) => s + (r.total_deals || 0), 0);
  const totalGMV = data.reduce((s, r) => s + (r.total_gmv || 0), 0);

  const columns = [
    {
      title: '排名',
      key: 'rank',
      width: 70,
      render: (_: any, __: any, index: number) => {
        if (index === 0) return <Tag color="gold">🥇 1</Tag>;
        if (index === 1) return <Tag color="silver">🥈 2</Tag>;
        if (index === 2) return <Tag color="orange">🥉 3</Tag>;
        return <span style={{ paddingLeft: 8 }}>{index + 1}</span>;
      },
    },
    {
      title: '经纪人',
      dataIndex: 'agent_name',
      key: 'agent_name',
    },
    {
      title: '成交套数',
      dataIndex: 'total_deals',
      key: 'total_deals',
      sorter: (a: PerfRow, b: PerfRow) => a.total_deals - b.total_deals,
      render: (v: number) => `${v} 套`,
    },
    {
      title: '成交总额（缅元）',
      dataIndex: 'total_gmv',
      key: 'total_gmv',
      sorter: (a: PerfRow, b: PerfRow) => a.total_gmv - b.total_gmv,
      render: (v: number) =>
        v >= 1_000_000
          ? `${(v / 1_000_000).toFixed(1)} M`
          : v.toLocaleString(),
    },
  ];

  return (
    <>
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={8}>
          <Card>
            <Statistic
              title="上榜经纪人数"
              value={data.length}
              prefix={<TrophyOutlined />}
              suffix="人"
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic
              title="合计成交套数"
              value={totalDeals}
              prefix={<HomeOutlined />}
              suffix="套"
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic
              title="合计成交总额"
              value={totalGMV >= 1_000_000 ? (totalGMV / 1_000_000).toFixed(1) : totalGMV}
              prefix={<RiseOutlined />}
              suffix={totalGMV >= 1_000_000 ? 'M 缅元' : '缅元'}
            />
          </Card>
        </Col>
      </Row>

      <Card title="经纪人业绩排行榜（按成交总额）">
        <Table
          rowKey="agent_id"
          loading={loading}
          dataSource={data}
          columns={columns}
          pagination={false}
        />
      </Card>
    </>
  );
};

export default Performance;
