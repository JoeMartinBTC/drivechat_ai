// lib/presentation/main_conversation_interface/widgets/debug_panel_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../controllers/conversation_controller.dart';
import '../../../controllers/api_config_controller.dart';
import '../../../services/debug_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class DebugPanelWidget extends StatefulWidget {
  final ConversationController conversationController;
  final ApiConfigController apiConfigController;

  const DebugPanelWidget({
    super.key,
    required this.conversationController,
    required this.apiConfigController,
  });

  @override
  State<DebugPanelWidget> createState() => _DebugPanelWidgetState();
}

class _DebugPanelWidgetState extends State<DebugPanelWidget> {
  final DebugService _debugService = DebugService();
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CustomIconWidget(
          iconName: 'developer_mode',
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        title: Text(
          'Debug Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          widget.conversationController.isUsingLiveApi
              ? 'Live ElevenLabs API Active'
              : 'Demo Mode (Mock Service)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.conversationController.isUsingLiveApi
                    ? Colors.green
                    : Colors.orange,
              ),
        ),
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionStatus(),
                const SizedBox(height: 16),
                _buildDebugStats(),
                const SizedBox(height: 16),
                _buildControls(),
                const SizedBox(height: 16),
                _buildApiLogs(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final platformInfo = _debugService.isMobile ? '📱 Mobile' : '💻 Desktop';
    final mobileDiagnostics = _debugService.getMobileDiagnostics();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: widget.conversationController.isConnected
                    ? 'check_circle'
                    : 'error',
                color: widget.conversationController.isConnected
                    ? Colors.green
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Connection Status $platformInfo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.conversationController.connectionStatus,
            style: Theme.of(context).textTheme.bodySmall,
          ),

          // Mobile-specific diagnostics
          if (_debugService.isMobile &&
              mobileDiagnostics['hasRecentMobileIssues'] == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Recent mobile connectivity issues detected (${mobileDiagnostics['recentMobileErrors']} errors)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (!widget.conversationController.isUsingLiveApi)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: Colors.orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Demo mode active - Enable Live API in settings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugStats() {
    final debugInfo = widget.conversationController.getDebugInfo();
    final debugSummary = debugInfo['debugSummary'] as Map<String, dynamic>;
    final mobileDiagnostics = _debugService.getMobileDiagnostics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Statistics', style: Theme.of(context).textTheme.titleSmall),
            if (_debugService.isMobile) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  'MOBILE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Messages',
                debugSummary['totalMessages'].toString(),
                Icons.chat,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'API Calls',
                debugSummary['totalApiCalls'].toString(),
                Icons.api,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Audio Gen',
                debugSummary['messagesWithAudio'].toString(),
                Icons.volume_up,
              ),
            ),
          ],
        ),

        // Mobile-specific stats
        if (_debugService.isMobile) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Mobile Errors',
                  debugSummary['mobileErrors'].toString(),
                  Icons.smartphone,
                  color: debugSummary['mobileErrors'] > 0 ? Colors.red : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Auth Errors',
                  debugSummary['authenticationErrors'].toString(),
                  Icons.security,
                  color: debugSummary['authenticationErrors'] > 0
                      ? Colors.red
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Network Logs',
                  mobileDiagnostics['networkLogsCount'].toString(),
                  Icons.network_check,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 8),
        if (debugSummary['averageApiDuration'] > 0)
          Text(
            'Avg API Response: ${debugSummary['averageApiDuration'].toInt()}ms ${_debugService.isMobile ? "(Mobile)" : "(Desktop)"}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: cardColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: cardColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final mobileDiagnostics = _debugService.getMobileDiagnostics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Controls', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildControlButton(
              'Force Live API',
              Icons.cloud_sync,
              !widget.conversationController.isUsingLiveApi,
              () async {
                await widget.apiConfigController.getUserInfo();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _debugService.isMobile
                            ? 'Switched to Live ElevenLabs API (Mobile)'
                            : 'Switched to Live ElevenLabs API',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            _buildControlButton('Clear Logs', Icons.clear_all, true, () {
              _debugService.clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _debugService.isMobile
                        ? 'Mobile debug logs cleared'
                        : 'Debug logs cleared',
                  ),
                ),
              );
            }),
            _buildControlButton('Export Logs', Icons.download, true, () {
              final logs = _debugService.exportLogs();
              Clipboard.setData(ClipboardData(text: logs));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _debugService.isMobile
                        ? 'Mobile logs copied to clipboard'
                        : 'Logs copied to clipboard',
                  ),
                ),
              );
            }),
            _buildControlButton(
              'Test Connection',
              Icons.wifi_protected_setup,
              true,
              () async {
                await widget.conversationController.refreshConnection();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.conversationController.isConnected
                            ? (_debugService.isMobile
                                ? 'Mobile connection successful'
                                : 'Connection successful')
                            : (_debugService.isMobile
                                ? 'Mobile connection failed'
                                : 'Connection failed'),
                      ),
                      backgroundColor: widget.conversationController.isConnected
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                }
              },
            ),

            // Mobile-specific controls
            if (_debugService.isMobile &&
                mobileDiagnostics['hasRecentMobileIssues'] == true)
              _buildControlButton('Mobile Diag', Icons.smartphone, true, () {
                final diagnostics = _debugService.getMobileDiagnostics();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Mobile errors: ${diagnostics['recentMobileErrors']}, Auth errors: ${diagnostics['authErrorsOnMobile']}',
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildApiLogs() {
    final apiLogs = _debugService.apiLogs;
    if (apiLogs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent API Calls',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'No API calls yet',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent API Calls (${apiLogs.length})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ListView.builder(
            itemCount: apiLogs.length,
            reverse: true,
            itemBuilder: (context, index) {
              final log = apiLogs[apiLogs.length - 1 - index];
              final isSuccess = log['success'] == true;
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                title: Text(
                  '${log['method']} ${log['endpoint']}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                subtitle: Text(
                  '${log['duration']}ms${isSuccess ? '' : ' - ${log['error']}'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                ),
                trailing: Text(
                  DateTime.parse(
                    log['timestamp'],
                  ).toLocal().toString().substring(11, 19),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
