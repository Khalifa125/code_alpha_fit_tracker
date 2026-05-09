import '../../imports/imports.dart';

class SkeletonWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool enabled;

  const SkeletonWrapper({
    super.key,
    required this.child,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;
    return child;
  }
}