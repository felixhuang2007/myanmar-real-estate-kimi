import React, { useRef, useState } from 'react';
import { ProTable, ModalForm, ProFormText, ProFormSelect, ProFormDigit } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';
import { Button, Popconfirm, message, Switch, Image } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import {
  getBannerList,
  createBanner,
  updateBanner,
  deleteBanner,
  updateBannerStatus,
  IBanner,
} from '@/services/banner';

const BannerManage: React.FC = () => {
  const actionRef = useRef<ActionType>();
  const [editRecord, setEditRecord] = useState<IBanner | null>(null);
  const [modalVisible, setModalVisible] = useState(false);

  const columns: ProColumns<IBanner>[] = [
    {
      title: '图片',
      dataIndex: 'image_url',
      width: 120,
      render: (url) => (
        <Image
          src={url as string}
          width={100}
          height={50}
          style={{ objectFit: 'cover' }}
        />
      ),
    },
    { title: '标题', dataIndex: 'title', width: 200 },
    {
      title: '位置',
      dataIndex: 'position',
      width: 100,
      valueEnum: { home: '首页', search: '搜索页', detail: '详情页' },
    },
    { title: '排序', dataIndex: 'sort_order', width: 80 },
    { title: '点击量', dataIndex: 'click_count', width: 80 },
    {
      title: '状态',
      dataIndex: 'status',
      width: 80,
      render: (_, record) => (
        <Switch
          checked={record.status === 'active'}
          onChange={async (checked) => {
            await updateBannerStatus(record.id, checked ? 'active' : 'inactive');
            actionRef.current?.reload();
          }}
        />
      ),
    },
    {
      title: '操作',
      valueType: 'option',
      width: 120,
      render: (_, record) => [
        <a
          key="edit"
          onClick={() => {
            setEditRecord(record);
            setModalVisible(true);
          }}
        >
          编辑
        </a>,
        <Popconfirm
          key="delete"
          title="确认删除?"
          onConfirm={async () => {
            await deleteBanner(record.id);
            message.success('已删除');
            actionRef.current?.reload();
          }}
        >
          <a style={{ color: 'red' }}>删除</a>
        </Popconfirm>,
      ],
    },
  ];

  return (
    <>
      <ProTable<IBanner>
        headerTitle="Banner管理"
        actionRef={actionRef}
        rowKey="id"
        columns={columns}
        request={async (params) => {
          const res = await getBannerList({
            position: params.position,
            status: params.status,
          });
          return { data: res.list || [], total: res.total || 0, success: true };
        }}
        toolBarRender={() => [
          <Button
            key="add"
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => {
              setEditRecord(null);
              setModalVisible(true);
            }}
          >
            新建Banner
          </Button>,
        ]}
        pagination={{ pageSize: 20 }}
        search={false}
      />
      <ModalForm
        title={editRecord ? '编辑Banner' : '新建Banner'}
        open={modalVisible}
        onOpenChange={setModalVisible}
        initialValues={
          editRecord || { position: 'home', link_type: 'none', sort_order: 0 }
        }
        onFinish={async (values) => {
          if (editRecord) {
            await updateBanner(editRecord.id, values);
            message.success('更新成功');
          } else {
            await createBanner(values);
            message.success('创建成功');
          }
          actionRef.current?.reload();
          return true;
        }}
      >
        <ProFormText name="title" label="标题" rules={[{ required: true }]} />
        <ProFormText
          name="image_url"
          label="图片URL"
          rules={[{ required: true }]}
        />
        <ProFormText name="link_url" label="跳转链接" />
        <ProFormSelect
          name="link_type"
          label="链接类型"
          options={[
            { label: '房源', value: 'house' },
            { label: '外部链接', value: 'url' },
            { label: '无跳转', value: 'none' },
          ]}
        />
        <ProFormSelect
          name="position"
          label="显示位置"
          options={[
            { label: '首页', value: 'home' },
            { label: '搜索页', value: 'search' },
            { label: '详情页', value: 'detail' },
          ]}
        />
        <ProFormDigit name="sort_order" label="排序" min={0} />
      </ModalForm>
    </>
  );
};

export default BannerManage;
