package com.myanmarhome.agent.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.House
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.House
import androidx.compose.material.icons.outlined.People
import androidx.compose.material.icons.outlined.Person
import androidx.compose.ui.graphics.vector.ImageVector
import com.myanmarhome.agent.R

object AgentDestinations {
    const val HOME_ROUTE = "home"
    const val HOUSE_ROUTE = "house"
    const val CUSTOMER_ROUTE = "customer"
    const val APPOINTMENT_ROUTE = "appointment"
    const val PROFILE_ROUTE = "profile"
    
    const val ADD_HOUSE_ROUTE = "add_house"
    const val EDIT_HOUSE_ROUTE = "edit_house/{houseId}"
    const val HOUSE_DETAIL_ROUTE = "house_detail/{houseId}"
    const val VERIFICATION_ROUTE = "verification/{houseId}"
    const val ACN_ROUTE = "acn"
    const val PERFORMANCE_ROUTE = "performance"
}

sealed class AgentBottomNavItem(
    val route: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val labelResId: Int
) {
    object Home : AgentBottomNavItem(
        route = AgentDestinations.HOME_ROUTE,
        selectedIcon = Icons.Filled.Home,
        unselectedIcon = Icons.Outlined.Home,
        labelResId = R.string.nav_home
    )
    
    object House : AgentBottomNavItem(
        route = AgentDestinations.HOUSE_ROUTE,
        selectedIcon = Icons.Filled.House,
        unselectedIcon = Icons.Outlined.House,
        labelResId = R.string.nav_house
    )
    
    object Customer : AgentBottomNavItem(
        route = AgentDestinations.CUSTOMER_ROUTE,
        selectedIcon = Icons.Filled.People,
        unselectedIcon = Icons.Outlined.People,
        labelResId = R.string.nav_customer
    )
    
    object Appointment : AgentBottomNavItem(
        route = AgentDestinations.APPOINTMENT_ROUTE,
        selectedIcon = Icons.Filled.CalendarMonth,
        unselectedIcon = Icons.Outlined.CalendarMonth,
        labelResId = R.string.nav_appointment
    )
    
    object Profile : AgentBottomNavItem(
        route = AgentDestinations.PROFILE_ROUTE,
        selectedIcon = Icons.Filled.Person,
        unselectedIcon = Icons.Outlined.Person,
        labelResId = R.string.nav_profile
    )
    
    companion object {
        val items = listOf(Home, House, Customer, Appointment, Profile)
    }
}
