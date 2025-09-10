import 'dart:async';
import 'package:flutter/material.dart';
import '../core/error/failures.dart';
import '../models/place_model.dart';
import '../services/place_service.dart';

enum PlaceSearchState {
  initial,
  loading,
  loaded,
  error,
}

class PlaceSearchViewModel extends ChangeNotifier {
  final PlaceService _placeService;
  Timer? _debounce;

  PlaceSearchViewModel({required PlaceService placeService})
      : _placeService = placeService;

  // State management
  PlaceSearchState _state = PlaceSearchState.initial;
  PlaceSearchState get state => _state;

  List<PlaceModel> _places = [];
  List<PlaceModel> get places => _places;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == PlaceSearchState.loading;
  bool get hasError => _state == PlaceSearchState.error;
  bool get hasData => _state == PlaceSearchState.loaded && _places.isNotEmpty;
  bool get isEmpty => _state == PlaceSearchState.loaded && _places.isEmpty;

  // Search functionality
  Future<void> searchPlaces(String query) async {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    if (query.isEmpty) {
      _resetToInitial();
      return;
    }

    _debounce = Timer(const Duration(seconds: 1), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _setState(PlaceSearchState.loading);
    _searchQuery = query;

    try {
      final places = await _placeService.searchPlaces(query);
      _places = places;
      _setState(PlaceSearchState.loaded);
    } catch (e) {
      _errorMessage = e is Failure ? e.message : e.toString();
      _setState(PlaceSearchState.error);
    }
  }

  void _setState(PlaceSearchState newState) {
    _state = newState;
    notifyListeners();
  }

  void _resetToInitial() {
    _state = PlaceSearchState.initial;
    _places = [];
    _searchQuery = '';
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}