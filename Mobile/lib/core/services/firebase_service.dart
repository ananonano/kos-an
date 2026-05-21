import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

/// Firebase Service
/// Mengelola operasi Firebase (Firestore, Storage, Auth)
class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // ==================== FIRESTORE ====================
  
  // Get Collection Reference
  static CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }
  
  // Add Document
  static Future<String> addDocument(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(collectionName).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan data: ${e.toString()}');
    }
  }
  
  // Update Document
  static Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .update(data);
    } catch (e) {
      throw Exception('Gagal mengupdate data: ${e.toString()}');
    }
  }
  
  // Delete Document
  static Future<void> deleteDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .delete();
    } catch (e) {
      throw Exception('Gagal menghapus data: ${e.toString()}');
    }
  }
  
  // Get Document
  static Future<Map<String, dynamic>?> getDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();
      
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data: ${e.toString()}');
    }
  }
  
  // Get Documents with Query
  static Future<List<Map<String, dynamic>>> getDocuments(
    String collectionName, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? where,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);
      
      // Apply where conditions
      if (where != null) {
        where.forEach((key, value) {
          query = query.where(key, isEqualTo: value);
        });
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data: ${e.toString()}');
    }
  }
  
  // Stream Documents (Realtime)
  static Stream<List<Map<String, dynamic>>> streamDocuments(
    String collectionName, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? where,
  }) {
    try {
      Query query = _firestore.collection(collectionName);
      
      // Apply where conditions
      if (where != null) {
        where.forEach((key, value) {
          query = query.where(key, isEqualTo: value);
        });
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();
      });
    } catch (e) {
      throw Exception('Gagal streaming data: ${e.toString()}');
    }
  }
  
  // ==================== STORAGE ====================
  
  // Upload File
  static Future<String> uploadFile(
    String filePath,
    String storagePath,
  ) async {
    try {
      final file = File(filePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child('$storagePath/$fileName');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal upload file: ${e.toString()}');
    }
  }
  
  // Delete File
  static Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Gagal menghapus file: ${e.toString()}');
    }
  }
}
