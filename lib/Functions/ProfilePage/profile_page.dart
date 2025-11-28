import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Constants/assets.dart';
import '../../Constants/constants.dart';
import '../../Repository/repository.dart';
import '../../Widgets/alert.dart';
import '../SubscriptionPage/Widgets/premium_card.dart';
import 'Widgets/profile_appbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(6.h),
        child: const ProfileAppbar(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Consumer<Repository>(builder: (context, data, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 3.h),
                // Profile Header Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Image with gradient border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Image.asset(
                            Assets.profileImage,
                            color: Colors.white,
                            height: 8.h,
                            width: 8.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Name
                      Text(
                        "${data.user?.f_name} ${data.user?.l_name}",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      // Subtitle
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: data.user?.has_subscription == true
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : const Color(0xFFEF4444).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: data.user?.has_subscription == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          data.user?.has_subscription == true
                              ? "Premium Member"
                              : "Free Member",
                          style: TextStyle(
                            color: data.user?.has_subscription == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // User Details Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Information",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // Email Row
                      _buildInfoRow(
                        context,
                        "Email",
                        data.user?.email ?? "N/A",
                        Icons.email_outlined,
                      ),
                      SizedBox(height: 2.h),
                      // Mobile Row
                      _buildInfoRow(
                        context,
                        "Mobile",
                        "${data.user?.mobile ?? "N/A"}",
                        Icons.phone_outlined,
                      ),
                      SizedBox(height: 2.h),
                      // User ID Row
                      _buildInfoRow(
                        context,
                        "User ID",
                        "#${data.user?.id ?? "N/A"}",
                        Icons.fingerprint,
                      ),
                      SizedBox(height: 2.h),
                      // Join Date Row
                      _buildInfoRow(
                        context,
                        "Member Since",
                        data.user?.expiry_date != null
                            ? _formatDate(data.user!.expiry_date!)
                            : "N/A",
                        Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),

                // SizedBox(height: 3.h),
                //
                // // Account Statistics Card
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 5.w),
                //   padding: EdgeInsets.all(5.w),
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.3),
                //         blurRadius: 15,
                //         offset: const Offset(0, 5),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Icon(
                //             Icons.analytics_outlined,
                //             color: const Color(0xFF6366F1),
                //             size: 6.w,
                //           ),
                //           SizedBox(width: 3.w),
                //           Text(
                //             "Account Statistics",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 14.sp,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 3.h),
                //       Row(
                //         children: [
                //           Expanded(
                //             child: _buildStatCard(
                //               "Profile Views",
                //               "${0}",
                //               // placeholder since profile_views doesn't exist
                //               Icons.visibility,
                //               const Color(0xFF10B981),
                //             ),
                //           ),
                //           SizedBox(width: 3.w),
                //           Expanded(
                //             child: _buildStatCard(
                //               "Total Posts",
                //               "${0}",
                //               // placeholder since total_posts doesn't exist
                //               Icons.post_add,
                //               const Color(0xFF6366F1),
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 2.h),
                //       Row(
                //         children: [
                //           Expanded(
                //             child: _buildStatCard(
                //               "Followers",
                //               "${0}",
                //               // placeholder since followers_count doesn't exist
                //               Icons.people,
                //               const Color(0xFFEF4444),
                //             ),
                //           ),
                //           SizedBox(width: 3.w),
                //           Expanded(
                //             child: _buildStatCard(
                //               "Following",
                //               "${0}",
                //               // placeholder since following_count doesn't exist
                //               Icons.person_add,
                //               const Color(0xFF8B5CF6),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                //
                // SizedBox(height: 3.h),
                //
                // // Account Status Card
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 5.w),
                //   padding: EdgeInsets.all(5.w),
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.3),
                //         blurRadius: 15,
                //         offset: const Offset(0, 5),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Icon(
                //             Icons.security,
                //             color: const Color(0xFF6366F1),
                //             size: 6.w,
                //           ),
                //           SizedBox(width: 3.w),
                //           Text(
                //             "Account Status",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 14.sp,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 3.h),
                //       _buildStatusRow(
                //         "Email Verified",
                //         true, // placeholder since email_verified doesn't exist
                //         Icons.verified_user,
                //       ),
                //       SizedBox(height: 2.h),
                //       _buildStatusRow(
                //         "Phone Verified",
                //         data.user?.mobile != null && data.user!.mobile! > 0,
                //         Icons.phone_android,
                //       ),
                //       SizedBox(height: 2.h),
                //       _buildStatusRow(
                //         "Premium Account",
                //         data.user?.has_subscription ?? false,
                //         Icons.star,
                //       ),
                //       SizedBox(height: 2.h),
                //       _buildStatusRow(
                //         "Account Active",
                //         true, // placeholder since is_active doesn't exist
                //         Icons.power_settings_new,
                //       ),
                //     ],
                //   ),
                // ),
                //
                // SizedBox(height: 3.h),
                //
                // // Quick Actions Card
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 5.w),
                //   padding: EdgeInsets.all(5.w),
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.3),
                //         blurRadius: 15,
                //         offset: const Offset(0, 5),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Icon(
                //             Icons.flash_on,
                //             color: const Color(0xFF6366F1),
                //             size: 6.w,
                //           ),
                //           SizedBox(width: 3.w),
                //           Text(
                //             "Quick Actions",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 14.sp,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 3.h),
                //       Row(
                //         children: [
                //           Expanded(
                //             child: _buildActionButton(
                //               "Edit Profile",
                //               Icons.edit,
                //               const Color(0xFF10B981),
                //               () {
                //                 // Navigation.instance.navigate(Routes.editProfile);
                //                 _showComingSoon("Edit Profile");
                //               },
                //             ),
                //           ),
                //           SizedBox(width: 3.w),
                //           Expanded(
                //             child: _buildActionButton(
                //               "Settings",
                //               Icons.settings,
                //               const Color(0xFF6366F1),
                //               () {
                //                 // Navigation.instance.navigate(Routes.settings);
                //                 _showComingSoon("Settings");
                //               },
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 2.h),
                //       Row(
                //         children: [
                //           Expanded(
                //             child: _buildActionButton(
                //               "Help & Support",
                //               Icons.help_outline,
                //               const Color(0xFFEF4444),
                //               () {
                //                 // Navigation.instance.navigate(Routes.support);
                //                 _showComingSoon("Help & Support");
                //               },
                //             ),
                //           ),
                //           SizedBox(width: 3.w),
                //           Expanded(
                //             child: _buildActionButton(
                //               "Privacy",
                //               Icons.privacy_tip,
                //               const Color(0xFF8B5CF6),
                //               () {
                //                 // Navigation.instance.navigate(Routes.privacy);
                //                 _showComingSoon("Privacy Settings");
                //               },
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                //
                // SizedBox(height: 3.h),
                //
                // // Subscription Section
                // if (!data.user!.has_subscription!)
                //   Container(
                //     margin: EdgeInsets.symmetric(horizontal: 5.w),
                //     padding: EdgeInsets.all(6.w),
                //     decoration: BoxDecoration(
                //       gradient: const LinearGradient(
                //         colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //       ),
                //       borderRadius: BorderRadius.circular(20),
                //       boxShadow: [
                //         BoxShadow(
                //           color: const Color(0xFF6366F1).withOpacity(0.3),
                //           blurRadius: 20,
                //           offset: const Offset(0, 8),
                //         ),
                //       ],
                //     ),
                //     child: Column(
                //       children: [
                //         Lottie.asset(
                //           "assets/animations/sad.json",
                //           height: 10.h,
                //           width: 10.h,
                //         ),
                //         SizedBox(height: 2.h),
                //         Text(
                //           "Unlock Premium Features",
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 16.sp,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         SizedBox(height: 1.h),
                //         Text(
                //           "Subscribe now to get access to all premium content and features",
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             color: Colors.white70,
                //             fontSize: 11.sp,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //         SizedBox(height: 3.h),
                //         Container(
                //           width: double.infinity,
                //           decoration: BoxDecoration(
                //             gradient: const LinearGradient(
                //               colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                //             ),
                //             borderRadius: BorderRadius.circular(15),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: const Color(0xFF6366F1).withOpacity(0.4),
                //                 blurRadius: 10,
                //                 offset: const Offset(0, 4),
                //               ),
                //             ],
                //           ),
                //           child: ElevatedButton(
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: Colors.transparent,
                //               shadowColor: Colors.transparent,
                //               padding: EdgeInsets.symmetric(vertical: 2.h),
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15),
                //               ),
                //             ),
                //             onPressed: () {
                //               Navigation.instance
                //                   .navigate(Routes.subscriptionScreen);
                //             },
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Icon(
                //                   Icons.rocket_launch,
                //                   color: Colors.white,
                //                   size: 5.w,
                //                 ),
                //                 SizedBox(width: 2.w),
                //                 Text(
                //                   "Subscribe Now",
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 14.sp,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                //
                // SizedBox(height: 3.h),

                // if (data.user?.last_sub != null)
                //   Container(
                //     margin: EdgeInsets.symmetric(horizontal: 5.w),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Padding(
                //           padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                //           child: Text(
                //             "Current Subscription",
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .labelLarge
                //                 ?.copyWith(
                //                   color: Colors.white,
                //                   fontSize: 15.sp,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //           ),
                //         ),
                //         const PremiumCard(),
                //       ],
                //     ),
                //   ),
                //
                // SizedBox(height: 5.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 5.w,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, bool status, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          style: TextStyle(
            color: status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          status ? "Active" : "Inactive",
          style: TextStyle(
            color: status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, Function onPressed) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          onPressed();
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return date;
    }
  }

  void _showComingSoon(String feature) {
    AlertX.instance.showAlert(
      title: "Coming Soon",
      msg: "$feature feature will be available in the next update!",
      positiveButtonText: "OK",
      positiveButtonPressed: () {
        Navigation.instance.goBack();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (Storage.instance.isLoggedIn ?? false) {
        fetchProfile(context);
      }
    });
  }

  void fetchProfile(BuildContext context) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getProfile();
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
      debugPrint("User: ${response.user?.last_sub}");
    } else { 
      Navigation.instance.goBack();
      showError(response.message ?? "Something went wrong");
    }
  }

  void showError(String msg) {
    AlertX.instance.showAlert(
        title: "Error",
        msg: msg,
        positiveButtonText: "Done",
        positiveButtonPressed: () {
          Navigation.instance.goBack();
        });
  }
}
