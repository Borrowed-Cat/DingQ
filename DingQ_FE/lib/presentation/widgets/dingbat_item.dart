import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/dingbat.dart';

/// 개별 딩벳 아이템 위젯
class DingbatItem extends StatelessWidget {
  final Dingbat dingbat;

  const DingbatItem({
    super.key,
    required this.dingbat,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dingbat.name,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // 딩벳 클릭 시 동작 (향후 확장 가능)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${dingbat.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SVG 이미지
                  Expanded(
                    child: SvgPicture.asset(
                      dingbat.assetPath,
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade700,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  
                  // 딩벳 이름 (작은 텍스트)
                  const SizedBox(height: 4),
                  Text(
                    dingbat.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 