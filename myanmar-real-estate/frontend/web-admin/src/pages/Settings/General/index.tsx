import React from 'react';
import { Card, Form, Input, Button, message } from 'antd';

const General: React.FC = () => {
  const [form] = Form.useForm();

  const onFinish = (values: any) => {
    console.log('提交的配置:', values);
    message.success('保存成功');
  };

  return (
    <Card title="基础配置">
      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        initialValues={{
          siteName: 'Myanmar Home',
          contactPhone: '+95 9 XXX XXX XXX',
          icp: '',
        }}
      >
        <Form.Item
          label="站点名称"
          name="siteName"
          rules={[{ required: true, message: '请输入站点名称' }]}
        >
          <Input />
        </Form.Item>

        <Form.Item
          label="联系电话"
          name="contactPhone"
          rules={[{ required: true, message: '请输入联系电话' }]}
        >
          <Input />
        </Form.Item>

        <Form.Item label="备案号" name="icp">
          <Input placeholder="如有需要请输入备案号" />
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit">
            保存配置
          </Button>
        </Form.Item>
      </Form>
    </Card>
  );
};

export default General;