import React, { useRef } from 'react';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { Tag } from 'antd';
import { getVerificationTasks } from '@/services/house';

interface IVerificationTask {
  id: number;
  task_code: string;
  house_id: number;
  type: string; // on_site/document/photo
  status: string; // pending/in_progress/completed/failed
  assignee: string;
  deadline_at: string;
  commission_amount: number;
  created_at: string;
}

const statusColors: Record<string, string> = {
  pending: 'processing',
  in_progress: 'warning',
  completed: 'success',
  failed: 'error',
};

const statusLabels: Record<string, string> = {
  pending: '待处理',
  in_progress: '进行中',
  completed: '已完成',
  failed: '已失败',
};

const typeLabels: Record<string, string> = {
  on_site: '实地核查',
  document: '证件核查',
  photo: '照片核查',
};

const Verification: React.FC = () => {
  const actionRef = useRef<ActionType>();

  const columns: ProColumns<IVerificationTask>[] = [
    {
      title: '任务编号',
      dataIndex: 'task_code',
      width: 160,
      copyable: true,
    },
    {
      title: '房源ID',
      dataIndex: 'house_id',
      width: 100,
    },
    {
      title: '类型',
      dataIndex: 'type',
      width: 120,
      render: (val) => typeLabels[val as string] || (val as string),
    },
    {
      title: '状态',
      dataIndex: 'status',
      width: 100,
      valueEnum: {
        pending: { text: '待处理', status: 'Processing' },
        in_progress: { text: '进行中', status: 'Warning' },
        completed: { text: '已完成', status: 'Success' },
        failed: { text: '已失败', status: 'Error' },
      },
    },
    {
      title: '验真员',
      dataIndex: 'assignee',
      width: 120,
    },
    {
      title: '截止时间',
      dataIndex: 'deadline_at',
      width: 160,
      render: (val) =>
        val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
    {
      title: '佣金金额',
      dataIndex: 'commission_amount',
      width: 120,
      render: (val) =>
        val != null ? `¥ ${Number(val).toLocaleString('zh-CN')}` : '-',
    },
    {
      title: '操作',
      valueType: 'option',
      width: 100,
      render: (_, record) => [
        <a key="detail" onClick={() => {}}>
          查看详情
        </a>,
      ],
    },
  ];

  return (
    <ProTable<IVerificationTask>
      headerTitle="验真任务管理"
      actionRef={actionRef}
      rowKey="id"
      columns={columns}
      request={async (params) => {
        const res = await getVerificationTasks({
          status: params.status,
          type: params.type,
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

export default Verification;
