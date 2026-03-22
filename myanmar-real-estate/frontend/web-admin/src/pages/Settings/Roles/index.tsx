import React, { useState } from 'react';
import { Card, Table, Button, Modal, Form, Input, Select, Tree, message } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';

const { Option } = Select;

const Roles: React.FC = () => {
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingRole, setEditingRole] = useState<any>(null);
  const [form] = Form.useForm();

  const columns = [
    {
      title: '角色名称',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '角色标识',
      dataIndex: 'code',
      key: 'code',
    },
    {
      title: '描述',
      dataIndex: 'description',
      key: 'description',
    },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: any) => (
        <span>
          <Button
            type="link"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            编辑
          </Button>
          <Button type="link" danger icon={<DeleteOutlined />}>
            删除
          </Button>
        </span>
      ),
    },
  ];

  const data = [
    {
      id: '1',
      name: '超级管理员',
      code: 'super_admin',
      description: '拥有所有权限',
    },
    {
      id: '2',
      name: '运营人员',
      code: 'operator',
      description: '负责日常运营管理',
    },
    {
      id: '3',
      name: '财务人员',
      code: 'finance',
      description: '负责财务结算',
    },
    {
      id: '4',
      name: '客服人员',
      code: 'customer_service',
      description: '负责客户服务',
    },
  ];

  const permissionTreeData = [
    {
      title: '数据大屏',
      key: 'dashboard',
    },
    {
      title: '房源管理',
      key: 'houses',
      children: [
        { title: '房源列表', key: 'houses:list' },
        { title: '房源审核', key: 'houses:audit' },
        { title: '验真管理', key: 'houses:verification' },
      ],
    },
    {
      title: '用户管理',
      key: 'users',
      children: [
        { title: 'C端用户', key: 'users:c-end' },
        { title: '经纪人', key: 'users:agents' },
      ],
    },
    {
      title: '财务结算',
      key: 'finance',
      children: [
        { title: '佣金结算', key: 'finance:commission' },
        { title: '提现审核', key: 'finance:withdrawal' },
      ],
    },
  ];

  const handleAdd = () => {
    setEditingRole(null);
    form.resetFields();
    setIsModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingRole(record);
    form.setFieldsValue(record);
    setIsModalVisible(true);
  };

  const handleModalOk = () => {
    form.validateFields().then((values) => {
      console.log('保存角色:', values);
      message.success(editingRole ? '更新成功' : '创建成功');
      setIsModalVisible(false);
    });
  };

  return (
    <Card
      title="权限管理"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增角色
        </Button>
      }
    >
      <Table columns={columns} dataSource={data} rowKey="id" />

      <Modal
        title={editingRole ? '编辑角色' : '新增角色'}
        open={isModalVisible}
        onOk={handleModalOk}
        onCancel={() => setIsModalVisible(false)}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            label="角色名称"
            name="name"
            rules={[{ required: true, message: '请输入角色名称' }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            label="角色标识"
            name="code"
            rules={[{ required: true, message: '请输入角色标识' }]}
          >
            <Input />
          </Form.Item>

          <Form.Item label="描述" name="description">
            <Input.TextArea rows={3} />
          </Form.Item>

          <Form.Item label="权限配置" name="permissions">
            <Tree
              checkable
              treeData={permissionTreeData}
              defaultExpandAll
            />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  );
};

export default Roles;