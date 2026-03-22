package com.myanmarhome.buyer

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
import com.myanmarhome.buyer.features.home.HomeScreen
import com.myanmarhome.buyer.features.profile.ProfileScreen
import com.myanmarhome.buyer.navigation.BuyerBottomNavItem
import com.myanmarhome.buyer.navigation.BuyerDestinations
import com.myanmarhome.common.ui.theme.MyanmarHomeTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyanmarHomeTheme {
                BuyerApp()
            }
        }
    }
}

@Composable
fun BuyerApp() {
    val navController = rememberNavController()
    
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentDestination = navBackStackEntry?.destination
            
            NavigationBar {
                BuyerBottomNavItem.items.forEach { item ->
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
            startDestination = BuyerDestinations.HOME_ROUTE,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(BuyerDestinations.HOME_ROUTE) {
                HomeScreen()
            }
            composable(BuyerDestinations.SEARCH_ROUTE) {
                Text("Search Screen")
            }
            composable(BuyerDestinations.FAVORITE_ROUTE) {
                Text("Favorite Screen")
            }
            composable(BuyerDestinations.PROFILE_ROUTE) {
                ProfileScreen()
            }
        }
    }
}
