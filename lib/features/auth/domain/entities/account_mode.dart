/// The three ways someone can hold a FloodStore session.
///
/// This is presentation-agnostic on purpose: it only decides *copy* and
/// *which extra fields are required*, never which repository method runs.
/// Sign-in/sign-up for [individual] and [business] both go through the same
/// [AuthRepository] calls — a company is just an [AppUser] with a
/// `companyName` on the register payload and a badge in the UI. Keeping
/// that mapping this thin is what makes "add business mode" a form-layer
/// change instead of a backend one.
enum AccountMode {
  individual,
  business,
  guest;

  String get label => switch (this) {
        AccountMode.individual => 'Individual',
        AccountMode.business => 'Business',
        AccountMode.guest => 'Guest',
      };

  String get loginSubtitle => switch (this) {
        AccountMode.individual => 'Sign in to continue to your account.',
        AccountMode.business => 'Sign in with your company workspace.',
        AccountMode.guest => 'Browse FloodStore without an account.',
      };

  bool get requiresCompanyName => this == AccountMode.business;

  bool get isGuest => this == AccountMode.guest;
}
