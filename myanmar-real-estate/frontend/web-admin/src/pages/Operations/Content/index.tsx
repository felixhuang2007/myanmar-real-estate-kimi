import React, { useRef, useState } from 'react';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { Button, message, Modal, Form, Input, Select, Tag } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { http } from '@/services/request';

interface IContent {
  id: number;
  title: string;
  type: 'notice' | 'article' | 'faq';
  status: 'published' | 'draft' | 'archived';
  author?: string;
  created_at: string;
  updated_at: string;
}

const typeMap: Record<string, string> = {
  notice: '公告',
  article: '文章',
  faq: '常见问题',
};

const statusMap: Record<string, { color: string; text: string }> = {
  published: { color: 'green', text: '已发布' },
  draft: { color: 'orange', text: '草稿' },
  archived: { color: 'default', text: '已归档' },
};

const Content: React.FC = () => {
  const actionRef = useRef<ActionType>();
  const [modalOpen, setModalOpen] = useState(false);
  const [editingRecord, setEditingRecord] = useState<IContent | null>(null);
  const [form] = Form.useForm();

  const handleSave = async () => {
    const values = await form.validateFields();
    try {
      if (editingRecord) {
        await http.put(`/admin/contents/${editingRecord.id}`, values);
        message.success('更新成功');
      } else {
        await http.post('/admin/contents', values);
        message.success('创建成功');
      }
      setModalOpen(false);
      form.resetFields();
      setEditingRecord(null);
      actionRef.current?.reload();
    } catch (e) {
      // error already shown by interceptor
    }
  };

  const handleEdit = (record: IContent) => {
    setEditingRecord(record);
    form.setFieldsValue(record);
    setModalOpen(true);
  };

  const handleDelete = (id: number) => {
    Modal.confirm({
      title: '确认删除该内容？',
      onOk: async () => {
        await http.delete(`/admin/contents/${id}`);
        message.success('删除成功');
        actionRef.current?.reload();
      },
    });
  };

  const columns: ProColumns<IContent>[] = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '标题', dataIndex: 'title', ellipsis: true },
    {
      title: '类型',
      dataIndex: 'type',
      width: 90,
      render: (val) => typeMap[val as string] ?? (val as string),
      valueEnum: {
        notice: { text: '公告' },
        article: { text: '文章' },
        faq: { text: '常见问题' },
      },
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
        published: { text: '已发布', status: 'Success' },
        draft: { text: '草稿', status: 'Warning' },
        archived: { text: '已归档', status: 'Default' },
      },
    },
    { title: '作者', dataIndex: 'author', width: 100 },
    {
      title: '更新时间',
      dataIndex: 'updated_at',
      width: 160,
      render: (val) => val ? new Date(val as string).toLocaleString('zh-CN') : '-',
    },
    {
      title: '操作',
      valueType: 'option',
      width: 130,
      render: (_, record) => [
        <a key="edit" onClick={() => handleEdit(record)}>编辑</a>,
        <a key="delete" style={{ color: 'red' }} onClick={() => handleDelete(record.id)}>删除</a>,
      ],
    },
  ];

  return (
    <>
      <ProTable<IContent>
        headerTitle="内容管理"
        actionRef={actionRef}
        rowKey="id"
        columns={columns}
        request={async (params) => {
          const res = await http.get<{ list: IContent[]; total: number }>('/admin/contents', {
            page: params.current,
            pageSize: params.pageSize,
            type: params.type,
            status: params.status,
          });
          return { data: res.list || [], total: res.total || 0, success: true };
        }}
        search={{ labelWidth: 'auto' }}
        pagination={{ pageSize: 20 }}
        toolBarRender={() => [
          <Button
            key="add"
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => {
              setEditingRecord(null);
              form.resetFields();
              setModalOpen(true);
            }}
          >
            新建内容
          </Button>,
        ]}
      />

      <Modal
        title={editingRecord ? '编辑内容' : '新建内容'}
        open={modalOpen}
        onOk={handleSave}
        onCancel={() => {
          setModalOpen(false);
          form.resetFields();
          setEditingRecord(null);
        }}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="标题" rules={[{ required: true, message: '请输入标题' }]}>
            <Input placeholder="请输入标题" />
          </Form.Item>
          <Form.Item name="type" label="类型" rules={[{ required: true, message: '请选择类型' }]}>
            <Select placeholder="请选择类型">
              <Select.Option value="notice">公告</Select.Option>
              <Select.Option value="article">文章</Select.Option>
              <Select.Option value="faq">常见问题</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="status" label="状态" initialValue="draft">
            <Select>
              <Select.Option value="draft">草稿</Select.Option>
              <Select.Option value="published">已发布</Select.Option>
              <Select.Option value="archived">已归档</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="content" label="内容" rules={[{ required: true, message: '请输入内容' }]}>
            <Input.TextArea rows={6} placeholder="请输入内容" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  );
};

export default Content;
