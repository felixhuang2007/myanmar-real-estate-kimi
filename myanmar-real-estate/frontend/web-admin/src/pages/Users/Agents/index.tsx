import React, { useRef } from 'react';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { Button, message, Modal, Input } from 'antd';
import { getAgentList, auditAgent, IAgent } from '@/services/agent';

const AgentsPage: React.FC = () => {
  const actionRef = useRef<ActionType>();

  const handleAudit = (id: number, status: 'active' | 'rejected') => {
    if (status === 'rejected') {
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
          await auditAgent(id, { status, reason });
          message.success('已拒绝');
          actionRef.current?.reload();
        },
      });
    } else {
      Modal.confirm({
        title: '确认审核通过该经纪人？',
        onOk: async () => {
          await auditAgent(id, { status });
          message.success('已审核通过');
          actionRef.current?.reload();
        },
      });
    }
  };

  const columns: ProColumns<IAgent>[] = [
    { title: '姓名', dataIndex: 'name', width: 100 },
    { title: '手机号', dataIndex: 'phone', width: 130 },
    { title: '执照号', dataIndex: 'license_number', width: 150 },
    { title: '所属机构', dataIndex: 'agency_name', width: 150 },
    {
      title: '状态',
      dataIndex: 'status',
      width: 100,
      valueEnum: {
        active: { text: '正常', status: 'Success' },
        inactive: { text: '禁用', status: 'Default' },
        pending: { text: '待审核', status: 'Processing' },
        rejected: { text: '已拒绝', status: 'Error' },
      },
    },
    { title: '房源数', dataIndex: 'house_count', width: 80 },
    { title: '成交数', dataIndex: 'deal_count', width: 80 },
    {
      title: '注册时间',
      dataIndex: 'created_at',
      width: 160,
      render: (val) => val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
    {
      title: '操作',
      valueType: 'option',
      width: 200,
      render: (_, record) => [
        record.status === 'pending' && (
          <a key="approve" onClick={() => handleAudit(record.id, 'active')}>通过</a>
        ),
        record.status === 'pending' && (
          <a key="reject" style={{ color: 'red' }} onClick={() => handleAudit(record.id, 'rejected')}>拒绝</a>
        ),
        record.status === 'active' && (
          <a
            key="disable"
            style={{ color: 'orange' }}
            onClick={async () => {
              await auditAgent(record.id, { status: 'inactive' });
              message.success('已禁用');
              actionRef.current?.reload();
            }}
          >
            禁用
          </a>
        ),
        record.status === 'inactive' && (
          <a
            key="enable"
            onClick={async () => {
              await auditAgent(record.id, { status: 'active' });
              message.success('已启用');
              actionRef.current?.reload();
            }}
          >
            启用
          </a>
        ),
      ],
    },
  ];

  return (
    <ProTable<IAgent>
      headerTitle="经纪人列表"
      actionRef={actionRef}
      rowKey="id"
      columns={columns}
      request={async (params) => {
        const res = await getAgentList({
          status: params.status,
          search: params.keyword,
          page: params.current,
          pageSize: params.pageSize,
        });
        return { data: res.list || [], total: res.total || 0, success: true };
      }}
      search={{ labelWidth: 'auto' }}
      pagination={{ pageSize: 20 }}
    />
  );
};

export default AgentsPage;
