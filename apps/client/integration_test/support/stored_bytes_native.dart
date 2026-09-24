/// What the browser has durably written for the store. Native builds write
/// through to a file, so there is nothing separate to inspect.
Future<List<int>?> browserStoredBytes(String storeName) async => null;
