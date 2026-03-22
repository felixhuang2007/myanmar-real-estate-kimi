import React, { useState, useRef } from 'react';
import { Form, Input, Button, Card, message, Space } from 'antd';
import { PhoneOutlined, SafetyOutlined } from '@ant-design/icons';
import { useNavigate } from 'umi';
import { useAuthStore } from '@/stores';
import { adminLogin, sendVerificationCode } from '@/services';
import styles from './index.less';

const Login: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [sendingCode, setSendingCode] = useState(false);
  const [countdown, setCountdown] = useState(0);
  const [form] = Form.useForm();
  const navigate = useNavigate();
  const { setToken, setUser } = useAuthStore();
  const countdownRef = useRef<NodeJS.Timeout | null>(null);

  const onFinish = async (values: { phone: string; code: string }) => {
    setLoading(true);
    try {
      const result = await adminLogin(values.phone, values.code);
      setToken(result.token);
      setUser(result.user);
      localStorage.setItem('token', result.token);
      message.success('登录成功');
      navigate('/');
    } catch (error: any) {
      message.error(error.message || '登录失败');
    } finally {
      setLoading(false);
    }
  };

  const handleSendCode = async () => {
    const phone = form.getFieldValue('phone');
    if (!phone) {
      message.error('请输入手机号');
      return;
    }

    // 简单手机号验证
    if (!/^\+?[0-9]{10,12}$/.test(phone)) {
      message.error('请输入正确的手机号');
      return;
    }

    setSendingCode(true);
    try {
      const result = await sendVerificationCode(phone);
      message.success('验证码已发送');

      // 开发环境自动填充验证码
      if (result.code) {
        form.setFieldValue('code', result.code);
        message.success(`开发模式：验证码已自动填充 ${result.code}`);
      }

      // 开始倒计时
      setCountdown(60);
      countdownRef.current = setInterval(() => {
        setCountdown((prev) => {
          if (prev <= 1) {
            if (countdownRef.current) {
              clearInterval(countdownRef.current);
            }
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } catch (error: any) {
      message.error(error.message || '发送验证码失败');
    } finally {
      setSendingCode(false);
    }
  };

  return (
    <div className={styles.loginContainer}>
      <Card className={styles.loginCard} title="Myanmar Home 管理后台">
        <Form
          form={form}
          name="login"
          onFinish={onFinish}
          autoComplete="off"
          size="large"
        >
          <Form.Item
            name="phone"
            rules={[
              { required: true, message: '请输入手机号' },
              { pattern: /^\+?[0-9]{10,12}$/, message: '请输入正确的手机号' }
            ]}
          >
            <Input
              prefix={<PhoneOutlined />}
              placeholder="手机号 (+95111111111)"
            />
          </Form.Item>

          <Form.Item
            name="code"
            rules={[{ required: true, message: '请输入验证码' }]}
          >
            <Space.Compact style={{ width: '100%' }}>
              <Input
                prefix={<SafetyOutlined />}
                placeholder="验证码"
                style={{ width: '60%' }}
              />
              <Button
                type="default"
                onClick={handleSendCode}
                loading={sendingCode}
                disabled={countdown > 0}
                style={{ width: '40%' }}
              >
                {countdown > 0 ? `${countdown}s` : '获取验证码'}
              </Button>
            </Space.Compact>
          </Form.Item>

          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              loading={loading}
              block
            >
              登录
            </Button>
          </Form.Item>

          <div style={{ textAlign: 'center', color: '#999', fontSize: '12px' }}>
            测试账号: +95111111111，点击"获取验证码"即可自动填充
          </div>
        </Form>
      </Card>
    </div>
  );
};

export default Login;