import 'package:flutter/material.dart';
import 'dart:async';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/shared/services/enhanced_model_downloader.dart';
import 'package:genlite/shared/services/gemma_downloader.dart';
import 'package:genlite/shared/services/model_downloader.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/shared/services/llm_service.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genlite/shared/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class DownloadScreen extends StatefulWidget {
  final VoidCallback onDownloadComplete;

  const DownloadScreen({
    super.key,
    required this.onDownloadComplete,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  double _speed = 0;
  Duration _elapsed = Duration.zero;
  String? _status;
  bool _isResuming = false;
  bool _isDownloading = false;
  bool _isInitializing = false;
  bool _hasError = false;
  String? _errorMessage;
  bool? _showAllErrorLines = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    _initializeModel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isDownloading = true;
      _status = 'Downloading Gemma 3N...';
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final modelPath = await EnhancedModelDownloader.ensureGemmaModel(
        onProgress: (info) {
          if (mounted) {
            setState(() {
              _progress = info.progress;
              _receivedBytes = info.receivedBytes;
              _totalBytes = info.totalBytes;
              _speed = info.speedBytesPerSec;
              _elapsed = info.elapsed;
              _isResuming = info.isResuming;
              _status = info.status;
            });
          }
        },
      );
      setState(() {
        _isDownloading = false;
        _isInitializing = true;
        _status = 'Initializing model...';
        _progress = 1.0;
      });
      await LLMService().initialize(modelPath: modelPath);
      setState(() {
        _isInitializing = false;
        _status = 'Setup complete!';
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        widget.onDownloadComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _retryDownload() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _progress = 0.0;
      _isInitializing = false;
    });
    await _initializeModel();
  }

  Future<void> _clearAndRestart() async {
    // Delete the model file and download state using EnhancedModelDownloader logic
    final docDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${docDir.path}/gemma2b');
    final filePath = '${modelDir.path}/gemma-3n-E4B-it-int4.task';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    // Optionally clear download state if you have a method for it
    setState(() {
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
      _speed = 0;
      _elapsed = Duration.zero;
      _status = null;
      _isResuming = false;
      _isInitializing = false;
      _hasError = false;
      _errorMessage = null;
    });
    await _initializeModel();
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  String _formatSpeed(double bytesPerSec) {
    if (bytesPerSec >= 1024 * 1024) {
      return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(2)} KB/s';
    } else {
      return '${bytesPerSec.toStringAsFixed(0)} B/s';
    }
  }

  String _formatElapsed(Duration d) {
    int h = d.inHours;
    int m = d.inMinutes % 60;
    int s = d.inSeconds % 60;

    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
    } else if (m > 0) {
      return '${m}m ${s.toString().padLeft(2, '0')}s';
    } else {
      return '${s}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _slideAnimation.value)),
              child: Opacity(
                opacity: _slideAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    children: [
                      const Spacer(),
                      _buildHeader(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildProgressSection(),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      _buildActionButtons(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.primaryColorWithOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColorWithOpacity(
                        _pulseController.value * 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isDownloading ? Icons.download : Icons.cloud_download,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            );
          },
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
          _hasError
              ? 'Download Failed'
              : _isInitializing
                  ? 'Initializing Model'
                  : 'Downloading AI Model',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _hasError
                    ? AppConstants.errorColor
                    : AppConstants.primaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          _hasError
              ? 'There was an error downloading the model. You can retry or skip for now.'
              : _isInitializing
                  ? 'Setting up the AI model for first use. This may take a moment...'
                  : 'GenLite needs to download a large language model to enable AI features. This may take several minutes.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppConstants.onSurfaceColorWithOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    if (_hasError) {
      final errorLines =
          (_errorMessage ?? 'Unknown error occurred').split('\n');
      bool showAll = _showAllErrorLines ?? false;
      int maxLines = 6;
      List<String> linesToShow =
          showAll ? errorLines : errorLines.take(maxLines).toList();
      return AppCard(
        backgroundColor: AppConstants.errorColorWithOpacity(0.1),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Download Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...linesToShow.map((line) => Text(
                          line,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.left,
                        )),
                    if (errorLines.length > maxLines)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllErrorLines = !showAll;
                          });
                        },
                        child: Text(showAll ? 'Show Less' : 'Show More'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isInitializing
                        ? 'Initialization Progress'
                        : 'Download Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    _isInitializing
                        ? '100%'
                        : '${(_progress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Progress bar
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppConstants.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Detailed progress information
              if (_isDownloading && _totalBytes > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloaded: ${_formatBytes(_receivedBytes)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.onSurfaceColorWithOpacity(0.7),
                          ),
                    ),
                    Text(
                      'Total: ${_formatBytes(_totalBytes)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.onSurfaceColorWithOpacity(0.7),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Speed: ${_formatSpeed(_speed)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.onSurfaceColorWithOpacity(0.7),
                          ),
                    ),
                    Text(
                      'Time: ${_formatElapsed(_elapsed)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.onSurfaceColorWithOpacity(0.7),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_hasError) {
      return Column(
        children: [
          PrimaryButton(
            text: 'Retry Download',
            icon: Icons.refresh,
            onPressed: _retryDownload,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          SecondaryButton(
            text: 'Clear and Restart',
            icon: Icons.clear,
            onPressed: _clearAndRestart,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
