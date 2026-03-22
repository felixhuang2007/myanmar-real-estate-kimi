package com.myanmarhome.agent

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.myanmarhome.agent.features.home.AgentHomeScreen
import com.myanmarhome.agent.features.house.HouseManageScreen
import com.myanmarhome.agent.features.profile.AgentProfileScreen
import com.myanmarhome.agent.navigation.AgentBottomNavItem
import com.myanmarhome.agent.navigation.AgentDestinations
import com.myanmarhome.common.ui.theme.MyanmarHomeTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyanmarHomeTheme {
                AgentApp()
            }
        }
    }
}

@Composable
fun AgentApp() {
    val navController = rememberNavController()
    
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentDestination = navBackStackEntry?.destination
            
            NavigationBar {
                AgentBottomNavItem.items.forEach { item ->
                    val selected = currentDestination?.hierarchy?.any { 
                        it.route == item.route 
                    } == true
                    
                    NavigationBarItem(
                        icon = { 
                            Icon(
                                imageVector = if (selected) item.selectedIcon else item.unselectedIcon,
                                contentDescription = stringResource(id = item.labelResId)
                            )
                        },
                        label = { Text(stringResource(id = item.labelResId)) },
                        selected = selected,
                        onClick = {
                            navController.navigate(item.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = AgentDestinations.HOME_ROUTE,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(AgentDestinations.HOME_ROUTE) {
                AgentHomeScreen()
            }
            composable(AgentDestinations.HOUSE_ROUTE) {
                HouseManageScreen()
            }
            composable(AgentDestinations.CUSTOMER_ROUTE) {
                Text("Customer Screen")
            }
            composable(AgentDestinations.APPOINTMENT_ROUTE) {
                Text("Appointment Screen")
            }
            composable(AgentDestinations.PROFILE_ROUTE) {
                AgentProfileScreen()
            }
        }
    }
}
