import React, { useRef } from 'react';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { Button, message, Modal, Input, Tag } from 'antd';
import { getWithdrawals, auditWithdrawal, IWithdrawal } from '@/services/finance';

const statusMap: Record<string, { color: string; text: string }> = {
  pending: { color: 'orange', text: '待审核' },
  approved: { color: 'blue', text: '已批准' },
  paid: { color: 'green', text: '已打款' },
  rejected: { color: 'red', text: '已拒绝' },
};

const Withdrawal: React.FC = () => {
  const actionRef = useRef<ActionType>();

  const handleAudit = (id: number, action: 'approved' | 'rejected') => {
    if (action === 'rejected') {
      let reason = '';
      Modal.confirm({
        title: '请填写拒绝原因',
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
          await auditWithdrawal(id, { status: 'rejected', reason });
          message.success('已拒绝');
          actionRef.current?.reload();
        },
      });
    } else {
      Modal.confirm({
        title: '确认批准该提现申请？',
        onOk: async () => {
          await auditWithdrawal(id, { status: 'approved' });
          message.success('已批准');
          actionRef.current?.reload();
        },
      });
    }
  };

  const columns: ProColumns<IWithdrawal>[] = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '经纪人', dataIndex: 'agent_name', width: 100 },
    { title: '手机号', dataIndex: 'agent_phone', width: 130 },
    {
      title: '金额 (MMK)',
      dataIndex: 'amount',
      width: 130,
      render: (val) => (val as number).toLocaleString(),
    },
    { title: '银行', dataIndex: 'bank_name', width: 100 },
    { title: '账号', dataIndex: 'bank_account', width: 150 },
    { title: '持卡人', dataIndex: 'bank_holder', width: 100 },
    {
      title: '状态',
      dataIndex: 'status',
      width: 90,
      render: (val) => {
        const s = statusMap[val as string] ?? { color: 'default', text: val as string };
        return <Tag color={s.color}>{s.text}</Tag>;
      },
      valueEnum: {
        pending: { text: '待审核', status: 'Warning' },
        approved: { text: '已批准', status: 'Processing' },
        paid: { text: '已打款', status: 'Success' },
        rejected: { text: '已拒绝', status: 'Error' },
      },
    },
    {
      title: '申请时间',
      dataIndex: 'created_at',
      width: 160,
      render: (val) => val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
    {
      title: '操作',
      valueType: 'option',
      width: 160,
      render: (_, record) =>
        record.status === 'pending'
          ? [
              <a key="approve" onClick={() => handleAudit(record.id, 'approved')}>批准</a>,
              <a key="reject" style={{ color: 'red' }} onClick={() => handleAudit(record.id, 'rejected')}>拒绝</a>,
            ]
          : ['-'],
    },
  ];

  return (
    <ProTable<IWithdrawal>
      headerTitle="提现审核"
      actionRef={actionRef}
      rowKey="id"
      columns={columns}
      request={async (params) => {
        const res = await getWithdrawals({
          page: params.current,
          pageSize: params.pageSize,
          status: params.status,
        });
        return { data: res.list || [], total: res.total || 0, success: true };
      }}
      search={{ labelWidth: 'auto' }}
      pagination={{ pageSize: 20 }}
      toolBarRender={() => [
        <Button key="refresh" onClick={() => actionRef.current?.reload()}>刷新</Button>,
      ]}
    />
  );
};

export default Withdrawal;
