package com.myanmarhome.buyer.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Search
import androidx.compose.ui.graphics.vector.ImageVector
import com.myanmarhome.buyer.R

object BuyerDestinations {
    const val HOME_ROUTE = "home"
    const val SEARCH_ROUTE = "search"
    const val FAVORITE_ROUTE = "favorite"
    const val PROFILE_ROUTE = "profile"
    
    const val HOUSE_DETAIL_ROUTE = "house_detail/{houseId}"
    const val MAP_SEARCH_ROUTE = "map_search"
    const val CHAT_ROUTE = "chat/{conversationId}"
    const val APPOINTMENT_ROUTE = "appointment/{houseId}"
    const val LOGIN_ROUTE = "login"
    const val REGISTER_ROUTE = "register"
}

sealed class BuyerBottomNavItem(
    val route: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val labelResId: Int
) {
    object Home : BuyerBottomNavItem(
        route = BuyerDestinations.HOME_ROUTE,
        selectedIcon = Icons.Filled.Home,
        unselectedIcon = Icons.Outlined.Home,
        labelResId = R.string.nav_home
    )
    
    object Search : BuyerBottomNavItem(
        route = BuyerDestinations.SEARCH_ROUTE,
        selectedIcon = Icons.Filled.Search,
        unselectedIcon = Icons.Outlined.Search,
        labelResId = R.string.nav_search
    )
    
    object Favorite : BuyerBottomNavItem(
        route = BuyerDestinations.FAVORITE_ROUTE,
        selectedIcon = Icons.Filled.Favorite,
        unselectedIcon = Icons.Outlined.FavoriteBorder,
        labelResId = R.string.nav_favorite
    )
    
    object Profile : BuyerBottomNavItem(
        route = BuyerDestinations.PROFILE_ROUTE,
        selectedIcon = Icons.Filled.Person,
        unselectedIcon = Icons.Outlined.Person,
        labelResId = R.string.nav_profile
    )
    
    companion object {
        val items = listOf(Home, Search, Favorite, Profile)
    }
}
