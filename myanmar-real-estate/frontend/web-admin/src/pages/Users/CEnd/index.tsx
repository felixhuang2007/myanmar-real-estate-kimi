import React, { useState } from 'react';
import { Card, Table, Tag, Button, Input, Avatar, Space } from 'antd';
import { SearchOutlined, EyeOutlined } from '@ant-design/icons';
import { getEndUserList } from '@/services';
import { IEndUser } from '@/types';
import { formatDate, maskPhone } from '@/utils';

const CEndUsers: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<IEndUser[]>([]);
  const [keyword, setKeyword] = useState('');

  const columns = [
    {
      title: '头像',
      dataIndex: 'avatar',
      key: 'avatar',
      width: 80,
      render: (avatar: string) => (
        <Avatar src={avatar} size="large" />
      ),
    },
    {
      title: '昵称',
      dataIndex: 'nickname',
      key: 'nickname',
      render: (nickname: string, record: IEndUser) => nickname || record.phone,
    },
    {
      title: '手机号',
      dataIndex: 'phone',
      key: 'phone',
      render: (phone: string) => maskPhone(phone),
    },
    {
      title: '实名认证',
      dataIndex: 'identityStatus',
      key: 'identityStatus',
      render: (status: string) => {
        const statusMap: Record<string, { color: string; text: string }> = {
          unverified: { color: 'default', text: '未认证' },
          pending: { color: 'processing', text: '审核中' },
          verified: { color: 'success', text: '已认证' },
          rejected: { color: 'error', text: '认证失败' },
        };
        const { color, text } = statusMap[status] || statusMap.unverified;
        return <Tag color={color}>{text}</Tag>;
      },
    },
    {
      title: '收藏数',
      dataIndex: 'favoriteCount',
      key: 'favoriteCount',
    },
    {
      title: '预约数',
      dataIndex: 'appointmentCount',
      key: 'appointmentCount',
    },
    {
      title: '注册时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => formatDate(date),
    },
    {
      title: '操作',
      key: 'action',
      render: () => (
        <Space>
          <Button type="link" icon={<EyeOutlined />}>查看</Button>
        </Space>
      ),
    },
  ];

  const loadData = async () => {
    setLoading(true);
    try {
      const result = await getEndUserList({ keyword });
      setData(result.list);
    } catch (error) {
      console.error('加载数据失败', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = () => {
    loadData();
  };

  return (
    <Card
      title="C端用户管理"
      extra={
        <Space>
          <Input
            placeholder="搜索手机号或昵称"
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
            onPressEnter={handleSearch}
            style={{ width: 200 }}
          />
          <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>
            搜索
          </Button>
        </Space>
      }
    >
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        pagination={{ pageSize: 10 }}
      />
    </Card>
  );
};

export default CEndUsers;