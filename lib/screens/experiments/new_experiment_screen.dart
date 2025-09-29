// lib/screens/experiments/new_experiment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExperimentScreen extends StatefulWidget {
  const NewExperimentScreen({super.key});

  @override
  State<NewExperimentScreen> createState() => _NewExperimentScreenState();
}

class _NewExperimentScreenState extends State<NewExperimentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _researcherController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'pending';
  List<String> _selectedEquipment = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 실험 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '실험 제목',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '실험 제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 실험 설명
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '실험 설명',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '실험 설명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 담당 연구원
              TextFormField(
                controller: _researcherController,
                decoration: const InputDecoration(
                  labelText: '담당 연구원',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '담당 연구원을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 시작 날짜
              ListTile(
                title: const Text('시작 날짜'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                leading: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // 상태 선택
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: '실험 상태',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('대기')),
                  DropdownMenuItem(value: 'in_progress', child: Text('진행 중')),
                  DropdownMenuItem(value: 'completed', child: Text('완료')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 필요 장비 선택
              const Text(
                '필요 장비',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  '현미경',
                  '원심분리기',
                  '인큐베이터',
                  'pH 미터',
                  '분광광도계',
                ].map((equipment) {
                  final isSelected = _selectedEquipment.contains(equipment);
                  return FilterChip(
                    label: Text(equipment),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEquipment.add(equipment);
                        } else {
                          _selectedEquipment.remove(equipment);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 실험 저장 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('실험이 등록되었습니다')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    '실험 등록',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _researcherController.dispose();
    super.dispose();
  }
}