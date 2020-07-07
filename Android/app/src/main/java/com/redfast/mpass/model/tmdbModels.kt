package com.redfast.mpass.model

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.redfast.mpass.api.GenreVideos
import com.redfast.mpass.api.Genres
import com.redfast.mpass.api.TmdbApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class TmdbModels {
    private val tmdbApi = TmdbApi()

    fun fetchTvGenres(): LiveData<Genres> {
        val data = MutableLiveData<Genres>()
        GlobalScope.launch {
            tmdbApi.tvGetGenre()?.let {
                data.postValue(it)
            }
        }
        return data
    }

    fun fetchTvByGenre(genreId: Int): LiveData<GenreVideos> {
        val data = MutableLiveData<GenreVideos>()
        GlobalScope.launch {
            tmdbApi.tvGetGenreCollection(genreId)?.let {
                data.postValue(it)
            }
        }
        return data
    }
}