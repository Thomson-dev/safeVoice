import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/report.dart';
import '../models/message.dart';
import '../models/trusted_contact.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  late GetStorage _storage;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> init() async {
    _storage = GetStorage();
  }

  // Reports
  Future<void> saveReport(Report report) async {
    final reports = getReports();
    reports.add(report);
    await _storage.write('reports', reports.map((r) => r.toJson()).toList());
  }

  List<Report> getReports() {
    final data = _storage.read<List>('reports') ?? [];
    return data.map((item) => Report.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Future<void> updateReport(Report report) async {
    final reports = getReports();
    final index = reports.indexWhere((r) => r.id == report.id);
    if (index >= 0) {
      reports[index] = report;
      await _storage.write('reports', reports.map((r) => r.toJson()).toList());
    }
  }

  Report? getReportByTrackingCode(String trackingCode) {
    final reports = getReports();
    try {
      return reports.firstWhere((r) => r.trackingCode == trackingCode);
    } catch (e) {
      return null;
    }
  }

  // Messages
  Future<void> saveMessage(Message message) async {
    final messages = getMessages();
    messages.add(message);
    await _storage.write('messages', messages.map((m) => m.toJson()).toList());
  }

  List<Message> getMessages() {
    final data = _storage.read<List>('messages') ?? [];
    return data.map((item) => Message.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  List<Message> getMessagesForTrackingCode(String trackingCode) {
    final messages = getMessages();
    return messages.where((m) => m.trackingCode == trackingCode).toList();
  }

  // Trusted Contacts
  Future<void> saveTrustedContact(TrustedContact contact) async {
    final contacts = getTrustedContacts();
    contacts.add(contact);
    await _storage.write('trusted_contacts', contacts.map((c) => c.toJson()).toList());
  }

  List<TrustedContact> getTrustedContacts() {
    final data = _storage.read<List>('trusted_contacts') ?? [];
    return data.map((item) => TrustedContact.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Future<void> updateTrustedContact(TrustedContact contact) async {
    final contacts = getTrustedContacts();
    final index = contacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      contacts[index] = contact;
      await _storage.write('trusted_contacts', contacts.map((c) => c.toJson()).toList());
    }
  }

  Future<void> deleteTrustedContact(String contactId) async {
    final contacts = getTrustedContacts();
    contacts.removeWhere((c) => c.id == contactId);
    await _storage.write('trusted_contacts', contacts.map((c) => c.toJson()).toList());
  }

  // User Data
  Future<void> saveUserRole(String role) async {
    await _storage.write('user_role', role);
  }

  String? getUserRole() {
    return _storage.read<String>('user_role');
  }

  Future<void> saveCounselorEmail(String email) async {
    await _storage.write('counselor_email', email);
  }

  String? getCounselorEmail() {
    return _storage.read<String>('counselor_email');
  }

  Future<void> clear() async {
    await _storage.erase();
  }
}
