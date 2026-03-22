package com.myanmarhome.buyer.features.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.myanmarhome.common.domain.model.House
import com.myanmarhome.common.ui.component.ErrorView
import com.myanmarhome.common.ui.component.LoadingView
import com.myanmarhome.common.ui.component.NetworkImage

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Myanmar Home") },
                actions = {
                    // TODO: City selector
                }
            )
        }
    ) { paddingValues ->
        when (val state = uiState) {
            is HomeUiState.Loading -> {
                LoadingView(modifier = Modifier.padding(paddingValues))
            }
            is HomeUiState.Success -> {
                HomeContent(
                    houses = state.houses,
                    modifier = Modifier.padding(paddingValues)
                )
            }
            is HomeUiState.Error -> {
                ErrorView(
                    message = state.message,
                    onRetry = { viewModel.loadHomeData() },
                    modifier = Modifier.padding(paddingValues)
                )
            }
        }
    }
}

@Composable
fun HomeContent(
    houses: List<House>,
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(houses) { house ->
            HouseCard(house = house)
        }
    }
}

@Composable
fun HouseCard(
    house: House,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        onClick = { /* TODO: Navigate to detail */ }
    ) {
        Column {
            NetworkImage(
                url = house.coverImage,
                contentDescription = house.title,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentScale = ContentScale.Crop
            )
            
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = house.title,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = "${house.price} ${house.priceUnit}",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.primary
                )
                Text(
                    text = "${house.rooms} | ${house.area}㎡ | ${house.location}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
