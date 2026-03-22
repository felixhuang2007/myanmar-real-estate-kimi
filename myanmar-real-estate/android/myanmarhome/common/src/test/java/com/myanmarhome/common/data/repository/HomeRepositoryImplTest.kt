package com.myanmarhome.common.data.repository

import com.myanmarhome.common.data.remote.api.HomeApi
import com.myanmarhome.common.data.remote.api.ApiResponse
import com.myanmarhome.common.domain.model.City
import com.myanmarhome.common.domain.model.HomeData
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@ExperimentalCoroutinesApi
class HomeRepositoryImplTest {
    
    private lateinit var homeApi: HomeApi
    private lateinit var repository: HomeRepositoryImpl
    
    @Before
    fun setup() {
        homeApi = mockk()
        repository = HomeRepositoryImpl(homeApi)
    }
    
    @Test
    fun `getHomeData returns success when API call succeeds`() = runTest {
        // Given
        val mockData = HomeData(
            banners = emptyList(),
            quickEntries = emptyList(),
            recommendHouses = emptyList()
        )
        val mockResponse = ApiResponse(
            code = 200,
            message = "Success",
            data = mockData,
            timestamp = System.currentTimeMillis()
        )
        coEvery { homeApi.getHomeData(any()) } returns mockResponse
        
        // When
        val result = repository.getHomeData("yangon")
        
        // Then
        assertTrue(result.isSuccess)
        assertEquals(mockData, result.getOrNull())
        coVerify { homeApi.getHomeData("yangon") }
    }
    
    @Test
    fun `getHomeData returns failure when API call throws exception`() = runTest {
        // Given
        val exception = RuntimeException("Network error")
        coEvery { homeApi.getHomeData(any()) } throws exception
        
        // When
        val result = repository.getHomeData("yangon")
        
        // Then
        assertTrue(result.isFailure)
        assertEquals(exception, result.exceptionOrNull())
    }
    
    @Test
    fun `getCities returns success with city list`() = runTest {
        // Given
        val mockCities = listOf(
            City(code = "yangon", name = "仰光", nameEn = "Yangon", hot = true),
            City(code = "mandalay", name = "曼德勒", nameEn = "Mandalay", hot = false)
        )
        val mockResponse = ApiResponse(
            code = 200,
            message = "Success",
            data = mockCities,
            timestamp = System.currentTimeMillis()
        )
        coEvery { homeApi.getCities() } returns mockResponse
        
        // When
        val result = repository.getCities()
        
        // Then
        assertTrue(result.isSuccess)
        assertEquals(2, result.getOrNull()?.size)
        assertEquals("仰光", result.getOrNull()?.get(0)?.name)
    }
    
    @Test
    fun `getDistricts returns success for given city code`() = runTest {
        // Given
        val cityCode = "yangon"
        coEvery { homeApi.getDistricts(cityCode) } returns ApiResponse(
            code = 200,
            message = "Success",
            data = emptyList(),
            timestamp = System.currentTimeMillis()
        )
        
        // When
        val result = repository.getDistricts(cityCode)
        
        // Then
        assertTrue(result.isSuccess)
        coVerify { homeApi.getDistricts(cityCode) }
    }
}
