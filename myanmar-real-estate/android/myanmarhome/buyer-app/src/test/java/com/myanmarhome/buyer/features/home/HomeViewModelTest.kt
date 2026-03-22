package com.myanmarhome.buyer.features.home

import com.myanmarhome.common.domain.model.House
import com.myanmarhome.common.domain.model.HouseStatus
import com.myanmarhome.common.domain.model.TransactionType
import com.myanmarhome.common.domain.model.HouseType
import com.myanmarhome.common.domain.repository.HouseRepository
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.math.BigDecimal

@ExperimentalCoroutinesApi
class HomeViewModelTest {
    
    private val testDispatcher = UnconfinedTestDispatcher()
    private lateinit var houseRepository: HouseRepository
    private lateinit var viewModel: HomeViewModel
    
    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        houseRepository = mockk()
    }
    
    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }
    
    @Test
    fun `initial state is Loading`() = runTest {
        // Given
        coEvery { houseRepository.getRecommendHouses(any(), any()) } returns Result.success(emptyList())
        
        // When
        viewModel = HomeViewModel(houseRepository)
        
        // Then
        val initialState = viewModel.uiState.first()
        assertTrue(initialState is HomeUiState.Loading)
    }
    
    @Test
    fun `loadHomeData updates state to Success when repository returns data`() = runTest {
        // Given
        val mockHouses = listOf(
            createMockHouse("1"),
            createMockHouse("2")
        )
        coEvery { houseRepository.getRecommendHouses(any(), any()) } returns Result.success(mockHouses)
        
        // When
        viewModel = HomeViewModel(houseRepository)
        
        // Wait for coroutine to complete
        testDispatcher.scheduler.advanceUntilIdle()
        
        // Then
        val state = viewModel.uiState.first()
        assertTrue(state is HomeUiState.Success)
        assertEquals(2, (state as HomeUiState.Success).houses.size)
        coVerify { houseRepository.getRecommendHouses(null, 20) }
    }
    
    @Test
    fun `loadHomeData updates state to Error when repository fails`() = runTest {
        // Given
        val errorMessage = "Network error"
        coEvery { houseRepository.getRecommendHouses(any(), any()) } returns 
            Result.failure(RuntimeException(errorMessage))
        
        // When
        viewModel = HomeViewModel(houseRepository)
        
        // Wait for coroutine to complete
        testDispatcher.scheduler.advanceUntilIdle()
        
        // Then
        val state = viewModel.uiState.first()
        assertTrue(state is HomeUiState.Error)
        assertEquals(errorMessage, (state as HomeUiState.Error).message)
    }
    
    @Test
    fun `retry loads data again`() = runTest {
        // Given
        coEvery { houseRepository.getRecommendHouses(any(), any()) } returns Result.success(emptyList())
        viewModel = HomeViewModel(houseRepository)
        testDispatcher.scheduler.advanceUntilIdle()
        
        // When
        viewModel.loadHomeData()
        testDispatcher.scheduler.advanceUntilIdle()
        
        // Then
        coVerify(exactly = 2) { houseRepository.getRecommendHouses(any(), any()) }
    }
    
    private fun createMockHouse(id: String) = House(
        id = id,
        title = "Test House $id",
        coverImage = "",
        images = emptyList(),
        video = null,
        transactionType = TransactionType.Sale,
        houseType = HouseType.Apartment,
        price = BigDecimal(10000000),
        priceUnit = "万缅币",
        priceNote = null,
        area = 100.0,
        rooms = "3室2厅",
        floor = "5",
        totalFloors = 10,
        decoration = null,
        orientation = null,
        buildYear = null,
        description = null,
        highlights = emptyList(),
        facilities = emptyList(),
        address = "Test Address",
        district = com.myanmarhome.common.domain.model.District("tamwe", "Tamwe", null, "yangon"),
        community = null,
        latitude = 0.0,
        longitude = 0.0,
        nearby = emptyList(),
        propertyType = null,
        ownership = null,
        hasLoan = null,
        propertyCertificate = null,
        verificationStatus = com.myanmarhome.common.domain.model.VerificationStatus.Unverified,
        verifiedAt = null,
        verifiedBy = null,
        tags = emptyList(),
        agent = com.myanmarhome.common.domain.model.AgentInfo("1", "Test Agent", null, null, 5.0f, 10, "+959123456789"),
        publishTime = "",
        status = HouseStatus(true, false, 0, 0)
    )
}
