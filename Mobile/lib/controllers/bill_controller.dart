import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';

/// Bill Controller
/// Mengelola state dan logic untuk tagihan
class BillController extends ChangeNotifier {
  List<BillModel> _billList = [];
  BillModel? _selectedBill;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<BillModel> get billList => _billList;
  BillModel? get selectedBill => _selectedBill;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get All Bills
  Future<void> getAllBills({String? tenantId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _billList = await BillService.getAllBills(tenantId: tenantId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Bill Detail
  Future<void> getBillDetail(String billId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _selectedBill = await BillService.getBillById(billId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Unpaid Bills
  List<BillModel> get unpaidBills {
    return _billList.where((bill) => bill.status == 'belum_lunas').toList();
  }
  
  // Get Paid Bills
  List<BillModel> get paidBills {
    return _billList.where((bill) => bill.status == 'lunas').toList();
  }
  
  // Get Overdue Bills
  List<BillModel> get overdueBills {
    return _billList.where((bill) => bill.status == 'terlambat').toList();
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Clear Selected Bill
  void clearSelectedBill() {
    _selectedBill = null;
    notifyListeners();
  }
}
