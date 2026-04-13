enum GrowthMessageType { begin, end }

extension GrowthMessageTypeApi on GrowthMessageType {
  String get apiValue {
    return switch (this) {
      GrowthMessageType.begin => 'Begin',
      GrowthMessageType.end => 'End',
    };
  }
}
