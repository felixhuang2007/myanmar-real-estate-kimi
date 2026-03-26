import React, { useRef } from 'react';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { Tag } from 'antd';
import { getCommissionDetails, ICommissionDetail } from '@/services/finance';

const roleDisplayMap: Record<string, string> = {
  entry: '录入人',
  maintainer: '维护人',
  viewer: '带看人',
  closer: '成交人',
  referrer: '转介绍',
};

const statusMap: Record<string, { color: string; text: string }> = {
  pending: { color: 'orange', text: '待结算' },
  settled: { color: 'green', text: '已结算' },
  cancelled: { color: 'default', text: '已取消' },
};

const Commission: React.FC = () => {
  const actionRef = useRef<ActionType>();

  const columns: ProColumns<ICommissionDetail>[] = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '交易ID', dataIndex: 'transaction_id', width: 80 },
    { title: '经纪人', dataIndex: 'agent_name', width: 100 },
    {
      title: '角色',
      dataIndex: 'role',
      width: 90,
      render: (val) => roleDisplayMap[val as string] ?? (val as string),
    },
    {
      title: '佣金比例',
      dataIndex: 'percentage',
      width: 90,
      render: (val) => `${val}%`,
    },
    {
      title: '佣金金额 (MMK)',
      dataIndex: 'amount',
      width: 140,
      render: (val) => (val as number).toLocaleString(),
    },
    {
      title: '状态',
      dataIndex: 'status',
      width: 90,
      render: (val) => {
        const s = statusMap[val as string] ?? { color: 'default', text: val as string };
        return <Tag color={s.color}>{s.text}</Tag>;
      },
      valueEnum: {
        pending: { text: '待结算', status: 'Warning' },
        settled: { text: '已结算', status: 'Success' },
        cancelled: { text: '已取消', status: 'Default' },
      },
    },
    {
      title: '结算时间',
      dataIndex: 'paid_at',
      width: 160,
      render: (val) => val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
    {
      title: '创建时间',
      dataIndex: 'created_at',
      width: 160,
      render: (val) => val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
  ];

  return (
    <ProTable<ICommissionDetail>
      headerTitle="佣金结算明细"
      actionRef={actionRef}
      rowKey="id"
      columns={columns}
      request={async (params) => {
        const res = await getCommissionDetails({
          page: params.current,
          pageSize: params.pageSize,
          status: params.status,
        });
        return { data: res.list || [], total: res.total || 0, success: true };
      }}
      search={{ labelWidth: 'auto' }}
      pagination={{ pageSize: 20 }}
    />
  );
};

export default Commission;
