import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';

/// Màn hình quản lý sân (admin)
class AdminCourtsPage extends StatefulWidget {
  const AdminCourtsPage({super.key});

  @override
  State<AdminCourtsPage> createState() => _AdminCourtsPageState();
}

class _AdminCourtsPageState extends State<AdminCourtsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadCourts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        title: const Text(
          'Quản lý sân',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoadingCourts) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (vm.allCourts.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có sân nào',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.allCourts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final court = vm.allCourts[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: court.isActive
                      ? AppColors.surface
                      : AppColors.surfaceDim,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    // Thông tin sân
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  court.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Badge loại sân
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  court.typeLabel,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            court.address,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút bật/tắt trạng thái
                    SizedBox(
                      height: 32,
                      child: court.isActive
                          ? OutlinedButton(
                              onPressed: () =>
                                  vm.toggleCourtActive(court),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.warning,
                                side: const BorderSide(
                                    color: AppColors.warning),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4)),
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              child: const Text('Tạm đóng'),
                            )
                          : ElevatedButton(
                              onPressed: () =>
                                  vm.toggleCourtActive(court),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4)),
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              child: const Text('Mở sân'),
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
