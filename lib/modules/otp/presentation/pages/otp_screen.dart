import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../controller/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Dark header ───────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.dark,
              height: size.height * 0.30,
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        color: AppColors.purple.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        color: AppColors.purple.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPad + 16,
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'OTP sent to',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.purpleLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Verify your\naccount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, bottomPad + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Timer
                  Obx(() => RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Enter the 4-digit code. Expires in '),
                        TextSpan(
                          text: controller.timerText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 28),

                  Text(
                    'ENTER OTP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // OTP boxes
                  GetBuilder<OtpController>(
                    builder: (_) => Row(
                      children: List.generate(4, (i) {
                        final isFilled = controller.ctrls[i].text.isNotEmpty;
                        final isFocused = controller.nodes[i].hasFocus;
                        final hasError = controller.errorText.value.isNotEmpty;

                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 12 : 0),
                            height: 62,
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? AppColors.purpleSoft
                                  : AppColors.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: hasError 
                                    ? AppColors.red 
                                    : (isFilled || isFocused) 
                                        ? AppColors.purple 
                                        : AppColors.border,
                                width: isFilled || isFocused || hasError ? 2 : 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: controller.ctrls[i],
                              focusNode: controller.nodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: hasError ? AppColors.red : AppColors.purple,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              onChanged: (v) {
                                controller.onDigitChanged(i, v);
                                // Auto submit when all 4 digits entered
                                if (controller.otp.value.length == 4) {
                                  FocusScope.of(context).unfocus();
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    // ignore: use_build_context_synchronously
                                    () => controller.verify(context, phone),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Obx(() => controller.errorText.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.red, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  controller.errorText.value,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 16),

                  // Resend row
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.canResend.value
                            ? () => controller.resendOtp(context, phone)
                            : null,
                        child: Text(
                          controller.canResend.value
                              ? 'Resend OTP'
                              : 'Resend in ${controller.seconds.value}s',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: controller.canResend.value
                                ? AppColors.purple
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 32),

                  // Verify button — shows loading when auto submitting
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.verify(context, phone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.otp.value.length == 4
                            ? AppColors.purple
                            : AppColors.dark2,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Verify & Continue',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )),
                  const SizedBox(height: 12),

                  // Change email
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Change Email',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Security badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: AppColors.green.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '256-bit secure OTP verification active',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A6B35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}