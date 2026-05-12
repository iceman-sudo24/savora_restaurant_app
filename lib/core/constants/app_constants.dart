/// Application-wide constants.
/// Centralizes static strings, collection names, and config values
/// to avoid magic strings scattered across the codebase.
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'Savora';
  static const String appVersion = '1.0.0';

  // ── Firestore Collection Names ──
  static const String usersCollection = 'users';
  static const String menuPackagesCollection = 'menu_packages';
  static const String bookingsCollection = 'bookings';

  // ── User Roles ──
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  // ── Booking Statuses ──
  static const String statusUpcoming = 'upcoming';
  static const String statusPast = 'past';
  static const String statusCancelled = 'cancelled';

  // ── Pricing ──
  static const double defaultBasePrice = 0.0;
  static const int defaultMinGuests = 1;
  static const int defaultMaxGuests = 500;

  // ── Route Paths ──
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String customerHomePath = '/customer/home';
  static const String customerBookingsPath = '/customer/bookings';
  static const String customerProfilePath = '/customer/profile';
  static const String adminPackagesPath = '/admin/packages';
  static const String adminBookingsPath = '/admin/bookings';
  static const String adminProfilePath = '/admin/profile';

  // ── Secure Storage Keys ──
  static const String secureStorageUidKey = 'user_uid';
  static const String secureStorageRoleKey = 'user_role';

  // ── Validation ──
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // ── Currency ──
  static const String currencySymbol = 'RM';
  static const String currencyCode = 'MYR';

  // ── Date Formats ──
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, h:mm a';
}