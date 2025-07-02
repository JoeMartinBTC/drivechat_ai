
import '../../../core/app_export.dart';

// lib/presentation/api_configuration_screen/widgets/connection_test_widget.dart

class ConnectionTestWidget extends StatelessWidget {
  final bool isLoading;
  final String connectionStatus;
  final bool isConnected;
  final VoidCallback onTestConnection;
  final Map<String, dynamic>? connectionDetails;

  const ConnectionTestWidget({
    super.key,
    required this.isLoading,
    required this.connectionStatus,
    required this.isConnected,
    required this.onTestConnection,
    this.connectionDetails,
  });

  Color _getStatusColor() {
    if (isLoading) return AppTheme.warningLight;
    if (isConnected) return AppTheme.successLight;
    if (connectionStatus.contains('failed') ||
        connectionStatus.contains('error')) {
      return AppTheme.errorLight;
    }
    return AppTheme.textSecondaryLight;
  }

  IconData _getStatusIcon() {
    if (isLoading) return Icons.sync;
    if (isConnected) return Icons.check_circle;
    if (connectionStatus.contains('failed') ||
        connectionStatus.contains('error')) {
      return Icons.error;
    }
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'network_check',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Connection Test',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Connection Status
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(),
                      ),
                    ),
                  )
                else
                  CustomIconWidget(
                    iconName: isConnected
                        ? 'check_circle'
                        : connectionStatus.contains('failed')
                            ? 'error'
                            : 'help_outline',
                    color: _getStatusColor(),
                    size: 20,
                  ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        connectionStatus,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Test Connection Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTestConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? AppTheme.textSecondaryLight
                    : AppTheme.primaryLight,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.backgroundLight,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Testing Connection...',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.backgroundLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'sync',
                          color: AppTheme.backgroundLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Test Connection',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.backgroundLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Additional Information
          if (isConnected && connectionDetails != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Details',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildConnectionDetail(
                    'Subscription',
                    connectionDetails?['subscription']?['tier'] ?? 'Unknown',
                  ),
                  _buildConnectionDetail(
                    'Available Characters',
                    '${connectionDetails?['subscription']?['character_count'] ?? 'Unknown'}',
                  ),
                  _buildConnectionDetail(
                    'Character Limit',
                    '${connectionDetails?['subscription']?['character_limit'] ?? 'Unknown'}',
                  ),
                  _buildConnectionDetail(
                    'Subscription Status',
                    connectionDetails?['subscription']?['status'] ?? 'Unknown',
                  ),
                ],
              ),
            ),
          ] else if (connectionStatus.contains('failed')) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troubleshooting Tips',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.errorLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildTroubleshootingTip('• Verify your API key is correct'),
                  _buildTroubleshootingTip('• Check your internet connection'),
                  _buildTroubleshootingTip(
                    '• Ensure you have API quota remaining',
                  ),
                  _buildTroubleshootingTip('• Try generating a new API key'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.successLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingTip(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Text(
        tip,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondaryLight,
        ),
      ),
    );
  }
}
