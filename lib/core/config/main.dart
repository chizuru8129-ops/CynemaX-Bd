import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/config/app_config.dart';

void main() {
  runApp(const CynemaXWebApp());
}

class CynemaXWebApp extends StatelessWidget {
  const CynemaXWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00A8A8),
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;
  String? _error;
  List<dynamic> _items = const [];
  String _title = 'Trending';

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<dynamic> _getJson(Uri uri) async {
    final response = await http
        .get(uri, headers: AppConfig.defaultHeaders)
        .timeout(AppConfig.receiveTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    if (response.body.trim().isEmpty) {
      return const [];
    }

    return jsonDecode(response.body);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      for (final key in const [
        'results',
        'items',
        'data',
        'movies',
        'shows',
        'trending',
        'latest',
      ]) {
        final value = data[key];
        if (value is List) return value;
      }

      final nestedData = data['data'];
      if (nestedData is Map) {
        for (final key in const [
          'results',
          'items',
          'movies',
          'shows',
          'trending',
          'latest',
        ]) {
          final value = nestedData[key];
          if (value is List) return value;
        }
      }
    }

    return [data];
  }

  Future<void> _load(String title, Uri uri) async {
    setState(() {
      _loading = true;
      _error = null;
      _title = title;
    });

    try {
      final data = await _getJson(uri);
      if (!mounted) return;
      setState(() => _items = _extractList(data));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _error =
            '$e\n\nIf this works on Android but not on Netlify, enable CORS on the Railway backend for your Netlify domain.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadTrending() {
    return _load('Trending', Uri.parse(AppConfig.trendingEndpoint));
  }

  Future<void> _loadLatest() {
    return _load('Latest', Uri.parse(AppConfig.latestEndpoint));
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final base = Uri.parse(AppConfig.searchEndpoint);
    final uri = base.replace(
      queryParameters: {
        ...base.queryParameters,
        'q': query,
      },
    );

    await _load('Search: $query', uri);
  }

  String _pickText(dynamic item, List<String> keys, {String fallback = ''}) {
    if (item is Map) {
      for (final key in keys) {
        final value = item[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return fallback;
  }

  String? _pickImage(dynamic item) {
    final value = _pickText(
      item,
      const [
        'poster',
        'posterUrl',
        'poster_url',
        'image',
        'imageUrl',
        'image_url',
        'thumbnail',
        'cover',
        'backdrop',
      ],
    );

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return null;
  }

  Widget _movieCard(dynamic item) {
    final title = _pickText(
      item,
      const ['title', 'name', 'movieTitle', 'original_title'],
      fallback: 'Untitled',
    );
    final subtitle = _pickText(
      item,
      const ['year', 'releaseDate', 'release_date', 'type', 'media_type'],
    );
    final image = _pickImage(item);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showRawDetails(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: image == null
                  ? const ColoredBox(
                      color: Color(0xFF151C24),
                      child: Center(
                        child: Icon(Icons.movie_outlined, size: 48),
                      ),
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF151C24),
                        child: Center(
                          child: Icon(Icons.broken_image_outlined, size: 42),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showRawDetails(dynamic item) {
    final pretty = const JsonEncoder.withIndent('  ').convert(item);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API data'),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: SelectableText(pretty),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: 'Trending',
            onPressed: _loadTrending,
            icon: const Icon(Icons.local_fire_department_outlined),
          ),
          IconButton(
            tooltip: 'Latest',
            onPressed: _loadLatest,
            icon: const Icon(Icons.new_releases_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Search movies or TV series',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _search,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                        '${_items.length} items',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    _error!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : _items.isEmpty
                                ? const Center(
                                    child: Text('No data returned by the API.'),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final columns = width >= 1000
                                          ? 6
                                          : width >= 760
                                              ? 4
                                              : width >= 520
                                                  ? 3
                                                  : 2;

                                      return GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          childAspectRatio: 0.62,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount: _items.length,
                                        itemBuilder: (context, index) =>
                                            _movieCard(_items[index]),
                                      );
                                    },
                                  ),
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
