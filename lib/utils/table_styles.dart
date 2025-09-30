import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableStyles {
  // 테이블 컨테이너 스타일
  static BoxDecoration tableContainer = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
      ),
    ],
  );
  
  // 헤더 색상
  static Color headerColor = Colors.grey[100]!;
  
  // 숫자 포맷터
  static final numberFormat = NumberFormat('#,###');
  
  // 상태별 색상
  static Color getStatusColor(String status) {
    final statusColors = {
      '확인요청': Colors.orange,
      '주문예정': Colors.blue,
      '도착완료': Colors.green,
      '교내물품활용': Colors.purple,
      '승인': Colors.green,
      '거절': Colors.red,
      '대기': Colors.amber,
      '완료': Colors.green,
      '진행중': Colors.blue,
    };
    return statusColors[status] ?? Colors.grey;
  }
}