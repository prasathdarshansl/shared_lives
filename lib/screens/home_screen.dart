// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// local screens (use package import to avoid relative-path issues)
import 'package:shared_lives/screens/donor_webview.dart';
import 'package:shared_lives/screens/hospital_map_screen.dart';
import 'package:shared_lives/screens/login_screen.dart';
import 'package:shared_lives/screens/info_page.dart';

import 'package:shared_lives/theme/app_colors.dart';
import 'package:shared_lives/widgets/category_card.dart';
import 'package:shared_lives/widgets/support_list_item.dart';
import 'package:shared_lives/widgets/course_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  int _bottomIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // If you prefer opening in external browser instead of WebView, use this.
  Future<void> _openDonorExternal() async {
    final uri = Uri.parse('https://notto.abdm.gov.in/register?utm_source=chatgpt.com');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open donor registration link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? "User";
    final email = user?.email ?? "No email";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared Lives"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      backgroundColor: AppColors.background,
      body: _bottomIndex == 0
          ? _buildHomeContent(displayName, email)
          : _buildSupportCoursesContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _bottomIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Support',
          ),
        ],
      ),
    );
  }

  // ---------- HOME TAB ----------

  Widget _buildHomeContent(String displayName, String email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $displayName",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Helpline card (tappable)
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _openHelplineSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent,
                      size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Helpline - 24/7",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "In 8 Languages",
                        style:
                            TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "1800 103 7100",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ====== Become a Donor Card ======
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              // open DonorWebView (in-app)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonorWebView()),
              );
              // Or if you prefer external browser, call: _openDonorExternal();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism,
                      size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Become an Organ Donor",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, color: Colors.white70),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              CategoryCard(
                icon: Icons.remove_red_eye,
                label: "Eye Banks",
                onTap: () {
                  _openCategoryPage(
                    title: "Eye Banks",
                    body:
                        "List of eye banks and information about corneal donation.",
                  );
                },
              ),
              CategoryCard(
                icon: Icons.healing,
                label: "Skin Banks",
                onTap: () {
                  _openCategoryPage(
                    title: "Skin Banks",
                    body:
                        "Information about skin donation and burn treatment support.",
                  );
                },
              ),
              CategoryCard(
                icon: Icons.accessibility_new,
                label: "Body Donations",
                onTap: () {
                  _openCategoryPage(
                    title: "Body Donations",
                    body:
                        "Guidelines and procedures for whole-body donation.",
                  );
                },
              ),
              CategoryCard(
                icon: Icons.apartment,
                label: "Organ Transplant Hospital",
                onTap: () {
                  // OPEN the Hospital Map screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HospitalMapScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- SUPPORT / COURSES TAB ----------

  Widget _buildSupportCoursesContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.primaryBlue,
              tabs: const [
                Tab(text: "Support"),
                Tab(text: "Courses"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSupportList(),
              _buildCoursesList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportList() {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        SupportListItem(
          icon: Icons.campaign,
          title: "Help Us Conduct an Awareness Program",
          subtitle: "Organise an awareness session in your community.",
          onTap: () => _openInfo(
            title: "Awareness Program",
            body:
                "Details on how to request an awareness program in schools, colleges, and workplaces.",
          ),
        ),
        SupportListItem(
          icon: Icons.emoji_people,
          title: "Become an Organ Donation Ambassador",
          subtitle: "Register as an ambassador and spread awareness.",
          onTap: () => _openInfo(
            title: "Organ Donation Ambassador",
            body:
                "Eligibility, responsibilities and registration process for ambassadors.",
          ),
        ),
        SupportListItem(
          icon: Icons.card_membership,
          title: "Become a Life Member",
          subtitle: "Support us through annual or lifetime membership.",
          onTap: () => _openInfo(
            title: "Life Membership",
            body:
                "Benefits of membership and how your contribution is used.",
          ),
        ),
        SupportListItem(
          icon: Icons.work,
          title: "Become an Intern",
          subtitle: "Volunteer or intern with our foundation.",
          onTap: () => _openInfo(
            title: "Internship",
            body:
                "Internship roles, duration, and application instructions.",
          ),
        ),
        SupportListItem(
          icon: Icons.subscriptions,
          title: "Subscribe to our Newsletter",
          subtitle: "Receive periodic updates and donor stories.",
          onTap: () => _openInfo(
            title: "Newsletter Subscription",
            body:
                "How to subscribe/unsubscribe and what type of content we send.",
          ),
        ),
        SupportListItem(
          icon: Icons.volunteer_activism,
          title: "Help Us Fundraise",
          subtitle: "Support our campaigns through fundraising.",
          onTap: () => _openInfo(
            title: "Fundraising",
            body:
                "Ideas, guidelines and legal notes for fundraising activities.",
          ),
        ),
        SupportListItem(
          icon: Icons.handshake,
          title: "Partner with Us",
          subtitle: "Collaborations with hospitals, NGOs, and corporates.",
          onTap: () => _openInfo(
            title: "Partnerships",
            body:
                "Partnership models and how to reach our collaboration team.",
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: const [
        CourseListItem(
          title: "Transplant Coordination Professional Certificate",
          subtitle: "Structured course for transplant coordinators.",
        ),
        CourseListItem(
          title:
              "Post Graduate Diploma in Transplant Coordination & Grief Counselling",
          subtitle: "Advanced training for professionals.",
        ),
        CourseListItem(
          title: "Family Counselling and Conversations on Organ Donation",
          subtitle: "Improve communication with donor families.",
        ),
        CourseListItem(
          title: "Legal Aspects of Organ Donation & Transplantation",
          subtitle: "Acts, rules and ethics explained.",
        ),
        CourseListItem(
          title:
              "Brain Stem Death Identification, Certification and Donor Optimisation",
          subtitle: "Clinical and procedural training.",
        ),
        CourseListItem(
          title:
              "Essential Course on Organ Donation for Medical Professionals",
          subtitle: "Introductory course for healthcare staff.",
        ),
        CourseListItem(
          title:
              "Saving Lives – A Course for Paramedical Professionals & Students",
          subtitle: "Focused on nurses and paramedical teams.",
        ),
      ],
    );
  }

  // ---------- DRAWER ----------

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.primaryBlue,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Shared Lives",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Organ Donation & Awareness",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _drawerItem(
                    icon: Icons.phone,
                    label: "Contact Us",
                    onTap: _openContactSheet,
                  ),
                  _drawerItem(
                    icon: Icons.info_outline,
                    label: "About Us",
                    onTap: () => _openInfo(
                      title: "About Us",
                      body: '''
Shared Lives is a compassionate initiative dedicated to promoting organ and tissue donation awareness across communities. We believe that one decision can save multiple lives, and our mission is to bridge the gap between donors and those in need. Through education, counselling, and collaboration with hospitals and volunteers, we strive to create a culture of empathy and responsibility. Our team works tirelessly to ensure that every potential donor’s wish is honoured with dignity and transparency. Shared Lives stands as a beacon of hope, inspiring people to contribute selflessly and make a lasting difference in the lives of others.
''',
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.help_outline,
                    label: "FAQ",
                    onTap: () => _openInfo(
                      title: "FAQ",
                      body: '''
Who can be a donor?
Anyone, regardless of age, race, ethnicity, or health condition, is considered a potential donor. Doctors will determine at the time of death which organs and tissues are suitable for donation.

How can I register to be an organ donor?
You can register through your state's motor vehicle agency, a state donor registry, or an online portal of a recognized organ donation organization. Registering your wishes is an important first step, but it is also crucial to discuss your decision with your family.

Does it cost anything for the donor's family?
No, there is no cost to the donor's family or estate for organ and tissue donation.

Can organ donation affect the body for funerals?
No, organ removal is a sterile surgical procedure. An open-casket funeral is possible for donors, as the body is intact afterward.

What if I have a pre-existing medical condition?
You may still be eligible to donate, as doctors will assess which organs are viable at the time of death. Very few conditions, such as active cancer, will prevent donation.

Do I need to tell my family if I've registered?
Yes, it is highly recommended. Knowing your wishes makes it easier for your family to give consent during a traumatic time, which helps ensure your decision is carried out.

How are donated organs matched with recipients?
Organs are matched to recipients on a national waiting list based on factors like blood type, tissue type, the recipient's medical urgency, and time on the waiting list.
''',
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.feedback_outlined,
                    label: "Feedback",
                    onTap: () => _openInfo(
                      title: "Feedback",
                      body: '''
You can share your feedback with us by filling out the online form below:

https://docs.google.com/forms/d/e/1FAIpQLSdpOFeT0JACeLocIB2wmisv36IoWvCwnU8sA23VufAgTN_NzQ/viewform?usp=dialog

Your suggestions help us improve Shared Lives and support more people in need.
''',
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.star_rate_outlined,
                    label: "Rate Us",
                    onTap: () => _openInfo(
                      title: "Rate Us",
                      body:
                          "On mobile stores, redirect users to the app rating page.",
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.share_outlined,
                    label: "Share",
                    onTap: () => _openInfo(
                      title: "Share App",
                      body:
                          "Use a share plugin later to let users share the app link.",
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.public,
                    label: "Our Website",
                    onTap: () => _openInfo(
                      title: "Website",
                      body:
                          "Open your organisation website using url_launcher here.",
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Follow Us",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 16),
              child: Row(
                children: const [
                  Icon(Icons.facebook, size: 28),
                  SizedBox(width: 10),
                  Icon(Icons.linked_camera, size: 28),
                  SizedBox(width: 10),
                  Icon(Icons.play_circle_fill, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(label),
      onTap: onTap,
    );
  }

  // ---------- NAV HELPERS ----------

  void _openCategoryPage({required String title, required String body}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InfoPage(title: title, body: body),
      ),
    );
  }

  void _openInfo({required String title, required String body}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openHelplineSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "24/7 Organ Donation Helpline",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Call us anytime for organ donation queries, counselling and support.",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              ListTile(
                dense: true,
                leading: const Icon(Icons.call),
                title: const Text("Call 1800 103 7100"),
                subtitle:
                    const Text("Toll-free • Multi-language support"),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Here you will trigger a phone call: tel:18001037100"),
                    ),
                  );
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.message_outlined),
                title: const Text("Request a call back"),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Open call-back form UI here."),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Reach Shared Lives through phone, email or office visit.",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              ListTile(
                dense: true,
                leading: const Icon(Icons.call),
                title: const Text("Helpline"),
                subtitle: const Text("1800 103 7100 (24/7)"),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Trigger tel:18001037100 here."),
                    ),
                  );
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.email_outlined),
                title: const Text("Email"),
                subtitle: const Text("support@sharedlives.org"),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Trigger mailto:support@sharedlives.org here."),
                    ),
                  );
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.location_on_outlined),
                title: const Text("Head Office"),
                subtitle: const Text(
                    "Shared Lives Foundation,\nChennai, Tamil Nadu, India"),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Open maps location here."),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
