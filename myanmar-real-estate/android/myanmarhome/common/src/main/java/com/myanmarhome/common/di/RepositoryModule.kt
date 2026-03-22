package com.myanmarhome.common.di

import com.myanmarhome.common.data.repository.HomeRepositoryImpl
import com.myanmarhome.common.data.repository.HouseRepositoryImpl
import com.myanmarhome.common.domain.repository.HomeRepository
import com.myanmarhome.common.domain.repository.HouseRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    
    @Binds
    @Singleton
    abstract fun bindHomeRepository(
        impl: HomeRepositoryImpl
    ): HomeRepository
    
    @Binds
    @Singleton
    abstract fun bindHouseRepository(
        impl: HouseRepositoryImpl
    ): HouseRepository
}
