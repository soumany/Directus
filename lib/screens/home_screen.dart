import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/directus_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DirectusService _directusService = DirectusService();
  List<dynamic> _homeContent = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHomeContent();
  }

  Future<void> _fetchHomeContent() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final content = await _directusService.getHomeContent();
    setState(() {
      _homeContent = content; // Now directly assigns the List
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}

  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';

    // Get base URL from .env and construct the image URL dynamically
    final baseUrl = dotenv.env['DIRECTUS_API_URL']?.replaceAll('/items', '');
    final imageUrl =
        '$baseUrl/assets/$imageId'; // Constructing the URL dynamically

    print('Constructed Image URL: $imageUrl'); // Log the image URL
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error loading content'),
                      Text(_errorMessage),
                      ElevatedButton(
                        onPressed: _fetchHomeContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _homeContent.isEmpty
                  ? const Center(child: Text('No content available'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _homeContent.map((item) {
                            final data = item is Map ? item : item['data'];
                            final imageUrl =
                                _getImageUrl(data['image']?.toString());

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                if (data['title'] != null)
                                  Text(
                                    data['title'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),

                                // Image
                                if (imageUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) {
                                        print(
                                            'Error loading image: $error'); // Log the error
                                        return const Icon(Icons.error);
                                      },
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                // Content
                                if (data['content'] != null)
                                  Html(
                                    data: data['content'],
                                  ),

                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
    );
  }
}
