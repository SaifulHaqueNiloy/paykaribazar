class RoleConstraint {
  final String role;
  final List<String> allowedRoles;
  final bool requireAuth;

  const RoleConstraint({
    required this.role,
    required this.allowedRoles,
    this.requireAuth = true,
  });

  bool isAllowed(String? userRole) {
    if (!requireAuth) return true;
    if (userRole == null) return false;
    return allowedRoles.contains(userRole) || allowedRoles.contains(role);
  }

  static const admin = RoleConstraint(
    role: 'admin',
    allowedRoles: ['admin'],
  );

  static const staff = RoleConstraint(
    role: 'staff',
    allowedRoles: ['admin', 'staff'],
  );

  static const staffOrAbove = RoleConstraint(
    role: 'staff',
    allowedRoles: ['admin', 'staff'],
  );

  static const reseller = RoleConstraint(
    role: 'reseller',
    allowedRoles: ['admin', 'reseller'],
  );

  static const customer = RoleConstraint(
    role: 'customer',
    allowedRoles: ['customer'],
  );

  static const all = RoleConstraint(
    role: 'customer',
    allowedRoles: ['admin', 'staff', 'reseller', 'customer'],
    requireAuth: false,
  );

  static bool isAdmin(String? role) => role == 'admin';

  static bool isStaff(String? role) =>
      role == 'staff' || role == 'admin';

  static bool isReseller(String? role) =>
      role == 'reseller' || role == 'admin';

  static bool hasSufficientRole(String? userRole, String requiredRole) {
    if (userRole == null) return false;
    if (userRole == 'admin') return true;
    if (requiredRole == 'admin') return userRole == requiredRole;
    if (requiredRole == 'staff') return userRole == 'staff' || userRole == 'admin';
    return userRole == requiredRole;
  }
}
