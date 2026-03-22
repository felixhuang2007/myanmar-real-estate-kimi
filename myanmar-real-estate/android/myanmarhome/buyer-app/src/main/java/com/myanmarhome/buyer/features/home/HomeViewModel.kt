package com.myanmarhome.buyer.features.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.myanmarhome.common.domain.model.House
import com.myanmarhome.common.domain.repository.HouseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed class HomeUiState {
    object Loading : HomeUiState()
    data class Success(val houses: List<House>) : HomeUiState()
    data class Error(val message: String) : HomeUiState()
}

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val houseRepository: HouseRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()
    
    init {
        loadHomeData()
    }
    
    fun loadHomeData() {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            
            houseRepository.getRecommendHouses(cityCode = null, limit = 20)
                .onSuccess { houses ->
                    _uiState.value = HomeUiState.Success(houses)
                }
                .onFailure { error ->
                    _uiState.value = HomeUiState.Error(error.message ?: "加载失败")
                }
        }
    }
}
