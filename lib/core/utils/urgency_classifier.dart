class UrgencyClassifier {
  static String classify(String incidentType, String description) {
    final lowerType = incidentType.toLowerCase();
    final lowerDesc = description.toLowerCase();

    // Urgent keywords
    final urgentKeywords = [
      'physical attack',
      'rape',
      'assault',
      'death threat',
      'bomb',
      'gun',
      'knife',
      'emergency',
      'danger',
      'immediate'
    ];

    // High priority keywords
    final highKeywords = [
      'harassment',
      'stalking',
      'threatening',
      'blackmail',
      'extortion',
      'sexual',
      'abuse',
      'violent',
      'threatened'
    ];

    // Check urgent
    if (urgentKeywords.any((kw) => lowerType.contains(kw) || lowerDesc.contains(kw))) {
      return 'urgent';
    }

    // Check high
    if (highKeywords.any((kw) => lowerType.contains(kw) || lowerDesc.contains(kw))) {
      return 'high';
    }

    // Default to medium
    return 'medium';
  }

  static String getColor(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'urgent':
        return '#FF0000'; // Red
      case 'high':
        return '#FF9800'; // Orange
      case 'medium':
        return '#4CAF50'; // Green
      default:
        return '#2196F3'; // Blue
    }
  }

  static String getLabel(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'urgent':
        return 'Urgent';
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      default:
        return 'Unknown';
    }
  }
}
