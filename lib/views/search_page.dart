import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/place_service.dart';
import '../viewmodels/place_search_viewmodel.dart';
import '../widgets/place_list_item.dart';
import '../widgets/search_input.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlaceSearchViewModel>(
      create: (context) => PlaceSearchViewModel(
        placeService: PlaceServiceImpl(client: http.Client()),
      ),
      child: const SearchPageView(),
    );
  }
}

class SearchPageView extends StatefulWidget {
  const SearchPageView({Key? key}) : super(key: key);

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Consumer<PlaceSearchViewModel>(
              builder: (context, viewModel, child) {
                return SearchInput(
                  controller: _searchController,
                  onChanged: (query) {
                    viewModel.searchPlaces(query);
                  },
                  isLoading: viewModel.isLoading,
                );
              },
            ),
            Expanded(
              child: Consumer<PlaceSearchViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.hasData) {
                    return _buildLoadedState(viewModel);
                  } else if (viewModel.isEmpty) {
                    return _buildEmptyState(viewModel);
                  } else if (viewModel.hasError) {
                    return _buildErrorState(viewModel);
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(PlaceSearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: viewModel.places.length,
      itemBuilder: (context, index) {
        final place = viewModel.places[index];
        return PlaceListItem(
          place: place,
          query: viewModel.searchQuery,
        );
      },
    );
  }

  Widget _buildEmptyState(PlaceSearchViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No results found for "${viewModel.searchQuery}"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PlaceSearchViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 30),
          const SizedBox(height: 16),
          Text(
            'Error: ${viewModel.errorMessage}',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}