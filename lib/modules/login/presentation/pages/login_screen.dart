import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Dark header ──────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.dark,
              padding: EdgeInsets.fromLTRB(24, topPad + 24, 24, 28),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        color: AppColors.purple.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    right: 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        color: AppColors.purple.withOpacity(0.1),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo/outrace_icon.png',
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Outrace',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Welcome to Outrace',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        controller.activeTab.value == 0
                            ? 'Sign in to manage your fleet'
                            : 'Create your account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.5),
                        ),
                      )),

                      const SizedBox(height: 20),

                      // Login / Register tab
                      Obx(() => Container(
                        height: 42,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _TabBtn(
                              label: 'Sign In',
                              isActive: controller.activeTab.value == 0,
                              onTap: () => controller.activeTab.value = 0,
                            ),
                            _TabBtn(
                              label: 'Register',
                              isActive: controller.activeTab.value == 1,
                              onTap: () => controller.activeTab.value = 1,
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form body ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(() => controller.activeTab.value == 0
                  ? _LoginForm(controller: controller)
                  : _RegisterForm(controller: controller)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab button ────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    // ignore: deprecated_member_use
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Login form ────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final LoginController controller;
  const _LoginForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Method toggle ──────────────────────
Obx(() => Row(
  children: [
    _MethodBtn(
      label: 'Via OTP',
      icon: Icons.mark_email_unread_outlined,
      isActive: controller.loginMethod.value == 'otp',
      onTap: () => controller.loginMethod.value = 'otp',
    ),
    const SizedBox(width: 10),
    _MethodBtn(
      label: 'Via Password',
      icon: Icons.lock_outline_rounded,
      isActive: controller.loginMethod.value == 'password',
      onTap: () => controller.loginMethod.value = 'password',
    ),
  ],
)),
        const SizedBox(height: 20),

        // Email field
        Text(
          'Email Address',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.loginEmailError.value.isNotEmpty
                  ? AppColors.red
                  : controller.isFocused.value
                      ? AppColors.purple
                      : AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller.emailCtrl,
            focusNode: controller.focusNode,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.textTertiary,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
            ),
          ),
        )),
        Obx(() => controller.loginEmailError.value.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  controller.loginEmailError.value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox.shrink()),

        // Password field — only show if password method
        Obx(() => controller.loginMethod.value == 'password'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Text(
                    'Password',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.loginPassError.value.isNotEmpty
                            ? AppColors.red
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: controller.passCtrl,
                      obscureText: !controller.showLoginPass.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              controller.showLoginPass.toggle(),
                          child: Icon(
                            controller.showLoginPass.value
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.textTertiary,
                            size: 18,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                      ),
                    ),
                  )),
                  Obx(() => controller.loginPassError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            controller.loginPassError.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              )
            : const SizedBox.shrink()),

        const SizedBox(height: 24),

        // Submit button
        Obx(() => GestureDetector(
          onTap: controller.isLoading.value
              ? null
              : () {
                  if (controller.loginMethod.value == 'otp') {
                    controller.sendOtp(context);
                  } else {
                    controller.loginWithPassword(context);
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      controller.loginMethod.value == 'otp'
                          ? 'Send OTP'
                          : 'Login',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        )),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_rounded,
                color: AppColors.green, size: 14),
            const SizedBox(width: 6),
            Text(
              'Secured with end-to-end encryption',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Method toggle button ──────────────────────────────────
class _MethodBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MethodBtn({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 46,
          decoration: BoxDecoration(
            color: isActive ? AppColors.purple : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.purple : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: AppColors.purple.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isActive
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.bg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ── Register form ─────────────────────────────────────────
class _RegisterForm extends StatelessWidget {
  final LoginController controller;
  const _RegisterForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => _InputField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: controller.nameCtrl,
          icon: Icons.person_outline_rounded,
          inputType: TextInputType.name,
          maxLength: 20,
          errorText: controller.regNameError.value,
        )),
        const SizedBox(height: 14),
        Obx(() => _InputField(
          label: 'Email Address',
          hint: 'Enter your email',
          controller: controller.regEmailCtrl,
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
          errorText: controller.regEmailError.value,
        )),
        const SizedBox(height: 14),
        Obx(() => _InputField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          controller: controller.phoneCtrl,
          icon: Icons.phone_outlined,
          inputType: TextInputType.phone,
          maxLength: 10,
          errorText: controller.regPhoneError.value,
        )),
        const SizedBox(height: 14),

        Text(
          'Password',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.regPassError.value.isNotEmpty
                  ? AppColors.red
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller.passwordCtrl,
            obscureText: !controller.showPassword.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textTertiary,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () => controller.showPassword.toggle(),
                child: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
            ),
          ),
        )),
        Obx(() => controller.regPassError.value.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  controller.regPassError.value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox.shrink()),

        const SizedBox(height: 24),

        Obx(() => GestureDetector(
          onTap: controller.isRegLoading.value
              ? null
              : () => controller.register(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: controller.isRegLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Create Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        )),

        const SizedBox(height: 16),

        Center(
          child: Text(
            'By registering you agree to our Terms & Privacy Policy',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Reusable input field ──────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType inputType;
  final int? maxLength;
  final String? errorText;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.inputType = TextInputType.text,
    this.maxLength,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (errorText?.isNotEmpty ?? false)
                  ? AppColors.red
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            maxLength: maxLength,
            inputFormatters: (maxLength != null &&
                    (inputType == TextInputType.phone ||
                        inputType == TextInputType.number))
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 18),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
            ),
          ),
        ),
        if (errorText?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}