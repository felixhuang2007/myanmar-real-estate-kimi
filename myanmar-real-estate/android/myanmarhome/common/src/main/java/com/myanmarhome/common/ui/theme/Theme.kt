package com.myanmarhome.common.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

// Light Theme Colors
private val LightPrimary = Color(0xFF1976D2)
private val LightOnPrimary = Color(0xFFFFFFFF)
private val LightPrimaryContainer = Color(0xFFBBDEFB)
private val LightOnPrimaryContainer = Color(0xFF0D47A1)
private val LightSecondary = Color(0xFF388E3C)
private val LightOnSecondary = Color(0xFFFFFFFF)
private val LightSecondaryContainer = Color(0xFFC8E6C9)
private val LightOnSecondaryContainer = Color(0xFF1B5E20)
private val LightTertiary = Color(0xFFF57C00)
private val LightOnTertiary = Color(0xFFFFFFFF)
private val LightTertiaryContainer = Color(0xFFFFE0B2)
private val LightOnTertiaryContainer = Color(0xFFE65100)
private val LightBackground = Color(0xFFF5F5F5)
private val LightOnBackground = Color(0xFF212121)
private val LightSurface = Color(0xFFFFFFFF)
private val LightOnSurface = Color(0xFF212121)
private val LightSurfaceVariant = Color(0xFFEEEEEE)
private val LightOnSurfaceVariant = Color(0xFF616161)
private val LightError = Color(0xFFD32F2F)
private val LightOnError = Color(0xFFFFFFFF)
private val LightOutline = Color(0xFFBDBDBD)

// Dark Theme Colors
private val DarkPrimary = Color(0xFF90CAF9)
private val DarkOnPrimary = Color(0xFF0D47A1)
private val DarkPrimaryContainer = Color(0xFF1565C0)
private val DarkOnPrimaryContainer = Color(0xFFBBDEFB)
private val DarkSecondary = Color(0xFFA5D6A7)
private val DarkOnSecondary = Color(0xFF1B5E20)
private val DarkSecondaryContainer = Color(0xFF2E7D32)
private val DarkOnSecondaryContainer = Color(0xFFC8E6C9)
private val DarkTertiary = Color(0xFFFFB74D)
private val DarkOnTertiary = Color(0xFFE65100)
private val DarkTertiaryContainer = Color(0xFFF57C00)
private val DarkOnTertiaryContainer = Color(0xFFFFE0B2)
private val DarkBackground = Color(0xFF121212)
private val DarkOnBackground = Color(0xFFE0E0E0)
private val DarkSurface = Color(0xFF1E1E1E)
private val DarkOnSurface = Color(0xFFE0E0E0)
private val DarkSurfaceVariant = Color(0xFF2C2C2C)
private val DarkOnSurfaceVariant = Color(0xFFB0B0B0)
private val DarkError = Color(0xFFEF5350)
private val DarkOnError = Color(0xFF212121)
private val DarkOutline = Color(0xFF424242)

private val LightColorScheme = lightColorScheme(
    primary = LightPrimary,
    onPrimary = LightOnPrimary,
    primaryContainer = LightPrimaryContainer,
    onPrimaryContainer = LightOnPrimaryContainer,
    secondary = LightSecondary,
    onSecondary = LightOnSecondary,
    secondaryContainer = LightSecondaryContainer,
    onSecondaryContainer = LightOnSecondaryContainer,
    tertiary = LightTertiary,
    onTertiary = LightOnTertiary,
    tertiaryContainer = LightTertiaryContainer,
    onTertiaryContainer = LightOnTertiaryContainer,
    background = LightBackground,
    onBackground = LightOnBackground,
    surface = LightSurface,
    onSurface = LightOnSurface,
    surfaceVariant = LightSurfaceVariant,
    onSurfaceVariant = LightOnSurfaceVariant,
    error = LightError,
    onError = LightOnError,
    outline = LightOutline
)

private val DarkColorScheme = darkColorScheme(
    primary = DarkPrimary,
    onPrimary = DarkOnPrimary,
    primaryContainer = DarkPrimaryContainer,
    onPrimaryContainer = DarkOnPrimaryContainer,
    secondary = DarkSecondary,
    onSecondary = DarkOnSecondary,
    secondaryContainer = DarkSecondaryContainer,
    onSecondaryContainer = DarkOnSecondaryContainer,
    tertiary = DarkTertiary,
    onTertiary = DarkOnTertiary,
    tertiaryContainer = DarkTertiaryContainer,
    onTertiaryContainer = DarkOnTertiaryContainer,
    background = DarkBackground,
    onBackground = DarkOnBackground,
    surface = DarkSurface,
    onSurface = DarkOnSurface,
    surfaceVariant = DarkSurfaceVariant,
    onSurfaceVariant = DarkOnSurfaceVariant,
    error = DarkError,
    onError = DarkOnError,
    outline = DarkOutline
)

data class ExtendedColors(
    val success: Color,
    val onSuccess: Color,
    val warning: Color,
    val onWarning: Color,
    val info: Color,
    val onInfo: Color
)

val LocalExtendedColors = staticCompositionLocalOf {
    ExtendedColors(
        success = Color.Unspecified,
        onSuccess = Color.Unspecified,
        warning = Color.Unspecified,
        onWarning = Color.Unspecified,
        info = Color.Unspecified,
        onInfo = Color.Unspecified
    )
}

private val LightExtendedColors = ExtendedColors(
    success = Color(0xFF4CAF50),
    onSuccess = Color.White,
    warning = Color(0xFFFF9800),
    onWarning = Color.Black,
    info = Color(0xFF2196F3),
    onInfo = Color.White
)

private val DarkExtendedColors = ExtendedColors(
    success = Color(0xFF81C784),
    onSuccess = Color.Black,
    warning = Color(0xFFFFB74D),
    onWarning = Color.Black,
    info = Color(0xFF64B5F6),
    onInfo = Color.Black
)

object MyanmarHomeTheme {
    val colors: ExtendedColors
        @Composable
        get() = LocalExtendedColors.current
}

@Composable
fun MyanmarHomeTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val extendedColors = if (darkTheme) DarkExtendedColors else LightExtendedColors
    
    CompositionLocalProvider(LocalExtendedColors provides extendedColors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
