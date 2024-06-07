import 'dart:ui';

/// __Description__:
/// Takes in the screen size (width or height) and a threshold for starting to apply a shift between two percentage points.
/// Returns a tuple that contains the final size as well as padding.
/// 
/// + __screenSize__ - either __width__ or __height__
/// + __ratioThreshold__ - value that determines when to move from __beforeThresholdPercent__ towards __afterThresholdPercent__ in the calculation.
/// + __afterThresholdPercent__ &  __beforeThresholdPercent__ - percentage of the screen that the __screenSize__ will take.
(double, double) screenScaler(double screenSize, double ratioThresold, double afterThresholdPercent, double beforeThresholdPercent) {
  final percent = clampDouble(((screenSize - ratioThresold) / (ratioThresold)), 0.0, 1.0);

  final ratio = (beforeThresholdPercent - (beforeThresholdPercent - afterThresholdPercent) * percent);

  // Returns (Size, Padding)
  return (screenSize * ratio, screenSize * (1.0 - ratio) / 2);
}

/// __Description__:
/// Takes in the screen size (width or height) with an upper and lower bound threshold that shifts between two percentage points.
/// Returns a tuple that contains the final size as well as padding.
/// 
/// Similar to __screenScaler__. 
/// 
/// + __screenSize__ - either __width__ or __height__.
/// + __upperLimitThreshold__ - the upper limit that determines the final size based on __upperThresholdPercent__.
/// + __lowerlimitThreshold__ - Similar to __upperLimitThreshold__ but with __lowerThresholdPercent__ instead.
/// + __upperThresholdPercent__ & __lowerThresholdPercent__ - the percentage of the screen that __screenSize__ will take. 
(double, double) screenScalerBounded(double screenSize, double upperLimitThreshold, double lowerLimitThreshold, double upperThresholdPercent, double lowerThresholdPercent) {
  final percent = clampDouble((screenSize - lowerLimitThreshold) / (upperLimitThreshold - lowerLimitThreshold), 0.0, 1.0);

  final ratio = (upperThresholdPercent - (upperThresholdPercent - lowerThresholdPercent) * percent);

  return (screenSize * ratio, screenSize * (1.0 - ratio) / 2);
}

/// A function that returns the absolute value of any numeric.
double abs(double value) {
  return value < 0.0 ? -value : value;
}