import React from 'react';
import { Card, Table, Tag } from 'antd';

const CommissionRules: React.FC = () => {
  const columns = [
    {
      title: '角色',
      dataIndex: 'role',
      key: 'role',
    },
    {
      title: '角色名称',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '分佣比例',
      dataIndex: 'ratio',
      key: 'ratio',
      render: (ratio: number) => `${ratio}%`,
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={status === 'active' ? 'success' : 'default'}>
          {status === 'active' ? '启用' : '禁用'}
        </Tag>
      ),
    },
  ];

  const data = [
    { role: 'ENTRANT', name: '房源录入人', ratio: 15, status: 'active' },
    { role: 'MAINTAINER', name: '房源维护人', ratio: 20, status: 'active' },
    { role: 'INTRODUCER', name: '客源转介绍', ratio: 10, status: 'active' },
    { role: 'ACCOMPANIER', name: '带看人', ratio: 15, status: 'active' },
    { role: 'CLOSER', name: '成交人', ratio: 40, status: 'active' },
  ];

  return (
    <Card title="分佣规则配置">
      <Table columns={columns} dataSource={data} rowKey="role" pagination={false} />
    </Card>
  );
};

export default CommissionRules;