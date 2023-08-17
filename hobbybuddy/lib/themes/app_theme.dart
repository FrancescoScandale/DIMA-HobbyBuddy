import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

ThemeData lightTheme = FlexThemeData.light(
  scheme: FlexScheme.amber,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
  ),
  keyColors: const FlexKeyColors(),
  tones: FlexTones.soft(Brightness.light),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
  // To use the Playground font, add GoogleFonts package and uncomment
  // fontFamily: GoogleFonts.notoSans().fontFamily,
);
ThemeData darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.amber,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useTextTheme: true,
  ),
  keyColors: const FlexKeyColors(),
  tones: FlexTones.soft(Brightness.dark),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
  // To use the Playground font, add GoogleFonts package and uncomment
  // fontFamily: GoogleFonts.notoSans().fontFamily,
);
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,


/* How can I access a particular textTheme?
- Theme.of(context).textTheme.<theme>
- Theme.of(context).primaryTextTheme.<theme>
e.g., Theme.of(context).textTheme.headlineLarge
*/

/* What is the difference:
    textTheme: defines the default text styles for various types of text widgets
    in the app, such as Text, TextField, and AppBar.
    Is typically used to define the overall style and hierarchy of text styles in the app.

    primaryTextTheme: defines the text styles for widgets that are part of the 
    app's primary color scheme, such as AppBar, TabBar, and FloatingActionButton. 
    Is typically used to define the typography for widgets that are associated 
    with the app's primary color, and is often used in conjunction with colorScheme 
    to define a consistent color and typography scheme throughout the app.

    NOTE: textTheme changes color on theme switch.
*/

/* Which textTheme/primaryTextTheme should I use?
  Plain Text:
- Eventy name                   --> textTheme.displayLarge
- Username in Profile view      --> textTheme.displaySmall
- Name/Surname in Profile view  --> textTheme.headlineSmall
- Screen titles, e.g. "Log In"  --> textTheme.headlineLarge
- Modal:
    Title    --> textTheme.headlineMedium
    Subtitle --> textTheme.headlineSmall
- Create event/poll, stepper:
    Step labels e.g., "Basics"                  --> textTheme.labelLarge
    Step title e.g. "Select the locations"      --> textTheme.headlineMedium
    Step subtitle e.g. "Description (optional)" --> textTheme.headlineSmall
*/
