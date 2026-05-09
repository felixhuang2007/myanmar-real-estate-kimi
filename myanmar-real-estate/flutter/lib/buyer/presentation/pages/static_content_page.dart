/**
 * C端 - 通用静态内容页面
 * 用于展示：购房指南、帮助与客服、关于我们、用户协议、隐私政策
 */
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StaticContentPage extends StatelessWidget {
  final String title;
  final String contentType;

  const StaticContentPage({
    super.key,
    required this.title,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getContent(),
            style: TextStyle(
              fontSize: 14,
              height: 1.8,
              color: AppColors.gray700,
            ),
          ),
        ),
      ),
    );
  }

  String _getContent() {
    switch (contentType) {
      case 'buying-guide':
        return '''Welcome to Myanmar Home Buying Guide

1. Determine Your Budget
Before starting your property search, assess your financial situation. Consider down payment, loan eligibility, and monthly mortgage payments.

2. Choose the Right Location
Yangon offers diverse neighborhoods:
- Bahan: Upscale residential area
- Tamwe: Central location with good connectivity
- Yankin: Family-friendly community
- Hlaing: Affordable options with growth potential

3. Property Types
- Apartments: Ideal for urban living
- Villas: Spacious family homes
- Townhouses: Balance of space and community
- Land: Build your dream home

4. Verify Property Documents
Always verify ownership documents, land title, and ensure the property is free from disputes.

5. Work with Licensed Agents
Our platform connects you with verified agents who can guide you through the entire process.

6. Schedule Viewings
Use our app to book property viewings at your convenience.

7. Negotiate and Close
Review terms carefully and work with your agent to negotiate the best deal.''';

      case 'help-support':
        return '''Help & Support

We're here to help you with any questions or issues.

Frequently Asked Questions:

Q: How do I create an account?
A: Simply use your phone number to register and verify with the SMS code.

Q: How do I schedule a property viewing?
A: Go to any property detail page and tap "Schedule Viewing" to book an appointment.

Q: How do I contact an agent?
A: Each listing shows the agent\'s contact information. You can call or message directly.

Q: Is my personal information secure?
A: Yes, we use industry-standard encryption to protect your data.

Q: How do I report a listing?
A: Use the report button on any listing detail page.

Contact Us:
- Hotline: +95 9 123 456 789
- Email: support@myanmarhome.com
- Working Hours: 9:00 AM - 6:00 PM (Mon-Sat)

For urgent matters, please call our hotline directly.''';      case 'about-us':
        return '''About Myanmar Home

Myanmar Home is the leading real estate platform in Myanmar, connecting buyers, sellers, and agents in a transparent and efficient marketplace.

Our Mission:
To make property transactions simple, transparent, and accessible for everyone in Myanmar.

What We Offer:
- Comprehensive property listings across Myanmar
- Verified agents and property information
- Secure transaction support
- Mortgage calculator and financial tools
- Multi-language support (English, Myanmar, Chinese)

Why Choose Us:
- Largest property database in Myanmar
- Verified listings with real photos
- Professional agent network
- User-friendly mobile experience
- Secure and reliable platform

Founded in 2024, Myanmar Home has quickly become the trusted platform for thousands of property seekers and real estate professionals across the country.''';      case 'terms':
        return '''User Agreement

Please read these terms carefully before using Myanmar Home.

1. Acceptance of Terms
By using our app, you agree to be bound by these terms and conditions.

2. User Accounts
- You must provide accurate information when registering
- You are responsible for maintaining account security
- One person may only maintain one active account

3. Property Listings
- All listing information should be accurate and truthful
- We reserve the right to remove misleading listings
- Users can report inaccurate information

4. Prohibited Activities
Users may not:
- Post false or misleading information
- Harass other users or agents
- Use the platform for illegal purposes
- Attempt to circumvent our security measures

5. Intellectual Property
All content and materials on the platform are protected by copyright and other intellectual property laws.

6. Limitation of Liability
We are not liable for any disputes between users and agents. Transactions should be conducted with due diligence.

7. Termination
We reserve the right to terminate accounts that violate these terms.

8. Changes to Terms
We may update these terms from time to time. Continued use constitutes acceptance of changes.''';      case 'privacy':
        return '''Privacy Policy

Myanmar Home is committed to protecting your privacy.

1. Information We Collect
- Account information (phone number, profile)
- Usage data and preferences
- Device information
- Location data (with permission)

2. How We Use Your Information
- To provide and improve our services
- To verify your identity
- To personalize your experience
- To communicate with you about your account

3. Information Sharing
We do not sell your personal information. We may share data with:
- Verified real estate agents (only when you request contact)
- Service providers who assist our operations
- Legal authorities when required by law

4. Data Security
We implement appropriate security measures to protect your data, including encryption and secure storage.

5. Your Rights
You have the right to:
- Access your personal data
- Request correction of inaccurate data
- Request deletion of your data
- Opt out of marketing communications

6. Cookies and Tracking
We use cookies and similar technologies to improve user experience and analyze usage patterns.

7. Changes to Privacy Policy
We may update this policy periodically. We will notify you of significant changes.

8. Contact Us
If you have questions about this privacy policy, please contact us at privacy@myanmarhome.com.''';      default:
        return 'Content coming soon...';
    }
  }
}
