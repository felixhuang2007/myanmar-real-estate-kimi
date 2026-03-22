import React, { useState } from 'react';
import { Card, Table, Tag, Button, Space, Modal, Form, Input, message } from 'antd';
import { CheckOutlined, CloseOutlined, EyeOutlined } from '@ant-design/icons';
import { getHouseList, auditHouse } from '@/services';
import { IHouse } from '@/types';
import { formatPrice, formatDate } from '@/utils';

const HouseAudit: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<IHouse[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [currentHouse, setCurrentHouse] = useState<IHouse | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const [actionType, setActionType] = useState<'approve' | 'reject' | null>(null);
  const [form] = Form.useForm();

  const columns = [
    {
      title: '房源标题',
      dataIndex: 'title',
      key: 'title',
      ellipsis: true,
    },
    {
      title: '发布人',
      dataIndex: ['agent', 'name'],
      key: 'publisher',
    },
    {
      title: '价格',
      dataIndex: 'price',
      key: 'price',
      render: (price: number, record: IHouse) => formatPrice(price, record.priceUnit),
    },
    {
      title: '发布时间',
      dataIndex: 'publishTime',
      key: 'publishTime',
      render: (date: string) => formatDate(date),
    },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: IHouse) => (
        <Space>
          <Button type="link" icon={<EyeOutlined />} onClick={() => viewDetail(record)}>
            查看
          </Button>
          <Button
            type="primary"
            icon={<CheckOutlined />}
            onClick={() => handleAction(record, 'approve')}
          >
            通过
          </Button>
          <Button
            danger
            icon={<CloseOutlined />}
            onClick={() => handleAction(record, 'reject')}
          >
            拒绝
          </Button>
        </Space>
      ),
    },
  ];

  const loadData = async () => {
    setLoading(true);
    try {
      const result = await getHouseList({ status: 'pending', pageSize: 100 });
      setData(result.list);
    } catch (error) {
      console.error('加载数据失败', error);
    } finally {
      setLoading(false);
    }
  };

  const viewDetail = (house: IHouse) => {
    setCurrentHouse(house);
    setModalVisible(true);
  };

  const handleAction = (house: IHouse, type: 'approve' | 'reject') => {
    setCurrentHouse(house);
    setActionType(type);
    if (type === 'reject') {
      setModalVisible(true);
    } else {
      Modal.confirm({
        title: '确认通过',
        content: `确定通过房源 "${house.title}" 的审核吗？`,
        onOk: () => submitAudit('approved'),
      });
    }
  };

  const submitAudit = async (status: 'approved' | 'rejected') => {
    if (!currentHouse) return;
    
    try {
      await auditHouse(currentHouse.id, status, rejectReason);
      message.success(status === 'approved' ? '审核通过' : '已拒绝');
      setModalVisible(false);
      setRejectReason('');
      loadData();
    } catch (error) {
      message.error('操作失败');
    }
  };

  const handleModalOk = () => {
    if (actionType === 'reject') {
      if (!rejectReason.trim()) {
        message.error('请输入拒绝原因');
        return;
      }
      submitAudit('rejected');
    } else {
      setModalVisible(false);
    }
  };

  return (
    <Card title="房源审核">
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        pagination={{ pageSize: 10 }}
      />

      <Modal
        title={actionType === 'reject' ? '拒绝原因' : '房源详情'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => {
          setModalVisible(false);
          setRejectReason('');
        }}
      >
        {actionType === 'reject' ? (
          <Form form={form}>
            <Form.Item
              label="拒绝原因"
              required
              rules={[{ required: true, message: '请输入拒绝原因' }]}
            >
              <Input.TextArea
                rows={4}
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="请输入拒绝原因，将反馈给发布人"
              />
            </Form.Item>
          </Form>
        ) : (
          currentHouse && (
            <div>
              <p><strong>标题：</strong>{currentHouse.title}</p>
              <p><strong>价格：</strong>{formatPrice(currentHouse.price, currentHouse.priceUnit)}</p>
              <p><strong>面积：</strong>{currentHouse.area}m²</p>
              <p><strong>地址：</strong>{currentHouse.address}</p>
              <p><strong>描述：</strong>{currentHouse.description || '无'}</p>
            </div>
          )
        )}
      </Modal>
    </Card>
  );
};

export default HouseAudit;