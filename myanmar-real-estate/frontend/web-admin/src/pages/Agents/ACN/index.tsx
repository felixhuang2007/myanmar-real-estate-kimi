import React, { useRef } from 'react';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { message, Modal, Input, Tag, Tooltip } from 'antd';
import { getACNTransactions, confirmACNTransaction, rejectACNTransaction, IACNTransaction } from '@/services/finance';

const statusMap: Record<string, { color: string; text: string }> = {
  pending: { color: 'orange', text: '待确认' },
  confirmed: { color: 'blue', text: '已确认' },
  settled: { color: 'green', text: '已结算' },
  rejected: { color: 'red', text: '已拒绝' },
  disputed: { color: 'purple', text: '争议中' },
};

const ACN: React.FC = () => {
  const actionRef = useRef<ActionType>();

  const handleConfirm = (id: number) => {
    Modal.confirm({
      title: '确认该ACN交易？',
      content: '确认后将进行佣金分配，无法撤销。',
      onOk: async () => {
        await confirmACNTransaction(id);
        message.success('已确认交易');
        actionRef.current?.reload();
      },
    });
  };

  const handleReject = (id: number) => {
    let reason = '';
    Modal.confirm({
      title: '拒绝原因',
      content: (
        <Input.TextArea
          rows={3}
          placeholder="请输入拒绝原因"
          onChange={(e) => { reason = e.target.value; }}
        />
      ),
      onOk: async () => {
        if (!reason.trim()) {
          message.warning('请填写拒绝原因');
          return Promise.reject();
        }
        await rejectACNTransaction(id, { reason });
        message.success('已拒绝交易');
        actionRef.current?.reload();
      },
    });
  };

  const columns: ProColumns<IACNTransaction>[] = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    {
      title: '房源',
      dataIndex: 'house_title',
      width: 180,
      ellipsis: true,
      render: (val, record) => (
        <Tooltip title={`房源ID: ${record.house_id}`}>{val as string}</Tooltip>
      ),
    },
    {
      title: '成交价 (MMK)',
      dataIndex: 'transaction_price',
      width: 130,
      render: (val) => (val as number).toLocaleString(),
    },
    {
      title: '总佣金 (MMK)',
      dataIndex: 'commission_amount',
      width: 130,
      render: (val) => (val as number).toLocaleString(),
    },
    {
      title: '平台费 (MMK)',
      dataIndex: 'platform_fee',
      width: 110,
      render: (val) => (val as number).toLocaleString(),
    },
    { title: '录入人', dataIndex: 'entry_agent', width: 90 },
    { title: '带看人', dataIndex: 'viewer_agent', width: 90 },
    { title: '成交人', dataIndex: 'closer_agent', width: 90 },
    {
      title: '状态',
      dataIndex: 'status',
      width: 90,
      render: (val) => {
        const s = statusMap[val as string] ?? { color: 'default', text: val as string };
        return <Tag color={s.color}>{s.text}</Tag>;
      },
      valueEnum: {
        pending: { text: '待确认', status: 'Warning' },
        confirmed: { text: '已确认', status: 'Processing' },
        settled: { text: '已结算', status: 'Success' },
        rejected: { text: '已拒绝', status: 'Error' },
        disputed: { text: '争议中', status: 'Default' },
      },
    },
    {
      title: '创建时间',
      dataIndex: 'created_at',
      width: 160,
      render: (val) => val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
    {
      title: '操作',
      valueType: 'option',
      width: 140,
      render: (_, record) =>
        record.status === 'pending'
          ? [
              <a key="confirm" onClick={() => handleConfirm(record.id)}>确认</a>,
              <a key="reject" style={{ color: 'red' }} onClick={() => handleReject(record.id)}>拒绝</a>,
            ]
          : ['-'],
    },
  ];

  return (
    <ProTable<IACNTransaction>
      headerTitle="ACN协作管理"
      actionRef={actionRef}
      rowKey="id"
      columns={columns}
      request={async (params) => {
        const res = await getACNTransactions({
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

export default ACN;
