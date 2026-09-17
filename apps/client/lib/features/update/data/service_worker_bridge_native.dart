/// Outside the browser there is no service worker.
class ServiceWorkerBridge {
  const ServiceWorkerBridge();

  Future<bool> hasUpdate() async => false;

  Future<void> applyUpdate() async {}

  Uri get base => Uri.base;
}
