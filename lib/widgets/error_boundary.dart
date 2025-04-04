import 'package:bookreader/constants/logger.dart';
import 'package:flutter/material.dart';
import '../constants/styles.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String fallbackTitle;
  final String fallbackMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackTitle = 'Something went wrong',
    this.fallbackMessage = 'An error occurred while loading this content.',
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                widget.fallbackTitle,
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.fallbackMessage,
                style: AppTextStyles.bodyText,
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _error = null;
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return widget.child;
  }

  void onError(FlutterErrorDetails details) {
    Logger.error('Error caught by error boundary', details.exception);
    setState(() {
      _hasError = true;
      _error = details.exception;
    });
  }
}
