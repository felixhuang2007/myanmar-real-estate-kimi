import React, { useState, useEffect } from 'react';
import { Table, Card, Button, Input, Select, Tag, Space, Popconfirm, message } from 'antd';
import { SearchOutlined, EyeOutlined, CheckOutlined, CloseOutlined } from '@ant-design/icons';
import { ProTable } from '@ant-design/pro-components';
import { getHouseList, updateHouseStatus, deleteHouse } from '@/services';
import { IHouse, IPageData } from '@/types';
import { formatPrice, formatDate } from '@/utils';

const { Option } = Select;

const HouseList: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<IPageData<IHouse>>({
    list: [],
    total: 0,
    current: 1,
    pageSize: 10,
  });

  const columns = [
    {
      title: '房源标题',
      dataIndex: 'title',
      key: 'title',
      width: 300,
      ellipsis: true,
    },
    {
      title: '类型',
      dataIndex: 'transactionType',
      key: 'transactionType',
      width: 80,
      render: (type: string) => (
        <Tag color={type === 'sale' ? 'blue' : 'green'}>
          {type === 'sale' ? '出售' : '出租'}
        </Tag>
      ),
    },
    {
      title: '价格',
      dataIndex: 'price',
      key: 'price',
      width: 120,
      render: (price: number, record: IHouse) => formatPrice(price, record.priceUnit),
    },
    {
      title: '面积',
      dataIndex: 'area',
      key: 'area',
      width: 100,
      render: (area: number) => `${area}m²`,
    },
    {
      title: '区域',
      dataIndex: 'district',
      key: 'district',
      width: 120,
    },
    {
      title: '验真状态',
      dataIndex: 'verificationStatus',
      key: 'verificationStatus',
      width: 100,
      render: (status: string) => {
        const statusMap: Record<string, { color: string; text: string }> = {
          unverified: { color: 'default', text: '未验真' },
          pending: { color: 'processing', text: '验真中' },
          verified: { color: 'success', text: '已验真' },
          failed: { color: 'error', text: '验真失败' },
        };
        const { color, text } = statusMap[status] || statusMap.unverified;
        return <Tag color={color}>{text}</Tag>;
      },
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      width: 80,
      render: (status: string) => {
        const statusMap: Record<string, { color: string; text: string }> = {
          active: { color: 'success', text: '上架' },
          inactive: { color: 'default', text: '下架' },
          sold: { color: 'error', text: '已售' },
          rented: { color: 'error', text: '已租' },
        };
        const { color, text } = statusMap[status] || statusMap.inactive;
        return <Tag color={color}>{text}</Tag>;
      },
    },
    {
      title: '发布时间',
      dataIndex: 'publishTime',
      key: 'publishTime',
      width: 180,
      render: (date: string) => formatDate(date),
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      render: (_: any, record: IHouse) => (
        <Space size="middle">
          <Button type="link" icon={<EyeOutlined />} size="small">
            查看
          </Button>
          {record.status === 'active' ? (
            <Button
              type="link"
              danger
              size="small"
              onClick={() => handleStatusChange(record.id, 'inactive')}
            >
              下架
            </Button>
          ) : (
            <Button
              type="link"
              size="small"
              onClick={() => handleStatusChange(record.id, 'active')}
            >
              上架
            </Button>
          )}
          <Popconfirm
            title="确定删除该房源吗？"
            onConfirm={() => handleDelete(record.id)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" danger size="small">
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const loadData = async (params?: any) => {
    setLoading(true);
    try {
      const result = await getHouseList({
        current: params?.current || 1,
        pageSize: params?.pageSize || 10,
        ...params,
      });
      setData(result);
    } catch (error) {
      console.error('加载数据失败', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (id: string, status: 'active' | 'inactive') => {
    try {
      await updateHouseStatus(id, status);
      message.success('操作成功');
      loadData();
    } catch (error) {
      message.error('操作失败');
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await deleteHouse(id);
      message.success('删除成功');
      loadData();
    } catch (error) {
      message.error('删除失败');
    }
  };

  return (
    <Card title="房源列表">
      <ProTable<IHouse>
        columns={columns}
        rowKey="id"
        loading={loading}
        dataSource={data.list}
        pagination={{
          total: data.total,
          current: data.current,
          pageSize: data.pageSize,
          showSizeChanger: true,
          showQuickJumper: true,
        }}
        search={{
          layout: 'vertical',
          defaultCollapsed: true,
        }}
        toolBarRender={() => [
          <Button type="primary" key="export">
            导出数据
          </Button>,
        ]}
        request={async (params) => {
          await loadData(params);
          return {
            data: data.list,
            success: true,
            total: data.total,
          };
        }}
      />
    </Card>
  );
};

export default HouseList;