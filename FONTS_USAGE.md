# Custom Fonts Usage Guide

This project now includes the `google_fonts` package, which provides access to over 1000 free fonts from Google Fonts.

## Installation

After pulling these changes, run:
```bash
flutter pub get
```

## Usage Examples

### Using a Font in a Text Widget

```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  'Blood Donation App',
  style: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  ),
)
```

### Setting App-Wide Default Font

In your `main.dart` or theme configuration:

```dart
import 'package:google_fonts/google_fonts.dart';

MaterialApp(
  theme: ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    ),
  ),
  // ... rest of your app
)
```

## Recommended Fonts for Blood Donation App

- **Poppins** - Modern, clean, and highly readable
- **Roboto** - Professional and widely used
- **Lato** - Friendly and approachable
- **Open Sans** - Clean and neutral
- **Montserrat** - Bold and attention-grabbing

## Example with Different Fonts

```dart
// Headings
Text(
  'Donate Blood, Save Lives',
  style: GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
)

// Body text
Text(
  'Your donation can make a difference',
  style: GoogleFonts.openSans(
    fontSize: 16,
  ),
)

// Buttons
ElevatedButton(
  child: Text(
    'DONATE NOW',
    style: GoogleFonts.roboto(
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  ),
  onPressed: () {},
)
```

## Additional Resources

- Google Fonts catalog: https://fonts.google.com/
- Package documentation: https://pub.dev/packages/google_fonts
