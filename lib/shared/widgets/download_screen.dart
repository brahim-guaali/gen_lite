import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import 'ui_components.dart';
import '../services/enhanced_model_downloader.dart';
import '../services/llm_service.dart';

class DownloadScreen extends StatefulWidget {
  final VoidCallback onDownloadComplete;
  final VoidCallback onSkip;

  const DownloadScreen({
    super.key,
    required this.onDownloadComplete,
    required this.onSkip,
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
  bool _hasError = false;
  String? _errorMessage;
  bool _showSkipButton = false;
  Timer? _skipTimer;
  DownloadState? _existingDownloadState;

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
    _checkExistingDownload();
    _startSkipTimer();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _skipTimer?.cancel();
    super.dispose();
  }

  void _startSkipTimer() {
    _skipTimer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _showSkipButton = true;
        });
      }
    });
  }

  Future<void> _checkExistingDownload() async {
    final hasIncomplete = await EnhancedModelDownloader.hasIncompleteDownload(
      'google/gemma-2b-it',
      'gemma-2b-it.gguf',
    );

    if (hasIncomplete) {
      final state = await EnhancedModelDownloader.getDownloadState(
        'google/gemma-2b-it',
        'gemma-2b-it.gguf',
      );

      if (state != null && mounted) {
        setState(() {
          _existingDownloadState = state;
          _receivedBytes = state.downloadedBytes;
          _totalBytes = state.totalBytes;
          _progress = state.downloadedBytes / state.totalBytes;
        });
      }
    }

    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
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

      // Initialize LLM service
      await LLMService().initialize(modelPath: modelPath);

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
    });
    await _startDownload();
  }

  Future<void> _clearAndRestart() async {
    await EnhancedModelDownloader.clearDownloadState(
      'google/gemma-2b-it',
      'gemma-2b-it.gguf',
    );
    setState(() {
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
      _speed = 0;
      _elapsed = Duration.zero;
      _status = null;
      _isResuming = false;
      _existingDownloadState = null;
    });
    await _startDownload();
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${bytes.toString().padLeft(3)} B';
    }
  }

  String _formatSpeed(double bytesPerSec) {
    if (bytesPerSec >= 1024 * 1024) {
      return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    } else if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${bytesPerSec.toStringAsFixed(0).padLeft(3)} B/s';
    }
  }

  String _formatElapsed(Duration d) {
    int h = d.inHours;
    int m = d.inMinutes % 60;
    int s = d.inSeconds % 60;
    String result = '';
    if (h > 0) result += '${h.toString().padLeft(2, '0')}h ';
    if (m > 0 || h > 0) result += '${m.toString().padLeft(2, '0')}m ';
    result += '${s.toString().padLeft(2, '0')}s';
    return result.trim();
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
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor
                        .withValues(alpha: _pulseController.value * 0.3),
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
          _hasError ? 'Download Failed' : 'Downloading AI Model',
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
              : 'GenLite needs to download a large language model to enable AI features. This may take several minutes.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    if (_hasError) {
      return AppCard(
        backgroundColor: AppConstants.errorColor.withValues(alpha: 0.1),
        child: Column(
          children: [
            Icon(
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
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isResuming) ...[
          AppCard(
            backgroundColor: AppConstants.accentColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: AppConstants.accentColor,
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    'Resuming download from ${_formatBytes(_receivedBytes)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
        ],
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Download Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Progress bar
              AppProgressBar(
                progress: _progress,
                height: 12,
                showPercentage: false,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Download stats
              _buildDownloadStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadStats() {
    return Container(
      height: 120, // Fixed height to prevent layout shifts
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatRow('Downloaded',
              '${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)}'),
          _buildStatRow('Speed', _formatSpeed(_speed)),
          _buildStatRow('Elapsed', _formatElapsed(_elapsed)),
          _buildStatRow('Status', _status ?? ''),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
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
          if (_existingDownloadState != null) ...[
            SecondaryButton(
              text: 'Clear and Restart',
              icon: Icons.clear,
              onPressed: _clearAndRestart,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
          DangerButton(
            text: 'Skip for Now',
            icon: Icons.skip_next,
            onPressed: widget.onSkip,
          ),
        ],
      );
    }

    if (_showSkipButton) {
      return Column(
        children: [
          if (_isDownloading) ...[
            Text(
              'Download in progress...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
          SecondaryButton(
            text: 'Skip for Now',
            icon: Icons.skip_next,
            onPressed: widget.onSkip,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
